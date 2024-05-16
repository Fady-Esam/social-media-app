

class UserDataState {}

class UserDataInitial extends UserDataState {}
//? sendUserData
class SendUserDataSuccess extends UserDataState {}
//? fetchUserData
class FetchUserDataSuccess extends UserDataState {
}

class FetchUserDataFailure extends UserDataState {
  final String errMessage;

  FetchUserDataFailure({required this.errMessage});
}

class FetchUserDataLoading extends UserDataState {}
class FetchUserIncrementLikes extends UserDataState {}
class FetchUserDecrementLikes extends UserDataState {}
class FetchUserAllLikes extends UserDataState {}
class EditUserData extends UserDataState {}
