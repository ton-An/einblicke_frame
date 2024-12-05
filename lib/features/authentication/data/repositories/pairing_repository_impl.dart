import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/authentication/data/datasources/pairing_data_source.dart';
import 'package:einblicke_frame/features/authentication/domain/models/pairing_event.dart';
import 'package:einblicke_frame/features/authentication/domain/repositories/pairing_repository.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

class PairingRepositoryImpl extends PairingRepository {
  const PairingRepositoryImpl({
    required this.pairingRemoteDataSource,
  });

  final PairingRemoteDataSource pairingRemoteDataSource;

  @override
  Stream<Either<Failure, PairingEvent>> initPairingProcess({
    required Uri websocketUrl,
    required Secrets secrets,
  }) async* {
    try {
      final Stream<PairingEvent> pairingEventStream =
          pairingRemoteDataSource.initPairingProcess(
        websocketUrl: websocketUrl,
        secrets: secrets,
      );

      await for (PairingEvent pairingEvent in pairingEventStream) {
        yield Right(pairingEvent);
      }
    } catch (exception) {
      if (exception is FormatException) {
        yield const Left(MalformedWebSocketMessageFailure());
      } else if (exception is UnauthorizedFailure ||
          exception is MalformedWebSocketMessageFailure) {
        yield Left(exception as Failure);
      } else {
        rethrow;
      }
    }
  }
}
