import 'package:dartz/dartz.dart';
import 'package:einblicke_frame/features/show_image/domain/usecases/stream_server_auth_wrapper.dart';
import 'package:einblicke_shared/einblicke_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';
import '../../../../mocks.dart';

void main() {
  late StreamServerAuthWrapper serverAuthWrapper;
  late MockRefreshTokenBundle mockRefreshTokenBundle;
  late MockAuthenticationRepository mockAuthenticationRepository;

  late MockServerCall mockServerCall;

  setUp(() {
    // -- Definitions
    mockRefreshTokenBundle = MockRefreshTokenBundle();
    mockAuthenticationRepository = MockAuthenticationRepository();
    serverAuthWrapper = StreamServerAuthWrapper(
      refreshTokenBundle: mockRefreshTokenBundle,
      authenticationRepository: mockAuthenticationRepository,
    );

    mockServerCall = MockServerCall();

    // -- Stubs
    when(
      () => mockAuthenticationRepository.getTokenBundleFromStorage(),
    ).thenAnswer((_) => Future.value(Right(tTokenBundle)));
    when(
      () => mockServerCall(
        any(),
      ),
    ).thenAnswer((invocation) => Stream.fromIterable([const Right(tImageId)]));
  });

  setUpAll(() {
    // -- Fallbacks
    registerFallbackValue(tAccessToken);
  });

  test("should get the [TokenBundle] from the [AuthenticationRepository]",
      () async {
    // act
    final stream = serverAuthWrapper(serverCall: mockServerCall);

    // assert
    await expectLater(stream, emits(const Right(tImageId)));
    verify(() => mockAuthenticationRepository.getTokenBundleFromStorage());
  });

  test("should relay [Failure]s", () async {
    // arrange
    when(
      () => mockAuthenticationRepository.getTokenBundleFromStorage(),
    ).thenAnswer((_) => Future.value(const Left(SecureStorageReadFailure())));

    // act
    final result = serverAuthWrapper(serverCall: mockServerCall);

    // assert
    await expectLater(result, emits(const Left(SecureStorageReadFailure())));
  });

  test("should call the callback to the server and emit the result", () async {
    // act
    final result = serverAuthWrapper(serverCall: mockServerCall);

    // assert
    await expectLater(result, emits(const Right(tImageId)));
    verify(
      () => mockServerCall(tAccessToken),
    );
  });

  test("should relay [Failure]s", () async {
    // arrange
    when(
      () => mockServerCall(
        any(),
      ),
    ).thenAnswer((invocation) =>
        Stream.fromIterable(const [Left(DatabaseReadFailure())]));

    // act
    final result = serverAuthWrapper(serverCall: mockServerCall);

    // assert
    await expectLater(result, emits(const Left(DatabaseReadFailure())));
  });

  group("if calling the server call returns a [UnauthorizedFailure]", () {
    setUp(() {
      // -- Stubs
      when(
        () => mockServerCall(
          any(),
        ),
      ).thenAnswer(
        (invocation) =>
            Stream.fromIterable(const [Left(UnauthorizedFailure())]),
      );
      when(
        () => mockRefreshTokenBundle(),
      ).thenAnswer((invocation) => Future.value(const Right(None())));
    });

    test(
        "should get a new [TokenBundle] if a [UnauthorizedFailure] was returned",
        () async {
      // act
      serverAuthWrapper(serverCall: mockServerCall);

      // assert
      await expectLater(
          serverAuthWrapper(serverCall: mockServerCall),
          emitsInOrder(const [
            Left(UnauthorizedFailure()),
            Left(UnauthorizedFailure())
          ]));
      verify(() => mockRefreshTokenBundle());
    });

    test("should relay [Failure]s", () async {
      // arrange
      when(
        () => mockRefreshTokenBundle(),
      ).thenAnswer(
          (invocation) => Future.value(const Left(UnauthorizedFailure())));

      // act
      final result = serverAuthWrapper(serverCall: mockServerCall);

      // arrange
      expectLater(result, emits(const Left(UnauthorizedFailure())));
    });

    test("should retry the server call once (aka. call it twice in total)",
        () async {
      // act
      final stream = serverAuthWrapper(serverCall: mockServerCall);

      // assert
      await expectLater(
          stream,
          emitsInOrder(const [
            Left(UnauthorizedFailure()),
            Left(UnauthorizedFailure())
          ]));
      verify(() => mockServerCall(tAccessToken)).called(2);
    });
  });
}
