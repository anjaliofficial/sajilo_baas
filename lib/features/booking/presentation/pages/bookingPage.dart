import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_providers.dart';

// Provider for booked dates
final bookedDatesProvider = FutureProvider.family<List<DateTime>, String>((
  ref,
  listingId,
) async {
  final getBookedDates = ref.read(getBookedDatesProvider);
  return getBookedDates(listingId);
});

class BookingPage extends ConsumerStatefulWidget {
  final String listingId;
  final double pricePerNight;

  const BookingPage({
    super.key,
    required this.listingId,
    required this.pricePerNight,
  });

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  String? _selectedPayment;
  DateTime? checkIn;
  DateTime? checkOut;

  double totalPrice = 0;
  List<DateTime> bookedDates = [];

  // Inline toast state
  String? _toastMessage;
  bool _toastIsError = false;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    _fetchBookedDates();
  }

  Future<void> _fetchBookedDates() async {
    try {
      final dates = await ref.read(
        bookedDatesProvider(widget.listingId).future,
      );
      setState(() {
        bookedDates = dates;
      });
    } catch (e) {
      _showInlineToast('Could not load booked dates.', isError: true);
    }
  }

  Future<void> _selectCheckIn(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (date) => !_isDateBooked(date),
    );

    if (picked != null) {
      setState(() {
        checkIn = picked;
        if (checkOut != null && checkOut!.isBefore(checkIn!)) {
          checkOut = null;
        }
        _calculatePrice();
      });
    }
  }

  Future<void> _selectCheckOut(BuildContext context) async {
    if (checkIn == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: checkIn!.add(const Duration(days: 1)),
      firstDate: checkIn!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 366)),
      selectableDayPredicate: (date) => !_isDateBooked(date),
    );

    if (picked != null) {
      setState(() {
        checkOut = picked;
        _calculatePrice();
      });
    }
  }

  bool _isDateBooked(DateTime date) {
    return bookedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  void _calculatePrice() {
    if (checkIn != null && checkOut != null) {
      final nights = checkOut!.difference(checkIn!).inDays;
      totalPrice = nights * widget.pricePerNight;
    } else {
      totalPrice = 0;
    }
  }

  Future<void> _bookNow() async {
    if (checkIn == null || checkOut == null) {
      _showInlineToast(
        'Please select check-in and check-out dates',
        isError: true,
      );
      return;
    }

    // Check if any selected date is already booked
    DateTime current = checkIn!;
    bool hasConflict = false;
    while (!current.isAfter(checkOut!)) {
      if (_isDateBooked(current)) {
        hasConflict = true;
        break;
      }
      current = current.add(const Duration(days: 1));
    }
    if (hasConflict) {
      _showInlineToast('Selected dates are not available.', isError: true);
      return;
    }

    final createBooking = ref.read(createBookingProvider);

    try {
      await createBooking(
        listingId: widget.listingId,
        checkIn: checkIn!,
        checkOut: checkOut!,
        pricePerNight: widget.pricePerNight,
      );

      _showInlineToast('Booking successful!', isError: false);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/my-bookings');
      }
    } catch (e) {
      String errorMsg = 'Failed to create booking';

      if (e is DioException) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMsg = e.response!.data['message'].toString();
        } else if (e.message != null) {
          errorMsg = e.message!;
        }
      }

      _showInlineToast(errorMsg, isError: true);
    }
  }

  void _showInlineToast(String message, {required bool isError}) {
    setState(() {
      _toastMessage = message;
      _toastIsError = isError;
      _showToast = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Now')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Check-in'),
              subtitle: Text(
                checkIn != null
                    ? checkIn!.toLocal().toString().split(' ')[0]
                    : 'Select date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectCheckIn(context),
            ),
            ListTile(
              title: const Text('Check-out'),
              subtitle: Text(
                checkOut != null
                    ? checkOut!.toLocal().toString().split(' ')[0]
                    : 'Select date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectCheckOut(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Price: NPR $totalPrice',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Payment Method:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Cash'),
              value: 'cash',
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v),
            ),
            RadioListTile<String>(
              title: const Text('eSewa'),
              value: 'esewa',
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v),
            ),
            RadioListTile<String>(
              title: const Text('Other'),
              value: 'other',
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: _bookNow,
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_showToast && _toastMessage != null)
                  _InlineToast(message: _toastMessage!, isError: _toastIsError),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Inline toast widget
class _InlineToast extends StatelessWidget {
  final String message;
  final bool isError;

  const _InlineToast({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? Colors.red[400] : Colors.green[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
