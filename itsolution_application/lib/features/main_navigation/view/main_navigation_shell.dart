import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 1. IMPORT CONTROLLER (NAIK SATU LEVEL DARI 'view', MASUK KE 'logic') ---
import '../logic/navigation_controller.dart'; 

// --- 2. IMPORT WIDGET NAVBAR (TURUN KE FOLDER 'widgets') ---
import 'widgets/custom_bottom_nav_bar.dart'; 

// --- 3. IMPORT SCREENS LAINNYA (SESUAIKAN DENGAN STRUKTUR PROJEK ANDA) ---
// Asumsi: folder home, chat, profile, saved sejajar dengan main_navigation
import '../../home/view/home_screen.dart';
import '../../chat/view/chat_screen.dart';
import '../../saved/view/saved_screen.dart';
import '../../profile/view/profile_screen.dart'; 
import '../../profile/view/business_profile_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Controller
    final controller = context.watch<NavigationController>();

    // 2. Tentukan Layar Profile mana yang dipakai (Personal / Bisnis)
    Widget currentProfileScreen;
    if (controller.isBusinessProfile) {
      currentProfileScreen = const BusinessProfileScreen();
    } else {
      currentProfileScreen = const ProfileScreen();
    }

    // 3. Susun List Screen (Tidak boleh const lagi karena ada variabel)
    final List<Widget> screens = [
      const HomeScreen(),
      const ChatScreen(),
      const SavedScreen(),
      currentProfileScreen, // <--- Layar ke-4 Dinamis
    ];

    return Scaffold(
      extendBody: true,
      
      // 4. Masukkan List ke IndexedStack
      body: IndexedStack(
        index: controller.selectedIndex,
        children: screens,
      ),
      
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: controller.selectedIndex,
        onTap: (index) {
          // Logika Navigasi (Pindah Tab & Buka Pop-up ada di dalam widget ini)
          context.read<NavigationController>().setIndex(index);
        },
      ),
    );
  }
}