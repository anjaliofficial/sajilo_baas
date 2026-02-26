double calculateAverageRating(List reviews) {
  if (reviews.isEmpty) return 0;

  final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);

  return double.parse((total / reviews.length).toStringAsFixed(1));
}
