import 'package:hive_flutter/hive_flutter.dart' show Hive;

class ToDoDatabase {
  // list of todo Task
  List toDoList = [];

  // reference the box
  final _myBox = Hive.box('mybox');

  //  frist time open app
  void createInitialData() {
    toDoList = [
      ["Drink Water ", false, null],
      ["Do exercise", false, null],
      ["Practice Mindfullness", false, null],
    ];
  }

  // load data
  void loadData() {
    toDoList = _myBox.get('TODOLIST');
  }

  // update data
  void updateData() {
    _myBox.put('TODOLIST', toDoList);
  }
}
