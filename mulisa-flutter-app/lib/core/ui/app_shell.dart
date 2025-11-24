import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBack;

  const AppShell({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.bottom,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'MULISA'),
        centerTitle: true,
        automaticallyImplyLeading: showBack,
        actions: actions,
        bottom: bottom,
        // You can style via ThemeData.appBarTheme in AppConfig.theme
      ),
      body: child,
    );
  }
}
