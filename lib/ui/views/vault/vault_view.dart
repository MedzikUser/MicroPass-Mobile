import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/auth/login_view.dart';
import 'package:micropass/ui/views/vault/add_item_view.dart';
import 'package:micropass/ui/views/vault/unlock_view.dart';
import 'package:micropass/ui/widgets/vault/item_widget.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass_api/micropass_api.dart';

class VaultView extends StatefulWidget {
  const VaultView({super.key});

  @override
  createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView> {
  late CiphersApi client;

  var loading = true;

  late List<Widget> widgets = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    final lastSyncString =
        await Storage.read(StorageKey.ciphersLastSync) ?? '0';
    final lastSync = int.parse(lastSyncString);

    final unixNow =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();

    final Map<String, Cipher> ciphers = {};

    final accessToken = await Storage.read(StorageKey.accessToken);
    final encryptionKey = await Storage.read(StorageKey.encryptionKey);

    client = CiphersApi(accessToken!, encryptionKey!);

    try {
      final ciphersList = await client.list(lastSync);
      if (ciphersList.updated != null) {
        for (final cipherId in ciphersList.updated!) {
          final cipher = await client.take(cipherId);

          ciphers.addAll({cipherId: cipher});

          await Storage.write(
              StorageKey.cipherCache(cipherId), jsonEncode(cipher));
        }
      }
    } catch (err) {
      print(err);
    }

    final cachedCipherIds = await Storage.read(StorageKey.cachedCipherIds);
    if (cachedCipherIds != null) {
      final cachedCipherIdsList = jsonDecode(cachedCipherIds);

      for (final cipherId in cachedCipherIdsList) {
        final cipherJson = await Storage.read(StorageKey.cipherCache(cipherId));

        final cipherJsonString = jsonDecode(cipherJson!);
        final cipherJsonMap = jsonDecode(cipherJsonString);

        ciphers.putIfAbsent(
          '$cipherId',
          () => Cipher.fromMap(cipherJsonMap),
        );
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
