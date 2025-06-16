import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'dart:ui';
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
    const EventScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildTabItem(
    IconData unselectedIcon,
    selectedIcon,
    int index,
  ) {
    final bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            size: isSelected ? 34.0 : 28.0,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4.0),
              height: 6.0,
              width: 6.0,
              decoration: const BoxDecoration(
                color: Colors.white,
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
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: _selectedIndex == 0
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(90.0),
                                  bottomLeft: Radius.circular(90.0),
                                  bottomRight: Radius.circular(90.0),
                                )
                              : BorderRadius.circular(90.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          borderRadius: _selectedIndex == 0
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(90.0),
                                  bottomLeft: Radius.circular(90.0),
                                  bottomRight: Radius.circular(90.0),
                                )
                              : BorderRadius.circular(90.0),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: BottomNavigationBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            items: <BottomNavigationBarItem>[
                              _buildTabItem(
                                MingCuteIcons.mgc_calendar_month_line,
                                MingCuteIcons.mgc_calendar_month_fill,
                                0,
                              ),
                              _buildTabItem(
                                MingCuteIcons.mgc_task_2_line,
                                MingCuteIcons.mgc_task_2_fill,
                                1,
                              ),
                              _buildTabItem(
                                MingCuteIcons.mgc_briefcase_2_line,
                                MingCuteIcons.mgc_briefcase_2_fill,
                                2,
                              ),
                              _buildTabItem(
                                MingCuteIcons.mgc_settings_3_line,
                                MingCuteIcons.mgc_settings_3_fill,
                                3,
                              ),
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
