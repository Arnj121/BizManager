import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
class DatabaseHelper{
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;
  Random rnd=Random();
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''Create table business(
              id INTEGER PRIMARY KEY,
              name text not null,
              date text not null,
              totalMoney integer,
              dailyTarget integer,
              monthlyTarget integer,
              dtimes integer,
              mtimes integer,
              dlast text,
              mlast text
    )''');
    await db.execute('''CREATE table payments(
              id integer primary key,
              bid integer,
              oid integer,
              name text,
              date text,
              dueDate text,
              paidDate text,
              amount integer not null,
              dueAmount integer,
              hasPaid integer not null
    )
    ''');
    await db.execute('''Create table orders(
              id integer primary key,
              bid integer,
              pid integer,
              name text not null,
              customerName text,
              customerId integer,
              description text,
              price integer,
              date text,
              completedDate text,
              completed integer
    )
    ''');

  }

  Future<void> clearAll() async{
    Database db = await database;
    await db.delete('business',where: '1=1');
    await db.delete('orders',where: '1=1');
    await db.delete('payments',where: '1=1');
  }


  Future<void> addBusiness(int id,String name,int dt,int mt)async {
    Database db = await database;
    await db.insert('business', {
      'id': id,
      'name': name,
      'date': DateTime.now().toString(),
      'totalMoney': 0,
      'dailyTarget': dt,
      'monthlyTarget': mt,
      'mtimes':0,
      'dtimes':0,
      'dlast':'',
      'mlast':''
    });
  }
  Future<void> addOrder(int id,int pid,int bid,String name,String desc,int price,String dueDate,String paidDate,int dueAmount,int hasPaid,int complete,String completedDate,String custname,int custid) async{
    Database db= await database;
    String date=DateTime.now().toString();
    await db.insert('orders', {'id':id,'pid':pid,'bid':bid,'name':name,'description':desc,'price':price,'date':date,'completedDate':completedDate,
      'completed':complete,'customerName':custname,'customerId':custid});
    await db.insert('payments', {'id':pid,'oid':id,'bid':bid,'name':name,'date':date,'dueDate':dueDate,'paidDate':paidDate,'amount':price,'dueAmount':dueAmount,'hasPaid':hasPaid});
  }

  // Future<void> addPayment(int id,String name,int price,String date,String dueDate,String paidDate,int dueAmount,int hasPaid)async{
  //   Database db= await database;
  //   await db.insert('payments', {'id':id,'name':name,'date':date,'dueDate':dueDate,'paidData':paidDate,'amount':price,'dueAmount':dueAmount,'hasPaid':hasPaid});
  // }

  Future<List<Map<String,dynamic>>> getOrders(int bid,int id,{column=0,order=0}) async{
    Database db= await database;
    List<Map<String, dynamic>> res;
    if(id==0){
      if(column==0 && order==0)
        res = await db.query('orders',where: 'bid=?',whereArgs: [bid]);
      else
        res = await db.query('orders',where: 'bid=? order by $column $order',whereArgs: [bid]);
      return res;
    }
    else {
      res = await db.query('orders',where: 'bid=? and id =?',whereArgs: [bid,id]);
      return res;
    }
  }

  Future<void> deleteOrders(int id,bid)async{
    Database db= await database;
    dynamic t = await db.query('payments',where: 'oid=? and bid=?',whereArgs: [id,bid]);
    t = t[0]['amount']-t[0]['dueAmount'];
    await db.delete('orders',where:'id=? and bid=?',whereArgs:[id,bid]);
    await db.delete('payments',where:'oid=? and bid=?',whereArgs:[id,bid]);
    await this.updateTotal(bid, -t);
  }

  Future<int> getCompletedOrders(int bid,int completed)async{
    Database db= await database;
    dynamic temp = await db.query('orders',where: 'bid=? and completed=?',whereArgs: [bid,completed]);
    return temp.length;
  }


  Future<List<Map<String,dynamic>>> getRecentOrders(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('orders',where: 'bid=? and completed=? order by date desc limit 5',whereArgs: [bid,1]);
    return res;
  }


  Future<List<Map<String,dynamic>>> getPendingOrders(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('orders',where:'bid=? and completed=? limit 5',whereArgs:[bid,0]);
    return res;
  }

  Future<List<Map<String,dynamic>>> getPayments(int bid,int id,int oid,{order=0,column=0}) async{
    Database db= await database;
    List<Map<String, dynamic>> res=[];
    if(id==0 && oid==0){
      if(order==0 && column==0)
        res = await db.query('payments',where: 'bid=?',whereArgs: [bid]);
      else
        res = await db.query('payments',where: 'bid=? order by $column $order',whereArgs: [bid]);
      return res;
    }
    else if(id!=0){
      res = await db.query('payments',where: 'id=? and bid=?',whereArgs: [id,bid]);
      return res;
    }
    else if(oid!=0){
      List<Map<String, dynamic>> res = await db.query('payments',where: 'oid=? and bid=?',whereArgs: [oid,bid]);
      return res;
    }
  }

  Future<List<Map<String,dynamic>>> getCompletedPayments(int bid,int completed)async{
    Database db= await database;
    dynamic l = await db.query('payments',where:'bid=? and hasPaid=?',whereArgs: [bid,completed]);
    return l;
  }

  Future<List<Map<String,dynamic>>> getTodayPayments(int bid)async{
    Database db= await database;
    DateTime d = DateTime.now();
    List<Map<String, dynamic>> res = await db.query('payments',columns: ['amount'],where: 'bid=? and hasPaid=? and date like ?-?-?',whereArgs: [bid,1,'${d.year}','%${d.month}','%${d.day}%']);
    return res;
  }

  Future<List<Map<String,dynamic>>> getPendingPayments(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('payments',where: 'bid=? and hasPaid=? limit 5',whereArgs: [bid,0]);
    return res;
  }

  Future<List<Map<String,dynamic>>> getBusiness() async{
    Database db = await database;
    List<Map<String,dynamic>> res=await db.query('business');
    return res;
  }

  Future<List<Map<String,dynamic>>> getTargets(int id) async{
    Database db = await database;
    List<Map<String,dynamic>> res=await db.query('business',where: 'id=?',whereArgs: [id]);
    return res;
  }


  Future<void> updatePayment(int bid,int id,int dueamt,String paidDate,int hasPaid)async{
    Database db = await database;
    db.update('payments', {'dueAmount':dueamt,'hasPaid':hasPaid,'paidDate':paidDate},
    where: 'bid=? and id=?',whereArgs: [bid,id]);
  }

  Future<void> updateOrder(int bid,int id,int completed,String date)async{
    Database db = await database;
    db.update('orders', {'completed':completed,'completedDate':date},where: 'id=? and bid=?',whereArgs: [id,bid]);
  }

  Future<void> setLimit(int id,int target,String type) async{
    Database db = await database;
    await db.update('business', {type+'Target':target},where: 'id=?',whereArgs: [id]);
  }

  Future<void> updateTotal(int id,int incr) async{
    Database db = await database;
    dynamic t = await db.query('business',where: 'id=?',whereArgs: [id]);
    t = t[0]['totalMoney'];
    await db.update('business', {'totalMoney':incr+t},where: 'id=?',whereArgs: [id]);
  }

  Future<dynamic> search(table,int bid,String text)async{
    Database db = await database;
    dynamic l =await db.query(table,where: 'bid=? and name like ?',whereArgs: [bid,'%$text%']);
    return l;
  }

  Future<void> DeleteBusiness(int id)async{
    Database db = await database;
    await db.delete('business',where: 'id=?',whereArgs: [id]);
  }

  Future<void> updateBusiness(String name,int id)async{
    Database db = await database;
    await db.update('business', {'name':name},where:'id=?',whereArgs: [id]);
  }

  Future<void> checkAchievements(int bid) async{
    Database db = await database;
    DateTime d, tod = DateTime.now();
    dynamic temp,dates =await db.query('business',where:'id=?',whereArgs: [bid]);
    temp = await this.getCompletedPayments(bid, 1);
    int todayEarn=0,monthEarn=0;
    temp.forEach((element) {
      d = DateTime.parse(element['date']);
      if (d.month == tod.month && d.year == tod.year) {
        monthEarn += element['amount'];
        if (d.day == tod.day)
          todayEarn += element['amount'];
      }
    });
    if(dates[0]['dlast'].length>0) {
      DateTime dlast = DateTime.parse(dates[0]['dlast']);
      if (dlast.day != tod.day && todayEarn >= dates[0]['dailyTarget']) {
          await db.update('business', {
            'dlast': DateTime.now().toString(),
            'dtimes': dates[0]['dtimes'] + 1
          });
          print(264);
      }
    }
    else if( todayEarn >= dates[0]['dailyTarget']){
      await db.update('business', {
        'dlast': DateTime.now().toString(),
        'dtimes': dates[0]['dtimes'] + 1
      });
      print(272);
    }
    if(dates[0]['mlast'].length>0) {
      DateTime mlast = DateTime.parse(dates[0]['mlast']);
      if (mlast.month != tod.month && monthEarn >= dates[0]['monthlyTarget']) {
          await db.update('business', {
            'mlast': DateTime.now().toString(),
            'mtimes': dates[0]['mtimes'] + 1
          });
          print(280);
      }
    }
    else if(monthEarn >= dates[0]['monthlyTarget']){
      await db.update('business', {
        'mlast': DateTime.now().toString(),
        'mtimes': dates[0]['mtimes'] + 1
      });
      print(288);
    }
  }

  Future<dynamic> searchDate(bid,table,date,month,year) async{
    Database db = await database;String pattern='';
    if(year.length==0)
      pattern+='____';
    else
      pattern+=year.toString();
    pattern+='-';
    if(month.length==0)
      pattern+='__';
    else{
      month = month.toString().length==1 ?'0'+month.toString() :month.toString();
      pattern+=month;
    }
    pattern+='-';
    if(date.length==0)
      pattern+='__';
    else{
      date = date.toString().length==1 ?'0'+date.toString() :date.toString();
      pattern+=date;
    }
    pattern+='%';
    print(pattern);
    dynamic l;
    if(table=='orders')
      l =await db.query(table,where: 'bid=? and date like ?',whereArgs: [bid,pattern]);
    else
      l = await db.query(table,where:'bid=? and paidDate like ?',whereArgs: [bid,pattern]);
    print(l);
    return l;
  }

}