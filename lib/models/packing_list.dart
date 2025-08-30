import 'packing_item.dart';

class PackingList {
  final String id;
  final String travelId;
  final String name;
  final DateTime createdAt;
  final List<PackingItem> items;

  const PackingList({
    required this.id,
    required this.travelId,
    required this.name,
    required this.createdAt,
    this.items = const [],
  });

  factory PackingList.fromJson(Map<String, dynamic> json) {
    return PackingList(
      id: json['id']?.toString() ?? '',
      travelId: json['travel_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      items: json['packing_items'] != null
          ? (json['packing_items'] as List)
              .map((item) => PackingItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travel_id': travelId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'travel_id': travelId,
      'name': name,
    };
  }

  PackingList copyWith({
    String? id,
    String? travelId,
    String? name,
    DateTime? createdAt,
    List<PackingItem>? items,
  }) {
    return PackingList(
      id: id ?? this.id,
      travelId: travelId ?? this.travelId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  // Helper methods
  int get totalItems => items.length;
  int get packedItems => items.where((item) => item.isPacked).length;
  int get unpackedItems => totalItems - packedItems;
  double get completionPercentage => totalItems > 0 ? packedItems / totalItems : 0.0;
  bool get isComplete => totalItems > 0 && packedItems == totalItems;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackingList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PackingList(id: $id, name: $name, progress: $packedItems/$totalItems)';
  }
}
