import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color brandColor = const Color(0xFFCCFD04);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 248, 252, 1),
      body: Column(
        children: [
          // ================= TAB BAR (HEIGHT DOUBLE + THICK INDICATOR) =================
          Container(
            height: 80, // 🔥 double height
            color: Colors.white,
            alignment: Alignment.bottomCenter,
            child: TabBar(
              controller: _tabController,
              indicatorColor: brandColor,
              indicatorWeight: 5, // 🔥 thicker indicator line
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "History"),
              ],
            ),
          ),

          // ================= TAB CONTENT =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _pendingOrders(),
                _historyOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= PENDING ORDERS =================
  Widget _pendingOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user!.uid)
          .where('status', isNotEqualTo: "Completed")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(
            icon: Icons.search_off,
            title: "No Pending Orders",
            subtitle: "You have no active orders right now.",
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data =
            orders[index].data() as Map<String, dynamic>;
            return _orderCard(data);
          },
        );
      },
    );
  }

  // ================= HISTORY ORDERS =================
  Widget _historyOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user!.uid)
          .where('status', whereIn: ["Completed", "Cancelled"])
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(
            icon: Icons.history,
            title: "No History Yet",
            subtitle: "Your completed orders will appear here.",
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data =
            orders[index].data() as Map<String, dynamic>;
            return _historyCard(data);
          },
        );
      },
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ================= ORDER CARD =================
  Widget _orderCard(Map<String, dynamic> data) {
    final status = data['status'] ?? "Pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // LEFT ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['serviceType'] == "Electrician"
                  ? Icons.flash_on
                  : Icons.plumbing,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // ORDER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['serviceType'] ?? "Service",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['details'] ?? "Service requested",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _statusBadge(status),
        ],
      ),
    );
  }

  // ================= HISTORY CARD =================
  Widget _historyCard(Map<String, dynamic> data) {
    final status = data['status'] ?? "Completed";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data['serviceType'] ?? "Service",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data['details'] ?? "Service completed successfully",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                _formatTime(data['createdAt']),
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(String status) {
    Color color = status == "Completed"
        ? Colors.green
        : status == "Cancelled"
        ? Colors.red
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.3),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  // ================= FORMAT TIME =================
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    final date = (timestamp as Timestamp).toDate();
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }
}
