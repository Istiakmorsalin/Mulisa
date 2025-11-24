# appointments/models.py
from django.db import models
from django.contrib.auth.models import User
from patients.models import Patient


class Provider(models.Model):
    """Healthcare provider/doctor model"""
    name = models.CharField(max_length=200)
    specialty = models.CharField(max_length=200)
    phone = models.CharField(max_length=20, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    bio = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Dr. {self.name}"
    
    class Meta:
        ordering = ['name']


class Location(models.Model):
    """Medical facility location model"""
    name = models.CharField(max_length=200)
    address = models.CharField(max_length=255)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=2)
    zip_code = models.CharField(max_length=10)
    phone = models.CharField(max_length=20, blank=True, null=True)
    
    # Link locations to providers (many-to-many)
    providers = models.ManyToManyField(Provider, related_name='locations', blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        ordering = ['name']


class AppointmentType(models.Model):
    """Type of appointment (checkup, consultation, etc.)"""
    name = models.CharField(max_length=200)
    duration_minutes = models.IntegerField(default=30)
    allow_patient_booking = models.BooleanField(default=True)
    buffer_before_min = models.IntegerField(
        default=0, 
        help_text="Buffer time before appointment in minutes"
    )
    buffer_after_min = models.IntegerField(
        default=0, 
        help_text="Buffer time after appointment in minutes"
    )
    description = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        ordering = ['name']


class Appointment(models.Model):
    """Patient appointment model"""
    STATUS_CHOICES = [
        ('scheduled', 'Scheduled'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    patient = models.ForeignKey(
        Patient, 
        on_delete=models.CASCADE, 
        related_name='appointments'
    )
    provider = models.ForeignKey(
        Provider, 
        on_delete=models.CASCADE, 
        related_name='appointments'
    )
    appointment_type = models.ForeignKey(
        AppointmentType, 
        on_delete=models.CASCADE,
        related_name='appointments'
    )
    location = models.ForeignKey(
        Location, 
        on_delete=models.CASCADE,
        related_name='appointments'
    )
    
    appointment_date = models.DateField()
    appointment_time = models.TimeField()
    
    status = models.CharField(
        max_length=20, 
        choices=STATUS_CHOICES, 
        default='scheduled'
    )
    notes = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-appointment_date', '-appointment_time']
        indexes = [
            models.Index(fields=['patient', 'appointment_date']),
            models.Index(fields=['provider', 'appointment_date']),
        ]
    
    def __str__(self):
        return f"{self.patient.user.get_full_name()} - {self.provider.name} on {self.appointment_date}"