import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final void Function(int)? onChanged;

  const StarRatingWidget({super.key, required this.rating, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: onChanged == null ? null : () => onChanged!(index + 1),
        );
      }),
    );
  }
}
