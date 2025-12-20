import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/features/doctor/profile/models/review_model.dart';
import 'package:videocalling/features/patient/doctors/models/doctor_detail_model.dart';

class DoctorProfileViewController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isErrorInLoading = false.obs;
  RxBool isLoadingReviews = true.obs;
  RxBool isErrorInLoadingReviews = false.obs;
  DoctorDetailsClass? doctorDetailsClass;
  String doctorId = "";
  RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  RxDouble averageRating = 0.0.obs;
  RxInt totalReviews = 0.obs;

  FirebaseHelper firebaseHelper = FirebaseHelper();
  SupabaseHelper supabaseHelper = SupabaseHelper();

  @override
  void onInit() {
    super.onInit();
    // Get the logged-in doctor ID
    StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    doctorId = firebaseHelper.currentUser!.uid;
    loggerNoStack.t('Doctor ID: $doctorId');
    fetchDoctorDetails();
    fetchReviews();
  }

  Future<void> fetchDoctorDetails() async {
    isLoading.value = true;
    isErrorInLoading.value = false;
    try {
      final response = await supabaseHelper.client
          .from('doctors')
          .select()
          .eq('doctor_id', doctorId)
          .single();

      final jsonResponse = response;
      doctorDetailsClass = DoctorDetailsClass(
        success: 'true',
        register: null,
        data: DoctorDData(
          name: (jsonResponse['full_name'] ?? '').toString(),
          email: (jsonResponse['email'] ?? '').toString(),
          phoneno: jsonResponse['phone_number']?.toString(),
          age: jsonResponse['age']?.toString(),
          gender: jsonResponse['gender']?.toString(),
          aboutus: (jsonResponse['bio'] ?? '').toString(),
          image: (jsonResponse['profile_img_url'] ?? '').toString(),
          departmentName: (jsonResponse['specialization'] ?? '').toString(),
          yearsOfExp: jsonResponse['years_of_exp'] is int
              ? jsonResponse['years_of_exp']
              : int.tryParse(jsonResponse['years_of_exp']?.toString() ?? '0'),
          numbPatients: jsonResponse['numb_patients'] is int
              ? jsonResponse['numb_patients']
              : int.tryParse(jsonResponse['numb_patients']?.toString() ?? '0'),
          consultationFee: jsonResponse['booking_price']?.toString(),
          totalReview: jsonResponse['number_review'] is int
              ? jsonResponse['number_review']
              : int.tryParse(jsonResponse['number_review']?.toString() ?? '0'),
          specializations:
              (jsonResponse['specialization'] != null &&
                  jsonResponse['specialization'].toString().isNotEmpty)
              ? [Speciality(name: jsonResponse['specialization'].toString())]
              : null,
        ),
      );
      loggerNoStack.i('Doctor details fetched successfully');
      loggerNoStack.i('Name: ${doctorDetailsClass?.data?.name}');
      loggerNoStack.i('Email: ${doctorDetailsClass?.data?.email}');
      loggerNoStack.i('Phone: ${doctorDetailsClass?.data?.phoneno}');
      loggerNoStack.i('Age: ${doctorDetailsClass?.data?.age}');
      loggerNoStack.i('Gender: ${doctorDetailsClass?.data?.gender}');
      loggerNoStack.i('Bio: ${doctorDetailsClass?.data?.aboutus}');
      loggerNoStack.i('Profile Image: ${doctorDetailsClass?.data?.image}');
      loggerNoStack.i(
        'Specialization: ${doctorDetailsClass?.data?.departmentName}',
      );
      loggerNoStack.i(
        'Years of Experience: ${doctorDetailsClass?.data?.yearsOfExp}',
      );
      loggerNoStack.i(
        'Number of Patients: ${doctorDetailsClass?.data?.numbPatients}',
      );
      loggerNoStack.i(
        'Consultation Fee: ${doctorDetailsClass?.data?.consultationFee}',
      );

      isLoading.value = false;
    } catch (e) {
      isErrorInLoading.value = true;
      loggerNoStack.e("Exception fetching doctor details: $e");
    }
  }

  Future<void> fetchReviews() async {
    isLoadingReviews.value = true;
    isErrorInLoadingReviews.value = false;
    try {
      loggerNoStack.i('Fetching reviews for doctor: $doctorId');

      final response = await supabaseHelper.client
          .from('reviews')
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      final List<dynamic> reviewsJson = response as List<dynamic>;
      reviews.clear();

      for (var reviewJson in reviewsJson) {
        final reviewData = reviewJson as Map<String, dynamic>;

        // Fetch patient details for each review
        try {
          final patientResponse = await supabaseHelper.client
              .from('patients')
              .select('full_name, profile_img_url')
              .eq('patient_id', reviewData['patient_id'])
              .maybeSingle();

          if (patientResponse != null) {
            reviewData['patient_name'] = patientResponse['full_name'];
            reviewData['patient_image'] = patientResponse['profile_img_url'];
          }
        } catch (e) {
          loggerNoStack.w('Could not fetch patient details: $e');
        }

        reviews.add(ReviewModel.fromJson(reviewData));
      }

      // Calculate average rating
      if (reviews.isNotEmpty) {
        double sum = 0;
        for (var review in reviews) {
          sum += review.ratingValue;
        }
        averageRating.value = sum / reviews.length;
        totalReviews.value = reviews.length;
      }

      loggerNoStack.i(
        'Reviews fetched successfully: ${reviews.length} reviews',
      );
      loggerNoStack.i('Average rating: ${averageRating.value}');
      isLoadingReviews.value = false;
    } catch (e) {
      isErrorInLoadingReviews.value = true;
      loggerNoStack.e("Exception fetching reviews: $e");
      isLoadingReviews.value = false;
    }
  }

  void editProfile() {
    // Navigate to edit profile screen
    Get.toNamed(Routes.editProfileScreen);
  }
}
