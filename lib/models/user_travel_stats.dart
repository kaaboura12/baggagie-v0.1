class UserTravelStats {
  final String userId;
  final String? fullName;
  final int totalTrips;
  final double avgTripDuration;
  final int shortestTrip;
  final int longestTrip;
  final int totalTravelDays;

  const UserTravelStats({
    required this.userId,
    this.fullName,
    required this.totalTrips,
    required this.avgTripDuration,
    required this.shortestTrip,
    required this.longestTrip,
    required this.totalTravelDays,
  });

  factory UserTravelStats.fromJson(Map<String, dynamic> json) {
    return UserTravelStats(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      totalTrips: json['total_trips'] as int? ?? 0,
      avgTripDuration: (json['avg_trip_duration'] as num?)?.toDouble() ?? 0.0,
      shortestTrip: json['shortest_trip'] as int? ?? 0,
      longestTrip: json['longest_trip'] as int? ?? 0,
      totalTravelDays: json['total_travel_days'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'total_trips': totalTrips,
      'avg_trip_duration': avgTripDuration,
      'shortest_trip': shortestTrip,
      'longest_trip': longestTrip,
      'total_travel_days': totalTravelDays,
    };
  }

  // Helper getters
  String get avgDurationText => '${avgTripDuration.toStringAsFixed(1)} days';
  String get totalDaysText => '$totalTravelDays days';
  
  @override
  String toString() {
    return 'UserTravelStats(userId: $userId, trips: $totalTrips, avgDuration: ${avgDurationText})';
  }
}
