import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class FakeParams extends Fake implements Params {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUpAll(() {
    registerFallbackValue(FakeParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () {
    expect(bloc.state, isA<Empty>());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should call the InputConverter to convert the string to an unsigned integer', () async {
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Right(tNumberParsed));
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockInputConverter.stringToUnsignedInteger(any()));

      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString)).called(1);
    });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Error] when input is invalid',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        isA<Error>().having((e) => e.message, 'message', INVALID_INPUT_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        isA<Loading>(),
        isA<Loaded>().having((l) => l.trivia, 'trivia', tNumberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        isA<Loading>(),
        isA<Error>().having((e) => e.message, 'message', SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        isA<Loading>(),
        isA<Error>().having((e) => e.message, 'message', CACHE_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should get data from the concrete use case',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      verify: (_) {
        verify(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed))).called(1);
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        isA<Loading>(),
        isA<Loaded>().having((l) => l.trivia, 'trivia', tNumberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        isA<Loading>(),
        isA<Error>().having((e) => e.message, 'message', SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        isA<Loading>(),
        isA<Error>().having((e) => e.message, 'message', CACHE_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should get data from the random use case',
      build: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      verify: (_) {
        verify(() => mockGetRandomNumberTrivia(NoParams())).called(1);
      },
    );
  });
}
