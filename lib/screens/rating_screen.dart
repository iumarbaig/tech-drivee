import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart'; // ✅ NEW

class RatingScreen extends StatefulWidget {
  final String orderId;

  const RatingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double rating = 5;
  final commentC = TextEditingController();
  bool loading = false;

  Future<void> submitRating() async {
    if (loading) return;
    setState(() => loading = true);

    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (!orderDoc.exists) throw "Order not found";

      final orderData = orderDoc.data()!;
      final String workerId = orderData['workerId'];

      final firestore = FirebaseFirestore.instance;

      await firestore.collection('ratings').add({
        "orderId": widget.orderId,
        "workerId": workerId,
        "rating": rating,
        "comment": commentC.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      final workerRef = firestore.collection('workers').doc(workerId);
      final workerSnap = await workerRef.get();

      double oldAvg = 0;
      int totalRatings = 0;

      if (workerSnap.exists) {
        oldAvg = (workerSnap['avgRating'] ?? 0).toDouble();
        totalRatings = (workerSnap['totalRatings'] ?? 0);
      }

      final newTotal = totalRatings + 1;
      final newAvg = ((oldAvg * totalRatings) + rating) / newTotal;

      await workerRef.set({
        "avgRating": newAvg,
        "totalRatings": newTotal,
      }, SetOptions(merge: true));

      // ✅ Worker ko notification bhejo
      await NotificationService.sendNotification(
        recipientUid: workerId,
        title: "Nai Rating Mili! ⭐",
        body: "Customer ne aapko ${rating.toStringAsFixed(1)} star rating di hai!",
        data: {"orderId": widget.orderId},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanks for your rating ⭐")),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Worker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "How was your experience?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() => rating = value);
              },
            ),

            Text(
              "Rating: ${rating.toStringAsFixed(1)} ⭐",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: commentC,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Optional comment...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : submitRating,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Rating"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}