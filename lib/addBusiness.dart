import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
import 'dart:math';

class AddBusiness extends StatefulWidget {
  @override
  _AddBusinessState createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {

  DatabaseHelper db = DatabaseHelper.instance;
  TextEditingController nameController = TextEditingController();
  Random rnd = Random();bool lightmode=true;
  DateTime d = DateTime.now();
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white : null,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: lightmode? Colors.white : null,
          leading: BackButton(
            color: Colors.redAccent,
          ),
          title:Text(
            'Add a Business',
            style: GoogleFonts.openSans(
                color: Colors.redAccent
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Center(
                      child:Container(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Enter a Business name',
                            labelStyle: GoogleFonts.openSans(
                              fontSize: 20.0
                            ),
                            border: OutlineInputBorder(),
                            focusColor: Colors.redAccent,
                          ),
                          autofocus: true,
                          cursorHeight: 20.0,
                        ),
                        height: 50.0,
                        width:200.0,
                        margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.0,),
                          Text(
                            'Registering on',
                            style: GoogleFonts.openSans(
                              color: Colors.deepPurpleAccent,
                            )
                          ),
                          SizedBox(height: 10.0,),
                          Text(
                            d.day.toString()+' '+months[d.month]+' '+d.year.toString(),
                            style: GoogleFonts.openSans(
                              color: lightmode? Colors.blueGrey[800] : Colors.white,
                              fontSize: 20.0
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Center(
                      child: Container(
                        child: TextButton.icon(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 0,horizontal: 10.0))
                          ),
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Add',
                            style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 20.0
                            ),
                          ),
                          onPressed: () async{
                            String name = this.nameController.text;
                            if(name.length==0){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:Text(
                                  'Enter a name',
                                  style: GoogleFonts.openSans(),
                                ),
                                duration: Duration(milliseconds: 600),
                              ));
                            }
                            else {
                              int id = rnd.nextInt(100000);
                              await db.addBusiness(id, name,0,0);
                              Navigator.pop(context,{'id':id,'name':name});
                            }
                          },
                        ),
                        margin: EdgeInsets.all(10.0),
                      ),
                    ),
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }
}
