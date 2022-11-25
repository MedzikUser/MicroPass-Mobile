import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/vault/edit_item_view.dart';
import 'package:micropass/ui/views/vault/item_view.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass_api/micropass_api.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({super.key, required this.cipher});

  final Cipher cipher;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(cipher.data.name),
      subtitle: Text(cipher.data.typedFields!.username ?? ''),
      trailing: IconButton(
        onPressed: () => _dialogBuilder(context, cipher),
        icon: const Icon(Icons.more_horiz),
      ),
      leading: const Icon(Icons.account_box, size: 40),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemView(cipher: cipher),
          ),
        );
      },
    );
  }
}

Future<void> _dialogBuilder(BuildContext context, Cipher cipher) async {
  final accessToken = await Storage.read(StorageKey.accessToken);
  final client = CiphersApi(accessToken!, '');

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 170,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: I18nText('vault.options_modal.view'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemView(cipher: cipher),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: I18nText('vault.options_modal.edit'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditItemView(cipher: cipher),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: I18nText('vault.options_modal.delete'),
              onTap: () {
                client.delete(cipher.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
