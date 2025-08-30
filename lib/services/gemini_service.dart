import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/travel.dart';
import '../models/packing_item.dart';
import '../models/packing_list.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static String? _apiKey;

  static Future<void> initialize() async {
    _apiKey = dotenv.env['GEMINI_API_KEY'];
    if (_apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
  }

  static Future<List<PackingItem>> generatePackingList(Travel travel) async {
    if (_apiKey == null) {
      await initialize();
    }

    try {
      final prompt = _buildPrompt(travel);
      final response = await _callGeminiAPI(prompt);
      return _parsePackingItems(response, travel.id);
    } catch (e) {
      print('Error generating packing list: $e');
      // Return a basic default packing list if AI fails
      return _getDefaultPackingItems(travel.id);
    }
  }

  static String _buildPrompt(Travel travel) {
    final activities = travel.activities.map((a) => a.name).join(', ');
    final purpose = travel.purpose?.name ?? 'General travel';
    
    return '''
You are a travel packing expert. Based on the following trip details, generate a comprehensive and practical packing list.

Trip Details:
- Destination: ${travel.destination}
- Duration: ${travel.durationDays} days
- Start Date: ${travel.startDate.toIso8601String().split('T')[0]}
- End Date: ${travel.endDate.toIso8601String().split('T')[0]}
- Trip Purpose: $purpose
- Planned Activities: $activities

Please provide a JSON response with an array of packing items. Each item should have:
- name: A clear, specific item name (e.g., "T-shirts (3-4 pieces)", "Toothbrush", "Phone charger")
- category: One of these categories: "clothing", "toiletries", "electronics", "documents", "accessories", "health", "other"

Consider:
1. The destination's climate and season
2. The trip duration (more days = more items)
3. The planned activities (specific gear needed)
4. The trip purpose (business vs leisure vs adventure)
5. Essential items that are always needed

Return ONLY a valid JSON array in this format:
[
  {
    "name": "Item name",
    "category": "category_name"
  }
]

Make the list practical and comprehensive but not excessive. Focus on essential items that travelers commonly forget.
''';
  }

  static Future<String> _callGeminiAPI(String prompt) async {
    final url = Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey');
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': prompt
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['candidates'] != null && 
          data['candidates'].isNotEmpty && 
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Invalid response format from Gemini API');
      }
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  static List<PackingItem> _parsePackingItems(String response, String travelId) {
    try {
      // Clean the response to extract JSON
      String cleanedResponse = response.trim();
      
      // Remove any markdown formatting if present
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      // Find the JSON array in the response
      final jsonStart = cleanedResponse.indexOf('[');
      final jsonEnd = cleanedResponse.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No JSON array found in response');
      }
      
      final jsonString = cleanedResponse.substring(jsonStart, jsonEnd);
      final List<dynamic> itemsJson = json.decode(jsonString);
      
      final List<PackingItem> items = [];
      final now = DateTime.now();
      
      for (int i = 0; i < itemsJson.length; i++) {
        final item = itemsJson[i];
        items.add(PackingItem(
          id: 'temp_${now.millisecondsSinceEpoch}_$i', // Temporary ID, will be replaced by database
          packingListId: 'temp_packing_list', // Temporary ID, will be replaced
          name: item['name'] as String,
          isPacked: false,
          createdAt: now,
        ));
      }
      
      return items;
    } catch (e) {
      print('Error parsing Gemini response: $e');
      print('Response was: $response');
      return _getDefaultPackingItems(travelId);
    }
  }

  static List<PackingItem> _getDefaultPackingItems(String travelId) {
    final now = DateTime.now();
    return [
      PackingItem(
        id: 'temp_${now.millisecondsSinceEpoch}_1',
        packingListId: 'temp_packing_list',
        name: 'Passport/ID',
        isPacked: false,
        createdAt: now,
      ),
      PackingItem(
        id: 'temp_${now.millisecondsSinceEpoch}_2',
        packingListId: 'temp_packing_list',
        name: 'Phone charger',
        isPacked: false,
        createdAt: now,
      ),
      PackingItem(
        id: 'temp_${now.millisecondsSinceEpoch}_3',
        packingListId: 'temp_packing_list',
        name: 'Toothbrush',
        isPacked: false,
        createdAt: now,
      ),
      PackingItem(
        id: 'temp_${now.millisecondsSinceEpoch}_4',
        packingListId: 'temp_packing_list',
        name: 'Clothes',
        isPacked: false,
        createdAt: now,
      ),
      PackingItem(
        id: 'temp_${now.millisecondsSinceEpoch}_5',
        packingListId: 'temp_packing_list',
        name: 'Underwear',
        isPacked: false,
        createdAt: now,
      ),
    ];
  }
}
