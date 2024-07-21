// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable{
  String ? text ;
  int ? number ;

  NumberTrivia({required this.text, required this.number,});
  @override
  List<Object?> get props => [text,number];


}