import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/dashboard',
      child: const Center(child: Text('Dashboard', style: TextStyle(fontSize: 24))),
    );
  }
}
