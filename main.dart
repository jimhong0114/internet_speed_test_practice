import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';//測試網速必要程式檔
import 'package:flutter_internet_speed_test/src/test_result.dart';//測試網速必要程式檔

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SpeedTestPage(),
    );
  }
}

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});
  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  final FlutterInternetSpeedTest _internetSpeedTest = FlutterInternetSpeedTest();//定義測網速的核心物件

  double _downloadRate = 0;//初始設置下載速度為0
  double _uploadRate = 0;//初始設置上傳速度為0
  String _unit = '';//設置目前速度單位為空（Mbps、Kbps 等）
  bool _isTesting = false;//初始設置目前沒有在測試網速

  void _startTest() {//測試網速的函式
    setState(() { //重設畫面上的狀態
      _isTesting = true;//設置目前有在測試網速
      _downloadRate = 0;//重置目前下載速度為0
      _uploadRate = 0;//重置目前上傳速度為0
      _unit = '';//設置目前速度單位為空（Mbps、Kbps 等）
    });

    _internetSpeedTest.startTesting(   //重設畫面狀態以後的測速過程與結束過程
      onProgress: (double percent, TestResult data) { //測試進行中會不斷回傳目前下載的百分比與即時測速資料
        setState(() {
          if (data.type == TestType.download) {
            _downloadRate = data.transferRate;
          } else if (data.type == TestType.upload) {
            _uploadRate = data.transferRate;
          }
          _unit = data.unit.name;
        });
      },
      onCompleted: (TestResult download, TestResult upload) {//測試結束，會傳回下載與上傳的測試結果
        setState(() {
          _isTesting = false;//因為已測試完畢，所以設置目前沒在測試網速
          _downloadRate = download.transferRate;//將這函式的下載速度偵測結果同步到函式外的下載速度值
          _uploadRate = upload.transferRate;//將這函式的上傳速度偵測結果同步到函式外的上傳速度值
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '測試完成：下載 ${download.transferRate.toStringAsFixed(2)} ${download.unit.name}，'//顯示下載速度與單位
                  '上傳 ${upload.transferRate.toStringAsFixed(2)} ${upload.unit.name}',//顯示上傳速度與單位
            ),
          ),
        );
      },
      onError: (String errorMessage, String speedTestError) {    //測試失敗時會呼叫這個函數
        setState(() => _isTesting = false);//因為測試過程發生錯誤，所以測試中斷，設置目前沒在測試網速
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('測試失敗：$errorMessage')),//顯示錯誤訊息
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('網路速度測試')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isTesting? '測試中...': ((_downloadRate > 0 && _uploadRate > 0)? '下載速度：${_downloadRate.toStringAsFixed(2)} $_unit\n上傳速度：${_uploadRate.toStringAsFixed(2)} $_unit': '尚未開始測試'),
                //如果_isTesting是true，則顯示'測試中'；如果_isTesting是false而且_downloadRate和 _uploadRate都大於0，則顯示網速測試結果；如果上述兩種結果都不符合，則顯示'尚未開始測試'
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isTesting ? null : _startTest,//按下按鈕後，如果_isTesting是true，則不做任何事，如果是false，則執行_startTest
                icon: const Icon(Icons.network_check),
                label: const Text('開始測試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
