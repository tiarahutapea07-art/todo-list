import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getAvatarImage(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return const NetworkImage("https://i.pravatar.cc/150?img=33");
  }

  // Cek apakah merupakan local file path dari kamera/galeri
  if (!avatarUrl.startsWith('http://') && !avatarUrl.startsWith('https://')) {
    final file = File(avatarUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
  }

  return NetworkImage(avatarUrl);
}
