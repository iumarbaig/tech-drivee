import 'dart:async';
import 'package:flutter/material.dart';
import 'avaliable_offers_screen.dart';

class FindingWorkerScreen extends StatefulWidget {
  final String orderId;

  const FindingWorkerScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<FindingWorkerScreen> createState() => _FindingWorkerScreenState();
}

class _FindingWorkerScreenState extends State<FindingWorkerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController anim;
  final brand = const Color(0xFFCCFD04);

  @override
  void initState() {
    super.initState();

    anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AvailableOffersScreen(
            orderId: widget.orderId,
            serviceType: '', // ✅ updated
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: brand,
        title: const Text(
          "Finding Worker...",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: anim,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: brand.withOpacity(.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search,
                    size: 60, color: Colors.black),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Searching best workers nearby...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Please wait a moment"),
          ],
        ),
      ),
    );
  }
}