part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();

  @override
  List<Object> get props => [];
}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;

  // ignore: prefer_const_constructors_in_immutables
  GetTriviaForConcreteNumber(this.numberString);
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}
