import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class PondsPage extends StatelessWidget {
  const PondsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/ponds',
      child: const Center(child: Text('Ponds', style: TextStyle(fontSize: 24))),
    );
  }
}
