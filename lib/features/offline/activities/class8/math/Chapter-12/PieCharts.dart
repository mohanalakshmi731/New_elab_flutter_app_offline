// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

class PieChartsActivity extends StatefulWidget {
  const PieChartsActivity({super.key});

  @override
  State<PieChartsActivity> createState() => _PieChartsActivityState();
}

class _PieChartsActivityState extends State<PieChartsActivity> {
  int currentStep = 1;
  
  // Step 1 State
  Set<int> selectedSlices = {};
  
  // Step 2 State
  bool isCard25Dropped = false;
  String angleInputValue = "";
  
  // Step 3 State
  double currentSliderAngle = 0;
  bool isEnglishDropped = false;
  
  // Step 4 State
  bool isCard5000Dropped = false;

  bool showSuccess = false;
  bool isSidebarOpen = true;
  String language = 'EN';
  
  bool isShutterOpen = false;
  Offset instructionOffset = const Offset(80, 20);

  final TransformationController _transformController = TransformationController();

  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class8/mixkit_2018.mp3';
  static const String _shutterUrl = 'audio/class8/mixkit_2574.mp3';
  static const String _snapUrl = 'audio/class8/mixkit_2578.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  void playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void resetLab() {
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentStep = 1;
      selectedSlices.clear();
      isCard25Dropped = false;
      angleInputValue = "";
      currentSliderAngle = 0;
      isEnglishDropped = false;
      isCard5000Dropped = false;
      showSuccess = false;
      isShutterOpen = false;
      language = 'EN';
      _transformController.value = Matrix4.identity();
    });
  }

  void toggleLanguage(String newLang) {
    if (language == newLang) return;
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      language = newLang;
    });
  }

  bool get isStepComplete {
    if (currentStep == 1) return selectedSlices.length == 8;
    if (currentStep == 2) return isCard25Dropped && angleInputValue == "90";
    if (currentStep == 3) return currentSliderAngle == 60 && isEnglishDropped;
    if (currentStep == 4) return isCard5000Dropped;
    return false;
  }

  // Translations
  String get tTitle => language == 'EN' ? "Pie Charts" : "पाई चार्ट";
  String get tSubtitle => language == 'EN' ? "CLASS 8 • TALES BY DOTS AND LINES" : "कक्षा 8 • बिंदुओं और रेखाओं से कहानियाँ";
  String get tMission => language == 'EN' ? "MISSION OBJECTIVE" : "मिशन का उद्देश्य";
  String get tAction => language == 'EN' ? "ACTION REQUIRED" : "कार्रवाई आवश्यक";
  String get tVerify => language == 'EN' ? "Verify Step" : "सत्यापित करें";
  String get tDrop => language == 'EN' ? "Drop Here" : "यहाँ छोड़ें";
  String get tDropPct => language == 'EN' ? "Drop %" : "% यहाँ छोड़ें";

  String theoryText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "A Pie Chart (or Circle Graph) shows the relationship between a whole and its parts.\n\nFor a 24-hour day, the whole circle represents 24 hours. If a student spends 8 hours sleeping, that is exactly 1/3 of the day.\n\nVisually, this means the Sleep slice should occupy 1/3 of the circle's total area.";
        case 2: return "To draw a pie chart accurately without grid segments, we use angles. Since a full circle is 360°, we calculate the Central Angle using the formula:\n\n(Value / Total) × 360°\n\nFor example, if 50% of people like Chocolate Ice Cream, the angle is (50/100) × 360° = 180°.";
        case 3: return "Let's construct a chart for students speaking different languages. Total students = 72.\n\nHindi: 40 ➔ (40/72) × 360° = 200°\nEnglish: 12 ➔ (12/72) × 360° = 60°\nMarathi: 9 ➔ (9/72) × 360° = 45°\n\nThe sum of all central angles must be exactly 360°.";
        case 4: return "We can also find the actual value if we know the angle.\n\n\"If the Rent sector is 90° and the total salary is ₹20,000, how much is spent on rent?\"\n\nSince 90° is (90/360) or 1/4 of the circle, the rent is 1/4 of the total salary.";
      }
    } else {
      switch (step) {
        case 1: return "एक पाई चार्ट (या वृत्त आलेख) एक पूर्ण और उसके भागों के बीच संबंध दिखाता है।\n\n24 घंटे के दिन के लिए, पूरा वृत्त 24 घंटे का प्रतिनिधित्व करता है। यदि कोई छात्र 8 घंटे सोता है, तो वह दिन का ठीक 1/3 है।\n\nइसका मतलब है कि नींद (Sleep) का स्लाइस वृत्त के कुल क्षेत्रफल का 1/3 होना चाहिए।";
        case 2: return "ग्रिड खंडों के बिना सटीक पाई चार्ट बनाने के लिए, हम कोणों का उपयोग करते हैं। चूंकि एक पूर्ण वृत्त 360° है, हम इस सूत्र का उपयोग करके केंद्रीय कोण की गणना करते हैं:\n\n(मान / कुल) × 360°\n\nउदाहरण के लिए, यदि 50% लोग चॉकलेट आइसक्रीम पसंद करते हैं, तो कोण (50/100) × 360° = 180° है।";
        case 3: return "आइए विभिन्न भाषाएं बोलने वाले छात्रों के लिए एक चार्ट बनाएं। कुल छात्र = 72.\n\nहिंदी: 40 ➔ (40/72) × 360° = 200°\nअंग्रेजी: 12 ➔ (12/72) × 360° = 60°\nमराठी: 9 ➔ (9/72) × 360° = 45°\n\nसभी केंद्रीय कोणों का योग ठीक 360° होना चाहिए।";
        case 4: return "यदि हम कोण जानते हैं तो हम वास्तविक मान भी ज्ञात कर सकते हैं।\n\n\"यदि किराया क्षेत्र 90° है और कुल वेतन ₹20,000 है, तो किराए पर कितना खर्च किया जाता है?\"\n\nचूंकि 90°, वृत्त का 1/4 है, इसलिए किराया कुल वेतन का 1/4 है।";
      }
    }
    return "";
  }

  String hudText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "Let's represent 'Sleep'. Click on the segments of the 24-hour circle to highlight exactly 8 segments.";
        case 2: return "Calculate the angle for Vanilla ice cream. Drag the '25' card into the percentage slot of the formula, then type the resulting angle in the degree box.";
        case 3: return "Use the Angle Slider to measure and draw the sectors. Set the slider to 60° for English, and drag the English label into the resulting sector space.";
        case 4: return "Calculate the amount for rent. 90° is what fraction of the whole? Divide the ₹20,000 by that denominator and drag the resulting cash amount to the Rent Wallet.";
      }
    } else {
      switch (step) {
        case 1: return "आइए 'नींद' का प्रतिनिधित्व करें। ठीक 8 खंडों को हाइलाइट करने के लिए 24-घंटे के वृत्त के खंडों पर क्लिक करें।";
        case 2: return "वेनिला आइसक्रीम के लिए कोण की गणना करें। '25' कार्ड को प्रतिशत स्लॉट में खींचें, फिर परिणामी कोण को डिग्री बॉक्स में टाइप करें।";
        case 3: return "कोण स्लाइडर का उपयोग करके क्षेत्र को मापें और बनाएं। अंग्रेजी के लिए स्लाइडर को 60° पर सेट करें, और 'English' लेबल को परिणामी क्षेत्र में खींचें।";
        case 4: return "किराए की राशि की गणना करें। 90° पूरे का कौन सा अंश है? ₹20,000 को उस भाजक से विभाजित करें और नकद राशि को 'Rent Wallet' में खींचें।";
      }
    }
    return "";
  }

  Widget _buildLanguageAndControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => toggleLanguage('EN'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: language == 'EN' ? Colors.yellow : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Text("EN", style: TextStyle(color: language == 'EN' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                GestureDetector(
                  onTap: () => toggleLanguage('HI'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: language == 'HI' ? Colors.yellow : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Text("HI", style: TextStyle(color: language == 'HI' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 28),
            onPressed: resetLab,
          )
        ],
      ),
    );
  }

  Widget buildSidebar() {
    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.95),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.yellow, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tTitle, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(tSubtitle, style: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLanguageAndControls(),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<int>(
              value: currentStep,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              items: [
                DropdownMenuItem(value: 1, child: Text(language == 'EN' ? "Step 1: Visualizing Proportions" : "चरण 1: अनुपात की कल्पना")),
                DropdownMenuItem(value: 2, child: Text(language == 'EN' ? "Step 2: Calculating Central Angles" : "चरण 2: केंद्रीय कोणों की गणना")),
                DropdownMenuItem(value: 3, child: Text(language == 'EN' ? "Step 3: Pie Chart Construction" : "चरण 3: पाई चार्ट निर्माण")),
                DropdownMenuItem(value: 4, child: Text(language == 'EN' ? "Step 4: Reverse Calculation" : "चरण 4: उलटी गणना")),
              ],
              onChanged: (val) {
                if (val != null) {
                  playSound(_clickPlayer, _clickUrl);
                  setState(() => currentStep = val);
                }
              },
              decoration: InputDecoration(
                filled: true, fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(tMission, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(theoryText(currentStep), style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.yellow, size: 20),
                      const SizedBox(width: 8),
                      Text(tAction, style: const TextStyle(color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(hudText(currentStep), style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
                  if (isStepComplete) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, color: Colors.black),
                      label: Text(tVerify, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        playSound(_successPlayer, _successUrl);
                        if (currentStep < 4) {
                          setState(() => currentStep++);
                        } else {
                          setState(() => showSuccess = true);
                        }
                      },
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("© ZEROSCIENCELAB | Fall in Love with Math and Science", textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontSize: 12)),
            ),
          ]
        )
      )
    );
  }

  Widget buildDraggableCard(String id, Widget content, {bool isInteractive = true}) {
    if (!isInteractive) {
      return Opacity(opacity: 0.7, child: content);
    }
    return Draggable<String>(
      data: id,
      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.1, child: content)),
      childWhenDragging: Opacity(opacity: 0.3, child: content),
      child: content,
    );
  }

  Widget buildSourceContainer() {
    if (currentStep == 1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(language == 'EN' ? "Activities" : "गतिविधियाँ", style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)), child: Text(language == 'EN' ? "Sleep (8 hrs)" : "नींद (8 घंटे)", style: const TextStyle(color: Colors.white, fontSize: 12))),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)), child: Text(language == 'EN' ? "School (6 hrs)" : "स्कूल (6 घंटे)", style: const TextStyle(color: Colors.white54, fontSize: 12))),
            const SizedBox(height: 12),
            Text(language == 'EN' ? "Selected Segments: ${selectedSlices.length}" : "चयनित खंड: ${selectedSlices.length}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    } else if (currentStep == 2) {
      Widget card25 = Container(
        width: 70, height: 60,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.pink, Colors.red]), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white30), boxShadow: const [BoxShadow(color: Colors.pink, blurRadius: 8)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(language == 'EN' ? "VANILLA" : "वेनिला", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const Text("25%", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      );
      Widget card50 = Container(
        width: 70, height: 60,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.orange]), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white30), boxShadow: const [BoxShadow(color: Colors.deepOrange, blurRadius: 8)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(language == 'EN' ? "CHOCO" : "चोको", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const Text("50%", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      );
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isCard25Dropped) buildDraggableCard("25", card25) else const SizedBox(width: 70),
          const SizedBox(width: 16),
          buildDraggableCard("50", card50),
        ],
      );
    } else if (currentStep == 3) {
      Widget cardEng = Container(
        width: 120, height: 40,
        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white30)),
        alignment: Alignment.center,
        child: Text(language == 'EN' ? "English (60°)" : "अंग्रेजी (60°)", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      );
      Widget cardHin = Container(
        width: 120, height: 40,
        decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white30)),
        alignment: Alignment.center,
        child: Text(language == 'EN' ? "Hindi (200°)" : "हिंदी (200°)", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      );
      Widget cardMar = Container(
        width: 120, height: 40,
        decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white30)),
        alignment: Alignment.center,
        child: Text(language == 'EN' ? "Marathi (45°)" : "मराठी (45°)", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      );
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isEnglishDropped) buildDraggableCard("english", cardEng) else const SizedBox(width: 120),
          const SizedBox(width: 8),
          cardHin,
          const SizedBox(width: 8),
          cardMar,
        ],
      );
    } else if (currentStep == 4) {
      Widget buildMoneyCard(String amt) {
        return Container(
          width: 90, height: 40,
          decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.greenAccent)),
          alignment: Alignment.center,
          child: Text("₹ $amt", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildDraggableCard("10000", buildMoneyCard("10,000")),
          const SizedBox(width: 12),
          if (!isCard5000Dropped) buildDraggableCard("5000", buildMoneyCard("5,000")) else const SizedBox(width: 90),
          const SizedBox(width: 12),
          buildDraggableCard("2500", buildMoneyCard("2,500")),
        ],
      );
    }
    return const SizedBox();
  }

  void handlePieTap(TapUpDetails details) {
    if (currentStep != 1) return;
    
    // Calculate angle relative to center (150,150)
    double dx = details.localPosition.dx - 150;
    double dy = details.localPosition.dy - 150;
    
    // Distance check
    double dist = math.sqrt(dx*dx + dy*dy);
    if (dist > 140) return; // Outside circle
    
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    angle += 90; // Shift origin to 12 o'clock
    if (angle < 0) angle += 360;
    
    int sliceIndex = (angle / 15).floor() % 24;
    
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      if (selectedSlices.contains(sliceIndex)) {
        selectedSlices.remove(sliceIndex);
      } else {
        selectedSlices.add(sliceIndex);
      }
    });
  }

  Widget buildCanvasContent() {
    if (currentStep == 1) {
      return GestureDetector(
        onTapUp: handlePieTap,
        child: SizedBox(
          width: 300, height: 300,
          child: CustomPaint(
            size: const Size(300, 300),
            painter: PiePainter(selectedSlices: selectedSlices, drawGrid: true),
            child: const Center(
              child: Icon(Icons.access_time, size: 40, color: Colors.white24),
            ),
          ),
        ),
      );
    } else if (currentStep == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("(", style: TextStyle(color: Colors.white54, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          DragTarget<String>(
            onWillAccept: (d) => d == "25",
            onAccept: (d) {
              playSound(_fxPlayer, _snapUrl);
              setState(() => isCard25Dropped = true);
            },
            builder: (ctx, cand, rej) {
              if (isCard25Dropped) {
                return Container(
                  width: 80, height: 70,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.pink, Colors.red]), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.yellowAccent, width: 2)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(language == 'EN' ? "VANILLA" : "वेनिला", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    const Text("25%", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                );
              }
              return Container(
                width: 80, height: 70,
                decoration: BoxDecoration(
                  color: cand.isNotEmpty ? Colors.yellow.withOpacity(0.3) : Colors.black26,
                  border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.white54, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8)
                ),
                alignment: Alignment.center,
                child: Text(cand.isNotEmpty ? "" : tDropPct, style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
              );
            },
          ),
          const SizedBox(width: 16),
          const Text("/ 100 )  ×  360°  =", style: TextStyle(color: Colors.white54, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: TextField(
              onChanged: (val) {
                setState(() => angleInputValue = val);
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.yellow, width: 2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text("°", style: TextStyle(color: Colors.yellow, fontSize: 40, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (currentStep == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300, height: 300,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(300, 300),
                  painter: SectorPainter(angle: currentSliderAngle),
                ),
                // Dropzone at specific sector position
                Positioned(
                  right: 40, top: 40,
                  child: DragTarget<String>(
                    onWillAccept: (d) => d == "english" && currentSliderAngle == 60,
                    onAccept: (d) {
                      playSound(_fxPlayer, _snapUrl);
                      setState(() => isEnglishDropped = true);
                    },
                    builder: (ctx, cand, rej) {
                      if (isEnglishDropped) {
                        return Container(
                          width: 100, height: 30,
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white30)),
                          alignment: Alignment.center,
                          child: Text(language == 'EN' ? "English (60°)" : "अंग्रेजी (60°)", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      }
                      return Container(
                        width: 100, height: 50,
                        decoration: BoxDecoration(
                          color: cand.isNotEmpty ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                          border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.white30, width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        alignment: Alignment.center,
                        child: Text(tDrop, style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }
                  )
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 300, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ANGLE SLIDER", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text("${currentSliderAngle.toInt()}°", style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: currentSliderAngle,
                  min: 0, max: 360, divisions: 72,
                  activeColor: Colors.yellow,
                  onChanged: (val) {
                    setState(() => currentSliderAngle = val);
                  },
                )
              ],
            ),
          )
        ],
      );
    } else if (currentStep == 4) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 250, height: 250,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(250, 250),
                  painter: StaticPiePainter(),
                ),
                Positioned(top: 30, right: 30, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), color: Colors.black54, child: Text(language == 'EN' ? "Rent (90°)" : "किराया (90°)", style: const TextStyle(color: Colors.white, fontSize: 12)))),
                Positioned(bottom: 30, right: 30, child: Text(language == 'EN' ? "Food" : "भोजन", style: const TextStyle(color: Colors.white, fontSize: 14))),
                Positioned(top: 115, left: 20, child: Text(language == 'EN' ? "Savings" : "बचत", style: const TextStyle(color: Colors.white, fontSize: 14))),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.5))),
                child: Column(children: [
                  Text(language == 'EN' ? "TOTAL SALARY" : "कुल वेतन", style: TextStyle(color: Colors.blue.shade300, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("₹ 20,000", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                width: 200, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.yellow, size: 16),
                    const SizedBox(width: 6),
                    Text(language == 'EN' ? "RENT WALLET" : "किराया वॉलेट", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),
                  DragTarget<String>(
                    onWillAccept: (d) => d == "5000",
                    onAccept: (d) {
                      playSound(_fxPlayer, _snapUrl);
                      setState(() => isCard5000Dropped = true);
                    },
                    builder: (ctx, cand, rej) {
                      if (isCard5000Dropped) {
                        return Container(
                          width: 120, height: 40,
                          decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.yellowAccent, width: 2)),
                          alignment: Alignment.center,
                          child: const Text("₹ 5,000", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        );
                      }
                      return Container(
                        width: 140, height: 50,
                        decoration: BoxDecoration(
                          color: cand.isNotEmpty ? Colors.yellow.withOpacity(0.3) : Colors.black26,
                          border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.white30, width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        alignment: Alignment.center,
                        child: Text(tDrop, style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }
                  )
                ]),
              )
            ],
          )
        ],
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: GridPatternPainter(),
              ),
            ),
          ),
          
          // Main Interactive Area
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 2.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(1000),
              child: SizedBox(
                width: 1200,
                height: 800,
                child: Center(
                  child: buildCanvasContent(),
                ),
              ),
            ),
          ),
          
          // Source Container Tool Panel (Top Center)
          if (isShutterOpen)
            Positioned(
              left: isSidebarOpen ? sidebarWidth : 0, 
              right: 0, 
              top: 20,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]
                  ),
                  child: buildSourceContainer()
                )
              )
            ),

          // Sidebar Container
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isSidebarOpen ? 0 : -sidebarWidth,
            top: 0, bottom: 0, width: sidebarWidth,
            child: buildSidebar(),
          ),
          
          // Sidebar Edge Toggle Button
          if (isShutterOpen)
            Positioned(
              left: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
                onPressed: () {
                  playSound(_clickPlayer, _clickUrl);
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
              ),
            ),

          // Compact Instructions AND Language/Reset Controls
          if (!isSidebarOpen && !isShutterOpen)
            Positioned(
              left: instructionOffset.dx,
              top: instructionOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    instructionOffset += details.delta;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLanguageAndControls(),
                    const SizedBox(height: 12),
                    Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.95),
                        border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tMission, style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const Icon(Icons.drag_indicator, color: Colors.white54, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(hudText(currentStep), style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ),
          
          if (showSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.yellow, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 90),
                          const SizedBox(height: 20),
                          Text(language == 'EN' ? "Lab Completed!" : "लैब पूर्ण!", style: const TextStyle(color: Colors.yellow, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(language == 'EN' ? "Congratulations! You have successfully mastered Pie Charts." : "बधाई हो! आपने सफलतापूर्वक पाई चार्ट में महारत हासिल कर ली है।", style: const TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, color: Colors.black),
                            label: Text(language == 'EN' ? "Restart Lab" : "लैब पुनरारंभ करें", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                            onPressed: resetLab,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // HTML-like Smooth Shutter sliding up
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutQuart,
            top: isShutterOpen ? -MediaQuery.of(context).size.height : 0,
            left: 0, right: 0, height: MediaQuery.of(context).size.height,
            child: Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: Colors.transparent, 
                        border: Border.all(color: Colors.yellow, width: 4), 
                        boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 40)]
                      ),
                      child: const Icon(Icons.pie_chart, color: Colors.yellow, size: 60),
                    ),
                    const SizedBox(height: 32),
                    Text(tTitle, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(tSubtitle, style: const TextStyle(color: Colors.yellow, fontSize: 16, letterSpacing: 5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 60),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shadowColor: Colors.yellow.withOpacity(0.3),
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        playSound(_fxPlayer, _shutterUrl);
                        setState(() => isShutterOpen = true);
                      },
                      icon: const Icon(Icons.play_circle_fill, color: Colors.black, size: 28),
                      label: Text(language == 'EN' ? "ENTER LAB" : "प्रयोगशाला में प्रवेश करें", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    )
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}

class PiePainter extends CustomPainter {
  final Set<int> selectedSlices;
  final bool drawGrid;

  PiePainter({required this.selectedSlices, this.drawGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    Paint bgPaint = Paint()..color = Colors.black26..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    Paint strokePaint = Paint()
      ..color = const Color(0xFF020617) // Canvas bg color for grid separation
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Paint fillPaint = Paint()..style = PaintingStyle.fill..color = Colors.yellow;

    double sweepAngle = (15 * math.pi) / 180;
    
    // Rotate to start at 12 o'clock (-90 degrees)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < 24; i++) {
      double startAngle = i * sweepAngle;
      
      if (selectedSlices.contains(i)) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, true, fillPaint
        );
      }
      
      if (drawGrid) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, true, strokePaint
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PiePainter oldDelegate) {
    return oldDelegate.selectedSlices != selectedSlices;
  }
}

class SectorPainter extends CustomPainter {
  final double angle;
  SectorPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Background circle
    Paint bgPaint = Paint()..color = Colors.black26..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);
    Paint borderPaint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Fixed axis line at 12 o'clock
    Paint axisPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx, center.dy - radius), axisPaint);

    if (angle > 0) {
      Paint sectorPaint = Paint()..color = Colors.yellow.withOpacity(0.5)..style = PaintingStyle.fill;
      Paint sectorBorder = Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 2;
      
      double sweepRad = (angle * math.pi) / 180;
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 2);
      canvas.translate(-center.dx, -center.dy);
      
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, sweepRad, true, sectorPaint);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, sweepRad, true, sectorBorder);
      
      // Moving line
      double endX = center.dx + radius * math.cos(sweepRad);
      double endY = center.dy + radius * math.sin(sweepRad);
      canvas.drawLine(center, Offset(endX, endY), Paint()..color = Colors.yellow..strokeWidth = 3..strokeCap = StrokeCap.round);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SectorPainter oldDelegate) => oldDelegate.angle != angle;
}

class StaticPiePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);

    Paint strokePaint = Paint()..color = const Color(0xFF020617)..style = PaintingStyle.stroke..strokeWidth = 2;

    // Rent (90)
    Paint rentP = Paint()..color = Colors.red.shade500..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 90 * math.pi / 180, true, rentP);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 90 * math.pi / 180, true, strokePaint);
    
    // Food (120) -> 90 to 210
    Paint foodP = Paint()..color = Colors.blue.shade500..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 90 * math.pi / 180, 120 * math.pi / 180, true, foodP);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 90 * math.pi / 180, 120 * math.pi / 180, true, strokePaint);
    
    // Savings (150) -> 210 to 360
    Paint saveP = Paint()..color = Colors.green.shade500..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 210 * math.pi / 180, 150 * math.pi / 180, true, saveP);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 210 * math.pi / 180, 150 * math.pi / 180, true, strokePaint);

    // Right angle square marker for Rent (at 0 to 90 degrees)
    Paint rightAngle = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    double dist = 20; // 20 pixels from center
    
    // Path for right angle: center -> x: dist -> y: dist -> center
    // In this rotated canvas, 0 is right, 90 is down.
    Path p = Path();
    p.moveTo(center.dx + dist, center.dy);
    p.lineTo(center.dx + dist, center.dy + dist);
    p.lineTo(center.dx, center.dy + dist);
    canvas.drawPath(p, rightAngle);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
      
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
