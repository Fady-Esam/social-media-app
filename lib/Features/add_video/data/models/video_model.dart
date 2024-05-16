
class VideoModel {
  final String userName;
  final String userImage;
  final String userId;
  final String videoId;
  final String song;
  final String caption;
  final String video;
  final String thumbnail;
  final List<dynamic> likes; 
  final int shareCount;

  VideoModel({
    required this.userName,
    required this.userImage,
    required this.userId,
    required this.videoId,
    required this.song,
    required this.caption,
    required this.video,
    required this.thumbnail,
    required this.likes,
    required this.shareCount,
  });
  factory VideoModel.formJson(Map<String, dynamic> data) {
    return VideoModel(
      userName: data['userName'],
      userImage: data['userImage'],
      userId: data['userId'],
      videoId: data['videoId'],
      song: data['song'],
      caption: data['caption'],
      video: data['video'],
      thumbnail: data['thumbnail'],
      likes: data['likes'],
      shareCount: data['shareCount'],
    );
  }
}
