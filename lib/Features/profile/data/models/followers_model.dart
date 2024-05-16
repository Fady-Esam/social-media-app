class FollowersModel {
  final String userIdWantToFollowOrUnFollowMe;
  final String userImageWantToFollowOrUnFollowMe;
  final String userNameWantToFollowOrUnFollowMe;

  FollowersModel({
    required this.userIdWantToFollowOrUnFollowMe,
    required this.userImageWantToFollowOrUnFollowMe,
    required this.userNameWantToFollowOrUnFollowMe,
  });
  factory FollowersModel.fromJson(Map<String, dynamic> data) {
    return FollowersModel(
        userIdWantToFollowOrUnFollowMe: data['userIdWantToFollowOrUnFollowMe'],
        userImageWantToFollowOrUnFollowMe: data['userImageWantToFollowOrUnFollowMe'],
        userNameWantToFollowOrUnFollowMe: data['userNameWantToFollowOrUnFollowMe'],
    );
  }
}
