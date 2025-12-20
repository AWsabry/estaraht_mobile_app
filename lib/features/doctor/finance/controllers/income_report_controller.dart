import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/features/doctor/finance/models/income_report_model.dart';

class IncomeReportController extends GetxController {
  final supabaseHelper = SupabaseHelper();
  RxString doctorId = "".obs;
  RxBool st = false.obs;
  RxString showOption =
      'income_report_tile_short_text3'.tr.obs; // Default to "last 30 days" text
  final String initialDuration;
  RxString selectedFilter = 'income'.obs; // 'income', 'withdrawal', 'total'

  IncomeReportController({this.initialDuration = "today"});

  getIncomeReport(String duration) async {
    st.value = false;

    try {
      // Calculate date range based on duration
      DateTime startDate;
      DateTime endDate = DateTime.now();

      if (duration == "today") {
        startDate = DateTime(endDate.year, endDate.month, endDate.day);
      } else if (duration == "last 7 days") {
        startDate = endDate.subtract(const Duration(days: 7));
      } else if (duration == "last 30 days") {
        startDate = endDate.subtract(const Duration(days: 30));
      } else if (duration.contains(',')) {
        // Custom date range format: "YYYY-MM-DD,YYYY-MM-DD"
        List<String> dates = duration.split(',');
        startDate = DateTime.parse(dates[0]);
        endDate = DateTime.parse(dates[1]);
      } else {
        startDate = endDate.subtract(const Duration(days: 30));
      }

      // Build query based on selected filter
      var query = supabaseHelper.client
          .from('payment_history')
          .select('total_amount, payment_date, action_type, operation_status')
          .eq('doctor_id', doctorId.value)
          .eq('operation_status', 'success')
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String());

      // Apply filter based on selected type
      if (selectedFilter.value == 'income') {
        query = query.eq('action_type', 'income');
      } else if (selectedFilter.value == 'withdrawal') {
        query = query.eq('action_type', 'withrowl');
      }
      // For 'total', don't filter by action_type

      final response = await query.order('payment_date', ascending: false);

      // Transform Supabase data to match existing model
      List<IncomeRecord> incomeRecords = [];
      double totalIncome = 0;

      // Group records by date and sum amounts
      Map<String, double> dailyIncome = {};

      for (var record in response) {
        // Extract date from timestamp
        String dateStr = record['payment_date'].toString().substring(0, 10);
        double amount = double.parse(record['total_amount'].toString());

        // For withdrawals, make amount negative
        if (record['action_type'] == 'withrowl') {
          amount = -amount;
        }

        if (dailyIncome.containsKey(dateStr)) {
          dailyIncome[dateStr] = dailyIncome[dateStr]! + amount;
        } else {
          dailyIncome[dateStr] = amount;
        }

        totalIncome += amount;
      }

      // Convert to IncomeRecord list
      dailyIncome.forEach((date, amount) {
        incomeRecords.add(IncomeRecord(date: date, amount: amount.round()));
      });

      // Sort by date descending
      incomeRecords.sort((a, b) => b.date!.compareTo(a.date!));

      // Create response matching the existing model
      final incomeData = {
        'success': incomeRecords.isEmpty ? 0 : 1,
        'register': 'success',
        'data': {
          'income_record': incomeRecords.map((r) => r.toJson()).toList(),
          'total_income': totalIncome.round(),
        },
      };

      incomeReport = IncomeReportRes.fromJson(incomeData);
      st.value = true;
    } catch (e) {
      loggerNoStack.e('Error fetching income report: $e');
      // Set empty data on error
      incomeReport = IncomeReportRes.fromJson({
        'success': 0,
        'register': 'error',
        'data': {'income_record': [], 'total_income': 0},
      });
      st.value = true;
    }
  }

  IncomeReportRes incomeReport = IncomeReportRes();

  optionBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 295,
        decoration: const BoxDecoration(
          color: AppColors.WHITE,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
              ),
              height: 60,
              // alignment: Alignment.center,
              child: Stack(
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppTextWidgets.blackText(
                          text: "filter_report_by".tr,
                          color: AppColors.totalFilterReportTextColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    margin: const EdgeInsets.only(right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Image.asset(
                            AppImages.closeIcon,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomOptionTile(
              callback: () {
                Get.back();
                showOption.value = "income_report_tile_short_text1".tr;
                getIncomeReport("today");
              },
              text: "income_report_tile_text1".tr,
            ),
            CustomOptionTile(
              callback: () {
                Get.back();
                showOption.value = "income_report_tile_short_text2".tr;
                getIncomeReport("last 7 days");
              },
              text: "income_report_tile_text2".tr,
            ),
            CustomOptionTile(
              callback: () {
                Get.back();
                showOption.value = "income_report_tile_short_text3".tr;
                getIncomeReport("last 30 days");
              },
              text: "income_report_tile_text3".tr,
            ),
            CustomOptionTile(
              callback: () {
                Get.back();
                showOption.value = "";
                _showDateRangePicker(Get.context!);
              },
              text: "income_report_tile_text4".tr,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
      backgroundColor: AppColors.transparentColor,
    );
  }

  DateTimeRange? selectedDateRange;

  void _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().add(const Duration(days: -7)),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: initialDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      selectedDateRange = picked;
      makeApi();
    }
  }

  makeApi() {
    showOption.value = "";
    getIncomeReport(
      "${selectedDateRange!.start.toString().substring(0, 10)},${selectedDateRange!.end.toString().substring(0, 10)}",
    );
  }

  void changeFilter(String filterType) {
    selectedFilter.value = filterType;
    getIncomeReport(
      selectedDateRange != null
          ? "${selectedDateRange!.start.toString().substring(0, 10)},${selectedDateRange!.end.toString().substring(0, 10)}"
          : showOption.value == "income_report_tile_short_text1".tr
          ? "today"
          : showOption.value == "income_report_tile_short_text2".tr
          ? "last 7 days"
          : "last 30 days",
    );
  }

  @override
  void onInit() {
    super.onInit();
    doctorId.value =
        StorageService.readData(key: LocalStorageKeys.userId) ?? "";

    // Use initialDuration parameter instead of hardcoded "today"
    if (initialDuration == "last 30 days") {
      showOption.value = "income_report_tile_short_text3".tr;
    }

    getIncomeReport(initialDuration);
  }
}
