import 'package:get/get.dart';
import 'package:soulnum/src/ui/ai_chat/ai_chat_limit_page.dart';
import 'package:soulnum/src/ui/ai_chat/ai_chat_page.dart';
import 'package:soulnum/src/ui/ai_chat/binding/ai_chat_binding.dart';
import 'package:soulnum/src/ui/compatibility/binding/compatibility_binding.dart';
import 'package:soulnum/src/ui/compatibility/compatibility_page.dart';
import 'package:soulnum/src/ui/daily_cycle/binding/daily_cycle_binding.dart';
import 'package:soulnum/src/ui/daily_cycle/daily_cycle_page.dart';
import 'package:soulnum/src/ui/history/binding/history_binding.dart';
import 'package:soulnum/src/ui/history/history_page.dart';
import 'package:soulnum/src/ui/home/binding/home_binding.dart';
import 'package:soulnum/src/ui/home/home_page.dart';
import 'package:soulnum/src/ui/login/binding/login_binding.dart';
import 'package:soulnum/src/ui/login/login_page.dart';
import 'package:soulnum/src/ui/main/main_page.dart';
import 'package:soulnum/src/ui/profile_manager/binding/profile_manager_binding.dart';
import 'package:soulnum/src/ui/profile_manager/profile_delete_confirm_page.dart';
import 'package:soulnum/src/ui/profile_manager/profile_detail_page.dart';
import 'package:soulnum/src/ui/profile_manager/profile_form_page.dart';
import 'package:soulnum/src/ui/profile_manager/profile_manager_page.dart';
import 'package:soulnum/src/ui/reading_detail/binding/reading_detail_binding.dart';
import 'package:soulnum/src/ui/reading_detail/reading_detail_page.dart';
import 'package:soulnum/src/ui/register/binding/register_binding.dart';
import 'package:soulnum/src/ui/register/register_page.dart';
import 'package:soulnum/src/ui/splash/splash_page.dart';
import 'package:soulnum/src/ui/subscription/binding/subscription_binding.dart';
import 'package:soulnum/src/ui/subscription/subscription_page.dart';

class AppPages {
  AppPages._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/';
  static const String home = '/home';
  static const String profileManager = '/profiles';
  static const String profileCreate = '/profiles/create';
  static const String profileDetail = '/profiles/detail';
  static const String profileDeleteConfirm = '/profiles/delete-confirm';
  static const String readingDetail = '/reading/detail';
  static const String compatibility = '/compatibility';
  static const String dailyCycle = '/daily-cycle';
  static const String subscriptionVip = '/subscription/vip';
  static const String aiChat = '/ai-chat';
  static const String aiChatLimit = '/ai-chat-limit';
  static const String history = '/history';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(name: main, page: () => const MainPage(), binding: HomeBinding()),
    GetPage(name: home, page: () => const HomePage(), binding: HomeBinding()),
    GetPage(
      name: profileManager,
      page: () => const ProfileManagerPage(),
      binding: ProfileManagerBinding(),
    ),
    GetPage(
      name: profileCreate,
      page: () => const ProfileFormPage(),
      binding: ProfileManagerBinding(),
    ),
    GetPage(
      name: profileDetail,
      page: () => const ProfileDetailPage(),
      binding: ProfileManagerBinding(),
    ),
    GetPage(
      name: profileDeleteConfirm,
      page: () => const ProfileDeleteConfirmPage(),
      binding: ProfileManagerBinding(),
    ),
    GetPage(
      name: readingDetail,
      page: () => const ReadingDetailPage(),
      binding: ReadingDetailBinding(),
    ),
    GetPage(
      name: compatibility,
      page: () => const CompatibilityPage(),
      binding: CompatibilityBinding(),
    ),
    GetPage(
      name: dailyCycle,
      page: () => const DailyCyclePage(),
      binding: DailyCycleBinding(),
    ),
    GetPage(
      name: subscriptionVip,
      page: () => const SubscriptionPage(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: aiChat,
      page: () => const AiChatPage(),
      binding: AiChatBinding(),
    ),
    GetPage(name: aiChatLimit, page: () => const AiChatLimitPage()),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
  ];
}
