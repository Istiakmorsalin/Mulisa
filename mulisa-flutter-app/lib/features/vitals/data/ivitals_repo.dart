abstract class IVitalsRepo {
  Future<void> createVital({
    required int patientId,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  });

  Future<List<Map<String, dynamic>>> listVitals({
    required int patientId,
    DateTime? from,
    DateTime? to,
    bool requireAuth = true,
  });

  Future<void> updateVital({
    required int patientId,
    required int vitalId,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  });
}
