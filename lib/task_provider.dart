import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  // SIMPAN KE LOCAL STORAGE
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('inProgressTasks', jsonEncode(_inProgressTasks));
    prefs.setString('completedTasks', jsonEncode(_completedTasks));
  }

  // BACA DARI LOCAL STORAGE
  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final inProgress = prefs.getString('inProgressTasks');
    final completed = prefs.getString('completedTasks');

    if (inProgress != null) {
      final List decoded = jsonDecode(inProgress);
      _inProgressTasks = decoded
          .map((e) => Map<String, String>.from(e))
          .toList();
    }

    if (completed != null) {
      final List decoded = jsonDecode(completed);
      _completedTasks = decoded
          .map((e) => Map<String, String>.from(e))
          .toList();
    }

    notifyListeners();
  }

  // FETCH DARI API (hanya kalau local storage kosong)
  Future<void> fetchTasksFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('inProgressTasks');

    // kalau sudah ada data lokal, pakai itu saja
    if (existing != null) {
      await loadFromLocal();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
      );

      if (response.statusCode == 200) {
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

        // simpan ke local setelah fetch
        await _saveToLocal();
      }
    } catch (e) {
      print("Error fetch API: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // TAMBAH TASK
  Future<void> addTask(Map<String, String> task) async {
    _inProgressTasks.add(task);
    await _saveToLocal();
    notifyListeners();
  }

  // HAPUS TASK
  Future<void> removeTask(int index) async {
    _inProgressTasks.removeAt(index);
    await _saveToLocal();
    notifyListeners();
  }

  // PINDAH KE COMPLETED
  Future<void> completeTask(int index) async {
    final task = Map<String, String>.from(_inProgressTasks[index]);
    task["desc"] = "Sudah selesai";
    _completedTasks.add(task);
    _inProgressTasks.removeAt(index);
    await _saveToLocal();
    notifyListeners();
  }
}
