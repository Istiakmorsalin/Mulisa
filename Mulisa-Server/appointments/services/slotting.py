# appointments/services/slotting.py
from datetime import datetime, time
from ..models import Provider, Location, AppointmentType, ProviderSchedule
from ..utils import generate_slots_for_range

# appointments/services/slotting.py
def get_slots(provider_id, location_id, type_id, start_dt, end_dt):
    """
    Fetch available slots for a given provider/location/type in a time range.
    """
    try:
        provider = Provider.objects.get(id=provider_id)
        location = Location.objects.get(id=location_id)
        appt_type = AppointmentType.objects.get(id=type_id)
    except (Provider.DoesNotExist, Location.DoesNotExist, AppointmentType.DoesNotExist) as e:
        return {"error": str(e), "slots": []}

    # Check if provider works at this location
    if location not in provider.locations.all():
        return {"error": "Provider does not work at this location", "slots": []}

    # Get the provider's schedule for the requested date
    weekday = start_dt.weekday()  # 0=Monday, 6=Sunday
    
    schedule = ProviderSchedule.objects.filter(
        provider=provider,
        location=location,
        weekday=weekday,  # Changed from day_of_week
        is_active=True
    ).first()

    # If no schedule found, return empty slots
    if not schedule:
        days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        return {
            "provider_id": str(provider_id),
            "location_id": str(location_id),
            "type_id": type_id,
            "slots": [],
            "message": f"No schedule found for this provider on {days[weekday]}"
        }

    slots = generate_slots_for_range(
        provider=provider,
        location=location,
        appt_type=appt_type,
        start_dt=start_dt,
        end_dt=end_dt,
        work_start=schedule.start,  # Changed from start_time
        work_end=schedule.end,  # Changed from end_time
    )

    return {
        "provider_id": str(provider_id),
        "location_id": str(location_id),
        "type_id": type_id,
        "slots": slots,
    }