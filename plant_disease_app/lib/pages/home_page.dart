import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scanner_page.dart';

// ── Colour tokens ──────────────────────────────────────────────
class AppColors {
  static const g900 = Color(0xFF0D3320);
  static const g800 = Color(0xFF144D30);
  static const g700 = Color(0xFF1A6B40);
  static const g600 = Color(0xFF1E8049);
  static const g500 = Color(0xFF25A05C);
  static const g400 = Color(0xFF3DBF73);
  static const g300 = Color(0xFF6ED498);
  static const g200 = Color(0xFFA8E8C0);
  static const g100 = Color(0xFFD6F5E4);
  static const g50  = Color(0xFFEDFAF3);
  static const bg   = Color(0xFFF4FAF6);
  static const card = Colors.white;
  static const text = Color(0xFF0D2418);
  static const textMid  = Color(0xFF3D5A47);
  static const textSoft = Color(0xFF7A9A84);
  static const border   = Color(0xFFD4EAD8);
  static const blue     = Color(0xFF2D84C8);
  static const amber    = Color(0xFFF5A623);
  static const red      = Color(0xFFE03C3C);
  static const orange   = Color(0xFFF07A28);
}

// ── Main shell with bottom nav ─────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    _LibraryTab(),
    _CommunityTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScannerPage()),
        ),
        backgroundColor: AppColors.g600,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.card,
        elevation: 12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,    label: 'Home',      index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              _NavItem(icon: Icons.menu_book_rounded, label: 'Library',  index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              const SizedBox(width: 48),
              _NavItem(icon: Icons.people_rounded,  label: 'Community', index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              _NavItem(icon: Icons.person_rounded,  label: 'Profile',   index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: active ? AppColors.g600 : AppColors.textSoft),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.g600 : AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ── HOME TAB ───────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero header
          _HomeHero(context: context),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather bar
                _WeatherBar(),
                const SizedBox(height: 20),
                // Recent scans
                _SectionHeader(title: 'Recent Scans', onSeeAll: () {}),
                const SizedBox(height: 10),
                _ScanCard(emoji: '🍇', plant: 'Grape',        disease: 'Black Rot',   time: 'Today, 8:14 AM',  severity: 'High'),
                _ScanCard(emoji: '🍅', plant: 'Tomato',       disease: 'Early Blight', time: 'Yesterday',      severity: 'Medium'),
                _ScanCard(emoji: '🌽', plant: 'Corn (Maize)', disease: 'Healthy',      time: '2 days ago',     severity: 'Healthy'),
                const SizedBox(height: 20),
                // Community preview
                _SectionHeader(title: 'Community Posts', onSeeAll: () {}),
                const SizedBox(height: 10),
                _CommunityPostCard(
                  avatar: '👨🌾',
                  name: 'Arjun Patil',
                  time: '2 hrs ago · Maharashtra',
                  badge: 'Farmer',
                  body: 'My tomato plants show yellow spots on older leaves. Scanned — says early blight. Anyone tried neem oil?',
                  likes: 24,
                  comments: 8,
                ),
                const SizedBox(height: 20),
                // Tips
                _SectionHeader(title: 'Crop Tips', onSeeAll: () {}),
                const SizedBox(height: 10),
                _TipsRow(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final BuildContext context;
  const _HomeHero({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.g800, AppColors.g600, AppColors.g400],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 52, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('🌿', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 8),
                Text('PlantGuard', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white)),
              ]),
              Row(children: [
                _HeroIconBtn(icon: Icons.wb_sunny_rounded, onTap: () {}),
                const SizedBox(width: 8),
                _HeroIconBtn(icon: Icons.notifications_rounded, onTap: () {}),
              ]),
            ],
          ),
          const SizedBox(height: 18),
          Text('Good morning, Farmer 👋', style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white, height: 1.2),
              children: const [
                TextSpan(text: 'Detect diseases.\n'),
                TextSpan(text: 'Protect your crops.', style: TextStyle(color: AppColors.g200)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Scan CTA
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerPage())),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('📷', style: TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Scan a Leaf Now', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text)),
                      Text('Point camera · instant AI diagnosis', style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.g600, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _StatPill(value: '38',      label: 'Diseases'),
              const SizedBox(width: 8),
              _StatPill(value: '14',      label: 'Crops'),
              const SizedBox(width: 8),
              _StatPill(value: 'Offline', label: 'Works'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeroIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white)),
          Text(label, style: GoogleFonts.nunitoSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }
}

class _WeatherBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2D84C8), Color(0xFF1A5FA8)]),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Text('⛅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('28°C', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white)),
              Text('Partly Cloudy', style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              Text('📍 Bengaluru, KA', style: GoogleFonts.nunitoSans(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('💧 68% Humidity', style: GoogleFonts.nunitoSans(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
            Text('💨 12 km/h Wind', style: GoogleFonts.nunitoSans(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
          ]),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('See all', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.g600)),
        ),
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  final String emoji;
  final String plant;
  final String disease;
  final String time;
  final String severity;
  const _ScanCard({required this.emoji, required this.plant, required this.disease, required this.time, required this.severity});

  Color get _badgeBg {
    switch (severity) {
      case 'High':    return const Color(0xFFFEE2E2);
      case 'Medium':  return const Color(0xFFFEF3C7);
      case 'Low':     return const Color(0xFFD1FAE5);
      default:        return AppColors.g100;
    }
  }

  Color get _badgeFg {
    switch (severity) {
      case 'High':    return const Color(0xFFB91C1C);
      case 'Medium':  return const Color(0xFF92400E);
      case 'Low':     return const Color(0xFF065F46);
      default:        return AppColors.g700;
    }
  }

  static const g700 = Color(0xFF1A6B40);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.09), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plant,   style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
              Text(disease, style: GoogleFonts.nunitoSans(fontSize: 12, color: AppColors.textMid)),
              Text(time,    style: GoogleFonts.nunitoSans(fontSize: 10, color: AppColors.textSoft)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: _badgeBg, borderRadius: BorderRadius.circular(20)),
            child: Text(severity, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 10, color: _badgeFg)),
          ),
        ],
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  final String avatar, name, time, badge, body;
  final int likes, comments;
  const _CommunityPostCard({required this.avatar, required this.name, required this.time, required this.badge, required this.body, required this.likes, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.09), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.g200, shape: BoxShape.circle),
              child: Center(child: Text(avatar, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
              Text(time, style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
              child: Text(badge, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.g700)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(body, style: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textMid, height: 1.6)),
          const SizedBox(height: 10),
          Row(children: [
            _PostAction(icon: Icons.favorite, label: '$likes',    color: AppColors.red),
            const SizedBox(width: 16),
            _PostAction(icon: Icons.chat_bubble_outline, label: '$comments', color: AppColors.textSoft),
            const SizedBox(width: 16),
            _PostAction(icon: Icons.share_outlined, label: 'Share', color: AppColors.textSoft),
          ]),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PostAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
    ]);
  }
}

class _TipsRow extends StatelessWidget {
  final _tips = const [
    ('💧', 'Water at the base', 'Wet foliage promotes fungal spread.'),
    ('🌞', 'Scan in morning light', 'Soft natural light improves AI accuracy.'),
    ('✂️', 'Prune infected leaves', 'Remove early to stop 80% spread.'),
    ('🧪', 'Rotate fungicides', 'Alternate to avoid resistance.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = _tips[i];
          return Container(
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.09), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(t.$2, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.text)),
              Text(t.$3, style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft, height: 1.4)),
            ]),
          );
        },
      ),
    );
  }
}

// ── LIBRARY TAB ────────────────────────────────────────────────
class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  static const _diseases = [
    ('🍇', 'Grape Black Rot',       'Fungal · Guignardia bidwellii',           'High',   Color(0xFFFEE2E2)),
    ('🍅', 'Tomato Early Blight',   'Fungal · Alternaria solani',              'Medium', Color(0xFFFEF3C7)),
    ('🍎', 'Apple Scab',            'Fungal · Venturia inaequalis',            'Medium', Color(0xFFDBEAFE)),
    ('🌽', 'Corn Common Rust',      'Fungal · Puccinia sorghi',                'Low',    Color(0xFFD1FAE5)),
    ('🥔', 'Potato Late Blight',    'Oomycete · Phytophthora infestans',       'High',   Color(0xFFEDE9FE)),
    ('🍅', 'Tomato Late Blight',    'Oomycete · Phytophthora infestans',       'High',   Color(0xFFFEE2E2)),
    ('🌽', 'Corn Gray Leaf Spot',   'Fungal · Cercospora zeae-maydis',         'Medium', Color(0xFFFEF3C7)),
    ('🍑', 'Peach Bacterial Spot',  'Bacterial · Xanthomonas arboricola',      'Medium', Color(0xFFDBEAFE)),
    ('🍓', 'Strawberry Leaf Scorch','Fungal · Diplocarpon earlianum',          'Low',    Color(0xFFD1FAE5)),
    ('🍊', 'Citrus Greening',       'Bacterial · Candidatus Liberibacter spp.','High',   Color(0xFFFEE2E2)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.g800, AppColors.g600]),
        ),
        padding: const EdgeInsets.fromLTRB(18, 52, 18, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Disease Library', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 21, color: Colors.white)),
          const SizedBox(height: 4),
          Text('38 diseases · 14 crop types', style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            child: Row(children: [
              const Icon(Icons.search, color: Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text('Search disease or crop…', style: GoogleFonts.nunitoSans(fontSize: 13, color: Colors.white54)),
            ]),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _diseases.length,
          itemBuilder: (context, i) {
            final d = _diseases[i];
            return _DiseaseRow(emoji: d.$1, name: d.$2, sub: d.$3, risk: d.$4, iconBg: d.$5);
          },
        ),
      ),
    ]);
  }
}

class _DiseaseRow extends StatelessWidget {
  final String emoji, name, sub, risk;
  final Color iconBg;
  const _DiseaseRow({required this.emoji, required this.name, required this.sub, required this.risk, required this.iconBg});

  Color get _riskBg {
    switch (risk) {
      case 'High':   return const Color(0xFFFEE2E2);
      case 'Medium': return const Color(0xFFFEF3C7);
      default:       return const Color(0xFFD1FAE5);
    }
  }

  Color get _riskFg {
    switch (risk) {
      case 'High':   return const Color(0xFFB91C1C);
      case 'Medium': return const Color(0xFF92400E);
      default:       return const Color(0xFF065F46);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.09), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
          Text(sub,  style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _riskBg, borderRadius: BorderRadius.circular(10)),
            child: Text('$risk Risk', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 10, color: _riskFg)),
          ),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft, size: 20),
      ]),
    );
  }
}

// ── COMMUNITY TAB ──────────────────────────────────────────────
class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.g800, AppColors.g600]),
        ),
        padding: const EdgeInsets.fromLTRB(18, 52, 18, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Community', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 21, color: Colors.white)),
          Text('Ask · Share · Learn from 2M+ farmers', style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            child: Row(children: [
              const Icon(Icons.search, color: Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text('Search posts, crops, diseases…', style: GoogleFonts.nunitoSans(fontSize: 13, color: Colors.white54)),
            ]),
          ),
        ]),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.g600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.g600.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('✏️  Ask a Question or Share a Tip',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
              ),
            ),
            _CommunityPostCard(avatar: '👨🌾', name: 'Arjun Patil',     time: '2 hrs ago · Maharashtra', badge: 'Farmer', body: 'My tomato plants show yellow spots on older leaves. Looking for organic solutions — anyone tried neem oil?', likes: 24, comments: 8),
            _CommunityPostCard(avatar: '👩🔬', name: 'Dr. Priya Sharma', time: '5 hrs ago · IARI',         badge: 'Expert', body: '⚠️ High humidity forecast in Karnataka. Perfect conditions for late blight. Apply preventive copper fungicide NOW.', likes: 156, comments: 43),
            _CommunityPostCard(avatar: '🧑🌾', name: 'Suresh Kumar',    time: '1 day ago · Punjab',       badge: 'Farmer', body: 'Used PlantGuard to catch common rust early on my 5-acre corn field. Saved ₹40,000 worth of crop this season! 🙏', likes: 89, comments: 17),
          ],
        ),
      ),
    ]);
  }
}

// ── PROFILE TAB ────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        // Profile hero
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.g800, AppColors.g600],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
          width: double.infinity,
          child: Column(children: [
            Container(
              width: 84, height: 84,
              decoration: BoxDecoration(
                color: AppColors.g200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
              ),
              child: const Center(child: Text('👨🌾', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 12),
            Text('Ravi Sharma', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
            Text('🌾 Farmer · 8 yrs experience', style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
            Text('📍 Bengaluru, Karnataka',      style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.65))),
            const SizedBox(height: 18),
            Row(children: [
              _ProfileStat(value: '47',  label: 'Scans Done'),
              const SizedBox(width: 10),
              _ProfileStat(value: '12',  label: 'Crops Saved'),
              const SizedBox(width: 10),
              _ProfileStat(value: '156', label: 'Community Rep'),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Text('✏️  Edit Profile', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Badges
            Text('Achievements', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView(scrollDirection: Axis.horizontal, children: const [
                _BadgeCard(emoji: '🔬', title: 'First Scan',  sub: 'Earned',  earned: true),
                _BadgeCard(emoji: '🌟', title: '10 Scans',    sub: 'Earned',  earned: true),
                _BadgeCard(emoji: '🏆', title: 'Crop Saver',  sub: 'Earned',  earned: true),
                _BadgeCard(emoji: '🌍', title: '100 Scans',   sub: '53/100',  earned: false),
                _BadgeCard(emoji: '💬', title: 'Helper',      sub: '3/10',    earned: false),
              ]),
            ),
            const SizedBox(height: 20),
            // Menu groups
            _MenuGroup(items: [
              _MenuItem(iconBg: AppColors.g100,             icon: Icons.bar_chart_rounded,        label: 'My Scan History',     sub: '47 scans saved'),
              _MenuItem(iconBg: const Color(0xFFFEF3C7),    icon: Icons.notifications_rounded,    label: 'Notifications',       sub: 'Disease alerts, weather', badge: '3'),
              _MenuItem(iconBg: const Color(0xFFDBEAFE),    icon: Icons.language_rounded,         label: 'Language',            sub: 'English · हिंदी · ಕನ್ನಡ'),
              _MenuItem(iconBg: const Color(0xFFEDE9FE),    icon: Icons.location_on_rounded,      label: 'Location & Region',   sub: 'Bengaluru, Karnataka'),
            ]),
            const SizedBox(height: 12),
            _MenuGroup(items: [
              _MenuItem(iconBg: AppColors.g100,             icon: Icons.offline_bolt_rounded,     label: 'Offline Mode',        sub: 'Model downloaded · Works offline'),
              _MenuItem(iconBg: const Color(0xFFFEF3C7),    icon: Icons.star_rounded,             label: 'Rate PlantGuard',     sub: 'Help us improve'),
              _MenuItem(iconBg: const Color(0xFFFEE2E2),    icon: Icons.lock_rounded,             label: 'Privacy & Data',      sub: 'Your data stays on device'),
              _MenuItem(iconBg: const Color(0xFFF3E8FF),    icon: Icons.info_rounded,             label: 'About PlantGuard',    sub: 'v1.0.0 · DeepCognix AI Labs'),
            ]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text('🚪  Log Out', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFFB91C1C))),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text('PlantGuard v1.0 · Made with ❤️ in Bengaluru',
              style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft))),
            const SizedBox(height: 20),
          ]),
        ),
      ]),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
          Text(label, style: GoogleFonts.nunitoSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String emoji, title, sub;
  final bool earned;
  const _BadgeCard({required this.emoji, required this.title, required this.sub, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.4,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.09), blurRadius: 10, offset: const Offset(0, 2))]),
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.text), textAlign: TextAlign.center),
          Text(sub,   style: GoogleFonts.nunitoSans(fontSize: 9, color: earned ? AppColors.g600 : AppColors.textSoft)),
        ]),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.09), blurRadius: 12, offset: const Offset(0, 2))]),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(children: [
            e.value,
            if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
          ]);
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String label, sub;
  final String? badge;
  const _MenuItem({required this.iconBg, required this.icon, required this.label, required this.sub, this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 17, color: AppColors.textMid),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text)),
          Text(sub,   style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft)),
        ])),
        if (badge != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(10)),
            child: Text(badge!, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.white)),
          ),
          const SizedBox(width: 6),
        ],
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft, size: 18),
      ]),
    );
  }
}
