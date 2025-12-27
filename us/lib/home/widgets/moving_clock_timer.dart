import 'package:flutter/material.dart';
import 'package:us/home/widgets/couple_timer_widget.dart'; // Import the detailed widget

class MovingClockTimer extends StatefulWidget {
  const MovingClockTimer({super.key});

  @override
  State<MovingClockTimer> createState() => _MovingClockTimerState();
}

class _MovingClockTimerState extends State<MovingClockTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Rotates the hands
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDetails() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: const CoupleTimerWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDetails,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Clock Face
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.pinkAccent.shade100, width: 2),
                color: Colors.pink.shade50,
              ),
            ),

            // Second Hand (Animated)
            RotationTransition(
              turns: _controller,
              child: Container(
                height: 60,
                width: 2,
                alignment: Alignment.topCenter,
                child: Container(height: 30, width: 2, color: Colors.redAccent),
              ),
            ),

            // Center Dot
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
            ),

            // Label
            Positioned(
              bottom: 8,
              child: Text(
                "Time Together",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
