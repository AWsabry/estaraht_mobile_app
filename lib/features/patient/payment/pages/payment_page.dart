import 'package:videocalling/core/config/app_imports.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: CustomAppBar(title: 'payment'.tr),
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
                    'payments'.tr,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment methods section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'select_a_payment_method'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Payment methods list
                    _buildPaymentMethodsList(isArabic),

                    // Appointment details card
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'details'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    _buildAppointmentDetailsCard(isArabic),

                    // Bankily payment fields (shown only when Visa/MasterCard is selected)
                    /*      Obx(() {
                      if (controller.selectedPaymentMethod.value == 1) {
                        return _buildBankilyPaymentFields(isArabic: isArabic,
                            subtotal: controller.subtotal.value,
                            serviceFees: controller.serviceFees.value,
                            tax:  controller.tax.value,
                            discount: controller.discount.value,
                            total: controller.total.value);
                      }
                      return const SizedBox.shrink();
                    }),*/
                    Obx(
                      () => _buildPaymentSummaryCard(
                        isArabic: isArabic,
                        subtotal: controller.subtotal.value,
                        serviceFees: controller.serviceFees.value,
                        tax: controller.tax.value,
                        discount: controller.discount.value,
                        total: controller.total.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          _buildConfirmPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(bool isArabic) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color.fromRGBO(246, 246, 246, 1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // --- Top Row (Profile + Name + Edit) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Profile Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    imageUrl: controller.doctorImageUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      AppImages.getDoctorPlaceholder(controller.doctorGender),
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      AppImages.getDoctorPlaceholder(controller.doctorGender),
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.doctorSpecialization,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Text(
                    "edit".tr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3366FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Appointment Date/Time ---
            Row(
              children: [
                SvgPicture.asset(
                  AppImages.appointmentTime,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${controller.appointmentDate} at ${controller.appointmentTime}",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Appointment Amount ---
            Row(
              children: [
                SvgPicture.asset(AppImages.payment),
                const SizedBox(width: 8),
                const Text(
                  'MRU',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Text(
                  "${controller.amount} ",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // --- Appointment Duration ---
            Row(
              children: [
                SvgPicture.asset(AppImages.appointmentTime, width: 20),
                const SizedBox(width: 8),
                Text(
                  '45 ${"min".tr}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(bool isArabic) {
    return Column(
      children: [
        _buildPaymentOption(
          title: 'pay_with_bankily'.tr,
          subtitle: 'pay_with_visa_or_mastercard_via_bankily'.tr,
          index: 1,
          isArabic: isArabic,
          logos: [Image.asset(AppImages.bankily, height: 50, width: 50)],
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          title: 'method6_title'.tr, // Stripe
          subtitle: 'method6_description'.tr,
          index: 2,
          isArabic: isArabic,
          icon: Icons.credit_card,
        ),
        Obx(() {
          if (controller.selectedPaymentMethod.value != 2) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'stripe_currency'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: controller.stripeCurrencyCode,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setStripeCurrencyCode(value);
                      }
                    },
                    items: controller.stripeSupportedCurrencies
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }),
        /*  const SizedBox(height: 8),
        _buildPaymentOption(
          title: 'e_wallet'.tr,
          subtitle: 'pay_at_the_clinic'.tr,
          index: 2,
          isArabic: isArabic,
          logos:[
            SvgPicture.asset(AppImages.wallet, height: 20),
          ],
        ),
        const SizedBox(height: 8),*/
        /*_buildPaymentOption(
          title: 'app_wallet'.tr,
          subtitle: 'pay_at_the_clinic'.tr,
          index: 3,
          isArabic: isArabic,
          logos:[
            SvgPicture.asset(AppImages.wallet, height: 20),
          ],
        ),*/
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    String? subtitle,
    required int index,
    required bool isArabic,
    IconData? icon,
    List<Widget>? logos,
  }) {
    return Obx(() {
      final bool isSelected = controller.selectedPaymentMethod.value == index;

      return InkWell(
        onTap: () => controller.selectPaymentMethod(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF3366FF) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3366FF)
                              : const Color(0xFFD9D9D9),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF3366FF)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (logos != null)
                Row(children: logos)
              else if (icon != null)
                Icon(icon, color: Colors.blue[800], size: 24),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPaymentSummaryCard({
    required bool isArabic,
    required double subtotal,
    required double serviceFees,
    required double tax,
    required double discount,
    required double total,
  }) {
    // Check if Stripe is selected (payment method 2)
    final isStripeSelected = controller.selectedPaymentMethod.value == 2;
    final currency = isStripeSelected ? 'USD' : 'MRU';
    const exchangeRate = 50.0; // 1 USD = 50 MRU

    // Convert amounts to USD if Stripe is selected
    final displaySubtotal = isStripeSelected
        ? subtotal / exchangeRate
        : subtotal;
    final displayServiceFees = isStripeSelected
        ? serviceFees / exchangeRate
        : serviceFees;
    final displayTax = isStripeSelected ? tax / exchangeRate : tax;
    final displayDiscount = isStripeSelected
        ? discount / exchangeRate
        : discount;
    final displayTotal = isStripeSelected ? total / exchangeRate : total;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // --- Coupon Row ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.couponController,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'enter_the_coupon_here'.tr,
                      hintStyle: const TextStyle(fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF3366FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.applyCoupon(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3366FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    "activate".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Show currency conversion notice if Stripe is selected
            if (isStripeSelected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amounts converted to USD (1 USD = $exchangeRate MRU)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // --- Payment Summary ---
            _buildSummaryRow(
              'subtotal'.tr,
              '$currency ${displaySubtotal.toStringAsFixed(2)}',
              isArabic,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'service_fees'.tr,
              '$currency ${displayServiceFees.toStringAsFixed(2)}',
              isArabic,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'tax'.tr,
              '$currency ${displayTax.toStringAsFixed(2)}',
              isArabic,
            ),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'discount'.tr,
                '-$currency ${displayDiscount.toStringAsFixed(2)}',
                isArabic,
                isDiscount: true,
              ),
            ],

            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 8),

            // --- Total ---
            _buildSummaryRow(
              'total'.tr,
              '$currency ${displayTotal.toStringAsFixed(2)}',
              isArabic,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isArabic, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPaymentButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isProcessingPayment.value
              ? null
              : () {
                  // Bankily -> show detailed bottom sheet
                  if (controller.selectedPaymentMethod.value == 1) {
                    Get.bottomSheet(
                      DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        maxChildSize: 1,
                        minChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: _buildBankilyPaymentFields(
                              isArabic:
                                  Get.find<LanguageController>()
                                      .currentLanguage
                                      .value ==
                                  'ar',
                              subtotal: controller.subtotal.value,
                              serviceFees: controller.serviceFees.value,
                              tax: controller.tax.value,
                              discount: controller.discount.value,
                              total: controller.total.value,
                            ),
                          );
                        },
                      ),
                      isScrollControlled: true,
                      enableDrag: true,
                      isDismissible: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    );
                  } else {
                    // Stripe and future methods -> trigger controller flow directly
                    controller.processPayment();
                  }
                },

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isProcessingPayment.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'process_payment'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBankilyPaymentFields({
    required bool isArabic,
    required double subtotal,
    required double serviceFees,
    required double tax,
    required double discount,
    required double total,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Title ---
            Align(
              child: Image.asset(AppImages.bankily, height: 250, width: 250),
            ),

            const SizedBox(height: 16),
            Obx(
              () => Align(
                alignment: isArabic ? Alignment.center : Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'bankily_payment_information'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        controller.merchantId.value.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Phone Number ---
            _buildTextField(
              label: 'phone_number'.tr,
              hint: 'phone_number_hint'.tr,
              controller: controller.phoneController,
              isArabic: isArabic,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // --- Passcode ---
            _buildTextField(
              label: 'bankily_passcode'.tr,
              hint: 'passcode_hint'.tr,
              controller: controller.passcodeController,
              isArabic: isArabic,
              keyboardType: TextInputType.number,
              obscureText: true,
            ),

            const SizedBox(height: 16),

            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enter your Bankily phone number and passcode to complete the payment'
                          .tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  // --- Payment Summary ---
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSummaryRow(
              'subtotal'.tr,
              'MRU ${subtotal.toStringAsFixed(2)}',
              isArabic,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'service_fees'.tr,
              'MRU ${serviceFees.toStringAsFixed(2)}',
              isArabic,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'tax'.tr,
              'MRU ${tax.toStringAsFixed(2)}',
              isArabic,
            ),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'discount'.tr,
                '-MRU ${discount.toStringAsFixed(2)}',
                isArabic,
                isDiscount: true,
              ),
            ],

            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 8),

            // --- Total ---
            _buildSummaryRow(
              'total'.tr,
              'MRU ${total.toStringAsFixed(2)}',
              isArabic,
              isBold: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: controller.isProcessingPayment.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'process_payment'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isArabic,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint.tr,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF3366FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCardNumber(String cardNumber) {
    // Remove all whitespace and format as "XXXX XXXX XXXX XXXX"
    String cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    StringBuffer formatted = StringBuffer();

    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(cleaned[i]);
    }

    return formatted.toString();
  }

  String _formatExpirationDate(String expirationDate) {
    // Remove all non-numeric characters and format as "MM/YY"
    String cleaned = expirationDate.replaceAll(RegExp(r'[^0-9]'), '');
    StringBuffer formatted = StringBuffer();

    for (int i = 0; i < cleaned.length; i++) {
      if (i == 2) {
        formatted.write('/');
      }
      formatted.write(cleaned[i]);
    }

    return formatted.toString();
  }
}
