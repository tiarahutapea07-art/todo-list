import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'task_provider.dart';
import 'edit_profile_page.dart';
import 'utils/avatar_helper.dart';

class _ProfileBackdropClipper extends CustomClipper<Path> {
  final double edgeY;
  const _ProfileBackdropClipper({required this.edgeY});

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
  bool shouldReclip(covariant _ProfileBackdropClipper oldClipper) =>
      oldClipper.edgeY != edgeY;
}

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
  // Switch animasi halus: bulatan bergeser ke kanan (Dark) & ke kiri (Light)
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
        width: 70,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isDark ? const Color(0xff4a7c6f) : const Color(0xffbac7c0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
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
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              size: 17,
              color: isDark ? const Color(0xff1f4d40) : Colors.amber.shade700,
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
            final textColor = isDark ? Colors.white : const Color(0xff1f4d40);
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
                          color: (isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40))
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: isDark ? const Color(0xff80cbc4) : const Color(0xff1f4d40),
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
                      color: isDark ? const Color(0xff80cbc4) : const Color(0xff1f4d40),
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
                        backgroundColor:
                            isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40),
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
                color: isDark ? const Color(0xff80cbc4) : const Color(0xff1f4d40),
              ),
              const SizedBox(width: 10),
              Text(
                'Bantuan & Dukungan',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xff1f4d40),
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
                backgroundColor: isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40),
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

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffeaf0ec);
    final headerColor = isDark ? const Color(0xff16342d) : const Color(0xff1f4d40);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff1f4d40);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff111815);
    final subTextColor = isDark ? Colors.white70 : const Color(0xff525d58);
    final topInset = MediaQuery.of(context).padding.top;

    final pinnedHeaderH = topInset + 86;
    final cardStartTop = topInset + 92;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // ===== Konten Scrollable dengan backdrop melengkung di atas =====
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 115),
              child: Stack(
                children: [
                  ClipPath(
                    clipper: _ProfileBackdropClipper(edgeY: cardStartTop + 95),
                    child: Container(
                      width: double.infinity,
                      height: cardStartTop + 150,
                      color: headerColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, cardStartTop, 20, 0),
                    child: Column(
                      children: [
                        // ===== Kartu Profil Utama =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
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
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xff5ea391)
                                            : const Color(0xff234b3f),
                                        width: 3.5,
                                      ),
                                    ),
                                    child: buildUserAvatar(
                                      avatarUrl: user?.avatarUrl,
                                      radius: 62,
                                      backgroundColor: isDark
                                          ? const Color(0xff2a3632)
                                          : const Color(0xffe1ece7),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const EditProfilePage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: cardColor, width: 3),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 19,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                (user?.name != null && user!.name.isNotEmpty)
                                    ? user.name
                                    : 'User TaskFlow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user?.email ?? '-',
                                style: TextStyle(color: subTextColor, fontSize: 15.5),
                              ),
                              if (user?.phone != null && user!.phone.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  user.phone,
                                  style: TextStyle(color: subTextColor, fontSize: 15.5),
                                ),
                              ],
                              if (user?.bio != null && user!.bio.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xff2a3632)
                                        : const Color(0xffb8c6bf),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    user.bio,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xffd7ebe4)
                                          : const Color(0xff111815),
                                      fontSize: 14.5,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ===== Kartu Tema Aplikasi =====
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xff263b34)
                                      : const Color(0xffa8c3b4),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Icon(
                                  isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_outlined,
                                  size: 27,
                                  color: isDark
                                      ? const Color(0xff80cbc4)
                                      : const Color(0xff1d3830),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tema Aplikasi',
                                      style: TextStyle(
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white60
                                            : const Color(0xff6b7571),
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

                        // ===== 3 Kartu Statistik Berwarna Pastel =====
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                label: 'Total',
                                value: '${taskProvider.allTasks.length}',
                                icon: Icons.format_list_bulleted_rounded,
                                bgColor: isDark
                                    ? const Color(0xff1e2d33)
                                    : const Color(0xffb8cfd6),
                                accentColor: isDark
                                    ? const Color(0xff8ecae6)
                                    : const Color(0xff1c333a),
                                labelColor: isDark
                                    ? Colors.white70
                                    : const Color(0xff2c4249),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                label: 'Berjalan',
                                value: '${taskProvider.inProgressTasks.length}',
                                icon: Icons.timelapse_rounded,
                                bgColor: isDark
                                    ? const Color(0xff332619)
                                    : const Color(0xffffdfbd),
                                accentColor: isDark
                                    ? const Color(0xffffb74d)
                                    : const Color(0xffe07b1a),
                                labelColor: isDark
                                    ? Colors.white70
                                    : const Color(0xff5c4632),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                label: 'Selesai',
                                value: '${taskProvider.completedTasks.length}',
                                icon: Icons.check_circle_outline_rounded,
                                bgColor: isDark
                                    ? const Color(0xff1b3020)
                                    : const Color(0xffd2f0d5),
                                accentColor: isDark
                                    ? const Color(0xff81c784)
                                    : const Color(0xff338a3e),
                                labelColor: isDark
                                    ? Colors.white70
                                    : const Color(0xff355439),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ===== Daftar Menu Opsi =====
                        _profileOption(
                          title: 'Edit Profil & Kamera',
                          icon: Icons.edit_outlined,
                          cardColor: cardColor,
                          iconBoxBg: isDark
                              ? const Color(0xff25323a)
                              : const Color(0xffa8bac4),
                          iconColor: isDark
                              ? const Color(0xff90caf9)
                              : const Color(0xff2c3e47),
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );
                          },
                        ),
                        _profileOption(
                          title: 'Pengaturan & Tema',
                          icon: Icons.settings_outlined,
                          cardColor: cardColor,
                          iconBoxBg: isDark
                              ? const Color(0xff24362b)
                              : const Color(0xffacc2b3),
                          iconColor: isDark
                              ? const Color(0xff80cbc4)
                              : const Color(0xff2d4536),
                          isDark: isDark,
                          onTap: _showSettings,
                        ),
                        _profileOption(
                          title: 'Bantuan & Dukungan',
                          icon: Icons.help_outline_rounded,
                          cardColor: cardColor,
                          iconBoxBg: isDark
                              ? const Color(0xff223242)
                              : const Color(0xffbfd4e6),
                          iconColor: isDark
                              ? const Color(0xff90caf9)
                              : const Color(0xff2e4c66),
                          isDark: isDark,
                          onTap: _showHelpSupport,
                        ),
                        _profileOption(
                          title: 'Keluar (Logout)',
                          icon: Icons.logout_rounded,
                          cardColor: cardColor,
                          iconBoxBg: isDark
                              ? const Color(0xff3b2020)
                              : const Color(0xfffad2d2),
                          iconColor: isDark
                              ? const Color(0xffff6b6b)
                              : const Color(0xffc93b3b),
                          isDark: isDark,
                          isDestructive: true,
                          onTap: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Pinned Top Header Melengkung (muncul rapi saat di-scroll ke bawah) =====
            ClipPath(
              clipper: _ProfileBackdropClipper(edgeY: pinnedHeaderH - 18),
              child: Container(
                width: double.infinity,
                height: pinnedHeaderH,
                color: headerColor,
                padding: EdgeInsets.fromLTRB(22, topInset + 14, 22, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Profil Pengguna',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showSettings,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
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
    required Color iconBoxBg,
    required Color iconColor,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final titleColor = isDestructive
        ? (isDark ? const Color(0xffff6b6b) : const Color(0xffc93b3b))
        : (isDark ? Colors.white : const Color(0xff111815));

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBoxBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 24,
          color: isDark ? Colors.white38 : const Color(0xff8a9490),
        ),
        onTap: onTap,
      ),
    );
  }
}
