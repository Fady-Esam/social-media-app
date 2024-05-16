class ChatModel {
  final String userIdMessageWith;
  final String userNameMessageWith;
  final String userImageMessageWith;
  final String currentUserName;
  final String currentUserImage;
  final List<dynamic> messageList;

  ChatModel({
    required this.userIdMessageWith,
    required this.userNameMessageWith,
    required this.userImageMessageWith,
    required this.currentUserName,
    required this.currentUserImage,
    required this.messageList,
  });
  factory ChatModel.fromJson(Map<String, dynamic> data) {
    return ChatModel(
      userIdMessageWith: data['userIdMessageWith'],
      userNameMessageWith: data['userNameMessageWith'],
      userImageMessageWith: data['userImageMessageWith'],
      currentUserName: data['currentUserName'],
      currentUserImage: data['currentUserImage'],
      messageList:
          data['messageList'].map((e) => MessageModelItem.fromJson(e)).toList(),
    );
  }
}

class MessageModelItem {
  final String message;
  final String? thumbnail;
  final String messageType;
  final String userIdSentMessage;
  final String userImageMessageWith;
  final String sentAt;

  MessageModelItem({
    required this.message,
    required this.thumbnail,
    required this.messageType,
    required this.userIdSentMessage,
    required this.userImageMessageWith,
    required this.sentAt,
  });

  factory MessageModelItem.fromJson(Map<String, dynamic> data) {
    return MessageModelItem(
      message: data['message'],
      thumbnail: data['thumbnail'],
      messageType: data['messageType'],
      userIdSentMessage: data['userIdSentMessage'],
      userImageMessageWith: data['userImageMessageWith'],
      sentAt: data['sentAt'],
    );
  }
}
