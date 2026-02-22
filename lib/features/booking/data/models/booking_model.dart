import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  BookingModel({
    required super.id,
    required super.listingId,
    required super.hostId,
    required super.checkInDate,
    required super.checkOutDate,
    required super.totalNights,
    required super.pricePerNight,
    required super.totalPrice,
    required super.status,
    // required super.paymentStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'],
      listingId: json['listingId'] is Map
          ? json['listingId']['_id']
          : json['listingId'],
      hostId: json['hostId'] is Map ? json['hostId']['_id'] : json['hostId'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      totalNights: json['totalNights'],
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'],
      // paymentStatus: json['paymentStatus'],
    );
  }
}
