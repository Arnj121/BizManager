import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  int bid;
  dynamic items=[];
  int dailyTarget,monthlyTarget,dtimes,mtimes,total,OrdersCompleted,paymentsRec,paymentsDue,ordersrec;
  DatabaseHelper db = DatabaseHelper.instance;

  TextEditingController dcont = TextEditingController();
  TextEditingController mcont = TextEditingController();

  Future<bool> initData()async{
    bid =ModalRoute.of(context).settings.arguments;
    items = await db.getTargets(bid);items=items[0];
    dailyTarget =items['dailyTarget'];
    monthlyTarget =items['monthlyTarget'];
    dtimes=items['dtimes'];
    mtimes=items['mtimes'];
    total = items['totalMoney'];
    dcont.text=dailyTarget.toString();mcont.text=monthlyTarget.toString();
    OrdersCompleted =await db.getCompletedOrders(items['id'], 1);
    paymentsRec = await db.getCompletedPayments(items['id'], 1);
    paymentsDue=await db.getCompletedPayments(items['id'], 0);
    dynamic temp =await db.getOrders(items['id'], 0);
    ordersrec=temp.length;
    this.setState(() {});
    return true;
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: BackButton(color: Colors.deepPurpleAccent),
            title: Text(
              'Settings',
              style: GoogleFonts.openSans(
                color: Colors.deepPurpleAccent,
              ),
            ),
            titleSpacing: 0.0,
            actions: [
              IconButton(
                  icon: Icon(Icons.refresh, color: Colors.redAccent[400]),
                  onPressed: () {
                    this.initData();
                  })
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                    [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              child: Icon(
                                Icons.business,
                                color: Colors.white,
                                size: 50.0,
                              ),
                              backgroundColor: Colors.deepPurpleAccent,
                              maxRadius: 40,
                            ),
                            Text(
                              this.items['name'],
                              style: GoogleFonts.openSans(
                                  fontSize: 25.0,
                                  color: Colors.deepPurpleAccent
                              ),
                            ),
                            SizedBox(height: 20.0,)
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total revenue',
                              style: GoogleFonts.openSans(
                                  fontSize: 25.0,
                                  color: Colors.blueGrey[800]
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              total.toString(),
                              style: GoogleFonts.openSans(
                                  fontSize: 20.0,
                                  color: Colors.blueGrey[800]
                              ),
                            ),
                            SizedBox(height: 20,),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'Stats',
                                style:GoogleFonts.openSans(
                                  color:Colors.white,
                                  fontSize: 25
                                ),
                              )
                            ),
                            Container(
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Orders Received',
                                    style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        color: Colors.white
                                    ),
                                  ),
                                  Text(
                                      ordersrec.toString(),
                                      style:GoogleFonts.openSans(
                                          fontSize: 15.0,
                                          color: Colors.white
                                      )
                                  )
                                ],
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            ),
                            Container(
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Orders completed',
                                    style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        color: Colors.white
                                    ),
                                  ),
                                  Text(
                                      OrdersCompleted.toString(),
                                      style:GoogleFonts.openSans(
                                          fontSize: 15.0,
                                          color: Colors.white
                                      )
                                  )
                                ],
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            ),
                            Container(
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payments Received',
                                    style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        color: Colors.white
                                    ),
                                  ),
                                  Text(
                                      paymentsRec.toString(),
                                      style:GoogleFonts.openSans(
                                          fontSize: 15.0,
                                          color: Colors.white
                                      )
                                  )
                                ],
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            ),
                            Container(
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payments Due',
                                    style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        color: Colors.white

                                    ),
                                  ),
                                  Text(
                                      paymentsDue.toString(),
                                      style:GoogleFonts.openSans(
                                        fontSize: 15.0,
                                        color: Colors.white
                                      )
                                  )
                                ],
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 0),
                        margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5))
                        ),
                      ),
                      Container(
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'Average',
                                style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontSize: 25
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Daily',
                                  style: GoogleFonts.openSans(
                                    color:Colors.white,
                                    fontSize: 20
                                  ),
                                ),
                                Text(
                                  '0',
                                  style: GoogleFonts.openSans(
                                      color:Colors.white,
                                      fontSize: 20
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly',
                                  style: GoogleFonts.openSans(
                                      color:Colors.white,
                                      fontSize: 20
                                  ),
                                ),
                                Text(
                                  '0',
                                  style: GoogleFonts.openSans(
                                      color:Colors.white,
                                      fontSize: 20
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent[400],
                          borderRadius: BorderRadius.circular(5)
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                        padding: EdgeInsets.all(15),
                      ),
                      Center(
                        child:Container(
                          child: Text(
                            'Achievements',
                            style: GoogleFonts.openSans(
                              fontSize: 20
                            ),
                          ),
                          margin: EdgeInsets.all(10),
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                "Daily target",
                                style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 20.0
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(
                                      'Target',
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    ),
                                    Text(
                                      dailyTarget.toString()
                                          .toString(),
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    )
                                  ],
                                )
                            ),
                            SizedBox(height: 20,),
                            Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(
                                      'Times reached',
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    ),
                                    Text(
                                      dtimes.toString(),
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    )
                                  ],
                                )
                            )
                          ],
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.orange
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                      // SizedBox(height: 20),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                "Monthly target",
                                style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 20.0
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(
                                      'Target',
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    ),
                                    Text(
                                      monthlyTarget.toString(),
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    )
                                  ],
                                )
                            ),
                            SizedBox(height: 20,),
                            Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(
                                      'Times reached',
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    ),
                                    Text(
                                      mtimes.toString(),
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 20.0
                                      ),
                                    )
                                  ],
                                )
                            )
                          ],
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.orange
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Column(
                          children: [
                            Text(
                              'Set Daily Target',
                              style: GoogleFonts.openSans(
                                  fontSize: 15
                              ),
                            ),
                            SizedBox(height: 20,),
                            Container(
                              child: TextField(
                                controller: dcont,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Target',
                                    labelStyle: GoogleFonts.openSans()
                                ),
                                cursorHeight: 20,
                              ),
                              height: 50.0,
                              width: 100,
                            ),
                            TextButton(
                              child: Text(
                                'Set',
                                style: GoogleFonts.openSans(
                                    fontSize: 20
                                ),
                              ),
                              onPressed: () async {
                                dynamic target = dcont.text;
                                if (target.length == 0) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Enter a target',
                                      style: GoogleFonts.openSans(),
                                    ),
                                    duration: Duration(milliseconds: 800),
                                  ));
                                }
                                else {
                                  target = int.parse(target);
                                  await db.setLimit(this.items['id'], target, 'daily');
                                  // this.items['dailyTarget'] = target;
                                  this.setState(() {
                                    dailyTarget=target;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Target set',
                                      style: GoogleFonts.openSans(),
                                    ),
                                    duration: Duration(milliseconds: 800),
                                  ));
                                }
                              },
                            )
                          ],
                        ),
                        margin: EdgeInsets.all(5.0),
                      ),
                      SizedBox(height: 20.0,),
                      Container(
                        child: Column(
                            children: [
                              Text(
                                'Set monthly target',
                                style: GoogleFonts.openSans(
                                    fontSize: 15
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                child: TextField(
                                  controller: mcont,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Target',
                                      labelStyle: GoogleFonts.openSans()
                                  ),
                                  cursorHeight: 20,
                                ),
                                height: 50.0,
                                width: 100,
                              ),
                              TextButton(
                                child: Text(
                                  'Set',
                                  style: GoogleFonts.openSans(
                                      fontSize: 20
                                  ),
                                ),
                                onPressed: () async {
                                  dynamic target = mcont.text;
                                  if (target.length == 0) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        'Enter a target',
                                        style: GoogleFonts.openSans(),
                                      ),
                                      duration: Duration(
                                          milliseconds: 800),
                                    ));
                                  }
                                  else {
                                    target = int.parse(target);
                                    await db.setLimit(this.items['id'], target, 'monthly');
                                    this.setState(() {
                                      monthlyTarget=target;
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        'Target set',
                                        style: GoogleFonts.openSans(),
                                      ),
                                      duration: Duration(
                                          milliseconds: 800),
                                    ));
                                  }
                                },
                              )
                            ]
                        ),
                        margin: EdgeInsets.all(5.0),
                      ),
                    ]
                ),
              )
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.blueAccent[400],
            selectedItemColor: Colors.white,
            unselectedItemColor:Colors.white,
            items:[
              BottomNavigationBarItem(
                icon: IconButton(
                  icon: Icon(
                    Icons.book_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: (){Navigator.pushNamed(context, '/orders',arguments:this.items['id']);},
                ),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  icon: Icon(
                    Icons.payments_sharp,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: (){Navigator.pushNamed(context, '/payments',arguments:this.items['id']);},
                ),
                label: 'Payments',
              ),
            ]
          ),
        )
    );

  }
}
