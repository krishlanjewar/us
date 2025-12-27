import 'package:flutter/material.dart';

class NotesShortcut extends StatelessWidget {
  const NotesShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/notes');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.yellow.shade100, // Sticky note color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(5), // Fold effect
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 40,
                color: Colors.orange.shade800,
              ),
              const SizedBox(height: 8),
              Text(
                "Notes & Thoughts",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Write it down...",
                style: TextStyle(fontSize: 10, color: Colors.orange.shade800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
