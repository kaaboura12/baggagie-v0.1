import 'activity.dart';

class TravelActivity {
  final String travelId;
  final String activityId;
  final Activity? activity; // Optional nested object

  const TravelActivity({
    required this.travelId,
    required this.activityId,
    this.activity,
  });

  factory TravelActivity.fromJson(Map<String, dynamic> json) {
    return TravelActivity(
      travelId: json['travel_id'] as String,
      activityId: json['activity_id'] as String,
      activity: json['activity'] != null
          ? Activity.fromJson(json['activity'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travel_id': travelId,
      'activity_id': activityId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelActivity && 
           other.travelId == travelId && 
           other.activityId == activityId;
  }

  @override
  int get hashCode => Object.hash(travelId, activityId);

  @override
  String toString() {
    return 'TravelActivity(travelId: $travelId, activityId: $activityId)';
  }
}