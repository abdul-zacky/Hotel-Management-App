import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisma1/screens/expense_screen/views/expenses_screen.dart';
import 'package:wisma1/screens/flow_screen/views/flow_screen.dart';
import 'package:wisma1/screens/home/views/main_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _getScreen(int index) {
    if (index == 0) {
      return const MainScreen();
    } else if (index == 1) {
      return const ExpensesScreen();
    } else if (index == 2) {
      return const FlowScreen();
    } else {
      return const Center(child: Text('Unknown screen'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex, // Make highlights for the slected page
          onTap: onItemTapped,
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          // selectedItemColor: Theme.of(context).colorScheme.primary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.graph_circle_fill),
              label: "income",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar_circle_fill),
              label: "income",
            ),
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   shape: const CircleBorder(),
      //   child: const Icon(CupertinoIcons.add),
      // ),
      body: _getScreen(selectedIndex),
    );
  }
}
