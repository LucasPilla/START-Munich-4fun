import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinguard/presentation/widgets/loading_overlay_widget.dart';

class ImagePickerSection extends StatelessWidget {
  final ColorScheme colorScheme;
  final Animation<double> scaleAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> rotateAnimation;
  final AnimationController pulseController;
  final int loadingMessageIndex;
  final List<String> loadingMessages;
  final bool isAnalyzing;
  final XFile? pickedImage;
  final dynamic pickImageError;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback? onProfileTap;

  const ImagePickerSection({
    super.key,
    required this.colorScheme,
    required this.scaleAnimation,
    required this.pulseAnimation,
    required this.rotateAnimation,
    required this.pulseController,
    required this.loadingMessageIndex,
    required this.loadingMessages,
    required this.isAnalyzing,
    this.pickedImage,
    this.pickImageError,
    required this.onCameraTap,
    required this.onGalleryTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
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
            Text(
              isAnalyzing ? 'Analyzing skin image...' : 'Choose an image to analyze',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildImagePickerButton(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: onCameraTap,
            ),
            const SizedBox(height: 16),
            _buildImagePickerButton(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: onGalleryTap,
            ),
            if (onProfileTap != null) ...[
              const SizedBox(height: 16),
              _buildImagePickerButton(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: onProfileTap!,
              ),
            ],
            if (pickedImage != null) ...[
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
                      RepaintBoundary(
                        key: ValueKey(pickedImage!.path),
                        child: Image.file(
                          File(pickedImage!.path),
                          key: ValueKey(pickedImage!.path),
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          cacheHeight: 600,
                          isAntiAlias: true,
                          filterQuality: FilterQuality.medium,
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
                      ),
                      if (isAnalyzing)
                        LoadingOverlayWidget(
                          colorScheme: colorScheme,
                          pulseAnimation: pulseAnimation,
                          rotateAnimation: rotateAnimation,
                          pulseController: pulseController,
                          loadingMessageIndex: loadingMessageIndex,
                          loadingMessages: loadingMessages,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (pickImageError != null) ...[
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
                        'Error: $pickImageError',
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

  Widget _buildImagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: Opacity(
        opacity: isAnalyzing ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

