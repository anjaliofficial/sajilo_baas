class BookingEntity {
  final String id;
  final String listingId;
  final String hostId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalNights;
  final double pricePerNight;
  final double totalPrice;
  final String status;
  // final String paymentStatus;

  BookingEntity({
    required this.id,
    required this.listingId,
    required this.hostId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.pricePerNight,
    required this.totalPrice,
    required this.status,
    // required this.paymentStatus,
  });

  Null get listingTitle => null;
}
