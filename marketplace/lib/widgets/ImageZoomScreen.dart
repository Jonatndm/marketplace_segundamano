import 'package:flutter/material.dart';

class ImageZoomScreen extends StatelessWidget {
  final String imageUrl;

  const ImageZoomScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista de Imagen')),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Permitir mover la imagen
          minScale: 0.5, // Escala mínima
          maxScale: 4.0, // Escala máxima
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder:
                (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 50,
                ),
          ),
        ),
      ),
    );
  }
}
