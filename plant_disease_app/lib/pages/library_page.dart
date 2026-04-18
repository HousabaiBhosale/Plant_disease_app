import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/disease_data.dart';
import 'home_page.dart' show AppColors;

// ════════════════════════════════════════════════════════════════
// LIBRARY PAGE — searchable disease encyclopaedia
// ════════════════════════════════════════════════════════════════
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _selectedPlant = 'All';
  List<DiseaseInfo> _results = DiseaseDatabase.all;
  bool _showSearch = false;

  void _onSearch(String q) {
    setState(() {
      _results = DiseaseDatabase.search(q)
          .where((d) => _selectedPlant == 'All' || d.plantName == _selectedPlant)
          .toList();
    });
  }

  void _onFilter(String plant) {
    setState(() {
      _selectedPlant = plant;
      _results = DiseaseDatabase.search(_searchCtrl.text)
          .where((d) => plant == 'All' || d.plantName == plant)
          .toList();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [

        // ── Header ────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.g900, AppColors.g700, AppColors.g500],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(children: [
            // Decorative
            Positioned(top: -20, right: -10, child: _DecorCircle(size: 120, opacity: 0.08)),
            Positioned(bottom: 0, left: 40,  child: _DecorCircle(size: 60,  opacity: 0.06)),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Disease Library', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 26, color: Colors.white)),
                    Row(children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                        child: Text('${DiseaseDatabase.all.length} diseases · ${DiseaseDatabase.plants.length - 1} crops',
                          style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                      ),
                    ]),
                  ])),
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = !_showSearch),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _showSearch ? Colors.white : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Icon(
                        _showSearch ? Icons.close_rounded : Icons.search_rounded,
                        color: _showSearch ? AppColors.g700 : Colors.white, size: 20),
                    ),
                  ),
                ]),

                // Search bar (animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(children: [
                        const Icon(Icons.search_rounded, color: AppColors.textSoft, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearch,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search disease, crop, symptom…',
                            hintStyle: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textSoft),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14)),
                          style: GoogleFonts.nunitoSans(fontSize: 14, color: AppColors.text),
                        )),
                        if (_searchCtrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () { _searchCtrl.clear(); _onSearch(''); },
                            child: const Icon(Icons.close_rounded, color: AppColors.textSoft, size: 18)),
                      ]),
                    ),
                  ),
                  crossFadeState: _showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),
              ]),
            ),
          ]),
        ),

        // ── Filter chips ──────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: DiseaseDatabase.plants.map((plant) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onFilter(plant),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedPlant == plant ? AppColors.g600 : AppColors.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedPlant == plant ? AppColors.g600 : AppColors.border, width: 1.5),
                      boxShadow: _selectedPlant == plant
                        ? [BoxShadow(color: AppColors.g600.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                        : [],
                    ),
                    child: Text(plant, style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 12,
                      color: _selectedPlant == plant ? Colors.white : AppColors.textMid)),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),

        // ── Results count bar ─────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(20)),
                child: Text('${_results.length} results',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.g600)),
              ),
            ]),
            Text('Swipe to browse', style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft)),
          ]),
        ),

        const Divider(height: 1, color: AppColors.border),

        // ── Disease list ──────────────────────────────────────
        Expanded(
          child: _results.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Text('🔍', style: TextStyle(fontSize: 40)))),
                const SizedBox(height: 16),
                Text('No results found', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.text)),
                Text('Try a different search term', style: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textSoft)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                itemCount: _results.length,
                itemBuilder: (_, i) => _DiseaseListCard(
                  disease: _results[i],
                  onTap: () => Navigator.push(context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, b) => DiseaseDetailPage(disease: _results[i]),
                      transitionsBuilder: (_, a, b, child) => FadeTransition(
                        opacity: a, child: SlideTransition(
                          position: Tween(begin: const Offset(0.05, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
                          child: child)),
                    )),
                ),
              ),
        ),
      ]),
    );
  }
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

// ── Disease list card ──────────────────────────────────────────
class _DiseaseListCard extends StatelessWidget {
  final DiseaseInfo disease;
  final VoidCallback onTap;
  const _DiseaseListCard({required this.disease, required this.onTap});

  Color get _riskBg {
    switch (disease.riskLevel) {
      case 'High':   return const Color(0xFFFEE2E2);
      case 'Medium': return const Color(0xFFFEF3C7);
      default:       return const Color(0xFFD1FAE5);
    }
  }
  Color get _riskFg {
    switch (disease.riskLevel) {
      case 'High':   return const Color(0xFFB91C1C);
      case 'Medium': return const Color(0xFF92400E);
      default:       return const Color(0xFF065F46);
    }
  }
  Color get _typeFg {
    switch (disease.type) {
      case 'Fungal':    return const Color(0xFF5B21B6);
      case 'Bacterial': return const Color(0xFF0369A1);
      case 'Viral':     return const Color(0xFFB91C1C);
      case 'Oomycete':  return const Color(0xFF92400E);
      case 'Pest':      return const Color(0xFF065F46);
      default:          return AppColors.g700;
    }
  }
  Color get _typeBg {
    switch (disease.type) {
      case 'Fungal':    return const Color(0xFFEDE9FE);
      case 'Bacterial': return const Color(0xFFDBEAFE);
      case 'Viral':     return const Color(0xFFFEE2E2);
      case 'Oomycete':  return const Color(0xFFFEF3C7);
      case 'Pest':      return const Color(0xFFD1FAE5);
      default:          return AppColors.g100;
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
          boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          // Colored left strip
          Container(
            width: 4, height: 88,
            decoration: BoxDecoration(
              color: _typeFg.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
            ),
          ),
          const SizedBox(width: 12),

          // Emoji icon
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: disease.iconBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: disease.iconBg.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(child: Text(disease.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(disease.plantName,
                style: GoogleFonts.nunitoSans(fontSize: 10, color: AppColors.textSoft, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(disease.diseaseName,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text)),
              Text(disease.scientificName,
                style: GoogleFonts.nunitoSans(fontSize: 10, color: AppColors.textSoft, fontStyle: FontStyle.italic)),
              const SizedBox(height: 7),
              Wrap(spacing: 6, children: [
                _SmallBadge(label: disease.type, bg: _typeBg, fg: _typeFg),
                if (!disease.isHealthy)
                  _SmallBadge(label: '${disease.riskLevel} Risk', bg: _riskBg, fg: _riskFg),
              ]),
            ]),
          )),

          // Arrow
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 30, height: 30,
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft, size: 20),
          ),
        ]),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label; final Color bg, fg;
  const _SmallBadge({required this.label, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 10, color: fg)),
  );
}

// ════════════════════════════════════════════════════════════════
// DISEASE DETAIL PAGE
// ════════════════════════════════════════════════════════════════
class DiseaseDetailPage extends StatelessWidget {
  final DiseaseInfo disease;
  const DiseaseDetailPage({super.key, required this.disease});

  Color get _typeFg {
    switch (disease.type) {
      case 'Fungal':    return const Color(0xFF5B21B6);
      case 'Bacterial': return const Color(0xFF0369A1);
      case 'Viral':     return const Color(0xFFB91C1C);
      case 'Oomycete':  return const Color(0xFF92400E);
      default:          return AppColors.g700;
    }
  }
  Color get _typeBg {
    switch (disease.type) {
      case 'Fungal':    return const Color(0xFFEDE9FE);
      case 'Bacterial': return const Color(0xFFDBEAFE);
      case 'Viral':     return const Color(0xFFFEE2E2);
      case 'Oomycete':  return const Color(0xFFFEF3C7);
      default:          return AppColors.g100;
    }
  }
  Color get _riskBg => disease.riskLevel == 'High' ? const Color(0xFFFEE2E2) : disease.riskLevel == 'Medium' ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5);
  Color get _riskFg => disease.riskLevel == 'High' ? const Color(0xFFB91C1C) : disease.riskLevel == 'Medium' ? const Color(0xFF92400E) : const Color(0xFF065F46);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [

        // ── Collapsing hero ───────────────────────────────────
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.g800,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: disease.isHealthy
                    ? [AppColors.g900, AppColors.g700, AppColors.g500]
                    : [const Color(0xFF2D1B69), AppColors.g800, AppColors.g600],
                ),
              ),
              child: Stack(children: [
                Positioned(top: -20, right: -20, child: _DecorCircle(size: 130, opacity: 0.08)),
                Positioned(bottom: 20, left: 40, child: _DecorCircle(size: 70, opacity: 0.06)),
                Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Center(child: Text(disease.emoji, style: const TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 10),
                  Text(disease.plantName,
                    style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  Text(disease.diseaseName,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                ])),
              ]),
            ),
          ),
        ),

        // ── Content ───────────────────────────────────────────
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Badges
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Badge(label: disease.type, bg: _typeBg, fg: _typeFg),
              _Badge(label: disease.scientificName, bg: AppColors.g50, fg: AppColors.g700, italic: true),
              if (!disease.isHealthy)
                _Badge(label: '${disease.riskLevel} Risk', bg: _riskBg, fg: _riskFg),
            ]),
            const SizedBox(height: 16),

            // Overview
            _Section(icon: '📋', title: 'Overview', child:
              Text(disease.description, style: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textMid, height: 1.7))),

            if (disease.symptoms.isNotEmpty)
              _Section(icon: '🔍', title: 'Symptoms', child:
                _BulletList(items: disease.symptoms, color: const Color(0xFFFEE2E2), dotColor: const Color(0xFFB91C1C))),

            if (disease.causes.isNotEmpty)
              _Section(icon: '⚡', title: 'Causes', child:
                _BulletList(items: disease.causes, color: const Color(0xFFFEF3C7), dotColor: const Color(0xFFD97706))),

            if (disease.treatments.isNotEmpty)
              _Section(icon: '💊', title: 'Treatment', child:
                _BulletList(items: disease.treatments, color: AppColors.g100, dotColor: AppColors.g600)),

            if (disease.preventions.isNotEmpty)
              _Section(icon: '🛡️', title: 'Prevention', child:
                _BulletList(items: disease.preventions, color: const Color(0xFFDBEAFE), dotColor: const Color(0xFF1D4ED8))),

            if (!disease.isHealthy)
              _Section(icon: '📊', title: 'Crop Impact', child:
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(disease.cropImpact, style: GoogleFonts.nunitoSans(
                      fontSize: 13, color: const Color(0xFF991B1B), height: 1.5, fontWeight: FontWeight.w600))),
                  ]),
                )),

            _Section(icon: '🌾', title: 'Affected Crops', child:
              Wrap(spacing: 8, runSpacing: 8, children: disease.affectedCrops.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.g50, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.g200, width: 1.5)),
                child: Text(c, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.g700)),
              )).toList())),

            // Scan tip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.g800, AppColors.g600]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.g700.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('📷', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Best Scan Tip', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(disease.bestScanTip, style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85), height: 1.5)),
                ])),
              ]),
            ),

            const SizedBox(height: 28),
          ]),
        )),
      ]),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label; final Color bg, fg; final bool italic;
  const _Badge({required this.label, required this.bg, required this.fg, this.italic = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.nunito(
      fontWeight: FontWeight.w700, fontSize: 12, color: fg,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
  );
}

class _Section extends StatelessWidget {
  final String icon, title; final Widget child;
  const _Section({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 17))),
        ),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.text)),
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _BulletList extends StatelessWidget {
  final List<String> items; final Color color, dotColor;
  const _BulletList({required this.items, required this.color, required this.dotColor});
  @override
  Widget build(BuildContext context) => Column(
    children: items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 20, height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, size: 12, color: dotColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(item, style: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textMid, height: 1.55))),
      ]),
    )).toList(),
  );
}