import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinguard/services/image_picker_service.dart';
// TODO: Uncomment when API is ready
// import 'package:skinguard/data/api/skin_analysis_api.dart';
import 'package:skinguard/domain/models/skin_analysis_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  final ImagePickerService _imagePickerService = ImagePickerService();
  // TODO: Uncomment when API is ready
  // final SkinAnalysisApi _skinAnalysisApi = SkinAnalysisApi();
  XFile? _pickedImage;
  dynamic _pickImageError;
  bool _isAnalyzing = false;
  SkinAnalysisResult? _analysisResult;
  String? _analysisError;
  int _loadingMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
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
              colorScheme.surfaceContainerHighest.withOpacity(0.4),
              colorScheme.primaryContainer.withOpacity(0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(colorScheme),
                  const SizedBox(height: 48),
                  // Camera button section
                  _buildCameraButtonSection(colorScheme),

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
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 56,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Skinguard',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -1,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'AI-Powered Skin Analysis',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButtonSection(ColorScheme colorScheme) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.4),
              colorScheme.primaryContainer.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImagePickerButton(
                  colorScheme: colorScheme,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => _pickAndAnalyzeImage(true),
                ),
                const SizedBox(width: 24),
                _buildImagePickerButton(
                  colorScheme: colorScheme,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => _pickAndAnalyzeImage(false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _isAnalyzing ? 'Analyzing skin image...' : 'Choose an image to analyze',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_pickedImage != null) ...[
              const SizedBox(height: 24),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(_pickedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Error loading image',
                              style: TextStyle(
                                color: colorScheme.error,
                              ),
                            ),
                          );
                        },
                      ),
                      if (_isAnalyzing)
                        _buildFunLoadingOverlay(colorScheme),
                    ],
                  ),
                ),
              ),
              if (!_isAnalyzing && _analysisResult == null && _analysisError == null) ...[
                const SizedBox(height: 12),
                Text(
                  'Image captured successfully!',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
            if (_analysisResult != null) ...[
              const SizedBox(height: 24),
              _buildAnalysisResult(colorScheme),
            ],
            if (_analysisError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Analysis Error: $_analysisError',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_pickImageError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Error: $_pickImageError',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startLoadingMessageCycle() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _isAnalyzing) {
        setState(() {
          _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
        _startLoadingMessageCycle();
      }
    });
  }

  final List<String> _loadingMessages = [
    'Scanning your skin...',
    'Analyzing texture...',
    'Detecting patterns...',
    'Almost there...',
  ];

  Widget _buildFunLoadingOverlay(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated rotating icon with pulsing effect
            ScaleTransition(
              scale: _pulseAnimation,
              child: RotationTransition(
                turns: _rotateAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                        colorScheme.tertiary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Animated dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final animationValue = (_pulseController.value + delay) % 1.0;
                    final opacity = (animationValue < 0.5)
                        ? animationValue * 2
                        : 2 - (animationValue * 2);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            // Cycling loading message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _loadingMessages[_loadingMessageIndex],
                key: ValueKey(_loadingMessageIndex),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our AI is working its magic ✨',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyzeImage(bool fromCamera) async {
    try {
      final XFile? pickedFile = fromCamera
          ? await _imagePickerService.pickImageFromCamera()
          : await _imagePickerService.pickImageFromGallery();
      
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
          _pickImageError = null;
          _analysisResult = null;
          _analysisError = null;
          _isAnalyzing = true;
          _loadingMessageIndex = 0;
        });
        
        // Cycle through loading messages
        _startLoadingMessageCycle();
        
        // Simulate API call with mock data for UI preview
        // TODO: Replace with actual API call when backend is ready
        await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
        
        if (mounted) {
          // Generate mock analysis result
          final mockResult = _generateMockAnalysisResult();
          setState(() {
            _analysisResult = mockResult;
            _isAnalyzing = false;
            _analysisError = null;
          });
        }
        
        /* 
        // Uncomment this when API is ready:
        try {
          final File imageFile = File(pickedFile.path);
          final result = await _skinAnalysisApi.analyzeSkinImage(imageFile);
          
          if (mounted) {
            setState(() {
              _analysisResult = result;
              _isAnalyzing = false;
              _analysisError = null;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isAnalyzing = false;
              _analysisError = e.toString();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error analyzing image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        */
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generates mock analysis results for UI preview
  /// TODO: Remove this when real API is integrated
  SkinAnalysisResult _generateMockAnalysisResult() {
    // Randomly generate different mock results for variety
    final random = DateTime.now().millisecond % 3;
    
    switch (random) {
      case 0:
        // Issue detected
        return SkinAnalysisResult(
          hasProblem: true,
          description: 'The analysis detected a potential skin concern. The image shows signs of irregular pigmentation and texture changes. It is recommended to consult with a dermatologist for a professional evaluation. Early detection and treatment are important for skin health.',
          condition: 'Irregular Pigmentation',
          confidence: 0.87,
        );
      case 1:
        // No issues
        return SkinAnalysisResult(
          hasProblem: false,
          description: 'Great news! The analysis shows healthy skin characteristics. Your skin appears to have good texture and even tone. Continue with your regular skincare routine and maintain good sun protection habits.',
          condition: 'Healthy Skin',
          confidence: 0.92,
        );
      default:
        // Minor concern
        return SkinAnalysisResult(
          hasProblem: true,
          description: 'The analysis identified some minor skin variations that may require attention. These could be related to dryness, sun exposure, or minor irritation. Consider using a gentle moisturizer and sunscreen. If concerns persist, consult a healthcare professional.',
          condition: 'Minor Skin Variation',
          confidence: 0.75,
        );
    }
  }

  Widget _buildAnalysisResult(ColorScheme colorScheme) {
    final result = _analysisResult!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: result.hasProblem
              ? [
                  colorScheme.errorContainer.withOpacity(0.3),
                  colorScheme.errorContainer.withOpacity(0.1),
                ]
              : [
                  colorScheme.tertiaryContainer.withOpacity(0.3),
                  colorScheme.tertiaryContainer.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: result.hasProblem
              ? colorScheme.error.withOpacity(0.3)
              : colorScheme.tertiary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (result.hasProblem
                    ? colorScheme.error
                    : colorScheme.tertiary)
                .withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  color: result.hasProblem
                      ? colorScheme.errorContainer
                      : colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.hasProblem
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: result.hasProblem
                      ? colorScheme.onErrorContainer
                      : colorScheme.onTertiaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.hasProblem ? 'Issue Detected' : 'No Issues Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: result.hasProblem
                            ? colorScheme.onErrorContainer
                            : colorScheme.onTertiaryContainer,
                      ),
                    ),
                    if (result.condition != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.condition!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: result.hasProblem
                              ? colorScheme.onErrorContainer.withOpacity(0.8)
                              : colorScheme.onTertiaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              result.description,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
          if (result.confidence != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _pickedImage = null;
                  _analysisResult = null;
                  _analysisError = null;
                  _pickImageError = null;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Analyze Another Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
