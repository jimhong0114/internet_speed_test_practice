import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:flutter_internet_speed_test/src/test_result.dart';

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
  final FlutterInternetSpeedTest _internetSpeedTest = FlutterInternetSpeedTest();

  double _downloadRate = 0;
  String _unit = '';
  bool _isTesting = false;

  void _startTest() {
    setState(() {
      _isTesting = true;
      _downloadRate = 0;
      _unit = '';
    });

    _internetSpeedTest.startTesting(
      onProgress: (double percent, TestResult data) {
        setState(() {
          _downloadRate = data.transferRate;
          _unit = data.unit.name;
        });
      },
      onCompleted: (TestResult download, TestResult upload) {
        setState(() => _isTesting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '測試完成：下載 ${download.transferRate.toStringAsFixed(2)} ${download.unit.name}，'
                  '上傳 ${upload.transferRate.toStringAsFixed(2)} ${upload.unit.name}',
            ),
          ),
        );
      },
      onError: (String errorMessage, String speedTestError) {
        setState(() => _isTesting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('測試失敗：$errorMessage')),
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
                _isTesting
                    ? '測試中...'
                    : _downloadRate > 0
                    ? '下載速度：${_downloadRate.toStringAsFixed(2)} $_unit'
                    : '尚未開始測試',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isTesting ? null : _startTest,
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
