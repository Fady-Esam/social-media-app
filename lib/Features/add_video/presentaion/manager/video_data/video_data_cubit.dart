import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/add_video/data/models/video_model.dart';
import '../../../../../secrets/app_secrets.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/like_model.dart';
import '../../../data/models/likes_on_comment_model.dart';
import 'video_data_state.dart';
import 'package:http/http.dart' as http;

class VideoDataCubit extends Cubit<VideoDataState> {
  var videosCollection = FirebaseFirestore.instance.collection('videos');
  VideoDataCubit() : super(VideoDataInitial());
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addVideoData({
    required VideoModel videoModel,
  }) async {
    emit(AddVideoDataLoading());
    try {
      videosCollection.doc(videoModel.videoId).set({
        'userName': videoModel.userName,
        'userImage': videoModel.userImage,
        'userId': videoModel.userId,
        'videoId': videoModel.videoId,
        'song': videoModel.song,
        'caption': videoModel.caption,
        'video': videoModel.video,
        'thumbnail': videoModel.thumbnail,
        'likes': videoModel.likes,
        'shareCount': videoModel.shareCount,
      });
      emit(AddVideoDataSuccess());
    } on FirebaseException catch (e) {
      emit(AddVideoDataFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(AddVideoDataFailure(errMessage: e.toString()));
    }
  }

  bool isVideoRemoved = false;

  Future<void> removeVideo({required String videoId}) async {
    isVideoRemoved = true;
    emit(RemoveVideoSuccess1());
    try {
      emit(RemoveVideoLoading());
      await videosCollection.doc(videoId).delete();
      isVideoRemoved = false;
      emit(RemoveVideoSuccess());
    } on FirebaseException catch (e) {
      emit(RemoveVideoFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(RemoveVideoFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> allVideos = [];

  void fetchAllVideos() {
    if (isVideoRemoved) {
      return;
    }
    videosCollection.snapshots().listen((event) {
      allVideos.clear();
      for (int i = event.docs.length - 1; i >= 0; i--) {
        allVideos.add(VideoModel.formJson(event.docs[i].data()));
      }
      emit(FetchAllVideosSuccess());
    });
  }

  List<dynamic> currentUserVideos = [];

  void fetchVideosForCurrentUser() {
    if (isVideoRemoved) {
      return;
    }
    emit(FetchVideosForCurrentUserLoading());
    try {
      videosCollection.snapshots().listen((event) {
        currentUserVideos.clear();
        for (int i = event.docs.length - 1; i >= 0; i--) {
          if (event.docs[i]['userId'] ==
              FirebaseAuth.instance.currentUser!.uid) {
            currentUserVideos.add(VideoModel.formJson(event.docs[i].data()));
          }
        }
        emit(FetchVideosForCurrrentUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FetchVideosForCurrrentUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FetchVideosForCurrrentUserFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> anotherUserVideos = [];
  void fetchVideosForAnotherUser({required String userUuid}) {
    emit(FetchVideosAnotherForUserLoading());
    try {
      videosCollection.snapshots().listen((event) {
        anotherUserVideos.clear();
        for (int i = event.docs.length - 1; i >= 0; i--) {
          if (event.docs[i]['userId'] == userUuid) {
            anotherUserVideos.add(VideoModel.formJson(event.docs[i].data()));
          }
        }
        emit(FetchVideosForAnotherUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FetchVideosAnotherForUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FetchVideosAnotherForUserFailure(errMessage: e.toString()));
    }
  }

  //! Comments Section
  Future<void> addAComment(
      {required CommentModel commentModel,
      required BuildContext context,
      required String userIdUploadedVideo}) async {
    emit(AddCommentLoading());
    try {
      videosCollection
          .doc(commentModel.videoId)
          .collection('comments')
          .doc(commentModel.commentId)
          .set({
        'commentText': commentModel.commentText,
        'commentId': commentModel.commentId,
        'videoId': commentModel.videoId,
        'userId': commentModel.userId,
        'userName': commentModel.userName,
        'userImage': commentModel.userImage,
        'timeAgo': commentModel.timeAgo.toString(),
        'likesOnComment': commentModel.likesOnComment,
      });
      await sendNotifictaionForCommentOnVideo(
        userIdUploadedVideo: userIdUploadedVideo,
        context: context,
        comment: commentModel.commentText,
      );
      emit(AddCommentSuccess());
    } on FirebaseException catch (e) {
      emit(AddCommentFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(AddCommentFailure(errMessage: e.toString()));
    }
  }

  Future<void> removeComment({required CommentModel commentModel}) async {
    emit(RemoveCommentLoading());
    try {
      await videosCollection
          .doc(commentModel.videoId)
          .collection('comments')
          .doc(commentModel.commentId)
          .delete();
      emit(RemoveCommentSuccess());
    } on FirebaseException catch (e) {
      emit(RemoveCommentFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(RemoveCommentFailure(errMessage: e.toString()));
    }
  }

  bool isCommentsCleared = false;

  Future<void> clearAllComments({required String videoId}) async {
    isCommentsCleared = true;
    emit(ClearUpdateComments1());
    try {
      emit(ClearAllCommentsLoading());
      var qurey =
          await videosCollection.doc(videoId).collection('comments').get();
      for (var e in qurey.docs) {
        await e.reference.delete();
      }
      isCommentsCleared = false;
      emit(ClearAllCommentsSuccess());
    } on FirebaseException catch (e) {
      emit(ClearAllCommentsFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(ClearAllCommentsFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> allCommments = [];
  void fetchAllComments({required String videoId}) {
    emit(FetchAllCommentsLoading());
    if (isVideoRemoved || isCommentsCleared) {
      return;
    }
    try {
      videosCollection
          .doc(videoId)
          .collection('comments')
          .orderBy('timeAgo', descending: true)
          .snapshots()
          .listen((event) {
        allCommments.clear();
        if (isVideoRemoved || isCommentsCleared) {
          return;
        }
        for (int i = 0; i < event.docs.length; i++) {
          allCommments.add(CommentModel.fromJson(event.docs[i].data()));
        }
        emit(FetchAllCommentsSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FetchAllCommentsFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FetchAllCommentsFailure(errMessage: e.toString()));
    }
  }

  Future<void> addLikesOnComment(
      {required LikesOnCommentModel likesOnCommentModel,
      required BuildContext context,
      required String userIdAddedComment}) async {
    emit(AddLikeOnCommentLoading());
    try {
      await videosCollection
          .doc(likesOnCommentModel.videoId)
          .collection('comments')
          .doc(likesOnCommentModel.commentId)
          .update({
        'likesOnComment': FieldValue.arrayUnion([
          {
            'videoId': likesOnCommentModel.videoId,
            'commentId': likesOnCommentModel.commentId,
            'userId': likesOnCommentModel.userId,
          }
        ])
      });
      await sendNotifictaionForLikesOnComment(
        userIdAddedComment: userIdAddedComment,
        context: context,
      );
      emit(AddLikeOnCommentSuccess());
    } on FirebaseException catch (e) {
      emit(AddLikeOnCommentFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(AddLikeOnCommentFailure(errMessage: e.toString()));
    }
  }

  Future<void> removeLikeFromComment(
      {required LikesOnCommentModel likesOnCommentModel}) async {
    emit(RemoveLikeFromCommentLoading());
    try {
      await videosCollection
          .doc(likesOnCommentModel.videoId)
          .collection('comments')
          .doc(likesOnCommentModel.commentId)
          .update({
        'likesOnComment': FieldValue.arrayRemove([
          {
            'videoId': likesOnCommentModel.videoId,
            'commentId': likesOnCommentModel.commentId,
            'userId': likesOnCommentModel.userId,
          }
        ])
      });
      emit(RemoveLikeFromCommentSuccess());
    } on FirebaseException catch (e) {
      emit(RemoveLikeFromCommentFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(RemoveLikeFromCommentFailure(errMessage: e.toString()));
    }
  }

  bool isAddedLikeOnComment({required String commentId}) {
    for (int i = 0; i < allCommments.length; i++) {
      if (allCommments[i].commentId == commentId) {
        for (int j = 0; j < allCommments[i].likesOnComment.length; j++) {
          if (allCommments[i].likesOnComment[j]['userId'] == userId) {
            return true;
          }
        }
      }
    }
    return false;
  }

  //! Likes Section
  Future<void> addLike(
      {required LikeModel likeModel,
      required BuildContext context,
      required String userIdUploadedVideo}) async {
    emit(AddLikeLoading());
    try {
      await videosCollection.doc(likeModel.videoId).update({
        'likes': FieldValue.arrayUnion([
          {
            'videoId': likeModel.videoId,
            'userAddedLikeId': likeModel.userAddedLikeId,
          }
        ])
      });
      await sendNotifictaionForLikeOnVideo(
        userIdUploadedVideo: userIdUploadedVideo,
        context: context,
      );
      emit(AddLikeSuccess());
    } on FirebaseException catch (e) {
      emit(AddLikeFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(AddLikeFailure(errMessage: e.toString()));
    }
  }

  Future<void> removeLike({required LikeModel likeModel}) async {
    emit(RemoveLikeLoading());
    try {
      await videosCollection.doc(likeModel.videoId).update({
        'likes': FieldValue.arrayRemove([
          {
            'videoId': likeModel.videoId,
            'userAddedLikeId': likeModel.userAddedLikeId,
          }
        ])
      });
      emit(RemoveLikeSuccess());
    } on FirebaseException catch (e) {
      emit(RemoveLikeFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(RemoveLikeFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> allLikes = [];

  void fetchLikes({required String videoId}) {
    if (isVideoRemoved) {
      return;
    }
    videosCollection.doc(videoId).snapshots().listen((event) {
      allLikes.clear();
      if (isVideoRemoved) {
        return;
      }
      for (var e in event['likes']) {
        allLikes.add(LikeModel.fromJson(e));
      }
      emit(FetchAllLikesSuccess());
    });
  }

  List<dynamic> currentUserLikes = [];
  void fetchCurrentUserLikes({required String useruuid}) {
    emit(FetchUserLikesLoading());
    try {
      videosCollection.snapshots().listen((event) {
        currentUserLikes.clear();
        for (var e in event.docs) {
          for (int i = 0; i < e['likes'].length; i++) {
            if (e['likes'][i]['userAddedLikeId'] == useruuid) {
              currentUserLikes.add(LikeModel.fromJson(e['likes'][i]));
            }
          }
        }
        emit(FetchUserLikedSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FetchUserLikesFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FetchUserLikesFailure(errMessage: e.toString()));
    }
  }

  bool isLikeAdded() {
    for (int i = 0; i < allLikes.length; i++) {
      if (allLikes[i].userAddedLikeId == userId) {
        return true;
      }
    }
    return false;
  }

  Future<void> sendNotifictaionForLikeOnVideo({
    required String userIdUploadedVideo,
    required BuildContext context,
  }) async {
    try {
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
      UserModel? currentUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: userIdUploadedVideo);
      UserModel? anotherUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      if (currentUser != null && anotherUser != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization':
              'key=${AppSecrets.apiKey}'
        };
        final body = {
          "to": anotherUser.token,
          "notification": {
            "body": '${currentUser.name} added like ❤️ on your video',
          }
        };
        var res = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers,
          body: jsonEncode(body),
        );
        log(res.body);
      }
    } catch (e) {
      log('error = $e');
    }
  }

  Future<void> sendNotifictaionForCommentOnVideo({
    required String userIdUploadedVideo,
    required BuildContext context,
    required String comment,
  }) async {
    try {
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
      UserModel? currentUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: userIdUploadedVideo);
      UserModel? anotherUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      if (currentUser != null && anotherUser != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization':
              'key=${AppSecrets.apiKey}'
        };
        final body = {
          "to": anotherUser.token,
          "notification": {
            "title": '${currentUser.name} added Comment on your video',
            "body": comment,
          }
        };
        var res = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers,
          body: jsonEncode(body),
        );
        log(res.body);
      }
    } catch (e) {
      log('error = $e');
    }
  }

  Future<void> sendNotifictaionForLikesOnComment({
    required String userIdAddedComment,
    required BuildContext context,
  }) async {
    try {
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
      UserModel? currentUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: userIdAddedComment);
      UserModel? anotherUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      if (currentUser != null && anotherUser != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization':
              'key=${AppSecrets.apiKey}'
        };
        final body = {
          "to": anotherUser.token,
          "notification": {
            "body": '${currentUser.name} added like ❤️ on your comment',
          }
        };
        var res = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers,
          body: jsonEncode(body),
        );
        log(res.body);
      }
    } catch (e) {
      log('error = $e');
    }
  }
}
