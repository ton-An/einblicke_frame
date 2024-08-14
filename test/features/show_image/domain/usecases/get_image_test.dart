import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/get_image.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';
import '../../../../mocks.dart';

/* To-Do:
    - [ ] make "should relay [Failure]s" test descriptions clearer (goes for all test in this app)
    - [ ] standardize comments in test files
*/

void main() {
  late GetImage getImage;
  late MockImageRepository mockImageRepository;
  late MockServerAuthWrapper<Uint8List> mockServerAuthWrapper;

  setUp(() {
    // -- Definitions
    mockImageRepository = MockImageRepository();
    mockServerAuthWrapper = MockServerAuthWrapper<Uint8List>();
    getImage = GetImage(
      imageRepository: mockImageRepository,
      serverAuthWrapper: mockServerAuthWrapper,
    );

    // -- Stubs
    when(() => mockServerAuthWrapper.call(serverCall: any(named: 'serverCall')))
        .thenAnswer(
      (_) async => Right(
        tImageBytes,
      ),
    );
    when(() => mockImageRepository.getImage(
          accessToken: any(named: 'accessToken'),
          imageId: any(named: 'imageId'),
        )).thenAnswer(
      (_) async => Right(
        tImageBytes,
      ),
    );
  });

  setUpAll(() {
    // -- Fallbacks
    registerFallbackValue(tAccessToken);
  });

  test(
      "should get the image bytes from the Server and return them as [Uint8List]",
      () async {
    // arrange & act
    final result = await getImage.call(
      imageId: tImageId,
    );
    final verificationResult = verify(
      () => mockServerAuthWrapper(
        serverCall: captureAny(named: 'serverCall'),
      ),
    );

    final Function serverCallClosure = verificationResult.captured[0];

    await serverCallClosure(tAccessToken);

    // assert
    verify(
      () => mockImageRepository.getImage(
        accessToken: tAccessToken,
        imageId: tImageId,
      ),
    );
    expect(result, Right(tImageBytes));
  });

  test("should relay [Failure]s", () async {
    // arrange
    when(() => mockServerAuthWrapper.call(serverCall: any(named: 'serverCall')))
        .thenAnswer(
      (_) async => const Left(
        UnauthorizedFailure(),
      ),
    );

    // act
    final result = await getImage.call(
      imageId: tImageId,
    );

    // assert
    expect(result, equals(const Left(UnauthorizedFailure())));
  });
}
