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
      final fetchLimit = (index != 0 && category.isNotEmpty && searchTerm.isNotEmpty) 
          ? itemsPerPage * 3  // Fetch more if both filters active
          : itemsPerPage;

      final response = await query
          .range(0, fetchLimit - 1)
          .order('full_name', ascending: true);

      print('✅ Found ${response.length} doctors for category "$category"${searchTerm.isNotEmpty ? " and search \"$searchTerm\"" : ""}');

      // Convert Supabase response to SDoctorData and apply in-memory filtering if needed
      List<SDoctorData> filteredDoctors = [];
      for (var doctor in response) {
        final doctorData = SDoctorData.fromJson(doctor);
        
        // If both category and search filters are active, verify both match (AND logic)
        bool matchesCategory = true;
        bool matchesSearch = true;
        
        if (index != 0 && category.isNotEmpty) {
          final normalizedCategory = category.trim().toLowerCase();
          final specialization = (doctorData.specialization ?? '').toLowerCase();
          matchesCategory = specialization.contains(normalizedCategory);
        }
        
        if (searchTerm.isNotEmpty) {
          final normalizedSearch = searchTerm.toLowerCase();
          final fullName = (doctorData.fullName ?? '').toLowerCase();
          final specialization = (doctorData.specialization ?? '').toLowerCase();
          final email = (doctorData.email ?? '').toLowerCase();
          matchesSearch = fullName.contains(normalizedSearch) || 
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

      doctors.value = filteredDoctors;

      // Check if there are more items
      hasMore = filteredDoctors.length >= itemsPerPage;

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

      var query = supabaseHelper.client.from('doctors').select();
      final term = searchKeyword.value.trim();

      // Apply category filter if not "All"
      if (selectedCategoryIndex != 0 && selectedCategory.isNotEmpty) {
        final normalizedCategory = selectedCategory.trim();
        query = query.ilike('specialization', '%$normalizedCategory%');
      }

      // Apply search keyword if exists
      if (term.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$term%,specialization.ilike.%$term%,email.ilike.%$term%',
        );
      }

      // Fetch more results if both filters active
      final fetchLimit = (selectedCategoryIndex != 0 && selectedCategory.isNotEmpty && term.isNotEmpty) 
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
        
        if (selectedCategoryIndex != 0 && selectedCategory.isNotEmpty) {
          final normalizedCategory = selectedCategory.trim().toLowerCase();
          final specialization = (doctorData.specialization ?? '').toLowerCase();
          matchesCategory = specialization.contains(normalizedCategory);
        }
        
        if (term.isNotEmpty) {
          final normalizedSearch = term.toLowerCase();
          final fullName = (doctorData.fullName ?? '').toLowerCase();
          final specialization = (doctorData.specialization ?? '').toLowerCase();
          final email = (doctorData.email ?? '').toLowerCase();
          matchesSearch = fullName.contains(normalizedSearch) || 
                         specialization.contains(normalizedSearch) || 
                         email.contains(normalizedSearch);
        }
        
        if (matchesCategory && matchesSearch) {
          filteredDoctors.add(doctorData);
        }
      }

      // Add filtered results to list
      doctors.addAll(filteredDoctors);

      // Check if there are more items
      hasMore = filteredDoctors.length >= itemsPerPage;
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

