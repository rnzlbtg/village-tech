import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/rfid_sticker.dart';
import '../models/sticker_allocation.dart';
import '../models/sticker_request.dart';
import '../services/offline_cache_service.dart';
import '../services/sticker_service.dart';
import '../utils/api_result.dart';

/// Sticker state
class StickerState {
  final StickerAllocation? allocation;
  final List<StickerRequest> pendingRequests;
  final List<RfidSticker> activeStickers;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  StickerState({
    this.allocation,
    this.pendingRequests = const [],
    this.activeStickers = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  StickerState copyWith({
    StickerAllocation? allocation,
    List<StickerRequest>? pendingRequests,
    List<RfidSticker>? activeStickers,
    bool? isLoading,
    String? error,
    bool? isOffline,
  }) {
    return StickerState(
      allocation: allocation ?? this.allocation,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      activeStickers: activeStickers ?? this.activeStickers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// Sticker provider
class StickerNotifier extends StateNotifier<StickerState> {
  StickerNotifier() : super(StickerState()) {
    _loadData();
  }

  final _stickerService = StickerService.instance;
  final _cacheService = OfflineCacheService.instance;

  /// Load sticker data (from cache first, then fetch fresh)
  Future<void> _loadData() async {
    developer.log('Loading sticker data...', name: 'StickerProvider');

    // Load from cache first
    final cachedAllocation = _cacheService.getCachedStickerAllocation();
    if (cachedAllocation != null) {
      developer.log('Using cached allocation data', name: 'StickerProvider');
      state = state.copyWith(
        allocation: StickerAllocation.fromJson(cachedAllocation),
        isOffline: true,
      );
    } else {
      developer.log('No cached allocation data found', name: 'StickerProvider');
    }

    // Fetch fresh data
    await refreshData();
  }

  /// Refresh all sticker data from network
  Future<void> refreshData() async {
    developer.log('Refreshing sticker data from network...', name: 'StickerProvider');
    state = state.copyWith(isLoading: true, error: null);

    // Fetch allocation
    developer.log('Fetching sticker allocation...', name: 'StickerProvider');
    final allocationResult = await _stickerService.checkAllocation();

    developer.log('Allocation result - Success: ${allocationResult.success}', name: 'StickerProvider');
    developer.log('Allocation result - Error: ${allocationResult.error}', name: 'StickerProvider');
    developer.log('Allocation result - Data: ${allocationResult.data}', name: 'StickerProvider');

    // Fetch pending requests
    developer.log('Fetching pending requests...', name: 'StickerProvider');
    final requestsResult = await _stickerService.fetchPendingRequests();

    developer.log('Requests result - Success: ${requestsResult.success}', name: 'StickerProvider');
    developer.log('Requests result - Error: ${requestsResult.error}', name: 'StickerProvider');
    developer.log('Requests result - Data count: ${requestsResult.data?.length ?? 0}', name: 'StickerProvider');

    // Fetch active stickers
    developer.log('Fetching active stickers...', name: 'StickerProvider');
    final stickersResult = await _stickerService.fetchActiveStickers();

    developer.log('Stickers result - Success: ${stickersResult.success}', name: 'StickerProvider');
    developer.log('Stickers result - Error: ${stickersResult.error}', name: 'StickerProvider');
    developer.log('Stickers result - Data count: ${stickersResult.data?.length ?? 0}', name: 'StickerProvider');

    if (allocationResult.success &&
        requestsResult.success &&
        stickersResult.success) {

      developer.log('All data loaded successfully!', name: 'StickerProvider');
      state = state.copyWith(
        allocation: allocationResult.data,
        pendingRequests: requestsResult.data ?? [],
        activeStickers: stickersResult.data ?? [],
        isLoading: false,
        isOffline: false,
      );

      // Cache the allocation
      if (allocationResult.data != null) {
        await _cacheService.cacheStickerAllocation(
          available: allocationResult.data!.available,
          used: allocationResult.data!.used,
          total: allocationResult.data!.total,
        );
        developer.log('Allocation data cached', name: 'StickerProvider');
      }
    } else {
      developer.log('Some requests failed!', name: 'StickerProvider');
      // Use cached data if available
      final cachedAllocation = _cacheService.getCachedStickerAllocation();
      if (cachedAllocation != null) {
        developer.log('Using cached allocation as fallback', name: 'StickerProvider');
        state = state.copyWith(
          allocation: StickerAllocation.fromJson(cachedAllocation),
          isLoading: false,
          isOffline: true,
          error: 'Using offline data',
        );
      } else {
        developer.log('No cached data available, showing error', name: 'StickerProvider');
        state = state.copyWith(
          isLoading: false,
          error: allocationResult.error ?? requestsResult.error ?? stickersResult.error ?? 'Failed to load data',
        );
      }
    }
  }

  /// Refresh allocation only
  Future<void> refreshAllocation() async {
    final result = await _stickerService.checkAllocation();

    if (result.success && result.data != null) {
      state = state.copyWith(
        allocation: result.data,
        isOffline: false,
      );

      await _cacheService.cacheStickerAllocation(
        available: result.data!.available,
        used: result.data!.used,
        total: result.data!.total,
      );
    }
  }

  /// Request sticker
  Future<ApiResult<StickerRequest>> requestSticker({
    required String ownerType,
    required String ownerId,
    required String vehiclePlate,
    String? vehicleMake,
    String? vehicleColor,
  }) async {
    final result = await _stickerService.requestSticker(
      ownerType: ownerType,
      ownerId: ownerId,
      vehiclePlate: vehiclePlate,
      vehicleMake: vehicleMake,
      vehicleColor: vehicleColor,
    );

    if (result.success) {
      // Refresh data to update allocation and pending requests
      await refreshData();
    }

    return result;
  }

  /// Cancel sticker request
  Future<ApiResult<void>> cancelRequest({
    required String requestId,
  }) async {
    final result = await _stickerService.cancelStickerRequest(
      requestId: requestId,
    );

    if (result.success) {
      // Remove from state
      final updatedRequests = state.pendingRequests
          .where((req) => req.id != requestId)
          .toList();

      state = state.copyWith(pendingRequests: updatedRequests);

      // Refresh allocation
      await refreshAllocation();
    }

    return result;
  }

  /// Fetch single sticker request
  Future<ApiResult<StickerRequest>> fetchStickerRequest({
    required String requestId,
  }) async {
    return await _stickerService.fetchStickerRequest(requestId: requestId);
  }
}

/// Sticker provider
final stickerProvider = StateNotifierProvider<StickerNotifier, StickerState>(
  (ref) => StickerNotifier(),
);
