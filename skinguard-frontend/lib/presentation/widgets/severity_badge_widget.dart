import 'package:flutter/material.dart';
import 'package:skinguard/domain/models/skin_analysis_result.dart';

class SeverityBadgeWidget extends StatelessWidget {
  final Severity severity;
  final ColorScheme colorScheme;

  const SeverityBadgeWidget({
    super.key,
    required this.severity,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (severity) {
      case Severity.high:
        label = 'High Priority';
        color = colorScheme.error;
        icon = Icons.priority_high_rounded;
        break;
      case Severity.medium:
        label = 'Medium Priority';
        color = Colors.orange;
        icon = Icons.warning_rounded;
        break;
      case Severity.low:
        label = 'Low Priority';
        color = Colors.amber;
        icon = Icons.info_outline_rounded;
        break;
      default:
        label = '';
        color = colorScheme.primary;
        icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

