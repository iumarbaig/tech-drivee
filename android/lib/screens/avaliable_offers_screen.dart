import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'request_accepted_screen.dart';
import '../services/notification_service.dart';

class AvailableOffersScreen extends StatelessWidget {
  final String orderId;
  const AvailableOffersScreen({super.key, required this.orderId});

  final Color brand = const Color(0xFFCCFD04);

  final List<Map<String, dynamic>> workers = const [
    {
      "name": "Ahsan Electrician",
      "rate": "Rs 1500",
      "rating": 4.8,
      "time": "20 mins",
      "image": "assets/images/plumber1.jpg",
      "uid": "mCFLZ84XtQgheZVtlzrKVV17y8l1", // 🔥 apna worker uid yahan paste karo
    },
    {
      "name": "Bilal Electric Services",
      "rate": "Rs 1300",
      "rating": 4.5,
      "time": "30 mins",
      "image": "assets/images/plumber1.jpg",
      "uid": "1ZfkPl5S3GPMCel2uenVldlWH0g1", // 🔥 apna worker uid yahan paste karo
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: brand,
        title: const Text("Available Workers",
            style: TextStyle(color: Colors.black)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workers.length,
        itemBuilder: (_, index) {
          final worker = workers[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(worker["image"]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker["name"],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("${worker["rate"]} • ETA ${worker["time"]}"),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    // Firestore update
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({
                      "status": "accepted",
                      "workerName": worker["name"],
                      "workerRate": worker["rate"],
                      "workerId": worker["uid"],
                    });

                    // ✅ Worker ko notification bhejo
                    await NotificationService.sendNotification(
                      recipientUid: worker["uid"],
                      title: "Nai Request! 🔔",
                      body: "Ek customer ne aapko select kiya hai!",
                      data: {"orderId": orderId},
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestAcceptedScreen(
                          worker: worker,
                          orderId: orderId,
                        ),
                      ),
                    );
                  },
                  child: const Text("Accept"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}