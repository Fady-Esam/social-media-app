// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:uuid/uuid.dart';

// import '../../../../core/functions/show_option_dialog.dart';
// import '../../../auth/data/models/user_model.dart';
// import '../../../auth/presentation/manager/user_data-cubit/user_data_cubit.dart';

// class EditProFileView extends StatefulWidget {
//   const EditProFileView({super.key, required this.userModel});

//   final UserModel userModel;

//   @override
//   State<EditProFileView> createState() => _EditProFileViewState();
// }

// class _EditProFileViewState extends State<EditProFileView> {
//   final imagePicker = ImagePicker();
//   File? pickedImage;
//   bool isNamePressed = false;
//   GlobalKey<FormState> formKey = GlobalKey();
//   bool isLoading = false;

//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   late TextEditingController joiningDateController;
//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.userModel.name);
//     emailController = TextEditingController(text: widget.userModel.email);
//     joiningDateController = TextEditingController(text: DateFormat.yMEd().format(widget.userModel.joiningDate));
//   }

//   AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

//   @override
//   Widget build(BuildContext context) {
//     return ModalProgressHUD(
//       inAsyncCall: isLoading,
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Row(
//             children: [
//               IconButton(
//                 onPressed: () async {
//                   await BlocProvider.of<UserDataCubit>(context).fetchUserData(
//                       uuid: FirebaseAuth.instance.currentUser!.uid);
//                   Navigator.pop(context,
//                       BlocProvider.of<UserDataCubit>(context).userModel);
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back,
//                 ),
//               ),
//               const Text(
//                 'Profile',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: Form(
//           key: formKey,
//           autovalidateMode: autovalidateMode,
//           child: Column(
//             children: [
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   CircleAvatar(
//                     radius: 65,
//                     backgroundImage: pickedImage != null
//                         ? FileImage(pickedImage!)
//                         : NetworkImage(widget.userModel.image)
//                             as ImageProvider<Object>?,
//                   ),
//                   Positioned(
//                     bottom: -17,
//                     right: 10,
//                     child: IconButton(
//                       onPressed: () async {
//                         String? option =
//                             await showOptionDialog(context: context);
//                         if (option == null || option == 'cancel') {
//                           return;
//                         }
//                         final XFile? image = await imagePicker.pickImage(
//                           source: option == 'camera'
//                               ? ImageSource.camera
//                               : ImageSource.gallery,
//                         );
//                         if (image != null) {
//                           setState(() {
//                             pickedImage = File(image.path);
//                           });
//                         }
//                       },
//                       icon: const Icon(
//                         Icons.edit,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Card(
//                 color: const Color.fromARGB(255, 188, 124, 146),
//                 child: ListTile(
//                   leading: const Icon(
//                     Icons.person,
//                   ),
//                   title: TextFormField(
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Name must not be empty';
//                       }
//                       return null;
//                     },
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     controller: nameController,
//                     enabled: isNamePressed,
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Name',
//                     ),
//                   ),
//                   trailing: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         isNamePressed = !isNamePressed;
//                       });
//                     },
//                     icon: const Icon(
//                       Icons.note_alt_outlined,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Card(
//                 color: const Color.fromARGB(255, 188, 124, 146),
//                 child: ListTile(
//                   leading: const Icon(
//                     Icons.email,
//                   ),
//                   title: TextFormField(
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     enabled: false,
//                     controller: emailController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       labelText: 'Email',
//                       labelStyle: TextStyle(
//                         fontSize: 18,
//                         color: Colors.black.withOpacity(0.5),
//                       ),
//                     ),
//                   ),
//                   trailing: IconButton(
//                     onPressed: () {},
//                     icon: const Icon(
//                       Icons.note_alt_outlined,
//                     ),
//                   ),
//                 ),
//               ),
//               Card(
//                 color: const Color.fromARGB(255, 188, 124, 146),
//                 child: ListTile(
//                   leading: const Icon(
//                     Icons.timer,
//                   ),
//                   title: TextFormField(
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     enabled: false,
//                     controller: joiningDateController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       labelText: 'JoinedAt',
//                       labelStyle: TextStyle(
//                         fontSize: 22,
//                         color: Colors.black.withOpacity(0.5),
//                       ),
//                     ),
//                   ),
//                   trailing: IconButton(
//                     onPressed: () {},
//                     icon: const Icon(
//                       Icons.note_alt_outlined,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: MediaQuery.sizeOf(context).width * 0.43,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () async {
//                   if (formKey.currentState!.validate()) {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     if (pickedImage != null) {
//                       Reference ref = FirebaseStorage.instance
//                           .ref()
//                           .child('userImages')
//                           .child('${const Uuid().v4()}.jpg');
//                       await ref.putFile(pickedImage!);
//                       String imageUrl = await ref.getDownloadURL();
//                       await BlocProvider.of<UserDataCubit>(context)
//                           .editUserData(
//                         name: nameController.text,
//                         image: imageUrl,
//                       );
//                     } else {
//                       await BlocProvider.of<UserDataCubit>(context)
//                           .editUserData(
//                         name: nameController.text,
//                         image: widget.userModel.image,
//                       );
//                     }
//                     setState(() {
//                       isLoading = false;
//                     });

//                   } else {
//                     autovalidateMode = AutovalidateMode.always;
//                     setState(() {});
//                   }
//                 },
//                 child: const Text(
//                   'Save',
//                   style: TextStyle(
//                     fontSize: 21,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
