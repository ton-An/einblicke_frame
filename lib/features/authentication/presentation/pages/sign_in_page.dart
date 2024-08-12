import 'package:einblicke_frame/core/secrets.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/sign_in_cubit/sign_in_cubit.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/sign_in_cubit/sign_in_states.dart';
import 'package:einblicke_frame/features/show_image/presentation/pages/image_screen.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// __Sign In Page__
///
/// The sign in page of the app.
/// Automatically signs in the user with the secret user credentials. (Temporary)
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  static const String pageName = "sign_in_page";
  static const String route = "/$pageName";

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    super.initState();

    context.read<SignInCubit>().updateUsername(username);
    context.read<SignInCubit>().updatePassword(password);
    context.read<SignInCubit>().signIn();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInCubit, SignInState>(
      bloc: context.read<SignInCubit>(),
      listener: (context, state) {
        if (state is SignInSuccess) {
          context.go(ImageScreen.route);
        } else if (state is AuthenticationSignedOut) {
          context
              .read<InAppNotificationCubit>()
              .sendFailureNotification(const UnauthorizedFailure());
        } else if (state is SignInFailure) {
          context
              .read<InAppNotificationCubit>()
              .sendFailureNotification(state.failure);
        }
      },
      child: const CupertinoPageScaffold(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loader(),
              MediumGap(),
              Text("Signing in..."),
            ],
          ),
        ),
      ),
    );
  }
}
