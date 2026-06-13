import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../domain/pond.dart';
import '../../infrastructure/pond_service.dart';

class PondsAverageStats extends StatefulWidget {
  final List<Pond> ponds;

  const PondsAverageStats({super.key, required this.ponds});

  @override
  State<PondsAverageStats> createState() => _PondsAverageStatsState();
}

class _PondsAverageStatsState extends State<PondsAverageStats> {
  bool _loading = true;
  final Map<String, double> _averages = {};
  final Map<String, String> _units = {};

  @override
  void initState() {
    super.initState();
    _calculateAverages();
  }

  @override
  void didUpdateWidget(covariant PondsAverageStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ponds != widget.ponds) {
      _calculateAverages();
    }
  }

  Future<void> _calculateAverages() async {
    if (widget.ponds.isEmpty) {
      setState(() {
        _loading = false;
        _averages.clear();
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final futures = widget.ponds.map((p) => getTelemetryStatus(p.id));
      final results = await Future.wait(futures);

      final Map<String, List<double>> groupedStats = {};

      for (var readings in results) {
        for (var reading in readings) {
          if (!groupedStats.containsKey(reading.sensorType)) {
            groupedStats[reading.sensorType] = [];
            _units[reading.sensorType] = reading.unit;
          }
          groupedStats[reading.sensorType]!.add(reading.value);
        }
      }

      final Map<String, double> newAverages = {};
      groupedStats.forEach((key, values) {
        if (values.isNotEmpty) {
          newAverages[key] = values.reduce((a, b) => a + b) / values.length;
        }
      });

      setState(() {
        _averages.clear();
        _averages.addAll(newAverages);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  IconData _getIconForType(String type) {
    if (type.toUpperCase().contains('TEMP')) return Icons.thermostat_outlined;
    if (type.toUpperCase().contains('PH')) return Icons.science_outlined;
    if (type.toUpperCase().contains('OXY')) return Icons.air_outlined;
    return Icons.sensors_outlined;
  }

  Color _getColorForType(String type) {
    if (type.toUpperCase().contains('TEMP')) return const Color(0xFFEF4444);
    if (type.toUpperCase().contains('PH')) return const Color(0xFF8B5CF6);
    if (type.toUpperCase().contains('OXY')) return const Color(0xFF3B82F6);
    return kPrimary;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: kPrimary)),
        ),
      );
    }

    if (_averages.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No hay datos de telemetría disponibles', style: TextStyle(color: kTextSecondary)),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Promedio Global de Sensores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _averages.entries.map((e) {
                final color = _getColorForType(e.key);
                return Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getIconForType(e.key), color: color, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${e.value.toStringAsFixed(1)} ${_units[e.key] ?? ""}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
