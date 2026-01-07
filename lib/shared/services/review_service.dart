import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/shared/models/review_model.dart';
import 'package:videocalling/shared/services/auth/supabase_helper.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final SupabaseHelper _supabaseHelper = SupabaseHelper();

  Future<bool> submitReview(ReviewModel review) async {
    try {
      await _supabaseHelper.client
          .from('reviews')
          .insert(review.toInsertJson());

      loggerNoStack.i(
        'Review submitted successfully for booking: ${review.bookingId}',
      );
      return true;
    } catch (e) {
      loggerNoStack.e('Error submitting review: $e');
      return false;
    }
  }

  Future<List<ReviewModel>> getReviewsForDoctor(String doctorId) async {
    try {
      final response = await _supabaseHelper.client
          .from('reviews')
          .select('*')
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      if ((response as List).isEmpty) {
        return [];
      }

      List<ReviewModel> reviewsList = [];

      for (var json in response) {
        String? patientName;
        String? patientImage;

        try {
          final patientId = json['patient_id']?.toString();
          if (patientId != null && patientId.isNotEmpty) {
            final patientData = await _supabaseHelper.client
                .from('patients')
                .select('name, profile_img_url')
                .eq('id', patientId)
                .maybeSingle();

            if (patientData != null) {
              patientName = patientData['name'];
              patientImage = patientData['profile_img_url'];
            }
          }
        } catch (patientError) {
          loggerNoStack.w('Could not fetch patient data: $patientError');
        }

        reviewsList.add(
          ReviewModel.fromJson({
            ...json,
            'patient_name': patientName,
            'patient_image': patientImage,
          }),
        );
      }

      return reviewsList;
    } catch (e) {
      loggerNoStack.e('Error fetching reviews for doctor: $e');
      return [];
    }
  }

  Future<ReviewModel?> getReviewForBooking(String bookingId) async {
    try {
      final response = await _supabaseHelper.client
          .from('reviews')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) return null;
      return ReviewModel.fromJson(response);
    } catch (e) {
      loggerNoStack.e('Error fetching review for booking: $e');
      return null;
    }
  }

  Future<bool> hasReviewedBooking(String bookingId) async {
    try {
      final response = await _supabaseHelper.client
          .from('reviews')
          .select('id')
          .eq('booking_id', bookingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      loggerNoStack.e('Error checking review status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getDoctorRating(String doctorId) async {
    try {
      final response = await _supabaseHelper.client
          .from('doctors')
          .select('average_rating, total_reviews')
          .eq('doctor_id', doctorId)
          .single();

      return {
        'average_rating':
            double.tryParse(response['average_rating']?.toString() ?? '0') ??
            0.0,
        'total_reviews':
            int.tryParse(response['total_reviews']?.toString() ?? '0') ?? 0,
      };
    } catch (e) {
      loggerNoStack.e('Error fetching doctor rating: $e');
      return {'average_rating': 0.0, 'total_reviews': 0};
    }
  }

  Future<bool> updateReview(
    String reviewId,
    int rating,
    String? comment,
  ) async {
    try {
      await _supabaseHelper.client
          .from('reviews')
          .update({'rating': rating, 'comment': comment})
          .eq('id', reviewId);

      return true;
    } catch (e) {
      loggerNoStack.e('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _supabaseHelper.client.from('reviews').delete().eq('id', reviewId);

      return true;
    } catch (e) {
      loggerNoStack.e('Error deleting review: $e');
      return false;
    }
  }
}

final reviewService = ReviewService();
