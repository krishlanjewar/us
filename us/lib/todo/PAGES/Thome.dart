import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us/todo/data/database.dart';
import 'package:us/todo/util/dialog_box.dart';
import 'package:us/todo/util/todo_tile.dart';

class Thome extends StatefulWidget {
  const Thome({super.key});

  @override
  State<Thome> createState() => _ThomeState();
}

class _ThomeState extends State<Thome> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDatabase db = ToDoDatabase();

  @override
  void initState() {
    // TODO: implement initState
    if (_myBox.get('TODOLIST') == null) {
      // frist time open app
      db.createInitialData();
    } else {
      // alredy exists
      db.loadData();
    }
    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateData();
  }

  //  save new task
  // TEACHING MOMENT: We added 'DateTime? deadline' as a parameter.
  // This lets us receive the date selected from the DialogBox!
  void saveNewTask(DateTime? deadline) {
    setState(() {
      // We add the new task to our list.
      // Index 0: Task Name (text)
      // Index 1: Task Completed? (false initially)
      // Index 2: Deadline (the new date we just got)
      db.toDoList.add([_controller.text, false, deadline]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateData();
  }

  void cancelTask() {
    Navigator.of(context).pop();
    _controller.clear();
  }

  // god plan
  void randomAction() {
    // Generate a random number (0 or 1)
    Random random = Random();
    int choice = random.nextInt(2); // 0 or 1

    if (choice == 0) {
      // perform save action
      // We pass 'null' because the random action doesn't pick a date.
      saveNewTask(null);
    } else {
      // perform cancel action
      cancelTask();
    }
  }

  // create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onrandom: randomAction,
          // We pass the function itself. internally, DialogBox calls it with the date.
          onSave: saveNewTask,
          onCancel: cancelTask,
        );
      },
    );
  }

  // delet task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'T O  D O',
          style: TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.pinkAccent),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.pinkAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.favorite_rounded, color: Colors.white),
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
          child: ListView.builder(
            itemCount: db.toDoList.length,
            itemBuilder: (context, index) {
              // TEACHING MOMENT: Safety Check!
              // Old tasks might only have 2 items [name, boolean].
              // New tasks have 3 items [name, boolean, deadline].
              // We check the length to avoid a "RangeError" crash.
              DateTime? deadline;
              if (db.toDoList[index].length > 2) {
                deadline = db.toDoList[index][2];
              }

              return ToDoTile(
                taskName: db.toDoList[index][0],
                taskCompleted: db.toDoList[index][1],
                // We pass the extracted deadline to the tile to be displayed
                deadline: deadline,
                onChanged: (value) => checkBoxChanged(value, index),
                deleteFunction: (context) => deleteTask(index),
              );
            },
          ),
        ),
      ),
    );
  }
}
