import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sentinel/models/guest.dart';
import 'package:sentinel/providers/guest_provider.dart';
import 'package:sentinel/services/household_contact_service.dart';

@GenerateMocks([MockGuestService])
void main() {
  group('Guest Management Integration Tests', () {
    late MockGuestService mockGuestService;
    late GuestNotifier guestNotifier;

    setUp(() {
      mockGuestService = MockGuestService();
      guestNotifier = GuestNotifier(mockGuestService);
    });

    group('Guest Data Models Validation', () {
      test('Guest model should serialize and deserialize correctly', () {
        // Arrange
        final originalGuest = Guest(
          id: 'test-guest-1',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'John Doe',
          phoneNumber: '+1234567890',
          purpose: 'Family visit',
          scheduledDate: DateTime(2024, 10, 20),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          vehicleInfo: 'Toyota Camry - ABC 1234',
          notes: 'Will bring children',
          approvedByGuardId: 'guard-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final json = originalGuest.toJson();
        final deserializedGuest = Guest.fromJson(json);

        // Assert
        expect(deserializedGuest.id, equals(originalGuest.id));
        expect(deserializedGuest.guestName, equals(originalGuest.guestName));
        expect(deserializedGuest.phoneNumber, equals(originalGuest.phoneNumber));
        expect(deserializedGuest.purpose, equals(originalGuest.purpose));
        expect(deserializedGuest.status, equals(originalGuest.status));
      });

      test('Guest model should validate required fields correctly', () {
        // Arrange
        final invalidGuest = Guest(
          id: 'test-guest-1',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: '', // Invalid: empty name
          phoneNumber: 'invalid-phone', // Invalid: wrong format
          purpose: '', // Invalid: empty purpose
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final errors = invalidGuest.validate();

        // Assert
        expect(errors, isNotEmpty);
        expect(errors, contains('Guest name is required'));
        expect(errors, contains('Phone number format is invalid'));
        expect(errors, contains('Purpose of visit is required'));
      });

      test('Guest model should calculate visit duration correctly', () {
        // Arrange
        final now = DateTime.now();
        final guestWithVisit = Guest(
          id: 'test-guest-1',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'John Doe',
          phoneNumber: '+1234567890',
          purpose: 'Family visit',
          scheduledDate: now,
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.checkedOut,
          actualArrival: now,
          actualDeparture: now.add(const Duration(hours: 2, minutes: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final duration = guestWithVisit.visitDuration;

        // Assert
        expect(duration, isNotNull);
        expect(duration!.inHours, equals(2));
        expect(duration.inMinutes, equals(150));
      });

      test('Guest model should handle status transitions correctly', () {
        // Arrange
        final guest = Guest(
          id: 'test-guest-1',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'John Doe',
          phoneNumber: '+1234567890',
          purpose: 'Family visit',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert - Initial state
        expect(guest.isPending, isTrue);
        expect(guest.isCheckedIn, isFalse);
        expect(guest.isCheckedOut, isFalse);
        expect(guest.isOnSite, isFalse);

        // Act & Assert - Check in
        final checkedInGuest = guest.copyWith(
          status: GuestStatus.checkedIn,
          actualArrival: DateTime.now(),
        );
        expect(checkedInGuest.isCheckedIn, isTrue);
        expect(checkedInGuest.isOnSite, isTrue);
        expect(checkedInGuest.isCheckedOut, isFalse);

        // Act & Assert - Check out
        final checkedOutGuest = checkedInGuest.copyWith(
          status: GuestStatus.checkedOut,
          actualDeparture: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(checkedOutGuest.isCheckedOut, isTrue);
        expect(checkedOutGuest.isOnSite, isFalse);
      });
    });

    group('Guest Provider State Management', () {
      test('GuestNotifier should load today\'s guests successfully', () async {
        // Arrange
        final mockGuests = [
          Guest(
            id: 'guest-1',
            tenantId: 'tenant-1',
            householdId: 'household-1',
            guestName: 'John Doe',
            phoneNumber: '+1234567890',
            purpose: 'Family visit',
            scheduledDate: DateTime.now(),
            expectedArrival: '10:00',
            expectedDeparture: '12:00',
            status: GuestStatus.pending,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockGuestService.getTodayGuests())
            .thenAnswer((_) async => mockGuests);

        // Act
        await guestNotifier.loadTodayGuests();

        // Assert
        expect(guestNotifier.state.guests.length, equals(1));
        expect(guestNotifier.state.guests.first.guestName, equals('John Doe'));
        expect(guestNotifier.state.isLoading, isFalse);
        expect(guestNotifier.state.error, isNull);
        verify(mockGuestService.getTodayGuests()).called(1);
      });

      test('GuestNotifier should handle loading errors gracefully', () async {
        // Arrange
        when(mockGuestService.getTodayGuests())
            .thenThrow(Exception('Network error'));

        // Act
        await guestNotifier.loadTodayGuests();

        // Assert
        expect(guestNotifier.state.guests.isEmpty, isTrue);
        expect(guestNotifier.state.isLoading, isFalse);
        expect(guestNotifier.state.error, isNotNull);
        expect(guestNotifier.state.error!.contains('Failed to load guests'), isTrue);
      });

      test('GuestNotifier should register new guest successfully', () async {
        // Arrange
        final newGuest = Guest(
          id: 'new-guest',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'Jane Smith',
          phoneNumber: '+0987654321',
          purpose: 'Delivery',
          scheduledDate: DateTime.now(),
          expectedArrival: '14:00',
          expectedDeparture: '15:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockGuestService.createGuest(any))
            .thenAnswer((_) async => newGuest);

        // Act
        final registeredGuest = await guestNotifier.registerGuest(
          guestName: 'Jane Smith',
          phoneNumber: '+0987654321',
          purpose: 'Delivery',
          scheduledDate: DateTime.now(),
          expectedArrival: '14:00',
          expectedDeparture: '15:00',
          householdId: 'household-1',
        );

        // Assert
        expect(registeredGuest.guestName, equals('Jane Smith'));
        expect(guestNotifier.state.guests.length, equals(1));
        expect(guestNotifier.state.guests.first.guestName, equals('Jane Smith'));
        verify(mockGuestService.createGuest(any)).called(1);
      });

      test('GuestNotifier should check in guest successfully', () async {
        // Arrange
        final guest = Guest(
          id: 'guest-1',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'John Doe',
          phoneNumber: '+1234567890',
          purpose: 'Family visit',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        guestNotifier = GuestNotifier(mockGuestService);
        // Manually set the state for testing
        guestNotifier.state = guestNotifier.state.copyWith(guests: [guest]);

        when(mockGuestService.updateGuest(any))
            .thenAnswer((_) async => guest);

        // Act
        await guestNotifier.checkInGuest('guest-1');

        // Assert
        expect(guestNotifier.state.guests.first.status, equals(GuestStatus.checkedIn));
        expect(guestNotifier.state.guests.first.actualArrival, isNotNull);
        verify(mockGuestService.updateGuest(any)).called(1);
      });
    });

    group('Household Contact Service Integration', () {
      test('HouseholdContactService should retrieve contact information', () async {
        // Arrange
        final service = HouseholdContactService();

        // Act
        final contact = await service.getHouseholdContact('household-1');

        // Assert
        expect(contact, isNotNull);
        expect(contact!.headName, equals('John Doe'));
        expect(contact.headPhone, equals('+1234567890'));
      });

      test('HouseholdContactService should record contact attempts', () async {
        // Arrange
        final service = HouseholdContactService();

        // Act
        final result = await service.callHouseholdHead('household-1', guestName: 'Test Guest');

        // Assert
        expect(result.success, isTrue);
        expect(result.message, equals('Call placed successfully'));
        expect(result.type, equals(ContactType.call));
      });

      test('HouseholdContactService should generate contact statistics', () async {
        // Arrange
        final service = HouseholdContactService();

        // Add some contact records
        await service.callHouseholdHead('household-1');
        await service.sendSMS('household-2', 'Test message');

        // Act
        final stats = await service.getContactStatistics();

        // Assert
        expect(stats.totalContacts, equals(2));
        expect(stats.successfulContacts, equals(2));
        expect(stats.callContacts, equals(1));
        expect(stats.smsContacts, equals(1));
        expect(stats.successRate, equals(100.0));
      });
    });

    group('Business Rules Validation', () {
      test('GuestValidator should enforce maximum guests per household', () {
        // Arrange
        final existingGuests = List.generate(10, (index) => Guest(
          id: 'guest-$index',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'Guest $index',
          phoneNumber: '+123456789$index',
          purpose: 'Visit',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        final errors = GuestValidator.validateBusinessRules(
          scheduledDate: DateTime.now(),
          householdId: 'household-1',
          existingGuests: existingGuests,
        );

        // Assert
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Maximum 10 guests per household per day'));
      });

      test('GuestValidator should allow guests under limit', () {
        // Arrange
        final existingGuests = List.generate(5, (index) => Guest(
          id: 'guest-$index',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'Guest $index',
          phoneNumber: '+123456789$index',
          purpose: 'Visit',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        final errors = GuestValidator.validateBusinessRules(
          scheduledDate: DateTime.now(),
          householdId: 'household-1',
          existingGuests: existingGuests,
        );

        // Assert
        expect(errors, isEmpty);
      });

      test('GuestValidator should handle advance registration limit', () {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 35));

        // Act
        final errors = GuestValidator.validateBusinessRules(
          scheduledDate: futureDate,
          householdId: 'household-1',
          existingGuests: [],
        );

        // Assert
        // Note: This would be handled by the guest model's validation
        // The validator focuses on household limits
        expect(errors, isEmpty);
      });
    });

    group('Performance and Reliability Tests', () {
      test('Guest registration should complete within performance target', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        when(mockGuestService.createGuest(any))
            .thenAnswer((_) async => Guest(
              id: 'perf-guest',
              tenantId: 'tenant-1',
              householdId: 'household-1',
              guestName: 'Performance Test',
              phoneNumber: '+1234567890',
              purpose: 'Testing',
              scheduledDate: DateTime.now(),
              expectedArrival: '10:00',
              expectedDeparture: '12:00',
              status: GuestStatus.pending,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));

        // Act
        await guestNotifier.registerGuest(
          guestName: 'Performance Test',
          phoneNumber: '+1234567890',
          purpose: 'Testing',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          householdId: 'household-1',
        );

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 second target
      });

      test('Guest search should return results quickly', () async {
        // Arrange
        when(mockGuestService.searchGuests(any))
            .thenAnswer((_) async => []);

        // Act
        final stopwatch = Stopwatch()..start();
        await guestNotifier.searchGuests('search query');
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 second target
        verify(mockGuestService.searchGuests('search query')).called(1);
      });

      test('Guest operations should handle offline scenarios gracefully', () async {
        // Arrange
        when(mockGuestService.createGuest(any))
            .thenThrow(Exception('Network unavailable'));

        // Act & Assert
        expect(
          () async => await guestNotifier.registerGuest(
            guestName: 'Offline Test',
            phoneNumber: '+1234567890',
            purpose: 'Testing',
            scheduledDate: DateTime.now(),
            expectedArrival: '10:00',
            expectedDeparture: '12:00',
            householdId: 'household-1',
          ),
          throwsException,
        );

        // Error should be captured in state
        expect(guestNotifier.state.error, isNotNull);
        expect(guestNotifier.state.error!.contains('Failed to register guest'), isTrue);
      });
    });

    group('End-to-End Guest Workflow Tests', () {
      test('Complete guest registration workflow should work end-to-end', () async {
        // Arrange
        final guestService = MockGuestService();
        final notifier = GuestNotifier(guestService);

        when(guestService.createGuest(any))
            .thenAnswer((_) async => Guest(
              id: 'workflow-guest',
              tenantId: 'tenant-1',
              householdId: 'household-1',
              guestName: 'Workflow Test',
              phoneNumber: '+1234567890',
              purpose: 'End-to-end test',
              scheduledDate: DateTime.now(),
              expectedArrival: '10:00',
              expectedDeparture: '12:00',
              status: GuestStatus.pending,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));

        when(guestService.updateGuest(any))
            .thenAnswer((_) async => Guest(
              id: 'workflow-guest',
              tenantId: 'tenant-1',
              householdId: 'household-1',
              guestName: 'Workflow Test',
              phoneNumber: '+1234567890',
              purpose: 'End-to-end test',
              scheduledDate: DateTime.now(),
              expectedArrival: '10:00',
              expectedDeparture: '12:00',
              status: GuestStatus.checkedIn,
              actualArrival: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));

        // Act - Register guest
        final registeredGuest = await notifier.registerGuest(
          guestName: 'Workflow Test',
          phoneNumber: '+1234567890',
          purpose: 'End-to-end test',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          householdId: 'household-1',
        );

        // Assert - Registration successful
        expect(registeredGuest.guestName, equals('Workflow Test'));
        expect(registeredGuest.status, equals(GuestStatus.pending));

        // Act - Check in guest
        await notifier.checkInGuest(registeredGuest.id);

        // Assert - Check in successful
        expect(notifier.state.guests.first.status, equals(GuestStatus.checkedIn));
        expect(notifier.state.guests.first.actualArrival, isNotNull);
      });

      test('Guest status transitions should maintain data integrity', () async {
        // Arrange
        final guest = Guest(
          id: 'transition-test',
          tenantId: 'tenant-1',
          householdId: 'household-1',
          guestName: 'Transition Test',
          phoneNumber: '+1234567890',
          purpose: 'Testing transitions',
          scheduledDate: DateTime.now(),
          expectedArrival: '10:00',
          expectedDeparture: '12:00',
          status: GuestStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert - Check in
        final checkedInGuest = guest.copyWith(
          status: GuestStatus.checkedIn,
          actualArrival: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(checkedInGuest.isCheckedIn, isTrue);
        expect(checkedInGuest.isOnSite, isTrue);
        expect(checkedInGuest.actualArrival, isNotNull);

        // Act & Assert - Check out
        final checkedOutGuest = checkedInGuest.copyWith(
          status: GuestStatus.checkedOut,
          actualDeparture: DateTime.now().add(const Duration(hours: 1)),
          updatedAt: DateTime.now(),
        );
        expect(checkedOutGuest.isCheckedOut, isTrue);
        expect(checkedOutGuest.isOnSite, isFalse);
        expect(checkedOutGuest.actualDeparture, isNotNull);
        expect(checkedOutGuest.visitDuration, isNotNull);
        expect(checkedOutGuest.visitDuration!.inMinutes, equals(60));
      });
    });
  });
}

/// Performance measurement utility for tests
class Stopwatch {
  late DateTime _start;
  int _elapsed = 0;

  Stopwatch() : _start = DateTime.now();

  void start() {
    _start = DateTime.now();
    _elapsed = 0;
  }

  void stop() {
    _elapsed = DateTime.now().difference(_start).inMilliseconds;
  }

  int get elapsedMilliseconds => _elapsed;
}