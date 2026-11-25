import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/file_api.dart';

class PetAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData icon;

  const PetAvatar({
    super.key,
    this.imageUrl,
    this.radius = 28,
    this.icon = Icons.pets,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final fallback = Icon(
      icon,
      size: radius,
      color: colorScheme.onPrimaryContainer,
    );

    final url = imageUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: url == null || url.isEmpty
          ? fallback
          : ClipOval(
              child: Image.network(
                '${context.read<FileApi>().baseUrl}$url',
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: fallback);
                },
              ),
            ),
    );
  }
}
