from rest_framework.permissions import BasePermission


class IsOwnerOrStaff(BasePermission):
    """
    Custom permission:
    - Allows access if the request.user is the owner of the patient
      (i.e., patient.owner == request.user)
    - OR the user is staff / superuser / has clinician role
    """

    def has_permission(self, request, view):
        get_patient = getattr(view, "get_patient", None)
        patient = get_patient() if callable(get_patient) else None
        user = request.user

        if not user or not user.is_authenticated:
            return False

        # Allow if staff or superuser
        if user.is_staff or getattr(user, "role", None) in ("admin", "clinician"):
            return True

        # Allow if owns the patient
        if patient and patient.owner_id == user.id:
            return True

        return False

    def has_object_permission(self, request, view, obj):
        """
        Works for both Patient and Vital objects.
        """
        user = request.user
        if not user or not user.is_authenticated:
            return False

        # Owner, staff, or clinician can access
        if user.is_staff or getattr(user, "role", None) in ("admin", "clinician"):
            return True

        # If it's a Vital, check its patient.owner
        patient = getattr(obj, "patient", None)
        if patient and patient.owner_id == user.id:
            return True

        # If it's a Patient instance
        if getattr(obj, "owner_id", None) == user.id:
            return True

        return False
