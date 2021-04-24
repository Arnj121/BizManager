import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
class Start extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Start> {
  DatabaseHelper db = DatabaseHelper.instance;
  List<Map<String,dynamic>> items=[];bool lightmode=true;
  Future<void> initData()async{
    items = await db.getBusiness();
    if(items.length>0){
      Navigator.pushReplacementNamed(context, '/home',arguments: items[0]);
    }
  }
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{initData();});
  }

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    return SafeArea(
        child: Scaffold(
            backgroundColor: lightmode?Colors.white : null,
            appBar: AppBar(
              backgroundColor: lightmode?Colors.white : null,
              elevation: 0,
              leading: Icon(
                Icons.book_sharp,
                color: Colors.redAccent,
                size: 30.0,
              ),
              title: Text(
                'BizManager',
                style: GoogleFonts.openSans(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold
                ),
              ),
              titleSpacing: 2.0,
            ),
            body: Center(
              child: Container(
                child: TextButton.icon(
                    icon: Icon(Icons.add, color: Colors.white,),
                    label: Text('Tap to add a business',
                      style: GoogleFonts.openSans(
                          fontSize: 20.0,
                          color: Colors.white
                      ),
                    ),
                    onPressed: () async {
                      dynamic ret = await Navigator.pushNamed(context, '/addnew');
                      if (ret != null) {
                        Navigator.pushReplacementNamed(context, '/home',arguments: ret);
                      }
                    }
                ),
                margin: EdgeInsets.symmetric(vertical: 100.0, horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  color: Colors.redAccent,
                ),
              ),
            )
        )
    );
  }
}
