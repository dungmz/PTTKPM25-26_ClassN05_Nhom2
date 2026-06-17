import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/jobs/providers/jobs_provider.dart';
import 'features/apply/providers/apply_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/jobs/screens/home_screen.dart';
import 'features/jobs/screens/jobs_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/jobs/screens/create_job_screen.dart';
import 'features/jobs/screens/candidate_list_screen.dart';
import 'features/auth/screens/verify_email_screen.dart';
import 'features/chat/screens/chat_list_screen.dart'; 

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => JobsProvider()),
        ChangeNotifierProvider(create: (_) => ApplyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: const JobConnectApp(),
    ),
  );
}

class JobConnectApp extends StatelessWidget {
  const JobConnectApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobConnect VN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (ctx, auth, _) {
      switch (auth.status) {
        case AuthStatus.initial:
        case AuthStatus.loading:
          return const _SplashScreen();
        case AuthStatus.authenticated:
          return const MainShell();
        case AuthStatus.unauthenticated:
        case AuthStatus.error:
          return const LoginScreen();
      }
    });
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight]),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 6))]),
            child: const Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 36)),
          const SizedBox(height: 20),
          Text('JobConnect VN', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 32),
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
        ])),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final isEmployer = auth.user?.role == 'employer';
    final notif = context.watch<NotificationsProvider>();

    final isVerified = auth.isVerified;

    final screens = [
      const HomeScreen(),
      isEmployer ? const CandidateListScreen() : const JobsScreen(),
      const ChatListScreen(), 
      const NotificationsScreen(),
      const ProfileScreen()
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _tab, children: screens),
          if (!isVerified && auth.user != null)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.accent.withOpacity(0.9),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tài khoản chưa được xác thực!',
                        style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyEmailScreen())),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Xác thực ngay', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (isEmployer && _tab == 0 && isVerified)
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateJobScreen())),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.bgCard, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,          label: 'Trang chủ', idx: 0, cur: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavItem(
                  icon: Icons.work_outline,
                  activeIcon: Icons.work_rounded,
                  label: isEmployer ? 'Ứng viên' : 'Việc làm',
                  idx: 1,
                  cur: _tab,
                  onTap: (i) => setState(() => _tab = i),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline, 
                  activeIcon: Icons.chat_bubble_rounded, 
                  label: 'Trò chuyện', 
                  idx: 2, 
                  cur: _tab, 
                  onTap: (i) => setState(() => _tab = i)
                ), 
                _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Thông báo', idx: 3, cur: _tab, onTap: (i) => setState(() => _tab = i), badge: notif.unreadCount),
                _NavItem(icon: Icons.person_outline,         activeIcon: Icons.person_rounded,        label: 'Hồ sơ',    idx: 4, cur: _tab, onTap: (i) => setState(() => _tab = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int idx, cur;
  final void Function(int) onTap;
  final int badge;
  const _NavItem({required this.icon, required this.activeIcon, required this.label,
    required this.idx, required this.cur, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final active = cur == idx;
    return GestureDetector(
      onTap: () => onTap(idx), behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 72, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: active ? AppColors.bgPurpleLight : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
            child: Icon(active ? activeIcon : icon, color: active ? AppColors.primary : AppColors.textMuted, size: 22)),
          if (badge > 0) Positioned(top: -2, right: -2, child: Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('$badge', style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)))),
        ]),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppColors.primary : AppColors.textMuted)),
      ])),
    );
  }
}
