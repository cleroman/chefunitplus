import 'package:flutter/foundation.dart';
import '../core/errors/error_handler.dart';
import '../services/register_service.dart';

class RegisterController extends ChangeNotifier {
  final RegisterService _service;
  RegisterController(this._service);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  String? _pendingEmail;
  String? get pendingEmail => _pendingEmail;

  List<Map<String, dynamic>> _scoutGroups = [];
  List<Map<String, dynamic>> get scoutGroups => _scoutGroups;

  bool _loadingGroups = false;
  bool get isLoadingGroups => _loadingGroups;

  Future<void> loadScoutGroups() async {
    if (_loadingGroups) return;
    _loadingGroups = true;
    _error = null;
    notifyListeners();
    try {
      _scoutGroups = await _service.listScoutGroups();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'RegisterController.loadScoutGroups');
    }
    _loadingGroups = false;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String scoutGroupId,
    required String region,
    required String district,
    required String scoutFunction,
    Uint8List? photoBytes,
    String? photoFileName,
    String? bio,
    bool acceptedTerms = true,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.register(
        fullName: fullName, email: email, password: password, phone: phone,
        role: role, scoutGroupId: scoutGroupId, region: region,
        district: district, scoutFunction: scoutFunction,
        photoBytes: photoBytes, photoFileName: photoFileName,
        bio: bio, acceptedTerms: acceptedTerms,
      );
      _pendingEmail = email;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'RegisterController.register');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmail(String code) async {
    if (_pendingEmail == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final ok = await _service.verifyEmail(email: _pendingEmail!, code: code);
      _loading = false;
      notifyListeners();
      return ok;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'RegisterController.verifyEmail');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendCode() async {
    if (_pendingEmail == null) return false;
    try {
      return await _service.resendVerificationCode(_pendingEmail!);
    } catch (e, st) {
      ErrorHandler.log(e, st, 'RegisterController.resendCode');
      return false;
    }
  }

  void reset() {
    _loading = false;
    _error = null;
    _pendingEmail = null;
    _scoutGroups = [];
    notifyListeners();
  }
}