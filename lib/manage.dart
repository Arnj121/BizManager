import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
class Manage extends StatefulWidget {
  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  List<String> months=['Jan','Feb','Mar','Apr','May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  List<Map<String,dynamic>> items=[];
  List<bool> visibility=[],editing=[];List<TextEditingController> controllers=[];
  DatabaseHelper db = DatabaseHelper.instance;
  Future<bool> initData()async{
    dynamic temp = await db.getBusiness();
    temp.forEach((e){items.add(Map.from(e));});
    items.forEach((e){visibility.add(false);});
    items.forEach((e){editing.add(false);});
    items.forEach((e){controllers.add(TextEditingController());});
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
    DateTime d = DateTime.parse(this.items[index]['date'].toString());
    this.controllers[index].text=this.items[index]['name'];
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
          Visibility(
            visible: !this.editing[index],
            child: Text(
              this.items[index]['name'],
              style: GoogleFonts.openSans(
                color: Colors.blueGrey[800],
                fontSize: 25,fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Visibility(
            visible: this.editing[index],
            child: Container(
              child: TextField(
                controller: this.controllers[index],
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 2,horizontal: 10)
                ),
                cursorHeight: 20,
                textAlign: TextAlign.center,
              ),
              width: 100,
              height: 50,
            ),
          ),
          Visibility(
            visible: this.editing[index],
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:Icon(
                      Icons.cancel,
                      color: Colors.blueAccent[400],
                      size: 30,
                    ),
                    onPressed: ()async{
                      this.setState(() {
                        this.editing[index]=false;
                      });
                    },
                  ),
                  IconButton(
                    icon:Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: ()async{
                      String name=this.controllers[index].text;
                      if(name.length==0){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Enter a name',
                                style: GoogleFonts.openSans(),
                              ),
                              duration: Duration(milliseconds:800),
                            )
                        );
                      }
                      else{
                        await db.updateBusiness(name, this.items[index]['id']);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Name edited',
                            style: GoogleFonts.openSans(),
                          ),
                          duration: Duration(milliseconds:800),
                        ));
                        this.setState(() {
                          this.editing[index]=false;
                          this.items[index]['name']=name;
                        });
                      }
                    },
                  )
                ],
              ),
              width:150
            )
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
                  Icons.edit_outlined,
                  color: Colors.blueAccent[400],
                  size: 30,
                ),
                onPressed: (){
                  this.setState(() {
                    this.editing[index]=true;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_sharp,
                  color: Colors.redAccent[400],
                  size: 30,
                ),
                onPressed: ()async{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Remove this business? ',
                        style: GoogleFonts.openSans(),
                      ),
                      action: SnackBarAction(
                        label: 'Do it',
                        textColor: Colors.redAccent[400],
                        onPressed: ()async{
                          await db.DeleteBusiness(this.items[index]['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Business removed',
                                style: GoogleFonts.openSans(),
                              ),
                              duration: Duration(milliseconds: 800),
                            )
                          );
                          this.items.removeAt(index);
                          if(this.items.length==0){
                            Navigator.popAndPushNamed(context, '/loading');
                          }
                          else
                            this.setState(() {
                              this.items=items;
                            });
                        },
                      ),
                      duration: Duration(seconds: 5),
                    )
                  );
                },
              ),
            ],
          ),
          Visibility(
            visible: !this.visibility[index],
            child: TextButton(
              child: Text(
                  'More'
              ),
              onPressed: (){
                this.setState(() {
                  visibility[index]=true;
                });
              },
            ),
          ),
          Visibility(
            visible: visibility[index],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Text(
                  'Registered on '+d.day.toString()+' '+months[d.month]+' '+d.year.toString(),
                  style:GoogleFonts.openSans(
                    color: Colors.blueGrey,
                    fontSize: 15
                  )
                ),
              ],
            )
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
