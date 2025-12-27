// This file creates a beautiful, romantic registration (sign up) page
// This is specifically for NEW users to create their accounts
// It's separate from the login page to give registration its own special experience

import 'package:flutter/material.dart';
import 'package:us/auth/auth_service.dart';

// RegistrationPage is a StatefulWidget because we need to:
// - Track form input (email, password, confirm password)
// - Show loading states
// - Display error messages
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  // --- CONTROLLERS ---
  // These controllers help us get what the user types in each field
  final _nameController = TextEditingController(); // For user's name
  final _phoneController = TextEditingController(); // For user's phone
  final _emailController = TextEditingController(); // For email address
  final _passwordController = TextEditingController(); // For password
  final _confirmPasswordController =
      TextEditingController(); // To confirm password matches

  // --- ANIMATION CONTROLLERS ---
  // These make the page look smooth and professional with animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation; // Fade in effect
  late Animation<Offset> _slideAnimation; // Slide up effect

  // --- STATE VARIABLES ---
  // This shows a loading spinner while creating the account
  bool _isLoading = false;

  // This stores error messages if something goes wrong
  String? _errorMessage;

  // This stores success message after successful registration
  String? _successMessage;

  // --- AUTH SERVICE ---
  // This connects to Supabase to create new user accounts
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // initState runs ONCE when the page first appears

    // Create the animation controller
    // 1000 milliseconds = 1 second for the animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this, // Required for smooth animations
    );

    // Fade animation: starts invisible (0.0) and becomes visible (1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation: starts below (0.2 = 20% down) and slides to normal position
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Start the animation!
    _animationController.forward();
  }

  @override
  void dispose() {
    // dispose() is called when the page is closed
    // We MUST clean up to prevent memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- REGISTRATION FUNCTION ---
  // This creates a new user account in Supabase
  Future<void> _handleRegistration() async {
    // Clear previous messages
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true; // Show loading spinner
    });

    // Get what the user typed (trim removes extra spaces)
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // --- VALIDATION CHECKS ---
    // Make sure all fields are filled
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
        _isLoading = false;
      });
      return; // Stop here if name is empty
    }

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your phone number';
        _isLoading = false;
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
        _isLoading = false;
      });
      return;
    }

    // Check if email has @ symbol (basic validation)
    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
        _isLoading = false;
      });
      return;
    }

    // Check password length (should be at least 6 characters)
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
        _isLoading = false;
      });
      return;
    }

    // Make sure passwords match
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    // --- TRY TO CREATE ACCOUNT ---
    try {
      // Call Supabase to create new user
      await _authService.signUpWithCredentials(
        email,
        password,
        phone: phone,
        displayName: name, // Pass name as displayName
      );

      // If successful, show success message
      setState(() {
        _successMessage = 'Account created successfully! ♥';
        _isLoading = false;
      });

      // Wait 2 seconds, then navigate back to login
      await Future.delayed(const Duration(seconds: 2));

      // Go back to previous page (probably login page)
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // If something went wrong, show the error
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Create romantic gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Romantic color palette
              Color(0xFFFFE5EC), // Soft pink
              Color(0xFFFFC2D1), // Medium pink
              Color(0xFFE5B8F4), // Lavender
              Color(0xFFD4A5F8), // Light purple
            ],
          ),
        ),

        // SafeArea prevents content from going under status bar
        child: SafeArea(
          // FadeTransition makes the whole page fade in
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              // SingleChildScrollView allows scrolling if keyboard appears
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // --- BACK BUTTON ---
                    // Let users go back to previous page (login)
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- ROMANTIC HEADER ICON ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glowing circle background
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),

                          // Two hearts icon (representing couple)
                          Icon(
                            Icons.favorite,
                            size: 80,
                            color: Colors.pink[300],
                          ),

                          // Small heart on the side
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Icon(
                              Icons.favorite,
                              size: 30,
                              color: Colors.purple[300],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- TITLE ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Create Account ♥',
                        style: TextStyle(
                          fontSize: 36,
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
                    ),

                    const SizedBox(height: 12),

                    // --- SUBTITLE ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Begin your romantic journey together',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- REGISTRATION FORM CARD ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          // Glass morphism effect (frosted glass)
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
                            // --- NAME FIELD ---
                            _buildTextField(
                              controller: _nameController,
                              hintText: 'Your Name',
                              icon: Icons.person_outline,
                            ),

                            const SizedBox(height: 16),

                            // --- PHONE FIELD ---
                            _buildTextField(
                              controller: _phoneController,
                              hintText: 'Phone Number',
                              icon: Icons.phone_android,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 16),

                            // --- EMAIL FIELD ---
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // --- PASSWORD FIELD ---
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 16),

                            // --- CONFIRM PASSWORD FIELD ---
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
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

                            // --- SUCCESS MESSAGE (if any) ---
                            if (_successMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // --- CREATE ACCOUNT BUTTON ---
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleRegistration,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink[400],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.pink.withOpacity(0.5),
                                ),

                                // Show loading spinner or button text
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.favorite),
                                          SizedBox(width: 12),
                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- ALREADY HAVE ACCOUNT LINK ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Go back to login page
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
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
  // This creates beautiful, consistent input fields
  // We reuse this for all 4 fields (name, email, password, confirm password)
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
        controller: controller, // Link to our controller
        obscureText: isPassword, // Hide text if it's a password field
        keyboardType: keyboardType, // Set keyboard type (email, text, etc)

        style: TextStyle(color: Colors.grey[800], fontSize: 16),

        decoration: InputDecoration(
          hintText: hintText, // Placeholder text
          hintStyle: TextStyle(color: Colors.grey[400]),

          // Icon on the left
          prefixIcon: Icon(icon, color: Colors.pink[300]),

          // Remove default border
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
