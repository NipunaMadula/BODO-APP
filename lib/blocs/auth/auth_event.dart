abstract class AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  RegisterRequested({
    required this.email,
    required this.password,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({
    required this.email,
    required this.password,
  });
}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}