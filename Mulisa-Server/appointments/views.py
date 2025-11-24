# appointments/views.py
from drf_spectacular.utils import extend_schema, OpenApiParameter
from drf_spectacular.types import OpenApiTypes
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination
from django.utils import timezone
from .models import Appointment, Provider, Location, AppointmentType
from .serializers import (
    AppointmentSerializer, 
    AppointmentCreateSerializer,
    ProviderSerializer,
    LocationSerializer,
    AppointmentTypeSerializer
)


class AppointmentPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 100


class ProviderViewSet(viewsets.ReadOnlyModelViewSet):
    """API endpoint for viewing providers"""
    queryset = Provider.objects.all()
    serializer_class = ProviderSerializer
    permission_classes = [IsAuthenticated]


class LocationViewSet(viewsets.ReadOnlyModelViewSet):
    """API endpoint for viewing locations"""
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    permission_classes = [IsAuthenticated]


class AppointmentTypeViewSet(viewsets.ReadOnlyModelViewSet):
    """API endpoint for viewing appointment types"""
    queryset = AppointmentType.objects.filter(allow_patient_booking=True)
    serializer_class = AppointmentTypeSerializer
    permission_classes = [IsAuthenticated]


class AppointmentViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    pagination_class = AppointmentPagination
    
    def get_queryset(self):
        """Get all appointments with optional filtering"""
        queryset = Appointment.objects.all().select_related(
            'provider', 
            'appointment_type', 
            'location',
            'patient__owner'
        )
        
        # Manual filtering
        patient_id = self.request.query_params.get('patient_id')
        provider_id = self.request.query_params.get('provider_id')
        location_id = self.request.query_params.get('location_id')
        status_filter = self.request.query_params.get('status')
        
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        if provider_id:
            queryset = queryset.filter(provider_id=provider_id)
        if location_id:
            queryset = queryset.filter(location_id=location_id)
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        return queryset
    
    def get_serializer_class(self):
        """Use different serializers for different actions"""
        if self.action == 'create':
            return AppointmentCreateSerializer
        return AppointmentSerializer
    
    @extend_schema(
        parameters=[
            OpenApiParameter(
                name='patient_id',
                type=OpenApiTypes.INT,
                location=OpenApiParameter.QUERY,
                description='Filter by patient ID',
                required=False
            ),
            OpenApiParameter(
                name='provider_id',
                type=OpenApiTypes.INT,
                location=OpenApiParameter.QUERY,
                description='Filter by provider ID',
                required=False
            ),
            OpenApiParameter(
                name='location_id',
                type=OpenApiTypes.INT,
                location=OpenApiParameter.QUERY,
                description='Filter by location ID',
                required=False
            ),
            OpenApiParameter(
                name='status',
                type=OpenApiTypes.STR,
                location=OpenApiParameter.QUERY,
                description='Filter by status (scheduled, completed, cancelled)',
                required=False,
                enum=['scheduled', 'completed', 'cancelled']
            ),
        ],
        responses={200: AppointmentSerializer(many=True)}
    )
    def list(self, request, *args, **kwargs):
        """List all appointments with optional filters"""
        return super().list(request, *args, **kwargs)
    
    def perform_create(self, serializer):
        """Save the appointment with status='scheduled'"""
        print(f"📥 Creating appointment with data: {serializer.validated_data}")
        serializer.save(status='scheduled')
        print(f"✅ Appointment created successfully")
    
    def update(self, request, *args, **kwargs):
        """Update an appointment"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        return Response(serializer.data)
    
    @extend_schema(
        parameters=[
            OpenApiParameter(
                name='patient_id',
                type=OpenApiTypes.INT,
                location=OpenApiParameter.QUERY,
                description='Filter by patient ID',
                required=False
            ),
        ],
        responses={200: AppointmentSerializer(many=True)}
    )
    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        """Get upcoming appointments (future dates, scheduled status)"""
        patient_id = request.query_params.get('patient_id')
        
        queryset = Appointment.objects.filter(
            appointment_date__gte=timezone.now().date(),
            status='scheduled'
        ).select_related('provider', 'appointment_type', 'location').order_by(
            'appointment_date', 
            'appointment_time'
        )
        
        # Filter by patient if provided
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        
        # Paginate the results
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = AppointmentSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = AppointmentSerializer(queryset, many=True)
        return Response(serializer.data)
    
    @extend_schema(
        parameters=[
            OpenApiParameter(
                name='patient_id',
                type=OpenApiTypes.INT,
                location=OpenApiParameter.QUERY,
                description='Filter by patient ID',
                required=False
            ),
        ],
        responses={200: AppointmentSerializer(many=True)}
    )
    @action(detail=False, methods=['get'])
    def past(self, request):
        """Get past appointments"""
        patient_id = request.query_params.get('patient_id')
        
        queryset = Appointment.objects.filter(
            appointment_date__lt=timezone.now().date()
        ).select_related('provider', 'appointment_type', 'location').order_by(
            '-appointment_date', 
            '-appointment_time'
        )
        
        # Filter by patient if provided
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        
        # Paginate the results
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = AppointmentSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = AppointmentSerializer(queryset, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['patch'])
    def cancel(self, request, pk=None):
        """Cancel an appointment"""
        appointment = self.get_object()
        
        if appointment.status == 'cancelled':
            return Response(
                {'error': 'Appointment is already cancelled'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        appointment.status = 'cancelled'
        appointment.save()
        
        serializer = AppointmentSerializer(appointment)
        return Response(serializer.data)
    
    @action(detail=True, methods=['patch'])
    def complete(self, request, pk=None):
        """Mark an appointment as completed"""
        appointment = self.get_object()
        
        appointment.status = 'completed'
        appointment.save()
        
        serializer = AppointmentSerializer(appointment)
        return Response(serializer.data)