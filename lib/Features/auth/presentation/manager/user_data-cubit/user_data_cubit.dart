import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_model.dart';
import 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  UserDataCubit() : super(UserDataInitial());
  var users = FirebaseFirestore.instance.collection('users');
  Future<void> sendUserData({required UserModel userModel}) async {
    await users.doc(userModel.uid).set({
      'uid': userModel.uid,
      'token': userModel.token,
      'name': userModel.name,
      'email': userModel.email,
      'image': userModel.image,
      'followers': userModel.followers,
      'followings': userModel.followings,
      'userChatsIds': userModel.userChatsIds,
    });
    emit(SendUserDataSuccess());
  }

  UserModel? userModel;
  Future<void> fetchUserData({required String uuid}) async {
    emit(FetchUserDataLoading());
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await users.doc(uuid).get();
      userModel = UserModel.formJson(doc.data()!);
      emit(FetchUserDataSuccess());
    } on FirebaseException catch (e) {
      FetchUserDataFailure(errMessage: e.code);
    } on Exception catch (e) {
      emit(FetchUserDataFailure(errMessage: e.toString()));
    }
  }

}
