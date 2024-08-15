import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/data/data_sources/image_remote_data_source.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:mocktail/mocktail.dart';

class MockServerAuthWrapper<T> extends Mock implements ServerAuthWrapper<T> {}

class MockImageRepository extends Mock implements ImageRepository {}

class MockGetImage extends Mock implements GetImage {}

class MockServerCall extends Mock {
  Future<Either<Failure, dynamic>> call(AuthenticationToken accessToken);
}

class MockFailureHandler extends Mock implements RepositoryFailureHandler {}

class MockImageRemoteDataSource extends Mock implements ImageRemoteDataSource {}
