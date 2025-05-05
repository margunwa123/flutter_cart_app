import 'package:ecommerce_app/domain/usecases/auth_usecase.dart';
import 'package:ecommerce_app/presentation/blocs/auth/auth_event.dart';
import 'package:ecommerce_app/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase authUseCase;

  AuthBloc(this.authUseCase) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authUseCase.login(event.username, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}
