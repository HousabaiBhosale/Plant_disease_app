import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import 'home_page.dart';

class LocationPermissionPage extends StatefulWidget {
  final bool isFromDashboard;
  const LocationPermissionPage({super.key, this.isFromDashboard = false});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _loadingText = '📍 Getting your location...';
  String _subLoadingText = 'Finding your farm...';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleEnableLocation() async {
    setState(() {
      _isLoading = true;
      _loadingText = '📍 Getting your location...';
      _subLoadingText = 'Requesting OS GPS permission...';
    });

    // Screen 2: Native Android Popup via Geolocator
    final granted = await LocationService.requestPermission();

    if (granted) {
      setState(() {
        _loadingText = '📍 Getting your location...';
        _subLoadingText = 'Finding your farm...';
      });

      // Fetch coordinates and geocode to city/state
      await LocationService.getCurrentLocationData();

      // Screen 3: Show loading animation for 1-2 seconds
      await Future.delayed(const Duration(milliseconds: 1500));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_onboarding_done', true);

      if (mounted) {
        if (widget.isFromDashboard) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied. You can enable it anytime in dashboard settings.'),
            backgroundColor: Color(0xFFE03C3C),
          ),
        );
      }
    }
  }

  Future<void> _handleNotNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_onboarding_done', true);

    if (mounted) {
      if (widget.isFromDashboard) {
        Navigator.of(context).pop(false);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF031A0F), // AppColors.g900
              Color(0xFF0D3320), // AppColors.g800
              Color(0xFF155933), // AppColors.g700
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: _isLoading ? _buildLoadingScreen() : _buildWelcomeScreen(),
          ),
        ),
      ),
    );
  }

  // Screen 1: Welcome to PlantSense AI
  Widget _buildWelcomeScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Animated/Glowing Icon Badge
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00FF87), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 48)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'PlantSense AI',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF00FF87), // AppColors.g500
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enable Your Location',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Get accurate disease detection and\nweather-based recommendations by\nallowing location access.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: const Color(0xFFD4F4E0), // AppColors.g100
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        // Benefits Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FF87).withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              _buildChecklistItem('GPS Field Tagging'),
              const SizedBox(height: 14),
              _buildChecklistItem('Local Weather Analysis'),
              const SizedBox(height: 14),
              _buildChecklistItem('Region-based Disease Prediction'),
              const SizedBox(height: 14),
              _buildChecklistItem('Farm Visit Tracking'),
            ],
          ),
        ),
        const Spacer(),
        // Buttons
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleEnableLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF87),
              foregroundColor: const Color(0xFF031A0F),
              elevation: 8,
              shadowColor: const Color(0xFF00FF87).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
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
        const SizedBox(height: 16),
        TextButton(
          onPressed: _handleNotNow,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Not Now',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFA8E8C0),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF00FF87),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Color(0xFF031A0F), size: 14),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Screen 3: After Permission Granted (Loading State)
  Widget _buildLoadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00FF87), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.my_location_rounded, color: Color(0xFF00FF87), size: 54),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _loadingText,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _subLoadingText,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: const Color(0xFF6ED498), // AppColors.g300
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              backgroundColor: Color(0xFF0D3320),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}
