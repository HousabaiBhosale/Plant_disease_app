import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/prediction_history_service.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import 'scanner_page.dart';
import 'notification_settings_page.dart';
import 'library_page.dart';
import 'login_page.dart';

// ── Colour tokens ──────────────────────────────────────────────
class AppColors {
  static const g900    = Color(0xFF031A0F); // Deeper dark
  static const g800    = Color(0xFF0D3320);
  static const g600    = Color(0xFF1E8049);
  static const g500    = Color(0xFF00FF87); // Vibrant Neon Green
  static const g400    = Color(0xFF60EFFF); // Vibrant Neon Blue
  static const g300    = Color(0xFF6ED498);
  static const g200    = Color(0xFFA8E8C0);
  static const g50     = Color(0xFFF0FAF5);
  static const bg      = Color(0xFFF8FCFA);
  static const card    = Colors.white;
  static const text    = Color(0xFF0D2418);
  static const textMid  = Color(0xFF3D5A47);
  static const textSoft = Color(0xFF7A9A84);
  static const border   = Color(0xFFE5F2E9);
  static const blue     = Color(0xFF2D84C8);
  static const red      = Color(0xFFE03C3C);
  static const orange   = Color(0xFFF07A28);
  static const amber    = Color(0xFFF5A623);
  static const accent   = Color(0xFF00FFBD);
}

class ScanRecord {
  final String id;
  final String plantName;
  final String diseaseName;
  final double confidence;
  final String severity;
  final DateTime scannedAt;

  ScanRecord({
    required this.id,
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.scannedAt,
  });

  String get emoji {
    final p = plantName.toLowerCase();
    if (p.contains('tomato'))     return '🍅';
    if (p.contains('corn'))       return '🌽';
    if (p.contains('apple'))      return '🍎';
    if (p.contains('grape'))      return '🍇';
    if (p.contains('potato'))     return '🥔';
    if (p.contains('pepper'))     return '🫑';
    if (p.contains('peach'))      return '🍑';
    if (p.contains('cherry'))     return '🍒';
    if (p.contains('strawberry')) return '🍓';
    if (p.contains('orange'))     return '🍊';
    return '🌿';
  }

  String get severityLabel => severity;
  String get imagePath => '';

  String get timeAgo {
    final diff = DateTime.now().difference(scannedAt);
    if (diff.inDays > 0)    return '${diff.inDays}d ago';
    if (diff.inHours > 0)   return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  bool get isHealthy => diseaseName.toLowerCase() == 'healthy';
}

// ── App shell ──────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _idx = 0;
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _fabAnim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const LibraryPage(),
      const _ProfileTab(),
    ];

    return PopScope(
      canPop: _idx == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _idx != 0) setState(() => _idx = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: KeyedSubtree(key: ValueKey(_idx), child: pages[_idx]),
        ),
        floatingActionButton: ScaleTransition(
          scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
          child: _PulseFAB(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const ScannerPage(),
                transitionsBuilder: (_, a, b, child) => SlideTransition(
                  position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            ).then((_) => setState(() {})),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _BottomBar(idx: _idx, onTap: (i) {
          setState(() {
            _idx = i;
            _fabAnim.forward(from: 0.6);
          });
        }),
      ),
    );
  }
}

// ── Pulsing FAB ────────────────────────────────────────────────
class _PulseFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _PulseFAB({required this.onTap});
  @override
  State<_PulseFAB> createState() => _PulseFABState();
}

class _PulseFABState extends State<_PulseFAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.g500, AppColors.g700],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.g600.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6)),
              BoxShadow(color: AppColors.g300.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 0)),
            ],
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ── Bottom navigation bar ──────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int idx;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.idx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.g900.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _NavItem(icon: Icons.home_rounded,      label: 'Home',     idx: 0, cur: idx, onTap: onTap),
                _NavItem(icon: Icons.menu_book_rounded,  label: 'History',  idx: 1, cur: idx, onTap: onTap),
                const SizedBox(width: 62),
                _NavItem(icon: Icons.person_rounded,     label: 'Profile',  idx: 2, cur: idx, onTap: onTap),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final int idx, cur;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.idx, required this.cur, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = idx == cur;
    return GestureDetector(
      onTap: () => onTap(idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.g50 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedScale(
            scale: active ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, size: 22, color: active ? AppColors.g600 : AppColors.textSoft),
          ),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.outfit(
            fontSize: 10, fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? AppColors.g600 : AppColors.textSoft)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// HOME TAB
// ════════════════════════════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<ScanRecord> _scans = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadScans(); }

  Future<void> _loadScans() async {
    try {
      final raw = await PredictionHistoryService.getHistory(limit: 5);
      final List<ScanRecord> scans = raw.map((r) => ScanRecord(
        id: r['id'],
        plantName: r['plant_name']?.isEmpty == false ? r['plant_name'] : 'Unknown',
        diseaseName: r['predicted_disease'].split('___').last.replaceAll('_', ' '),
        confidence: r['confidence'] * 100,
        severity: r['confidence'] > 0.85 ? 'High' : 'Medium',
        scannedAt: DateTime.parse(r['created_at']).toLocal(),
      )).toList();
      if (mounted) setState(() { _scans = scans; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadScans,
      color: AppColors.g600,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _HeroHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _QuickActions(onScan: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ScannerPage())
              ).then((_) => _loadScans())),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Recent Scans',
                action: 'See all',
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ScanHistoryPage())),
              ),
              const SizedBox(height: 10),
              if (_loading)
                const _LoadingCards()
              else if (_scans.isEmpty)
                _EmptyScans()
              else
                ..._scans.map((s) => _ScanCard(record: s, onTap: () {})),
              const SizedBox(height: 22),
              _SectionHeader(title: 'Crop Tips', action: null, onAction: null),
              const SizedBox(height: 10),
              const _CropTipsCarousel(),
              const SizedBox(height: 32),
            ])),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header ────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF041209)),
      child: Stack(children: [
        // ── Mesh Gradient (Animated Orbs) ─────────────────────
        Positioned(top: -100, right: -60, child: _Orb(size: 320, color: const Color(0xFF1E8049), opacity: 0.4)),
        Positioned(top: 40,  right: 120, child: _Orb(size: 180, color: const Color(0xFF0D3320), opacity: 0.5)),
        Positioned(bottom: -40, left: -40, child: _Orb(size: 240, color: AppColors.accent, opacity: 0.15)),
        
        // Subtle Blur for Mesh Effect
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container(color: Colors.transparent))),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top bar
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: const Center(child: Text('🌿', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PlantGuard', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: -0.5)),
                  Text('PRO AI SCANNERS', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.g500, letterSpacing: 1.2)),
                ]),
              ]),
              _GlassBtn(icon: Icons.notifications_none_rounded, onTap: () {}),
            ]),

            const SizedBox(height: 28),

            // Greeting Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8, height: 8, 
                  decoration: const BoxDecoration(color: AppColors.g500, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.g500, blurRadius: 8)]),
                ),
                const SizedBox(width: 8),
                Text('Real-time Monitoring Active', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9))),
              ]),
            ),
            const SizedBox(height: 14),

            RichText(text: TextSpan(
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.white, height: 1.1, letterSpacing: -0.8),
              children: [
                const TextSpan(text: 'Healthy Growth.\n'),
                TextSpan(text: 'Smart Results.', style: TextStyle(color: AppColors.g500.withValues(alpha: 0.85))),
              ],
            )),

            const SizedBox(height: 24),

            // Scan CTA card (Glassmorphic)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerPage())),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.g500, AppColors.accent]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.g500.withValues(alpha: 0.4), blurRadius: 12)],
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF041209), size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Instant Diagnosis', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                        Text('Ready to scan 38 diseases', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 24),
                    ]),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(children: [
              _StatPill(value: '38+',     label: 'DISEASES', icon: '🦠'),
              const SizedBox(width: 10),
              _StatPill(value: 'Offline', label: 'TFLITE AI', icon: '🚀'),
              const SizedBox(width: 10),
              _StatPill(value: '99%',     label: 'UPTIME',   icon: '🌐'),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size, opacity; final Color color;
  const _Orb({required this.size, required this.color, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: opacity)),
  );
}

class _DecorCircle extends StatelessWidget {
  final double size, opacity;
  const _DecorCircle({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: opacity), width: 1.5),
    ),
  );
}

class _GlassBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

class _StatPill extends StatelessWidget {
  final String value, label, icon;
  const _StatPill({required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 3),
      Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.65))),
    ]),
  ));
}

// ── Quick Actions ──────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final VoidCallback onScan;
  const _QuickActions({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _QAction(emoji: '📷', label: 'Scan Leaf',    sub: 'AI diagnosis', color: AppColors.g600, onTap: onScan),
      const SizedBox(width: 10),
      _QAction(emoji: '📚', label: 'Disease Info', sub: '38 diseases',  color: AppColors.blue,
        onTap: () {}),
    ]);
  }
}

class _QAction extends StatelessWidget {
  final String emoji, label, sub; final Color color; final VoidCallback onTap;
  const _QAction({required this.emoji, required this.label, required this.sub, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.text), textAlign: TextAlign.center),
        Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSoft), textAlign: TextAlign.center),
      ]),
    ),
  ));
}

// ── Section header ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title; final String? action; final VoidCallback? onAction;
  const _SectionHeader({required this.title, required this.action, required this.onAction});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.g600, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
      ]),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(20)),
            child: Text(action!, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.g600)),
          ),
        ),
    ],
  );
}

// ── Loading skeleton cards ─────────────────────────────────────
class _LoadingCards extends StatelessWidget {
  const _LoadingCards();
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(3, (i) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(color: AppColors.g300, strokeWidth: 2)),
    )),
  );
}

// ── Empty state ────────────────────────────────────────────────
class _EmptyScans extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text('🌱', style: TextStyle(fontSize: 36))),
      ),
      const SizedBox(height: 14),
      Text('No scans yet', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
      const SizedBox(height: 4),
      Text('Tap the camera button below\nto scan your first leaf!',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSoft, height: 1.5)),
    ]),
  );
}


// ── Scan card ──────────────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onTap;
  const _ScanCard({required this.record, required this.onTap});

  Color get _accentColor {
    if (record.isHealthy) return AppColors.g600;
    switch (record.severityLabel) {
      case 'High': return AppColors.red;
      case 'Medium': return AppColors.orange;
      default: return AppColors.g600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          // Left accent bar
          Container(
            width: 4, height: 72,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
            ),
          ),
          const SizedBox(width: 12),
          // Emoji / image
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(record.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(record.plantName, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(record.diseaseName, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMid)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSoft),
                const SizedBox(width: 3),
                Text(record.timeAgo, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSoft)),
                const SizedBox(width: 8),
                Text('${record.confidence.toStringAsFixed(0)}% match',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
              ]),
            ]),
          )),
          // Severity badge
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _SeverityBadge(label: record.severityLabel),
          ),
        ]),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String label;
  const _SeverityBadge({required this.label});

  Color get _bg {
    switch (label) {
      case 'High':    return const Color(0xFFFEE2E2);
      case 'Medium':  return const Color(0xFFFEF3C7);
      case 'Healthy': return const Color(0xFFD1FAE5);
      default:        return const Color(0xFFD1FAE5);
    }
  }
  Color get _fg {
    switch (label) {
      case 'High':    return const Color(0xFFB91C1C);
      case 'Medium':  return const Color(0xFF92400E);
      case 'Healthy': return const Color(0xFF065F46);
      default:        return const Color(0xFF065F46);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 10, color: _fg)),
  );
}

// ── Crop Tips Carousel ─────────────────────────────────────────
class _CropTipsCarousel extends StatelessWidget {
  const _CropTipsCarousel();

  static const _tips = [
    ('💧', 'Water Early', 'Water crops before 8 AM to prevent fungal growth during the day.'),
    ('☀️', 'Scan in Light', 'Scan leaves in natural sunlight for most accurate AI results.'),
    ('✂️', 'Prune Infected', 'Remove infected leaves immediately to stop disease spreading.'),
    ('🔄', 'Rotate Fungicides', 'Alternate between fungicide types to prevent resistance.'),
    ('📏', 'Correct Distance', 'Hold phone 20-30 cm from leaf for best camera focus.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (emoji, title, body) = _tips[i];
          return Container(
            width: 180,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text))),
              ]),
              const SizedBox(height: 6),
              Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSoft, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            ]),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PROFILE TAB
// ════════════════════════════════════════════════════════════════
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _profile = ProfileService();
  Map<String, dynamic> _data = {};
  int  _totalScans = 0;
  int  _cropsSaved = 0;
  bool _loading    = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data  = await _profile.loadProfile();
    final total = await PredictionHistoryService.getHistoryCount();
    if (mounted) setState(() { _data = data; _totalScans = total; _cropsSaved = total; _loading = false; });
  }

  void _openEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _EditProfilePage(data: _data))).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.g600, strokeWidth: 2));

    final name     = _data['name']     as String? ?? 'Farmer';
    final role     = _data['role']     as String? ?? 'Farmer';
    final location = _data['location'] as String? ?? 'India';
    final years    = _data['years']    as int?    ?? 0;
    final crops    = _data['crops']    as List<dynamic>? ?? [];

    return SingleChildScrollView(child: Column(children: [

      // ── Profile Hero ──────────────────────────────────────
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.g900, AppColors.g700, AppColors.g500],
          ),
        ),
        child: Stack(children: [
          Positioned(top: -30, right: -20, child: _DecorCircle(size: 140, opacity: 0.08)),
          Positioned(bottom: 10, left: -30, child: _DecorCircle(size: 100, opacity: 0.06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
            child: Column(children: [
              // Avatar
              Stack(alignment: Alignment.bottomRight, children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.g400, AppColors.g600]),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16)],
                  ),
                  child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 42))),
                ),
                GestureDetector(
                  onTap: _openEdit,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)]),
                    child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.g700),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('🌾 $role${years > 0 ? " · $years yrs exp" : ""}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                ),
              ]),
              const SizedBox(height: 4),
              Text('📍 $location', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.65))),
              const SizedBox(height: 20),

              // Stats
              Row(children: [
                _PStat(value: '$_totalScans', label: 'Scans Done',   emoji: '📷'),
                _PStatDivider(),
                _PStat(value: '$_cropsSaved', label: 'Crops Helped', emoji: '🌿'),
                _PStatDivider(),
                _PStat(value: crops.length.toString(), label: 'Crops Grown', emoji: '🌾'),
              ]),
              const SizedBox(height: 18),

              // Edit button
              GestureDetector(
                onTap: _openEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.edit_rounded, size: 15, color: AppColors.g600),
                    const SizedBox(width: 6),
                    Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.g700)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),

      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // My Crops
          if (crops.isNotEmpty) ...[
            const SizedBox(height: 4),
            _SectionHeader(title: 'My Crops', action: null, onAction: null),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: crops.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.g50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.g200),
              ),
              child: Text(c.toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.g700)),
            )).toList()),
            const SizedBox(height: 20),
          ],

          _MenuGroup(items: [
            _MenuTile(iconBg: AppColors.g100, icon: Icons.history_rounded, label: 'Scan History',
              sub: '$_totalScans scans saved', iconColor: AppColors.g600,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ScanHistoryPage()))),
            _MenuTile(iconBg: const Color(0xFFFEF3C7), icon: Icons.notifications_active_rounded,
              label: 'Notifications', sub: 'Disease & weather alerts', iconColor: AppColors.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage()))),
            _MenuTile(iconBg: const Color(0xFFDBEAFE), icon: Icons.language_rounded,
              label: 'Language', sub: 'English · हिंदी · ಕನ್ನಡ', iconColor: AppColors.blue, onTap: () {}),
            _MenuTile(iconBg: const Color(0xFFEDE9FE), icon: Icons.location_on_rounded,
              label: 'Location', sub: location, iconColor: const Color(0xFF7C3AED), onTap: _openEdit),
          ]),

          const SizedBox(height: 12),
          _MenuGroup(items: [
            _MenuTile(iconBg: AppColors.g100, icon: Icons.offline_bolt_rounded,
              label: 'Offline Mode', sub: 'AI runs on-device · no internet', iconColor: AppColors.g600, onTap: () {}),
            _MenuTile(iconBg: const Color(0xFFFEF3C7), icon: Icons.star_rounded,
              label: 'Rate PlantGuard', sub: 'Help farmers everywhere', iconColor: AppColors.amber, onTap: () {}),
            _MenuTile(iconBg: const Color(0xFFFEE2E2), icon: Icons.lock_rounded,
              label: 'Privacy & Data', sub: 'Photos never leave your phone', iconColor: AppColors.red, onTap: () {}),
            _MenuTile(iconBg: const Color(0xFFF3E8FF), icon: Icons.info_rounded,
              label: 'About PlantGuard', sub: 'v1.0.0 · DeepCognix AI Labs', iconColor: const Color(0xFF7C3AED), onTap: () {}),
          ]),

          const SizedBox(height: 16),

          // Logout
          GestureDetector(
            onTap: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
              }
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout_rounded, color: Color(0xFFB91C1C), size: 18),
                const SizedBox(width: 8),
                Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFFB91C1C))),
              ]),
            ),
          ),

          const SizedBox(height: 20),
          Center(child: Text('PlantGuard v1.0 · Made with ❤️ in Bengaluru',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSoft))),
          const SizedBox(height: 24),
        ]),
      ),
    ]));
  }
}

class _PStat extends StatelessWidget {
  final String value, label, emoji;
  const _PStat({required this.value, required this.label, required this.emoji});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 4),
    Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.65))),
  ]));
}

class _PStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 40,
    color: Colors.white.withValues(alpha: 0.2),
  );
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuTile> items;
  const _MenuGroup({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Column(children: items.asMap().entries.map((e) => Column(children: [
      e.value,
      if (e.key < items.length - 1) const Divider(height: 1, indent: 60, endIndent: 16, color: AppColors.border),
    ])).toList()),
  );
}

class _MenuTile extends StatelessWidget {
  final Color iconBg, iconColor; final IconData icon;
  final String label, sub; final VoidCallback onTap;
  const _MenuTile({required this.iconBg, required this.icon, required this.label,
    required this.sub, required this.onTap, required this.iconColor});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text)),
          Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSoft)),
        ])),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft, size: 18),
        ),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
// SCAN HISTORY PAGE
// ════════════════════════════════════════════════════════════════
class _ScanHistoryPage extends StatefulWidget {
  const _ScanHistoryPage();
  @override
  State<_ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<_ScanHistoryPage> {
  List<ScanRecord> _scans = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final raw = await PredictionHistoryService.getHistory(limit: 50);
      final List<ScanRecord> scans = raw.map((r) => ScanRecord(
        id: r['id'],
        plantName: r['plant_name']?.isEmpty == false ? r['plant_name'] : 'Unknown',
        diseaseName: r['predicted_disease'].split('___').last.replaceAll('_', ' '),
        confidence: r['confidence'] * 100,
        severity: r['confidence'] > 0.85 ? 'High' : 'Medium',
        scannedAt: DateTime.parse(r['created_at']).toLocal(),
      )).toList();
      if (mounted) setState(() { _scans = scans; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    await PredictionHistoryService.deletePrediction(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.g800,
        elevation: 0,
        title: Text('Scan History', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: () { setState(() => _loading = true); _load(); }),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.g600, strokeWidth: 2))
        : _scans.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('📷', style: TextStyle(fontSize: 40)))),
              const SizedBox(height: 16),
              Text('No scans yet', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.text)),
              Text('Scan a leaf to build your history.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSoft)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _scans.length,
              itemBuilder: (_, i) {
                final s = _scans[i];
                return Dismissible(
                  key: Key('scan_${s.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(18)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                      Text('Delete', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white)),
                    ]),
                  ),
                  onDismissed: (_) => _delete(s.id),
                  child: _ScanCard(record: s, onTap: () {}),
                );
              },
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// EDIT PROFILE PAGE
// ════════════════════════════════════════════════════════════════
class _EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> data;
  const _EditProfilePage({required this.data});
  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  final _svc = ProfileService();
  late TextEditingController _name, _location;
  late int    _years;
  late String _role;
  late List<String> _crops;
  bool _saving = false;

  final _allCrops = ['Tomato','Grape','Corn','Apple','Potato','Pepper','Peach','Cherry','Strawberry','Orange','Wheat','Rice'];
  final _roles    = ['Farmer','Expert','Student','Researcher'];

  @override
  void initState() {
    super.initState();
    _name     = TextEditingController(text: widget.data['name']     as String? ?? '');
    _location = TextEditingController(text: widget.data['location'] as String? ?? '');
    _years    = widget.data['years'] as int?    ?? 0;
    _role     = widget.data['role']  as String? ?? 'Farmer';
    _crops    = List<String>.from(widget.data['crops'] as List<dynamic>? ?? []);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _svc.saveProfile(name: _name.text, role: _role, location: _location.text, years: _years, crops: _crops);
    if (mounted) { setState(() => _saving = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.g800,
        elevation: 0,
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Your Name'),
          _textField(_name, 'e.g. Ravi Sharma', Icons.person_rounded),
          const SizedBox(height: 18),

          _label('Role'),
          Wrap(spacing: 8, runSpacing: 8, children: _roles.map((r) => GestureDetector(
            onTap: () => setState(() => _role = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: _role == r ? AppColors.g600 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _role == r ? AppColors.g600 : AppColors.border, width: 1.5),
                boxShadow: _role == r ? [BoxShadow(color: AppColors.g600.withValues(alpha: 0.3), blurRadius: 8)] : [],
              ),
              child: Text(r, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13,
                color: _role == r ? Colors.white : AppColors.textMid)),
            ),
          )).toList()),
          const SizedBox(height: 18),

          _label('Location'),
          _textField(_location, 'e.g. Bengaluru, Karnataka', Icons.location_on_rounded),
          const SizedBox(height: 18),

          _label('Experience: $_years years'),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.g600,
              inactiveTrackColor: AppColors.g100,
              thumbColor: AppColors.g600,
              overlayColor: AppColors.g600.withValues(alpha: 0.15),
            ),
            child: Slider(value: _years.toDouble(), min: 0, max: 40, divisions: 40,
              onChanged: (v) => setState(() => _years = v.round())),
          ),
          const SizedBox(height: 18),

          _label('My Crops'),
          Wrap(spacing: 8, runSpacing: 8, children: _allCrops.map((c) {
            final on = _crops.contains(c);
            return GestureDetector(
              onTap: () => setState(() => on ? _crops.remove(c) : _crops.add(c)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: on ? AppColors.g50 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: on ? AppColors.g500 : AppColors.border, width: on ? 2 : 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (on) const Icon(Icons.check_circle_rounded, color: AppColors.g600, size: 14),
                  if (on) const SizedBox(width: 5),
                  Text(c, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12,
                    color: on ? AppColors.g700 : AppColors.textMid)),
                ]),
              ),
            );
          }).toList()),

          const SizedBox(height: 32),
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.g500, AppColors.g700]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.g600.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Save Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text)));

  Widget _textField(TextEditingController ctrl, String hint, IconData icon) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.g500),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: ctrl,
        decoration: InputDecoration.collapsed(
          hintText: hint,
          hintStyle: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textSoft)),
        style: GoogleFonts.nunitoSans(fontSize: 14, color: AppColors.text))),
    ]),
  );
}