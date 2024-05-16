import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';

// import '../../../../message/presentaion/manager/message_cubit/tempCodeRunnerFile.dart';
import '../../../../../secrets/app_secrets.dart';
import '../../../data/models/followers_model.dart';
import '../../../data/models/following_model.dart';
import 'follow_state.dart';
import 'package:http/http.dart' as http;

class FollowCubit extends Cubit<FollowState> {
  FollowCubit() : super(FollowInitial());
  var users = FirebaseFirestore.instance.collection('users');
  Future<void> addFollow({
    required String userIdYouWantToFollow,
    required String userImageIWantToFollowOrUnFollow,
    required String userNameIWantToFollowOrUnFollow,
    required BuildContext context,
  }) async {
    emit(FollowAddLoading());
    try {
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
      await users.doc(FirebaseAuth.instance.currentUser!.uid).update({
        'followings': FieldValue.arrayUnion([
          {
            'userIdIWantToFollowOrUnFollow': userIdYouWantToFollow,
            'userImageIWantToFollowOrUnFollow':
                userImageIWantToFollowOrUnFollow,
            'userNameIWantToFollowOrUnFollow': userNameIWantToFollowOrUnFollow,
          },
        ]),
      });
      await users.doc(userIdYouWantToFollow).update({
        'followers': FieldValue.arrayUnion([
          {
            'userIdWantToFollowOrUnFollowMe':
                FirebaseAuth.instance.currentUser!.uid,
            'userImageWantToFollowOrUnFollowMe':
                BlocProvider.of<UserDataCubit>(context).userModel!.image,
            'userNameWantToFollowOrUnFollowMe':
                BlocProvider.of<UserDataCubit>(context).userModel!.name,
          },
        ]),
      });
      await sendNotifictaionForFollow(
          context: context, userIdYouWantToFollow: userIdYouWantToFollow);
      emit(FollowAddSuccess());
    } on FirebaseException catch (e) {
      emit(FollowAddFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FollowAddFailure(errMessage: e.toString()));
    }
  }

  Future<void> removeFollow({
    required String userIdYouWantToUnFollow,
    required String userImageIWantToFollowOrUnFollow,
    required String userNameIWantToFollowOrUnFollow,
    required BuildContext context,
  }) async {
    emit(FollowRemoveLoading());
    try {
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
      await users.doc(FirebaseAuth.instance.currentUser!.uid).update({
        'followings': FieldValue.arrayRemove([
          {
            'userIdIWantToFollowOrUnFollow': userIdYouWantToUnFollow,
            'userImageIWantToFollowOrUnFollow':
                userImageIWantToFollowOrUnFollow,
            'userNameIWantToFollowOrUnFollow': userNameIWantToFollowOrUnFollow,
          },
        ]),
      });
      await users.doc(userIdYouWantToUnFollow).update({
        'followers': FieldValue.arrayRemove([
          {
            'userIdWantToFollowOrUnFollowMe':
                FirebaseAuth.instance.currentUser!.uid,
            'userImageWantToFollowOrUnFollowMe':
                BlocProvider.of<UserDataCubit>(context).userModel!.image,
            'userNameWantToFollowOrUnFollowMe':
                BlocProvider.of<UserDataCubit>(context).userModel!.name,
          },
        ]),
      });
      emit(FollowRemoveSuccess());
    } on FirebaseException catch (e) {
      emit(FollowRemoveFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FollowRemoveFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> followersForCurrentUser = [];
  void fetchFollowersForCurrentUser() {
    emit(FollowFetchFollowersForCurrentUserLoading());
    try {
      users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((event) {
        followersForCurrentUser.clear();
        for (int i = 0; i < event['followers'].length; i++) {
          followersForCurrentUser
              .add(FollowersModel.fromJson(event['followers'][i]));
        }
        emit(FollowFetchFollowersForCurrentUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FollowFetchFollowersForCurrentUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FollowFetchFollowersForCurrentUserFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> followingsForCurrentUser = [];

  void fetchFollowingsForCurrentUser() async {
    emit(FollowFetchFollowingForCurrentUserLoading());
    try {
      users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((event) {
        followingsForCurrentUser.clear();
        for (int i = 0; i < event['followings'].length; i++) {
          followingsForCurrentUser
              .add(FollowingModel.fromJson(event['followings'][i]));
        }
        emit(FollowFetchFollowingForCurrentUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FollowFetchFollowingForCurrentUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FollowFetchFollowingForCurrentUserFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> followersForAnotherUser = [];
  void fetchFollowersForAnotherUser({required String userIdToFetchFollowers}) {
    emit(FollowFetchFollowersForAnotherUserLoading());
    try {
      users.doc(userIdToFetchFollowers).snapshots().listen((event) {
        followersForAnotherUser.clear();
        for (var e in event['followers']) {
          followersForAnotherUser.add(FollowersModel.fromJson(e));
        }
        emit(FollowFetchFollowersForAnotherUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FollowFetchFollowersForAnotherUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FollowFetchFollowersForAnotherUserFailure(errMessage: e.toString()));
    }
  }

  List<dynamic> followingsForAnotherUser = [];

  void fetchFollowingsForAnotherUser({required String userUuid}) async {
    emit(FollowFetchFollowingForAnotherUserLoading());
    try {
      users.doc(userUuid).snapshots().listen((event) {
        followingsForAnotherUser.clear();
        for (int i = 0; i < event['followings'].length; i++) {
          followingsForAnotherUser
              .add(FollowingModel.fromJson(event['followings'][i]));
        }
        emit(FollowFetchFollowingForAnotherUserSuccess());
      });
    } on FirebaseException catch (e) {
      emit(FollowFetchFollowingForAnotherUserFailure(errMessage: e.code));
    } on Exception catch (e) {
      emit(FollowFetchFollowingForAnotherUserFailure(errMessage: e.toString()));
    }
  }

  bool isFollowing() {
    for (int i = 0; i < followersForAnotherUser.length; i++) {
      if (followersForAnotherUser[i].userIdWantToFollowOrUnFollowMe ==
          FirebaseAuth.instance.currentUser!.uid) {
        return true;
      }
    }
    return false;
  }

  bool isTheCurrenUserFollowing({required String userUUid}) {
    for (int i = 0; i < followingsForCurrentUser.length; i++) {
      if (followingsForCurrentUser[i].userIdIWantToFollowOrUnFollow ==
          userUUid) {
        return true;
      }
    }
    return false;
  }

  Future<void> sendNotifictaionForFollow({
    required String userIdYouWantToFollow,
    required BuildContext context,
  }) async {
    try {
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
      UserModel? currentUser =
          BlocProvider.of<UserDataCubit>(context).userModel;
      await BlocProvider.of<UserDataCubit>(context)
          .fetchUserData(uuid: userIdYouWantToFollow);
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
            "body": '${currentUser.name} Followed You',
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
