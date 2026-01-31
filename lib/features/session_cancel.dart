import 'package:videocalling/core/config/app_imports.dart';

class SessionCancelDoctor extends StatelessWidget {
  const SessionCancelDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'session_cancelled_by_doctor'.tr,
              style: const CustomTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
