import 'package:business/start.dart';
import 'package:business/manage.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'addBusiness.dart';
import 'selectbiz.dart';
import 'orderinfo.dart';
import 'createorder.dart';
import 'paymentinfo.dart';
import 'settings.dart';
import 'start.dart';
import 'loading.dart';
import 'payments.dart';
import 'orders.dart';

void main(){runApp(MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/loading',
      routes: {
        '/home':(context)=>Home(),
        '/addnew':(context)=>AddBusiness(),
        '/selectbiz':(context)=>SelectBiz(),
        '/orderInfoPage':(context)=>OrderInfo(),
        '/paymentInfoPage':(context)=>PaymentInfo(),
        '/createOrder':(context)=>CreateOrder(),
        '/manage':(context)=>Manage(),
        '/settings':(context)=>Settings(),
        '/loading':(context)=>Loading(),
        '/start':(context)=>Start(),
        '/payments':(context)=>Payments(),
        '/orders':(context)=>Orders()
      },
    );
  }
}
