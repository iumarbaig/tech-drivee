import 'package:flutter/material.dart';

class WorkerOrdersScreen extends StatefulWidget {
  const WorkerOrdersScreen({super.key});

  @override
  State<WorkerOrdersScreen> createState() => _WorkerOrdersScreenState();
}

class _WorkerOrdersScreenState extends State<WorkerOrdersScreen>
    with SingleTickerProviderStateMixin {
  static const Color brand = Color(0xFFCCFD04);

  late TabController _tabController;

  // 🔹 Dummy Booked Orders
  final List<Map<String, String>> bookedOrders = [
    {
      "name": "Ali Khan",
      "service": "Plumber",
      "area": "Model Town",
    },
    {
      "name": "Ahmed Raza",
      "service": "Electrician",
      "area": "Johar Town",
    },
  ];

  // 🔹 Dummy History Orders
  final List<Map<String, String>> historyOrders = [
    {
      "name": "Usman",
      "service": "AC Repair",
      "area": "Wapda Town",
    },
    {
      "name": "Bilal",
      "service": "Plumber",
      "area": "Gulberg",
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      appBar: AppBar(
        backgroundColor: brand,
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: "Booked Orders"),
            Tab(text: "History"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _bookedOrdersView(),
          _historyOrdersView(),
        ],
      ),
    );
  }

  // ================= BOOKED ORDERS =================
  Widget _bookedOrdersView() {
    if (bookedOrders.isEmpty) {
      return const Center(child: Text("No booked orders"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookedOrders.length,
      itemBuilder: (context, index) {
        final order = bookedOrders[index];
        return _orderCard(
          name: order["name"]!,
          service: order["service"]!,
          area: order["area"]!,
          isHistory: false,
        );
      },
    );
  }

  // ================= HISTORY ORDERS =================
  Widget _historyOrdersView() {
    if (historyOrders.isEmpty) {
      return const Center(child: Text("No history available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: historyOrders.length,
      itemBuilder: (context, index) {
        final order = historyOrders[index];
        return _orderCard(
          name: order["name"]!,
          service: order["service"]!,
          area: order["area"]!,
          isHistory: true,
        );
      },
    );
  }

  // ================= ORDER CARD UI =================
  Widget _orderCard({
    required String name,
    required String service,
    required String area,
    required bool isHistory,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: brand,
            child: Text(name[0]),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Service: $service"),
                Text("Area: $area"),
              ],
            ),
          ),

          if (isHistory)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // later: open order detail or tracking
              },
              child: const Text("Open"),
            ),
        ],
      ),
    );
  }
}
