import 'package:flutter/material.dart';
import 'package:flutter_application_1/CalendarPage.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/tas_list_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/task_provider.dart';
import 'providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/search_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
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

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const LoginPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();

    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "TaskFlow",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Pesan error validasi
              if (auth.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("Forget password?"),
              ),
              const SizedBox(height: 20),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("— or Login with —"),
              const SizedBox(height: 20),

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
                        children: [
                          const Spacer(),

                          // Tombol Search
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Tombol Notification
                          IconButton(
                            onPressed: () {
                              debugPrint('Tombol Notification diklik');
                              _showNotificationDialog();
                            },
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 26,
                            ),
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
                          // NAMA DARI AUTH PROVIDER
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Good Evening!",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  auth.user?.name ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  // Fungsi Notification
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: const Text("Belum ada notifikasi."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildHomePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _navIndex = 0;
            });
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            );
          } else if (index == 2) {
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

  void _addTaskModal() {
    String taskTitle = '';
    String taskDescription = '';

    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 15,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 25,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Create New Task",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff304b46),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Task Name",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff304b46),
                      ),
                    ),

                    const SizedBox(height: 9),

                    TextField(
                      onChanged: (value) {
                        taskTitle = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Masukkan nama tugas...",
                        filled: true,
                        fillColor: const Color(0xfff2f6f3),
                        prefixIcon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xff60766f),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Deadline",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff304b46),
                      ),
                    ),

                    const SizedBox(height: 9),

                    InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: modalContext,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xff304b46),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null && modalContext.mounted) {
                          setModalState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 17,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xfff2f6f3),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Color(0xff304b46),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? "Pilih tanggal deadline"
                                    : DateFormat(
                                        'dd MMMM yyyy',
                                      ).format(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.grey
                                      : const Color(0xff304b46),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xff304b46),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff304b46),
                      ),
                    ),

                    const SizedBox(height: 9),

                    TextField(
                      onChanged: (value) {
                        taskDescription = value;
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Tuliskan deskripsi tugas...",
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: const Color(0xfff2f6f3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff304b46),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          if (taskTitle.trim().isEmpty) {
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              const SnackBar(
                                content: Text("Nama tugas harus diisi!"),
                              ),
                            );
                            return;
                          }

                          if (selectedDate == null) {
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              const SnackBar(
                                content: Text("Silakan pilih deadline!"),
                              ),
                            );
                            return;
                          }

                          final formattedDate = DateFormat(
                            'dd MMMM yyyy',
                          ).format(selectedDate!);

                          await Provider.of<TaskProvider>(
                            modalContext,
                            listen: false,
                          ).addTask({
                            "title": taskTitle.trim(),
                            "desc": taskDescription.trim(),
                            "time": "Deadline: $formattedDate",
                          });

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        child: const Text(
                          "Create Task",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
              _taskTag("Kerja", const Color(0xffd5c9ff)),
              const SizedBox(width: 6),
              _taskTag("Penting", const Color(0xffffd4d4)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Jadwalin harimu sekarang",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            DateFormat('EEE, dd MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.grey),
          ),
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
    final isCompleted = _tabIndex == 2;

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Tombol menyelesaikan tugas
          GestureDetector(
            onTap: () {
              if (!isCompleted) {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).completeTask(index);
              }
            },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xff304b46)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xff304b46), width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : const SizedBox(),
            ),
          ),

          const SizedBox(width: 12),

          // Informasi tugas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.grey : const Color(0xff304b46),
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(Icons.more_vert, color: Colors.grey),
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
