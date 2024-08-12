import 'package:einblicke_frame/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:einblicke_frame/features/show_image/presentation/pages/image_screen.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// __Splash Screen__
///
/// The splash screen of the app.
/// Checks if the user is signed in and redirects to the appropriate page.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String pageName = "splash_screen";
  static const String route = "/$pageName";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationStatusCubit>().checkAuthenticationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationStatusCubit, AuthenticationState>(
      bloc: context.read<AuthenticationStatusCubit>(),
      listener: (context, state) {
        if (state is AuthenticationSignedIn) {
          context.go(ImageScreen.route);
        } else if (state is AuthenticationSignedOut) {
          context.go(SignInPage.route);
        } else if (state is AuthenticationFailureState) {
          context
              .read<InAppNotificationCubit>()
              .sendFailureNotification(state.failure);
          context.go(SignInPage.route);
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
              Text("Checking authentication status..."),
            ],
          ),
        ),
      ),
    );
  }
}
