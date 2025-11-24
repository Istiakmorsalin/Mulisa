# patients/urls.py
from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import PatientViewSet
from .views_vitals import (
    PatientVitalListCreateView,
    PatientVitalDetailView,
    PatientVitalLatestView,
)

app_name = "patients"

router = DefaultRouter()
router.register(r"patients", PatientViewSet, basename="patient")

urlpatterns = [
    # Router-generated CRUD for /api/patients/...
    *router.urls,

    # Nested vitals history under a patient
    path(
        "patients/<int:patient_id>/vitals/",
        PatientVitalListCreateView.as_view(),
        name="patient-vitals-list-create",
    ),
    path(
        "patients/<int:patient_id>/vitals/latest/",
        PatientVitalLatestView.as_view(),
        name="patient-vitals-latest",
    ),
    path(
        "patients/<int:patient_id>/vitals/<int:vital_id>/",
        PatientVitalDetailView.as_view(),
        name="patient-vitals-detail",
    ),
]
