import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_firebase_2/common/constants/app_constants.dart';
import 'package:flutter_bloc_firebase_2/modules/sign_up_page/models/user.dart';
import 'package:flutter_bloc_firebase_2/modules/sign_up_page/repository/authentication_repo.dart';
import 'package:flutter_bloc_firebase_2/modules/sign_up_page/repository/database_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_form_event.dart';
part 'login_form_state.dart';

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  final AuthenticationRepository _authenticationRepository;
  final DatabaseRepository _databaseRepository;

  LoginFormBloc(this._authenticationRepository, this._databaseRepository)
      : super(const LoginFormState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<FormSubmitted>(_onFormSubmitted);
    on<Logout>(_onLogout);
    on<GetData>(_onGetData);
  }

  Future<void> _onLogout(Logout event, Emitter<LoginFormState> emit) async {
    emit(state.copyWith(
      status: StateStatus.loading,
    ));
    await _authenticationRepository.signOut();
    _deleteData();
    emit(state.copyWith(
      status: StateStatus.failure,
      isFormValid: false,
      isLoginVerified: false,
    ));
  }

  Future<void> _deleteData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uId');
    prefs.remove('email');
  }

  Future<void> _onGetData(GetData event, Emitter<LoginFormState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    emit(state.copyWith(
      status: StateStatus.loading,
    ));

    final String uId = prefs.getString('uId') ?? 'Unknown';
    final String displayName = prefs.getString('displayName') ?? 'Unknown';

    emit(state.copyWith(
      status: StateStatus.success,
      isFormValid: true,
      isLoginVerified: true,
      uid: uId,
      email: displayName,
    ));
  }

  bool _isEmailValid(String email) {
    return email.isNotEmpty;
  }

  bool _isPasswordValid(String password) {
    return password.isNotEmpty;
  }

  Future<void> _onEmailChanged(
      EmailChanged event, Emitter<LoginFormState> emit) async {
    emit(state.copyWith(
      status: StateStatus.initial,
      email: event.email,
    ));
  }

  Future<void> _onPasswordChanged(
      PasswordChanged event, Emitter<LoginFormState> emit) async {
    emit(state.copyWith(
      status: StateStatus.initial,
      password: event.password,
    ));
  }

  Future<void> _onFormSubmitted(
      FormSubmitted event, Emitter<LoginFormState> emit) async {
    UserModel user = UserModel(
      email: state.email,
      password: state.password,
    );
    emit(
      state.copyWith(
        email: state.email,
        password: state.password,
        status: StateStatus.loading,
        isFormValid:
            _isEmailValid(state.email) && _isPasswordValid(state.password),
      ),
    );
    if (state.isFormValid) {
      try {
        UserCredential? authUser = await _authenticationRepository.signIn(user);
        print("authUser$authUser");
        UserModel updateUser =
            user.copyWith(isVerified: authUser != null ? true : false);
        await _databaseRepository.saveUserData(updateUser);
        if (updateUser.isVerified!) {
          emit(state.copyWith(
            uid: authUser!.user!.uid,
            status: StateStatus.success,
          ));

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('uId', authUser.user!.uid);
          print('User: ${updateUser.email}');
          prefs.setString('email', updateUser.email ?? 'Unkown');
        } else {
          emit(state.copyWith(
            status: StateStatus.failure,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: StateStatus.failure,
          isFormValid: false,
          isLoginVerified: false,
        ));
      }
    } else {
      emit(state.copyWith(
        status: StateStatus.failure,
        isFormValid: false,
        isLoginVerified: false,
      ));
    }
  }
}
