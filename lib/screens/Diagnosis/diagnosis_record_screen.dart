import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:jin_reflex_new/screens/foot_images/left_foot_screen.dart';
import 'package:jin_reflex_new/screens/foot_images/left_hand_sc.dart';
import 'package:jin_reflex_new/screens/foot_images/right_hand_sc.dart';
import 'package:jin_reflex_new/screens/foot_images/right_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({
    super.key,
    this.patient_id,
    this.name,
    this.diagnosis_id,
  });

  // keep dynamic for flexibility (int or String)
  final dynamic patient_id;
  final dynamic name;
  final dynamic diagnosis_id;

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String? satisfaction = "Yes";
  final TextEditingController matchedProblem = TextEditingController();
  final TextEditingController notDetected = TextEditingController();

  bool lfSaved = false;
  bool rfSaved = false;
  bool lhSaved = false;
  bool rhSaved = false;

  final List<String> diagnosisOptions = [
    "Diagnose Left Foot",
    "Diagnose Right Foot",
    "Diagnose Left Hand",
    "Diagnose Right Hand",
  ];

  @override
  void initState() {
    super.initState();
    loadSavedStatus();
  }

  void loadSavedStatus() {
    try {
      final lfKey = "LF_SAVED_${widget.diagnosis_id}_${widget.patient_id}";
      final rfKey = "RF_SAVED_${widget.diagnosis_id}_${widget.patient_id}";
      final lhKey = "LH_SAVED_${widget.diagnosis_id}_${widget.patient_id}";
      final rhKey = "RH_SAVED_${widget.diagnosis_id}_${widget.patient_id}";

      final lf = AppPreference().getBool(lfKey);
      final rf = AppPreference().getBool(rfKey);
      final lh = AppPreference().getBool(lhKey);
      final rh = AppPreference().getBool(rhKey);

      debugPrint(
        "LOAD SAVED STATUS -> LF:$lfKey=$lf, RF:$rfKey=$rf, LH:$lhKey=$lh, RH:$rhKey=$rh",
      );

      setState(() {
        lfSaved = lf;
        rfSaved = rf;
        lhSaved = lh;
        rhSaved = rh;
      });
    } catch (e, st) {
      debugPrint("Error in loadSavedStatus: $e");
      debugPrint("$st");
      // keep defaults (false)
    }
  }

  Color _borderColor(String option) {
    if (option == "Diagnose Left Foot" && lfSaved) return Colors.green;
    if (option == "Diagnose Right Foot" && rfSaved) return Colors.green;
    if (option == "Diagnose Left Hand" && lhSaved) return Colors.green;
    if (option == "Diagnose Right Hand" && rhSaved) return Colors.green;

    return const Color(0xffF9CF63);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F3EB),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Diagnosis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF9CF63),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Patient ID : ${widget.patient_id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Patient Name : ${widget.name}",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF9CF63),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: const Center(
                child: Text(
                  "Diagnosis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            ...diagnosisOptions.map((option) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor(option), width: 2),
                ),
                child: ListTile(
                  title: Center(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (option == "Diagnose Left Foot") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => LeftFootScreenNew(
                                diagnosisId: widget.diagnosis_id.toString(),
                                patientId: widget.patient_id.toString(),
                                pid: "22", // ← ALWAYS STRING
                              ),
                        ),
                      ).then((_) {
                        loadSavedStatus();
                      });
                    } else if (option == "Diagnose Right Foot") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => rightFootScreenNew(
                                pid: widget.patient_id,
                                diagnosisId: widget.diagnosis_id,
                              ),
                        ),
                      ).then((_) {
                        loadSavedStatus();
                      });
                    } else if (option == "Diagnose Right Hand") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RightHandScreen(
                                pid: widget.patient_id,
                                diagnosisId: widget.diagnosis_id,
                              ),
                        ),
                      ).then((_) {
                        loadSavedStatus();
                      });
                    } else if (option == "Diagnose Left Hand") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LeftHandScreen(
                                pid: widget.patient_id,
                                diagnosisId: widget.diagnosis_id,
                              ),
                        ),
                      ).then((_) {
                        loadSavedStatus();
                      });
                    }
                  },
                ),
              );
            }),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Are You Satisfied with the Diagnosis?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: "Yes",
                          groupValue: satisfaction,
                          title: const Text("Yes"),
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() => satisfaction = value);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: "No",
                          groupValue: satisfaction,
                          title: const Text("No"),
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() => satisfaction = value);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _textInput(
                    "Which of the Diagnosis points match your problem?",
                    matchedProblem,
                  ),

                  const SizedBox(height: 12),

                  _textInput("Which problems were not detected?", notDetected),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _button("Cancel", Colors.black87, () {
              Navigator.pop(context);
            }),
            _button("Submit", Colors.green, () async {
              await _submitDiagnosis();
            }),
          ],
        ),
      ),
    );
  }

  Widget _textInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _button(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  // Builds data/result for a part (LF/RF/LH/RH)
  Future<Map<String, String>> _buildDataForPart(
    String label,
    String asset,
    String listKey,
    String prefKey,
  ) async {
    debugPrint(
      ">>> _buildDataForPart START ($label) asset:$asset listKey:$listKey prefKey:$prefKey",
    );

    Map<String, dynamic> idMap = {};
    try {
      final jsonStr = await rootBundle.loadString(asset);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      final dynamic arrDyn = jsonMap[listKey];

      if (arrDyn is List) {
        for (var item in arrDyn) {
          try {
            final idx = item['index'].toString();
            idMap[idx] = item;
          } catch (e) {
            debugPrint("Skipping invalid item in asset for $label: $e");
          }
        }
      } else {
        debugPrint(
          "Asset $asset: expected list at $listKey but found ${arrDyn.runtimeType}",
        );
      }
      debugPrint("Asset loaded for $label, idMap size: ${idMap.length}");
    } catch (e, st) {
      debugPrint("Error loading/parsing asset '$asset' for $label: $e");
      debugPrint("$st");
    }

    final saved = AppPreference().getString(prefKey);
    debugPrint("PREF ($prefKey) => '$saved'");

    if (saved.isEmpty) {
      debugPrint("$label saved string empty -> returning empty map");
      return {
        '${label.toLowerCase()}_data': '',
        '${label.toLowerCase()}_result': '',
      };
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(saved) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error decoding saved JSON for $label: $e");
      return {
        '${label.toLowerCase()}_data': '',
        '${label.toLowerCase()}_result': '',
      };
    }

    List<String> dataParts = [];
    List<String> resultParts = [];

    for (var idx in decoded.keys) {
      try {
        final val = decoded[idx] as String;
        final parts = val.split(',');
        final stateStr = parts.length > 2 ? parts[2] : '';
        final state = int.tryParse(stateStr);

        // skip if state null or zero
        if (state == null || state == 0) continue;

        int serverVal;
        if (state == 2) {
          serverVal = 1;
        } else if (state == 1) {
          serverVal = 0;
        } else {
          // unknown state, skip
          continue;
        }

        dataParts.add('$idx:$serverVal');

        final item = idMap[idx];
        if (item != null && item['tag'] != null) {
          resultParts.add(item['tag'].toString());
        }
      } catch (e) {
        debugPrint("Error processing saved entry $idx for $label: $e");
      }
    }

    final res = {
      '${label.toLowerCase()}_data': dataParts.join(';'),
      '${label.toLowerCase()}_result': resultParts.join('|'),
    };

    debugPrint(
      "$label build result -> data: ${res['${label.toLowerCase()}_data']}, result: ${res['${label.toLowerCase()}_result']}",
    );
    return res;
  }

  Future<void> _submitDiagnosis() async {
    debugPrint(
      ">>> _submitDiagnosis START for pid=${widget.patient_id}, diag=${widget.diagnosis_id}",
    );

    // -------------------------------
    // Build all 4 part data
    // -------------------------------
    var lf = await _buildDataForPart(
      'LF',
      'assets/button.json',
      'buttons',
      'LF_DATA_${widget.diagnosis_id}_${widget.patient_id}',
    );
    var rf = await _buildDataForPart(
      'RF',
      'assets/right_foot.json',
      'RightFoot',
      'RF_DATA_${widget.diagnosis_id}_${widget.patient_id}',
    );
    var lh = await _buildDataForPart(
      'LH',
      'assets/left_hand_btn.json',
      'LeftHand',
      'LH_DATA_${widget.diagnosis_id}_${widget.patient_id}',
    );
    var rh = await _buildDataForPart(
      'RH',
      'assets/right_hand_btn.json',
      'RightHand',
      'RH_DATA_${widget.diagnosis_id}_${widget.patient_id}',
    );

    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // -------------------------------
    // PREPARE REQUEST
    // -------------------------------
    var uri = Uri.parse("https://jinreflexology.in/api/add_diagnosis.php");
    var request = http.MultipartRequest("POST", uri);

    // pid ALWAYS static = 22
    request.fields["pid"] = "22";

    // patient_id = dynamic
    request.fields["patient_id"] = widget.patient_id.toString();
    request.fields["timestamp"] = timestamp;

    // Only add if not empty
    if (lf['lf_data']!.isNotEmpty) {
      request.fields['lf_data'] = lf['lf_data']!;
      request.fields['lf_result'] = lf['lf_result']!;
    }
    if (rf['rf_data']!.isNotEmpty) {
      request.fields['rf_data'] = rf['rf_data']!;
      request.fields['rf_result'] = rf['rf_result']!;
    }
    if (lh['lh_data']!.isNotEmpty) {
      request.fields['lh_data'] = lh['lh_data']!;
      request.fields['lh_result'] = lh['lh_result']!;
    }
    if (rh['rh_data']!.isNotEmpty) {
      request.fields['rh_data'] = rh['rh_data']!;
      request.fields['rh_result'] = rh['rh_result']!;
    }

    // -------------------------------
    // Load Base64 images from Prefs
    // -------------------------------
    final lfImg =
        AppPreference().getString(
          "LF_IMG_${widget.diagnosis_id}_${widget.patient_id}",
        ) ??
        "";
    final rfImg =
        AppPreference().getString(
          "RF_IMG_${widget.diagnosis_id}_${widget.patient_id}",
        ) ??
        "";
    final lhImg =
        AppPreference().getString(
          "LH_IMG_${widget.diagnosis_id}_${widget.patient_id}",
        ) ??
        "";
    final rhImg =
        AppPreference().getString(
          "RH_IMG_${widget.diagnosis_id}_${widget.patient_id}",
        ) ??
        "";

    debugPrint(
      "IMG LENGTHS => LF:${lfImg.length}, RF:${rfImg.length}, LH:${lhImg.length}, RH:${rhImg.length}",
    );

    // Missing image check
    final missing = <String>[];
    if (lfImg.isEmpty) missing.add("lf_img");
    if (rfImg.isEmpty) missing.add("rf_img");
    if (lhImg.isEmpty) missing.add("lh_img");
    if (rhImg.isEmpty) missing.add("rh_img");

    if (missing.isNotEmpty) {
      debugPrint("ERROR: Missing images => $missing");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Missing screenshots: ${missing.join(", ")}")),
      );
      return;
    }

    // Add images to fields
    request.fields["lf_img"] = lfImg;
    request.fields["rf_img"] = rfImg;
    request.fields["lh_img"] = lhImg;
    request.fields["rh_img"] = rhImg;

    // Duplicate fields as required
    request.fields["lf_img2"] = lfImg;
    request.fields["lh_img2"] = lhImg;

    // Other form fields
    request.fields["is_satisfied"] = satisfaction ?? "Yes";
    request.fields["not_detected"] = notDetected.text;
    request.fields["problems_matched"] = matchedProblem.text;

    // -------------------------------
    // POSTMAN DEBUG JSON OUTPUT
    // -------------------------------
    final postmanBody = {
      "pid": "22",
      "patient_id": widget.patient_id.toString(),
      "timestamp": timestamp,
      "lf_data": lf["lf_data"],
      "lf_result": lf["lf_result"],
      "rf_data": rf["rf_data"],
      "rf_result": rf["rf_result"],
      "lh_data": lh["lh_data"],
      "lh_result": lh["lh_result"],
      "rh_data": rh["rh_data"],
      "rh_result": rh["rh_result"],
      "lf_img": lfImg,
      "rf_img": rfImg,
      "lh_img": lhImg,
      "rh_img": rhImg,
      "lf_img2": lfImg,
      "lh_img2": lhImg,
      "is_satisfied": satisfaction ?? "Yes",
      "not_detected": notDetected.text,
      "problems_matched": matchedProblem.text,
    };

    debugPrint("=========== POSTMAN JSON ===========");
    debugPrint(jsonEncode(postmanBody)); // <-- copy this into Postman
    debugPrint("====================================");

    // -------------------------------
    // SEND REQUEST
    // -------------------------------
    try {
      final streamedResponse = await request.send();
      final responseString = await streamedResponse.stream.bytesToString();

      debugPrint("API STATUS: ${streamedResponse.statusCode}");
      debugPrint("API RESPONSE: $responseString");

      if (streamedResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Diagnosis Submitted Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${streamedResponse.statusCode}")),
        );
      }
    } catch (e, st) {
      debugPrint("API ERROR: $e");
      debugPrint("$st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    matchedProblem.dispose();
    notDetected.dispose();
    super.dispose();
  }
}
