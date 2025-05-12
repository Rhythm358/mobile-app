import 'package:todo/ui/memo_screen.dart';

const String tableTodo = 'todos';

// Todoオブジェクトの各フィールドの名前を保持する静的クラス
// これにより、オブジェクトのフィールドの名前をプログラム全体で一貫して使用できます。
class TodoFields {
  static final List<String> values = [
    id,
    title,
    time,
    transparency,
    characterSize,
    postitSize,
    postit,
    background,
  ];
  static const String id = '_id';
  static const String title = 'title';
  static const String time = 'time';
  static const String transparency = 'transparency';
  static const String characterSize = 'characterSize';
  static const String postitSize = 'postitSize';
  static const String postit = 'postit';
  static const String background = 'background';
}

// Todoクラスには、コンストラクタ、copy()メソッド、
// およびtoJson()およびfromJson()メソッドが含まれています。
class Todo {
  int? id;
  final String title;
  final DateTime createdTime;
  final double transparency;
  final double characterSize;
  final double postitSize;
  final String postit;
  final String background;

  // コンストラクタは、Catatanオブジェクトを作成するために使用されます。
  Todo({
    this.id,
    required this.title,
    required this.createdTime,
    required this.transparency,
    required this.characterSize,
    required this.postitSize,
    required this.postit,
    required this.background,
  });

  // 既存のTodoオブジェクトを複製し、必要に応じて値を変更します。
  Todo copy({
    int? id,
    String? title,
    DateTime? createdTime,
    double? transparency,
    double? characterSize,
    double? postitSize,
    String? postit,
    String? background,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        createdTime: createdTime ?? this.createdTime,
        transparency: transparency ?? this.transparency,
        characterSize: characterSize ?? this.characterSize,
        postitSize: postitSize ?? this.postitSize,
        postit: postit ?? this.postit,
        background: background ?? this.background,
      );

  // JSON形式のマップからTodoオブジェクトを作成します。
  static Todo fromJson(Map<String, Object?> json) => Todo(
        id: json[TodoFields.id] as int?,
        title: json[TodoFields.title] as String,
        createdTime: DateTime.parse(json[TodoFields.time] as String),
        transparency:
            (json[TodoFields.transparency] as num?)?.toDouble() ?? 20.0,
        characterSize:
            (json[TodoFields.characterSize] as num?)?.toDouble() ?? 20.0,
        postitSize: (json[TodoFields.postitSize] as num?)?.toDouble() ?? 10.0,
        postit: json[TodoFields.postit] as String,
        background: json[TodoFields.background] as String,
      );

  // TodoオブジェクトをJSON形式のマップに変換します。
  Map<String, Object?> toJson() => {
        TodoFields.id: id,
        TodoFields.title: title,
        TodoFields.time: createdTime.toIso8601String(),
        TodoFields.transparency: transparency,
        TodoFields.characterSize: characterSize,
        TodoFields.postitSize: postitSize,
        TodoFields.postit: postit,
        TodoFields.background: background,
      };

  static defaultTodo() {
    return Todo(
      id: null,
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
