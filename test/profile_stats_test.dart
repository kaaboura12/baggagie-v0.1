import 'package:flutter_test/flutter_test.dart';
import 'package:baggagie/models/travel.dart';
import 'package:baggagie/models/activity.dart';
import 'package:baggagie/models/trip_purpose.dart';

void main() {
  group('Profile Statistics Tests', () {
    test('should calculate correct statistics for empty travel list', () {
      final travels = <Travel>[];
      
      final stats = _calculateTravelStats(travels);
      
      expect(stats['totalTrips'], equals(0));
      expect(stats['uniqueCountries'], equals(0));
      expect(stats['uniqueCities'], equals(0));
      expect(stats['totalDays'], equals(0));
      expect(stats['upcomingTrips'], equals(0));
      expect(stats['completedTrips'], equals(0));
    });

    test('should calculate correct statistics for multiple travels', () {
      final now = DateTime.now();
      final travels = [
        Travel(
          id: '1',
          userId: 'user1',
          destination: 'Paris, France',
          startDate: now.add(const Duration(days: 7)),
          endDate: now.add(const Duration(days: 14)),
          durationDays: 7,
          createdAt: now,
          updatedAt: now,
        ),
        Travel(
          id: '2',
          userId: 'user1',
          destination: 'Tokyo, Japan',
          startDate: now.add(const Duration(days: 30)),
          endDate: now.add(const Duration(days: 37)),
          durationDays: 7,
          createdAt: now,
          updatedAt: now,
        ),
        Travel(
          id: '3',
          userId: 'user1',
          destination: 'London, UK',
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now.subtract(const Duration(days: 23)),
          durationDays: 7,
          createdAt: now,
          updatedAt: now,
        ),
        Travel(
          id: '4',
          userId: 'user1',
          destination: 'New York, USA',
          startDate: now.add(const Duration(days: 60)),
          endDate: now.add(const Duration(days: 67)),
          durationDays: 7,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      
      final stats = _calculateTravelStats(travels);
      
      expect(stats['totalTrips'], equals(4));
      expect(stats['uniqueCountries'], equals(4)); // France, Japan, UK, USA
      expect(stats['uniqueCities'], equals(4)); // All destinations are unique
      expect(stats['totalDays'], equals(28)); // 7 * 4 trips
      expect(stats['upcomingTrips'], equals(3)); // 3 future trips
      expect(stats['completedTrips'], equals(1)); // 1 past trip
    });

    test('should handle destinations without country format', () {
      final now = DateTime.now();
      final travels = [
        Travel(
          id: '1',
          userId: 'user1',
          destination: 'Paris',
          startDate: now.add(const Duration(days: 7)),
          endDate: now.add(const Duration(days: 14)),
          durationDays: 5,
          createdAt: now,
          updatedAt: now,
        ),
        Travel(
          id: '2',
          userId: 'user1',
          destination: 'Tokyo',
          startDate: now.add(const Duration(days: 30)),
          endDate: now.add(const Duration(days: 35)),
          durationDays: 5,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      
      final stats = _calculateTravelStats(travels);
      
      expect(stats['totalTrips'], equals(2));
      expect(stats['uniqueCountries'], equals(0)); // No country format detected
      expect(stats['uniqueCities'], equals(2)); // Paris, Tokyo
      expect(stats['totalDays'], equals(10)); // 5 * 2 trips
    });

    test('should handle duplicate destinations correctly', () {
      final now = DateTime.now();
      final travels = [
        Travel(
          id: '1',
          userId: 'user1',
          destination: 'Paris, France',
          startDate: now.add(const Duration(days: 7)),
          endDate: now.add(const Duration(days: 14)),
          durationDays: 7,
          createdAt: now,
          updatedAt: now,
        ),
        Travel(
          id: '2',
          userId: 'user1',
          destination: 'Paris, France',
          startDate: now.add(const Duration(days: 30)),
          endDate: now.add(const Duration(days: 37)),
          durationDays: 7,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      
      final stats = _calculateTravelStats(travels);
      
      expect(stats['totalTrips'], equals(2));
      expect(stats['uniqueCountries'], equals(1)); // Only France
      expect(stats['uniqueCities'], equals(1)); // Only Paris, France (duplicate)
      expect(stats['totalDays'], equals(14)); // 7 * 2 trips
    });
  });
}

// Helper function to calculate travel statistics (copied from profile.dart)
Map<String, int> _calculateTravelStats(List<Travel> travels) {
  if (travels.isEmpty) {
    return {
      'totalTrips': 0,
      'uniqueCountries': 0,
      'uniqueCities': 0,
      'totalDays': 0,
      'upcomingTrips': 0,
      'completedTrips': 0,
    };
  }

  // Calculate unique countries and cities
  final countries = <String>{};
  final cities = <String>{};
  int totalDays = 0;
  int upcomingTrips = 0;
  int completedTrips = 0;

  for (final travel in travels) {
    // Extract country from destination (assuming format like "Paris, France" or "Tokyo, Japan")
    final destinationParts = travel.destination.split(',');
    if (destinationParts.length > 1) {
      final country = destinationParts.last.trim();
      countries.add(country);
    }
    
    // Add destination as city
    cities.add(travel.destination);
    
    // Sum total days
    totalDays += travel.durationDays;
    
    // Count trip status
    if (travel.isUpcoming) {
      upcomingTrips++;
    } else if (travel.isPast) {
      completedTrips++;
    }
  }

  return {
    'totalTrips': travels.length,
    'uniqueCountries': countries.length,
    'uniqueCities': cities.length,
    'totalDays': totalDays,
    'upcomingTrips': upcomingTrips,
    'completedTrips': completedTrips,
  };
}
