import 'dart:convert';
import 'dart:io';

import 'package:einblicke_frame/features/show_image/data/data_sources/image_remote_data_source.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../fixtures.dart';
import '../../../../mocks.dart';

void main() {
  late ImageRemoteDataSource imageRemoteDataSource;
  late MockServerRemoteHandler mockServerRemoteHandler;
  late MockFailureMapper mockFailureMapper;

  setUp(() {
    mockServerRemoteHandler = MockServerRemoteHandler();
    mockFailureMapper = MockFailureMapper();
    imageRemoteDataSource = ImageRemoteDataSourceImpl(
      serverRemoteHandler: mockServerRemoteHandler,
      failureMapper: mockFailureMapper,
      secrets: tFakeSecrets,
    );
  });

  group('getImageIdStream', () {
    late HttpServer server;

    tearDown(() => server.close(force: true));

    test("should emit the image ids sent by the server", () async {
      // arrange
      server = await createWebSocketServer(onConnection: (channel) {
        channel.sink.add(jsonEncode({'image_id': tImageId}));
        channel.sink.add(jsonEncode({'image_id': tImageId2}));
      });

      // act
      final result = imageRemoteDataSource.getImageIdStream(
          accessToken: tAccessToken,
          webSocketUrl: Uri.parse("ws://localhost:${server.port}"));

      // assert
      await expectLater(
        result,
        emitsInOrder([
          tImageId,
          tImageId2,
        ]),
      );
    });

    test("should map failures sent by the server", () async {
      // arrange
      when(() => mockFailureMapper.mapCodeToFailure(any())).thenReturn(
        const ImageNotFoundFailure(),
      );
      server = await createWebSocketServer(
        onConnection: (channel) {
          channel.sink.add(
            jsonEncode(
              const ImageNotFoundFailure().toJson(),
            ),
          );
        },
      );

      // act
      final result = imageRemoteDataSource.getImageIdStream(
          accessToken: tAccessToken,
          webSocketUrl: Uri.parse("ws://localhost:${server.port}"));

      // assert
      await expectLater(
        result,
        emitsError(
          const ImageNotFoundFailure(),
        ),
      );
    });

    test(
        "should throw a [UnauthorizedFailure] when the server disconnects the client",
        () async {
      // arrange
      server = await createWebSocketServer();

      // act
      final result = imageRemoteDataSource.getImageIdStream(
          accessToken: tAccessToken,
          webSocketUrl: Uri.parse("ws://localhost:${server.port}"));

      server.close(force: true);

      // assert
      await expectLater(
        result,
        emitsError(
          const UnauthorizedFailure(),
        ),
      );
    });
  });
}

Future<HttpServer> createWebSocketServer({
  void Function(WebSocketChannel channel)? onConnection,
  int port = 0,
}) async {
  final server = await HttpServer.bind('localhost', port);
  server.transform(WebSocketTransformer()).listen((webSocket) {
    if (onConnection != null) onConnection(IOWebSocketChannel(webSocket));
  });
  return server;
}
