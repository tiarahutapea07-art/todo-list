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
  Map<DateTime, List<String>> _notes = {}; // penyimpanan sederhana

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      appBar: AppBar(
        backgroundColor: const Color(0xff304b46),
        title: const Text('Calendar', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
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
              _showNoteDialog(selectedDay); // fungsi tambah data
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xff304b46), //lingkaran hijau
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                _selectedDay != null &&
                    _notes[_selectedDay] !=
                        null //logika
                ? ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _notes[_selectedDay]!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_notes[_selectedDay]![index]),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Select a date to view notes',
                      style: TextStyle(color: Color.fromARGB(255, 12, 12, 12)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(DateTime date) {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // untuk munculnya jendela pop up kecil di tengah layar
          title: Text('Add Note for ${date.day}/${date.month}/${date.year}'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: 'Enter your note'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  setState(() {
                    if (_notes[date] == null) {
                      _notes[date] = [];
                    }
                    _notes[date]!.add(noteController.text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
