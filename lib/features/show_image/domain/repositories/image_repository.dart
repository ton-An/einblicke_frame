import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

/// {@template show_image_repository}
/// __Show Image Repository__ is a contract for repository operations related to showing an image.
/// {@endtemplate}
abstract class ImageRepository {
  /// Get a stream of image id from the server which updates whenever a new image uploaded by a curator
  ///
  /// Returns:
  /// - [Stream] of [String] containing the image id
  ///
  /// Failures:
  /// - TBD
  /// - {@macro converted_dio_exceptions}
  Future<Either<Failure, Stream<Either<Failure, String>>>> getImageIdStream({
    required AuthenticationToken accessToken,
  });

  /// Gets an image from the server
  ///
  /// Returns:
  /// - [Uint8List] containing the image data
  ///
  /// Failures:
  /// - TBD
  /// - {@macro converted_dio_exceptions}
  Future<Either<Failure, Uint8List>> getImage({
    required AuthenticationToken accessToken,
    required String imageId,
  });
}
