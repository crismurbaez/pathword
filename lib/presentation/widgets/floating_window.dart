import 'package:flutter/material.dart';

class FloatingWindow extends StatefulWidget {
  final Widget child;
  final String title;
  final VoidCallback onClose;
  final Offset initialPosition;
  final Size initialSize;
  final double minWidth;
  final double minHeight;

  const FloatingWindow({
    super.key,
    required this.child,
    required this.title,
    required this.onClose,
    this.initialPosition = const Offset(100, 100),
    this.initialSize = const Size(300, 400),
    this.minWidth = 320.0,
    this.minHeight = 150.0,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<FloatingWindow> {
  late Offset position;
  late Size size;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    size = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: theme.cardTheme.color,
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                // Header / Drag bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(11),
                    ),
                    child: widget.child,
                  ),
                ),
                // Resize corner
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        size = Size(
                          (size.width + details.delta.dx).clamp(
                            widget.minWidth,
                            800.0,
                          ),
                          (size.height + details.delta.dy).clamp(
                            widget.minHeight,
                            800.0,
                          ),
                        );
                      });
                    },
                    child: const Icon(
                      Icons.signal_cellular_0_bar_rounded,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
