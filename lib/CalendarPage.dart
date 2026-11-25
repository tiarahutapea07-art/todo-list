import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'search_page.dart';

class _CalendarHeaderClipper extends CustomClipper<Path> {
  final double edgeY;
  const _CalendarHeaderClipper({required this.edgeY});

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
  bool shouldReclip(covariant _CalendarHeaderClipper oldClipper) =>
      oldClipper.edgeY != edgeY;
}

class CalendarPage extends StatefulWidget {
  final VoidCallback? onNotification;

  const CalendarPage({super.key, this.onNotification});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const List<int> _paletteColors = [
    0xffde8d42,
    0xff4f8bc9,
    0xff3da17a,
    0xff9b6bc2,
    0xffe06b60,
  ];

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final Map<String, List<Map<String, String>>> _notesByDate = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime.utc(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _loadOrSeedNotes();
  }

  String _dateKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  Future<void> _loadOrSeedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('calendar_daily_notes_v2');

    if (raw != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        decoded.forEach((key, value) {
          final list = (value as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
          _notesByDate[key] = list;
        });
      } catch (_) {}
    }

    final todayKey = _dateKey(_selectedDay);
    if (!_notesByDate.containsKey(todayKey) || _notesByDate[todayKey]!.isEmpty) {
      _notesByDate[todayKey] = [
        {
          'title': 'Desain Antarmuka Mobile',
          'time': '09:00 - 10:30 WIB',
          'color': '0xffde8d42',
        },
        {
          'title': 'Rapat Evaluasi ERD',
          'time': '13:00 - 14:00 WIB',
          'color': '0xff4f8bc9',
        },
        {
          'title': 'Belajar Basis Data',
          'time': '15:30 - 17:00 WIB',
          'color': '0xff3da17a',
        },
      ];
      await _saveNotes();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendar_daily_notes_v2', jsonEncode(_notesByDate));
  }

  List<Map<String, String>> _getNotesForDay(DateTime day) {
    return _notesByDate[_dateKey(day)] ?? [];
  }

  void _defaultNotificationDialog() {
    if (widget.onNotification != null) {
      widget.onNotification!();
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Notifikasi Kalender',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xff1f4d40),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Pengingat jadwal harian aktif untuk semua catatan Anda.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(DateTime date) {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00 - 10:30 WIB');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Tambah Catatan (${date.day}/${date.month}/${date.year})',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xff1f4d40),
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Judul Kegiatan',
                  hintText: 'Contoh: Belajar Basis Data',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                  filled: true,
                  fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff3f6f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Waktu',
                  hintText: '13:00 - 14:00 WIB',
                  prefixIcon: Icon(Icons.access_time_rounded, color: primaryColor),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                  filled: true,
                  fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff3f6f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
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
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final key = _dateKey(date);
                  final existing = _notesByDate[key] ?? [];
                  final nextColor = _paletteColors[existing.length % _paletteColors.length];
                  setState(() {
                    _notesByDate[key] = [
                      ...existing,
                      {
                        'title': titleCtrl.text.trim(),
                        'time': timeCtrl.text.trim().isEmpty
                            ? '09:00 - 10:00 WIB'
                            : timeCtrl.text.trim(),
                        'color': '0x${nextColor.toRadixString(16)}',
                      },
                    ];
                  });
                  await _saveNotes();
                }
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteNote(DateTime date, int index) async {
    final key = _dateKey(date);
    final notes = _notesByDate[key];
    if (notes == null || index >= notes.length) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hapus Catatan?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Hapus "${notes[index]['title']}" dari jadwal harian?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _notesByDate[key]!.removeAt(index);
      });
      await _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffeaf0ec);
    final headerColor = isDark ? const Color(0xff16342d) : const Color(0xff1f4d40);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff111815);
    final weekendColor = isDark ? const Color(0xffe59888) : const Color(0xffb56957);

    final topInset = MediaQuery.of(context).padding.top;
    final cardTop = topInset + 18 + 48 + 22;
    final notes = _getNotesForDay(_selectedDay);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header hijau melengkung + Kartu Kalender =====
              Stack(
                children: [
                  ClipPath(
                    clipper: _CalendarHeaderClipper(edgeY: cardTop + 88),
                    child: Container(
                      width: double.infinity,
                      height: cardTop + 145,
                      color: headerColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(22, topInset + 18, 22, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kalender & Catatan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
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
                          icon: Icons.notifications_none_rounded,
                          onTap: _defaultNotificationDialog,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, cardTop, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TableCalendar<Map<String, String>>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2032, 12, 31),
                        focusedDay: _focusedDay,
                        rowHeight: 54,
                        daysOfWeekHeight: 34,
                        eventLoader: _getNotesForDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          final normalized = DateTime.utc(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );
                          if (isSameDay(_selectedDay, normalized)) {
                            _showAddNoteDialog(normalized);
                          } else {
                            setState(() {
                              _selectedDay = normalized;
                              _focusedDay = focusedDay;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          headerPadding: const EdgeInsets.symmetric(vertical: 6),
                          titleTextStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                            color: textColor,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right_rounded,
                            size: 28,
                            color: textColor,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : const Color(0xff3b4541),
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: weekendColor,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: true,
                          cellMargin: const EdgeInsets.fromLTRB(5, 3, 5, 9),
                          defaultTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: weekendColor,
                          ),
                          outsideTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white24 : const Color(0xffc5ccca),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          todayDecoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : primaryColor,
                          ),
                          markersMaxCount: 1,
                          markerSize: 6,
                          markerMargin: const EdgeInsets.only(top: 2),
                          markerDecoration: BoxDecoration(
                            color: isDark ? const Color(0xff80cbc4) : const Color(0xff1f4d40),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ===== Judul Catatan Harian + Tombol Tambah =====
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
                child: Row(
                  children: [
                    Text(
                      'Catatan Harian',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAddNoteDialog(_selectedDay),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.note_add_outlined,
                          size: 26,
                          color: isDark ? Colors.white70 : const Color(0xff2c3e3a),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Daftar Catatan Harian =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: notes.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_note_outlined,
                              size: 42,
                              color: isDark ? Colors.white30 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada catatan pada tanggal ini.\nKetuk ikon di kanan atas untuk menambah.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildNotesGrid(notes, isDark, cardColor, textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(
    List<Map<String, String>> notes,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    final widgets = <Widget>[];

    // Item pertama tampil penuh (full-width) seperti desain
    widgets.add(
      _noteCard(
        note: notes[0],
        index: 0,
        isDark: isDark,
        cardColor: cardColor,
        textColor: textColor,
        compact: false,
      ),
    );

    // Item berikutnya tampil berpasangan 2 kolom berdampingan
    int i = 1;
    while (i < notes.length) {
      if (i + 1 < notes.length) {
        widgets.add(
          const SizedBox(height: 14),
        );
        widgets.add(
          Row(
            children: [
              Expanded(
                child: _noteCard(
                  note: notes[i],
                  index: i,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  compact: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _noteCard(
                  note: notes[i + 1],
                  index: i + 1,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  compact: true,
                ),
              ),
            ],
          ),
        );
        i += 2;
      } else {
        widgets.add(const SizedBox(height: 14));
        widgets.add(
          _noteCard(
            note: notes[i],
            index: i,
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            compact: false,
          ),
        );
        i += 1;
      }
    }

    return Column(children: widgets);
  }

  Widget _noteCard({
    required Map<String, String> note,
    required int index,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required bool compact,
  }) {
    final parsedColor = int.tryParse(note['color'] ?? '') ?? 0xffde8d42;
    final barColor = Color(parsedColor);

    return GestureDetector(
      onLongPress: () => _confirmDeleteNote(_selectedDay, index),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 18,
          16,
          compact ? 10 : 16,
          16,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                constraints: const BoxConstraints(minHeight: 50),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: compact ? 11 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      note['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 15 : 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 18,
                          color: isDark ? Colors.white54 : const Color(0xff848f8b),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note['time'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 13 : 14.5,
                              color: isDark ? Colors.white70 : const Color(0xff3e4a46),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
