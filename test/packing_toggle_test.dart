import 'package:flutter_test/flutter_test.dart';
import 'package:baggagie/models/packing_item.dart';
import 'package:baggagie/models/packing_list.dart';

void main() {
  group('Packing Item Toggle Tests', () {
    test('should toggle packed status correctly', () {
      final now = DateTime.now();
      final item = PackingItem(
        id: 'test-item-1',
        packingListId: 'test-list-1',
        name: 'Test Item',
        isPacked: false,
        createdAt: now,
      );

      expect(item.isPacked, isFalse);

      final toggledItem = item.togglePacked();
      expect(toggledItem.isPacked, isTrue);
      expect(toggledItem.id, equals(item.id));
      expect(toggledItem.name, equals(item.name));
    });

    test('should update packing list progress correctly', () {
      final now = DateTime.now();
      final items = [
        PackingItem(
          id: 'item-1',
          packingListId: 'list-1',
          name: 'Item 1',
          isPacked: false,
          createdAt: now,
        ),
        PackingItem(
          id: 'item-2',
          packingListId: 'list-1',
          name: 'Item 2',
          isPacked: true,
          createdAt: now,
        ),
        PackingItem(
          id: 'item-3',
          packingListId: 'list-1',
          name: 'Item 3',
          isPacked: false,
          createdAt: now,
        ),
      ];

      final packingList = PackingList(
        id: 'list-1',
        travelId: 'travel-1',
        name: 'Test List',
        createdAt: now,
        items: items,
      );

      expect(packingList.totalItems, equals(3));
      expect(packingList.packedItems, equals(1));
      expect(packingList.unpackedItems, equals(2));
      expect(packingList.completionPercentage, closeTo(0.33, 0.01));
      expect(packingList.isComplete, isFalse);

      // Toggle one more item
      final updatedItems = items.map((item) {
        if (item.id == 'item-1') {
          return item.togglePacked();
        }
        return item;
      }).toList();

      final updatedPackingList = packingList.copyWith(items: updatedItems);
      expect(updatedPackingList.packedItems, equals(2));
      expect(updatedPackingList.unpackedItems, equals(1));
      expect(updatedPackingList.completionPercentage, closeTo(0.67, 0.01));
    });

    test('should handle complete packing list', () {
      final now = DateTime.now();
      final items = [
        PackingItem(
          id: 'item-1',
          packingListId: 'list-1',
          name: 'Item 1',
          isPacked: true,
          createdAt: now,
        ),
        PackingItem(
          id: 'item-2',
          packingListId: 'list-1',
          name: 'Item 2',
          isPacked: true,
          createdAt: now,
        ),
      ];

      final packingList = PackingList(
        id: 'list-1',
        travelId: 'travel-1',
        name: 'Test List',
        createdAt: now,
        items: items,
      );

      expect(packingList.totalItems, equals(2));
      expect(packingList.packedItems, equals(2));
      expect(packingList.unpackedItems, equals(0));
      expect(packingList.completionPercentage, equals(1.0));
      expect(packingList.isComplete, isTrue);
    });
  });
}
