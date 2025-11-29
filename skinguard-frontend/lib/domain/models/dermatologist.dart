class Dermatologist {
  final String id;
  final String name;
  final String profession;
  final String location;
  final double latitude;
  final double longitude;
  final double distance; // in kilometers
  final DateTime nextAvailableTime;
  final List<DateTime> availableDates; // List of all available dates/times
  final double? rating;
  final String? phoneNumber;
  final String? email;

  Dermatologist({
    required this.id,
    required this.name,
    required this.profession,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.nextAvailableTime,
    required this.availableDates,
    this.rating,
    this.phoneNumber,
    this.email,
  });

  /// Check if dermatologist is available on a specific date
  bool isAvailableOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return availableDates.any((availableDate) {
      final availableDateOnly = DateTime(
        availableDate.year,
        availableDate.month,
        availableDate.day,
      );
      return availableDateOnly.isAtSameMomentAs(targetDate);
    });
  }

  /// Get available times for a specific date
  List<DateTime> getAvailableTimesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return availableDates
        .where((availableDate) {
          final availableDateOnly = DateTime(
            availableDate.year,
            availableDate.month,
            availableDate.day,
          );
          return availableDateOnly.isAtSameMomentAs(targetDate);
        })
        .toList()
      ..sort();
  }

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  String get formattedNextAvailableTime {
    final now = DateTime.now();
    final difference = nextAvailableTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'Available now';
    }
  }

  String get formattedDateTime {
    final date = nextAvailableTime;
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour;
    final minute = date.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    
    return '${date.day} ${monthNames[date.month - 1]}, ${displayHour}:${displayMinute} $amPm';
  }
}

