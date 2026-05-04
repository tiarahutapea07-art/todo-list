import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskProvider extends ChangeNotifier {
  List<Map<String, String>> _inProgressTasks = [];
  List<Map<String, String>> _completedTasks = [];
  bool isLoading = false;

  List<Map<String, String>> get inProgressTasks => _inProgressTasks;
  List<Map<String, String>> get completedTasks => _completedTasks;
  List<Map<String, String>> get allTasks => [
    ..._inProgressTasks,
    ..._completedTasks,
  ];

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('inProgressTasks', jsonEncode(_inProgressTasks));
    await prefs.setString('completedTasks', jsonEncode(_completedTasks));
  }

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

  Future<void> fetchTasksFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('inProgressTasks');

    if (existing != null) {
      await loadFromLocal();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final List<String> namaTugas = [
          'Tugas Basis Data',
          'Tugas Algoritma',
          'Tugas Pemrograman Mobile',
          'Tugas Struktur Data',
          'Tugas Jaringan Komputer',
        ];

        final List<String> deskripsiTugas = [
          'Membuat ERD dan relasi tabel',
          'Mengerjakan sorting dan searching',
          'Membuat aplikasi To Do List Flutter',
          'Mengerjakan stack dan queue',
          'Membuat laporan topologi jaringan',
        ];

        final List<String> deadlineTugas = [
          'Deadline: Senin',
          'Deadline: Selasa',
          'Deadline: Rabu',
          'Deadline: Kamis',
          'Deadline: Jumat',
        ];

        _inProgressTasks = data
            .where((item) => item['completed'] == false)
            .toList()
            .asMap()
            .entries
            .map<Map<String, String>>((entry) {
              final index = entry.key;

              return {
                'title': namaTugas[index % namaTugas.length],
                'desc': deskripsiTugas[index % deskripsiTugas.length],
                'time': deadlineTugas[index % deadlineTugas.length],
              };
            })
            .toList();

        _completedTasks = data
            .where((item) => item['completed'] == true)
            .toList()
            .asMap()
            .entries
            .map<Map<String, String>>((entry) {
              final index = entry.key;

              return {
                'title': namaTugas[index % namaTugas.length],
                'desc': deskripsiTugas[index % deskripsiTugas.length],
                'time': 'Selesai',
              };
            })
            .toList();

        await _saveToLocal();
      } else {
        print('Gagal fetch API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error koneksi ke API: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Map<String, String> task) async {
    _inProgressTasks.add(task);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> removeTask(int index) async {
    _inProgressTasks.removeAt(index);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> completeTask(int index) async {
    final task = Map<String, String>.from(_inProgressTasks[index]);
    task['time'] = 'Selesai';

    _completedTasks.add(task);
    _inProgressTasks.removeAt(index);

    await _saveToLocal();
    notifyListeners();
  }
}
