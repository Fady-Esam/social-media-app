import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tiktok/Features/add_video/data/models/video_model.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_cubit.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_state.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_state.dart';
import 'package:tiktok/Features/auth/presentation/views/widgets/custom_text_field.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/functions/show_snack_bar_fun.dart';

class ConfirmView extends StatefulWidget {
  const ConfirmView({
    super.key,
    required this.pickedVideo,
  });
  final File pickedVideo;

  @override
  State<ConfirmView> createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<ConfirmView> {
  late VideoPlayerController videoPlayerController;
  GlobalKey<FormState> formKey = GlobalKey();
  String song = '';
  String caption = '';
  Future<void> setUpVideoController() async {
    await videoPlayerController.initialize().then((_) => setState(() {}));
    await videoPlayerController.play();
    await videoPlayerController.setVolume(1);
    await videoPlayerController.setLooping(false);
  }

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(widget.pickedVideo);
    setUpVideoController();
  }

  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  late UserModel userModel;
  Future<File> compressedVideo({required String videoPath}) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file!;
  }

  Future<File> getThumbnail({required String videoPath}) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoDataCubit, VideoDataState>(
      listener: (context, state) {
        if (state is AddVideoDataSuccess) {
          isLoading = false;
          context.popView();
        } else if (state is AddVideoDataFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        }
      },
      builder: (context, state) {
        return BlocListener<UserDataCubit, UserDataState>(
          listener: (context, state) {
            if (state is FetchUserDataSuccess) {
              userModel = BlocProvider.of<UserDataCubit>(context).userModel!;
            } else if (state is FetchUserDataFailure) {
              isLoading = false;
              showSnackBarFun(
                context: context,
                text: 'Something went wrong, Please try again',
              );
            }
          },
          child: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await videoPlayerController.dispose();
                        context.popView();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Uploading Video',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.58,
                      width: double.infinity,
                      child: VideoPlayer(videoPlayerController),
                    ),
                    const SizedBox(height: 22),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CustomTextFormField(
                              hint: 'Song',
                              prefixIcon: Icons.music_note,
                              onChanged: (value) {
                                song = value;
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CustomTextFormField(
                              hint: 'Caption',
                              prefixIcon: Icons.closed_caption,
                              onChanged: (value) {
                                caption = value;
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.sizeOf(context).width * 0.41,
                                vertical: 14,
                              ),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await videoPlayerController.pause();
                                setState(() {
                                  isLoading = true;
                                });
                                await BlocProvider.of<UserDataCubit>(context)
                                    .fetchUserData(
                                        uuid: FirebaseAuth
                                            .instance.currentUser!.uid);
                                if (!isLoading) {
                                  return;
                                }
                                final File commpressedVd =
                                    await compressedVideo(
                                  videoPath: widget.pickedVideo.path,
                                );
                                Reference ref = FirebaseStorage.instance
                                    .ref()
                                    .child('videos')
                                    .child('${const Uuid().v4()}.mp4');
                                await ref.putFile(commpressedVd);
                                final String videoUrl =
                                    await ref.getDownloadURL();
                                final File thumbnail = await getThumbnail(
                                  videoPath: widget.pickedVideo.path,
                                );
                                Reference refer = FirebaseStorage.instance
                                    .ref()
                                    .child('thumbnails')
                                    .child('${const Uuid().v4()}.jpg');
                                await refer.putFile(thumbnail);
                                final String thumbnailUrl =
                                    await refer.getDownloadURL();
                                await BlocProvider.of<VideoDataCubit>(context)
                                    .addVideoData(
                                  videoModel: VideoModel(
                                    userName: userModel.name,
                                    userImage: userModel.image,
                                    userId: userModel.uid,
                                    videoId: const Uuid().v4(),
                                    song: song,
                                    caption: caption,
                                    video: videoUrl,
                                    thumbnail: thumbnailUrl,
                                    likes: [],
                                    shareCount: 0,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Share',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
