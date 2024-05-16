import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_cubit.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_state.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_state.dart';
import 'package:tiktok/Features/message/presentaion/views/chat_view.dart';
import 'package:tiktok/Features/profile/presentaion/manager/follow_cubit/follow_cubit.dart';
import 'package:tiktok/Features/profile/presentaion/manager/follow_cubit/follow_state.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import '../../../../core/functions/show_snack_bar_fun.dart';

class ProfileView extends StatefulWidget {
  const ProfileView(
      {super.key, this.anothUserUserModel, this.isFromChat = false});

  final UserModel? anothUserUserModel;
  final bool isFromChat;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  UserModel? userModel;
  bool isLoading = false;
  Future<void> fetchUserDataFun() async {
    await BlocProvider.of<UserDataCubit>(context)
        .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
    userModel = BlocProvider.of<UserDataCubit>(context).userModel;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.anothUserUserModel == null ||
        widget.anothUserUserModel!.uid ==
            FirebaseAuth.instance.currentUser!.uid) {
      //! Current
      fetchUserDataFun();
      BlocProvider.of<VideoDataCubit>(context).fetchCurrentUserLikes(
          useruuid: FirebaseAuth.instance.currentUser!.uid);
      BlocProvider.of<VideoDataCubit>(context).fetchVideosForCurrentUser();
      BlocProvider.of<FollowCubit>(context).fetchFollowersForCurrentUser();
      BlocProvider.of<FollowCubit>(context).fetchFollowingsForCurrentUser();
    } else {
      setState(() {
        userModel = widget.anothUserUserModel;
      });
      BlocProvider.of<VideoDataCubit>(context)
          .fetchVideosForAnotherUser(userUuid: userModel!.uid);
      BlocProvider.of<VideoDataCubit>(context)
          .fetchCurrentUserLikes(useruuid: userModel!.uid);
      BlocProvider.of<FollowCubit>(context)
          .fetchFollowersForAnotherUser(userIdToFetchFollowers: userModel!.uid);
      BlocProvider.of<FollowCubit>(context).fetchFollowingsForAnotherUser(
        userUuid: userModel!.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<VideoDataCubit, VideoDataState>(
      listener: (context, state) {
        if (state is FetchUserLikesLoading ||
            state is FetchVideosForCurrentUserLoading ||
            state is FollowFetchFollowersForCurrentUserLoading ||
            state is FollowFetchFollowingForCurrentUserLoading ||
            state is FetchVideosAnotherForUserLoading ||
            state is FollowFetchFollowersForAnotherUserLoading ||
            state is FollowFetchFollowingForAnotherUserLoading) {
          isLoading = true;
        } else if (state is FetchUserLikesFailure ||
            state is FetchVideosForCurrrentUserFailure ||
            state is FollowFetchFollowersForCurrentUserFailure ||
            state is FollowFetchFollowingForCurrentUserFailure ||
            state is FetchVideosAnotherForUserFailure ||
            state is FollowFetchFollowersForAnotherUserFailure ||
            state is FollowFetchFollowingForAnotherUserFailure) {
          isLoading = false;
          showSnackBarFun(
            context: context,
            text: 'Something went wrong, Please try again',
          );
        } else if (state is FetchUserLikedSuccess ||
            state is FetchVideosForCurrrentUserSuccess ||
            state is FollowFetchFollowersForCurrentUserSuccess ||
            state is FollowFetchFollowingForCurrentUserSuccess ||
            state is FetchVideosForAnotherUserSuccess ||
            state is FollowFetchFollowersForAnotherUserSuccess ||
            state is FollowFetchFollowingForAnotherUserSuccess) {
          isLoading = false;
        }
      },
      builder: (context, state) {
        return BlocConsumer<UserDataCubit, UserDataState>(
          listener: (context, state) {
            if (state is FetchUserDataLoading) {
              isLoading = true;
            } else if (state is FetchUserDataFailure) {
              isLoading = false;
              showSnackBarFun(
                context: context,
                text: '${state.errMessage}, Please try again',
              );
            } else if (state is FetchUserDataSuccess) {
              isLoading = false;
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: widget.anothUserUserModel == null,
                  title: widget.anothUserUserModel != null
                      ? Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.popView();
                                FocusScope.of(context).unfocus();
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              userModel?.name ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 48),
                            const Spacer(),
                          ],
                        )
                      : Text(
                          userModel?.name ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: BlocBuilder<FollowCubit, FollowState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              const SizedBox(height: 4),
                              if (userModel != null)
                                CircleAvatar(
                                  radius: 45,
                                  backgroundImage:
                                      NetworkImage(userModel!.image),
                                ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      BlocBuilder<FollowCubit, FollowState>(
                                        builder: (context, state) {
                                          int following = widget
                                                          .anothUserUserModel ==
                                                      null ||
                                                  widget.anothUserUserModel!
                                                          .uid ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                              ? BlocProvider.of<FollowCubit>(
                                                      context)
                                                  .followingsForCurrentUser
                                                  .length
                                              : BlocProvider.of<FollowCubit>(
                                                      context)
                                                  .followingsForAnotherUser
                                                  .length;
                                          return Text(
                                            following.toString(),
                                            style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                      const Text(
                                        'Following',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      BlocBuilder<FollowCubit, FollowState>(
                                        builder: (context, state) {
                                          int followers = widget
                                                          .anothUserUserModel ==
                                                      null ||
                                                  widget.anothUserUserModel!
                                                          .uid ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                              ? BlocProvider.of<FollowCubit>(
                                                      context)
                                                  .followersForCurrentUser
                                                  .length
                                              : BlocProvider.of<FollowCubit>(
                                                      context)
                                                  .followersForAnotherUser
                                                  .length;
                                          return Text(
                                            followers.toString(),
                                            style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                      const Text(
                                        'Followers',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      BlocBuilder<VideoDataCubit,
                                          VideoDataState>(
                                        builder: (context, state) {
                                          int count =
                                              BlocProvider.of<VideoDataCubit>(
                                                      context)
                                                  .currentUserLikes
                                                  .length;
                                          return Text(
                                            count.toString(),
                                            style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                      const Text(
                                        'Likes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (widget.anothUserUserModel != null &&
                                  !BlocProvider.of<FollowCubit>(context)
                                      .isFollowing() &&
                                  widget.anothUserUserModel!.uid !=
                                      FirebaseAuth.instance.currentUser!.uid)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 42),
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await BlocProvider.of<FollowCubit>(
                                                context)
                                            .addFollow(
                                          context: context,
                                          userIdYouWantToFollow:
                                              widget.anothUserUserModel!.uid,
                                          userImageIWantToFollowOrUnFollow:
                                              widget.anothUserUserModel!.image,
                                          userNameIWantToFollowOrUnFollow:
                                              widget.anothUserUserModel!.name,
                                        );
                                      },
                                      child: const Text(
                                        'Follow',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (!widget.isFromChat)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 28,
                                          ),
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await BlocProvider.of<UserDataCubit>(
                                                  context)
                                              .fetchUserData(
                                            uuid: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          );
                                          UserModel? currentUserModel =
                                              BlocProvider.of<UserDataCubit>(
                                                      context)
                                                  .userModel;
                                          context.pushToView(
                                            view: ChatView(
                                              token: widget
                                                  .anothUserUserModel!.token,
                                              userUuid: widget
                                                  .anothUserUserModel!.uid,
                                              anotherUserName: widget
                                                  .anothUserUserModel!.name,
                                              anotherUserImage: widget
                                                  .anothUserUserModel!.image,
                                              currentUserName:
                                                  currentUserModel!.name,
                                              currentUserImage:
                                                  currentUserModel.image,
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Message',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              if (widget.anothUserUserModel != null &&
                                  BlocProvider.of<FollowCubit>(context)
                                      .isFollowing() &&
                                  widget.anothUserUserModel!.uid !=
                                      FirebaseAuth.instance.currentUser!.uid)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 28),
                                        backgroundColor: const Color.fromARGB(
                                            255, 200, 226, 245),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await BlocProvider.of<FollowCubit>(
                                                context)
                                            .removeFollow(
                                          userIdYouWantToUnFollow:
                                              widget.anothUserUserModel!.uid,
                                          userImageIWantToFollowOrUnFollow:
                                              widget.anothUserUserModel!.image,
                                          userNameIWantToFollowOrUnFollow:
                                              widget.anothUserUserModel!.name,
                                          context: context,
                                        );
                                      },
                                      child: const Text(
                                        'UnFollow',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (!widget.isFromChat)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 28),
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await BlocProvider.of<UserDataCubit>(
                                                  context)
                                              .fetchUserData(
                                                  uuid: FirebaseAuth.instance
                                                      .currentUser!.uid);
                                          UserModel? currentUserModel =
                                              BlocProvider.of<UserDataCubit>(
                                                      context)
                                                  .userModel;
                                          context.pushToView(
                                            view: ChatView(
                                              token: widget
                                                  .anothUserUserModel!.token,
                                              userUuid: widget
                                                  .anothUserUserModel!.uid,
                                              currentUserName:
                                                  currentUserModel!.name,
                                              anotherUserImage: widget
                                                  .anothUserUserModel!.image,
                                              anotherUserName: widget
                                                  .anothUserUserModel!.name,
                                              currentUserImage:
                                                  currentUserModel.image,
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Message',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 6),
                              if (widget.anothUserUserModel == null ||
                                  widget.anothUserUserModel!.uid ==
                                      FirebaseAuth.instance.currentUser!.uid)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final cacheDir =
                                        await getTemporaryDirectory();
                                    if (cacheDir.existsSync()) {
                                      cacheDir.deleteSync(recursive: true);
                                    }
                                    final appDir =
                                        await getApplicationSupportDirectory();
                                    if (appDir.existsSync()) {
                                      appDir.deleteSync(recursive: true);
                                    }
                                    try {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await FirebaseAuth.instance.signOut();
                                      BlocProvider.of<AuthCubit>(context)
                                          .checkStateChanges();
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showSnackBarFun(
                                        context: context,
                                        text:
                                            'Something went wrong, Please try again',
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 22),
                            ],
                          );
                        },
                      ),
                    ),
                    BlocBuilder<VideoDataCubit, VideoDataState>(
                      builder: (context, state) {
                        List<dynamic> userVideos =
                            widget.anothUserUserModel == null ||
                                    widget.anothUserUserModel!.uid ==
                                        FirebaseAuth.instance.currentUser!.uid
                                ? BlocProvider.of<VideoDataCubit>(context)
                                    .currentUserVideos
                                : BlocProvider.of<VideoDataCubit>(context)
                                    .anotherUserVideos;
                        return SliverGrid.builder(
                          itemCount: userVideos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onLongPress: widget.anothUserUserModel == null ||
                                      widget.anothUserUserModel!.uid ==
                                          FirebaseAuth.instance.currentUser!.uid
                                  ? () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(height: 14),
                                              const Text(
                                                'Are You sure to delet This Video ?',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        context.popView(),
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
                                                      await BlocProvider.of<
                                                                  VideoDataCubit>(
                                                              context)
                                                          .removeVideo(
                                                        videoId:
                                                            userVideos[index]
                                                                .videoId,
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
                                    }
                                  : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Image.network(
                                  userVideos[index].thumbnail,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
