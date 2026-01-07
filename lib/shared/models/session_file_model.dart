class SessionFileModel {
  final String? id;
  final String bookingId;
  final String uploadedBy;
  final String uploaderType;
  final String fileName;
  final String filePath;
  final int? fileSize;
  final String? mimeType;
  final DateTime? createdAt;

  SessionFileModel({
    this.id,
    required this.bookingId,
    required this.uploadedBy,
    required this.uploaderType,
    required this.fileName,
    required this.filePath,
    this.fileSize,
    this.mimeType,
    this.createdAt,
  });

  factory SessionFileModel.fromJson(Map<String, dynamic> json) {
    return SessionFileModel(
      id: json['id']?.toString(),
      bookingId: json['booking_id']?.toString() ?? '',
      uploadedBy: json['uploaded_by']?.toString() ?? '',
      uploaderType: json['uploader_type']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileSize: int.tryParse(json['file_size']?.toString() ?? '0'),
      mimeType: json['mime_type']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'uploaded_by': uploadedBy,
      'uploader_type': uploaderType,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'booking_id': bookingId,
      'uploaded_by': uploadedBy,
      'uploader_type': uploaderType,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
    };
  }

  String get formattedSize {
    if (fileSize == null) return '';

    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  bool get isPdf =>
      mimeType == 'application/pdf' || fileName.toLowerCase().endsWith('.pdf');

  bool get isImage =>
      mimeType?.startsWith('image/') == true ||
      [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
      ].contains(fileExtension.toLowerCase());

  String get uploaderLabel =>
      uploaderType == 'doctor' ? 'Therapist' : 'Patient';
}
