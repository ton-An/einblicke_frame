import 'package:einblicke_frame/features/authentication/presentation/cubits/pairing_cubit/pairing_cubit.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/pairing_cubit/pairing_states.dart';
import 'package:einblicke_frame/features/show_image/presentation/pages/image_screen.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  @override
  void initState() {
    super.initState();

    context.read<PairingCubit>().initPairing();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
    );
  }
}
