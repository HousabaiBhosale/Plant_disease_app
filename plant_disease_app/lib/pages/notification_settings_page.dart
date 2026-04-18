import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'home_page.dart' show AppColors;

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _notifSvc = NotificationService();

  bool _diseaseAlerts   = true;
  bool _weatherAdvisory = true;
  bool _scanReminders   = false;
  bool _dailyMorning    = false;
  bool _loading         = true;

  static const _kDisease  = 'notif_disease';
  static const _kWeather  = 'notif_weather';
  static const _kScan     = 'notif_scan';
  static const _kMorning  = 'notif_morning';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _diseaseAlerts   = p.getBool(_kDisease)  ?? true;
      _weatherAdvisory = p.getBool(_kWeather)  ?? true;
      _scanReminders   = p.getBool(_kScan)     ?? false;
      _dailyMorning    = p.getBool(_kMorning)  ?? false;
      _loading         = false;
    });
  }

  Future<void> _saveAndApply() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDisease,  _diseaseAlerts);
    await p.setBool(_kWeather,  _weatherAdvisory);
    await p.setBool(_kScan,     _scanReminders);
    await p.setBool(_kMorning,  _dailyMorning);

    // Cancel all first
    await _notifSvc.cancelAll();

    // Re-schedule based on preferences
    if (_dailyMorning) await _notifSvc.scheduleDailyAdvisory();
    if (_scanReminders) await _notifSvc.scheduleWeeklyScanReminder();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification settings saved!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white)),
          backgroundColor: AppColors.g600,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    await _notifSvc.showDiseaseRiskAlert(
      title: '⚠️ Test: High Disease Risk Alert',
      body: 'This is a test notification from PlantGuard. '
          'In real use, you\'ll get alerts when weather conditions '
          'are dangerous for your crops!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.g800,
        title: Text('Notifications',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.g600))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.g800, AppColors.g600]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Center(child: Text('🔔', style: TextStyle(fontSize: 24)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Stay Protected', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                    Text('Get alerts before diseases spread to your crops.',
                      style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                  ])),
                ]),
              ),
              const SizedBox(height: 20),

              // Alert types
              Text('Alert Types', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textSoft)),
              const SizedBox(height: 10),

              _NotifToggle(
                icon: '⚠️',
                iconBg: const Color(0xFFFEE2E2),
                title: 'Disease Risk Alerts',
                subtitle: 'Instant alert when humidity + temperature creates high disease risk for your crops',
                value: _diseaseAlerts,
                onChanged: (v) { setState(() => _diseaseAlerts = v); _saveAndApply(); },
              ),
              _NotifToggle(
                icon: '🌧',
                iconBg: const Color(0xFFDBEAFE),
                title: 'Weather Advisory',
                subtitle: 'Alerts for rain, strong wind, extreme heat — when to spray, irrigate or protect crops',
                value: _weatherAdvisory,
                onChanged: (v) { setState(() => _weatherAdvisory = v); _saveAndApply(); },
              ),

              const SizedBox(height: 20),
              Text('Scheduled Reminders', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textSoft)),
              const SizedBox(height: 10),

              _NotifToggle(
                icon: '🌅',
                iconBg: const Color(0xFFFEF3C7),
                title: 'Daily Morning Advisory',
                subtitle: 'Every morning at 8 AM — disease risk summary and farming tips for the day',
                value: _dailyMorning,
                onChanged: (v) { setState(() => _dailyMorning = v); _saveAndApply(); },
              ),
              _NotifToggle(
                icon: '📷',
                iconBg: AppColors.g100,
                title: 'Weekly Scan Reminder',
                subtitle: 'Every Monday at 9 AM — reminder to scan your crops for early disease detection',
                value: _scanReminders,
                onChanged: (v) { setState(() => _scanReminders = v); _saveAndApply(); },
              ),

              const SizedBox(height: 24),

              // Test notification button
              GestureDetector(
                onTap: _testNotification,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.g600, width: 2),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.notifications_active_rounded, color: AppColors.g600, size: 18),
                    const SizedBox(width: 8),
                    Text('Send Test Notification',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.g600)),
                  ]),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Disease alerts fire automatically when high-risk\nweather is detected in your area.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
    );
  }
}

// ── Toggle card widget ─────────────────────────────────────────
class _NotifToggle extends StatelessWidget {
  final String icon, title, subtitle;
  final Color iconBg;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 2))],
        border: value ? Border.all(color: AppColors.g200, width: 1.5) : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
          const SizedBox(height: 3),
          Text(subtitle, style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textSoft, height: 1.5)),
        ])),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.g600,
          activeTrackColor: AppColors.g200,
        ),
      ]),
    );
  }
}
