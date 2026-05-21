import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/proposta_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/proposal_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<PropostaProvider>().load(user);
      }
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _formatCurrency(double v) {
    if (v >= 1000) {
      return 'R\$ ${(v / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$ ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pp = context.watch<PropostaProvider>();
    final user = auth.user!;
    final isArtist = user.isArtist;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => pp.load(user),
          color: AppTheme.white,
          backgroundColor: AppTheme.bgCard,
          child: CustomScrollView(
            slivers: [
              // ── AppBar customizada ─────────────────────
              SliverAppBar(
                backgroundColor: AppTheme.bg,
                floating: true,
                snap: true,
                title: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.heroGradient.createShader(b),
                      child: const Icon(Icons.music_note_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Music Connect',
                      style: GoogleFonts.inter(
                        color: AppTheme.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.border,
                      backgroundImage: user.image != null
                          ? NetworkImage(user.image!)
                          : null,
                      child: user.image == null
                          ? Text(
                              user.name[0].toUpperCase(),
                              style: GoogleFonts.inter(
                                  color: AppTheme.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/profile'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Hero banner ───────────────────────
                    _HeroBanner(
                      greeting: _greeting(),
                      name: user.name,
                      isArtist: isArtist,
                      onPrimaryTap: () =>
                          Navigator.of(context).pushNamed('/profile'),
                      onSecondaryTap: () =>
                          Navigator.of(context).pushNamed('/proposals'),
                    ),
                    const SizedBox(height: 20),

                    // ── Stats grid ────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          label: 'Total',
                          value: '${pp.total}',
                          icon: Icons.bar_chart_rounded,
                          accent: const Color(0xFF3B82F6),
                          subtitle: isArtist
                              ? 'propostas recebidas'
                              : 'propostas enviadas',
                        ),
                        StatCard(
                          label: 'Pendentes',
                          value: '${pp.pendentes}',
                          icon: Icons.hourglass_empty_rounded,
                          accent: AppTheme.amber,
                          subtitle: 'aguardando resposta',
                        ),
                        StatCard(
                          label: 'Aceitas',
                          value: '${pp.aceitas}',
                          icon: Icons.check_circle_outline_rounded,
                          accent: AppTheme.emerald,
                          subtitle: pp.valorTotalAceitas > 0
                              ? _formatCurrency(pp.valorTotalAceitas)
                              : 'nenhuma ainda',
                        ),
                        StatCard(
                          label: 'Recusadas',
                          value: '${pp.recusadas}',
                          icon: Icons.cancel_outlined,
                          accent: AppTheme.red,
                          subtitle: pp.canceladas > 0
                              ? '+ ${pp.canceladas} cancelada(s)'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Atividade mensal ──────────────────
                    _ActivityChart(activity: pp.atividadeMensal),
                    const SizedBox(height: 20),

                    // ── Ações rápidas ─────────────────────
                    _QuickActions(isArtist: isArtist),
                    const SizedBox(height: 20),

                    // ── Propostas recentes ─────────────────
                    _SectionHeader(
                      title: isArtist
                          ? 'Propostas Recebidas'
                          : 'Propostas Enviadas',
                      count: pp.total,
                      onViewAll: () =>
                          Navigator.of(context).pushNamed('/proposals'),
                    ),
                    const SizedBox(height: 12),

                    if (pp.loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: AppTheme.white, strokeWidth: 2),
                        ),
                      )
                    else if (pp.recentes.isEmpty)
                      _EmptyProposals(isArtist: isArtist)
                    else
                      ...pp.recentes.map(
                        (proposta) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProposalCard(
                            proposta: proposta,
                            isArtist: isArtist,
                            onUpdateStatus: (id, status) async {
                              try {
                                await pp.updateStatus(id, status);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e
                                          .toString()
                                          .replaceFirst('Exception: ', '')),
                                      backgroundColor: AppTheme.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Banner ─────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final String greeting;
  final String name;
  final bool isArtist;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _HeroBanner({
    required this.greeting,
    required this.name,
    required this.isArtist,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF18181B),
            const Color(0xFF1C1917),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isArtist ? 'Painel do Artista' : 'Painel do Contratante',
                      style: GoogleFonts.inter(
                        color: AppTheme.fgSubtle,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.w900),
                  children: [
                    TextSpan(
                        text: '$greeting, ',
                        style: const TextStyle(color: AppTheme.white)),
                    WidgetSpan(
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.heroGradient.createShader(bounds),
                        child: Text(
                          name.split(' ').first,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArtist
                    ? 'Acompanhe suas propostas e conquiste novos palcos.'
                    : 'Gerencie contratações e descubra novos talentos.',
                style: GoogleFonts.inter(
                    color: AppTheme.fgMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: onPrimaryTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        isArtist ? 'Meu Perfil' : 'Meu Perfil',
                        style: GoogleFonts.inter(
                          color: AppTheme.bg,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onSecondaryTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Text(
                        'Ver Propostas',
                        style: GoogleFonts.inter(
                          color: AppTheme.fgSubtle,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Activity Chart ──────────────────────────────────────────
class _ActivityChart extends StatelessWidget {
  final List<MapEntry<String, int>> activity;
  const _ActivityChart({required this.activity});

  @override
  Widget build(BuildContext context) {
    final maxVal =
        activity.isEmpty ? 1 : activity.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final max = maxVal == 0 ? 1 : maxVal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atividade Recente',
                    style: GoogleFonts.inter(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Propostas nos últimos 6 meses',
                    style: GoogleFonts.inter(
                        color: AppTheme.fgMuted, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${DateTime.now().year}',
                  style: GoogleFonts.inter(
                      color: AppTheme.fgSubtle,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: max.toDouble() + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= activity.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            activity[idx].key,
                            style: GoogleFonts.inter(
                              color: AppTheme.fgMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: activity.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFBBF24),
                            Color(0xFFFB7185),
                            Color(0xFFE879F9),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: max.toDouble() + 1,
                          color: AppTheme.border.withOpacity(0.3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final bool isArtist;
  const _QuickActions({required this.isArtist});

  @override
  Widget build(BuildContext context) {
    final actions = isArtist
        ? [
            (
              icon: Icons.person_outline_rounded,
              label: 'Editar Perfil',
              route: '/profile',
            ),
            (
              icon: Icons.description_outlined,
              label: 'Ver Propostas',
              route: '/proposals',
            ),
          ]
        : [
            (
              icon: Icons.description_outlined,
              label: 'Minhas Propostas',
              route: '/proposals',
            ),
            (
              icon: Icons.person_outline_rounded,
              label: 'Meu Perfil',
              route: '/profile',
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: GoogleFonts.inter(
              color: AppTheme.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...actions.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(a.route),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(a.icon,
                            color: AppTheme.fgSubtle, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        a.label,
                        style: GoogleFonts.inter(
                          color: AppTheme.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppTheme.fgMuted, size: 13),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onViewAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (count > 4)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'Ver todas',
              style: GoogleFonts.inter(
                color: AppTheme.fgMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Empty State ──────────────────────────────────────────────
class _EmptyProposals extends StatelessWidget {
  final bool isArtist;
  const _EmptyProposals({required this.isArtist});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.border,
            style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isArtist ? Icons.mic_none_rounded : Icons.description_outlined,
              color: AppTheme.fgMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma proposta ainda',
            style: GoogleFonts.inter(
              color: AppTheme.fgSubtle,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isArtist
                ? 'Mantenha seu perfil completo para atrair contratantes.'
                : 'Explore artistas e envie sua primeira proposta.',
            style:
                GoogleFonts.inter(color: AppTheme.fgMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
