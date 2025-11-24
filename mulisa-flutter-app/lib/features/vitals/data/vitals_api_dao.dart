import 'package:mulisa/core/network/dio_client.dart';
import 'package:mulisa/features/vitals/data/ivitals_repo.dart';

class VitalsApiDao implements IVitalsRepo {
  final DioClient _dio;
  VitalsApiDao(this._dio);

  @override
  Future<void> createVital({
    required int patientId,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    await _dio.post<void>(
      '/patients/$patientId/vitals/',
      data: body,
      requireAuth: requireAuth,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listVitals({
    required int patientId,
    DateTime? from,
    DateTime? to,
    bool requireAuth = true,
  }) async {
    final qp = <String, dynamic>{};
    if (from != null) qp['from'] = from.toUtc().toIso8601String();
    if (to != null) qp['to'] = to.toUtc().toIso8601String();

    final res = await _dio.get<Map<String, dynamic>>(  // ← Changed from List<dynamic>
      '/patients/$patientId/vitals/',
      queryParameters: qp,
      requireAuth: requireAuth,
    );

    // Extract results array from paginated response
    if (res.data != null && res.data!['results'] is List) {
      return (res.data!['results'] as List).cast<Map<String, dynamic>>();
    }

    return const [];
  }

  @override
  Future<void> updateVital({
    required int patientId,
    required int vitalId,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    await _dio.put<void>(
      '/patients/$patientId/vitals/$vitalId/',
      data: body,
      requireAuth: requireAuth,
    );
  }
}
