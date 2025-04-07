import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/views/tabs/token/token_view.dart';
import '../tabs/chatboards/chatboards_view.dart';
import '../tabs/profile/profile_view.dart';
import '../tabs/settings/settings_view.dart';
import '../constants/strings.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  int _currentIndex = 0;  // Starts with chatboards tab
  
  final List<Widget> _screens = [
    const ChatboardsView(),
    const ProfileView(),
    const TokensView(),
    const SettingsView()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: Strings.chatboards,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: Strings.profile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_rounded),
            label: Strings.tokens,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: Strings.settings,
          ),
          
        ],
      ),
    );
  }
}
