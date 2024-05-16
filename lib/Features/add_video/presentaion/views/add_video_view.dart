import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok/Features/add_video/presentaion/views/confirm_view.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';

import '../../../../core/functions/show_option_dialog.dart';

class AddVideoView extends StatefulWidget {
  const AddVideoView({super.key});

  @override
  State<AddVideoView> createState() => _AddVideoViewState();
}

class _AddVideoViewState extends State<AddVideoView> {
  final ImagePicker imagePicker = ImagePicker();
  File? pickedVideo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () async {
            String? option = await showOptionDialog(context: context);
            if (option == null || option == 'cancel') {
              return;
            }
            final XFile? video = await imagePicker.pickVideo(
                source: option == 'camera'
                    ? ImageSource.camera
                    : ImageSource.gallery);
            if (video != null) {
              setState(() {
                pickedVideo = File(video.path);
              });
              context.pushToView(
                view: ConfirmView(
                  pickedVideo: pickedVideo!,
                ),
              );
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: 60,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Add Video',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
