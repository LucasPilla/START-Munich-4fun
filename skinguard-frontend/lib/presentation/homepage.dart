import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinguard/services/image_picker_service.dart';
import 'package:skinguard/data/api/skin_analysis_api.dart';
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
  final SkinAnalysisApi _skinAnalysisApi = SkinAnalysisApi();
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
        
        // Call the actual API
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
            // Close image preview dialog and show analysis dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _analysisResult != null) {
                // Close image preview dialog if it's open
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
        } catch (e) {
          if (mounted) {
            _stopLoadingMessageCycle();
            setState(() {
              _isAnalyzing = false;
              _analysisError = e.toString();
            });
            // Close image preview dialog if it's open
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error analyzing image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
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

}
