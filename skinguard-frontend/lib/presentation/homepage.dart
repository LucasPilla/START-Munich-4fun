import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/api/skin_analysis_api.dart';
import '../domain/models/skin_analysis_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final SkinAnalysisApi _api = SkinAnalysisApi();
  
  File? _selectedImage;
  SkinAnalysisResult? _analysisResult;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
          _errorMessage = null;
        });
        _scaleController.forward(from: 0);
      }
    } catch (e) {
      String errorMessage = 'Error picking image';
      
      // Provide more user-friendly error messages
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        errorMessage = source == ImageSource.camera
            ? 'Camera permission denied. Please enable camera access in your device settings.'
            : 'Photo library permission denied. Please enable photo access in your device settings.';
      } else if (e.toString().contains('camera') || e.toString().contains('Camera')) {
        errorMessage = 'Camera not available. Please check if your device has a camera.';
      } else {
        errorMessage = 'Failed to pick image: ${e.toString()}';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final result = await _api.analyzeSkinImage(_selectedImage!);
      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
      _slideController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error analyzing image: $e';
        _isLoading = false;
      });
    }
  }

  void _reset() {
    _scaleController.reverse();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _selectedImage = null;
        _analysisResult = null;
        _errorMessage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(colorScheme),
                  const SizedBox(height: 40),

                  // Main content
                  if (_selectedImage == null)
                    _buildImagePickerSection(colorScheme)
                  else
                    _buildImageAnalysisSection(colorScheme, theme),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Skinguard',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI-Powered Skin Analysis',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerSection(ColorScheme colorScheme) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Capture or select a photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Take a clear photo of the area you\'d like to analyze',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _InteractiveButton(
                  onTap: () => _pickImage(ImageSource.camera),
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: colorScheme.primary,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InteractiveButton(
                  onTap: () => _pickImage(ImageSource.gallery),
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: colorScheme.secondary,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysisSection(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      children: [
        // Image preview with animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    height: 350,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _reset,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action button
        if (!_isLoading && _analysisResult == null)
          _InteractiveButton(
            onTap: _analyzeImage,
            icon: Icons.auto_awesome_rounded,
            label: 'Analyze Skin',
            color: colorScheme.primary,
            isPrimary: true,
            isFullWidth: true,
          ),

        // Loading state
        if (_isLoading) _buildLoadingState(colorScheme),

        // Error message
        if (_errorMessage != null)
          _buildErrorMessage(_errorMessage!, colorScheme),

        // Results
        if (_analysisResult != null)
          SlideTransition(
            position: _slideAnimation,
            child: _buildResultsCard(_analysisResult!, colorScheme),
          ),
      ],
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing your skin...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is examining the image',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard(SkinAnalysisResult result, ColorScheme colorScheme) {
    final isHealthy = !result.hasProblem;
    final bgColor = isHealthy ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor = isHealthy ? Colors.green.shade300 : Colors.orange.shade300;
    final iconColor = isHealthy ? Colors.green.shade700 : Colors.orange.shade700;
    final icon = isHealthy ? Icons.check_circle_rounded : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHealthy ? 'Skin Looks Healthy' : 'Skin Issue Detected',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    if (result.condition != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.condition!,
                        style: TextStyle(
                          fontSize: 14,
                          color: iconColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (result.confidence != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics_rounded, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: borderColor.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: iconColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          _InteractiveButton(
            onTap: _reset,
            icon: Icons.refresh_rounded,
            label: 'Analyze Another',
            color: colorScheme.primary,
            isPrimary: true,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _InteractiveButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;
  final bool isFullWidth;

  const _InteractiveButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    this.isPrimary = false,
    this.isFullWidth = false,
  });

  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPrimary ? null : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: widget.isPrimary
                ? null
                : Border.all(color: widget.color.withOpacity(0.3), width: 1.5),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.white : widget.color,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isPrimary ? Colors.white : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
