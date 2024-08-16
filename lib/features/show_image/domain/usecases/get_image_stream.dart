import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/stream_server_auth_wrapper.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

/*
  To-Do:
  - [ ] Add potential failures
  - [ ] What happens if the access token gets invalidated during the stream?
  - [ ] Find a proper solution for getting the web socket url
*/

/// _Get Image Stream_ gets a stream of images from the server which updates whenever a new image uploaded by a curator
///
/// Returns:
/// - [Stream] of [Uint8List] containing the image data
///
/// Failures:
/// - TBD
/// - {@macro converted_dio_exceptions}

class GetImageStream {
  final ImageRepository imageRepository;
  final StreamServerAuthWrapper<String> streamServerAuthWrapper;
  final GetImage getImage;
  final Secrets secrets;

  const GetImageStream({
    required this.imageRepository,
    required this.streamServerAuthWrapper,
    required this.getImage,
    required this.secrets,
  });

  Stream<Either<Failure, Uint8List>> call() {
    return _getImageIdStream();
  }

  Stream<Either<Failure, Uint8List>> _getImageIdStream() async* {
    final Stream<Either<Failure, String>> imageStream =
        streamServerAuthWrapper.call(
      serverCall: (AuthenticationToken accessToken) {
        return imageRepository.getImageIdStream(
          accessToken: accessToken,
          webSocketUrl: Uri.parse(
              "${secrets.serverUrl.replaceFirst("http://", "ws://")}/frame/image_socket"),
        );
      },
    );

    await for (Either<Failure, String> imageIdEither in imageStream) {
      yield* imageIdEither.fold(
        (Failure failure) async* {
          yield Left(failure);
        },
        (String imageId) async* {
          yield await getImage(imageId: imageId);
        },
      );
    }
  }
}
