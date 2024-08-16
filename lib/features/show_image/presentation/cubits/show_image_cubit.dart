import 'package:einblicke_frame/features/show_image/domain/usecases/get_image_stream.dart';
import 'package:einblicke_frame/features/show_image/presentation/cubits/show_image_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowImageCubit extends Cubit<ShowImageState> {
  ShowImageCubit({
    required this.getImageStream,
  }) : super(ShowImageLoading());

  final GetImageStream getImageStream;

  void setUpImageStream() {
    getImageStream().listen((imageBytesEither) {
      imageBytesEither.fold(
          (failure) => emit(ShowImageFailure(failure: failure)),
          (imageBytes) => emit(ShowImageLoaded(imageBytes: imageBytes)));
    });
  }
}
