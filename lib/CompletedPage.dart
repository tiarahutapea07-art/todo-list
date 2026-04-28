import 'package:flutter/material.dart';

class CompletedPage extends StatelessWidget {
  final List<Map<String, String>> completedTasks;

  const CompletedPage({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      appBar: AppBar(
        backgroundColor: const Color(0xff304b46),
        title: const Text('Completed', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: completedTasks.isEmpty
          ? const Center(
              child: Text(
                'No completed tasks',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task["title"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
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
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
