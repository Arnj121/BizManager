import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Manage extends StatefulWidget {
  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: Colors.deepPurpleAccent),
          title: Text(
            'Manage',
            style: GoogleFonts.openSans(
              color: Colors.deepPurpleAccent,
            ),
          ),
          titleSpacing: 0.0,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(

            )
          ],
        ),
      ),
    );
  }
}
