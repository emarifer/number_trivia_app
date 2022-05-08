import '../../domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({
    required String text,
    required int number,
  }) : super(text: text, number: number);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) =>
      NumberTriviaModel(
        text: json['text'],
        number: (json['number'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'number': number,
      };
}
