import 'package:balanced_meal/core/error_handling/faliure.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      debugPrint(FirebaseErrorMapper.fromCode(e.code).message);
      emit(LoginFailure(FirebaseErrorMapper.fromCode(e.code).message));
    }
  }

}
