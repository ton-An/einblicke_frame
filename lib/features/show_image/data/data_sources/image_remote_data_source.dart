import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

/// {@template image_remote_data_source}
/// __Image Remote Data Source__ is a contract for remote data source operations related to images.
/// {@endtemplate}
abstract class ImageRemoteDataSource {
  /// Get a stream of image id from the server which updates whenever a new image uploaded by a curator
  ///
  /// Returns:
  /// - [Stream] containing [Either] a [Failure] or a [String] containing the image id
  ///
  /// Exceptions:
  /// - [DatabaseReadFailure]
  /// - [NoImagesFoundFailure]
  /// - [StorageReadFailure]
  /// - [DioException]
  Future<Stream<Either<Failure, String>>> getImageIdStream({
    required AuthenticationToken accessToken,
  });

  /// Get the image from the server
  ///
  /// Returns:
  /// - [Uint8List] containing the image
  ///
  /// Exceptions:
  /// - [DatabaseReadFailure]
  /// - [StorageReadFailure]
  /// - [ImageNotFoundFailure]
  /// - [DioException]
  Future<Uint8List> getImage({
    required AuthenticationToken accessToken,
    required String imageId,
  });
}
