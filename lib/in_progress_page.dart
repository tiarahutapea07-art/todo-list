import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task_detail_page.dart';

class InProgressPage extends StatefulWidget {
  final List<Map<String, String>>? inProgressTasks;
  final Function(int)? onTaskCompleted;

  const InProgressPage({
    super.key,
    this.inProgressTasks,
    this.onTaskCompleted,
  });

  @override
  State<InProgressPage> createState() => _InProgressPageState();
}

class _InProgressPageState extends State<InProgressPage> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = widget.inProgressTasks ?? taskProvider.inProgressTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Sedang Berjalan', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'Tidak ada tugas yang sedang berjalan',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white60 : Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
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
                    padding: const EdgeInsets.all(15),
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
                        Checkbox(
                          activeColor: primaryColor,
                          value: false,
                          onChanged: (value) {
                            if (value == true) {
                              if (widget.onTaskCompleted != null) {
                                widget.onTaskCompleted!(index);
                              } else {
                                taskProvider.completeTask(index);
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task["title"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xff222222),
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
                              const SizedBox(height: 3),
                              Text(
                                task["time"]!,
                                style: TextStyle(
                                  color: isDark ? const Color(0xff80cbc4) : Colors.grey,
                                  fontSize: 12,
                                ),
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
