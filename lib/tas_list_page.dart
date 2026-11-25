import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'search_page.dart';
import 'task_detail_page.dart';
import 'task_provider.dart';

class TaskListPage extends StatefulWidget {
  final List<Map<String, String>>? allTasks;

  const TaskListPage({super.key, this.allTasks});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _filterMode = 'Semua'; // Semua | Berjalan | Selesai

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        final options = [
          {'key': 'Semua', 'label': 'Semua Tugas', 'icon': Icons.list_alt_rounded},
          {'key': 'Berjalan', 'label': 'Tugas Sedang Berjalan', 'icon': Icons.timelapse_rounded},
          {'key': 'Selesai', 'label': 'Tugas Selesai', 'icon': Icons.check_circle_outline_rounded},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Filter Daftar Tugas',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xff111815),
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final selected = _filterMode == opt['key'];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: Icon(
                      opt['icon'] as IconData,
                      color: selected
                          ? primaryColor
                          : (isDark ? Colors.white60 : Colors.grey.shade700),
                    ),
                    title: Text(
                      opt['label'] as String,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_rounded, color: primaryColor)
                        : null,
                    onTap: () {
                      setState(() => _filterMode = opt['key'] as String);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Visual badge kiri berdasarkan topik tugas ----------
  Widget _buildSubjectBadge(String title, int index, bool isDark) {
    final lower = title.toLowerCase();

    // 1. Algoritma (mint hijau + diagram hierarki)
    if (lower.contains('algoritma')) {
      return _iconContainer(
        colors: isDark
            ? [const Color(0xff234538), const Color(0xff1c382d)]
            : [const Color(0xffcaeedc), const Color(0xffbbe5d0)],
        child: CustomPaint(
          size: const Size(30, 30),
          painter: _HierarchyIconPainter(
            color: isDark ? const Color(0xff80e5b9) : const Color(0xff1b5944),
          ),
        ),
      );
    }

    // 2. Pemrograman Mobile / Desain Antarmuka (biru muda + smartphone </>)
    if (lower.contains('mobile') || lower.contains('antarmuka') || lower.contains('aplikasi')) {
      return _iconContainer(
        colors: isDark
            ? [const Color(0xff22354d), const Color(0xff1b2b3f)]
            : [const Color(0xffa9c2e0), const Color(0xff94b1d5)],
        child: CustomPaint(
          size: const Size(30, 30),
          painter: _MobileCodeIconPainter(
            color: isDark ? const Color(0xff9cc4f5) : const Color(0xff1d3a5c),
          ),
        ),
      );
    }

    // 3. Struktur Data (gradasi ungu-tosca + diagram hierarki)
    if (lower.contains('struktur')) {
      return _iconContainer(
        colors: isDark
            ? [const Color(0xff38334f), const Color(0xff234440)]
            : [const Color(0xff9c92bf), const Color(0xff76b8ad)],
        child: CustomPaint(
          size: const Size(30, 30),
          painter: _HierarchyIconPainter(
            color: isDark ? const Color(0xffcbe8e2) : const Color(0xff1d3545),
            twoLevels: true,
          ),
        ),
      );
    }

    // 4. Basis Data / Database / MySQL (gradasi koral-oranye + silinder database)
    if (lower.contains('basis data') || lower.contains('database') || lower.contains('mysql')) {
      return _iconContainer(
        colors: isDark
            ? [const Color(0xff4f2d25), const Color(0xff422220)]
            : [const Color(0xfff59f79), const Color(0xffea7869)],
        child: CustomPaint(
          size: const Size(30, 30),
          painter: _DatabaseIconPainter(
            color: isDark ? const Color(0xffffb4a2) : const Color(0xff6b2219),
          ),
        ),
      );
    }

    // 5. Jaringan / Tugas lainnya
    final fallbackPalettes = [
      [const Color(0xffcaeedc), const Color(0xffbbe5d0)],
      [const Color(0xffa9c2e0), const Color(0xff94b1d5)],
      [const Color(0xff9c92bf), const Color(0xff76b8ad)],
      [const Color(0xfff59f79), const Color(0xffea7869)],
    ];
    final pair = fallbackPalettes[index % fallbackPalettes.length];

    return _iconContainer(
      colors: isDark ? [const Color(0xff273b37), const Color(0xff1f302c)] : pair,
      child: Icon(
        lower.contains('jaringan') ? Icons.hub_outlined : Icons.assignment_outlined,
        size: 28,
        color: isDark ? const Color(0xff80cbc4) : const Color(0xff1f4d40),
      ),
    );
  }

  Widget _iconContainer({
    required List<Color> colors,
    required Widget child,
  }) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  // ---------- Pill Deadline berwarna sesuai desain ----------
  Widget _buildDeadlinePill(String time, bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xff8fcfb5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 15, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Selesai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    Color pillBg;
    Color fgColor;

    if (time.contains('Selasa')) {
      pillBg = const Color(0xfff7c39f);
      fgColor = const Color(0xff231f1d);
    } else if (time.contains('Rabu')) {
      pillBg = const Color(0xffc7b0cc);
      fgColor = const Color(0xff231f1d);
    } else if (time.contains('Kamis') || time.contains('Jumat')) {
      pillBg = const Color(0xff7396b5);
      fgColor = Colors.white;
    } else if (time.contains('Hari ini') || time.contains('Besok') || time.contains('Senin')) {
      pillBg = const Color(0xffec6d62);
      fgColor = Colors.white;
    } else {
      pillBg = const Color(0xffe3a63c);
      fgColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 15, color: fgColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final baseList = widget.allTasks ??
        (_filterMode == 'Semua'
            ? taskProvider.allTasks
            : (_filterMode == 'Berjalan'
                ? taskProvider.inProgressTasks
                : taskProvider.completedTasks));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffeaf0ec);
    final headerColor = isDark ? const Color(0xff16342d) : const Color(0xff1f4d40);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final topInset = MediaQuery.of(context).padding.top;

    final headerTitle = _filterMode == 'Semua'
        ? 'Semua Tugas'
        : (_filterMode == 'Berjalan' ? 'Tugas Berjalan' : 'Tugas Selesai');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            // ===== Header hijau membulat =====
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, topInset + 18, 22, 26),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      headerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  _headerCircleButton(
                    icon: Icons.search,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _headerCircleButton(
                    icon: Icons.tune_rounded,
                    onTap: _showFilterSheet,
                  ),
                ],
              ),
            ),

            // ===== Daftar Kartu Tugas =====
            Expanded(
              child: baseList.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada tugas tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 115),
                      itemCount: baseList.length,
                      itemBuilder: (context, index) {
                        final task = baseList[index];
                        final title = task['title'] ?? '';
                        final desc = task['desc'] ?? '';
                        final time = task['time'] ?? '';
                        final isCompleted = time == 'Selesai';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailPage(task: task),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildSubjectBadge(title, index, isDark),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18.5,
                                            fontWeight: FontWeight.w800,
                                            color: isCompleted
                                                ? Colors.grey
                                                : (isDark ? Colors.white : const Color(0xff111815)),
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          desc,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : const Color(0xff1d2623),
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildDeadlinePill(time, isCompleted),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 26,
                                    color: isDark ? Colors.white38 : const Color(0xff6b7571),
                                  ),
                                ],
                              ),
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

  Widget _headerCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// =========================================================
// Custom Painters untuk ikon mata kuliah sesuai referensi
// =========================================================

class _HierarchyIconPainter extends CustomPainter {
  final Color color;
  final bool twoLevels;

  const _HierarchyIconPainter({required this.color, this.twoLevels = false});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    if (!twoLevels) {
      // Kotak atas -> garis cabang -> 3 kotak bawah
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.37, h * 0.1, w * 0.26, h * 0.22), const Radius.circular(2)),
        p,
      );
      canvas.drawLine(Offset(w * 0.5, h * 0.32), Offset(w * 0.5, h * 0.52), p);
      canvas.drawLine(Offset(w * 0.16, h * 0.52), Offset(w * 0.84, h * 0.52), p);

      for (final cx in [0.16, 0.5, 0.84]) {
        canvas.drawLine(Offset(w * cx, h * 0.52), Offset(w * cx, h * 0.66), p);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * (cx - 0.11), h * 0.66, w * 0.22, h * 0.22),
            const Radius.circular(2),
          ),
          p,
        );
      }
    } else {
      // Struktur data: 2 tingkat kotak terhubung
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.34, h * 0.08, w * 0.32, h * 0.18), const Radius.circular(2)),
        p,
      );
      canvas.drawLine(Offset(w * 0.5, h * 0.26), Offset(w * 0.5, h * 0.38), p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.34, h * 0.38, w * 0.32, h * 0.18), const Radius.circular(2)),
        p,
      );
      canvas.drawLine(Offset(w * 0.5, h * 0.56), Offset(w * 0.5, h * 0.66), p);
      canvas.drawLine(Offset(w * 0.16, h * 0.66), Offset(w * 0.84, h * 0.66), p);
      for (final cx in [0.16, 0.5, 0.84]) {
        canvas.drawLine(Offset(w * cx, h * 0.66), Offset(w * cx, h * 0.74), p);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * (cx - 0.11), h * 0.74, w * 0.22, h * 0.18),
            const Radius.circular(2),
          ),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HierarchyIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MobileCodeIconPainter extends CustomPainter {
  final Color color;
  const _MobileCodeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Bingkai smartphone
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.06, w * 0.6, h * 0.88), const Radius.circular(4)),
      p,
    );
    canvas.drawLine(Offset(w * 0.2, h * 0.18), Offset(w * 0.8, h * 0.18), p);
    canvas.drawLine(Offset(w * 0.2, h * 0.80), Offset(w * 0.8, h * 0.80), p);

    // Simbol </>
    final leftBracket = Path()
      ..moveTo(w * 0.40, h * 0.41)
      ..lineTo(w * 0.31, h * 0.49)
      ..lineTo(w * 0.40, h * 0.57);
    canvas.drawPath(leftBracket, p);

    final rightBracket = Path()
      ..moveTo(w * 0.60, h * 0.41)
      ..lineTo(w * 0.69, h * 0.49)
      ..lineTo(w * 0.60, h * 0.57);
    canvas.drawPath(rightBracket, p);

    canvas.drawLine(Offset(w * 0.54, h * 0.39), Offset(w * 0.46, h * 0.59), p);
  }

  @override
  bool shouldRepaint(covariant _MobileCodeIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DatabaseIconPainter extends CustomPainter {
  final Color color;
  const _DatabaseIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9;

    final w = size.width;
    final h = size.height;
    final rx = w * 0.36;
    final ry = h * 0.11;

    // Elips atas
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: rx * 2, height: ry * 2),
      p,
    );
    // Dinding kiri & kanan
    canvas.drawLine(Offset(w * 0.5 - rx, h * 0.22), Offset(w * 0.5 - rx, h * 0.76), p);
    canvas.drawLine(Offset(w * 0.5 + rx, h * 0.22), Offset(w * 0.5 + rx, h * 0.76), p);

    // Garis lengkung tengah & bawah
    for (final cy in [0.49, 0.76]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(w * 0.5, h * cy), width: rx * 2, height: ry * 2),
        0,
        3.14159,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DatabaseIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
