import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscure = true;
  final _emailCtrl = TextEditingController(text: 'minhtu@gmail.com');
  final _passCtrl = TextEditingController(text: '••••••••');
  final _nameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCard,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4B30D4), Color(0xFF7C5DFA), Color(0xFFFF7B4F)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'JobConnect VN',
            style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nền tảng việc làm thông minh cho sinh viên',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabToggle(),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'hoặc',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          _buildGoogleButton(),
          const SizedBox(height: 24),
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Bằng cách đăng nhập, bạn đồng ý với ',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Điều khoản sử dụng',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tabBtn('Đăng nhập', true),
          _tabBtn('Đăng ký', false),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool isLoginTab) {
    final selected = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLogin = isLoginTab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Email'),
        const SizedBox(height: 6),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'you@example.com'),
        ),
        const SizedBox(height: 14),
        _fieldLabel('Mật khẩu'),
        const SizedBox(height: 6),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Quên mật khẩu?',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        GradientButton(label: 'Đăng nhập', onTap: widget.onLogin),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Họ và tên'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Nguyễn Minh Tú'),
        ),
        const SizedBox(height: 14),
        _fieldLabel('Email'),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'you@example.com'),
        ),
        const SizedBox(height: 14),
        _fieldLabel('Mật khẩu'),
        const SizedBox(height: 6),
        TextField(
          controller: _regPassCtrl,
          obscureText: true,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Tối thiểu 8 ký tự'),
        ),
        const SizedBox(height: 20),
        GradientButton(label: 'Tạo tài khoản', onTap: widget.onLogin),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: widget.onLogin,
      icon: const Icon(Icons.g_mobiledata_rounded, size: 22, color: Color(0xFFDB4437)),
      label: Text(
        'Tiếp tục với Google',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}