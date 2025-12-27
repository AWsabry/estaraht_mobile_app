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
      final searchTerm = searchKeyword.value.trim();

      // If not "All" category, filter by category/specialization
      if (index != 0 && category.isNotEmpty) {
        // Trim and normalize category for better matching
        final normalizedCategory = category.trim();
        query = query.ilike('specialization', '%$normalizedCategory%');
      }

      // Apply search keyword if exists - need to combine with category filter properly
      // Since Supabase .or() creates OR conditions, we need to filter results in memory
      // when both filters are active to ensure AND logic
      if (searchTerm.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$searchTerm%,specialization.ilike.%$searchTerm%,email.ilike.%$searchTerm%',
        );
      }

      // Fetch more results than needed to account for in-memory filtering
      final fetchLimit =
          (index != 0 && category.isNotEmpty && searchTerm.isNotEmpty)
          ? itemsPerPage *
                3 // Fetch more if both filters active
          : itemsPerPage;

      final response = await query
          .range(0, fetchLimit - 1)
          .order('full_name', ascending: true);

      print(
        '✅ Found ${response.length} doctors for category "$category"${searchTerm.isNotEmpty ? " and search \"$searchTerm\"" : ""}',
      );

      // Convert Supabase response to SDoctorData and apply in-memory filtering if needed
      List<SDoctorData> filteredDoctors = [];
      for (var doctor in response) {
        final doctorData = SDoctorData.fromJson(doctor);

        // If both category and search filters are active, verify both match (AND logic)
        bool matchesCategory = true;
        bool matchesSearch = true;

        if (index != 0 && category.isNotEmpty) {
          final normalizedCategory = category.trim().toLowerCase();
          final specialization = (doctorData.specialization ?? '')
              .toLowerCase();
          matchesCategory = specialization.contains(normalizedCategory);
        }

        if (searchTerm.isNotEmpty) {
          final normalizedSearch = searchTerm.toLowerCase();
          final fullName = (doctorData.fullName ?? '').toLowerCase();
          final specialization = (doctorData.specialization ?? '')
              .toLowerCase();
          final email = (doctorData.email ?? '').toLowerCase();
          matchesSearch =
              fullName.contains(normalizedSearch) ||
              specialization.contains(normalizedSearch) ||
              email.contains(normalizedSearch);
        }

        // Only add if both filters match (when both are active)
        if (matchesCategory && matchesSearch) {
          filteredDoctors.add(doctorData);

          // Stop if we have enough results
          if (filteredDoctors.length >= itemsPerPage) {
            break;
          }
        }
      }

      newData.value = filteredDoctors;

      // Check if there are more items
      hasMore = filteredDoctors.length >= itemsPerPage;

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

      var query = supabaseHelper.client.from('doctors').select();
      final term = searchKeyword.value.trim();

      // Apply category filter if not "All"
      if (selectedCategoryIndex.value != 0 &&
          selectedCategory.value.isNotEmpty) {
        final normalizedCategory = selectedCategory.value.trim();
        query = query.ilike('specialization', '%$normalizedCategory%');
      }

      // Apply search keyword if exists
      if (term.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$term%,specialization.ilike.%$term%,email.ilike.%$term%',
        );
      }

      // Fetch more results if both filters active
      final fetchLimit =
          (selectedCategoryIndex.value != 0 &&
              selectedCategory.value.isNotEmpty &&
              term.isNotEmpty)
          ? itemsPerPage * 3
          : itemsPerPage;
      final fetchEnd = startRange + fetchLimit - 1;

      final response = await query
          .range(startRange, fetchEnd)
          .order('full_name', ascending: true);

      print('✅ Loaded ${response.length} more doctors (page $currentPage)');

      // Convert and filter results in memory if both filters active
      List<SDoctorData> filteredDoctors = [];
      for (var doctor in response) {
        final doctorData = SDoctorData.fromJson(doctor);

        // If both category and search filters are active, verify both match
        bool matchesCategory = true;
        bool matchesSearch = true;

        if (selectedCategoryIndex.value != 0 &&
            selectedCategory.value.isNotEmpty) {
          final normalizedCategory = selectedCategory.value
              .trim()
              .toLowerCase();
          final specialization = (doctorData.specialization ?? '')
              .toLowerCase();
          matchesCategory = specialization.contains(normalizedCategory);
        }

        if (term.isNotEmpty) {
          final normalizedSearch = term.toLowerCase();
          final fullName = (doctorData.fullName ?? '').toLowerCase();
          final specialization = (doctorData.specialization ?? '')
              .toLowerCase();
          final email = (doctorData.email ?? '').toLowerCase();
          matchesSearch =
              fullName.contains(normalizedSearch) ||
              specialization.contains(normalizedSearch) ||
              email.contains(normalizedSearch);
        }

        if (matchesCategory && matchesSearch) {
          filteredDoctors.add(doctorData);
        }
      }

      // Add filtered results to list
      newData.addAll(filteredDoctors);

      // Check if there are more items
      hasMore = filteredDoctors.length >= itemsPerPage;

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
