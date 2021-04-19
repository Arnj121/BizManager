import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database.dart';
import 'package:google_fonts/google_fonts.dart';

class Orders extends StatefulWidget {
  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Orders> {

  DatabaseHelper db = DatabaseHelper.instance;
  List<Map<String,dynamic>> items=[];
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  TextEditingController searchcont = TextEditingController();
  IconData icon = Icons.arrow_downward_sharp;String order='asc',column='completed';
  TextEditingController date=TextEditingController();
  TextEditingController month=TextEditingController();
  TextEditingController year=TextEditingController();
  int bid;bool visible=false;String Date;
  Future<bool> initData()async{
    items=[];
    bid = ModalRoute.of(context).settings.arguments;
    dynamic temp = await db.getOrders(bid, 0,order:order,column: column);
    temp.forEach((e){items.add(jsonDecode(jsonEncode(e)));});
    if(temp.length==0)
      visible=true;
    else visible =false;
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
        backgroundColor:Colors.white,
        appBar: AppBar(
          leading: BackButton(color: Colors.redAccent),
          title: Text(
            'Orders',
            style: GoogleFonts.openSans(
                color: Colors.redAccent[400]
            ),
          ),
          titleSpacing: 0,
          backgroundColor:Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(
                    Icons.refresh_sharp,
                    color: Colors.redAccent[400]
                ),
                onPressed: (){
                  FocusScope.of(context).unfocus();
                  initData();
                })
          ],
        ),
        body: CustomScrollView(
          slivers: [
            // SliverList(
            //   delegate: SliverChildListDelegate(
            //       [
            //         Center(
            //           child: Container(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 SizedBox(height: 20,),
            //                 CircleAvatar(
            //                   child: Icon(
            //                     Icons.book_sharp,
            //                     size: 40.0,
            //                     color: Colors.white,
            //                   ),
            //                   maxRadius: 40,
            //                   backgroundColor: Colors.redAccent[400],
            //                 ),
            //                 SizedBox(height: 20,),
            //                 Text(
            //                   'Orders',
            //                   style: GoogleFonts.openSans(
            //                       fontSize: 25.0,
            //                       color: Colors.blueGrey[800]
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //         SizedBox(height: 20,),
            //       ]
            //   ),
            // ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    child: TextField(
                      controller: searchcont,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal:10 ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[800],
                        ),
                        suffixIcon: IconButton(
                          icon:Icon(
                            Icons.cancel,
                            color: Colors.grey[800],
                          ),
                          onPressed: (){
                            searchcont.text='';
                            initData();
                          },
                        )
                      ),
                      onChanged: (text)async{
                        if(text.length>2){
                          dynamic t = await db.search('orders', bid, text);
                          this.setState(() {
                            if(t.length==0)
                              visible=true;
                            else
                              visible=false;
                            this.items=t;
                          });
                        }
                      },
                      cursorHeight: 20,
                      style: GoogleFonts.openSans(),
                    ),
                    height: 50,
                    margin: EdgeInsets.symmetric(vertical: 5,horizontal:10),
                  )
                ]
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                                'Search by date',
                                style: GoogleFonts.openSans(
                                  fontSize: 15
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                             label: Text(
                               'Search',
                               style: GoogleFonts.openSans(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white
                               ),
                              ),
                              icon: Icon(
                                Icons.search,
                                color: Colors.blueGrey[700],
                              ),
                              onPressed: ()async{
                               //TODO
                                dynamic date1 = date.text;
                                dynamic month1 = month.text;
                                dynamic year1 = year.text;

                                dynamic ret = await db.searchDate(bid, 'orders', date1, month1, year1);
                                date1 = date1.length==0? '*' : date1;
                                month1 = month1.length==0? '*' : month1;
                                year1 = year1.length==0? '*' : year1;
                                this.setState(() {
                                  items=ret;
                                  initData();
                                  Date=date1+'/'+month1+'/'+year1;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent[400])
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: TextField(
                                   controller: date,
                                   decoration: InputDecoration(
                                     border: OutlineInputBorder(),
                                     hintText: 'Date',
                                     hintStyle: GoogleFonts.openSans(),
                                       contentPadding: EdgeInsets.symmetric(vertical: 2,horizontal: 10)
                                   ),
                                    cursorHeight: 20,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  width: 70,
                                  height: 40,
                                  margin: EdgeInsets.symmetric(vertical: 0,horizontal: 3),
                                ),
                                Container(
                                  child: TextField(
                                    controller: month,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Month',
                                        hintStyle: GoogleFonts.openSans(),
                                        contentPadding: EdgeInsets.symmetric(vertical: 2,horizontal: 10)
                                    ),
                                    textAlign: TextAlign.center,
                                    cursorHeight: 20,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  width: 70,
                                  height: 40,
                                  margin: EdgeInsets.symmetric(vertical: 0,horizontal: 3),
                                ),
                                Container(
                                  child: TextField(
                                    controller: year,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Year',
                                        hintStyle: GoogleFonts.openSans(),
                                        contentPadding: EdgeInsets.symmetric(vertical: 2,horizontal: 10)
                                    ),
                                    cursorHeight: 20,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  width: 70,
                                  height: 40,
                                  margin: EdgeInsets.symmetric(vertical: 0,horizontal: 3),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  ),

                ]
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort by',
                            style: GoogleFonts.openSans(
                                fontSize: 15
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  icon,
                                  color: Colors.grey[700],
                                ),
                                onPressed: (){
                                  FocusScope.of(context).unfocus();
                                  if(this.order =='asc'){
                                    this.order='desc';
                                    icon = Icons.arrow_upward_sharp;
                                  }
                                  else{
                                    this.order='asc';
                                    icon = Icons.arrow_downward_sharp;
                                  }
                                  initData();
                                },
                              ),
                              TextButton(
                                  onPressed: (){
                                    FocusScope.of(context).unfocus();
                                    column='completed';
                                    initData();
                                  },
                                  child: Text(
                                      'Pending',
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.w700
                                    ),
                                  )
                              ),
                              TextButton(
                                  onPressed: (){
                                    FocusScope.of(context).unfocus();
                                    column='price';
                                    initData();
                                  },
                                  child: Text(
                                      'Price',
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w700
                                    ),
                                  )
                              ),
                              TextButton(
                                  onPressed: (){
                                    FocusScope.of(context).unfocus();
                                    column='date';
                                    initData();
                                  },
                                  child: Text(
                                      'Date',
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.w700
                                    ),
                                  )
                              )
                            ],
                          )
                        ],
                      ),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    ),
                    Divider(color: Colors.grey,),
                  ]
              ),
            ),
            SliverList(
                delegate:SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                      return orderBuilder(index);
                    },
                    childCount: this.items.length
                )
            ),
            SliverVisibility(
              visible: visible,
              sliver: SliverList(
                delegate:SliverChildListDelegate(
                  [
                    Center(
                    child:Text(
                      'No orders found',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[800],
                        fontSize: 20
                      ),
                      )
                    )
                  ]
                ),
              )
            )
          ],
        ),
      ),
    );
  }
  Container orderBuilder(int index){
    String txt;
    if(this.items[index]['completed']==1){
      DateTime d = DateTime.parse(this.items[index]['completedDate'].toString());
      txt = 'completed on '+d.day.toString()+' '+months[d.month]+' '+d.year.toString();
    }
    else
      txt='Due';
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            Icons.book_sharp,
            color:Colors.white,
            size:25,
          ),
          backgroundColor: Colors.redAccent[400],
        ),
        onTap: ()async{
          FocusScope.of(context).unfocus();
          dynamic ret = await Navigator.pushNamed(context, '/orderInfoPage',arguments: this.items[index]);
          if(ret!=null){
            if(ret['deleted']==1){
              this.setState((){
                this.items.removeAt(index);
              });
            }
          }
          },
        title: Text(
          this.items[index]['name'],
          style: GoogleFonts.openSans(
              color:Colors.grey[800],
              fontSize: 20
          ),
        ),
        trailing: Text(
          this.items[index]['price'].toString(),
          style: GoogleFonts.openSans(
              color:Colors.grey[800],
              fontSize: 15
          ),
        ),
        subtitle: Text(
          txt,
          style: GoogleFonts.openSans(
              color: Colors.grey[800]
          ),
        ),
      ),
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5.0),
    );
  }
}
