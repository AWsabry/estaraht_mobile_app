import 'package:videocalling/core/config/app_imports.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView(
            controller: controller.pageController,
            onPageChanged: (index) => controller.currentPage.value = index,
            children: const [
              OnboardingPage(
                logo: AppImages.splashIcon,
                title: "Connect with your therapist easily & safely.",
                subtitle: "Start your journey now!",
                description:
                    "You healing starts here. Private sessions and secure medical records, anywhere, and anytime.",
                isPatientPage: true,
              ),
              OnboardingPage(
                logo: AppImages.splashIcon,
                title: "Help your patients wherever they are, managing",
                subtitle: "your appointments just got easier.",
                description:
                    "Manage your appointments easily, communicate with your patients flexibly.",
                isPatientPage: false,
              ),
            ],
          ),

          // Bottom navigation
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Page indicators
                      Obx(
                        () => Row(
                          children: List.generate(
                            controller.pages,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: controller.currentPage.value == index
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Login/Sign up buttons
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => controller.navigateToLogin(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Login in",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.navigateToSignUp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Sign up"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String logo;
  final String title;
  final String subtitle;
  final String description;
  final bool isPatientPage;

  const OnboardingPage({
    Key? key,
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isPatientPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          SvgPicture.asset(logo, height: 80),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
