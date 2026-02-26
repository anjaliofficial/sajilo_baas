import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sajilo_baas/core/utils/image_utils.dart';
import 'package:gal/gal.dart';
import 'package:sajilo_baas/core/utils/navigator_key.dart';

void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: InteractiveViewer(child: Image.network(imageUrl)),
      ),
    ),
  );
}

Future<void> _saveImageToGallery(String imageUrl) async {
  try {
    // Download image data
    await Gal.putImage(imageUrl);
    Fluttertoast.showToast(msg: 'Image saved to gallery');
  } catch (e) {
    Fluttertoast.showToast(msg: 'Failed to save image');
  }
}

Widget mediaBubble(String url, String kind) {
  if (kind == 'image') {
    final fullUrl = getFullImageUrl(url);
    return GestureDetector(
      onTap: () {
        Fluttertoast.showToast(msg: 'Image tapped');
        _showImageDialog(
          // Use root navigator for fullscreen
          navigatorKey.currentContext ??
              (throw Exception('No navigator context')),
          fullUrl,
        );
      },
      onLongPress: () async {
        // Show bottom sheet for save option
        final context = navigatorKey.currentContext;
        if (context != null) {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.save_alt),
                    title: Text('Save Image'),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _saveImageToGallery(fullUrl);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('View Fullscreen'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showImageDialog(context, fullUrl);
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          fullUrl,
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
      ),
    );
  } else if (kind == 'video') {
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
