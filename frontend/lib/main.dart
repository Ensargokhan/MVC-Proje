import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/home_screen.dart';
import 'package:flutter_application_1/views/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';

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
    return MaterialApp(
      title: 'Campus 2. El',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : LoginScreen();
        },
      ),
    );
  }
}
