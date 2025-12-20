// Core Flutter and Dart exports
export 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState, CarouselController;
export 'package:flutter/services.dart';
export 'package:flutter/foundation.dart';
export 'dart:async';
export 'dart:typed_data';
export 'dart:io' hide X509Certificate, Cookie, HttpClient;
export 'dart:convert';
export 'dart:math' hide log;
export 'dart:collection' hide IterableExtensions;

// Core constants
export 'package:videocalling/core/constants/app_colors.dart';
export 'package:videocalling/core/constants/app_strings.dart';
export 'package:videocalling/core/constants/app_images.dart';
export 'package:videocalling/core/constants/app_fonts.dart';

// Core utils
export 'package:videocalling/core/utils/logger.dart';
export 'package:videocalling/core/utils/extensions/extensions.dart';
export 'package:videocalling/core/utils/extensions/compat_extensions.dart';
export 'package:videocalling/core/utils/helpers/temp_stubs.dart';
export 'package:videocalling/core/widgets/others/app_text_widgets.dart';

// Core widgets
export 'package:videocalling/core/widgets/buttons/app_button.dart';
export 'package:videocalling/core/widgets/dialogs/app_dialog.dart';
export 'package:videocalling/core/widgets/text_fields/app_text_field.dart';
export 'package:videocalling/core/widgets/app_bar/app_appbar.dart';
export 'package:videocalling/core/widgets/others/language_widget.dart';
export 'package:videocalling/core/widgets/others/option_tile.dart';
export 'package:videocalling/core/widgets/others/no_chats.dart';
export 'package:videocalling/core/widgets/others/otp_pin.dart';

// Core config
export 'package:videocalling/core/config/routes.dart';
export 'package:videocalling/core/config/app_apis.dart';
export 'package:videocalling/core/config/app_variables.dart';

// Shared services
export 'package:videocalling/shared/services/storage/storage_service.dart';
export 'package:videocalling/shared/services/api/api_service.dart';
export 'package:videocalling/shared/services/auth/firebase_helper.dart';
export 'package:videocalling/shared/services/auth/supabase_helper.dart';
export 'package:videocalling/shared/services/notifications/fcm_service.dart';
export 'package:videocalling/shared/services/notifications/notification_service.dart';
export 'package:videocalling/shared/services/notifications/push_notification_service.dart';
export 'package:videocalling/shared/services/notifications/payment_notification_service.dart';
export 'package:videocalling/shared/services/notifications/notification_background_message_helper.dart';
export 'package:videocalling/shared/services/payment/bankily_service.dart';
export 'package:videocalling/shared/services/others/email_service.dart';
export 'package:videocalling/shared/services/others/string_services.dart';

// Shared models
export 'package:videocalling/shared/models/appointment/appointment_model.dart';
export 'package:videocalling/shared/models/appointment/appointment_details_model.dart';
export 'package:videocalling/shared/models/chat/chat_list_model.dart';
export 'package:videocalling/shared/models/speciality/speciality_model.dart';
export 'package:videocalling/shared/models/upload/upload_image_model.dart';

// Shared widgets
export 'package:videocalling/shared/widgets/info_notification_widget.dart';

// Features - Auth
export 'package:videocalling/features/auth/controllers/patient_login_controller.dart';
export 'package:videocalling/features/auth/controllers/doctor_login_controller.dart';
export 'package:videocalling/features/auth/controllers/patient_register_controller.dart';
export 'package:videocalling/features/auth/controllers/doctor_register_controller.dart';
export 'package:videocalling/features/auth/controllers/forget_password_controller.dart';
export 'package:videocalling/features/auth/controllers/otp_controller.dart';
export 'package:videocalling/features/auth/pages/patient_login_screen.dart'
    hide LanguageController;
export 'package:videocalling/features/auth/pages/doctor_login_screen.dart';
export 'package:videocalling/features/auth/pages/patient_register_screen.dart'
    hide LanguageController;
export 'package:videocalling/features/auth/pages/doctor_register_screen.dart'
    hide LanguageController;
export 'package:videocalling/features/auth/pages/forget_password_screen.dart';
export 'package:videocalling/features/auth/pages/otp_screen.dart';

// Features - Splash
export 'package:videocalling/features/splash/controllers/splash_controller.dart';
export 'package:videocalling/features/splash/pages/splash_screen.dart';
export 'package:videocalling/features/splash/splash_screen_binding.dart';

// Features - Onboarding
export 'package:videocalling/features/onboarding/controllers/onboarding_controller.dart';
export 'package:videocalling/features/onboarding/pages/onboarding_screen.dart';
export 'package:videocalling/features/onboarding/pages/role_selection_screen.dart';
export 'package:videocalling/features/onboarding/pages/patient_onboarding_screen.dart';
export 'package:videocalling/features/onboarding/pages/therapist_onboarding_screen.dart';

// Features - Language
export 'package:videocalling/features/language/controllers/language_controller.dart';
export 'package:videocalling/features/language/pages/language_selection_screen.dart';

// Features - Chat
export 'package:videocalling/features/chat/controllers/chat_controller.dart';
export 'package:videocalling/features/chat/pages/chat_screen.dart';
export 'package:videocalling/features/chat/chat_binding.dart';

// Features - Video Call
export 'package:videocalling/features/video_call/controllers/incoming_call_controller.dart';
export 'package:videocalling/features/video_call/controllers/incoming_call_image_name.dart';
export 'package:videocalling/features/video_call/pages/incoming_call_screen.dart';
export 'package:videocalling/features/video_call/pages/call_screen.dart';
export 'package:videocalling/features/video_call/incoming_call_binding.dart';

// Features - Media
export 'package:videocalling/features/media/controllers/photo_viewer_controller.dart';
export 'package:videocalling/features/media/controllers/video_player_controller.dart';
export 'package:videocalling/features/media/controllers/video_thumbnail_controller.dart';
export 'package:videocalling/features/media/pages/photo_viewer_screen.dart';
export 'package:videocalling/features/media/pages/video_player_screen.dart';
export 'package:videocalling/features/media/pages/video_thumbnail_screen.dart';
export 'package:videocalling/features/media/photo_viewer_binding.dart';
export 'package:videocalling/features/media/video_player_binding.dart';
export 'package:videocalling/features/media/video_thumbnail_binding.dart';

// Features - Patient
export 'package:videocalling/features/patient/home/controllers/home_controller.dart';
export 'package:videocalling/features/patient/home/pages/home_page.dart';
export 'package:videocalling/features/patient/tabs/controllers/tabs_controller.dart';
export 'package:videocalling/features/patient/tabs/pages/tabs_page.dart';
export 'package:videocalling/features/patient/appointments/controllers/appointments_list_controller.dart';
export 'package:videocalling/features/patient/appointments/controllers/appointment_detail_controller.dart';
export 'package:videocalling/features/patient/appointments/controllers/make_appointment_controller.dart';
export 'package:videocalling/features/patient/appointments/controllers/past_appointments_controller.dart';
export 'package:videocalling/features/patient/appointments/controllers/pdf_viewer_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/doctor_detail_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/doctor_search_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/nearby_doctors_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/speciality_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/speciality_doctors_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/indemand_doctors_controller.dart';
export 'package:videocalling/features/patient/doctors/controllers/review_controller.dart';
export 'package:videocalling/features/patient/profile/controllers/profile_controller.dart';
export 'package:videocalling/features/patient/profile/controllers/profile_parameters_controller.dart';
export 'package:videocalling/features/patient/chat/controllers/chat_list_controller.dart';
export 'package:videocalling/features/patient/payment/controllers/payment_controller.dart';
export 'package:videocalling/features/patient/more/controllers/more_controller.dart';
export 'package:videocalling/features/patient/more/controllers/notification_controller.dart';
export 'package:videocalling/features/patient/more/controllers/about_us_controller.dart';
export 'package:videocalling/features/patient/more/controllers/terms_controller.dart';
export 'package:videocalling/features/patient/more/controllers/report_issue_controller.dart';

// Features - Doctor
export 'package:videocalling/features/doctor/dashboard/controllers/dashboard_controller.dart';
export 'package:videocalling/features/doctor/tabs/controllers/tabs_controller.dart';
export 'package:videocalling/features/doctor/appointments/controllers/appointments_list_controller.dart';
export 'package:videocalling/features/doctor/appointments/controllers/appointment_detail_controller.dart';
export 'package:videocalling/features/doctor/appointments/controllers/past_appointments_controller.dart';
export 'package:videocalling/features/doctor/appointments/controllers/medicine_controller.dart';
export 'package:videocalling/features/doctor/profile/controllers/profile_view_controller.dart';
export 'package:videocalling/features/doctor/profile/controllers/edit_profile_controller.dart';
export 'package:videocalling/features/doctor/profile/controllers/change_password_controller.dart';
export 'package:videocalling/features/doctor/profile/controllers/step_three_controller.dart';
export 'package:videocalling/features/doctor/availability/controllers/availability_controller.dart';
export 'package:videocalling/features/doctor/availability/controllers/holiday_controller.dart';
export 'package:videocalling/features/doctor/finance/controllers/income_report_controller.dart';
export 'package:videocalling/features/doctor/finance/controllers/bank_details_controller.dart';
export 'package:videocalling/features/doctor/finance/controllers/withdrawal_controller.dart';
export 'package:videocalling/features/doctor/finance/controllers/subscription_controller.dart';
export 'package:videocalling/features/doctor/finance/controllers/choose_plan_controller.dart';
export 'package:videocalling/features/doctor/chat/controllers/chat_list_controller.dart';
export 'package:videocalling/features/doctor/more/controllers/more_controller.dart';

// Features - Other
export 'package:videocalling/features/myapp_controller.dart';
export 'package:videocalling/features/myapp_screen.dart';
export 'package:videocalling/features/myapp_screen_binding.dart';
export 'package:videocalling/features/in_app_webview_controller.dart';
export 'package:videocalling/features/in_app_webview_screen.dart';
export 'package:videocalling/features/in_app_webview_binding.dart';
export 'package:videocalling/features/session_cancel.dart';

// Third-party packages
export 'package:get/get.dart'
    hide Response, FormData, MultipartFile, HeaderValue;
export 'package:shared_preferences/shared_preferences.dart';
export 'package:pull_to_refresh/pull_to_refresh.dart';
export 'package:flutter_stripe/flutter_stripe.dart' hide Card, Address;
export 'package:get_storage/get_storage.dart' hide Data;
export 'package:dotted_border/dotted_border.dart';
export 'package:google_maps_flutter/google_maps_flutter.dart';
export 'package:geocode/geocode.dart';
export 'package:geocoding/geocoding.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:path_provider/path_provider.dart';
export 'package:auto_size_text/auto_size_text.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:google_sign_in/google_sign_in.dart';
export 'package:photo_view/photo_view.dart';
export 'package:video_player/video_player.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:http/http.dart' hide MultipartFile;
export 'package:carousel_slider/carousel_slider.dart';
export 'package:firebase_database/firebase_database.dart' hide Query;
export 'package:url_launcher/url_launcher.dart';
export 'package:flutter_html/flutter_html.dart' hide OnTap, Marker;
export 'package:cached_network_image/cached_network_image.dart';
export 'package:image_picker/image_picker.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:sn_progress_dialog/sn_progress_dialog.dart';
export 'package:device_info_plus/device_info_plus.dart';
export 'package:table_calendar/table_calendar.dart';
export 'package:syncfusion_flutter_datepicker/datepicker.dart';
export 'package:flutter_pdfview/flutter_pdfview.dart';
export 'package:flutter_inappwebview/flutter_inappwebview.dart';
export 'package:geolocator/geolocator.dart' hide AndroidResource;
export 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
export 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
export 'package:cloud_firestore/cloud_firestore.dart'
    hide Query, Transaction, TransactionHandler, kIsWasm;
