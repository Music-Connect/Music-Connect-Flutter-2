import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final config = _config[status] ?? _config['pendente']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: config.border),
      ),
      child: Text(
        config.label,
        style: GoogleFonts.inter(
          color: config.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static final _config = {
    'pendente': _StatusConfig(
      label: 'Pendente',
      color: AppTheme.amber,
      bg: const Color(0x26F59E0B),
      border: const Color(0x4DF59E0B),
    ),
    'aceita': _StatusConfig(
      label: 'Aceita',
      color: AppTheme.emerald,
      bg: const Color(0x2610B981),
      border: const Color(0x4D10B981),
    ),
    'recusada': _StatusConfig(
      label: 'Recusada',
      color: AppTheme.red,
      bg: const Color(0x26EF4444),
      border: const Color(0x4DEF4444),
    ),
    'cancelada': _StatusConfig(
      label: 'Cancelada',
      color: AppTheme.fgMuted,
      bg: const Color(0x1A71717A),
      border: const Color(0x3371717A),
    ),
  };
}

class _StatusConfig {
  final String label;
  final Color color;
  final Color bg;
  final Color border;
  const _StatusConfig({
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
  });
}
