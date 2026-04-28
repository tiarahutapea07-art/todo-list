import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskProvider extends ChangeNotifier {
  List<Map<String, String>> _inProgressTasks = [];
  List<Map<String, String>> _completedTasks = [];
  bool isLoading = false;

  // GETTER
  List<Map<String, String>> get inProgressTasks => _inProgressTasks;
  List<Map<String, String>> get completedTasks => _completedTasks;
  List<Map<String, String>> get allTasks => [
    ..._inProgressTasks,
    ..._completedTasks,
  ];

  // FETCH DARI API
  Future<void> fetchTasksFromApi() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _inProgressTasks = [
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
          {
            "title": "Tugas Mobile",
            "desc": "Buat aplikasi Flutter",
            "time": "Deadline 15:00 - 16:00",
          },
          {
            "title": "Tugas Jaringan",
            "desc": "Konfigurasi router",
            "time": "Deadline 17:00 - 18:00",
          },
          {
            "title": "Tugas Kalkulus",
            "desc": "Kerjakan soal integral",
            "time": "Deadline 19:00 - 20:00",
          },
        ];
      }
    } catch (e) {
      print("Error fetch API: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // TAMBAH TASK
  void addTask(Map<String, String> task) {
    _inProgressTasks.add(task);
    notifyListeners();
  }

  // HAPUS TASK
  void removeTask(int index) {
    _inProgressTasks.removeAt(index);
    notifyListeners();
  }

  // PINDAH KE COMPLETED
  void completeTask(int index) {
    final task = Map<String, String>.from(_inProgressTasks[index]);
    task["desc"] = "Sudah selesai";
    _completedTasks.add(task);
    _inProgressTasks.removeAt(index);
    notifyListeners();
  }
}
