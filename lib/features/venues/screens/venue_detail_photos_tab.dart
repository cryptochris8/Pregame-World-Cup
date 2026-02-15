import 'package:flutter/material.dart';
import '../widgets/venue_photo_gallery.dart';

/// Photos tab content for the venue detail screen.
///
/// Shows a grid of venue photos with tap-to-enlarge functionality.
class VenueDetailPhotosTab extends StatelessWidget {
  final List<String> venuePhotos;
  final bool isLoading;

  const VenueDetailPhotosTab({
    super.key,
    required this.venuePhotos,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (venuePhotos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.white38,
            ),
            SizedBox(height: 16),
            Text(
              'No photos available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: venuePhotos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showPhotoGallery(context, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              venuePhotos[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPhotoGallery(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('Photos (${initialIndex + 1}/${venuePhotos.length})'),
          ),
          body: VenuePhotoGallery(
            photoUrls: venuePhotos,
            heroTag: 'photo_gallery_detail',
            showIndicators: true,
          ),
        ),
      ),
    );
  }
}
