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
    } catch (e, stack) {
      print('UI: Error fetching booked dates: $e\n$stack');
      setState(() {
        bookedDates = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load booked dates.')));
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
        // Reset check-out if it's before check-in
        if (checkOut != null && checkOut!.isBefore(checkIn!)) checkOut = null;
        _calculatePrice();
      });
    }
  }

  Future<void> _selectCheckOut(BuildContext context) async {
    if (checkIn == null) return; // Must select check-in first
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
      setState(() {
        totalPrice = nights * widget.pricePerNight;
      });
    } else {
      setState(() {
        totalPrice = 0;
      });
    }
  }

  Future<void> _bookNow() async {
    if (checkIn == null || checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
        ),
      );
      return;
    }

    final createBooking = ref.read(createBookingProvider);

    try {
      final booking = await createBooking(
        listingId: widget.listingId,
        checkIn: checkIn!,
        checkOut: checkOut!,
        pricePerNight: widget.pricePerNight,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking created! Status: ${booking.status}')),
      );

      Navigator.pop(context);
    } on DioError catch (e) {
      final response = e.response;
      if (response != null &&
          response.statusCode == 409 &&
          response.data is Map &&
          response.data['message'] == 'Selected dates are not available') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected dates are not available. Please choose different dates.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create booking: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create booking: $e')));
    }
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Cash'),
              value: 'cash',
              groupValue: _selectedPayment,
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('eSewa'),
              value: 'esewa',
              groupValue: _selectedPayment,
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Other'),
              value: 'other',
              groupValue: _selectedPayment,
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: _bookNow,
                  child: const Text('Book Now', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
