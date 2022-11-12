import 'package:flutter/material.dart';
import 'package:micropass/ui/views/auth/login_view.dart';
import 'package:micropass/ui/views/vault/unlock_view.dart';

class HomeView extends StatelessWidget {
  final bool loggedIn;

  const HomeView({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loggedIn ? const UnlockView() : const LoginView(),
    );
  }
}
