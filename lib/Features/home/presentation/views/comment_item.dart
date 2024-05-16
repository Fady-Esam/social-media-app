
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/add_video/data/models/likes_on_comment_model.dart';
import 'package:tiktok/Features/profile/presentaion/views/profile_view.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../add_video/data/models/comment_model.dart';
import '../../../add_video/presentaion/manager/video_data/video_data_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.commentModel,
    required this.userPublishedVideoId,
  });

  final CommentModel commentModel;
  final String userPublishedVideoId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 6),
      child: ListTile(
        onTap: () async {
          await BlocProvider.of<UserDataCubit>(context)
              .fetchUserData(uuid: commentModel.userId);
          UserModel? userModel =
              BlocProvider.of<UserDataCubit>(context).userModel;
          if (userModel != null) {
            context.pushToView(
              view: ProfileView(anothUserUserModel: userModel),
            );
          }
        },
        onLongPress: commentModel.userId ==
                    FirebaseAuth.instance.currentUser!.uid ||
                userPublishedVideoId == FirebaseAuth.instance.currentUser!.uid
            ? () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 14),
                        const Text(
                          'Are you sure to delete this comment ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.popView(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                context.popView();
                                await BlocProvider.of<VideoDataCubit>(context)
                                    .removeComment(commentModel: commentModel);
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
            : null,
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            commentModel.userImage,
          ),
        ),
        title: Text(
          commentModel.userName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              commentModel.commentText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${timeago.format(commentModel.timeAgo)},  ${commentModel.likesOnComment.length} Likes',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        trailing: !BlocProvider.of<VideoDataCubit>(context)
                .isAddedLikeOnComment(commentId: commentModel.commentId)
            ? IconButton(
                onPressed: () async {
                  await BlocProvider.of<VideoDataCubit>(context)
                      .addLikesOnComment(
                        userIdAddedComment: commentModel.userId,
                        context: context,
                    likesOnCommentModel: LikesOnCommentModel(
                      videoId: commentModel.videoId,
                      commentId: commentModel.commentId,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  size: 24,
                ),
              )
            : IconButton(
                onPressed: () {
                  BlocProvider.of<VideoDataCubit>(context)
                      .removeLikeFromComment(
                    likesOnCommentModel: LikesOnCommentModel(
                      videoId: commentModel.videoId,
                      commentId: commentModel.commentId,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 24,
                ),
              ),
      ),
    );
  }
}
