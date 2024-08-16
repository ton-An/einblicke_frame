import 'dart:typed_data';

import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:equatable/equatable.dart';

abstract class ShowImageState extends Equatable {}

class ShowImageLoading extends ShowImageState {
  @override
  List<Object> get props => [];
}

class ShowImageLoaded extends ShowImageState {
  final Uint8List imageBytes;

  ShowImageLoaded({required this.imageBytes});

  @override
  List<Object> get props => [imageBytes];
}

class ShowImageFailure extends ShowImageState {
  final Failure failure;

  ShowImageFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}
