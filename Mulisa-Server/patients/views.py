from rest_framework import viewsets, permissions
from .models import Patient
from .serializers import PatientSerializer

class PatientViewSet(viewsets.ModelViewSet):
    serializer_class = PatientSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff or user.role in ("admin", "clinician"):
            return Patient.objects.all()
        return Patient.objects.filter(owner=user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
