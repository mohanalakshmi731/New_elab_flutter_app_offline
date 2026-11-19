// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExponentialGrowthLab());
}

// Custom Scroll Behavior to ensure Mouse and Trackpad dragging works smoothly
class CanvasScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class ExponentialGrowthLab extends StatefulWidget {
  const ExponentialGrowthLab({Key? key}) : super(key: key);

  @override
  State<ExponentialGrowthLab> createState() => _ExponentialGrowthLabState();
}

class _ExponentialGrowthLabState extends State<ExponentialGrowthLab>
    with TickerProviderStateMixin {
  // App State
  String currentLang = 'en';
  int currentScenario = 0;
  bool showCurtain = true;
  bool leftSidebarOpen = true;

  // Audio System - Initialized securely to prevent memory leaks
  final AudioPlayer _audioPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Feedback State
  bool showFeedback = false;
  String feedbackText = "";
  bool isFeedbackError = false;
  bool isValidationSuccess = false;

  // --- Scenario 0: Paper Fold ---
  int s0Folds = 0;

  // --- Scenario 1: Add vs Mult ---
  int s1AddCount = 0;
  int s1MultCount = 0;

  // --- Scenario 2: Notation ---
  final TextEditingController _baseController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  bool s2Condensed = false;

  // --- Scenario 3: 30 Folds ---
  double s3SliderVal = 0;

  // --- Scenario 4: Prime Factors ---
  bool s4Factorized = false;
  String s4SelectedFactor = "";

  // --- Localization Dictionary ---
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'title': "Exponential Growth & Notation",
      'subtitle': "Class 8 • Power Play",
      'validate': "Validate Investigation",
      'scenarios': [
        "1. The Impossible Paper Fold",
        "2. Additive vs Multiplicative",
        "3. Exponential Notation",
        "4. The 30 Folds Challenge",
        "5. Prime Factorization",
      ],
      'theory': [
        "<b>Mission Objective</b>\nUnderstand exponential growth through folding paper.\n\nImagine a sheet of paper. It is about 0.001 cm thick. If you fold it in half, it becomes twice (2×) as thick.\n\n<b>Procedural Steps</b>\n• Use the controls below to fold the paper.\n• Observe how the thickness increases.\n• Fold the paper 7 times to unlock validation.",
        "<b>Mission Objective</b>\nCompare linear (additive) growth to exponential (multiplicative) growth.\n\nAdding a constant amount (+1) is slow. Doubling (×2) creates massive growth quickly.\n\n<b>Procedural Steps</b>\n• Add +1 to Stack A 5 times.\n• Multiply Stack B by ×2, 5 times.\n• Observe the drastic difference in height.",
        "<b>Mission Objective</b>\nLearn to write repeated multiplication efficiently.\n\nWriting 2 × 2 × 2 ... 10 times is tedious. We use a <b>Base</b> and an <b>Exponent</b>: 2¹⁰.\n\n<b>Procedural Steps</b>\n• Look at the sequence of 2s on the board.\n• Select the correct Base and Exponent in the controls to match the 10 terms.",
        "<b>Mission Objective</b>\nCalculate extreme heights using powers of 2.\n\nWhat happens at 30 folds? The thickness is 2³⁰ × 0.001 cm. That's over 10 km!\n\n<b>Procedural Steps</b>\n• Use the slider to fold the paper 30 times.\n• Compare its height to the Burj Khalifa and Mariana Trench.",
        "<b>Mission Objective</b>\nExpress large numbers as products of prime factors using exponents.\n\nLet's factorize 32400. Breaking it down, we get: 2 × 2 × 2 × 2 × 3 × 3 × 3 × 3 × 5 × 5.\n\n<b>Procedural Steps</b>\n• Click 'Factorize' to break down 32400.\n• Group the identical prime factors.\n• Select the correct exponential equation.",
      ],
      'msgs': {
        'inst0': "Click 'Fold Paper' to double its thickness. Reach 7 folds.",
        'btnFold': "Fold Paper",
        'errFold':
            "Notice: It's physically impossible to fold a standard sheet of paper more than 7 times!",
        'inst1': "Click Add to Stack A and Multiply Stack B 5 times each.",
        'btnAdd': "Stack A: Add +1",
        'btnMult': "Stack B: Multiply ×2",
        'inst2': "Enter the correct Base and Exponent, then click 'Condense'.",
        'btnCondense': "Condense Equation",
        'errCondense1': "Error: Please enter both the Base and Exponent!",
        'errCondense2':
            "Error: Incorrect. We are multiplying the number 2 by itself 10 times!",
        'inst3': "Drag the slider to fold the paper 30 times.",
        'inst4': "Click factorize, then choose the correct exponential form.",
        'btnFactorize': "Factorize 32400",
        'valSuccess':
            "Correct! Great job. You've completed this step successfully.",
        'valFail': "Not quite yet. Check the instructions and try again.",
        'labDone': "Lab Completed!",
        'mission': "Current Mission",
      },
    },
    'hi': {
      'title': "घातीय वृद्धि और संकेतन",
      'subtitle': "कक्षा 8 • पावर प्ले",
      'validate': "सत्यापित करें",
      'scenarios': [
        "1. असंभव कागज मोड़",
        "2. योगात्मक बनाम गुणात्मक",
        "3. घातांकीय संकेतन",
        "4. 30 मोड़ों की चुनौती",
        "5. अभाज्य गुणनखंडन",
      ],
      'theory': [
        "<b>मिशन उद्देश्य</b>\nकागज मोड़ने के माध्यम से घातांकीय वृद्धि को समझें।\n\nकागज की एक शीट की कल्पना करें। यह लगभग 0.001 cm मोटी है। यदि आप इसे आधा मोड़ते हैं, तो यह दोगुनी (2×) मोटी हो जाती है।\n\n<b>प्रक्रियात्मक कदम</b>\n• कागज मोड़ने के लिए नीचे दिए गए नियंत्रणों का उपयोग करें।\n• देखें कि मोटाई कैसे बढ़ती ক্ষমতায় है।\n• सत्यापन अनलॉक करने के लिए कागज को 7 बार मोड़ें।",
        "<b>मिशन उद्देश्य</b>\nरैखिक (योगात्मक) वृद्धि की तुलना घातांकीय (गुणात्मक) वृद्धि से करें।\n\nएक स्थिर राशि (+1) जोड़ना धीमा है। दोगुना करना (×2) तेजी से भारी वृद्धि पैदा करता है।\n\n<b>प्रक्रियात्मक कदम</b>\n• स्टैक A में 5 बार +1 जोड़ें।\n• स्टैक B को ×2 से, 5 बार गुणा करें।\n• ऊंचाई में भारी अंतर देखें।",
        "<b>मिशन उद्देश्य</b>\nबार-बार होने वाले गुणन को कुशलता से लिखना सीखें।\n\n2 × 2 × 2 ... को 10 बार लिखना थकाऊ है। हम एक <b>आधार (Base)</b> और एक <b>घातांक (Exponent)</b> का उपयोग करते हैं: 2¹⁰।\n\n<b>प्रक्रियात्मक कदम</b>\n• बोर्ड पर 2 के अनुक्रम को देखें।\n• 10 पदों से मेल खाने के लिए नियंत्रणों में सही आधार और घातांक दर्ज करें।",
        "<b>मिशन उद्देश्य</b>\n2 की घातों का उपयोग करके चरम ऊंचाइयों की गणना करें।\n\n30 मोड़ों पर क्या होता है? मोटाई 2³⁰ × 0.001 cm है। यह 10 km से अधिक है!\n\n<b>प्रक्रियात्मक कदम</b>\n• कागज को 30 बार मोड़ने के लिए स्लाइडर का उपयोग करें।\n• इसकी ऊंचाई की तुलना बुर्ज खलीफा और मारियाना ट्रेंच से करें।",
        "<b>मिशन उद्देश्य</b>\nबड़ी संख्याओं को घातांकों का उपयोग करके अभाज्य गुणनखंडों के गुणनफल के रूप में व्यक्त करें।\n\nआइए 32400 का गुणनखंड करें। इसे तोड़ने पर, हमें प्राप्त होता है: 2 × 2 × 2 × 2 × 3 × 3 × 3 × 3 × 5 × 5।\n\n<b>प्रक्रियात्मक कदम</b>\n• 32400 को तोड़ने के लिए 'गुणनखंड करें' पर क्लिक करें।\n• समान अभाज्य गुणनखंडों का समूह बनाएं।\n• सही घातांकीय समीकरण चुनें।",
      ],
      'msgs': {
        'inst0': "कागज मोड़ने के लिए क्लिक करें। 7 मोड़ों तक पहुँचें।",
        'btnFold': "कागज मोड़ें",
        'errFold':
            "सूचना: एक मानक कागज की शीट को 7 बार से अधिक मोड़ना भौतिक रूप से असंभव है!",
        'inst1':
            "स्टैक A में जोड़ें और स्टैक B को 5 बार गुणा करें पर क्लिक करें।",
        'btnAdd': "स्टैक A: +1 जोड़ें",
        'btnMult': "स्टैक B: ×2 गुणा करें",
        'inst2':
            "सही आधार और घातांक दर्ज करें, फिर 'संघनित करें' पर क्लिक करें।",
        'btnCondense': "समीकरण संघनित करें",
        'errCondense1': "त्रुटि: कृपया आधार और घातांक दोनों दर्ज करें!",
        'errCondense2':
            "त्रुटि: गलत। हम संख्या 2 को उसी से 10 बार गुणा कर रहे हैं!",
        'inst3': "कागज को 30 बार मोड़ने के लिए स्लाइडर खींचें।",
        'inst4': "गुणनखंड पर क्लिक करें, फिर सही घातांकीय रूप चुनें।",
        'btnFactorize': "32400 का गुणनखंड करें",
        'valSuccess':
            "सही! बहुत बढ़िया। आपने इस चरण को सफलतापूर्वक पूरा कर लिया है।",
        'valFail': "अभी नहीं। निर्देशों की जाँच करें और पुनः प्रयास करें।",
        'labDone': "लैब पूरी हुई!",
        'mission': "वर्तमान मिशन",
      },
    },
  };

  // Type-safe Translation Helpers
  String t(String key) => (i18n[currentLang]?[key] ?? key).toString();
  String tMsg(String key) =>
      (i18n[currentLang]?['msgs']?[key] ?? key).toString();

  String tScenario(int index) {
    final list = i18n[currentLang]?['scenarios'] as List?;
    return (list != null && index >= 0 && index < list.length)
        ? list[index].toString()
        : '';
  }

  String tTheory(int index) {
    final list = i18n[currentLang]?['theory'] as List?;
    return (list != null && index >= 0 && index < list.length)
        ? list[index].toString()
        : '';
  }

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
    _baseController.dispose();
    _expController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- Audio System ---
  Future<void> _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'click':
        url =
            'audio/class8/mixkit_2568.mp3';
        break;
      case 'success':
        url =
            'audio/class8/mixkit_2013.mp3';
        break;
      case 'error':
        url =
            'audio/class8/mixkit_2954.mp3';
        break;
      case 'slide':
        url =
            'audio/class8/mixkit_2568.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.stop();
        }
        await _audioPlayer.play(
          AssetSource(url),
        ); // Removed deprecated PlayerMode.lowLatency
      } catch (e) {
        debugPrint("Audio play failed: $e");
      }
    }
  }

  void _loadScenario(int index) {
    _playSound('click');
    setState(() {
      currentScenario = index;
      showFeedback = false;
      isValidationSuccess = false;

      // Reset Scenario States
      s0Folds = 0;
      s1AddCount = 0;
      s1MultCount = 0;
      _baseController.clear();
      _expController.clear();
      s2Condensed = false;
      s3SliderVal = 0;
      s4Factorized = false;
      s4SelectedFactor = "";
    });
  }

  void _showFeedbackMsg(String msg, bool isError) {
    setState(() {
      showFeedback = true;
      feedbackText = msg;
      isFeedbackError = isError;
    });
    if (isError) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => showFeedback = false);
      });
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1e293b),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Icon(Icons.stars, color: Colors.amber, size: 60),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        currentScenario == 4 ? tMsg('labDone') : t('validate'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tMsg('valSuccess'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _playSound('click');
                    Navigator.of(ctx).pop();
                    if (currentScenario < 4) {
                      _loadScenario(currentScenario + 1);
                    }
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateInvestigation() {
    bool passed = false;

    switch (currentScenario) {
      case 0:
        passed = s0Folds >= 7;
        break;
      case 1:
        passed = s1AddCount >= 5 && s1MultCount >= 5;
        break;
      case 2:
        passed =
            _baseController.text.trim() == "2" &&
            _expController.text.trim() == "10";
        break;
      case 3:
        passed = s3SliderVal == 30;
        break;
      case 4:
        passed = s4SelectedFactor == 'correct';
        break;
    }

    if (passed) {
      _playSound('success');
      setState(() => isValidationSuccess = true);
      _showSuccessPopup();
    } else {
      _playSound('error');
      _showFeedbackMsg(tMsg('valFail'), true);
    }
  }

  // --- Scenario Specific Actions ---
  void _actionFold() {
    if (s0Folds >= 7) {
      _playSound('error');
      _showFeedbackMsg(tMsg('errFold'), true);
      return;
    }
    _playSound('click');
    setState(() => s0Folds++);
  }

  void _actionCondense() {
    if (_baseController.text.trim() != "2" ||
        _expController.text.trim() != "10") {
      _playSound('error');
      if (_baseController.text.trim().isEmpty ||
          _expController.text.trim().isEmpty) {
        _showFeedbackMsg(tMsg('errCondense1'), true);
      } else {
        _showFeedbackMsg(tMsg('errCondense2'), true);
      }
      return;
    }
    _playSound('success');
    setState(() {
      s2Condensed = true;
      showFeedback = false;
    });
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = math.max(300.0, screenWidth * 0.30); // 30% of screen

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Background Elements
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [Color(0xFF0f172a), Color(0xFF020617)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // Zoomable Canvas Area (Responsive Center Activity)
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.2,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                panEnabled: true,
                scaleEnabled: true,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      width: 1000,
                      height: 700,
                      color: Colors.black.withOpacity(
                        0.001,
                      ), // CRITICAL: Catch hit-tests for zooming and panning
                      child: Center(child: _buildCanvasArea()),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Mission Card (Visible when sidebar is closed)
            if (!showCurtain)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 70,
                left: leftSidebarOpen ? -300 : 16,
                child: IgnorePointer(
                  ignoring: leftSidebarOpen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: leftSidebarOpen ? 0.0 : 1.0,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10,
                      child: _buildFloatingMissionCard(),
                    ),
                  ),
                ),
              ),

            // Sliding Left Sidebar (Z-Index Front)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: leftSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Material(
                elevation: 20,
                color: const Color(0xFF0f172a).withOpacity(0.95),
                child: _buildLeftSidebar(),
              ),
            ),

            // Fixed Top-Left Menu Toggle Button
            if (!showCurtain) // CRITICAL: Wait for splash screen to hide before showing menu icon
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(
                    leftSidebarOpen ? Icons.menu_open : Icons.menu,
                    size: 28,
                  ),
                  color: Colors.amber,
                  onPressed: () {
                    _playSound('click');
                    setState(() => leftSidebarOpen = !leftSidebarOpen);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),

            // Curtain Raiser
            if (showCurtain) _buildCurtainRaiser(),
          ],
        ),
      ),
    );
  }

  // --- Scrollable Left Sidebar ---
  Widget _buildLeftSidebar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sidebar Header (added left padding to avoid fixed menu icon)
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 70,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.hub, color: Colors.amberAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          t('subtitle'),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Language Toggle & Reset Control (Moved below title)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['en', 'hi'].map((lang) {
                        bool isActive = currentLang == lang;
                        return GestureDetector(
                          onTap: () {
                            _playSound('click');
                            setState(() => currentLang = lang);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.pinkAccent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              lang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : Colors.white54,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1e293b).withOpacity(0.8),
                    ),
                    onPressed: () => _loadScenario(0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    dropdownColor: const Color(0xFF1e293b),
                    isExpanded: true,
                    value: currentScenario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    items: List.generate(5, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text(tScenario(index)),
                      );
                    }),
                    onChanged: (v) {
                      if (v != null) _loadScenario(v);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Theory Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  children: _parseHtmlToSpans(tTheory(currentScenario)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24),
            ),
            const SizedBox(height: 16),

            // Controls Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSidebarControls(),
            ),

            const SizedBox(height: 30),

            // Validate Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildValidateButton(),
            ),

            const SizedBox(height: 30),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black26,
              width: double.infinity,
              child: const Text(
                "© ZeroScienceLab - Fall in love with math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Floating Mission Card ---
  Widget _buildFloatingMissionCard() {
    return Container(
      width: 280,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 80,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  tMsg('mission'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            _buildSidebarControls(),

            const SizedBox(height: 20),
            _buildValidateButton(),
          ],
        ),
      ),
    );
  }

  // --- Reusable Validate Button ---
  Widget _buildValidateButton() {
    return ElevatedButton.icon(
      icon: Icon(
        isValidationSuccess
            ? Icons.check_circle
            : (currentScenario == 4 && isValidationSuccess
                  ? Icons.star
                  : Icons.check_circle_outline),
      ),
      label: Text(
        isValidationSuccess
            ? (currentScenario == 4 ? tMsg('labDone') : "Proceeding...")
            : t('validate'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isValidationSuccess
            ? Colors.green.shade500
            : Colors.amber.shade500,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _validateInvestigation,
    );
  }

  // --- Dynamic Controls ---
  Widget _buildSidebarControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tMsg('inst$currentScenario'),
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        if (currentScenario == 0)
          ElevatedButton.icon(
            icon: const Icon(Icons.unfold_more),
            label: Text("${tMsg('btnFold')} ($s0Folds)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _actionFold,
          ),

        if (currentScenario == 1)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  _playSound('click');
                  if (s1AddCount < 5) setState(() => s1AddCount++);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("${tMsg('btnAdd')} ($s1AddCount)"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _playSound('click');
                  if (s1MultCount < 5) setState(() => s1MultCount++);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("${tMsg('btnMult')} ($s1MultCount)"),
              ),
            ],
          ),

        if (currentScenario == 2)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _buildMiniInput("Base:", _baseController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMiniInput("Exp:", _expController)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_fix_high),
                label: Text(tMsg('btnCondense')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _actionCondense,
              ),
            ],
          ),

        if (currentScenario == 3)
          Column(
            children: [
              Slider(
                value: s3SliderVal,
                min: 0,
                max: 30,
                divisions: 30,
                activeColor: Colors.amber,
                inactiveColor: Colors.blueGrey,
                onChangeStart: (_) => _playSound('slide'),
                onChanged: (v) => setState(() => s3SliderVal = v),
              ),
              Text(
                "${s3SliderVal.toInt()} Folds",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

        if (currentScenario == 4)
          !s4Factorized
              ? ElevatedButton(
                  onPressed: () {
                    _playSound('success');
                    setState(() => s4Factorized = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(tMsg('btnFactorize')),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFactorChoice("wrong", "2³ × 3⁵ × 5²"),
                    const SizedBox(height: 12),
                    _buildFactorChoice("correct", "2⁴ × 3⁴ × 5²"),
                  ],
                ),

        // Inline Feedback Message
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showFeedback ? 40 : 0,
          margin: EdgeInsets.only(top: showFeedback ? 16 : 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: showFeedback
                ? (isFeedbackError
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showFeedback
                  ? (isFeedbackError ? Colors.redAccent : Colors.greenAccent)
                  : Colors.transparent,
            ),
          ),
          child: showFeedback
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    feedbackText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isFeedbackError
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMiniInput(String label, TextEditingController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 35,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() => showFeedback = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorChoice(String value, String text) {
    bool isSelected = s4SelectedFactor == value;
    return InkWell(
      onTap: () {
        _playSound('click');
        setState(() => s4SelectedFactor = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black45,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white24,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.amber : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Visualizations (Canvas Area) ---
  Widget _buildCanvasArea() {
    return Builder(
      builder: (context) {
        // Scenario 0: Paper Fold
        if (currentScenario == 0) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Text(
                  "Thickness: ${math.pow(2, s0Folds)} Layers",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3D View
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Top/3D View",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 350,
                        height: 250,
                        child: Center(
                          child: RealisticPaperFold(folds: s0Folds),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 60),
                  // Side View (Cross Section)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Side Profile (Fold Lines)",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 150,
                        height: 250,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PaperCrossSection(folds: s0Folds),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }

        // Scenario 1: Additive vs Multiplicative
        if (currentScenario == 1) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Stack A
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Height: ${1 + s1AddCount}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    height:
                        20.0 +
                        (s1AddCount * 20.0)
                            .toDouble(), // Explicit Double conversion
                    decoration: BoxDecoration(
                      color: Colors.blue.shade500,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Stack A",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(width: 120),
              // Stack B
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Height: ${math.pow(2, s1MultCount)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    height:
                        20.0 *
                        math
                            .pow(1.5, s1MultCount)
                            .toDouble(), // Explicit Double conversion
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Stack B",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          );
        }

        // Scenario 2: Exponential Notation
        if (currentScenario == 2) {
          return s2Condensed
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade900,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.purpleAccent,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.5),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "2",
                                  style: TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  "10",
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "EXPONENTIAL FORM",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(19, (index) {
                      if (index % 2 == 0) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "2",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else {
                        return const Text(
                          "×",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    }),
                  ),
                );
        }

        // Scenario 3: 30 Folds Challenge
        if (currentScenario == 3) {
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    // CRITICAL FIX: Explicit typing ensures double parameters are strictly enforced to prevent Dart compilation crashes!
                    width: math.max<double>(10.0, 100.0 - (s3SliderVal * 2.5)),
                    height:
                        (math.pow(s3SliderVal / 30.0, 3) * 450.0).toDouble() +
                        10.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: Colors.amber, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Thickness: ${s3SliderVal == 0
                          ? '0.001 cm'
                          : math.pow(2, s3SliderVal) * 0.001 > 100000
                          ? '${((math.pow(2, s3SliderVal) * 0.001) / 100000).toStringAsFixed(2)} km'
                          : '${((math.pow(2, s3SliderVal) * 0.001) / 100).toStringAsFixed(2)} m'}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Markers
                if (math.pow(2, s3SliderVal) * 0.001 >= 80000)
                  Positioned(
                    bottom: 120,
                    left: 100,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Burj Khalifa (~0.8km)",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 2,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                if (s3SliderVal == 30)
                  Positioned(
                    bottom: 350,
                    right: 100,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 2,
                          color: Colors.redAccent,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Mariana Trench (~11km)",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }

        // Scenario 4: Prime Factorization
        if (currentScenario == 4) {
          return !s4Factorized
              ? Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.shade600,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: const Text(
                    "32400",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [2, 2, 2, 2, 3, 3, 3, 3, 5, 5].map((f) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, val, child) {
                          return Transform.scale(
                            scale: val,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: f == 2
                                    ? Colors.blue
                                    : (f == 3 ? Colors.red : Colors.green),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (f == 2
                                                ? Colors.blue
                                                : (f == 3
                                                      ? Colors.red
                                                      : Colors.green))
                                            .withOpacity(0.5),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                f.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // --- Curtain Raiser (Splash) ---
  Widget _buildCurtainRaiser() {
    return AnimatedOpacity(
      opacity: showCurtain ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      onEnd: () {
        if (!showCurtain) setState(() {});
      },
      child: Container(
        color: const Color(0xFF020617),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hub, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            Text(
              t('subtitle').toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t('title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: Text(
                tMsg('btnFold') == "Fold Paper"
                    ? "Enter Lab"
                    : "लैब में प्रवेश करें",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _playSound('success');
                setState(() => showCurtain = false);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper: Parse basic HTML for RichText ---
  List<TextSpan> _parseHtmlToSpans(String text) {
    List<TextSpan> spans = [];
    final boldRegex = RegExp(r'<b>(.*?)</b>', dotAll: true);
    int lastMatchEnd = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return spans;
  }
}

// --- Side View Cross Section Painter ---
class PaperCrossSection extends StatelessWidget {
  final int folds;
  const PaperCrossSection({super.key, required this.folds});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: math.max(0, folds - 1).toDouble(),
        end: folds.toDouble(),
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      builder: (context, val, child) {
        return CustomPaint(
          painter: CrossSectionPainter(val),
          size: const Size(double.infinity, double.infinity),
        );
      },
    );
  }
}

class CrossSectionPainter extends CustomPainter {
  final double progress;
  CrossSectionPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    int baseFolds = progress.floor();
    double fraction = progress - baseFolds;

    // To represent fold dynamically, visually double the lines past fraction 0.5
    int discreteLayers = math
        .pow(2, baseFolds + (fraction > 0.5 ? 1 : 0))
        .toInt();

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = math
          .max(1.0, 5.0 - (progress * 0.6)) // Lines compress dynamically
      ..strokeJoin = StrokeJoin.round;

    double layerGap = (size.height - 20) / math.max(1, discreteLayers);
    double actualHeight = (discreteLayers - 1) * layerGap;
    double startY = (size.height - actualHeight) / 2;

    Path path = Path();
    for (int i = 0; i < discreteLayers; i++) {
      double y = startY + (i * layerGap);

      if (i == 0) {
        path.moveTo(10, y);
        path.lineTo(size.width - 10, y);
      } else {
        bool rightSide = (i % 2 != 0);
        if (rightSide) {
          path.arcToPoint(
            Offset(size.width - 10, y),
            radius: Radius.circular(layerGap / 2),
            clockwise: true,
          );
          path.lineTo(10, y);
        } else {
          path.arcToPoint(
            Offset(10, y),
            radius: Radius.circular(layerGap / 2),
            clockwise: false,
          );
          path.lineTo(size.width - 10, y);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CrossSectionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// --- Realistic 3D Paper Fold Visualization ---
class RealisticPaperFold extends StatelessWidget {
  final int folds;
  const RealisticPaperFold({super.key, required this.folds});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: math.max(0, folds - 1).toDouble(),
        end: folds.toDouble(),
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      builder: (context, progress, child) {
        int baseFolds = progress.floor();
        double fraction = progress - baseFolds;

        if (progress == folds.toDouble() && folds > 0) {
          baseFolds = folds - 1;
          fraction = 1.0;
        }

        // True underlying physical width and height
        double w = 300.0;
        double h = 200.0;
        for (int i = 0; i < baseFolds; i++) {
          if (i % 2 == 0) {
            w /= 2;
          } else {
            h /= 2;
          }
        }

        bool isHorizontalFold = baseFolds % 2 == 0;

        // Scale factor: Keeps the paper visible on screen as it shrinks
        double scale = math.pow(1.35, baseFolds + fraction).toDouble();

        // Emphasize the exponential growth of thickness massively
        double rawThickness = math.pow(1.8, baseFolds + fraction).toDouble();
        double visualThickness = rawThickness / scale;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Mild 3D Perspective
            ..rotateX(0.4) // Tilt forward to reveal top & thickness
            ..rotateY(-0.1) // Slight pan
            ..scale(scale, scale, 1.0), // Counteract shrinkage
          child: SizedBox(
            width: w,
            height: h,
            child: isHorizontalFold
                ? _buildHorizontalFold(w, h, fraction, visualThickness)
                : _buildVerticalFold(w, h, fraction, visualThickness),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalFold(
    double w,
    double h,
    double fraction,
    double thickness,
  ) {
    return Stack(
      children: [
        // Right Static Half (Base)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: w / 2,
          child: _buildPaperLayer(thickness, isBase: true),
        ),
        // Left Folding Half (Flap)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: w / 2,
          child: Transform(
            alignment: Alignment.centerRight,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                fraction * math.pi,
              ), // Swings perfectly over to the right
            child: _buildPaperLayer(
              thickness,
              isFlap: true,
              fraction: fraction,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalFold(
    double w,
    double h,
    double fraction,
    double thickness,
  ) {
    return Stack(
      children: [
        // Bottom Static Half (Base)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: h / 2,
          child: _buildPaperLayer(thickness, isBase: true),
        ),
        // Top Folding Half (Flap)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: h / 2,
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(
                -fraction * math.pi,
              ), // Sweeps perfectly down to the bottom
            child: _buildPaperLayer(
              thickness,
              isFlap: true,
              fraction: fraction,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaperLayer(
    double thickness, {
    bool isBase = false,
    bool isFlap = false,
    double fraction = 0,
  }) {
    double flapShadow = isFlap ? math.sin(fraction * math.pi) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isFlap && fraction > 0.5
            ? Colors.grey.shade300
            : Colors.grey.shade100, // Show backside shading when flipped
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: math.max(0.5, thickness),
          ),
          right: BorderSide(
            color: Colors.grey.shade400,
            width: math.max(0.5, thickness / 2),
          ),
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
          left: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        boxShadow: [
          if (flapShadow > 0.05)
            BoxShadow(
              color: Colors.black.withOpacity(0.4 * flapShadow),
              blurRadius: 15 * flapShadow,
              spreadRadius: 2 * flapShadow,
              offset: Offset(10 * flapShadow, 10 * flapShadow),
            ),
          if (isBase)
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
        ],
      ),
      child: isFlap && fraction > 0.5
          ? Container(
              color: Colors.black.withOpacity(0.05),
            ) // Subtle darkening for the back of the paper
          : null,
    );
  }
}
