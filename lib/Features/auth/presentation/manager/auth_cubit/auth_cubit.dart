import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_states.dart';
import '../../../data/models/auth_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState());
  Future<void> logIn({required AuthModel atuhModel}) async {
    emit(LogInLoadingState());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: atuhModel.email,
        password: atuhModel.password,
      );
      emit(LogInSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(LogInFailureState(errMessage: e.code));
    } on Exception catch (e) {
      emit(LogInFailureState(errMessage: e.toString()));
    }
  }

  Future<void> signUp({required AuthModel atuhModel}) async {
    emit(SignUpLoadingState());
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: atuhModel.email, password: atuhModel.password);
      emit(SignUpSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailureState(errMessage: e.code));
    } on Exception catch (e) {
      emit(SignUpFailureState(errMessage: e.toString()));
    }
  }


  void checkStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        emit(CheckAuthStateLoggedInUser());
      } else {
        emit(CheckAuthStateLoggedOutUser());
      }
    });
  }
}
