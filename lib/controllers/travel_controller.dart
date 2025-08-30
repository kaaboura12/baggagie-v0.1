import 'package:flutter/foundation.dart';
import '../models/travel.dart';
import '../models/activity.dart';
import '../models/trip_purpose.dart';
import '../services/travel_service.dart';
import '../services/packing_service.dart';

class TravelController extends ChangeNotifier {
  List<Travel> _travels = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Travel> get travels => _travels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Create a new travel with AI-generated packing list
  Future<Travel?> createTravelWithPackingList({
    required String userId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? purposeId,
    List<String>? activityIds,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // First create the travel
      final travel = await TravelService.createTravel(
        userId: userId,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        purposeId: purposeId,
        activityIds: activityIds,
      );

      if (travel == null) {
        _setError('Failed to create travel');
        return null;
      }

      // Then generate packing list using AI
      try {
        final packingList = await PackingService.generatePackingListForTravel(travel);
        final travelWithPackingList = travel.copyWith(
          packingLists: [packingList],
        );
        
        // Add to local list
        _travels.insert(0, travelWithPackingList);
        notifyListeners();
        
        return travelWithPackingList;
      } catch (packingError) {
        // If packing list generation fails, still return the travel
        // but log the error
        print('Warning: Failed to generate packing list: $packingError');
        _travels.insert(0, travel);
        notifyListeners();
        return travel;
      }
    } catch (e) {
      _setError('Failed to create travel: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Create a travel without packing list (for backward compatibility)
  Future<Travel?> createTravel({
    required String userId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? purposeId,
    List<String>? activityIds,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final travel = await TravelService.createTravel(
        userId: userId,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        purposeId: purposeId,
        activityIds: activityIds,
      );

      if (travel != null) {
        _travels.insert(0, travel);
        notifyListeners();
      }
      return travel;
    } catch (e) {
      _setError('Failed to create travel: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user's travels
  Future<void> loadUserTravels(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final travels = await TravelService.getUserTravels(userId);
      _travels = travels;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load travels: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update a travel
  Future<Travel?> updateTravel(Travel travel) async {
    _clearError();

    try {
      final updatedTravel = await TravelService.updateTravel(travel);
      if (updatedTravel != null) {
        final index = _travels.indexWhere((t) => t.id == travel.id);
        if (index != -1) {
          _travels[index] = updatedTravel;
          notifyListeners();
        }
      }
      return updatedTravel;
    } catch (e) {
      _setError('Failed to update travel: $e');
      return null;
    }
  }

  /// Delete a travel
  Future<bool> deleteTravel(String travelId) async {
    _clearError();

    try {
      final success = await TravelService.deleteTravel(travelId);
      if (success) {
        _travels.removeWhere((t) => t.id == travelId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete travel: $e');
      return false;
    }
  }

  /// Get travel by ID
  Travel? getTravelById(String id) {
    try {
      return _travels.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get upcoming travels
  List<Travel> get upcomingTravels {
    return _travels.where((t) => t.isUpcoming).toList();
  }

  /// Get active travels
  List<Travel> get activeTravels {
    return _travels.where((t) => t.isActive).toList();
  }

  /// Get past travels
  List<Travel> get pastTravels {
    return _travels.where((t) => t.isPast).toList();
  }

  /// Clear all data
  void clear() {
    _travels.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
