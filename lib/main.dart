import 'package:flutter/material.dart';
import 'package:flutter_application_1/CalendarPage.dart';
import 'package:flutter_application_1/ProfilePage.dart';
import 'package:flutter_application_1/TaskListPage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const FlexFlowApp(),
    ),
  );
}

class FlexFlowApp extends StatefulWidget {
  const FlexFlowApp({super.key});

  @override
  State<FlexFlowApp> createState() => _FlexFlowAppState();
}

class _FlexFlowAppState extends State<FlexFlowApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xff304b46),
        scaffoldBackgroundColor: const Color(0xffe3ece7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff304b46),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[800],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// LOGIN PAGE
//

class LoginPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const LoginPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Flex Flow To Do List",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Email
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("Forget password?"),
              ),
              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                  ),
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 20),
              const Text("— or Login with —"),

              const SizedBox(height: 20),

              // Apple & Google Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton("Apple", Icons.apple),
                  const SizedBox(width: 15),
                  _socialButton("Google", Icons.android),
                ],
              ),

              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54),
      ),
      child: Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]),
    );
  }
}

// HOME PAGE WITH BOTTOM NAVIGATION

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  int _navIndex = 0;

  // Task lists
  List<Map<String, String>> _inProgressTasks = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<TaskProvider>(context, listen: false).fetchTasksFromApi(),
    );
  }

  Widget _buildHomePage() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final inProgressTasks = taskProvider.inProgressTasks;

    if (taskProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xff304b46)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // HEADER HIJAU
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(23, 53, 23, 28),
                  decoration: const BoxDecoration(
                    color: Color(0xff304b46),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Spacer(),
                          Icon(Icons.search, color: Colors.white, size: 26),
                          SizedBox(width: 12),
                          Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 26,
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?img=3",
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Good Evening!",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                "Erik Smith",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _onTabTapped(0),
                            child: _tabItem(
                              "My Tasks",
                              isSelected: _tabIndex == 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _onTabTapped(1),
                            child: _tabItem(
                              "In-progress",
                              isSelected: _tabIndex == 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _onTabTapped(2),
                            child: _tabItem(
                              "Completed",
                              isSelected: _tabIndex == 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _topTaskCard()),
                          const SizedBox(width: 15),
                          Expanded(child: _topTaskCard()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // TITLE TODAY TASKS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                  child: Row(
                    children: const [
                      Text(
                        "Today Tasks",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              // LIST TUGAS
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final taskProvider = Provider.of<TaskProvider>(context);
                      final currentList = _tabIndex == 2
                          ? taskProvider.completedTasks
                          : taskProvider.inProgressTasks;
                      final task = currentList[index];
                      return _taskRow(
                        title: task["title"]!,
                        desc: task["desc"]!,
                        time: task["time"]!,
                        index: index,
                      );
                    },
                    childCount: _tabIndex == 2
                        ? Provider.of<TaskProvider>(
                            context,
                          ).completedTasks.length
                        : Provider.of<TaskProvider>(
                            context,
                          ).inProgressTasks.length,
                  ),
                ),
              ),
            ],
          ),

          // FLOATING BUTTON
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xff304b46),
              onPressed: () => _addTaskModal(),
              child: const Icon(Icons.add, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void _onTaskCompleted(int index) {
    Provider.of<TaskProvider>(context, listen: false).completeTask(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildHomePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 0) {
            // Home - stay on current page
            setState(() {
              _navIndex = 0;
            });
          } else if (index == 1) {
            // Calendar - navigate to calendar page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            );
          } else if (index == 2) {
            // Tasks - navigate to task list page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskListPage(
                  allTasks: Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).allTasks,
                ),
              ),
            );
          } else if (index == 3) {
            // Profile - navigate to profile page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: const Color(0xff304b46),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // MODAL ADD TASK menambahkan tugas yg baru di tombol plus
  void _addTaskModal() {
    TextEditingController titleC = TextEditingController();
    TextEditingController descC = TextEditingController();
    TextEditingController timeC = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add New Task",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              TextField(
                controller: descC,
                decoration: const InputDecoration(labelText: "Description"),
              ),

              TextField(
                controller: timeC,
                decoration: const InputDecoration(
                  labelText: "Time (10:00 - 11:00)",
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false).addTask({
                    "title": titleC.text,
                    "desc": descC.text,
                    "time": timeC.text,
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save Task"),
              ),
            ],
          ),
        );
      },
    );
  }

  // COMPONENTS (Tab, Card, Row)
  Widget _tabItem(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _topTaskCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _taskTag("Kerja", Color(0xffd5c9ff)),
              SizedBox(width: 6),
              _taskTag("Penting", Color(0xffffd4d4)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Jadwalin harimu sekarang",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text("Mon, 12 July 2022", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _taskRow({
    required String title,
    required String desc,
    required String time,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // TOMBOL CENTANG
          GestureDetector(
            onTap: () {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).completeTask(index);
            },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _tabIndex == 2
                    ? const Color(0xff304b46)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xff304b46), width: 2),
              ),
              child: _tabIndex == 2
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : const SizedBox(),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }

  Widget _taskTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
