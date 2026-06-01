import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../domain/notification.dart';
import '../../domain/pond.dart';
import '../../infrastructure/auth_provider.dart';
import '../../infrastructure/farm_service.dart';
import '../../infrastructure/notification_service.dart';
import '../../infrastructure/pond_service.dart';
import '../widgets/dashboard_layout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Pond> _ponds = [];
  List<AppNotification> _notifications = [];
  bool _loading = true;
  bool _showCreateFarm = false;
  final _farmNameCtrl = TextEditingController();
  final _farmAddressCtrl = TextEditingController();
  bool _creatingFarm = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id ?? 0;
    try {
      final farm = await getUserFarm(userId);
      if (farm == null) {
        setState(() { _showCreateFarm = true; _loading = false; });
        return;
      }
      final results = await Future.wait([getPondsByFarm(farm.id), getNotifications(userId)]);
      setState(() {
        _ponds = results[0] as List<Pond>;
        _notifications = results[1] as List<AppNotification>;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createFarm() async {
    if (_farmNameCtrl.text.trim().isEmpty) return;
    setState(() => _creatingFarm = true);
    try {
      await createFarm(name: _farmNameCtrl.text.trim(), address: _farmAddressCtrl.text.trim());
      setState(() { _showCreateFarm = false; _creatingFarm = false; });
      _load();
    } catch (_) { setState(() => _creatingFarm = false); }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return DashboardLayout(
      currentRoute: '/dashboard',
      child: Stack(children: [
        _loading
            ? const Center(child: CircularProgressIndicator(color: kPrimary))
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bienvenido, ${user?.firstName ?? ""}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kTextPrimary)),
                    const SizedBox(height: 4),
                    const Text('Resumen de tu sistema acuícola', style: TextStyle(color: kTextSecondary, fontSize: 14)),
                    const SizedBox(height: 24),
                    _StatsGrid(activePonds: _ponds.where((p) => p.status == 'ACTIVE').length, totalPonds: _ponds.length, unreadAlerts: _notifications.length),
                    const SizedBox(height: 24),
                    _RecentAlerts(notifications: _notifications.take(5).toList()),
                    const SizedBox(height: 24),
                    _PondsPreview(ponds: _ponds),
                  ]),
                ),
              ),
        if (_showCreateFarm) _CreateFarmModal(nameCtrl: _farmNameCtrl, addressCtrl: _farmAddressCtrl, loading: _creatingFarm, onConfirm: _createFarm),
      ]),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int activePonds, totalPonds, unreadAlerts;
  const _StatsGrid({required this.activePonds, required this.totalPonds, required this.unreadAlerts});
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 600;
    return GridView.count(
      crossAxisCount: wide ? 4 : 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.6,
      children: [
        _StatCard('ESTANQUES ACTIVOS', '$activePonds', Icons.water_outlined, kPrimary),
        _StatCard('TOTAL ESTANQUES', '$totalPonds', Icons.grid_view_outlined, const Color(0xFF0D9488)),
        _StatCard('ALERTAS NO LEÍDAS', '$unreadAlerts', Icons.notifications_outlined, kWarning),
        _StatCard('SISTEMA', 'ACTIVO', Icons.check_circle_outline, kSuccess),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: kTextSecondary))),
          Icon(icon, color: color, size: 18),
        ]),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
      ],
    )),
  );
}

class _RecentAlerts extends StatelessWidget {
  final List<AppNotification> notifications;
  const _RecentAlerts({required this.notifications});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Alertas Recientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary)),
      const SizedBox(height: 16),
      if (notifications.isEmpty)
        const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Sin alertas recientes', style: TextStyle(color: kTextSecondary))))
      else ...notifications.map((n) {
        final isTemp = n.type.toUpperCase().contains('TEMP');
        final color = n.isCritical ? kError : kWarning;
        final icon = isTemp ? Icons.thermostat_outlined : n.type.toUpperCase().contains('PH') ? Icons.science_outlined : Icons.warning_amber_outlined;
        return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextPrimary)),
            Text(n.message, style: const TextStyle(fontSize: 12, color: kTextSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Text(n.relativeTime, style: const TextStyle(fontSize: 11, color: kTextSecondary)),
        ]));
      }),
    ])),
  );
}

class _PondsPreview extends StatelessWidget {
  final List<Pond> ponds;
  const _PondsPreview({required this.ponds});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Mis Estanques', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary)),
        TextButton(onPressed: () => context.go('/estanques'), child: const Text('Ver todos', style: TextStyle(color: kPrimary, fontSize: 13))),
      ]),
      const SizedBox(height: 12),
      if (ponds.isEmpty)
        const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No tienes estanques aún', style: TextStyle(color: kTextSecondary))))
      else ...ponds.take(4).map((p) {
        final isActive = p.status == 'ACTIVE';
        return InkWell(
          onTap: () => context.go('/estanques/${p.id}'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: isActive ? kSuccess : kTextSecondary, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary)),
              Text('${p.species} · ${p.volume.toStringAsFixed(0)} m³', style: const TextStyle(fontSize: 12, color: kTextSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: isActive ? kSuccess.withValues(alpha: 0.1) : kTextSecondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(p.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? kSuccess : kTextSecondary)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: kTextSecondary),
          ])),
        );
      }),
    ])),
  );
}

class _CreateFarmModal extends StatelessWidget {
  final TextEditingController nameCtrl, addressCtrl;
  final bool loading;
  final VoidCallback onConfirm;
  const _CreateFarmModal({required this.nameCtrl, required this.addressCtrl, required this.loading, required this.onConfirm});
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black54,
    child: Center(child: Container(
      margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Crea tu primera granja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextPrimary)),
        const SizedBox(height: 8),
        const Text('Para comenzar necesitas registrar tu granja acuícola.', style: TextStyle(color: kTextSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre de la granja')),
        const SizedBox(height: 12),
        TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Dirección (opcional)')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: loading ? null : onConfirm,
          child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Crear Granja'),
        ),
      ]),
    )),
  );
}
