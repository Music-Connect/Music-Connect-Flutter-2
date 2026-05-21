import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/usuario_service.dart';
import '../../shared/theme/app_theme.dart';
import '../proposals/proposals_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _artists = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadArtists([String? query]) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Usamos a query tanto para genero quanto para local por simplicidade
      final all = await UsuarioService.getArtistas();
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        _artists = all.where((a) {
          return a.name.toLowerCase().contains(q) ||
                 (a.cidade?.toLowerCase().contains(q) ?? false) ||
                 (a.generoMusical?.toLowerCase().contains(q) ?? false);
        }).toList();
      } else {
        _artists = all;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isContractor = user != null && !user.isArtist;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text(
          'Explorar Artistas',
          style: GoogleFonts.inter(
            color: AppTheme.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.inter(color: AppTheme.white, fontSize: 14),
              onSubmitted: _loadArtists,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, cidade ou gênero...',
                hintStyle: GoogleFonts.inter(color: AppTheme.fgSubtle),
                prefixIcon: const Icon(Icons.search, color: AppTheme.fgMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.fgMuted),
                  onPressed: () {
                    _searchCtrl.clear();
                    _loadArtists();
                  },
                ),
                filled: true,
                fillColor: AppTheme.bgCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
            ),
          ),
        ),
      ),
      body: _buildBody(isContractor),
    );
  }

  Widget _buildBody(bool isContractor) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.inter(color: AppTheme.fgMuted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _loadArtists(_searchCtrl.text),
              child: Text('Tentar novamente',
                  style: GoogleFonts.inter(color: AppTheme.white)),
            ),
          ],
        ),
      );
    }
    if (_artists.isEmpty) {
      return Center(
        child: Text(
          'Nenhum artista encontrado.',
          style: GoogleFonts.inter(color: AppTheme.fgMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _artists.length,
      itemBuilder: (ctx, i) {
        final artist = _artists[i];
        return _ArtistCard(
          artist: artist,
          isContractor: isContractor,
          onPropose: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CreateProposalSheet(
                onCreated: () {
                  // Pode fazer algo após criar a proposta
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final UserModel artist;
  final bool isContractor;
  final VoidCallback onPropose;

  const _ArtistCard({
    required this.artist,
    required this.isContractor,
    required this.onPropose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.border,
                backgroundImage: artist.image != null
                    ? NetworkImage(artist.image!)
                    : null,
                child: artist.image == null
                    ? Text(
                        artist.name[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          color: AppTheme.fgMuted,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: GoogleFonts.inter(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (artist.generoMusical != null)
                      Text(
                        artist.generoMusical!,
                        style: GoogleFonts.inter(
                          color: AppTheme.fgMuted,
                          fontSize: 13,
                        ),
                      ),
                    if (artist.cidade != null)
                      Text(
                        '${artist.cidade}${artist.estado != null ? ' - ${artist.estado}' : ''}',
                        style: GoogleFonts.inter(
                          color: AppTheme.fgSubtle,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isContractor) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPropose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Fazer Proposta',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
