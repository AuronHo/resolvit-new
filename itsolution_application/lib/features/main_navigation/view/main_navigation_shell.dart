import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../logic/navigation_controller.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import '../../home/view/home_screen.dart';
import '../../chat/view/chat_screen.dart';
import '../../saved/view/saved_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../profile/view/business_profile_screen.dart';
import '../../../utils/responsive.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  DateTime? _lastBackPress;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NavigationController>();
    final isTablet = Responsive.isTablet(context);

    final Widget currentProfileScreen = controller.isBusinessProfile
        ? const BusinessProfileScreen()
        : const ProfileScreen();

    final List<Widget> screens = [
      const HomeScreen(),
      const ChatScreen(),
      const SavedScreen(),
      currentProfileScreen,
    ];

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _TabletNavRail(
              selectedIndex: controller.selectedIndex,
              onSelect: (i) =>
                  context.read<NavigationController>().setIndex(i),
            ),
            const VerticalDivider(
                width: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            Expanded(
              child: IndexedStack(
                index: controller.selectedIndex,
                children: screens,
              ),
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: controller.selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: controller.selectedIndex,
          onTap: (index) =>
              context.read<NavigationController>().setIndex(index),
        ),
      ),
    );
  }
}

class _TabletNavRail extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const _TabletNavRail(
      {required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF4981FB);

    return Container(
      color: brandBlue,
      child: SafeArea(
        child: NavigationRail(
          backgroundColor: brandBlue,
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          labelType: NavigationRailLabelType.all,
          indicatorColor: Colors.white.withValues(alpha: 0.18),
          selectedIconTheme:
              const IconThemeData(color: Colors.white, size: 24),
          unselectedIconTheme: IconThemeData(
              color: Colors.white.withValues(alpha: 0.6), size: 24),
          selectedLabelTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11),
          unselectedLabelTextStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
          leading: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Resolv\nIT',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.2),
            ),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_filled),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: Text('Chat'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: Text('Saved'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
