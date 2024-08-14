import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

/*
  To-Do:
  - [ ] Add potential failures
  - [ ] What happens if the access token gets invalidated during the stream?
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
  final ServerAuthWrapper<Stream<Either<Failure, String>>> serverAuthWrapper;
  final GetImage getImage;

  const GetImageStream({
    required this.imageRepository,
    required this.serverAuthWrapper,
    required this.getImage,
  });

  Stream<Either<Failure, Uint8List>> call() {
    return _getImageIdStream();
  }

  Stream<Either<Failure, Uint8List>> _getImageIdStream() async* {
    final Either<Failure, Stream<Either<Failure, String>>> imageStreamEither =
        await serverAuthWrapper.call(
      serverCall: (AuthenticationToken accessToken) {
        return imageRepository.getImageIdStream(
          accessToken: accessToken,
        );
      },
    );

    yield* imageStreamEither.fold(
      (Failure failure) async* {
        yield Left(failure);
      },
      (Stream<Either<Failure, String>> imageStream) async* {
        yield* _generateImageByteStream(imageStream);
      },
    );
  }

  Stream<Either<Failure, Uint8List>> _generateImageByteStream(
      Stream<Either<Failure, String>> imageStream) async* {
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
