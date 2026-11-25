import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _notes = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Kalender & Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showNoteDialog(selectedDay);
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                weekendStyle: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red.shade700),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: textColor),
                weekendTextStyle: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                outsideTextStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade400),
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: isDark ? const Color(0xff80cbc4).withOpacity(0.4) : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Catatan Harian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xff304b46),
                  ),
                ),
                const Spacer(),
                if (_selectedDay != null)
                  Text(
                    '${_notes[_selectedDay]?.length ?? 0} catatan',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _selectedDay != null &&
                    _notes[_selectedDay] != null &&
                    _notes[_selectedDay]!.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: _notes[_selectedDay]!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _notes[_selectedDay]![index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                              onPressed: () {
                                setState(() {
                                  _notes[_selectedDay]!.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 48,
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pilih tanggal untuk melihat atau menambah catatan',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(DateTime date) {
    final noteController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Catatan: ${date.day}/${date.month}/${date.year}',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xff304b46),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: TextField(
            controller: noteController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Tuliskan catatan...',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f8f6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (noteController.text.trim().isNotEmpty) {
                  setState(() {
                    _notes[date] ??= [];
                    _notes[date]!.add(noteController.text.trim());
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
