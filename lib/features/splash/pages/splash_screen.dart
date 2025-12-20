import 'package:videocalling/core/config/app_imports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF204FCF),
      body: Stack(
        children: [
          // Background SVG
          SvgPicture.asset(
            AppImages.splashBg,
            fit: BoxFit.fill,
            height: Get.height,
            width: Get.width,
          ),
          Padding(
            padding: const EdgeInsets.all(85),
            child: Center(
              child: Hero(
                tag:
                    'app_logo',
                child: SvgPicture.asset(
                  AppImages.splashIcon,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
