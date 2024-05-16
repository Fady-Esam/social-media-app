class CommentModel {
  final String commentText;
  final String commentId;
  final String videoId;
  final String userId;
  final String userName;
  final String userImage;
  final DateTime timeAgo;
  final List<dynamic> likesOnComment;

  CommentModel({
    required this.commentText,
    required this.commentId,
    required this.videoId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.timeAgo,
    required this.likesOnComment,
  });
  factory CommentModel.fromJson(Map<String, dynamic> data) {
    return CommentModel(
      commentText: data['commentText'],
      commentId: data['commentId'],
      videoId: data['videoId'],
      userId: data['userId'],
      userName: data['userName'],
      userImage: data['userImage'],
      timeAgo: DateTime.parse(data['timeAgo']),
      likesOnComment: data['likesOnComment'],
    );
  }
}
