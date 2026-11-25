import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatelessWidget {
  final List<Map<String, String>>? allTasks;

  const TaskListPage({super.key, this.allTasks});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = allTasks ?? taskProvider.allTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Semua Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'Belum ada tugas tersedia',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white60 : Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isCompleted = task["time"] == 'Selesai';

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailPage(task: task),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.15)
                                : (isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.assignment_outlined,
                            color: isCompleted ? Colors.green : (isDark ? const Color(0xff80cbc4) : const Color(0xff304b46)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task["title"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? Colors.grey
                                      : (isDark ? Colors.white : const Color(0xff222222)),
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task["desc"]!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: isDark ? Colors.white38 : Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    task["time"]!,
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : (isDark ? const Color(0xff80cbc4) : Colors.grey),
                                      fontSize: 12,
                                      fontWeight: isCompleted
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
