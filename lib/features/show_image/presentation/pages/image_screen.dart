import 'package:einblicke_frame/features/show_image/presentation/cubits/show_image_cubit.dart';
import 'package:einblicke_frame/features/show_image/presentation/cubits/show_image_state.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// __Image Screen__
///
/// The image screen of the app.
/// Gets the latest image from the server and displays it.
class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  static const String pageName = "image_screen";
  static const String route = "/$pageName";

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShowImageCubit>().setUpImageStream();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: BlocConsumer<ShowImageCubit, ShowImageState>(
          listener: (context, state) {
        if (state is ShowImageFailure) {
          context
              .read<InAppNotificationCubit>()
              .sendFailureNotification(state.failure);
        }
      }, builder: (context, state) {
        if (state is ShowImageLoaded) {
          return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.memory(state.imageBytes, fit: BoxFit.cover));
        }

        return const Center(child: Loader());
      }),
    );
  }
}
