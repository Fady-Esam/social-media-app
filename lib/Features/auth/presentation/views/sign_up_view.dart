import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tiktok/Features/auth/data/models/auth_model.dart';
import 'package:tiktok/Features/auth/data/models/user_model.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_states.dart';
import 'package:tiktok/core/functions/show_snack_bar_fun.dart';
import 'package:tiktok/core/functions/show_warning_message_fun.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';
import 'package:tiktok/core/widgets/tabs_nav.dart';
import '../../../../core/functions/show_option_dialog.dart';
import '../manager/user_data-cubit/user_data_cubit.dart';
import 'widgets/check_authentication_custom_row.dart';
import 'widgets/custom_text_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  String password = '';
  String email = '';
  var userName = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool isLoading = false;
  final imagePicker = ImagePicker();
  File? pickedImage;
  @override
  void dispose() {
    super.dispose();
    userName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is SignUpSuccessState) {
          await FirebaseMessaging.instance.requestPermission();
          String? token = await FirebaseMessaging.instance.getToken();
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('userImages')
              .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
          await ref.putFile(pickedImage!);
          final String imageUrl = await ref.getDownloadURL();
          await BlocProvider.of<UserDataCubit>(context).sendUserData(
            userModel: UserModel(
              uid: FirebaseAuth.instance.currentUser!.uid,
              token: token ?? '',
              name: userName.text,
              email: email.toLowerCase(),
              image: imageUrl,
              followers: [],
              followings: [],
              userChatsIds: [],
            ),
          );
          isLoading = false;
          context.pushToView(view: const TabsNav());
        } else if (state is SignUpFailureState) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is SignUpLoadingState) {
          isLoading = true;
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Form(
                  key: formKey,
                  autovalidateMode: autovalidateMode,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom * 0.2),
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Stack(
                          children: [
                            if (pickedImage == null)
                              const CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                  'https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png',
                                ),
                              ),
                            if (pickedImage != null)
                              CircleAvatar(
                                radius: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(55),
                                  child: Image.file(
                                    pickedImage!,
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 80,
                              left: 75,
                              child: IconButton(
                                onPressed: () async {
                                  String? option =
                                      await showOptionDialog(context: context);
                                  if (option == null || option == 'cancel') {
                                    return;
                                  }
                                  final XFile? image =
                                      await imagePicker.pickImage(
                                    source: option == 'camera'
                                        ? ImageSource.camera
                                        : ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      pickedImage = File(image.path);
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: userName,
                          autovalidateMode: autovalidateMode,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'UserName Field is required';
                            } else if (value.trim().length < 3 ||
                                value.trim().length > 20) {
                              return 'UserName charcters must be between 3 and 20';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'UserName',
                            prefixIcon: const Icon(
                              Icons.person,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        CustomTextFormField(
                          hint: 'Email',
                          prefixIcon: Icons.email,
                          onChanged: (value) {
                            email = value;
                          },
                          autovalidateMode: autovalidateMode,
                        ),
                        const SizedBox(height: 28),
                        CustomTextFormField(
                          hint: 'Password',
                          prefixIcon: Icons.password,
                          onChanged: (value) {
                            password = value;
                          },
                          autovalidateMode: autovalidateMode,
                        ),
                        const SizedBox(height: 28),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (pickedImage == null) {
                                  showWarningMessageFun(
                                    context: context,
                                    text: 'Make sure you picked an image',
                                  );
                                } else {
                                  await BlocProvider.of<AuthCubit>(context)
                                      .signUp(
                                    atuhModel: AuthModel(
                                      email: email,
                                      password: password,
                                    ),
                                  );
                                }
                              } else {
                                autovalidateMode = AutovalidateMode.always;
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.sizeOf(context).width * 0.325,
                                vertical: 16,
                              ),
                              child: const Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        CheckAuthenticationCusomRow(
                          questionText: "Already have an account ? ",
                          text: 'Log In',
                          onTap: () => context.popView(),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
