import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/data/repository_implementation/image_repository_impl.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';
import '../../../../mocks.dart';

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
    registerFallbackValue(tWebSocketUrl);
    registerFallbackValue(tDioException);
  });

  group("getImageIdStream", () {
    setUp(() {
      // -- Stubs
      when(() => mockImageRemoteDataSource.getImageIdStream(
            accessToken: any(named: "accessToken"),
            webSocketUrl: any(named: "webSocketUrl"),
          )).thenAnswer((_) => Stream.fromIterable([tImageId]));
    });

    test(
        "should get image id stream from remote data source and return the contents",
        () async {
      // act
      final result = imageRepositoryImpl.getImageIdStream(
        accessToken: tAccessToken,
        webSocketUrl: tWebSocketUrl,
      );

      // assert
      await expectLater(result, emits(const Right(tImageId)));
      verify(
        () => mockImageRemoteDataSource.getImageIdStream(
          accessToken: tAccessToken,
          webSocketUrl: tWebSocketUrl,
        ),
      );
    });

    test(
        "should return a [MalformedWebSocketMessageFailure] if a [FormatException] is thrown",
        () async {
      // arrange
      when(() => mockImageRemoteDataSource.getImageIdStream(
            accessToken: any(named: "accessToken"),
            webSocketUrl: any(named: "webSocketUrl"),
          )).thenAnswer((_) => Stream.error(const FormatException()));

      // act
      final result = imageRepositoryImpl.getImageIdStream(
        accessToken: tAccessToken,
        webSocketUrl: tWebSocketUrl,
      );

      // assert
      await expectLater(
          result, emits(const Left(MalformedWebSocketMessageFailure())));
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

    test("should re-map [DioException]s to [Failure]s if they are thrown",
        () async {
      // arrange
      when(() => mockImageRemoteDataSource.getImage(
            accessToken: any(named: "accessToken"),
            imageId: any(named: "imageId"),
          )).thenThrow(tDioException);
      when(
        () => mockFailureHandler.dioExceptionMapper(any()),
      ).thenAnswer((invocation) => tMappedDioFailure);

      // act
      final result = await imageRepositoryImpl.getImage(
        accessToken: tAccessToken,
        imageId: tImageId,
      );

      // assert
      expect(result, const Left(tMappedDioFailure));
      verify(() => mockFailureHandler.dioExceptionMapper(tDioException));
    });
  });
}
