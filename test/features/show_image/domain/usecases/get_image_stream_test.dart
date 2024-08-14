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
  late MockServerAuthWrapper<Stream<Either<Failure, String>>>
      mockServerAuthWrapper;
  late MockGetImage mockGetImage;

  setUp(() {
    // -- Definitions
    mockImageRepository = MockImageRepository();
    mockServerAuthWrapper =
        MockServerAuthWrapper<Stream<Either<Failure, String>>>();
    mockGetImage = MockGetImage();
    getImageStream = GetImageStream(
      imageRepository: mockImageRepository,
      serverAuthWrapper: mockServerAuthWrapper,
      getImage: mockGetImage,
    );

    // -- Stubs
    when(() => mockServerAuthWrapper.call(serverCall: any(named: 'serverCall')))
        .thenAnswer(
      (_) async => Right(
        Stream.fromIterable(const [Right(tImageId), Right(tImageId)]),
      ),
    );
    when(() =>
        mockImageRepository.getImageIdStream(
            accessToken: any(named: "accessToken"))).thenAnswer((_) async =>
        Right(Stream.fromIterable(const [Right(tImageId), Right(tImageId)])));

    when(() => mockGetImage.call(imageId: any(named: "imageId")))
        .thenAnswer((_) async => Right(tImageBytes));
  });

  setUpAll(() {
    // -- Fallbacks
    registerFallbackValue(tAccessToken);
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
      () => mockServerAuthWrapper(
        serverCall: captureAny(named: "serverCall"),
      ),
    );

    final Function serverCallClosure = verificationResult.captured[0];
    await serverCallClosure(tAccessToken);

    // assert
    verify(
      () => mockImageRepository.getImageIdStream(
        accessToken: tAccessToken,
      ),
    );
  });

  test("should relay [Failure]s", () async {
    // arrange
    when(() => mockServerAuthWrapper.call(serverCall: any(named: "serverCall")))
        .thenAnswer(
      (_) async => const Left(UnauthorizedFailure()),
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
