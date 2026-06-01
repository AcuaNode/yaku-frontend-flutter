import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../infrastructure/auth_provider.dart';
import '../../../infrastructure/farm_service.dart';
import '../../../infrastructure/notification_service.dart';
import '../../widgets/operator_layout.dart';

class OperatorProfilePage extends StatefulWidget {
  const OperatorProfilePage({super.key});
  @override
  State<OperatorProfilePage> createState() => _State();
}

class _State extends State<OperatorProfilePage> {
  Farm? _farm;
  int _alertCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().user?.id ?? 0;
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        getUserFarm(userId),
        getNotifications(userId),
      ]);
      if (mounted) {
        setState(() {
          _farm = results[0] as Farm?;
          final notifs = results[1] as List;
          _alertCount = notifs.length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final initials = user != null && user.firstName.isNotEmpty
        ? '${user.firstName[0]}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'.toUpperCase()
        : '?';
    final farmName = _farm?.name ?? 'Sin finca';
    final farmCode = _farm != null ? 'SAN-JOSE-0${_farm!.id}' : '--';

    return OperatorLayout(
      currentRoute: '/op/profile',
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kPrimary))
            : ListView(
                children: [
                  Container(
                    color: kSurface,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mi Perfil',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kNavy)),
                        Row(children: [
                          Text(farmName,
                              style: const TextStyle(fontSize: 13, color: kTextSecondary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.location_on_outlined, size: 16, color: kTextSecondary),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    color: kSurface,
                    child: Column(children: [
                      Container(
                        height: 100,
                        color: kNavy,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Column(children: [
                          Stack(alignment: Alignment.bottomRight, children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kSurface, width: 3),
                              ),
                              child: Center(
                                child: Text(initials,
                                    style: const TextStyle(
                                        fontSize: 32, fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kSurface, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_outlined,
                                  size: 14, color: Colors.white),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text(
                            user != null ? '${user.firstName} ${user.lastName}' : '',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: kNavy),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: kSuccess.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.verified_outlined, size: 14, color: kSuccess),
                              const SizedBox(width: 5),
                              const Text('OPERATOR',
                                  style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                      color: kSuccess, letterSpacing: 0.5)),
                            ]),
                          ),
                        ]),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(children: [
                            _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'CORREO ELECTRÓNICO',
                              value: user?.email ?? '--',
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              icon: Icons.grid_view_outlined,
                              label: 'ID DE FINCA ASIGNADA',
                              value: farmCode,
                            ),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: kNavy,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const Text('TURNOS',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8),
                                            letterSpacing: 0.8, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    const Text('24/30',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: 24 / 30,
                                        minHeight: 6,
                                        backgroundColor: const Color(0xFF1E3A5F),
                                        valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: kSurface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: kBorder),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const Text('ALERTAS',
                                        style: TextStyle(fontSize: 11, color: kTextSecondary,
                                            letterSpacing: 0.8, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text(_alertCount.toString().padLeft(2, '0'),
                                        style: const TextStyle(fontSize: 22,
                                            fontWeight: FontWeight.bold, color: kNavy)),
                                    const SizedBox(height: 4),
                                    const Text('Resueltas',
                                        style: TextStyle(fontSize: 13, color: kSuccess,
                                            fontWeight: FontWeight.w600)),
                                  ]),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Editar perfil'),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.shield_outlined, size: 16, color: kNavy),
                                label: const Text('Seguridad y Acceso',
                                    style: TextStyle(color: kNavy)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: kBorder),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                icon: const Icon(Icons.logout, size: 16, color: kError),
                                label: const Text('Cerrar sesión',
                                    style: TextStyle(color: kError, fontWeight: FontWeight.w600)),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  await context.read<AuthProvider>().logout();
                                  if (context.mounted) context.go('/login');
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: kTextSecondary),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: kTextSecondary,
                  letterSpacing: 0.8, fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kNavy)),
        ]),
      ]),
    );
  }
}
