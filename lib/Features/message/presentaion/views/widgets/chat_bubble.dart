import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/message/presentaion/manager/message_cubit/message_cubit.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/functions/show_warning_message_fun.dart';
import '../../../data/models/chat_model.dart';

// ! You Can Delete A Message From both Sides

class ChatBubbleForAnotherUser extends StatefulWidget {
  const ChatBubbleForAnotherUser({
    super.key,
    required this.messageModelItem,
    required this.userIdMessageWith,
  });

  final MessageModelItem messageModelItem;
  final String userIdMessageWith;

  @override
  State<ChatBubbleForAnotherUser> createState() =>
      _ChatBubbleForAnotherUserState();
}

class _ChatBubbleForAnotherUserState extends State<ChatBubbleForAnotherUser> {
  bool isPlay = false;
  bool isAudioEnded = false;
  bool isVideoPlay = false;
  bool isVideoEnded = false;
  bool isVideoStarted = false;
  final player = AudioPlayer();
  late VideoPlayerController videoPlayerController;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.messageModelItem.message));
    if (widget.messageModelItem.messageType == 'audio') {
      initAudioPlayer();
    }
    if (widget.messageModelItem.messageType == 'video') {
      initVideoData();
      videoPlayerController.addListener(() {
        if (videoPlayerController.value.isPlaying) {
          setState(() {
            isVideoPlay = true;
          });
        } else if (videoPlayerController.value.isCompleted) {
          setState(() {
            isVideoEnded = true;
            isVideoPlay = false;
            isVideoStarted = false;
          });
        }
      });
    }
  }

  void initVideoData() {
    videoPlayerController.initialize().then((_) => setState(() {}));
  }

  Future<void> setUpVideoControllerAndPlay() async {
    await videoPlayerController.play();
    await videoPlayerController.setVolume(1);
    if (!isVideoStarted) {
      videoPlayerController.initialize().then((_) => setState(() {
            isVideoStarted = true;
            isVideoEnded = false;
          }));
    }
  }

  Future<void> pauseTheVideo() async {
    await videoPlayerController.pause();
  }

  Future<void> initAudioPlayer() async {
    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    player.onPlayerComplete.listen((event) async {
      await player.stop();
      await player.pause();
      await player.release();
      setState(() {
        isPlay = false;
        isAudioEnded = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.messageModelItem.messageType == 'audio') {
      player.stop();
      player.release();
      player.dispose();
    }
    videoPlayerController.dispose();
  }

  void seek2(double value) async {
    final newPosition = Duration(seconds: value.toInt());
    player.seek(newPosition);
    player.resume();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(widget.messageModelItem.sentAt);
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    widget.messageModelItem.userImageMessageWith,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: widget.messageModelItem.messageType == 'audio'
                  ? () async {
                      if (!isPlay) {
                        await player.play(
                          UrlSource(
                            widget.messageModelItem.message,
                          ),
                        );
                        setState(() {
                          isPlay = true;
                          isAudioEnded = false;
                        });
                      } else if (isPlay) {
                        await player.pause();
                        log('Paused');
                        setState(() {
                          isPlay = false;
                        });
                      }
                    }
                  : null,
              onLongPress: () async {
                await showWarningMessageFunction2(
                  context: context,
                  text: 'Delete Message ?',
                  onTapYes: () async {
                    await BlocProvider.of<MessageCubit>(context).deleteMessage(
                      userIdMessageWith: widget.userIdMessageWith,
                      messageModelItem: widget.messageModelItem,
                    );
                  },
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  color: Color.fromRGBO(13, 114, 104, 1),
                ),
                margin: const EdgeInsets.only(
                    top: 10, left: 8, right: 40, bottom: 10),
                padding: const EdgeInsets.only(
                    right: 15, left: 15, top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.messageModelItem.messageType == 'text')
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.55,
                        ),
                        child: Text(
                          widget.messageModelItem.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    if (widget.messageModelItem.messageType == 'image') ...[
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.35,
                        width: MediaQuery.sizeOf(context).width * 0.65,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.messageModelItem.message,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (widget.messageModelItem.messageType == 'video')
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.35,
                        width: MediaQuery.sizeOf(context).width * 0.68,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: !isVideoStarted
                                    ? Image.network(
                                        widget.messageModelItem.thumbnail!,
                                        fit: BoxFit.fill,
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.65,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.35,
                                      )
                                    : VideoPlayer(videoPlayerController),
                              ),
                              Positioned(
                                top: MediaQuery.sizeOf(context).height * 0.16,
                                right: MediaQuery.sizeOf(context).width * 0.3,
                                child: IconButton(
                                  onPressed: () async {
                                    if (isVideoPlay) {
                                      await pauseTheVideo();
                                      setState(() {
                                        isVideoPlay = false;
                                      });
                                    } else if (!isVideoPlay || isVideoEnded) {
                                      await setUpVideoControllerAndPlay();
                                      setState(() {
                                        isVideoPlay = true;
                                      });
                                    }
                                  },
                                  icon: !isVideoPlay || isVideoEnded
                                      ? const Icon(
                                          Icons.play_arrow,
                                          size: 32,
                                        )
                                      : const Icon(
                                          Icons.stop,
                                          size: 32,
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    if (widget.messageModelItem.messageType == 'audio')
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.03,
                        width: MediaQuery.sizeOf(context).width * 0.68,
                        child: Row(
                          children: [
                            if (isPlay)
                              Icon(
                                Icons.stop,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                            if (!isPlay)
                              Icon(
                                Icons.play_arrow,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                            Expanded(
                              child: Slider(
                                min: 0.0,
                                max: duration.inSeconds.toDouble(),
                                value: isAudioEnded
                                    ? 0
                                    : position.inSeconds.toDouble(),
                                onChanged: seek2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.messageModelItem.messageType == 'video')
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.68,
                        child: Slider(
                          value: videoPlayerController.value.position.inSeconds
                              .toDouble(),
                          min: 0.0,
                          max: videoPlayerController.value.duration.inSeconds
                              .toDouble(),
                          onChanged: (double value) {
                            videoPlayerController
                                .seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                    const SizedBox(height: 5),
                    if (widget.messageModelItem.messageType != 'audio' &&
                        widget.messageModelItem.messageType != 'video')
                      Text(
                        '${date.hour != 0 ? date.hour > 12 && date.hour < 22 ? '0${date.hour - 12}' : date.hour < 10 ? '0${date.hour}' : date.hour : '12'}:${date.minute < 10 ? '0${date.minute}' : date.minute} ${date.hour > 12 ? 'PM' : 'AM'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (widget.messageModelItem.messageType == 'audio' ||
                        widget.messageModelItem.messageType == 'video')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              widget.messageModelItem.messageType == 'audio'
                                  ? formatSeconds(position.inSeconds)
                                  : formatSeconds(videoPlayerController
                                      .value.position.inSeconds),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.sizeOf(context).width * 0.38),
                            child: Text(
                              '${date.hour != 0 ? date.hour > 12 && date.hour < 22 ? '0${date.hour - 12}' : date.hour < 10 ? '0${date.hour}' : date.hour : '12'}:${date.minute < 10 ? '0${date.minute}' : date.minute} ${date.hour > 12 ? 'PM' : 'AM'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();
    int remainingSeconds = seconds % 60;
    String formattedMinutes = (minutes % 60).toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }
}

class ChatBubbleForCurrentUser extends StatefulWidget {
  const ChatBubbleForCurrentUser({
    super.key,
    required this.messageModelItem,
    required this.userIdMessageWith,
  });

  final MessageModelItem messageModelItem;
  final String userIdMessageWith;

  @override
  State<ChatBubbleForCurrentUser> createState() =>
      _ChatBubbleForCurrentUserState();
}

class _ChatBubbleForCurrentUserState extends State<ChatBubbleForCurrentUser> {
  bool isPlay = false;
  bool isAudioEnded = false;
  bool isVideoPlay = false;
  bool isVideoEnded = false;
  bool isVideoStarted = false;
  final player = AudioPlayer();
  late VideoPlayerController videoPlayerController;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.messageModelItem.message));
    if (widget.messageModelItem.messageType == 'audio') {
      initAudioPlayer();
    }
    if (widget.messageModelItem.messageType == 'video') {
      initVideoData();
      videoPlayerController.addListener(() {
        if (videoPlayerController.value.isPlaying) {
          setState(() {
            isVideoPlay = true;
          });
        } else if (videoPlayerController.value.isCompleted) {
          setState(() {
            isVideoEnded = true;
            isVideoPlay = false;
            isVideoStarted = false;
          });
        }
      });
    }
  }

  void initVideoData() {
    videoPlayerController.initialize().then((_) => setState(() {}));
  }

  Future<void> setUpVideoControllerAndPlay() async {
    await videoPlayerController.play();
    await videoPlayerController.setVolume(1);
    if (!isVideoStarted) {
      videoPlayerController.initialize().then((_) => setState(() {
            isVideoStarted = true;
            isVideoEnded = false;
          }));
    }
  }

  Future<void> pauseTheVideo() async {
    await videoPlayerController.pause();
  }

  Future<void> initAudioPlayer() async {
    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    player.onPlayerComplete.listen((event) async {
      await player.stop();
      await player.pause();
      await player.release();
      setState(() {
        isPlay = false;
        isAudioEnded = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.messageModelItem.messageType == 'audio') {
      player.stop();
      player.release();
      player.dispose();
    }
    videoPlayerController.dispose();
  }

  void seek2(double value) async {
    final newPosition = Duration(seconds: value.toInt());
    player.seek(newPosition);
    player.resume();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(widget.messageModelItem.sentAt);
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: widget.messageModelItem.messageType == 'audio'
            ? () async {
                if (!isPlay) {
                  await player.play(
                    UrlSource(
                      widget.messageModelItem.message,
                    ),
                  );
                  setState(() {
                    isPlay = true;
                    isAudioEnded = false;
                  });
                } else if (isPlay) {
                  await player.pause();
                  log('Paused');
                  setState(() {
                    isPlay = false;
                  });
                }
              }
            : null,
        onLongPress: () async {
          await showWarningMessageFunction2(
            context: context,
            text: 'Delete Message ?',
            onTapYes: () async {
              await BlocProvider.of<MessageCubit>(context).deleteMessage(
                userIdMessageWith: widget.userIdMessageWith,
                messageModelItem: widget.messageModelItem,
              );
            },
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
              bottomLeft: Radius.circular(28),
            ),
          ),
          margin:
              const EdgeInsets.only(top: 10, left: 60, right: 16, bottom: 10),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.messageModelItem.messageType == 'text')
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                  ),
                  child: Text(
                    widget.messageModelItem.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (widget.messageModelItem.messageType == 'image') ...[
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.35,
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.messageModelItem.message,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              if (widget.messageModelItem.messageType == 'video')
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.35,
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: !isVideoStarted
                              ? Image.network(
                                  widget.messageModelItem.thumbnail!,
                                  fit: BoxFit.fill,
                                  width: MediaQuery.sizeOf(context).width * 0.7,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.35,
                                )
                              : VideoPlayer(videoPlayerController),
                        ),
                        Positioned(
                          top: MediaQuery.sizeOf(context).height * 0.16,
                          right: MediaQuery.sizeOf(context).width * 0.3,
                          child: IconButton(
                            onPressed: () async {
                              if (isVideoPlay) {
                                await pauseTheVideo();
                                setState(() {
                                  isVideoPlay = false;
                                });
                              } else if (!isVideoPlay || isVideoEnded) {
                                await setUpVideoControllerAndPlay();
                                setState(() {
                                  isVideoPlay = true;
                                });
                              }
                            },
                            icon: !isVideoPlay || isVideoEnded
                                ? const Icon(
                                    Icons.play_arrow,
                                    size: 32,
                                  )
                                : const Icon(
                                    Icons.stop,
                                    size: 32,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              if (widget.messageModelItem.messageType == 'video')
                Slider(
                  value:
                      videoPlayerController.value.position.inSeconds.toDouble(),
                  min: 0.0,
                  max:
                      videoPlayerController.value.duration.inSeconds.toDouble(),
                  onChanged: (double value) {
                    videoPlayerController
                        .seekTo(Duration(seconds: value.toInt()));
                  },
                ),
              if (widget.messageModelItem.messageType == 'audio')
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.03,
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: Row(
                    children: [
                      if (isPlay)
                        Icon(
                          Icons.stop,
                          size: 30,
                          color: Colors.grey[400],
                        ),
                      if (!isPlay)
                        Icon(
                          Icons.play_arrow,
                          size: 30,
                          color: Colors.grey[400],
                        ),
                      Expanded(
                        child: Slider(
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          value:
                              isAudioEnded ? 0 : position.inSeconds.toDouble(),
                          onChanged: seek2,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 5),
              if (widget.messageModelItem.messageType != 'audio' &&
                  widget.messageModelItem.messageType != 'video')
                Text(
                  '${date.hour != 0 ? date.hour > 12 && date.hour < 22 ? '0${date.hour - 12}' : date.hour < 10 ? '0${date.hour}' : date.hour : '12'}:${date.minute < 10 ? '0${date.minute}' : date.minute} ${date.hour > 12 ? 'PM' : 'AM'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (widget.messageModelItem.messageType == 'audio' ||
                  widget.messageModelItem.messageType == 'video')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        widget.messageModelItem.messageType == 'audio'
                            ? formatSeconds(position.inSeconds)
                            : formatSeconds(
                                videoPlayerController.value.position.inSeconds,
                              ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${date.hour != 0 ? date.hour > 12 && date.hour < 22 ? '0${date.hour - 12}' : date.hour < 10 ? '0${date.hour}' : date.hour : '12'}:${date.minute < 10 ? '0${date.minute}' : date.minute} ${date.hour > 12 ? 'PM' : 'AM'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String formatSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();
    int remainingSeconds = seconds % 60;
    String formattedMinutes = (minutes % 60).toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    log('$formattedMinutes:$formattedSeconds');
    return '$formattedMinutes:$formattedSeconds';
  }
}
