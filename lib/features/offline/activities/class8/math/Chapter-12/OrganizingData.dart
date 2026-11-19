// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class OrganizingDataActivity extends StatefulWidget {
  const OrganizingDataActivity({super.key});

  @override
  State<OrganizingDataActivity> createState() => _OrganizingDataActivityState();
}

class _OrganizingDataActivityState extends State<OrganizingDataActivity> {
  int currentStep = 1;
  
  // Step 1 State
  bool s1Card8Dropped = false;
  bool s1Card24Dropped = false;
  
  // Step 2 State
  bool s2Card10Dropped = false;
  
  // Step 3 State
  int s3TallyCount = 0;
  bool s3Card4Dropped = false;
  
  // Step 4 State
  bool s4MedalDropped = false;

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
  static const String _errorUrl = 'audio/class8/mixkit_955.mp3';
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
      s1Card8Dropped = false;
      s1Card24Dropped = false;
      s2Card10Dropped = false;
      s3TallyCount = 0;
      s3Card4Dropped = false;
      s4MedalDropped = false;
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
    if (currentStep == 1) return s1Card8Dropped && s1Card24Dropped;
    if (currentStep == 2) return s2Card10Dropped;
    if (currentStep == 3) return s3TallyCount == 4 && s3Card4Dropped;
    if (currentStep == 4) return s4MedalDropped;
    return false;
  }

  // Translations
  String get tTitle => language == 'EN' ? "Organizing Data" : "डेटा व्यवस्थित करना";
  String get tSubtitle => language == 'EN' ? "CLASS 8 • TALES BY DOTS AND LINES" : "कक्षा 8 • बिंदुओं और रेखाओं की कहानियाँ";
  String get tMission => language == 'EN' ? "MISSION OBJECTIVE" : "मिशन का उद्देश्य";
  String get tAction => language == 'EN' ? "ACTION REQUIRED" : "कार्रवाई आवश्यक";
  String get tVerify => language == 'EN' ? "Verify Step" : "चरण सत्यापित करें";
  String get tDrop => language == 'EN' ? "Drop Here" : "यहाँ छोड़ें";
  
  String get tInterval => language == 'EN' ? "Class Interval" : "वर्ग अंतराल";
  String get tTally => language == 'EN' ? "Tally Marks" : "मिलान चिह्न";
  String get tFreq => language == 'EN' ? "Frequency" : "बारंबारता";
  String get tStrike => language == 'EN' ? "STRIKE" : "स्ट्राइक";
  String get tClicks => language == 'EN' ? "Clicks:" : "क्लिक:";

  String theoryText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "When we have a large amount of raw data, listing them individually is messy.\n\nWe group data into Class Intervals. This allows us to see patterns.\n\n- Lower Limit: Starting value\n- Upper Limit: Ending value";
        case 2: return "What happens if a student scores exactly 10? Does it go into '0-10' or '10-20'?\n\nIn mathematics, a value equal to the Upper Limit is EXCLUDED from that interval and included in the next one.";
        case 3: return "Let's practice tabulating data.\n\nRaw Data: 6, 7, 8, 9, 12, 13, 14\n\nTo record frequency efficiently, we use Tally Marks. For every 5th count, we draw a diagonal line across the 4 vertical marks.";
        case 4: return "Once the table is complete, we can interpret the data at a glance.\n\nWe can easily identify the highest density of data which helps in making decisions!";
      }
    } else {
      switch (step) {
        case 1: return "जब हमारे पास बड़ी मात्रा में डेटा होता है, तो उन्हें अलग-अलग सूचीबद्ध करना अव्यवस्थित होता है।\n\nहम डेटा को वर्ग अंतरालों में समूहित करते हैं।\n\n- निचली सीमा: प्रारंभिक मान\n- ऊपरी सीमा: अंतिम मान";
        case 2: return "क्या होगा यदि स्कोर ठीक 10 हो? क्या यह '0-10' में जाएगा या '10-20' में?\n\nगणित में, ऊपरी सीमा के बराबर मान को उस अंतराल से हटा दिया जाता है और अगले में शामिल किया जाता है।";
        case 3: return "आइए डेटा को सारणीबद्ध करने का अभ्यास करें।\n\nकच्चा डेटा: 6, 7, 8, 9, 12, 13, 14\n\nबारंबारता रिकॉर्ड करने के लिए, हम मिलान चिह्न का उपयोग करते हैं। हर 5वीं गिनती के लिए एक विकर्ण रेखा खींचें।";
        case 4: return "एक बार तालिका पूरी हो जाने पर, हम एक नज़र में डेटा की व्याख्या कर सकते हैं।\n\nहम आसानी से डेटा के उच्चतम घनत्व की पहचान कर सकते हैं!";
      }
    }
    return "";
  }

  String hudText(int step) {
    if (language == 'EN') {
      switch (step) {
        case 1: return "Pick up the highlighted score cards '8' and '24' and drag them into their correct Class Interval rows.";
        case 2: return "Solve the conflict! Drag the score card '10' into the correct Class Interval based on the exclusion convention.";
        case 3: return "Count the plants! Use the STRIKE button to mark the '5-10' interval based on heights (6,7,8,9). Then drag '4' to its frequency column.";
        case 4: return "Analyze the results! Drag the Gold Medal to the Class Interval row that contains the maximum number of plants.";
      }
    } else {
      switch (step) {
        case 1: return "हाइलाइट किए गए स्कोर कार्ड '8' और '24' उठाएं और उन्हें सही वर्ग अंतराल पंक्तियों में खींचें।";
        case 2: return "अपवर्जन परंपरा के आधार पर स्कोर कार्ड '10' को सही वर्ग अंतराल में खींचें।";
        case 3: return "(6,7,8,9) के आधार पर '5-10' अंतराल को चिह्नित करने के लिए स्ट्राइक बटन का उपयोग करें। फिर '4' को खींचें।";
        case 4: return "स्वर्ण पदक को उस वर्ग अंतराल पंक्ति में खींचें जिसमें अधिकतम संख्या हो।";
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
                const Icon(Icons.table_chart, color: Colors.yellow, size: 36),
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
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              items: [
                DropdownMenuItem(value: 1, child: Text(language == 'EN' ? "Step 1: The Need for Grouping" : "चरण 1: समूहीकरण")),
                DropdownMenuItem(value: 2, child: Text(language == 'EN' ? "Step 2: The 'Gap' Problem" : "चरण 2: 'अंतराल' समस्या")),
                DropdownMenuItem(value: 3, child: Text(language == 'EN' ? "Step 3: Tabulation Practice" : "चरण 3: सारणीकरण अभ्यास")),
                DropdownMenuItem(value: 4, child: Text(language == 'EN' ? "Step 4: Data Interpretation" : "चरण 4: डेटा व्याख्या")),
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

  Widget buildTallyMarks(int count) {
    if (count == 0) return const SizedBox();
    List<Widget> groups = [];
    int fives = count ~/ 5;
    int rem = count % 5;
    
    for (int i = 0; i < fives; i++) {
      groups.add(SizedBox(
        width: 30, height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (_) => Container(width: 3, height: 24, color: Colors.white)),
            ),
            Transform.rotate(
              angle: -0.8,
              child: Container(width: 34, height: 3, color: Colors.white),
            )
          ],
        )
      ));
    }
    if (rem > 0) {
      groups.add(SizedBox(
        width: rem * 7.5, height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(rem, (_) => Container(width: 3, height: 24, color: Colors.white)),
        )
      ));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: groups.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList(),
    );
  }

  Widget buildDraggableCard(String val, {bool isInteractive = true, Color bgColor = Colors.yellow, Color textColor = Colors.black}) {
    if (!isInteractive) {
      return Container(
        width: 35, height: 28,
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
        alignment: Alignment.center,
        child: Text(val, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
    
    Widget content = Container(
      width: 45, height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bgColor == Colors.yellow ? Colors.yellowAccent : bgColor.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: bgColor.withOpacity(0.6), blurRadius: 8)]
      ),
      alignment: Alignment.center,
      child: Text(val, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
    );

    return Draggable<String>(
      data: val,
      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.1, child: content)),
      childWhenDragging: Opacity(opacity: 0.3, child: content),
      child: content,
    );
  }

  Widget buildMedalCard() {
    Widget content = Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
        border: Border.all(color: Colors.yellowAccent, width: 3),
        boxShadow: const [BoxShadow(color: Colors.amber, blurRadius: 15)]
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.emoji_events, color: Colors.white, size: 40),
    );

    return Draggable<String>(
      data: "medal",
      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.1, child: content)),
      childWhenDragging: Opacity(opacity: 0.3, child: content),
      child: content,
    );
  }

  Widget buildSourceContainer() {
    if (currentStep == 1) {
      List<int> vals = [5, 28, 41, 19, 33, 48, 15, 22, 3, 9, 36, 20, 17, 25, 45, 11, 30, 7, 29, 39, 8, 24];
      return Wrap(
        spacing: 6, runSpacing: 6,
        alignment: WrapAlignment.center,
        children: vals.map((v) {
          if (v == 8 && s1Card8Dropped) return const SizedBox();
          if (v == 24 && s1Card24Dropped) return const SizedBox();
          bool isInteractive = (v == 8 || v == 24);
          return buildDraggableCard(v.toString(), isInteractive: isInteractive);
        }).toList(),
      );
    } else if (currentStep == 2) {
      if (s2Card10Dropped) return const SizedBox();
      return buildDraggableCard("10");
    } else if (currentStep == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () {
              if (s3TallyCount < 4) {
                playSound(_clickPlayer, _clickUrl);
                setState(() => s3TallyCount++);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, color: Colors.white),
                const SizedBox(height: 4),
                Text(tStrike, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            )
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tClicks, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              Text("$s3TallyCount", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 32),
          if (!s3Card4Dropped)
            buildDraggableCard("4", 
              isInteractive: s3TallyCount == 4, 
              bgColor: s3TallyCount == 4 ? Colors.teal : Colors.grey, 
              textColor: Colors.white
            )
        ],
      );
    } else if (currentStep == 4) {
      if (s4MedalDropped) return const SizedBox();
      return buildMedalCard();
    }
    return const SizedBox();
  }

  Widget buildTableCell(Widget child, {bool isHeader = false, bool isYellow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Center(
        child: isHeader
          ? Text((child as Text).data!, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14))
          : DefaultTextStyle(style: TextStyle(color: isYellow ? Colors.yellow : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'), child: child),
      )
    );
  }

  Widget buildDropzoneCell(String targetVal, bool isFilled) {
    if (isFilled) {
      return buildDraggableCard(targetVal, isInteractive: false, bgColor: Colors.yellow);
    }
    return DragTarget<String>(
      onWillAccept: (d) => d == targetVal,
      onAccept: (d) {
        playSound(_fxPlayer, _snapUrl);
        setState(() {
          if (currentStep == 1) {
            if (d == '8') s1Card8Dropped = true;
            if (d == '24') s1Card24Dropped = true;
          } else if (currentStep == 2) {
            if (d == '10') s2Card10Dropped = true;
          } else if (currentStep == 3) {
            if (d == '4') s3Card4Dropped = true;
          }
        });
      },
      builder: (ctx, c, r) => Container(
        width: 60, height: 40,
        decoration: BoxDecoration(
          color: c.isNotEmpty ? Colors.yellow.withOpacity(0.3) : Colors.black26,
          border: Border.all(color: c.isNotEmpty ? Colors.yellow : Colors.white24, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8)
        ),
        alignment: Alignment.center,
        child: Text(c.isNotEmpty ? "" : tDrop, style: const TextStyle(color: Colors.white30, fontSize: 10)),
      ),
    );
  }

  Widget buildTable() {
    List<TableRow> rows = [];
    
    // Header
    rows.add(TableRow(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24, width: 1))),
      children: [
        buildTableCell(Text(tInterval.toUpperCase()), isHeader: true),
        buildTableCell(Text(tTally.toUpperCase()), isHeader: true),
        buildTableCell(Text(tFreq.toUpperCase()), isHeader: true),
      ]
    ));

    if (currentStep == 1) {
      rows.addAll([
        TableRow(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("0-10"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(buildDropzoneCell("8", s1Card8Dropped)),
        ]),
        TableRow(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("10-20"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(const Text("")),
        ]),
        TableRow(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("20-30"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(buildDropzoneCell("24", s1Card24Dropped)),
        ]),
        TableRow(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("30-40"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(const Text("")),
        ]),
        TableRow(children: [
          buildTableCell(const Text("40-50"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(const Text("")),
        ]),
      ]);
    } else if (currentStep == 2) {
      rows.addAll([
        TableRow(decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.1), border: const Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("0-10"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(DragTarget<String>(
            onWillAccept: (d) => true,
            onAccept: (d) {
              playSound(_errorPlayer, _errorUrl);
            },
            builder: (ctx, c, r) => Container(
              width: 60, height: 40,
              decoration: BoxDecoration(color: c.isNotEmpty ? Colors.red.withOpacity(0.3) : Colors.black26, border: Border.all(color: c.isNotEmpty ? Colors.red : Colors.white24, width: 2), borderRadius: BorderRadius.circular(8)),
            ),
          )),
        ]),
        TableRow(decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.1), border: const Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("10-20"), isYellow: true),
          buildTableCell(const Text("")),
          buildTableCell(buildDropzoneCell("10", s2Card10Dropped)),
        ]),
      ]);
    } else if (currentStep == 3) {
      rows.addAll([
        TableRow(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))), children: [
          buildTableCell(const Text("5-10"), isYellow: true),
          buildTableCell(buildTallyMarks(s3TallyCount)),
          buildTableCell(buildDropzoneCell("4", s3Card4Dropped)),
        ]),
        TableRow(children: [
          buildTableCell(const Text("10-15"), isYellow: true),
          buildTableCell(buildTallyMarks(3)),
          buildTableCell(const Text("3")),
        ]),
      ]);
    } else if (currentStep == 4) {
      List<Map<String, dynamic>> rowData = [
        {"int": "5-10", "t": 4, "f": "4"},
        {"int": "10-15", "t": 12, "f": "12"},
        {"int": "15-20", "t": 8, "f": "8"},
        {"int": "20-25", "t": 6, "f": "6"},
      ];
      
      for (var rd in rowData) {
        Widget rowContent = Table(
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
          children: [
            TableRow(children: [
              buildTableCell(Text(rd["int"]), isYellow: true),
              buildTableCell(buildTallyMarks(rd["t"])),
              buildTableCell(Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Text(rd["f"]),
                  if (rd["int"] == "10-15" && s4MedalDropped)
                    const Positioned(right: -40, child: Icon(Icons.emoji_events, color: Colors.amber, size: 40))
                ],
              )),
            ])
          ]
        );
        
        rows.add(TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
          children: [
            TableCell(
              child: DragTarget<String>(
                onWillAccept: (d) => rd["int"] == "10-15" && d == "medal",
                onAccept: (d) {
                  playSound(_fxPlayer, _snapUrl);
                  setState(() => s4MedalDropped = true);
                },
                builder: (ctx, c, r) {
                  return Container(
                    decoration: BoxDecoration(color: c.isNotEmpty ? Colors.yellow.withOpacity(0.2) : Colors.transparent),
                    child: rowContent,
                  );
                }
              )
            ),
            const TableCell(child: SizedBox()), // dummy cells to keep structure if needed, or we just render the single child across 3 columns? 
            // Wait, TableRow must have same number of columns.
            // Let's refactor step 4 rows to just use the standard TableRow but wrap the row in a DragTarget?
            // TableRow doesn't support wrapping. We can just wrap each cell in a DragTarget, or just the whole row via a single column table.
          ]
        ));
      }
    }

    if (currentStep != 4) {
      return Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24)
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1),
          },
          children: rows,
        ),
      );
    } else {
      // Step 4: Special table with row dropzones
      List<TableRow> s4Rows = [];
      s4Rows.add(TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24, width: 1))),
        children: [
          buildTableCell(Text(tInterval.toUpperCase()), isHeader: true),
          buildTableCell(Text(tTally.toUpperCase()), isHeader: true),
          buildTableCell(Text(tFreq.toUpperCase()), isHeader: true),
        ]
      ));
      
      List<Map<String, dynamic>> rowData = [
        {"int": "5-10", "t": 4, "f": "4"},
        {"int": "10-15", "t": 12, "f": "12"},
        {"int": "15-20", "t": 8, "f": "8"},
        {"int": "20-25", "t": 6, "f": "6"},
      ];
      
      for (var rd in rowData) {
        s4Rows.add(TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
          children: [
            DragTarget<String>(
              onWillAccept: (d) => rd["int"] == "10-15",
              onAccept: (d) { playSound(_fxPlayer, _snapUrl); setState(() => s4MedalDropped = true); },
              builder: (ctx, c, r) => Container(color: c.isNotEmpty ? Colors.yellow.withOpacity(0.2) : Colors.transparent, child: buildTableCell(Text(rd["int"]), isYellow: true)),
            ),
            DragTarget<String>(
              onWillAccept: (d) => rd["int"] == "10-15",
              onAccept: (d) { playSound(_fxPlayer, _snapUrl); setState(() => s4MedalDropped = true); },
              builder: (ctx, c, r) => Container(color: c.isNotEmpty ? Colors.yellow.withOpacity(0.2) : Colors.transparent, child: buildTableCell(buildTallyMarks(rd["t"]))),
            ),
            DragTarget<String>(
              onWillAccept: (d) => rd["int"] == "10-15",
              onAccept: (d) { playSound(_fxPlayer, _snapUrl); setState(() => s4MedalDropped = true); },
              builder: (ctx, c, r) => Container(
                color: c.isNotEmpty ? Colors.yellow.withOpacity(0.2) : Colors.transparent, 
                child: buildTableCell(Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Text(rd["f"]),
                    if (rd["int"] == "10-15" && s4MedalDropped)
                      const Positioned(right: -40, child: Icon(Icons.emoji_events, color: Colors.amber, size: 40))
                  ],
                ))
              ),
            ),
          ]
        ));
      }
      
      return Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24)
        ),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1)},
          children: s4Rows,
        ),
      );
    }
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      buildTable(),
                      
                      // Visual Aid for Step 2
                      if (currentStep == 2)
                        Positioned(
                          top: -60,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                            child: const Row(
                              children: [
                                Text("10 < 10 ? ❌", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 24),
                                Text("10 >= 10 ? ✅", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        )
                    ],
                  )
                ),
              ),
            ),
          ),
          
          // Elements sitting ABOVE the canvas
          
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
                          Text(language == 'EN' ? "Congratulations! You have successfully mastered Frequency Distributions." : "बधाई हो! आपने सफलतापूर्वक बारंबारता बंटन में महारत हासिल कर ली है।", style: const TextStyle(color: Colors.white, fontSize: 18)),
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
                      child: const Icon(Icons.table_chart, color: Colors.yellow, size: 60),
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
