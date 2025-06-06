import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter
import 'package:sundial/screens/home.dart';
import 'package:sundial/screens/dial.dart';
import 'package:sundial/screens/times.dart';
import 'package:sundial/screens/account.dart';

class BottomTab extends StatefulWidget {
  const BottomTab({super.key});

  @override
  _BottomTabState createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(title: 'Sundial'),
    const DialScreen(),
    const TimesScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildTabItem(IconData iconData, int index) {
    final bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: isSelected ? 32.0 : 24.0, // Bigger when selected
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4.0),
              height: 6.0,
              width: 6.0,
              decoration: const BoxDecoration(
                color: Colors.white, // The dot color
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: _widgetOptions.elementAt(_selectedIndex)),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0), // Adjust padding as needed
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Rounded corners for the glass effect
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism blur effect
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Translucent background
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4), // Subtle border
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: BottomNavigationBar(
                        backgroundColor: Colors.transparent, // Make background transparent
                        elevation: 0, // Remove default elevation
                        items: <BottomNavigationBarItem>[
                          _buildTabItem(Icons.dashboard, 0),
                          _buildTabItem(Icons.access_time, 1),
                          _buildTabItem(Icons.bar_chart, 2),
                          _buildTabItem(Icons.account_circle, 3),
                        ],
                        currentIndex: _selectedIndex,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.white,
                        type: BottomNavigationBarType.fixed,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        enableFeedback: false,
                        onTap: _onItemTapped,
                      ),
                    ),
                  ),
                ),
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
