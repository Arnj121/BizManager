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
  List<Map<String,dynamic>> pendingOrders = [],total=[];
  List<Map<String,dynamic>> pendingPayments = [];
  List<Map<String,dynamic>> achievements = [];
  List<Map<String,dynamic>> recentOrders = [];
  //END
  int current=0;String name='New';
  bool visible=false;
  Future<void> initData()async{
    items = await db.getBusiness();
    print(items);print(19);
    if(items.length==0){
      current=0;
      name='New';
    }
    else {
      current = items[0]['id'];
      name = items[0]['name'];
      await this.getBusinessData();
    }
  }

  Future<void> getBusinessData()async{
    this.pendingOrders=[];this.pendingPayments=[];
    this.recentOrders=[];this.total=[];
    int todayEarn=0,monthEarn=0;
    List<Map<String,dynamic>> temp=[];

    items=await db.getBusiness();

    temp = await db.getPendingOrders(current);
    temp.forEach((e){this.pendingOrders.add(jsonDecode(jsonEncode(e)));});

    temp = await db.getPendingPayments(current);
    temp.forEach((e){this.pendingPayments.add(jsonDecode(jsonEncode(e)));});

    achievements = await db.getAchievements(current);

    temp= await db.getRecentOrders(current);
    temp.forEach((e){this.recentOrders.add(jsonDecode(jsonEncode(e)));});

    DateTime d,tod = DateTime.now();

    total = await db.getPayments(current,0,0);
    total.forEach((element){
      d = DateTime.parse(element['date']);
      if(d.month==tod.month && d.year == tod.year && element['hasPaid']==1){
        monthEarn+=element['amount'];
        if(d.day == tod.day)
          todayEarn+=element['amount'];
      }
    });

    targets.add({'name':'Daily','target':this.items[0]['dailyTarget'],'value':todayEarn});
    targets.add({'name':'Monthly','target':this.items[0]['monthlyTarget'],'value':monthEarn});

    this.setState(() {
      visible=true;
    });
  }

  @override
  void initState(){
    super.initState();
    this.initData();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Icon(
                  Icons.book_sharp,
                  color: Colors.redAccent,
                  size: 30.0,
                ),
              title: Text(
                'BizManager',
                style: GoogleFonts.openSans(
                  color: Colors.redAccent
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
                  onPressed: ()async{await this.getBusinessData();},
                ),
                IconButton(
                  icon:Icon(
                    Icons.add,
                    color: Colors.redAccent,
                  ),
                  // onPressed: ()async {
                  //   dynamic ret= await Navigator.pushNamed(context, '/addnew');
                  //   if(ret!=null)
                    //   this.setState(() {
                    //      name=ret['name'];
                    //      current = ret['id'];
                    //   });
                  // },
                  onPressed: ()async{
                    await db.clearAll();
                  },
                )
              ],
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                (BuildContext context,int index){
                  // if(this.empty!=0)
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: TextButton(
                              onPressed: ()async {
                                if(this.current!=0) {
                                  dynamic ret = await Navigator.pushNamed(
                                      context, '/selectbiz');
                                  print(ret);
                                  print(81);
                                  if (ret != null)
                                    this.setState(() {
                                      this.name = ret['name'];
                                      this.current = ret['id'];
                                    });
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
                                this.name,
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
                          Visibility(
                            child: TextButton.icon(
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label:Text(
                                'Create a order',
                                style: GoogleFonts.openSans(
                                    color: Colors.white
                                )
                              ),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 0.0,horizontal: 10.0))
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
                            visible: this.visible,
                            ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 5.0),
                    );
                  // else return null;
                },childCount: 1
            )),
            SliverVisibility(
              visible: !(this.visible),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context,int index) {
                      // if(this.empty==1)
                        return Container(
                            child: TextButton.icon(
                                icon: Icon(Icons.add,color: Colors.white,),
                                label:Text('Tap to add a business',
                                  style: GoogleFonts.openSans(
                                      fontSize: 20.0,
                                      color: Colors.white
                                    ),
                                  ),
                                  onPressed: () async{
                                  dynamic ret =await Navigator.pushNamed(context, '/addnew');
                                  print(ret);print(176);
                                  if(ret!=null) {
                                    this.setState(() {
                                      this.name = ret['name'];
                                      this.current = ret['id'];
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Business added',
                                          style: GoogleFonts.openSans(),
                                        ),
                                        duration: Duration(milliseconds: 800),
                                      ),
                                    );
                                    this.getBusinessData();
                                  }
                                }
                                ),
                            margin: EdgeInsets.symmetric(vertical: 100.0,horizontal: 10),
                            padding: EdgeInsets.symmetric(vertical: 3.0,horizontal: 0.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Colors.redAccent,
                          ),
                        );
                      // else return null;
                    },
                  childCount: 1
                ),
              ),
            ),
            //Progress bars
            SliverVisibility(
              visible: this.visible,
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2
                ),
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context,int index){
                        return this.renderProgress(index);
                    },
                  childCount: 2
                ),
              ),
            ),
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 20.0,),
                  Container(
                    child: Text(
                      'Pending Orders',
                      style: GoogleFonts.openSans(
                        color: Colors.blueGrey[800],
                        fontSize: 20.0
                      ),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                  ),
                  SizedBox(height: 10.0,)
                ]
              ),
            ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    if(this.pendingOrders.length==0 && this.visible){
                      return Container(
                        child: Center(
                          child: Text(
                            'No Pending Orders',
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
            SliverVisibility(
              visible: this.visible,
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
              visible: this.visible,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: 20.0,),
                    Container(
                      child: Text(
                        'Payments due',
                        style: GoogleFonts.openSans(
                          color: Colors.blueGrey[800],
                          fontSize: 20.0
                        ),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                    ),
                    SizedBox(height: 10.0,)
                  ]
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    if(this.pendingPayments.length==0 && this.visible){
                      return Container(
                        child: Center(
                          child: Text(
                            'No Payments Due',
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
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                          print(this.pendingPayments.length);print(408);
                          return this.paymentObject(index);
                          },
                    childCount: this.pendingPayments.length
                ),
              ),
            ),
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
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
                    if(this.recentOrders.length==0 && this.visible){
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
          backgroundColor: Colors.white,
          items:[
            BottomNavigationBarItem(
              icon:IconButton(
                icon: Icon(
                  Icons.settings_applications_sharp,
                  color: Colors.deepPurpleAccent,
                ),
                onPressed: (){},
              ),
              label: 'Manage',
            ),
            BottomNavigationBarItem(
                icon:IconButton(
                  icon: Icon(
                    Icons.payments_sharp,
                    color: Colors.deepPurpleAccent,
                  ),
                  onPressed: (){},
                ),
              label: 'Payments'
            ),
            BottomNavigationBarItem(
                icon:IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.deepPurpleAccent,
                  ),
                  onPressed: (){},
                ),
              label: 'Info',
            ),
          ]
        ),
      ),
    );
  }

  Container renderProgress(index) {
    dynamic percent=0.0;String txt='0.00 %';
    if(this.targets[index]['target']>0){
      percent=this.targets[index]['value']/this.targets[index]['target'];
      txt=((this.targets[index]['value']/this.targets[index]['target'])*100).toStringAsFixed(2);
      if(percent>1.0){
        percent=1.0;
      }
    }
    return Container(
        child: CircularPercentIndicator(
          header: Text(
            this.targets[index]['value'].toString()+'/'+this.targets[index]['target'].toString(),
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 20.0
            ),
          ),
          percent: percent,
          radius: 120.0,
          backgroundColor: Colors.orange[50],
          fillColor: Colors.deepPurpleAccent,
          progressColor: Colors.orangeAccent,
          center: Text(
            txt,
            style: GoogleFonts.openSans(
              color: Colors.orangeAccent,
              fontSize: 30.0
            ),
          ),
          animation: true,
          animationDuration: 700,
          footer: Container(
            child: Text(
              this.targets[index]['name']+' Earnings',
              style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: Colors.orange[50]
              ),
            ),
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          ),
        ),
    );
  }
  Container orderObject(index){
    return Container(
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, '/orderInfoPage',arguments: this.pendingOrders[index]);
        },
        leading: Icon(
          Icons.book_sharp,
          color: Colors.white,
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
        leading: Icon(
          Icons.book_sharp,
          color: Colors.white,
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
        onTap: (){
          Navigator.pushNamed(context, '/orderInfoPage',arguments: this.recentOrders[index]);
        },
        leading: Icon(
          Icons.book,
          color: Colors.white,
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
