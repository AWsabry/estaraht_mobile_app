import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/appointments/pages/appointments_list_page.dart';

class ConsultationsPage extends StatefulWidget {
  const ConsultationsPage({super.key});

  @override
  State<ConsultationsPage> createState() => _ConsultationsPageState();
}

class _ConsultationsPageState extends State<ConsultationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.LIGHT_GREY_SCREEN_BACKGROUND,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: CustomAppBar(
          title: 'consultations'.tr,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.color1,
          labelColor: AppColors.color1,
          unselectedLabelColor: AppColors.greyShade6,
          labelStyle: TextStyle(
            fontFamily: AppFontStyleTextStrings.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppFontStyleTextStrings.regular,
            fontSize: 16,
          ),
          tabs: [
            Tab(text: 'appointments_str'.tr),
            Tab(text: 'messages'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UAllAppointments(),
          PChatListScreen(),
        ],
      ),
    );
  }
}
