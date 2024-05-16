
import 'package:flutter/material.dart';
import 'package:tiktok/Features/add_video/presentaion/views/add_video_view.dart';
import 'package:tiktok/Features/home/presentation/views/home_view.dart';
import 'package:tiktok/Features/profile/presentaion/views/profile_view.dart';
import 'package:tiktok/Features/search/presentaion/views/search_view.dart';
import 'package:tiktok/core/widgets/custom_icon.dart';

import '../../Features/message/presentaion/views/message__chats_view.dart';

class TabsNav extends StatefulWidget {
  const TabsNav({super.key});

  @override
  State<TabsNav> createState() => _TabsNavState();
}

class _TabsNavState extends State<TabsNav> {
  late PageController pageController;
  List<Widget> views = const [
    HomeView(),
    SearchView(),
    AddVideoView(),
    MessageChatsView(),
    ProfileView(),
  ];

  int currentViewIndex = 0;



  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentViewIndex);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: views,
        onPageChanged: (int index) {
          setState(() {
            currentViewIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        selectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        fixedColor: Colors.red,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        currentIndex: currentViewIndex,
        onTap: (index) {
          setState(() {
            currentViewIndex = index;
          });
          pageController.jumpToPage(currentViewIndex);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              size: 30,
            ),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
