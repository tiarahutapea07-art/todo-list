import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/avatar_helper.dart';

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

  final Map<String, List<Map<String, String>>> _categorizedAvatars = {
    'Laki-laki Muda': [
      {'name': 'Alex', 'url': 'https://i.pravatar.cc/150?img=11'},
      {'name': 'Dimas', 'url': 'https://i.pravatar.cc/150?img=12'},
      {'name': 'Rian', 'url': 'https://i.pravatar.cc/150?img=33'},
      {'name': 'Kevin', 'url': 'https://i.pravatar.cc/150?img=15'},
    ],
    'Wanita Muda': [
      {'name': 'Siti', 'url': 'https://i.pravatar.cc/150?img=5'},
      {'name': 'Maya', 'url': 'https://i.pravatar.cc/150?img=9'},
      {'name': 'Nadia', 'url': 'https://i.pravatar.cc/150?img=47'},
      {'name': 'Clara', 'url': 'https://i.pravatar.cc/150?img=49'},
    ],
    'Laki-laki Dewasa / Tua': [
      {'name': 'Pak Budi', 'url': 'https://i.pravatar.cc/150?img=52'},
      {'name': 'Pak Hendra', 'url': 'https://i.pravatar.cc/150?img=59'},
      {'name': 'Kakek Robert', 'url': 'https://i.pravatar.cc/150?img=60'},
      {'name': 'Pak Surya', 'url': 'https://i.pravatar.cc/150?img=68'},
    ],
    'Wanita Dewasa / Tua': [
      {'name': 'Ibu Ani', 'url': 'https://i.pravatar.cc/150?img=23'},
      {'name': 'Ibu Dewi', 'url': 'https://i.pravatar.cc/150?img=24'},
      {'name': 'Nenek Sarah', 'url': 'https://i.pravatar.cc/150?img=26'},
      {'name': 'Ibu Rina', 'url': 'https://i.pravatar.cc/150?img=32'},
    ],
  };

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _selectedAvatar = user?.avatarUrl.isNotEmpty == true
        ? user!.avatarUrl
        : 'https://i.pravatar.cc/150?img=33';
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
              backgroundColor: Color(0xff304b46),
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
              backgroundColor: Color(0xff304b46),
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
    final allAvatars = <String>[];
    _categorizedAvatars.forEach((category, list) {
      for (final item in list) {
        allAvatars.add(item['url']!);
      }
    });

    if (allAvatars.isNotEmpty) {
      final random = Random();
      final randomUrl = allAvatars[random.nextInt(allAvatars.length)];
      setState(() {
        _selectedAvatar = randomUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar acak berhasil dipilih!'),
          backgroundColor: Color(0xff304b46),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  void _showImageSourceOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xff304b46),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff304b46).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Color(0xff304b46)),
                  ),
                  title: Text(
                    'Ambil Foto Langsung (Kamera)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Buka kamera dan ambil foto sekarang',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _takePhotoDirectly();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Pilih foto dari penyimpanan galeri perangkat',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shuffle, color: Colors.orange),
                  ),
                  title: Text(
                    'Acak Avatar (Random)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Pilih avatar secara acak dari berbagai kalangan',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _randomizeAvatar();
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
          backgroundColor: Color(0xff304b46),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xffe3ece7);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final primaryColor = isDark ? const Color(0xff4a7c6f) : const Color(0xff304b46);
    final textColor = isDark ? Colors.white : const Color(0xff304b46);
    final bodyTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Preview with interactive camera button
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceOptions,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: isDark ? const Color(0xff2a2a2a) : const Color(0xffe3ece7),
                        backgroundImage: getAvatarImage(_selectedAvatar),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _takePhotoDirectly,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Camera & Random buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhotoDirectly,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Foto Langsung'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _randomizeAvatar,
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Acak Avatar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor, width: 1.5),
                    backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Categorized Avatar Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilihan Avatar Beragam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Laki / Wanita / Usia',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Display all categories
                  ..._categorizedAvatars.entries.map((entry) {
                    final categoryTitle = entry.key;
                    final avatars = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xff80cbc4) : const Color(0xff304b46),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: avatars.map((item) {
                                final isSelected = _selectedAvatar == item['url'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedAvatar = item['url']!;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? primaryColor : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 26,
                                            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                            backgroundImage: NetworkImage(item['url']!),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected
                                                ? (isDark ? const Color(0xff80cbc4) : primaryColor)
                                                : (isDark ? Colors.white60 : Colors.black54),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form inputs
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: bodyTextColor),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                      prefixIcon: Icon(Icons.person, color: primaryColor),
                      filled: true,
                      fillColor: isDark ? const Color(0xff292929) : const Color(0xfff5f8f6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: bodyTextColor),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                      prefixIcon: Icon(Icons.email, color: primaryColor),
                      filled: true,
                      fillColor: isDark ? const Color(0xff292929) : const Color(0xfff5f8f6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: bodyTextColor),
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: '+62 812-xxxx-xxxx',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                      prefixIcon: Icon(Icons.phone, color: primaryColor),
                      filled: true,
                      fillColor: isDark ? const Color(0xff292929) : const Color(0xfff5f8f6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    maxLines: 2,
                    style: TextStyle(color: bodyTextColor),
                    decoration: InputDecoration(
                      labelText: 'Bio / Status',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                      prefixIcon: Icon(Icons.info_outline, color: primaryColor),
                      filled: true,
                      fillColor: isDark ? const Color(0xff292929) : const Color(0xfff5f8f6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _saveProfile,
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
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
