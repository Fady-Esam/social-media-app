class FollowingModel {
  final String userIdIWantToFollowOrUnFollow;
  final String userImageIWantToFollowOrUnFollow;
  final String userNameIWantToFollowOrUnFollow;

  FollowingModel({
    required this.userIdIWantToFollowOrUnFollow,
    required this.userImageIWantToFollowOrUnFollow,
    required this.userNameIWantToFollowOrUnFollow,
  });
  factory FollowingModel.fromJson(Map<String, dynamic> data) {
    return FollowingModel(
      userIdIWantToFollowOrUnFollow: data['userIdIWantToFollowOrUnFollow'],
      userImageIWantToFollowOrUnFollow: data['userImageIWantToFollowOrUnFollow'],
      userNameIWantToFollowOrUnFollow: data['userNameIWantToFollowOrUnFollow'],
    );
  }
}
