import 'package:flutter/material.dart';
import 'package:skinguard/domain/models/skin_analysis_result.dart';
import 'package:skinguard/domain/models/dermatologist.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class AppointmentBookingPage extends StatefulWidget {
  final SkinAnalysisResult analysisResult;

  const AppointmentBookingPage({super.key, required this.analysisResult});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  // Location and map state
  Position? _currentPosition;
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  List<Dermatologist> _nearbyDermatologists = [];
  List<Dermatologist> _filteredDermatologists = [];
  Dermatologist? _selectedDermatologist;
  bool _shareIssueWithDermatologist = true;
  DateTime _selectedFilterDate = DateTime.now();
  DateTime? _selectedTimeSlot;
  bool _showBookingTicket = false;

  @override
  void initState() {
    super.initState();
    _loadMockDermatologists();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Request location permission
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location permission is required to find nearby dermatologists',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        // Update map camera to current location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        // Use default location (Munich) if location access fails
        _currentPosition = Position(
          latitude: 48.1351,
          longitude: 11.5820,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    }
  }

  void _loadMockDermatologists() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));
    final nextWeek = today.add(const Duration(days: 7));

    _nearbyDermatologists = [
      Dermatologist(
        id: '1',
        name: 'Dr. Sarah Müller',
        profession: 'Dermatologist',
        location: 'Maximilianstraße 15, 80539 München',
        latitude: 48.1374,
        longitude: 11.5755,
        distance: 0.8,
        nextAvailableTime: DateTime(today.year, today.month, today.day, 14, 0),
        availableDates: [
          DateTime(today.year, today.month, today.day, 14, 0),
          DateTime(today.year, today.month, today.day, 16, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
          DateTime(
            dayAfterTomorrow.year,
            dayAfterTomorrow.month,
            dayAfterTomorrow.day,
            11,
            0,
          ),
        ],
        rating: 4.8,
        phoneNumber: '+49 89 12345678',
        email: 's.mueller@dermaclinic.de',
      ),
      Dermatologist(
        id: '2',
        name: 'Dr. Michael Schmidt',
        profession: 'Dermatologist & Skin Specialist',
        location: 'Sendlinger Straße 32, 80331 München',
        latitude: 48.1356,
        longitude: 11.5703,
        distance: 1.2,
        nextAvailableTime: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          9,
          0,
        ),
        availableDates: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15, 0),
          DateTime(
            dayAfterTomorrow.year,
            dayAfterTomorrow.month,
            dayAfterTomorrow.day,
            10,
            0,
          ),
          DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 14, 0),
        ],
        rating: 4.9,
        phoneNumber: '+49 89 23456789',
        email: 'm.schmidt@skincare.de',
      ),
      Dermatologist(
        id: '3',
        name: 'Dr. Anna Weber',
        profession: 'Dermatologist',
        location: 'Leopoldstraße 45, 80802 München',
        latitude: 48.1633,
        longitude: 11.5756,
        distance: 2.5,
        nextAvailableTime: DateTime(today.year, today.month, today.day, 17, 0),
        availableDates: [
          DateTime(today.year, today.month, today.day, 17, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0),
          DateTime(
            dayAfterTomorrow.year,
            dayAfterTomorrow.month,
            dayAfterTomorrow.day,
            9,
            0,
          ),
        ],
        rating: 4.7,
        phoneNumber: '+49 89 34567890',
        email: 'a.weber@dermatology.de',
      ),
      Dermatologist(
        id: '4',
        name: 'Dr. Thomas Fischer',
        profession: 'Dermatologist',
        location: 'Brienner Straße 11, 80333 München',
        latitude: 48.1442,
        longitude: 11.5708,
        distance: 1.8,
        nextAvailableTime: DateTime(today.year, today.month, today.day, 15, 30),
        availableDates: [
          DateTime(today.year, today.month, today.day, 15, 30),
          DateTime(today.year, today.month, today.day, 18, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 30),
          DateTime(
            dayAfterTomorrow.year,
            dayAfterTomorrow.month,
            dayAfterTomorrow.day,
            14,
            0,
          ),
        ],
        rating: 4.6,
        phoneNumber: '+49 89 45678901',
        email: 't.fischer@skinhealth.de',
      ),
      Dermatologist(
        id: '5',
        name: 'Dr. Lisa Hoffmann',
        profession: 'Dermatologist & Cosmetic Dermatology',
        location: 'Odeonsplatz 1, 80539 München',
        latitude: 48.1425,
        longitude: 11.5770,
        distance: 1.5,
        nextAvailableTime: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          8,
          0,
        ),
        availableDates: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17, 0),
          DateTime(
            dayAfterTomorrow.year,
            dayAfterTomorrow.month,
            dayAfterTomorrow.day,
            10,
            0,
          ),
        ],
        rating: 4.9,
        phoneNumber: '+49 89 56789012',
        email: 'l.hoffmann@cosmeticderm.de',
      ),
    ];
    _filterDermatologists();
  }

  void _filterDermatologists() {
    setState(() {
      _filteredDermatologists = _nearbyDermatologists
          .where((derm) => derm.isAvailableOnDate(_selectedFilterDate))
          .toList();
    });
  }

  void _selectFilterDate(DateTime date) {
    setState(() {
      _selectedFilterDate = date;
    });
    _filterDermatologists();
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  bool _isDateSelected(DateTime date) {
    final selectedDate = DateTime(
      _selectedFilterDate.year,
      _selectedFilterDate.month,
      _selectedFilterDate.day,
    );
    final compareDate = DateTime(date.year, date.month, date.day);
    return selectedDate.isAtSameMomentAs(compareDate);
  }

  Widget _buildDateFilterButton({
    required String label,
    required DateTime date,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _isDateSelected(date);

    return InkWell(
      onTap: () => _selectFilterDate(date),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _selectTimeSlot(Dermatologist dermatologist, DateTime timeSlot) {
    setState(() {
      _selectedDermatologist = dermatologist;
      _selectedTimeSlot = timeSlot;
    });
    _showConfirmationDialog(dermatologist, timeSlot);
  }

  Future<void> _showConfirmationDialog(
    Dermatologist dermatologist,
    DateTime timeSlot,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final hour = timeSlot.hour;
    final minute = timeSlot.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    final timeStr = '$displayHour:$displayMinute $amPm';
    final dateStr =
        '${timeSlot.day} ${_getMonthAbbr(timeSlot.month)} ${timeSlot.year}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest.withOpacity(0.4),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review your booking details',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_rounded,
                      label: 'Dermatologist',
                      value: dermatologist.name,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: dermatologist.location,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: dateStr,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: timeStr,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() {
        _showBookingTicket = true;
      });
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Widget _buildBookingTicket(ColorScheme colorScheme) {
    final derm = _selectedDermatologist!;
    final timeSlot = _selectedTimeSlot!;
    final hour = timeSlot.hour;
    final minute = timeSlot.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    final timeStr = '$displayHour:$displayMinute $amPm';
    final dateStr =
        '${timeSlot.day} ${_getMonthAbbr(timeSlot.month)} ${timeSlot.year}';
    final bookingId =
        'SKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showBookingTicket = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Confirmed',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your appointment is booked',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Ticket Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ticket Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.onPrimary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appointment Booked!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Booking ID: $bookingId',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onPrimary.withOpacity(
                                        0.9,
                                      ),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ticket Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTicketInfoRow(
                              icon: Icons.person_rounded,
                              label: 'Dermatologist',
                              value: derm.name,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 20),
                            _buildTicketInfoRow(
                              icon: Icons.work_rounded,
                              label: 'Specialization',
                              value: derm.profession,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 20),
                            _buildTicketInfoRow(
                              icon: Icons.location_on_rounded,
                              label: 'Location',
                              value: derm.location,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTicketInfoRow(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Date',
                                    value: dateStr,
                                    colorScheme: colorScheme,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTicketInfoRow(
                                    icon: Icons.access_time_rounded,
                                    label: 'Time',
                                    value: timeStr,
                                    colorScheme: colorScheme,
                                  ),
                                ),
                              ],
                            ),
                            if (derm.phoneNumber != null) ...[
                              const SizedBox(height: 20),
                              _buildTicketInfoRow(
                                icon: Icons.phone_rounded,
                                label: 'Contact',
                                value: derm.phoneNumber!,
                                colorScheme: colorScheme,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Ticket Footer
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: colorScheme.onTertiaryContainer,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You will receive a confirmation email shortly. Please arrive 10 minutes before your appointment.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onTertiaryContainer,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.home_rounded),
                                label: const Text(
                                  'Back to Home',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedDermatologist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a dermatologist'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Appointment booked successfully! You will receive a confirmation email shortly.',
          ),
          backgroundColor: colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show booking ticket if confirmed
    if (_showBookingTicket &&
        _selectedDermatologist != null &&
        _selectedTimeSlot != null) {
      return _buildBookingTicket(colorScheme);
    }

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule with a dermatologist',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Share issue with dermatologist toggle
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share issue with dermatologist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Allow the dermatologist to view your analysis results',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _shareIssueWithDermatologist,
                        onChanged: (value) {
                          setState(() {
                            _shareIssueWithDermatologist = value;
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Map and Location Section
                Text(
                  'Find Nearby Dermatologists',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                // Map Container
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      _currentPosition != null
                          ? GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 13.0,
                              ),
                              markers: {
                                // Current location marker
                                Marker(
                                  markerId: const MarkerId('current_location'),
                                  position: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueBlue,
                                  ),
                                  infoWindow: const InfoWindow(
                                    title: 'Your Location',
                                  ),
                                ),
                                // Dermatologist markers
                                ..._filteredDermatologists.map((derm) {
                                  return Marker(
                                    markerId: MarkerId(derm.id),
                                    position: LatLng(
                                      derm.latitude,
                                      derm.longitude,
                                    ),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueRed,
                                    ),
                                    infoWindow: InfoWindow(
                                      title: derm.name,
                                      snippet: derm.location,
                                    ),
                                  );
                                }),
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              mapType: MapType.normal,
                            )
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: _isLoadingLocation
                                    ? CircularProgressIndicator(
                                        color: colorScheme.primary,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.map_rounded,
                                            size: 48,
                                            color: colorScheme.onSurface
                                                .withOpacity(0.3),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Loading map...',
                                            style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                      // Current location button
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _getCurrentLocation,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          child: _isLoadingLocation
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Nearby Dermatologists List
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Available Dermatologists',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDateFilterButton(
                        label: 'Today',
                        date: DateTime.now(),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildDateFilterButton(
                        label: 'Tomorrow',
                        date: DateTime.now().add(const Duration(days: 1)),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildDateFilterButton(
                        label:
                            '${DateTime.now().add(const Duration(days: 2)).day} ${_getMonthAbbr(DateTime.now().add(const Duration(days: 2)).month)}',
                        date: DateTime.now().add(const Duration(days: 2)),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildDateFilterButton(
                        label:
                            '${DateTime.now().add(const Duration(days: 3)).day} ${_getMonthAbbr(DateTime.now().add(const Duration(days: 3)).month)}',
                        date: DateTime.now().add(const Duration(days: 3)),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildDateFilterButton(
                        label:
                            '${DateTime.now().add(const Duration(days: 4)).day} ${_getMonthAbbr(DateTime.now().add(const Duration(days: 4)).month)}',
                        date: DateTime.now().add(const Duration(days: 4)),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_filteredDermatologists.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 48,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No dermatologists available on this date',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different date',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._filteredDermatologists.map((derm) {
                    final isSelected = _selectedDermatologist?.id == derm.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer.withOpacity(0.3)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDermatologist = derm;
                          });
                          // Animate map to selected dermatologist
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(derm.latitude, derm.longitude),
                              15.0,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: colorScheme.onPrimaryContainer,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          derm.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          derm.profession,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (derm.rating != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color:
                                                colorScheme.onTertiaryContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            derm.rating!.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme
                                                  .onTertiaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      derm.location,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.straighten_rounded,
                                          size: 16,
                                          color:
                                              colorScheme.onSecondaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          derm.formattedDistance,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 16,
                                          color:
                                              colorScheme.onTertiaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          derm.formattedNextAvailableTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                colorScheme.onTertiaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Available times:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: derm
                                          .getAvailableTimesForDate(
                                            _selectedFilterDate,
                                          )
                                          .map((time) {
                                            final hour = time.hour;
                                            final minute = time.minute;
                                            final amPm = hour >= 12
                                                ? 'PM'
                                                : 'AM';
                                            final displayHour = hour > 12
                                                ? hour - 12
                                                : (hour == 0 ? 12 : hour);
                                            final displayMinute = minute
                                                .toString()
                                                .padLeft(2, '0');
                                            final timeStr =
                                                '$displayHour:$displayMinute $amPm';

                                            final isSelected =
                                                _selectedTimeSlot != null &&
                                                _selectedDermatologist?.id ==
                                                    derm.id &&
                                                _selectedTimeSlot!
                                                    .isAtSameMomentAs(time);

                                            return InkWell(
                                              onTap: () =>
                                                  _selectTimeSlot(derm, time),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? colorScheme.primary
                                                      : colorScheme
                                                            .primaryContainer
                                                            .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? colorScheme.primary
                                                        : colorScheme.primary
                                                              .withOpacity(0.3),
                                                    width: isSelected ? 2 : 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  timeStr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? colorScheme.onPrimary
                                                        : colorScheme
                                                              .onPrimaryContainer,
                                                  ),
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
