import 'package:balanced_meal/core/error_handling/faliure.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future<void> signIn(String email, String password) async {
    emit(RegisterLoading());
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(FirebaseErrorMapper.fromCode(e.code).message));
    }
  }

}
