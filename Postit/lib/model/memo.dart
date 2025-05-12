
import 'dart:ui';

const String tableMemo = 'memos';

// Memoオブジェクトの各フィールドの名前を保持する静的クラス
// これにより、オブジェクトのフィールドの名前をプログラム全体で一貫して使用できます。
class MemoFields {
  static final List<String> values = [
    id,
    positionX,
    positionY,
    description,
    done,
    todoId,
  ];
  static const String id = '_id';
  static const String positionX = 'positionX';
  static const String positionY = 'positionY';
  static const String description = 'description';
  static const String done = 'done';
  static const String todoId = 'todo_id';
}

// Todoクラスには、コンストラクタ、copy()メソッド、
// およびtoJson()およびfromJson()メソッドが含まれています。
class Memo {
  final int? id;
  final Offset position;
  final String description;
  final bool done;
  final int? todoId;

  // コンストラクタは、Catatanオブジェクトを作成するために使用されます。
  const Memo({
    this.id,
    required this.position,
    required this.description,
    required this.done,
    this.todoId,
  });

  // 既存のTodoオブジェクトを複製し、必要に応じて値を変更します。
  Memo copy({
    int? id,
    Offset? position,
    String? description,
    bool? done,
    int? todoId,
  }) =>
      Memo(
        id          : id ?? this.id,
        position    : position ?? this.position,
        description : description ?? this.description,
        done        : done ?? this.done,
        todoId      : todoId ?? this.todoId,
      );

  // JSON形式のマップからTodoオブジェクトを作成します。
  static Memo fromJson(Map<String, Object?> json) => Memo(
    id         : json[MemoFields.id] as int?,
    position: Offset(json[MemoFields.positionX] as double, json[MemoFields.positionY] as double),
    description: json[MemoFields.description] as String,
    done: (json[MemoFields.done] as int) == 1, // intからboolに変換
    todoId     : json[MemoFields.todoId] as int?,
  );

  // TodoオブジェクトをJSON形式のマップに変換します。
  //MemoFields.position   : position,
  Map<String, Object?> toJson() => {
    MemoFields.id         : id,
    MemoFields.positionX  : position.dx,
    MemoFields.positionY  : position.dy,
    MemoFields.description: description,
    MemoFields.done       : done ? 1 : 0, // boolをintに変換して保存する
    MemoFields.todoId     : todoId,
  };

  Memo copyWith({
    // Key? id,
    int? id,
    Offset? position,
    String? description,
    bool? done,
  }) {
    return Memo(
      id: id ?? this.id,
      position: position ?? this.position,
      description: description ?? this.description,
      done: done ?? this.done,
    );
  }

  static defaultMemo() {
    return const Memo(
      id: null,
      position : Offset.zero,
      description: '',
      done: false
    );
  }

}
