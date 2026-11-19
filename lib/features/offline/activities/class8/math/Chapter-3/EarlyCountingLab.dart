// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class EarlyCountingLab extends StatefulWidget {
  const EarlyCountingLab({Key? key}) : super(key: key);

  @override
  State<EarlyCountingLab> createState() => _EarlyCountingLabState();
}

class _EarlyCountingLabState extends State<EarlyCountingLab>
    with TickerProviderStateMixin {
  bool isDarkMode = true;
  String currentLang = 'en';
  bool isSidebarOpen = true;
  int currentStep = 1;
  double boardFontSize = 16.0;

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Lab Interaction State
  int currentHits = 0;
  int maxHits = 3;

  // Step 1 State
  List<bool> sheepInPasture = [false, false, false];
  List<double> sheepPositions = [0, 0, 0];

  // Step 3 State
  bool sticksMultiplied = false;
  List<Offset> scatteredSticks = [];

  // Step 4 & 5 State
  int currentSum = 0;
  List<int> addedBlocks = []; // 1 for Urapon, 2 for Ukasar

  // Translations Map
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'mainTitle': "Early Counting & Tallying",
      'subTitle': "Class 8 • A Story of Numbers",
      'enterLab': "Enter Lab",
      'settingsTitle': "Lab Settings",
      'theme': "Theme",
      'fontSize': "Board Font Size",
      'headerTitle': "Early Counting",
      'headerSub': "Class 8 • Numbers",
      'taskStatusLbl': "Task Status",
      'currentActionLbl': "Current Action",
      'theoryLbl': "Theory",
      'interactionLbl': "Interaction Task",
      'awaiting': "Awaiting Interaction",
      'inProgress': "In Progress",
      'taskCompleted': "Task Completed!",
      'completeTaskBtn': "Complete Task to Proceed",
      'proceedBtn': "Proceed to Step",
      'finishBtn': "Finish Activity",
      'currentSum': "Current Sum:",
      'hintUkasar': "Hint: Start with the largest base (Ukasar)",
      'hintUkasarFirst': "Hint: Use Ukasar first!",
      'finishedAlertTitle': "Activity Completed!",
      'finishedAlertMsg':
          "Congratulations! You have mastered Early Counting & Tallying.",
      'understood': "Understood",
      'alertNotif': "Notification",
      'textMultiply': "MULTIPLY",
      'textUkasar': "Ukasar (2)",
      'textUrapon': "Urapon (1)",
      'scenarios': {
        1: {
          'opt': "Step 1: Shepherd's Counting",
          'title': "The Shepherd's Counting",
          'theory':
              "Long before we had numbers like 1, 2, or 3, how did people count? A shepherd needs to know if all his sheep returned from the pasture. For every sheep that goes out, he puts one pebble in a pouch. When they return, he takes one pebble out. If the pouch is empty, all sheep are back. This is called 'one-to-one correspondence'.",
          'task':
              "Tap the sheep in the pen to move them to the pasture. Watch how a pebble is added to the pouch for each sheep.",
        },
        2: {
          'opt': "Step 2: Body Part Counting",
          'title': "Body Part Counting",
          'theory':
              "Pebbles are heavy to carry around. What if you used something you always carry? Indigenous tribes in Papua New Guinea use their own bodies as a sequence to count! They start with the fingers of one hand, move up to the wrist, elbow, shoulder, neck, and ear. This sequence allows them to count up to 27 objects reliably without modern number words.",
          'task':
              "Trace the counting sequence by tapping the glowing yellow markers on the figure's right arm in the correct order: Hand (1-5) → Wrist (6) → Elbow (7).",
        },
        3: {
          'opt': "Step 3: Stick Math",
          'title': "Figure It Out - Stick Math",
          'theory':
              "Can we do arithmetic using just tallies or sticks? Try adding two piles of sticks. It's easy, just push them together. But try multiplying a pile of 4 sticks by a pile of 3 sticks. Without modern numerals or a place-value system, you have to physically count out 12 individual sticks. Imagine multiplying large quantities! This shows the severe limitations of early methods.",
          'task':
              "Tap the 'MULTIPLY' block between the two groups of sticks to see the result.",
        },
        4: {
          'opt': "Step 4: Gumulgal Words",
          'title': "Gumulgal Words",
          'theory':
              "Some cultures developed words for numbers, but only a few base words. The Gumulgal counting system from Australia has only two base words: 'urapon' for 1, and 'ukasar' for 2. To say 3, they combine them: 'ukasar-urapon' (2+1). It is an additive word system.",
          'task':
              "Construct the number 3 using the blocks below. Select the blocks in the correct additive order (2 then 1).",
        },
        5: {
          'opt': "Step 5: Gumulgal Arithmetic",
          'title': "Gumulgal Arithmetic",
          'theory':
              "Now for the final challenge: Perform arithmetic using only Gumulgal words. What is 'ukasar' plus 'ukasar-urapon'? We translate it first: 2 + 3 = 5. Now, how do we say 5 in Gumulgal? We must group it by twos and ones: 2 + 2 + 1. So, 5 becomes 'ukasar-ukasar-urapon'. This reveals why standard, modern number systems were invented—to make counting and arithmetic efficient!",
          'task':
              "Construct the number 5 using the Gumulgal blocks (2 + 2 + 1).",
        },
      },
    },
    'hi': {
      'mainTitle': "प्रारंभिक गिनती और मिलान",
      'subTitle': "कक्षा 8 • संख्या की कहानी",
      'enterLab': "प्रयोगशाला में प्रवेश करें",
      'settingsTitle': "प्रयोगशाला सेटिंग्स",
      'theme': "थीम",
      'fontSize': "बोर्ड फ़ॉन्ट आकार",
      'headerTitle': "प्रारंभिक गिनती",
      'headerSub': "कक्षा 8 • संख्या",
      'taskStatusLbl': "कार्य की स्थिति",
      'currentActionLbl': "वर्तमान कार्रवाई",
      'theoryLbl': "सिद्धांत",
      'interactionLbl': "इंटरेक्शन कार्य",
      'awaiting': "बातचीत की प्रतीक्षा",
      'inProgress': "प्रगति पर है",
      'taskCompleted': "कार्य पूरा हुआ!",
      'completeTaskBtn': "आगे बढ़ने के लिए कार्य पूरा करें",
      'proceedBtn': "चरण पर आगे बढ़ें",
      'finishBtn': "गतिविधि समाप्त करें",
      'currentSum': "वर्तमान योग:",
      'hintUkasar': "संकेत: सबसे बड़े आधार (उकासर) से शुरू करें",
      'hintUkasarFirst': "संकेत: पहले उकासर का उपयोग करें!",
      'finishedAlertTitle': "गतिविधि पूरी हुई!",
      'finishedAlertMsg':
          "बधाई हो! आपने प्रारंभिक गिनती और मिलान में महारत हासिल कर ली है।",
      'understood': "समझ गया",
      'alertNotif': "अधिसूचना",
      'textMultiply': "गुणा करें",
      'textUkasar': "उकासर (2)",
      'textUrapon': "उरापोन (1)",
      'scenarios': {
        1: {
          'opt': "चरण 1: चरवाहे की गिनती",
          'title': "चरवाहे की गिनती",
          'theory':
              "1, 2, या 3 जैसी संख्याओं के होने से बहुत पहले, लोग कैसे गिनते थे? एक चरवाहे को यह जानना होता है कि क्या उसकी सभी भेड़ें चरागाह से लौट आई हैं। बाहर जाने वाली प्रत्येक भेड़ के लिए, वह थैली में एक कंकड़ डालता है। जब वे लौटती हैं, तो वह एक कंकड़ निकालता है। यदि थैली खाली है, तो सभी भेड़ें वापस आ गई हैं। इसे 'एक-से-एक पत्राचार' कहा जाता है।",
          'task':
              "भेड़ों को चरागाह में ले जाने के लिए बाड़े में टैप करें। देखें कि प्रत्येक भेड़ के लिए थैली में कैसे एक कंकड़ जोड़ा जाता है।",
        },
        2: {
          'opt': "चरण 2: शरीर के अंगों की गिनती",
          'title': "शरीर के अंगों की गिनती",
          'theory':
              "कंकड़ ले जाने में भारी होते हैं। क्या होगा यदि आप उस चीज़ का उपयोग करें जिसे आप हमेशा साथ रखते हैं? पापुआ न्यू गिनी में स्वदेशी जनजातियां गिनने के लिए अपने शरीर का अनुक्रम के रूप में उपयोग करती हैं! वे एक हाथ की उंगलियों से शुरू करते हैं, कलाई, कोहनी, कंधे, गर्दन और कान तक जाते हैं। यह अनुक्रम उन्हें आधुनिक संख्या शब्दों के बिना 27 वस्तुओं तक मज़बूती से गिनने की अनुमति देता है।",
          'task':
              "सही क्रम में आकृति के दाहिने हाथ पर चमकते हुए पीले मार्करों पर टैप करके गिनती अनुक्रम का पता लगाएं: हाथ (1-5) → कलाई (6) → कोहनी (7)।",
        },
        3: {
          'opt': "चरण 3: इसे समझें - स्टिक मैथ",
          'title': "इसे समझें - स्टिक मैथ",
          'theory':
              "क्या हम केवल मिलान या छड़ियों का उपयोग करके अंकगणित कर सकते हैं? छड़ियों के दो ढेरों को जोड़ने का प्रयास करें। यह आसान है, बस उन्हें एक साथ धकेलें। लेकिन 4 छड़ियों के ढेर को 3 छड़ियों के ढेर से गुणा करने का प्रयास करें। आधुनिक अंकों या स्थानीय-मान प्रणाली के बिना, आपको 12 अलग-अलग छड़ियों को भौतिक रूप से गिनना होगा। बड़ी मात्रा में गुणा करने की कल्पना करें! यह शुरुआती तरीकों की गंभीर सीमाओं को दर्शाता है।",
          'task':
              "परिणाम देखने के लिए छड़ियों के दो समूहों के बीच 'गुणा करें' ब्लॉक पर टैप करें।",
        },
        4: {
          'opt': "चरण 4: गुमुल्गल शब्द",
          'title': "गुमुल्गल शब्द",
          'theory':
              "कुछ संस्कृतियों ने संख्याओं के लिए शब्द विकसित किए, लेकिन केवल कुछ मूल शब्द। ऑस्ट्रेलिया की गुमुल्गल गिनती प्रणाली में केवल दो मूल शब्द हैं: 1 के लिए 'उरापोन' और 2 के लिए 'उकासर'। 3 कहने के लिए, वे उन्हें मिलाते हैं: 'उकासर-उरापोन' (2+1)। यह एक योगात्मक शब्द प्रणाली है।",
          'task':
              "नीचे दिए गए ब्लॉकों का उपयोग करके संख्या 3 का निर्माण करें। ब्लॉकों को सही योगात्मक क्रम (2 फिर 1) में चुनें।",
        },
        5: {
          'opt': "चरण 5: गुमुल्गल अंकगणित",
          'title': "गुमुल्गल अंकगणित",
          'theory':
              "अब अंतिम चुनौती के लिए: केवल गुमुल्गल शब्दों का उपयोग करके अंकगणित करें। 'उकासर' और 'उकासर-उरापोन' का योग क्या है? हम पहले इसका अनुवाद करते हैं: 2 + 3 = 5. अब, हम गुमुल्गल में 5 कैसे कहते हैं? हमें इसे दो और एक के समूह में रखना होगा: 2 + 2 + 1. इसलिए, 5 'उकासर-उकासर-उरापोन' बन जाता है। इससे पता चलता है कि गिनती और अंकगणित को कुशल बनाने के लिए मानक, आधुनिक संख्या प्रणालियों का आविष्कार क्यों किया गया था!",
          'task':
              "गुमुल्गल ब्लॉकों (2 + 2 + 1) का उपयोग करके संख्या 5 का निर्माण करें।",
        },
      },
    },
  };

  bool showShutter = true;
  bool showSettings = false;

  // Colors based on theme
  Color get bgColor =>
      isDarkMode ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
  Color get textColor =>
      isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textMuted =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get glassBg => isDarkMode
      ? const Color.fromRGBO(15, 23, 42, 0.75)
      : const Color.fromRGBO(255, 255, 255, 0.85);
  Color get glassBorder => isDarkMode
      ? const Color.fromRGBO(255, 255, 255, 0.15)
      : const Color.fromRGBO(0, 0, 0, 0.15);
  Color get primary => const Color(0xFFEAB308);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  // Audio Playback
  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'tap') {
        url =
            'audio/class8/mixkit_2568.mp3'; // Pop
      } else if (type == 'success') {
        url =
            'audio/class8/mixkit_2018.mp3'; // Tada
      } else if (type == 'error') {
        url =
            'audio/class8/mixkit_955.mp3'; // Buzzer
      }

      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  void _loadScenario(int step) {
    setState(() {
      currentStep = step;
      currentHits = 0;

      // Reset logic states
      sheepInPasture = [false, false, false];
      sticksMultiplied = false;
      scatteredSticks.clear();
      currentSum = 0;
      addedBlocks.clear();

      // Setup target hits
      if (step == 1) maxHits = 3;
      if (step == 2) maxHits = 3;
      if (step == 3) maxHits = 1;
      if (step == 4) maxHits = 2;
      if (step == 5) maxHits = 3;
    });
  }

  void _checkValidation() {
    if (currentHits >= maxHits) {
      HapticFeedback.lightImpact();
      _playSound('success');
      // Force UI update to show completion
      setState(() {});
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
        // Made success popup strictly scrollable
        content: SingleChildScrollView(
          child: Text(
            msg,
            style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              i18n[currentLang]!['understood'],
              style: TextStyle(color: primary, fontWeight: FontWeight.bold),
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dict = i18n[currentLang]!;
    final scenarioData = dict['scenarios'][currentStep];
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.35;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // --- MAIN CANVAS LAYER ---
            // Pushed dynamically to the right when sidebar is open to make the center responsive
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [glassBg, bgColor],
                    radius: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Adjustable Zoomable Interactive Area
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return InteractiveViewer(
                          // Setting infinite margin allows moving/panning freely without boundaries
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.1,
                          maxScale: 5.0,
                          clipBehavior: Clip.none,
                          child: Container(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            // Transparent color ensures the entire canvas captures pan/zoom gestures
                            color: Colors.transparent,
                            child: _buildInteractiveSceneBase(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                          ),
                        );
                      },
                    ),

                    // Floating Mission Card (Visible only when sidebar collapsed)
                    if (!isSidebarOpen)
                      Positioned(
                        bottom: 24,
                        left: 24,
                        right: 24,
                        child: Center(
                          child: _buildMissionFloatingCard(dict, scenarioData),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- LEFT SIDEBAR LAYER (z-index front) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildLeftSidebar(sidebarWidth, dict, scenarioData),
            ),

            // --- FIXED TOP LEFT CONTROLS (Z-index top - always visible) ---
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => isSidebarOpen = !isSidebarOpen);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- SETTINGS OVERLAY ---
            if (showSettings)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: _buildGlassPanel(
                    width: 340,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.settings, color: textColor),
                                const SizedBox(width: 8),
                                Text(
                                  dict['settingsTitle'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: textColor),
                              onPressed: () =>
                                  setState(() => showSettings = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dict['theme'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: primary,
                              ),
                              onPressed: () =>
                                  setState(() => isDarkMode = !isDarkMode),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dict['fontSize'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${boardFontSize.toInt()}px",
                              style: TextStyle(color: primary),
                            ),
                          ],
                        ),
                        Slider(
                          value: boardFontSize,
                          min: 14,
                          max: 32,
                          activeColor: primary,
                          onChanged: (val) =>
                              setState(() => boardFontSize = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- SHUTTER SCREEN ---
            if (showShutter)
              Positioned.fill(
                child: Container(
                  color: bgColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dict['mainTitle'],
                        style: TextStyle(
                          color: primary,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dict['subTitle'],
                        style: TextStyle(color: textMuted, fontSize: 20),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _playSound('success');
                          setState(() => showShutter = false);
                        },
                        icon: const Icon(Icons.science, color: Colors.black),
                        label: Text(
                          dict['enterLab'],
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

  // --- FLOATING MISSION CARD (Visible when sidebar collapsed) ---
  Widget _buildMissionFloatingCard(
    Map<String, dynamic> dict,
    Map<String, dynamic> scenarioData,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dict['taskStatusLbl'].toUpperCase(),
                style: TextStyle(
                  color: textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currentHits >= maxHits
                    ? dict['taskCompleted']
                    : dict['inProgress'],
                style: TextStyle(
                  color: currentHits >= maxHits
                      ? Colors.greenAccent[400]
                      : primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 36,
            width: 1,
            color: glassBorder,
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dict['currentActionLbl'].toUpperCase(),
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentStep >= 4
                      ? "${dict['currentSum']} $currentSum"
                      : scenarioData['task'],
                  style: TextStyle(color: textColor, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FULLY SCROLLABLE LEFT SIDEBAR ---
  Widget _buildLeftSidebar(
    double width,
    Map<String, dynamic> dict,
    Map<String, dynamic> scenarioData,
  ) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        border: Border(right: BorderSide(color: glassBorder, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Block (Title, Buttons)
                Container(
                  // Added top padding to prevent content from going under the fixed floating buttons
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: glassBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.science, color: primary, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dict['headerTitle'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  dict['headerSub'],
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Text(
                              currentLang.toUpperCase(),
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => setState(
                              () => currentLang = currentLang == 'en'
                                  ? 'hi'
                                  : 'en',
                            ),
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.settings, color: textMuted),
                          //   onPressed: () =>
                          //       setState(() => showSettings = true),
                          // ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: textMuted),
                            onPressed: () => _loadScenario(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Content Block
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dropdown
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
                                if (val != null) _loadScenario(val);
                              },
                              items: List.generate(5, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(
                                    dict['scenarios'][index + 1]['opt'],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Theory Block
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dict['theoryLbl'].toUpperCase(),
                            style: TextStyle(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scenarioData['title'],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scenarioData['theory'],
                          style: TextStyle(
                            color: textColor.withOpacity(0.9),
                            fontSize: boardFontSize,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Target/Task Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    dict['interactionLbl'],
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                scenarioData['task'],
                                style: TextStyle(
                                  color: textColor.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Validation Button Block
                        ElevatedButton(
                          onPressed: currentHits >= maxHits
                              ? () {
                                  if (currentStep < 5) {
                                    _loadScenario(currentStep + 1);
                                  } else {
                                    _showAlert(
                                      dict['finishedAlertTitle'],
                                      dict['finishedAlertMsg'],
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentHits >= maxHits
                                ? primary
                                : glassBg,
                            disabledBackgroundColor: glassBg,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: currentHits >= maxHits
                                  ? primary
                                  : glassBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  currentHits >= maxHits
                                      ? (currentStep < 5
                                            ? "${dict['proceedBtn']} ${currentStep + 1}"
                                            : dict['finishBtn'])
                                      : dict['completeTaskBtn'],
                                  style: TextStyle(
                                    color: currentHits >= maxHits
                                        ? Colors.black
                                        : textMuted,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                currentHits >= maxHits
                                    ? (currentStep < 5
                                          ? Icons.arrow_forward
                                          : Icons.check_circle)
                                    : Icons.lock,
                                color: currentHits >= maxHits
                                    ? Colors.black
                                    : textMuted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

  // Helper widget to draw a realistic layered cartoon sheep
  Widget _buildRealisticSheep() {
    return SizedBox(
      width: 90,
      height: 75,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow
          Positioned(
            bottom: 0,
            left: 10,
            child: Container(
              width: 60,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          // Back Legs
          Positioned(bottom: 5, left: 25, child: _buildSheepLeg()),
          Positioned(bottom: 5, right: 35, child: _buildSheepLeg()),
          // Front Legs
          Positioned(bottom: 2, left: 35, child: _buildSheepLeg()),
          Positioned(bottom: 2, right: 25, child: _buildSheepLeg()),

          // Fluffy Wool Body (Layered white circles)
          Positioned(top: 15, left: 10, child: _buildWoolPuff(45, 45)),
          Positioned(top: 10, left: 30, child: _buildWoolPuff(50, 50)),
          Positioned(top: 18, right: 15, child: _buildWoolPuff(45, 45)),
          Positioned(bottom: 12, left: 15, child: _buildWoolPuff(40, 40)),
          Positioned(bottom: 10, left: 40, child: _buildWoolPuff(45, 40)),

          // Sheep Head
          Positioned(
            right: 0,
            top: 25,
            child: Container(
              width: 38,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Almost black
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(-2, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Floppy Ears
                  Positioned(
                    left: -5,
                    top: 10,
                    child: Transform.rotate(
                      angle: -0.4,
                      child: Container(
                        width: 14,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -5,
                    top: 10,
                    child: Transform.rotate(
                      angle: 0.4,
                      child: Container(
                        width: 14,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Eyes
                  Positioned(left: 8, top: 8, child: _buildSheepEye()),
                  Positioned(right: 8, top: 8, child: _buildSheepEye()),
                  // Blush (Pink cheeks)
                  Positioned(left: 3, top: 18, child: _buildSheepBlush()),
                  Positioned(right: 3, top: 18, child: _buildSheepBlush()),
                ],
              ),
            ),
          ),

          // Top Head Wool Puff
          Positioned(right: 5, top: 15, child: _buildWoolPuff(28, 22)),
        ],
      ),
    );
  }

  Widget _buildSheepLeg() {
    return Container(
      width: 6,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildWoolPuff(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(-2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSheepEye() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1.0),
        child: Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSheepBlush() {
    return Container(
      width: 8,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.pink[300],
        shape: BoxShape.circle,
      ),
    );
  }

  // Helper widget to construct the Realistic Mannequin parts with 3D gradients
  Widget _buildMannequinPart(
    double w,
    double h, {
    double borderRadius = 0,
    bool isDark = false,
  }) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF64748B),
                  const Color(0xFF334155),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFF1F5F9),
                  const Color(0xFF94A3B8),
                  const Color(0xFF475569),
                ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4,
            offset: Offset(-2, 3),
          ),
        ],
      ),
    );
  }

  // Helper to assemble the full realistic human mannequin
  Widget _buildRealisticHuman(double w, double h) {
    return Positioned(
      left: w / 2 - 200,
      top: h / 2 - 200,
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Head
            Positioned(
              top: 20,
              left: 175,
              child: _buildMannequinPart(50, 65, borderRadius: 30),
            ),
            // Neck
            Positioned(
              top: 80,
              left: 190,
              child: _buildMannequinPart(
                20,
                25,
                borderRadius: 10,
                isDark: true,
              ),
            ),
            // Abdomen (dark lower torso) - drawn before chest so chest overlaps
            Positioned(
              top: 155,
              left: 175,
              child: _buildMannequinPart(
                50,
                45,
                borderRadius: 25,
                isDark: true,
              ),
            ),
            // Chest
            Positioned(
              top: 95,
              left: 145,
              child: _buildMannequinPart(110, 70, borderRadius: 35),
            ),
            // Pelvis
            Positioned(
              top: 190,
              left: 155,
              child: _buildMannequinPart(90, 55, borderRadius: 30),
            ),

            // LEFT ARM
            Positioned(
              top: 100,
              left: 110,
              child: _buildMannequinPart(45, 45, borderRadius: 25),
            ), // Shoulder
            Positioned(
              top: 110,
              left: 40,
              child: _buildMannequinPart(80, 25, borderRadius: 12),
            ), // Upper
            Positioned(
              top: 112,
              left: -25,
              child: _buildMannequinPart(70, 20, borderRadius: 10),
            ), // Forearm
            Positioned(
              top: 113,
              left: -45,
              child: _buildMannequinPart(25, 18, borderRadius: 10),
            ), // Hand
            // RIGHT ARM
            Positioned(
              top: 100,
              left: 245,
              child: _buildMannequinPart(45, 45, borderRadius: 25),
            ), // Shoulder
            Positioned(
              top: 110,
              left: 280,
              child: _buildMannequinPart(80, 25, borderRadius: 12),
            ), // Upper
            Positioned(
              top: 112,
              left: 355,
              child: _buildMannequinPart(70, 20, borderRadius: 10),
            ), // Forearm
            Positioned(
              top: 113,
              left: 420,
              child: _buildMannequinPart(25, 18, borderRadius: 10),
            ), // Hand
            // LEFT LEG
            Positioned(
              top: 235,
              left: 160,
              child: _buildMannequinPart(35, 90, borderRadius: 18),
            ), // Thigh
            Positioned(
              top: 315,
              left: 165,
              child: _buildMannequinPart(
                25,
                25,
                borderRadius: 15,
                isDark: true,
              ),
            ), // Knee
            Positioned(
              top: 335,
              left: 165,
              child: _buildMannequinPart(25, 85, borderRadius: 15),
            ), // Calf
            // RIGHT LEG
            Positioned(
              top: 235,
              left: 205,
              child: _buildMannequinPart(35, 90, borderRadius: 18),
            ), // Thigh
            Positioned(
              top: 315,
              left: 210,
              child: _buildMannequinPart(
                25,
                25,
                borderRadius: 15,
                isDark: true,
              ),
            ), // Knee
            Positioned(
              top: 335,
              left: 210,
              child: _buildMannequinPart(25, 85, borderRadius: 15),
            ), // Calf
          ],
        ),
      ),
    );
  }

  // --- NATIVE INTERACTIVE CANVAS BUILDER ---
  Widget _buildInteractiveSceneBase(double w, double h) {
    switch (currentStep) {
      case 1: // Shepherd
        return Container(
          color: const Color(0xFF0F172A), // Deep dark blue background
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The Green Pasture (Curved horizon using wide stretched circular container)
              Positioned(
                left: -w * 0.2,
                right: -w * 0.2,
                bottom: -h * 0.2,
                height: h * 1.1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFF5EEAD4,
                    ), // Bright minty green like the image
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // The Fence Shadow
              Positioned(
                left: w * 0.45 - 20,
                top: h * 0.25,
                bottom: h * 0.2,
                child: Transform(
                  transform: Matrix4.skewY(-0.3),
                  child: Container(
                    width: 25,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ),
              ),

              // The Fence Post (Vertical divider)
              Positioned(
                left: w * 0.45,
                top: h * 0.15,
                bottom: h * 0.2,
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.brown[500],
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown[800]!,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                ),
              ),

              // Pouch / Bucket (Perspective styled, Bottom Left)
              Positioned(
                bottom: h * 0.15,
                left: w * 0.08,
                child: SizedBox(
                  width: 120,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Bucket shadow on ground
                      Positioned(
                        bottom: -10,
                        left: -5,
                        child: Container(
                          width: 110,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      // Bucket main body
                      Positioned(
                        top: 20,
                        child: Container(
                          width: 100,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.brown[600],
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.elliptical(50, 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(-8, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Metal Rings on the body
                      Positioned(
                        top: 40,
                        child: Container(
                          width: 104,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black87, width: 1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        child: Container(
                          width: 90,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black87, width: 1),
                          ),
                        ),
                      ),
                      // Top Rim Opening
                      Container(
                        width: 115,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.brown[900], // Dark deep inside
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: Colors.brown[500]!,
                            width: 4,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: List.generate(
                              currentHits,
                              (i) => Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black87,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sheep Interactive Elements
              ...List.generate(3, (i) {
                // Arranged diagonally in the left pen
                double penX = w * 0.15 + (i * 25);
                double penY = h * 0.2 + (i * 45);

                // Scattered in the right pasture
                double pastureX = w * 0.55 + (i * 50);
                double pastureY = h * 0.35 + (i % 2 == 0 ? 30 : -10);

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  left: sheepInPasture[i] ? pastureX : penX,
                  top: sheepInPasture[i] ? pastureY : penY,
                  child: GestureDetector(
                    onTap: () {
                      if (!sheepInPasture[i]) {
                        HapticFeedback.selectionClick();
                        _playSound('tap');
                        setState(() {
                          sheepInPasture[i] = true;
                          currentHits++;
                          _checkValidation();
                        });
                      }
                    },
                    child: _buildRealisticSheep(),
                  ),
                );
              }),
            ],
          ),
        );

      case 2: // Body Parts
        List<Offset> bodyNodes = [
          Offset(w / 2 + 210, h / 2 - 93), // Hand
          Offset(w / 2 + 160, h / 2 - 93), // Wrist
          Offset(w / 2 + 105, h / 2 - 93), // Elbow
        ];
        // Removed the hardcoded background color and green floor here
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Shadow mapping the realistic human figure
            Positioned(
              left: w / 2 - 320,
              top: h / 2 + 100,
              child: Transform(
                transform: Matrix4.skewX(1.5)..rotateZ(-0.05),
                child: Container(
                  width: 350,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),

            // Render Custom Realistic 3D Mannequin
            _buildRealisticHuman(w, h),

            // Glowing Interactive Yellow Nodes
            ...List.generate(3, (i) {
              bool isActive = i == currentHits;
              bool isDone = i < currentHits;
              return Positioned(
                left: bodyNodes[i].dx,
                top: bodyNodes[i].dy,
                child: GestureDetector(
                  onTap: () {
                    if (isActive) {
                      HapticFeedback.lightImpact();
                      _playSound('tap');
                      setState(() {
                        currentHits++;
                        _checkValidation();
                      });
                    } else if (!isDone) {
                      HapticFeedback.vibrate();
                      _playSound('error');
                      _showAlert(
                        "Error",
                        "Tap them in order! Hand -> Wrist -> Elbow.",
                      );
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? Colors.greenAccent
                          : (isActive ? Colors.yellowAccent : Colors.white24),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.yellowAccent,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      case 3: // Stick Math
        if (!sticksMultiplied && scatteredSticks.isEmpty) {
          final random = Random();
          for (int i = 0; i < 12; i++) {
            scatteredSticks.add(
              Offset(
                (w / 2 - 100) + random.nextDouble() * 200,
                (h / 2) + random.nextDouble() * 100,
              ),
            );
          }
        }

        return Stack(
          children: [
            if (!sticksMultiplied) ...[
              // Group 1
              Positioned(
                left: w * 0.3,
                top: h / 2 - 50,
                child: Row(
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.all(4),
                      width: 10,
                      height: 80,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              // Group 2
              Positioned(
                right: w * 0.3,
                top: h / 2 - 50,
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Container(
                      margin: const EdgeInsets.all(4),
                      width: 10,
                      height: 80,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              // Multi Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _playSound('tap');
                    setState(() {
                      sticksMultiplied = true;
                      currentHits = 1;
                      _checkValidation();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      i18n[currentLang]!['textMultiply'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Scattered
              ...List.generate(
                12,
                (i) => Positioned(
                  left: scatteredSticks[i].dx,
                  top: scatteredSticks[i].dy,
                  child: Transform.rotate(
                    angle: i * 0.5,
                    child: Container(
                      width: 10,
                      height: 80,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );

      case 4:
      case 5: // Gumulgal Words & Arithmetic
        return Stack(
          children: [
            // Build Area display (Dynamically sized container instead of fixed 300 width)
            Positioned(
              top: h * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 100,
                  constraints: const BoxConstraints(minWidth: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: glassBorder),
                  ),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Dynamically fits content width
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: addedBlocks
                          .map((val) => _buildGumulgalBlock(val, false))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Interactive Blocks (Bottom)
            Positioned(
              bottom: h * 0.2,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _handleGumulgalTap(2),
                    child: _buildGumulgalBlock(2, true),
                  ),
                  GestureDetector(
                    onTap: () => _handleGumulgalTap(1),
                    child: _buildGumulgalBlock(1, true),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  void _handleGumulgalTap(int val) {
    if (currentStep == 4) {
      // Step 4 Constraint: Only allow adding each block exactly once
      if (addedBlocks.contains(val)) {
        HapticFeedback.vibrate();
        _playSound('error');
        return; // Reject if already added
      }

      // Existing Step 4 Constraint: Must start with Ukasar (2)
      if (currentHits == 0 && val != 2) {
        HapticFeedback.vibrate();
        _playSound('error');
        _showAlert("Hint", i18n[currentLang]!['hintUkasar']);
        return;
      }
    }

    if (currentStep == 5 &&
        (currentHits == 0 || currentHits == 1) &&
        val != 2) {
      HapticFeedback.vibrate();
      _playSound('error');
      _showAlert("Hint", i18n[currentLang]!['hintUkasarFirst']);
      return;
    }

    HapticFeedback.lightImpact();
    _playSound('tap');
    setState(() {
      addedBlocks.add(val);
      currentSum += val;
      currentHits++;
      _checkValidation();
    });
  }

  Widget _buildGumulgalBlock(int val, bool isInteractive) {
    bool isUkasar = val == 2;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isUkasar ? Colors.blueAccent : Colors.greenAccent[700],
        borderRadius: BorderRadius.circular(8),
        boxShadow: isInteractive
            ? [
                BoxShadow(
                  color: (isUkasar ? Colors.blue : Colors.green).withOpacity(
                    0.5,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Text(
        isUkasar
            ? i18n[currentLang]!['textUkasar']
            : i18n[currentLang]!['textUrapon'],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
