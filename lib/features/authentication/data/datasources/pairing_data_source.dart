import 'dart:convert';

import 'package:async/async.dart';
import 'package:einblicke_frame/features/authentication/domain/models/pairing_event.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:web_socket_client/web_socket_client.dart';

abstract class PairingRemoteDataSource {
  const PairingRemoteDataSource();

  Stream<PairingEvent> initPairingProcess({
    required Uri websocketUrl,
    required Secrets secrets,
  });
}

class PairingRemoteDataSourceImpl extends PairingRemoteDataSource {
  const PairingRemoteDataSourceImpl({
    required this.failureMapper,
  });

  final FailureMapper failureMapper;
  @override
  Stream<PairingEvent> initPairingProcess({
    required Uri websocketUrl,
    required Secrets secrets,
  }) async* {
    WebSocket webSocket = WebSocket(
      websocketUrl,
      headers: {
        "client_secret": secrets.clientSecret,
        "client_id": secrets.clientId,
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
        if (json.containsKey("temp_frame_id")) {
          yield PairingTempIdAcquired(tempId: json["temp_frame_id"]!);
        } else if (json.containsKey("access_token")) {
          final TokenBundle tokenBundle = TokenBundle.fromJson(json);

          yield PairingSuccessful(tokenBundle: tokenBundle);
        } else if (json.containsKey("code")) {
          throw failureMapper.mapCodeToFailure(json["code"]!);
        } else {
          throw const MalformedWebSocketMessageFailure();
        }
      }
    }
  }
}
