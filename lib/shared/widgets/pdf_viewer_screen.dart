import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:videocalling/core/config/app_imports.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({Key? key}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late String _url;
  late String _title;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _url = Get.arguments?['url'] ?? '';
    _title = Get.arguments?['title'] ?? 'PDF Viewer';
    Logger().i('PDF Viewer URL: $_url');
    
    // Validate URL early
    if (_url.isEmpty) {
      _errorMessage = 'No PDF URL provided';
      _isLoading = false;
    } else if (!_isValidUrl(_url)) {
      _errorMessage = 'Invalid PDF URL format';
      _isLoading = false;
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.color1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel + 0.25).clamp(0.5, 3.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel - 0.25).clamp(0.5, 3.0);
            },
          ),
        ],
      ),
      body: _errorMessage != null
          ? _buildErrorWidget()
          : _url.isEmpty
              ? Center(
                  child: Text(
                    'no_pdf_url'.tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : Stack(
                  children: [
                    SfPdfViewer.network(
                      _url,
                      controller: _pdfViewerController,
                      onDocumentLoaded: (details) {
                        setState(() => _isLoading = false);
                  },
                  onDocumentLoadFailed: (details) {
                    Logger().e('PDF Load Failed: ${details.error}');
                    setState(() {
                      _isLoading = false;
                      _errorMessage = details.error;
                    });
                  },
                ),
                if (_isLoading && _errorMessage == null)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.color1),
                          SizedBox(height: 16),
                          Text('Loading PDF...'),
                        ],
                      ),
                    ),
                  ),
                if (_errorMessage != null) _buildErrorWidget(),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'failed_to_load_pdf'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? 'Unknown error',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color1,
              ),
              child: Text(
                'go_back'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
