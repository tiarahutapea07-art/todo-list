import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'task_provider.dart';

class TaskDetailPage extends StatefulWidget {
  final Map<String, String> task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Map<String, String> _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = Map<String, String>.from(widget.task);
  }

  bool get _isCompleted => _currentTask['time'] == 'Selesai';

  void _showEditDialog() {
    final titleController = TextEditingController(text: _currentTask['title']);
    final descController = TextEditingController(text: _currentTask['desc']);
    String deadlineStr = _currentTask['time'] ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
            final inputBg = isDark
                ? const Color(0xff2a2a2a)
                : const Color(0xfff2f6f3);
            final titleColor = isDark ? Colors.white : const Color(0xff304b46);

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 25,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Edit Tugas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey,
                        ),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey,
                        ),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() {
                            deadlineStr =
                                'Deadline: ${DateFormat('dd MMMM yyyy').format(picked)}';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: isDark
                                  ? const Color(0xff80cbc4)
                                  : const Color(0xff304b46),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                deadlineStr.isEmpty
                                    ? 'Pilih Deadline'
                                    : deadlineStr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xff4a7c6f)
                              : const Color(0xff304b46),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;

                          final updated = {
                            'title': titleController.text.trim(),
                            'desc': descController.text.trim(),
                            'time': deadlineStr.isEmpty
                                ? 'Deadline: Hari ini'
                                : deadlineStr,
                          };

                          Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          ).updateTask(_currentTask, updated);

                          setState(() {
                            _currentTask = updated;
                          });

                          Navigator.pop(modalCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tugas berhasil diperbarui!'),
                              backgroundColor: isDark
                                  ? const Color(0xff4a7c6f)
                                  : const Color(0xff304b46),
                            ),
                          );
                        },
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
        title: Text(
          'Hapus Tugas',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${_currentTask['title']}"?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).deleteTask(_currentTask);
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tugas telah dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final primaryColor = isDark
        ? const Color(0xff4a7c6f)
        : const Color(0xff304b46);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Tugas',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Tugas',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCompleted
                                ? Colors.green.shade400
                                : Colors.orange.shade400,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCompleted
                                  ? Icons.check_circle
                                  : Icons.timelapse,
                              size: 16,
                              color: _isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isCompleted ? 'Selesai' : 'Sedang Berjalan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isCompleted
                                    ? Colors.green.shade400
                                    : Colors.orange.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Prioritas Tinggi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xff80cbc4)
                                : const Color(0xff304b46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentTask['title'] ?? 'Tanpa Judul',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isCompleted
                          ? Colors.grey
                          : (isDark ? Colors.white : const Color(0xff222222)),
                      decoration: _isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: isDark
                            ? const Color(0xff80cbc4)
                            : const Color(0xff60766f),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentTask['time'] ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xff60766f),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Deskripsi Section
            Text(
              'Deskripsi Tugas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xff304b46),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                (_currentTask['desc'] == null || _currentTask['desc']!.isEmpty)
                    ? 'Tidak ada deskripsi tambahan untuk tugas ini.'
                    : _currentTask['desc']!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Checklist & Informasi Tambahan
            Text(
              'Informasi Proyek',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xff304b46),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.folder_outlined,
                    'Kategori',
                    'Kuliah / Pemrograman Mobile',
                    isDark,
                  ),
                  Divider(
                    height: 20,
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  _infoRow(
                    Icons.flag_outlined,
                    'Status',
                    _isCompleted ? 'Tugas Selesai' : 'Dalam Pengerjaan',
                    isDark,
                  ),
                  Divider(
                    height: 20,
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  _infoRow(
                    Icons.alarm,
                    'Pengingat',
                    'Aktif (1 jam sebelum deadline)',
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Tombol Ubah Status
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted
                      ? Colors.grey.shade700
                      : (isDark
                            ? const Color(0xff4a7c6f)
                            : const Color(0xff304b46)),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  _isCompleted ? Icons.undo : Icons.check_circle_outline,
                ),
                label: Text(
                  _isCompleted
                      ? 'Kembalikan ke Dalam Pengerjaan'
                      : 'Tandai sebagai Selesai',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).toggleTaskStatus(_currentTask);

                  setState(() {
                    if (_isCompleted) {
                      _currentTask['time'] = 'Deadline: Hari ini';
                    } else {
                      _currentTask['time'] = 'Selesai';
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isCompleted
                            ? 'Tugas ditandai selesai!'
                            : 'Tugas dikembalikan ke antrian pengerjaan!',
                      ),
                      backgroundColor: isDark
                          ? const Color(0xff4a7c6f)
                          : const Color(0xff304b46),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xff304b46),
          ),
        ),
      ],
    );
  }
}
