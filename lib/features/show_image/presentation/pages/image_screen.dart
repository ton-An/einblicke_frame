import 'package:flutter/cupertino.dart';

/// __Image Screen__
///
/// The image screen of the app.
/// Gets the latest image from the server and displays it.
class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key});

  static const String pageName = "image_screen";
  static const String route = "/$pageName";

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(child: Center(child: Text("Yippie :)")));
  }
}
