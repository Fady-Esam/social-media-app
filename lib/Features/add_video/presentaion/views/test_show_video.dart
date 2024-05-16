import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TestShowVideo extends StatefulWidget {
  const TestShowVideo({super.key});

  @override
  State<TestShowVideo> createState() => _TestShowVideoState();
}

class _TestShowVideoState extends State<TestShowVideo> {
  late VideoPlayerController videoPlayerController;
  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'));
    setUpVideoController();
    // ..initialize().then((_) {
    //   // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //   setState(() {});
    // });
  }

  Future<void> setUpVideoController() async {
    await videoPlayerController.initialize().then((_) => setState(() {}));
    await videoPlayerController.play();
    await videoPlayerController.setVolume(0.8);
    await videoPlayerController.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: videoPlayerController.value.isInitialized
              ? VideoPlayer(videoPlayerController)
              : const SizedBox.shrink(),
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () async {
          // await videoPlayerController.play();
          await videoPlayerController.setVolume(0.8);
          await videoPlayerController.setLooping(true);
        },
        icon: const Icon(
          Icons.play_arrow,
        ),
      ),
    );
  }
}
