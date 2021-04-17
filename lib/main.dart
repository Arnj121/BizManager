import 'package:flutter/material.dart';
import 'home.dart';
import 'addBusiness.dart';
import 'selectbiz.dart';
import 'orderinfo.dart';
import 'createorder.dart';
import 'paymentinfo.dart';
void main(){runApp(MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home':(context)=>Home(),
        '/addnew':(context)=>AddBusiness(),
        '/selectbiz':(context)=>SelectBiz(),
        '/orderInfoPage':(context)=>OrderInfo(),
        '/paymentInfoPage':(context)=>PaymentInfo(),
        '/createOrder':(context)=>CreateOrder(),

      },
    );
  }
}
