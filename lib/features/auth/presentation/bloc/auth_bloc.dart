import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      emit(AuthLoading());
      final user = _authRepository.currentUser;
      if (user != null) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signIn(email: event.email, password: event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signUp(name: event.name, email: event.email, password: event.password);
  
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoggedOut>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
