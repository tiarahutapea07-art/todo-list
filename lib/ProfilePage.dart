import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart'; // sesuaikan path kalau beda

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfilePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dark Mode"),
              Switch(
                value: widget.isDarkMode,
                onChanged: (value) {
                  widget.toggleTheme();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xffe3ece7),
      appBar: AppBar(
        backgroundColor: const Color(0xff304b46),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
            ),
            const SizedBox(height: 20),

            Text(
              user?.name ?? 'Guest',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ?? '-',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () {},
              child: _profileOption("Edit Profile", Icons.edit),
            ),
            GestureDetector(
              onTap: _showSettings,
              child: _profileOption("Settings", Icons.settings),
            ),
            _profileOption("Help & Support", Icons.help),

            GestureDetector(
              onTap: () {
                authProvider.logout();
                Navigator.pop(context);
              },
              child: _profileOption("Logout", Icons.logout),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff304b46)),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
