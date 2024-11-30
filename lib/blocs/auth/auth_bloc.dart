import 'package:bodo_app/blocs/auth/auth_event.dart';
import 'package:bodo_app/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bodo_app/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.register(event.email, event.password);
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.login(event.email, event.password);
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}