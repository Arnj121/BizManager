import 'package:flutter/material.dart';
import 'database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  DatabaseHelper db = DatabaseHelper.instance;
  List<Map<String,dynamic>> items=[];
  Future<void> initData()async{
    items = await db.getBusiness();
    if(items.length==0)
      Navigator.pushReplacementNamed(context, '/start');
    else
      Navigator.pushReplacementNamed(context, '/home',arguments: items[0]);
  }
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{initData();});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SpinKitFoldingCube(
                size: 50.0,
                color: Colors.blueAccent,
                duration: Duration(milliseconds: 1000),
              )
            )
        )
    );
  }
}
