import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:io';
import 'dart:typed_data';
import '../widgets/color_swatch.dart' as CustomColorSwatch;
import '../models/color_palette.dart';
import '../services/palette_storage_service.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';

class ImageColorExtractorScreen extends StatefulWidget {
  const ImageColorExtractorScreen({Key? key}) : super(key: key);

  @override
  State<ImageColorExtractorScreen> createState() => _ImageColorExtractorScreenState();
}

class _ImageColorExtractorScreenState extends State<ImageColorExtractorScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  File? _selectedImage;
  List<Color> _extractedColors = [];
  bool _isExtracting = false;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

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
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Extract Colors from Image'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_extractedColors.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePalette,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: AppConstants.animationSlow,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildImageSelector(),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildImagePreview(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildExtractButton(),
                  ],
                  if (_extractedColors.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildExtractedColors(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.image,
            size: 64,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          const Text(
            'Select an Image',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Choose a photo to extract its dominant colors',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _extractedColors.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppConstants.radiusLarge),
            ),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExtracting ? null : _extractColors,
        icon: _isExtracting 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.palette),
        label: Text(_isExtracting ? 'Extracting Colors...' : 'Extract Colors'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildExtractedColors() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: _extractedColors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                final isFirst = index == 0;
                final isLast = index == _extractedColors.length - 1;
                
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        topLeft: isFirst ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                        bottomLeft: isFirst ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                        topRight: isLast ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                        bottomRight: isLast ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ColorUtils.colorToHex(color),
                        style: TextStyle(
                          color: ColorUtils.getContrastingTextColor(color),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: _extractedColors.map((color) {
              return CustomColorSwatch.ColorSwatch(
                color: color,
                showHex: true,
                size: 60,
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          Text(
            '${_extractedColors.length} colors extracted',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedColors.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _extractColors() async {
  if (_selectedImage == null) return;
  
  setState(() {
    _isExtracting = true;
  });
  
  try {
    final Uint8List imageBytes = await _selectedImage!.readAsBytes();
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      MemoryImage(imageBytes),
      maximumColorCount: 8,
    );
    
    final List<Color> colors = [];
  
    if (paletteGenerator.dominantColor != null) {
      colors.add(paletteGenerator.dominantColor!.color);
    }
    
    if (paletteGenerator.vibrantColor != null) {
      colors.add(paletteGenerator.vibrantColor!.color);
    }
    
    if (paletteGenerator.lightVibrantColor != null) {
      colors.add(paletteGenerator.lightVibrantColor!.color);
    }
    
    if (paletteGenerator.darkVibrantColor != null) {
      colors.add(paletteGenerator.darkVibrantColor!.color);
    }
    
    if (paletteGenerator.mutedColor != null) {
      colors.add(paletteGenerator.mutedColor!.color);
    }
    
    if (paletteGenerator.lightMutedColor != null) {
      colors.add(paletteGenerator.lightMutedColor!.color);
    }
    
    if (paletteGenerator.darkMutedColor != null) {
      colors.add(paletteGenerator.darkMutedColor!.color);
    }
    
    final uniqueColors = <Color>[];
    for (final color in colors) {
      if (!uniqueColors.any((c) => c.value == color.value)) {
        uniqueColors.add(color);
      }
    }
    
    setState(() {
      _extractedColors = uniqueColors;
      _isExtracting = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Extracted ${uniqueColors.length} colors! 🎨'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    setState(() {
      _isExtracting = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error extracting colors: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _savePalette() {
    if (_extractedColors.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Color Palette'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Palette Name',
            hintText: 'Enter a name for your palette',
          ),
          maxLength: AppConstants.maxPaletteNameLength,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final palette = ColorPalette(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  colors: _extractedColors,
                  harmonyType: 'extracted',
                  createdAt: DateTime.now(),
                );
                
                await PaletteStorageService.savePalette(palette);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Palette saved successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
