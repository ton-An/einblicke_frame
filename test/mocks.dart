import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/data/data_sources/image_remote_data_source.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/stream_server_auth_wrapper.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:mocktail/mocktail.dart';

class MockServerAuthWrapper<T> extends Mock implements ServerAuthWrapper<T> {}

class MockStreamServerAuthWrapper<T> extends Mock
    implements StreamServerAuthWrapper<T> {}

class MockImageRepository extends Mock implements ImageRepository {}

class MockGetImage extends Mock implements GetImage {}

class MockServerCall extends Mock {
  Stream<Either<Failure, String>> call(AuthenticationToken accessToken);
}

class MockFailureHandler extends Mock implements RepositoryFailureHandler {}

class MockImageRemoteDataSource extends Mock implements ImageRemoteDataSource {}

class MockServerRemoteHandler extends Mock implements ServerRemoteHandler {}

class MockFailureMapper extends Mock implements FailureMapper {}

class MockRefreshTokenBundle extends Mock implements RefreshTokenBundle {}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}
