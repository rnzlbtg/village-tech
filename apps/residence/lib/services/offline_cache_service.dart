import 'package:hive_flutter/hive_flutter.dart';

/// Offline cache service using Hive
/// Provides caching for household data, stickers, and guests
class OfflineCacheService {
  static const String householdBox = 'household_data';
  static const String stickerBox = 'sticker_data';
  static const String guestBox = 'guest_data';

  static OfflineCacheService? _instance;

  OfflineCacheService._();

  /// Singleton instance
  static OfflineCacheService get instance {
    _instance ??= OfflineCacheService._();
    return _instance!;
  }

  /// Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(householdBox);
    await Hive.openBox(stickerBox);
    await Hive.openBox(guestBox);
  }

  // ========== Household Members Cache ==========

  /// Cache household members
  Future<void> cacheHouseholdMembers(List<Map<String, dynamic>> members) async {
    final box = Hive.box(householdBox);
    await box.put('members', members);
    await box.put('members_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached household members
  List<Map<String, dynamic>>? getCachedHouseholdMembers() {
    final box = Hive.box(householdBox);
    final data = box.get('members');
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Get household members cache timestamp
  DateTime? getHouseholdMembersCacheTimestamp() {
    final box = Hive.box(householdBox);
    final timestamp = box.get('members_cached_at') as String?;
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  /// Check if household members cache is stale (> 1 hour)
  bool isHouseholdMembersCacheStale() {
    final timestamp = getHouseholdMembersCacheTimestamp();
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp).inHours > 1;
  }

  // ========== Sticker Allocation Cache ==========

  /// Cache sticker allocation
  Future<void> cacheStickerAllocation({
    required int available,
    required int used,
    required int total,
  }) async {
    final box = Hive.box(stickerBox);
    await box.put('allocation', {
      'available': available,
      'used': used,
      'total': total,
      'cached_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached sticker allocation
  Map<String, dynamic>? getCachedStickerAllocation() {
    final box = Hive.box(stickerBox);
    return box.get('allocation') as Map<String, dynamic>?;
  }

  /// Get sticker allocation cache timestamp
  DateTime? getStickerAllocationCacheTimestamp() {
    final allocation = getCachedStickerAllocation();
    if (allocation == null) return null;
    final timestamp = allocation['cached_at'] as String?;
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  /// Check if sticker allocation cache is stale (> 1 hour)
  bool isStickerAllocationCacheStale() {
    final timestamp = getStickerAllocationCacheTimestamp();
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp).inHours > 1;
  }

  // ========== Guest Cache ==========

  /// Cache guest list
  Future<void> cacheGuestList(List<Map<String, dynamic>> guests) async {
    final box = Hive.box(guestBox);
    await box.put('guests', guests);
    await box.put('guests_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached guest list
  List<Map<String, dynamic>>? getCachedGuestList() {
    final box = Hive.box(guestBox);
    final data = box.get('guests');
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Get guest cache timestamp
  DateTime? getGuestCacheTimestamp() {
    final box = Hive.box(guestBox);
    final timestamp = box.get('guests_cached_at') as String?;
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  /// Check if guest cache is stale (> 15 minutes)
  bool isGuestCacheStale() {
    final timestamp = getGuestCacheTimestamp();
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp).inMinutes > 15;
  }

  // ========== General Cache Operations ==========

  /// Get value from cache
  Future<dynamic> get(String key, {String box = householdBox}) async {
    final hiveBox = Hive.box(box);
    return hiveBox.get(key);
  }

  /// Put value in cache
  Future<void> put(String key, dynamic value, {String box = householdBox}) async {
    final hiveBox = Hive.box(box);
    await hiveBox.put(key, value);
  }

  /// Delete value from cache
  Future<void> delete(String key, {String box = householdBox}) async {
    final hiveBox = Hive.box(box);
    await hiveBox.delete(key);
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await Hive.box(householdBox).clear();
    await Hive.box(stickerBox).clear();
    await Hive.box(guestBox).clear();
  }

  /// Clear household cache
  Future<void> clearHouseholdCache() async {
    await Hive.box(householdBox).clear();
  }

  /// Clear sticker cache
  Future<void> clearStickerCache() async {
    await Hive.box(stickerBox).clear();
  }

  /// Clear guest cache
  Future<void> clearGuestCache() async {
    await Hive.box(guestBox).clear();
  }
}
