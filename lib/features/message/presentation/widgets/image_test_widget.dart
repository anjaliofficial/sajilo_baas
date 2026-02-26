import 'package:flutter/material.dart';

class ImageTestWidget extends StatelessWidget {
  final String imageUrl;
  const ImageTestWidget({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Test')),
      body: Center(
        child: Image.network(
          imageUrl,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error: ' + error.toString()),
              ],
            );
          },
        ),
      ),
    );
  }
}
