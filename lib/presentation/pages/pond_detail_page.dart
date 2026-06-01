import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class PondDetailPage extends StatelessWidget {
  final int pondId;
  const PondDetailPage({super.key, required this.pondId});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: '/estanques/$pondId',
      child: Center(child: Text('Detalle Estanque #$pondId', style: const TextStyle(fontSize: 24))),
    );
  }
}
