import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/settings',
      child: const Center(child: Text('Settings', style: TextStyle(fontSize: 24))),
    );
  }
}
