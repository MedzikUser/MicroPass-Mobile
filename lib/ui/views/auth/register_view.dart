import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/auth/login_view.dart';
import 'package:micropass/utils/toast.dart';
import 'package:micropass_api/micropass_api.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var masterPasswordController = TextEditingController();
  var masterPasswordHintController = TextEditingController();

  var passwordVisible = false;
  void handlePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  final client = IdentityApi();

  var loading = false;

  Future<void> handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      final email = emailController.text;
      final masterPassword = masterPasswordController.text;
      final masterPasswordHint = masterPasswordHintController.text;

      try {
        await client.register(email, masterPassword, masterPasswordHint);

        if (!mounted) return;

        Toast.show(
          context,
          content:
              FlutterI18n.translate(context, 'toast.registered_successfully'),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginView(),
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
              'register.title',
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

                  // Re-type Master Password
                  TextFormField(
                    validator: (value) => value != masterPasswordController.text
                        ? FlutterI18n.translate(
                            context,
                            'form.invalid.password_do_not_match',
                          )
                        : null,
                    maxLines: 1,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: FlutterI18n.translate(
                        context,
                        'form.hint.master_password_retype',
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Master Password Hint
                  TextFormField(
                    controller: masterPasswordHintController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: FlutterI18n.translate(
                        context,
                        'form.hint.master_password_hint',
                      ),
                      prefixIcon: const Icon(Icons.question_mark),
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
                          onPressed: handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                          ),
                          child: I18nText('register.button'),
                        ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      I18nText('register.question'),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        ),
                        child: I18nText('register.question_link'),
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
