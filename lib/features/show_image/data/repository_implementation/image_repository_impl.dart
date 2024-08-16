import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:einblicke_frame/features/show_image/data/data_sources/image_remote_data_source.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';

/// {@template image_repository_impl}
/// __Image Repository Implementation__ is the concrete implementation of
/// the [ImageRepository] contract and handles the repository operations
/// related to images.
/// {@endtemplate}
class ImageRepositoryImpl extends ImageRepository {
  /// {@macro image_repository_impl}
  ImageRepositoryImpl({
    required this.imageRemoteDataSource,
    required this.failureHandler,
  });

  final ImageRemoteDataSource imageRemoteDataSource;
  final RepositoryFailureHandler failureHandler;

  @override
  Stream<Either<Failure, String>> getImageIdStream({
    required AuthenticationToken accessToken,
    required Uri webSocketUrl,
  }) async* {
    try {
      Stream<String> imageIdStream = imageRemoteDataSource.getImageIdStream(
          accessToken: accessToken, webSocketUrl: webSocketUrl);

      await for (String imageId in imageIdStream) {
        yield Right(imageId);
      }
    } catch (exception) {
      if (exception is FormatException) {
        yield const Left(MalformedWebSocketMessageFailure());
      } else if (exception is UnauthorizedFailure ||
          exception is DatabaseReadFailure ||
          exception is NoImagesFoundFailure ||
          exception is StorageReadFailure ||
          exception is MalformedWebSocketMessageFailure) {
        yield Left(exception as Failure);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Either<Failure, Uint8List>> getImage({
    required AuthenticationToken accessToken,
    required String imageId,
  }) async {
    try {
      final Uint8List imageBytes = await imageRemoteDataSource.getImage(
        accessToken: accessToken,
        imageId: imageId,
      );

      return Right(imageBytes);
    } catch (exception) {
      if (exception is DatabaseReadFailure ||
          exception is StorageReadFailure ||
          exception is ImageNotFoundFailure) {
        return Left(exception as Failure);
      } else if (exception is DioException) {
        return Left(failureHandler.dioExceptionMapper(exception));
      } else {
        rethrow;
      }
    }
  }
}
