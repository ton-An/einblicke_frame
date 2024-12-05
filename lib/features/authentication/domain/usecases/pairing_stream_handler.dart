import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/authentication/domain/models/pairing_event.dart';
import 'package:einblicke_frame/features/authentication/domain/repositories/pairing_repository.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/stream_server_auth_wrapper.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

class PairingStreamHandler {
  PairingStreamHandler({
    required this.streamServerAuthWrapper,
    required this.pairingRepository,
    required this.secrets,
    required this.authenticationRepository,
  });

  final StreamServerAuthWrapper<PairingEvent> streamServerAuthWrapper;
  final PairingRepository pairingRepository;
  final Secrets secrets;
  final AuthenticationRepository authenticationRepository;

  Stream<Either<Failure, PairingEvent>> call() {
    return _initPairingStream();
  }

  Stream<Either<Failure, PairingEvent>> _initPairingStream() async* {
    final Stream<
        Either<Failure,
            PairingEvent>> pairingStream = pairingRepository.initPairingProcess(
        websocketUrl: Uri.parse(
            "${secrets.serverUrl.replaceFirst("http://", "ws://")}/frame/pairing_socket"),
        secrets: secrets);

    await for (Either<Failure, PairingEvent> pairingEventEither
        in pairingStream) {
      yield* pairingEventEither.fold((Failure failure) async* {
        yield Left(failure);
      }, (PairingEvent pairingEvent) async* {
        yield* _handlePairingEvent(pairingEvent: pairingEvent);
      });
    }
  }

  Stream<Either<Failure, PairingEvent>> _handlePairingEvent(
      {required PairingEvent pairingEvent}) async* {
    if (pairingEvent is PairingSuccessful) {
      final TokenBundle tokenBundle = pairingEvent.tokenBundle;

      final Either<Failure, None> tokenBundleSaveResult =
          await authenticationRepository.saveTokenBundle(
              tokenBundle: tokenBundle);

      yield* tokenBundleSaveResult.fold(
        (Failure failure) async* {
          yield Left(failure);
        },
        (_) async* {},
      );
    }

    yield Right(pairingEvent);
  }
}
