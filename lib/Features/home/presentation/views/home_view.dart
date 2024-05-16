import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_cubit.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_state.dart';

import '../video_player_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController pageController;
  List<dynamic> videos = [];
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    BlocProvider.of<VideoDataCubit>(context).fetchAllVideos();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  bool isLoading = false;
  int _currentPage = 0;
  bool _isPageScrolledCompletely = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final currentPage = pageController.page?.round() ?? 0;
              final scrollOffset = notification.metrics.pixels;
              final pageSize = MediaQuery.of(context).size.height;
              if (scrollOffset >= pageSize && currentPage == _currentPage) {
                setState(() {
                  _isPageScrolledCompletely = true;
                });
              } else {
                setState(() {
                  _currentPage = currentPage;
                  _isPageScrolledCompletely = false;
                });
              }
            }
            return true;
          },
          child: BlocBuilder<VideoDataCubit, VideoDataState>(
            builder: (context, state) {
              videos = BlocProvider.of<VideoDataCubit>(context).allVideos;
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                controller: pageController,
                itemBuilder: (context, index) {
                  if ((index == _currentPage && !_isPageScrolledCompletely) ||
                      (index == _currentPage + 1 &&
                          _isPageScrolledCompletely) ||
                      (index == _currentPage && _isPageScrolledCompletely)) {
                    return VideoPlayerItem(
                      videoModel: videos[index],
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
