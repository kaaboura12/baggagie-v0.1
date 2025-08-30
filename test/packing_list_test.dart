import 'package:flutter_test/flutter_test.dart';
import 'package:baggagie/models/packing_item.dart';
import 'package:baggagie/models/packing_list.dart';
import 'package:baggagie/models/travel.dart';

void main() {
  group('Packing List Tests', () {
    test('should create packing item with correct properties', () {
      final now = DateTime.now();
      final item = PackingItem(
        id: 'test-id',
        packingListId: 'packing-list-id',
        name: 'Test Item',
        isPacked: false,
        createdAt: now,
      );

      expect(item.id, equals('test-id'));
      expect(item.name, equals('Test Item'));
      expect(item.isPacked, isFalse);
      expect(item.packingListId, equals('packing-list-id'));
    });

    test('should toggle packed status correctly', () {
      final now = DateTime.now();
      final item = PackingItem(
        id: 'test-id',
        packingListId: 'packing-list-id',
        name: 'Test Item',
        isPacked: false,
        createdAt: now,
      );

      final toggledItem = item.togglePacked();
      
      expect(toggledItem.isPacked, isTrue);
      expect(toggledItem.id, equals(item.id));
      expect(toggledItem.name, equals(item.name));
    });

    test('should create packing list with items', () {
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
      ];

      final packingList = PackingList(
        id: 'list-1',
        travelId: 'travel-1',
        name: 'Test List',
        createdAt: now,
        items: items,
      );

      expect(packingList.totalItems, equals(2));
      expect(packingList.packedItems, equals(1));
      expect(packingList.unpackedItems, equals(1));
      expect(packingList.completionPercentage, equals(0.5));
      expect(packingList.isComplete, isFalse);
    });

    test('should calculate completion percentage correctly', () {
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

      expect(packingList.completionPercentage, closeTo(0.67, 0.01));
      expect(packingList.isComplete, isFalse);
    });

    test('should handle empty packing list', () {
      final now = DateTime.now();
      final packingList = PackingList(
        id: 'list-1',
        travelId: 'travel-1',
        name: 'Empty List',
        createdAt: now,
        items: [],
      );

      expect(packingList.totalItems, equals(0));
      expect(packingList.packedItems, equals(0));
      expect(packingList.unpackedItems, equals(0));
      expect(packingList.completionPercentage, equals(0.0));
      expect(packingList.isComplete, isFalse);
    });
  });
}
