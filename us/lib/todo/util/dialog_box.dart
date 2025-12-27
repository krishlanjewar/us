import 'package:flutter/material.dart';
import 'package:us/todo/util/my_butt.dart';

// We are changing this to a StatefulWidget.
// WHY? Because we need to update the UI *while* the dialog is open (when a date is picked).
// StatelessWidgets can't rebuild themselves with new data, but StatefulWidgets can!
class DialogBox extends StatefulWidget {
  final controller;
  // We need to pass the date back to the parent, so onSave now accepts a DateTime?
  final VoidCallback onrandom;
  final Function(DateTime?) onSave;
  final VoidCallback onCancel;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onrandom,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  // This variable stores the date the user picks.
  // It's nullable (DateTime?) because initially, no date is selected.
  DateTime? _selectedDate;

  // This function opens the date picker.
  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // The earliest date allowed
      lastDate: DateTime(2030), // The latest date allowed
    ).then((value) {
      // This runs after the user closes the date picker.
      // 'value' is the date they picked (or null if they cancelled).
      if (value != null) {
        // setState tells Flutter: "Hey, data changed! Re-run the build method to update the screen."
        setState(() {
          _selectedDate = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.pink[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        height: 180, // Made it taller to fit the date stuff!
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Text filed input
            TextField(
              controller:
                  widget.controller, // Access parent's variable using 'widget.'
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Input Task",
              ),
            ),

            SizedBox(height: 10),

            // TEACHING MOMENT: This Row holds our Date display and Button
            Row(
              children: [
                // Expanded makes the text take up all available space to the left
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Date Selected' // Show this if variable is null
                        : 'Due: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}', // Show formatted date
                  ),
                ),
                // The button to trigger the picker
                IconButton(
                  onPressed: _showDatePicker,
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),

            SizedBox(height: 10),
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // random button
                // We use 'widget.onrandom' because onrandom is in the widget class, not state class
                IconButton(
                  onPressed: widget.onrandom,
                  icon: Icon(Icons.ramen_dining),
                ),
                SizedBox(width: 10),
                // save button
                // When saved, we now pass BOTH the text (handled by controller) AND the _selectedDate
                MyButton(
                  text: 'Save',
                  onPressed: () => widget.onSave(_selectedDate),
                ),
                SizedBox(width: 10),
                // cancel button
                MyButton(text: 'Cancel', onPressed: widget.onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
