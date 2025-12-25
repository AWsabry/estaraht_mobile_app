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

  // Category selection
  int selectedCategoryIndex = 0;
  String selectedCategory = "";
  RxList<Map<String, String>> categories = <Map<String, String>>[].obs;
  RxBool isCategoriesLoading = false.obs;

  /// Fetch categories from Supabase specializations table
  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;

      print('📋 Fetching categories from Supabase...');

      final response = await supabaseHelper.client
          .from('specializations')
          .select('name')
          .order('name', ascending: true);

      print('✅ Fetched ${response.length} categories from Supabase');

      // Clear existing categories
      categories.clear();

      // Add "All" category first
      categories.add({'name_en': 'All', 'name_ar': 'الجميع', 'value': ''});

      // Add categories from database
      for (var spec in response) {
        final name = spec['name'] ?? '';
        categories.add({
          'name_en': name,
          'name_ar': name,
          'value': name,
        });
      }

      print('✅ Total categories loaded: ${categories.length}');
      isCategoriesLoading.value = false;
    } catch (e, stackTrace) {
      print('❌ Error fetching categories: $e');
      print('Stack trace: $stackTrace');
      isCategoriesLoading.value = false;

      // Fallback to default categories if fetch fails
      categories.value = [
        {'name_en': 'All', 'name_ar': 'الجميع', 'value': ''},
        {
          'name_en': 'Relationships',
          'name_ar': 'العلاقات',
          'value': 'Relationships',
        },
        {'name_en': 'Addiction', 'name_ar': 'الإدمان', 'value': 'Addiction'},
        {
          'name_en': 'Family therapy',
          'name_ar': 'العلاج النفسي',
          'value': 'Family therapy',
        },
        {'name_en': 'ADHD', 'name_ar': 'التوتر وفرط الحركة', 'value': 'ADHD'},
      ];
    }
  }

  /// Handle category selection
  void onCategorySelected(int index, String category) async {
    selectedCategoryIndex = index;
    selectedCategory = category;

    // Reset pagination and state
    currentPage = 0;
    hasMore = true;
    isLoading.value = true;
    isErrorInLoading.value = false;
    doctors.clear();

    try {
      var query = supabaseHelper.client.from('doctors').select();

      // If not "All" category, filter by category/specialization
      if (index != 0 && category.isNotEmpty) {
        query = query.or(
          'specialization.ilike.%$category%,department_name.ilike.%$category%',
        );
      }

      // Apply search keyword if exists
      if (searchKeyword.value.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%${searchKeyword.value}%,specialization.ilike.%${searchKeyword.value}%,email.ilike.%${searchKeyword.value}%',
        );
      }

      final response = await query
          .range(0, itemsPerPage - 1)
          .order('full_name', ascending: true);

      print('✅ Found ${response.length} doctors for category "$category"');

      // Convert Supabase response to SDoctorData
      for (var doctor in response) {
        doctors.add(SDoctorData.fromJson(doctor));
      }

      // Check if there are more items
      hasMore = response.length >= itemsPerPage;

      isLoading.value = false;
    } catch (e, stackTrace) {
      print('❌ Error filtering doctors by category: $e');
      print('Stack trace: $stackTrace');
      isLoading.value = false;
      isErrorInLoading.value = true;
    }
    update();
  }

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
      final startRange = currentPage * itemsPerPage;
      final endRange = startRange + itemsPerPage - 1;

      var query = supabaseHelper.client.from('doctors').select();

      // Apply category filter if not "All"
      if (selectedCategoryIndex != 0 && selectedCategory.isNotEmpty) {
        query = query.or(
          'specialization.ilike.%$selectedCategory%,department_name.ilike.%$selectedCategory%',
        );
      }

      // Apply search keyword if exists
      final term = searchKeyword.value.trim();
      if (term.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$term%,specialization.ilike.%$term%,email.ilike.%$term%',
        );
      }

      final response = await query
          .range(startRange, endRange)
          .order('full_name', ascending: true);

      print('✅ Loaded ${response.length} more doctors (page $currentPage)');

      // Convert and add to list
      for (var doctor in response) {
        doctors.add(SDoctorData.fromJson(doctor));
      }

      // Check if there are more items
      hasMore = response.length >= itemsPerPage;
    } catch (e) {
      print('❌ Error loading more doctors: $e');
      currentPage--; // Revert page increment on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Fetch categories from Supabase first
    fetchCategories();

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

