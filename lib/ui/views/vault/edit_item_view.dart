import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/utils/custom_colors.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass_api/micropass_api.dart';

class EditItemView extends StatefulWidget {
  final Cipher cipher;

  const EditItemView({super.key, required this.cipher});

  @override
  createState() => _EditItemViewState();
}

class _EditItemViewState extends State<EditItemView> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late CiphersApi client;

  @override
  void initState() {
    nameController.text = widget.cipher.name;
    usernameController.text = widget.cipher.username ?? '';
    passwordController.text = widget.cipher.password ?? '';

    () async {
      final accessToken = await Storage.read(StorageKey.accessToken);
      final encryptionKey = await Storage.read(StorageKey.encryptionKey);

      client = CiphersApi(accessToken!, encryptionKey!);
    }();

    super.initState();
  }

  var passwordVisible = false;
  void handlePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  var loading = false;

  Future<void> handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      final name = nameController.text;
      final username = usernameController.text;
      final password = passwordController.text;

      await client.update(
        widget.cipher.id!,
        Cipher(
          type: CipherType.login,
          name: name,
          username: username,
          password: password,
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I18nText('vault.update_item.app_bar_text'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              I18nText(
                'vault.section.item_informations',
                child: Text('', style: CustomColors.sectionTextStyle(context)),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: nameController,
                validator: (value) => value!.isEmpty
                    ? FlutterI18n.translate(context, 'form.invalid.empty')
                    : null,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, 'form.hint.name'),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: usernameController,
                validator: (value) => value!.isEmpty
                    ? FlutterI18n.translate(context, 'form.invalid.empty')
                    : null,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText:
                      FlutterI18n.translate(context, 'form.hint.username'),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                maxLines: 1,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'form.hint.password',
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        // TODO password generator
                        onPressed: () => {},
                      ),
                      IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: handlePasswordVisibility,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: handleUpdate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                      ),
                      child: I18nText('vault.update_item.button'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
