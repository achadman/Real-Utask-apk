import 'package:flutter/material.dart';
import 'package:online_classroom/data/accounts.dart';
import 'package:online_classroom/screens/student_classroom/add_class.dart';
import 'package:online_classroom/screens/student_classroom/classes_tab.dart';
import 'package:online_classroom/screens/student_classroom/timeline_tab.dart';
import 'package:online_classroom/services/auth.dart';
import 'package:online_classroom/data/custom_user.dart';
import 'package:provider/provider.dart';

class StudentHomePage extends StatefulWidget {
  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<CustomUser?>(context);
    var account = getAccount(user!.uid);

    final tabs = [
      TimelineTab(),
      ClassesTab(),
    ];

    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Roboto",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4), // Menambahkan jarak antar teks
              Text(
                "Welcome, ${account!.firstName} ${account!.lastName}", // Menggunakan string interpolation
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: const Color.fromARGB(221, 51, 51, 51),
                size: 24,
              ),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notification_add_rounded,
                color: const Color.fromARGB(221, 51, 51, 51),
                size: 24,
              ),
              onPressed: () async {},
            ),
          ],
        ),
        body: tabs[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'ClassWork',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Classes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Calender",
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (context) => AddClass(),
                ))
                .then((_) => setState(() {}));
          },
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ));
  }
}
