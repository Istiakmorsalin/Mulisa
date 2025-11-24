import 'package:flutter/material.dart';
import 'package:mulisa/features/auth/view/login_page.dart';
import 'package:mulisa/core/config.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash';
  final AppConfig config;
  const SplashPage({super.key, required this.config});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120, // optional size
              width: 120,
            ),

            const SizedBox(height: 20),

            Text(
              "Welcome to ${widget.config.appTitle}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
