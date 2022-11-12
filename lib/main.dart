import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:micropass/theme.dart';
import 'package:micropass/ui/views/home/home_view.dart';
import 'package:micropass/utils/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final refreshToken = await Storage.read(StorageKey.refreshToken);

  runApp(MyApp(loggedIn: refreshToken != null));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      themeCollection: themeCollection,
      // TODO detect system theme
      defaultThemeId: AppThemes.dark,
      builder: (context, theme) {
        return MaterialApp(
          title: 'MicroPass',
          theme: theme,
          home: HomeView(loggedIn: loggedIn),
          localizationsDelegates: [
            FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                fallbackFile: 'en_US',
                basePath: 'assets/i18n',
              ),
            ),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
        );
      },
    );
  }
}
