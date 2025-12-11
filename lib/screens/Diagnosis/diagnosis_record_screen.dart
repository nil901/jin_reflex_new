import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/Diagnosis/left_foot_screen.dart';
import 'package:jin_reflex_new/screens/left_foot_screen.dart';
import 'package:jin_reflex_new/screens/left_hand_sc.dart';
import 'package:jin_reflex_new/screens/right_hand_sc.dart';
import 'package:jin_reflex_new/screens/right_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({
    super.key,
    this.patient_id,
    this.name,
    this.diagnosis_id,
  });
  final patient_id;
  final name;
  final diagnosis_id;

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String? satisfaction = "Yes";
  final TextEditingController matchedProblem = TextEditingController();
  final TextEditingController notDetected = TextEditingController();

  // diagnosis status flags
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
    setState(() {
      lfSaved = AppPreference().getBool(
        "LF_SAVED_${widget.diagnosis_id}_${widget.patient_id}",
      );
      rfSaved = AppPreference().getBool(
        "RF_SAVED_${widget.diagnosis_id}_${widget.patient_id}",
      );
      lhSaved = AppPreference().getBool(
        "LH_SAVED_${widget.diagnosis_id}_${widget.patient_id}",
      );
      rhSaved = AppPreference().getBool(
        "RH_SAVED_${widget.diagnosis_id}_${widget.patient_id}",
      );
    });
  }

  // dynamically get border
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
            /// 🔶 Patient Header Bar
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

            /// 🔶 DIAGNOSIS TITLE BAR
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

            /// 🔘 DIAGNOSIS OPTIONS LIST
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
                    // Navigation with response
                    if (option == "Diagnose Left Foot") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LeftFootScreenNew(
                                pid: widget.patient_id,
                                diagnosisId: widget.diagnosis_id,
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Coming Soon")),
                      );
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
                        child: RadioListTile(
                          value: "Yes",
                          groupValue: satisfaction,
                          title: const Text("Yes"),
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() => satisfaction = value.toString());
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          value: "No",
                          groupValue: satisfaction,
                          title: const Text("No"),
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() => satisfaction = value.toString());
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
              await _printSavedDiagnosisData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Diagnosis Submitted Successfully"),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------
  // INPUT FIELD
  // ---------------------------------------
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

  // ---------------------------------------
  // CUSTOM BUTTON
  // ---------------------------------------
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

  // ---------------------------------------
  // PRINT SAVED DIAGNOSIS DATA
  // ---------------------------------------
  Future<void> _printSavedDiagnosisData() async {
    // mapping of part -> (assetPath, jsonListKey, prefKeyPrefix, label)
    final parts = [
      {
        'label': 'LF',
        'asset': 'assets/button.json',
        'listKey': 'buttons',
        'pref': 'LF_DATA_${widget.diagnosis_id}_${widget.patient_id}',
      },
      {
        'label': 'RF',
        'asset': 'assets/right_foot.json',
        'listKey': 'RightFoot',
        'pref': 'RF_DATA_${widget.diagnosis_id}_${widget.patient_id}',
      },
      {
        'label': 'LH',
        'asset': 'assets/left_hand_btn.json',
        'listKey': 'LeftHand',
        'pref': 'LH_DATA_${widget.diagnosis_id}_${widget.patient_id}',
      },
      {
        'label': 'RH',
        'asset': 'assets/right_hand_btn.json',
        'listKey': 'RightHand',
        'pref': 'RH_DATA_${widget.diagnosis_id}_${widget.patient_id}',
      },
    ];

    for (var part in parts) {
      final label = part['label'] as String;
      final asset = part['asset'] as String;
      final listKey = part['listKey'] as String;
      final prefKey = part['pref'] as String;

      // Load asset once to map index -> id (for lookup)
      Map<String, dynamic> idMap = {};
      try {
        final jsonStr = await rootBundle.loadString(asset);
        final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
        final List<dynamic> arr = jsonMap[listKey] as List<dynamic>;
        for (var item in arr) {
          try {
            final idx = item['index'].toString();
            idMap[idx] = item; // keep whole item (id,x,y,etc)
          } catch (e) {
            // ignore item parse errors
          }
        }
      } catch (e) {
        // asset load failed - continue, we'll still try pref values
      }

      final saved = AppPreference().getString(prefKey);

      if (saved.isEmpty) {
        // no saved local data; print a notice
        print('$label: No local saved data found for key $prefKey');
        continue;
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(saved) as Map<String, dynamic>;
      } catch (e) {
        print('$label: Saved data for $prefKey is not valid JSON');
        continue;
      }

      // Iterate sorted by index for readability
      final keys =
          decoded.keys.toList()
            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      for (var idx in keys) {
        final val = decoded[idx] as String;
        final parts = val.split(',');
        final x = parts.isNotEmpty ? parts[0] : '';
        final y = parts.length > 1 ? parts[1] : '';
        final state = parts.length > 2 ? parts[2] : '';

        final idItem = idMap[idx];
        final id =
            (idItem != null && idItem['id'] != null)
                ? idItem['id'].toString()
                : 'IDX_$idx';

        // compute server mapping: state 2 -> 1, state 0 -> -1, state 1 -> 0
        int? stateInt;
        try {
          stateInt = int.parse(state);
        } catch (e) {
          stateInt = null;
        }

        int? serverVal;
        if (stateInt == 2)
          serverVal = 1;
        else if (stateInt == 0)
          serverVal = -1;
        else if (stateInt == 1)
          serverVal = 0;
        else
          serverVal = null;

        final serverStr = serverVal != null ? serverVal.toString() : '';

        // Print in requested format with server mapping
        print(
          '$label: ID=$id, Index=$idx, X=$x, Y=$y, State=$state, ServerVal=$serverStr',
        );
      }
    }
  }
}
