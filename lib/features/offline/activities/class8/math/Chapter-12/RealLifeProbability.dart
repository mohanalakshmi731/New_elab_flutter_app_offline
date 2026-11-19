// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

class RealLifeProbabilityActivity extends StatefulWidget {
  const RealLifeProbabilityActivity({super.key});

  @override
  State<RealLifeProbabilityActivity> createState() => _RealLifeProbabilityActivityState();
}

class _RealLifeProbabilityActivityState extends State<RealLifeProbabilityActivity> {
  int currentStep = 1;
  
  // Step 1 State
  Set<String> sourceCardsS1 = {'2-e', '4-e', '6-e', '2-p', '3-p', '5-p'};
  Set<String> evensZone = {};
  Set<String> primesZone = {};
  
  // Step 2 State
  Set<int> rainDays = {};
  
  // Step 3 State
  bool isSimplified = false;
  String drumXPos = 'source'; // 'source', 'equal', 'better'
  String drumYPos = 'source';
  
  // Step 4 State
  double pieAngle = 360.0;
  Map<int, String> sectorNames = {}; // sectorIndex -> nameId
  Set<String> sourceNames = {'n1', 'n2', 'n3'};

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
      sourceCardsS1 = {'2-e', '4-e', '6-e', '2-p', '3-p', '5-p'};
      evensZone.clear();
      primesZone.clear();
      rainDays.clear();
      isSimplified = false;
      drumXPos = 'source';
      drumYPos = 'source';
      pieAngle = 360.0;
      sectorNames.clear();
      sourceNames = {'n1', 'n2', 'n3'};
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
    if (currentStep == 1) return evensZone.length == 3 && primesZone.length == 3 && evensZone.every((c) => c.endsWith('-e')) && primesZone.every((c) => c.endsWith('-p'));
    if (currentStep == 2) return rainDays.length == 30;
    if (currentStep == 3) return isSimplified && drumXPos == 'equal' && drumYPos == 'equal';
    if (currentStep == 4) return pieAngle == 120.0 && sectorNames.length == 3;
    return false;
  }

  // Translations
  String get tTitle => language == 'EN' ? "Real-Life Probability" : "वास्तविक जीवन में प्रायिकता";
  String get tSubtitle => language == 'EN' ? "CLASS 8 • TALES BY DOTS AND LINES" : "कक्षा 8 • बिंदुओं और रेखाओं से कहानियाँ";
  String get tMission => language == 'EN' ? "MISSION OBJECTIVE" : "मिशन का उद्देश्य";
  String get tAction => language == 'EN' ? "ACTION REQUIRED" : "कार्रवाई आवश्यक";
  String get tVerify => language == 'EN' ? "Verify Step" : "सत्यापित करें";
  
  String theoryText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "A game is considered Fair if all players have an equal probability of winning.\n\nLet's test a game with a single die. Player A wins if an Even number is rolled. Player B wins if a Prime number is rolled.\n\nTo determine if this is fair, we must list the favorable outcomes for each player and calculate their probabilities.";
        case 2: return "In real life, probability is often expressed as a percentage.\n\nWhen a forecaster says there is a '30% chance of rain,' it means that based on historical data, out of 100 days with similar conditions, it rained on exactly 30 of them.\n\nThis is a practical application of the probability fraction: 30 / 100.";
        case 3: return "Probability helps us compare chances in different scenarios.\n\nWho has a better chance of winning: Person X who buys 1 ticket in a lottery of 100, or Person Y who buys 10 tickets in a lottery of 1000?\n\nWhile the numbers are larger for Person Y, we must simplify the fractions to see the true probability.";
        case 4: return "We use probability to make fair decisions.\n\nIf 3 friends want to decide who goes first in a game using a spinner, the spinner must be divided into 3 equal sectors (120° each).\n\nThis ensures that P(Friend 1) = P(Friend 2) = P(Friend 3) = 1/3.";
      }
    } else {
      switch (step) {
        case 1: return "एक खेल को निष्पक्ष (Fair) माना जाता है यदि सभी खिलाड़ियों के जीतने की प्रायिकता समान हो।\n\nआइए एक पासे के साथ एक खेल का परीक्षण करें। खिलाड़ी A जीतता है यदि कोई सम (Even) संख्या आती है। खिलाड़ी B जीतता है यदि कोई अभाज्य (Prime) संख्या आती है।\n\nयह निर्धारित करने के लिए कि क्या यह निष्पक्ष है, हमें प्रत्येक खिलाड़ी के लिए अनुकूल परिणामों को सूचीबद्ध करना होगा।";
        case 2: return "वास्तविक जीवन में, प्रायिकता अक्सर प्रतिशत के रूप में व्यक्त की जाती है।\n\nजब मौसम विज्ञानी कहता है कि '30% संभावना है,' तो इसका मतलब है कि समान परिस्थितियों वाले 100 दिनों में से ठीक 30 दिनों में बारिश हुई।\n\nयह प्रायिकता भिन्न का एक व्यावहारिक अनुप्रयोग है: 30 / 100।";
        case 3: return "प्रायिकता हमें विभिन्न परिदृश्यों में संभावनाओं की तुलना करने में मदद करती है।\n\nजीतने की बेहतर संभावना किसकी है: व्यक्ति X जो 100 की लॉटरी में 1 टिकट खरीदता है, या व्यक्ति Y जो 1000 की लॉटरी में 10 टिकट खरीदता है?\n\nहालांकि व्यक्ति Y के लिए संख्याएँ बड़ी हैं, हमें सही प्रायिकता देखने के लिए भिन्नों को सरल करना होगा।";
        case 4: return "हम निष्पक्ष निर्णय लेने के लिए प्रायिकता का उपयोग करते हैं।\n\nयदि 3 दोस्त यह तय करना चाहते हैं कि स्पिनर का उपयोग करके खेल में पहले कौन जाएगा, तो स्पिनर को 3 समान खंडों (प्रत्येक 120°) में विभाजित किया जाना चाहिए।\n\nयह सुनिश्चित करता है कि P(दोस्त 1) = P(दोस्त 2) = P(दोस्त 3) = 1/3।";
      }
    }
    return "";
  }

  String hudText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "Drag the correct numbers from the pool into the winning sets for both players. If the number of outcomes is equal, the game is fair.";
        case 2: return "Represent the 30% probability on the grid. Click and drag over the grid to highlight exactly 30 days it is expected to rain.";
        case 3: return "Drag the Simplifier lens over Drum Y to reduce the fraction. Then, drag both drums to the correct tray on the balance scale based on their probability.";
        case 4: return "Create a fair decision-maker. Use the Degree Slicer to divide the circle into 3 equal parts of 120° each, then drag the names into the sectors.";
      }
    } else {
      switch (step) {
        case 1: return "पूल से सही संख्याओं को दोनों खिलाड़ियों के जीतने वाले सेट में खींचें। यदि परिणामों की संख्या समान है, तो खेल निष्पक्ष है।";
        case 2: return "ग्रिड पर 30% प्रायिकता का प्रतिनिधित्व करें। ठीक 30 दिनों को हाइलाइट करने के लिए ग्रिड पर क्लिक करें और खींचें।";
        case 3: return "भिन्न को कम करने के लिए ड्रम Y पर सरलीकृत लेंस को खींचें। फिर, दोनों ड्रमों को उनकी प्रायिकता के आधार पर सही ट्रे में खींचें।";
        case 4: return "एक निष्पक्ष निर्णय-निर्माता बनाएँ। वृत्त को 120° के 3 समान भागों में विभाजित करने के लिए स्लाइडर का उपयोग करें, फिर नामों को खींचें।";
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
                const Icon(Icons.scale, color: Colors.yellow, size: 36),
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
              initialValue: currentStep,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              items: [
                DropdownMenuItem(value: 1, child: Text(language == 'EN' ? "Step 1: The 'Unfair' Game" : "चरण 1: 'अनुचित' खेल")),
                DropdownMenuItem(value: 2, child: Text(language == 'EN' ? "Step 2: Weather Forecasting" : "चरण 2: मौसम का पूर्वानुमान")),
                DropdownMenuItem(value: 3, child: Text(language == 'EN' ? "Step 3: Lottery Comparison" : "चरण 3: लॉटरी की तुलना")),
                DropdownMenuItem(value: 4, child: Text(language == 'EN' ? "Step 4: Decision Making" : "चरण 4: निर्णय लेना")),
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
      return Wrap(
        spacing: 12, runSpacing: 12,
        alignment: WrapAlignment.center,
        children: sourceCardsS1.map((id) {
          String display = id.split('-')[0];
          bool isEven = id.endsWith('-e');
          Widget content = Container(
            width: 50, height: 60,
            decoration: BoxDecoration(
              color: isEven ? Colors.blue.shade600 : Colors.green.shade600,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white30),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)]
            ),
            alignment: Alignment.center,
            child: Text(display, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          );
          return buildDraggableCard(id, content);
        }).toList(),
      );
    } else if (currentStep == 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud, color: Colors.blue, size: 40),
            Text(language == 'EN' ? "FORECAST" : "पूर्वानुमान", style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            const Text("30%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(language == 'EN' ? "Chance of Rain" : "बारिश की संभावना", style: const TextStyle(color: Colors.yellow, fontSize: 10)),
          ],
        ),
      );
    } else if (currentStep == 3) {
      Widget lens = Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 3),
          boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 15)]
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.search, color: Colors.white, size: 40),
      );

      Widget drumX = Container(
        width: 100, height: 130,
        decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(language == 'EN' ? "Drum X" : "ड्रम X", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Text("1 / 100", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))
        ]),
      );

      Widget drumY = Container(
        width: 100, height: 130,
        decoration: BoxDecoration(color: isSimplified ? Colors.orange.shade500 : Colors.orange.shade700, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(language == 'EN' ? "Drum Y" : "ड्रम Y", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(isSimplified ? "1 / 100" : "10 / 1000", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))
        ]),
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSimplified) ...[
            Column(
              children: [
                buildDraggableCard("lens", lens),
                const SizedBox(height: 4),
                Text(language == 'EN' ? "SIMPLIFIER LENS" : "सरलीकृत लेंस", style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(width: 40),
          ],
          if (drumXPos == 'source') buildDraggableCard("drumX", drumX) else const SizedBox(width: 100),
          const SizedBox(width: 20),
          if (drumYPos == 'source') ...[
            if (isSimplified) buildDraggableCard("drumY", drumY)
            else
              DragTarget<String>(
                onWillAccept: (d) => d == 'lens',
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() => isSimplified = true);
                },
                builder: (ctx, cand, rej) => Container(
                  decoration: BoxDecoration(border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.transparent, width: 2), borderRadius: BorderRadius.circular(12)),
                  child: drumY,
                )
              )
          ] else const SizedBox(width: 100),
        ],
      );
    } else if (currentStep == 4) {
      return Wrap(
        spacing: 12, runSpacing: 12,
        alignment: WrapAlignment.center,
        children: sourceNames.map((id) {
          String name = "";
          if (id == 'n1') name = language == 'EN' ? "Arjun" : "अर्जुन";
          if (id == 'n2') name = language == 'EN' ? "Sara" : "सारा";
          if (id == 'n3') name = language == 'EN' ? "Deepak" : "दीपक";

          Widget content = Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30),
            ),
            alignment: Alignment.center,
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          );
          return buildDraggableCard(id, content);
        }).toList(),
      );
    }
    return const SizedBox();
  }

  void handleGridDrag(Offset localPos, double width, double height) {
    if (currentStep != 2) return;
    
    double cellW = width / 10;
    double cellH = height / 10;
    
    int col = (localPos.dx / cellW).floor();
    int row = (localPos.dy / cellH).floor();
    
    if (col >= 0 && col < 10 && row >= 0 && row < 10) {
      int index = row * 10 + col;
      if (!rainDays.contains(index)) {
        setState(() => rainDays.add(index));
      }
    }
  }

  Widget buildCanvasContent() {
    if (currentStep == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Player A
          Column(
            children: [
              Text(language == 'EN' ? "PLAYER A (EVENS)" : "खिलाड़ी A (सम संख्या)", style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              DragTarget<String>(
                onWillAccept: (d) => true,
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() {
                    sourceCardsS1.remove(d);
                    primesZone.remove(d);
                    evensZone.add(d);
                  });
                },
                builder: (ctx, cand, rej) {
                  return Container(
                    width: 250, constraints: const BoxConstraints(minHeight: 120),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.blue.withOpacity(0.5), width: cand.isNotEmpty ? 3 : 2, style: BorderStyle.solid)
                    ),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: evensZone.map((id) {
                        String display = id.split('-')[0];
                        bool isEven = id.endsWith('-e');
                        return Container(
                          width: 40, height: 50,
                          decoration: BoxDecoration(color: isEven ? Colors.blue.shade600 : Colors.green.shade600, borderRadius: BorderRadius.circular(6)),
                          alignment: Alignment.center,
                          child: Text(display, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        );
                      }).toList()
                    ),
                  );
                }
              )
            ],
          ),
          const SizedBox(width: 40),
          // Scales Icon
          Column(
            children: [
              const Icon(Icons.scale, color: Colors.yellow, size: 80),
              const SizedBox(height: 8),
              Text(language == 'EN' ? "FAIRNESS SCALE" : "निष्पक्षता पैमाना", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5))
            ],
          ),
          const SizedBox(width: 40),
          // Player B
          Column(
            children: [
              Text(language == 'EN' ? "PLAYER B (PRIMES)" : "खिलाड़ी B (अभाज्य संख्या)", style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              DragTarget<String>(
                onWillAccept: (d) => true,
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() {
                    sourceCardsS1.remove(d);
                    evensZone.remove(d);
                    primesZone.add(d);
                  });
                },
                builder: (ctx, cand, rej) {
                  return Container(
                    width: 250, constraints: const BoxConstraints(minHeight: 120),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.green.withOpacity(0.5), width: cand.isNotEmpty ? 3 : 2, style: BorderStyle.solid)
                    ),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: primesZone.map((id) {
                        String display = id.split('-')[0];
                        bool isEven = id.endsWith('-e');
                        return Container(
                          width: 40, height: 50,
                          decoration: BoxDecoration(color: isEven ? Colors.blue.shade600 : Colors.green.shade600, borderRadius: BorderRadius.circular(6)),
                          alignment: Alignment.center,
                          child: Text(display, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        );
                      }).toList()
                    ),
                  );
                }
              )
            ],
          )
        ],
      );
    } else if (currentStep == 2) {
      double gridW = 350;
      double gridH = 350;
      return Column(
        children: [
          Text(language == 'EN' ? "100-DAY FORECAST GRID" : "100-दिन का पूर्वानुमान ग्रिड", style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          GestureDetector(
            onPanDown: (details) {
              playSound(_fxPlayer, _snapUrl);
              handleGridDrag(details.localPosition, gridW, gridH);
            },
            onPanUpdate: (details) {
              handleGridDrag(details.localPosition, gridW, gridH);
            },
            child: Container(
              width: gridW, height: gridH,
              color: Colors.black26,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 1, mainAxisSpacing: 1),
                itemCount: 100,
                itemBuilder: (ctx, i) {
                  bool active = rainDays.contains(i);
                  return Container(
                    decoration: BoxDecoration(
                      color: active ? Colors.blue : Colors.transparent,
                      border: Border.all(color: Colors.white12, width: 1)
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(language == 'EN' ? "Selected: " : "चयनित: ", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${rainDays.length}", style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text(" / 100", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      );
    } else if (currentStep == 3) {
      Widget drumX = Container(
        width: 80, height: 110,
        decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(language == 'EN' ? "Drum X" : "ड्रम X", style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const Text("1 / 100", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
        ]),
      );

      Widget drumY = Container(
        width: 80, height: 110,
        decoration: BoxDecoration(color: Colors.orange.shade500, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(language == 'EN' ? "Drum Y" : "ड्रम Y", style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const Text("1 / 100", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
        ]),
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tray Equal
          Column(
            children: [
              Text(language == 'EN' ? "EQUAL CHANCE" : "समान अवसर", style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              DragTarget<String>(
                onWillAccept: (d) => d == 'drumX' || d == 'drumY',
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() {
                    if (d == 'drumX') drumXPos = 'equal';
                    if (d == 'drumY') drumYPos = 'equal';
                  });
                },
                builder: (ctx, cand, rej) => Container(
                  width: 250, constraints: const BoxConstraints(minHeight: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.white24, width: cand.isNotEmpty ? 3 : 2)),
                  child: Wrap(
                    alignment: WrapAlignment.center, spacing: 12,
                    children: [
                      if (drumXPos == 'equal') drumX,
                      if (drumYPos == 'equal') drumY,
                    ],
                  ),
                )
              )
            ],
          ),
          const SizedBox(width: 40),
          // Tray Better
          Column(
            children: [
              Text(language == 'EN' ? "BETTER CHANCE" : "बेहतर अवसर", style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              DragTarget<String>(
                onWillAccept: (d) => d == 'drumX' || d == 'drumY',
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() {
                    if (d == 'drumX') drumXPos = 'better';
                    if (d == 'drumY') drumYPos = 'better';
                  });
                },
                builder: (ctx, cand, rej) => Container(
                  width: 250, constraints: const BoxConstraints(minHeight: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.white24, width: cand.isNotEmpty ? 3 : 2)),
                  child: Wrap(
                    alignment: WrapAlignment.center, spacing: 12,
                    children: [
                      if (drumXPos == 'better') drumX,
                      if (drumYPos == 'better') drumY,
                    ],
                  ),
                )
              )
            ],
          )
        ],
      );
    } else if (currentStep == 4) {
      int numSectors = (360 / pieAngle).floor();
      
      List<Widget> dropzones = [];
      if (pieAngle == 120.0) {
        // Create 3 specific positioned dropzones
        for (int i = 0; i < 3; i++) {
          double startAngle = i * 120;
          double midAngle = startAngle + 60;
          double rad = (midAngle - 90) * math.pi / 180;
          
          double dx = 150 + 70 * math.cos(rad);
          double dy = 150 + 70 * math.sin(rad);

          dropzones.add(
            Positioned(
              left: dx - 40, top: dy - 20,
              child: DragTarget<String>(
                onWillAccept: (d) => sourceNames.contains(d),
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() {
                    sourceNames.remove(d);
                    sectorNames[i] = d;
                  });
                },
                builder: (ctx, cand, rej) {
                  if (sectorNames.containsKey(i)) {
                    String id = sectorNames[i]!;
                    String name = "";
                    if (id == 'n1') name = language == 'EN' ? "Arjun" : "अर्जुन";
                    if (id == 'n2') name = language == 'EN' ? "Sara" : "सारा";
                    if (id == 'n3') name = language == 'EN' ? "Deepak" : "दीपक";
                    return Container(
                      width: 80, height: 40,
                      decoration: BoxDecoration(color: Colors.purple.shade600, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white30)),
                      alignment: Alignment.center,
                      child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    );
                  }
                  return Container(
                    width: 80, height: 40,
                    decoration: BoxDecoration(
                      color: cand.isNotEmpty ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                      border: Border.all(color: cand.isNotEmpty ? Colors.yellow : Colors.white30, width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8)
                    ),
                  );
                }
              )
            )
          );
        }
      }

      return Column(
        children: [
          SizedBox(
            width: 300, height: 300,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(300, 300),
                  painter: Step4SectorPainter(angle: pieAngle, numSectors: numSectors),
                ),
                ...dropzones
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 400, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language == 'EN' ? "DEGREE SLICER" : "डिग्री स्लाइसर", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text("${pieAngle.toInt()}°", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: pieAngle,
                  min: 60, max: 360, divisions: 30, // steps of 10
                  activeColor: Colors.yellow,
                  onChanged: (val) {
                    setState(() {
                      pieAngle = val;
                      sectorNames.clear(); // Reset on change
                      sourceNames = {'n1', 'n2', 'n3'};
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text("${language == 'EN' ? 'SECTORS' : 'खंड'}: $numSectors", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
              ],
            ),
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
                  constraints: const BoxConstraints(maxWidth: 800),
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
                          Text(language == 'EN' ? "Outstanding! You have successfully completed the chapter on Data Handling and Probability!" : "असाधारण! आपने डेटा प्रबंधन और प्रायिकता पर अध्याय सफलतापूर्वक पूरा कर लिया है!", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
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
                      child: const Icon(Icons.scale, color: Colors.yellow, size: 60),
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

class Step4SectorPainter extends CustomPainter {
  final double angle;
  final int numSectors;
  Step4SectorPainter({required this.angle, required this.numSectors});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Background circle
    Paint bgPaint = Paint()..color = Colors.black26..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);
    Paint borderPaint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    if (angle > 0) {
      Paint sectorBorder = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      
      double sweepRad = (angle * math.pi) / 180;
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 2);
      canvas.translate(-center.dx, -center.dy);
      
      for (int i = 0; i < numSectors; i++) {
        // Different colors for sectors
        Color fillCol = i % 3 == 0 ? Colors.purple.withOpacity(0.3) : i % 3 == 1 ? Colors.blue.withOpacity(0.3) : Colors.green.withOpacity(0.3);
        Paint sectorPaint = Paint()..color = fillCol..style = PaintingStyle.fill;
        
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * sweepRad, sweepRad, true, sectorPaint);
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * sweepRad, sweepRad, true, sectorBorder);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant Step4SectorPainter oldDelegate) => oldDelegate.angle != angle;
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
