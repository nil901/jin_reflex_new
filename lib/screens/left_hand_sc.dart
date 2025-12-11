import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';

// --------------------------------------------------
// MODEL
// --------------------------------------------------
class PointData {
  final String id;
  double x;
  double y;
  final String tag;
  final int index;
  final String group;

  /// 0 = white
  /// 1 = red
  /// 2 = green
  int state;

  PointData({
    required this.id,
    required this.x,
    required this.y,
    required this.tag,
    required this.index,
    required this.group,
    this.state = 0,
  });

  factory PointData.fromJson(Map<String, dynamic> json) {
    return PointData(
      id: json["id"],
      x: json["x"].toDouble(),
      y: json["y"].toDouble(),
      tag: json["tag"],
      index: json["index"],
      group: json["group"],
      state: 0,
    );
  }
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------
class LeftHandScreen extends StatefulWidget {
  final String diagnosisId;
  final String pid;

  const LeftHandScreen({required this.diagnosisId, required this.pid});

  @override
  State<LeftHandScreen> createState() => _LeftHandScreenState();
}

class _LeftHandScreenState extends State<LeftHandScreen> {
  static const double baseWidth = 340;
  static const double baseHeight = 130;

  List<PointData> points = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  // --------------------------------------------------
  // LOAD JSON + LOCAL
  Future<void> loadPoints() async {
    try {
      final jsonString = await rootBundle.loadString(
        "assets/left_hand_btn.json",
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final List<dynamic> jsonList = jsonMap["LeftHand"];
      points = jsonList.map((p) => PointData.fromJson(p)).toList();

      loadSavedLocal();

      setState(() => isLoading = false);
    } catch (e) {
      print("JSON ERROR: $e");
    }
  }

  // --------------------------------------------------
  // LOAD FROM LOCAL (FAST)
  void loadSavedLocal() {
    final key = "LH_DATA_${widget.diagnosisId}_${widget.pid}";
    final raw = AppPreference().getString(key);

    if (raw.isEmpty) return;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    decoded.forEach((idx, val) {
      final parts = val.split(",");
      final p = points.firstWhere((e) => e.index.toString() == idx);
      p.x = double.parse(parts[0]);
      p.y = double.parse(parts[1]);
      p.state = int.parse(parts[2]);
    });
  }

  // --------------------------------------------------
  // FAST SAVE (ONE WRITE)
  Future<void> saveAllPointsFast() async {
    Map<String, String> data = {};

    for (var p in points) {
      data[p.index.toString()] = "${p.x},${p.y},${p.state}";
    }

    await AppPreference().setString(
      "LH_DATA_${widget.diagnosisId}_${widget.pid}",
      jsonEncode(data),
    );
  }

  // --------------------------------------------------
  // SERVER FETCH
  Future<void> fetchServer() async {
    try {
      final response = await Dio().post(
        "https://jinreflexology.in/api/get_data.php",
        data: FormData.fromMap({
          "diagnosisId": widget.diagnosisId,
          "pid": widget.pid,
          "which": "lh",
        }),
        options: Options(responseType: ResponseType.plain),
      );

      final raw = response.data.toString();
      final start = raw.indexOf("{");
      final end = raw.lastIndexOf("}");
      final jsonStr = raw.substring(start, end + 1);

      final body = jsonDecode(jsonStr);

      if (body["success"] == 1) {
        String dataStr = body["data"];
        Map<int, int> states = {};

        for (var item in dataStr.split(";")) {
          if (item.contains(":")) {
            final part = item.split(":");
            states[int.parse(part[0])] = int.parse(part[1]);
          }
        }

        for (var p in points) {
          if (states.containsKey(p.index)) {
            int val = states[p.index]!;
            if (val == 1)
              p.state = 2;
            else if (val == -1)
              p.state = 0;
            else
              p.state = 1;
          }
        }
      }
    } catch (e) {
      print("SERVER LH ERROR: $e");
    }
  }

  // --------------------------------------------------
  // SERVER SAVE (ASYNC)
  Future<void> saveAllToServer() async {
    StringBuffer sb = StringBuffer();

    for (var p in points) {
      int sendVal =
          (p.state == 2)
              ? 1
              : (p.state == 0)
              ? -1
              : 0;

      sb.write("${p.index}:$sendVal;");
    }

    try {
      await Dio().post(
        "https://jinreflexology.in/api/save_data.php",
        data: FormData.fromMap({
          "diagnosisId": widget.diagnosisId,
          "pid": widget.pid,
          "which": "lh",
          "data": sb.toString(),
        }),
      );
    } catch (e) {
      print("SAVE LH ERROR: $e");
    }
  }

  // --------------------------------------------------
  // DOT UI
  Widget _buildDot(PointData p, double scaleX, double scaleY) {
    Color color;
    if (p.state == 1)
      color = Colors.red;
    else if (p.state == 2)
      color = Colors.green;
    else
      color = Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() => p.state = (p.state + 1) % 3);

        print(
          "LH CLICK => ID:${p.id}, Index:${p.index}, "
          "X:${p.x.toStringAsFixed(2)}, Y:${p.y.toStringAsFixed(2)}, "
          "State:${p.state}",
        );
      },
      onPanUpdate: (details) {
        setState(() {
          p.x += details.delta.dx / scaleX;
          p.y += details.delta.dy / scaleY;
        });

        print(
          "LH MOVE => ID:${p.id}, Index:${p.index}, "
          "X:${p.x.toStringAsFixed(2)}, Y:${p.y.toStringAsFixed(2)}, "
          "State:${p.state}",
        );
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SAVE & EXIT
  Future<void> _saveAndExit() async {
    await saveAllPointsFast();

    await AppPreference().setBool(
      "LH_SAVED_${widget.diagnosisId}_${widget.pid}",
      true,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saving data...")));

    Navigator.pop(context);

    saveAllToServer();
  }

  // --------------------------------------------------
  // UI
  @override
  Widget build(BuildContext context) {
    double desiredAspect = baseWidth / baseHeight;

    double screenW = MediaQuery.of(context).size.width * 0.95;
    double screenH = MediaQuery.of(context).size.height * 0.30;

    double containerW = math.min(screenW, screenH * desiredAspect);
    double containerH = containerW / desiredAspect;

    double scaleX = containerW / baseWidth;
    double scaleY = containerH / baseHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Left Hand Editor"),
        backgroundColor: Colors.green,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndExit,
        label: const Text("Save"),
        backgroundColor: Colors.green,
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Container(
                  width: containerW,
                  height: containerH,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/hand_left.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      ...points.map((p) {
                        return Positioned(
                          left: p.x * scaleX,
                          top: p.y * scaleY,
                          child: _buildDot(p, scaleX, scaleY),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
    );
  }
}
