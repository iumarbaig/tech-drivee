import 'package:flutter/material.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: const Center(
        child: Text(
          "No notifications available",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
