import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/home_screen.dart';
import 'package:flutter_application_1/views/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
import 'package:flutter_application_1/theme/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) =>
              AuthController(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProxyProvider<AuthController, ListingController>(
          create: (context) =>
              ListingController(apiService: context.read<ApiService>()),
          update: (context, auth, controller) {
            controller ??=
                ListingController(apiService: context.read<ApiService>());
            controller.updateSession(userId: auth.userId);
            return controller;
          },
        ),
      ],
      child: const CampusApp(),
    ),
  );
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Centralized brand color scheme
    final ColorScheme lightScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
    );
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Campus Marketplace',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: lightScheme.onPrimary,
        ),
        // Brand page background
        scaffoldBackgroundColor: AppColors.pageBackground,
        cardTheme: CardThemeData(
          elevation: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          // Keep cards crisp on the beige background
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightScheme.surfaceVariant.withOpacity(.55),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: lightScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: lightScheme.onPrimary,
          ),
        ),
        chipTheme: ChipThemeData(
          labelStyle: TextStyle(color: lightScheme.onSurface),
          backgroundColor: lightScheme.surfaceVariant.withOpacity(.8),
          selectedColor: lightScheme.secondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: darkScheme.onPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: darkScheme.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkScheme.surfaceVariant.withOpacity(.45),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: darkScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: darkScheme.onPrimary,
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: darkScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : LoginScreen();
        },
      ),
    );
  }
}
