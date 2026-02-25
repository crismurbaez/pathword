import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/word_bloc.dart';
import '../bloc/word_state.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/anchor_group.dart';
import '../widgets/floating_window.dart';
import 'import_page.dart';

class InvestigationBoardPage extends StatefulWidget {
  const InvestigationBoardPage({super.key});

  @override
  State<InvestigationBoardPage> createState() => _InvestigationBoardPageState();
}

class _InvestigationBoardPageState extends State<InvestigationBoardPage> {
  final GlobalKey _boardKey = GlobalKey();
  final Map<int, Offset> _wordPositions = {};
  int? _selectedWordId;
  int? _detailWindowWordId;
  int? _anchorEditGroupId;
  TextEditingController? _anchorDetailController;
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
          onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
        ),
        title: const Text('Investigation Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportPage()),
              );
            },
          ),
          BlocBuilder<WordBloc, WordState>(
            builder: (context, state) {
              if (state is WordLoaded) {
                return IconButton(
                  icon: Icon(
                    state.showThreads ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      context.read<WordBloc>().add(ToggleThreadsVisibility()),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocListener<WordBloc, WordState>(
        listener: (context, state) {
          if (state is WordLoaded) {
            // Clean up positions for words no longer on board
            final boardIds = state.boardWords.map((w) => w.id).toSet();
            setState(() {
              _wordPositions.removeWhere((id, _) => !boardIds.contains(id));
            });
          }
        },
        child: BlocBuilder<WordBloc, WordState>(
          builder: (context, state) {
            if (state is WordInitial || state is WordLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WordLoaded) {
              return Stack(
                key: _boardKey,
                children: [
                  // Background
                  Positioned.fill(
                    child: Container(
                      color: Colors.brown[100], // Simple board background
                    ),
                  ),

                  // Canvas for Red Threads
                  if (state.showThreads)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: RedThreadsPainter(
                          wordPositions: _wordPositions,
                          anchorGroups: state.anchorGroups,
                          boardWords: state.boardWords,
                        ),
                      ),
                    ),

                  // Board Drag Target & Interactor
                  Positioned.fill(
                    child: DragTarget<Word>(
                      onWillAcceptWithDetails: (details) =>
                          state.boardWords.length < 12,
                      onAcceptWithDetails: (details) {
                        final renderBox =
                            _boardKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (renderBox == null || details.data.id == null) {
                          return;
                        }

                        final localOffset =
                            renderBox.globalToLocal(details.offset) -
                            const Offset(75, 40);

                        setState(() {
                          _wordPositions[details.data.id!] = localOffset;
                        });

                        context.read<WordBloc>().add(
                          MoveWordToBoard(
                            details.data.copyWith(
                              x: localOffset.dx,
                              y: localOffset.dy,
                            ),
                          ),
                        );

                        if (_isSidebarOpen) {
                          setState(() => _isSidebarOpen = false);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapUp: (details) {
                            // 1. Close sidebar if open
                            if (_isSidebarOpen) {
                              setState(() => _isSidebarOpen = false);
                              return;
                            }
                            // 2. Check for thread taps if threads are visible
                            if (state.showThreads) {
                              _handleCanvasTap(details.localPosition, state);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: candidateData.isNotEmpty
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.transparent,
                            child: const SizedBox.expand(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Board Words
                  ..._buildBoardWordCards(context, state.boardWords),

                  // Floating Detail Window
                  if (_detailWindowWordId != null)
                    _buildDetailWindow(
                      state.allWords.firstWhere(
                        (w) => w.id == _detailWindowWordId,
                      ),
                    ),

                  // Floating Anchor Window
                  if (_anchorEditGroupId != null)
                    _buildAnchorWindow(
                      state.anchorGroups.firstWhere(
                        (g) => g.id == _anchorEditGroupId,
                      ),
                      state.allWords,
                    ),

                  // Bottom shelf for external connections
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ExternalConnectionsShelf(
                      onTapWord: (id) =>
                          setState(() => _detailWindowWordId = id),
                    ),
                  ),

                  // (Sidebar dismissal is now handled by DragTarget's GestureDetector above)

                  // Animated Non-Modal Sidebar
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isSidebarOpen ? 0 : -300,
                    top: 0,
                    bottom: 0,
                    width: 300,
                    child: const WordSidebar(),
                  ),
                ],
              );
            } else if (state is WordError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  List<Widget> _buildBoardWordCards(BuildContext context, List<Word> words) {
    return List.generate(words.length, (index) {
      final word = words[index];

      // Initialize position from entity if not already in local state
      if (!_wordPositions.containsKey(word.id!)) {
        if (word.isOnBoard) {
          // Use saved position
          _wordPositions[word.id!] = Offset(word.x, word.y);
          if (kDebugMode) {
            print(
              'UI: Initializing Word ${word.english} at (${word.x}, ${word.y})',
            );
          }
        } else {
          // Calculate default if none saved (should rarely happen now)
          final defaultOffset = Offset(
            100.0 + (index * 200) % 600,
            100.0 + (index * 150) % 400,
          );
          _wordPositions[word.id!] = defaultOffset;
        }
      }

      final position = _wordPositions[word.id!]!;

      return Positioned(
        key: ValueKey('pos_${word.id}'),
        left: position.dx,
        top: position.dy,
        child: DraggableWordCard(
          key: ValueKey('card_${word.id}'),
          word: word,
          isSelected: _selectedWordId == word.id,
          onTap: () => _handleWordSelection(word.id!),
          onLongPress: () => setState(() => _detailWindowWordId = word.id),
          onPositionChanged: (globalOffset) {
            final RenderBox renderBox =
                _boardKey.currentContext!.findRenderObject() as RenderBox;
            final localOffset = renderBox.globalToLocal(globalOffset);
            setState(() {
              _wordPositions[word.id!] = localOffset;
            });
            // Persist the new position
            context.read<WordBloc>().add(
              UpdateWordPosition(word.id!, localOffset.dx, localOffset.dy),
            );
          },
        ),
      );
    });
  }

  void _handleCanvasTap(Offset tapPos, WordLoaded state) {
    final boardIds = state.boardWords.map((w) => w.id).toSet();

    for (var group in state.anchorGroups) {
      if (!group.isVisible) continue;

      final visibleIds = group.wordIds
          .where(
            (id) => boardIds.contains(id) && _wordPositions.containsKey(id),
          )
          .toList();

      if (visibleIds.length < 2) continue;

      for (int i = 0; i < visibleIds.length; i++) {
        for (int j = i + 1; j < visibleIds.length; j++) {
          final p1 = _wordPositions[visibleIds[i]]! + const Offset(75, 100);
          final p2 = _wordPositions[visibleIds[j]]! + const Offset(75, 100);

          final distance = _distanceToSegment(tapPos, p1, p2);
          if (distance < 20.0) {
            _anchorDetailController?.dispose();
            _anchorDetailController = TextEditingController(text: group.detail);
            setState(() => _anchorEditGroupId = group.id);
            return;
          }
        }
      }
    }
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final double l2 = (a - b).distanceSquared;
    if (l2 == 0) return (p - a).distance;
    double t =
        ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(
      a.dx + t * (b.dx - a.dx),
      a.dy + t * (b.dy - a.dy),
    );
    return (p - projection).distance;
  }

  void _handleWordSelection(int wordId) {
    if (_selectedWordId == null) {
      setState(() => _selectedWordId = wordId);
    } else if (_selectedWordId == wordId) {
      setState(() => _selectedWordId = null);
    } else {
      _showCreateAnchorDialog([_selectedWordId!, wordId]);
      setState(() => _selectedWordId = null);
    }
  }

  void _showCreateAnchorDialog(List<int> wordIds) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Connection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter memory detail...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WordBloc>().add(
                CreateAnchor(controller.text, wordIds),
              );
              Navigator.pop(context);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailWindow(Word word) {
    return FloatingWindow(
      title: 'Word Detail: ${word.english}',
      onClose: () => setState(() => _detailWindowWordId = null),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (word.imagePath != null)
            Image.asset(
              word.imagePath!,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          const SizedBox(height: 16),
          Text(
            'Spanish: ${word.translations.join(", ")}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text('Status: ${word.isKnown ? "Known" : "Learning"}'),
          Text('Difficulty: ${word.difficulty.name.toUpperCase()}'),
        ],
      ),
    );
  }

  Widget _buildAnchorWindow(AnchorGroup group, List<Word> allWords) {
    final theme = Theme.of(context);
    return FloatingWindow(
      title: 'Anchor Group Detail',
      onClose: () {
        _anchorDetailController?.dispose();
        _anchorDetailController = null;
        setState(() => _anchorEditGroupId = null);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text detail area with priority flex
            Expanded(
              flex: 3,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 100),
                child: TextFormField(
                  controller: _anchorDetailController,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Memory Detail',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: 'Describe how these words are connected...',
                    fillColor: theme.canvasColor.withValues(alpha: 0.3),
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Save / Discard Buttons (Wrap handles overflow better than Row)
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _anchorDetailController?.dispose();
                    _anchorDetailController = null;
                    setState(() => _anchorEditGroupId = null);
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Discard'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final newGroup = group.copyWith(
                      detail: _anchorDetailController?.text,
                    );
                    context.read<WordBloc>().add(UpdateAnchor(newGroup));
                    _anchorDetailController?.dispose();
                    _anchorDetailController = null;
                    setState(() => _anchorEditGroupId = null);
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Connected Words:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            // Words list with guaranteed share of space
            Expanded(
              flex: 2,
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: group.wordIds.length,
                  itemBuilder: (context, index) {
                    final id = group.wordIds[index];
                    final word = allWords.firstWhere((w) => w.id == id);
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      leading: const Icon(Icons.link, size: 16),
                      title: Text(
                        word.english,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.link_off, size: 16),
                        onPressed: () {
                          // Logic to remove word could go here
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DraggableWordCard extends StatelessWidget {
  final Word word;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(Offset) onPositionChanged;

  const DraggableWordCard({
    super.key,
    required this.word,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Draggable<Word>(
        data: word,
        feedback: Opacity(
          opacity: 0.7,
          child: _buildCardContent(context, true),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildCardContent(context, false),
        ),
        onDragEnd: (details) {
          // Calculate local position relative to the Stack.
          // This is a simplification; ideally we'd subtract board position.
          // Since the board starts at top-left approx (appBar + drawer),
          // we use the offset provided.
          onPositionChanged(details.offset);
        },
        child: _buildCardContent(context, false),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, bool isFeedback) {
    final theme = Theme.of(context);
    return Card(
      elevation: isFeedback ? 10 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.secondary, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images_ui/backgrounds/background_case_board.webp',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.english.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              if (word.imagePath != null)
                Image.asset(
                  word.imagePath!,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                )
              else
                const Icon(Icons.image_not_supported, size: 80),
              const Divider(),
              Text(
                word.translations.first,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.delete, size: 16),
                onPressed: () {
                  context.read<WordBloc>().add(RemoveWordFromBoard(word));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordSidebar extends StatelessWidget {
  const WordSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 16,
      child: Container(
        color: theme.canvasColor,
        child: BlocBuilder<WordBloc, WordState>(
          builder: (context, state) {
            if (state is WordLoaded) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    color: theme.colorScheme.primary,
                    child: const Center(
                      child: Text(
                        'Search / Queue',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Words...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) =>
                          context.read<WordBloc>().add(SearchWords(query)),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final source = state.searchResults.isNotEmpty
                          ? state.searchResults
                          : state.sidebarWords;
                      final filteredList = source
                          .where(
                            (w) => !state.boardWords.any((bw) => bw.id == w.id),
                          )
                          .toList();

                      return Expanded(
                        child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final word = filteredList[index];
                            return Draggable<Word>(
                              data: word,
                              feedback: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  child: Text(
                                    word.english.toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              child: ListTile(
                                title: Text(word.english),
                                subtitle: Text(word.translations.join(', ')),
                                trailing: const Icon(Icons.drag_indicator),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class ExternalConnectionsShelf extends StatelessWidget {
  final Function(int) onTapWord;
  const ExternalConnectionsShelf({super.key, required this.onTapWord});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordBloc, WordState>(
      builder: (context, state) {
        if (state is! WordLoaded) return const SizedBox();

        final boardIds = state.boardWords.map((w) => w.id).toSet();
        final sidebarIds = state.sidebarWords.map((w) => w.id).toSet();
        final externalWords = <Word>[];

        for (var group in state.anchorGroups) {
          if (group.wordIds.any((id) => boardIds.contains(id))) {
            for (var id in group.wordIds) {
              if (!boardIds.contains(id) && !sidebarIds.contains(id)) {
                final word = state.allWords.firstWhere(
                  (w) => w.id == id,
                  orElse: () => state.allWords.first,
                );
                if (!externalWords.contains(word)) externalWords.add(word);
              }
            }
          }
        }

        if (externalWords.isEmpty) return const SizedBox();

        return Container(
          height: 60,
          color: Colors.black.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.link, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: externalWords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        label: Text(externalWords[index].english),
                        onPressed: () => onTapWord(externalWords[index].id!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RedThreadsPainter extends CustomPainter {
  final Map<int, Offset> wordPositions;
  final List<AnchorGroup> anchorGroups;
  final List<Word> boardWords;

  RedThreadsPainter({
    required this.wordPositions,
    required this.anchorGroups,
    required this.boardWords,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B0000).withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final boardIds = boardWords.map((w) => w.id).toSet();

    for (var group in anchorGroups) {
      if (!group.isVisible) {
        continue;
      }

      // Filter words that are actually on the board AND have positions
      final visibleIds = group.wordIds
          .where((id) => boardIds.contains(id) && wordPositions.containsKey(id))
          .toList();

      if (visibleIds.length < 2) {
        continue;
      }

      for (int i = 0; i < visibleIds.length; i++) {
        for (int j = i + 1; j < visibleIds.length; j++) {
          final p1 = wordPositions[visibleIds[i]]! + const Offset(75, 100);
          final p2 = wordPositions[visibleIds[j]]! + const Offset(75, 100);
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
