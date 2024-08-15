import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/data/repository_implementation/image_repository_impl.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures.dart';
import '../../../mocks.dart';

void main() {
  late ImageRepositoryImpl imageRepositoryImpl;
  late MockImageRemoteDataSource mockImageRemoteDataSource;
  late MockFailureHandler mockFailureHandler;

  setUp(() {
    // -- Definitions
    mockImageRemoteDataSource = MockImageRemoteDataSource();
    mockFailureHandler = MockFailureHandler();
    imageRepositoryImpl = ImageRepositoryImpl(
      imageRemoteDataSource: mockImageRemoteDataSource,
      failureHandler: mockFailureHandler,
    );
  });

  setUpAll(() {
    // -- Fallbacks
    registerFallbackValue(tAccessToken);
  });

  group("getImageIdStream", () {
    setUp(() {
      // -- Stubs
      when(() => mockImageRemoteDataSource.getImageIdStream(
              accessToken: any(named: "accessToken")))
          .thenAnswer((_) async => const Stream.empty());
    });

    test("should get image id stream from remote data source and return it",
        () async {
      // act
      final result =
          await imageRepositoryImpl.getImageIdStream(accessToken: tAccessToken);

      // assert
      expect(result, const Right(Stream<Either<Failure, String>>.empty()));
      verify(
        () => mockImageRemoteDataSource.getImageIdStream(
          accessToken: tAccessToken,
        ),
      );
    });

    test("should re-map [DioException]s to [Failure]s if they are thrown",
        () async {
      // arrange
      when(() => mockImageRemoteDataSource.getImageIdStream(
            accessToken: any(named: "accessToken"),
          )).thenThrow(tDioException);
      when(() => mockFailureHandler.dioExceptionMapper(tDioException))
          .thenReturn(tMappedDioFailure);

      // act
      final result = await imageRepositoryImpl.getImageIdStream(
        accessToken: tAccessToken,
      );

      // assert
      expect(result, const Left(tMappedDioFailure));
      verify(() => mockFailureHandler.dioExceptionMapper(tDioException));
    });
  });

  group("getImage", () {
    setUp(() {
      // -- Stubs
      when(() => mockImageRemoteDataSource.getImage(
          accessToken: any(named: "accessToken"),
          imageId: any(named: "imageId"))).thenAnswer((_) async => tImageBytes);
    });

    test("should get image from remote data source and return it", () async {
      // act
      final result = await imageRepositoryImpl.getImage(
        accessToken: tAccessToken,
        imageId: tImageId,
      );

      // assert
      expect(result, Right(tImageBytes));
      verify(
        () => mockImageRemoteDataSource.getImage(
          accessToken: tAccessToken,
          imageId: tImageId,
        ),
      );
    });

    test("should re-map [DioException]s to [Failure]s if they are thrown", () {
      // arrange
      when(() => mockImageRemoteDataSource.getImage(
            accessToken: any(named: "accessToken"),
            imageId: any(named: "imageId"),
          )).thenThrow(tDioException);
      when(() => mockFailureHandler.dioExceptionMapper(tDioException));

      // act
      final result = imageRepositoryImpl.getImage(
        accessToken: tAccessToken,
        imageId: tImageId,
      );

      // assert
      expect(result, const Left(tMappedDioFailure));
      verify(() => mockFailureHandler.dioExceptionMapper(tDioException));
    });
  });
}
