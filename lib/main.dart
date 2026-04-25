import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/firestore_service.dart';
import 'screens/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeFirebase() async {
    if (!kIsWeb && Platform.environment['FLUTTER_TEST'] == 'true') {
      return;
    }
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDRZnVOqtBeQiUrP1PNTqPCl4NBInyQImI',
          appId: '1:619605778933:web:3fd0eac09217ddb86900bc',
          messagingSenderId: '619605778933',
          projectId: 'database-finalproject-e967f',
          storageBucket: 'database-finalproject-e967f.firebasestorage.app',
          authDomain: 'database-finalproject-e967f.firebaseapp.com',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error.toString();
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'App initialization failed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            Provider<FirestoreService>(create: (_) => FirestoreService()),
          ],
          child: MaterialApp(
            title: 'Expense Calculator',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1A56B0),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F6FA),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Color(0xFF1A56B0),
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFEAEAEA), width: 0.8),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF0F2F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A56B0),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF8A9AB0),
                  fontSize: 14,
                ),
                hintStyle: const TextStyle(
                  color: Color(0xFFB0BACC),
                  fontSize: 14,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56B0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF1A56B0),
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF1A56B0),
                unselectedItemColor: Color(0xFFB0BACC),
                selectedLabelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(fontSize: 11),
                elevation: 8,
              ),
            ),
            home: const MainScaffold(),
          ),
        );
      },
    );
  }
}
