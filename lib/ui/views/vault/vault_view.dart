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

  late List<Cipher> ciphers = [];
  late List<Widget> widgets = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    // TODO: Implement ciphers cache.

    //final lastSync = await Storage.read(StorageKey.ciphersLastSync);
    final unixNow =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();

    await Storage.write(StorageKey.ciphersLastSync, unixNow);

    const lastSync = null;

    ciphers = [];

    // final ciphersJsonText = await Storage.read(StorageKey.cachedCiphers);
    // if (ciphersJsonText != null) {
    //   final ciphersJson = jsonDecode(ciphersJsonText);

    //   for (var cipher in ciphersJson["ciphers"]) {
    //     ciphers.add(Cipher.fromMap(cipher));
    //   }

    //   if (ciphers.isEmpty) {
    //     setState(() {
    //       loading = false;
    //     });
    //   }
    // }

    final accessToken = await Storage.read(StorageKey.accessToken);
    final encryptionKey = await Storage.read(StorageKey.encryptionKey);

    client = CiphersApi(accessToken!, encryptionKey!);

    final ciphersList = await client.list(lastSync);
    for (var cipherId in ciphersList) {
      final cipher = await client.take(cipherId);

      ciphers.add(cipher);
    }

    // await Storage.write(StorageKey.cachedCipherIds, jsonEncode(ciphersList));

    widgets = [];
    for (var cipher in ciphers) {
      widgets.add(ItemWidget(cipher: cipher));
    }

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
