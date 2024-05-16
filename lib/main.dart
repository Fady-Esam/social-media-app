import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/share/share_cubit.dart';
import 'package:tiktok/Features/add_video/presentaion/manager/video_data/video_data_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:tiktok/Features/auth/presentation/manager/auth_cubit/auth_states.dart';
import 'package:tiktok/Features/auth/presentation/manager/user_data-cubit/user_data_cubit.dart';
import 'package:tiktok/Features/auth/presentation/views/log_in_view.dart';
import 'package:tiktok/Features/message/presentaion/manager/message_cubit/message_cubit.dart';
import 'package:tiktok/Features/profile/presentaion/manager/follow_cubit/follow_cubit.dart';
import 'package:tiktok/Features/search/presentaion/manager/search_cubit/search_cubit.dart';
import 'package:tiktok/core/widgets/tabs_nav.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TikTok());
}

class TikTok extends StatelessWidget {
  const TikTok({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => UserDataCubit()),
        BlocProvider(create: (context) => ShareCubit()),
        BlocProvider(create: (context) => VideoDataCubit()),
        BlocProvider(create: (context) => MessageCubit()),
        BlocProvider(create: (context) => FollowCubit()),
        BlocProvider(create: (context) => SearchCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is CheckAuthStateLoggedInUser) {
              return const TabsNav();
            } else {
              return const LogInView();
            }
          },
        ),
      ),
    );
  }
}
