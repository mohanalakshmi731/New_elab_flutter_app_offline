// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnequalRatiosLabApp());
}

class UnequalRatiosLabApp extends StatelessWidget {
  const UnequalRatiosLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sharing in Unequal Ratios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFFEAB308),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          surface: Color(0xFF0F172A),
        ),
        fontFamily: 'Roboto',
      ),
      home: const UnequalRatiosLab(),
    );
  }
}

class UnequalRatiosLab extends StatefulWidget {
  const UnequalRatiosLab({super.key});

  @override
  State<UnequalRatiosLab> createState() => _UnequalRatiosLabState();
}

class _UnequalRatiosLabState extends State<UnequalRatiosLab> {
  bool _isSidebarOpen = true;
  int _currentStep = 1;
  String _hudMessage =
      "Ready! Read the instructions and use the interactive tools.";
  bool _isHudSuccess = false;
  String _currentLang = 'EN';

  // --- Shutter State ---
  bool _shutterOpen = false;
  bool _shutterVisible = true;

  // --- Audio Players ---
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class8/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class8/mixkit_955.mp3';
  static const String _shutterUrl =
      'audio/class8/mixkit_2574.mp3';
  static const String _dropUrl =
      'audio/class8/mixkit_2869.mp3';

  // --- Step 1 State ---
  bool s1ProfitSliced = false;
  int s1AvailableChunks = 4;
  int s1PrashantiWallet = 0;
  int s1BhuvanWallet = 0;

  // --- Step 2 State ---
  final TextEditingController s2PartCtrl = TextEditingController();
  final TextEditingController s2TargetCtrl = TextEditingController();
  int s2DroppedCement = 0;

  // --- Step 3 State ---
  final TextEditingController s3ShareCtrl = TextEditingController();
  String? s3Tray2;
  String? s3Tray3;

  // --- Step 4 State ---
  bool s4Poured = false;
  final TextEditingController s4AnsBCtrl = TextEditingController();
  final TextEditingController s4AnsYCtrl = TextEditingController();

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
    s2PartCtrl.dispose();
    s2TargetCtrl.dispose();
    s3ShareCtrl.dispose();
    s4AnsBCtrl.dispose();
    s4AnsYCtrl.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    super.dispose();
  }

  void _playSound(AudioPlayer player, String url) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  String _t(String en, String hi) {
    if (_currentLang == 'HI') return hi;
    return en;
  }

  void _toggleLang() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _currentLang = _currentLang == 'EN' ? 'HI' : 'EN';
      _updateHudDefaultMessage();
    });
  }

  void _updateHudDefaultMessage() {
    if (!_isHudSuccess) {
      _hudMessage = _t(
        "Ready! Read the instructions and use the interactive tools.",
        "तैयार! निर्देश पढ़ें और इंटरैक्टिव टूल का उपयोग करें।",
      );
    }
  }

  void _resetLab() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _currentLang = 'EN';
      _currentStep = 1;
      _isHudSuccess = false;
      _shutterOpen = false;
      _shutterVisible = true;
      _isSidebarOpen = true;
      _updateHudDefaultMessage();
      _resetStepStates();
    });
  }

  void _resetStepStates() {
    s1ProfitSliced = false;
    s1AvailableChunks = 4;
    s1PrashantiWallet = 0;
    s1BhuvanWallet = 0;

    s2PartCtrl.clear();
    s2TargetCtrl.clear();
    s2DroppedCement = 0;

    s3ShareCtrl.clear();
    s3Tray2 = null;
    s3Tray3 = null;

    s4Poured = false;
    s4AnsBCtrl.clear();
    s4AnsYCtrl.clear();
  }

  void _showFeedback(bool isSuccess, String message) {
    setState(() {
      _isHudSuccess = isSuccess;
      _hudMessage = message;
    });
    if (isSuccess) {
      _playSound(_successPlayer, _successUrl);
      HapticFeedback.heavyImpact();
    } else {
      _playSound(_errorPlayer, _errorUrl);
      HapticFeedback.vibrate();
    }
  }

  void _verifyStep() {
    _playSound(_clickPlayer, _clickUrl);
    bool success = false;
    String msg = "";

    switch (_currentStep) {
      case 1:
        if (s1PrashantiWallet == 3000 && s1BhuvanWallet == 1000) {
          success = true;
          msg = _t(
            "Correct! 4000 ÷ 4 = 1000 per part. Prashanti gets 3 parts (₹3000) and Bhuvan gets 1 part (₹1000).",
            "सही! 4000 ÷ 4 = 1000 प्रति भाग। प्रशांति को 3 भाग और भुवन को 1 भाग मिलते हैं।",
          );
        } else if (s1PrashantiWallet > 0 || s1BhuvanWallet > 0) {
          msg = _t(
            "Wait! The simplified ratio is 3:1. Prashanti invested three times as much as Bhuvan.",
            "रुको! सरल अनुपात 3:1 है। प्रशांति ने भुवन से तीन गुना अधिक निवेश किया।",
          );
        } else {
          msg = _t(
            "Please complete the interactions before verifying.",
            "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।",
          );
        }
        break;
      case 2:
        if (s2PartCtrl.text.trim() == "6" &&
            s2TargetCtrl.text.trim() == "12" &&
            s2DroppedCement == 2) {
          success = true;
          msg = _t(
            "Excellent! Sand is fixed at 30kg, setting 1-part to 6kg. To get 2 parts of cement, you need 12kg total. Adding 2kg makes a 5:2 mix!",
            "उत्कृष्ट! रेत 30kg पर स्थिर है। 2 भाग सीमेंट के लिए 12kg चाहिए। 2kg अतिरिक्त जोड़ना सही है!",
          );
        } else if (s2PartCtrl.text.isNotEmpty ||
            s2TargetCtrl.text.isNotEmpty ||
            s2DroppedCement > 0) {
          msg = _t(
            "Check the math steps. If 5 parts = 30kg, what does 1 part equal? Multiply by 2 for target cement.",
            "गणित की जाँच करें। 5 भाग = 30kg, तो 1 भाग? उसे 2 से गुणा करें।",
          );
        } else {
          msg = _t(
            "Please complete the interactions before verifying.",
            "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।",
          );
        }
        break;
      case 3:
        if (s3ShareCtrl.text.trim() == "900" &&
            s3Tray2 == "1800" &&
            s3Tray3 == "2700") {
          success = true;
          msg = _t(
            "Spot on! 900 is the value of one part. 900 × 2 = 1800 and 900 × 3 = 2700. The math checks out perfectly.",
            "बिल्कुल सही! 900 एक भाग है। 900 × 2 = 1800 और 900 × 3 = 2700।",
          );
        } else if (s3ShareCtrl.text.isNotEmpty ||
            s3Tray2 != null ||
            s3Tray3 != null) {
          msg = _t(
            "Careful! Find the value of 4500 ÷ 5 first. Then multiply that answer by 2 for tray 1, and by 3 for tray 2.",
            "सावधान! पहले 4500 ÷ 5 ज्ञात करें। फिर 2 और 3 से गुणा करें।",
          );
        } else {
          msg = _t(
            "Please complete the interactions before verifying.",
            "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।",
          );
        }
        break;
      case 4:
        if (s4Poured &&
            s4AnsBCtrl.text.trim() == "3" &&
            s4AnsYCtrl.text.trim() == "7") {
          success = true;
          msg = _t(
            "Perfect! Blue stayed at 30mL, while Yellow increased to 70mL. The ratio 30:70 simplifies to 3:7.",
            "उत्कृष्ट! ब्लू 30mL पर रहा, जबकि येलो 70mL हो गया। 30:70 सरल होकर 3:7 हो जाता है।",
          );
        } else if (s4Poured ||
            s4AnsBCtrl.text.isNotEmpty ||
            s4AnsYCtrl.text.isNotEmpty) {
          msg = _t(
            "Pour the paint first. You now have 30mL Blue and 70mL Yellow. How do you simplify 30:70?",
            "पेंट डालें। अब आपके पास 30mL ब्लू और 70mL येलो है। 30:70 को कैसे सरल बनाएँ?",
          );
        } else {
          msg = _t(
            "Please complete the interactions before verifying.",
            "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।",
          );
        }
        break;
    }

    _showFeedback(success, msg);

    if (success) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentStep < 4) {
          _loadStep(_currentStep + 1);
        } else {
          _showSuccessModal();
        }
      });
    }
  }

  void _loadStep(int step) {
    setState(() {
      _currentStep = step;
      _isHudSuccess = false;
      _updateHudDefaultMessage();
      _resetStepStates();
    });
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  color: Color(0xFFEAB308),
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  _t("Congratulations!", "बधाई हो!"),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(
                    "You've mastered Sharing in Unequal Ratios.",
                    "आपने असमान अनुपात में बँटवारे में महारत हासिल कर ली है।",
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _playSound(_clickPlayer, _clickUrl);
                    Navigator.of(context).pop();
                    _loadStep(1);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: Text(
                    _t("Restart Lab", "प्रयोगशाला पुनः आरंभ करें"),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _enterLab() async {
    _playSound(_shutterPlayer, _shutterUrl);
    setState(() {
      _shutterOpen = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _shutterVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sidebarWidth = screenWidth * 0.30;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content Row
            Row(
              children: [
                // Collapsible Sidebar (Left)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(right: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth: sidebarWidth,
                      minWidth: sidebarWidth,
                      child: _buildSidebar(),
                    ),
                  ),
                ),
                // Responsive Workspace (Center/Right)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFF020617)),
                    child: Stack(
                      children: [
                        _buildWorkspace(),
                        // HUD Feedback
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0F172A,
                                ).withOpacity(0.95),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isHudSuccess
                                        ? Icons.check_circle
                                        : Icons.info,
                                    color: _isHudSuccess
                                        ? Colors.green
                                        : Colors.blue,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      _hudMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _isHudSuccess
                                            ? Colors.green.shade300
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Left Menu Button (Floating Front Z-Index)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.menu),
                color: Colors.white,
                onPressed: () {
                  _playSound(_clickPlayer, _clickUrl);
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A).withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
              ),
            ),

            // Floating Controls Panel (Visible on Canvas when Sidebar is Closed)
            if (!_isSidebarOpen)
              Positioned(
                top: 16,
                right: 16,
                bottom: 90, // Leave room for HUD
                child: SafeArea(
                  child: Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.95),
                      border: Border.all(color: const Color(0xFF334155)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 10),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.build,
                              color: Color(0xFFEAB308),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _t("Tools", "उपकरण"),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEAB308),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _buildSidebarTools(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _verifyStep,
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.black,
                              size: 18,
                            ),
                            label: Text(
                              _t("Verify Task", "सत्यापित करें"),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAB308),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Shutter Screen Overlay
            if (_shutterVisible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOutCubic,
                top: _shutterOpen ? -screenHeight : 0,
                left: 0,
                right: 0,
                height: screenHeight,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [Color(0xFF0F172A), Color(0xFF020617)],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEAB308), width: 8),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.biotech,
                          size: 80,
                          color: Color(0xFFEAB308),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _t(
                            "Sharing in Unequal Ratios",
                            "असमान अनुपात में बँटवारा",
                          ),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _t(
                            "Class 8 • Proportional Reasoning-2",
                            "कक्षा 8 • आनुपातिक तर्कशक्ति-2",
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _enterLab,
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                            size: 28,
                          ),
                          label: Text(
                            _t("Enter Lab", "लैब में प्रवेश करें"),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAB308),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            elevation: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SIDEBAR (Fully Scrollable, Width 30%)
  // =========================================================================
  Widget _buildSidebar() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 80.0,
          bottom: 20,
          left: 20,
          right: 20,
        ), // Top padding avoids menu button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Header
            Text(
              _t("Sharing in Unequal Ratios", "असमान अनुपात में बँटवारा"),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _t(
                "Class 8 • Proportional Reasoning-2",
                "कक्षा 8 • आनुपातिक तर्कशक्ति-2",
              ),
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 16),

            // Language & Reset Controls
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleLang,
                  icon: const Icon(Icons.language, size: 16),
                  label: Text(_currentLang),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetLab,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(_t("Reset", "रीसेट")),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Step Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _currentStep,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0F172A),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(
                        _t("Step 1: Investment Profit", "चरण 1: निवेश लाभ"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text(
                        _t(
                          "Step 2: Mixture Adjustment",
                          "चरण 2: मिश्रण समायोजन",
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text(
                        _t("Step 3: Figure It Out", "चरण 3: इसे हल करें"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text(
                        _t("Step 4: Paint Mixing", "चरण 4: पेंट मिश्रण"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _playSound(_clickPlayer, _clickUrl);
                      _loadStep(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Theory Text
            Text(
              _getTheoryText(),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Color(0xFF334155)),
            const SizedBox(height: 16),

            // Interactive Tools
            Row(
              children: [
                const Icon(Icons.build, color: Color(0xFFEAB308), size: 20),
                const SizedBox(width: 8),
                Text(
                  _t("Interactive Tools", "इंटरएक्टिव उपकरण"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEAB308),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSidebarTools(),

            const SizedBox(height: 40),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _verifyStep,
                icon: const Icon(Icons.check_circle, color: Colors.black),
                label: Text(
                  _t("Verify Task", "कार्य सत्यापित करें"),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Footer (untouched translation)
            const Center(
              child: Text(
                "© ZEROSCIENCELAB - Fall in Love with Math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTheoryText() {
    switch (_currentStep) {
      case 1:
        return _t(
          "When dividing a total quantity into unequal shares, we first find the simplest ratio, then determine the value of a single 'part'.\n\nPrashanti invested ₹75,000 and Bhuvan invested ₹25,000. Their investment ratio simplifies to 3:1.\n\nThis means there are 4 total 'parts' (3 + 1). To share a ₹4,000 profit fairly, divide the profit by the 4 parts to find the value of one part, then distribute it according to the 3:1 ratio.",
          "कुल मात्रा को असमान शेयरों में विभाजित करते समय, हम पहले सबसे सरल अनुपात ज्ञात करते हैं...\n\nप्रशांति ने ₹75,000 और भुवन ने ₹25,000 का निवेश किया। अनुपात 3:1 है।\n\nकुल 4 'भाग' हैं। ₹4,000 के लाभ को उचित रूप से साझा करने के लिए, 4 भागों से विभाजित करें और 3:1 में वितरित करें।",
        );
      case 2:
        return _t(
          "Sometimes we adjust an existing ratio by adding to only one side.\n\nA 40kg sand-cement mix has a ratio of 3:1. This means 30kg of Sand and 10kg of Cement.\n\nIf we want to change the ratio to 5:2, we only add cement. The Sand is FIXED at 30kg. Therefore, in our new 5:2 ratio, the '5 parts' must equal our fixed 30kg of sand. Calculate the new value of '1 part' to find out how much cement is needed.",
          "कभी-कभी हम केवल एक तरफ जोड़कर मौजूदा अनुपात को समायोजित करते हैं।\n\n40kg रेत-सीमेंट मिश्रण का अनुपात 3:1 है। मतलब 30kg रेत और 10kg सीमेंट।\n\nयदि हम अनुपात को 5:2 में बदलना चाहते हैं, तो रेत 30kg पर निश्चित है। नए 5:2 अनुपात में, '5 भाग' 30kg के बराबर होना चाहिए।",
        );
      case 3:
        return _t(
          "Let's practice the core algorithm. 'Divide ₹4,500 in the ratio 2:3'.\n\nStep 1: Add the ratio numbers to find total parts (2 + 3 = 5).\n\nStep 2: Divide the total amount by the total parts to find the value of one share.\nStep 3: Multiply that single share value by 2 and by 3.",
          "आइए मुख्य एल्गोरिथ्म का अभ्यास करें। '₹4,500 को 2:3 के अनुपात में विभाजित करें'।\n\nचरण 1: कुल भाग ज्ञात करने के लिए अनुपात संख्याओं को जोड़ें (2 + 3 = 5)।\n\nचरण 2: एक शेयर का मूल्य ज्ञात करने के लिए 5 से विभाजित करें।\nचरण 3: उस मूल्य को 2 और 3 से गुणा करें।",
        );
      case 4:
        return _t(
          "Let's observe how adding a fixed amount changes a ratio.\n\nA painter has an 80mL paint mixture of Blue and Yellow in a 3:5 ratio (30mL Blue, 50mL Yellow).\n\nIf the painter adds exactly 20mL of pure Yellow paint, the volume of Yellow changes, but Blue remains the same. We must find the new volumes and simplify them to find the new ratio.",
          "आइए देखें कि एक निश्चित मात्रा जोड़ने से अनुपात कैसे बदलता है।\n\nएक चित्रकार के पास 3:5 के अनुपात में 80mL पेंट है (30mL ब्लू, 50mL येलो)।\n\nयदि 20mL शुद्ध येलो पेंट जोड़ता है, तो येलो की मात्रा बदल जाती है। नई मात्रा ज्ञात करें और सरल बनाएँ।",
        );
      default:
        return "";
    }
  }

  Widget _buildSidebarTools() {
    switch (_currentStep) {
      case 1:
        return Column(
          children: [
            if (!s1ProfitSliced)
              _buildDraggableItem(
                _t("Ratio Slicer", "अनुपात स्लाइसर"),
                Colors.indigo,
                Icons.cut,
                id: "Ratio Slicer",
              ),
            if (s1ProfitSliced) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  s1AvailableChunks,
                  (index) => _buildDraggableItem(
                    "₹1000",
                    Colors.green.shade600,
                    Icons.money,
                    id: "1000",
                    isSmall: true,
                  ),
                ),
              ),
            ],
          ],
        );
      case 2:
        return Column(
          children: [
            _buildInputRow(_t("1 Part =", "1 भाग ="), "kg", s2PartCtrl),
            const SizedBox(height: 12),
            _buildInputRow(
              _t("Target Cement =", "लक्ष्य सीमेंट ="),
              "kg",
              s2TargetCtrl,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem(
                  "+1kg",
                  Colors.blueGrey,
                  Icons.add,
                  isSmall: true,
                  id: "1",
                ),
                _buildDraggableItem(
                  "+2kg",
                  Colors.blueGrey,
                  Icons.add,
                  isSmall: true,
                  id: "2",
                ),
                _buildDraggableItem(
                  "+3kg",
                  Colors.blueGrey,
                  Icons.add,
                  isSmall: true,
                  id: "3",
                ),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _buildInputRow(_t("1 Share =", "1 शेयर ="), "", s3ShareCtrl),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem(
                  "900",
                  Colors.green.shade600,
                  Icons.money,
                  isSmall: true,
                  id: "900",
                ),
                _buildDraggableItem(
                  "1800",
                  Colors.green.shade600,
                  Icons.money,
                  isSmall: true,
                  id: "1800",
                ),
                _buildDraggableItem(
                  "2700",
                  Colors.green.shade600,
                  Icons.money,
                  isSmall: true,
                  id: "2700",
                ),
                _buildDraggableItem(
                  "3600",
                  Colors.green.shade600,
                  Icons.money,
                  isSmall: true,
                  id: "3600",
                ),
              ],
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            _buildDraggableItem(
              _t("Pour 20mL Yellow", "20mL येलो डालें"),
              Colors.indigo,
              Icons.science,
              id: "pour",
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputRow(_t("Blue", "ब्लू"), "", s4AnsBCtrl),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 24.0,
                  ),
                  child: Text(
                    ":",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildInputRow(_t("Yellow", "येलो"), "", s4AnsYCtrl),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDraggableItem(
    String label,
    Color bgColor,
    IconData icon, {
    Color textColor = Colors.white,
    bool isSmall = false,
    required String id,
  }) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 8 : 12,
        horizontal: isSmall ? 16 : 0,
      ),
      width: isSmall ? null : double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isSmall) Icon(icon, color: textColor, size: 20),
          if (!isSmall) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 14 : 16,
            ),
          ),
        ],
      ),
    );

    return Draggable<String>(
      data: id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => _playSound(_fxPlayer, _dropUrl),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(width: isSmall ? 80 : 200, child: child),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }

  Widget _buildInputRow(
    String label,
    String unit,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF334155)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEAB308),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "?",
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
              if (unit.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Text(
                    unit,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // WORKSPACE (Center Area - Mobile Responsive)
  // =========================================================================
  Widget _buildWorkspace() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: _isSidebarOpen
              ? 24
              : 290, // Dynamic padding to avoid floating tools overlap
          top: 40,
          bottom: 80,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Builder(
                builder: (context) {
                  switch (_currentStep) {
                    case 1:
                      return _buildStep1Workspace();
                    case 2:
                      return _buildStep2Workspace();
                    case 3:
                      return _buildStep3Workspace();
                    case 4:
                      return _buildStep4Workspace();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Step 1 Layout ---
  Widget _buildStep1Workspace() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Ledger
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 4),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.blue.shade100,
                child: Text(
                  _t("Business Ledger", "व्यापार बहीखाता"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _t("Prashanti", "प्रशांति"),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const Text(
                          "₹75k",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _t("Bhuvan", "भुवन"),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const Text(
                          "₹25k",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Main Profit Dropzone
        if (!s1ProfitSliced)
          DragTarget<String>(
            onAcceptWithDetails: (details) {
              if (details.data == "Ratio Slicer") {
                _playSound(_fxPlayer, _dropUrl);
                setState(() => s1ProfitSliced = true);
              }
            },
            builder: (context, candidate, rejected) {
              return Container(
                width: 220,
                height: 120,
                decoration: BoxDecoration(
                  color: candidate.isNotEmpty
                      ? Colors.green.shade400
                      : Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: candidate.isNotEmpty
                        ? Colors.white
                        : Colors.green.shade800,
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _t("Total Profit", "कुल लाभ").toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "₹4,000",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        else
          // Show empty space where block was, chunks are generated in the tool box in this app design
          Container(
            width: 220,
            height: 120,
            alignment: Alignment.center,
            child: const Text(
              "Sliced into\n4 parts",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white30,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        const SizedBox(width: 32),

        // Wallets
        Column(
          children: [
            // Prashanti
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                final d = details.data;
                if (d == "1000") {
                  _playSound(_fxPlayer, _dropUrl);
                  setState(() {
                    s1PrashantiWallet += 1000;
                    s1AvailableChunks--;
                  });
                }
              },
              builder: (context, candidate, rejected) {
                return _buildWallet(
                  _t("Prashanti's Wallet", "प्रशांति का बटुआ"),
                  s1PrashantiWallet,
                  candidate.isNotEmpty,
                );
              },
            ),
            const SizedBox(height: 16),
            // Bhuvan
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                final d = details.data;
                if (d == "1000") {
                  _playSound(_fxPlayer, _dropUrl);
                  setState(() {
                    s1BhuvanWallet += 1000;
                    s1AvailableChunks--;
                  });
                }
              },
              builder: (context, candidate, rejected) {
                return _buildWallet(
                  _t("Bhuvan's Wallet", "भुवन का बटुआ"),
                  s1BhuvanWallet,
                  candidate.isNotEmpty,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWallet(String name, int total, bool isHovered) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5A2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHovered ? Colors.white : const Color(0xFF5C3A21),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  _t("Total", "कुल").toUpperCase(),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                Text(
                  "₹$total",
                  style: TextStyle(
                    color: total > 0 ? Colors.greenAccent : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2 Layout ---
  Widget _buildStep2Workspace() {
    double totalCement = 10 + s2DroppedCement.toDouble();
    double totalWeight = 30 + totalCement;
    double sandPct = (30 / totalWeight);
    double cementPct = (totalCement / totalWeight);

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        _playSound(_fxPlayer, _dropUrl);
        setState(() {
          s2DroppedCement += int.parse(details.data);
        });
      },
      builder: (context, candidate, rejected) {
        return Container(
          width: 250,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black26,
            border: Border.all(
              color: candidate.isNotEmpty ? Colors.white : Colors.blueGrey,
              width: 4,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cement Layer
              Container(
                width: double.infinity,
                height: 400 * cementPct * 0.8, // Scale visually
                color: Colors.blueGrey.shade400,
                alignment: Alignment.center,
                child: Text(
                  "${_t("Cement", "सीमेंट")}: ${totalCement.toInt()}kg",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              // Sand Layer (Fixed)
              Container(
                width: double.infinity,
                height: 400 * sandPct * 0.8, // Scale visually
                color: Colors.orange.shade500,
                alignment: Alignment.center,
                child: Text(
                  "${_t("Sand", "रेत")}: 30kg",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Step 3 Layout ---
  Widget _buildStep3Workspace() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Tray 2
        Column(
          children: [
            Text(
              _t("2x Tray", "2x ट्रे"),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DragTarget<String>(
              onAccept: (d) {
                _playSound(_fxPlayer, _dropUrl);
                setState(() {
                  s3Tray2 = d;
                });
              },
              builder: (context, candidate, rejected) {
                return Container(
                  width: 180,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: candidate.isNotEmpty
                          ? Colors.white
                          : Colors.blueAccent,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: s3Tray2 != null
                      ? Container(
                          width: double.infinity,
                          height: 60,
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: Text(
                            "₹$s3Tray2",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        const SizedBox(width: 40),

        // Main Pile
        Container(
          width: 140,
          height: 140,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(color: Colors.green.shade800, width: 12),
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            "₹4,500",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 40),

        // Tray 3
        Column(
          children: [
            Text(
              _t("3x Tray", "3x ट्रे"),
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DragTarget<String>(
              onAccept: (d) {
                _playSound(_fxPlayer, _dropUrl);
                setState(() {
                  s3Tray3 = d;
                });
              },
              builder: (context, candidate, rejected) {
                return Container(
                  width: 180,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border.all(
                      color: candidate.isNotEmpty
                          ? Colors.white
                          : Colors.orangeAccent,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: s3Tray3 != null
                      ? Container(
                          width: double.infinity,
                          height: 90,
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: Text(
                            "₹$s3Tray3",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // --- Step 4 Layout ---
  Widget _buildStep4Workspace() {
    double blueVol = 30;
    double yellowVol = s4Poured ? 70 : 50;
    double totalVol = blueVol + yellowVol;

    return DragTarget<String>(
      onAccept: (d) {
        if (d == "pour" && !s4Poured) {
          _playSound(_successPlayer, _successUrl);
          setState(() {
            s4Poured = true;
          });
        }
      },
      builder: (context, candidate, rejected) {
        return Container(
          width: 220,
          height: 350,
          decoration: BoxDecoration(
            color: Colors.black26,
            border: Border.all(
              color: candidate.isNotEmpty ? Colors.white : Colors.grey.shade400,
              width: 4,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Yellow Layer
              Container(
                width: double.infinity,
                height: 350 * (yellowVol / totalVol),
                color: Colors.yellow.shade400,
                alignment: Alignment.center,
                child: Text(
                  "${_t("Yellow", "येलो")}: ${yellowVol.toInt()}mL",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Blue Layer
              Container(
                width: double.infinity,
                height: 350 * (blueVol / totalVol),
                color: Colors.blue.shade600,
                alignment: Alignment.center,
                child: Text(
                  "${_t("Blue", "ब्लू")}: ${blueVol.toInt()}mL",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
