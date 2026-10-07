// =====================================================================
//  UserAvatar - Widget réutilisable pour afficher la photo de profil
//  Généré automatiquement par diagnostic_photo_chefunitplus.ps1
// =====================================================================
//  Utilisation :
//    UserAvatar(photoUrl: user.photoUrl, radius: 20)
//    UserAvatar(photoBase64: user.photoBase64, radius: 20)
//    UserAvatar(photoBytes: bytes, radius: 20)
//    UserAvatar(initials: 'JD', radius: 20)  // fallback
// =====================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  /// URL http(s) de la photo (backend)
  final String? photoUrl;

  /// Photo encodée en base64 (backend ou stockage local)
  final String? photoBase64;

  /// Photo en bytes (mémoire, ex: après image_picker)
  final Uint8List? photoBytes;

  /// Rayon de l'avatar (défaut 20)
  final double radius;

  /// Initiales de secours si aucune photo (ex: "JD")
  final String? initials;

  /// Couleur de fond si pas de photo
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.photoBase64,
    this.photoBytes,
    this.radius = 20,
    this.initials,
    this.backgroundColor,
  });

  Uint8List? _resolveBytes() {
    if (photoBytes != null && photoBytes!.isNotEmpty) return photoBytes;
    if (photoBase64 != null && photoBase64!.trim().isNotEmpty) {
      try {
        return base64Decode(photoBase64!.trim());
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _resolveBytes();

    ImageProvider? imageProvider;
    if (bytes != null) {
      imageProvider = MemoryImage(bytes);
    } else if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      imageProvider = NetworkImage(photoUrl!.trim());
    }

    final fallbackText = (initials != null && initials!.trim().isNotEmpty)
        ? initials!.trim().toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              fallbackText,
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
