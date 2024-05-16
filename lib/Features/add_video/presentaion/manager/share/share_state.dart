class ShareState {}

class ShareInitial extends ShareState {}

class ShareUpdatedSuccess extends ShareState {}

class ShareUpdatedFailure extends ShareState {
  final String errMessage;

  ShareUpdatedFailure({required this.errMessage});
}

class ShareUpdatedLoading extends ShareState {}
