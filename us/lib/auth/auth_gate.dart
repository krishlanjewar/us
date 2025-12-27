// This file acts as a "gate" that checks if user is logged in or not
// If logged in → show HomePage (main app)
// If not logged in → show LoginPage

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import our romantic login page
import 'package:us/profile/uiPages/login_page.dart';
// Import the main home page to show after login
import 'package:us/home/home.dart';

// AuthGate is a StatelessWidget because it just listens to auth changes
// It doesn't need to manage its own state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to authentication state changes
    // Whenever user logs in or out, this rebuilds automatically
    return StreamBuilder(
      // This stream sends updates when auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // builder runs every time the stream sends new data
      builder: (context, snapshot) {
        // --- LOADING STATE ---
        // While waiting for auth state, show a loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // --- CHECK IF USER IS LOGGED IN ---
        // Get the current session from the snapshot
        final session = snapshot.hasData ? snapshot.data!.session : null;

        // If session exists, user is logged in → show HomePage
        if (session != null) {
          return HomePage(); // Show main app home page
        } else {
          // If no session, user is not logged in → show LoginPage
          return const LoginPage();
        }
      },
    );
  }
}
