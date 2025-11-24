# appointments/permissions.py
from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsStaffOrReadOnly(BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        return bool(request.user and request.user.is_authenticated and getattr(request.user, "is_staff", False))

class IsOwnerPatientOrStaff(BasePermission):
    """
    Patients can access their own appointments via patient_id in token (you’ll map this in your Auth).
    Staff/Clinicians can access broadly (simplified here: staff only).
    """
    def has_object_permission(self, request, view, obj):
        if getattr(request.user, "is_staff", False):
            return True
        # If you propagate patient_id in request.user (e.g., via custom auth), check it here:
        user_patient_id = getattr(request.user, "patient_id", None)
        return user_patient_id and obj.patient_id == user_patient_id
