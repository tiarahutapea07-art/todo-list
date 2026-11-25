import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'task_provider.dart';
import 'edit_profile_page.dart';
import 'utils/avatar_helper.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Widget Function()? loginPageBuilder;

  const ProfilePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    this.loginPageBuilder,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Widget Switch Animasi Halus: bulatan bergeser ke kanan (Dark) & ke kiri (Light)
  Widget _buildSlidingSwitch({
    required bool isDark,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 66,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isDark ? const Color(0xff4a7c6f) : const Color(0xffc2d1cb),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              size: 16,
              color: isDark ? const Color(0xff304b46) : Colors.amber.shade800,
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xff304b46);
            final subTextColor = isDark ? Colors.white70 : Colors.black87;

            return Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46)).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Pengaturan & Tema',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mode Gelap Toggle Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff292929) : const Color(0xfff2f6f4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xff3a3a3a) : const Color(0xffdbe7e2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Gelap (Dark Mode)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: subTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDark
                                    ? 'Aktif — Tampilan gelap nyaman di mata'
                                    : 'Nonaktif — Tampilan cerah klasik',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildSlidingSwitch(
                          isDark: isDark,
                          onToggle: () {
                            widget.toggleTheme();
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    leading: Icon(
                      Icons.notifications_active_outlined,
                      color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                    ),
                    title: Text(
                      'Notifikasi Pengingat',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                    trailing: const Text(
                      'Aktif',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(modalCtx),
                      child: const Text('Tutup Pengaturan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpSupport() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
              ),
              const SizedBox(width: 10),
              Text(
                'Bantuan & Dukungan',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xff304b46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TaskFlow App v1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aplikasi manajemen tugas harian modern untuk mempermudah pencatatan, pemantauan deadline, dan penyelesaian tugas perkuliahan atau pekerjaan.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kontak Dukungan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Email: support@taskflow.dev\nWebsite: https://taskflow.dev',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Konfirmasi Logout',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();

              if (mounted) {
                if (widget.loginPageBuilder != null) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => widget.loginPageBuilder!()),
                    (route) => false,
                  );
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final textColor = isDark ? Colors.white : const Color(0xff304b46);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Nama Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7),
                          backgroundImage: getAvatarImage(user?.avatarUrl),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    (user?.name != null && user!.name.isNotEmpty)
                        ? user.name
                        : 'User TaskFlow',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '-',
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  if (user?.phone != null && user!.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.phone,
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  ],
                  if (user?.bio != null && user!.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Mode Gelap Quick Toggle Banner with smooth sliding switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tema Aplikasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          isDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSlidingSwitch(
                    isDark: isDark,
                    onToggle: widget.toggleTheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Statistik Tugas
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total',
                    '${taskProvider.allTasks.length}',
                    Icons.format_list_bulleted,
                    isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                    cardColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    'Berjalan',
                    '${taskProvider.inProgressTasks.length}',
                    Icons.timelapse,
                    Colors.orange.shade600,
                    cardColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    'Selesai',
                    '${taskProvider.completedTasks.length}',
                    Icons.check_circle_outline,
                    Colors.green.shade600,
                    cardColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Options list
            _profileOption(
              title: "Edit Profil & Kamera",
              icon: Icons.edit_outlined,
              cardColor: cardColor,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),
            _profileOption(
              title: "Pengaturan & Tema",
              icon: Icons.settings_outlined,
              cardColor: cardColor,
              isDark: isDark,
              onTap: _showSettings,
            ),
            _profileOption(
              title: "Bantuan & Dukungan",
              icon: Icons.help_outline,
              cardColor: cardColor,
              isDark: isDark,
              onTap: _showHelpSupport,
            ),
            _profileOption(
              title: "Keluar (Logout)",
              icon: Icons.logout,
              cardColor: cardColor,
              isDark: isDark,
              isDestructive: true,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color accentColor, Color cardColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color cardColor,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.12)
                : (isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.redAccent
                : (isDark ? const Color(0xff80cbc4) : const Color(0xff304b46)),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? Colors.redAccent
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDark ? Colors.white38 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
