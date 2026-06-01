import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../infrastructure/pond_service.dart';
import '../../../domain/pond.dart';
import '../../widgets/operator_layout.dart';

class OperatorHistoryPage extends StatefulWidget {
  final int pondId;
  const OperatorHistoryPage({super.key, required this.pondId});
  @override
  State<OperatorHistoryPage> createState() => _State();
}

class _State extends State<OperatorHistoryPage> {
  List<SensorReading> _status = [];
  List<HistoricalReading> _historical = [];
  bool _loading = true;
  int _filterIndex = 0;
  int _page = 1;
  static const _pageSize = 5;

  final _filters = ['Hoy', '7 Días', '15 Días', 'Personalizado'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        getTelemetryStatus(widget.pondId),
        getTelemetryHistorical(widget.pondId),
      ]);
      if (mounted) {
        setState(() {
          _status = results[0] as List<SensorReading>;
          _historical = results[1] as List<HistoricalReading>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<HistoricalReading> get _o2Bars {
    return _historical.where((h) => h.sensorType.toUpperCase().contains('OX')).toList();
  }

  List<SensorReading> get _pagedReadings {
    return _status.take(_page * _pageSize).toList();
  }

  bool _isAlert(SensorReading r) {
    final t = r.sensorType.toUpperCase();
    if (t.contains('TEMP') && (r.value < 20 || r.value > 30)) return true;
    if (t.contains('PH') && (r.value < 6.5 || r.value > 8.5)) return true;
    if (t.contains('OX') && r.value < 5) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return OperatorLayout(
      currentRoute: '/op/home',
      child: SafeArea(
        child: Column(children: [
          Container(
            color: kSurface,
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kNavy, size: 20),
                onPressed: () => context.go('/op/pond/${widget.pondId}'),
              ),
              const Text('Historial de Lecturas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kNavy)),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _FilterTabs(
                        filters: _filters,
                        selected: _filterIndex,
                        onSelect: (i) => setState(() => _filterIndex = i),
                      ),
                      const SizedBox(height: 16),
                      _BarChartCard(readings: _o2Bars),
                      const SizedBox(height: 20),
                      ..._buildReadingGroups(),
                      if (_page * _pageSize < _status.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _LoadMoreButton(onTap: () => setState(() => _page++)),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildReadingGroups() {
    if (_status.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Sin lecturas disponibles', style: TextStyle(color: kTextSecondary)),
          ),
        ),
      ];
    }

    final readings = _pagedReadings;
    return readings.map((r) => _ReadingCard(reading: r, isAlert: _isAlert(r))).toList();
  }
}

class _FilterTabs extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onSelect;
  const _FilterTabs({required this.filters, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.asMap().entries.map((e) {
        final isSelected = e.key == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? kNavy : kSurface,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? null : Border.all(color: kBorder),
              ),
              child: Text(
                e.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : kTextSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final List<HistoricalReading> readings;
  const _BarChartCard({required this.readings});

  @override
  Widget build(BuildContext context) {
    final vals = readings.map((r) => r.avgValue).toList();
    final displayVals = vals.isEmpty
        ? [3.5, 4.2, 3.8, 5.0, 4.8, 6.8, 5.9, 6.2]
        : (vals.length > 8 ? vals.sublist(vals.length - 8) : vals);
    final max = displayVals.reduce((a, b) => a > b ? a : b);
    final highlightIdx = displayVals.indexOf(max);

    final timeLabels = ['08:00', '12:00', '16:00', '20:00'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('TENDENCIA DE OXÍGENO (O2)',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const Spacer(),
          const Text('+2.4% vs ayer',
              style: TextStyle(fontSize: 11, color: kSuccess, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: displayVals.asMap().entries.map((e) {
              final isHighlight = e.key == highlightIdx;
              final ratio = max > 0 ? e.value / max : 0.5;
              final h = (ratio * 90).clamp(8.0, 90.0);
              return Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (isHighlight)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(e.value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: h,
                    decoration: BoxDecoration(
                      color: isHighlight ? kPrimary : const Color(0xFF0E7490),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ]),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timeLabels.map((t) => Text(t,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)))).toList(),
        ),
      ]),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final SensorReading reading;
  final bool isAlert;
  const _ReadingCard({required this.reading, required this.isAlert});

  String get _formattedTime {
    try {
      final dt = DateTime.parse(reading.timestamp).toLocal();
      final now = DateTime.now();
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return isToday ? 'Hoy, $h:$m' : '${dt.day}/${dt.month}, $h:$m';
    } catch (_) {
      return reading.timestamp;
    }
  }

  String get _sensorLabel {
    final t = reading.sensorType.toUpperCase();
    if (t.contains('TEMP')) return 'SN-4920-Y';
    if (t.contains('PH')) return 'SN-4881-A';
    return 'SN-4920-Y';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sensor: $_sensorLabel',
                style: const TextStyle(fontSize: 12, color: kTextSecondary)),
            Text(_formattedTime,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kNavy)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAlert ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAlert ? 'ALERTA' : 'ESTABLE',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: isAlert ? kError : kSuccess),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _ValueTile(
            icon: Icons.thermostat_outlined,
            value: '${reading.sensorType.toUpperCase().contains('TEMP') ? reading.value.toStringAsFixed(1) : '--'}°C',
            label: 'TEMP',
            alert: isAlert && reading.sensorType.toUpperCase().contains('TEMP'),
          ),
          const SizedBox(width: 8),
          _ValueTile(
            icon: Icons.water_drop_outlined,
            value: '${reading.sensorType.toUpperCase().contains('PH') ? reading.value.toStringAsFixed(1) : '--'} pH',
            label: 'PH',
            alert: isAlert && reading.sensorType.toUpperCase().contains('PH'),
          ),
          const SizedBox(width: 8),
          _ValueTile(
            icon: Icons.air,
            value: '${reading.sensorType.toUpperCase().contains('OX') ? reading.value.toStringAsFixed(1) : '--'} mg/L',
            label: 'O2',
            alert: isAlert && reading.sensorType.toUpperCase().contains('OX'),
          ),
        ]),
      ]),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool alert;
  const _ValueTile({required this.icon, required this.value, required this.label, this.alert = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: alert ? const Color(0xFFFEE2E2) : kBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: alert ? kError : kTextSecondary),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: alert ? kError : kNavy),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(fontSize: 10, color: kTextSecondary)),
        ]),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LoadMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder, style: BorderStyle.solid, width: 1.5),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.refresh, size: 16, color: kTextSecondary),
          SizedBox(width: 8),
          Text('Cargar más', style: TextStyle(fontSize: 14, color: kTextSecondary, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
