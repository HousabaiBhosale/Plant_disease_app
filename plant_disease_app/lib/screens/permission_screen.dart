import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/permission_provider.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Set up a listener to automatically redirect if permission is granted
    final provider = Provider.of<PermissionProvider>(context, listen: false);
    provider.addListener(_onPermissionChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final provider = Provider.of<PermissionProvider>(context, listen: false);
    provider.removeListener(_onPermissionChanged);
    super.dispose();
  }

  void _onPermissionChanged() {
    final provider = Provider.of<PermissionProvider>(context, listen: false);
    if (provider.isGranted && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if (state == AppLifecycleState.resumed) {
    final provider =
        Provider.of<PermissionProvider>(context, listen: false);

    await provider.refreshStatus();

    if (!mounted) return;

    if (provider.isGranted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

  Future<void> _handleEnableLocation() async {
  final provider =
      Provider.of<PermissionProvider>(context, listen: false);

  final granted = await provider.requestLocationPermission();

  if (!mounted) return;

  if (granted) {
    Navigator.pushReplacementNamed(context, '/home');
    return;
  }

  if (provider.isPermanentlyDenied) {
    _showSettingsExplanationDialog();
  } else {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Location permission is required to continue.",
        ),
        backgroundColor: Color(0xFFE03C3C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  void _showSettingsExplanationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.location_off_rounded, color: Color(0xFFE03C3C), size: 28),
              const SizedBox(width: 10),
              Text(
                'Permission Required',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: const Color(0xFF0D2418),
                ),
              ),
            ],
          ),
          content: Text(
            'PlantGuard requires location access to function. You have previously denied this permission permanently. Please open Settings and enable it.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF3D5A47),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A9A84),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8049),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Open Settings',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PermissionProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF031A0F),
              Color(0xFF0D3320),
              Color(0xFF155933),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // PlantGuard logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF87).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00FF87), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF87).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌱', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Enable Location',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'PlantGuard uses your location to tag crop scans, monitor disease outbreaks, and improve field tracking.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: const Color(0xFFD4F4E0),
                    height: 1.6,
                  ),
                ),
                
                const Spacer(),
                
                // Enable Location Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleEnableLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: const Color(0xFF031A0F),
                      elevation: 8,
                      shadowColor: const Color(0xFF00FF87).withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF031A0F)),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Enable Location',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
