// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PieChartsLabApp());
}

class PieChartsLabApp extends StatelessWidget {
  const PieChartsLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pie Charts Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // bg-zsl-dark
        primaryColor: const Color(0xFFEAB308), // zsl-yellow
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          surface: Color(0xFF0F172A),
        ),
        fontFamily: 'Roboto',
      ),
      home: const PieChartsLab(),
    );
  }
}

class PieChartsLab extends StatefulWidget {
  const PieChartsLab({super.key});

  @override
  State<PieChartsLab> createState() => _PieChartsLabState();
}

class _PieChartsLabState extends State<PieChartsLab> {
  bool _isSidebarOpen = true;
  int _currentStep = 1;
  String _hudMessage = "Ready! Read the instructions and use the interactive tools.";
  bool _isHudSuccess = false;
  String _currentLang = 'EN';

  // --- Shutter State ---
  bool _shutterOpen = false;
  bool _shutterVisible = true;

  // --- Audio Players ---
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class8/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class8/mixkit_2574.mp3';
  static const String _dropUrl = 'audio/class8/mixkit_2869.mp3';

  // --- Step 1 State ---
  String? s1Pie;

  // --- Step 2 State ---
  String? s2Large;
  String? s2Small;

  // --- Step 3 State ---
  String? s3Frac;
  String? s3Angle;

  // --- Step 4 State ---
  String? s4S1;
  String? s4S2;
  String? s4S3;
  String? s4S4;

  // --- Step 5 State ---
  String? s5Num;
  String? s5Frac;

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
    return _currentLang == 'HI' ? hi : en;
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
        "तैयार! निर्देश पढ़ें और इंटरैक्टिव टूल का उपयोग करें।"
      );
    }
  }

  void _resetLab() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _currentStep = 1;
      _isHudSuccess = false;
      _updateHudDefaultMessage();
      _resetStepStates();
    });
  }

  void _resetStepStates() {
    s1Pie = null;
    s2Large = null;
    s2Small = null;
    s3Frac = null;
    s3Angle = null;
    s4S1 = null;
    s4S2 = null;
    s4S3 = null;
    s4S4 = null;
    s5Num = null;
    s5Frac = null;
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
        if (s1Pie == "50%") {
          success = true;
          msg = _t(
            "Correct! The Cricket sector takes up exactly half the circle's area. Pie charts give us an instant visual understanding of proportions.",
            "सही! क्रिकेट सेक्टर वृत्त के ठीक आधे हिस्से को घेरता है। पाई चार्ट हमें अनुपात की त्वरित समझ देते हैं।"
          );
        } else if (s1Pie != null) {
          msg = _t(
            "Observe the percentage. 50% represents exactly half of the total. Select the slice that is shaped like a half-circle.",
            "प्रतिशत का निरीक्षण करें। 50% कुल के ठीक आधे का प्रतिनिधित्व करता है। वह स्लाइस चुनें जो आधे वृत्त के आकार का हो।"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
      case 2:
        if (s2Large == "Python" && s2Small == "Giraffe") {
          success = true;
          msg = _t(
            "Great visual estimation! 18 out of 24 hours is a huge portion, while 2 out of 24 is very small.",
            "बढ़िया दृश्य अनुमान! 24 में से 18 घंटे एक बहुत बड़ा हिस्सा है, जबकि 24 में से 2 घंटे बहुत छोटा है।"
          );
        } else if (s2Large != null || s2Small != null) {
          msg = _t(
            "Compare the hours. Does a Giraffe sleep for most of the day, or just a tiny part of it? Swap the tags.",
            "घंटों की तुलना करें। क्या जिराफ दिन के अधिकांश समय सोता है, या केवल एक छोटा हिस्सा? टैग बदलें।"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
      case 3:
        if (s3Frac == "8" && s3Angle == "120") {
          success = true;
          msg = _t(
            "Masterful calculation! 8 hours is exactly 1/3 of a day. 1/3 of a full 360° circle is a 120° angle.",
            "उत्कृष्ट गणना! 8 घंटे दिन का ठीक 1/3 है। पूरे 360° वृत्त का 1/3 हिस्सा 120° का कोण है।"
          );
        } else if (s3Frac != null || s3Angle != null) {
          msg = _t(
            "Check the math. 8/24 reduces to 1/3. What is 360 divided by 3? Choose that number block for the final angle.",
            "गणित की जाँच करें। 8/24 को 1/3 तक कम किया जाता है। 360 को 3 से विभाजित करने पर क्या आता है?"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
      case 4:
        if (s4S1 == "90" && (s4S2 == "120a" || s4S2 == "120b") && (s4S3 == "120a" || s4S3 == "120b") && s4S4 == "30") {
          success = true;
          msg = _t(
            "Beautiful construction! 90° + 120° + 120° + 30° = 360°. Your slices fit together perfectly.",
            "सुंदर निर्माण! 90° + 120° + 120° + 30° = 360°। आपके स्लाइस पूरी तरह से एक साथ फिट होते हैं।"
          );
        } else if (s4S1 != null || s4S2 != null || s4S3 != null || s4S4 != null) {
          msg = _t(
            "Make sure all the pieces fit perfectly. The points of every wedge must be placed into the correct zone.",
            "सुनिश्चित करें कि सभी टुकड़े पूरी तरह से फिट हों। प्रत्येक पच्चर के बिंदुओं को सही क्षेत्र में रखा जाना चाहिए।"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
      case 5:
        if (s5Num == "60" && s5Frac == "1/6") {
          success = true;
          msg = _t(
            "Outstanding! 60/360 simplifies exactly to 1/6. You have successfully mastered Pie Charts!",
            "बकाया! 60/360 ठीक 1/6 तक सरल हो जाता है। आपने पाई चार्ट में सफलतापूर्वक महारत हासिल कर ली है!"
          );
        } else if (s5Num != null || s5Frac != null) {
          msg = _t(
            "Check the division. The angle is 60. How many times does 60 fit into 360?",
            "विभाजन की जाँच करें। कोण 60 है। 60 कितनी बार 360 में फिट बैठता है?"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
    }

    _showFeedback(success, msg);

    if (success) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentStep < 5) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pie_chart, color: Color(0xFFEAB308), size: 80),
                const SizedBox(height: 16),
                Text(
                  _t("Simulation Complete!", "सिमुलेशन पूर्ण!"),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(
                    "Congratulations! You've mastered Pie Charts.",
                    "बधाई हो! आपने पाई चार्ट सफलतापूर्वक पूर्ण कर लिए हैं।"
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
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                )
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF020617),
                    ),
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
                              margin: const EdgeInsets.symmetric(horizontal: 40),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.95),
                                border: Border.all(color: const Color(0xFF334155)),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isHudSuccess ? Icons.check_circle : Icons.info,
                                    color: _isHudSuccess ? Colors.green : Colors.blue,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      _hudMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _isHudSuccess ? Colors.green.shade300 : Colors.white,
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
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.build, color: Color(0xFFEAB308), size: 18),
                            const SizedBox(width: 8),
                            Text(_t("Tools", "उपकरण"), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEAB308), fontSize: 16)),
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
                            icon: const Icon(Icons.check_circle, color: Colors.black, size: 18),
                            label: Text(_currentStep == 5 ? _t("Finish", "समाप्त करें") : _t("Verify Step", "चरण सत्यापित करें"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAB308),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    border: Border(bottom: BorderSide(color: Color(0xFFEAB308), width: 8)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pie_chart, size: 80, color: Color(0xFFEAB308)),
                        const SizedBox(height: 24),
                        Text(
                          _t("Pie Charts", "पाई चार्ट (Pie Charts)"),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _t("Class 8 • Proportional Reasoning-2", "कक्षा 8 • आनुपातिक तर्कशक्ति-2"),
                          style: const TextStyle(fontSize: 24, color: Colors.white70),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _enterLab,
                          icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                          label: Text(
                            _t("Enter Lab", "लैब में प्रवेश करें"),
                            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAB308),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            elevation: 10,
                          ),
                        )
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
        padding: const EdgeInsets.only(top: 80.0, bottom: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Header
            Text(
              _t("Pie Charts", "पाई चार्ट (Pie Charts)"),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _t("Class 8 • Proportional Reasoning-2", "कक्षा 8 • आनुपातिक तर्कशक्ति-2"),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    DropdownMenuItem(value: 1, child: Text(_t("Step 1: Preference Visualization", "चरण 1: प्राथमिकता दृश्य"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 2, child: Text(_t("Step 2: Sleepy-Deepy Data", "चरण 2: स्लीपी-डीपी डेटा"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 3, child: Text(_t("Step 3: Calculating Central Angles", "चरण 3: केंद्रीय कोणों की गणना"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 4, child: Text(_t("Step 4: Drawing the Pie Chart", "चरण 4: पाई चार्ट बनाना"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 5, child: Text(_t("Step 5: Interpretation", "चरण 5: व्याख्या (बचत)"), style: const TextStyle(fontSize: 14, color: Colors.white))),
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
              style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Divider(color: Color(0xFF334155)),
            const SizedBox(height: 16),
            
            // Interactive Tools
            Row(
              children: [
                const Icon(Icons.build, color: Color(0xFFEAB308), size: 20),
                const SizedBox(width: 8),
                Text(_t("Interactive Tools", "इंटरएक्टिव उपकरण"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEAB308))),
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
                label: Text(_currentStep == 5 ? _t("Finish", "समाप्त करें") : _t("Verify Step", "चरण सत्यापित करें"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer (untouched translation)
            const Center(
              child: Text(
                "© ZEROSCIENCELAB - Fall in Love with Math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w500),
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
          "Let's compare ways to display data like 'Favorite Sports'. A bar graph is excellent for comparing exact counts between categories.\n\nHowever, to see 'parts of a whole', a Pie Chart (Circle Graph) is much better.\n\nThe entire circle represents 100% of the class. If 50% of the students chose Cricket, we need to show that as a proportion of the entire circle.",
          "'पसंदीदा खेल' जैसे डेटा प्रदर्शित करने के तरीकों की तुलना करें। एक बार ग्राफ श्रेणियों के बीच सटीक संख्या की तुलना करने के लिए उत्कृष्ट है।\n\nहालांकि, 'संपूर्ण के भागों' को देखने के लिए, एक पाई चार्ट (वृत्त आरेख) बहुत बेहतर है।\n\nपूरा वृत्त कक्षा के 100% का प्रतिनिधित्व करता है। यदि 50% छात्रों ने क्रिकेट चुना, तो हमें पूरे वृत्त के अनुपात के रूप में दिखाना होगा।"
        );
      case 2: 
        return _t(
          "Let's look at the 'Sleepy-Deepy' data. A full day is 24 hours, which represents our whole circle.\n\nA Python sleeps for 18 hours, while a Giraffe sleeps for only 2 hours.\n\nBefore calculating exact math, we can visually estimate the sizes of their sectors on the pie chart based on their proportion of the 24-hour day.",
          "आइए 'स्लीपी-डीपी' डेटा देखें। एक पूरा दिन 24 घंटे का होता है, जो हमारे पूरे वृत्त का प्रतिनिधित्व करता है।\n\nएक अजगर 18 घंटे सोता है, जबकि जिराफ केवल 2 घंटे सोता है।\n\nसटीक गणित की गणना करने से पहले, हम 24 घंटे के दिन के उनके अनुपात के आधार पर पाई चार्ट पर उनके क्षेत्रों के आकार का दृश्य रूप से अनुमान लगा सकते हैं।"
        );
      case 3: 
        return _t(
          "To draw a pie chart accurately, we use the Central Angle. A full circle is exactly 360°.\n\nTo find the angle for any activity, we take its fraction of the total and multiply it by 360°.\n\nFor example, School is 6 hours out of 24. Angle = (6/24) × 360° = 90°.\n\nLet's calculate the angle for 'Sleep', which takes 8 hours.",
          "एक पाई चार्ट को सटीक रूप से खींचने के लिए, हम केंद्रीय कोण का उपयोग करते हैं। एक पूरा वृत्त ठीक 360° होता है।\n\nकिसी भी गतिविधि के लिए कोण खोजने के लिए, हम कुल के उसके अंश को लेते हैं और इसे 360° से गुणा करते हैं।\n\nउदाहरण के लिए, स्कूल 24 में से 6 घंटे है। कोण = (6/24) × 360° = 90°।\n\nआइए 'नींद' के लिए कोण की गणना करें, जिसमें 8 घंटे लगते हैं।"
        );
      case 4: 
        return _t(
          "Let's finish the pie chart for the student's entire day:\n\nSchool (6 hrs) = 90°, Sleep (8 hrs) = 120°, Play (2 hrs) = 30°, Others (8 hrs) = 120°.\n\nA pie chart is constructed by measuring these central angles outward from the center point, creating perfectly sized sectors that add up to the whole.",
          "आइए छात्र के पूरे दिन के लिए पाई चार्ट पूरा करें:\n\nस्कूल (6 घंटे) = 90°, नींद (8 घंटे) = 120°, खेलना (2 घंटे) = 30°, अन्य (8 घंटे) = 120°।\n\nएक पाई चार्ट इन केंद्रीय कोणों को केंद्र बिंदु से बाहर की ओर मापकर बनाया जाता है, जिससे पूरी तरह से आकार के क्षेत्र बनते हैं जो कुल को जोड़ते हैं।"
        );
      case 5:
        return _t(
          "What if we have a finished pie chart and need to find the data fraction?\n\nLook at this family budget graph. The 'Savings' sector has a measured central angle of 60°.\n\nTo find what fraction of their total income is saved, we work backward: divide the sector's angle by the total 360°.",
          "क्या होगा यदि हमारे पास एक तैयार पाई चार्ट है और हमें डेटा अंश खोजने की आवश्यकता है?\n\nइस पारिवारिक बजट ग्राफ को देखें। 'बचत' क्षेत्र में 60° का मापा गया केंद्रीय कोण है।\n\nउनकी कुल आय का कितना अंश बचाया जाता है, यह जानने के लिए, हम पीछे की ओर काम करते हैं: कुल 360° से क्षेत्र के कोण को विभाजित करें।"
        );
      default: return "";
    }
  }

  Widget _buildSidebarTools() {
    switch (_currentStep) {
      case 1:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _buildDraggableItem(_t("Cricket: 50%", "क्रिकेट: 50%"), Colors.blue, Icons.sports_cricket, id: "50%"),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem(_t("Football: 25%", "फुटबॉल: 25%"), Colors.green, Icons.sports_soccer, id: "25a", isSmall: true),
                _buildDraggableItem(_t("Tennis: 25%", "टेनिस: 25%"), Colors.orange, Icons.sports_tennis, id: "25b", isSmall: true),
              ],
            )
          ],
        );
      case 2:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _buildDraggableItem(_t("Python (18 hrs)", "अजगर (18 घंटे)"), Colors.blue, Icons.pest_control, id: "Python"),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildDraggableItem(_t("Giraffe (2 hrs)", "जिराफ (2 घंटे)"), Colors.green, Icons.pets, id: "Giraffe"),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem("6", Colors.blue, Icons.numbers, id: "6", isSmall: true),
                _buildDraggableItem("8", Colors.blue, Icons.numbers, id: "8", isSmall: true),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem("90", Colors.green, Icons.tag, id: "90", isSmall: true),
                _buildDraggableItem("120", Colors.green, Icons.tag, id: "120", isSmall: true),
                _buildDraggableItem("180", Colors.green, Icons.tag, id: "180", isSmall: true),
              ],
            ),
          ],
        );
      case 4:
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDraggableItem("90°", Colors.blue, Icons.pie_chart, id: "90", isSmall: true),
            _buildDraggableItem("120°", Colors.green, Icons.pie_chart, id: "120a", isSmall: true),
            _buildDraggableItem("120°", Colors.orange, Icons.pie_chart, id: "120b", isSmall: true),
            _buildDraggableItem("30°", Colors.red, Icons.pie_chart, id: "30", isSmall: true),
          ],
        );
      case 5:
         return Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem("60", Colors.blue, Icons.numbers, id: "60", isSmall: true),
                _buildDraggableItem("90", Colors.blue, Icons.numbers, id: "90", isSmall: true),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDraggableItem("1/2", Colors.green, Icons.calculate, id: "1/2", isSmall: true),
                _buildDraggableItem("1/4", Colors.green, Icons.calculate, id: "1/4", isSmall: true),
                _buildDraggableItem("1/6", Colors.green, Icons.calculate, id: "1/6", isSmall: true),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDraggableItem(String label, Color bgColor, IconData icon, {Color textColor = Colors.white, bool isSmall = false, required String id}) {
    final childWidget = Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12, horizontal: isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isSmall) Icon(icon, color: textColor, size: 20),
          if (!isSmall) const SizedBox(width: 8),
          Flexible(
            child: Text(
              label, 
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16),
              overflow: TextOverflow.ellipsis,
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
          child: childWidget
        )
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: childWidget),
      child: childWidget,
    );
  }

  // =========================================================================
  // WORKSPACE (Center Area - Mobile Responsive)
  // =========================================================================
  Widget _buildWorkspace() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, 
        right: _isSidebarOpen ? 24 : 290, // Dynamic padding to avoid floating tools overlap
        top: 40, 
        bottom: 80
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    switch (_currentStep) {
                      case 1: return _buildStep1Workspace();
                      case 2: return _buildStep2Workspace();
                      case 3: return _buildStep3Workspace();
                      case 4: return _buildStep4Workspace();
                      case 5: return _buildStep5Workspace();
                      default: return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  // --- Step 1 Layout ---
  Widget _buildStep1Workspace() {
    return DragTarget<String>(
      onAccept: (d) {
        _playSound(_fxPlayer, _dropUrl);
        setState(() => s1Pie = d);
      },
      builder: (context, candidate, rejected) {
        bool isCorrect = s1Pie == "50%";
        
        double? angle;
        Color? color;
        String displayVal = "?";
        
        if (s1Pie == "50%") { angle = 180; color = Colors.blue; displayVal = "50%"; }
        else if (s1Pie == "25a" || s1Pie == "25b") { angle = 90; color = s1Pie == "25a" ? Colors.green : Colors.orange; displayVal = "25%"; }
        
        return Container(
          width: 350, height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : const Color(0xFF334155), width: 8),
            color: Colors.black12,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (angle != null && color != null)
                CustomPaint(
                  size: const Size(350, 350),
                  painter: PieChartPainter(angles: [angle], colors: [color]),
                ),
              Text(
                s1Pie == null ? "?" : (isCorrect ? displayVal : "X"),
                style: TextStyle(
                  color: s1Pie == null ? Colors.white54 : (isCorrect ? Colors.white : Colors.red),
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 10)]
                )
              )
            ],
          ),
        );
      },
    );
  }

  // --- Step 2 Layout ---
  Widget _buildStep2Workspace() {
    List<double> angles = [];
    List<Color> colors = [];

    if (s2Large == "Python") { angles.add(270); colors.add(Colors.blue); }
    if (s2Small == "Giraffe") { angles.add(30); colors.add(Colors.green); }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base Clock styling pie
        Container(
          width: 360, height: 360,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF334155), width: 8),
            color: Colors.black26,
          ),
          child: CustomPaint(
             painter: PieChartPainter(angles: angles, colors: colors),
          ),
        ),
        // Clock center
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF334155), width: 4),
          ),
          child: const Icon(Icons.access_time, color: Colors.white54, size: 30),
        ),
        
        // Large Dropzone (roughly bottom-left/left covering 270 deg)
        Positioned(
          left: 40, bottom: 80,
          child: DragTarget<String>(
            onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s2Large = d); },
            builder: (context, candidate, rejected) {
              return _buildPieDropzone(s2Large == "Python", s2Large, candidate.isNotEmpty);
            },
          ),
        ),

        // Small Dropzone (roughly top-right covering 30 deg)
        Positioned(
          right: 40, top: 40,
          child: DragTarget<String>(
            onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s2Small = d); },
            builder: (context, candidate, rejected) {
              return _buildPieDropzone(s2Small == "Giraffe", s2Small, candidate.isNotEmpty);
            },
          ),
        )
      ],
    );
  }

  Widget _buildPieDropzone(bool isCorrect, String? val, bool isHovered) {
    return Container(
      width: 120, height: 40,
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.8) : Colors.black54,
        border: Border.all(color: isHovered ? Colors.yellow : (isCorrect ? Colors.green : Colors.white), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        val == null ? "?" : (isCorrect ? val : "X"),
        style: TextStyle(color: val == null ? Colors.white54 : (isCorrect ? Colors.white : Colors.red), fontWeight: FontWeight.bold)
      ),
    );
  }

  // --- Step 3 Layout ---
  Widget _buildStep3Workspace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.calculate, size: 80, color: Colors.yellow),
        const SizedBox(height: 32),
        
        // Fraction area
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t("Fraction =", "अंश ="), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 24),
              Column(
                children: [
                  DragTarget<String>(
                    onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s3Frac = d); },
                    builder: (context, candidate, rejected) {
                      return Container(
                        width: 80, height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : (s3Frac != null ? Colors.blue : Colors.white30), width: 3, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: s3Frac != null ? Colors.blue : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(s3Frac ?? "?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: s3Frac != null ? Colors.white : Colors.white54)),
                      );
                    },
                  ),
                  Container(width: 80, height: 4, color: Colors.white54, margin: const EdgeInsets.symmetric(vertical: 12)),
                  const Text("24", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Angle Area
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t("Angle = Frac × 360° =", "कोण = अंश × 360° ="), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 24),
              DragTarget<String>(
                onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s3Angle = d); },
                builder: (context, candidate, rejected) {
                  return Container(
                    width: 100, height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : (s3Angle != null ? Colors.green : Colors.white30), width: 3, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: s3Angle != null ? Colors.green : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text("${s3Angle ?? "?"}°", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: s3Angle != null ? Colors.white : Colors.white54)),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  // --- Step 4 Layout ---
  Widget _buildStep4Workspace() {
    List<double> angles = [];
    List<Color> colors = [];

    if (s4S1 == "90") { angles.add(90); colors.add(Colors.blue); }
    if (s4S2 == "120a" || s4S2 == "120b") { angles.add(120); colors.add(Colors.green); }
    if (s4S3 == "120a" || s4S3 == "120b") { angles.add(120); colors.add(Colors.orange); }
    if (s4S4 == "30") { angles.add(30); colors.add(Colors.red); }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pie Builder
        Container(
          width: 360, height: 360,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF334155), width: 8),
            color: Colors.black26,
          ),
          child: CustomPaint(
            painter: PieChartPainter(angles: angles, colors: colors),
          ),
        ),
        
        const SizedBox(width: 60),

        // Slots
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSlotRow(_t("School", "स्कूल"), Colors.blue, Icons.school, s4S1, (d) => setState(() => s4S1 = d)),
            const SizedBox(height: 16),
            _buildSlotRow(_t("Sleep", "नींद"), Colors.green, Icons.bed, s4S2, (d) => setState(() => s4S2 = d)),
            const SizedBox(height: 16),
            _buildSlotRow(_t("Others", "अन्य"), Colors.orange, Icons.more_horiz, s4S3, (d) => setState(() => s4S3 = d)),
            const SizedBox(height: 16),
            _buildSlotRow(_t("Play", "खेलना"), Colors.red, Icons.sports_soccer, s4S4, (d) => setState(() => s4S4 = d)),
          ],
        )
      ],
    );
  }

  Widget _buildSlotRow(String title, Color color, IconData icon, String? val, Function(String) onAccept) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white))),
          DragTarget<String>(
            onAccept: (d) { _playSound(_fxPlayer, _dropUrl); onAccept(d); },
            builder: (context, candidate, rejected) {
              String displayVal = val ?? "?";
              if (displayVal == "120a" || displayVal == "120b") displayVal = "120°";
              else if (displayVal != "?") displayVal += "°";

              return Container(
                width: 80, height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : (val != null ? Colors.yellow : Colors.white30), width: 3, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                  color: val != null ? Colors.yellow : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(displayVal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: val != null ? Colors.black : Colors.white54)),
              );
            },
          )
        ],
      ),
    );
  }

  // --- Step 5 Layout ---
  Widget _buildStep5Workspace() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pie Chart Visual
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 320, height: 320,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF334155), width: 8)),
              child: CustomPaint(
                painter: PieChartPainter(
                  angles: [60, 120, 100, 80],
                  colors: [Colors.red, Colors.blue, Colors.green, Colors.orange]
                ),
              ),
            ),
            Positioned(
              top: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("${_t('Savings', 'बचत')} (60°)", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),

        const SizedBox(width: 60),

        // Math Area
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t("Fraction =", "अंश ="), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 24),
              Column(
                children: [
                  DragTarget<String>(
                    onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s5Num = d); },
                    builder: (context, candidate, rejected) {
                      return Container(
                        width: 80, height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : (s5Num != null ? Colors.blue : Colors.white30), width: 3, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: s5Num != null ? Colors.blue : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(s5Num ?? "?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: s5Num != null ? Colors.white : Colors.white54)),
                      );
                    },
                  ),
                  Container(width: 80, height: 4, color: Colors.white54, margin: const EdgeInsets.symmetric(vertical: 12)),
                  const Text("360°", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(width: 24),
              const Text("=", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 24),
              DragTarget<String>(
                onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s5Frac = d); },
                builder: (context, candidate, rejected) {
                  return Container(
                    width: 100, height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : (s5Frac != null ? Colors.green : Colors.white30), width: 3, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(16),
                      color: s5Frac != null ? Colors.green : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(s5Frac ?? "?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: s5Frac != null ? Colors.white : Colors.white54)),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw Pie Chart Segments easily
class PieChartPainter extends CustomPainter {
  final List<double> angles;
  final List<Color> colors;

  PieChartPainter({required this.angles, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -math.pi / 2; // Start from top
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (int i = 0; i < angles.length; i++) {
      final sweepAngle = angles[i] * math.pi / 180;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}