import 'package:flutter/material.dart';

import '../../domain/entities/number_trivia.dart';

class TriviaDisplay extends StatelessWidget {
  final NumberTrivia trivia;

  const TriviaDisplay({
    Key? key,
    required this.trivia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: <Widget>[
          // Tamaño fijo, no tiene desplazamiento
          Text(
            trivia.number.toString(),
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Expanded hace que llene todo el espacio restante
          Expanded(
            child: Center(
              // Only the trivia "message" part will be scrollable
              child: SingleChildScrollView(
                child: Text(
                  trivia.text,
                  style: const TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
