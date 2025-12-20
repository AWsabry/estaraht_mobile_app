import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/doctors/models/sdoctor_model.dart';

class IndemandDoctorScreen extends StatefulWidget {
  const IndemandDoctorScreen({super.key});

  @override
  State<IndemandDoctorScreen> createState() => _IndemandDoctorScreenState();
}

class _IndemandDoctorScreenState extends State<IndemandDoctorScreen> {
  late final IndemandDoctorController controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<IndemandDoctorController>();
    _textController = TextEditingController(text: controller.keyword);
  }

  @override
  void dispose() {
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
          _buildHeader(context, isArabic),

          // Content
          Expanded(
            child: GetX<IndemandDoctorController>(
              builder: (ctrl) {
                if (ctrl.isErrorInLoading.value) {
                  return _buildErrorState();
                }
                if (ctrl.isLoading.value && ctrl.doctors.isEmpty) {
                  return _buildLoadingState();
                }
                return _buildDoctorList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isArabic) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 24, 34, 12),
        child: Column(
          children: [
            // Top row with logo (matching dsearch layout style)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                SvgPicture.asset(AppImages.appBarIcon, width: 38),
              ],
            ),
            const SizedBox(height: 16),

            // Search input
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
                  hintText: 'find_a_therapist'.tr,
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
                  controller.search(val);
                },
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),

            // Subheading label: Most in-demand doctors
            const SizedBox(height: 20),
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                'most_in_demand_doctors'
                    .tr, // add this key in your translations
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF424242), // equivalent to Colors.grey[800]
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.0, // 100% line height
                  letterSpacing: 0.0,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3961F1)),
      ),
    );
  }

  // Error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'unable_to_load_data'.tr,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchAll(reset: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3961F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('try_again'.tr),
          ),
        ],
      ),
    );
  }

  // Doctor list
  Widget _buildDoctorList() {
    return GetBuilder<IndemandDoctorController>(
      builder: (ctrl) {
        return ListView.builder(
          controller: ctrl.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.doctors.length + (ctrl.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == ctrl.doctors.length && ctrl.isLoadingMore.value) {
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

            final doctor = ctrl.doctors[index];
            return _buildDoctorCard(doctor);
          },
        );
      },
    );
  }

  // Reuse the same doctor card widget design as the search screen
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
            arguments: {'id': "${doctor.doctorId}"},
          );
          Get.delete<DoctorDetailController>();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top pills (sessions/fee)
            Row(
              mainAxisAlignment: isArabic
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
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

            // Info row
            Row(
              children: [
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

            // Specializations header (reused)
            Text(
              isArabic ? 'التخصصات' : 'Specializations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SpecChip(label: doctor.specialization ?? "N/A"),
                _SpecChip(label: doctor.specialization ?? "N/A"),
              ],
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        Routes.makeAppointmentScreen,
                        arguments: {
                          'id': "${doctor.doctorId}",
                          'name': doctor.name ?? "",
                          'image': doctor.image ?? "",
                          'consultationFee': "${doctor.bookingPrice ?? 0}",
                        },
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
                      'book_now'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(
                        Routes.doctorDetailScreen,
                        arguments: {'id': "${doctor.doctorId}"},
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
