import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

/// {@template get_image}
/// _Get Image_ gets an image from the server
///
/// Parameters:
/// - [String] imageId: the id of the image to get
///
/// Returns:
/// - [Uint8List] containing the image data
///
/// Failures:
/// - TBD
/// - {@macro converted_dio_exceptions}
/// {@endtemplate}
class GetImage {
  final ImageRepository imageRepository;
  final ServerAuthWrapper<Uint8List> serverAuthWrapper;

  /// {@macro get_image}
  const GetImage({
    required this.imageRepository,
    required this.serverAuthWrapper,
  });

  /// {@macro get_image}
  Future<Either<Failure, Uint8List>> call({
    required String imageId,
  }) {
    return serverAuthWrapper.call(
      serverCall: (AuthenticationToken accessToken) {
        return imageRepository.getImage(
          accessToken: accessToken,
          imageId: imageId,
        );
      },
    );
  }
}
