import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:einblicke_frame/features/authentication/presentation/cubits/pairing_cubit/pairing_cubit.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/pairing_cubit/pairing_states.dart';
import 'package:einblicke_frame/features/gpio/epd_2in13d.dart';
import 'package:einblicke_frame/features/show_image/presentation/pages/image_screen.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:qr_bar_code/code/code.dart';

/// __Sign In Page__
///
/// The sign in page of the app.
/// Automatically signs in the user with the secret user credentials. (Temporary)
class PairingPage extends StatefulWidget {
  const PairingPage({super.key});

  static const String pageName = "sign_in_page";
  static const String route = "/$pageName";

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    context.read<PairingCubit>().initPairing();

    Future.delayed(const Duration(seconds: 1), () {
      _captureAndSave();
    });
  }

  Future<void> _captureAndSave() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    img.Image? image2 = img.decodeImage(pngBytes);

    final Epd2in13d epd = Epd2in13d();

    epd.init();
    epd.Clear();

    epd.display(image2!);
  }

  @override
  Widget build(BuildContext context) {
    print("asdasd");
    return RepaintBoundary(
      key: globalKey,
      child: CupertinoPageScaffold(
        child: Center(
          child: BlocConsumer<PairingCubit, PairingCubitState>(
            bloc: context.read<PairingCubit>(),
            listener: (context, state) {
              if (state is PairingCubitSuccess) {
                context.go(ImageScreen.route);
              } else if (state is PairingCubitFailure) {
                context
                    .read<InAppNotificationCubit>()
                    .sendFailureNotification(state.failure);
              }
            },
            builder: (context, state) {
              if (state is PairingCubitQRCodeReceived) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Code(
                      data: state.qrCode,
                      codeType: CodeType.qrCode(),
                    )
                  ],
                );
              }

              return const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Loader(),
                  MediumGap(),
                  Text("Pairing..."),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
