import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/features/authentification/data/auth_repository.dart';
import 'package:amex5/features/authentification/data/models/login_body_model.dart';
import 'package:amex5/features/authentification/data/models/login_response_model.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final LoginResponseModel response;
  AuthAuthenticated(this.response);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

@injectable
class LoginCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  LoginCubit(this._repository) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final body = LoginBodyModel(
        login: username,
        pwd: password,
        checkCode: "DUMMY_CODE",
      );
      final response = await _repository.login(body: body);
      emit(AuthAuthenticated(response));
    } catch (e) {
      emit(AuthError('Erreur de connexion : $e'));
    }
  }
}
