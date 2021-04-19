import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
class Manage extends StatefulWidget {
  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> {

  List<Map<String,dynamic>> items=[];
  DatabaseHelper db = DatabaseHelper.instance;
  Future<bool> initData()async{
    items = await db.getBusiness();
    this.setState(() {});
    return true;
  }

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{initData(); });
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
            'Manage',
            style: GoogleFonts.openSans(
              color: Colors.deepPurpleAccent,
            ),
          ),
          titleSpacing: 0.0,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    return BusinessBuilder(index);
                  },
                childCount: this.items.length
              ),
            )
          ],
        ),
      ),
    );
  }
  Container BusinessBuilder(int index){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            child: Icon(
              Icons.business,
              size: 40,
              color: Colors.deepOrange,
            ),
            maxRadius: 40,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 10,),
          Text(
            this.items[index]['name'],
            style: GoogleFonts.openSans(
              color: Colors.blueGrey[800],
              fontSize: 25,fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10,),
          Text(
            this.items[index]['totalMoney'].toString()+' Earned',
            style: GoogleFonts.openSans(
              fontSize: 20,fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800]
            ),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.delete_outline_sharp,
                  color: Colors.redAccent[400],
                  size: 30,
                ),
                onPressed: (){},
              ),

            ],
          )
        ],
      ),
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.amberAccent
      )
    );
  }
}
