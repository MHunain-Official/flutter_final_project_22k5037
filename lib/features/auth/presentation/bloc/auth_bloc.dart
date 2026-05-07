import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// SRP: AuthBloc only orchestrates auth flow — no HTTP, no storage details
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _repo.login(e.email, e.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onRegister(RegisterRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _repo.register(e.name, e.email, e.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthLoggedOut());
  }
}
