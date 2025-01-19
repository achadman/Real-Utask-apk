import 'package:flutter/material.dart';
import 'package:online_classroom/data/accounts.dart';
import 'package:online_classroom/screens/teacher_classroom/add_class.dart';
import 'package:online_classroom/screens/teacher_classroom/classes_tab.dart';
import 'package:online_classroom/services/auth.dart';
import 'package:online_classroom/data/custom_user.dart';
import 'package:provider/provider.dart';

class TeacherHomePage extends StatefulWidget {
  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<CustomUser?>(context);
    var account = getAccount(user!.uid);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
         title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Classes",
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
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: Text("Log out",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
          ),
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: ClassesTab(account),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddClass(),
              )).then((_) => setState(() {}));
        },
        backgroundColor: const Color.fromARGB(255, 18, 95, 204),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
