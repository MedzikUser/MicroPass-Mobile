import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:micropass/ui/views/vault/edit_item_view.dart';
import 'package:micropass/utils/custom_styles.dart';
import 'package:micropass/utils/storage.dart';
import 'package:micropass/utils/toast.dart';
import 'package:micropass_api/micropass_api.dart';

class ItemView extends StatefulWidget {
  final Cipher cipher;

  const ItemView({super.key, required this.cipher});

  @override
  createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  Future<void> copy(String data) async {
    await Clipboard.setData(ClipboardData(text: data));

    if (!mounted) return;
    Toast.show(
      context,
      content: FlutterI18n.translate(context, 'toast.copied_to_clipboard'),
    );
  }

  String parseTime(int unix) {
    return DateTime.fromMillisecondsSinceEpoch(unix * 1000).toString();
  }

  Future<void> delete() async {
    final accessToken = await Storage.read(StorageKey.accessToken);
    final client = CiphersApi(accessToken!, '');

    await client.delete(widget.cipher.id!);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cipher.name),
        actions: [
          IconButton(
            onPressed: delete,
            icon: const Icon(Icons.delete_outline),
            tooltip:
                FlutterI18n.translate(context, 'vault.options_modal.delete'),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            I18nText(
              'vault.section.item_informations',
              child: Text('', style: CustomStyles.sectionTextStyle(context)),
            ),
            ItemWidget(
              title: FlutterI18n.translate(context, 'vault.item.name'),
              subtitle: widget.cipher.name,
              copy: false,
            ),
            ItemWidget(
              title: FlutterI18n.translate(context, 'vault.item.username'),
              subtitle: widget.cipher.username,
            ),
            ItemWidget(
              title: FlutterI18n.translate(context, 'vault.item.password'),
              subtitle: widget.cipher.password,
              secret: true,
            ),
            const SizedBox(height: 10),
            I18nText(
              'vault.section.other',
              child: Text('', style: CustomStyles.sectionTextStyle(context)),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(
                    text: 'ID: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.cipher.id)
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(
                    text: 'Created: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: parseTime(widget.cipher.created!))
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(
                    text: 'Updated: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: parseTime(widget.cipher.updated!))
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditItemView(
                cipher: widget.cipher,
              ),
            ),
          );
        },
        tooltip:
            FlutterI18n.translate(context, 'vault.app_bar.tooltip.edit_item'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class ItemWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool copy;
  final bool secret;

  const ItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.copy = true,
    this.secret = false,
  });

  @override
  createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  var secretVisible = false;
  void handleSecretVisibility() {
    setState(() {
      secretVisible = !secretVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (widget.subtitle ?? '').isNotEmpty
        ? ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            // visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            title: Text(
              widget.title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            subtitle: Text(
              widget.secret
                  ? !secretVisible
                      ? '••••••••••'
                      : widget.subtitle!
                  : widget.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: widget.secret
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: Icon(
                        secretVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: handleSecretVisibility,
                    ),
                    IconButton(
                      onPressed: () async {
                        Clipboard.setData(ClipboardData(text: widget.subtitle));

                        Toast.show(
                          context,
                          content: FlutterI18n.translate(
                              context, 'toast.copied_to_clipboard'),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ])
                : widget.copy
                    ? IconButton(
                        onPressed: () async {
                          Clipboard.setData(
                              ClipboardData(text: widget.subtitle));

                          Toast.show(
                            context,
                            content: FlutterI18n.translate(
                                context, 'toast.copied_to_clipboard'),
                          );
                        },
                        icon: const Icon(Icons.copy),
                      )
                    : null,
          )
        : const SizedBox();
  }
}
