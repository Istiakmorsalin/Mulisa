from django.contrib.auth import get_user_model, authenticate
from django.db.models import Q
from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.exceptions import ValidationError, AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import SignupSerializer, LoginSerializer, MeSerializer

User = get_user_model()

def _display_name(user: User) -> str:
    full = f"{(user.first_name or '').strip()} {(user.last_name or '').strip()}".strip()
    return full or user.username or "User"

def _issue_tokens_dict(user: User) -> dict:
    """
    Returns {id, name, token} where token is an access token string.
    """
    refresh = RefreshToken.for_user(user)
    access  = str(refresh.access_token)
    return {
        "id": str(user.id),
        "name": _display_name(user),
        "token": access,
    }

class SignupView(APIView):
    """
    POST /api/accounts/signup/
    body: { "email": "...", "password": "..." }
    returns: { "id", "name", "token" }
    """
    permission_classes = [permissions.AllowAny]
    serializer_class = SignupSerializer  # Add this for schema generation

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data["email"].lower()
        password = serializer.validated_data["password"]

        if User.objects.filter(Q(email__iexact=email) | Q(username__iexact=email)).exists():
            raise ValidationError({"detail": "User with this email already exists"})

        user = User.objects.create_user(
            username=email,
            email=email,
            password=password,
        )
        data = _issue_tokens_dict(user)
        return Response(data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """
    POST /api/accounts/login/
    body: { "email": "...", "password": "..." } OR { "username": "...", "password": "..." }
    returns: { "id", "name", "token" }
    """
    permission_classes = [permissions.AllowAny]
    serializer_class = LoginSerializer  # Add this for schema generation

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email_or_username = (
            serializer.validated_data.get("email") or 
            serializer.validated_data.get("username") or ""
        ).strip()
        password = serializer.validated_data["password"]

        user = authenticate(request, username=email_or_username, password=password)

        if user is None and "@" in email_or_username:
            try:
                u = User.objects.get(email__iexact=email_or_username)
                user = authenticate(request, username=u.username, password=password)
            except User.DoesNotExist:
                pass

        if user is None:
            raise AuthenticationFailed("Invalid credentials")

        data = _issue_tokens_dict(user)
        return Response(data, status=status.HTTP_200_OK)


class LogoutView(APIView):
    """
    POST /api/accounts/logout/
    Optionally accept { "refresh": "<token>" } to blacklist (if blacklist app enabled).
    Returns 204 always (stateless logout).
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get("refresh")
        if refresh_token:
            try:
                token = RefreshToken(refresh_token)
                token.blacklist()
            except Exception:
                pass
        return Response(status=status.HTTP_204_NO_CONTENT)


class MeView(APIView):
    """
    GET /api/accounts/me/
    returns a profile snapshot
    """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MeSerializer  # Add this for schema generation

    def get(self, request):
        u = request.user
        data = {
            "id": u.id,
            "username": u.username,
            "email": u.email,
            "first_name": u.first_name,
            "last_name": u.last_name,
            "role": getattr(u, "role", None),
            "phone": getattr(u, "phone", None),
            "name": _display_name(u),
        }
        serializer = MeSerializer(data)
        return Response(serializer.data)