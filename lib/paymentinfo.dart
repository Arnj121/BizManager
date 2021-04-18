import 'package:business/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PaymentInfo extends StatefulWidget {
  @override
  _PaymentInfoState createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {

  DatabaseHelper db=  DatabaseHelper.instance;
  Map<String,dynamic> items={};
  String date='',duedate='No due date',paiddate='Not paid';
  dynamic percent=0.0;
  TextEditingController controller  = TextEditingController();
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  Widget build(BuildContext context) {
    items = ModalRoute.of(context).settings.arguments;
    DateTime temp=DateTime.parse(items['date']);
    date=temp.day.toString()+' '+months[temp.month]+' '+temp.year.toString();
    if(items['dueDate'].length>0){
      temp=DateTime.parse(items['dueDate']);
      duedate=temp.day.toString()+' '+months[temp.month]+' '+temp.year.toString();
    }
    if(items['paidDate'].length>0){
      temp=DateTime.parse(items['paidDate']);
      paiddate=temp.day.toString()+' '+months[temp.month]+' '+temp.year.toString();
    }
    if(this.items['amount']>0)
      percent=(this.items['amount']-this.items['dueAmount'])/this.items['amount'];
    if(this.items['hasPaid']==0)
      controller.text=this.items['dueAmount'].toString();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Payments info',
            style: GoogleFonts.openSans(
              color: Colors.deepPurpleAccent
            ),
          ),
          titleSpacing: 0,
          leading: BackButton(color: Colors.deepPurpleAccent),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Center(
                    child: CircularPercentIndicator(
                      center: Icon(
                        Icons.payment_sharp,
                        color: Colors.deepPurpleAccent,
                        size: 40.0,
                      ),
                      radius: 80.0,
                      percent: percent,
                      progressColor: Colors.deepPurpleAccent,
                      backgroundColor: Colors.purple[50],
                      animation: true,
                      animationDuration: 600,
                    ),
                  ),
                  Center(
                    child: Container(
                      child: Text(
                        this.items['name'],
                        style: GoogleFonts.openSans(
                          fontSize: 30.0,
                          color: Colors.deepPurpleAccent[400]
                        ),
                      ),
                      margin: EdgeInsets.all(5.0),
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
                              'Amount',
                              style: GoogleFonts.openSans(
                                color: Colors.deepPurpleAccent,
                                fontSize: 25
                              ),
                            ),
                            Text(
                              this.items['amount'].toString(),
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
                              'Due date',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              duedate,
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
                              'Due Amount',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              this.items['dueAmount'].toString(),
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
                              'Paid date',
                              style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 25
                              ),
                            ),
                            Text(
                              paiddate,
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[800],
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 30.0),
                        PaymentGateway(this.items['hasPaid'])
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
  Center PaymentGateway(int hasPaid){
    if(hasPaid==0)
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Received',
                    labelStyle: GoogleFonts.openSans()
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                textAlign: TextAlign.center,
                cursorHeight: 20.0,
              ),
              width: 100.0,
              height: 50.0,
            ),
            SizedBox(height: 20.0,),
            TextButton(
              onPressed: ()async{
                dynamic price = controller.text;
                if(price.toString().length==0 || (price.toString().length>0 && int.parse(price)==0)){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Enter an amount',
                        style: GoogleFonts.openSans(),
                      ),
                      duration: Duration(milliseconds: 800),
                    ),
                  );
                }
                else{
                  price=int.parse(price);
                  if(price>this.items['dueAmount']){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Amount greater han due amount',
                          style: GoogleFonts.openSans(),
                        ),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  }
                  else{
                    print(this.items);print(260);
                    int hasPaid=0;
                    this.items['dueAmount']=this.items['dueAmount']-price;
                    if(this.items['dueAmount']==0){
                      hasPaid=1;
                      this.items['hasPaid']=hasPaid;
                      this.items['paidDate']=DateTime.now().toString();
                    }
                    print(this.items);print(267);
                    await db.updatePayment(this.items['bid'], this.items['id'], this.items['dueAmount'],this.items['paidDate'],hasPaid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Payment updated',
                          style: GoogleFonts.openSans(),
                        ),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                    this.setState(() {
                      this.items=items;
                    });
                  }
                }
              },
              child: Text(
                'Receive payment',
                style: GoogleFonts.openSans(
                    color: Colors.white,
                  fontSize: 20.0
                ),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                padding:  MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0))
              ),
            )
          ],
        ),
      );
    else
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_sharp,
              color: Colors.green,
              size: 30.0,
            ),
            SizedBox(height: 10.0),
            Container(
              child: Text(
                'Payment Received',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 20.0
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: Colors.deepPurple[200]
              ),
            )
          ],
        ),
      );
  }
}
