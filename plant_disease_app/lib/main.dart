import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();

  // Notifications
  await NotificationService().initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF144D30),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PlantGuardApp());
}

class PlantGuardApp extends StatelessWidget {
  const PlantGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'PlantGuard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E8049),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.nunitoSansTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF4FAF6),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF144D30),
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1E8049))),
      );
    }
    
    if (authProvider.isAuthenticated) {
      return const HomePage();
    }
    
    return LoginPage();
  }
}