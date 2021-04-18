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
              monthlyTarget integer
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
    await db.execute('''create table achievements(
              id integer primary key,
              bid integer,
              daily text,
              dtimes integer,
              monthly text,
              mtimes integer
    )
    ''');

  }

  Future<void> clearAll() async{
    Database db = await database;
    await db.delete('business',where: '1=1');
    await db.delete('orders',where: '1=1');
    await db.delete('payments',where: '1=1');
    await db.delete('achievements',where: '1=1');
  }


  Future<void> addBusiness(int id,String name,int dt,int mt)async {
    Database db = await database;
    await db.insert('business', {
      'id': id,
      'name': name,
      'date': DateTime.now().toString(),
      'totalMoney': 0,
      'dailyTarget': dt,
      'monthlyTarget': mt
    });
    await db.insert('achievements', {
      'id': rnd.nextInt(100000),
      'bid': id,
      'daily': 'dailyTarget',
      'dtimes': 0,
      'monthly': 'monthlyTarget',
      'mtimes': 0
    });
    print(await db.query('business'));print(await db.query('achievements'));print(101);
  }
  Future<void> addOrder(int id,int pid,int bid,String name,String desc,int price,String dueDate,String paidDate,int dueAmount,int hasPaid,int complete,String completedDate,String custname,int custid) async{
    Database db= await database;
    String date=DateTime.now().toString();
    await db.insert('orders', {'id':id,'pid':pid,'bid':bid,'name':name,'description':desc,'price':price,'date':date,'completedDate':completedDate,
      'completed':complete,'customerName':custname,'customerId':custid});
    await db.insert('payments', {'id':pid,'oid':id,'bid':bid,'name':name,'date':date,'dueDate':dueDate,'paidDate':paidDate,'amount':price,'dueAmount':dueAmount,'hasPaid':hasPaid});
    print(await db.query('orders'));print(await db.query('payments'));print(110);
  }

  // Future<void> addPayment(int id,String name,int price,String date,String dueDate,String paidDate,int dueAmount,int hasPaid)async{
  //   Database db= await database;
  //   await db.insert('payments', {'id':id,'name':name,'date':date,'dueDate':dueDate,'paidData':paidDate,'amount':price,'dueAmount':dueAmount,'hasPaid':hasPaid});
  // }

  Future<List<Map<String,dynamic>>> getOrders(int bid,int id) async{
    Database db= await database;
    if(id==0){
      List<Map<String, dynamic>> res = await db.query('orders',where: 'bid=?',whereArgs: [bid]);
      print(res);print(122);
      return res;
    }
    else {
      List<Map<String, dynamic>> res = await db.query('orders',where: 'bid=? and id =?',whereArgs: [bid,id]);
      print(res);print(127);
      return res;
    }
  }

  Future<List<Map<String,dynamic>>> getRecentOrders(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('orders',where: 'bid=? and completed=? order by date desc limit 5',whereArgs: [bid,1]);
    print(res);print(135);
    return res;
  }


  Future<List<Map<String,dynamic>>> getPendingOrders(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('orders',where:'bid=? and completed=? limit 5',whereArgs:[bid,0]);
    print(res);print(128);
    return res;
  }

  Future<List<Map<String,dynamic>>> getPayments(int bid,int id,int oid) async{
    Database db= await database;
    if(id==0 && oid==0){
      List<Map<String, dynamic>> res = await db.query('payments',where: 'bid=?',whereArgs: [bid]);
      print(res);
      print(137);
      return res;
    }
    else if(id!=0){
      List<Map<String, dynamic>> res = await db.query('payments',where: 'id=? and bid=?',whereArgs: [id,bid]);
      print(res);
      print(143);
      return res;
    }
    else if(oid!=0){
      List<Map<String, dynamic>> res = await db.query('payments',where: 'oid=? and bid=?',whereArgs: [oid,bid]);
      print(res);
      print(149);
      return res;
    }
  }

  Future<List<Map<String,dynamic>>> getTodayPayments(int bid)async{
    Database db= await database;
    DateTime d = DateTime.now();
    List<Map<String, dynamic>> res = await db.query('payments',columns: ['amount'],where: 'bid=? and hasPaid=? and date like ?-?-?',whereArgs: [bid,1,'${d.year}','%${d.month}','%${d.day}%']);
    print(res);
    print(158);
    return res;
  }

  Future<List<Map<String,dynamic>>> getPendingPayments(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('payments',where: 'bid=? and hasPaid=? limit 5',whereArgs: [bid,0]);
    print(res);
    print(166);
    return res;
  }

  Future<List<Map<String,dynamic>>> getBusiness() async{
    Database db = await database;
    List<Map<String,dynamic>> res=await db.query('business');
    print(res);print(173);
    return res;
  }

  Future<List<Map<String,dynamic>>> getTargets(int id) async{
    Database db = await database;
    List<Map<String,dynamic>> res=await db.query('business',where: 'id=?',whereArgs: [id]);
    print(res);print(180);
    return res;
  }

  Future<List<Map<String,dynamic>>> getAchievements(int id) async{
    Database db = await database;
    List<Map<String,dynamic>> res=await db.query('achievements',where: 'bid=?',whereArgs: [id]);
    print(res);print(187);
    return res;
  }

  Future<void> updatePayment(int bid,int id,int dueamt,String paidDate,int hasPaid)async{
    Database db = await database;
    db.update('payments', {'dueAmount':dueamt,'hasPaid':hasPaid,'paidDate':paidDate},
    where: 'bid=? and id=?',whereArgs: [bid,id]);
    print(await db.query('payments',where: 'bid=? and id=?',whereArgs: [bid,id]));
  }

  Future<void> updateOrder(int bid,int id,int completed,String date)async{
    Database db = await database;
    db.update('orders', {'completed':completed,'completedDate':date},where: 'id=? and bid=?',whereArgs: [id,bid]);
  }

}