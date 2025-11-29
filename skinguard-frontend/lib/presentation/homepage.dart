import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinguard/services/image_picker_service.dart';
// TODO: Uncomment when API is ready
// import 'package:skinguard/data/api/skin_analysis_api.dart';
import 'package:skinguard/domain/models/skin_analysis_result.dart';
import 'package:skinguard/presentation/widgets/header_widget.dart';
import 'package:skinguard/presentation/widgets/image_picker_section.dart';
import 'package:skinguard/presentation/widgets/analysis_dialog.dart';
import 'package:skinguard/presentation/widgets/image_preview_dialog.dart';
import 'package:skinguard/presentation/profile_page.dart';

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
  Timer? _loadingMessageTimer;

  final List<String> _loadingMessages = [
    'Scanning your skin...',
    'Analyzing texture...',
    'Detecting patterns...',
    'Almost there...',
  ];

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
    _loadingMessageTimer?.cancel();
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
                  HeaderWidget(
                    slideAnimation: _slideAnimation,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 48),
                  // Image picker section
                  ImagePickerSection(
                    colorScheme: colorScheme,
                    scaleAnimation: _scaleAnimation,
                    pulseAnimation: _pulseAnimation,
                    rotateAnimation: _rotateAnimation,
                    pulseController: _pulseController,
                    loadingMessageIndex: _loadingMessageIndex,
                    loadingMessages: _loadingMessages,
                    isAnalyzing: _isAnalyzing,
                    pickedImage: _pickedImage,
                    pickImageError: _pickImageError,
                    onCameraTap: () => _pickAndAnalyzeImage(true),
                    onGalleryTap: () => _pickAndAnalyzeImage(false),
                    onProfileTap: _navigateToProfile,
                  ),
                  // Analysis error
                  if (_analysisError != null) ...[
                    const SizedBox(height: 24),
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
                  const SizedBox(height: 68),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetAnalysis() {
    setState(() {
      _pickedImage = null;
      _analysisResult = null;
      _analysisError = null;
      _pickImageError = null;
    });
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void _startLoadingMessageCycle() {
    _loadingMessageTimer?.cancel();
    _loadingMessageTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted && _isAnalyzing) {
        setState(() {
          _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopLoadingMessageCycle() {
    _loadingMessageTimer?.cancel();
    _loadingMessageTimer = null;
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
        
        // Show image preview dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pickedImage != null) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => ImagePreviewDialog(
                pickedImage: _pickedImage!,
                colorScheme: Theme.of(context).colorScheme,
                isAnalyzing: _isAnalyzing,
                loadingMessageIndex: _loadingMessageIndex,
                loadingMessages: _loadingMessages,
                pulseAnimation: _pulseAnimation,
                rotateAnimation: _rotateAnimation,
                pulseController: _pulseController,
              ),
            );
          }
        });
        
        // Cycle through loading messages
        _startLoadingMessageCycle();
        
        // Simulate API call with mock data for UI preview
        // TODO: Replace with actual API call when backend is ready
        await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
        
        if (mounted) {
          // Generate mock analysis result
          final mockResult = _generateMockAnalysisResult();
          _stopLoadingMessageCycle();
          setState(() {
            _analysisResult = mockResult;
            _isAnalyzing = false;
            _analysisError = null;
          });
          // Close image dialog and show analysis dialog after state update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _analysisResult != null) {
              // Close image preview dialog if it's open (pop once to close any open dialog)
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              // Show analysis dialog
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => AnalysisDialog(
                  result: _analysisResult!,
                  colorScheme: Theme.of(context).colorScheme,
                  onReset: _resetAnalysis,
                ),
              );
            }
          });
        }
        
        /* 
        // Uncomment this when API is ready:
        try {
          final File imageFile = File(pickedFile.path);
          final result = await _skinAnalysisApi.analyzeSkinImage(imageFile);
          
          if (mounted) {
            _stopLoadingMessageCycle();
            setState(() {
              _analysisResult = result;
              _isAnalyzing = false;
              _analysisError = null;
            });
          }
        } catch (e) {
          if (mounted) {
            _stopLoadingMessageCycle();
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
      _stopLoadingMessageCycle();
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
    final random = DateTime.now().millisecond % 4;
    
    switch (random) {
      case 0:
        // High severity issue - Eczema example
        return SkinAnalysisResult(
          hasProblem: true,
          description: 'The analysis detected a potential skin concern that requires professional attention. The image shows signs of irregular pigmentation and texture changes. It is strongly recommended to consult with a dermatologist for a professional evaluation. Early detection and treatment are important for skin health.',
          condition: 'Eczema',
          confidence: 0.87,
          severity: Severity.high,
          diseaseDescription: 'Eczema, or atopic dermatitis, is a chronic inflammatory skin condition characterized by itchy, red, and dry skin patches. It is often triggered by environmental factors and can vary in severity.',
          severityLevel: 'Medium',
          immediateAction: 'Apply a fragrance-free moisturizer to affected areas and avoid known triggers such as harsh soaps, detergents, and allergens.',
          thingsToKeepInMind: [
            'Eczema can worsen with stress and in dry environments.',
            'Certain fabrics like wool may exacerbate symptoms; choose soft, breathable clothing.',
            'Keep nails trimmed to prevent skin damage from scratching.',
            'Track any new skincare products or environmental changes that might trigger flare-ups.',
            'Consider a humidifier in dry home environments.',
          ],
          consultDoctor: true,
          consultDoctorReasoning: 'A doctor can provide a more accurate diagnosis, assess for potential infections, and prescribe stronger treatments if over-the-counter options are ineffective.',
        );
      case 1:
        // No issues
        return SkinAnalysisResult(
          hasProblem: false,
          description: 'Great news! The analysis shows healthy skin characteristics. Your skin appears to have good texture and even tone. Continue with your regular skincare routine and maintain good sun protection habits.',
          condition: 'Healthy Skin',
          confidence: 0.92,
          severity: Severity.none,
          diseaseDescription: 'Your skin appears healthy with no significant concerns detected.',
          severityLevel: 'None',
          immediateAction: 'Continue with your regular skincare routine and maintain good sun protection habits.',
          thingsToKeepInMind: [
            'Use sunscreen daily to protect against UV damage.',
            'Stay hydrated and maintain a balanced diet.',
            'Get adequate sleep for skin regeneration.',
          ],
          consultDoctor: false,
        );
      case 2:
        // Medium severity
        return SkinAnalysisResult(
          hasProblem: true,
          description: 'The analysis identified some skin variations that may require attention. These could be related to dryness, sun exposure, or minor irritation. Consider using a gentle moisturizer and sunscreen. It is recommended to consult a healthcare professional if concerns persist.',
          condition: 'Skin Variation Detected',
          confidence: 0.75,
          severity: Severity.medium,
          diseaseDescription: 'The analysis shows some skin variations that may indicate mild irritation or dryness. These changes are typically manageable with proper skincare.',
          severityLevel: 'Medium',
          immediateAction: 'Apply a gentle, fragrance-free moisturizer and use sunscreen to protect the affected area. Avoid harsh skincare products.',
          thingsToKeepInMind: [
            'Monitor the area for any changes in size, color, or texture.',
            'Avoid picking or scratching the affected area.',
            'Use gentle, hypoallergenic skincare products.',
            'Consider keeping a skincare diary to track any triggers.',
          ],
          consultDoctor: true,
          consultDoctorReasoning: 'If symptoms persist or worsen, a healthcare professional can provide a more accurate diagnosis and treatment plan.',
        );
      default:
        // Low severity
        return SkinAnalysisResult(
          hasProblem: true,
          description: 'The analysis shows minor skin variations that are likely benign. These could be related to normal skin texture or minor dryness. Continue with your regular skincare routine. Monitor the area and consult a professional if you notice any changes.',
          condition: 'Minor Skin Variation',
          confidence: 0.68,
          severity: Severity.low,
          diseaseDescription: 'Minor skin variations detected that are likely benign and related to normal skin texture or mild dryness.',
          severityLevel: 'Low',
          immediateAction: 'Continue with your regular skincare routine. Apply moisturizer if the area feels dry.',
          thingsToKeepInMind: [
            'These variations are typically harmless.',
            'Monitor for any changes over time.',
            'Maintain a consistent skincare routine.',
          ],
          consultDoctor: false,
        );
    }
  }
}
