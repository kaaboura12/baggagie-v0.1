class PackingItem {
  final String id;
  final String packingListId;
  final String name;
  final bool isPacked;
  final DateTime createdAt;

  const PackingItem({
    required this.id,
    required this.packingListId,
    required this.name,
    required this.isPacked,
    required this.createdAt,
  });

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id']?.toString() ?? '',
      packingListId: json['packing_list_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isPacked: json['is_packed'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packing_list_id': packingListId,
      'name': name,
      'is_packed': isPacked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'packing_list_id': packingListId,
      'name': name,
      'is_packed': isPacked,
    };
  }

  PackingItem copyWith({
    String? id,
    String? packingListId,
    String? name,
    bool? isPacked,
    DateTime? createdAt,
  }) {
    return PackingItem(
      id: id ?? this.id,
      packingListId: packingListId ?? this.packingListId,
      name: name ?? this.name,
      isPacked: isPacked ?? this.isPacked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  PackingItem togglePacked() {
    return copyWith(isPacked: !isPacked);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PackingItem(id: $id, name: $name, packed: $isPacked)';
  }
}