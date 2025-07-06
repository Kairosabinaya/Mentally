import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(isAuthenticated: user != null));
    });

    // Register event handlers
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
        event.name,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      try {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.deleteAccount();
      emit(const AuthAccountDeleted());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
