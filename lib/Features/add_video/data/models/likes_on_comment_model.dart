class LikesOnCommentModel {
  final String videoId;
  final String commentId;
  final String userId;

  LikesOnCommentModel({
    required this.videoId,
    required this.commentId,
    required this.userId,
  });
  factory LikesOnCommentModel.fromJson(Map<String, dynamic> data) {
    return LikesOnCommentModel(
      videoId: data['videoId'],
      commentId: data['commentId'],
      userId: data['userId'],
    );
  }
}
