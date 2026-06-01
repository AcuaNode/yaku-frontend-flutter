import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/notifications',
      child: const Center(child: Text('Notifications', style: TextStyle(fontSize: 24))),
    );
  }
}
