import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final query = _searchController.text.trim().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final headerBg = isDark ? const Color(0xff1c2824) : const Color(0xff304b46);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;

    final results = taskProvider.allTasks.where((task) {
      final title = (task['title'] ?? '').toLowerCase();
      final desc = (task['desc'] ?? '').toLowerCase();
      final isCompleted = task['time'] == 'Selesai';

      final matchesSearch =
          query.isNotEmpty && (title.contains(query) || desc.contains(query));
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Berjalan' && !isCompleted) ||
          (_selectedFilter == 'Selesai' && isCompleted);

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temukan tugasmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Cari berdasarkan nama atau deskripsi tugas.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Cari tugas kamu...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.grey),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xff292929) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori tugas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 9,
                    children: ['Semua', 'Berjalan', 'Selesai'].map((filter) {
                      final selected = _selectedFilter == filter;

                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: primaryColor,
                        backgroundColor: cardColor,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : (isDark ? Colors.white70 : const Color(0xff304b46)),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Hasil pencarian',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${results.length} tugas',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 65,
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            query.isEmpty
                                ? 'Belum ada tugas dicari'
                                : 'Tugas tidak ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Coba gunakan kata kunci lainnya.',
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final task = results[index];
                        final isCompleted = task['time'] == 'Selesai';

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
                            margin: const EdgeInsets.only(bottom: 13),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.withOpacity(0.15)
                                        : (isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7)),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    isCompleted ? Icons.check_circle : Icons.task_alt,
                                    color: isCompleted
                                        ? Colors.green
                                        : (isDark ? const Color(0xff80cbc4) : const Color(0xff304b46)),
                                    size: 25,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task['title'] ?? '',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: isCompleted
                                              ? Colors.grey
                                              : (isDark ? Colors.white : Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        task['desc'] ?? '',
                                        style: TextStyle(
                                          color: isDark ? Colors.white60 : Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 13,
                                            color: isDark ? Colors.white38 : Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              task['time'] ?? '',
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
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
            ),
          ],
        ),
      ),
    );
  }
}
