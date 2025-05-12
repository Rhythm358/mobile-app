import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/model/todo.dart';

class DatabaseTodo {
  static const _databaseName = "todos.db"; // データベース名
  static const _databaseVersion = 1; // スキーマのバージョン
  static final DatabaseTodo instance = DatabaseTodo._init();
  static Database? _database;

  DatabaseTodo._init();

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
      path, // データベースのパスを指定
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  // SQLiteデータベース内に新しいテーブルを作成
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT'; //整数型
    const textType = 'TEXT NOT NULL'; //文字列型
    const realType = 'REAL NOT NULL'; //浮動小数点型
    //const idType = 'INTEGER NOT NULL';

    // 外部キー制約有効化
    await db.execute('''
      PRAGMA foreign_keys = ON;
    ''');

    // 列名(カラム)と列に使用されるデータ型
    await db.execute('''
      CREATE TABLE $tableTodo ( 
        ${TodoFields.id}            $idType, 
        ${TodoFields.title}         $textType,
        ${TodoFields.time}          $textType,
        ${TodoFields.transparency}  $realType,
        ${TodoFields.characterSize} $realType,
        ${TodoFields.postitSize}    $realType,
        ${TodoFields.postit}        $textType,
        ${TodoFields.background}    $textType
      )
    ''');
  }

  // SQLiteデータベースに新しいメモを挿入し、
  // 挿入されたメモを含む新しいTodoオブジェクトを返します。
  Future<Todo> create(Todo todo) async {
    final db = await instance.database;
    final id = await db.insert(tableTodo, todo.toJson());
    //sprint('New TodoData: ${todo.toJson()}');
    return todo.copy(id: id);
  }

  // 指定されたIDのTodoオブジェクトをSQLiteデータベースから取得
  // もし、指定されたIDのメモが見つからなければ、例外がスローされます。
  Future<Todo> readTodo(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableTodo,
      columns: TodoFields.values,
      where: '${TodoFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Todo.fromJson(maps.first);
    } else {
      // throw Exception('ID $id not found');
      // Todoが見つからない場合、新しいTodoを作成して返す
      return Todo(
        id: id,
        title: '',
        createdTime: DateTime.now(),
        transparency: 20.0,
        characterSize: 20.0,
        postitSize: 10.0,
        postit: 'lib/images/postit/postit1.png',
        background: 'lib/images/background/background1.jpg',
      );
    }
  }

  // readAllTodo関数は、SQLiteデータベース内のすべての
  // Todoオブジェクトを取得し、時間順に並べ替えた結果を返します。
  // db.queryメソッドを使用して、テーブルtableTodoからすべての行を取得し、
  // その結果をJSON形式からTodoオブジェクトに変換して、リスト形式で返します。
  Future<List<Todo>> readAllTodo(bool isAscending) async {
    final db = await instance.database;
    //const orderBy = '${TodoFields.time} ASC'; //昇順:ASC 降順:DESC
    //bool isAscending = false; // デフォルトは昇順
    var orderBy = '${TodoFields.id} ${isAscending ? 'ASC' : 'DESC'}'; //昇順:ASC 降順:DESC
    //var orderBy = '${TodoFields.time} ${isAscending ? 'ASC' : 'DESC'}'; //昇順:ASC 降順:DESC
    final result = await db.query(tableTodo, orderBy: orderBy);
    return result.map((json) => Todo.fromJson(json)).toList();
  }

  // update関数は、指定されたTodoオブジェクトをSQLiteデータベースで
  // 更新するための非同期関数です。db.updateメソッドを使用して、
  // tableTodoテーブル内で指定されたIDを持つ行を検索し、
  // 新しいTodoオブジェクトで更新します。最後に、変更された行の数を返します。
  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return db.update(
      tableTodo,
      todo.toJson(),
      where: '${TodoFields.id} = ?',
      whereArgs: [todo.id],
    );
  }

  // delete関数は、指定されたIDを持つTodoオブジェクトを
  // SQLiteデータベースから削除するための非同期関数です。
  // db.deleteメソッドを使用して、tableTodoテーブル内で
  // 指定されたIDを持つ行を検索し、削除します。最後に、削除された行の数を返します。
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableTodo,
      where: '${TodoFields.id} = ?',
      whereArgs: [id],
    );
  }

  // close関数は、SQLiteデータベース接続を閉じるための非同期関数です。
  // db.closeメソッドを使用して、データベース接続を閉じます。
  Future close() async {
    Database? db = await instance.database;
    db = null;
    db?.close();
  }
}
