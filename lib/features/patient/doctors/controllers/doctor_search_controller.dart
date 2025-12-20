import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/doctors/models/sdoctor_model.dart';
class DoctorSearchController extends GetxController {
  String keyword = Get.arguments?['keyword'] ?? '';
  String? initialCategory = Get.arguments?['category'];
  int? initialCategoryIndex = Get.arguments?['categoryIndex'];

  RxBool isSearching = false.obs;
  RxBool isLoading = false.obs;
  RxBool isErrorInLoading = false.obs;
  SearchDoctorClass? searchDoctorClass;
  RxList<SDoctorData> newData = <SDoctorData>[].obs;
  RxString nextUrl = "".obs;
  RxBool isLoadingMore = false.obs;
  RxString searchKeyword = "".obs;
  ScrollController scrollController = ScrollController();
  SpecialityClass? specialityClass;
  RxList<String> departmentList = <String>[].obs;

  // Category selection
  RxInt selectedCategoryIndex = 0.obs;
  RxString selectedCategory = "".obs;
  RxList<Map<String, String>> categories = <Map<String, String>>[].obs;
  RxBool isCategoriesLoading = false.obs;

  // Pagination
  int currentPage = 0;
  int itemsPerPage = 20;
  bool hasMore = true;

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
          'name_ar':
              name, // Same name for all languages since DB only has one name
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

  onCategorySelected(int index, String category) async {
    selectedCategoryIndex.value = index;
    selectedCategory.value = category;

    // Reset pagination
    currentPage = 0;
    hasMore = true;
    isLoading.value = true;
    isErrorInLoading.value = false;

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

      newData.clear();

      // Convert Supabase response to SDoctorData
      for (var doctor in response) {
        print('🔍 Doctor data from Supabase: $doctor');
        final doctorData = SDoctorData.fromJson(doctor);
        print('🆔 Doctor ID after parsing: ${doctorData.id}');
        newData.add(doctorData);
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
  }

  onChanged(String value) async {
    if (value.isEmpty) {
      newData.clear();
      isErrorInLoading.value = false;
      isSearching.value = false;
      hasMore = true;
      currentPage = 0;
    } else {
      isLoading.value = true;
      isSearching.value = true;
      isErrorInLoading.value = false;
      currentPage = 0;
      hasMore = true;

      try {
        // Search doctors from Supabase
        final response = await supabaseHelper.client
            .from('doctors')
            .select()
            .or(
              'full_name.ilike.%$value%,specialization.ilike.%$value%,email.ilike.%$value%',
            )
            .range(0, itemsPerPage - 1)
            .order('full_name', ascending: true);

        print('✅ Found ${response.length} doctors matching "$value"');

        newData.clear();

        // Convert Supabase response to SDoctorData
        for (var doctor in response) {
          newData.add(SDoctorData.fromJson(doctor));
        }

        // Check if there are more items
        hasMore = response.length >= itemsPerPage;

        isLoading.value = false;
      } catch (e, stackTrace) {
        print('❌ Error searching doctors: $e');
        print('Stack trace: $stackTrace');
        isLoading.value = false;
        isErrorInLoading.value = true;
      }
    }
  }

  _loadMoreFunc() async {
    if (!hasMore || isLoadingMore.value) {
      return;
    }

    isLoadingMore.value = true;
    currentPage++;

    try {
      final startRange = currentPage * itemsPerPage;
      final endRange = startRange + itemsPerPage - 1;

      var query = supabaseHelper.client.from('doctors').select();

      // Apply category filter if not "All"
      if (selectedCategoryIndex.value != 0 &&
          selectedCategory.value.isNotEmpty) {
        query = query.or(
          'specialization.ilike.%${selectedCategory.value}%,department_name.ilike.%${selectedCategory.value}%',
        );
      }

      // Apply search keyword if exists
      if (searchKeyword.value.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%${searchKeyword.value}%,specialization.ilike.%${searchKeyword.value}%,email.ilike.%${searchKeyword.value}%',
        );
      }

      final response = await query
          .range(startRange, endRange)
          .order('full_name', ascending: true);

      print('✅ Loaded ${response.length} more doctors (page $currentPage)');

      // Convert and add to list
      for (var doctor in response) {
        newData.add(SDoctorData.fromJson(doctor));
      }

      // Check if there are more items
      hasMore = response.length >= itemsPerPage;

      isLoadingMore.value = false;
    } catch (e) {
      print('❌ Error loading more doctors: $e');
      isLoadingMore.value = false;
      currentPage--; // Revert page increment on error
    }
  }

  onSubmit(String value) async {
    if (value.isEmpty) {
      newData.clear();
      isSearching.value = false;
      hasMore = true;
      currentPage = 0;
    } else {
      isLoading.value = true;
      isSearching.value = true;
      isErrorInLoading.value = false;
      currentPage = 0;
      hasMore = true;
      searchKeyword.value = value;

      try {
        // Search doctors from Supabase
        final response = await supabaseHelper.client
            .from('doctors')
            .select()
            .or(
              'full_name.ilike.%$value%,specialization.ilike.%$value%,email.ilike.%$value%',
            )
            .range(0, itemsPerPage - 1)
            .order('full_name', ascending: true);

        print('✅ Found ${response.length} doctors matching "$value"');

        newData.clear();

        // Convert Supabase response to SDoctorData
        for (var doctor in response) {
          newData.add(SDoctorData.fromJson(doctor));
        }

        // Check if there are more items
        hasMore = response.length >= itemsPerPage;

        isLoading.value = false;
      } catch (e, stackTrace) {
        print('❌ Error searching doctors: $e');
        print('Stack trace: $stackTrace');
        isLoading.value = false;
        isErrorInLoading.value = true;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Fetch categories from Supabase first
    fetchCategories();

    // Set initial category if provided
    if (initialCategory != null || initialCategoryIndex != null) {
      selectedCategoryIndex.value = initialCategoryIndex ?? 0;
      selectedCategory.value = initialCategory ?? '';
      // Call onCategorySelected to load data with the initial category
      onCategorySelected(selectedCategoryIndex.value, selectedCategory.value);
    } else {
      // Default behavior - load with keyword if provided
      onChanged(keyword);
      searchKeyword.value = keyword;
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        _loadMoreFunc();
      }
    });
  }

  @override
  void onClose() {
    // Unfocus to avoid callbacks firing on disposed widgets
    Get.focusScope?.unfocus();
    // Dispose scroll controller only; keep textController alive to prevent post-dispose callbacks during transitions
    scrollController.dispose();
    // Do NOT dispose textController here to avoid 'used after disposed' when TextField rebuilds during transition
    super.onClose();
  }
}
