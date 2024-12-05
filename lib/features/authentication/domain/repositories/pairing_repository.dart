import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/authentication/domain/models/pairing_event.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

abstract class PairingRepository {
  const PairingRepository();

  Stream<Either<Failure, PairingEvent>> initPairingProcess({
    required Uri websocketUrl,
    required Secrets secrets,
  });
}
