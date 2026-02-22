class BookingFilter {
  final String? status; // upcoming, completed, cancelled
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? query; // listing title search

  const BookingFilter({this.status, this.fromDate, this.toDate, this.query});
}
