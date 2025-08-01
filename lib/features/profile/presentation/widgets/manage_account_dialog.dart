import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/domain/usecase/add_config_usecase.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/utils/hive_db_provider.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';

class ManageAccountDialog extends StatefulWidget {
  const ManageAccountDialog({super.key});

  @override
  State<ManageAccountDialog> createState() => _ManageAccountDialogState();
}

class _ManageAccountDialogState extends State<ManageAccountDialog> {
  bool _syncEnabled = true;
  final _addConfig = locator<AddConfigUsecase>();
  final _configRepo = locator<ConfigRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _configRepo.getSupabaseSyncEnabled();
    setState(() => _syncEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).manageAccountTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).manageAccountDescription),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(S.of(context).manageAccountEnableSync),
              value: _syncEnabled,
              onChanged: (value) {
                setState(() => _syncEnabled = value);
                _addConfig.setSupabaseSyncEnabled(value);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _confirmDelete(context),
              child: Text(S.of(context).manageAccountDelete),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogOKLabel),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).manageAccountConfirmTitle),
        content: Text(S.of(context).manageAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.of(context).manageAccountConfirmAction),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (!mounted) return;
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not connected.")),
      );
      return;
    }

    try {
      final response = await supabase.functions.invoke('delete_my_account');
      if (!mounted) return;

      if (response.status == 200) {
        final hive = locator<HiveDBProvider>();
        await hive.deleteCurrentUserDatabase();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account successfully deleted.")),
        );

        try {
          // ▸ 1. Déconnexion Supabase
          try {
            debugPrint('Appel supabase.auth.signOut()');
            await supabase.auth.signOut();
          } catch (err, stack) {
            debugPrint('Erreur pendant signOut: $err\n$stack');
          }

          final hive = locator<HiveDBProvider>();
          await hive.initForUser(null);
          await registerUserScope(hive);
          if (!mounted) return;

          // ▸ 2. Ferme le loader
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);
          if (!mounted) return;

          // ▸ 3. Redirige vers la page login
          Navigator.of(context)
              .pushReplacementNamed(NavigationOptions.loginRoute);
          debugPrint('safeSignOut terminé → retour login.');
        } catch (err, stack) {
          debugPrint('Erreur pendant signOut: $err\n$stack');
        }
      } else {
        final errorMessage = response.data?['error'] ?? 'Unknown error';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: $errorMessage")),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error deleting account: $e\n$stackTrace");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred.")),
      );
    }
  }
}
