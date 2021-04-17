import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper{
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

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
              description text,
              price integer,
              date text,
              completed integer
    )
    ''');
    await db.execute('''create table achievements(
              id integer primary key,
              int bid,
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

  }


  Future<void> addBusiness(int id,String name,int dt,int mt)async {
    Database db = await database;
    await db.insert('business', {
      'id': id,
      'name': name,
      'date': DateTime.now(),
      'totalMoney': 0,
      'dailyTarget': dt,
      'monthlyTarget': mt
    });
    await db.insert('achievements', {
      'id': 324253,
      'bid': id,
      'daily': 'dailyTarget',
      'dtimes': 0,
      'monthly': 'monthlyTarget',
      'mtimes': 0
    });
    print(await db.query('business'));print(101);
  }
  Future<void> addOrder(int id,int pid,int bid,String name,String desc,int price,String date,String dueDate,String paidDate,int dueAmount,int hasPaid) async{
    Database db= await database;
    await db.insert('orders', {'id':id,'pid':pid,'bid':bid,'name':name,'description':desc,'price':price,'date':date,'completed':0});
    await db.insert('payments', {'id':pid,'oid':id,'bid':bid,'name':name,'date':date,'dueDate':dueDate,'paidData':paidDate,'amount':price,'dueAmount':dueAmount,'hasPaid':hasPaid});
  }

  Future<void> addPayment(int id,String name,int price,String date,String dueDate,String paidDate,int dueAmount,int hasPaid)async{
    Database db= await database;
    await db.insert('payments', {'id':id,'name':name,'date':date,'dueDate':dueDate,'paidData':paidDate,'amount':price,'dueAmount':dueAmount,'hasPaid':hasPaid});
  }

  Future<List<Map<String,dynamic>>> getOrders(int bid,int id) async{
    Database db= await database;
    if(id==0){
      List<Map<String, dynamic>> res = await db.query('orders');
      return res;
    }
    else {
      List<Map<String, dynamic>> res = await db.query('orders',where: 'id =?',whereArgs: [id]);
      return res;
    }
  }

  Future<List<Map<String,dynamic>>> getPendingOrders(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('orders',where:'bid=?, completed=?',whereArgs:[bid,0]);
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
      List<Map<String, dynamic>> res = await db.query('payments',where: 'id=?, bid=>',whereArgs: [id,bid]);
      print(res);
      print(143);
      return res;
    }
    else if(oid!=0){
      List<Map<String, dynamic>> res = await db.query('payments',where: 'oid=?, bid=?',whereArgs: [oid,bid]);
      print(res);
      print(149);
      return res;
    }
  }

  Future<List<Map<String,dynamic>>> getTodayPayments(int bid)async{
    Database db= await database;
    DateTime d = DateTime.now();
    List<Map<String, dynamic>> res = await db.query('payments',columns: ['sum(amount)'],where: 'bid=? and hasPaid=? and date like ?-?-?%',whereArgs: [bid,1,d.day,d.month,d.year]);
    print(res);
    print(158);
    return res;
  }

  Future<List<Map<String,dynamic>>> getPendingPayments(int bid) async{
    Database db= await database;
    List<Map<String, dynamic>> res = await db.query('payments',where: 'bid=?, hasPaid=?',whereArgs: [bid,0]);
    print(res);
    print(166);
    return res;
  }

  Future<List<Map<String,dynamic>>> getBusiness() async{
    Database db = await database;
    List<Map<String,dynamic>> res=await db.query('business',columns: ['id']);
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
    List<Map<String,dynamic>> res=await db.query('achievements',where: 'id=?',whereArgs: [id]);
    print(res);print(187);
    return res;
  }
}