import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/widgets.dart';

class NumberTriviaPge extends StatelessWidget {
  const NumberTriviaPge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: _buildBody(context),
      ),
    );
  }

  BlocProvider<NumberTriviaBloc> _buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              // Top half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) => state.when(
                  empty: () =>
                      const MessageDisplay(message: 'Start searching!'),
                  loading: () => const LoadingWidget(),
                  loaded: (trivia) => TriviaDisplay(trivia: trivia),
                  error: (message) => MessageDisplay(message: message),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom half
              const TriviaControls()
            ],
          ),
        ),
      ),
    );
  }
}
