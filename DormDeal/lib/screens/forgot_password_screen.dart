import 'package:flutter/material.dart';
import 'login_screen.dart';

class _C {
  static const primary            = Color(0xFF003F87);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outline            = Color(0xFF727784);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const successGreen       = Color(0xFF1B6B3A);
  static const successBg          = Color(0xFFD1FAE5);
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() { _emailSent = true; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')));
      setState(() => _isLoading = false);
    }
  }

  void _goLogin() => Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  InputDecoration _dec() => InputDecoration(
    hintText: 'student@university.edu',
    hintStyle: const TextStyle(color: _C.outline, fontSize: 14),
    prefixIcon: const Icon(Icons.mail_outline_rounded, color: _C.outline, size: 20),
    filled: true, fillColor: _C.surfaceLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _C.outlineVariant)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _C.outlineVariant)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _C.primary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth < 600 ? 16 : 64, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: _emailSent ? _buildSuccess() : _buildForm(),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.secondaryContainer),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _C.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: _C.primary),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: _C.secondaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.lock_reset_rounded, size: 40, color: _C.primary),
          ),
          const SizedBox(height: 20),
          const Text('Forgot Password?', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: _C.onSurface)),
          const SizedBox(height: 8),
          const Text(
            'No worries! Enter your university email and we will send you a reset link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.5, color: _C.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('University Email',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: _C.onSurface)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16, color: _C.onSurface),
                  decoration: _dec(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _SendButton(isLoading: _isLoading, onPressed: _handleSend),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _goLogin,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.arrow_back_rounded, size: 14, color: _C.onSurfaceVariant),
              SizedBox(width: 4),
              Text('Back to Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: _C.primary, decoration: TextDecoration.underline, decorationColor: _C.primary)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.secondaryContainer),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: _C.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_rounded, size: 40, color: _C.successGreen),
          ),
          const SizedBox(height: 20),
          const Text('Check Your Email', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: _C.onSurface)),
          const SizedBox(height: 8),
          Text(
            'We sent a reset link to\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.5, color: _C.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => setState(() { _emailSent = false; _emailController.clear(); }),
            child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.primary, width: 1.5)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.refresh_rounded, color: _C.primary, size: 18),
                SizedBox(width: 8),
                Text('Resend Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.primary)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _goLogin,
            child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Back to Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _SendButton({required this.isLoading, required this.onPressed});
  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> with SingleTickerProviderStateMixin {
  late final AnimationController _sc;
  @override
  void initState() {
    super.initState();
    _sc = AnimationController(vsync: this, duration: const Duration(milliseconds: 90),
      lowerBound: 0.98, upperBound: 1.0, value: 1.0);
  }
  @override
  void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _sc.reverse(),
      onTapUp: (_) { _sc.forward(); if (!widget.isLoading) widget.onPressed(); },
      onTapCancel: () => _sc.forward(),
      child: ScaleTransition(
        scale: _sc,
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
                ? const [SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))]
                : const [
                    Text('Send Reset Link', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ],
          ),
        ),
      ),
    );
  }
}
