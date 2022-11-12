import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/auth/register_view.dart';
import 'package:micropass/ui/views/vault/vault_view.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass/utils/toast.dart';
import 'package:micropass_api/micropass_api.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var masterPasswordController = TextEditingController();

  var passwordVisible = false;
  void handlePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  final client = IdentityApi();

  var loading = false;

  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      final email = emailController.text;
      final masterPassword = masterPasswordController.text;

      try {
        final response = await client.login(email, masterPassword);

        final accessToken = response.accessToken!;
        final refreshToken = response.refreshToken!;

        await Storage.insert(StorageKey.email, email);
        await Storage.insert(StorageKey.accessToken, accessToken);
        await Storage.insert(StorageKey.refreshToken, refreshToken);

        final encryptionKey =
            await UserApi(accessToken).encryptionKey(masterPassword, email);

        await Storage.insert(StorageKey.encryptionKey, encryptionKey);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VaultView(),
          ),
        );
      } catch (err) {
        Toast.show(context, content: err.toString());
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.android,
              size: 100,
            ),

            // Title
            I18nText(
              'signin.title',
              child: const Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
            ),
            const SizedBox(height: 40),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email
                  TextFormField(
                    controller: emailController,
                    validator: (value) => EmailValidator.validate(value!)
                        ? null
                        : FlutterI18n.translate(context, 'form.invalid.email'),
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText:
                          FlutterI18n.translate(context, 'form.hint.email'),
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Master Password
                  TextFormField(
                    controller: masterPasswordController,
                    validator: (value) => value!.isEmpty
                        ? FlutterI18n.translate(context, 'form.invalid.empty')
                        : null,
                    maxLines: 1,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: FlutterI18n.translate(
                        context,
                        'form.hint.master_password',
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: handlePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In Button
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                          ),
                          child: I18nText(
                            'signin.button',
                            child: const Text(
                              '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      I18nText(
                        'signin.question',
                        child: const Text(''),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterView(),
                          ),
                        ),
                        child: I18nText(
                          'signin.question_link',
                          child: const Text(''),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
