class ListingEntity {
  final String id;
  final String title;
  final String description;
  final String location;
  final String propertyType;
  final List<String> amenities;
  final int pricePerNight;
  final DateTime availableFrom;
  final DateTime availableTo;
  final int minStay;
  final int maxGuests;
  final String cancellationPolicy;
  final String houseRules;
  final List<String> images;
  final HostEntity? host;
  final String status;
  final double? latitude;
  final double? longitude;

  ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.propertyType,
    required this.amenities,
    required this.pricePerNight,
    required this.availableFrom,
    required this.availableTo,
    required this.minStay,
    required this.maxGuests,
    required this.cancellationPolicy,
    required this.houseRules,
    required this.images,
    this.host,
    required this.status,
    this.latitude,
    this.longitude,
  });

  factory ListingEntity.fromJson(Map<String, dynamic> json) {
    return ListingEntity(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      propertyType: json['propertyType'] ?? '',
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pricePerNight: json['pricePerNight'] ?? 0,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'])
          : DateTime.now(),
      availableTo: json['availableTo'] != null
          ? DateTime.parse(json['availableTo'])
          : DateTime.now(),
      minStay: json['minStay'] ?? 1,
      maxGuests: json['maxGuests'] ?? 1,
      cancellationPolicy: json['cancellationPolicy'] ?? '',
      houseRules: json['houseRules'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      host: json['hostId'] != null
          ? HostEntity.fromJson(json['hostId'] as Map<String, dynamic>)
          : null,
      status: json['status'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }
}

class HostEntity {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String profilePicture;

  HostEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.profilePicture,
  });

  factory HostEntity.fromJson(Map<String, dynamic> json) {
    return HostEntity(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
    );
  }
}
