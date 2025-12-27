// This is the entry point of our Flutter app
// It sets up Supabase, Hive, and runs the main app widget

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us/profile/uiPages/login_page.dart';
import 'package:us/profile/uiPages/profile_page.dart';
// Import note pages
import 'package:us/notes/pages/notes_list_page.dart';
import 'package:us/notes/pages/create_note_page.dart';
import 'package:us/profile/uiPages/registration_page.dart';
import 'package:us/todo/PAGES/Thome.dart';
import 'package:us/home/home.dart';
import 'package:us/home/widgets/couple_timer_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import AuthGate to handle authentication flow
import 'package:us/auth/auth_gate.dart';

// main() is the first function that runs when app starts
void main() async {
  // ensureInitialized() is required before using any async operations in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // This file contains our Supabase credentials (kept secret)
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with our project credentials
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Hive (local database for storing todos)
  await Hive.initFlutter();

  // Open a Hive box called 'mybox' (like opening a database)
  await Hive.openBox('mybox');

  // Run the app - MyApp is the root widget
  runApp(const MyApp());
}

// MyApp is the root widget of our application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up the overall app structure
    return MaterialApp(
      // Hide the debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // AuthGate is the home page - it decides whether to show login or profile
      // This way, logged-in users go straight to their profile
      // and logged-out users see the login page
      home: const AuthGate(),

      // Set the app's primary color to pink (romantic theme!)
      theme: ThemeData(primarySwatch: Colors.pink),

      // Named routes allow navigation like: Navigator.pushNamed(context, '/TODO')
      routes: {
        '/TODO': (context) => Thome(), // Todo list page
        '/home': (context) => HomePage(), // Home page with couple features
        '/TIMER': (context) => CoupleTimerWidget(), // Timer widget
        '/profile': (context) => const ProfilePage(), // Profile page
        '/register': (context) => const RegistrationPage(), // Registration page
        '/notes': (context) => NotesListPage(), // List of notes
        '/create_note': (context) => const CreateNotePage(), // Create new note
      },
    );
  }
}
