import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/manager.dart';

/// Reusable widget for displaying manager photos with caching and error handling.
/// Supports Firebase Storage URLs and falls back to placeholder on error.
class ManagerPhoto extends StatelessWidget {
  final String? photoUrl;
  final String? managerName;
  final double size;
  final bool circular;
  final BoxFit fit;

  const ManagerPhoto({
    super.key,
    this.photoUrl,
    this.managerName,
    this.size = 80,
    this.circular = true,
    this.fit = BoxFit.cover,
  });

  /// Create from Manager model
  factory ManagerPhoto.fromManager(
    Manager manager, {
    double size = 80,
    bool circular = true,
    BoxFit fit = BoxFit.cover,
  }) {
    return ManagerPhoto(
      photoUrl: manager.photoUrl,
      managerName: manager.fullName,
      size: size,
      circular: circular,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // Check if we have a valid URL
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if it's a network URL (Firebase Storage, etc.)
    if (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://')) {
      // Use Image.network on web for better CORS handling
      if (kIsWeb) {
        return Image.network(
          photoUrl!,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingIndicator();
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
      // Use CachedNetworkImage on mobile for caching benefits
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: fit,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    }

    // If it's a local asset path (legacy support)
    if (photoUrl!.startsWith('assets/')) {
      return Image.asset(
        photoUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Unknown format, show placeholder
    return _buildPlaceholder();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: managerName != null && managerName!.isNotEmpty
            ? Text(
                _getInitials(managerName!),
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: Colors.grey[400],
              ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}

/// Circular manager photo with optional border
class CircularManagerPhoto extends StatelessWidget {
  final String? photoUrl;
  final String? managerName;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  const CircularManagerPhoto({
    super.key,
    this.photoUrl,
    this.managerName,
    this.size = 60,
    this.borderColor,
    this.borderWidth = 2,
  });

  factory CircularManagerPhoto.fromManager(
    Manager manager, {
    double size = 60,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    return CircularManagerPhoto(
      photoUrl: manager.photoUrl,
      managerName: manager.fullName,
      size: size,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = ManagerPhoto(
      photoUrl: photoUrl,
      managerName: managerName,
      size: size - (borderColor != null ? borderWidth * 2 : 0),
      circular: true,
    );

    if (borderColor == null) {
      return photo;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor!,
          width: borderWidth,
        ),
      ),
      child: ClipOval(child: photo),
    );
  }
}
