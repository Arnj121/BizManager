import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
import 'package:percent_indicator/percent_indicator.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  DatabaseHelper db = DatabaseHelper.instance;
  List<Map<String,dynamic>> items = [];
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  //All the Business data that will be rendered
  List<Map<String,dynamic>> targets = [];
  Map<String,dynamic> currentData = {};
  List<Map<String,dynamic>> pendingOrders = [],total=[];
  List<Map<String,dynamic>> pendingPayments = [];
  List<Map<String,dynamic>> achievements = [];
  List<Map<String,dynamic>> recentOrders = [];
  //END
  int current=0;String name='New';

  Future<bool> getBusinessData({int m=0})async{
    dynamic temp;
    if(m==0) {
      temp = ModalRoute.of(context).settings.arguments;
      current = temp['id'];name = temp['name'];
    }
    targets = [];
    this.pendingOrders=[];this.pendingPayments=[];
    this.recentOrders=[];this.total=[];
    int todayEarn=0,monthEarn=0;

    temp = await db.getTargets(current);
    if(temp.length==0){
      Navigator.of(context).pushReplacementNamed('/loading');
    }
    else {
      currentData = temp[0];
      temp = await db.getPendingOrders(current);
      temp.forEach((e) {
        this.pendingOrders.add(jsonDecode(jsonEncode(e)));
      });

      temp = await db.getPendingPayments(current);
      temp.forEach((e) {
        this.pendingPayments.add(jsonDecode(jsonEncode(e)));
      });

      temp = await db.getRecentOrders(current);
      temp.forEach((e) {
        this.recentOrders.add(jsonDecode(jsonEncode(e)));
      });

      DateTime d, tod = DateTime.now();

      total = await db.getPayments(current, 0, 0);
      total.forEach((element) {
        d = DateTime.parse(element['date']);
        if (d.month == tod.month && d.year == tod.year &&
            element['hasPaid'] == 1) {
          monthEarn += element['amount'];
          if (d.day == tod.day)
            todayEarn += element['amount'];
        }
      });

      targets.add({
        'name': 'Daily',
        'target': currentData['dailyTarget'],
        'value': todayEarn
      });
      targets.add({
        'name': 'Monthly',
        'target': currentData['monthlyTarget'],
        'value': monthEarn
      });
      this.setState(() {
        targets = targets;
        name = name;
      });
      return true;
    }
  }

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getBusinessData();
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: Icon(
                Icons.book_sharp,
                color: Colors.redAccent,
                size: 30.0,
              ),
              title: Text(
                'BizManager',
                style: GoogleFonts.openSans(
                    color: Colors.redAccent,
                    fontWeight:FontWeight.bold
                ),
              ),
              titleSpacing: 2.0,
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon:Icon(
                    Icons.refresh,
                    color: Colors.redAccent[400],
                  ),
                  onPressed: ()async{
                    await this.getBusinessData(m:1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Refreshed',
                          style: GoogleFonts.openSans(),
                        ),
                        duration: Duration(milliseconds: 800),
                      )
                    );
                    },
                ),
                IconButton(
                  icon:Icon(
                    Icons.add,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                  onPressed: ()async {
                    dynamic ret= await Navigator.pushNamed(context, '/addnew');
                    if(ret!=null) {
                      // this.setState(() {
                      this.name = ret['name'];
                      this.current = ret['id'];
                      getBusinessData(m:1);
                      // });
                    }
                  },
                  // onPressed: ()async{
                  //   await db.clearAll();
                  // },
                )
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30,),
                        CircleAvatar(
                          child: Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          maxRadius: 40,
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        SizedBox(height: 10,),
                        Text(
                          this.name,
                          style: GoogleFonts.openSans(
                              fontSize: 25.0,
                              color: Colors.deepPurpleAccent
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          child: TextButton(
                            onPressed: ()async {
                              if(this.current!=0) {
                                dynamic ret = await Navigator.pushNamed(
                                    context, '/selectbiz');
                                if (ret != null) {
                                  // this.setState(() {
                                  this.name = ret['name'];
                                  this.current = ret['id'];
                                  // });
                                  this.getBusinessData(m:1);
                                }
                              }
                              else
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    'No business available',
                                    style: GoogleFonts.openSans(),
                                  ),
                                  duration: Duration(milliseconds: 1000),
                                ));
                            },
                            child: Text(
                              'Select',
                              style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontSize: 15.0
                              ),
                            ),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 0,horizontal: 5.0)),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                            ),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 0,horizontal: 10.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0,)
                ]
              )
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2
              ),
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                    return this.renderProgress(index);
                  },
                  childCount: this.targets.length
              ),
            ),
            SliverVisibility(
              visible: this.pendingOrders.length>0 ? true: false,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 20.0,),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              'Pending Orders',
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20.0
                              ),
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(
                              child: Text(
                                this.pendingOrders.length.toString(),
                                style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 12
                                ),
                              ),
                              maxRadius: 15,
                              backgroundColor: Colors.redAccent[400],
                            )

                          ],
                        ),
                        margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                      ),
                      SizedBox(height: 10.0,)
                    ]
                ),
              ),
            ),
            SliverVisibility(
              visible: this.pendingOrders.length==0? false: true,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                      return this.orderObject(index);
                    },
                    childCount: this.pendingOrders.length
                ),
              ),
            ),
            SliverVisibility(
              visible: this.pendingPayments.length>0 ? true:false,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 20.0,),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Payments due',
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20.0
                              ),
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(
                              child: Text(
                                this.pendingPayments.length.toString(),
                                style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 12
                                ),
                              ),
                              maxRadius: 15,
                              backgroundColor: Colors.orangeAccent,
                            )
                          ],
                        ),
                        margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                      ),
                      SizedBox(height: 10.0,)
                    ]
                ),
              ),
            ),

            SliverVisibility(
              visible: this.pendingPayments.length==0? false:true,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                      return this.paymentObject(index);
                    },
                    childCount: this.pendingPayments.length
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 20.0,),
                      Container(
                        child: Text(
                          'Recent orders',
                          style: GoogleFonts.openSans(
                              color: Colors.blueGrey[800],
                              fontSize: 20.0
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                      ),
                      SizedBox(height: 10.0)
                    ]
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                    return recentOrdersObject(index);
                  },
                  childCount: recentOrders.length
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                    if(this.recentOrders.length==0){
                      return Container(
                        child: Center(
                          child: Text(
                            'No recent orders',
                            style: GoogleFonts.openSans(
                                fontSize: 15.0,
                                color: Colors.blueGrey[800]
                            ),
                          ),
                        ),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      );
                    }
                    else return null;
                  },
                  childCount: 1
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: Colors.deepPurpleAccent,
            items:[
              BottomNavigationBarItem(
                icon:IconButton(
                  icon: Icon(
                    Icons.settings_applications_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: (){Navigator.pushNamed(context,'/manage');},
                ),
                label: 'Manage',
              ),
              BottomNavigationBarItem(
                  icon:IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: ()async{
                      dynamic ret =await Navigator.pushNamed(context, '/createOrder',arguments: current);
                      if(ret!=null){
                        this.setState(() {
                          if (ret['orders']['completed'] == 1)
                            this.recentOrders.add(ret['orders']);
                          else
                            this.pendingOrders.add(ret['orders']);
                          if (ret['payments']['hasPaid'] == 0)
                            this.pendingPayments.add(ret['payments']);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order added',
                              style: GoogleFonts.openSans(),
                            ),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      }
                    },
                  ),
                  label: 'Order'
              ),
              BottomNavigationBarItem(
                icon:IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: (){Navigator.pushNamed(context, '/settings',arguments:this.currentData['id']);},
                ),
                label: 'Settings',
              ),
            ]
        ),
      ),
    );
  }

  Container renderProgress(index) {
    dynamic percent=0.0;String txt='0.00 %';
    Color Font= Colors.orange,Back=Colors.orange[50],Prog=Colors.orangeAccent;
    if(this.targets[index]['target']>0){
      if(this.targets[index]['value']>=this.targets[index]['target']){
        Font=Colors.green;Back=Colors.green[50];Prog=Colors.greenAccent;
      }
      percent=this.targets[index]['value']/this.targets[index]['target'];
      txt=((this.targets[index]['value']/this.targets[index]['target'])*100).toStringAsFixed(1)+' %';
      if(percent>1.0){
        percent=1.0;
      }
    }
    Radius tl,tr,bl,br;
    double l,t,r,b;
    if(this.targets[index]['name']=='Daily'){
      tl=Radius.circular(10);bl=Radius.circular(10);
      tr=Radius.circular(0);br=Radius.circular(0);
      l=5;t=r=b=0;
    }
    else{
      tl=Radius.circular(0);bl=Radius.circular(0);
      tr=Radius.circular(10);br=Radius.circular(10);
      r=5;b=l=t=0;
    }
    return Container(
        child: CircularPercentIndicator(
          header: Text(
            this.targets[index]['value'].toString()+' / '+this.targets[index]['target'].toString(),
            style: GoogleFonts.openSans(
                color: Font,
                fontSize: 20.0
            ),
          ),
          percent: percent,
          radius: 120.0,
          backgroundColor: Back,
          progressColor: Prog,
          center: Text(
            txt,
            style: GoogleFonts.openSans(
              color: Prog,
              fontSize: 20.0
            ),
          ),
          animation: true,
          animationDuration: 1000,
          footer: Container(
            child: Text(
              this.targets[index]['name']+' Earnings',
              style: GoogleFonts.openSans(
                fontSize: 20.0,
                // color: Colors.orange[50]
                color: Colors.deepPurpleAccent[100],
              ),
            ),
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          ),
        ),
      decoration: BoxDecoration(
          // color: Colors.deepPurpleAccent[100],
          borderRadius: BorderRadius.only(topLeft: tl,topRight: tr,bottomLeft: bl,bottomRight:br),
      ),
      margin: EdgeInsets.fromLTRB(l, t, r, b),
    );
  }
  Container orderObject(index){
    return Container(
      child: ListTile(
        onTap: ()async{
          dynamic ret = await Navigator.pushNamed(context, '/orderInfoPage',arguments: this.pendingOrders[index]);
          if(ret!=null){
            if(ret['deleted']==1){
                for(int i=0;i<this.pendingPayments.length;i++){
                  if(this.pendingPayments[i]['id']==this.pendingOrders[index]['pid']){
                    this.pendingPayments.removeAt(i);
                    break;
                  }
                }
                this.pendingOrders.removeAt(index);
                this.setState(() {
                  this.pendingPayments=pendingPayments;
                  this.pendingOrders=pendingOrders;
                });
              }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Order deleted',
                style: GoogleFonts.openSans(),
              ),
              duration: Duration(milliseconds: 800),
            ));
          }
          },
        leading: CircleAvatar(
          child: Icon(
            Icons.book_sharp,
            color: Colors.redAccent,
          ),
          backgroundColor: Colors.white,
        ),
        title: Text(
          this.pendingOrders[index]['name'],
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20.0
          ),
        ),
        subtitle: Text(
          'Pending',
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
        trailing: Text(
          this.pendingOrders[index]['price'].toString(),
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.redAccent[400]
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 4.0),
      padding: EdgeInsets.all(5.0),
    );
  }
  Container paymentObject(index){
    String Due='';
    if(this.pendingPayments[index]['dueDate']=='')
      Due='no due date';
    else {
      DateTime d = DateTime.parse(this.pendingPayments[index]['dueDate']);
      Due='due on '+ d.day.toString()+' '+this.months[d.month]+ ' '+d.year.toString().substring(0,2);
    }
    return Container(
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, '/paymentInfoPage',arguments: this.pendingPayments[index]);
        },
        leading: CircleAvatar(
          child: Icon(
            Icons.payment_sharp,
            color: Colors.orangeAccent,
          ),
          backgroundColor: Colors.white,
        ),
        title: Text(
          this.pendingPayments[index]['name'],
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
        subtitle: Text(
          Due,
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
        trailing: Text(
          this.pendingPayments[index]['dueAmount'].toString(),
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.orangeAccent
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 4.0),
      padding: EdgeInsets.all(5.0),
    );
  }
  Container recentOrdersObject(int index){
    return Container(
      child: ListTile(
        onTap: () async{
          dynamic ret =await Navigator.pushNamed(context, '/orderInfoPage',arguments: this.recentOrders[index]);
          if(ret!=null){
            if(ret['deleted']==1){
              this.recentOrders.removeAt(index);
              this.setState(() {
                this.recentOrders=recentOrders;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Order deleted',
                  style: GoogleFonts.openSans(),
                ),
                duration: Duration(milliseconds: 800),
              ));
            }
          }
        },
        leading: CircleAvatar(
          child: Icon(
            Icons.book,
            color: Colors.deepPurpleAccent,
          ),
          backgroundColor: Colors.white,
        ),
        title: Text(
          this.recentOrders[index]['name'],
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
        subtitle: Text(
          'Click to view',
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
        trailing: Text(
          this.recentOrders[index]['price'].toString(),
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.deepPurpleAccent
      ),
    );
  }
}
