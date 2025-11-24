import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/patient.dart';
import 'ipatient_repo.dart';

class PatientApiDao implements IPatientRepo {
  final DioClient _client;
  PatientApiDao(this._client);

  // GET /patients/  (handles DRF pagination and plain lists)
  Future<List<Patient>> getAll() async {
    final List<Patient> all = [];
    String? url = '/patients/';

    while (url != null) {
      final Response res = await _client.get(
        url,
        requireAuth: true,
        // If you need page-size, pass queryParameters: {'page': 1, 'page_size': 50}
      );

      final data = res.data;
      if (data is Map<String, dynamic> && data.containsKey('results')) {
        final List results = data['results'] as List? ?? [];
        all.addAll(results.map((e) => Patient.fromJson(e as Map<String, dynamic>)));
        final next = data['next'];
        // If your API returns absolute URLs for next, keep them as-is.
        // Dio will accept absolute or relative. If you prefer relative, convert here.
        url = (next is String && next.isNotEmpty) ? next : null;
      } else if (data is List) {
        all.addAll(data.map((e) => Patient.fromJson(e as Map<String, dynamic>)));
        url = null;
      } else {
        // unexpected shape
        url = null;
      }
    }

    return all;
  }

  // POST /patients/
  Future<Patient> add(Patient p) async {
    final payload = p.toJson();
    final res = await _client.post(
      '/patients/',
      data: payload,
      requireAuth: true,
    );
    return Patient.fromJson(res.data as Map<String, dynamic>);
  }

  // PUT /patients/{id}/
  Future<Patient> update(Patient p) async {
    final id = p.id ?? int.tryParse('${p.externalId ?? ''}');
    if (id == null) {
      throw ArgumentError('update() requires a numeric id on Patient');
    }
    final res = await _client.put(
      '/patients/$id/',
      data: p.toJson(),
      requireAuth: true,
    );
    return Patient.fromJson(res.data as Map<String, dynamic>);
  }

  // DELETE /patients/{id}/
  Future<void> delete(int id) async {
    await _client.delete(
      '/patients/$id/',
      requireAuth: true,
    );
  }
}
