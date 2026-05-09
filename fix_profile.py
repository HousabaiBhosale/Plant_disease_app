import re

# ── 1. Fix LanguageService: add missing translation keys ──────────────────────
lang_path = r"c:\Users\HP\PlantDiseaseApp\plant_disease_app\lib\services\language_service.dart"
with open(lang_path, 'r', encoding='utf-8') as f:
    lang = f.read()

new_translations = {
    'en': {
        'rate_app': 'Rate PlantGuard',
        'rate_app_sub': 'Help farmers everywhere',
        'privacy_data': 'Privacy & Data',
        'privacy_data_sub': 'Photos never leave your phone',
        'about_app': 'About PlantGuard',
        'about_app_sub': 'v1.0.0 • DeepCognix AI Labs',
        'offline_mode_sub': 'AI runs on-device • no internet',
        'notif_sub': 'Disease & weather alerts',
        'location_label': 'Location',
        'offline_title': 'Offline Mode',
        'offline_desc': 'PlantGuard works fully offline using the on-device TFLite AI model. Your data never leaves your phone.',
        'rate_title': 'Enjoying PlantGuard?',
        'rate_desc': 'Please rate us on the Play Store to help more farmers!',
        'privacy_title': 'Privacy & Data',
        'privacy_desc': 'All scans are processed on-device. Photos are never uploaded without your consent. Scan history is stored only on this device and your account.',
        'about_title': 'About PlantGuard',
        'about_desc': 'PlantGuard v1.0.0 uses AI to detect plant diseases in real time. Built for Indian farmers with 38+ disease classes across 14 crop types.',
        'close': 'Close',
        'go_rate': 'Rate Now',
    },
    'hi': {
        'rate_app': 'PlantGuard को रेट करें',
        'rate_app_sub': 'किसानों की मदद करें',
        'privacy_data': 'गोपनीयता और डेटा',
        'privacy_data_sub': 'फोटो आपके फोन से बाहर नहीं जाते',
        'about_app': 'PlantGuard के बारे में',
        'about_app_sub': 'v1.0.0 • DeepCognix AI Labs',
        'offline_mode_sub': 'ऑन-डिवाइस AI • इंटरनेट की जरूरत नहीं',
        'notif_sub': 'रोग और मौसम अलर्ट',
        'location_label': 'स्थान',
        'offline_title': 'ऑफलाइन मोड',
        'offline_desc': 'PlantGuard पूरी तरह ऑफलाइन काम करता है। आपका डेटा आपके फोन से बाहर नहीं जाता।',
        'rate_title': 'PlantGuard पसंद है?',
        'rate_desc': 'Play Store पर रेटिंग दें और अधिक किसानों की मदद करें!',
        'privacy_title': 'गोपनीयता और डेटा',
        'privacy_desc': 'सभी स्कैन ऑन-डिवाइस प्रोसेस होते हैं। फोटो आपकी अनुमति के बिना अपलोड नहीं होते।',
        'about_title': 'PlantGuard के बारे में',
        'about_desc': 'PlantGuard v1.0.0 AI से पौधों की बीमारी पहचानता है। 14 फसलों में 38+ बीमारियां।',
        'close': 'बंद करें',
        'go_rate': 'रेट करें',
    },
    'mr': {
        'rate_app': 'PlantGuard ला रेटिंग द्या',
        'rate_app_sub': 'शेतकऱ्यांना मदत करा',
        'privacy_data': 'गोपनीयता आणि डेटा',
        'privacy_data_sub': 'फोटो आपल्या फोनबाहेर जात नाहीत',
        'about_app': 'PlantGuard बद्दल',
        'about_app_sub': 'v1.0.0 • DeepCognix AI Labs',
        'offline_mode_sub': 'ऑन-डिव्हाइस AI • इंटरनेट लागत नाही',
        'notif_sub': 'रोग आणि हवामान अलर्ट',
        'location_label': 'स्थान',
        'offline_title': 'ऑफलाइन मोड',
        'offline_desc': 'PlantGuard पूर्णपणे ऑफलाइन काम करतो. आपला डेटा फोनबाहेर जात नाही.',
        'rate_title': 'PlantGuard आवडतो का?',
        'rate_desc': 'Play Store वर रेटिंग द्या!',
        'privacy_title': 'गोपनीयता आणि डेटा',
        'privacy_desc': 'सर्व स्कॅन ऑन-डिव्हाइस प्रोसेस होतात. फोटो कधीही अपलोड होत नाहीत.',
        'about_title': 'PlantGuard बद्दल',
        'about_desc': 'PlantGuard v1.0.0 AI द्वारे पिकांचे रोग ओळखतो. 14 पिकांमध्ये 38+ रोग.',
        'close': 'बंद करा',
        'go_rate': 'रेटिंग द्या',
    },
    'kn': {
        'rate_app': 'PlantGuard ರೇಟ್ ಮಾಡಿ',
        'rate_app_sub': 'ರೈತರಿಗೆ ಸಹಾಯ ಮಾಡಿ',
        'privacy_data': 'ಗೌಪ್ಯತೆ ಮತ್ತು ಡೇಟಾ',
        'privacy_data_sub': 'ಫೋಟೋಗಳು ಫೋನ್ ಬಿಡುವುದಿಲ್ಲ',
        'about_app': 'PlantGuard ಬಗ್ಗೆ',
        'about_app_sub': 'v1.0.0 • DeepCognix AI Labs',
        'offline_mode_sub': 'ಆನ್-ಡಿವೈಸ್ AI • ಇಂಟರ್ನೆಟ್ ಬೇಡ',
        'notif_sub': 'ರೋಗ ಮತ್ತು ಹವಾಮಾನ ಎಚ್ಚರಿಕೆಗಳು',
        'location_label': 'ಸ್ಥಳ',
        'offline_title': 'ಆಫ್‌ಲೈನ್ ಮೋಡ್',
        'offline_desc': 'PlantGuard ಸಂಪೂರ್ಣ ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ. ನಿಮ್ಮ ಡೇಟಾ ಫೋನ್ ಬಿಡುವುದಿಲ್ಲ.',
        'rate_title': 'PlantGuard ಇಷ್ಟವಾಯಿತೇ?',
        'rate_desc': 'Play Store ನಲ್ಲಿ ರೇಟ್ ಮಾಡಿ!',
        'privacy_title': 'ಗೌಪ್ಯತೆ ಮತ್ತು ಡೇಟಾ',
        'privacy_desc': 'ಎಲ್ಲ ಸ್ಕ್ಯಾನ್‌ಗಳು ಡಿವೈಸ್‌ನಲ್ಲೇ ಪ್ರಕ್ರಿಯೆಗೊಳ್ಳುತ್ತವೆ. ಫೋಟೋಗಳು ಅಪ್‌ಲೋಡ್ ಆಗುವುದಿಲ್ಲ.',
        'about_title': 'PlantGuard ಬಗ್ಗೆ',
        'about_desc': 'PlantGuard v1.0.0 AI ಮೂಲಕ ಸಸ್ಯ ರೋಗ ಪತ್ತೆ ಮಾಡುತ್ತದೆ. 14 ಬೆಳೆಗಳಲ್ಲಿ 38+ ರೋಗಗಳು.',
        'close': 'ಮುಚ್ಚಿ',
        'go_rate': 'ರೇಟ್ ಮಾಡಿ',
    },
    'te': {
        'rate_app': 'PlantGuard రేటింగ్ ఇవ్వండి',
        'rate_app_sub': 'రైతులకు సహాయపడండి',
        'privacy_data': 'గోప్యత మరియు డేటా',
        'privacy_data_sub': 'ఫోటోలు ఫోన్ వదలవు',
        'about_app': 'PlantGuard గురించి',
        'about_app_sub': 'v1.0.0 • DeepCognix AI Labs',
        'offline_mode_sub': 'ఆన్-డివైస్ AI • ఇంటర్నెట్ అవసరం లేదు',
        'notif_sub': 'వ్యాధి మరియు వాతావరణ హెచ్చరికలు',
        'location_label': 'ప్రాంతం',
        'offline_title': 'ఆఫ్‌లైన్ మోడ్',
        'offline_desc': 'PlantGuard పూర్తిగా ఆఫ్‌లైన్‌లో పనిచేస్తుంది. మీ డేటా ఫోన్ వదలదు.',
        'rate_title': 'PlantGuard నచ్చిందా?',
        'rate_desc': 'Play Store లో రేటింగ్ ఇవ్వండి!',
        'privacy_title': 'గోప్యత మరియు డేటా',
        'privacy_desc': 'అన్ని స్కాన్‌లు పరికరంలోనే ప్రాసెస్ అవుతాయి. ఫోటోలు అప్‌లోడ్ కావు.',
        'about_title': 'PlantGuard గురించి',
        'about_desc': 'PlantGuard v1.0.0 AI తో మొక్కల వ్యాధులు గుర్తిస్తుంది. 14 పంటల్లో 38+ వ్యాధులు.',
        'close': 'మూసివేయి',
        'go_rate': 'రేటింగ్ ఇవ్వండి',
    },
    'ta': {
        'rate_app': 'PlantGuard மதிப்பிடுங்கள்',
        'rate_app_sub': 'விவசாயிகளுக்கு உதவுங்கள்',
        'privacy_data': 'தனியுரிமை மற்றும் தரவு',
        'privacy_data_sub': 'புகைப்படங்கள் போனை விட்டு வெளியேறாது',
        'about_app': 'PlantGuard பற்றி',
        'about_app_sub': 'v1.0.0 • DeepCognix AI Labs',
        'offline_mode_sub': 'ஆன்-டிவைஸ் AI • இணையம் தேவையில்லை',
        'notif_sub': 'நோய் மற்றும் வானிலை எச்சரிக்கைகள்',
        'location_label': 'இடம்',
        'offline_title': 'ஆஃப்லைன் பயன்முறை',
        'offline_desc': 'PlantGuard முழுவதும் ஆஃப்லைனில் செயல்படுகிறது. உங்கள் தரவு போனை விட்டு வெளியேறாது.',
        'rate_title': 'PlantGuard பிடித்ததா?',
        'rate_desc': 'Play Store இல் மதிப்பிடுங்கள்!',
        'privacy_title': 'தனியுரிமை மற்றும் தரவு',
        'privacy_desc': 'அனைத்து ஸ்கேன்களும் சாதனத்திலேயே செயலாக்கப்படுகின்றன. புகைப்படங்கள் பதிவேற்றப்படாது.',
        'about_title': 'PlantGuard பற்றி',
        'about_desc': 'PlantGuard v1.0.0 AI மூலம் தாவர நோய்களை கண்டறிகிறது. 14 பயிர்களில் 38+ நோய்கள்.',
        'close': 'மூடு',
        'go_rate': 'மதிப்பிடுக',
    },
}

# Insert new keys into each language block
for lang_code, keys in new_translations.items():
    for key, value in keys.items():
        # Find the closing brace of this language block and insert before it
        # Pattern: find the lang block and check if key already exists
        block_pattern = rf"'{lang_code}': \{{([^}}]+)\}}"
        match = re.search(block_pattern, lang, re.DOTALL)
        if match and f"'{key}'" not in match.group(0):
            # Insert before the closing brace of this block
            insert_str = f"      '{key}': '{value}',\n"
            # Find position just before closing } of this language block
            block_end = match.start() + match.group(0).rfind('}')
            lang = lang[:block_end] + insert_str + lang[block_end:]

with open(lang_path, 'w', encoding='utf-8') as f:
    f.write(lang)
print("✅ Language service updated")

# ── 2. Fix home_page.dart ───────────────────────────────────────────────────
home_path = r"c:\Users\HP\PlantDiseaseApp\plant_disease_app\lib\pages\home_page.dart"
with open(home_path, 'r', encoding='utf-8') as f:
    home = f.read()

# Fix 1: Location menu tile - hardcoded 'Location' → lang.t('location_label')
home = home.replace(
    "label: 'Location', sub: location, iconColor: const Color(0xFF7C3AED), onTap: _openEdit",
    "label: lang.t('location_label'), sub: location, iconColor: const Color(0xFF7C3AED), onTap: _openEdit"
)

# Fix 2: Notifications subtitle - hardcoded 'Disease & weather alerts'
home = home.replace(
    "label: lang.t('notifications'), sub: 'Disease & weather alerts'",
    "label: lang.t('notifications'), sub: lang.t('notif_sub')"
)

# Fix 3: Offline mode subtitle - hardcoded 'AI runs on-device • no internet'
home = home.replace(
    "label: lang.t('offline_mode'), sub: 'AI runs on-device • no internet', iconColor: AppColors.g600, onTap: () {}",
    "label: lang.t('offline_mode'), sub: lang.t('offline_mode_sub'), iconColor: AppColors.g600, onTap: () => _showInfoDialog(context, lang.t('offline_title'), lang.t('offline_desc'), Icons.offline_bolt_rounded, AppColors.g600)"
)

# Fix 4: Rate PlantGuard - hardcoded
home = home.replace(
    "label: 'Rate PlantGuard', sub: 'Help farmers everywhere', iconColor: AppColors.amber, onTap: () {}",
    "label: lang.t('rate_app'), sub: lang.t('rate_app_sub'), iconColor: AppColors.amber, onTap: () => _showInfoDialog(context, lang.t('rate_title'), lang.t('rate_desc'), Icons.star_rounded, AppColors.amber)"
)

# Fix 5: Privacy & Data - hardcoded
home = home.replace(
    "label: 'Privacy & Data', sub: 'Photos never leave your phone', iconColor: AppColors.red, onTap: () {}",
    "label: lang.t('privacy_data'), sub: lang.t('privacy_data_sub'), iconColor: AppColors.red, onTap: () => _showInfoDialog(context, lang.t('privacy_title'), lang.t('privacy_desc'), Icons.lock_rounded, AppColors.red)"
)

# Fix 6: About PlantGuard - hardcoded
home = home.replace(
    "label: 'About PlantGuard', sub: 'v1.0.0 • DeepCognix AI Labs', iconColor: const Color(0xFF7C3AED), onTap: () {}",
    "label: lang.t('about_app'), sub: lang.t('about_app_sub'), iconColor: const Color(0xFF7C3AED), onTap: () => _showInfoDialog(context, lang.t('about_title'), lang.t('about_desc'), Icons.info_rounded, const Color(0xFF7C3AED))"
)

# Fix 7: Logout - fix Provider.of<dynamic> → proper AuthProvider call
old_logout = """    onTap: () async {
              final authProvider = Provider.of<dynamic>(context, listen: false);
              await AuthService.logout();
              try { authProvider.logout(); } catch (_) {}
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
              }
            },"""
new_logout = """    onTap: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await AuthService.logout();
              authProvider.logout();
              // AuthWrapper will automatically navigate to LoginPage
            },"""
home = home.replace(old_logout, new_logout)

# Fix 8: Remove footer text
home = home.replace(
    "Center(child: Text('PlantGuard v1.0 • Made with ❤️ in Bengaluru',\n            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSoft))),\n          const SizedBox(height: 24),",
    "const SizedBox(height: 8),"
)

# Fix 9: Remove hardcoded 'Log Out' → use lang.t('log_out')
home = home.replace(
    "Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFFB91C1C)))",
    "Text(lang.t('log_out'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFFB91C1C)))"
)

with open(home_path, 'w', encoding='utf-8') as f:
    f.write(home)
print("✅ home_page.dart updated")

# ── 3. Add _showInfoDialog method to _ProfileTabState ───────────────────────
# Insert helper method before the build() method
with open(home_path, 'r', encoding='utf-8') as f:
    home = f.read()

info_dialog_method = '''
  void _showInfoDialog(BuildContext context, String title, String desc, IconData icon, Color color) {
    final lang = Provider.of<LanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.text), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSoft, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(lang.t('close'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ]),
      ),
    );
  }

'''

# Find the location of `@override\n  Widget build(BuildContext context) {` in _ProfileTabState
# and insert the helper before it
target = "  @override\n  Widget build(BuildContext context) {\n    if (_loading)"
if info_dialog_method.strip() not in home:
    home = home.replace(target, info_dialog_method + target, 1)

with open(home_path, 'w', encoding='utf-8') as f:
    f.write(home)
print("✅ _showInfoDialog added")
print("\nAll fixes done!")
