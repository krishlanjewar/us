// This file creates a beautiful, romantic login page for our app
// It handles both Sign In (for existing users) and Sign Up (for new users)

import 'package:flutter/material.dart';
import 'package:us/auth/auth_service.dart';

// LoginPage is a StatefulWidget because it needs to change/update based on user actions
// For example: switching between Sign In and Sign Up, showing error messages, etc.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // --- CONTROLLERS ---
  // TextEditingControllers help us get the text that users type into text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // AnimationController controls animations (like fade-in effects, sliding, etc.)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // --- STATE VARIABLES ---
  // Note: This page is now ONLY for Sign In
  // For Sign Up (registration), we have a separate page

  // This shows loading spinner when we're waiting for server response
  bool _isLoading = false;

  // This stores error messages if something goes wrong (like wrong password)
  String? _errorMessage;

  // --- AUTH SERVICE ---
  // This is our connection to Supabase authentication
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // initState runs once when the page is first created

    // Set up the animation controller
    // Duration: how long the animation takes (800 milliseconds = 0.8 seconds)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this, // This is required for animations to work smoothly
    );

    // Create a fade animation that goes from 0.0 (invisible) to 1.0 (fully visible)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // This makes the animation smooth and natural
      ),
    );

    // Start the animation when the page loads
    _animationController.forward();
  }

  @override
  void dispose() {
    // dispose() is called when the page is closed/destroyed
    // We need to clean up to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- AUTHENTICATION FUNCTION ---
  // This function handles Sign In (Login) only
  Future<void> _handleSignIn() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = null;
      _isLoading = true; // Show loading spinner
    });

    // Get the text that user typed
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Debug: Print what we're trying to sign in with
    print('🔐 Attempting to sign in with email: $email');

    // Validate fields are not empty
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
        _isLoading = false;
      });
      return;
    }

    try {
      // Try to sign in the user
      print('📡 Calling signInWithCredentials...');
      await _authService.signInWithCredentials(email, password);

      // If we get here, authentication was successful!
      print('✅ Sign in successful!');
      // The AuthGate will automatically detect the auth state change
      // and navigate to the profile page
    } catch (e) {
      // If something went wrong, show the error message to the user
      print('❌ Sign in error: $e');

      // Make error message more user-friendly
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Special handling for email confirmation error
      if (errorMessage.toLowerCase().contains('email') &&
          (errorMessage.toLowerCase().contains('confirm') ||
              errorMessage.toLowerCase().contains('verified'))) {
        errorMessage =
            '📧 Email not confirmed!\n\nPlease check your email inbox and click the confirmation link to activate your account.';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body fills the entire screen with a gradient background
      body: Container(
        // Create a beautiful gradient background (pink to purple)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Gradient goes from top-left to bottom-right
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // These colors create a romantic, cozy feeling
              Color(0xFFFFE5EC), // Soft pink
              Color(0xFFFFC2D1), // Medium pink
              Color(0xFFE5B8F4), // Lavender purple
              Color(0xFFD4A5F8), // Light purple
            ],
          ),
        ),

        // SafeArea ensures content doesn't go under the status bar or notch
        child: SafeArea(
          child: Center(
            // SingleChildScrollView allows scrolling if keyboard appears
            child: SingleChildScrollView(
              // Add padding around the content
              padding: const EdgeInsets.symmetric(horizontal: 24.0),

              // FadeTransition makes everything fade in smoothly
              child: FadeTransition(
                opacity: _fadeAnimation,

                // Column arranges widgets vertically (top to bottom)
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- ROMANTIC HEADER ICON ---
                    // Stack allows us to layer widgets on top of each other
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle with soft shadow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Heart icon on top
                        Icon(Icons.favorite, size: 70, color: const Color.fromARGB(255, 221, 102, 142)),
                      ],
                    ),

                    const SizedBox(height: 30), // Add space
                    // --- TITLE TEXT ---
                    Text(
                      'Welcome Back ♥',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.pink.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- SUBTITLE TEXT ---
                    Text(
                      'Sign in to continue your journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- LOGIN FORM CARD ---
                    // This creates a glass-morphism effect (frosted glass look)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        // Semi-transparent white background
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // --- EMAIL INPUT FIELD ---
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          // --- PASSWORD INPUT FIELD ---
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            isPassword:
                                true, // This hides the password with dots
                          ),

                          const SizedBox(height: 24),

                          // --- ERROR MESSAGE (if any) ---
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // --- SIGN IN BUTTON ---
                          SizedBox(
                            width: double.infinity, // Button takes full width
                            height: 56,
                            child: ElevatedButton(
                              // When button is pressed, call _handleSignIn function
                              onPressed: _isLoading ? null : _handleSignIn,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink[400],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: Colors.pink.withOpacity(0.5),
                              ),

                              // Show either loading spinner or button text
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Sign In ♥',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- LINK TO REGISTRATION PAGE ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                        ),

                        // TextButton to go to registration page
                        TextButton(
                          onPressed: () {
                            // Navigate to the registration page
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER FUNCTION TO BUILD TEXT FIELDS ---
  // This creates consistent, beautiful input fields
  // We use this function twice (for email and password) to avoid repeating code
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),

      child: TextField(
        controller: controller, // Connect to our controller
        obscureText: isPassword, // Hide text if it's a password
        keyboardType: keyboardType,

        style: TextStyle(color: Colors.grey[800], fontSize: 16),

        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),

          // Icon on the left side of the field
          prefixIcon: Icon(icon, color: Colors.pink[300]),

          // Remove default borders
          border: InputBorder.none,

          // Add padding inside the field
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
