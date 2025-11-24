from django.db import models
from django.conf import settings


class Patient(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="patients"
    )

    # Core
    name = models.CharField(max_length=120)
    age = models.PositiveSmallIntegerField()
    gender = models.CharField(max_length=20)
    photo_url = models.URLField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    # Contact
    contact_phone = models.CharField(max_length=32, blank=True, null=True)
    contact_email = models.EmailField(blank=True, null=True)
    contact_address = models.CharField(max_length=256, blank=True, null=True)

    # Medical Profile
    med_blood_group = models.CharField(max_length=8, blank=True, null=True)
    med_allergies = models.TextField(blank=True, null=True)
    med_history = models.TextField(blank=True, null=True)
    med_current_meds = models.TextField(blank=True, null=True)

    # Emergency Contact
    emc_name = models.CharField(max_length=120, blank=True, null=True)
    emc_phone = models.CharField(max_length=32, blank=True, null=True)
    emc_relationship = models.CharField(max_length=64, blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['name']  # Add this line

    def __str__(self):
        return f"{self.name} ({self.gender})"


class Vital(models.Model):
    patient = models.ForeignKey(
        Patient,
        on_delete=models.CASCADE,
        related_name="vitals"
    )

    heart_rate = models.PositiveSmallIntegerField(blank=True, null=True)   # bpm
    bp_sys = models.PositiveSmallIntegerField(blank=True, null=True)       # systolic
    bp_dia = models.PositiveSmallIntegerField(blank=True, null=True)       # diastolic
    height_cm = models.FloatField(blank=True, null=True)
    weight_kg = models.FloatField(blank=True, null=True)
    temperature_c = models.FloatField(blank=True, null=True)
    spo2 = models.FloatField(blank=True, null=True)
    respiratory_rate = models.PositiveSmallIntegerField(blank=True, null=True)

    recorded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-recorded_at"]

    def __str__(self):
        return f"Vitals for {self.patient.name} on {self.recorded_at.strftime('%Y-%m-%d %H:%M')}"