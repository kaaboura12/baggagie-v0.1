import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/travel.dart';
import '../models/travel_activity.dart';
import '../models/activity.dart';

class TravelService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new travel
  static Future<Travel?> createTravel({
    required String userId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? purposeId,
    List<String>? activityIds,
  }) async {
    try {
      // Calculate duration in days
      final durationDays = endDate.difference(startDate).inDays + 1;

      // Insert travel (duration_days is a generated column, so we don't include it)
      final travelResponse = await _supabase
          .from('travels')
          .insert({
            'user_id': userId,
            'destination': destination,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'purpose_id': purposeId,
          })
          .select()
          .single();

      final travel = Travel.fromJson(travelResponse);

      // Add travel activities if provided
      if (activityIds != null && activityIds.isNotEmpty) {
        await _addTravelActivities(travel.id, activityIds);
      }

      return travel;
    } catch (e) {
      print('Error creating travel: $e');
      return null;
    }
  }

  /// Add activities to a travel
  static Future<void> _addTravelActivities(String travelId, List<String> activityIds) async {
    try {
      final travelActivities = activityIds.map((activityId) => {
        'travel_id': travelId,
        'activity_id': activityId,
      }).toList();

      await _supabase
          .from('travel_activities')
          .insert(travelActivities);
    } catch (e) {
      print('Error adding travel activities: $e');
    }
  }

  /// Get user's travels
  static Future<List<Travel>> getUserTravels(String userId) async {
    try {
      final response = await _supabase
          .from('travels')
          .select('''
            *,
            purpose:trip_purposes(*),
            activities:travel_activities(
              activity:activities(*)
            )
          ''')
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return response.map((json) {
        // Transform the nested activities structure
        final activities = json['activities'] != null
            ? (json['activities'] as List)
                .map((ta) {
                  if (ta is Map<String, dynamic> && ta['activity'] != null) {
                    return Activity.fromJson(ta['activity'] as Map<String, dynamic>);
                  }
                  return null;
                })
                .where((a) => a != null)
                .cast<Activity>()
                .toList()
            : <Activity>[];

        return Travel.fromJson(json).copyWith(activities: activities);
      }).toList();
    } catch (e) {
      print('Error fetching user travels: $e');
      return [];
    }
  }

  /// Update travel
  static Future<Travel?> updateTravel(Travel travel) async {
    try {
      final response = await _supabase
          .from('travels')
          .update(travel.toJson())
          .eq('id', travel.id)
          .select()
          .single();

      return Travel.fromJson(response);
    } catch (e) {
      print('Error updating travel: $e');
      return null;
    }
  }

  /// Delete travel
  static Future<bool> deleteTravel(String travelId) async {
    try {
      // First delete travel activities
      await _supabase
          .from('travel_activities')
          .delete()
          .eq('travel_id', travelId);

      // Then delete the travel
      await _supabase
          .from('travels')
          .delete()
          .eq('id', travelId);

      return true;
    } catch (e) {
      print('Error deleting travel: $e');
      return false;
    }
  }
}
