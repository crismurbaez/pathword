import 'package:equatable/equatable.dart';

class AnchorGroup extends Equatable {
  final int? id;
  final String detail;
  final List<int> wordIds;
  final bool isVisible;

  const AnchorGroup({
    this.id,
    required this.detail,
    required this.wordIds,
    this.isVisible = true,
  });

  @override
  List<Object?> get props => [id, detail, wordIds, isVisible];

  AnchorGroup copyWith({
    int? id,
    String? detail,
    List<int>? wordIds,
    bool? isVisible,
  }) {
    return AnchorGroup(
      id: id ?? this.id,
      detail: detail ?? this.detail,
      wordIds: wordIds ?? this.wordIds,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
