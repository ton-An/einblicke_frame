import 'package:einblicke_frame/core/dependency_injector.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/sign_in_cubit/sign_in_cubit.dart';
import 'package:einblicke_frame/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:einblicke_frame/features/authentication/presentation/pages/splash_screen.dart';
import 'package:einblicke_frame/features/show_image/presentation/cubits/show_image_cubit.dart';
import 'package:einblicke_frame/features/show_image/presentation/pages/image_screen.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart' as l10n;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  initGetIt();

  runApp(EinblickeFrame());
}

class EinblickeFrame extends StatelessWidget {
  EinblickeFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<InAppNotificationCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<AuthenticationStatusCubit>(),
        ),
      ],
      child: CupertinoApp.router(
        title: "Einblicke",
        localizationsDelegates: const [
          l10n.AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("en"),
        ],
        theme: const CupertinoThemeData(
          scaffoldBackgroundColor: CustomCupertinoColors.white,
        ),
        routerConfig: _router,
      ),
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: SplashScreen.route,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            InAppNotificationListener(child: child),
        routes: [
          GoRoute(
            path: "/",

            /// This base route is necessary for the edges of the modal to be blurred
            /// when an [InAppNotification] is shown.
            pageBuilder: (context, state) => const CupertinoPage(
              child: ColoredBox(color: Colors.black),
            ),
            routes: [
              GoRoute(
                path: SplashScreen.pageName,
                pageBuilder: (context, state) => const CupertinoPage(
                  child: SplashScreen(),
                ),
              ),
              GoRoute(
                path: SignInPage.pageName,
                pageBuilder: (context, state) => CupertinoPage(
                  child: BlocProvider(
                      create: (context) => getIt<SignInCubit>(),
                      child: const SignInPage()),
                ),
              ),
              GoRoute(
                path: ImageScreen.pageName,
                pageBuilder: (context, state) => CupertinoPage(
                  child: BlocProvider(
                    create: (context) => getIt<ShowImageCubit>(),
                    child: const ImageScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
