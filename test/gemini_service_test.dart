import 'package:flutter_test/flutter_test.dart';
import 'package:baggagie/models/travel.dart';
import 'package:baggagie/models/activity.dart';
import 'package:baggagie/models/trip_purpose.dart';

void main() {
  group('Travel Model Tests', () {
    test('should create travel with all required fields', () {
      final travel = Travel(
        id: 'test-travel-id',
        userId: 'test-user-id',
        destination: 'Paris, France',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        durationDays: 7,
        purposeId: 'vacation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        purpose: const TripPurpose(id: 'vacation', name: 'Vacation'),
        activities: const [
          Activity(id: 'sightseeing', name: 'Sightseeing'),
          Activity(id: 'dining', name: 'Fine Dining'),
        ],
      );

      expect(travel.id, equals('test-travel-id'));
      expect(travel.destination, equals('Paris, France'));
      expect(travel.durationDays, equals(7));
      expect(travel.purpose?.name, equals('Vacation'));
      expect(travel.activities.length, equals(2));
      expect(travel.isUpcoming, isTrue);
    });

    test('should calculate travel status correctly', () {
      final now = DateTime.now();
      
      // Upcoming travel
      final upcomingTravel = Travel(
        id: 'upcoming',
        userId: 'user',
        destination: 'Future',
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 14)),
        durationDays: 7,
        createdAt: now,
        updatedAt: now,
      );
      
      expect(upcomingTravel.isUpcoming, isTrue);
      expect(upcomingTravel.isActive, isFalse);
      expect(upcomingTravel.isPast, isFalse);
      expect(upcomingTravel.statusText, equals('Upcoming'));
      
      // Past travel
      final pastTravel = Travel(
        id: 'past',
        userId: 'user',
        destination: 'Past',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 7)),
        durationDays: 7,
        createdAt: now,
        updatedAt: now,
      );
      
      expect(pastTravel.isUpcoming, isFalse);
      expect(pastTravel.isActive, isFalse);
      expect(pastTravel.isPast, isTrue);
      expect(pastTravel.statusText, equals('Completed'));
    });
  });
}
