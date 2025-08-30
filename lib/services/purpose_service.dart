import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_purpose.dart';

class PurposeService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all trip purposes from the database
  static Future<List<TripPurpose>> getAllPurposes() async {
    try {
      final response = await _supabase
          .from('trip_purposes')
          .select('*')
          .order('name');

      return response
          .map((json) => TripPurpose.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching trip purposes: $e');
      // Return some default purposes if database fails
      return _getDefaultPurposes();
    }
  }

  /// Fetch trip purposes with pagination
  static Future<Map<String, dynamic>> getPurposesPaginated({
    int page = 1,
    int limit = 6,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await _supabase
          .from('trip_purposes')
          .select('*')
          .order('name')
          .range(from, to);

      // Get total count for pagination - using a separate query
      final countResponse = await _supabase
          .from('trip_purposes')
          .select('id');

      final purposes = response
          .map((json) => TripPurpose.fromJson(json))
          .toList();

      final totalCount = countResponse.length;
      final totalPages = (totalCount / limit).ceil();

      return {
        'purposes': purposes,
        'currentPage': page,
        'totalPages': totalPages,
        'totalCount': totalCount,
        'hasNextPage': page < totalPages,
        'hasPreviousPage': page > 1,
      };
    } catch (e) {
      print('Error fetching paginated purposes: $e');
      // Return default purposes with pagination info
      final defaultPurposes = _getDefaultPurposes();
      final totalCount = defaultPurposes.length;
      final totalPages = (totalCount / limit).ceil();
      final startIndex = (page - 1) * limit;
      final endIndex = (startIndex + limit).clamp(0, totalCount);
      
      return {
        'purposes': defaultPurposes.sublist(startIndex, endIndex),
        'currentPage': page,
        'totalPages': totalPages,
        'totalCount': totalCount,
        'hasNextPage': page < totalPages,
        'hasPreviousPage': page > 1,
      };
    }
  }

  /// Get purpose by ID
  static Future<TripPurpose?> getPurposeById(String id) async {
    try {
      final response = await _supabase
          .from('trip_purposes')
          .select('*')
          .eq('id', id)
          .single();

      return TripPurpose.fromJson(response);
    } catch (e) {
      print('Error fetching purpose by ID: $e');
      return null;
    }
  }

  /// Default purposes to show if database is unavailable
  static List<TripPurpose> _getDefaultPurposes() {
    return [
      const TripPurpose(id: '1', name: 'Leisure'),
      const TripPurpose(id: '2', name: 'Business'),
      const TripPurpose(id: '3', name: 'Adventure'),
      const TripPurpose(id: '4', name: 'Cultural'),
      const TripPurpose(id: '5', name: 'Romantic'),
      const TripPurpose(id: '6', name: 'Family'),
      const TripPurpose(id: '7', name: 'Solo Travel'),
      const TripPurpose(id: '8', name: 'Educational'),
      const TripPurpose(id: '9', name: 'Wellness'),
      const TripPurpose(id: '10', name: 'Photography'),
    ];
  }
}
