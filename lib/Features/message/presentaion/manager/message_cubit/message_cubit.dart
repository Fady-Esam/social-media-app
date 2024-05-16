import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/message/data/models/chat_model.dart';
import '../../../../../secrets/app_secrets.dart';
import 'message_state.dart';
import 'package:http/http.dart' as http;

class MessageCubit extends Cubit<MessageState> {
  MessageCubit() : super(MessageInitial());
  var users = FirebaseFirestore.instance.collection('users');
  Future<void> sendChatToFirebase({
    required ChatModel chatModel,
  }) async {
    try {
      emit(SendChatToFirebaseLoading());
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(chatModel.userIdMessageWith)
          .set({
        'userIdMessageWith': chatModel.userIdMessageWith,
        'userNameMessageWith': chatModel.userNameMessageWith,
        'userImageMessageWith': chatModel.userImageMessageWith,
        'currentUserName': chatModel.currentUserName,
        'currentUserImage': chatModel.currentUserImage,
        'messageList': chatModel.messageList,
      });
      await users
          .doc(chatModel.userIdMessageWith)
          .collection('messages')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userIdMessageWith': FirebaseAuth.instance.currentUser!.uid,
        'userNameMessageWith': chatModel.currentUserName,
        'userImageMessageWith': chatModel.currentUserImage,
        'currentUserName': chatModel.userNameMessageWith,
        'currentUserImage': chatModel.userImageMessageWith,
        'messageList': chatModel.messageList,
      });
      await users.doc(FirebaseAuth.instance.currentUser!.uid).update({
        'userChatsIds': FieldValue.arrayUnion([
          {
            'userIdMessageWith': chatModel.userIdMessageWith,
          }
        ])
      });
      await users.doc(chatModel.userIdMessageWith).update({
        'userChatsIds': FieldValue.arrayUnion([
          {
            'userIdMessageWith': FirebaseAuth.instance.currentUser!.uid,
          }
        ])
      });
      emit(SendChatToFirebaseSuccess());
    } on FirebaseException catch (e) {
      emit(SendChatToFirebaseFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(SendChatToFirebaseFailure(errMessage: e.toString()));
    }
  }

  List<String> userIdsChats = [];
  Future<void> fetchUserIdsChatsCurrent() async {
    var doc = await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
    List<dynamic> userIds = doc['userChatsIds'];
    userIdsChats.clear();
    for (int i = 0; i < userIds.length; i++) {
      userIdsChats.add(userIds[i]['userIdMessageWith']);
    }
    emit(FetchUsersChatsIdsSuccess());
  }

  Future<void> sendMessageItemList({
    required String userIdMessageWith,
    required String currentUserName,
    required String userImageMessageWith,
    required String currentUserImage,
    required String message,
    required String messageType,
    required String userTokenMessageWith,
    String? thumbnail,
  }) async {
    emit(SendMessageLoading());
    try {
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(userIdMessageWith)
          .update({
        'messageList': FieldValue.arrayUnion([
          {
            'message': message,
            'thumbnail': thumbnail,
            'messageType': messageType,
            'userIdSentMessage': FirebaseAuth.instance.currentUser!.uid,
            'userImageMessageWith': userImageMessageWith,
            'sentAt': DateTime.now().toString(),
          }
        ])
      });
      await users
          .doc(userIdMessageWith)
          .collection('messages')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'messageList': FieldValue.arrayUnion([
          {
            'message': message,
            'thumbnail': thumbnail,
            'messageType': messageType,
            'userIdSentMessage': FirebaseAuth.instance.currentUser!.uid,
            'userImageMessageWith': currentUserImage,
            'sentAt': DateTime.now().toString(),
          }
        ])
      });
      await sendNotifictaionForChatting(
        userTokenMessageWith: userTokenMessageWith,
        userNameSentMessage: currentUserName,
        message: message,
        messageType: messageType,
      );
      emit(SendMessageSuccess());
    } on FirebaseException catch (e) {
      emit(SendMessageFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString()));
    }
  }

  Future<void> deleteMessage({
    required String userIdMessageWith,
    required MessageModelItem messageModelItem,
  }) async {
    emit(DeleteMessageLoading());
    try {
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(userIdMessageWith)
          .update({
        'messageList': FieldValue.arrayRemove([
          {
            'message': messageModelItem.message,
            'thumbnail': messageModelItem.thumbnail,
            'messageType': messageModelItem.messageType,
            'userIdSentMessage': messageModelItem.userIdSentMessage,
            'userImageMessageWith': messageModelItem.userImageMessageWith,
            'sentAt': messageModelItem.sentAt,
          }
        ])
      });
      emit(DeleteMessageSuccess());
    } on FirebaseException catch (e) {
      emit(DeleteMessageFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(DeleteMessageFailure(errMessage: e.toString()));
    }
  }

  bool isAvailable = true;
  Future<void> deleteChat({required String useUUid}) async {
    isAvailable = false;
    emit(Update1Success());
    try {
      emit(DeleteChatLoading());
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(useUUid)
          .update({
        'messageList': [],
      });
      isAvailable = true;
      emit(DeleteChatSuccess());
    } on FirebaseException catch (e) {
      emit(DeleteChatFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(DeleteChatFailure(errMessage: e.toString()));
    }
  }

  bool isAval = true;
  Future<void> clearAllChats() async {
    isAval = false;
    emit(Update3Success());
    try {
      emit(ClearAllChatsLoading());
      var querySnapshot = await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        await users
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('messages')
            .doc(querySnapshot.docs[i]['userIdMessageWith'])
            .update({
          'messageList': [],
        });
      }
      isAval = true;
      emit(ClearAllChatsSuccess());
    } on FirebaseException catch (e) {
      emit(ClearAllChatsFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(ClearAllChatsFailure(errMessage: e.toString()));
    }
  }

  int numberOfNotEmptyMessagesList = 0;

  Future<void> fetchNumberOfNotEmptyMessagesList() async {
    await fetchUserIdsChatsCurrent();
    if (userIdsChats.isEmpty) {
      return;
    }
    users
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('messages')
        .snapshots()
        .listen((event) {
      numberOfNotEmptyMessagesList = 0;
      for (var e in event.docs) {
        if (e['messageList'].isNotEmpty) {
          ++numberOfNotEmptyMessagesList;
        }
      }
      emit(FetchNumberOfNotEmptyMessagesList());
    });
  }

  List<dynamic> allMessagesList = [];
  void fetchMessagesOfChat({required String userId}) {
    if (!isAvailable || !isAval) {
      return;
    }
    try {
      emit(FetchMessagesForCurrentUserLoading());
      users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(userId)
          .snapshots()
          .listen((event) {
        allMessagesList.clear();
        for (int i = event['messageList'].length - 1; i >= 0; i--) {
          allMessagesList
              .add(MessageModelItem.fromJson(event['messageList'][i]));
        }
        emit(FetchMessagesForCurrentUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FetchMessagesForCurrentUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FetchMessagesForCurrentUserFailure(errMessage: e.toString()));
    }
  }

  Future<void> clearAllMessages({required String userUUid}) async {
    emit(ClearAllMessagesLoading());
    try {
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(userUUid)
          .update({'messageList': []});
      emit(ClearAllMessagesSuccess());
    } on FirebaseException catch (e) {
      emit(ClearAllMessagesFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(ClearAllMessagesFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> chats = [];
  void fetchChats() async {
    await fetchUserIdsChatsCurrent();
    if (userIdsChats.isEmpty) {
      return;
    }
    emit(FetchChatsLoading());
    try {
      users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .snapshots()
          .listen((event) {
        chats.clear();
        for (int i = event.docs.length - 1; i >= 0; i--) {
          chats.add(ChatModel.fromJson(event.docs[i].data()));
        }
        emit(FetchChatsSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FetchChatsFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FetchChatsFailure(errMessage: e.toString()));
    }
  }

  Future<bool> isAvailbilityChatCurrent({required String userIdToCheck}) async {
    await fetchUserIdsChatsCurrent();
    for (int i = 0; i < userIdsChats.length; i++) {
      if (userIdsChats[i] == userIdToCheck) {
        return true;
      }
    }
    return false;
  }

  Future<void> sendNotifictaionForChatting({
    required String userTokenMessageWith,
    required String userNameSentMessage,
    required String message,
    required String messageType,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'key=${AppSecrets.apiKey}'
      };
      final body = {
        "to": userTokenMessageWith,
        "notification": {
          "title": userNameSentMessage,
          "body": messageType == 'text' ? message : messageType,
        }
      };
      var res = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headers,
        body: jsonEncode(body),
      );
      log(res.body);
    } catch (e) {
      log('error => $e');
    }
  }
}
