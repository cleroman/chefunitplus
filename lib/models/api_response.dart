// =============================================================
// ChefUnitPlus - Wrapper gnrique de rponse API
// Standardise toutes les rponses du backend
// =============================================================


class ApiResponse<T> {
  /// true si l'appel s'est bien pass
  final bool success;

  /// Message lisible (optionnel)
  final String? message;

  /// Donnes types (T = User, List<Formation>, ...)
  final T? data;

  /// Code HTTP brut (optionnel)
  final int? statusCode;

  /// Erreurs additionnelles (validation, dtails)
  final Map<String, dynamic>? errors;

  /// Pagination (optionnel)
  final int? page;
  final int? totalPages;
  final int? totalItems;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
    this.page,
    this.totalPages,
    this.totalItems,
  });

  // ===========================================================
  // Y FACTORIES
  // ===========================================================
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    int? page,
    int? totalPages,
    int? totalItems,
  }) =>
      ApiResponse(
        success: true,
        data: data,
        message: message,
        statusCode: statusCode,
        page: page,
        totalPages: totalPages,
        totalItems: totalItems,
      );

  factory ApiResponse.failure({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) =>
      ApiResponse(
        success: false,
        message: message,
        statusCode: statusCode,
        errors: errors,
      );

  /// Construit une rponse gnrique depuis un JSON et un parser
  /// (le parser est fourni par le service appelant)
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic raw)? parser,
  }) {
    final ok = json['success'] == true ||
        json['status'] == '0' ||
        (json['statusCode'] is int && json['statusCode'] < 400);

    return ApiResponse(
      success: ok,
      message: json['message'],
      statusCode: json['statusCode'],
      errors: json['errors'] as Map<String, dynamic>?,
      data: parser != null && json['data'] != null
          ? parser(json['data'])
          : json['data'] as T?,
      page: json['page'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
    );
  }

  // ===========================================================
  // Y" S?RIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'success': success,
        if (message != null) 'message': message,
        if (data != null) 'data': data,
        if (statusCode != null) 'statusCode': statusCode,
        if (errors != null) 'errors': errors,
        if (page != null) 'page': page,
        if (totalPages != null) 'totalPages': totalPages,
        if (totalItems != null) 'totalItems': totalItems,
      };

  // ===========================================================
  // Y"< COPYWITH
  // ===========================================================
  ApiResponse<T> copyWith({
    bool? success,
    String? message,
    T? data,
    int? statusCode,
    Map<String, dynamic>? errors,
    int? page,
    int? totalPages,
    int? totalItems,
  }) {
    return ApiResponse<T>(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      errors: errors ?? this.errors,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  // ===========================================================
  // Y" GETTERS
  // ===========================================================
  bool get isFailure => !success;
  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasPagination => page != null && totalPages != null;

  /// Indique s'il reste des pages  charger
  bool get hasMore =>
      page != null && totalPages != null && page! < totalPages!;

  // ===========================================================
  // Y TRANSFORMATION
  // ===========================================================
  /// Applique une transformation sur les donnes
  ApiResponse<R> map<R>(R Function(T data) transform) {
    if (!success || data == null) {
      return ApiResponse<R>.failure(
        message: message,
        statusCode: statusCode,
        errors: errors,
      );
    }
    return ApiResponse<R>.success(
      data: transform(data as T),
      message: message,
      statusCode: statusCode,
      page: page,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }

  // ===========================================================
  // Y AFFICHAGE
  // ===========================================================
  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, hasData: $hasData)';
}