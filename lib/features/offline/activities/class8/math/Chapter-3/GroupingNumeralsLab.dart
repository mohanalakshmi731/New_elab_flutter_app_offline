// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Make sure to add this to pubspec.yaml

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GroupingNumeralsLab(),
    ),
  );
}

class GroupingNumeralsLab extends StatefulWidget {
  const GroupingNumeralsLab({Key? key}) : super(key: key);

  @override
  State<GroupingNumeralsLab> createState() => _GroupingNumeralsLabState();
}

class _GroupingNumeralsLabState extends State<GroupingNumeralsLab>
    with TickerProviderStateMixin {
  String currentLang = 'en';
  bool isSidebarOpen = true;
  int currentStep = 0;

  bool showShutter = true;
  bool isTaskValidated = false;

  // --- Step States ---
  int step0Selected = 0;
  bool step0Merged = false;
  List<bool> step0TallyState = List.filled(10, false);

  bool step1Found4 = false;
  bool step1Found6 = false;

  bool step2CCC = false;
  bool step2II = false;

  int step3C = 0;
  int step3X = 0;
  int step3I = 0;
  List<Map<String, dynamic>> step3Scattered = [];

  bool step4Error = false;

  // Audio Player
  late AudioPlayer _audioPlayer;

  // --- Translations Map ---
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'shutter_title': "Grouping & Written Numerals",
      'class_chapter': "Class 8 • A Story of Numbers",
      'btn_enter': "Enter Virtual Lab",
      'header_title': "Lab Control",
      'btn_validate': "Validate Model",
      'btn_validated': "Model Validated",
      'btn_pending': "Task Pending",
      'dropdown_s1': "Step 1: Landmark Numbers",
      'dropdown_s2': "Step 2: Adding & Subtracting",
      'dropdown_s3': "Step 3: Figure It Out",
      'dropdown_s4': "Step 4: Arithmetic Difficulty",
      'dropdown_s5': "Step 5: The Daredevil Contest",
      's2_subtract': "Subtract (-1)",
      's2_add': "Add (+1)",
      's2_value': "Value",
      's4_hundreds': "Hundreds",
      's4_tens': "Tens",
      's4_ones': "Ones",
      's5_title': "The Daredevil Contest",
      's5_info': "Tap or drag multiplier to stack it",
      's5_error_title': "Error: No Place Value",
      's5_error_desc':
          "Cannot align columns for calculation. Arithmetic breaks down!",
      's4_incorrect': "Incorrect!",
      's4_not_belong': "does not belong in the pool.",
      'understood': 'Understood',
      'scenarios': [
        {
          'title': "Landmark Numbers",
          'task':
              "Tap all 10 tally marks on the tablet to group them into the Roman landmark number 'X'.",
          'hud': "Tap tallies to select them. Group 10 to form X.",
        },
        {
          'title': "Adding & Subtracting",
          'task':
              "Drag the 'I' symbol to the left dropzone of 'V' to form 4, then to the right dropzone to form 6.",
          'hud': "Drag 'I' to a drop zone relative to 'V'.",
        },
        {
          'title': "Figure It Out: Conversions",
          'task':
              "Construct the number 302 by dragging the correct Roman landmark blocks into the empty slots.",
          'hud': "Drag the correct Roman blocks to form 302.",
        },
        {
          'title': "Arithmetic Difficulty",
          'task':
              "Sort the scattered symbols of the two numbers into their respective pools to add them together.",
          'hud': "Tap or drag C's to Hundreds, X's to Tens, I's to Ones.",
        },
        {
          'title': "The Daredevil Contest",
          'task':
              "Attempt to stack the multiplication problem by tapping or dragging the multiplier onto the multiplicand. Observe what happens.",
          'hud': "Tap or drag the multiplier to stack it.",
        },
      ],
    },
    'hi': {
      'shutter_title': "समूह और लिखित अंक",
      'class_chapter': "कक्षा 8 • संख्याओं की कहानी",
      'btn_enter': "वर्चुअल लैब में प्रवेश करें",
      'header_title': "लैब नियंत्रण",
      'btn_validate': "मॉडल मान्य करें",
      'btn_validated': "मॉडल मान्य हो गया",
      'btn_pending': "कार्य लंबित है",
      'dropdown_s1': "चरण 1: लैंडमार्क संख्याएँ",
      'dropdown_s2': "चरण 2: जोड़ना और घटाना",
      'dropdown_s3': "चरण 3: इसे समझें",
      'dropdown_s4': "चरण 4: अंकगणितीय कठिनाई",
      'dropdown_s5': "चरण 5: साहसी प्रतियोगिता",
      's2_subtract': "घटाएं (-1)",
      's2_add:': "जोड़ें (+1)",
      's2_value': "मान",
      's4_hundreds': "सैकड़ों",
      's4_tens': "दहाई",
      's4_ones': "इकाई",
      's5_title': "साहसी प्रतियोगिता",
      's5_info': "स्टैक करने के लिए गुणक को खींचें या टैप करें",
      's5_error_title': "त्रुटि: कोई स्थानीय मान नहीं",
      's5_error_desc':
          "गणना के लिए कॉलम संरेखित नहीं कर सकते। अंकगणित टूट जाता है!",
      's4_incorrect': "ग़लत!",
      's4_not_belong': "इस पूल से संबंधित नहीं है",
      'understood': 'समझ गया',
      'scenarios': [
        {
          'title': "लैंडमार्क संख्याएँ",
          'task':
              "रोमन लैंडमार्क संख्या 'X' में समूह बनाने के लिए टैबलेट पर सभी 10 मिलान चिह्नों को टैप करें।",
          'hud':
              "चुनने के लिए मिलान पर टैप करें। X बनाने के लिए 10 को समूहित करें।",
        },
        {
          'title': "लैंडमार्क जोड़ना और घटाना",
          'task':
              "4 बनाने के लिए 'I' प्रतीक को 'V' के बाईं ओर ड्रॉपज़ोन में खींचें, फिर 6 बनाने के लिए दाईं ओर खींचें।",
          'hud': "'I' को 'V' के सापेक्ष ड्रॉप ज़ोन में खींचें।",
        },
        {
          'title': "इसे समझें: रूपांतरण",
          'task':
              "खाली स्लॉट में सही रोमन लैंडमार्क ब्लॉक खींचकर 302 संख्या का निर्माण करें।",
          'hud': "302 बनाने के लिए सही रोमन ब्लॉक खींचें।",
        },
        {
          'title': "अंकगणितीय कठिनाई",
          'task':
              "जोड़ने के लिए दोनों संख्याओं के बिखरे हुए प्रतीकों को उनके संबंधित पूल में क्रमबद्ध करें।",
          'hud':
              "C को सैकड़ों में, X को दहाई में, I को इकाई में खींचें या टैप करें।",
        },
        {
          'title': "साहसी प्रतियोगिता",
          'task':
              "गुणा समस्या को स्टैक करने के लिए गुणक पर टैप करें या उसे खींचें। देखें क्या होता है।",
          'hud': "गुणक को गुण्य पर स्टैक करने के लिए टैप करें या खींचें।",
        },
      ],
    },
  };

  // Hardcoded Dark Theme Colors
  Color get bgColor => const Color(0xFF020617);
  Color get textColor => const Color(0xFFF8FAFC);
  Color get textMuted => const Color(0xFF94A3B8);
  Color get glassBg => const Color.fromRGBO(15, 23, 42, 0.75);
  Color get glassBorder => const Color.fromRGBO(255, 255, 255, 0.1);
  Color get primary => const Color(0xFFEAB308);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initStep3Scatter();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // --- Network Audio Tones ---
  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'success') {
        url =
            'audio/class8/mixkit_2013.mp3';
      } else if (type == 'click') {
        url =
            'audio/class8/mixkit_2568.mp3';
      } else if (type == 'error') {
        url =
            'audio/class8/mixkit_2955.mp3';
      }

      if (url.isNotEmpty) {
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.stop();
        }
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _loadStep(int step) {
    setState(() {
      currentStep = step;
      isTaskValidated = false;

      step0Selected = 0;
      step0Merged = false;
      step0TallyState = List.filled(10, false);

      step1Found4 = false;
      step1Found6 = false;

      step2CCC = false;
      step2II = false;

      step3C = 0;
      step3X = 0;
      step3I = 0;
      if (step == 3) _initStep3Scatter();

      step4Error = false;
    });
  }

  void _initStep3Scatter() {
    final symbols = [
      "C",
      "C",
      "X",
      "X",
      "X",
      "I",
      "I",
      "C",
      "C",
      "C",
      "X",
      "I",
      "I",
      "I",
    ];
    symbols.shuffle();
    step3Scattered.clear();
    for (var sym in symbols) {
      step3Scattered.add({'sym': sym, 'visible': true});
    }
  }

  void _checkValidation() {
    bool passed = false;
    if (currentStep == 0 && step0Selected == 10) passed = true;
    if (currentStep == 1 && step1Found4 && step1Found6) passed = true;
    if (currentStep == 2 && step2CCC && step2II) passed = true;
    if (currentStep == 3 && step3C == 5 && step3X == 4 && step3I == 5) {
      passed = true;
    }
    if (currentStep == 4 && step4Error) passed = true;

    if (passed && !isTaskValidated) {
      HapticFeedback.lightImpact();
      _playSound('success');
      setState(() => isTaskValidated = true);
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassBorder),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(msg, style: TextStyle(color: textColor.withOpacity(0.9))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              i18n[currentLang]!['understood'],
              style: TextStyle(color: primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glassBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 30,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // --- FLOATING MISSION CARD (Visible when sidebar collapsed) ---
  Widget _buildFloatingMissionCard(
    Map<String, dynamic> scenarioData,
    Map<String, dynamic> dict,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, color: primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scenarioData['title'],
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scenarioData['task'],
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Actions Row (Reset & Next Step)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: "Reset Step",
                icon: Icon(Icons.refresh, color: textMuted, size: 22),
                onPressed: () {
                  _playSound('click');
                  _loadStep(currentStep);
                },
              ),
              ElevatedButton.icon(
                onPressed: isTaskValidated
                    ? () {
                        _playSound('click');
                        if (currentStep < 4) {
                          _loadStep(currentStep + 1);
                        } else {
                          _loadStep(0); // Restart
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTaskValidated
                      ? Colors.green
                      : Colors.white12,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  isTaskValidated ? Icons.check_circle : Icons.lock,
                  color: isTaskValidated ? Colors.white : textMuted,
                  size: 18,
                ),
                label: Text(
                  isTaskValidated
                      ? (currentStep < 4 ? "Next Step" : "Restart")
                      : dict['btn_pending'],
                  style: TextStyle(
                    color: isTaskValidated ? Colors.white : textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 30% SIDEBAR LAYOUT ---
  Widget _buildSidebar(
    Map<String, dynamic> scenarioData,
    Map<String, dynamic> dict,
    double width,
  ) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: glassBg,
        border: Border(right: BorderSide(color: glassBorder)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
      ),
      // Make the entire sidebar scrollable while pushing footer to the bottom
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Header inside sidebar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: glassBorder)),
                    color: Colors.black12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Menu Icon Fixed at top-left
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: Icon(Icons.menu_open, color: textColor, size: 28),
                        onPressed: () {
                          _playSound('click');
                          setState(() => isSidebarOpen = false);
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Activity Icon, Title, and Subtitle
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.biotech,
                              color: primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dict['shutter_title'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dict['class_chapter'],
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. Language & Reset Controls
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: "Toggle Language",
                              icon: Text(
                                currentLang.toUpperCase(),
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(
                                  () => currentLang = currentLang == 'en'
                                      ? 'hi'
                                      : 'en',
                                );
                              },
                            ),
                            Container(width: 1, height: 24, color: glassBorder),
                            IconButton(
                              tooltip: "Reset Step",
                              icon: Icon(Icons.refresh, color: textMuted),
                              onPressed: () {
                                _playSound('click');
                                _loadStep(currentStep);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content (Takes up remaining space to push footer down)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: glassBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: currentStep,
                              dropdownColor: bgColor,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: primary,
                              ),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  _playSound('click');
                                  _loadStep(val);
                                }
                              },
                              items: List.generate(5, (index) {
                                return DropdownMenuItem(
                                  value: index,
                                  child: Text(dict['dropdown_s${index + 1}']),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Target Output
                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Target Output",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          scenarioData['title'],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            scenarioData['task'],
                            style: TextStyle(
                              color: Colors.blue[100],
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Validation Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isTaskValidated
                                ? () {
                                    _playSound('click');
                                    if (currentStep < 4) {
                                      _loadStep(currentStep + 1);
                                    } else {
                                      _loadStep(0); // Restart
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTaskValidated
                                  ? Colors.green
                                  : Colors.white12,
                              disabledBackgroundColor: Colors.white12,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isTaskValidated
                                      ? Icons.check_circle
                                      : Icons.lock,
                                  color: isTaskValidated
                                      ? Colors.white
                                      : textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isTaskValidated
                                      ? (currentStep < 4
                                            ? "Next Step"
                                            : "Restart Lab")
                                      : dict['btn_pending'],
                                  style: TextStyle(
                                    color: isTaskValidated
                                        ? Colors.white
                                        : textMuted,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sidebar Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border(top: BorderSide(color: glassBorder)),
                  ),
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dict = i18n[currentLang]!;
    final scenarioData = dict['scenarios'][currentStep];
    final size = MediaQuery.of(context).size;

    // Sidebar occupies 30% of screen width, minimum 300px
    final double sidebarWidth = max(size.width * 0.3, 300.0);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/offline_texture.png'),
                    opacity: 0.05,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                // CRITICAL FIX: Safe area padding ensures the workspace is NEVER overlapped by floating cards or the HUD!
                padding: EdgeInsets.only(
                  left: isSidebarOpen ? 20.0 : 290.0,
                  bottom: 100.0,
                  top: isSidebarOpen ? 20.0 : 80.0,
                  right: 20.0,
                ),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 4.0,
                  panEnabled: currentStep < 3,
                  scaleEnabled: currentStep < 3,
                  child: Center(
                    // CRITICAL FIX: FittedBox acts as a lens, scaling the entire workspace down proportionately to guarantee no overflow!
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 1000,
                        height: 700,
                        child: Container(
                          color: Colors.black.withOpacity(
                            0.001,
                          ), // Transparent background catches Hit Tests
                          child: _buildInteractiveScene(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Bottom Center HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 20,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Center(
                child: _buildGlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Text(
                    scenarioData['hud'],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // 3. Floating Mission Card (Visible if Sidebar is Closed)
            if (!isSidebarOpen)
              Positioned(
                top: 70,
                left: 20,
                child: _buildFloatingMissionCard(scenarioData, dict),
              ),

            // 4. Floating Menu & Back Buttons (Visible if Sidebar is Closed)
            if (!isSidebarOpen)
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.4),
                        ),
                        onPressed: () {
                          _playSound('click');
                          setState(() => isSidebarOpen = true);
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Scrollable 30% Sidebar (z-index overlapping front)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(scenarioData, dict, sidebarWidth),
            ),

            // 6. Initial Shutter Overlay
            if (showShutter)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hexagon, size: 80, color: primary),
                      const SizedBox(height: 24),
                      Text(
                        dict['shutter_title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dict['class_chapter'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _playSound('success');
                          setState(() => showShutter = false);
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.black),
                        label: Text(
                          dict['btn_enter'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- INTERACTIVE SCENES ---
  Widget _buildInteractiveScene() {
    double w = 1000;
    double h = 700;

    switch (currentStep) {
      case 0:
        return _buildStep0(w, h);
      case 1:
        return _buildStep1(w, h);
      case 2:
        return _buildStep2(w, h);
      case 3:
        return _buildStep3(w, h);
      case 4:
        return _buildStep4(w, h);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep0(double w, double h) {
    return Center(
      child: _buildGlassPanel(
        padding: const EdgeInsets.all(40),
        width: 400,
        child: step0Merged
            ? Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, val, child) => Transform.scale(
                    scale: val,
                    child: Text(
                      'X',
                      style: TextStyle(
                        color: primary,
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                            color: primary.withOpacity(0.6),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Wrap(
                spacing: 16,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: List.generate(10, (i) {
                  bool isSel = step0TallyState[i];
                  return GestureDetector(
                    onTap: () {
                      if (!isSel) {
                        HapticFeedback.selectionClick();
                        _playSound('click');
                        setState(() {
                          step0TallyState[i] = true;
                          step0Selected++;
                          if (step0Selected == 10) {
                            Future.delayed(
                              const Duration(milliseconds: 400),
                              () {
                                setState(() {
                                  step0Merged = true;
                                  _checkValidation();
                                });
                              },
                            );
                          }
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 12,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSel ? primary : textColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isSel
                            ? [BoxShadow(color: primary, blurRadius: 15)]
                            : [
                                const BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 5,
                                ),
                              ],
                      ),
                    ),
                  );
                }),
              ),
      ),
    );
  }

  Widget _buildStep1(double w, double h) {
    return Center(
      child: _buildGlassPanel(
        width: 500,
        height: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DragTarget<String>(
                  onAccept: (data) {
                    if (data == 'I') {
                      HapticFeedback.lightImpact();
                      _playSound('click');
                      setState(() {
                        step1Found4 = true;
                        _checkValidation();
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) => Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: step1Found4
                          ? Colors.redAccent.withOpacity(0.2)
                          : Colors.black26,
                      border: Border.all(
                        color: step1Found4 ? Colors.redAccent : glassBorder,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "-1 (IV)",
                        style: TextStyle(
                          color: step1Found4 ? Colors.redAccent : textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  'V',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 10),
                    ],
                  ),
                ),
                DragTarget<String>(
                  onAccept: (data) {
                    if (data == 'I') {
                      HapticFeedback.lightImpact();
                      _playSound('click');
                      setState(() {
                        step1Found6 = true;
                        _checkValidation();
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) => Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: step1Found6
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.black26,
                      border: Border.all(
                        color: step1Found6 ? Colors.greenAccent : glassBorder,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "+1 (VI)",
                        style: TextStyle(
                          color: step1Found6 ? Colors.greenAccent : textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (!step1Found4 || !step1Found6)
              Draggable<String>(
                data: 'I',
                feedback: _buildRomanBlock('I', true),
                childWhenDragging: _buildRomanBlock('I', false, opacity: 0.3),
                child: _buildRomanBlock('I', false),
              )
            else
              Text(
                "Awesome! IV=4, VI=6",
                style: TextStyle(
                  color: primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(double w, double h) {
    return Center(
      child: _buildGlassPanel(
        width: 600,
        height: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              "302",
              style: TextStyle(
                color: textColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 10,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTargetSlot('CCC', step2CCC, "300", (data) {
                  if (data == 'CCC') {
                    setState(() {
                      step2CCC = true;
                      _checkValidation();
                    });
                  }
                }),
                const SizedBox(width: 20),
                _buildTargetSlot('II', step2II, "2", (data) {
                  if (data == 'II') {
                    setState(() {
                      step2II = true;
                      _checkValidation();
                    });
                  }
                }),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: ['M', 'CC', 'CCC', 'XX', 'II', 'V'].map((opt) {
                if ((opt == 'CCC' && step2CCC) || (opt == 'II' && step2II)) {
                  return const SizedBox(width: 60, height: 60);
                }
                return Draggable<String>(
                  data: opt,
                  feedback: _buildRomanBlock(opt, true),
                  childWhenDragging: _buildRomanBlock(opt, false, opacity: 0.3),
                  child: _buildRomanBlock(opt, false),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSlot(
    String target,
    bool isFilled,
    String label,
    Function(String) onAccept,
  ) {
    return DragTarget<String>(
      onAccept: (data) {
        if (data == target) {
          _playSound('click');
          onAccept(data);
        } else {
          HapticFeedback.vibrate();
          _playSound('error');
        }
      },
      builder: (context, candidateData, rejectedData) => Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: isFilled ? Colors.green.withOpacity(0.2) : Colors.black26,
          border: Border.all(
            color: isFilled ? Colors.green : glassBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isFilled
              ? Text(
                  target,
                  style: TextStyle(
                    color: primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStep3(double w, double h) {
    bool isComplete = step3C == 5 && step3X == 4 && step3I == 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: glassBorder),
          ),
          child: Text(
            "CCXXXII + CCCXIII",
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),

        if (!isComplete) const SizedBox(height: 30),

        if (!isComplete)
          Container(
            width: 800,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(step3Scattered.length, (i) {
                var item = step3Scattered[i];
                if (!item['visible']) return const SizedBox();
                Color color = item['sym'] == 'C'
                    ? Colors.blueAccent
                    : (item['sym'] == 'X' ? Colors.greenAccent : primary);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _playSound('click');
                    setState(() {
                      step3Scattered[i]['visible'] = false;
                      if (item['sym'] == 'C') step3C++;
                      if (item['sym'] == 'X') step3X++;
                      if (item['sym'] == 'I') step3I++;
                      _checkValidation();
                    });
                  },
                  child: Draggable<String>(
                    data: '${item['sym']}_$i',
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildRomanBlock(item['sym'], true, color: color),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildRomanBlock(item['sym'], false, color: color),
                    ),
                    child: _buildRomanBlock(item['sym'], false, color: color),
                  ),
                );
              }),
            ),
          ),

        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPool(
              'C',
              "Hundreds",
              Colors.blueAccent,
              step3C,
              5,
              isComplete ? "D" : null,
            ),
            _buildPool(
              'X',
              "Tens",
              Colors.greenAccent,
              step3X,
              4,
              isComplete ? "XL" : null,
            ),
            _buildPool(
              'I',
              "Ones",
              primary,
              step3I,
              5,
              isComplete ? "V" : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPool(
    String target,
    String title,
    Color color,
    int count,
    int maxCount,
    String? resultSymbol,
  ) {
    return DragTarget<String>(
      onAccept: (data) {
        String sym = data.split('_')[0];
        int index = int.parse(data.split('_')[1]);
        if (sym == target) {
          HapticFeedback.selectionClick();
          _playSound('click');
          setState(() {
            step3Scattered[index]['visible'] = false;
            if (target == 'C') step3C++;
            if (target == 'X') step3X++;
            if (target == 'I') step3I++;
            _checkValidation();
          });
        } else {
          HapticFeedback.vibrate();
          _playSound('error');
          _showAlert("Incorrect", "'$sym' does not belong in the $title pool.");
        }
      },
      builder: (context, candidateData, rejectedData) => Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$title ($target)",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (resultSymbol != null)
              Text(
                resultSymbol,
                style: TextStyle(
                  color: color,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  shadows: [BoxShadow(color: color, blurRadius: 20)],
                ),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: List.generate(
                  count,
                  (i) => Text(
                    target,
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(double w, double h) {
    void handleStack() {
      if (step4Error) return;
      HapticFeedback.heavyImpact();
      _playSound('error');
      setState(() {
        step4Error = true;
        isTaskValidated = true;
      });
      Future.delayed(
        const Duration(milliseconds: 600),
        () => _playSound('success'),
      );
    }

    return Center(
      child: _buildGlassPanel(
        width: 500,
        height: 300,
        padding: const EdgeInsets.all(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (step4Error)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        i18n[currentLang]!['s5_error_title'],
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          i18n[currentLang]!['s5_error_desc'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Perfectly Aligned Target Block
                  DragTarget<String>(
                    onAccept: (data) => handleStack(),
                    builder: (context, candidateData, rejectedData) =>
                        Container(
                          width: 250, // Matches width of draggable
                          height: 60, // Matches height of draggable
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidateData.isNotEmpty
                                  ? Colors.redAccent
                                  : glassBorder,
                              width: candidateData.isNotEmpty ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            "CCXXXI",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Draggable wrapped with Tap-To-Stack feature
                  GestureDetector(
                    onTap: handleStack, // Native Tap Support!
                    child: Draggable<String>(
                      data: 'MDCCCLII',
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildRomanBlock("MDCCCLII", true, width: 250),
                      ),
                      childWhenDragging: _buildRomanBlock(
                        "MDCCCLII",
                        false,
                        opacity: 0.3,
                        width: 250,
                      ),
                      child: _buildRomanBlock("MDCCCLII", false, width: 250),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRomanBlock(
    String text,
    bool isDragging, {
    double opacity = 1.0,
    Color? color,
    double width = 60,
  }) {
    Color blockColor = color ?? primary;
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: isDragging
              ? [
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black38,
                    blurRadius: 5,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: blockColor,
              fontSize: 24,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
        ),
      ),
    );
  }
}
