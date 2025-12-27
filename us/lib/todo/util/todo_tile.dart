import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  // TEACHING MOMENT: We receive the deadline here from the parent list.
  final DateTime? deadline;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    // We add it to the constructor. It's optional (?) because old tasks don't have it.
    required this.deadline,
    required this.onChanged,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // delete button
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.pink.shade100.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // check box
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                activeColor: Colors.pinkAccent,
                checkColor: Colors.white,
                shape: const CircleBorder(),
                side: BorderSide(color: Colors.pinkAccent.shade100, width: 2),
              ),

              // TEACHING MOMENT: Preventing Overflow!
              // Problem: A Row gives its children infinite width. If text is too long, it goes off-screen (Overflow).
              // Solution: 'Expanded' tells the child: "You can ONLY take the space that is left over, no more."
              // This forces the Text inside to wrap to the next line instead of crashing.
              Expanded(
                // Task name AND Deadline
                // We wrap them in a Column so they stack vertically (Name on top, Date below)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: taskCompleted ? Colors.grey : Colors.black87,
                        decoration: taskCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.pinkAccent,
                      ),
                    ),

                    // TEACHING MOMENT: Conditional UI!
                    // We only want to show this Text widget IF deadline is not null.
                    if (deadline != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Due: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pinkAccent.shade200, // Make it subtle
                            fontStyle: FontStyle.italic,
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
    );
  }
}
