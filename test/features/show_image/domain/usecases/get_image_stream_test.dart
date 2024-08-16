import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image_stream.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';
import '../../../../mocks.dart';

void main() {
  late GetImageStream getImageStream;
  late MockImageRepository mockImageRepository;
  late MockStreamServerAuthWrapper<String> mockStreamServerAuthWrapper;
  late MockGetImage mockGetImage;

  setUp(() {
    // -- Definitions
    mockImageRepository = MockImageRepository();
    mockStreamServerAuthWrapper = MockStreamServerAuthWrapper<String>();
    mockGetImage = MockGetImage();
    getImageStream = GetImageStream(
      imageRepository: mockImageRepository,
      streamServerAuthWrapper: mockStreamServerAuthWrapper,
      getImage: mockGetImage,
      secrets: tFakeSecrets,
    );

    // -- Stubs
    when(() => mockStreamServerAuthWrapper.call(
        serverCall: any(named: 'serverCall'))).thenAnswer(
      (_) => Stream.fromIterable(const [Right(tImageId), Right(tImageId)]),
    );
    when(
      () => mockImageRepository.getImageIdStream(
        accessToken: any(named: "accessToken"),
        webSocketUrl: any(named: "webSocketUrl"),
      ),
    ).thenAnswer(
        (_) => Stream.fromIterable(const [Right(tImageId), Right(tImageId)]));

    when(() => mockGetImage.call(imageId: any(named: "imageId")))
        .thenAnswer((_) async => Right(tImageBytes));
  });

  setUpAll(() {
    // -- Fallbacks
    registerFallbackValue(tAccessToken);
    registerFallbackValue(tWebSocketUrl);
  });

  test(
      "should get the image id stream from the server and returns [Uint8List]s",
      () async {
    //  act & assert
    final Stream stream = getImageStream();
    await expectLater(
      stream,
      emitsInOrder([Right(tImageBytes), Right(tImageBytes)]),
    );

    final verificationResult = verify(
      () => mockStreamServerAuthWrapper(
        serverCall: captureAny(named: "serverCall"),
      ),
    );

    final Function serverCallClosure = verificationResult.captured[0];
    await serverCallClosure(tAccessToken);

    // assert
    verify(
      () => mockImageRepository.getImageIdStream(
        accessToken: tAccessToken,
        webSocketUrl: tWebSocketUrl,
      ),
    );
  });

  test("should relay [Failure]s", () async {
    // arrange
    when(() => mockStreamServerAuthWrapper.call(
        serverCall: any(named: "serverCall"))).thenAnswer(
      (_) => Stream.fromIterable([const Left(UnauthorizedFailure())]),
    );

    // act & assert
    final stream = getImageStream();
    await expectLater(
      stream,
      emitsInOrder([const Left(UnauthorizedFailure())]),
    );
  });

  test("should get the image bytes from the server", () async {
    // arrange & act
    final stream = getImageStream();

    // assert
    await expectLater(
      stream,
      emitsInOrder([Right(tImageBytes), Right(tImageBytes)]),
    );
    verify(
      () => mockGetImage(imageId: tImageId),
    ).called(2);
  });

  test("should relay [Failure]s", () async {
    // arrange
    when(() => mockGetImage(imageId: any(named: "imageId")))
        .thenAnswer((_) async => const Left(UnauthorizedFailure()));

    // act
    final stream = getImageStream();

    // assert
    await expectLater(
      stream,
      emitsInOrder([const Left(UnauthorizedFailure())]),
    );
  });
}
