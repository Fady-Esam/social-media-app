class VideoDataState {}

class VideoDataInitial extends VideoDataState {}

//? addVideoData
class AddVideoDataSuccess extends VideoDataState {}

class AddVideoDataFailure extends VideoDataState {
  final String errMessage;

  AddVideoDataFailure({
    required this.errMessage,
  });
}

class AddVideoDataLoading extends VideoDataState {}

class RemoveVideoDataSuccess extends VideoDataState {}

class RemoveVideoDataFailure extends VideoDataState {
  final String errMessage;

  RemoveVideoDataFailure({
    required this.errMessage,
  });
}

class RemoveVideoDataLoading extends VideoDataState {}

//? fetchVideosForUser
class FetchVideosForCurrrentUserSuccess extends VideoDataState {}

class FetchVideosForCurrrentUserFailure extends VideoDataState {
  final String errMessage;

  FetchVideosForCurrrentUserFailure({required this.errMessage});
}

class FetchVideosForCurrentUserLoading extends VideoDataState {}

class FetchVideosForAnotherUserSuccess extends VideoDataState {}

class FetchVideosAnotherForUserFailure extends VideoDataState {
  final String errMessage;

  FetchVideosAnotherForUserFailure({required this.errMessage});
}

class FetchVideosAnotherForUserLoading extends VideoDataState {}

//? fetchAllVideos

class FetchAllVideosSuccess extends VideoDataState {}

class FetchAllVideosFailure extends VideoDataState {
  final String errMessage;

  FetchAllVideosFailure({required this.errMessage});
}

class FetchAllVideosLoading extends VideoDataState {}

class RemoveVideoSuccess1 extends VideoDataState {}

class RemoveVideoSuccess2 extends VideoDataState {}

class RemoveVideoLoading extends VideoDataState {}

class RemoveVideoFailure extends VideoDataState {
  final String errMessage;

  RemoveVideoFailure({required this.errMessage});
}

class RemoveVideoSuccess extends VideoDataState {}

//! Comments Section

class ClearAllCommentsSuccess extends VideoDataState {}

class ClearAllCommentsLoading extends VideoDataState {}

class ClearAllCommentsFailure extends VideoDataState {
  final String errMessage;

  ClearAllCommentsFailure({required this.errMessage});
}

class ClearUpdateComments1 extends VideoDataState {}

class ClearUpdateComments2 extends VideoDataState {}

class AddCommentSuccess extends VideoDataState {}

class AddCommentFailure extends VideoDataState {
  final String errMessage;

  AddCommentFailure({required this.errMessage});
}

class AddCommentLoading extends VideoDataState {}

class RemoveCommentSuccess extends VideoDataState {}

class RemoveCommentFailure extends VideoDataState {
  final String errMessage;

  RemoveCommentFailure({required this.errMessage});
}

class RemoveCommentLoading extends VideoDataState {}

class FetchAllCommentsSuccess extends VideoDataState {}

class FetchAllCommentsFailure extends VideoDataState {
  final String errMessage;

  FetchAllCommentsFailure({required this.errMessage});
}

class FetchAllCommentsLoading extends VideoDataState {}

class AddLikeOnCommentSuccess extends VideoDataState {}

class AddLikeOnCommentFailure extends VideoDataState {
  final String errMessage;

  AddLikeOnCommentFailure({required this.errMessage});
}

class AddLikeOnCommentLoading extends VideoDataState {}

class RemoveLikeFromCommentSuccess extends VideoDataState {}

class RemoveLikeFromCommentFailure extends VideoDataState {
  final String errMessage;

  RemoveLikeFromCommentFailure({required this.errMessage});
}

class RemoveLikeFromCommentLoading extends VideoDataState {}

//! Likes Section
class AddLikeLoading extends VideoDataState {}

class AddLikeFailure extends VideoDataState {
  final String errMessage;

  AddLikeFailure({required this.errMessage});
}

class AddLikeSuccess extends VideoDataState {}

class RemoveLikeLoading extends VideoDataState {}

class RemoveLikeFailure extends VideoDataState {
  final String errMessage;

  RemoveLikeFailure({required this.errMessage});
}

class RemoveLikeSuccess extends VideoDataState {}

class FetchUserLikedSuccess extends VideoDataState {}

class FetchUserLikesFailure extends VideoDataState {
  final String errMessage;

  FetchUserLikesFailure({required this.errMessage});
}

class FetchUserLikesLoading extends VideoDataState {}

class FetchAllLikesSuccess extends VideoDataState {}

class FetchAllLikesFailure extends VideoDataState {
  final String errMessage;

  FetchAllLikesFailure({required this.errMessage});
}

class FetchAllLikesLoading extends VideoDataState {}



