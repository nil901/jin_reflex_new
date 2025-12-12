import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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
class RightHandScreen extends StatefulWidget {
  final String diagnosisId;
  final String pid;

  const RightHandScreen({required this.diagnosisId, required this.pid});

  @override
  State<RightHandScreen> createState() => _RightHandScreenState();
}

class _RightHandScreenState extends State<RightHandScreen> {
  static const double baseWidth = 340;
  static const double baseHeight = 130;

  List<PointData> points = [];
  bool isLoading = true;

  final GlobalKey screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  // --------------------------------------------------
  Future<void> loadPoints() async {
    try {
      final jsonString = await rootBundle.loadString(
        "assets/right_hand_btn.json",
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final List<dynamic> list = jsonMap["RightHand"];
      points = list.map((e) => PointData.fromJson(e)).toList();

      // only load state, not X,Y
      loadSavedState();

      await fetchServer();

      setState(() => isLoading = false);
    } catch (e) {
      print("LOAD ERROR RH: $e");
    }
  }

  // --------------------------------------------------
  // LOAD ONLY STATE FROM LOCAL
  void loadSavedState() {
    final key = "RH_DATA_${widget.diagnosisId}_${widget.pid}";
    final raw = AppPreference().getString(key);

    if (raw.isEmpty) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    decoded.forEach((idx, val) {
      final parts = val.split(",");
      final p = points.firstWhere((e) => e.index.toString() == idx);
      // DO NOT LOAD XY
      // p.x = double.parse(parts[0]);
      // p.y = double.parse(parts[1]);
      p.state = int.parse(parts[2]);
    });
  }

  // --------------------------------------------------
  // SAVE ONLY STATE
  Future<void> saveAllPointsFast() async {
    Map<String, String> data = {};

    for (var p in points) {
      data[p.index.toString()] = "${p.x},${p.y},${p.state}";
    }

    await AppPreference().setString(
      "RH_DATA_${widget.diagnosisId}_${widget.pid}",
      jsonEncode(data),
    );
  }

  // --------------------------------------------------
  Future<void> fetchServer() async {
    try {
      final response = await Dio().post(
        "https://jinreflexology.in/api/get_data.php",
        data: FormData.fromMap({
          "diagnosisId": widget.diagnosisId,
          "pid": widget.pid,
          "which": "rh",
        }),
        options: Options(responseType: ResponseType.plain),
      );

      String raw = response.data.toString();
      int start = raw.indexOf("{");
      int end = raw.lastIndexOf("}");
      String jsonStr = raw.substring(start, end + 1);

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
      print("SERVER RH ERROR: $e");
    }
  }

  // --------------------------------------------------
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
          "which": "rh",
          "data": sb.toString(),
        }),
      );
    } catch (e) {
      print("SAVE RH ERROR: $e");
    }
  }

  // --------------------------------------------------
  // CAPTURE SCREENSHOT
  // --------------------------------------------------
  Future<String?> captureScreenshot() async {
    try {
      RenderRepaintBoundary boundary = screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      String base64 = base64Encode(pngBytes);
      return base64;
    } catch (e) {
      print("Screenshot error: $e");
      return null;
    }
  }

  // --------------------------------------------------
  // FIXED DOT
  Widget _buildDot(PointData p, double scaleX, double scaleY) {
    Color color;
    if (p.state == 1)
      color = Colors.red;
    else if (p.state == 2)
      color = Colors.green;
    else
      color = Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => p.state = (p.state + 1) % 3);

        print(
          "CLICK => ID:${p.id}, Index:${p.index}, X:${p.x}, Y:${p.y}, State:${p.state}",
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
  Future<void> _saveAndExit() async {
    await saveAllPointsFast();

    // Capture screenshot
    final base64 = await captureScreenshot();
    if (base64 != null) {
      await AppPreference().setString("RH_IMG_${widget.diagnosisId}_${widget.pid}", base64);
    }

    await AppPreference().setBool(
      "RH_SAVED_${widget.diagnosisId}_${widget.pid}",
      true,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saving...")));
    Navigator.pop(context);
    saveAllToServer();
  }

  // --------------------------------------------------
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
        title: const Text("Right Hand Editor"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndExit,
        backgroundColor: Colors.green,
        label: const Text("Save"),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: SizedBox(
                  width: containerW,
                  height: containerH,
                  child: RepaintBoundary(
                    key: screenshotKey,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/hand_right.png',
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
              ),
    );
  }
}
