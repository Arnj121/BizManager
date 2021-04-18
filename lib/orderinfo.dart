import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'database.dart';

class OrderInfo extends StatefulWidget {
  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  Map<String,dynamic> items={};
  String date='';String completed='Not completed';
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  DatabaseHelper db=  DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    items=ModalRoute.of(context).settings.arguments;
    print(items);
    DateTime temp=DateTime.parse(items['date']);
    date=temp.day.toString()+' '+months[temp.month]+' '+temp.year.toString();
    if(this.items['completedDate'].toString().length>0){
      temp = DateTime.parse(this.items['completedDate'].toString());
      completed=temp.day.toString()+' '+months[temp.month]+' '+temp.year.toString();
    }
    dynamic percent =0.0;
    if(this.items['completed']==1)
      percent=0.99;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: Colors.deepPurpleAccent),
          titleSpacing: 0,
          title: Text(
            'Order info',
            style: GoogleFonts.openSans(
              color: Colors.deepPurpleAccent
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    child: Center(
                      child: CircularPercentIndicator(
                        percent:percent,
                        center: Icon(
                          Icons.book_sharp,
                          color: Colors.redAccent[400],
                          size: 40.0,
                        ),
                        radius: 80.0,
                        animation: true,
                        animationDuration: 1000,
                        progressColor: Colors.deepPurpleAccent,
                        backgroundColor: Colors.purple[50],
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 10),
                  ),
                  Center(
                    child: Text(
                      this.items['name'],
                      style: GoogleFonts.openSans(
                        fontSize: 30.0,
                        color: Colors.blueGrey[800]
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Center(
                    child: Text(
                      this.items['description'],
                      style:GoogleFonts.openSans(
                        fontSize: 20.0
                      ) ,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Order date',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              date,
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Customer',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              this.items['customerName'].toString(),
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Price',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              this.items['price'].toString(),
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Completed',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              completed,
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Center(
                          child: TextButton(
                            child: Text(
                              'View order payment info',
                              style: GoogleFonts.openSans(),
                            ),
                            onPressed: ()async{
                              dynamic ret = await db.getPayments(this.items['bid'], this.items['pid'],0);
                              Navigator.pushNamed(context, '/paymentInfoPage',arguments: ret[0]);
                            },
                          ),
                        ),
                        SizedBox(height: 20.0),
                        OrderProcessor(this.items['completed'])
                      ],
                    ),
                    margin: EdgeInsets.fromLTRB(30, 100, 30, 0),
                  ),

                ]
              ),
            )
          ],
        ),
      ),
    );
  }
  Center OrderProcessor(int completed){
    if(completed==1)
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_sharp,
              color: Colors.green,
              size: 30.0,
            ),
            SizedBox(height: 10.0),
            TextButton(
              child: Text(
                'Completed',
                style: GoogleFonts.openSans(
                  fontSize: 20.0,
                  color: Colors.white
                ),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple[200]),
                  padding:  MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0))
              ),
              onPressed: ()async{
                this.items['completed']=0;this.items['completedDate'] ='';
                await db.updateOrder(this.items['bid'], this.items['id'], this.items['completed'], this.items['completedDate']);
                this.setState(() {
                  this.items=items;
                  this.completed='Not completed';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order updated',
                      style: GoogleFonts.openSans(),
                    ),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
            ),
          ],
        ),
      );
    else
      return Center(
        child: TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
              padding:  MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0))
          ),
          onPressed: ()async{
            DateTime t=DateTime.now();
            this.items['completed']=1;this.items['completedDate'] =t.toString();
            await db.updateOrder(this.items['bid'], this.items['id'], this.items['completed'], this.items['completedDate']);
            this.setState(() {
              this.items=items;
              this.completed=t.day.toString()+' '+months[t.month]+' '+t.year.toString();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order updated',
                  style: GoogleFonts.openSans(),
                ),
                duration: Duration(milliseconds: 800),
              ),
            );
          },
          child: Text(
            'Complete now',
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 20.0
            ),
          ),
        ),
      );
  }
}
