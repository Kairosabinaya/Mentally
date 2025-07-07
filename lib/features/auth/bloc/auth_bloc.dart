import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repository/auth_repository.dart';
import '../../../shared/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _authStateSubscription;
  bool _isManualOperation = false; // Flag to prevent race conditions

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      // Only process auth state changes if not in manual operation
      if (!_isManualOperation) {
        add(AuthUserChanged(isAuthenticated: user != null));
      }
    });

    // Register event handlers
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthRegisterRequestedDetailed>(_onAuthRegisterRequestedDetailed);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
    on<AuthRefreshUserRequested>(_onAuthRefreshUserRequested);
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
      print('❌ AuthBloc: Error in _onAuthStarted: $e');
      emit(AuthError(message: 'Failed to check authentication status'));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AuthBloc: Login requested for ${event.email}');

    // Set manual operation flag to prevent race conditions
    _isManualOperation = true;
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );

      print('✅ AuthBloc: Login successful, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: user));

      // Add small delay to ensure UI navigation completes
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ AuthBloc: Login failed with error: $e');
      String errorMessage = 'Login failed';

      // Extract clean error message
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      emit(AuthError(message: errorMessage));
    } finally {
      // Reset manual operation flag
      _isManualOperation = false;
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AuthBloc: Registration requested for ${event.email}');

    // Set manual operation flag to prevent race conditions
    _isManualOperation = true;
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
        event.name,
      );

      print('✅ AuthBloc: Registration successful, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: user));

      // Add small delay to ensure UI navigation completes
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ AuthBloc: Registration failed with error: $e');
      String errorMessage = 'Registration failed';

      // Extract clean error message
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      emit(AuthError(message: errorMessage));
    } finally {
      // Reset manual operation flag
      _isManualOperation = false;
    }
  }

  Future<void> _onAuthRegisterRequestedDetailed(
    AuthRegisterRequestedDetailed event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AuthBloc: Detailed registration requested for ${event.email}');

    // Set manual operation flag to prevent race conditions
    _isManualOperation = true;
    emit(const AuthLoading());

    try {
      // Step 1: Create user with basic info first
      print('📝 AuthBloc: Creating basic user account...');
      final basicUser = await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
        event.name,
      );

      print(
        '✅ AuthBloc: Basic user created, now updating with detailed info...',
      );

      // Step 2: Update user with detailed information
      final detailedUser = await _authRepository.updateUserProfile(
        basicUser.id,
        event.gender,
        event.dateOfBirth,
        event.phone,
      );

      print(
        '✅ AuthBloc: Detailed registration successful, emitting AuthAuthenticated',
      );
      emit(AuthAuthenticated(user: detailedUser));

      // Add small delay to ensure UI navigation completes
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ AuthBloc: Detailed registration failed with error: $e');
      String errorMessage = 'Registration failed';

      // Extract clean error message
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      emit(AuthError(message: errorMessage));
    } finally {
      // Reset manual operation flag
      _isManualOperation = false;
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _isManualOperation = true;
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('❌ AuthBloc: Logout failed: $e');
      emit(AuthError(message: 'Failed to sign out'));
    } finally {
      _isManualOperation = false;
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    print(
      '🔄 AuthBloc: User changed event, isAuthenticated = ${event.isAuthenticated}',
    );

    // Skip if manual operation is in progress
    if (_isManualOperation) {
      print('⏭️ AuthBloc: Skipping auth state change due to manual operation');
      return;
    }

    if (event.isAuthenticated) {
      try {
        print('🔍 AuthBloc: Getting current user from repository...');
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          print('✅ AuthBloc: Current user found, emitting AuthAuthenticated');
          emit(AuthAuthenticated(user: user));
        } else {
          print(
            '❌ AuthBloc: Current user is null, emitting AuthUnauthenticated',
          );
          emit(const AuthUnauthenticated());
        }
      } catch (e) {
        print('❌ AuthBloc: Error getting current user: $e');
        // Don't emit error for auth state changes, just log it
        print('⏭️ AuthBloc: Skipping error emission for auth state change');
      }
    } else {
      print(
        '🔄 AuthBloc: User not authenticated, emitting AuthUnauthenticated',
      );
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
      print('❌ AuthBloc: Password reset failed: $e');
      emit(AuthError(message: 'Failed to send password reset email'));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    _isManualOperation = true;
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user: user));

      // Add small delay to ensure UI navigation completes
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ AuthBloc: Google sign in failed: $e');
      String errorMessage = 'Google sign in failed';

      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      emit(AuthError(message: errorMessage));
    } finally {
      _isManualOperation = false;
    }
  }

  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    _isManualOperation = true;
    emit(const AuthLoading());

    try {
      await _authRepository.deleteAccount();
      emit(const AuthAccountDeleted());
    } catch (e) {
      print('❌ AuthBloc: Account deletion failed: $e');
      emit(AuthError(message: 'Failed to delete account'));
    } finally {
      _isManualOperation = false;
    }
  }

  Future<void> _onAuthRefreshUserRequested(
    AuthRefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AuthBloc: Refresh user data requested');

    try {
      // Get fresh user data from Firebase
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        print('✅ AuthBloc: User data refreshed successfully');
        print('📊 AuthBloc: Updated user points: ${user.points}');
        emit(AuthAuthenticated(user: user));
      } else {
        print('❌ AuthBloc: No user found during refresh');
        // Don't change state if user is null, just log it
      }
    } catch (e) {
      print('❌ AuthBloc: Error refreshing user data: $e');
      // Don't emit error for refresh failures, just log it
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
