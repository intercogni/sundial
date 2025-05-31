import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 109, 99, 80), // Pastel muted orange
          unselectedItemColor: const Color(0xFF1E3F05), // Pastel light cream
          type:
              BottomNavigationBarType
                  .fixed, // This will prevent icon size change
          showSelectedLabels: false,
          showUnselectedLabels: false,
          enableFeedback: false,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
