import 'package:flutter/foundation.dart';
import '../models/packing_list.dart';
import '../models/packing_item.dart';
import '../models/travel.dart';
import '../services/packing_service.dart';

class PackingController extends ChangeNotifier {
  List<PackingList> _packingLists = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PackingList> get packingLists => _packingLists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Generate a packing list for a travel using AI
  Future<PackingList?> generatePackingListForTravel(Travel travel) async {
    _setLoading(true);
    _clearError();

    try {
      final packingList = await PackingService.generatePackingListForTravel(travel);
      _packingLists.add(packingList);
      notifyListeners();
      return packingList;
    } catch (e) {
      _setError('Failed to generate packing list: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load all packing lists for a travel
  Future<void> loadPackingListsForTravel(String travelId) async {
    _setLoading(true);
    _clearError();

    try {
      final lists = await PackingService.getPackingListsForTravel(travelId);
      _packingLists = lists;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load packing lists: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load a specific packing list
  Future<PackingList?> loadPackingList(String packingListId) async {
    _setLoading(true);
    _clearError();

    try {
      final packingList = await PackingService.getPackingList(packingListId);
      if (packingList != null) {
        // Update the list if it exists in our local list
        final index = _packingLists.indexWhere((pl) => pl.id == packingListId);
        if (index != -1) {
          _packingLists[index] = packingList;
        } else {
          _packingLists.add(packingList);
        }
        notifyListeners();
      }
      return packingList;
    } catch (e) {
      _setError('Failed to load packing list: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle the packed status of an item
  Future<void> toggleItemPackedStatus(String itemId) async {
    _clearError();

    try {
      // Find the item in our local lists
      PackingItem? item;
      PackingList? parentList;
      
      for (final list in _packingLists) {
        try {
          final foundItem = list.items.firstWhere((i) => i.id == itemId);
          item = foundItem;
          parentList = list;
          break;
        } catch (e) {
          // Item not found in this list, continue to next list
          continue;
        }
      }

      if (item == null || parentList == null) {
        _setError('Item not found');
        return;
      }

      // Update the item status
      print('Toggling item ${item.name} from ${item.isPacked} to ${!item.isPacked}');
      final updatedItem = await PackingService.updatePackingItemStatus(
        itemId,
        !item.isPacked,
      );
      print('Updated item: ${updatedItem.name}, isPacked: ${updatedItem.isPacked}');

      // Update local state
      final listIndex = _packingLists.indexWhere((pl) => pl.id == parentList!.id);
      if (listIndex != -1) {
        final updatedItems = List<PackingItem>.from(_packingLists[listIndex].items);
        final itemIndex = updatedItems.indexWhere((i) => i.id == itemId);
        if (itemIndex != -1) {
          updatedItems[itemIndex] = updatedItem;
          _packingLists[listIndex] = _packingLists[listIndex].copyWith(items: updatedItems);
          print('Updated local state. List now has ${_packingLists[listIndex].items.length} items');
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to update item status: $e');
    }
  }

  /// Update an item's name
  Future<void> updateItemName(String itemId, String newName) async {
    _clearError();

    try {
      // Find the item in our local lists
      PackingItem? item;
      PackingList? parentList;
      
      for (final list in _packingLists) {
        try {
          final foundItem = list.items.firstWhere((i) => i.id == itemId);
          item = foundItem;
          parentList = list;
          break;
        } catch (e) {
          // Item not found in this list, continue
        }
      }

      if (item == null || parentList == null) {
        _setError('Item not found');
        return;
      }

      // Update the item name
      final updatedItem = await PackingService.updatePackingItemName(itemId, newName);

      // Update local state
      final listIndex = _packingLists.indexWhere((pl) => pl.id == parentList!.id);
      if (listIndex != -1) {
        final updatedItems = List<PackingItem>.from(_packingLists[listIndex].items);
        final itemIndex = updatedItems.indexWhere((i) => i.id == itemId);
        if (itemIndex != -1) {
          updatedItems[itemIndex] = updatedItem;
          _packingLists[listIndex] = _packingLists[listIndex].copyWith(items: updatedItems);
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to update item name: $e');
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    _clearError();

    try {
      // Find the item in our local lists
      PackingItem? item;
      PackingList? parentList;
      
      for (final list in _packingLists) {
        try {
          final foundItem = list.items.firstWhere((i) => i.id == itemId);
          item = foundItem;
          parentList = list;
          break;
        } catch (e) {
          // Item not found in this list, continue
        }
      }

      if (item == null || parentList == null) {
        _setError('Item not found');
        return;
      }

      // Delete the item
      await PackingService.deletePackingItem(itemId);

      // Update local state
      final listIndex = _packingLists.indexWhere((pl) => pl.id == parentList!.id);
      if (listIndex != -1) {
        final updatedItems = _packingLists[listIndex].items
            .where((i) => i.id != itemId)
            .toList();
        _packingLists[listIndex] = _packingLists[listIndex].copyWith(items: updatedItems);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to delete item: $e');
    }
  }

  /// Add a custom item to a packing list
  Future<void> addCustomItem(String packingListId, String itemName) async {
    _clearError();

    try {
      final newItem = await PackingService.addCustomItem(
        packingListId: packingListId,
        name: itemName,
      );

      // Update local state
      final listIndex = _packingLists.indexWhere((pl) => pl.id == packingListId);
      if (listIndex != -1) {
        final updatedItems = List<PackingItem>.from(_packingLists[listIndex].items);
        updatedItems.add(newItem);
        _packingLists[listIndex] = _packingLists[listIndex].copyWith(items: updatedItems);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add custom item: $e');
    }
  }

  /// Regenerate a packing list using AI
  Future<void> regeneratePackingList(PackingList packingList, Travel travel) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedList = await PackingService.regeneratePackingList(packingList, travel);
      
      // Update local state
      final listIndex = _packingLists.indexWhere((pl) => pl.id == packingList.id);
      if (listIndex != -1) {
        _packingLists[listIndex] = updatedList;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to regenerate packing list: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a packing list
  Future<void> deletePackingList(String packingListId) async {
    _clearError();

    try {
      await PackingService.deletePackingList(packingListId);
      
      // Remove from local state
      _packingLists.removeWhere((pl) => pl.id == packingListId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete packing list: $e');
    }
  }

  /// Get packing list by ID
  PackingList? getPackingListById(String id) {
    try {
      final packingList = _packingLists.firstWhere((pl) => pl.id == id);
      print('Found packing list ${packingList.id} with ${packingList.items.length} items');
      return packingList;
    } catch (e) {
      print('Packing list $id not found in local lists');
      return null;
    }
  }

  /// Get all items for a specific packing list
  List<PackingItem> getItemsForPackingList(String packingListId) {
    final packingList = getPackingListById(packingListId);
    return packingList?.items ?? [];
  }

  /// Clear all data
  void clear() {
    _packingLists.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
