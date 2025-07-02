import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/model/todo.dart';

final _lightColors = [
  Colors.amber[100],
  Colors.lightGreen[100],
  Colors.lightBlue[100],
  Colors.orange[100],
  Colors.pinkAccent[100],
  Colors.tealAccent[100],
  Colors.purple[100],
  Colors.cyan[100],
  Colors.yellow[100],
  Colors.redAccent[100],
];

// Todoオブジェクトを受け取り、それをカード形式で画面に表示
class TodoCardWidget extends StatelessWidget {

  const TodoCardWidget({
    Key? key,
    required this.todo,
    required this.index,
  }) : super(key: key);

  final Todo todo;
  final int index;

  @override
  Widget build(BuildContext context) {

    // 各カードの背景色を、_lightColorsリストから取得し、indexに基づいて選択
    // メモの作成日時は、DateFormatを使用してフォーマット、
    // メモのタイトルはカードのヘッダーに表示
    // 各カードの最小の高さは、getMinHeightメソッドによって設定
    final color = _lightColors[index % _lightColors.length];
    final time = DateFormat.yMMMd().format(todo.createdTime);
    final minHeight = getMinHeight(index);

    return Card(
      color: color,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 時間 テキスト
            Text(
              time,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            // タイトル テキスト
            Text(
              todo.title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:   return 10;//100
      case 1:   return 10;//150
      case 2:   return 10;//150
      case 3:   return 10;//100
      default:  return 10;//100
    }
  }
}
