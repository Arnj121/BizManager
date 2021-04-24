import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';

class SelectBiz extends StatefulWidget {
  @override
  _SelectBizState createState() => _SelectBizState();
}

class _SelectBizState extends State<SelectBiz> {

  List<Map<String,dynamic>> items=[];
  bool lightmode=true;
  void initData() async{
    DatabaseHelper db = DatabaseHelper.instance;
    items=await db.getBusiness();
    this.setState(() {
      items=items;
    });
  }

  @override void initState() {
    super.initState();
    this.initData();
  }

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white : null,
          title: Text(
            'Select a business',
            style: GoogleFonts.openSans(
                color: Colors.redAccent
            ),
          ),
          titleSpacing: 0,
          leading: BackButton(color: Colors.redAccent),
        ),
        backgroundColor: lightmode?Colors.white : null,
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    return Container(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            Icons.business,
                            color: Colors.redAccent,
                          ),
                          maxRadius: 30,
                          backgroundColor: Colors.white,
                        ),
                        minLeadingWidth: 30.0,
                        onTap: (){
                          Navigator.pop(context,{'id':this.items[index]['id'],'name':this.items[index]['name']});
                        },
                        title: Text(
                          this.items[index]['name'],
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                        subtitle: Text(
                          'Click to select',
                          style: GoogleFonts.openSans(
                            color: Colors.white
                          ),
                        ),
                        trailing: Text(
                          this.items[index]['totalMoney'].toString(),
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 25.0
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.redAccent
                      ),
                    );
                  },childCount: this.items.length
              ),
            )
          ],
        ),
      ),
    );
  }
}
