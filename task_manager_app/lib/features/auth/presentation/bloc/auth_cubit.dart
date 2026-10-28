import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/auth_repository.dart';
import '../../models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;
  AuthCubit({required this.authRepository, required this.tokenStorage}): super(const AuthState()) {checkAuthStatus();}

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authRepository.checkSession();
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({required String email, required String password}) async {                                                                                 
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final UserModel user = await authRepository.login(email: email,password: password);
      // await tokenStorage.saveTokens(accessToken: user.accessToken,refreshToken: user.refreshToken); 
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final UserModel user = await authRepository.signup(
        name: name,
        email: email,
        password: password,
      );
      // await tokenStorage.saveTokens(accessToken: user.accessToken,refreshToken: user.refreshToken);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();

      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) return error.toString().replaceFirst('Exception: ', '');
    return 'Something went wrong. Please try again.';
  }

}



