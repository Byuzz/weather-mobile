import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/screens/splash_screen.dart';
import 'package:weathertech/providers/auth_provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const WeatherTechApp());
}

class WeatherTechApp extends StatelessWidget {
  const WeatherTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
      ],
      child: MaterialApp(
        title: 'WeatherTech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1E3A8A),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}