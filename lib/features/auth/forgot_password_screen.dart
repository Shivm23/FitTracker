import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:email_validator/email_validator.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

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

      Navigator.of(context).pop();
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
              Card(
                color: Colors.amber.shade100,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black87),
                          children: [
                              TextSpan(
                                text: S.of(context).forgotPasswordHelp,
                              ),
                              TextSpan(
                                text: S.of(context).websiteLabel,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final url = Uri.parse(
                                        "https://atlas-tracker.fr/auth/forgot-password");
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    NavigationOptions.loginRoute,
                    (route) => false,
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
