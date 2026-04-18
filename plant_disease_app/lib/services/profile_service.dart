import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const _kName     = 'profile_name';
  static const _kRole     = 'profile_role';
  static const _kLocation = 'profile_location';
  static const _kCrops    = 'profile_crops';
  static const _kYears    = 'profile_years';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Getters ─────────────────────────────────────────────────
  Future<String> getName()     async => (await _prefs).getString(_kName)     ?? 'Farmer';
  Future<String> getRole()     async => (await _prefs).getString(_kRole)     ?? 'Farmer';
  Future<String> getLocation() async => (await _prefs).getString(_kLocation) ?? 'India';
  Future<int>    getYears()    async => (await _prefs).getInt(_kYears)        ?? 0;

  Future<List<String>> getCrops() async {
    final p = await _prefs;
    return p.getStringList(_kCrops) ?? ['Tomato', 'Corn'];
  }

  // ── Setters ─────────────────────────────────────────────────
  Future<void> setName(String v)         async => (await _prefs).setString(_kName, v);
  Future<void> setRole(String v)         async => (await _prefs).setString(_kRole, v);
  Future<void> setLocation(String v)     async => (await _prefs).setString(_kLocation, v);
  Future<void> setYears(int v)           async => (await _prefs).setInt(_kYears, v);
  Future<void> setCrops(List<String> v)  async => (await _prefs).setStringList(_kCrops, v);

  // ── Save all at once ─────────────────────────────────────────
  Future<void> saveProfile({
    required String name,
    required String role,
    required String location,
    required int years,
    required List<String> crops,
  }) async {
    final p = await _prefs;
    await p.setString(_kName,     name);
    await p.setString(_kRole,     role);
    await p.setString(_kLocation, location);
    await p.setInt(_kYears,       years);
    await p.setStringList(_kCrops, crops);
  }

  // ── Load all at once ─────────────────────────────────────────
  Future<Map<String, dynamic>> loadProfile() async {
    final p = await _prefs;
    return {
      'name':     p.getString(_kName)          ?? 'Farmer',
      'role':     p.getString(_kRole)          ?? 'Farmer',
      'location': p.getString(_kLocation)      ?? 'India',
      'years':    p.getInt(_kYears)            ?? 0,
      'crops':    p.getStringList(_kCrops)     ?? ['Tomato', 'Corn'],
    };
  }

  Future<bool> hasProfile() async {
    final p = await _prefs;
    return p.containsKey(_kName);
  }
}
