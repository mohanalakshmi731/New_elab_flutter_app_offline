// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InverseProportionLabApp());
}

class InverseProportionLabApp extends StatelessWidget {
  const InverseProportionLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inverse Proportion Lab',
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
      home: const InverseProportionLab(),
    );
  }
}

class InverseProportionLab extends StatefulWidget {
  const InverseProportionLab({super.key});

  @override
  State<InverseProportionLab> createState() => _InverseProportionLabState();
}

class _InverseProportionLabState extends State<InverseProportionLab> {
  bool _isSidebarOpen = true;
  int _currentStep = 1;
  String _hudMessage = "";
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
  int s1Speed = 50;

  // --- Step 2 State ---
  int s2Children = 4;
  String? s2ChocPerChild;

  // --- Step 3 State ---
  String? s3EquationAns;

  // --- Step 4 State ---
  int s4SiteBDays = 5;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _updateHudDefaultMessage();
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
    if (_currentLang == 'HI') return hi;
    return en;
  }

  void _toggleLang() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      if (_currentLang == 'EN') {
        _currentLang = 'HI';
      } else {
        _currentLang = 'EN';
      }
      _updateHudDefaultMessage();
    });
  }

  void _updateHudDefaultMessage() {
    if (!_isHudSuccess) {
      switch (_currentStep) {
        case 1:
          _hudMessage = _t(
            "Use the slider to double the car's speed. Observe what happens to the travel time!",
            "कार की गति को दोगुना करने के लिए स्लाइडर का उपयोग करें। देखें कि यात्रा के समय का क्या होता है!"
          );
          break;
        case 2:
          _hudMessage = _t(
            "Click 'Add 5th Child'. Then, drag the correct number of chocolates each child will receive into the drop box.",
            "'5वां बच्चा जोड़ें' पर क्लिक करें। फिर, प्रत्येक बच्चे को मिलने वाली चॉकलेट की सही संख्या को ड्रॉप बॉक्स में खींचें।"
          );
          break;
        case 3:
          _hudMessage = _t(
            "Use the constant product rule to solve the equation. Drag the correct number into the box.",
            "समीकरण को हल करने के लिए स्थिर गुणनफल नियम का उपयोग करें। सही संख्या को बॉक्स में खींचें।"
          );
          break;
        case 4:
          _hudMessage = _t(
            "Use the slider to find how many days 10 workers need to complete 100 man-days of work.",
            "यह पता लगाने के लिए स्लाइडर का उपयोग करें कि 10 श्रमिकों को 100 मैन-डे का काम पूरा करने में कितने दिन लगते हैं।"
          );
          break;
      }
    }
  }

  void _resetLab() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _currentStep = 1;
      _isHudSuccess = false;
      _resetStepStates();
      _updateHudDefaultMessage();
    });
  }

  void _resetStepStates() {
    s1Speed = 50;
    s2Children = 4;
    s2ChocPerChild = null;
    s3EquationAns = null;
    s4SiteBDays = 5;
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
        if (s1Speed == 100) {
          success = true;
          msg = _t(
            "Correct! By doubling the speed from 50 to 100 km/h, the travel time halved from 2 hours to 1 hour.",
            "सही! गति को 50 से 100 किमी/घंटा तक दोगुना करने से, यात्रा का समय 2 घंटे से आधा होकर 1 घंटा रह गया।"
          );
        } else {
          msg = _t(
            "Slide the speed up to 100 km/h to see inverse proportion in action!",
            "प्रतिलोम समानुपात को क्रिया में देखने के लिए गति को 100 किमी/घंटा तक स्लाइड करें!"
          );
        }
        break;
      case 2:
        if (s2Children == 5 && s2ChocPerChild == "4") {
          success = true;
          msg = _t(
            "Exactly! With 5 children, the 20 chocolates are divided 5 ways. Everyone now gets 4 chocolates instead of 5.",
            "बिल्कुल! 5 बच्चों के साथ, 20 चॉकलेट को 5 तरीकों से विभाजित किया जाता है। अब सभी को 5 के बजाय 4 चॉकलेट मिलती हैं।"
          );
        } else if (s2Children == 4) {
          msg = _t(
            "First add the 5th child. Then divide 20 chocolates by 5 children to find the new share.",
            "पहले 5वां बच्चा जोड़ें। फिर नया हिस्सा ज्ञात करने के लिए 20 चॉकलेट को 5 बच्चों से विभाजित करें।"
          );
        } else {
          msg = _t(
            "Please complete the interactions before verifying.",
            "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।"
          );
        }
        break;
      case 3:
        if (s3EquationAns == "4") {
          success = true;
          msg = _t(
            "Brilliant! 5 × 4 = 20. Because the total (20) is constant, as one number goes up, the other must go down.",
            "बहुत बढ़िया! 5 × 4 = 20। चूंकि कुल (20) स्थिर है, जब एक संख्या बढ़ती है, तो दूसरी घटनी चाहिए।"
          );
        } else if (s3EquationAns != null) {
          msg = _t(
            "Look at the top equation: 4 × 5 = 20. For the bottom equation, what number multiplied by 5 equals 20?",
            "शीर्ष समीकरण को देखें: 4 × 5 = 20। निचले समीकरण के लिए, किस संख्या को 5 से गुणा करने पर 20 आता है?"
          );
        } else {
          msg = _t(
            "Please complete the interactions before verifying.",
            "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।"
          );
        }
        break;
      case 4:
        if (s4SiteBDays == 10) {
          success = true;
          msg = _t(
            "Outstanding! Half the workers (20 to 10) means double the time (5 to 10 days). 10 × 10 = 100. You've mastered Inverse Proportion!",
            "उत्कृष्ट! आधे श्रमिक (20 से 10) का अर्थ है दोगुना समय (5 से 10 दिन)। 10 × 10 = 100। आपने प्रतिलोम समानुपात में महारत हासिल कर ली है!"
          );
        } else {
          msg = _t(
            "Site A's total work is 100. Adjust Site B's days until 10 workers × Days = 100.",
            "साइट A का कुल कार्य 100 है। साइट B के दिनों को तब तक समायोजित करें जब तक कि 10 श्रमिक × दिन = 100 न हो जाए।"
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
      _resetStepStates();
      _updateHudDefaultMessage();
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
                const Icon(Icons.sync_alt, color: Color(0xFFEAB308), size: 80),
                const SizedBox(height: 16),
                Text(
                  _t("Simulation Complete!", "सिमुलेशन पूर्ण!"),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(
                    "Congratulations! You've mastered Inverse Proportion.",
                    "बधाई हो! आपने प्रतिलोम समानुपात को समझ लिया है।"
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
                    _t("Restart Lab", "लैब पुनः प्रारंभ करें"),
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
                            label: Text(_currentStep == 4 ? _t("Finish", "समाप्त करें") : _t("Verify Step", "चरण सत्यापित करें"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
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
                        const Icon(Icons.sync_alt, size: 80, color: Color(0xFFEAB308)),
                        const SizedBox(height: 24),
                        Text(
                          _t("Inverse Proportion", "प्रतिलोम समानुपात"),
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
              _t("Inverse Proportion", "प्रतिलोम समानुपात"),
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
                    DropdownMenuItem(value: 1, child: Text(_t("Step 1: Speed vs. Time", "चरण 1: गति बनाम समय"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 2, child: Text(_t("Step 2: Distributing Chocolates", "चरण 2: चॉकलेट बांटना"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 3, child: Text(_t("Step 3: Constant Product Rule", "चरण 3: स्थिर गुणनफल नियम"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 4, child: Text(_t("Step 4: Construction Workers", "चरण 4: निर्माण श्रमिक"), style: const TextStyle(fontSize: 14, color: Colors.white))),
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
                label: Text(_currentStep == 4 ? _t("Finish", "समाप्त करें") : _t("Verify Step", "चरण सत्यापित करें"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer
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
          "Inverse Proportion happens when one value increases, and the other decreases at the exact same rate.\n\nIf you are driving a 100km route at 50 km/h, it takes 2 hours.\n\nIf you double your speed to 100 km/h, your travel time halves to just 1 hour! This is Inverse Proportion.",
          "प्रतिलोम समानुपात तब होता है जब एक मान बढ़ता है, और दूसरा उसी दर पर घटता है।\n\nयदि आप 50 किमी/घंटा की गति से 100 किमी का मार्ग चला रहे हैं, तो 2 घंटे लगते हैं।\n\nयदि आप अपनी गति को 100 किमी/घंटा तक दोगुना करते हैं, तो आपका यात्रा का समय आधा होकर केवल 1 घंटा रह जाता है! यह प्रतिलोम समानुपात है।"
        );
      case 2:
        return _t(
          "Imagine you have 20 chocolates to share equally among 4 children. Each child gets 5 chocolates (20 ÷ 4 = 5).\n\nWhat happens if a 5th child joins them?\n\nThe total number of chocolates (20) remains FIXED. As the number of children increases, the share each child receives must decrease.",
          "कल्पना करें कि आपके पास 4 बच्चों में समान रूप से बांटने के लिए 20 चॉकलेट हैं। प्रत्येक बच्चे को 5 चॉकलेट मिलती हैं (20 ÷ 4 = 5)।\n\nक्या होगा यदि 5वां बच्चा उनके साथ जुड़ जाए?\n\nचॉकलेट की कुल संख्या (20) निश्चित रहती है। जैसे-जैसे बच्चों की संख्या बढ़ती है, प्रत्येक बच्चे को मिलने वाला हिस्सा कम होना चाहिए।"
        );
      case 3:
        return _t(
          "The key to solving Inverse Proportion problems is the Constant Product Rule.\n\nIf x and y are inversely proportional, then x × y = k (a constant).\n\nIn our chocolate example: 4 children × 5 chocolates = 20. Therefore, 5 children × ? chocolates = 20.",
          "प्रतिलोम समानुपात की समस्याओं को हल करने की कुंजी स्थिर गुणनफल नियम है।\n\nयदि x और y व्युत्क्रमानुपाती हैं, तो x × y = k (एक स्थिरांक)।\n\nहमारे चॉकलेट उदाहरण में: 4 बच्चे × 5 चॉकलेट = 20। इसलिए, 5 बच्चे × ? चॉकलेट = 20।"
        );
      case 4:
        return _t(
          "Let's apply this to a real-world scenario: Work = Workers × Days.\n\nSite A completes a project with 20 workers in 5 days. Total Work = 20 × 5 = 100 man-days.\n\nSite B has the exact same 100 man-day project, but only 10 workers. How many days will it take them?",
          "आइए इसे एक वास्तविक दुनिया के परिदृश्य पर लागू करें: कार्य = श्रमिक × दिन।\n\nसाइट A 20 श्रमिकों के साथ 5 दिनों में एक परियोजना पूरी करती है। कुल कार्य = 20 × 5 = 100 मैन-डे।\n\nसाइट B के पास वही 100 मैन-डे की परियोजना है, लेकिन केवल 10 श्रमिक हैं। उन्हें कितने दिन लगेंगे?"
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
            Text(_t("Set Car Speed", "कार की गति निर्धारित करें"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Slider(
              value: s1Speed.toDouble(),
              min: 50,
              max: 100,
              divisions: 50,
              activeColor: Colors.red,
              onChanged: (val) {
                _playSound(_clickPlayer, _clickUrl);
                setState(() {
                  s1Speed = val.toInt();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("50 ${_t("km/h", "किमी/घंटा")}", style: const TextStyle(color: Colors.white54)),
                Text("100 ${_t("km/h", "किमी/घंटा")}", style: const TextStyle(color: Colors.white54)),
              ],
            )
          ],
        );
      case 2:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                   _playSound(_clickPlayer, _clickUrl);
                   setState(() => s2Children = 5);
                },
                icon: const Icon(Icons.person_add),
                label: Text(_t("Add 5th Child", "5वां बच्चा जोड़ें")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: s2Children == 5 ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDraggableItem("3", Colors.orange, Icons.cookie, id: "3", isSmall: true),
                _buildDraggableItem("4", Colors.orange, Icons.cookie, id: "4", isSmall: true),
                _buildDraggableItem("5", Colors.orange, Icons.cookie, id: "5", isSmall: true),
              ],
            )
          ],
        );
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDraggableItem("3", Colors.orange, Icons.numbers, id: "3", isSmall: true),
            _buildDraggableItem("4", Colors.orange, Icons.numbers, id: "4", isSmall: true),
            _buildDraggableItem("5", Colors.orange, Icons.numbers, id: "5", isSmall: true),
          ],
        );
      case 4:
        return Column(
          children: [
            Text(_t("Slide to find Days", "दिन खोजने के लिए स्लाइड करें"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Slider(
              value: s4SiteBDays.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: Colors.orange,
              onChanged: (val) {
                _playSound(_clickPlayer, _clickUrl);
                setState(() {
                  s4SiteBDays = val.toInt();
                });
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("1", style: TextStyle(color: Colors.white54)),
                Text("20", style: TextStyle(color: Colors.white54)),
              ],
            )
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
    // Interpolate the car position correctly using current speed (50 -> 50px, 100 -> 450px)
    double carPos = 50 + ((s1Speed - 50) / 50) * 400;
    // Formatted exact time for visual feedback based on Speed
    String timeStr = (100 / s1Speed) == 1.0 ? "1 ${_t('Hour', 'घंटा')}" : "${(100/s1Speed).toStringAsFixed(1).replaceAll('.0', '')} ${_t('Hours', 'घंटे')}";

    return Container(
      width: 600,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 4),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: Stack(
        children: [
          // Road lines
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(10, (index) => Container(width: 30, height: 4, color: Colors.white54)),
            ),
          ),
          // Car
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
            left: carPos,
            bottom: 45,
            child: const Icon(Icons.directions_car, size: 80, color: Colors.red),
          ),
          // Display Board
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDisplayPanel(_t("Speed", "गति"), "$s1Speed ${_t("km/h", "किमी/घंटा")}", Colors.blue),
                _buildDisplayPanel(_t("Time", "समय"), timeStr, Colors.orange),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDisplayPanel(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Step 2 Layout ---
  Widget _buildStep2Workspace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Box of chocolates
        Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.shade800,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.brown.shade600, width: 4),
          ),
          child: Column(
            children: [
              Text(_t("Box of 20", "20 का बॉक्स"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4, runSpacing: 4, alignment: WrapAlignment.center,
                children: List.generate(20, (index) => const Icon(Icons.cookie, color: Colors.orangeAccent, size: 24)),
              )
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Children & Dropzone
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Children
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  Text(_t("Children", "बच्चे"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      bool active = index < s2Children;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.person, size: 40, color: active ? Colors.blue : Colors.white12),
                      );
                    }),
                  )
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Dropzone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  Text(_t("Share", "हिस्सा"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DragTarget<String>(
                    onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s2ChocPerChild = d); },
                    builder: (context, candidate, rejected) {
                      return Container(
                        width: 80, height: 60,
                        decoration: BoxDecoration(
                          color: s2ChocPerChild != null ? Colors.orange : Colors.black26,
                          border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : Colors.white30, style: BorderStyle.solid, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(s2ChocPerChild ?? "?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: s2ChocPerChild != null ? Colors.black : Colors.white54)),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  // --- Step 3 Layout ---
  Widget _buildStep3Workspace() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("4 × 5 = 20", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("5 × ", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
              DragTarget<String>(
                onAccept: (d) { _playSound(_fxPlayer, _dropUrl); setState(() => s3EquationAns = d); },
                builder: (context, candidate, rejected) {
                  return Container(
                    width: 80, height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: s3EquationAns != null ? Colors.orange : Colors.black26,
                      border: Border.all(color: candidate.isNotEmpty ? Colors.yellow : Colors.white30, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(s3EquationAns ?? "?", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: s3EquationAns != null ? Colors.black : Colors.white54)),
                  );
                },
              ),
              const Text(" = 20", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          )
        ],
      ),
    );
  }

  // --- Step 4 Layout ---
  Widget _buildStep4Workspace() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Site A
        _buildSiteCard(_t("Site A", "साइट A"), 20, 5, 100),
        const SizedBox(width: 40),
        // Site B
        _buildSiteCard(_t("Site B", "साइट B"), 10, s4SiteBDays, 10 * s4SiteBDays),
      ],
    );
  }

  Widget _buildSiteCard(String name, int workers, int days, int totalWork) {
    bool isSiteB = name == _t("Site B", "साइट B");
    bool isSuccess = totalWork == 100;
    
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSiteB && isSuccess ? Colors.green : const Color(0xFF334155), width: 3),
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_t("Workers", "श्रमिक"), style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("$workers", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_t("Days", "दिन"), style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("$days", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSiteB ? Colors.orange : Colors.blue)),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Text(_t("Total Work", "कुल कार्य"), style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          Text("$totalWork ${_t("Man-Days", "मैन-डे")}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSuccess ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}