// This file creates a beautiful, romantic profile page
// It shows user information and allows them to logout

import 'package:flutter/material.dart';
import 'package:us/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ProfilePage is a StatefulWidget because we might update profile information
// and we need to show loading states during logout
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // --- ANIMATION CONTROLLER ---
  // This creates smooth entrance animations when page loads
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // --- AUTH SERVICE ---
  // This connects to Supabase to get user info and handle logout
  final _authService = AuthService();

  // --- STATE VARIABLES ---
  // This shows loading spinner during logout
  bool _isLoggingOut = false;
  String? _partnerName; // Stores the partner's name

  @override
  void initState() {
    super.initState();
    _loadPartnerName(); // Load saved name

    // initState runs once when the page is first created

    // Set up animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Fade in animation (from invisible to visible)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide up animation (cards slide up from bottom)
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.3), // Start 30% down
          end: Offset.zero, // End at normal position
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Start the animations
    _animationController.forward();
  }

  Future<void> _loadPartnerName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _partnerName = prefs.getString('partner_name');
      });
    }
  }

  Future<void> _updatePartnerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partner_name', name);
    if (mounted) {
      setState(() {
        _partnerName = name;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the animation controller when page is closed
    _animationController.dispose();
    super.dispose();
  }

  // --- LOGOUT FUNCTION ---
  // This signs the user out and returns them to the login page
  Future<void> _handleLogout() async {
    // Show confirmation dialog before logging out
    // This prevents accidental logouts
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // Make the dialog match our romantic theme
        backgroundColor: Colors.pink[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.pink[400]),
            const SizedBox(width: 12),
            const Text('Logout?'),
          ],
        ),

        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),

        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),

          // Confirm logout button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // If user clicked "Logout" button
    if (shouldLogout == true && mounted) {
      setState(() {
        _isLoggingOut = true; // Show loading spinner
      });

      try {
        // Call the auth service to sign out
        await _authService.signOut();

        // AuthGate will automatically detect the auth state change
        // and navigate back to the login page
      } catch (e) {
        // If logout fails, show error message
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });

          // Show error in a snackbar (popup message at bottom of screen)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's email from auth service
    final userEmail = _authService.getCurrentUserEmail() ?? 'No email';

    return Scaffold(
      // Create a gradient background matching the login page
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE5EC), // Soft pink
              Color(0xFFFFC2D1), // Medium pink
              Color(0xFFE5B8F4), // Lavender purple
              Color(0xFFD4A5F8), // Light purple
            ],
          ),
        ),

        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // --- ROMANTIC HEADER ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // --- PROFILE AVATAR WITH HEARTS ---
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow circle
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.pink.withOpacity(0.3),
                                      Colors.purple.withOpacity(0.3),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),

                              // Main avatar circle
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  size: 60,
                                  color: Colors.pink[400],
                                ),
                              ),

                              // Small hearts floating around avatar
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Icon(
                                  Icons.favorite,
                                  size: 24,
                                  color: Colors.pink[300],
                                ),
                              ),

                              Positioned(
                                bottom: 15,
                                left: 15,
                                child: Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: Colors.purple[300],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --- WELCOME TEXT ---
                          Text(
                            'Welcome ♥',
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

                          const SizedBox(height: 8),

                          // --- USER EMAIL ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- PROFILE INFO CARDS ---
                    // These cards can show different information about the user
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Partner Name Card
                          _buildInfoCard(
                            icon: Icons.favorite_rounded,
                            title: 'My Partner',
                            subtitle: _partnerName ?? 'Tap to add name',
                            onTap: () {
                              _showPartnerNameDialog();
                            },
                          ),

                          const SizedBox(height: 16),

                          // Account Info Card
                          _buildInfoCard(
                            icon: Icons.account_circle,
                            title: 'Account',
                            subtitle: 'Manage your account settings',
                            onTap: () {
                              // TODO: Navigate to account settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Account settings coming soon! ♥',
                                  ),
                                  backgroundColor: Colors.pink[400],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Preferences Card
                          _buildInfoCard(
                            icon: Icons.settings,
                            title: 'Preferences',
                            subtitle: 'Customize your experience',
                            onTap: () {
                              // TODO: Navigate to preferences
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Preferences coming soon! ♥',
                                  ),
                                  backgroundColor: Colors.pink[400],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // About Card
                          _buildInfoCard(
                            icon: Icons.info_outline,
                            title: 'About',
                            subtitle: 'Version 1.0.0 - Made with ♥',
                            onTap: () {
                              // Show about dialog
                              _showAboutDialog();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- LOGOUT BUTTON ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoggingOut ? null : _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.red.withOpacity(0.5),
                          ),

                          // Show loading spinner or logout text
                          child: _isLoggingOut
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.logout),
                                    SizedBox(width: 12),
                                    Text(
                                      'Logout',
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

  // --- SHOW PARTNER NAME DIALOG ---
  void _showPartnerNameDialog() {
    final TextEditingController _nameController = TextEditingController(
      text: _partnerName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.pink[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink[400]),
            const SizedBox(width: 12),
            const Text('Partner\'s Name'),
          ],
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter name...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.pinkAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                _updatePartnerName(_nameController.text);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- HELPER FUNCTION TO BUILD INFO CARDS ---
  // This creates consistent, beautiful cards for different profile sections
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),

      // InkWell makes the card clickable with a ripple effect
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon on the left
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.pink[400], size: 28),
              ),

              const SizedBox(width: 16),

              // Text in the middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon on the right
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SHOW ABOUT DIALOG ---
  // This shows information about the app
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.pink[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink[400]),
            const SizedBox(width: 12),
            const Text('About US'),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A romantic todo app made with love ♥',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with Flutter & Supabase',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),

        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
