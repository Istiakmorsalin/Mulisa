from rest_framework import viewsets, permissions
from .models import LabReport
from .serializers import LabReportSerializer

class LabReportViewSet(viewsets.ModelViewSet):
    queryset = LabReport.objects.all().order_by("-created_at")
    serializer_class = LabReportSerializer
    permission_classes = [permissions.IsAuthenticated]
