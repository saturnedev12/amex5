import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/core/session/session_manager.dart';
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
  final SessionManager _sessionManager;

  LoginCubit(this._repository, this._sessionManager) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final body = LoginBodyModel(
        login: username,
        pwd: password,
        checkCode: "DUMMY_CODE",
        tokenRequired: true,
        authsRequired: true,
        eamDocRequired: true,
        userAsPerson: false,
        remoteRequestDate: "2024-12-16T20:07:11+0000",
        appData: {
          "syncRequired": true,
          "scopes": ["WMWO_MOBILE"],
        },
      );
      final response = await _repository.login(body: body);

      // Save token + full login response JSON locally
      await _sessionManager.saveLoginData(
        token: response.token ?? '',
        loginResponseJson: response.toJson(),
        password: password,
      );

      emit(AuthAuthenticated(response));
    } catch (e) {
      inspect(e);
      emit(AuthError('Erreur de connexion : $e'));
    }
  }
}
