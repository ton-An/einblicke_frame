import 'package:dartz/dartz.dart';
import 'package:einblicke_shared/einblicke_shared.dart';

class StreamServerAuthWrapper<T> {
  StreamServerAuthWrapper({
    required this.refreshTokenBundle,
    required this.authenticationRepository,
  });

  final RefreshTokenBundle refreshTokenBundle;
  final AuthenticationRepository authenticationRepository;

  Stream<Either<Failure, T>> call({
    required Stream<Either<Failure, T>> Function(
      AuthenticationToken accessToken,
    ) serverCall,
  }) {
    return _getAccessToken(
      serverCall: serverCall,
    );
  }

  Stream<Either<Failure, T>> _getAccessToken({
    required Stream<Either<Failure, T>> Function(
      AuthenticationToken accessToken,
    ) serverCall,
    bool hasRetried = false,
  }) async* {
    final Either<Failure, TokenBundle> tokenBundle =
        await authenticationRepository.getTokenBundleFromStorage();

    yield* tokenBundle.fold(
      (Failure failure) async* {
        yield Left(failure);
      },
      (TokenBundle tokenBundle) async* {
        final AuthenticationToken accessToken = tokenBundle.accessToken;

        yield* _callServer(
          serverCall: serverCall,
          accessToken: accessToken,
          hasRetried: hasRetried,
        );
      },
    );
  }

  Stream<Either<Failure, T>> _callServer({
    required Stream<Either<Failure, T>> Function(
      AuthenticationToken accessToken,
    ) serverCall,
    required AuthenticationToken accessToken,
    required bool hasRetried,
  }) async* {
    final Stream<Either<Failure, T>> serverCallStream = serverCall(accessToken);

    await for (Either<Failure, T> either in serverCallStream) {
      yield* either.fold((Failure failure) async* {
        if (failure is UnauthorizedFailure && !hasRetried) {
          yield* _retryWithNewTokens(serverCall: serverCall);
        }

        yield Left(failure);
      }, (T t) async* {
        yield Right(t);
      });
    }
  }

  Stream<Either<Failure, T>> _retryWithNewTokens({
    required Stream<Either<Failure, T>> Function(
      AuthenticationToken accessToken,
    ) serverCall,
  }) async* {
    final Either<Failure, None> refreshTokenEither = await refreshTokenBundle();

    yield* refreshTokenEither.fold(
      (Failure failure) async* {
        yield Left(failure);
      },
      (None none) async* {
        yield* _getAccessToken(serverCall: serverCall, hasRetried: true);
      },
    );
  }
}
