import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:app_links/app_links.dart';
import 'package:email_validator/email_validator.dart';
import 'package:opennutritracker/features/auth/validate_password.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'forgot_password_screen.dart';
import 'reset_password_screen.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/hive_db_provider.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/export_import_bloc.dart';
import 'package:opennutritracker/features/settings/domain/usecase/import_data_supabase_usecase.dart';
import 'package:opennutritracker/services/firebase_messaging_service.dart';
import 'package:opennutritracker/services/local_notifications_service.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_user_usecase.dart';
import 'package:opennutritracker/core/domain/entity/user_role_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_macro_goal_usecase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  bool _loading = false;
  final supabase = Supabase.instance.client;

  /// Navigate to the home screen after a successful sign‑in.
  void _navigateHome() =>
      Navigator.of(context).pushReplacementNamed(NavigationOptions.mainRoute);

  /// Display an error message and log it.
  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$error')));
    Logger('LoginScreen').warning('Auth error', error);
  }

  /// Configure deep‑link handling (password‑reset flow).
  void _configDeepLink() {
    final links = AppLinks();

    links.uriLinkStream.listen((Uri? uri) async {
      if (uri == null || uri.host != 'login-callback') return;

      try {
        await supabase.auth.getSessionFromUrl(uri);
        if (!mounted) return;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
      } catch (e) {
        debugPrint('Deep‑link error: $e');
      }
    });
  }

  /// Attempt to authenticate with e‑mail / password.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    // Capture everything that needs context before the async gap
    final l10n = S.of(context);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      if (res.session != null) {
        // ── 1. Prépare Hive pour le user (nécessaire à l’import) + add user profile if needed
        final hive = locator<HiveDBProvider>();
        await hive.initForUser(res.user?.id);
        await registerUserScope(hive);

        final getUser = locator<GetUserUsecase>();

        final hasProfile = await getUser.hasUserData();
        if (!hasProfile) {
          final userId = res.user?.id;
          final addUser = locator<AddUserUsecase>();

          try {
            final List<Map<String, dynamic>> rows = await supabase
                .from('users')
                .select('display_name, role')
                .eq('id', userId!);

            if (rows.isEmpty) {
              debugPrint('No users found with ID $userId');
              return;
            }

            if (rows.isNotEmpty) {
              final row = rows.first;
              final roleStr = (row['role'] as String?) ?? 'student';
              final displayName =
                  (row['display_name'] as String?) ?? 'John Doe';
              final role = roleStr == 'coach'
                  ? UserRoleEntity.coach
                  : UserRoleEntity.student;
              final defaultUser = UserEntity(
                name: displayName,
                birthday: DateTime(2000, 1, 1),
                heightCM: 180,
                weightKG: 80,
                gender: UserGenderEntity.male,
                goal: UserWeightGoalEntity.maintainWeight,
                pal: UserPALEntity.active,
                role: role,
                profileImagePath: null,
              );

              await addUser.addUser(defaultUser);
            }
          } catch (e, stackTrace) {
            debugPrint('Error when getting profile from Supabase: $e');
            debugPrint('Stack trace: $stackTrace');
            await supabase.auth.signOut();
            return;
          }
        }

        // ── 2. Tente l’import
        final importData = locator<ImportDataSupabaseUsecase>();
        final importSuccessful = await importData.importData(
          ExportImportBloc.exportZipFileName,
          ExportImportBloc.userActivityJsonFileName,
          ExportImportBloc.userIntakeJsonFileName,
          ExportImportBloc.trackedDayJsonFileName,
          ExportImportBloc.userWeightJsonFileName,
          ExportImportBloc.recipesJsonFileName,
          ExportImportBloc.userJsonFileName,
        );

        // ── 3. ERREUR D’IMPORT  →  on déconnecte la session
        if (!importSuccessful) {
          try {
            await supabase.auth.signOut(); // libère le « verrou »
          } catch (e, s) {
            Logger('LoginScreen').warning('Forced sign-out failed', e, s);
          }

          // Nettoie la base locale (facultatif mais recommandé)
          await hive.initForUser(null);
          await registerUserScope(hive);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).exportImportErrorLabel)),
            );
          }
          return; // reste sur l’écran de login
        }

        // Récuperer les objectifs si student
        final user = await getUser.getUserData();
        if (user.role == UserRoleEntity.student) {
          try {
            final user = await locator.get<GetUserUsecase>().getUserData();
            if (user.role == UserRoleEntity.student) {
              await locator.get<AddMacroGoalUsecase>().addMacroGoalFromCoach();
              Logger('LoginScreen')
                  .fine('[✅] Objectifs macro mis à jour depuis Supabase');
            }
          } catch (e, stack) {
            Logger('LoginScreen')
                .warning('[❌] Erreur lors de la mise à jour des macros : $e');
            Logger('LoginScreen').warning(stack.toString());
            return;
          }
        }

        // ✅ Init Firebase Messaging & Local Notifications après login
        final localNotificationsService = LocalNotificationsService.instance();
        await localNotificationsService.init();

        final firebaseMessagingService = FirebaseMessagingService.instance();
        await firebaseMessagingService.init(
          localNotificationsService: localNotificationsService,
        );

        // ── 4. Tout est OK  →  on passe à l’app
        _navigateHome();
      }
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();

      if (!mounted) return; // context might be gone

      if (message.contains('error granting user')) {
        _showError(l10n.loginAlreadySignedIn);
      } else {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _configDeepLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).loginTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelText: S.of(context).loginEmailLabel,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? S.of(context).loginEmailRequired
                    : (EmailValidator.validate(v.trim())
                        ? null
                        : S.of(context).loginEmailInvalid),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: S.of(context).loginPasswordLabel,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => validatePassword(context, value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(S.of(context).loginButton),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: Text(S.of(context).loginForgotPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
