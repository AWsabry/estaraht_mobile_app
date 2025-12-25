import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/doctors/models/sdoctor_model.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  late final DoctorSearchController controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DoctorSearchController>();
    _textController = TextEditingController(text: controller.keyword);
  }

  @override
  void dispose() {
    // Ensure focus is released to prevent callbacks hitting a disposed controller
    FocusManager.instance.primaryFocus?.unfocus();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchHeader(context, isArabic),
          _buildFilterChips(isArabic),

          // Main content area - GetX listens to controller observables
          Expanded(
            child: GetX<DoctorSearchController>(
              builder: (ctrl) {
                if (ctrl.isErrorInLoading.value) {
                  return _buildErrorState();
                } else if (ctrl.isLoading.value) {
                  return _buildLoadingState();
                } else {
                  return _buildSearchResults();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, bool isArabic) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 24, 34, 24),
        child: Column(
          children: [
            // Top row with profile icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Profile Icons
                Row(
                  children: [
                    SvgPicture.asset(
                      AppImages.appAccountCircle,
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SvgPicture.asset(
                        AppImages.appBadging,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),

                // Right side - Logo/icon
                SvgPicture.asset(AppImages.appBarIcon, width: 38),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),

            // Search field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.search,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  // hintText: isArabic ? 'البحث عن طبيب' : 'Find a therapist',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: isArabic
                      ? null
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(Icons.search, color: Colors.grey[700]),
                        ),
                  suffixIcon: isArabic
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(Icons.search, color: Colors.grey[700]),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 48,
                    minWidth: 48,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minHeight: 48,
                    minWidth: 48,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  controller.searchKeyword.value = val;
                  controller.onSubmit(val);
                },
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isArabic) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 16),
      child: Obx(() {
        // Show loading indicator while fetching categories
        if (controller.isCategoriesLoading.value) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3961F1)),
              ),
            ),
          );
        }

        // Show categories list
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 34),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final displayName = isArabic
                ? (category['name_ar'] ?? category['name_en'] ?? '')
                : (category['name_en'] ?? '');
            final categoryValue = category['value'] ?? '';

            return Obx(() {
              final isSelected =
                  controller.selectedCategoryIndex.value == index;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  selected: isSelected,
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF3961F1),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      controller.onCategorySelected(index, categoryValue);
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3961F1)),
          ),
          const SizedBox(height: 16),
          Text(
            'loading'.tr,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'unable_to_load_data'.tr,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              controller.onChanged(controller.searchKeyword.value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3961F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('try_again'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Use GetBuilder for lists to prevent rebuilds
    return GetBuilder<DoctorSearchController>(
      builder: (controller) {
        // Show suggestions if no results
        if (controller.newData.isEmpty && !controller.isLoading.value) {
          return _buildSearchSuggestions();
        }

        // Show results if we have data
        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              controller.newData.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom when loading more
            if (index == controller.newData.length &&
                controller.isLoadingMore.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF3961F1),
                    ),
                  ),
                ),
              );
            }

            // Regular doctor card
            return _buildDoctorCard(controller.newData[index]);
          },
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent searches
            Text(
              isArabic ? 'البحث الأخير' : 'Latest search',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildSuggestionChip(
                  isArabic ? 'العلاقات' : 'Relationships',
                  Icons.history,
                ),
                _buildSuggestionChip(
                  isArabic ? 'التوتر وفرط الحركة' : 'ADHD',
                  Icons.history,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Popular searches
            Text(
              isArabic ? 'البحث الشائع' : 'Popular search',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildSuggestionChip(
                  isArabic ? 'العلاقات' : 'Relationships',
                  Icons.arrow_forward,
                  isPopular: true,
                ),
                _buildSuggestionChip(
                  isArabic ? 'التوتر وفرط الحركة' : 'ADHD',
                  Icons.arrow_forward,
                  isPopular: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    String label,
    IconData icon, {
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ActionChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 16,
              color: isPopular ? const Color(0xFF3961F1) : Colors.grey,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onPressed: () {
          _textController.text = label;
          controller.onSubmit(label);
        },
      ),
    );
  }

  Widget _buildDoctorCard(SDoctorData doctor) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await Get.toNamed(
            Routes.doctorDetailScreen,
            arguments: {'id': "${doctor.id}"},
          );
          Get.delete<DoctorDetailController>();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session & Fee info
            Row(
              mainAxisAlignment: isArabic
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                // 500+ Sessions
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '+500 ${isArabic ? 'جلسة' : 'Sessions'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.video_call,
                        size: 14,
                        color: Color(0xFF3961F1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // $50 Fee
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '50 ${isArabic ? 'أوقية' : 'MRU'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.attach_money,
                        size: 14,
                        color: Color(0xFF3961F1),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Doctor info
            Row(
              children: [
                // Doctor image
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    imageUrl: doctor.image ?? "",
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      AppImages.getDoctorPlaceholder(doctor.gender),
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, err) => Image.asset(
                      AppImages.getDoctorPlaceholder(doctor.gender),
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Doctor details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.departmentName ?? "",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Specializations
            Text(
              isArabic ? 'التخصصات' : 'Specializations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),

            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Static chips for now
                _SpecChip(label: 'ADHD'),
                _SpecChip(label: 'Relationships'),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Book now button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        Routes.doctorDetailScreen,
                        arguments: {'id': "${doctor.id}"},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3961F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isArabic ? 'إحجز الآن' : 'Book now',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Profile button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(
                        Routes.doctorDetailScreen,
                        arguments: {'id': "${doctor.id}"},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isArabic ? 'الصفحة الشخصية' : 'Profile',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSpecializationChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  const _SpecChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
      ),
    );
  }
}
