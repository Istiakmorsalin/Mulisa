import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_local_store.dart';
import '../data/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _service;
  final AuthLocalStore _local;
  AuthCubit(this._service, this._local) : super(const AuthState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _service.login(email, password);
      if (user.token.isNotEmpty) {
        // Save both token and userId
        await _local.saveSession(user.token, user.id.toString());
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: user.token,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, error: e.toString()));
    }
  }

  Future<void> signup(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      final user = await _service.signUp(email, password);
      // Optionally auto-login after sign-up:
      if (user.token.isNotEmpty) {
        // Save both token and userId
        await _local.saveSession(user.token, user.id.toString());
      }
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, error: e.toString()));
    }
  }

  Future<void> logout() async {
    await _local.clear();
    emit(const AuthState(status: AuthStatus.initial));
  }

  Future<void> checkSession() async {
    final token = await _local.readToken();
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(status: AuthStatus.authenticated, token: token));
    }
  }
}
