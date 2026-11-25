import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/avatar_helper.dart';

/// Clipper kubah melengkung ke atas seperti desain Edit Profil.
class _ArchHeaderClipper extends CustomClipper<Path> {
  final double peakY;
  const _ArchHeaderClipper({required this.peakY});

  @override
  Path getClip(Size size) {
    final sideY = size.height;
    final controlY = 2 * peakY - sideY;
    final path = Path()
      ..lineTo(0, sideY)
      ..quadraticBezierTo(size.width / 2, controlY, size.width, sideY)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ArchHeaderClipper oldClipper) =>
      oldClipper.peakY != peakY;
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late String _selectedAvatar;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _selectedAvatar = normalizeAvatarId(user?.avatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _takePhotoDirectly() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedAvatar = photo.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto kamera berhasil diambil!'),
              backgroundColor: Color(0xff1f4d40),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka kamera: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedAvatar = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto dari galeri dipilih!'),
              backgroundColor: Color(0xff1f4d40),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _randomizeAvatar() {
    final candidates = kDiverseAvatarPresets
        .where((item) => item['id'] != _selectedAvatar)
        .toList();
    if (candidates.isEmpty) return;

    final random = Random();
    final picked = candidates[random.nextInt(candidates.length)];
    setState(() {
      _selectedAvatar = picked['id']!;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Avatar acak terpilih: ${picked['name']} (${picked['group']})'),
        backgroundColor: const Color(0xff1f4d40),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _showPhotoPickerOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Masukkan Foto Profil',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xff1f4d40),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff1f4d40).withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: isDark ? const Color(0xff80cbc4) : const Color(0xff1f4d40),
                    ),
                  ),
                  title: Text(
                    'Ambil Foto Langsung (Kamera)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Buka kamera untuk foto profil secara langsung',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _takePhotoDirectly();
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Pilih gambar dari penyimpanan perangkat',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      name: name,
      email: email,
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: _selectedAvatar,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Color(0xff1f4d40),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffeef3f0);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final headerColor = isDark ? const Color(0xff16342d) : const Color(0xff21483e);
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff23483e);
    final textColor = isDark ? Colors.white : const Color(0xff111815);
    final topInset = MediaQuery.of(context).padding.top;

    final archPeakY = topInset + 68;
    final headerSideHeight = topInset + 186;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 36),
          child: Column(
            children: [
              // ===== Header Melengkung Kubah + Avatar Besar =====
              Stack(
                children: [
                  ClipPath(
                    clipper: _ArchHeaderClipper(peakY: archPeakY),
                    child: Container(
                      width: double.infinity,
                      height: headerSideHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xff142d27), const Color(0xff1d3f37)]
                              : [const Color(0xff1c3d34), const Color(0xff275448)],
                        ),
                      ),
                    ),
                  ),

                  // AppBar Transparan (Back + Judul Edit Profil)
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, topInset + 6, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Edit Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lingkaran Avatar Pratinjau Besar
                  Padding(
                    padding: EdgeInsets.only(top: archPeakY + 26),
                    child: Center(
                      child: GestureDetector(
                        onTap: _showPhotoPickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(4.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cardColor,
                            border: Border.all(
                              color: isDark ? const Color(0xff5fa392) : const Color(0xff25493f),
                              width: 3.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: buildUserAvatar(
                            avatarUrl: _selectedAvatar,
                            radius: 82,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ===== Tombol Masukkan Foto & Acak Avatar =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showPhotoPickerOptions,
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 21),
                      label: const Text(
                        'Masukkan Foto',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.black38,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _randomizeAvatar,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xff1e3d34),
                      ),
                      label: Text(
                        'Acak Avatar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xff1e3d34),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xff1e1e1e) : const Color(0xfff4f7f5),
                        side: BorderSide(
                          color: isDark ? const Color(0xff5fa392) : const Color(0xff25493f),
                          width: 1.4,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== Kartu Pilihan Avatar Beragam (Grid 2x3) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pilihan Avatar Beragam',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                          Text(
                            'Laki / Wanita / Usia',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? Colors.white60 : const Color(0xff77827d),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Baris 1: Dimas, Siti, Budi
                      Row(
                        children: kDiverseAvatarPresets
                            .sublist(0, 3)
                            .map((item) => Expanded(child: _buildAvatarGridItem(item, isDark)))
                            .toList(),
                      ),
                      const SizedBox(height: 18),

                      // Baris 2: Maya, Hendra, Sri
                      Row(
                        children: kDiverseAvatarPresets
                            .sublist(3, 6)
                            .map((item) => Expanded(child: _buildAvatarGridItem(item, isDark)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== Kartu Form Input Data Profil =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileField(
                        label: 'Nama Lengkap',
                        controller: _nameController,
                        icon: Icons.person,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Nomor Telepon',
                        controller: _phoneController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Bio / Status',
                        controller: _bioController,
                        icon: Icons.info_outline_rounded,
                        maxLines: 4,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== Tombol Simpan Perubahan =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerColor,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGridItem(Map<String, String> item, bool isDark) {
    final id = item['id']!;
    final name = item['name']!;
    final isSelected = _selectedAvatar == id;
    final ringColor = isDark ? const Color(0xff80cbc4) : const Color(0xff25493f);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = id;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ringColor : Colors.transparent,
                width: 2.8,
              ),
            ),
            child: buildUserAvatar(
              avatarUrl: id,
              radius: 44,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xff111815),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final fieldBg = isDark ? const Color(0xff292f2c) : const Color(0xffeaf0ec);
    final labelColor = isDark ? const Color(0xff9cc7bc) : const Color(0xff2d4a42);
    final iconColor = isDark ? const Color(0xff80cbc4) : const Color(0xff23483e);
    final textColor = isDark ? Colors.white : const Color(0xff111815);
    final isMultiline = maxLines > 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isMultiline ? 12 : 4,
            ),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment:
                  isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: isMultiline ? 6 : 0, right: 12),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.35,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 0,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ),
      ],
    );
  }
}
