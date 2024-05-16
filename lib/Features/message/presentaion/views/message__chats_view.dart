import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tiktok/Features/message/presentaion/manager/message_cubit/message_cubit.dart';
import 'package:tiktok/Features/message/presentaion/manager/message_cubit/message_state.dart';
import 'package:tiktok/core/functions/show_warning_message_fun.dart';

import '../../../../core/functions/show_snack_bar_fun.dart';
import 'widgets/message_item.dart';

class MessageChatsView extends StatefulWidget {
  const MessageChatsView({super.key});

  @override
  State<MessageChatsView> createState() => _MessageChatsViewState();
}

class _MessageChatsViewState extends State<MessageChatsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<dynamic> chats = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MessageCubit>(context).fetchNumberOfNotEmptyMessagesList();
    BlocProvider.of<MessageCubit>(context).fetchChats();
    setState(() {
      chats = BlocProvider.of<MessageCubit>(context).chats;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        if (state is FetchChatsLoading ||
            state is ClearAllChatsLoading ||
            state is DeleteChatLoading) {
          isLoading = true;
        } else if (state is DeleteChatFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is ClearAllChatsFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is FetchChatsFailure) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is FetchChatsSuccess ||
            state is ClearAllChatsSuccess ||
            state is DeleteChatSuccess) {
          isLoading = false;
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'Chats',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                BlocBuilder<MessageCubit, MessageState>(
                  builder: (context, state) {
                    int numberOfNotEmptyMessagesList =
                        BlocProvider.of<MessageCubit>(context)
                            .numberOfNotEmptyMessagesList;
                    if (numberOfNotEmptyMessagesList == 0) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      onPressed: () async {
                        await showWarningMessageFunction(
                          context: context,
                          text: 'Are you sure to clear all chats?',
                          onTapYes: () async {
                            await BlocProvider.of<MessageCubit>(context)
                                .clearAllChats();
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.delete,
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<MessageCubit, MessageState>(
                    builder: (context, state) {
                      chats = BlocProvider.of<MessageCubit>(context).chats;
                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onLongPress: () async {
                              await showWarningMessageFunction(
                                context: context,
                                text:
                                    'Are you sure to delete your Chat with ${chats[index].userNameMessageWith} ?',
                                onTapYes: () async {
                                  await BlocProvider.of<MessageCubit>(context)
                                      .deleteChat(
                                    useUUid: chats[index].userIdMessageWith,
                                  );
                                },
                              );
                            },
                            child: MessageItem(
                              
                              chatModel: chats[index],
                              messageModelItem:
                                  chats[index].messageList.isNotEmpty
                                      ? chats[index].messageList[
                                          chats[index].messageList.length - 1]
                                      : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
