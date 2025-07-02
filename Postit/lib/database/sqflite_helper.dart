import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


//DatabaseHelperクラスには、次のような静的変数があります。
class DatabaseHelper {

  static const _databaseName = "MyDatabase.db"; // データベース名
  static const _databaseVersion = 1;            // スキーマのバージョン
  static const table = 'my_table';  // テーブル名
  static const columnId = '_id';    // カラム名：ID
  static const columnName = 'name'; // カラム名:Name
  static const columnAge  = 'age';  // カラム名:age

  // クラスの外部からインスタンスを生成することを防ぐためにプライベートに宣言
  // DatabaseHelper クラスを定義
  DatabaseHelper._privateConstructor();
  // DatabaseHelper._privateConstructor() コンストラクタを使用して生成されたインスタンスを返すように定義
  // DatabaseHelper クラスのインスタンスは、常に同じものであるという保証
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // データベースへのアクセスを簡単にするために、クラスのインスタンス全体で保持される、
  // SQLite データベースのインスタンスを格納するための変数
  // DBにアクセスするためのメソッド
  static Database? _database;
  Future<Database?> get database async {  // databaseメソッド定義(非同期処理)
    // _databaseがNULLか判定
    // NULLの場合、_initDatabaseを呼び出しデータベースの初期化し、_databaseに返す
    // NULLでない場合、そのまま_database変数を返す
    // これにより、データベースを初期化する処理は、最初にデータベースを参照するときにのみ実行されるようになります。
    // このような実装を「遅延初期化 (lazy initialization)」と呼びます。
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // データベースを開く。データベースがない場合は作る関数
  _initDatabase() async {
    // アプリケーションのドキュメントディレクトリのパスを取得
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // 取得パスを基に、データベースのパスを生成
    String path = join(documentsDirectory.path, _databaseName);
    // データベース接続
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // DBを作成するメソッド
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnAge INTEGER NOT NULL
      )
    ''');
  }

  // 挿入
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  // 全件取得、my_tableテーブル内のすべての行を取得するために使用
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }
  // データ件数取得
  Future<int?> queryRowCount() async {
    Database? db = await instance.database; //DBにアクセス
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }
  // 更新
  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!
        .update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
  // 削除、idパラメータで渡されたIDに対応する行を削除します。
  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

}
