class FollowState {}

class FollowInitial extends FollowState {}

class FollowAddSuccess extends FollowState {}

class FollowAddFailure extends FollowState {
  final String errMessage;

  FollowAddFailure({required this.errMessage});
}

class FollowAddLoading extends FollowState {}

class FollowRemoveSuccess extends FollowState {}

class FollowRemoveFailure extends FollowState {
  final String errMessage;

  FollowRemoveFailure({required this.errMessage});

}

class FollowRemoveLoading extends FollowState {}




class FollowFetchFollowersForCurrentUserSuccess extends FollowState {}

class FollowFetchFollowersForCurrentUserFailure extends FollowState {
  final String errMessage;

  FollowFetchFollowersForCurrentUserFailure({required this.errMessage});

}

class FollowFetchFollowersForCurrentUserLoading extends FollowState {}



class FollowFetchFollowingForCurrentUserSuccess extends FollowState {}

class FollowFetchFollowingForCurrentUserFailure extends FollowState {
  final String errMessage;

  FollowFetchFollowingForCurrentUserFailure({required this.errMessage});

}

class FollowFetchFollowingForCurrentUserLoading extends FollowState {}

class FollowFetchFollowersForAnotherUserSuccess extends FollowState {}

class FollowFetchFollowersForAnotherUserFailure extends FollowState {
  final String errMessage;

  FollowFetchFollowersForAnotherUserFailure({required this.errMessage});

}

class FollowFetchFollowersForAnotherUserLoading extends FollowState {}



class FollowFetchFollowingForAnotherUserSuccess extends FollowState {}

class FollowFetchFollowingForAnotherUserFailure extends FollowState {
  final String errMessage;

  FollowFetchFollowingForAnotherUserFailure({required this.errMessage});

}

class FollowFetchFollowingForAnotherUserLoading extends FollowState {}


