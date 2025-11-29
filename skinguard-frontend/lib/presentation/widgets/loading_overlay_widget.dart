import 'package:flutter/material.dart';

class LoadingOverlayWidget extends StatelessWidget {
  final ColorScheme colorScheme;
  final Animation<double> pulseAnimation;
  final Animation<double> rotateAnimation;
  final AnimationController pulseController;
  final int loadingMessageIndex;
  final List<String> loadingMessages;

  const LoadingOverlayWidget({
    super.key,
    required this.colorScheme,
    required this.pulseAnimation,
    required this.rotateAnimation,
    required this.pulseController,
    required this.loadingMessageIndex,
    required this.loadingMessages,
  });

  @override
  Widget build(BuildContext context) {
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
              scale: pulseAnimation,
              child: RotationTransition(
                turns: rotateAnimation,
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
                  animation: pulseController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final animationValue = (pulseController.value + delay) % 1.0;
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
                loadingMessages[loadingMessageIndex],
                key: ValueKey(loadingMessageIndex),
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
}

