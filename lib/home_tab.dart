import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'search_page.dart';
import 'task_detail_page.dart';
import 'task_provider.dart';
import 'utils/avatar_helper.dart';

/// Clipper header hijau melengkung (bagian bawah membulat seperti desain).
class _HeaderClipper extends CustomClipper<Path> {
  final double edgeY;
  const _HeaderClipper({required this.edgeY});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, edgeY)
      ..quadraticBezierTo(
        size.width / 2,
        2 * size.height - edgeY,
        size.width,
        edgeY,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _HeaderClipper oldClipper) =>
      oldClipper.edgeY != edgeY;
}

class HomeTab extends StatefulWidget {
  final VoidCallback onNotification;

  const HomeTab({super.key, required this.onNotification});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const double _cardsH = 146;
  int _filter = 0;

  // ---------- Warna deadline ----------
  Color _deadlineColor(String time) {
    const red = Color(0xffee6b60);
    const amber = Color(0xffe3a63c);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int? diff;

    if (time.contains('Hari ini')) {
      diff = 0;
    } else if (time.contains('Besok')) {
      diff = 1;
    } else {
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final idx = days.indexWhere((d) => time.contains(d));
      if (idx != -1) {
        diff = ((idx + 1) - now.weekday) % 7;
      } else {
        try {
          final raw = time.replaceFirst('Deadline:', '').trim();
          final parsed = DateFormat('dd MMMM yyyy').parse(raw);
          diff = parsed.difference(today).inDays;
        } catch (_) {
          diff = null;
        }
      }
    }

    if (diff == null) return amber;
    return diff <= 1 ? red : amber;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tp = context.watch<TaskProvider>();

    final bg = isDark ? const Color(0xff121212) : const Color(0xffeaf0ec);
    final headerColor = isDark ? const Color(0xff16342d) : const Color(0xff1f4d40);
    final primary = isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40);

    final topInset = MediaQuery.of(context).padding.top;
    final cardsTop = topInset + 14 + 58 + 24;
    final headerH = cardsTop + _cardsH + 16;

    final list = _filter == 0
        ? tp.allTasks
        : (_filter == 1 ? tp.inProgressTasks : tp.completedTasks);
    final heading = _filter == 0
        ? 'Semua Tugas'
        : (_filter == 1 ? 'Tugas Berjalan' : 'Tugas Selesai');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
      color: bg,
      child: CustomScrollView(
        slivers: [
          // ===== Header + kartu ringkasan =====
          SliverToBoxAdapter(
            child: SizedBox(
              height: headerH,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: _HeaderClipper(edgeY: cardsTop + 40),
                    child: Container(
                      width: double.infinity,
                      height: headerH,
                      color: headerColor,
                    ),
                  ),
                  Positioned(
                    top: topInset + 14,
                    left: 22,
                    right: 22,
                    child: _topRow(),
                  ),
                  Positioned(
                    top: cardsTop,
                    left: 20,
                    right: 20,
                    height: _cardsH,
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            isDark: isDark,
                            title: 'Tugas Aktif',
                            value: '${tp.inProgressTasks.length}',
                            sub: 'Sedang dikerjakan',
                            icon: Icons.data_usage_rounded,
                            accent: const Color(0xffe08a2e),
                            accentBg: const Color(0xffffe6cf),
                            dot: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _summaryCard(
                            isDark: isDark,
                            title: 'Tuntas',
                            value: '${tp.completedTasks.length}',
                            sub: 'Berhasil diselesaikan',
                            icon: Icons.check_rounded,
                            accent: const Color(0xff1e8f6e),
                            accentBg: const Color(0xffd5efe4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Chip filter =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('Semua (${tp.allTasks.length})', 0, isDark, primary),
                    const SizedBox(width: 10),
                    _chip('Berjalan (${tp.inProgressTasks.length})', 1, isDark, primary),
                    const SizedBox(width: 10),
                    _chip('Selesai (${tp.completedTasks.length})', 2, isDark, primary),
                  ],
                ),
              ),
            ),
          ),

          // ===== Judul daftar =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    heading,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xff111815),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${list.length} item',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white54 : const Color(0xff7b8782),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Daftar tugas =====
          if (tp.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: primary)),
              ),
            )
          else if (list.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 48,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada tugas dalam kategori ini',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _taskCard(list[i], isDark, primary),
                  childCount: list.length,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  // ---------- Baris atas: avatar, sapaan, search, notifikasi ----------
  Widget _topRow() {
    return Row(
      children: [
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 2),
              ),
              child: buildUserAvatar(
                avatarUrl: auth.user?.avatarUrl,
                radius: 25,
                backgroundColor: const Color(0xffe1ece7),
              ),
            );
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selamat Datang,',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    (auth.user?.name.isNotEmpty ?? false)
                        ? auth.user!.name
                        : 'Pengguna',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _circleButton(
          icon: Icons.search,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          },
        ),
        const SizedBox(width: 10),
        _circleButton(
          icon: Icons.notifications_none_rounded,
          onTap: widget.onNotification,
          showDot: true,
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            if (showDot)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xffff7043),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff1f4d40), width: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Kartu ringkasan ----------
  Widget _summaryCard({
    required bool isDark,
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color accent,
    required Color accentBg,
    bool dot = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? accent.withOpacity(0.2) : accentBg,
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xff111815),
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 42,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          Row(
            children: [
              if (dot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xff1d2623),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Chip filter ----------
  Widget _chip(String label, int index, bool isDark, Color primary) {
    final selected = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? primary
                : (isDark ? Colors.white24 : const Color(0xffc9d3cf)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xff4a5a56)),
          ),
        ),
      ),
    );
  }

  // ---------- Kartu tugas ----------
  Widget _taskCard(Map<String, String> task, bool isDark, Color primary) {
    final time = task['time'] ?? '';
    final done = time == 'Selesai';
    final checkColor = const Color(0xff2e9e78);

    final card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.read<TaskProvider>().toggleTaskStatus(task),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? checkColor : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? checkColor
                        : (isDark ? Colors.white54 : const Color(0xff2c3e3a)),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: done
                        ? Colors.grey
                        : (isDark ? Colors.white : const Color(0xff111815)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['desc'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: done
                        ? Colors.grey
                        : (isDark ? Colors.white70 : const Color(0xff1d2623)),
                  ),
                ),
                const SizedBox(height: 10),
                _deadlinePill(time, done),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
        );
      },
      child: done ? Opacity(opacity: 0.7, child: card) : card,
    );
  }

  Widget _deadlinePill(String time, bool done) {
    if (done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xff8fcfb5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Selesai',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _deadlineColor(time),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
