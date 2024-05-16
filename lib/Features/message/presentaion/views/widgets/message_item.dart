import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';

import '../../../data/models/chat_model.dart';
import '../chat_view.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.chatModel,
    required this.messageModelItem,
  });

  final ChatModel chatModel;
  final MessageModelItem? messageModelItem;

  @override
  Widget build(BuildContext context) {
    if (messageModelItem != null) {
      final DateTime? date = messageModelItem != null
          ? DateTime.parse(messageModelItem!.sentAt)
          : null;
      return Padding(
        padding: const EdgeInsets.only(right: 8, left: 6, bottom: 8),
        child: ListTile(
          onTap: () async {
            await BlocProvider.of<UserDataCubit>(context)
                .fetchUserData(uuid: chatModel.userIdMessageWith);
            UserModel? userModel =
                BlocProvider.of<UserDataCubit>(context).userModel;
            if (userModel != null) {
              context.pushToView(
                view: ChatView(
                  token: userModel.token,
                  userUuid: chatModel.userIdMessageWith,
                  currentUserName: chatModel.currentUserName,
                  anotherUserImage: chatModel.userImageMessageWith,
                  anotherUserName: chatModel.userNameMessageWith,
                  currentUserImage: chatModel.currentUserImage,
                ),
              );
            }
          },
          contentPadding: const EdgeInsets.all(8),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              chatModel.userImageMessageWith,
            ),
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chatModel.userNameMessageWith,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (date != null)
                    Text(
                      '${date.month}/${date.day}/${date.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2)
            ],
          ),
          subtitle: Text(
            messageModelItem!.messageType == 'image'
                ? 'Photo'
                : messageModelItem!.messageType == 'audio'
                    ? 'Audio'
                    : messageModelItem!.messageType == 'video'
                        ? 'Video'
                        : messageModelItem!.message,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
