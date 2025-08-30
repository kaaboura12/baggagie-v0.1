import 'activity.dart';
import 'trip_purpose.dart';
import 'packing_list.dart';

class Travel {
  final String id;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final String? purposeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional related objects
  final TripPurpose? purpose;
  final List<Activity> activities;
  final List<PackingList> packingLists;

  const Travel({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    this.purposeId,
    required this.createdAt,
    required this.updatedAt,
    this.purpose,
    this.activities = const [],
    this.packingLists = const [],
  });

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      durationDays: json['duration_days'] as int,
      purposeId: json['purpose_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      purpose: json['purpose'] != null 
          ? TripPurpose.fromJson(json['purpose'] as Map<String, dynamic>)
          : null,
      activities: json['activities'] != null
          ? (json['activities'] as List)
              .map((a) => Activity.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      packingLists: json['packing_lists'] != null
          ? (json['packing_lists'] as List)
              .map((pl) => PackingList.fromJson(pl as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'destination': destination,
      'start_date': startDate.toIso8601String().split('T')[0], // Date only
      'end_date': endDate.toIso8601String().split('T')[0], // Date only
      // Note: duration_days is a generated column, so it's not included in updates
      'purpose_id': purposeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a new travel without database-generated fields (for inserts)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'destination': destination,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'purpose_id': purposeId,
      // Note: duration_days is a generated column, so it's not included
    };
  }

  Travel copyWith({
    String? id,
    String? userId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    String? purposeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TripPurpose? purpose,
    List<Activity>? activities,
    List<PackingList>? packingLists,
  }) {
    return Travel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      purposeId: purposeId ?? this.purposeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      purpose: purpose ?? this.purpose,
      activities: activities ?? this.activities,
      packingLists: packingLists ?? this.packingLists,
    );
  }

  // Helper methods
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate.add(const Duration(days: 1)));
  bool get isPast => endDate.isBefore(DateTime.now());
  
  String get statusText {
    if (isUpcoming) return 'Upcoming';
    if (isActive) return 'Active';
    return 'Completed';
  }

  int get daysUntilStart {
    if (isPast || isActive) return 0;
    return startDate.difference(DateTime.now()).inDays;
  }

  double get completionPercentage {
    if (isUpcoming) return 0.0;
    if (isPast) return 1.0;
    
    final totalDays = durationDays;
    final daysPassed = DateTime.now().difference(startDate).inDays + 1;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Travel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Travel(id: $id, destination: $destination, duration: ${durationDays}d)';
  }
}
