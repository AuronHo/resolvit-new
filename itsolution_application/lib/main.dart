import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. Imports for Logic/State
import 'features/auth/logic/auth_controller.dart';
import 'features/main_navigation/logic/navigation_controller.dart';
import 'features/main_navigation/logic/theme_controller.dart'; 

// 2. Imports for Colors
import 'constants/app_colors.dart';

// 3. Imports for Screens
import 'features/auth/view/splash_screen.dart';
import 'features/auth/view/auth_welcome_screen.dart';
import 'features/auth/view/create_account_screen.dart';
import 'features/main_navigation/view/main_navigation_shell.dart';
import 'features/home/view/category_list_screen.dart';
import 'features/service/view/service_detail_screen.dart';
import 'features/auth/view/login_screen.dart'; 
import 'features/auth/view/reset_password_screen.dart';
import 'features/auth/view/verification_code_screen.dart';
import 'features/auth/view/new_password_screen.dart';
import 'features/auth/view/service_provider_register_screen.dart';
import 'features/auth/view/setup_business_profile_screen.dart';
import 'features/profile/view/business_profile_screen.dart';
import 'features/profile/view/business_view_details_screen.dart';
import 'features/profile/view/edit_business_details_screen.dart';
import 'features/profile/view/settings_screen.dart';
import 'features/profile/view/edit_profile_screen.dart';
import 'features/profile/view/test_screen.dart';
import 'features/notification/view/notification_screen.dart';
import 'features/notification/view/rate_service_screen.dart';
import 'features/saved/view/saved_screen.dart';
import 'features/profile/view/edit_business_profile_screen.dart';
import 'features/profile/view/add_post_screen.dart';
import 'features/profile/view/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => ThemeController()), // Crucial for the toggle
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the theme controller to detect changes (Light vs Dark)
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Resolv IT',
      debugShowCheckedModeBanner: false,

      // --- LIGHT THEME CONFIGURATION ---
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: kPrimaryBlue, // Uses your #173DDC
        scaffoldBackgroundColor: Colors.white,
        
        // Default styling for Elevated Buttons in Light Mode
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue, 
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(double.infinity, 50),
            elevation: 2,
          ),
        ),
        
        // Default styling for Outlined Buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),

        // Default styling for Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        // Ensure color scheme matches your blue
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: kPrimaryBlue,
          secondary: kPrimaryBlue,
        ),
      ),

      // --- DARK THEME CONFIGURATION ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryBlue,
        scaffoldBackgroundColor: const Color(0xFF121212), // Standard Dark Grey
        
        // Default styling for Elevated Buttons in Dark Mode
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: kPrimaryBlue,
          secondary: kPrimaryBlue,
        ),
      ),

      // This connects the app to the controller's current mode
      themeMode: themeController.themeMode,

      // Start at Splash
      home: const SplashScreen(),

      // Route Definitions
      routes: {
        '/welcome': (context) => const AuthWelcomeScreen(),
        '/create_account': (context) => const CreateAccountScreen(),
        '/home': (context) => const MainNavigationShell(),
        '/category_list': (context) {
          // Mengambil argumen judul kategori yang dikirim
          final title = ModalRoute.of(context)!.settings.arguments as String? ?? 'Services';
          return CategoryListScreen(categoryTitle: title);
        },
        '/service_detail': (context) => const ServiceDetailScreen(),
        '/login': (context) => const LoginScreen(), 
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/verification_code': (context) => const VerificationCodeScreen(),
        '/new_password': (context) => const NewPasswordScreen(),
        '/service_provider_register': (context) => const ServiceProviderRegisterScreen(),
        '/setup_business_profile': (context) => const SetupBusinessProfileScreen(),
        '/business_profile': (context) => const BusinessProfileScreen(),
        '/business_view_details': (context) => const BusinessViewDetailsScreen(),
        '/edit_business_details': (context) => const EditBusinessDetailsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/test_screen': (context) => const TestScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/rate_service': (context) => const RateServiceScreen(),
        '/saved': (context) => const SavedScreen(),
        '/edit_business_profile': (context) => const EditBusinessProfileScreen(),
        '/add_post': (context) => const AddPostScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}