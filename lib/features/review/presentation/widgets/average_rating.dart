import 'package:flutter/material.dart';

class AverageRating extends StatelessWidget {
  final double average;
  final int count;

  const AverageRating({super.key, this.average = 4.2, this.count = 120});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          average.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Icon(
            index < average.round() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18,
          );
        }),
        const SizedBox(width: 4),
        Text('($count)'),
      ],
    );
  }
}
