import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart' show StreamGroup;
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:web_socket_client/web_socket_client.dart';

/*
  To-Do:
  - [ ] Find a proper solution for getting the web socket url. Probably in a usecase.
*/

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
  /// - [UnauthorizedFailure]
  /// - [MalformedWebSocketMessageFailure]
  Stream<String> getImageIdStream({
    required AuthenticationToken accessToken,
    required Uri webSocketUrl,
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
  /// - [UnauthorizedFailure]
  /// - [DioException]
  Future<Uint8List> getImage({
    required AuthenticationToken accessToken,
    required String imageId,
  });
}

/// {@template image_remote_data_source_impl}
/// __Image Remote Data Source Implementation__ is the concrete implementation of the [ImageRemoteDataSource] contract
/// and handles the remote data source operations related to images.
/// {@endtemplate}
class ImageRemoteDataSourceImpl extends ImageRemoteDataSource {
  /// {@macro image_remote_data_source_impl}
  ImageRemoteDataSourceImpl({
    required this.serverRemoteHandler,
    required this.failureMapper,
    required this.secrets,
  });

  final ServerRemoteHandler serverRemoteHandler;
  final FailureMapper failureMapper;
  final Secrets secrets;

  @override
  Future<Uint8List> getImage(
      {required AuthenticationToken accessToken,
      required String imageId}) async {
    final Uint8List response = await serverRemoteHandler.getBytes(
      path: "/get_image?image_id=$imageId",
      accessToken: accessToken.token,
    );

    return response;
  }

  @override
  Stream<String> getImageIdStream({
    required AuthenticationToken accessToken,
    required Uri webSocketUrl,
  }) async* {
    WebSocket webSocket = WebSocket(
      webSocketUrl,
      headers: {
        "Authorization": "Bearer ${accessToken.token}",
      },
      timeout: const Duration(seconds: 2),
    );

    Stream mergedStream = StreamGroup.merge([
      webSocket.connection,
      webSocket.messages,
    ]);

    await for (dynamic message in mergedStream) {
      if (message is Disconnected) {
        throw const UnauthorizedFailure();
      } else if (message is String) {
        final Map<String, dynamic> json = jsonDecode(message);

        if (json.containsKey("image_id")) {
          yield json["image_id"]!;
        } else if (json.containsKey("code")) {
          throw failureMapper.mapCodeToFailure(json["code"]!);
        } else {
          throw const MalformedWebSocketMessageFailure();
        }
      }
    }
  }
}
