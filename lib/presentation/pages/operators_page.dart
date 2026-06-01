import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class OperatorsPage extends StatelessWidget {
  const OperatorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/operators',
      child: const Center(child: Text('Operators', style: TextStyle(fontSize: 24))),
    );
  }
}
