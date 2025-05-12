
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/model/memo.dart';
import 'package:todo/model/todo.dart';


class DatabaseMemo {
  static const _databaseName = "memos.db"; // データベース名
  static const _databaseVersion = 1;       // スキーマのバージョン
  static final DatabaseMemo instance = DatabaseMemo._init();
  static Database? _database;

  DatabaseMemo._init();

  // databaseメソッド定義
  // データベースのインスタンスを取得(非同期処理)
  // NULLの場合、_initDatabaseを呼び出しデータベースの初期化し、_databaseに返す
  // NULLでない場合、そのまま_database変数を返す
  // これにより、データベースを初期化する処理は、最初にデータベースを参照するときにのみ実行されるようになります。
  // このような実装を「遅延初期化 (lazy initialization)」と呼びます。
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }
  // データベースを初期化
  // データベースを開き、必要に応じて_createDB()メソッドを呼び出してテーブルを作成
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,    // データベースのパスを指定
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }
  // SQLiteデータベース内に新しいテーブルを作成
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT'; //整数型
    const textType = 'TEXT NOT NULL';       //文字列型
    const realType = 'REAL NOT NULL';       //浮動小数点型
    const integerType = 'INTEGER NOT NULL'; //整数型
    //const idType = 'INTEGER NOT NULL';
    //const boolType = 'BOOLEAN NOT NULL';

    // 外部キー制約有効化
    await db.execute('''
      PRAGMA foreign_keys = ON;
    ''');

    // 列名(カラム)と列に使用されるデータ型
    await db.execute('''
      CREATE TABLE $tableMemo (
        ${MemoFields.id} $idType, 
        ${MemoFields.positionX} $realType,
        ${MemoFields.positionY} $realType,
        ${MemoFields.description} $textType,
        ${MemoFields.done} $integerType,
        ${MemoFields.todoId} INTEGER, -- todoデータベースのidを参照する外部キー
        FOREIGN KEY (${MemoFields.todoId}) REFERENCES $tableTodo(${TodoFields.id}) ON DELETE CASCADE -- 外部キー制約を追加
      )
    ''');
  }
  // データベースのバージョンをチェックして、
  // 古いバージョンから新しいバージョンにアップグレードする必要がある場合に、テーブルに新しいカラムを追加
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the "todo_id" column to the "memos" table
      await db.execute('ALTER TABLE $tableMemo ADD COLUMN ${MemoFields.todoId} INTEGER');
    }
  }
  // SQLiteデータベースに新しいメモを挿入し、
  // 挿入されたメモを含む新しいMemoオブジェクトを返します。
  Future<Memo> create(Memo memo) async {
    final db = await instance.database;
    final id = await db.insert(tableMemo, memo.toJson());
    print('New MemoData: ${memo.toJson()}');
    return memo.copy(id: id);
  }

  // 指定されたIDのTodoオブジェクトをSQLiteデータベースから取得
  // もし、指定されたIDのメモが見つからなければ、例外がスローされます。
  Future<Memo> readMemo(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableMemo,
      columns: MemoFields.values,
      where: '${MemoFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Memo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }
  // SQLiteデータベース内のすべてのMemoオブジェクトを取得した結果を返します。
  // db.queryメソッドを使用して、テーブルtableTodoからすべての行を取得し、
  // その結果をJSON形式からTodoオブジェクトに変換して、リスト形式で返します。
  Future<List<Memo>> readAllMemo(int id) async {
    final db = await instance.database;
    final result = await db.query(tableMemo);
    return result.map((json) => Memo.fromJson(json)).toList();
  }
  // update関数は、指定されたTodoオブジェクトをSQLiteデータベースで
  // 更新するための非同期関数です。db.updateメソッドを使用して、
  // tableTodoテーブル内で指定されたIDを持つ行を検索し、
  // 新しいTodoオブジェクトで更新します。最後に、変更された行の数を返します。
  Future<int> update(Memo memo) async {
      print('Update MemoData: ${memo.toJson()}');
      final db = await instance.database;
      return db.update(
        tableMemo,
        memo.toJson(),
        where: '${MemoFields.id} = ?',
        whereArgs: [memo.id],
      );
  }
  // delete関数は、指定されたIDを持つTodoオブジェクトを
  // SQLiteデータベースから削除するための非同期関数です。
  // db.deleteメソッドを使用して、tableTodoテーブル内で
  // 指定されたIDを持つ行を検索し、削除します。最後に、削除された行の数を返します。
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableMemo,
      where: '${MemoFields.id} = ?',
      whereArgs: [id],
    );
  }
  // todoIdに一致するレコードを削除
  Future<int> deleteMemoByTodoId(int todoId) async {
    final db = await instance.database;
    return await db.delete(
      tableMemo,
      where: '${MemoFields.todoId} = ?', // `todoId`を条件として指定
      whereArgs: [todoId],
    );
  }
  // close関数は、SQLiteデータベース接続を閉じるための非同期関数です。
  // db.closeメソッドを使用して、データベース接続を閉じます。
  Future close() async {
    Database? db = await instance.database;
    db = null;
    db?.close();
  }
  // todoId に対応する列（レコード）を取得
  Future<List<Memo>> readMemoByTodoId(int todoId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableMemo,
      columns: MemoFields.values,
      where: '${MemoFields.todoId} = ?', // `todoId`を条件として指定
      whereArgs: [todoId],
    );
    // レコードが見つかった場合はMemoオブジェクトのリストに変換して返す
    if (maps.isNotEmpty) {
      return maps.map((map) => Memo.fromJson(map)).toList();
    } else {
      return []; // レコードが見つからない場合は空のリストを返す
    }
  }


}
