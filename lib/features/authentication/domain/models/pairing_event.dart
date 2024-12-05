import 'package:einblicke_shared/einblicke_shared.dart';

abstract class PairingEvent {
  const PairingEvent();
}

class PairingTempIdAcquired extends PairingEvent {
  const PairingTempIdAcquired({
    required this.tempId,
  });

  final String tempId;
}

class PairingSuccessful extends PairingEvent {
  const PairingSuccessful({required this.tokenBundle});

  final TokenBundle tokenBundle;
}
