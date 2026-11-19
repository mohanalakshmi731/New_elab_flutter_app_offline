// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class HistogramsActivity extends StatefulWidget {
  const HistogramsActivity({super.key});

  @override
  State<HistogramsActivity> createState() => _HistogramsActivityState();
}

class _HistogramsActivityState extends State<HistogramsActivity> {
  int currentStep = 1;
  List<bool> s1BarsPlaced = [false, false, false];
  bool s2KinkPlaced = false;
  List<int> s3BarHeights = [0, 0, 0, 0, 0];
  bool s4BoxPlaced = false;
  String s4Answer = "";
  
  bool showSuccess = false;
  bool isSidebarOpen = true;
  String language = 'EN';
  
  bool isShutterOpen = false;
  Offset instructionOffset = const Offset(80, 20); // Moved a bit right to not overlap edge button

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
      s1BarsPlaced = [false, false, false];
      s2KinkPlaced = false;
      s3BarHeights = [0, 0, 0, 0, 0];
      s4BoxPlaced = false;
      s4Answer = "";
      showSuccess = false;
      isShutterOpen = false;
      language = 'EN';
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
    if (currentStep == 1) return s1BarsPlaced.every((b) => b);
    if (currentStep == 2) return s2KinkPlaced;
    if (currentStep == 3) {
      List<int> expected = [3, 2, 1, 5, 8];
      for (int i = 0; i < 5; i++) {
        if (s3BarHeights[i] != expected[i]) return false;
      }
      return true;
    }
    if (currentStep == 4) return s4BoxPlaced && s4Answer.trim() == "13";
    return false;
  }

  // Translation Strings
  String get tHistograms => language == 'EN' ? "Histograms" : "आयतचित्र (Histograms)";
  String get tSubtitle => language == 'EN' ? "CLASS 8 • TALES BY DOTS AND LINES" : "कक्षा 8 • बिंदुओं और रेखाओं की कहानियाँ";
  String get tMission => language == 'EN' ? "MISSION OBJECTIVE" : "मिशन का उद्देश्य";
  String get tAction => language == 'EN' ? "ACTION REQUIRED" : "कार्रवाई आवश्यक";
  String get tVerify => language == 'EN' ? "Verify Step" : "चरण सत्यापित करें";
  String get tWages => language == 'EN' ? "Wages (₹)" : "मज़दूरी (₹)";
  String get tWorkers => language == 'EN' ? "Workers" : "श्रमिक";
  String get tDrop => language == 'EN' ? "Drop Here" : "यहाँ छोड़ें";
  String get tAnswer => language == 'EN' ? "Answer: " : "उत्तर: ";

  String theoryText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "Unlike bar graphs that represent separate categories, a Histogram is used for grouped, continuous data like wages.\n\nBecause the intervals are continuous, the bars must touch each other without gaps.";
        case 2: return "Sometimes our data starts at a high value, like ₹800, instead of zero.\n\nIf we show the space from 0 to 800 as empty, the graph becomes too wide and hard to read.";
        case 3: return "Let's construct a full histogram for the weekly wages of 30 workers.\n\nThe height of each bar represents the number of workers in that wage bracket.";
        case 4: return "We can analyze the histogram to answer specific questions.\n\n'How many workers earn ₹830 or more?'\n\nTo find this, we must look at all the bars starting from the 830 mark and sum their frequencies together.";
      }
    } else {
      switch (step) {
        case 1: return "बार ग्राफ़ के विपरीत जो अलग-अलग श्रेणियों का प्रतिनिधित्व करते हैं, एक आयतचित्र का उपयोग मज़दूरी जैसे समूहीकृत, निरंतर डेटा के लिए किया जाता है।\n\nचूंकि अंतराल निरंतर होते हैं, इसलिए बार को बिना अंतराल के एक-दूसरे को छूना चाहिए।";
        case 2: return "कभी-कभी हमारा डेटा शून्य के बजाय ₹800 जैसे उच्च मूल्य से शुरू होता है।\n\nयदि हम 0 से 800 तक के स्थान को खाली दिखाते हैं, तो ग्राफ बहुत चौड़ा हो जाता है और पढ़ने में मुश्किल हो जाता है।";
        case 3: return "आइए 30 श्रमिकों की साप्ताहिक मज़दूरी के लिए एक पूर्ण आयतचित्र बनाएँ।\n\nप्रत्येक बार की ऊँचाई उस मज़दूरी ब्रैकेट में श्रमिकों की संख्या को दर्शाती है।";
        case 4: return "हम विशिष्ट प्रश्नों के उत्तर देने के लिए आयतचित्र का विश्लेषण कर सकते हैं।\n\n'कितने श्रमिक ₹830 या उससे अधिक कमाते हैं?'\n\nयह जानने के लिए, हमें 830 चिह्न से शुरू होने वाले सभी बारों को देखना होगा और उनकी आवृत्तियों को एक साथ जोड़ना होगा।";
      }
    }
    return "";
  }

  String hudText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "These bars represent continuous wage data. Move the bars onto the X-axis so that they touch each other perfectly with no gaps to form a histogram.";
        case 2: return "The space between 0 and 800 is empty. Drag the Jagged Line symbol and place it on the X-axis near the zero mark to properly represent this break in the scale.";
        case 3: return "Adjust the height of each bar to match the frequency table. For example, pull the '840-850' bar up until it reaches 8 on the Y-axis.";
        case 4: return "Select all the bars that represent wages of ₹830 and above using the Selection Highlight box. Then, add their frequencies together and type the total in the box.";
      }
    } else {
      switch (step) {
        case 1: return "ये बार निरंतर मज़दूरी डेटा का प्रतिनिधित्व करते हैं। बार को X-अक्ष पर ले जाएँ ताकि वे एक आयतचित्र बनाने के लिए बिना किसी अंतराल के पूरी तरह से एक-दूसरे को छू लें।";
        case 2: return "0 और 800 के बीच का स्थान खाली है। जैग्ड लाइन प्रतीक को खींचें और पैमाने में इस ब्रेक को ठीक से दर्शाने के लिए इसे शून्य चिह्न के पास X-अक्ष पर रखें।";
        case 3: return "आवृत्ति तालिका से मिलान करने के लिए प्रत्येक बार की ऊँचाई को समायोजित करें। उदाहरण के लिए, '840-850' बार को ऊपर खींचें जब तक कि वह Y-अक्ष पर 8 तक न पहुँच जाए।";
        case 4: return "चयन हाइलाइट बॉक्स का उपयोग करके ₹830 और उससे अधिक की मज़दूरी दर्शाने वाले सभी बार का चयन करें। फिर, उनकी आवृत्तियों को एक साथ जोड़ें और कुल योग बॉक्स में टाइप करें।";
      }
    }
    return "";
  }

  Widget buildTheoryTable(int step) {
    if (step == 1 || step == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Table(
          border: TableBorder.all(color: Colors.white24),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Colors.black12),
              children: [
                Padding(padding: const EdgeInsets.all(6), child: Text(tWages, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
                Padding(padding: const EdgeInsets.all(6), child: Text(tWorkers, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
              ]
            ),
            const TableRow(children: [Text("800-810", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)), Text("3", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))]),
            const TableRow(children: [Text("810-820", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)), Text("2", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))]),
            const TableRow(children: [Text("820-830", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)), Text("1", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))]),
            if (step == 3) ...const [
              TableRow(children: [Text("830-840", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)), Text("5", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))]),
              TableRow(children: [Text("840-850", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)), Text("8", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))]),
            ]
          ],
        ),
      );
    }
    if (step == 2) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.yellow, width: 4)), color: Colors.black26),
        child: Text(
          language == 'EN' ? "We use a Jagged Line or a Kink on the X-axis to show that we are skipping the values between 0 and the first interval." : "हम X-अक्ष पर एक जैग्ड लाइन या किंक का उपयोग करते हैं यह दिखाने के लिए कि हम 0 और पहले अंतराल के बीच के मूल्यों को छोड़ रहे हैं।",
          style: const TextStyle(color: Colors.white70, fontSize: 16)
        ),
      );
    }
    return const SizedBox();
  }

  double barStartX(int index) {
    if (currentStep == 1) return 100.0 + index * 80;
    if (currentStep == 2 && !s2KinkPlaced) return 300.0 + index * 80;
    return 130.0 + index * 80;
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
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
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
                const Icon(Icons.bar_chart, color: Colors.yellow, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tHistograms, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
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
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              items: [
                DropdownMenuItem(value: 1, child: Text(language == 'EN' ? "Step 1: Continuous Data" : "चरण 1: निरंतर डेटा")),
                DropdownMenuItem(value: 2, child: Text(language == 'EN' ? "Step 2: The Jagged Line" : "चरण 2: जैग्ड लाइन")),
                DropdownMenuItem(value: 3, child: Text(language == 'EN' ? "Step 3: Construction" : "चरण 3: निर्माण")),
                DropdownMenuItem(value: 4, child: Text(language == 'EN' ? "Step 4: Analysis" : "चरण 4: विश्लेषण")),
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
            buildTheoryTable(currentStep),
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

  Widget buildSourceContainer() {
    if (currentStep == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!s1BarsPlaced[0]) buildDraggableBar("bar1", Colors.blue, "800-810", 40),
          const SizedBox(width: 24),
          if (!s1BarsPlaced[1]) buildDraggableBar("bar2", Colors.green, "810-820", 30),
          const SizedBox(width: 24),
          if (!s1BarsPlaced[2]) buildDraggableBar("bar3", Colors.purple, "820-830", 20),
        ],
      );
    } else if (currentStep == 2 && !s2KinkPlaced) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Draggable<String>(
            data: "kink",
            feedback: const Material(color: Colors.transparent, child: Icon(Icons.show_chart, color: Colors.white, size: 60)),
            childWhenDragging: const SizedBox(width: 60, height: 60),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(border: Border.all(color: Colors.white30), color: Colors.white12),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 40),
            ),
          )
        ],
      );
    } else if (currentStep == 4) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!s4BoxPlaced)
            Draggable<String>(
              data: "selectbox",
              feedback: Material(color: Colors.transparent, child: Container(width: 160, height: 100, decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.3), border: Border.all(color: Colors.yellow, width: 3)))),
              childWhenDragging: const SizedBox(width: 60, height: 60),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.3), border: Border.all(color: Colors.yellow, width: 3)),
                child: const Center(child: Text("Box", style: TextStyle(color: Colors.yellow, fontSize: 16))),
              ),
            ),
          if (!s4BoxPlaced) const SizedBox(width: 40),
          Text(tAnswer, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (val) {
                playSound(_clickPlayer, _clickUrl);
                setState(() => s4Answer = val);
              },
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
              decoration: const InputDecoration(
                isDense: true,
                filled: true, fillColor: Colors.black45,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
              )
            )
          )
        ]
      );
    }
    return const SizedBox();
  }

  Widget buildDraggableBar(String id, Color color, String label, double h) {
    return Draggable<String>(
      data: id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 80, height: h * 1.5,
          color: color.withOpacity(0.9),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      childWhenDragging: const SizedBox(width: 90, height: 60),
      child: Container(
        width: 90, height: 60,
        decoration: BoxDecoration(border: Border.all(color: Colors.white30), color: Colors.white12),
        child: Center(
          child: Container(
            width: 80, height: h > 50 ? 50 : h,
            color: color,
            alignment: Alignment.center,
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget buildAnimatedBar(int index, double h, Color color, String id) {
    bool isPlaced = (currentStep == 1 && s1BarsPlaced[index]) || (currentStep > 1);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: barStartX(index),
      top: 350 - h,
      width: 80,
      height: h,
      child: isPlaced 
        ? Container(decoration: BoxDecoration(color: color, border: Border.all(color: const Color(0xFF0F172A), width: 2)))
        : DragTarget<String>(
            onWillAccept: (d) => d == id,
            onAccept: (d) {
              playSound(_fxPlayer, _snapUrl);
              setState(() => s1BarsPlaced[index] = true);
            },
            builder: (ctx, c, r) => Container(
              decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: c.isNotEmpty ? Colors.yellow : Colors.white54, width: 2))
            )
          )
    );
  }

  Widget buildStaticBar(double x, double h) {
    return Positioned(
      left: x, top: 350 - h, width: 80, height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(decoration: BoxDecoration(color: Colors.teal, border: Border.all(color: const Color(0xFF0F172A), width: 2))),
          Positioned(
            top: -24, left: 0, right: 0,
            child: Center(child: Text("${(h/15).round()}", style: TextStyle(color: currentStep == 4 && s4BoxPlaced && x >= 370 ? Colors.yellow : Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Main Graph Area - Infinite Pan/Zoom
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.3,
              maxScale: 3.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(1000),
              child: SizedBox(
                width: 800,
                height: 600,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(currentStep, s2KinkPlaced),
                      ),
                    ),
                    Positioned(
                      left: -20, top: 250,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(tWorkers, style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                      )
                    ),
                    Positioned(
                      left: 350, bottom: 200,
                      child: Text(tWages, style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    
                    if (currentStep == 1 || currentStep == 2) ...[
                      buildAnimatedBar(0, 45, Colors.blue, "bar1"),
                      buildAnimatedBar(1, 30, Colors.green, "bar2"),
                      buildAnimatedBar(2, 15, Colors.purple, "bar3"),
                    ],
            
                    if (currentStep == 2 && !s2KinkPlaced)
                      Positioned(
                        left: 150, top: 320, width: 60, height: 60,
                        child: DragTarget<String>(
                          onWillAccept: (d) => d == "kink",
                          onAccept: (d) {
                            playSound(_fxPlayer, _snapUrl);
                            setState(() => s2KinkPlaced = true);
                          },
                          builder: (ctx, c, r) => Container(decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: c.isNotEmpty ? Colors.yellow : Colors.white54, width: 2)))
                        )
                      ),
                      
                    if (currentStep == 3) ...List.generate(5, (i) {
                      double left = 130 + i * 80.0;
                      double height = s3BarHeights[i] * 15.0; // scale factor 15
                      return Positioned(
                        left: left, top: 50, width: 80, height: 300,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            double y = details.localPosition.dy; 
                            double hPixels = 300 - y;
                            int units = (hPixels / 15).round().clamp(0, 20);
                            setState(() => s3BarHeights[i] = units);
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                bottom: 0, left: 0, right: 0, height: height,
                                child: Container(decoration: BoxDecoration(color: Colors.teal, border: Border.all(color: const Color(0xFF0F172A), width: 2)))
                              ),
                              Positioned(
                                bottom: height - 8, left: 0, right: 0, height: 16,
                                child: Container(color: Colors.yellow.withOpacity(0.8))
                              ),
                              if (s3BarHeights[i] > 0)
                                Positioned(
                                  bottom: height + 6, left: 0, right: 0,
                                  child: Center(child: Text("${s3BarHeights[i]}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                                )
                            ]
                          )
                        )
                      );
                    }),
                    
                    if (currentStep == 4) ...[
                      buildStaticBar(130, 45),
                      buildStaticBar(210, 30),
                      buildStaticBar(290, 15),
                      buildStaticBar(370, 75),
                      buildStaticBar(450, 120),
                      
                      if (!s4BoxPlaced)
                        Positioned(
                          left: 370, top: 230, width: 160, height: 120,
                          child: DragTarget<String>(
                            onWillAccept: (d) => d == "selectbox",
                            onAccept: (d) {
                              playSound(_fxPlayer, _snapUrl);
                              setState(() => s4BoxPlaced = true);
                            },
                            builder: (ctx, c, r) => Container(
                              decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.1), border: Border.all(color: c.isNotEmpty ? Colors.yellow : Colors.white54, width: 2)),
                              child: Center(child: Text(tDrop, style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold)))
                            )
                          )
                        ),
                        
                      if (s4BoxPlaced)
                        Positioned(
                          left: 370, top: 230, width: 160, height: 120,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.3)),
                          )
                        ),
                        
                      if (s4BoxPlaced) ...[
                        Positioned(left: 370, top: 275, width: 80, height: 75, child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 4)))),
                        Positioned(left: 450, top: 230, width: 80, height: 120, child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 4)))),
                      ]
                    ]
                  ]
                ),
              ),
            ),
          ),
          
          // Elements sitting ABOVE the canvas
          
          // Source tools always visible at the top of the canvas area
          if (isShutterOpen)
            Positioned(
              left: isSidebarOpen ? sidebarWidth : 0, 
              right: 0, 
              top: 20,
              height: 100,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow.withOpacity(0.3)),
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
          
          // Sidebar Edge Toggle Button (Hamburger Menu on Top-Left)
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

          // Compact Instructions AND Language/Reset Controls (Draggable)
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
                          Text(language == 'EN' ? "Congratulations! You have successfully mastered Histograms." : "बधाई हो! आपने सफलतापूर्वक आयतचित्र में महारत हासिल कर ली है।", style: const TextStyle(color: Colors.white, fontSize: 18)),
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
                        color: Colors.yellow, 
                        border: Border.all(color: const Color(0xFF0F172A), width: 5), 
                        boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 40)]
                      ),
                      child: const Icon(Icons.bar_chart, color: Colors.black, size: 60),
                    ),
                    const SizedBox(height: 32),
                    Text(tHistograms, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
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
                      icon: const Icon(Icons.power_settings_new, color: Colors.black, size: 28),
                      label: Text(language == 'EN' ? "START MISSION" : "मिशन शुरू करें", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int step;
  final bool s2KinkPlaced;
  GridPainter(this.step, this.s2KinkPlaced);

  @override
  void paint(Canvas canvas, Size size) {
    Paint gridPaint = Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 2;
    Paint axisPaint = Paint()..color = Colors.white..strokeWidth = 3;
    
    double originX = 100;
    double originY = 350; // shifted down for bigger canvas
    
    for (int i = 0; i <= 10; i++) {
      double py = originY - i * 30; // 30px spacing per unit
      canvas.drawLine(Offset(originX, py), Offset(600, py), gridPaint);
      canvas.drawLine(Offset(originX - 5, py), Offset(originX, py), axisPaint);
      if (i > 0) {
        drawText(canvas, "${i * 2}", Offset(originX - 15, py), TextAlign.right);
      }
    }
    
    canvas.drawLine(Offset(originX, originY), Offset(600, originY), axisPaint);
    canvas.drawLine(Offset(originX, originY), Offset(originX, 30), axisPaint);
    
    drawText(canvas, "0", Offset(originX - 15, originY + 15), TextAlign.center);
    
    double startX = step == 1 ? originX : originX + 30;
    
    if (step > 1 && s2KinkPlaced) {
      Paint kinkPaint = Paint()..color = Colors.yellow..strokeWidth = 3..style = PaintingStyle.stroke;
      Path kinkPath = Path();
      kinkPath.moveTo(originX, originY);
      kinkPath.lineTo(originX + 10, originY - 15);
      kinkPath.lineTo(originX + 20, originY + 15);
      kinkPath.lineTo(originX + 30, originY);
      canvas.drawPath(kinkPath, kinkPaint);
    }

    if (step == 1) {
      drawTick(canvas, axisPaint, startX, originY, "800");
      drawTick(canvas, axisPaint, startX + 80, originY, "810");
      drawTick(canvas, axisPaint, startX + 160, originY, "820");
      drawTick(canvas, axisPaint, startX + 240, originY, "830");
    } else {
      drawTick(canvas, axisPaint, startX, originY, "800");
      drawTick(canvas, axisPaint, startX + 80, originY, "810");
      drawTick(canvas, axisPaint, startX + 160, originY, "820");
      drawTick(canvas, axisPaint, startX + 240, originY, "830");
      if (step >= 3) {
        drawTick(canvas, axisPaint, startX + 320, originY, "840");
        drawTick(canvas, axisPaint, startX + 400, originY, "850");
      }
    }
  }

  void drawTick(Canvas canvas, Paint paint, double x, double y, String label) {
    canvas.drawLine(Offset(x, y), Offset(x, y + 8), paint);
    drawText(canvas, label, Offset(x, y + 20), TextAlign.center);
  }

  void drawText(Canvas canvas, String text, Offset position, TextAlign align) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    double dx = position.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, position.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
