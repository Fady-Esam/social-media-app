import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/profile/presentaion/views/profile_view.dart';
import 'package:tiktok/Features/search/presentaion/manager/search_cubit/search_cubit.dart';
import 'package:tiktok/Features/search/presentaion/manager/search_cubit/search_state.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<dynamic> searchedUsers = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SearchCubit>(context).usersList.clear();
    searchedUsers = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 253, 81, 68),
        title: TextField(
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            filled: false,
            hintText: 'Search',
            hintStyle: TextStyle(
              fontSize: 21,
              color: Colors.white,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              BlocProvider.of<SearchCubit>(context).usersList.clear();
              setState(() {
                searchedUsers = [];
              });
              return;
            }
            BlocProvider.of<SearchCubit>(context)
                .searchForUser(userName: value);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                searchedUsers = BlocProvider.of<SearchCubit>(context).usersList;
                return ListView.builder(
                  itemCount: searchedUsers.length,
                  itemBuilder: (context, index) {
                    return SearchItem(userModel: searchedUsers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchItem extends StatelessWidget {
  const SearchItem({super.key, required this.userModel});

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 14, bottom: 14),
      child: ListTile(
        onTap: () => context.pushToView(
          view: ProfileView(anothUserUserModel: userModel),
        ),
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            userModel.image,
          ),
        ),
        title: Text(
          userModel.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
