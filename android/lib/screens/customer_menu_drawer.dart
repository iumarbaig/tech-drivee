import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'become_worker_promo_screen.dart';

class CustomerMenuDrawer extends StatefulWidget {
  const CustomerMenuDrawer({super.key});

  @override
  State<CustomerMenuDrawer> createState() => _CustomerMenuDrawerState();
}

class _CustomerMenuDrawerState extends State<CustomerMenuDrawer> {
  final Color baseColor = const Color.fromARGB(255, 204, 253, 4);

  bool isWorkerMode = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tech Drive',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ================= MENU ITEMS =================
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      Icons.person_outline,
                      'My Profile',
                      routeName: '/profile',
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.settings_outlined,
                      'Settings',
                      routeName: '/settings',
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.contact_mail_outlined,
                      'Contact Us',
                      routeName: '/contact',
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.help_outline,
                      'Help & Support',
                      routeName: '/support',
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.logout,
                      'Logout',
                      isLogout: true,
                    ),
                  ],
                ),
              ),

              // ================= WORKER MODE BUTTON =================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isWorkerMode = !isWorkerMode;
                    });

                    Navigator.pop(context); // close drawer

                    if (isWorkerMode) {
                      // ✅ Navigate to Become Worker Promo Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const BecomeWorkerPromoScreen(),
                        ),
                      );
                    } else {
                      // ✅ Feedback snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Switched back to Customer Mode'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      isWorkerMode
                          ? 'Switch to Customer Mode'
                          : 'Switch to Worker Mode',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DRAWER ITEM =================
  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title, {
        bool isLogout = false,
        String? routeName,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: baseColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : baseColor),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isLogout ? Colors.red : Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.black38,
          ),
          onTap: () async {
            Navigator.pop(context);

            if (isLogout) {
              // ✅ FIREBASE LOGOUT
              await FirebaseAuth.instance.signOut();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            } else if (routeName != null) {
              Navigator.pushNamed(context, routeName);
            }
          },
        ),
      ),
    );
  }
}
