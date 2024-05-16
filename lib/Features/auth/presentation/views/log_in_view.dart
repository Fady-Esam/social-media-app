import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_states.dart';
import 'package:tiktok/Features/auth/presentation/views/sign_up_view.dart';
import 'package:tiktok/core/functions/show_snack_bar_fun.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';

import '../../data/models/auth_model.dart';
import 'widgets/check_authentication_custom_row.dart';
import 'widgets/custom_text_field.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  String password = '';
  String email = '';
  GlobalKey<FormState> formKey = GlobalKey();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context).checkStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LogInSuccessState) {
          isLoading = false;
          BlocProvider.of<AuthCubit>(context).checkStateChanges();
        } else if (state is LogInFailureState) {
          isLoading = false;
          showSnackBarFun(
              context: context, text: '${state.errMessage}, Please try again');
        } else if (state is LogInLoadingState) {
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
                        const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
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
                                await BlocProvider.of<AuthCubit>(context).logIn(
                                  atuhModel: AuthModel(
                                    email: email,
                                    password: password,
                                  ),
                                );
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
                                    MediaQuery.sizeOf(context).width * 0.33,
                                vertical: 12,
                              ),
                              child: const Text(
                                'Sign In',
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
                          questionText: "Don't have an account ? ",
                          text: 'Sign Up',
                          onTap: () => context.pushToView(view: SignUpView()),
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
