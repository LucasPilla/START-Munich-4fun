import 'package:flutter/material.dart';
import 'package:skinguard/domain/models/skin_analysis_result.dart';
import 'package:skinguard/presentation/appointment_booking_page.dart';
import 'package:skinguard/presentation/widgets/severity_badge_widget.dart';

class AnalysisDialog extends StatefulWidget {
  final SkinAnalysisResult result;
  final ColorScheme colorScheme;
  final VoidCallback onReset;

  const AnalysisDialog({
    super.key,
    required this.result,
    required this.colorScheme,
    required this.onReset,
  });

  @override
  State<AnalysisDialog> createState() => _AnalysisDialogState();
}

class _AnalysisDialogState extends State<AnalysisDialog> {
  bool _showMore = false;

  void _navigateToAppointmentBooking() {
    Navigator.of(context).pop(); // Close dialog first
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentBookingPage(
          analysisResult: widget.result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final colorScheme = widget.colorScheme;
    final isProblem = result.hasProblem;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Header - matching homepage theme
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isProblem
                      ? [
                          colorScheme.errorContainer.withOpacity(0.5),
                          colorScheme.errorContainer.withOpacity(0.3),
                        ]
                      : [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withOpacity(0.6),
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isProblem ? colorScheme.error : colorScheme.primary)
                        .withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isProblem
                              ? colorScheme.error
                              : colorScheme.primary)
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isProblem
                          ? Icons.health_and_safety_rounded
                          : Icons.check_circle_rounded,
                      color: isProblem
                          ? colorScheme.error
                          : colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isProblem ? 'Issue Detected' : 'No Issues Found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isProblem
                                ? colorScheme.error
                                : colorScheme.onPrimaryContainer,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (result.condition != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            result.condition!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isProblem
                                  ? colorScheme.error.withOpacity(0.9)
                                  : colorScheme.onPrimaryContainer.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // if (isProblem && result.severity != Severity.none) ...[
                  //   const SizedBox(width: 6),
                  //   SeverityBadgeWidget(
                  //     severity: result.severity,
                  //     colorScheme: colorScheme,
                  //   ),
                  // ],
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isProblem
                          ? colorScheme.error
                          : colorScheme.onPrimaryContainer,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content - showing all data initially
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease Description
                    if (result.diseaseDescription != null) ...[
                      _buildCard(
                        title: 'Disease Description',
                        content: result.diseaseDescription!,
                        icon: Icons.description_rounded,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Severity Level
                    if (result.severityLevel != null) ...[
                      _buildCard(
                        title: 'Severity Level',
                        content: result.severityLevel!,
                        icon: Icons.priority_high_rounded,
                        colorScheme: colorScheme,
                        isHighlighted: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Immediate Action
                    if (result.immediateAction != null) ...[
                      _buildCard(
                        title: 'Action',
                        content: result.immediateAction!,
                        icon: Icons.emergency_rounded,
                        colorScheme: colorScheme,
                        isImportant: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Things to Keep in Mind - Show first 2, then "See More"
                    if (result.thingsToKeepInMind != null && 
                        result.thingsToKeepInMind!.isNotEmpty) ...[
                      _buildListCard(
                        title: 'Things to Keep in Mind',
                        items: result.thingsToKeepInMind!,
                        icon: Icons.lightbulb_outline_rounded,
                        colorScheme: colorScheme,
                        showMore: _showMore,
                        onToggleShowMore: () {
                          setState(() {
                            _showMore = !_showMore;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Consult Doctor
                    if (result.consultDoctor == true) ...[
                      _buildCard(
                        title: 'Consult Doctor',
                        content: result.consultDoctorReasoning ?? 
                                'A doctor consultation is recommended for proper diagnosis and treatment.',
                        icon: Icons.medical_services_rounded,
                        colorScheme: colorScheme,
                        isImportant: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Fallback Description
                    if (result.diseaseDescription == null && result.description.isNotEmpty) ...[
                      _buildCard(
                        title: 'Analysis Summary',
                        content: result.description,
                        icon: Icons.analytics_rounded,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Confidence
                    if (result.confidence != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Action buttons - matching homepage theme
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  if (result.shouldRecommendAppointment) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToAppointmentBooking,
                        icon: const Icon(Icons.calendar_today_rounded, size: 20),
                        label: const Text(
                          'Book Appointment',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onReset();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Analyze Another Image',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    required ColorScheme colorScheme,
    bool isImportant = false,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isImportant
              ? [
                  colorScheme.errorContainer.withOpacity(0.3),
                  colorScheme.errorContainer.withOpacity(0.1),
                ]
              : isHighlighted
                  ? [
                      colorScheme.primaryContainer.withOpacity(0.4),
                      colorScheme.primaryContainer.withOpacity(0.2),
                    ]
                  : [
                      colorScheme.surface,
                      colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isImportant
              ? colorScheme.error.withOpacity(0.3)
              : isHighlighted
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.1),
          width: isImportant || isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isImportant
                    ? colorScheme.error
                    : isHighlighted
                        ? colorScheme.primary
                        : Colors.black)
                .withOpacity(0.1),
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
              Icon(
                icon,
                size: 20,
                color: isImportant
                    ? colorScheme.error
                    : isHighlighted
                        ? colorScheme.primary
                        : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool showMore,
    required VoidCallback onToggleShowMore,
  }) {
    final displayItems = showMore ? items : items.take(2).toList();
    final hasMore = items.length > 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayItems.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < displayItems.length - 1 ? 10 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (hasMore) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onToggleShowMore,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    showMore
                        ? 'Show Less'
                        : 'See More (${items.length - 2} more)',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    showMore ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
