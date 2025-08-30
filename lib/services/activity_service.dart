import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';

class ActivityService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all activities from the database
  static Future<List<Activity>> getAllActivities() async {
    try {
      final response = await _supabase
          .from('activities')
          .select('*')
          .order('name');

      return response
          .map((json) => Activity.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching activities: $e');
      // Return some default activities if database fails
      return _getDefaultActivities();
    }
  }

  /// Fetch activities with pagination
  static Future<Map<String, dynamic>> getActivitiesPaginated({
    int page = 1,
    int limit = 6,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await _supabase
          .from('activities')
          .select('*')
          .order('name')
          .range(from, to);

      // Get total count for pagination - using a separate query
      final countResponse = await _supabase
          .from('activities')
          .select('id');

      final activities = response
          .map((json) => Activity.fromJson(json))
          .toList();

      final totalCount = countResponse.length;
      final totalPages = (totalCount / limit).ceil();

      return {
        'activities': activities,
        'currentPage': page,
        'totalPages': totalPages,
        'totalCount': totalCount,
        'hasNextPage': page < totalPages,
        'hasPreviousPage': page > 1,
      };
    } catch (e) {
      print('Error fetching paginated activities: $e');
      // Return default activities with pagination info
      final defaultActivities = _getDefaultActivities();
      final totalCount = defaultActivities.length;
      final totalPages = (totalCount / limit).ceil();
      final startIndex = (page - 1) * limit;
      final endIndex = (startIndex + limit).clamp(0, totalCount);
      
      return {
        'activities': defaultActivities.sublist(startIndex, endIndex),
        'currentPage': page,
        'totalPages': totalPages,
        'totalCount': totalCount,
        'hasNextPage': page < totalPages,
        'hasPreviousPage': page > 1,
      };
    }
  }

  /// Get activities by IDs
  static Future<List<Activity>> getActivitiesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await _supabase
          .from('activities')
          .select('*')
          .inFilter('id', ids);

      return response
          .map((json) => Activity.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching activities by IDs: $e');
      return [];
    }
  }

  /// Default activities to show if database is unavailable
  static List<Activity> _getDefaultActivities() {
    return [
      const Activity(id: '1', name: 'Sightseeing'),
      const Activity(id: '2', name: 'Beach'),
      const Activity(id: '3', name: 'Hiking'),
      const Activity(id: '4', name: 'Museums'),
      const Activity(id: '5', name: 'Shopping'),
      const Activity(id: '6', name: 'Food Tours'),
      const Activity(id: '7', name: 'Photography'),
      const Activity(id: '8', name: 'Adventure Sports'),
      const Activity(id: '9', name: 'Cultural Events'),
      const Activity(id: '10', name: 'Nightlife'),
      const Activity(id: '11', name: 'Relaxation'),
      const Activity(id: '12', name: 'Business'),
    ];
  }
}
