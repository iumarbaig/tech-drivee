import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'live_tracking_screen.dart';
import '../services/notification_service.dart'; // ✅ NEW

class RequestAcceptedScreen extends StatelessWidget {
  final Map<String, dynamic> worker;
  final String orderId;

  const RequestAcceptedScreen({
    super.key,
    required this.worker,
    required this.orderId,
  });

  static const Color brand = Color(0xFFCCFD04);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: brand,
        title: const Text("Request Accepted",
            style: TextStyle(color: Colors.black)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'];
          final workerId = data['workerId'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage(worker["image"]),
                ),
                const SizedBox(height: 20),
                Text(worker["name"],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("${worker["rate"]} • ETA ${worker["time"]}"),
                const SizedBox(height: 40),

                // Track Worker Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveTrackingScreen(orderId: orderId),
                        ),
                      );
                    },
                    child: const Text("Track Worker"),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Cancel button — sirf tab dikhao jab worker "on_my_way" nahi hua
                if (status == 'accepted')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Confirm dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Cancel Order?"),
                            content: const Text(
                                "Kya aap sach mein ye order cancel karna chahte hain?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Nahi"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Haan, Cancel Karo",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Firestore update
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({'status': 'cancelled'});

                          // ✅ Worker ko notification bhejo
                          if (workerId != null) {
                            await NotificationService.sendNotification(
                              recipientUid: workerId,
                              title: "Order Cancel Ho Gaya! ❌",
                              body: "Customer ne order cancel kar diya hai!",
                              data: {"orderId": orderId},
                            );
                          }

                          if (context.mounted) {
                            Navigator.popUntil(
                                context, ModalRoute.withName('/home'));
                          }
                        }
                      },
                      child: const Text("Cancel Order"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}