import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/proposta_provider.dart';
import '../../core/services/usuario_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/proposal_card.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  String _activeFilter = 'todas';

  static const _filters = [
    ('todas', 'Todas'),
    ('pendente', 'Pendentes'),
    ('aceita', 'Aceitas'),
    ('recusada', 'Recusadas'),
    ('cancelada', 'Canceladas'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final pp = context.read<PropostaProvider>();
        if (pp.propostas.isEmpty) pp.load(user);
      }
    });
  }

  Color _filterColor(String f) {
    switch (f) {
      case 'pendente':
        return AppTheme.amber;
      case 'aceita':
        return AppTheme.emerald;
      case 'recusada':
        return AppTheme.red;
      case 'cancelada':
        return AppTheme.zinc;
      default:
        return AppTheme.white;
    }
  }

  int _count(PropostaProvider pp, String filter) {
    if (filter == 'todas') return pp.total;
    return pp.filtradas(filter).length;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pp = context.watch<PropostaProvider>();
    final user = auth.user!;
    final isArtist = user.isArtist;
    final filtered = pp.filtradas(_activeFilter);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(
          isArtist ? 'Propostas Recebidas' : 'Minhas Contratações',
          style: GoogleFonts.inter(
              color: AppTheme.white,
              fontWeight: FontWeight.w800,
              fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.fgSubtle),
            onPressed: () => pp.load(user),
          ),
          if (!isArtist) ...[
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppTheme.white),
              tooltip: 'Nova Proposta',
              onPressed: () => _showCreateSheet(context, user),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => pp.load(user),
        color: AppTheme.white,
        backgroundColor: AppTheme.bgCard,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats row ─────────────────────────
                    _StatsRow(pp: pp),
                    const SizedBox(height: 16),

                    // ── Filtros ────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) {
                          final isActive = _activeFilter == f.$1;
                          final color = _filterColor(f.$1);
                          final cnt = _count(pp, f.$1);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _activeFilter = f.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? color.withValues(alpha: 0.15)
                                      : AppTheme.bgCard,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isActive
                                        ? color.withValues(alpha: 0.5)
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      f.$2,
                                      style: GoogleFonts.inter(
                                        color: isActive
                                            ? color
                                            : AppTheme.fgMuted,
                                        fontSize: 13,
                                        fontWeight: isActive
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    if (f.$1 != 'todas' && cnt > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '($cnt)',
                                        style: GoogleFonts.inter(
                                          color: isActive
                                              ? color.withValues(alpha: 0.7)
                                              : AppTheme.fgMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Lista ─────────────────────────────────────
            if (pp.loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.white, strokeWidth: 2),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  filter: _activeFilter,
                  isArtist: isArtist,
                  onClearFilter: () =>
                      setState(() => _activeFilter = 'todas'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${filtered.length} proposta(s)',
                            style: GoogleFonts.inter(
                              color: AppTheme.fgMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }
                      final proposta = filtered[i - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProposalCard(
                          proposta: proposta,
                          isArtist: isArtist,
                          onUpdateStatus: (id, status) async {
                            try {
                              await pp.updateStatus(id, status);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(status == 'aceita'
                                        ? '✅ Proposta aceita!'
                                        : '❌ Proposta recusada'),
                                  ),
                                );
                              }
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
                          onDelete: (id) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppTheme.bgCard,
                                title: Text('Excluir?',
                                    style: GoogleFonts.inter(
                                        color: AppTheme.white)),
                                content: Text(
                                  'Deseja excluir esta proposta? Esta ação não pode ser desfeita.',
                                  style: GoogleFonts.inter(
                                      color: AppTheme.fgMuted),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text('Cancelar',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.fgMuted)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text('Excluir',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.red,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              try {
                                await pp.deleteProposta(id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🗑️ Proposta excluída!'),
                                    ),
                                  );
                                }
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
                            }
                          },
                        ),
                      );
                    },
                    childCount: filtered.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),

      // ── FAB para contratante ───────────────────────────
      floatingActionButton: !isArtist
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(context, user),
              backgroundColor: AppTheme.white,
              foregroundColor: AppTheme.bg,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Nova Proposta',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  void _showCreateSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateProposalSheet(
        onCreated: () {
          context.read<PropostaProvider>().load(user);
        },
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final PropostaProvider pp;
  const _StatsRow({required this.pp});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Total', pp.total, const Color(0xFF3B82F6)),
      ('Pendentes', pp.pendentes, AppTheme.amber),
      ('Aceitas', pp.aceitas, AppTheme.emerald),
      ('Recusadas', pp.recusadas, AppTheme.red),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                right: s == stats.last ? 0 : 8),
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Text(
                  '${s.$2}',
                  style: GoogleFonts.inter(
                    color: s.$3,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.$1,
                  style: GoogleFonts.inter(
                      color: AppTheme.fgMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  final bool isArtist;
  final VoidCallback onClearFilter;

  const _EmptyState({
    required this.filter,
    required this.isArtist,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != 'todas';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : (isArtist
                      ? Icons.mic_none_rounded
                      : Icons.description_outlined),
              color: AppTheme.fgMuted,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'Sem resultados' : 'Nenhuma proposta',
            style: GoogleFonts.inter(
              color: AppTheme.fgSubtle,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFiltered
                ? 'Tente outro filtro.'
                : (isArtist
                    ? 'Mantenha seu perfil completo para\natrair mais contratantes.'
                    : 'Envie sua primeira proposta para\num artista.'),
            style: GoogleFonts.inter(
                color: AppTheme.fgMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (isFiltered)
            ElevatedButton(
              onPressed: onClearFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.bgCard,
                foregroundColor: AppTheme.white,
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Text('Ver todas',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// ── Create Proposal Bottom Sheet ─────────────────────────────
class CreateProposalSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const CreateProposalSheet({super.key, required this.onCreated});

  @override
  State<CreateProposalSheet> createState() => _CreateProposalSheetState();
}

class _CreateProposalSheetState extends State<CreateProposalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _artistaCtrl = TextEditingController();
  final _tipoEventoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime? _dataEvento;
  bool _loading = false;
  List<UserModel> _artistas = [];
  UserModel? _artistaSelecionado;
  bool _loadingArtistas = false;

  @override
  void initState() {
    super.initState();
    _loadArtistas();
  }

  Future<void> _loadArtistas() async {
    setState(() => _loadingArtistas = true);
    try {
      _artistas = await UsuarioService.getArtistas();
    } catch (_) {}
    if (mounted) setState(() => _loadingArtistas = false);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _localCtrl.dispose();
    _valorCtrl.dispose();
    _artistaCtrl.dispose();
    _tipoEventoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.white),
          dialogTheme: const DialogThemeData(backgroundColor: AppTheme.bgCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dataEvento = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataEvento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data do evento')),
      );
      return;
    }
    if (_artistaSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um artista')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final pp = context.read<PropostaProvider>();
      await pp.create({
        'id_artista': _artistaSelecionado!.id,
        'titulo': _tituloCtrl.text.trim(),
        'descricao': _descCtrl.text.trim(),
        'local_evento': _localCtrl.text.trim(),
        'data_evento': DateFormat('yyyy-MM-dd').format(_dataEvento!),
        'valor_oferecido': double.parse(_valorCtrl.text.replaceAll(',', '.')),
        if (_tipoEventoCtrl.text.isNotEmpty)
          'tipo_evento': _tipoEventoCtrl.text.trim(),
        if (_obsCtrl.text.isNotEmpty) 'observacoes': _obsCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Proposta enviada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nova Proposta',
                    style: GoogleFonts.inter(
                      color: AppTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.fgMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.border),

            // Form
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artista
                      _SheetLabel('Artista *'),
                      const SizedBox(height: 8),
                      if (_loadingArtistas)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                color: AppTheme.white, strokeWidth: 2),
                          ),
                        )
                      else
                        DropdownButtonFormField<UserModel>(
                          value: _artistaSelecionado,
                          dropdownColor: AppTheme.bgCard,
                          decoration: InputDecoration(
                            hintText: 'Selecione um artista',
                            prefixIcon: const Icon(Icons.person_outline_rounded,
                                color: AppTheme.fgMuted, size: 18),
                          ),
                          items: _artistas
                              .map((a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(
                                      '${a.name}${a.generoMusical != null ? ' • ${a.generoMusical}' : ''}',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.white, fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _artistaSelecionado = v),
                          validator: (_) => _artistaSelecionado == null
                              ? 'Selecione um artista'
                              : null,
                        ),
                      const SizedBox(height: 16),

                      _SheetLabel('Título *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tituloCtrl,
                        style: GoogleFonts.inter(
                            color: AppTheme.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ex: Show de Rock no Bar...',
                          prefixIcon: Icon(Icons.title_rounded,
                              color: AppTheme.fgMuted, size: 18),
                        ),
                        validator: (v) => v == null || v.length < 3
                            ? 'Mínimo 3 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _SheetLabel('Descrição *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        style: GoogleFonts.inter(
                            color: AppTheme.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Descreva o evento e o que você precisa...',
                          prefixIcon: Icon(Icons.description_outlined,
                              color: AppTheme.fgMuted, size: 18),
                        ),
                        validator: (v) => v == null || v.length < 10
                            ? 'Mínimo 10 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _SheetLabel('Local do Evento *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _localCtrl,
                        style: GoogleFonts.inter(
                            color: AppTheme.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ex: Bar do Zé, São Paulo - SP',
                          prefixIcon: Icon(Icons.location_on_outlined,
                              color: AppTheme.fgMuted, size: 18),
                        ),
                        validator: (v) => v == null || v.length < 3
                            ? 'Informe o local'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _SheetLabel('Data do Evento *'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppTheme.fgMuted, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                _dataEvento != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_dataEvento!)
                                    : 'Selecionar data',
                                style: GoogleFonts.inter(
                                  color: _dataEvento != null
                                      ? AppTheme.white
                                      : AppTheme.fgMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _SheetLabel('Valor Oferecido (R\$) *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _valorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: GoogleFonts.inter(
                            color: AppTheme.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '500,00',
                          prefixIcon: Icon(Icons.attach_money_rounded,
                              color: AppTheme.fgMuted, size: 18),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o valor';
                          final n = double.tryParse(v.replaceAll(',', '.'));
                          if (n == null || n <= 0) return 'Valor inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _SheetLabel('Tipo de Evento'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tipoEventoCtrl,
                        style: GoogleFonts.inter(
                            color: AppTheme.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ex: Casamento, Show, Corporativo...',
                          prefixIcon: Icon(Icons.event_outlined,
                              color: AppTheme.fgMuted, size: 18),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _SheetLabel('Observações'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _obsCtrl,
                        maxLines: 2,
                        style: GoogleFonts.inter(
                            color: AppTheme.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Informações adicionais...',
                          prefixIcon: Icon(Icons.notes_rounded,
                              color: AppTheme.fgMuted, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botão enviar
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
              decoration: const BoxDecoration(
                color: AppTheme.bgCard,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.bg),
                        )
                      : Text(
                          'Enviar Proposta',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppTheme.fgSubtle,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
