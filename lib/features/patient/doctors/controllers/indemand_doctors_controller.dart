import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/doctors/models/sdoctor_model.dart';

class IndemandDoctorController extends GetxController {
  // Search keyword (for display/reference)
  String keyword = Get.arguments?['keyword'] ?? '';

  // State
  RxBool isLoading = false.obs;
  RxBool isErrorInLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  // Data
  RxList<SDoctorData> doctors = <SDoctorData>[].obs;

  // Paging & search
  final ScrollController scrollController = ScrollController();
  RxString searchKeyword = ''.obs;
  int currentPage = 0;
  final int itemsPerPage = 20;
  bool hasMore = true;

  // Fetch all doctors (initial load or when clearing search)
  Future<void> fetchAll({bool reset = true}) async {
    try {
      if (reset) {
        isLoading.value = true;
        isErrorInLoading.value = false;
        currentPage = 0;
        hasMore = true;
        doctors.clear();
      }

      final start = currentPage * itemsPerPage;
      final end = start + itemsPerPage - 1;

      final response = await supabaseHelper.client
          .from('doctors')
          .select()
          .order('full_name', ascending: true)
          .range(start, end);

      // Append results
      for (final d in response) {
        doctors.add(SDoctorData.fromJson(d));
      }

      hasMore = response.length >= itemsPerPage;
    } catch (e, st) {
      print('❌ Error fetching doctors: $e');
      print(st);
      if (reset) isErrorInLoading.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Search doctors by keyword
  Future<void> search(String term, {bool reset = true}) async {
    searchKeyword.value = term;

    // If empty -> load all
    if (term.trim().isEmpty) {
      await fetchAll(reset: reset);
      return;
    }

    try {
      if (reset) {
        isLoading.value = true;
        isErrorInLoading.value = false;
        currentPage = 0;
        hasMore = true;
        doctors.clear();
      }

      final start = currentPage * itemsPerPage;
      final end = start + itemsPerPage - 1;

      final response = await supabaseHelper.client
          .from('doctors')
          .select()
          .or('full_name.ilike.%$term%,specialization.ilike.%$term%,email.ilike.%$term%')
          .order('full_name', ascending: true)
          .range(start, end);

      for (final d in response) {
        doctors.add(SDoctorData.fromJson(d));
      }

      hasMore = response.length >= itemsPerPage;
    } catch (e, st) {
      print('❌ Error searching doctors: $e');
      print(st);
      if (reset) isErrorInLoading.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Load more (either for search or all)
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      currentPage++;
      final term = searchKeyword.value.trim();
      if (term.isEmpty) {
        await fetchAll(reset: false);
      } else {
        await search(term, reset: false);
      }
    } catch (e) {
      // ignore
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initial load: all doctors
    searchKeyword.value = keyword;
    if (keyword.isNotEmpty) {
      search(keyword);
    } else {
      fetchAll();
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
  }

  @override
  void onClose() {
    // Ensure no focus glitches
    Get.focusScope?.unfocus();
    scrollController.dispose();
    super.onClose();
  }
}

