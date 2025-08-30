import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/packing_list.dart';
import '../models/packing_item.dart';
import 'gemini_service.dart';
import '../models/travel.dart';

class PackingService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Generate and create a packing list for a travel using AI
  static Future<PackingList> generatePackingListForTravel(Travel travel) async {
    try {
      // Generate packing items using Gemini AI
      final aiGeneratedItems = await GeminiService.generatePackingList(travel);
      
      // Create the packing list in database
      final packingList = await createPackingList(
        travelId: travel.id,
        name: 'Packing List for ${travel.destination}',
      );
      
      // Create all packing items in database
      final createdItems = <PackingItem>[];
      for (final item in aiGeneratedItems) {
        final createdItem = await createPackingItem(
          packingListId: packingList.id,
          name: item.name,
        );
        createdItems.add(createdItem);
      }
      
      // Return the packing list with all items
      return packingList.copyWith(items: createdItems);
    } catch (e) {
      print('Error generating packing list: $e');
      rethrow;
    }
  }

  /// Create a new packing list
  static Future<PackingList> createPackingList({
    required String travelId,
    required String name,
  }) async {
    try {
      final response = await _supabase
          .from('packing_lists')
          .insert({
            'travel_id': travelId,
            'name': name,
          })
          .select()
          .single();

      return PackingList.fromJson(response);
    } catch (e) {
      print('Error creating packing list: $e');
      rethrow;
    }
  }

  /// Create a new packing item
  static Future<PackingItem> createPackingItem({
    required String packingListId,
    required String name,
    bool isPacked = false,
  }) async {
    try {
      final response = await _supabase
          .from('packing_items')
          .insert({
            'packing_list_id': packingListId,
            'name': name,
            'is_packed': isPacked,
          })
          .select()
          .single();

      return PackingItem.fromJson(response);
    } catch (e) {
      print('Error creating packing item: $e');
      rethrow;
    }
  }

  /// Get all packing lists for a travel
  static Future<List<PackingList>> getPackingListsForTravel(String travelId) async {
    try {
      final response = await _supabase
          .from('packing_lists')
          .select('''
            *,
            packing_items (*)
          ''')
          .eq('travel_id', travelId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PackingList.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching packing lists: $e');
      rethrow;
    }
  }

  /// Get a specific packing list with its items
  static Future<PackingList?> getPackingList(String packingListId) async {
    try {
      final response = await _supabase
          .from('packing_lists')
          .select('''
            *,
            packing_items (*)
          ''')
          .eq('id', packingListId)
          .single();

      return PackingList.fromJson(response);
    } catch (e) {
      print('Error fetching packing list: $e');
      return null;
    }
  }

  /// Update a packing item's packed status
  static Future<PackingItem> updatePackingItemStatus(
    String itemId,
    bool isPacked,
  ) async {
    try {
      final response = await _supabase
          .from('packing_items')
          .update({'is_packed': isPacked})
          .eq('id', itemId)
          .select()
          .single();

      return PackingItem.fromJson(response);
    } catch (e) {
      print('Error updating packing item: $e');
      rethrow;
    }
  }

  /// Update a packing item's name
  static Future<PackingItem> updatePackingItemName(
    String itemId,
    String name,
  ) async {
    try {
      final response = await _supabase
          .from('packing_items')
          .update({'name': name})
          .eq('id', itemId)
          .select()
          .single();

      return PackingItem.fromJson(response);
    } catch (e) {
      print('Error updating packing item name: $e');
      rethrow;
    }
  }

  /// Delete a packing item
  static Future<void> deletePackingItem(String itemId) async {
    try {
      await _supabase
          .from('packing_items')
          .delete()
          .eq('id', itemId);
    } catch (e) {
      print('Error deleting packing item: $e');
      rethrow;
    }
  }

  /// Delete a packing list and all its items
  static Future<void> deletePackingList(String packingListId) async {
    try {
      // First delete all items in the packing list
      await _supabase
          .from('packing_items')
          .delete()
          .eq('packing_list_id', packingListId);

      // Then delete the packing list itself
      await _supabase
          .from('packing_lists')
          .delete()
          .eq('id', packingListId);
    } catch (e) {
      print('Error deleting packing list: $e');
      rethrow;
    }
  }

  /// Add a custom item to an existing packing list
  static Future<PackingItem> addCustomItem({
    required String packingListId,
    required String name,
  }) async {
    return createPackingItem(
      packingListId: packingListId,
      name: name,
      isPacked: false,
    );
  }

  /// Regenerate packing list using AI (replaces existing items)
  static Future<PackingList> regeneratePackingList(
    PackingList existingList,
    Travel travel,
  ) async {
    try {
      // Delete existing items
      await _supabase
          .from('packing_items')
          .delete()
          .eq('packing_list_id', existingList.id);

      // Generate new items using AI
      final aiGeneratedItems = await GeminiService.generatePackingList(travel);
      
      // Create new items
      final createdItems = <PackingItem>[];
      for (final item in aiGeneratedItems) {
        final createdItem = await createPackingItem(
          packingListId: existingList.id,
          name: item.name,
        );
        createdItems.add(createdItem);
      }
      
      // Return updated packing list
      return existingList.copyWith(items: createdItems);
    } catch (e) {
      print('Error regenerating packing list: $e');
      rethrow;
    }
  }
}
