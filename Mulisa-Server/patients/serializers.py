from rest_framework import serializers
from .models import Patient, Vital


class PatientSerializer(serializers.ModelSerializer):
    externalId = serializers.CharField(source="id", read_only=True)
    photoUrl = serializers.URLField(source="photo_url", allow_null=True, required=False)

    contact = serializers.SerializerMethodField()
    medical = serializers.SerializerMethodField()
    emergency = serializers.SerializerMethodField()
    vitals = serializers.SerializerMethodField()  # now derived from Vital (latest)

    class Meta:
        model = Patient
        fields = [
            "id", "externalId", "name", "age", "gender", "photoUrl",
            "contact", "medical", "emergency", "vitals", "notes", "created_at"
        ]
        read_only_fields = ("id", "externalId", "created_at")

    # ---------- Nested getters ----------
    def get_contact(self, obj):
        return {
            "phone": obj.contact_phone,
            "email": obj.contact_email,
            "address": obj.contact_address,
        }

    def get_medical(self, obj):
        return {
            "bloodGroup": obj.med_blood_group,
            "allergies": obj.med_allergies,
            "medicalHistory": obj.med_history,
            "currentMedications": obj.med_current_meds,
        }

    def get_emergency(self, obj):
        return {
            "name": obj.emc_name,
            "phone": obj.emc_phone,
            "relationship": obj.emc_relationship,
        }

    def get_vitals(self, obj):
        """
        Return the LATEST vitals snapshot from the Vital history table,
        or nulls if none exist yet. (Relies on Vital.Meta.ordering = ['-recorded_at'])
        """
        latest = obj.vitals.first()  # thanks to ordering, this is the most recent
        if not latest:
            return {
                "heartRate": None,
                "bpSystolic": None,
                "bpDiastolic": None,
                "heightCm": None,
                "weightKg": None,
                "temperatureC": None,
                "spo2": None,
                "respiratoryRate": None,
                "recordedAt": None,
            }
        return {
            "heartRate": latest.heart_rate,
            "bpSystolic": latest.bp_sys,
            "bpDiastolic": latest.bp_dia,
            "heightCm": latest.height_cm,
            "weightKg": latest.weight_kg,
            "temperatureC": latest.temperature_c,
            "spo2": latest.spo2,
            "respiratoryRate": latest.respiratory_rate,
            "recordedAt": latest.recorded_at,
        }

    # ---------- Create ----------
    def create(self, validated_data):
        """
        Create Patient and (optionally) create an initial Vital record
        if 'vitals' was provided in the request payload.
        """
        request = self.context.get("request")
        owner = request.user if request else None

        # nested input sections
        contact = self.initial_data.get("contact", {}) or {}
        medical = self.initial_data.get("medical", {}) or {}
        emergency = self.initial_data.get("emergency", {}) or {}
        vitals_in = self.initial_data.get("vitals", {}) or {}

        # Create the patient
        patient = Patient.objects.create(
            owner=owner,
            name=validated_data["name"],
            age=validated_data["age"],
            gender=validated_data["gender"],
            photo_url=validated_data.get("photo_url"),
            notes=validated_data.get("notes"),

            contact_phone=contact.get("phone"),
            contact_email=contact.get("email"),
            contact_address=contact.get("address"),

            med_blood_group=medical.get("bloodGroup"),
            med_allergies=medical.get("allergies"),
            med_history=medical.get("medicalHistory"),
            med_current_meds=medical.get("currentMedications"),

            emc_name=emergency.get("name"),
            emc_phone=emergency.get("phone"),
            emc_relationship=emergency.get("relationship"),
        )

        # Optionally seed first Vital history row
        if any(vitals_in.get(k) is not None for k in (
            "heartRate", "bpSystolic", "bpDiastolic", "heightCm",
            "weightKg", "temperatureC", "spo2", "respiratoryRate"
        )):
            Vital.objects.create(
                patient=patient,
                heart_rate=vitals_in.get("heartRate"),
                bp_sys=vitals_in.get("bpSystolic"),
                bp_dia=vitals_in.get("bpDiastolic"),
                height_cm=vitals_in.get("heightCm"),
                weight_kg=vitals_in.get("weightKg"),
                temperature_c=vitals_in.get("temperatureC"),
                spo2=vitals_in.get("spo2"),
                respiratory_rate=vitals_in.get("respiratoryRate"),
            )

        return patient
    
    # ---------- Update ----------
    def update(self, instance, validated_data):
        """
        Update Patient - only basic info and contact phone.
        Medical/vitals/emergency handled by separate endpoints.
        """
        # Get nested contact data
        contact = self.initial_data.get("contact", {}) or {}
        
        # Update basic fields
        instance.name = validated_data.get("name", instance.name)
        instance.age = validated_data.get("age", instance.age)
        instance.gender = validated_data.get("gender", instance.gender)
        instance.photo_url = validated_data.get("photo_url", instance.photo_url)
        instance.notes = validated_data.get("notes", instance.notes)
        
        # Update contact phone only
        if contact and "phone" in contact:
            instance.contact_phone = contact.get("phone")
        
        instance.save()
        return instance


class VitalSerializer(serializers.ModelSerializer):
    patientId = serializers.IntegerField(source="patient.id", read_only=True)
    recordedAt = serializers.DateTimeField(source="recorded_at", read_only=True)

    class Meta:
        model = Vital
        fields = [
            "id",
            "patientId",
            "heart_rate",
            "bp_sys",
            "bp_dia",
            "height_cm",
            "weight_kg",
            "temperature_c",
            "spo2",
            "respiratory_rate",
            "recordedAt",
        ]
        read_only_fields = ["id", "patientId", "recordedAt"]
        
        
class PatientListSerializer(serializers.ModelSerializer):
    """Simple serializer for patient list - used in dropdowns"""
    owner_email = serializers.CharField(source='owner.email', read_only=True)
    
    class Meta:
        model = Patient
        fields = [
            'id',
            'name',  # Direct field from Patient model
            'age',
            'gender',
            'owner_email',
            'contact_phone',
            'contact_email',
            'med_blood_group',
        ]