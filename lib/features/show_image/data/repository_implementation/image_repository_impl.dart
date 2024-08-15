import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:einblicke_frame/features/show_image/data/data_sources/image_remote_data_source.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';

/// {@macro image_repository}
class ImageRepositoryImpl extends ImageRepository {
  /// {@macro image_repository}
  ImageRepositoryImpl({
    required this.imageRemoteDataSource,
    required this.failureHandler,
  });

  final ImageRemoteDataSource imageRemoteDataSource;
  final RepositoryFailureHandler failureHandler;

  @override
  Future<Either<Failure, Stream<Either<Failure, String>>>> getImageIdStream(
      {required AuthenticationToken accessToken}) async {
    try {
      final Stream<Either<Failure, String>> imageIdStream =
          await imageRemoteDataSource.getImageIdStream(
              accessToken: accessToken);

      return Right(imageIdStream);
    } catch (exception) {
      if (exception is DatabaseReadFailure ||
          exception is NoImagesFoundFailure ||
          exception is StorageReadFailure) {
        return Left(exception as Failure);
      } else if (exception is DioException) {
        return Left(failureHandler.dioExceptionMapper(exception));
      } else {
        rethrow;
      }
    }
  }

// - [DatabaseReadFailure]
  /// - [NoImagesFoundFailure]
  /// - [StorageReadFailure]
  @override
  Future<Either<Failure, Uint8List>> getImage(
      {required AuthenticationToken accessToken,
      required String imageId}) async {
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
