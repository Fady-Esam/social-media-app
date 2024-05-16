import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/Features/message/presentaion/manager/message_cubit/message_cubit.dart';
import 'package:tiktok/Features/message/presentaion/manager/message_cubit/message_state.dart';
import 'package:tiktok/Features/profile/presentaion/views/profile_view.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import '../../../../core/functions/show_option_dialog.dart';
import '../../../../core/functions/show_snack_bar_fun.dart';
import '../../../../core/functions/show_warning_message_fun.dart';
import '../../data/models/chat_model.dart';
import 'widgets/chat_bubble.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.userUuid,
    required this.anotherUserName,
    required this.anotherUserImage,
    required this.currentUserName,
    required this.currentUserImage,
    required this.token,
  });

  final String userUuid;
  final String anotherUserName;
  final String anotherUserImage;
  final String currentUserName;
  final String currentUserImage;
  final String token;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  var controller = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  var controle = ScrollController();
  List<dynamic> allMessagesList = [];
  bool isAvailbaleMessges = false;
  var users = FirebaseFirestore.instance.collection('users');
  UserModel? userModel;
  var record = AudioRecorder();
  File? audioFile;
  bool isRecord = false;

  Future<void> checkAndFetch() async {
    if (await BlocProvider.of<MessageCubit>(context)
            .isAvailbilityChatCurrent(userIdToCheck: widget.userUuid) ==
        true) {
      BlocProvider.of<MessageCubit>(context)
          .fetchMessagesOfChat(userId: widget.userUuid);
      setState(() {
        allMessagesList =
            BlocProvider.of<MessageCubit>(context).allMessagesList;
      });
    } else {
      BlocProvider.of<MessageCubit>(context).allMessagesList.clear();
      allMessagesList.clear();
    }
  }

  Future<void> checkPermissionAndStartRecording() async {
    final location = await getApplicationCacheDirectory();
    if (await record.hasPermission()) {
      setState(() {
        isRecord = true;
      });
      await record.start(const RecordConfig(),
          path: '${location.path + const Uuid().v4()}.m4a');
    }
  }

  Future<void> uploadToFirebase(String path) async {
    setState(() {
      audioFile = File(path);
    });
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('chatAudios')
        .child(audioFile!.path);
    await ref.putFile(audioFile!);
    String audioUrl = await ref.getDownloadURL();
    addMessage(audioUrl: audioUrl);
  }

  Future<void> stopRecording() async {
    setState(() {
      isRecord = false;
    });
    final path2 = await record.stop();
    uploadToFirebase(path2!);
  }

  @override
  void initState() {
    super.initState();
    checkAndFetch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controle.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  final ImagePicker imagePicker = ImagePicker();
  File? pickedImage;
  File? pickedVideo;

  void addMessage({
    String? textMessage,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    String? thumbnail,
  }) async {
    controller.clear();
    controle.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    if (await BlocProvider.of<MessageCubit>(context)
            .isAvailbilityChatCurrent(userIdToCheck: widget.userUuid) ==
        false) {
      await BlocProvider.of<MessageCubit>(context).sendChatToFirebase(
        chatModel: ChatModel(
          userIdMessageWith: widget.userUuid,
          userNameMessageWith: widget.anotherUserName,
          userImageMessageWith: widget.anotherUserImage,
          currentUserName: widget.currentUserName,
          currentUserImage: widget.currentUserImage,
          messageList: [],
        ),
      );
    }
    await BlocProvider.of<MessageCubit>(context).sendMessageItemList(
      userIdMessageWith: widget.userUuid,
      currentUserName: widget.currentUserName,
      userImageMessageWith: widget.anotherUserImage,
      currentUserImage: widget.currentUserImage,
      userTokenMessageWith: widget.token,
      message: textMessage ?? imageUrl ?? videoUrl ?? audioUrl!,
      messageType: textMessage != null
          ? 'text'
          : imageUrl != null
              ? 'image'
              : videoUrl != null
                  ? 'video'
                  : 'audio',
      thumbnail: thumbnail,
    );
    BlocProvider.of<MessageCubit>(context)
        .fetchMessagesOfChat(userId: widget.userUuid);
    setState(() {
      allMessagesList = BlocProvider.of<MessageCubit>(context).allMessagesList;
    });
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        if (state is FetchMessagesForCurrentUserLoading ||
            state is SendMessageLoading ||
            state is DeleteMessageLoading ||
            state is ClearAllMessagesLoading ||
            state is SendChatToFirebaseLoading) {
          isLoading = true;
        } else if (state is FetchMessagesForCurrentUserFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is SendMessageFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is DeleteMessageFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is ClearAllMessagesFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is SendChatToFirebaseFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is FetchMessagesForCurrentUserSuccess ||
            state is SendMessageSuccess ||
            state is DeleteMessageSuccess ||
            state is ClearAllMessagesSuccess ||
            state is SendChatToFirebaseSuccess) {
          isLoading = false;
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      await BlocProvider.of<UserDataCubit>(context)
                          .fetchUserData(uuid: widget.userUuid);
                      setState(() {
                        userModel =
                            BlocProvider.of<UserDataCubit>(context).userModel;
                      });
                      context.pushToView(
                        view: ProfileView(
                          anothUserUserModel: userModel,
                          isFromChat: true,
                        ),
                      );
                    },
                    child: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(widget.anotherUserImage)),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      await BlocProvider.of<UserDataCubit>(context)
                          .fetchUserData(uuid: widget.userUuid);
                      setState(() {
                        userModel =
                            BlocProvider.of<UserDataCubit>(context).userModel;
                      });
                      context.pushToView(
                        view: ProfileView(
                          anothUserUserModel: userModel,
                          isFromChat: true,
                        ),
                      );
                    },
                    child: Text(
                      widget.anotherUserName,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                BlocBuilder<MessageCubit, MessageState>(
                  builder: (context, state) {
                    allMessagesList =
                        BlocProvider.of<MessageCubit>(context).allMessagesList;
                    return allMessagesList.isNotEmpty
                        ? IconButton(
                            onPressed: () async {
                              await showWarningMessageFunction(
                                context: context,
                                text:
                                    'Are you sure to clear all the messages ?',
                                onTapYes: () async {
                                  await BlocProvider.of<MessageCubit>(context)
                                      .clearAllMessages(
                                    userUUid: widget.userUuid,
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 25,
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                )
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<MessageCubit, MessageState>(
                    builder: (context, state) {
                      allMessagesList = BlocProvider.of<MessageCubit>(context)
                          .allMessagesList;
                      return ListView.builder(
                        controller: controle,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: allMessagesList.length,
                        itemBuilder: (context, index) {
                          return allMessagesList[index].userIdSentMessage ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? ChatBubbleForCurrentUser(
                                  messageModelItem: allMessagesList[index],
                                  userIdMessageWith: widget.userUuid,
                                )
                              : ChatBubbleForAnotherUser(
                                  messageModelItem: allMessagesList[index],
                                  userIdMessageWith: widget.userUuid,
                                );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.88,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: controller,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 5,
                            minLines: 1,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Text message cannot be empty or spaces';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.blue,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        String? imageOrVideo = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop('image');
                                                  },
                                                  child: const Text(
                                                    'Image',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop('video');
                                                  },
                                                  child: const Text(
                                                    'Video',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                        if (imageOrVideo == null) {
                                          return;
                                        }
                                        if (imageOrVideo == 'image') {
                                          String? option =
                                              await showOptionDialog(
                                                  context: context);
                                          if (option == null ||
                                              option == 'cancel') {
                                            return;
                                          }
                                          final XFile? image =
                                              await imagePicker.pickImage(
                                            source: option == 'camera'
                                                ? ImageSource.camera
                                                : ImageSource.gallery,
                                          );
                                          if (image != null) {
                                            setState(() {
                                              pickedImage = File(image.path);
                                            });
                                            Reference ref = FirebaseStorage
                                                .instance
                                                .ref()
                                                .child('chatImages')
                                                .child(pickedImage!.path);
                                            await ref.putFile(pickedImage!);
                                            String imageUrl =
                                                await ref.getDownloadURL();
                                            addMessage(imageUrl: imageUrl);
                                          }
                                        } else {
                                          String? option =
                                              await showOptionDialog(
                                                  context: context);
                                          if (option == null ||
                                              option == 'cancel') {
                                            return;
                                          }
                                          final XFile? video =
                                              await imagePicker.pickVideo(
                                            source: option == 'camera'
                                                ? ImageSource.camera
                                                : ImageSource.gallery,
                                          );
                                          if (video != null) {
                                            setState(() {
                                              pickedVideo = File(video.path);
                                            });
                                            final compressedVideo =
                                                await VideoCompress
                                                    .compressVideo(
                                              pickedVideo!.path,
                                              quality:
                                                  VideoQuality.MediumQuality,
                                            );
                                            final thumbnail =
                                                await VideoCompress
                                                    .getFileThumbnail(
                                                        pickedVideo!.path);
                                            Reference ref = FirebaseStorage
                                                .instance
                                                .ref()
                                                .child('chatVideos')
                                                .child(pickedVideo!.path);
                                            await ref.putFile(
                                                compressedVideo!.file!);
                                            String videoUrl =
                                                await ref.getDownloadURL();
                                            Reference refer = FirebaseStorage
                                                .instance
                                                .ref()
                                                .child('chatThumbnailsVideos')
                                                .child(
                                                    '${const Uuid().v4()}.jpg');
                                            await refer.putFile(thumbnail);
                                            String thumbnailUrl =
                                                await refer.getDownloadURL();
                                            addMessage(
                                                videoUrl: videoUrl,
                                                thumbnail: thumbnailUrl);
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.photo,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () async {
                                        if (!isRecord) {
                                          await checkPermissionAndStartRecording();
                                        } else {
                                          await stopRecording();
                                        }
                                      },
                                      child: !isRecord
                                          ? const Icon(
                                              Icons.mic,
                                              size: 30,
                                            )
                                          : const Icon(
                                              Icons.stop,
                                              size: 30,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          addMessage(textMessage: controller.text);
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom * 0.02),
              ],
            ),
          ),
        );
      },
    );
  }
}
