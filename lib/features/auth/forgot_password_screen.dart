import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:email_validator/email_validator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'atlas-tracker://login-callback',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).forgotPasswordEmailSent),
        ),
      );

      // 👉 no more push to ResetPasswordScreen here
      Navigator.of(context).pop(); // or pushNamed(loginRoute)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${S.of(context).forgotPasswordSendError} $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).forgotPasswordTitle)),
      body: Padding(
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
                  labelText: S.of(context).forgotPasswordEmailLabel,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? S.of(context).loginEmailRequired
                    : (EmailValidator.validate(v.trim())
                        ? null
                        : S.of(context).loginEmailInvalid),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: _loading ? null : _sendResetEmail,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(S.of(context).forgotPasswordButton),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                    NavigationOptions.loginRoute, // your login route
                    (route) => false, // remove everything else from the stack
                  ),
                  child: Text(S.of(context).forgotPasswordBackToLogin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
