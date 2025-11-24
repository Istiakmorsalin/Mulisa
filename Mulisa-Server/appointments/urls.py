# appointments/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AppointmentViewSet,
    ProviderViewSet,
    LocationViewSet,
    AppointmentTypeViewSet
)

router = DefaultRouter()
router.register(r'appointments', AppointmentViewSet, basename='appointment')
router.register(r'providers', ProviderViewSet, basename='provider')
router.register(r'locations', LocationViewSet, basename='location')
router.register(r'appointment-types', AppointmentTypeViewSet, basename='appointmenttype')

urlpatterns = [
    path('', include(router.urls)),
]