import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/palette_card.dart';
import '../models/color_palette.dart';
import '../services/palette_storage_service.dart';
import '../utils/constants.dart';

class SavedPalettesScreen extends StatefulWidget {
  const SavedPalettesScreen({super.key});

  @override
  State<SavedPalettesScreen> createState() => _SavedPalettesScreenState();
}

class _SavedPalettesScreenState extends State<SavedPalettesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<ColorPalette> _palettes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadPalettes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadPalettes() async {
    final palettes = await PaletteStorageService.getSavedPalettes();
    setState(() {
      _palettes = palettes;
      _isLoading = false;
    });
    _fadeController.forward();
  }

  List<ColorPalette> get _filteredPalettes {
    if (_searchQuery.isEmpty) return _palettes;
    
    return _palettes.where((palette) {
      return palette.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             palette.harmonyType.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Saved Palettes'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _showClearAllDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPalettesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search palettes...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
        ),
      ),
    );
  }

  Widget _buildPalettesList() {
    final filteredPalettes = _filteredPalettes;
    
    if (filteredPalettes.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.palette_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                _searchQuery.isEmpty
                    ? 'No saved palettes yet'
                    : 'No palettes found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                _searchQuery.isEmpty
                    ? 'Create your first palette to see it here'
                    : 'Try a different search term',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
          itemCount: filteredPalettes.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: AppConstants.animationMedium,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: PaletteCard(
                    palette: filteredPalettes[index],
                    onTap: () => _showPaletteDetails(filteredPalettes[index]),
                    onDelete: () => _deletePalette(filteredPalettes[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPaletteDetails(ColorPalette palette) {
  }

  void _deletePalette(ColorPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Palette'),
        content: Text('Are you sure you want to delete "${palette.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PaletteStorageService.deletePalette(palette.id);
              Navigator.pop(context);
              _loadPalettes();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Palette deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    if (_palettes.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Palettes'),
        content: const Text('Are you sure you want to delete all saved palettes? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PaletteStorageService.clearAllPalettes();
              Navigator.pop(context);
              _loadPalettes();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All palettes cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
