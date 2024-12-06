import 'package:einblicke_frame/core/dependency_injector.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/pairing_cubit/pairing_cubit.dart';
import 'package:einblicke_frame/features/authentication/presentation/pages/pairing_page.dart';
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

  // sendImage();

  runApp(EinblickeFrame());
}

// void sendImage() {
//   // Create a 256x256 8-bit (default) rgb (default) image.
//   final image = img.Image(width: 256, height: 256);
//   // Iterate over its pixels

//   for (int i = 0; i < image.length; i++) {
//     // first half of the image is black, second half is white
//     final x = i % 256;
//     final y = i ~/ 256;

//     if (i < image.length / 2) {
//       image..setPixel(x, y, img.ColorInt8.rgb(0, 0, 0));
//     } else {
//       image..setPixel(x, y, img.ColorInt8.rgb(255, 255, 255));
//     }
//     // Set the pixels red value to its x position value, creating a gradient.
//   }
//   // Encode the resulting image to the PNG image format.
//   final png = img.encodePng(image);
//   File('example.png').writeAsBytesSync(png);
//   // Write the PNG formatted data to a file.
// }

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
                path: PairingPage.pageName,
                pageBuilder: (context, state) => CupertinoPage(
                  child: BlocProvider(
                      create: (context) => getIt<PairingCubit>(),
                      child: const PairingPage()),
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
