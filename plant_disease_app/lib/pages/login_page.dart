import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart' show AppColors, HomePage;

// ════════════════════════════════════════════════════════════════
// ONBOARDING FLOW  →  WELCOME  →  SIGN IN / SIGN UP
// ════════════════════════════════════════════════════════════════
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OnboardingFlow();
  }
}

// ── 3-step onboarding ─────────────────────────────────────────
class _OnboardingFlow extends StatefulWidget {
  const _OnboardingFlow();
  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow>
    with TickerProviderStateMixin {
  final PageController _pc = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardData(
      emoji: '🌿',
      title: 'Welcome to\nPlantGuard',
      subtitle: 'AI-powered plant disease detection.\nInstant diagnosis for every farmer.',
      features: [],
    ),
    _OnboardData(
      emoji: '📷',
      title: 'Scan Any Leaf\nInstantly',
      subtitle: 'Point your camera at a diseased leaf.\nGet results in under 1 second.',
      features: ['38 plant diseases', '14 crop types', 'Works offline'],
    ),
    _OnboardData(
      emoji: '🛡️',
      title: 'Protect Your\nCrops Today',
      subtitle: 'Treatment advice, weather alerts,\nand farmer community — all in one.',
      features: ['Smart weather advisory', 'Community tips', 'Expert recommendations'],
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      _goToAuth();
    }
  }

  void _goToAuth() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, b) => const _AuthPage(),
      transitionsBuilder: (_, a, b, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1F0E),
        body: Stack(children: [
          // ── Animated background ─────────────────────────
          const Positioned.fill(child: _GreenBackground()),

          // ── Page view ───────────────────────────────────
          PageView.builder(
            controller: _pc,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardPage(data: _pages[i], isFirst: i == 0),
          ),

          // ── Bottom controls ─────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Dots
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
                    _pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8, height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? Colors.white : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),

                  // Continue button
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF00FF87), Color(0xFF00FFBD)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 8))],
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          _page == _pages.length - 1 ? 'GET STARTED' : 'CONTINUE',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900, fontSize: 15,
                            color: const Color(0xFF041209), letterSpacing: 1.2),
                        ),
                        const SizedBox(width: 10),
                        Icon(_page == _pages.length - 1 ? Icons.agriculture_rounded : Icons.arrow_forward_rounded,
                          color: const Color(0xFF041209), size: 20),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skip / sign in
                  GestureDetector(
                    onTap: _goToAuth,
                    child: Text('Already have an account? Sign In',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _OnboardData {
  final String emoji, title, subtitle;
  final List<String> features;
  const _OnboardData({required this.emoji, required this.title,
    required this.subtitle, required this.features});
}

// ── Single onboard page ────────────────────────────────────────
class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  final bool isFirst;
  const _OnboardPage({required this.data, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 160),
      child: Column(children: [
        // Large emoji hero with floating animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final offset = math.sin(value * math.pi * 2) * 10;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: size.width * 0.55, height: size.width * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
                  boxShadow: [BoxShadow(color: const Color(0xFF00FF87).withValues(alpha: 0.3), blurRadius: 50)],
                ),
                child: Center(child: Text(data.emoji, style: TextStyle(fontSize: size.width * 0.22))),
              ),
            );
          },
        ),
        const SizedBox(height: 36),

        // Title
        Text(data.title, textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 32,
            color: Colors.white, height: 1.2)),
        const SizedBox(height: 12),

        // Subtitle
        Text(data.subtitle, textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 15,
            color: Colors.white.withValues(alpha: 0.7), height: 1.6)),

        if (data.features.isNotEmpty) ...[
          const SizedBox(height: 28),
          // Feature pills
          Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
            children: data.features.map((f) => _GlassPill(text: f)).toList()),
        ],
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// AUTH PAGE  —  Sign In / Sign Up with glassmorphism
// ════════════════════════════════════════════════════════════════
class _AuthPage extends StatefulWidget {
  const _AuthPage();
  @override
  State<_AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _isLogin    = true;
  bool _obscurePw  = true;
  bool _obscureCf  = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    _nameCtrl.dispose();  _confirmCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _animCtrl.reverse().then((_) {
      setState(() => _isLogin = !_isLogin);
      _animCtrl.forward();
    });
  }

  Future<void> _submit(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ctx.read<AuthProvider>();
    bool ok;
    if (_isLogin) {
      ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      ok = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    }
    if (ok && ctx.mounted) {
      Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1F0E),
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          const Positioned.fill(child: _GreenBackground()),

          SafeArea(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Consumer<AuthProvider>(
              builder: (ctx, auth, _) => Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Hero section ─────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF25A05C).withValues(alpha: 0.3), blurRadius: 20)],
                        ),
                        child: const Center(child: Text('🌿', style: TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin ? 'Welcome back,\nFarmer 👋' : 'Join PlantGuard,\nFarmer 🌾',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 32,
                          color: Colors.white, height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                          ? 'Sign in to protect your crops with AI.'
                          : 'Create account to unlock all features.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.65)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // ── Feature pills (sign up only) ──────────
                  if (!_isLogin) ...[
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: const [
                          _GlassPill(text: '🤖 AI Diagnosis', small: true),
                          SizedBox(width: 8),
                          _GlassPill(text: '🌤️ Weather Alerts', small: true),
                          SizedBox(width: 8),
                          _GlassPill(text: '📚 Disease Library', small: true),
                          SizedBox(width: 8),
                          _GlassPill(text: '👥 Community', small: true),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Glass form card ───────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(22),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(children: [

                            // Name field (signup only)
                            if (!_isLogin) ...[
                              _GlassField(
                                ctrl: _nameCtrl,
                                hint: 'Full Name',
                                icon: Icons.person_rounded,
                                validator: (v) => (v?.isEmpty ?? true) ? 'Enter your name' : null,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Email
                            _GlassField(
                              ctrl: _emailCtrl,
                              hint: 'Email Address',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Enter email';
                                if (!(v!.contains('@'))) return 'Invalid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Password
                            _GlassField(
                              ctrl: _passwordCtrl,
                              hint: 'Password',
                              icon: Icons.lock_rounded,
                              obscure: _obscurePw,
                              suffix: GestureDetector(
                                onTap: () => setState(() => _obscurePw = !_obscurePw),
                                child: Icon(_obscurePw ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.white54, size: 18)),
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Enter password';
                                if (!_isLogin && (v?.length ?? 0) < 6) return 'Min 6 characters';
                                return null;
                              },
                            ),

                            // Confirm password (signup)
                            if (!_isLogin) ...[
                              const SizedBox(height: 12),
                              _GlassField(
                                ctrl: _confirmCtrl,
                                hint: 'Confirm Password',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscureCf,
                                suffix: GestureDetector(
                                  onTap: () => setState(() => _obscureCf = !_obscureCf),
                                  child: Icon(_obscureCf ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: Colors.white54, size: 18)),
                                validator: (v) =>
                                  v != _passwordCtrl.text ? 'Passwords do not match' : null,
                              ),
                            ],

                            // Forgot password
                            if (_isLogin) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => _showForgotDialog(context),
                                  child: Text('Forgot Password?',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700,
                                      fontSize: 12, color: const Color(0xFF6ED498))),
                                ),
                              ),
                            ],

                            // Error
                            if (auth.error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(auth.error!,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.redAccent))),
                                ]),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Submit button
                            auth.isLoading
                              ? const SizedBox(height: 56,
                                  child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                              : GestureDetector(
                                  onTap: () => _submit(ctx),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF25A05C), Color(0xFF0D3320)]),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(
                                        color: const Color(0xFF25A05C).withValues(alpha: 0.4),
                                        blurRadius: 20, offset: const Offset(0, 6))],
                                    ),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(_isLogin ? Icons.login_rounded : Icons.agriculture_rounded,
                                        color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Text(_isLogin ? 'Sign In' : 'Create Account',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900,
                                          fontSize: 16, color: Colors.white)),
                                    ]),
                                  ),
                                ),
                          ]),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Features showcase (login only) ────────
                  if (_isLogin) ...[
                    _FeatureRow(icon: '🤖', title: 'AI Diagnosis',
                      sub: '38 diseases across 14 crop types — works offline'),
                    const SizedBox(height: 10),
                    _FeatureRow(icon: '🌤️', title: 'Weather Advisory',
                      sub: 'Real-time disease risk based on your location'),
                    const SizedBox(height: 10),
                    _FeatureRow(icon: '👥', title: 'Farmer Community',
                      sub: 'Share tips and ask questions in real-time'),
                    const SizedBox(height: 24),
                  ],

                  // Toggle sign in / sign up
                  Center(
                    child: GestureDetector(
                      onTap: _toggle,
                      child: RichText(text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.65)),
                        children: [
                          TextSpan(text: _isLogin ? "Don't have an account? " : "Already have an account? "),
                          TextSpan(
                            text: _isLogin ? 'Sign Up' : 'Sign In',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                              fontSize: 14, color: const Color(0xFF6ED498)).copyWith(decoration: TextDecoration.underline)),
                        ],
                      )),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Disclaimer
                  Center(child: Text(
                    'Not a substitute for expert agronomist advice.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.35)))),
                ]),
              ),
            ),
          )),
        ]),
      ),
    );
  }

  void _showForgotDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1F0E).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🔑', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text('Reset Password', style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Enter your email to receive a reset link',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 20),
                _GlassField(ctrl: ctrl, hint: 'Email', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Center(child: Text('Cancel', style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white70))),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Reset link sent to ${ctrl.text}',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
                        backgroundColor: AppColors.g600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF25A05C), Color(0xFF0D3320)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('Send Link', style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white))),
                    ),
                  )),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════════════════════════════

// ── Animated green background ──────────────────────────────────
class _GreenBackground extends StatefulWidget {
  const _GreenBackground();
  @override
  State<_GreenBackground> createState() => _GreenBackgroundState();
}

class _GreenBackgroundState extends State<_GreenBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(children: [
        // Base dark green
        Container(color: const Color(0xFF061209)),

        // Large blurry orbs
        Positioned(
          top: -100 + _anim.value * 50,
          left: -80 + _anim.value * 40,
          child: _Orb(size: 380, color: const Color(0xFF00FF87), opacity: 0.35)), // Neon Green
        Positioned(
          top: 220 + _anim.value * 70,
          right: -100 - _anim.value * 30,
          child: _Orb(size: 300, color: const Color(0xFF60EFFF), opacity: 0.3)), // Neon Blue
        Positioned(
          bottom: -80 - _anim.value * 40,
          left: 50 + _anim.value * 30,
          child: _Orb(size: 280, color: const Color(0xFF00FFBD), opacity: 0.25)), // Accent
        Positioned(
          bottom: 180 - _anim.value * 50,
          right: 30 - _anim.value * 20,
          child: _Orb(size: 220, color: const Color(0xFF1E8049), opacity: 0.4)),

        // Subtle noise overlay for texture
        Positioned.fill(child: Opacity(
          opacity: 0.04,
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Breezeicons-devices-22-camera-photo.svg/256px-Breezeicons-devices-22-camera-photo.svg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        )),

        // Blur over everything
        Positioned.fill(child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        )),
      ]),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _Orb({required this.size, required this.color, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

// ── Glass text field ───────────────────────────────────────────
class _GlassField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _GlassField({
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.45)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6ED498), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Glass pill tag ─────────────────────────────────────────────
class _GlassPill extends StatelessWidget {
  final String text;
  final bool small;
  const _GlassPill({required this.text, this.small = false});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 14 : 18, vertical: small ? 7 : 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.2),
        ),
        child: Text(text, style: GoogleFonts.outfit(
          fontWeight: FontWeight.w700, fontSize: small ? 12 : 13, color: Colors.white)),
      ),
    ),
  );
}

// ── Feature row for login page ─────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final String icon, title, sub;
  const _FeatureRow({required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E8049).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6ED498).withValues(alpha: 0.3)),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.6), height: 1.4)),
          ])),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1E8049).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF6ED498), size: 16),
          ),
        ]),
      ),
    ),
  );
}