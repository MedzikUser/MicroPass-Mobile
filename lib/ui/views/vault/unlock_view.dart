import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/auth/login_view.dart';
import 'package:micropass/ui/views/vault/vault_view.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass/utils/toast.dart';
import 'package:micropass/utils/utils.dart';
import 'package:micropass_api/micropass_api.dart';

class UnlockView extends StatefulWidget {
  const UnlockView({super.key});

  @override
  createState() => _UnlockViewState();
}

class _UnlockViewState extends State<UnlockView> {
  final _formKey = GlobalKey<FormState>();

  // create a password controller
  final passwordController = TextEditingController();

  var loading = false;

  var passwordVisible = false;
  void handlePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Future<void> unlock() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      try {
        // read email from storage
        final email = await Storage.read(StorageKey.email);
        // read access token from storage
        final refreshToken = await Storage.read(StorageKey.refreshToken);

        // generate new access token
        final accessToken = await IdentityApi().refreshToken(refreshToken!);
        // write access token to storage
        await Storage.write(StorageKey.accessToken, accessToken.accessToken!);

        // get the encryption key
        final encryptionKey = await UserApi(accessToken.accessToken!)
            .encryptionKey(email!, passwordController.text);
        // write the encryption key to storage
        await Storage.write(StorageKey.encryptionKey, encryptionKey);

        // go to the vault view
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VaultView(),
          ),
        );

        return;
      } catch (err, stacktrace) {
        debugCatch(err, stacktrace);

        if (mounted) {
          Toast.show(
            context,
            content: FlutterI18n.translate(
              context,
              'vault.unlock_page.invalid_password',
            ),
          );
        }
      }

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> logout() async {
    await Storage.dropAll();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroPass'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip:
                FlutterI18n.translate(context, 'vault.app_bar.tooltip.logout'),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'form.hint.master_password',
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: handlePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: !passwordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your master password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              I18nText(
                'vault.unlock_page.text',
                child: Text(
                  '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 15),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: unlock,
                      child: I18nText('vault.unlock_page.button'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
