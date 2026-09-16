import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/certificate.dart';
import 'api_client.dart';

class CertificateService {
  final ApiClient _api;

  CertificateService(this._api);

  /// Mes certificats
  Future<List<Certificate>> myCertificates() async {
    try {
      final data = await _api.get(ApiConstants.myCertificates);
      final list = data['certificates'] as List? ?? data['data'] as List? ?? [];
      return list
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      ErrorHandler.log(e, st, 'CertificateService.myCertificates');
      rethrow;
    }
  }

  /// Télécharger le PDF d'un certificat
  Future<String?> getPdfUrl(String certificateId) async {
    try {
      final data = await _api.get(
        '${ApiConstants.certificates}/$certificateId/download',
      );
      return data['url'] as String?;
    } catch (e, st) {
      ErrorHandler.log(e, st, 'CertificateService.getPdfUrl');
      rethrow;
    }
  }
}