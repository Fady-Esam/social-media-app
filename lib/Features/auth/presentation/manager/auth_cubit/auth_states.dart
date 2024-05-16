class AuthState {}

class AuthInitialState extends AuthState {}

//? Log In

class LogInSuccessState extends AuthState {}

class LogInFailureState extends AuthState {
  final String errMessage;

  LogInFailureState({required this.errMessage});
}

class LogInLoadingState extends AuthState {}

//? Sign Up

class SignUpSuccessState extends AuthState {}

class SignUpFailureState extends AuthState {
  final String errMessage;

  SignUpFailureState({required this.errMessage});
}

class SignUpLoadingState extends AuthState {}

class CheckAuthStateLoggedInUser extends AuthState {}

class CheckAuthStateLoggedOutUser extends AuthState {}
