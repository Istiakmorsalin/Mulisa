from django.utils.dateparse import parse_datetime
from rest_framework import generics, permissions
from rest_framework.exceptions import NotFound
from rest_framework.response import Response

from .models import Patient, Vital
from .serializers import VitalSerializer
from .permissions import IsOwnerOrStaff


# --- Helper: fetch patient safely ---
def _get_patient_or_404(patient_id: int) -> Patient:
    try:
        return Patient.objects.get(pk=patient_id)
    except Patient.DoesNotExist:
        raise NotFound("Patient not found.")


# --- Mixin to scope vitals to a patient ---
class PatientScopedMixin:
    def get_patient(self) -> Patient:
        return _get_patient_or_404(self.kwargs["patient_id"])

    def get_queryset(self):
        patient = self.get_patient()
        return Vital.objects.filter(patient=patient)


# ==========================================================
#               VITALS CRUD + LATEST ENDPOINTS
# ==========================================================

class PatientVitalListCreateView(PatientScopedMixin, generics.ListCreateAPIView):
    """
    GET  /api/patients/<patient_id>/vitals/?from=ISO&to=ISO
        → List all vitals for the given patient (optionally date-filtered)
    POST /api/patients/<patient_id>/vitals/
        → Add a new vital record for that patient
    """
    serializer_class = VitalSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrStaff]

    def get(self, request, *args, **kwargs):
        qs = self.get_queryset()
        # Optional ?from & ?to query params for date filtering
        from_str = request.query_params.get("from")
        to_str = request.query_params.get("to")

        if from_str:
            dt = parse_datetime(from_str)
            if dt:
                qs = qs.filter(recorded_at__gte=dt)
        if to_str:
            dt = parse_datetime(to_str)
            if dt:
                qs = qs.filter(recorded_at__lte=dt)

        self.queryset = qs
        return super().get(request, *args, **kwargs)

    def perform_create(self, serializer):
        patient = self.get_patient()
        serializer.save(patient=patient)


class PatientVitalDetailView(PatientScopedMixin, generics.RetrieveUpdateDestroyAPIView):
    """
    GET     /api/patients/<patient_id>/vitals/<vital_id>/
    PATCH   /api/patients/<patient_id>/vitals/<vital_id>/
    DELETE  /api/patients/<patient_id>/vitals/<vital_id>/
    """
    serializer_class = VitalSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrStaff]
    lookup_url_kwarg = "vital_id"

    def get_object(self):
        patient = self.get_patient()
        try:
            obj = Vital.objects.get(pk=self.kwargs["vital_id"], patient=patient)
        except Vital.DoesNotExist:
            raise NotFound("Vital record not found for this patient.")
        self.check_object_permissions(self.request, obj)
        return obj


class PatientVitalLatestView(PatientScopedMixin, generics.RetrieveAPIView):
    """
    GET /api/patients/<patient_id>/vitals/latest/
        → Fetch the most recent vitals record for that patient
    """
    serializer_class = VitalSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrStaff]

    def get_object(self):
        patient = self.get_patient()
        obj = Vital.objects.filter(patient=patient).order_by("-recorded_at").first()
        if not obj:
            raise NotFound("No vitals recorded yet for this patient.")
        self.check_object_permissions(self.request, obj)
        return obj
