import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tiktok/Features/add_video/data/models/comment_model.dart';
import 'package:tiktok/Features/add_video/data/models/video_model.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_state.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/core/functions/show_snack_bar_fun.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import 'package:uuid/uuid.dart';
import '../../../add_video/presentaion/manager/video_data/video_data_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import 'comment_item.dart';

class CommmentView extends StatefulWidget {
  const CommmentView({super.key, required this.videoModel});

  final VideoModel videoModel;

  @override
  State<CommmentView> createState() => _CommmentViewState();
}

class _CommmentViewState extends State<CommmentView> {
  var textController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  UserModel? userModel;
  bool isLoading = false;
  List<dynamic> allComments = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<VideoDataCubit>(context)
        .fetchAllComments(videoId: widget.videoModel.videoId);
    setState(() {
      allComments = BlocProvider.of<VideoDataCubit>(context).allCommments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoDataCubit, VideoDataState>(
      listener: (context, state) {
        if (state is FetchAllCommentsLoading ||
            state is ClearAllCommentsLoading ||
            state is RemoveCommentLoading) {
          isLoading = true;
        } else if (state is FetchAllCommentsFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is ClearAllCommentsFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is RemoveCommentFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is FetchAllCommentsSuccess ||
            state is ClearAllCommentsSuccess ||
            state is RemoveCommentSuccess) {
          isLoading = false;
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                BlocBuilder<VideoDataCubit, VideoDataState>(
                  builder: (context, state) {
                    allComments =
                        BlocProvider.of<VideoDataCubit>(context).allCommments;
                    if (widget.videoModel.userId ==
                            FirebaseAuth.instance.currentUser!.uid &&
                        allComments.isNotEmpty) {
                      return IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Are you sure to clear all comments ?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                          await BlocProvider.of<VideoDataCubit>(
                                                  context)
                                              .clearAllComments(
                                            videoId: widget.videoModel.videoId,
                                          );
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
                        },
                        icon: const Icon(
                          Icons.delete,
                          size: 26,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<VideoDataCubit, VideoDataState>(
                    builder: (context, state) {
                      allComments =
                          BlocProvider.of<VideoDataCubit>(context).allCommments;
                      return ListView.builder(
                        itemCount: allComments.length,
                        itemBuilder: (context, index) {
                          return CommentItem(
                            commentModel: allComments[index],
                            userPublishedVideoId: widget.videoModel.userId,
                          );
                        },
                      );
                    },
                  ),
                ),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Comment cannot be empty or spaces';
                              }
                              return null;
                            },
                            minLines: 1,
                            maxLines: 5,
                            controller: textController,
                            decoration: InputDecoration(
                              hintText: 'Comment',
                              hintStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await BlocProvider.of<UserDataCubit>(context)
                                  .fetchUserData(
                                uuid: FirebaseAuth.instance.currentUser!.uid,
                              );
                              setState(() {
                                userModel =
                                    BlocProvider.of<UserDataCubit>(context)
                                        .userModel;
                              });
                              await BlocProvider.of<VideoDataCubit>(context)
                                  .addAComment(
                                    context: context,
                                    userIdUploadedVideo: widget.videoModel.userId,
                                commentModel: CommentModel(
                                  commentText: textController.text,
                                  commentId: const Uuid().v4(),
                                  videoId: widget.videoModel.videoId,
                                  userId: userModel!.uid,
                                  userName: userModel!.name,
                                  userImage: userModel!.image,
                                  timeAgo: DateTime.now(),
                                  likesOnComment: [],
                                ),
                              );
                              textController.clear();
                            }
                          },
                          child: const Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}
