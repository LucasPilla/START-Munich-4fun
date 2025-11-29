import 'package:flutter/material.dart';
import 'package:skinguard/domain/models/skin_analysis_result.dart';
import 'package:skinguard/presentation/appointment_booking_page.dart';
import 'package:skinguard/presentation/widgets/severity_badge_widget.dart';

class AnalysisResultWidget extends StatelessWidget {
  final SkinAnalysisResult result;
  final ColorScheme colorScheme;
  final VoidCallback onReset;

  const AnalysisResultWidget({
    super.key,
    required this.result,
    required this.colorScheme,
    required this.onReset,
  });

  void _navigateToAppointmentBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentBookingPage(
          analysisResult: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    if (result.hasProblem && result.severity != Severity.none) ...[
                      const SizedBox(height: 8),
                      SeverityBadgeWidget(
                        severity: result.severity,
                        colorScheme: colorScheme,
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
          if (result.shouldRecommendAppointment) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.error.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    color: colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Professional Consultation Recommended',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on the analysis, we recommend scheduling an appointment with a dermatologist.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onErrorContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToAppointmentBooking(context),
                icon: const Icon(Icons.calendar_today_rounded),
                label: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Analyze Another Image'),
              style: OutlinedButton.styleFrom(
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

