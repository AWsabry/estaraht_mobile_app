import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/models/session_file_model.dart';
import 'package:videocalling/shared/services/file_upload_service.dart';

class SessionFilesWidget extends StatefulWidget {
  final String bookingId;
  final String currentUserId;
  final String currentUserType;
  final bool canUpload;

  const SessionFilesWidget({
    Key? key,
    required this.bookingId,
    required this.currentUserId,
    required this.currentUserType,
    this.canUpload = true,
  }) : super(key: key);

  @override
  State<SessionFilesWidget> createState() => _SessionFilesWidgetState();
}

class _SessionFilesWidgetState extends State<SessionFilesWidget> {
  List<SessionFileModel> _files = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    _files = await fileUploadService.getFilesForBooking(widget.bookingId);
    setState(() => _isLoading = false);
  }

  Future<void> _uploadFile() async {
    final file = await fileUploadService.pickFile(
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (file == null) {
      Get.snackbar(
        'info'.tr,
        'no_file_selected'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isUploading = true);

    final uploadedFile = await fileUploadService.uploadFile(
      file: file,
      bookingId: widget.bookingId,
      uploadedBy: widget.currentUserId,
      uploaderType: widget.currentUserType,
    );

    setState(() => _isUploading = false);

    if (uploadedFile != null) {
      Get.snackbar(
        'success'.tr,
        'file_uploaded'.tr,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      await _loadFiles();
    } else {
      Get.snackbar(
        'error'.tr,
        'file_upload_failed'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _viewFile(SessionFileModel file) async {
    final url = await fileUploadService.getSignedUrl(file.filePath);
    if (url == null) {
      Get.snackbar(
        'error'.tr,
        'cannot_load_file'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (file.isPdf) {
      Get.toNamed(
        '/session-pdf-viewer',
        arguments: {'url': url, 'title': file.fileName},
      );
    } else if (file.isImage) {
      Get.dialog(Dialog(child: Image.network(url)));
    } else if (file.isWordDocument) {
      // Open Word documents in external viewer/browser
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'error'.tr,
          'cannot_open_file'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'info'.tr,
        'file_type_not_supported'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _deleteFile(SessionFileModel file) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('delete_file'.tr),
        content: Text('delete_file_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'delete'.tr,
              style: const CustomTextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && file.id != null) {
      final success = await fileUploadService.deleteFile(
        file.id!,
        file.filePath,
      );
      if (success) {
        Get.snackbar(
          'success'.tr,
          'file_deleted'.tr,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        await _loadFiles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'session_files'.tr,
                style: const CustomTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.canUpload)
                _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.color1,
                        ),
                      )
                    : IconButton(
                        onPressed: _uploadFile,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.color1,
                        ),
                        tooltip: 'upload_file'.tr,
                      ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.color1),
            ),
          )
        else if (_files.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'no_files_uploaded'.tr,
                    style: CustomTextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              return _buildFileItem(file);
            },
          ),
      ],
    );
  }

  Widget _buildFileItem(SessionFileModel file) {
    final canDelete = file.uploadedBy == widget.currentUserId;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: file.isPdf ? Colors.red[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          file.isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
          color: file.isPdf ? Colors.red : Colors.blue,
        ),
      ),
      title: Text(
        file.fileName,
        style: const CustomTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${file.uploaderLabel} • ${file.formattedSize}',
        style: CustomTextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _viewFile(file),
            icon: const Icon(Icons.visibility, size: 20),
            tooltip: 'view'.tr,
          ),
          if (canDelete)
            IconButton(
              onPressed: () => _deleteFile(file),
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              tooltip: 'delete'.tr,
            ),
        ],
      ),
      onTap: () => _viewFile(file),
    );
  }
}
