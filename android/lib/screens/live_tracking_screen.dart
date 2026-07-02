import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'chat_screen.dart';
import 'rating_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String orderId;
  final String? workerId;
  final String? customerId;
  final String? workerName;
  final String? customerName;

  const LiveTrackingScreen({
    super.key,
    required this.orderId,
    this.workerId,
    this.customerId,
    this.workerName,
    this.customerName,
  });

  static const Color brand = Color(0xFFCCFD04);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapController _mapController = MapController();
  bool _mapInitialized = false;

  // ===== STORE LOCATIONS TO PREVENT UNNECESSARY UPDATES =====
  double _currentWorkerLat = 33.6844;
  double _currentWorkerLng = 73.0479;
  double _currentCustomerLat = 33.6844;
  double _currentCustomerLng = 73.0479;

  // ===== ROUTE DATA =====
  List<LatLng> routePoints = [];
  double distanceKm = 0;
  double durationMin = 0;

  // ===== ROUTE CALL CONTROL =====
  bool _isFetchingRoute = false;

  // ===== FOR UPDATING CUSTOMER LOCATION =====
  bool _isUpdatingLocation = false;
  bool _initialLocationSaved = false;
  String _currentStatus = "accepted";

  // ===== WORKER INFO =====
  String _workerId = '';
  String _customerId = '';
  String _workerName = 'Worker';
  String _customerName = 'Customer';

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveInitialCustomerLocation();
    });
  }

  Future<void> _loadOrderDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _workerId = widget.workerId ?? data['workerId'] ?? '';
          _customerId = widget.customerId ?? data['customerId'] ?? '';
          _workerName = widget.workerName ?? data['workerName'] ?? 'Worker';
          _customerName = widget.customerName ?? data['customerName'] ?? 'Customer';
        });
      }
    } catch (e) {
      debugPrint("Error loading order details: $e");
    }
  }

  // ===== SAVE INITIAL CUSTOMER LOCATION =====
  Future<void> _saveInitialCustomerLocation() async {
    if (_initialLocationSaved) return;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'customerLat': position.latitude,
        'customerLng': position.longitude,
        'customerLocationSavedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _currentCustomerLat = position.latitude;
        _currentCustomerLng = position.longitude;
      });

      _initialLocationSaved = true;
      debugPrint("✅ Initial customer location saved");
    } catch (e) {
      debugPrint("Error saving initial location: $e");
    }
  }

  // ================= FETCH ROUTE =================
  Future<void> fetchRoute() async {
    if (_isFetchingRoute) return;

    try {
      _isFetchingRoute = true;

      final url =
          "https://router.project-osrm.org/route/v1/driving/"
          "${_currentWorkerLng},${_currentWorkerLat};${_currentCustomerLng},${_currentCustomerLat}"
          "?overview=full&geometries=geojson";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          final meters = data['routes'][0]['distance'];
          final seconds = data['routes'][0]['duration'];

          if (!mounted) return;

          setState(() {
            routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();
            distanceKm = meters / 1000;
            durationMin = seconds / 60;
          });
        }
      }
    } catch (e) {
      debugPrint("Route fetch error: $e");
    } finally {
      _isFetchingRoute = false;
    }
  }

  // ================= UPDATE CUSTOMER LOCATION =================
  Future<void> _updateCustomerLocationInFirestore(double lat, double lng) async {
    try {
      setState(() {
        _isUpdatingLocation = true;
      });

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'customerLat': lat,
        'customerLng': lng,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _currentCustomerLat = lat;
        _currentCustomerLng = lng;
      });

      await fetchRoute();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your location has been updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint("Update location error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  // ================= GO TO CURRENT LOCATION =================
  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLat = position.latitude;
      final currentLng = position.longitude;

      _mapController.move(
        LatLng(currentLat, currentLng),
        14,
      );

      await _updateCustomerLocationInFirestore(currentLat, currentLng);
    } catch (e) {
      debugPrint("Current location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ================= STATUS FORMATTERS =================
  String getStatusText(String status) {
    switch (status) {
      case "on_my_way":
        return "🚗 Worker is on the way";
      case "arrived":
        return "📍 Worker has arrived";
      case "completed":
        return "✅ Work completed";
      default:
        return "⏳ Order accepted";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "on_my_way":
        return Colors.blue.shade100;
      case "arrived":
        return Colors.green.shade100;
      case "completed":
        return Colors.purple.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          orderId: widget.orderId,
          workerId: _workerId,
          customerId: _customerId,
          workerName: _workerName,
          customerName: _customerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: LiveTrackingScreen.brand,
        title: const Text(
          "Live Tracking",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final rawData = snapshot.data!.data();
          if (rawData == null) {
            return const Center(child: Text("Order data missing"));
          }

          final data = rawData as Map<String, dynamic>;
          final String status = data['status'] ?? "accepted";

          // Get locations from Firestore
          final double newWorkerLat = (data['workerLat'] ?? 33.6844).toDouble();
          final double newWorkerLng = (data['workerLng'] ?? 73.0479).toDouble();
          final double newCustomerLat = (data['customerLat'] ?? _currentCustomerLat).toDouble();
          final double newCustomerLng = (data['customerLng'] ?? _currentCustomerLng).toDouble();

          // ✅ Check if locations changed significantly
          bool locationChanged = false;

          if ((_currentWorkerLat - newWorkerLat).abs() > 0.00001 ||
              (_currentWorkerLng - newWorkerLng).abs() > 0.00001) {
            _currentWorkerLat = newWorkerLat;
            _currentWorkerLng = newWorkerLng;
            locationChanged = true;
          }

          if ((_currentCustomerLat - newCustomerLat).abs() > 0.00001 ||
              (_currentCustomerLng - newCustomerLng).abs() > 0.00001) {
            _currentCustomerLat = newCustomerLat;
            _currentCustomerLng = newCustomerLng;
            locationChanged = true;
          }

          // ✅ Update route only if locations changed
          if (locationChanged) {
            fetchRoute();
          }

          // ✅ Update status
          if (_currentStatus != status) {
            _currentStatus = status;

            // Auto navigate to rating when completed
            if (status == "completed") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RatingScreen(orderId: widget.orderId),
                  ),
                );
              });
            }
          }

          final statusText = getStatusText(status);
          final statusColor = getStatusColor(status);

          // 🎯 Center map only once
          if (!_mapInitialized && _currentWorkerLat != 33.6844) {
            _mapInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(
                LatLng(_currentWorkerLat, _currentWorkerLng),
                14,
              );
            });
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // STATUS CARD
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // 🗺️ MAP
                Container(
                  height: 260,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade200,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_currentWorkerLat, _currentWorkerLng),
                          initialZoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.example.tech_drive',
                          ),

                          // 🛣️ ROUTE LINE
                          if (routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: routePoints,
                                  strokeWidth: 4,
                                  color: Colors.blue,
                                ),
                              ],
                            ),

                          // 📍 MARKERS
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_currentWorkerLat, _currentWorkerLng),
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 42,
                                ),
                              ),
                              Marker(
                                point: LatLng(_currentCustomerLat, _currentCustomerLng),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.green,
                                  size: 34,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // CURRENT LOCATION BUTTON
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Column(
                          children: [
                            if (_isUpdatingLocation)
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              onPressed: _isUpdatingLocation ? null : _goToCurrentLocation,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.my_location,
                                color: _isUpdatingLocation ? Colors.grey : Colors.blue,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 📏 DISTANCE + ETA
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "📏 ${distanceKm.toStringAsFixed(2)} km",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "⏱️ ${durationMin.toStringAsFixed(1)} min",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // WORKER INFO
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Assigned Worker",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _workerName,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // CONTACT BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Call feature coming soon!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text("Chat"),
                          onPressed: _openChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // CURRENT LOCATION UPDATE INFO
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap the location button to update your current location for accurate tracking',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}