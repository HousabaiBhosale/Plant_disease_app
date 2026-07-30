import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../pages/home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _verifyLocationPermission();
  }

  void _verifyLocationPermission() {
    final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
    if (!permissionProvider.isGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/permission');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);

    // Safeguard rendering: If permission is revoked or missing, show a loading placeholder
    // and redirect in the post frame callback.
    if (!permissionProvider.isGranted) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E8049)),
          ),
        ),
      );
    }

    // Load the main Dashboard HomePage
    return const HomePage();
  }
}
