import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wallet_budget_tracker/views/Analysisscreen.dart';
import 'package:wallet_budget_tracker/views/acountscreen.dart';
import 'package:wallet_budget_tracker/views/homescreen.dart';

import '../helper/colors.dart';
import 'budgetscreen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const Analysisscreen(),
    const BudgetScreen(),
    const Acountscreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: ColorsHelper.white,
          unselectedItemColor: ColorsHelper.black,
          elevation: 10,
          backgroundColor: ColorsHelper.green,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.scrollText),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.chartSpline),
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.walletCards),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.circleUserRound),
              label: 'Accounts',
            ),
          ],
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });

            switch (index) {
              case 0:
                // Navigate to Records page

                break;
              case 1:
                // Navigate to Analysis page
                break;
              case 2:
                // Navigate to Budget page
                break;
              case 3:
                // Navigate to Accounts page
                break;
            }
          },
        ));
  }
}
