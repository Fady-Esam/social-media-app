import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/data/models/user_model.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  var users = FirebaseFirestore.instance.collection('users');
  List<dynamic> usersList = [];

  void searchForUser({required String userName}) {
    users.snapshots().listen((event) {
      usersList.clear();
      for (var e in event.docs) {
        if (e['name'].toLowerCase().contains(userName.toLowerCase())) {
          usersList.add(UserModel.formJson(e.data()));
        }
        emit(SearchSuccess());
      }
    });
  }


}
