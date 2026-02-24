import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/word_bloc.dart';
import '../bloc/word_state.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PathWord Dictionary'),
        centerTitle: true,
      ),
      body: BlocBuilder<WordBloc, WordState>(
        builder: (context, state) {
          if (state is WordInitial) {
            context.read<WordBloc>().add(LoadInitialData());
            return const Center(child: CircularProgressIndicator());
          } else if (state is WordLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WordLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.allWords.length,
              itemBuilder: (context, index) {
                final word = state.allWords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: word.imagePath != null
                              ? Image.asset(
                                  word.imagePath!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          word.english.toUpperCase(),
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 24, letterSpacing: 2),
                        ),
                        const Divider(height: 24),
                        Wrap(
                          spacing: 8,
                          children: word.translations.map((t) {
                            return Chip(
                              label: Text(
                                t,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is WordError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
