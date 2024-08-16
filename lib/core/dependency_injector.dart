import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:einblicke_frame/core/secrets.dart';
import 'package:einblicke_frame/features/authentication/presentation/cubits/sign_in_cubit/sign_in_cubit.dart';
import 'package:einblicke_frame/features/show_image/data/data_sources/image_remote_data_source.dart';
import 'package:einblicke_frame/features/show_image/data/repository_implementation/image_repository_impl.dart';
import 'package:einblicke_frame/features/show_image/domain/repositories/image_repository.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image_stream.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/stream_server_auth_wrapper.dart';
import 'package:einblicke_frame/features/show_image/presentation/cubits/show_image_cubit.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:einblicke_shared_clients/einblicke_shared_clients.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/*
  To-Dos:
  - [ ] Revamp to make structure clearer (will become more important as the app grows)
*/

final GetIt getIt = GetIt.instance;

void initGetIt() {
  // =+=+ 3rd Party +=+= //
  getIt.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: "${getIt<Secrets>().serverUrl}/frame",
        validateStatus: (status) => true,
      ),
    ),
  );
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  // =+=+ Shared +=+= //
  getIt.registerLazySingleton(() => const FailureMapper());

  // =+=+ Core +=+= //
  _registerCore();

  // =+=+ Authentication +=+= //
  _registerAuthentication();

  // =+=+ Show Image +=+= //
  _registerShowImage();
}

void _registerCore() {
  getIt.registerLazySingleton<Secrets>(() => const SecretsImpl());

  // -- Data -- //
  getIt.registerLazySingleton(
    () => ServerRemoteHandler(dio: getIt(), failureMapper: getIt()),
  );
  getIt.registerLazySingleton(() => const RepositoryFailureHandler());

  // -- Presentation -- //
  getIt.registerFactory(() => InAppNotificationCubit());
}

void _registerAuthentication() {
  // -- Data -- //
  getIt.registerLazySingleton<AuthenticationLocalDataSource>(
    () => AuthenticationLocalDataSourceImpl(
      secureStorage: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSourceImpl(
      serverRemoteHandler: getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      authenticationLocalDataSource: getIt(),
      authenticationRemoteDataSource: getIt(),
      failureHandler: getIt(),
    ),
  );

  // -- Domain -- //
  getIt.registerLazySingleton(
      () => SignIn(authenticationRepository: getIt(), secrets: getIt()));
  getIt.registerLazySingleton(
      () => IsSingnedIn(authenticationRepository: getIt()));
  getIt.registerLazySingleton(
      () => RefreshTokenBundle(authenticationRepository: getIt()));

  // -- Presentation -- //
  getIt.registerFactory(() => AuthenticationStatusCubit(isSignedIn: getIt()));
  getIt.registerFactory(
    () => SignInCubit(
      signInUsecase: getIt(),
    ),
  );
}

void _registerShowImage() {
  // -- Data -- //
  getIt.registerLazySingleton<ImageRemoteDataSource>(
    () => ImageRemoteDataSourceImpl(
      serverRemoteHandler: getIt(),
      failureMapper: getIt(),
      secrets: getIt(),
    ),
  );

  getIt.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(
      imageRemoteDataSource: getIt(),
      failureHandler: getIt(),
    ),
  );

  // -- Domain -- //
  getIt.registerLazySingleton(
    () => ServerAuthWrapper<Uint8List>(
      authenticationRepository: getIt(),
      refreshTokenBundle: getIt(),
    ),
  );
  getIt.registerLazySingleton(
      () => GetImage(imageRepository: getIt(), serverAuthWrapper: getIt()));
  getIt.registerLazySingleton(
    () => StreamServerAuthWrapper<String>(
      authenticationRepository: getIt(),
      refreshTokenBundle: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetImageStream(
      imageRepository: getIt(),
      streamServerAuthWrapper: getIt(),
      getImage: getIt(),
      secrets: getIt(),
    ),
  );

  // -- Presentation -- //
  getIt.registerFactory(
    () => ShowImageCubit(
      getImageStream: getIt(),
    ),
  );
}
