import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier {
  List<Map<String, String>> _inProgressTasks = [
    {
      "title": "Tugas Algoritma",
      "desc": "Buat proyek untuk C++",
      "time": "Deadline 10:00 - 11:00",
    },
    {
      "title": "Tugas Basis Data",
      "desc": "Kerjakan laporan ERD",
      "time": "Deadline 13:00 - 14:00",
    },
  ];

  List<Map<String, String>> _completedTasks = [];

  // GETTER
  List<Map<String, String>> get inProgressTasks => _inProgressTasks;
  List<Map<String, String>> get completedTasks => _completedTasks;
  List<Map<String, String>> get allTasks => [
    ..._inProgressTasks,
    ..._completedTasks,
  ];

  // TAMBAH TASK
  void addTask(Map<String, String> task) {
    _inProgressTasks.add(task);
    notifyListeners(); // update semua UI otomatis
  }

  // HAPUS TASK
  void removeTask(int index) {
    _inProgressTasks.removeAt(index);
    notifyListeners();
  }

  // PINDAH KE COMPLETED
  void completeTask(int index) {
    _completedTasks.add(_inProgressTasks[index]);
    _inProgressTasks.removeAt(index);
    notifyListeners();
  }
}
