import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_palette.dart';

class PaletteStorageService {
  static const String _palettesKey = 'saved_palettes';
  static const String _favoritesKey = 'favorite_palettes';

  static Future<List<ColorPalette>> getSavedPalettes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final palettesJson = prefs.getStringList(_palettesKey) ?? [];
      
      return palettesJson.map((json) {
        try {
          return ColorPalette.fromJson(jsonDecode(json));
        } catch (e) {
          print('Error parsing palette: $e');
          return null;
        }
      }).where((palette) => palette != null).cast<ColorPalette>().toList();
    } catch (e) {
      print('Error getting saved palettes: $e');
      return [];
    }
  }

  static Future<void> savePalette(ColorPalette palette) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final palettes = await getSavedPalettes();
      
      // Remove existing palette with same ID if it exists
      palettes.removeWhere((p) => p.id == palette.id);
      palettes.add(palette);
      
      final palettesJson = palettes.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_palettesKey, palettesJson);
    } catch (e) {
      print('Error saving palette: $e');
    }
  }

  static Future<void> deletePalette(String paletteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final palettes = await getSavedPalettes();
      
      palettes.removeWhere((p) => p.id == paletteId);
      
      final palettesJson = palettes.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_palettesKey, palettesJson);
    } catch (e) {
      print('Error deleting palette: $e');
    }
  }

  static Future<void> clearAllPalettes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_palettesKey);
      await prefs.remove(_favoritesKey);
    } catch (e) {
      print('Error clearing palettes: $e');
    }
  }

  static Future<List<String>> getFavoritePaletteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  static Future<void> toggleFavorite(String paletteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoritePaletteIds();
      
      if (favorites.contains(paletteId)) {
        favorites.remove(paletteId);
      } else {
        favorites.add(paletteId);
      }
      
      await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
