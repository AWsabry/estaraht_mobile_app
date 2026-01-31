import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/video_call/call_manager.dart';
import 'package:videocalling/features/video_call/video_call_imports.dart';

customDialog({
  required String s1,
  required String s2,
  TextStyle? s1style,
  TextStyle? s2style,
  TextStyle? s3style,
  VoidCallback? onPressed,
  bool dismiss = true,
}) {
  final languageController = Get.find<LanguageController>();
  final bool isArabic = languageController.currentLanguage.value == 'ar';
  final fontFamily = isArabic ? 'NotoKufiArabic' : 'Roboto';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              s1,
              style:
                  s1style ??
                  CustomTextStyle(
                    fontFamily: fontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            SizedBox(height: 16.h),
            // Content
            Text(
              s2,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style:
                  s2style ??
                  CustomTextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 24.h),
            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    onPressed ??
                    () {
                      Get.back();
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF204FCF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'ok_btn'.tr,
                  style:
                      s3style ??
                      CustomTextStyle(
                        fontFamily: fontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: dismiss,
  );
}

customDialog1({
  required String s1,
  required String s2,
  TextStyle? s1style,
  TextStyle? s2style,
}) {
  final languageController = Get.find<LanguageController>();
  final bool isArabic = languageController.currentLanguage.value == 'ar';
  final fontFamily = isArabic ? 'NotoKufiArabic' : 'Roboto';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s1,
              style:
                  s1style ??
                  CustomTextStyle(
                    fontFamily: fontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            SizedBox(height: 20.h),
            Text(
              s2,
              style:
                  s2style ??
                  CustomTextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF204FCF)),
              backgroundColor: Color(0xFFE0E0E0),
              minHeight: 2,
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

customDialog2({
  required String s1,
  required String s2,
  TextStyle? s1style,
  TextStyle? s2style,
  TextStyle? s3style,
  required VoidCallback onPressedYes,
  required VoidCallback onPressedNo,
}) {
  Get.dialog(
    AlertDialog(
      title: Text(
        s1,
        style: s1style ?? CustomTextStyle(fontFamily: AppFontStyleTextStrings.black, height: 1.3),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s2,
            maxLines: 3,
            style:
                s2style ??
                CustomTextStyle(
                  fontSize: 14,
                  fontFamily: AppFontStyleTextStrings.regular,
                  height: 1.3,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onPressedYes, child: Text('yes_btn'.tr)),
        TextButton(onPressed: onPressedNo, child: Text('no_btn'.tr)),
      ],
    ),
  );
}

logoutDialog({
  required String s1,
  required String s2,
  required VoidCallback onPressed,
}) {
  Get.dialog(
    AlertDialog(
      title: Text(
        s1,
        style: CustomTextStyle(fontFamily: AppFontStyleTextStrings.black, height: 1.3),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s2,
            style: CustomTextStyle(
              fontSize: 14,
              fontFamily: AppFontStyleTextStrings.regular,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(Get.context!).hintColor,
          ),
          child: AppTextWidgets.mediumTextWithColor(
            text: 'yes_btn'.tr,
            color: AppColors.BLACK,
          ),
        ),
      ],
    ),
  );
}

errorDialog({required String message}) {
  Get.dialog(
    AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Icon(Icons.error, size: 80, color: AppColors.RED),
          const SizedBox(height: 20),
          Text(message.toString()),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

callOptionDialog({required int callId}) {
  final languageController = Get.find<LanguageController>();
  final bool isArabic = languageController.currentLanguage.value == 'ar';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'call_dialog_title'.tr,
                style: CustomTextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: AppFontStyleTextStrings.regular,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Call options
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Audio call button
                  Expanded(
                    child: _buildCallButton(
                      icon: Icons.call,
                      label: 'audio'.tr,
                      gradient: const LinearGradient(
                        colors: [AppColors.color1, AppColors.color1],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      onTap: () async {
                        Get.back();
                        CallManager.instance.startCall(
                          channelName: 'audio_$callId',
                          token: '', // Get from your backend
                          isVideoCall: false,
                          opponentName: 'Doctor',
                        );
                      },
                      isArabic: isArabic,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Video call button
                  Expanded(
                    child: _buildCallButton(
                      icon: Icons.videocam,
                      label: 'video'.tr,
                      gradient: const LinearGradient(
                        colors: [AppColors.color1, AppColors.color1],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      onTap: () async {
                        Get.back();
                        CallManager.instance.startCall(
                          channelName: 'video_$callId',
                          token: '', // Get from your backend
                          isVideoCall: true,
                          opponentName: 'Doctor',
                        );
                      },
                      isArabic: isArabic,
                    ),
                  ),
                ],
              ),
            ),

            // Cancel button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr,
                  style: CustomTextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontFamily: AppFontStyleTextStrings.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

// Helper method to build call buttons
Widget _buildCallButton({
  required IconData icon,
  required String label,
  required LinearGradient gradient,
  required Function onTap,
  required bool isArabic,
}) {
  return InkWell(
    onTap: () => onTap(),
    child: Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.color1.withOpacity(0.3),
        //     spreadRadius: 1,
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: CustomTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: AppFontStyleTextStrings.medium,
            ),
          ),
        ],
      ),
    ),
  );
}

uploadMediaOptionDialog({
  required VoidCallback onTap,
  required VoidCallback onTap1,
}) {
  Get.dialog(
    AlertDialog(
      title: Text('media_upload_title'.tr),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: Get.width / 4,
                  child: InkWell(
                    onTap: onTap,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.color1, AppColors.color2],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            height: 50,
                            width: Get.width / 4,
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.WHITE,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  width: Get.width / 4,
                  child: InkWell(
                    onTap: onTap1,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.color1, AppColors.color2],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            width: Get.width / 4,
                            height: 50,
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.file_present,
                            color: AppColors.WHITE,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

unSendMessageDialog({required VoidCallback onTap}) {
  Get.dialog(
    barrierColor: AppColors.chatUnSendBarrierColor,
    AlertDialog(
      backgroundColor: AppColors.WHITE,
      elevation: 0,
      title: Text(
        'remove_msg_title'.tr,
        style: CustomTextStyle(
          fontFamily: AppFontStyleTextStrings.regular,
          color: AppColors.BLACK,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'remove_msg_subtitle'.tr,
            style: CustomTextStyle(
              fontFamily: AppFontStyleTextStrings.regular,
              fontSize: 13,
              color: AppColors.RED800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.grey.withOpacity(0.3),
                    ),
                    child: Center(
                      child: AppTextWidgets.blackText(
                        text: 'cancel'.tr,
                        color: AppColors.BLACK,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.grey,
                    ),
                    child: Center(
                      child: AppTextWidgets.blackText(
                        text: 'remove'.tr,
                        color: AppColors.WHITE,
                        size: 15,
                      ),
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
