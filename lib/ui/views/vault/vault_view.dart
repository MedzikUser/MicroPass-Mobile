import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/auth/login_view.dart';
import 'package:micropass/ui/views/vault/add_item_view.dart';
import 'package:micropass/ui/views/vault/unlock_view.dart';
import 'package:micropass/ui/widgets/vault/item_widget.dart';
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

  late List<Widget> widgets = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    // get unix time of the last vault sync
    final lastSyncString =
        await Storage.read(StorageKey.ciphersLastSync) ?? '0';
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

          final cipherJson = cipher.toJsonFull();

          // write the cipher to the cache
          await Storage.write(
            StorageKey.cipherCache(cipherId),
            cipherJson,
          );
        }
      }

      if (ciphersList.deleted != null) {
        // read the cached cipher IDs
        final cachedCipherIds = await Storage.read(StorageKey.cachedCipherIds);

        // parse the cached cipher IDs
        final cipherIds = jsonDecode(cachedCipherIds!);

        for (final cipherId in ciphersList.deleted!) {
          // remove the cipher from map
          cipherIds.remove(cipherId);

          // delete the cipher from cache
          Storage.delete(StorageKey.cipherCache(cipherId));
        }

        // encode the cipher IDs
        final newCipherIds = jsonEncode(cipherIds);

        // write the new cipher IDs
        await Storage.write(StorageKey.cachedCipherIds, newCipherIds);
      }
    } catch (err, stacktrace) {
      debugCatch(err, stacktrace);
      if (mounted) Toast.show(context, content: err.toString());
    }

    // if it is a partial vault sync
    if (lastSync != 0) {
      // read the cached ciphers IDs
      final cachedCipherIds = await Storage.read(StorageKey.cachedCipherIds);

      if (cachedCipherIds != null) {
        // parse the cached ciphers IDs
        final cachedCipherIdsList = jsonDecode(cachedCipherIds);

        for (final cipherId in cachedCipherIdsList) {
          // read the cipher from the cache
          final cipherJson =
              await Storage.read(StorageKey.cipherCache(cipherId));

          // parse the cipher data
          final cipherJsonMap = jsonDecode(cipherJson!);

          // if absent, place cipher in ciphers map
          ciphers.putIfAbsent(
            '$cipherId',
            () => Cipher.fromMap(cipherJsonMap),
          );
        }
      }
    }

    var cipherIds = [];

    widgets = [];

    for (var cipher in ciphers.entries) {
      widgets.add(ItemWidget(cipher: cipher.value));
      cipherIds.add(cipher.key);
    }

    await Storage.write(StorageKey.cachedCipherIds, jsonEncode(cipherIds));

    await Storage.write(StorageKey.ciphersLastSync, unixNow);

    setState(() {
      loading = false;
    });
  }

  Future<void> lock() async {
    await Storage.dropMemory();

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
