import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthRegisterRequestedDetailed extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String gender;
  final DateTime dateOfBirth;
  final String phone;

  const AuthRegisterRequestedDetailed({
    required this.email,
    required this.password,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    name,
    gender,
    dateOfBirth,
    phone,
  ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthUserChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthUserChanged({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

class AuthRefreshUserRequested extends AuthEvent {
  const AuthRefreshUserRequested();
}
