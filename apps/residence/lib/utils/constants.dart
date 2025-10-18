import 'package:flutter/material.dart';

/// Application constants
class AppConstants {
  // Color Scheme - Village Tech Branding
  static const Color primaryColor = Color(0xFF105640); // Rich forest green
  static const Color secondaryColor = Color(0xFF2D7D5C); // Lighter green
  static const Color accentColor = Color(0xFFF59E0B); // Warm amber

  // Storage Bucket Names
  static const String userPhotosBucket = 'user-photos';

  // Cache Keys
  static const String householdMembersCacheKey = 'members';
  static const String householdMembersCacheTimestampKey = 'members_cached_at';
  static const String stickerAllocationCacheKey = 'allocation';
  static const String guestListCacheKey = 'guests';
  static const String guestListCacheTimestampKey = 'guests_cached_at';

  // Cache Durations
  static const Duration householdCacheDuration = Duration(hours: 1);
  static const Duration stickerCacheDuration = Duration(hours: 1);
  static const Duration guestCacheDuration = Duration(minutes: 15);

  // Photo Upload Settings
  static const int maxPhotoSizeMB = 5;
  static const int photoQuality = 85;
  static const int photoMaxWidth = 1920;
  static const int photoMaxHeight = 1080;
  static const int signedUrlExpirySeconds = 86400; // 24 hours

  // Validation Limits
  static const int maxMessageLength = 1000;
  static const int maxGuestVisitDays = 30;
  static const int maxPermitDurationDays = 365;

  // Relationship Types
  static const List<String> householdRelationships = [
    'head',
    'spouse',
    'child',
    'parent',
    'sibling',
    'other',
  ];

  static const List<String> beneficialUserRelationships = [
    'helper',
    'family',
    'friend',
    'service_provider',
    'other',
  ];

  // Visit Types
  static const List<String> visitTypes = [
    'day_trip',
    'multi_day',
  ];

  // Project Types
  static const List<String> projectTypes = [
    'renovation',
    'construction',
    'repair',
    'landscaping',
  ];

  // Sticker Status
  static const String stickerStatusPending = 'pending';
  static const String stickerStatusApproved = 'approved';
  static const String stickerStatusDistributed = 'distributed';
  static const String stickerStatusRejected = 'rejected';

  // RFID Sticker Status
  static const String rfidStickerStatusActive = 'active';
  static const String rfidStickerStatusExpired = 'expired';
  static const String rfidStickerStatusLost = 'lost';
  static const String rfidStickerStatusDeactivated = 'deactivated';

  // Guest Status
  static const String guestStatusScheduled = 'scheduled';
  static const String guestStatusCheckedIn = 'checked_in';
  static const String guestStatusCheckedOut = 'checked_out';
  static const String guestStatusCancelled = 'cancelled';

  // Permit Status
  static const String permitStatusPending = 'pending';
  static const String permitStatusFeePending = 'fee_pending';
  static const String permitStatusApproved = 'approved';
  static const String permitStatusRejected = 'rejected';
  static const String permitStatusCompleted = 'completed';

  // Payment Status
  static const String paymentStatusUnpaid = 'unpaid';
  static const String paymentStatusPaid = 'paid';

  // Owner Types
  static const String ownerTypeHouseholdMember = 'household_member';
  static const String ownerTypeBeneficialUser = 'beneficial_user';

  // Message Types
  static const String messageTypeHouseholdToAdmin = 'household_to_admin';
  static const String messageTypeAdminToHousehold = 'admin_to_household';

  // Announcement Priority
  static const String priorityNormal = 'normal';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';

  // Notification Types
  static const String notificationTypeStickerApproval = 'sticker_approval';
  static const String notificationTypeGuestVerification = 'guest_verification';
  static const String notificationTypeAnnouncement = 'announcement';
  static const String notificationTypePermitApproval = 'permit_approval';

  // Rule Categories
  static const List<String> ruleCategories = [
    'general',
    'parking',
    'noise',
    'construction',
    'curfew',
  ];
}
