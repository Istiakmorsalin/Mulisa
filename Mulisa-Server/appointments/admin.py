# appointments/admin.py
from django.contrib import admin
from .models import Provider, Location, AppointmentType, Appointment


@admin.register(Provider)
class ProviderAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'specialty', 'phone', 'email']
    search_fields = ['name', 'specialty']
    list_filter = ['specialty']


@admin.register(Location)
class LocationAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'city', 'state', 'zip_code', 'phone']
    search_fields = ['name', 'city', 'address']
    list_filter = ['state', 'city']
    filter_horizontal = ['providers']


@admin.register(AppointmentType)
class AppointmentTypeAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'name',
        'duration_minutes',
        'allow_patient_booking',
        'buffer_before_min',
        'buffer_after_min'
    ]
    search_fields = ['name']
    list_filter = ['allow_patient_booking']


@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'patient',
        'provider',
        'appointment_type',
        'appointment_date',
        'appointment_time',
        'status',
        'created_at'
    ]
    list_filter = ['status', 'appointment_date', 'provider']
    search_fields = [
        'patient__user__first_name',
        'patient__user__last_name',
        'provider__name'
    ]
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Appointment Details', {
            'fields': (
                'patient',
                'provider',
                'appointment_type',
                'location',
            )
        }),
        ('Schedule', {
            'fields': (
                'appointment_date',
                'appointment_time',
                'status',
            )
        }),
        ('Additional Information', {
            'fields': ('notes',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )