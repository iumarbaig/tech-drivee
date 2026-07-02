import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:tech_drive/screens_for_workers/worker_home_screen.dart'; // ✅ Add this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 800), () async {
      final user = _auth.currentUser;

      if (user != null) {
        // ✅ Check if user is a worker
        bool isWorkerUser = await _auth.isWorker();

        if (mounted) {
          if (isWorkerUser) {
            // Worker - go to worker home screen
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WorkerHomeScreen())
            );
          } else {
            // Customer - go to customer home screen
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen())
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen())
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }
}