class ListingApiModel {
  final String id;
  final String title;
  final String location;
  final double pricePerNight;
  final List<String> images;
  final String description;
  final List<String> amenities;
  ListingApiModel({
    required this.id,
    required this.title,
    required this.location,
    required this.pricePerNight,
    required this.images,
    required this.description,
    required this.amenities,
  });

  factory ListingApiModel.fromJson(Map<String, dynamic> json) {
    return ListingApiModel(
      id: json['_id'],
      title: json['title'],
      location: json['location'],
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }
}
