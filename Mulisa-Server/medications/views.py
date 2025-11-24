from rest_framework import viewsets, permissions
from .models import Medication
from .serializers import MedicationSerializer

class MedicationViewSet(viewsets.ModelViewSet):
    queryset = Medication.objects.all().order_by("-created_at")
    serializer_class = MedicationSerializer
    permission_classes = [permissions.IsAuthenticated]
