import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
class CreateOrder extends StatefulWidget {
  @override
  _CreateOrderState createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {

  TextEditingController nameController = TextEditingController();
  TextEditingController custnameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Random rnd= Random();bool lightmode=true;
  DatabaseHelper db= DatabaseHelper.instance;
  int id,pid,bid;bool complete=false,paymentrec=false;
  String paymentdue='',paymentDueDate='';
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  DateTime d = DateTime.now();

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    bid = ModalRoute.of(context).settings.arguments;
    id = rnd.nextInt(100000);
    pid = rnd.nextInt(100000);
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white : null,
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white : null,
          leading: BackButton(color: Colors.deepPurpleAccent),
          title: Text(
            'Create Order',
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
                  Center(
                    child: Container(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Order name',
                            labelStyle: GoogleFonts.openSans(
                              color: Colors.deepPurpleAccent
                            ),
                          ),
                          cursorHeight: 20.0,
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      width: 200.0,
                      height: 50.0,
                    ),
                  ),
                  Center(
                    child: Container(
                      child: TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Order description',
                          hintText: 'optional',
                          hintStyle: GoogleFonts.openSans(),
                          labelStyle: GoogleFonts.openSans(
                              color: Colors.deepPurpleAccent
                          ),
                        ),
                        cursorHeight: 20.0,
                        maxLines: 5,
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      width: 200.0,
                    ),
                  ),
                  Center(
                    child: Container(
                      child: TextField(
                        controller: custnameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Customer name',
                          hintText: 'optional',
                          hintStyle: GoogleFonts.openSans(),
                          labelStyle: GoogleFonts.openSans(
                              color: Colors.deepPurpleAccent
                          ),
                        ),
                        cursorHeight: 20.0,
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      width: 200.0,
                    ),
                  ),
                  Center(
                    child: Container(
                      child: Column(
                        children: [
                          Text(
                            'Order date',
                            style: GoogleFonts.openSans(
                              color: Colors.deepPurpleAccent
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            d.day.toString()+' '+this.months[d.month]+' '+d.year.toString().substring(0,2),
                            style: GoogleFonts.openSans(
                              color: lightmode ?Colors.blueGrey[800]:Colors.white,
                              fontSize: 20.0
                            ),
                          )
                        ],
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      width: 200.0,
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Center(
                    child: Container(
                      child: TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Order payment',
                          labelStyle: GoogleFonts.openSans()
                        ),
                        keyboardType: TextInputType.number,
                        cursorHeight: 20.0,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      width: 200.0,
                      height: 50.0,
                    ),
                  ),
                  Center(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                  value: this.complete,
                                  onChanged: (value){
                                    this.setState(() {
                                      this.complete=value;
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                                activeColor: Colors.deepPurpleAccent,
                                fillColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                              ),
                              Text(
                                'Order completed  ',
                                style: GoogleFonts.openSans(
                                  color: Colors.deepPurpleAccent
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: this.paymentrec,
                                onChanged: (value){
                                  this.setState(() {
                                    this.paymentrec=value;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                activeColor: Colors.deepPurpleAccent,
                                fillColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                              ),
                              Text(
                                'Payment received',
                                style: GoogleFonts.openSans(
                                    color: Colors.deepPurpleAccent
                                ),
                              )
                            ],
                          ),
                          this.showDueDate()
                        ],
                      ),
                      width: 200.0,
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: TextButton(
                        child: Text(
                          'Create',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 0,horizontal: 10.0))
                        ),
                        onPressed: ()async{
                          String name = this.nameController.text;
                          dynamic price = this.priceController.text;
                          String desc = this.descController.text;
                          String cust=this.custnameController.text;
                          if(name.length==0 || price.length==0){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Enter all the field',
                                  style: GoogleFonts.openSans(),
                                ),
                                duration: Duration(milliseconds: 800),
                              )
                            );
                          }
                          else{
                            if(desc.length==0)
                              desc='';
                            if(cust.length==0)
                              cust='';
                            price=int.parse(price);
                            String paidDate='',completedDate='';int hasPaid=0,complete=0,dueAmt=price;
                            if(this.paymentrec) {
                              paidDate=DateTime.now().toString();
                              hasPaid=1;
                              dueAmt=0;
                            }
                            if(this.complete){
                              completedDate=DateTime.now().toString();
                              complete=1;
                            }
                            int custid=rnd.nextInt(100000);
                            await db.addOrder(id, pid, bid, name, desc, price, paymentDueDate, paidDate, dueAmt,hasPaid,complete,completedDate,cust,custid);
                            if(hasPaid==1) {
                              await db.updatePayment(bid, pid, dueAmt, paidDate, hasPaid);
                              await db.updateTotal(bid, price);
                              db.checkAchievements(bid);
                            }
                            Navigator.pop(context,{
                              'orders':{'id':id,'pid':pid,'bid':bid,'name':name,'customerName':cust,'customerId':custid,
                              'description':desc,'price':price,'date':DateTime.now(),'completedDate':completedDate,'completed':complete},
                              'payments':{'id':pid,'bid':bid,'oid':id,'name':name,'date':DateTime.now().toString(),
                              'dueDate':paymentDueDate,'paidDate':paidDate,'amount':price,'dueAmount':dueAmt,'hasPaid':hasPaid}
                            });
                          }

                        },
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),

                    ),
                  )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
  Center showDueDate(){
    if(this.paymentrec)
      return Center();
    else
      return Center(
        child: Column(
          children: [
            TextButton(
              child: Text(
                'Set payment due date',
                style: GoogleFonts.openSans(
                  color: Colors.blueAccent
                ),
              ),
              onPressed: DueDate,
            ),
            SizedBox(height: 10.0),
            Visibility(
              visible: this.paymentdue.length==0? false:true,
              child: Text(
                this.paymentdue,
                style: GoogleFonts.openSans(
                  color: Colors.deepPurpleAccent,
                  fontSize: 20.0
                ),
              ),
            )
          ],
        ),
      );
  }
  void DueDate(){
    DatePicker.showDatePicker(context,
      minTime: DateTime.now(),
      maxTime: DateTime(2030),
      onConfirm: (date){
        this.setState(() {
          this.paymentdue=date.day.toString()+' '+this.months[date.month]+' '+d.year.toString().substring(0,2);
          this.paymentDueDate=date.toString();
        });
      }
    );
  }
}
