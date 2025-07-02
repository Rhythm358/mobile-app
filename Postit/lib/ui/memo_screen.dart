import 'dart:io';
import 'package:path/path.dart' as path; //pathという名のエイリアス
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:todo/model/memo.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/database/database_todo.dart';
import 'package:todo/database/database_memo.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


double width          = 160.0;
double height         = 140.0;
double defWidth       = 160.0;
double defHeight      = 140.0;
String transparency   = '20.0';
String characterSize  = '20.0';
String postitSize     = '10.0';
String selectedPostIt     = 'lib/images/postit/postit1.png';
String selectedBackground = 'lib/images/background/background1.jpg';
bool areButtonsVisible = true; // ボタンの表示状態を管理するフラグ
bool _editMode         = false;

List<String> selectedPostIts = [
  'lib/images/postit/postit1.png',  'lib/images/postit/postit2.png',
  'lib/images/postit/postit3.png',  'lib/images/postit/postit4.png',
  'lib/images/postit/postit5.png',  'lib/images/postit/postit6.png',
  'lib/images/postit/postit7.png',  'lib/images/postit/postit8.png',
  'lib/images/postit/postit9.png',  'lib/images/postit/postit10.png',
  'lib/images/postit/postit11.png',  'lib/images/postit/postit12.png',
  'lib/images/postit/postit13.png',
];
List<String> selectedBackgrounds = [
  'lib/images/background/background1.jpg',  'lib/images/background/background2.jpg',
  'lib/images/background/background3.jpg',  'lib/images/background/background4.jpg',
  'lib/images/background/background5.jpg',  'lib/images/background/background6.jpg',
  'lib/images/background/background7.jpg',  'lib/images/background/background8.jpg',
   'lib/images/background/background9.jpg',  'lib/images/background/background10.jpg',
  'lib/images/background/background11.jpg',  'lib/images/background/background12.jpg',
  'lib/images/background/background13.jpg',  'lib/images/background/background14.jpg',
  'lib/images/background/background15.jpg',  'lib/images/background/background16.jpg',
  'lib/images/background/background17.jpg',  'lib/images/background/background18.jpg',
];

// SharedPreferencesキー
const todoIdNumKey    = "todoId";
const int initTodoNum = 1;


class MemoPage extends StatefulWidget {
  final String title;
  final Todo? todo;  // ?:NULLを許容

  const MemoPage({
    Key? key,
    required this.title,
    this.todo,
  }) : super(key: key);

  @override
  MemoPageState createState() => MemoPageState();
}

class MemoPageState extends State<MemoPage> {
  late Todo todo;
  late List<Memo> memos;
  late Offset _mousePosition;
  late String title;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  bool isLoading = false;
  ScreenshotController screenshotController = ScreenshotController();
  //FacebookBannerAd? _currentAd;
  BannerAd? _bannerAd;
  // test : ca-app-pub-3940256099942544/6300978111
  // Android : ca-app-pub-1474069724283041/7817796794
  // iOS  : ca-app-pub-1474069724283041/5191633456
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-1474069724283041/7817796794'
      : 'ca-app-pub-1474069724283041/5191633456';

  //*********************************************************
  // Meta 広告
  //*********************************************************
  // _showBannerAd() {
  //   setState(() {
  //     // Android用のID：564232615795934_564240545795141
  //     // iOS用のID：564232615795934_564239945795201
  //     _currentAd = FacebookBannerAd(
  //       //placementId: "IMG_16_9_APP_INSTALL#564232615795934_564240545795141",
  //       placementId: Platform.isAndroid ? "564232615795934_564240545795141" : "564232615795934_564239945795201",
  //       bannerSize: BannerSize.STANDARD,
  //       listener: (result, value) {
  //         print("Banner Ad: $result -->  $value");
  //       },
  //     );
  //   });
  // }

  @override
  void initState() {
    super.initState();

    toggleButtonsVisibility();    // 付箋内のオプション表示オン
    _mousePosition = const Offset(100,200);    // 付箋 初期値

    // ??演算子 左がnullでない場合その値を返し、nullの場合、右側の式を評価してその値を返す
    _titleController.text = widget.todo?.title ?? '';
    title = widget.todo?.title ?? '';

    // todoフィールドを初期化
    // 新規ページの場合はデフォルトのTodoオブジェクトを使用
    todo = widget.todo ?? Todo.defaultTodo();
    print("From ${widget.title} Screen  todoID ${todo.id}");

    // データベースから選択したtodo,memoを読み取り
    refreshTodo();
    if (widget.title == 'Edit')  refreshMemo();
    //print("[メモ init todoId]: ${todo.id}");

    //_showBannerAd();
    _loadAd();
  }
  void _loadAd() async {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = TodosNotifierProvider.of(context);
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        leading:
          backButton(), // 戻るボタン
        actions: [
          deleteButton(),
          settingButton(),
          cameraButton(),
          saveButton(),
        ],
      ),

      body: GestureDetector(
        //テキストフィールド外をクリックするとキーボードを閉じる
        onTap: () {
          // 付箋内のオプション表示オン
          setState(() {
            areButtonsVisible = true;
          });
          print("TAPPPPPP");
          FocusScope.of(context).unfocus();
        },
        // TapDown時に位置取得し、Tap時（指を離した）に_addTodoを実行
        // onDoubleTapDown：ダブルタップの開始位置を取得するためのコールバック
        // _mousePosition変数にダブルタップの位置が保存
        onDoubleTapDown: (details) => _mousePosition = details.localPosition,
        //onDoubleTap：ダブルタップが発生したときに_addTodoメソッドを実行するためのコールバック
        onDoubleTap: _addMemo,

        child: Stack(
          children: [

            Form(
              key: _formKey,
              child: Screenshot(
                controller: screenshotController,
                // Container：ウィジェットの背景となるコンテナ
                child: Container(
                  // 親ウィジェットの幅と高さに合わせて自動的に拡大
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      // バックグラウンド画像
                      image: AssetImage(selectedBackground),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Stack：子ウィジェットを重ねて配置するためのウィジェット
                  child: Stack(
                    children: [
                      for (final memo in notifier.value)
                        Positioned(
                          left: memo.position.dx,
                          top: memo.position.dy,
                          child: GestureDetector(
                            // dragStartBehavior：ドラッグの開始動作を指定
                            // downにすることで移動開始が少し早まる
                            dragStartBehavior: DragStartBehavior.down,
                            // onPanUpdate：ドラッグ中の動作を処理するためのコールバック
                            onPanUpdate: (details) {
                              // ドラッグの変位と関連するtodoオブジェクトのIDを通知
                              notifier.move(details.delta, memo.id);
                            },
                            // Todoメモ帳 Widget
                            child: TodoWidgetWithButtons(
                              todo: memo,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),


              ),
            ),

            //Other widgets in the Stack
            Positioned(
              left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0), // テキストフィールドの上部に適切な余白を設定
                child: TextFormField(
                  controller: _titleController, // コントローラーを設定
                  style: const TextStyle(
                    color: Colors.white, //black, // 文字色
                    fontSize: 20.0, // フォントサイズ
                    shadows: [
                      Shadow(
                        color: Colors.black, // 影の色を黒に設定
                        blurRadius: 5, // 影のぼかし半径を設定
                      ),
                    ],
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter title ...',
                    hintStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0
                    ),
                  ),
                  textAlign: TextAlign.center, // 中央揃え
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'The title cannot be empty';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // 入力値が変更された時に呼ばれるコールバック
                    setState(() {
                      title = value; // 入力値を変数に代入
                    });
                  },
                ),
              ),
            ),

            //*********************************************************
            //  Meta banner 広告
            //*********************************************************
            // Positioned(
            //   top: 0, left: 0, right: 0,
            //   child: Align(
            //     alignment: Alignment.topCenter,
            //     child: _currentAd,
            //   ),
            // ),

            if (_bannerAd != null)
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),

          ],
        ),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: 'Increment',
        backgroundColor: Colors.green.shade200,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white          // ダークモードの場合は白色のアイコン
            : null,                 // ライトモードの場合はnullに設定してデフォルトの色を使用
        child: const Icon(Icons.add),
      ),

    );
  }

  //****************************************************************
  //  初期化 処理
  //****************************************************************
  Future refreshTodo() async {
    //isLoading変数を設定し、UIを更新するためにsetState()メソッドを使用
    setState(() => isLoading = true);
    //データベースから選択したノートを読み取り
    todo = await DatabaseTodo.instance.readTodo(todo.id!);

    //設定情報を入力
    transparency       = todo.transparency.toString();
    characterSize      = todo.characterSize.toString();
    postitSize         = todo.postitSize.toString();
    selectedPostIt     = todo.postit;
    selectedBackground = todo.background;

    width  = defWidth  * (double.parse(postitSize) / 10);
    height = defHeight * (double.parse(postitSize) / 10);

    // データベース内の Todo を更新する
    await DatabaseTodo.instance.update(todo);

    // setState メソッドを呼び出してウィジェットツリーの再構築をトリガーする
    setState(() => isLoading = false);
  }

  Future refreshMemo() async {
    print('[refreshMemo] todoID: ${todo.id}');
    memos = await DatabaseMemo.instance.readMemoByTodoId(todo.id!);
    //print('[refreshMemo] memosLength: $memos.length');
    for (var memo in memos) {
      print('memo Description: ${memo.description}  Todo.id: ${memo.todoId}   position: ${memo.position}');
      TodosNotifierProvider.of(context).setAddMemo(memo);
    }
  }
  //****************************************************************

  // AppBar 削除ボタン
  Widget deleteButton() => IconButton(
    icon: const Icon(
      Icons.delete,
      //color: Colors.black,
    ),
    onPressed: () async {
      // TODOを削除
      if (todo.id != null) {
        await DatabaseTodo.instance.delete(todo.id!);
      }
      // MEMOを削除
      if (todo.id != null) {
        await DatabaseMemo.instance.deleteMemoByTodoId(todo.id!);
      }
      Navigator.of(context).pop(); //      // ignore: use_build_context_synchronously
    },
  );

  // AppBar Saveボタン
  Widget saveButton() {
    final isFormValid = title.isNotEmpty && _editMode == false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: isFormValid ? null : Colors.grey.shade700,
          ),
           onPressed: () async {
             if (_editMode == true) { //編集モードがオンの時
               showEditErrorDialog(context);
             }
            else if (title.isEmpty) {  //タイトルが空欄の時
               showEmptyTitleErrorDialog(context);
            }
            else {
              addOrUpdateTodo();            // Todo情報をデータベースに登録
              addOrUpdateMemo();            // Memo情報をデータベースに登録
              Navigator.of(context).pop();  // 直前の画面に戻る
             }
          },
          child: const Row(
            children: [
              Icon(Icons.save_as_outlined),
              Text(' Save ', style: TextStyle(fontWeight: FontWeight.bold,),),
            ],
          )
      ),
    );
  }

  void showEmptyTitleErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Title ...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // ポップアップを閉じる
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showEditErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please Change Post-it',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_rounded, size: 24),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, size: 24),
                    SizedBox(width: 10),
                    Icon(Icons.edit, size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // ポップアップを閉じる
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // データベース Memoオブジェクトを更新/追加
  void addOrUpdateMemo() async {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      if (isValid) {
        if (widget.title == 'Edit') {
          print("Memo アップデート(編集) タイトル : $title");
          await updateMemo();
        } else {
          print("Memo 新規メモ(新規) タイトル : $title");
          await addMemo();
        }
      }
    }
    else{
      //print("else: _formKey.currentState != null に入った");
    }
  }
  // データベースのMemoオブジェクトを更新
  Future updateMemo() async {
    final notifier = TodosNotifierProvider.of(context);
    // MEMOを削除
    if (todo.id != null) {
      await DatabaseMemo.instance.deleteMemoByTodoId(todo.id!);
    }

    for (var memo in notifier.value) {
      //新規メモ
      var tmpMemo = Memo(
        position: memo.position,
        description: memo.description,
        done: memo.done,
        todoId: todo.id,
      );
      await DatabaseMemo.instance.create(tmpMemo);
      print('[updateMemo] New memoDescription: ${memo.description}');
      //print('[updateMemo] New : ${memo.toJson()}');
      //print('[updateMemo] New');
    }
  }

  // データベースに新しいMemoオブジェクトを追加
  Future addMemo() async {
    final notifier = TodosNotifierProvider.of(context);
    for (var memo in notifier.value) {
      memo = Memo(
        position: memo.position,
        description: memo.description,
        done: memo.done,
        todoId: todo.id,
      );
      //print('ADD memo.description: ${memo.description}');
      await DatabaseMemo.instance.create(memo);
      // print('addMemo New : ${memo.toJson()}');
    }
    final prefs = await SharedPreferences.getInstance();
    int todoNum = prefs.getInt(todoIdNumKey) ?? initTodoNum;
    todoNum++;
    prefs.setInt(todoIdNumKey, todoNum);
    print("314 [memo_screen] saved todoNum $todoNum");
  }
  // Todoオブジェクトを更新
  // データベースから現在のTodoオブジェクトを取得し、新しいプロパティで更新
  void addOrUpdateTodo() async {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      if (isValid) {
        //final isUpdating = widget.todo != null;
        final isUpdating = widget.todo!.title != '';
        if (isUpdating) {
          //print("アップデート [ $title ]");
          await updateTodo();
        } else {
          //print("新規追加 [ $title ]");
          await addTodo();
        }
      }
    }else{
      //print("else: _formKey.currentState != null に入った");
    }
  }
  // Todoオブジェクトを更新
  // 元のデータを保持するためコピーした後、データベースを更新(更新が失敗した際の対策)
  Future updateTodo() async {
    final todo = widget.todo!.copy(
      title         : title,
      createdTime   : DateTime.now(),
      transparency  : double.parse(transparency),  // String を double に変換
      characterSize : double.parse(characterSize), // String を double に変換
      postitSize    : double.parse(postitSize),    // String を double に変換
      postit        : selectedPostIt,
      background    : selectedBackground,
    );
    await DatabaseTodo.instance.update(todo);
  }

  // Todoオブジェクトに追加
  // 新しいTodoオブジェクトを作成(適切な状態で初期化)し,それをデータベースに追加
  Future addTodo() async {
    final todo = Todo(
      title         : title,
      createdTime   : DateTime.now(),
      transparency  : double.parse(transparency),  // String を double に変換
      characterSize : double.parse(characterSize), // String を double に変換
      postitSize    : double.parse(postitSize),    // String を double に変換
      postit        : selectedPostIt,
      background    : selectedBackground,
    );
    await DatabaseTodo.instance.create(todo);
    print('addTodo New : ${todo.toJson()}');
  }

  // AppBar 戻るボタン
  Widget backButton() => IconButton(
      icon: const Icon(
        Icons.arrow_back,
        //color: Colors.black
      ),
      onPressed: () async {
        Navigator.pop(context);
      }
  );

  void _addMemo() {
    TodosNotifierProvider.of(context).addMemo(_mousePosition);
  }

  // ボタンを押すと付箋ないのオプション表示状態が切り替わる関数
  void toggleButtonsVisibilityOff() {
    setState(() {
      areButtonsVisible = false;
    });
  }
  void toggleButtonsVisibility() {
    setState(() {
      areButtonsVisible = true;
    });
  }

  // プレビューを表示するための処理
  void _showPreviewDialog(BuildContext context) async {
    //スクリーンショットを撮影
    var capturedImage = await screenshotController.capture();
    if (capturedImage != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = path.join(directory.path, 'captured_image.png');
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(capturedImage);

      //contextが無くなっていたら、早期リターンしてNavigatorを実行させないようにする
      if (!mounted) return;

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Colors.green.shade100, // 背景色を指定
                  title: const Center(
                      child: Text('Screenshot Preview',
                        style: TextStyle(
                          color: Colors.black, // 色を指定
                          fontSize: 20, // フォントサイズを指定
                          fontWeight: FontWeight.bold, // フォントの太さを指定
                        ),
                      )
                  ),
                  content: Image.memory(capturedImage),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text('Close'),
                          onPressed: () {
                            // contextが無くなっていたら、早期リターンしてNavigatorを実行させないようにする
                            if (!mounted) return;
                            toggleButtonsVisibility();
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 60), // ボタン間のスペース
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            // 写真フォルダに画像を保存
                            await ImageGallerySaver.saveFile(imagePath);
                            // contextが無くなっていたら、早期リターンしてNavigatorを実行させないようにする
                            if (!mounted) return;
                            toggleButtonsVisibility();
                            Navigator.of(context).pop();
                            //******************************************************
                            //adInterstitial.showAd();//インタースティシャル広告
                            //******************************************************
                          },
                        ),
                      ],
                    ),
                  ],

                );
              },
            );
          });

    }
  }

  // カメラボタン
  IconButton cameraButton() => IconButton(
      icon: const Icon(
        Icons.camera_alt_outlined,
        //color: Colors.black,
      ),
      onPressed: (){
        toggleButtonsVisibilityOff();
        _showPreviewDialog(context);
      }
  );

  // 設定ボタン
  IconButton settingButton() => IconButton(
      icon: const Icon(
        Icons.settings,
        //color: Colors.black,
      ),
      onPressed: () async{
        //設定画面へ画面遷移
        var result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingScreen()),
        );
        if (result != null) {
          setState(() {
            //print("Image Updated");
            transparency = result;
          });
        }
      }
  );

}

// ------------------
// 付箋 画像 選択ページ
// ------------------
class PostItPage extends StatefulWidget {
  const PostItPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PostItPage();
}

class _PostItPage extends State<PostItPage> {
  // FacebookBannerAd? _currentAd;

  //*********************************************************
  // Meta広告
  //*********************************************************
  // _showBannerAd() {
  //   setState(() {
  //     // Android用のID：564232615795934_564240545795141
  //     // iOS用のID：564232615795934_564239945795201
  //     _currentAd = FacebookBannerAd(
  //       //placementId: "IMG_16_9_APP_INSTALL#564232615795934_564240545795141", //testid
  //       placementId: Platform.isAndroid ? "564232615795934_564240545795141" : "564232615795934_564239945795201",
  //       bannerSize: BannerSize.STANDARD,
  //       keepAlive: true,  //いらないかも
  //       listener: (result, value) {
  //         print("Banner Ad: $result -->  $value");
  //       },
  //     );
  //   });
  // }

  @override
  void initState() {
    super.initState();
    //_showBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text(
          'Post-it',
          //style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        //iconTheme: const IconThemeData(color: Colors.black), // バックボタンの色を黒色に設定
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop(context); // 画面遷移元に戻る
            Navigator.pop(context, selectedPostIt);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            //*********************************************************
            //  Meta banner 広告
            //*********************************************************
            // Align(
            //   alignment: Alignment.topCenter,
            //   child: _currentAd,
            // ),

            SizedBox(
              // 画像を表示するボックスの高さを指定
              height: MediaQuery.of(context).size.height * 0.9,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 列数を調整
                  mainAxisSpacing: 8, // 垂直方向のスペース
                  crossAxisSpacing: 8, // 水平方向のスペース
                ),
                itemCount: selectedPostIts.length,
                itemBuilder: (context, index) {
                  final imagePath = selectedPostIts[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPostIt = imagePath;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPostIt == imagePath
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Image.asset(imagePath),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

      ),


    );
  }
}

// ------------------
// 背景 画像 選択ページ
// ------------------
class BackgroundPage extends StatefulWidget {
  const BackgroundPage({super.key});
  @override
  State<StatefulWidget> createState() => _BackgroundPage();
}

class _BackgroundPage extends State<BackgroundPage> {
  Widget? _currentAd;

  //*********************************************************
  // Meta広告
  //*********************************************************
  // _showBannerAd() {
  //   setState(() {
  //     // Android用のID：564232615795934_564240545795141
  //     // iOS用のID：564232615795934_564239945795201
  //     _currentAd = FacebookBannerAd(
  //       //placementId: "IMG_16_9_APP_INSTALL#564232615795934_564240545795141",
  //       placementId: Platform.isAndroid ? "564232615795934_564240545795141" : "564232615795934_564239945795201",
  //       bannerSize: BannerSize.STANDARD,
  //       listener: (result, value) {
  //         print("Banner Ad: $result -->  $value");
  //       },
  //     );
  //   });
  // }

  @override
  void initState() {
    super.initState();
    //_showBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text('Background'),
        centerTitle: true,
        //iconTheme: const IconThemeData(color: Colors.black), // バックボタンの色を黒色に設定
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop(context); // 画面遷移元に戻る
            Navigator.pop(context, selectedBackground);
          },
        ),
      ),

      body: Column(
        children: [
          //*********************************************************
          //  Meta banner 広告
          //*********************************************************
          Align(
            alignment: Alignment.topCenter,
            child: _currentAd,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                // 画像を表示するボックスの高さを指定
                height: MediaQuery.of(context).size.height * 0.9,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 列数を調整
                    mainAxisSpacing: 8, // 垂直方向のスペース
                    crossAxisSpacing: 8, // 水平方向のスペース
                  ),
                  itemCount: selectedBackgrounds.length,
                  itemBuilder: (context, index) {
                    final imagePath = selectedBackgrounds[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBackground = imagePath;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedBackground == imagePath ? Colors.blue : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Image.asset(imagePath),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),


    );
  }
}

// ------------------
// 設定 ページ
// ------------------
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});
  @override
  State<StatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var transparencySliderValue  = double.parse(transparency);
  var characterSizeSliderValue = double.parse(characterSize);
  var memoSizeSliderValue      = double.parse(postitSize);
  Widget? _currentAd;

  //*********************************************************
  // Meta広告
  //*********************************************************
  // _showBannerAd() {
  //   setState(() {
  //     // Android用のID：564232615795934_564240545795141
  //     // iOS用のID：564232615795934_564239945795201
  //     _currentAd = FacebookBannerAd(
  //       //placementId: "IMG_16_9_APP_INSTALL#564232615795934_564240545795141",
  //       placementId: Platform.isAndroid ? "564232615795934_564240545795141" : "564232615795934_564239945795201",
  //       bannerSize: BannerSize.STANDARD,
  //       keepAlive: true,  //いらないかも
  //       listener: (result, value) {
  //         print("Banner Ad: $result -->  $value");
  //       },
  //     );
  //   });
  // }

  @override
  void initState() {
    super.initState();
    //_showBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 遷移元の画面で事前にキャッシュ
      for (String imagePath in selectedPostIts) {   // 付箋 画像
        precacheImage(AssetImage(imagePath), context);
      }
      for (String imagePath in selectedBackgrounds) { // 背景 画像
        precacheImage(AssetImage(imagePath), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text('Settings',),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,transparency); // 画面遷移元に戻る
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            //*********************************************************
            //  Meta banner 広告
            //*********************************************************
            Align(
              alignment: Alignment.topCenter,
              child: _currentAd,
            ),
            SizedBox(
              // 画像を表示するボックスの高さを指定
              height: MediaQuery.of(context).size.height * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // ------------
                    // 透明性
                    // ------------
                    const Text('Transparency', style: TextStyle(fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(transparency.split('.').first,
                            style: const TextStyle(fontSize: 30)),
                        const Text(' %', style: TextStyle(fontSize: 20))
                      ],
                    ),
                    Slider(
                      value: transparencySliderValue,
                      min: 0,
                      max: 100,
                      divisions: 5,
                      onChanged: (double value) {
                        setState(() {
                          transparencySliderValue = value.roundToDouble();
                          transparency = '$transparencySliderValue';
                        });
                      },
                    ),

                    // ------------
                    // 文字サイズ
                    // ------------
                    const Text('Character Size', style: TextStyle(fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(characterSize.split('.').first,
                            style: const TextStyle(fontSize: 30)),
                        const Text(' %', style: TextStyle(fontSize: 20))
                      ],
                    ),
                    Slider(
                      value: characterSizeSliderValue,
                      min: 10,
                      max: 30,
                      // divisions: 5,
                      onChanged: (double value) {
                        setState(() {
                          characterSizeSliderValue = value.roundToDouble();
                          characterSize = '$characterSizeSliderValue';
                        });
                      },
                    ),

                    // ------------
                    // 付箋画像サイズ
                    // ------------
                    const Text('Post-it Size', style: TextStyle(fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(postitSize.split('.').first,
                            style: const TextStyle(fontSize: 30)),
                        const Text(' x', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    Slider(
                      value: memoSizeSliderValue,
                      min: 6,
                      max: 16,
                      //divisions: 6,
                      onChanged: (double value) {
                        setState(() {
                          memoSizeSliderValue = value.roundToDouble();
                          postitSize = '$memoSizeSliderValue';

                          width = defWidth * (memoSizeSliderValue / 10);
                          height = defHeight * (memoSizeSliderValue / 10);
                        });
                      },
                    ),

                    // ------------
                    // 付箋 画像選択
                    // ------------
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PostItPage()),
                        );
                        if (result != null) {
                          setState(() {
                            selectedPostIt = result;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          const Text(
                            'Post-it',
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          Image.asset(
                            selectedPostIt,
                            width: 120, // 画像の幅を指定
                            height: 120, // 画像の高さを指定
                          ),
                        ],
                      ),
                    ),

                    // ------------
                    // 背景 画像 選択
                    // ------------
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BackgroundPage()),
                        );
                        if (result != null) {
                          setState(() {
                            selectedBackground = result;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          const Text(
                            'Background',
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 16), // スペースを追加
                          Image.asset(
                            selectedBackground,
                            width: 120, // 画像の幅を指定
                            height: 120, // 画像の高さを指定
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}


class TodoWidgetWithButtons extends StatefulWidget {
  final Memo todo;
  const TodoWidgetWithButtons({Key? key, required this.todo}) : super(key: key);
  @override
  TodoWidgetWithButtonsState createState() => TodoWidgetWithButtonsState();
}

// SingleTickerProviderStateMixin：アニメーションWidget
class TodoWidgetWithButtonsState extends State<TodoWidgetWithButtons>
    with SingleTickerProviderStateMixin {

  // アニメーションを800ミリ秒間再生
  static const _duration = Duration(milliseconds: 500);
  // アニメーションの制御を行うためのインスタンス
  // アニメーションが再生された後にsetStateメソッドが呼ばれ、Widgetの状態が更新
  late final _animationController = AnimationController(
    vsync: this,
    duration: _duration,
  )..forward().then((value) => setState(() {}));

  late final _textController = TextEditingController();
  //bool _editMode = false;

  @override
  Widget build(BuildContext context) {

    // ScaleTransition:子Widgetを拡大または縮小するアニメーションを提供
    return ScaleTransition(
      // scaleプロパティにCurveTweenのアニメーションを設定
      scale: _animationController.drive(
        CurveTween(
          curve: _animationController.isCompleted
              ? Curves.bounceIn
              : Curves.bounceOut,
        ),
      ),
      // 固定の幅と高さを持つボックスを作成
      child: SizedBox(
        width: width,
        height: height,

        // Stack：複数の子ウィジェットを重ねて表示
        child: Stack(
          children: [
            // Todoメモの本体
            _buildAnimatedTodo(),
            // 周りのボタン類
            Visibility(
              visible: areButtonsVisible, // ボタンの表示状態を制御
              child: _buildEditButton(),
            ),
            Visibility(
              visible: areButtonsVisible, // ボタンの表示状態を制御
              child: _buildDeleteButton(),
            ),
            Visibility(
              visible: areButtonsVisible, // ボタンの表示状態を制御
              child: _buildCheckButton(),
            ),
            // テキストフィールド
          ],
        ),
      ),
    );
  }

  void _toggleEditMode() {
    if (_editMode) {
      _changeDescription();
    } else {
      setState(() => _editMode = true);
    }
  }

  // Memoの説明を変更するためのメソッド
  void _changeDescription() {
    print("1019 _changeDescription called");
    // テキスト内容が変わっている時のみ、メモの内容を変更
    if (_textController.text != widget.todo.description) {
      TodosNotifierProvider.of(context)
          .changeDescription(_textController.text, widget.todo.id);
    }
    // Widgetの状態を更新して、編集モードを終了
    setState(() => _editMode = false);
  }

  void _toggleDone() {
    TodosNotifierProvider.of(context).toggleDone(widget.todo.id);
  }

  void _delete() {
    //print('Widget ID: ${widget.todo.id}');
    TodosNotifierProvider.of(context).delete(widget.todo.id);
  }

  // メモ帳 確認ボタン
  Widget _buildCheckButton() {
    return Align(
      alignment: const Alignment(0.9,0.9),
      child: IconButton(
        iconSize: 30,
        icon: Icon(
          widget.todo.done ? Icons.check_circle : Icons.circle_outlined,
        ),
        color: Colors.amber,
        onPressed: _toggleDone,
      ),
    );
  }

  // メモ帳 Trashボタン
  Widget _buildDeleteButton() {
    return Positioned(
      left: 5,
      top: 5,
      child: IconButton(
        icon: const Icon(Icons.delete_rounded),
        color: Colors.black26,
        onPressed: _delete,
      ),
    );
  }

  // メモ帳 編集ボタン
  Widget _buildEditButton() {
    return Positioned(
      right: 0,
      top: 5,
      child: IconButton(
        icon: Icon(_editMode ? Icons.done_rounded : Icons.edit),
        color: Colors.black38,
        onPressed: () async {
          setState(() {
          });
          _toggleEditMode();
        }
        // onPressed: _toggleEditMode,
      ),
    );
  }

  // 子ウィジェットの不透明度をアニメーションさせるウィジェット
  Widget _buildAnimatedTodo() {
    return AnimatedOpacity(
      // opacity:アニメーションの透明度を設定
      opacity: widget.todo.done ? 0.25 : 1.0,
      curve: Curves.easeOutQuint,
      duration: _duration,
      // メモ帳本体
      child: TodoWidget(
        controller: _textController,
        todo: widget.todo,
        editMode: _editMode,
        onSubmitted: _changeDescription,
        onEditMode: _toggleEditMode,
      ),
    );
  }

}

class TodoWidget extends StatefulWidget {

  final TextEditingController controller;
  final Memo todo;
  final bool editMode;
  final VoidCallback? onSubmitted;
  final VoidCallback? onEditMode;
  // メモサイズ
  // Static:クラスのフィールド変数に指定し、その変数がインスタンスごとに保持されるのではなく、
  // クラスで1つの実体を持つことを宣言する。
  final Size imageSize = Size(width, height);

   TodoWidget({
    Key? key,
    required this.controller,
    required this.todo,
    required this.editMode,
    required this.onEditMode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  TodoWidgetState createState() => TodoWidgetState();
}

class TodoWidgetState extends State<TodoWidget> {

  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.todo.description;
  }

  @override
  Widget build(BuildContext context) {
    // 編集モード時にTextField以外をタップすると編集モードが解除
    return GestureDetector(
      onTap: widget.editMode ? widget.onSubmitted?.call : null,
      child: Container(
        width: width,
        height: height,
        // padding: const EdgeInsets.fromLTRB(30, 50, 60, 145),
        // Container margin（外側の余白）/padding（内側の余白）設定
        padding: const EdgeInsets.fromLTRB(20, 40, 10, 0),
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topLeft,
            fit: BoxFit.fitWidth,
            opacity: double.parse(transparency), // 透明度を指定（0.0から1.0の範囲）
            image: AssetImage(selectedPostIt),   // メモ帳画像
          ),
        ),

        // 編集モード時はTextField、それ以外はテキスト表示
        // テキストをダブルクリックすると編集モードになる
        child: !widget.editMode
            ? GestureDetector(
                onDoubleTap: widget.onEditMode,
                child: Text(
                  widget.todo.description,
                  maxLines: 4,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: double.parse(characterSize)
                  ),
                ),
              )
            : TextField(
                controller: widget.controller,
                maxLines: null,
                maxLength: 50,
                autofocus: true,
                textAlign: TextAlign.center, // 中央揃え
                style: TextStyle(
                    color: Colors.black,
                    fontSize: double.parse(characterSize)
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
      ),
    );
  }
}


// ValueNotifier: 変更を通知できる値を保持するためのクラス
// TodosNotifierクラスはTodoリストの状態を管理し、Todoの追加・移動・編集・削除などの操作を提供
// また、状態の変更があった場合には、notifyListenersを呼び出して変更を通知
// これにより、UI側でリアルタイムに状態の変化を検知し、表示を更新することができます。
class TodosNotifier extends ValueNotifier<List<Memo>> {

  final String superScreen;

  TodosNotifier(this.superScreen) : super(<Memo>[]) {
    // 遷移元のタイトルがNewの場合 新規作成画面からの遷移のため条件を反転
    if (superScreen == 'NEW'){
      //print("[TodosNotifier] Enter superScreen == NEW !!!");
      _init();
    }else{
      //print("[TodosNotifier] superScreen : $superScreen");
    }
  }
  void _init() {
    // メモリストの初期値
    super.value = [
      Memo(
        id: UniqueKey().hashCode,
        position: const Offset(30, 120),
        description: 'memo 1',
        done: false,
      ),
      Memo(
        id: UniqueKey().hashCode,
        position: const Offset(150, 400),
        description: 'memo 2',
        done: false,
      ),
    ];
  }
  // addTodoメソッドは、新しいTodoを追加するためのメソッド
  // Offsetから画像のサイズの半分を引くことで、中央寄せの位置に設定
  // 新しいTodoをsuper.valueに追加し、notifyListenersを呼び出して変更を通知
  void addMemo(Offset position) {
    final memo = Memo(
      id: UniqueKey().hashCode,
      description: 'memo',
      done: false,
      // positionは左上隅のOffsetなので画像の大きさの半分を縦横それぞれ引くことで中央寄せ
      position: position - Offset( width / 2, height / 2),
    );
    //print('New ID: ${todo.id}');
    super.value.add(memo);
    // super.valueのリスト自体を入れ替えない場合はnotifyListeners()が必要
    notifyListeners();
  }
  void setAddMemo(var superMemo) {
    final memo = Memo(
      id: superMemo.id,
      position: superMemo.position,
      description: superMemo.description,
      done: superMemo.done,
      todoId: superMemo.todoId,
    );
    //print('New ID: ${todo.id}');
    super.value.add(memo);
    // super.valueのリスト自体を入れ替えない場合はnotifyListeners()が必要
    notifyListeners();
  }
  void delete(int? id) {
    if (id != null) {
      //print('Delete ID: $id');
      super.value.removeWhere((element) => element.id == id);
      notifyListeners();
    }
  }
  void move(Offset delta, int? id) {
    final list = value.map<Memo>((e) {
      if (e.id == id) {
        return e.copyWith(position: e.position + delta);
      }
      return e;
    }).toList();
    super.value = list;
  }
  void changeDescription(String description, int? id) {
    final list = value.map<Memo>((e) {
      if (e.id == id) {
        return e.copyWith(description: description);
      }
      return e;
    }).toList();
    super.value = list;
  }
  void toggleDone(int? id) {
    final list = value.map<Memo>((e) {
      if (e.id == id) {
        return e.copyWith(done: !e.done);
      }
      return e;
    }).toList();
    super.value = list;
  }

}

//状態共有のためのクラス
class TodosNotifierProvider extends InheritedNotifier {

  const TodosNotifierProvider({
    Key? key,
    required TodosNotifier notifier,
    required Widget child,
  }) : super(key: key,notifier: notifier, child: child);

  static TodosNotifier of(BuildContext context) {
    final todosProvider = context.dependOnInheritedWidgetOfExactType<TodosNotifierProvider>();
    if (todosProvider == null) {
      throw Exception("TodosNotifierProvider not found in the widget tree!");
    }
    return todosProvider.notifier as TodosNotifier;
  }

}
