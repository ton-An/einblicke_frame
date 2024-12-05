import 'package:einblicke_shared/einblicke_shared.dart';

/*
  To-Dos:
  - [ ] Re-do naming os states
*/

abstract class PairingCubitState {
  const PairingCubitState();
}

class PairingCubitInitial extends PairingCubitState {
  const PairingCubitInitial();
}

class PairingCubitLoading extends PairingCubitState {
  const PairingCubitLoading();
}

class PairingCubitQRCodeReceived extends PairingCubitState {
  const PairingCubitQRCodeReceived({
    required this.qrCode,
  });

  final String qrCode;
}

class PairingCubitSuccess extends PairingCubitState {
  const PairingCubitSuccess();
}

class PairingCubitFailure extends PairingCubitState {
  const PairingCubitFailure({
    required this.failure,
  });

  final Failure failure;
}
