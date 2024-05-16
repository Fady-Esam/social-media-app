import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  ShareCubit() : super(ShareInitial());
  var videosCollection = FirebaseFirestore.instance.collection('videos');
  Future<void> updateShareCounter({required String videoId}) async {
    var doc = await videosCollection.doc(videoId).get();
    int count = doc.data()!['shareCount'] as int;
    await videosCollection.doc(videoId).update({
      'shareCount': ++count,
    });
    emit(ShareUpdatedSuccess());
  }
}
