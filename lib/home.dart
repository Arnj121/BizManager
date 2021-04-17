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
  List<Map<String,dynamic>> orders = [],total=[];
  List<Map<String,dynamic>> payments = [];
  List<Map<String,dynamic>> achievements = [];
  //END
  int empty=0;
  int current=0;String name='New';
  bool visible=false;
  Future<void> initData()async{
    items = await db.getBusiness();
    print(items);print(19);
    if(items.length==0){
      empty=1;
    }
    else {
      current = items[0]['id'];
      name = items[0]['name'];
      await this.getBusinessData();
      if (empty == 1)
        empty = 0;
    }
  }

  Future<void> getBusinessData()async{
    List<Map<String,dynamic>> temp = await db.getTargets(current);
    targets.add({'name':'daily','value':temp[0]['dailyTarget']});
    targets.add({'name':'monthly','value':temp[0]['monthlyTarget']});
    orders = await db.getPendingOrders(current);
    payments = await db.getPendingPayments(current);
    achievements = await db.getAchievements(current);
    total = await db.getTodayPayments(current);
    visible=true;
  }

  @override
  Widget build(BuildContext context) {
    this.initData();current=0;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.book_sharp,
                  color: Colors.redAccent,
                  size: 30.0,
                ),
                onPressed: (){},
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
                    Icons.add,
                    color: Colors.redAccent,
                  ),
                  // onPressed: ()async {
                  //   dynamic ret= await Navigator.pushNamed(context, '/addnew');
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
            SliverList(delegate: SliverChildBuilderDelegate(
                (BuildContext context,int index){
                  if(this.empty!=0)
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: TextButton(
                              onPressed: ()async {
                                if(this.empty!=1) {
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
                          // Divider(color: Colors.deepPurpleAccent,height: 10.0),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 5.0),
                    );
                  else return null;
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
                                  dynamic ret =Navigator.pushNamed(context, '/addnew');
                                  this.setState(() {
                                    this.name=ret['name'];
                                    this.current=ret['id'];
                                  });
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
                  SizedBox(height: 10.0,),
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
            // SliverList(
            //   delegate: SliverChildBuilderDelegate(
            //       (BuildContext context,int index){
            //         if(this.orders.length!=0){
            //           return Container(
            //             child: Center(
            //               child: Text(
            //                 'No Pending Orders',
            //                 style: GoogleFonts.openSans(
            //                   fontSize: 20.0,
            //                   color: Colors.blueGrey[800]
            //                 ),
            //               ),
            //             ),
            //             margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 3.0),
            //           );
            //         }
            //         else return null;
            //       },
            //     childCount: this.orders.length
            //   ),
            // ),
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                      return this.orderObject(index);
                    },
                    childCount: this.orders.length
                ),
              ),
            ),
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Center(
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label:Text(
                          'Create a order',
                          style: GoogleFonts.openSans(
                            color: Colors.white
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 0.0,horizontal: 10.0))
                        ),
                        onPressed: (){
                          Navigator.pushNamed(context, '/createOrder');
                        },
                      ),
                    ),
                    SizedBox(height: 10.0,)
                  ]
                ),
              ),
            ),
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
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
            SliverVisibility(
              visible: this.visible,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                      return this.paymentObject(index);
                    },
                    childCount: this.payments.length
                ),
              ),
            )
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
    return Container(
        child: CircularPercentIndicator(
          percent: 0.5,
          radius: 50.0,
          backgroundColor: Colors.purple[50],
          fillColor: Colors.deepPurpleAccent,
          center: Text(
            this.targets[index]['value'],
            style: GoogleFonts.openSans(
              color: Colors.orangeAccent
            ),
          ),
          animation: true,
          animationDuration: 700,
          footer: Text(
            this.targets[index]['name'],
            style: GoogleFonts.openSans(),
          ),
        ),
    );
  }

  Container orderObject(index){
    return Container(
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, '/orderInfoPage',arguments: this.orders[index]);
        },
        leading: Icon(
          Icons.book_sharp,
          color: Colors.white,
        ),
        title: Text(
          this.orders[index]['name'],
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
        subtitle: Text(
          'Pending',
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
        trailing: Text(
          this.orders[index]['price'],
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.redAccent
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 2.0),
      padding: EdgeInsets.all(5.0),
    );
  }
  Container paymentObject(index){
    DateTime d = DateTime.parse(this.payments[index]['dueDate']);
    return Container(
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, '/paymentInfoPage',arguments: this.payments[index]);
        },
        leading: Icon(
          Icons.book_sharp,
          color: Colors.white,
        ),
        title: Text(
          this.payments[index]['name'],
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
        subtitle: Text(
          'due on '+ d.day.toString()+' '+this.months[d.month]+ ' '+d.year.toString().substring(0,2),
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
        trailing: Text(
          this.payments[index]['dueAmount'],
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.redAccent
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 2.0),
      padding: EdgeInsets.all(5.0),
    );
  }

  Container renderBusinessModel(){
    return Container(
        child: Column(
          children: [

          ],
        ),
    );
  }
}
