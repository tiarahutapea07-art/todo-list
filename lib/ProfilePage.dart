import 'package:flutter/material.dart';

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
  String _name = "Erik Smith";

  void _editProfile() {
    TextEditingController nameController = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
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
              _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "erik.smith@example.com",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _editProfile,
              child: _profileOption("Edit Profile", Icons.edit),
            ),
            GestureDetector(
              onTap: _showSettings,
              child: _profileOption("Settings", Icons.settings),
            ),
            _profileOption("Help & Support", Icons.help),
            _profileOption("Logout", Icons.logout),
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
