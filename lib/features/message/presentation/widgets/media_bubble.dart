import 'package:flutter/material.dart';

Widget mediaBubble(String url, String kind) {
  if (kind == 'image') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(url, width: 180),
    );
  }
  return const Icon(Icons.videocam);
}
