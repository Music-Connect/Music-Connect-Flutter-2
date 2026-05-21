import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/usuario_service.dart';
import '../../shared/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _editing = false;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _descCtrl.text = user.descricao ?? '';
      _telCtrl.text = user.telefone ?? '';
      _cidadeCtrl.text = user.cidade ?? '';
      _estadoCtrl.text = user.estado ?? '';
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _telCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final user = auth.user!;

    try {
      final updated = await UsuarioService.updateUsuario(user.id, {
        'name': _nameCtrl.text.trim(),
        'descricao': _descCtrl.text.trim(),
        'telefone': _telCtrl.text.trim(),
        'cidade': _cidadeCtrl.text.trim(),
        'estado': _estadoCtrl.text.trim().toUpperCase(),
      });
      auth.updateUser(updated);
      setState(() => _editing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Perfil atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.bg,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFE11D48), Color(0xFFD946EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppTheme.white),
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildHeader(user),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabCtrl,
                indicatorColor: AppTheme.white,
                labelColor: AppTheme.white,
                unselectedLabelColor: AppTheme.fgMuted,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Sobre'),
                  Tab(text: 'Portfólio'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildSobreTab(user),
                _buildPortfolioTab(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar que sobrepõe
          Transform.translate(
            offset: const Offset(0, -40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.bg, width: 4),
                    image: user.image != null
                        ? DecorationImage(
                            image: NetworkImage(user.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.image == null
                      ? Center(
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: GoogleFonts.inter(
                              color: AppTheme.fgMuted,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : null,
                ),
                const Spacer(),
                if (!_editing)
                  ElevatedButton(
                    onPressed: () => setState(() => _editing = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Editar Perfil',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
          // Info Básica
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  user.isArtist ? 'Artista' : 'Contratante',
                  style: GoogleFonts.inter(
                    color: AppTheme.fgMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (user.generoMusical != null && user.generoMusical!.isNotEmpty)
                      _Badge(
                        icon: Icons.music_note_rounded,
                        label: user.generoMusical!,
                        color: AppTheme.red,
                        bgColor: AppTheme.red.withOpacity(0.1),
                      ),
                    if (user.cidade != null && user.cidade!.isNotEmpty)
                      _Badge(
                        icon: Icons.location_on_rounded,
                        label: '${user.cidade}${user.estado != null ? ', ${user.estado}' : ''}',
                        color: AppTheme.fgSubtle,
                        bgColor: AppTheme.bgCard,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSobreTab(UserModel user) {
    if (_editing) {
      return _buildEditForm();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.descricao != null && user.descricao!.isNotEmpty) ...[
            Text(
              'Sobre Mim',
              style: GoogleFonts.inter(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.descricao!,
              style: GoogleFonts.inter(
                color: AppTheme.fgMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Informações',
            style: GoogleFonts.inter(
              color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.email_outlined, label: 'E-mail', value: user.email),
          if (user.telefone != null && user.telefone!.isNotEmpty)
            _InfoRow(icon: Icons.phone_outlined, label: 'Telefone', value: user.telefone!),
          if (user.cidade != null && user.cidade!.isNotEmpty)
            _InfoRow(
              icon: Icons.map_outlined,
              label: 'Local',
              value: '${user.cidade}${user.estado != null ? ', ${user.estado}' : ''}',
            ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar Perfil',
                  style: GoogleFonts.inter(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _editing = false),
                  child: Text('Cancelar',
                      style: GoogleFonts.inter(color: AppTheme.fgMuted)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Nome',
              controller: _nameCtrl,
              icon: Icons.person_outline_rounded,
              validator: (v) => (v != null && v.isNotEmpty && v.length < 2)
                  ? 'Mínimo 2 caracteres'
                  : null,
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Telefone',
              controller: _telCtrl,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (!RegExp(r'^\+?[0-9()\-\s]{8,20}$').hasMatch(v)) {
                  return 'Telefone inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _Field(
                    label: 'Cidade',
                    controller: _cidadeCtrl,
                    icon: Icons.location_city_outlined,
                    validator: (v) => (v != null && v.isNotEmpty && v.length < 2)
                        ? 'Mínimo 2 caracteres'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _Field(
                    label: 'UF',
                    controller: _estadoCtrl,
                    icon: Icons.map_outlined,
                    maxLength: 2,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!RegExp(r'^[A-Z]{2}$').hasMatch(v.toUpperCase())) {
                        return 'Ex: SP';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Descrição',
              controller: _descCtrl,
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        'Salvar Alterações',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioTab(UserModel user) {
    if (!user.isArtist) {
      return Center(
        child: Text(
          'Portfólio disponível apenas para artistas.',
          style: GoogleFonts.inter(color: AppTheme.fgMuted),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4, // Placeholder items for now
      itemBuilder: (ctx, i) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Center(
            child: Icon(Icons.add_photo_alternate_outlined,
                color: AppTheme.fgMuted),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.bg,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.fgMuted, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  color: AppTheme.fgSubtle,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppTheme.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(color: AppTheme.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppTheme.fgMuted),
        alignLabelWithHint: true,
        prefixIcon: Icon(icon, color: AppTheme.fgMuted, size: 20),
        filled: true,
        fillColor: AppTheme.bgCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
    );
  }
}
