import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/finance/pages/withdrawal_page.dart';
import 'package:videocalling/features/doctor/finance/withdrawal_binding.dart';

class IncomeReportScreen extends GetView<IncomeReportController> {
  final IncomeReportController reportController = Get.put(
    IncomeReportController(),
  );

  IncomeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: CustomAppBar(title: 'financial_reports'.tr),
        leading: Container(),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            height: 60,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'financial_reports'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Balance Card
            _buildBalanceCard(),

            // Filter Tabs
            _buildFilterTabs(),

            // Detailed Report Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'detailed_report'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            // Transactions List
            Expanded(
              child: Obx(
                () => reportController.st.value
                    ? reportController.incomeReport.success.toString() == "0"
                          ? _buildEmptyState()
                          : _buildTransactionList()
                    : _buildLoadingState(),
              ),
            ),

            // Withdraw Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to withdrawal screen with available balance
                  final result = await Get.to(
                    () => const WithdrawalScreen(),
                    binding: WithdrawalBinding(),
                    arguments: {
                      'totalBalance': reportController.availableBalance.value,
                    },
                  );

                  // Refresh the income report if withdrawal was successful
                  if (result != null && result['success'] == true) {
                    reportController.getIncomeReport('last 30 days');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                ),
                child: Text(
                  'withdraw_funds'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reportController.st.value
                      ? Text(
                          "\$${reportController.availableBalance.value.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.color1,
                          ),
                        )
                      : SizedBox(
                          height: 32,
                          child: Center(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey[200],
                              color: AppColors.color1,
                            ),
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    'available_balance'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                onPressed: () => reportController.optionBottomSheet(),
                icon: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.grey[700],
                ),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(
        () => Row(
          children: [
            _buildFilterTab(
              'all'.tr,
              reportController.selectedFilter.value == 'total',
              'total',
              null,
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              'profits'.tr,
              reportController.selectedFilter.value == 'income',
              'income',
              const Color(0xFF34C759),
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              'withdrawals'.tr,
              reportController.selectedFilter.value == 'withdrawal',
              'withdrawal',
              const Color(0xFFF26749),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    String label,
    bool isSelected,
    String filterType,
    Color? selectedColor,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          reportController.changeFilter(filterType);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? (selectedColor ?? AppColors.color1)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (selectedColor ?? AppColors.color1)
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: reportController.incomeReport.data!.incomeRecord!.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final record = reportController.incomeReport.data!.incomeRecord![index];
        // Determine if it's a withdrawal based on negative amount
        bool isWithdrawal = record.amount! < 0;
        return _buildTransactionItem(record, isWithdrawal);
      },
    );
  }

  Widget _buildTransactionItem(dynamic record, bool isWithdrawal) {
    // Format date from YYYY-MM-DD to DD/MM/YYYY
    String formattedDate =
        "${record.date.toString().substring(8, 10)}/${record.date.toString().substring(5, 7)}/${record.date.toString().substring(0, 4)}";

    bool isIncome = !isWithdrawal;
    // Get absolute value for display
    int absoluteAmount = record.amount!.abs();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome ? Colors.green[50] : Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.south_west : Icons.north_east,
              color: isIncome ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncome ? 'consultation_payment'.tr : 'withdrawal'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            "${isIncome ? '+' : '-'} \$${absoluteAmount.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'not_any_income_str'.trParams({
              'option': reportController.showOption.value,
            }),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: AppColors.color1,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'loading_transactions'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
