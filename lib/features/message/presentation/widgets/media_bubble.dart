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
    print('[CHAT_IMAGE] Attempting to load: $fullUrl');
    if (fullUrl.isEmpty) {
      return Container(
        width: 180,
        height: 150,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(height: 8),
              Text(
                'No image URL',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
              Text('Media data missing', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Fluttertoast.showToast(msg: 'Image tapped');
        _showImageDialog(
          navigatorKey.currentContext ??
              (throw Exception('No navigator context')),
          fullUrl,
        );
      },
      onLongPress: () async {
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
        child: Stack(
          children: [
            Image.network(
              fullUrl,
              width: 180,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  print('[CHAT_IMAGE] Loaded successfully: $fullUrl');
                  return child;
                }
                print('[CHAT_IMAGE] Loading in progress: $fullUrl');
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                print('[CHAT_IMAGE] ERROR loading $fullUrl: $error');
                return Container(
                  width: 180,
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image),
                        SizedBox(height: 8),
                        Text(
                          'Image error:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(error.toString(), style: TextStyle(fontSize: 10)),
                        SizedBox(height: 6),
                        Text(
                          'URL: $fullUrl',
                          style: TextStyle(fontSize: 7, color: Colors.red),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: Container(
                color: Colors.white70,
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Text(
                  fullUrl,
                  style: TextStyle(fontSize: 9, color: Colors.red),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
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

class MediaBubble extends StatelessWidget {
  final String url;
  final String kind;
  const MediaBubble({super.key, required this.url, required this.kind});

  @override
  Widget build(BuildContext context) {
    return mediaBubble(url, kind);
  }
}
