import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_accepted_screen.dart';
import '../services/notification_service.dart';

class AvailableOffersScreen extends StatelessWidget {
  final String orderId;
  final String serviceType; // ✅ NEW — service ke hisaab se workers filter honge

  const AvailableOffersScreen({
    super.key,
    required this.orderId,
    required this.serviceType, // ✅ NEW
  });

  final Color brand = const Color(0xFFCCFD04);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: brand,
        title: const Text("Available Workers",
            style: TextStyle(color: Colors.black)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Firestore se real workers load karo
        stream: FirebaseFirestore.instance
            .collection('worker_requests')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final workers = snapshot.data!.docs;

          if (workers.isEmpty) {
            return const Center(
              child: Text("Koi worker available nahi hai abhi"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workers.length,
            itemBuilder: (_, index) {
              final worker = workers[index].data() as Map<String, dynamic>;
              final workerUid = worker['uid'] ?? '';
              final workerName = worker['name'] ?? 'Worker';
              final workerType = worker['workType'] ?? '';
              final workerArea = worker['area'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workerName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(workerType),
                          Text(workerArea,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brand,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .update({
                          "status": "accepted",
                          "workerName": workerName,
                          "workerId": workerUid,
                        });

                        await NotificationService.sendNotification(
                          recipientUid: workerUid,
                          title: "Nai Request! 🔔",
                          body: "Ek customer ne aapko select kiya hai!",
                          data: {"orderId": orderId},
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestAcceptedScreen(
                              worker: {
                                "name": workerName,
                                "rate": "Rate TBD",
                                "time": "ETA TBD",
                                "image": "assets/images/plumber1.jpg",
                                "uid": workerUid,
                              },
                              orderId: orderId,
                            ),
                          ),
                        );
                      },
                      child: const Text("Select"),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}