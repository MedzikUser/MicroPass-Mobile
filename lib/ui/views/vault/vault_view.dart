import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/auth/login_view.dart';
import 'package:micropass/ui/views/vault/add_item_view.dart';
import 'package:micropass/ui/views/vault/unlock_view.dart';
import 'package:micropass/ui/widgets/vault/item_widget.dart';
import 'package:micropass/utils/db.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass/utils/toast.dart';
import 'package:micropass/utils/utils.dart';
import 'package:micropass_api/micropass_api.dart';

class VaultView extends StatefulWidget {
  const VaultView({super.key});

  @override
  createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView> {
  var loading = true;

  List<Widget> widgets = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    // get unix time of the last vault sync
    final lastSyncString = await Storage.read(StorageKey.lastSync) ?? '0';
    final lastSync = int.parse(lastSyncString);

    // current unix time
    final unixNow =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();

    // read the user access token
    final accessToken = await Storage.read(StorageKey.accessToken);
    // read the encryption key
    final encryptionKey = await Storage.read(StorageKey.encryptionKey);

    // create the api client
    final client = CiphersApi(accessToken!, encryptionKey!);

    // ciphers map, to which all ciphers will be added
    final Map<String, Cipher> ciphers = {};

    try {
      // get the ciphers list from the api
      final ciphersList = await client.list(lastSync);

      if (ciphersList.updated != null) {
        for (final cipherId in ciphersList.updated!) {
          // get the cipher info from the api
          final cipher = await client.take(cipherId);

          // add the cipher to the ciphers map
          ciphers.addAll({cipherId: cipher});

          CipherDB.insert(cipher);
        }
      }

      if (ciphersList.deleted != null) {
        for (final cipherId in ciphersList.deleted!) {
          // delete the cipher from app database
          CipherDB.delete(cipherId);
        }
      }
    } catch (err, stacktrace) {
      debugCatch(err, stacktrace);
      if (mounted) Toast.show(context, content: err.toString());
    }

    // if it is a partial vault sync
    if (lastSync != 0) {
      // read the cached ciphers IDs
      final cachedCipherIds = (await CipherDB.toMap()).keys;

      for (final cipherId in cachedCipherIds) {
        // read the cipher from the cache
        final cipher = await CipherDB.get(cipherId);

        // if absent, place cipher in ciphers map
        ciphers.putIfAbsent(
          '$cipherId',
          () => cipher,
        );
      }
    }

    // the list will contain all the cipher IDs that are in the ciphers map
    var cipherIds = [];

    // clear the widgets list
    widgets = [];

    // iterate over the ciphers map
    for (var cipher in ciphers.entries) {
      // add the cipher to the widgets list
      widgets.add(ItemWidget(cipher: cipher.value));
      // add the cipher ID to the cipher IDs list
      cipherIds.add(cipher.key);
    }

    // write the last sync unix time to the cache
    await Storage.write(StorageKey.lastSync, unixNow);

    setState(() {
      loading = false;
    });
  }

  Future<void> lock() async {
    // drop all secrets from memory
    await Storage.dropMemory();

    // navigate to locked view
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UnlockView(),
      ),
    );
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
        title: Row(children: [
          const Icon(Icons.lock),
          const SizedBox(width: 8),
          I18nText('vault.app_bar.title'),
        ]),
        actions: [
          IconButton(
            onPressed: lock,
            icon: const Icon(Icons.lock_outline),
            tooltip:
                FlutterI18n.translate(context, 'vault.app_bar.tooltip.lock'),
          ),
          const SizedBox(
            width: 8,
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip:
                FlutterI18n.translate(context, 'vault.app_bar.tooltip.logout'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _init,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: loading
                ? [const Center(child: CircularProgressIndicator())]
                : widgets,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemView()),
          );
        },
        tooltip:
            FlutterI18n.translate(context, 'vault.app_bar.tooltip.add_item'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
