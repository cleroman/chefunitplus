// =============================================================
// ChefUnitPlus - PermissionService
// Gestion des permissions camera + galerie
// =============================================================

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // ============================================================
  // DEMANDER LA PERMISSION CAMERA
  // ============================================================
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // ============================================================
  // DEMANDER LA PERMISSION GALERIE
  // ============================================================
  static Future<bool> requestPhotos() async {
    // Android 13+
    if (await Permission.photos.isGranted) return true;
    if (await Permission.photos.request().isGranted) return true;

    // Android 12-
    if (await Permission.storage.isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;

    return false;
  }

  // ============================================================
  // VERIFIER TOUTES LES PERMISSIONS
  // ============================================================
  static Future<bool> requestAll() async {
    final camera = await requestCamera();
    final photos = await requestPhotos();
    return camera || photos;
  }

  // ============================================================
  // OUVRIR LES PARAMETRES DE L'APP
  // ============================================================
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}