import 'package:equatable/equatable.dart';

class VitalsState extends Equatable {
  final bool loading;
  final bool saving;
  final String? error;

  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? current; // latest (or one being edited)

  bool get editing => current != null && current!['id'] != null;

  const VitalsState({
    required this.loading,
    required this.saving,
    required this.items,
    this.current,
    this.error,
  });

  factory VitalsState.initial() =>
      const VitalsState(loading: false, saving: false, items: [], current: null);

  VitalsState copyWith({
    bool? loading,
    bool? saving,
    String? error, // set null to clear
    List<Map<String, dynamic>>? items,
    Map<String, dynamic>? current,
  }) {
    return VitalsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      items: items ?? this.items,
      current: current,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, saving, error, items, current];
}
