import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/shared/models/session_file_model.dart';
import 'package:videocalling/shared/services/auth/supabase_helper.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final SupabaseHelper _supabaseHelper = SupabaseHelper();
  static const String _bucketName = 'session-files';
  static const String _chatBucketName = 'chat-files';
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  Future<PlatformFile?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.size > _maxFileSizeBytes) {
          loggerNoStack.w('File too large: ${file.size} bytes');
          return null;
        }

        return file;
      }
      return null;
    } catch (e) {
      loggerNoStack.e('Error picking file: $e');
      return null;
    }
  }

  Future<PlatformFile?> pickPdf() async {
    return pickFile(allowedExtensions: ['pdf']);
  }

  Future<SessionFileModel?> uploadFile({
    required PlatformFile file,
    required String bookingId,
    required String uploadedBy,
    required String uploaderType,
  }) async {
    try {
      if (file.path == null) {
        loggerNoStack.e('File path is null');
        return null;
      }

      final fileBytes = await File(file.path!).readAsBytes();
      final fileName = '${TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch}_${file.name}';
      final storagePath = '$bookingId/$fileName';

      await _supabaseHelper.client.storage
          .from(_bucketName)
          .uploadBinary(storagePath, fileBytes);

      // Use signed URL since bucket is private
      final fileUrl = await _supabaseHelper.client.storage
          .from(_bucketName)
          .createSignedUrl(storagePath, 3600);

      loggerNoStack.d('Upload signed URL created: $fileUrl');

      final sessionFile = SessionFileModel(
        bookingId: bookingId,
        uploadedBy: uploadedBy,
        uploaderType: uploaderType,
        fileName: file.name,
        filePath: storagePath,
        fileSize: file.size,
        mimeType: _getMimeType(file.extension ?? ''),
      );

      final response = await _supabaseHelper.client
          .from('session_files')
          .insert(sessionFile.toInsertJson())
          .select()
          .single();

      loggerNoStack.i('File uploaded successfully: $storagePath');
      return SessionFileModel.fromJson(response);
    } catch (e) {
      loggerNoStack.e('Error uploading file: $e');
      return null;
    }
  }

  Future<List<SessionFileModel>> getFilesForBooking(String bookingId) async {
    try {
      final response = await _supabaseHelper.client
          .from('session_files')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SessionFileModel.fromJson(json))
          .toList();
    } catch (e) {
      loggerNoStack.e('Error fetching files for booking: $e');
      return [];
    }
  }

  Future<String?> getFileUrl(String filePath) async {
    try {
      // Use signed URL since bucket is private
      final url = await _supabaseHelper.client.storage
          .from(_bucketName)
          .createSignedUrl(filePath, 3600);
      return url;
    } catch (e) {
      loggerNoStack.e('Error getting file URL: $e');
      return null;
    }
  }

  Future<String?> getSignedUrl(String filePath, {int expiresIn = 3600}) async {
    try {
      final url = await _supabaseHelper.client.storage
          .from(_bucketName)
          .createSignedUrl(filePath, expiresIn);
      return url;
    } catch (e) {
      loggerNoStack.e('Error getting signed URL: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String fileId, String filePath) async {
    try {
      await _supabaseHelper.client.storage.from(_bucketName).remove([filePath]);

      await _supabaseHelper.client
          .from('session_files')
          .delete()
          .eq('id', fileId);

      loggerNoStack.i('File deleted: $filePath');
      return true;
    } catch (e) {
      loggerNoStack.e('Error deleting file: $e');
      return false;
    }
  }

  /// Upload a file for chat messages to Supabase storage
  /// Returns the public URL of the uploaded file, or null if upload failed
  Future<String?> uploadChatFile({
    required PlatformFile file,
    required String channelId,
  }) async {
    try {
      if (file.path == null) {
        loggerNoStack.e('Chat file path is null');
        return null;
      }

      if (file.size > _maxFileSizeBytes) {
        loggerNoStack.w('Chat file too large: ${file.size} bytes');
        return null;
      }

      final fileBytes = await File(file.path!).readAsBytes();
      // Sanitize filename - only allow alphanumeric, dots, hyphens, underscores
      final sanitizedName = _sanitizeFileName(file.name);
      final fileName = '${TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch}_$sanitizedName';
      // Sanitize channel ID as well
      final sanitizedChannelId = _sanitizeFileName(channelId);
      final storagePath = '$sanitizedChannelId/$fileName';

      await _supabaseHelper.client.storage
          .from(_chatBucketName)
          .uploadBinary(storagePath, fileBytes);

      // Use signed URL since bucket may be private
      final fileUrl = await _supabaseHelper.client.storage
          .from(_chatBucketName)
          .createSignedUrl(storagePath, 3600);

      loggerNoStack.i('Chat file uploaded successfully: $storagePath');
      return fileUrl;
    } catch (e) {
      loggerNoStack.e('Error uploading chat file: $e');
      return null;
    }
  }

  /// Get the signed URL for a chat file (async since bucket is private)
  Future<String?> getChatFileUrl(String filePath) async {
    try {
      final url = await _supabaseHelper.client.storage
          .from(_chatBucketName)
          .createSignedUrl(filePath, 3600);
      return url;
    } catch (e) {
      loggerNoStack.e('Error getting chat file URL: $e');
      return null;
    }
  }

  /// Sanitize file name to only allow safe characters for Supabase storage
  String _sanitizeFileName(String name) {
    // Replace any non-alphanumeric characters (except dots, hyphens, underscores) with underscores
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    // Remove consecutive underscores
    return sanitized.replaceAll(RegExp(r'_+'), '_');
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}

final fileUploadService = FileUploadService();
