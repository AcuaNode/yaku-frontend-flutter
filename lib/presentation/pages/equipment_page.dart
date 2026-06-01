import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class EquipmentPage extends StatelessWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/equipment',
      child: const Center(child: Text('Equipment', style: TextStyle(fontSize: 24))),
    );
  }
}
