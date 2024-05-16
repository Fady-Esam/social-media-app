import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/add_video/data/models/like_model.dart';
import 'package:tiktok/Features/add_video/data/models/video_model.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/share/share_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/Features/home/presentation/views/comment_view.dart';
import 'package:tiktok/Features/profile/presentaion/views/profile_view.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/functions/show_snack_bar_fun.dart';
import '../../add_video/presentaion/manager/video_data/video_data_cubit.dart';
import '../../add_video/presentaion/manager/video_data/video_data_state.dart';

class VideoPlayerItem extends StatefulWidget {
  const VideoPlayerItem({
    super.key,
    required this.videoModel,
  });

  final VideoModel videoModel;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  bool isLoading = true;
  @override
  void initState() {
  
    super.initState();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoModel.video));
    // setUpVideoController().then((_) => setState(() {
    //       isLoading = false;
    //     }));
    BlocProvider.of<VideoDataCubit>(context)
        .fetchLikes(videoId: widget.videoModel.videoId);
    BlocProvider.of<VideoDataCubit>(context)
        .fetchAllComments(videoId: widget.videoModel.videoId);
  }

  Future<void> setUpVideoController() async {
    await videoPlayerController.initialize();
    await videoPlayerController.play();
    await videoPlayerController.setVolume(1);
    await videoPlayerController.setLooping(false);
  }

  void listenToVideo() {
    videoPlayerController.addListener(() async {
      if (videoPlayerController.value.isCompleted) {
        await videoPlayerController.pause();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return /* isLoading
        ? const Center(child: CircularProgressIndicator())
        : */
        Container(
      height: size.height,
      width: size.width,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          VideoPlayer(
            videoPlayerController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 22,
                  top: MediaQuery.sizeOf(context).height * 0.8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.videoModel.userName,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.videoModel.caption,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 21,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.videoModel.song,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BlocBuilder<VideoDataCubit, VideoDataState>(
                builder: (context, state) {
                  return Container(
                    margin: EdgeInsets.only(
                      right: 22,
                      top: MediaQuery.sizeOf(context).height * 0.48,
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await BlocProvider.of<UserDataCubit>(context)
                                .fetchUserData(uuid: widget.videoModel.userId);
                            if (BlocProvider.of<UserDataCubit>(context)
                                    .userModel !=
                                null) {
                              context.pushToView(
                                view: ProfileView(
                                  anothUserUserModel:
                                      BlocProvider.of<UserDataCubit>(
                                    context,
                                  ).userModel,
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 33,
                              backgroundImage:
                                  NetworkImage(widget.videoModel.userImage),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (!BlocProvider.of<VideoDataCubit>(context)
                            .isLikeAdded())
                          IconButton(
                            onPressed: () async {
                              await BlocProvider.of<VideoDataCubit>(context)
                                  .addLike(
                                    context: context,
                                    userIdUploadedVideo: widget.videoModel.userId,
                                likeModel: LikeModel(
                                  videoId: widget.videoModel.videoId,
                                  userAddedLikeId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.favorite,
                              size: 40,
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () async {
                              await BlocProvider.of<VideoDataCubit>(
                                context,
                              ).removeLike(
                                likeModel: LikeModel(
                                  videoId: widget.videoModel.videoId,
                                  userAddedLikeId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.favorite,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        BlocBuilder<VideoDataCubit, VideoDataState>(
                          builder: (context, state) {
                            List<dynamic> likes =
                                BlocProvider.of<VideoDataCubit>(context)
                                    .allLikes;
                            return Text(
                              '${likes.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        IconButton(
                          onPressed: () {
                            context.pushToView(
                              view: CommmentView(
                                videoModel: widget.videoModel,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.message,
                            size: 40,
                          ),
                        ),
                        BlocBuilder<VideoDataCubit, VideoDataState>(
                          builder: (context, state) {
                            return Text(
                              '${BlocProvider.of<VideoDataCubit>(context).allCommments.length}',
                              // '6',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        IconButton(
                          onPressed: () async {
                            try {
                              await Share.share(widget.videoModel.video);
                              await BlocProvider.of<ShareCubit>(
                                context,
                              ).updateShareCounter(
                                videoId: widget.videoModel.videoId,
                              );
                            } catch (e) {
                              showSnackBarFun(
                                context: context,
                                text: 'Something went wrong ,Please try again',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.reply,
                            size: 40,
                          ),
                        ),
                        Text(
                          widget.videoModel.shareCount.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // const SizedBox(height: 12),
                        // CustomCircleAnimation(
                        //   image: widget.videoModel.userImage,
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
