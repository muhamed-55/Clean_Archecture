part of 'number_trivia_bloc.dart';

@immutable
sealed class NumberTriviaEvent {}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;
  GetTriviaForConcreteNumber(this.numberString) ;
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}