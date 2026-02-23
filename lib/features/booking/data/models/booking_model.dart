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
    super.listingTitle,
    super.listingImages,
    super.listingLocation,
    super.listingDescription,
    super.listingPropertyType,
    super.listingMaxGuests,
    super.listingMinStay,
    super.listingCancellationPolicy,
    super.listingHouseRules,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // listingId may be a Map with details
    final listing = json['listingId'] is Map ? json['listingId'] : null;
    return BookingModel(
      id: json['_id'],
      listingId: listing != null ? listing['_id'] : json['listingId'],
      hostId: json['hostId'] is Map ? json['hostId']['_id'] : json['hostId'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      totalNights: json['totalNights'],
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'],
      // Extract listing details if available
      listingTitle: listing != null ? listing['title'] : null,
      listingImages: listing != null && listing['images'] != null
          ? List<String>.from(listing['images'])
          : null,
      listingLocation: listing != null ? listing['location'] : null,
      listingDescription: listing != null ? listing['description'] : null,
      listingPropertyType: listing != null ? listing['propertyType'] : null,
      listingMaxGuests: listing != null ? listing['maxGuests'] : null,
      listingMinStay: listing != null ? listing['minStay'] : null,
      listingCancellationPolicy: listing != null
          ? listing['cancellationPolicy']
          : null,
      listingHouseRules: listing != null ? listing['houseRules'] : null,
    );
  }
}
