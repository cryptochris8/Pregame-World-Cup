import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import '../entities/file_attachment.dart';
import '../entities/video_message.dart';
import '../../../../core/services/performance_monitor.dart';

class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Supported file types
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedVideoTypes = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  static const List<String> supportedAudioTypes = ['mp3', 'wav', 'aac', 'm4a', 'ogg'];
  static const List<String> supportedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
  
  // File size limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100 MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50 MB
  static const int maxDocumentSize = 25 * 1024 * 1024; // 25 MB

  /// Pick and upload an image file
  Future<FileAttachment?> pickAndUploadImage({
    required String chatId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      PerformanceMonitor.startApiCall('image_upload');
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image == null) {
        PerformanceMonitor.endApiCall('image_upload', success: false);
        return null;
      }
      
      final file = File(image.path);
      final fileSize = await file.length();
      
      if (fileSize > maxImageSize) {
        // Debug output removed
        PerformanceMonitor.endApiCall('image_upload', success: false);
        return null;
      }
      
      final fileName = image.name;
      final uploadPath = 'chats/$chatId/images/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      final downloadUrl = await _uploadFile(file, uploadPath);
      if (downloadUrl == null) {
        PerformanceMonitor.endApiCall('image_upload', success: false);
        return null;
      }
      
      PerformanceMonitor.endApiCall('image_upload', success: true);
      return FileAttachment(
        fileName: fileName,
        fileUrl: downloadUrl,
        fileType: 'image',
        fileSizeBytes: fileSize,
        mimeType: 'image/${_getFileExtension(fileName)}',
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      // Debug output removed
      PerformanceMonitor.endApiCall('image_upload', success: false);
      return null;
    }
  }

  /// Pick and upload a video file
  Future<VideoMessage?> pickAndUploadVideo({
    required String chatId,
    required String messageId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      PerformanceMonitor.startApiCall('video_upload');
      
      final XFile? video = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );
      
      if (video == null) {
        PerformanceMonitor.endApiCall('video_upload', success: false);
        return null;
      }
      
      final file = File(video.path);
      final fileSize = await file.length();
      
      if (fileSize > maxVideoSize) {
        // Debug output removed
        PerformanceMonitor.endApiCall('video_upload', success: false);
        return null;
      }
      
      // Get video metadata
      final videoController = VideoPlayerController.file(file);
      await videoController.initialize();
      
      final duration = videoController.value.duration;
      final size = videoController.value.size;
      
      videoController.dispose();
      
      // Upload video
      final fileName = video.name;
      final uploadPath = 'chats/$chatId/videos/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      final downloadUrl = await _uploadFile(file, uploadPath);
      if (downloadUrl == null) {
        PerformanceMonitor.endApiCall('video_upload', success: false);
        return null;
      }
      
      // Generate thumbnail (simplified - in production, use a proper thumbnail generator)
      final thumbnailUrl = await _generateVideoThumbnail(file, chatId);
      
      PerformanceMonitor.endApiCall('video_upload', success: true);
      return VideoMessage(
        messageId: messageId,
        videoUrl: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        durationSeconds: duration.inSeconds,
        width: size.width.toInt(),
        height: size.height.toInt(),
        fileSizeBytes: fileSize,
      );
    } catch (e) {
      // Debug output removed
      PerformanceMonitor.endApiCall('video_upload', success: false);
      return null;
    }
  }

  /// Pick and upload any file type
  Future<FileAttachment?> pickAndUploadFile({
    required String chatId,
    List<String>? allowedExtensions,
  }) async {
    try {
      PerformanceMonitor.startApiCall('file_upload');
      
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        PerformanceMonitor.endApiCall('file_upload', success: false);
        return null;
      }
      
      final platformFile = result.files.first;
      final file = File(platformFile.path!);
      final fileSize = await file.length();
      final fileName = platformFile.name;
      final extension = _getFileExtension(fileName);
      
      // Check file size limits based on type
      if (!_isFileSizeValid(extension, fileSize)) {
        // Debug output removed
        PerformanceMonitor.endApiCall('file_upload', success: false);
        return null;
      }
      
      // Determine file type category
      final fileType = _getFileTypeCategory(extension);
      
      final uploadPath = 'chats/$chatId/$fileType/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      final downloadUrl = await _uploadFile(file, uploadPath);
      if (downloadUrl == null) {
        PerformanceMonitor.endApiCall('file_upload', success: false);
        return null;
      }
      
      PerformanceMonitor.endApiCall('file_upload', success: true);
      return FileAttachment(
        fileName: fileName,
        fileUrl: downloadUrl,
        fileType: fileType,
        fileSizeBytes: fileSize,
        mimeType: _getMimeType(extension),
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      // Debug output removed
      PerformanceMonitor.endApiCall('file_upload', success: false);
      return null;
    }
  }

  /// Upload audio file (for voice messages)
  Future<String?> uploadAudioFile({
    required String filePath,
    required String chatId,
    required String fileName,
  }) async {
    try {
      PerformanceMonitor.startApiCall('audio_upload');
      
      final file = File(filePath);
      final fileSize = await file.length();
      
      if (fileSize > maxAudioSize) {
        // Debug output removed
        PerformanceMonitor.endApiCall('audio_upload', success: false);
        return null;
      }
      
      final uploadPath = 'chats/$chatId/audio/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      final downloadUrl = await _uploadFile(file, uploadPath);
      PerformanceMonitor.endApiCall('audio_upload', success: downloadUrl != null);
      return downloadUrl;
    } catch (e) {
      // Debug output removed
      PerformanceMonitor.endApiCall('audio_upload', success: false);
      return null;
    }
  }

  /// Upload file to Firebase Storage
  Future<String?> _uploadFile(File file, String uploadPath) async {
    try {
      final ref = _storage.ref().child(uploadPath);
      final uploadTask = ref.putFile(file);
      
      // Listen to upload progress (you can expose this as a stream if needed)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        // Upload progress: snapshot.bytesTransferred / snapshot.totalBytes
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Generate video thumbnail (simplified implementation)
  Future<String?> _generateVideoThumbnail(File videoFile, String chatId) async {
    try {
      // In a real implementation, you would extract a frame from the video
      // For now, we'll return null and let the UI handle it gracefully
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Get file extension from filename
  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Get file type category
  String _getFileTypeCategory(String extension) {
    if (supportedImageTypes.contains(extension)) return 'image';
    if (supportedVideoTypes.contains(extension)) return 'video';
    if (supportedAudioTypes.contains(extension)) return 'audio';
    if (supportedDocumentTypes.contains(extension)) return 'document';
    return 'file';
  }

  /// Get MIME type from extension
  String? _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'm4a':
        return 'audio/mp4';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return null;
    }
  }

  /// Check if file size is valid for its type
  bool _isFileSizeValid(String extension, int fileSize) {
    final category = _getFileTypeCategory(extension);
    
    switch (category) {
      case 'image':
        return fileSize <= maxImageSize;
      case 'video':
        return fileSize <= maxVideoSize;
      case 'audio':
        return fileSize <= maxAudioSize;
      case 'document':
        return fileSize <= maxDocumentSize;
      default:
        return fileSize <= maxDocumentSize; // Default limit
    }
  }

  /// Get supported file types for display
  static List<String> getSupportedFileTypes() {
    return [
      ...supportedImageTypes,
      ...supportedVideoTypes,
      ...supportedAudioTypes,
      ...supportedDocumentTypes,
    ];
  }

  /// Check if file type is supported
  static bool isFileTypeSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return getSupportedFileTypes().contains(extension);
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
} 