import 'package:flutter/material.dart';
import 'package:flutter_application_1/CalendarPage.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/tas_list_page.dart';
import 'package:flutter_application_1/task_detail_page.dart';
import 'package:flutter_application_1/register_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/task_provider.dart';
import 'providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/search_page.dart';
import 'utils/avatar_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Catatan inisialisasi Firebase: $e');
  }

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
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xff304b46),
        scaffoldBackgroundColor: const Color(0xffe3ece7),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xff304b46),
          secondary: Color(0xff4a7c6f),
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff304b46),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xff304b46),
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff4a7c6f),
        scaffoldBackgroundColor: const Color(0xff121212),
        cardColor: const Color(0xff1e1e1e),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff4a7c6f),
          secondary: Color(0xff80cbc4),
          surface: Color(0xff1e1e1e),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff1b2623),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xff1a1a1a),
          selectedItemColor: Color(0xff80cbc4),
          unselectedItemColor: Colors.white38,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// ==========================================
// LOGIN PAGE
// ==========================================

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
  bool _obscurePassword = true;

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

  Future<void> _handleDemoLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.quickDemoLogin();

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

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xff304b46),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan email Anda untuk menerima instruksi reset password:',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xff2a2a2a) : Colors.grey.shade100,
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
              backgroundColor: isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final success = await auth.resetPassword(emailCtrl.text.trim());
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Email reset password telah dikirim jika akun terdaftar'
                        : (auth.errorMessage ?? 'Gagal mengirim email reset'),
                  ),
                ),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final textColor = isDark ? Colors.white : const Color(0xff304b46);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "TaskFlow",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Kelola jadwal dan tugasmu dengan mudah",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 35),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => auth.clearError(),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                  labelText: "Email",
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => auth.clearError(),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  labelText: "Password",
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                  filled: true,
                  fillColor: cardColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Error banner
              if (auth.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.shade200),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: Text(
                    "Lupa password?",
                    style: TextStyle(
                      color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Masuk (Login)",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // Tombol Masuk Cepat (Demo Mode)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: auth.isLoading ? null : _handleDemoLogin,
                  icon: Icon(Icons.flash_on, color: primaryColor, size: 20),
                  label: Text(
                    "Masuk Cepat (Demo Mode)",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: cardColor,
                    side: BorderSide(color: primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterPage(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                        homePageBuilder: () => HomePage(
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        ),
                      ),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Belum punya akun? ",
                    style: TextStyle(color: subTextColor, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Daftar di sini",
                        style: TextStyle(
                          color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HOME PAGE WITH PERSISTENT BOTTOM NAVIGATION
// ==========================================

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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    Future.microtask(() {
      if (mounted) {
        Provider.of<TaskProvider>(context, listen: false).fetchTasksFromApi();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _navIndex = index;
    });
    // Efek pergeseran halaman yang sangat smooth
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildHomeView() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final headerBg = isDark ? const Color(0xff1c2824) : const Color(0xff304b46);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);

    if (taskProvider.isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    final currentList = _tabIndex == 0
        ? taskProvider.allTasks
        : (_tabIndex == 1
            ? taskProvider.inProgressTasks
            : taskProvider.completedTasks);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(23, 53, 23, 28),
                  decoration: BoxDecoration(
                    color: headerBg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                            onPressed: _showNotificationDialog,
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white24,
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: getAvatarImage(auth.user?.avatarUrl),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selamat Datang,",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    auth.user?.name ?? 'Pengguna',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _onTabTapped(0),
                            child: _tabItem(
                              "Semua (${taskProvider.allTasks.length})",
                              isSelected: _tabIndex == 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _onTabTapped(1),
                            child: _tabItem(
                              "Berjalan (${taskProvider.inProgressTasks.length})",
                              isSelected: _tabIndex == 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _onTabTapped(2),
                            child: _tabItem(
                              "Selesai (${taskProvider.completedTasks.length})",
                              isSelected: _tabIndex == 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _topSummaryCard(
                              title: "Tugas Aktif",
                              value: "${taskProvider.inProgressTasks.length}",
                              sub: "Sedang dikerjakan",
                              isDark: isDark,
                              iconColor: Colors.orange.shade500,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _topSummaryCard(
                              title: "Tuntas",
                              value: "${taskProvider.completedTasks.length}",
                              sub: "Berhasil diselesaikan",
                              isDark: isDark,
                              iconColor: Colors.green.shade500,
                            ),
                          ),
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
                    children: [
                      Text(
                        _tabIndex == 0
                            ? "Semua Tugas"
                            : (_tabIndex == 1 ? "Tugas Berjalan" : "Tugas Selesai"),
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xff304b46),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${currentList.length} item",
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                sliver: currentList.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_outlined,
                                size: 48,
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Tidak ada tugas dalam kategori ini",
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = currentList[index];
                            return _taskRow(
                              task: task,
                              title: task["title"] ?? '',
                              desc: task["desc"] ?? '',
                              time: task["time"] ?? '',
                              index: index,
                              isDark: isDark,
                            );
                          },
                          childCount: currentList.length,
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: _addTaskModal,
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
              ),
              const SizedBox(width: 8),
              Text(
                "Notifikasi",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "Semua tugas Anda tersinkronisasi dengan baik. Tidak ada notifikasi tertunda saat ini.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Tutup",
                style: TextStyle(color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46)),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // PageView memberikan efek pergeseran yang sangat halus
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _navIndex = index;
          });
        },
        children: [
          _buildHomeView(),
          const CalendarPage(),
          const TaskListPage(),
          ProfilePage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            loginPageBuilder: () => LoginPage(
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        ],
      ),
      // Bottom navigation bar tetap ada dan tidak menghilang
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
        backgroundColor: isDark ? const Color(0xff1c1c1c) : Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  void _addTaskModal() {
    String taskTitle = '';
    String taskDescription = '';
    DateTime? selectedDate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
            final inputBg = isDark ? const Color(0xff2a2a2a) : const Color(0xfff2f6f3);
            final titleColor = isDark ? Colors.white : const Color(0xff304b46);

            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 15,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 25,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      "Buat Tugas Baru",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Nama Tugas",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      onChanged: (value) => taskTitle = value,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Masukkan nama tugas...",
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        filled: true,
                        fillColor: inputBg,
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                          color: isDark ? const Color(0xff80cbc4) : const Color(0xff60766f),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Deadline",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
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
                                colorScheme: ColorScheme.light(
                                  primary: isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46),
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
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? "Pilih tanggal deadline"
                                    : DateFormat('dd MMMM yyyy').format(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? (isDark ? Colors.white38 : Colors.grey)
                                      : (isDark ? Colors.white : const Color(0xff304b46)),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? Colors.white54 : const Color(0xff304b46),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      onChanged: (value) => taskDescription = value,
                      maxLines: 3,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Tuliskan deskripsi tugas...",
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46),
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

                          final formattedDate = selectedDate == null
                              ? "Deadline: Hari ini"
                              : "Deadline: ${DateFormat('dd MMMM yyyy').format(selectedDate!)}";

                          await Provider.of<TaskProvider>(
                            modalContext,
                            listen: false,
                          ).addTask({
                            "title": taskTitle.trim(),
                            "desc": taskDescription.trim().isEmpty
                                ? "Tugas baru ditambahkan"
                                : taskDescription.trim(),
                            "time": formattedDate,
                          });

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Tugas berhasil ditambahkan!"),
                                backgroundColor: isDark
                                    ? const Color(0xff4a7c6f)
                                    : const Color(0xff304b46),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Tambah Tugas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _tabItem(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? const Color(0xff304b46) : Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _topSummaryCard({
    required String title,
    required String value,
    required String sub,
    required bool isDark,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Icon(Icons.trending_up, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow({
    required Map<String, String> task,
    required String title,
    required String desc,
    required String time,
    required int index,
    required bool isDark,
  }) {
    final isCompleted = task['time'] == 'Selesai';
    final cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final primaryColor = isDark ? const Color(0xff80cbc4) : const Color(0xff304b46);

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
          color: cardBg,
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
            // Tombol menyelesaikan tugas
            GestureDetector(
              onTap: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).toggleTaskStatus(task);
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? primaryColor : Colors.transparent,
                  border: Border.all(color: primaryColor, width: 2),
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
                      color: isCompleted
                          ? Colors.grey
                          : (isDark ? Colors.white : const Color(0xff304b46)),
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
                      color: isDark ? Colors.white60 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.green
                          : (isDark ? const Color(0xff80cbc4) : Colors.grey),
                      fontSize: 12,
                      fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                    ),
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
  }
}
