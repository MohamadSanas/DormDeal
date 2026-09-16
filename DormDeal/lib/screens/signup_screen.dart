import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class _SC {
  static const primary            = Color(0xFF003F87);
  static const primaryContainer   = Color(0xFF0056B3);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outline            = Color(0xFF727784);
  static const outlineVariant     = Color(0xFFC2C6D4);
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose();
    _passwordController.dispose(); _confirmController.dispose();
    _fadeCtrl.dispose(); super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiService().signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Color(0xFF1B6B3A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dec({required String hint, required IconData prefixIcon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _SC.outline, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: _SC.onSurfaceVariant, size: 20),
      suffixIcon: suffix,
      filled: true, fillColor: _SC.surfaceLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _SC.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _SC.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _SC.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _SC.onSurface)),
  );

  Widget _eyeBtn(bool obscure, VoidCallback onTap) => IconButton(
    icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _SC.onSurfaceVariant, size: 20),
    onPressed: onTap, padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SC.background,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 600 ? 16 : 64, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _buildCard(),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _SC.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _SC.secondaryContainer),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/DormDeal.jpg', width: 96, height: 96, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          const Text('Create Account', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: _SC.primary)),
          const SizedBox(height: 4),
          const Text('Join the campus marketplace.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: _SC.onSurfaceVariant)),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Full Name'),
                TextFormField(
                  controller: _nameController, textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 16, color: _SC.onSurface),
                  decoration: _dec(hint: 'Jane Doe', prefixIcon: Icons.person_outline_rounded),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _label('University Email (.edu)'),
                TextFormField(
                  controller: _emailController, keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16, color: _SC.onSurface),
                  decoration: _dec(hint: 'jane.doe@university.edu', prefixIcon: Icons.mail_outline_rounded),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Password'),
                TextFormField(
                  controller: _passwordController, obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 16, color: _SC.onSurface),
                  decoration: _dec(hint: '••••••••', prefixIcon: Icons.lock_outline_rounded,
                    suffix: _eyeBtn(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword))),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Confirm Password'),
                TextFormField(
                  controller: _confirmController, obscureText: _obscureConfirm,
                  style: const TextStyle(fontSize: 16, color: _SC.onSurface),
                  decoration: _dec(hint: '••••••••', prefixIcon: Icons.lock_reset_rounded,
                    suffix: _eyeBtn(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm))),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _SignupButton(isLoading: _isLoading, onPressed: _handleSignup),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? ', style: TextStyle(fontSize: 14, color: _SC.onSurfaceVariant)),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Log In', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _SC.primary,
                  decoration: TextDecoration.underline, decorationColor: _SC.primary,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignupButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _SignupButton({required this.isLoading, required this.onPressed});
  @override
  State<_SignupButton> createState() => _SignupButtonState();
}

class _SignupButtonState extends State<_SignupButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 90), lowerBound: 0.98, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) { _scaleCtrl.forward(); if (!widget.isLoading) widget.onPressed(); },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            color: widget.isLoading ? const Color(0xFF0056B3) : const Color(0xFF003F87),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.isLoading
                ? const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))]
                : const [
                    Text('Create Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
          ),
        ),
      ),
    );
  }
}
