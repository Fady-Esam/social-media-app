class LikeModel {
  final String videoId;
  final String userAddedLikeId;

  LikeModel({
    required this.videoId,
    required this.userAddedLikeId,
  });
  factory LikeModel.fromJson(Map<String, dynamic> data) {
    return LikeModel(
      videoId: data['videoId'],
      userAddedLikeId: data['userAddedLikeId'],
    );
  }
}
