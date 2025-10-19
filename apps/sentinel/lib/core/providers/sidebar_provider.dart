import 'package:flutter_riverpod/flutter_riverpod.dart';

final sidebarStateProvider = StateNotifierProvider<SidebarStateNotifier, SidebarState>((ref) {
  return SidebarStateNotifier();
});

class SidebarStateNotifier extends StateNotifier<SidebarState> {
  SidebarStateNotifier() : super(const SidebarState(isOpen: true, isDesktop: true));

  void toggle() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  void open() {
    state = state.copyWith(isOpen: true);
  }

  void close() {
    state = state.copyWith(isOpen: false);
  }

  void updateDeviceType(bool isDesktop) {
    state = state.copyWith(isDesktop: isDesktop);
  }
}

class SidebarState {
  final bool isOpen;
  final bool isDesktop;

  const SidebarState({
    required this.isOpen,
    required this.isDesktop,
  });

  SidebarState copyWith({
    bool? isOpen,
    bool? isDesktop,
  }) {
    return SidebarState(
      isOpen: isOpen ?? this.isOpen,
      isDesktop: isDesktop ?? this.isDesktop,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SidebarState &&
          runtimeType == other.runtimeType &&
          isOpen == other.isOpen &&
          isDesktop == other.isDesktop;

  @override
  int get hashCode => isOpen.hashCode ^ isDesktop.hashCode;
}