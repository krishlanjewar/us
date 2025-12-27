import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoupleTimerWidget extends StatefulWidget {
  final DateTime? initialStartDate;
  const CoupleTimerWidget({super.key, this.initialStartDate});

  @override
  State<CoupleTimerWidget> createState() => _CoupleTimerWidgetState();
}

class _CoupleTimerWidgetState extends State<CoupleTimerWidget> {
  DateTime? startDate;
  Duration timeTogether = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    loadStartDate();
  }

  // Load saved date from SharedPreferences
  Future<void> loadStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('startDate');
    if (dateStr != null) {
      setState(() {
        startDate = DateTime.parse(dateStr);
      });
      startLiveTimer();
    }
  }

  // Save start date to SharedPreferences
  Future<void> saveStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('startDate', date.toIso8601String());
  }

  // Start live updating timer
  void startLiveTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (startDate != null) {
        setState(() {
          timeTogether = DateTime.now().difference(startDate!);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Pick date & time
  void pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selectedDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      startDate = selectedDate;
    });
    await saveStartDate(selectedDate);
    startLiveTimer();
  }

  String formatDuration(Duration d) {
    int days = d.inDays;
    int hours = d.inHours % 24;
    int minutes = d.inMinutes % 60;
    int seconds = d.inSeconds % 60;
    return "$days days : $hours hrs : $minutes min : $seconds sec";
  }

  // Anniversary message
  String getAnniversaryMessage() {
    if (timeTogether == Duration.zero) return "";
    final years = timeTogether.inDays ~/ 365;
    if (years >= 1) {
      return "🎉 Happy $years Year${years > 1 ? 's' : ''} Anniversary! 💖";
    }
    final days = timeTogether.inDays;
    if (days >= 100 && days % 100 == 0) {
      return "💞 $days days together! Keep shining!";
    }
    return "Love keeps growing every second 💕";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85), // Glassmorphism base
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.redAccent, size: 28),
              const SizedBox(width: 8),
              const Text(
                "Time Together",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.favorite, color: Colors.redAccent, size: 28),
            ],
          ),
          const SizedBox(height: 20),

          // Pick date button
          if (startDate == null)
            ElevatedButton.icon(
              onPressed: pickStartDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 20),
              label: const Text("Select Start Date"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
                shadowColor: Colors.pinkAccent.withOpacity(0.5),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Since: ${DateFormat('dd MMM yyyy').format(startDate!)}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.pink.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              formatDuration(timeTogether),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.5,
                fontFamily: 'Monospace', // Monospace for numbers alignment
              ),
            ),
            const SizedBox(height: 20),

            AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: Text(
                getAnniversaryMessage(),
                key: ValueKey(getAnniversaryMessage()),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent.shade200,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cursive',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
