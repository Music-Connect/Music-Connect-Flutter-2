import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/proposta_model.dart';
import '../../shared/theme/app_theme.dart';
import 'status_badge.dart';

class ProposalCard extends StatefulWidget {
  final PropostaModel proposta;
  final bool isArtist;
  final Function(int id, String status)? onUpdateStatus;
  final Function(int id)? onDelete;

  const ProposalCard({
    super.key,
    required this.proposta,
    required this.isArtist,
    this.onUpdateStatus,
    this.onDelete,
  });

  @override
  State<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  bool _expanded = false;

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    } catch (_) {
      return dateStr.substring(0, 10).split('-').reversed.join('/');
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proposta;
    final otherPerson = widget.isArtist ? p.contratante : p.artista;
    final canAct = widget.isArtist && p.status == 'pendente';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expanded ? AppTheme.borderLight : AppTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.titulo,
                          style: GoogleFonts.inter(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(p.status),
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => widget.onDelete?.call(p.idProposta),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0x1AEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                size: 16, color: AppTheme.red),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Info row
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: p.localEvento,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(p.dataEvento),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Valor
                      Text(
                        _formatCurrency(p.valorOferecido),
                        style: GoogleFonts.inter(
                          color: AppTheme.emerald,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // Pessoa da outra parte
                      if (otherPerson != null)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.border,
                              backgroundImage: otherPerson.image != null
                                  ? NetworkImage(otherPerson.image!)
                                  : null,
                              child: otherPerson.image == null
                                  ? Text(
                                      otherPerson.name[0].toUpperCase(),
                                      style: GoogleFonts.inter(
                                          color: AppTheme.fgSubtle,
                                          fontSize: 10),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              otherPerson.name,
                              style: GoogleFonts.inter(
                                color: AppTheme.fgMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Expandido: detalhes ────────────────────────
            if (_expanded) ...[
              Divider(color: AppTheme.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailItem(label: 'Descrição', value: p.descricao),
                    if (p.tipoEvento != null)
                      _DetailItem(label: 'Tipo de Evento', value: p.tipoEvento!),
                    if (p.duracaoHoras != null)
                      _DetailItem(
                          label: 'Duração',
                          value: '${p.duracaoHoras}h'),
                    if (p.publicoEsperado != null)
                      _DetailItem(
                          label: 'Público Esperado',
                          value: '${p.publicoEsperado} pessoas'),
                    if (p.equipamentoIncluso != null)
                      _DetailItem(
                          label: 'Equipamento',
                          value: p.equipamentoIncluso! ? 'Incluso' : 'Não incluso'),
                    if (p.horaEvento != null)
                      _DetailItem(label: 'Horário', value: p.horaEvento!),
                    if (p.enderecoCompleto != null)
                      _DetailItem(
                          label: 'Endereço', value: p.enderecoCompleto!),
                    if (p.observacoes != null)
                      _DetailItem(label: 'Observações', value: p.observacoes!),
                    if (p.mensagemResposta != null)
                      _DetailItem(
                          label: 'Mensagem de Resposta',
                          value: p.mensagemResposta!),
                  ],
                ),
              ),
            ],

            // ── Botões aceitar/recusar ─────────────────────
            if (canAct) ...[
              Divider(color: AppTheme.border, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Recusar',
                        color: AppTheme.red,
                        bgColor: const Color(0x26EF4444),
                        onTap: () => widget.onUpdateStatus
                            ?.call(p.idProposta, 'recusada'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Aceitar',
                        color: AppTheme.emerald,
                        bgColor: const Color(0x2610B981),
                        onTap: () => widget.onUpdateStatus
                            ?.call(p.idProposta, 'aceita'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.fgMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
                color: AppTheme.fgMuted, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                  color: AppTheme.fgMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                  color: AppTheme.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
              color: color, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
