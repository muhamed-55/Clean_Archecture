// ignore_for_file: void_checks

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia ;
  final InputConverter inputConverter;

  NumberTriviaBloc({required this.getConcreteNumberTrivia, required this.getRandomNumberTrivia, required this.inputConverter}) : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async{
  if(event is GetTriviaForConcreteNumber){
    final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);
    inputEither.fold(
            (failure) {
              emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
            },
            (integer) async{
             emit(Loading());
             final failureOrTrivia = await getConcreteNumberTrivia.call(Params(number: integer));
             failureOrTrivia.fold(
                     (failure) => emit(Error(message: _mapFailureToMessage(failure))),
                     (trivia) => emit(Loaded(trivia: trivia)),
             );
            });
  }
  else if(event is GetTriviaForRandomNumber){
    emit(Loading());
    final failureOrTrivia = await getRandomNumberTrivia.call(NoParams());
    failureOrTrivia.fold(
          (failure) => emit(Error(message: _mapFailureToMessage(failure))),
          (trivia) => emit(Loaded(trivia: trivia)),
    );

  }
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
