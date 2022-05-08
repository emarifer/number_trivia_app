import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // TextField
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            addConcrete();
          },
        ),

        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              // Search concrete button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: addConcrete,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              // Random button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey.shade500,
                ),
                onPressed: addRandom,
                child: const Text('Get random trivia'),
              ),
            )
          ],
        )
      ],
    );
  }

  void addConcrete() {
    controller.clear();
    context.read<NumberTriviaBloc>().add(GetTriviaForConcreteNumber(inputStr));
  }

  void addRandom() {
    controller.clear();
    context.read<NumberTriviaBloc>().add(GetTriviaForRandomNumber());
  }
}
