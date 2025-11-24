from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/accounts/", include("accounts.urls")),
    path("api/", include("patients.urls")),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path('api/medications/', include('medications.urls')),
    path('api/labreports/', include('labreports.urls')),
    path("api/", include("appointments.urls")),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
]
