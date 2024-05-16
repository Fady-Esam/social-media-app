// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tiktok/Features/auth/data/models/user_model.dart';
// import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
// import 'edit_profile_view.dart';

// class SettingsView extends StatefulWidget {
//   const SettingsView({super.key});

//   @override
//   State<SettingsView> createState() => _SettingsViewState();
// }

// class _SettingsViewState extends State<SettingsView> {
//   Future<void> fetchUserData() async {
//     await BlocProvider.of<UserDataCubit>(context)
//         .fetchUserData(uuid: FirebaseAuth.instance.currentUser!.uid);
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   UserModel? userModelResult;

//   @override
//   Widget build(BuildContext context) {
//     UserModel? userModel = BlocProvider.of<UserDataCubit>(context).userModel;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             IconButton(
//               onPressed: () async {
//                 await BlocProvider.of<UserDataCubit>(context).fetchUserData(
//                     uuid: FirebaseAuth.instance.currentUser!.uid);
//                 Navigator.pop(
//                     context, BlocProvider.of<UserDataCubit>(context).userModel);
//               },
//               icon: const Icon(
//                 Icons.arrow_back,
//               ),
//             ),
//             const Text(
//               'Profile',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundImage: NetworkImage(
//                     userModelResult == null
//                         ? userModel!.image
//                         : userModelResult!.image,
//                   ),
//                 ),
//                 const SizedBox(width: 18),
//                 Text(
//                   userModel!.name,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 18),
//             Card(
//               color: const Color.fromARGB(255, 188, 124, 146),
//               elevation: 5,
//               child: ListTile(
//                 onTap: () async {
//                   userModelResult = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               EditProFileView(userModel: userModel)));
//                   setState(() {});
//                 },
//                 leading: const Icon(
//                   Icons.person,
//                   size: 28,
//                 ),
//                 title: const Text(
//                   'Profile',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios_rounded,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
