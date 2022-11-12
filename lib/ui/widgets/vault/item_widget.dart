import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
      title: Text(cipher.name),
      subtitle: Text(cipher.username ?? ''),
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

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(cipher.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                client.delete(cipher.id!);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
              ),
              child: I18nText('vault.dialog.delete'),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: I18nText('vault.dialog.close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
