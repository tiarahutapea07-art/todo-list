import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  final List<Map<String, String>> allTasks;

  const TaskListPage({super.key, required this.allTasks}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      appBar: AppBar(
        backgroundColor: const Color(0xff304b46),
        title: const Text('All Tasks', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: allTasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: allTasks.length,
              itemBuilder: (context, index) {
                final task = allTasks[index];
                return Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task["title"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task["desc"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        task["time"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
