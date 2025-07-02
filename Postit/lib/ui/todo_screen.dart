import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/database/database_memo.dart';
import 'package:todo/model/theme_mode.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/database/database_todo.dart';
import 'package:todo/widget/todo_card_widget.dart';
import 'package:todo/ui/memo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


bool isAscending = true; // デフォルトは昇順
// SharedPreferencesキー
const sortKey = "isAscending";
const todoIdNumKey = "todoId";
const int initTodoNum = 1;


// アプリケーションの状態に基づいて動的にUIを更新
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  TodoScreenState createState() => TodoScreenState();
}

// カテゴリのリストを取得し、UIに反映するための状態を管理
class TodoScreenState extends State<TodoScreen> {
  late List<Todo> todos;
  bool isLoading = false;
  String status = 'none';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool sortSwitch = false;
  //FacebookBannerAd? _currentAd;
  BannerAd? _bannerAd;
  // test : ca-app-pub-3940256099942544/6300978111
  // Android : ca-app-pub-1474069724283041/7817796794
  // iOS  : ca-app-pub-1474069724283041/5191633456
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-1474069724283041/7817796794'
      : 'ca-app-pub-1474069724283041/5191633456';

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
  //       listener: (result, value) {
  //         print("Banner Ad: $result -->  $value");
  //       },
  //     );
  //   });
  // }

  //*********************************************************
  // Admob 広告
  //*********************************************************
  void _AdmobloadAd() async {
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
          // エラーメッセージをコンソールに出力する
          print('広告読み込みに失敗しました: $err');
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
  void initState() {
    super.initState();
    refreshTodo();        // UIを更新するために現在のカテゴリのリストを取得
    init();               // アプリ起動時に保存したデータを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_)
        => initPlugin()); // ATT対応
    loadSortSettings();   // ソート設定を反映

    //*********************************************************
    //  Meta広告 初期化
    //*********************************************************
    // FacebookAudienceNetwork.init(
    //   // テストモードを有効にする時、testingIdを設定、リリース時は、コメントアウト
    //   // testingId ログに hased IDとして出力されるので、それをパラメータに貼り付ける。
    //   // I/AdInternalSettings(16349): Test mode device hash: 9f253ecc-26db-48e8-a403-55925e09c027
    //   //testingId: "9f253ecc-26db-48e8-a403-55925e09c027",
    //   iOSAdvertiserTrackingEnabled: true,
    // );
    // _showBannerAd();
    _AdmobloadAd();
  }

  // 参考) Widget build(BuildContext context) => Scaffoldは、下のreturnを使用するときと同じ意味。
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, mode, child) =>
          SafeArea(
            child: Scaffold(

              appBar: AppBar(
                //centerTitle: true,
                backgroundColor: Colors.green[200],
                //leading: const Icon(Icons.settings_rounded),
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('ToDo'),
                    //SizedBox(width:10),
                    //Icon(Icons.sports_score , size: 30, color: Colors.black),
                  ],
                ),
                // ボタン追加
                //actions: [sortButton()],
              ),

              key: _scaffoldKey,
              endDrawer: Drawer(
                child: Center(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 65.0,
                        child: DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                          ),
                          child: const Text("Setting",
                              style: TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Sort method'),
                        subtitle: const Text('Creation-order'),
                        value: sortSwitch,
                        // スイッチの現在の状態（trueまたはfalse）
                        onChanged: (bool value) async {
                          isAscending = !isAscending;
                          //データを保存
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool(sortKey, isAscending); // ソート方法を保存
                          setState(() {
                            sortSwitch = value!;
                            refreshTodo();
                          });
                        },
                        // スイッチの左側に表示するアイコン
                        secondary:
                        const Icon(FontAwesomeIcons.sort, color: Colors.green),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // 左端と右端に要素を配置
                        children: [
                          const Row(
                            children: [
                              SizedBox(width: 15),
                              Icon(FontAwesomeIcons.glasses,
                                  color: Colors.green),
                              SizedBox(width: 32),
                              Text('Theme'),
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              // ドロップダウンを右揃えに配置
                              child: DropdownButton<ThemeMode>(
                                value: mode.mode,
                                onChanged: (ThemeMode? newValue) {
                                  if (newValue != null) {
                                    mode.update(newValue);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text('System Setting'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.light,
                                    child: Text('Light Mode'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.dark,
                                    child: Text('Dark Mode'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),

              body: Column(
                children: [

                  //*********************************************************
                  //  Meta banner 広告
                  //*********************************************************
                  // Align(
                  //   alignment: Alignment.topCenter,
                  //   child: _currentAd,
                  // ),
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        child: SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    ),

                  Expanded(
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : todos.isEmpty
                          ? const Text('No ToDo',
                          style: TextStyle(color: Colors.black, fontSize: 24))
                          : buildTodo(),
                    ),
                  ),

                ],
              ),

              // bottomNavigationBar: const Column(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   mainAxisSize: MainAxisSize.min,
              //   children:[
              //     //******************************************************
              //     //AdBanner(size: AdSize.banner,)//バナー広告表示
              //     Padding(
              //       padding: EdgeInsets.all(10.0), // 上下左右に16ポイントの余白を設定
              //       child: AdBanner(size: AdSize.banner),//バナー広告表示
              //     )
              //     //******************************************************
              //   ],
              // ),

              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.green[200],
                foregroundColor: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? Colors.white // ダークモードの場合は白色のアイコン
                    : null, // ライトモードの場合はnullに設定してデフォルトの色を使用
                child: const Icon(Icons.add),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  int todoNum = prefs.getInt(todoIdNumKey) ?? initTodoNum;
                  //print("131 [todo_screen] todoNum: $todoNum");
                  final todo = Todo(
                    id: todoNum,
                    // id: todos.length+1,
                    //id: UniqueKey().hashCode,
                    title: '',
                    createdTime: DateTime.now(),
                    transparency: 20.0,
                    characterSize: 20.0,
                    postitSize: 10.0,
                    postit: 'lib/images/postit/postit1.png',
                    background: 'lib/images/background/background1.jpg',
                  );
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          TodosNotifierProvider(
                            // TodosNotifierProviderを追加
                            notifier: TodosNotifier('NEW'),
                            child: MemoPage(title: 'New', todo: todo),
                          ),
                    ),
                  );
                  refreshTodo();
                },
              ),

    ),
          ),
    );
  }

  //****************************************************************
  //  初期化 処理
  //****************************************************************
  // 保存されたソート設定を取得する関数
  Future<void> loadSortSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool savedSortValue = prefs.getBool(sortKey) ?? false; // デフォルト値をfalseに設定
    setState(() {
      sortSwitch = savedSortValue;
    });
  }
  // アプリ起動時に保存したデータを読み込む
  void init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(sortKey)) {
      setState(() {
        // データ読み取り
        isAscending = prefs.getBool(sortKey)!; //作成順(昇順/降順)
        refreshTodo();
        //print("Changed isAscending $isAscending");
      });
    }
  }
  Future<void> initPlugin() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
  // UIを更新するために現在のカテゴリのリストを取得
  Future refreshTodo() async {
    setState(() => isLoading = true);
    todos = await DatabaseTodo.instance.readAllTodo(isAscending);
    setState(() => isLoading = false);
  }
  //****************************************************************

  @override
  void dispose() {
    DatabaseTodo.instance.close();  // データベースとの接続を切断
    DatabaseMemo.instance.close();
    _bannerAd?.dispose();
    super.dispose();
  }

  // StaggeredGridView を使用してカテゴリのリストを表示
  // 異なるサイズのグリッドアイテムをレイアウト
  // 各アイテムはTodoCardWidgetを呼び出し、リストに表示されるカテゴリの個々の項目を表示
  Widget buildTodo() => StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(8),
        itemCount: todos.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(4),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,

        // itemBuilderコールバック:リスト内の各アイテムに対して連番を振る
        itemBuilder: (context, index) {
          final todo = todos[index];
          // ユーザーがノートをタップすると、MemoPageに移動
          return GestureDetector(
            onTap: () async {
              //print("todos[index: $index]");
              //todo.id = index+1;
              //print("画面遷移直前 todoId: ${todo.id}");
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TodosNotifierProvider(
                    // TodosNotifierProviderを追加
                    notifier: TodosNotifier('Edit'),
                    child: MemoPage(title: 'Edit', todo: todo),
                  ),
                ),
              );
              //print("画面遷移直後 todoId: ${todo.id}");
              refreshTodo();
            },
            // 各タイルは、TodoCardWidgetを使用して表示されます。
            child: TodoCardWidget(todo: todo, index: index),
          );
        },
      );
}
