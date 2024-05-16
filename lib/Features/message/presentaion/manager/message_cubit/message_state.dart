class MessageState {}

class MessageInitial extends MessageState {}

class SendChatToFirebaseLoading extends MessageState {}

class SendChatToFirebaseFailure extends MessageState {
  final String errMessage;

  SendChatToFirebaseFailure({required this.errMessage});
}

class SendChatToFirebaseSuccess extends MessageState {}

class FetchMessagesForCurrentUserSuccess extends MessageState {}

class FetchMessagesForCurrentUserFailure extends MessageState {
  final String errMessage;

  FetchMessagesForCurrentUserFailure({required this.errMessage});
}

class FetchMessagesForCurrentUserLoading extends MessageState {}

class FetchChatsSuccess extends MessageState {}

class FetchChatsFailure extends MessageState {
  final String errMessage;

  FetchChatsFailure({required this.errMessage});
}

class FetchChatsLoading extends MessageState {}

class FetchUsersChatsIdsSuccess extends MessageState {}

class Update1Success extends MessageState {}

class Update3Success extends MessageState {}

class FetchNumberOfNotEmptyMessagesList extends MessageState {}

class ClearAllChatsSuccess extends MessageState {}

class ClearAllChatsFailure extends MessageState {
  final String errMessage;

  ClearAllChatsFailure({required this.errMessage});
}

class ClearAllChatsLoading extends MessageState {}

class DeleteChatSuccess extends MessageState {}

class DeleteChatFailure extends MessageState {
  final String errMessage;

  DeleteChatFailure({required this.errMessage});
}

class DeleteChatLoading extends MessageState {}

class SendMessageLoading extends MessageState {}

class SendMessageFailure extends MessageState {
  final String errMessage;

  SendMessageFailure({required this.errMessage});
}

class SendMessageSuccess extends MessageState {}

class DeleteMessageLoading extends MessageState {}

class DeleteMessageFailure extends MessageState {
  final String errMessage;

  DeleteMessageFailure({required this.errMessage});
}

class DeleteMessageSuccess extends MessageState {}

class ClearAllMessagesLoading extends MessageState {}

class ClearAllMessagesFailure extends MessageState {
  final String errMessage;

  ClearAllMessagesFailure({required this.errMessage});
}

class ClearAllMessagesSuccess extends MessageState {}
