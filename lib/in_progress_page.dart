import 'package:flutter/material.dart';

class InProgressPage extends StatefulWidget {
  final List<Map<String, String>> inProgressTasks;
  final Function(int) onTaskCompleted;

  const InProgressPage({
    super.key,
    required this.inProgressTasks,
    required this.onTaskCompleted,
  });

  @override
  State<InProgressPage> createState() => _InProgressPageState();
}

class _InProgressPageState extends State<InProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      appBar: AppBar(
        backgroundColor: const Color(0xff304b46),
        title: const Text('In Progress', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: widget.inProgressTasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks in progress',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.inProgressTasks.length,
              itemBuilder: (context, index) {
                final task = widget.inProgressTasks[index];
                return Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {
                          if (value == true) {
                            widget.onTaskCompleted(index);
                          }
                        },
                      ),
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
