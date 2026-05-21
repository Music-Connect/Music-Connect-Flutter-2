import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../explore/explore_screen.dart';
import '../profile/profile_screen.dart';
import '../proposals/proposals_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    final List<Widget> screens = [
      const DashboardScreen(),
      const ExploreScreen(),
      const ProposalsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppTheme.bgCard,
            indicatorColor: AppTheme.white.withOpacity(0.1),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white);
              }
              return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.fgMuted);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) {
              setState(() => _currentIndex = idx);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppTheme.fgMuted),
                selectedIcon: Icon(Icons.home_filled, color: AppTheme.white),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined, color: AppTheme.fgMuted),
                selectedIcon: Icon(Icons.search_rounded, color: AppTheme.white),
                label: 'Explorar',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined, color: AppTheme.fgMuted),
                selectedIcon: Icon(Icons.library_music_rounded, color: AppTheme.white),
                label: 'Propostas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: AppTheme.fgMuted),
                selectedIcon: Icon(Icons.person, color: AppTheme.white),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
