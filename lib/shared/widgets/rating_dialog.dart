import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/models/review_model.dart';
import 'package:videocalling/shared/services/review_service.dart';

class RatingDialog extends StatefulWidget {
  final String bookingId;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final VoidCallback? onSubmitted;

  const RatingDialog({
    Key? key,
    required this.bookingId,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      Get.snackbar(
        'error'.tr,
        'please_select_rating'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = ReviewModel(
        bookingId: widget.bookingId,
        patientId: widget.patientId,
        doctorId: widget.doctorId,
        rating: _selectedRating,
        comment: _reviewController.text.trim().isNotEmpty
            ? _reviewController.text.trim()
            : null,
      );

      final success = await reviewService.submitReview(review);

      if (success) {
        Get.back();
        Get.snackbar(
          'success'.tr,
          'review_submitted'.tr,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        widget.onSubmitted?.call();
      } else {
        Get.snackbar(
          'error'.tr,
          'review_submit_failed'.tr,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'an_unexpected_error_occurred'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'rate_your_session'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${'how_was_your_experience_with'.tr} ${widget.doctorName}?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRating = index + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: index < _selectedRating
                          ? Colors.amber
                          : Colors.grey[400],
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _getRatingText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _selectedRating > 0 ? AppColors.color1 : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'write_your_review_optional'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.color1),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Get.back(),
                    child: Text(
                      'skip'.tr,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'submit'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_selectedRating) {
      case 1:
        return 'poor'.tr;
      case 2:
        return 'fair'.tr;
      case 3:
        return 'good'.tr;
      case 4:
        return 'very_good'.tr;
      case 5:
        return 'excellent'.tr;
      default:
        return 'tap_to_rate'.tr;
    }
  }
}

void showRatingDialog({
  required String bookingId,
  required String doctorId,
  required String patientId,
  required String doctorName,
  VoidCallback? onSubmitted,
}) {
  Get.dialog(
    RatingDialog(
      bookingId: bookingId,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      onSubmitted: onSubmitted,
    ),
    barrierDismissible: false,
  );
}
