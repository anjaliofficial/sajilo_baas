import 'package:flutter/material.dart';

Widget mediaBubble(String url, String kind) {
  if (kind == 'image') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 180,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 180,
          height: 150,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  } else if (kind == 'video') {
    // For simplicity, show a video icon and a play button overlay
    return Container(
      width: 180,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white, size: 50),
      ),
    );
  }
  return Container(
    width: 180,
    height: 150,
    color: Colors.grey[200],
    child: const Center(child: Icon(Icons.help_outline)),
  );
}
