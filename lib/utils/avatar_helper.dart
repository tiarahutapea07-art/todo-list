import 'dart:io';
import 'package:flutter/material.dart';

const List<Map<String, String>> kDiverseAvatarPresets = [
  {'id': 'avatar:dimas', 'name': 'Dimas', 'group': 'Laki-laki Muda'},
  {'id': 'avatar:siti', 'name': 'Siti', 'group': 'Wanita Muda'},
  {'id': 'avatar:budi', 'name': 'Budi', 'group': 'Laki-laki Dewasa'},
  {'id': 'avatar:maya', 'name': 'Maya', 'group': 'Wanita Dewasa'},
  {'id': 'avatar:hendra', 'name': 'Hendra', 'group': 'Laki-laki Lansia'},
  {'id': 'avatar:sri', 'name': 'Sri', 'group': 'Wanita Lansia'},
];

String normalizeAvatarId(String? avatarUrl) {
  if (avatarUrl == null ||
      avatarUrl.isEmpty ||
      avatarUrl == 'illustrated_default' ||
      avatarUrl == 'https://i.pravatar.cc/150?img=12' ||
      avatarUrl == 'https://i.pravatar.cc/150?img=3' ||
      avatarUrl == 'https://i.pravatar.cc/150?img=33') {
    return 'avatar:dimas';
  }
  return avatarUrl;
}

ImageProvider getAvatarImage(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return const NetworkImage('https://i.pravatar.cc/150?img=33');
  }
  if (!avatarUrl.startsWith('http://') && !avatarUrl.startsWith('https://')) {
    final file = File(avatarUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
  }
  return NetworkImage(avatarUrl);
}

/// Widget avatar utama untuk Home, Profile, dan Edit Profile.
/// Mendukung 6 karakter ilustrasi beragam, foto kamera/galeri lokal, dan URL internet.
Widget buildUserAvatar({
  required String? avatarUrl,
  required double radius,
  Color? backgroundColor,
}) {
  final diameter = radius * 2;
  final resolved = normalizeAvatarId(avatarUrl);

  Widget presetWidget(String presetId) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        size: Size(diameter, diameter),
        painter: _DiverseAvatarPainter(presetId: presetId),
      ),
    );
  }

  if (resolved.startsWith('avatar:')) {
    return ClipOval(child: presetWidget(resolved));
  }

  if (!resolved.startsWith('http://') && !resolved.startsWith('https://')) {
    final file = File(resolved);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => presetWidget('avatar:dimas'),
        ),
      );
    }
    return ClipOval(child: presetWidget('avatar:dimas'));
  }

  return ClipOval(
    child: SizedBox(
      width: diameter,
      height: diameter,
      child: Image.network(
        resolved,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return presetWidget('avatar:dimas');
        },
        errorBuilder: (_, __, ___) => presetWidget('avatar:dimas'),
      ),
    ),
  );
}

class _DiverseAvatarPainter extends CustomPainter {
  final String presetId;
  const _DiverseAvatarPainter({required this.presetId});

  Color get _bgColor {
    switch (presetId) {
      case 'avatar:siti':
        return const Color(0xfff5e2d0);
      case 'avatar:budi':
        return const Color(0xffcbe0cf);
      case 'avatar:maya':
        return const Color(0xffe4c6c4);
      case 'avatar:hendra':
        return const Color(0xffb7c8ca);
      case 'avatar:sri':
        return const Color(0xffe6dcf0);
      case 'avatar:dimas':
      default:
        return const Color(0xffdae5e0);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Latar lingkaran
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _bgColor);

    switch (presetId) {
      case 'avatar:siti':
        _paintSiti(canvas, w, h);
        break;
      case 'avatar:budi':
        _paintBudi(canvas, w, h);
        break;
      case 'avatar:maya':
        _paintMaya(canvas, w, h);
        break;
      case 'avatar:hendra':
        _paintHendra(canvas, w, h);
        break;
      case 'avatar:sri':
        _paintSri(canvas, w, h);
        break;
      case 'avatar:dimas':
      default:
        _paintDimas(canvas, w, h);
        break;
    }
  }

  // 1. DIMAS — Laki-laki Muda
  void _paintDimas(Canvas canvas, double w, double h) {
    final shirt = Paint()..color = const Color(0xff25353a);
    final neck = Paint()..color = const Color(0xffe9a985);
    final skin = Paint()..color = const Color(0xfff6be9a);
    final hair = Paint()..color = const Color(0xff2f2623);

    // Kaos gelap
    final shirtPath = Path()
      ..moveTo(w * 0.14, h * 1.02)
      ..quadraticBezierTo(w * 0.21, h * 0.77, w * 0.40, h * 0.75)
      ..lineTo(w * 0.60, h * 0.75)
      ..quadraticBezierTo(w * 0.79, h * 0.77, w * 0.86, h * 1.02)
      ..close();
    canvas.drawPath(shirtPath, shirt);

    // Leher & kerah bulat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.41, h * 0.61, w * 0.18, h * 0.19),
        Radius.circular(w * 0.06),
      ),
      neck,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.76), width: w * 0.22, height: h * 0.11),
      0,
      3.14159,
      true,
      skin,
    );

    // Telinga & wajah
    _drawEarsAndFace(canvas, w, h, skin, neck);

    // Rambut belah samping rapi
    final hairPath = Path()
      ..moveTo(w * 0.29, h * 0.46)
      ..quadraticBezierTo(w * 0.26, h * 0.23, w * 0.43, h * 0.17)
      ..quadraticBezierTo(w * 0.54, h * 0.14, w * 0.65, h * 0.21)
      ..quadraticBezierTo(w * 0.75, h * 0.27, w * 0.71, h * 0.46)
      ..quadraticBezierTo(w * 0.69, h * 0.33, w * 0.61, h * 0.30)
      ..quadraticBezierTo(w * 0.46, h * 0.27, w * 0.35, h * 0.32)
      ..quadraticBezierTo(w * 0.31, h * 0.36, w * 0.29, h * 0.46)
      ..close();
    canvas.drawPath(hairPath, hair);

    _drawFacialFeatures(
      canvas,
      w,
      h,
      browColor: const Color(0xff2f2623),
      openSmile: false,
    );
  }

  // 2. SITI — Wanita Muda Berhijab
  void _paintSiti(Canvas canvas, double w, double h) {
    final tunic = Paint()..color = const Color(0xff9bb5a3);
    final hijab = Paint()..color = const Color(0xff2c4d45);
    final hijabFold = Paint()
      ..color = const Color(0xff1e3832)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016
      ..strokeCap = StrokeCap.round;
    final skin = Paint()..color = const Color(0xfff6be9b);

    // Baju sage muda
    final tunicPath = Path()
      ..moveTo(w * 0.13, h * 1.02)
      ..quadraticBezierTo(w * 0.20, h * 0.76, w * 0.39, h * 0.73)
      ..lineTo(w * 0.61, h * 0.73)
      ..quadraticBezierTo(w * 0.80, h * 0.76, w * 0.87, h * 1.02)
      ..close();
    canvas.drawPath(tunicPath, tunic);

    // Kerudung luar membungkus kepala hingga bahu
    final hijabOuter = Path()
      ..moveTo(w * 0.24, h * 0.76)
      ..quadraticBezierTo(w * 0.24, h * 0.46, w * 0.28, h * 0.31)
      ..quadraticBezierTo(w * 0.34, h * 0.16, w * 0.50, h * 0.16)
      ..quadraticBezierTo(w * 0.66, h * 0.16, w * 0.72, h * 0.31)
      ..quadraticBezierTo(w * 0.76, h * 0.46, w * 0.76, h * 0.76)
      ..quadraticBezierTo(w * 0.64, h * 0.86, w * 0.50, h * 0.85)
      ..quadraticBezierTo(w * 0.36, h * 0.86, w * 0.24, h * 0.76)
      ..close();
    canvas.drawPath(hijabOuter, hijab);

    // Ciput dalam tipis
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.37, height: h * 0.44),
      Paint()..color = const Color(0xff233e38),
    );

    // Wajah oval lembut
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.48), width: w * 0.34, height: h * 0.39),
      skin,
    );

    // Lipatan kain hijab di bawah dagu
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.69), width: w * 0.36, height: h * 0.14),
      0.2,
      2.7,
      false,
      hijabFold,
    );

    // Rona pipi halus
    final blush = Paint()..color = const Color(0xffeb9b86).withValues(alpha: 0.45);
    canvas.drawCircle(Offset(w * 0.39, h * 0.53), w * 0.032, blush);
    canvas.drawCircle(Offset(w * 0.61, h * 0.53), w * 0.032, blush);

    _drawFacialFeatures(
      canvas,
      w,
      h,
      browColor: const Color(0xff3b2c27),
      openSmile: true,
    );
  }

  // 3. BUDI — Laki-laki Dewasa Berkacamata
  void _paintBudi(Canvas canvas, double w, double h) {
    final shirt = Paint()..color = const Color(0xff365350);
    final collar = Paint()..color = const Color(0xff273f3c);
    final neck = Paint()..color = const Color(0xffe7a783);
    final skin = Paint()..color = const Color(0xfff4bc98);
    final hair = Paint()..color = const Color(0xff2d2928);

    // Kemeja hijau tua
    final shirtPath = Path()
      ..moveTo(w * 0.13, h * 1.02)
      ..quadraticBezierTo(w * 0.20, h * 0.76, w * 0.40, h * 0.74)
      ..lineTo(w * 0.60, h * 0.74)
      ..quadraticBezierTo(w * 0.80, h * 0.76, w * 0.87, h * 1.02)
      ..close();
    canvas.drawPath(shirtPath, shirt);

    // Leher
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.41, h * 0.61, w * 0.18, h * 0.19),
        Radius.circular(w * 0.05),
      ),
      neck,
    );

    // Kerah kemeja V
    final leftCollar = Path()
      ..moveTo(w * 0.38, h * 0.73)
      ..lineTo(w * 0.49, h * 0.85)
      ..lineTo(w * 0.43, h * 0.88)
      ..lineTo(w * 0.34, h * 0.77)
      ..close();
    final rightCollar = Path()
      ..moveTo(w * 0.62, h * 0.73)
      ..lineTo(w * 0.51, h * 0.85)
      ..lineTo(w * 0.57, h * 0.88)
      ..lineTo(w * 0.66, h * 0.77)
      ..close();
    canvas.drawPath(leftCollar, collar);
    canvas.drawPath(rightCollar, collar);

    _drawEarsAndFace(canvas, w, h, skin, neck);

    // Rambut dewasa rapi dengan sedikit aksen uban tipis di pelipis
    final hairPath = Path()
      ..moveTo(w * 0.29, h * 0.46)
      ..quadraticBezierTo(w * 0.27, h * 0.23, w * 0.44, h * 0.18)
      ..quadraticBezierTo(w * 0.58, h * 0.16, w * 0.68, h * 0.23)
      ..quadraticBezierTo(w * 0.74, h * 0.30, w * 0.71, h * 0.46)
      ..quadraticBezierTo(w * 0.69, h * 0.33, w * 0.60, h * 0.30)
      ..quadraticBezierTo(w * 0.45, h * 0.28, w * 0.34, h * 0.33)
      ..quadraticBezierTo(w * 0.31, h * 0.36, w * 0.29, h * 0.46)
      ..close();
    canvas.drawPath(hairPath, hair);

    _drawFacialFeatures(
      canvas,
      w,
      h,
      browColor: const Color(0xff2d2928),
      openSmile: false,
      slightLaughLines: true,
    );
    _drawGlasses(canvas, w, h, const Color(0xff262221));
  }

  // 4. MAYA — Wanita Dewasa Rambut Bergelombang & Kacamata
  void _paintMaya(Canvas canvas, double w, double h) {
    final hairBack = Paint()..color = const Color(0xff4a3227);
    final blouse = Paint()..color = const Color(0xff385958);
    final innerTop = Paint()..color = const Color(0xfff2f4f3);
    final neck = Paint()..color = const Color(0xffe8a986);
    final skin = Paint()..color = const Color(0xfff6c09d);

    // Rambut belakang bergelombang sebahu
    final backHairPath = Path()
      ..moveTo(w * 0.20, h * 0.74)
      ..quadraticBezierTo(w * 0.16, h * 0.58, w * 0.22, h * 0.42)
      ..quadraticBezierTo(w * 0.24, h * 0.20, w * 0.50, h * 0.18)
      ..quadraticBezierTo(w * 0.76, h * 0.20, w * 0.78, h * 0.42)
      ..quadraticBezierTo(w * 0.84, h * 0.58, w * 0.80, h * 0.74)
      ..quadraticBezierTo(w * 0.66, h * 0.80, w * 0.50, h * 0.79)
      ..quadraticBezierTo(w * 0.34, h * 0.80, w * 0.20, h * 0.74)
      ..close();
    canvas.drawPath(backHairPath, hairBack);

    // Blazer / blus teal & inner putih V
    final blousePath = Path()
      ..moveTo(w * 0.15, h * 1.02)
      ..quadraticBezierTo(w * 0.21, h * 0.77, w * 0.39, h * 0.74)
      ..lineTo(w * 0.61, h * 0.74)
      ..quadraticBezierTo(w * 0.79, h * 0.77, w * 0.85, h * 1.02)
      ..close();
    canvas.drawPath(blousePath, blouse);

    final innerV = Path()
      ..moveTo(w * 0.39, h * 0.75)
      ..lineTo(w * 0.50, h * 0.96)
      ..lineTo(w * 0.61, h * 0.75)
      ..close();
    canvas.drawPath(innerV, innerTop);

    // Leher
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.61, w * 0.16, h * 0.19),
        Radius.circular(w * 0.05),
      ),
      neck,
    );

    _drawEarsAndFace(canvas, w, h, skin, neck);

    // Anting mutiara kecil
    canvas.drawCircle(Offset(w * 0.30, h * 0.54), w * 0.015, Paint()..color = Colors.white);

    // Poni miring lembut
    final frontHair = Path()
      ..moveTo(w * 0.28, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.22, w * 0.50, h * 0.20)
      ..quadraticBezierTo(w * 0.72, h * 0.22, w * 0.72, h * 0.45)
      ..quadraticBezierTo(w * 0.67, h * 0.33, w * 0.53, h * 0.29)
      ..quadraticBezierTo(w * 0.38, h * 0.31, w * 0.28, h * 0.45)
      ..close();
    canvas.drawPath(frontHair, hairBack);

    _drawFacialFeatures(
      canvas,
      w,
      h,
      browColor: const Color(0xff4a3227),
      openSmile: false,
      lipTint: const Color(0xffc97064),
    );
    _drawGlasses(canvas, w, h, const Color(0xff3b2620));
  }

  // 5. HENDRA — Laki-laki Tua / Lansia Berambut & Berjenggot Putih
  void _paintHendra(Canvas canvas, double w, double h) {
    final shirt = Paint()..color = const Color(0xff435847);
    final collar = Paint()..color = const Color(0xff314234);
    final neck = Paint()..color = const Color(0xffe5a480);
    final skin = Paint()..color = const Color(0xfff4bb97);
    final whiteHair = Paint()..color = const Color(0xffeceeed);
    final silverShade = Paint()..color = const Color(0xffd7dcda);

    // Kemeja hijau olive tua
    final shirtPath = Path()
      ..moveTo(w * 0.13, h * 1.02)
      ..quadraticBezierTo(w * 0.20, h * 0.76, w * 0.40, h * 0.74)
      ..lineTo(w * 0.60, h * 0.74)
      ..quadraticBezierTo(w * 0.80, h * 0.76, w * 0.87, h * 1.02)
      ..close();
    canvas.drawPath(shirtPath, shirt);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.41, h * 0.62, w * 0.18, h * 0.19),
        Radius.circular(w * 0.05),
      ),
      neck,
    );

    final leftCollar = Path()
      ..moveTo(w * 0.38, h * 0.73)
      ..lineTo(w * 0.49, h * 0.85)
      ..lineTo(w * 0.42, h * 0.88)
      ..lineTo(w * 0.34, h * 0.77)
      ..close();
    final rightCollar = Path()
      ..moveTo(w * 0.62, h * 0.73)
      ..lineTo(w * 0.51, h * 0.85)
      ..lineTo(w * 0.58, h * 0.88)
      ..lineTo(w * 0.66, h * 0.77)
      ..close();
    canvas.drawPath(leftCollar, collar);
    canvas.drawPath(rightCollar, collar);

    _drawEarsAndFace(canvas, w, h, skin, neck);

    // Rambut putih perak rapi
    final hairPath = Path()
      ..moveTo(w * 0.29, h * 0.46)
      ..quadraticBezierTo(w * 0.26, h * 0.23, w * 0.43, h * 0.18)
      ..quadraticBezierTo(w * 0.58, h * 0.16, w * 0.68, h * 0.23)
      ..quadraticBezierTo(w * 0.74, h * 0.30, w * 0.71, h * 0.46)
      ..quadraticBezierTo(w * 0.69, h * 0.33, w * 0.60, h * 0.29)
      ..quadraticBezierTo(w * 0.45, h * 0.27, w * 0.35, h * 0.32)
      ..quadraticBezierTo(w * 0.31, h * 0.36, w * 0.29, h * 0.46)
      ..close();
    canvas.drawPath(hairPath, whiteHair);

    // Jenggot & kumis putih rapi
    final beardPath = Path()
      ..moveTo(w * 0.31, h * 0.52)
      ..quadraticBezierTo(w * 0.31, h * 0.70, w * 0.50, h * 0.71)
      ..quadraticBezierTo(w * 0.69, h * 0.70, w * 0.69, h * 0.52)
      ..lineTo(w * 0.65, h * 0.52)
      ..quadraticBezierTo(w * 0.64, h * 0.63, w * 0.50, h * 0.64)
      ..quadraticBezierTo(w * 0.36, h * 0.63, w * 0.35, h * 0.52)
      ..close();
    canvas.drawPath(beardPath, whiteHair);

    // Kumis putih
    final moustache = Path()
      ..moveTo(w * 0.39, h * 0.585)
      ..quadraticBezierTo(w * 0.50, h * 0.545, w * 0.61, h * 0.585)
      ..quadraticBezierTo(w * 0.55, h * 0.61, w * 0.50, h * 0.595)
      ..quadraticBezierTo(w * 0.45, h * 0.61, w * 0.39, h * 0.585)
      ..close();
    canvas.drawPath(moustache, silverShade);

    // Garis kerutan dahi halus
    final wrinkle = Paint()
      ..color = const Color(0xffd99c78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.011
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.42, h * 0.36), Offset(w * 0.58, h * 0.36), wrinkle);

    _drawFacialFeatures(
      canvas,
      w,
      h,
      browColor: const Color(0xffeceeed),
      openSmile: false,
      slightLaughLines: true,
    );
  }

  // 6. SRI — Wanita Tua / Nenek Berhijab Ramah
  void _paintSri(Canvas canvas, double w, double h) {
    final hijab = Paint()..color = const Color(0xff2e4a49);
    final hijabFold = Paint()
      ..color = const Color(0xff1e3433)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016
      ..strokeCap = StrokeCap.round;
    final silverHair = Paint()..color = const Color(0xffe7e9e8);
    final skin = Paint()..color = const Color(0xfff4bc99);

    // Kerudung lebar menutup bahu
    final drape = Path()
      ..moveTo(w * 0.14, h * 1.02)
      ..quadraticBezierTo(w * 0.18, h * 0.75, w * 0.26, h * 0.66)
      ..quadraticBezierTo(w * 0.23, h * 0.42, w * 0.30, h * 0.27)
      ..quadraticBezierTo(w * 0.37, h * 0.16, w * 0.50, h * 0.16)
      ..quadraticBezierTo(w * 0.63, h * 0.16, w * 0.70, h * 0.27)
      ..quadraticBezierTo(w * 0.77, h * 0.42, w * 0.74, h * 0.66)
      ..quadraticBezierTo(w * 0.82, h * 0.75, w * 0.86, h * 1.02)
      ..close();
    canvas.drawPath(drape, hijab);

    // Rambut perak terlihat sedikit di bawah kerudung bagian dahi
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.36, height: h * 0.42),
      silverHair,
    );

    // Wajah oval hangat
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.49), width: w * 0.34, height: h * 0.37),
      skin,
    );

    // Belahan rambut perak halus di dahi atas
    final silverBangs = Path()
      ..moveTo(w * 0.33, h * 0.42)
      ..quadraticBezierTo(w * 0.40, h * 0.29, w * 0.50, h * 0.33)
      ..quadraticBezierTo(w * 0.60, h * 0.29, w * 0.67, h * 0.42)
      ..quadraticBezierTo(w * 0.62, h * 0.25, w * 0.50, h * 0.25)
      ..quadraticBezierTo(w * 0.38, h * 0.25, w * 0.33, h * 0.42)
      ..close();
    canvas.drawPath(silverBangs, silverHair);

    // Lipatan kerudung
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.71), width: w * 0.42, height: h * 0.16),
      0.2,
      2.7,
      false,
      hijabFold,
    );

    _drawFacialFeatures(
      canvas,
      w,
      h,
      browColor: const Color(0xffb5b8b7),
      openSmile: false,
      slightLaughLines: true,
    );
  }

  // ---------- Helper bentuk wajah & fitur ----------
  void _drawEarsAndFace(
    Canvas canvas,
    double w,
    double h,
    Paint skin,
    Paint earPaint,
  ) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.29, h * 0.49), width: w * 0.08, height: h * 0.11),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.71, h * 0.49), width: w * 0.08, height: h * 0.11),
      earPaint,
    );
    final faceRect = Rect.fromLTWH(w * 0.30, h * 0.26, w * 0.40, h * 0.43);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        faceRect,
        topLeft: Radius.circular(w * 0.18),
        topRight: Radius.circular(w * 0.18),
        bottomLeft: Radius.circular(w * 0.20),
        bottomRight: Radius.circular(w * 0.20),
      ),
      skin,
    );
  }

  void _drawFacialFeatures(
    Canvas canvas,
    double w,
    double h, {
    required Color browColor,
    required bool openSmile,
    bool slightLaughLines = false,
    Color? lipTint,
  }) {
    final browPaint = Paint()
      ..color = browColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.020
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.41, h * 0.43), width: w * 0.085, height: h * 0.03),
      3.4,
      2.6,
      false,
      browPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.59, h * 0.43), width: w * 0.085, height: h * 0.03),
      3.4,
      2.6,
      false,
      browPaint,
    );

    final eyeFill = Paint()..color = const Color(0xff261e1b);
    canvas.drawCircle(Offset(w * 0.41, h * 0.475), w * 0.017, eyeFill);
    canvas.drawCircle(Offset(w * 0.59, h * 0.475), w * 0.017, eyeFill);

    final nosePaint = Paint()
      ..color = const Color(0xffd69572)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    final nosePath = Path()
      ..moveTo(w * 0.50, h * 0.475)
      ..lineTo(w * 0.49, h * 0.538)
      ..quadraticBezierTo(w * 0.50, h * 0.552, w * 0.52, h * 0.542);
    canvas.drawPath(nosePath, nosePaint);

    if (slightLaughLines) {
      final linePaint = Paint()
        ..color = const Color(0xffd99975)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.011
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(w * 0.39, h * 0.58), width: w * 0.05, height: h * 0.07),
        4.2,
        1.7,
        false,
        linePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(w * 0.61, h * 0.58), width: w * 0.05, height: h * 0.07),
        0.3,
        1.7,
        false,
        linePaint,
      );
    }

    if (openSmile) {
      final mouthBg = Paint()..color = const Color(0xffb56555);
      final teeth = Paint()..color = Colors.white;
      final smileRect = Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.575),
        width: w * 0.11,
        height: h * 0.065,
      );
      canvas.drawArc(smileRect, 0, 3.14159, true, mouthBg);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.575), width: w * 0.09, height: h * 0.035),
        0,
        3.14159,
        true,
        teeth,
      );
    } else {
      final smilePaint = Paint()
        ..color = lipTint ?? const Color(0xffba7357)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.017
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.575), width: w * 0.115, height: h * 0.055),
        0.2,
        2.74,
        false,
        smilePaint,
      );
    }
  }

  void _drawGlasses(Canvas canvas, double w, double h, Color frameColor) {
    final g = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.017;

    final leftLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.41, h * 0.478), width: w * 0.13, height: h * 0.082),
      Radius.circular(w * 0.022),
    );
    final rightLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.59, h * 0.478), width: w * 0.13, height: h * 0.082),
      Radius.circular(w * 0.022),
    );
    canvas.drawRRect(leftLens, g);
    canvas.drawRRect(rightLens, g);
    canvas.drawLine(Offset(w * 0.475, h * 0.472), Offset(w * 0.525, h * 0.472), g);
    canvas.drawLine(Offset(w * 0.30, h * 0.475), Offset(w * 0.345, h * 0.475), g);
    canvas.drawLine(Offset(w * 0.655, h * 0.475), Offset(w * 0.70, h * 0.475), g);
  }

  @override
  bool shouldRepaint(covariant _DiverseAvatarPainter oldDelegate) =>
      oldDelegate.presetId != presetId;
}
