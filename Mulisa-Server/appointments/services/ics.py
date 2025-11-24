# appointments/services/ics.py
def generate_ics(appt) -> str:
    """
    Minimal ICS content for calendar add.
    """
    uid = f"{appt.id}@mulisa"
    summary = f"{appt.type.name} with provider {appt.provider_id}"
    tz = appt.timezone_str
    # using UTC for simplicity; clients can convert
    start = appt.start.strftime("%Y%m%dT%H%M%SZ")
    end = appt.end.strftime("%Y%m%dT%H%M%SZ")
    desc = (appt.notes_patient or "")[:500].replace("\n", "\\n")

    return (
        "BEGIN:VCALENDAR\r\n"
        "VERSION:2.0\r\n"
        "PRODID:-//Mulisa//Appointments 1.0//EN\r\n"
        "BEGIN:VEVENT\r\n"
        f"UID:{uid}\r\n"
        f"DTSTAMP:{start}\r\n"
        f"DTSTART:{start}\r\n"
        f"DTEND:{end}\r\n"
        f"SUMMARY:{summary}\r\n"
        f"DESCRIPTION:{desc}\r\n"
        "END:VEVENT\r\n"
        "END:VCALENDAR\r\n"
    )
