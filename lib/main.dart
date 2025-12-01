import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'constants.dart';
import 'widgets/connectivity_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();

    // Habilitar persistencia offline de Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('Firestore offline persistence enabled');

    // Sign in anonymously so Firestore operations work when rules require auth
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Signed in anonymously to Firebase Auth');
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  } catch (e) {
    // If you generated `firebase_options.dart` with FlutterFire CLI,
    // replace the call above with: `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`
    // This catch ensures the app still runs if options are missing during local dev.
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appTitle,
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Arial'),
      home: const ConnectivityWrapper(child: HomeScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
