import 'package:flutter/material.dart';
import 'package:us/home/widgets/couple_profile_avatar.dart';

import 'package:us/home/widgets/moving_clock_timer.dart';
import 'package:us/home/widgets/romantic_music_player.dart';
import 'package:us/home/widgets/partner_location_map.dart';
import 'package:us/home/widgets/notes_shortcut.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows gradient to go behind AppBar
      appBar: AppBar(
        title: const Text(
          'U S',
          style: TextStyle(
            fontFamily: 'Serif', // Use a serif font for elegance
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            color: Colors.pinkAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Glass effect
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 50,
                      color: Colors.pinkAccent.shade200,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Love & Planner',
                      style: TextStyle(
                        fontFamily: 'Cursive',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black12,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home_rounded,
                title: 'H O M E',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.check_circle_outline_rounded,
                title: 'T O  D O',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/TODO');
                },
              ),
              _buildDrawerItem(
                icon: Icons.person_rounded,
                title: 'P R O F I L E',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _buildDrawerItem(
                icon: Icons.edit_note_rounded,
                title: 'N O T E S',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/notes');
                },
              ),
              const Divider(color: Colors.pinkAccent, thickness: 0.5),
              _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'L O G I N',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 30), // Spacing for AppBar
                // Row 1: Photo (Left) | Clock (Right)
                Row(
                  children: [
                    // Col 1: Square Photo
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1, // Square
                        child: CoupleProfileAvatar(
                          size: 150,
                        ), // Size is flexible
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Col 2: Moving Clock Timer
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1, // Square
                        child: MovingClockTimer(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 2: Song Player (Full Width)
                RomanticMusicPlayer(),

                const SizedBox(height: 16),

                // Row 3: Location (Left) | Notes (Right)
                Row(
                  children: [
                    // Col 1: Live Location
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PartnerLocationMap(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Col 2: Notes
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: NotesShortcut(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.pink.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      hoverColor: Colors.pink.shade50,
    );
  }
}
