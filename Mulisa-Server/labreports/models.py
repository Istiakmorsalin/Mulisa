from django.db import models
from django.conf import settings
from patients.models import Patient

def upload_lab_report(instance, filename):
    return f"labreports/{instance.patient.id}/{filename}"

class LabReport(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name="lab_reports")
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True
    )
    report_type = models.CharField(max_length=150)
    report_date = models.DateField()
    file = models.FileField(upload_to=upload_lab_report)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.report_type} ({self.patient})"
