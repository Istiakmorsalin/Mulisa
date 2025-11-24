# appointments/serializers.py
from rest_framework import serializers
from .models import Appointment, Provider, Location, AppointmentType


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = [
            'id',
            'name',
            'address',
            'city',
            'state',
            'zip_code',
            'phone',
        ]


class ProviderSerializer(serializers.ModelSerializer):
    locations = LocationSerializer(many=True, read_only=True)
    
    class Meta:
        model = Provider
        fields = [
            'id',
            'name',
            'specialty',
            'phone',
            'email',
            'bio',
            'locations',
        ]


class AppointmentTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppointmentType
        fields = [
            'id',
            'name',
            'duration_minutes',
            'allow_patient_booking',
            'description',
        ]


class AppointmentSerializer(serializers.ModelSerializer):
    # Read-only fields for display
    provider_name = serializers.CharField(source='provider.name', read_only=True)
    provider_specialty = serializers.CharField(source='provider.specialty', read_only=True)
    type_name = serializers.CharField(source='appointment_type.name', read_only=True)
    location_name = serializers.CharField(source='location.name', read_only=True)
    location_address = serializers.CharField(source='location.address', read_only=True)
    patient_name = serializers.CharField(source='patient.name', read_only=True)  # Changed: patient.name directly
    patient_age = serializers.IntegerField(source='patient.age', read_only=True)
    patient_gender = serializers.CharField(source='patient.gender', read_only=True)
    
    class Meta:
        model = Appointment
        fields = [
            'id',
            'patient',
            'provider',
            'appointment_type',
            'location',
            'appointment_date',
            'appointment_time',
            'status',
            'notes',
            # Read-only display fields
            'provider_name',
            'provider_specialty',
            'type_name',
            'location_name',
            'location_address',
            'patient_name',
            'patient_age',
            'patient_gender',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['created_at', 'updated_at']
    
    def validate_appointment_date(self, value):
        """Ensure appointment date is not in the past"""
        from django.utils import timezone
        if value < timezone.now().date():
            raise serializers.ValidationError("Appointment date cannot be in the past")
        return value


class AppointmentCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating appointments - includes patient field"""
    
    class Meta:
        model = Appointment
        fields = [
            'patient',
            'provider',
            'appointment_type',
            'location',
            'appointment_date',
            'appointment_time',
            'notes',
        ]
    
    def validate_appointment_date(self, value):
        """Ensure appointment date is not in the past"""
        from django.utils import timezone
        if value < timezone.now().date():
            raise serializers.ValidationError("Appointment date cannot be in the past")
        return value