class TripPurpose {
  final String id;
  final String name;

  const TripPurpose({
    required this.id,
    required this.name,
  });

  factory TripPurpose.fromJson(Map<String, dynamic> json) {
    return TripPurpose(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TripPurpose && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TripPurpose(id: $id, name: $name)';
}
