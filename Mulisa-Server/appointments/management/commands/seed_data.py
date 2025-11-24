from django.core.management.base import BaseCommand
from appointments.models import Provider, Location, AppointmentType


class Command(BaseCommand):
    help = 'Seed database with sample data'

    def handle(self, *args, **kwargs):
        self.stdout.write('Starting to seed data...')
        
        # Create Providers
        provider1, created = Provider.objects.get_or_create(
            name='Trivedi',
            defaults={
                'specialty': 'Family Medicine',
                'phone': '34343434',
                'email': 'dr.trivedi@example.com'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created provider: {provider1.name}'))
        else:
            self.stdout.write(f'Provider already exists: {provider1.name}')
        
        provider2, created = Provider.objects.get_or_create(
            name='Johnson',
            defaults={
                'specialty': 'Cardiology',
                'phone': '55555555',
                'email': 'dr.johnson@example.com'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created provider: {provider2.name}'))
        else:
            self.stdout.write(f'Provider already exists: {provider2.name}')
        
        # Create Locations
        location1, created = Location.objects.get_or_create(
            name='Emory',
            defaults={
                'address': 'East Cobb',
                'city': 'Marietta',
                'state': 'GA',
                'zip_code': '30458',
                'phone': '1234567890'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created location: {location1.name}'))
        else:
            self.stdout.write(f'Location already exists: {location1.name}')
        
        location2, created = Location.objects.get_or_create(
            name='Northside Hospital',
            defaults={
                'address': '1000 Johnson Ferry Rd',
                'city': 'Atlanta',
                'state': 'GA',
                'zip_code': '30342',
                'phone': '0987654321'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created location: {location2.name}'))
        else:
            self.stdout.write(f'Location already exists: {location2.name}')
        
        # Link providers to locations
        location1.providers.add(provider1, provider2)
        location2.providers.add(provider2)
        self.stdout.write('Linked providers to locations')
        
        # Create Appointment Types
        apt_type1, created = AppointmentType.objects.get_or_create(
            name='General Checkup',
            defaults={
                'duration_minutes': 30,
                'allow_patient_booking': True,
                'description': 'Regular health checkup'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created appointment type: {apt_type1.name}'))
        else:
            self.stdout.write(f'Appointment type already exists: {apt_type1.name}')
        
        apt_type2, created = AppointmentType.objects.get_or_create(
            name='Follow-up',
            defaults={
                'duration_minutes': 15,
                'allow_patient_booking': True,
                'description': 'Follow-up appointment'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created appointment type: {apt_type2.name}'))
        else:
            self.stdout.write(f'Appointment type already exists: {apt_type2.name}')
        
        apt_type3, created = AppointmentType.objects.get_or_create(
            name='Consultation',
            defaults={
                'duration_minutes': 45,
                'allow_patient_booking': True,
                'description': 'Initial consultation'
            }
        )
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created appointment type: {apt_type3.name}'))
        else:
            self.stdout.write(f'Appointment type already exists: {apt_type3.name}')
        
        self.stdout.write(self.style.SUCCESS('Successfully seeded database!'))