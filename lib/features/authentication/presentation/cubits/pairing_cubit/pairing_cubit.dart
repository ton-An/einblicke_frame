import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/authentication/domain/models/pairing_event.dart';
import 'package:einblicke_frame/features/authentication/domain/usecases/pairing_stream_handler.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/pairing_cubit/pairing_states.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/*
  To-Do:
  - [ ] Delete this file once a permanent solution is found.
*/

class PairingCubit extends Cubit<PairingCubitState> {
  PairingCubit({required this.pairingStreamHandler})
      : super(const PairingCubitInitial());

  final PairingStreamHandler pairingStreamHandler;

  void initPairing() async {
    emit(const PairingCubitLoading());

    final Stream<Either<Failure, PairingEvent>> pairingStream =
        pairingStreamHandler();

    await for (Either<Failure, PairingEvent> pairingEventEither
        in pairingStream) {
      pairingEventEither.fold(
        (Failure failure) {
          emit(PairingCubitFailure(failure: failure));
        },
        (PairingEvent pairingEvent) {
          if (pairingEvent is PairingTempIdAcquired) {
            emit(PairingCubitQRCodeReceived(qrCode: pairingEvent.tempId));
          } else if (pairingEvent is PairingSuccessful) {
            emit(const PairingCubitSuccess());
          }
        },
      );
    }
  }
}
