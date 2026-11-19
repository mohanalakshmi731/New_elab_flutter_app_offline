// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnitConversionLabApp());
}

class UnitConversionLabApp extends StatelessWidget {
  const UnitConversionLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Conversion & Comparison',
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
      home: const UnitConversion(),
    );
  }
}

class UnitConversion extends StatefulWidget {
  const UnitConversion({super.key});

  @override
  State<UnitConversion> createState() => _UnitConversionState();
}

class _UnitConversionState extends State<UnitConversion> {
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
  bool s1SachetDivided = false;
  bool s1BottleDivided = false;
  String? s1SachetLabel;
  String? s1BottleLabel;

  // --- Step 2 State ---
  bool s2HimachalMultiplied = false;
  String? s2HimachalLabel;
  String? s2MeghalayaLabel;

  // --- Step 3 State ---
  final TextEditingController s3AreaCtrl = TextEditingController();
  final TextEditingController s3ManureCtrl = TextEditingController();

  // --- Step 4 State ---
  bool s4CoinSplit = false;
  int s4CopperGrams = 0;
  int s4NickelGrams = 0;
  List<String> s4AvailableChunks = ['2g', '2g', '2g', '2g'];

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
    s3AreaCtrl.dispose();
    s3ManureCtrl.dispose();
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
    s1SachetDivided = false;
    s1BottleDivided = false;
    s1SachetLabel = null;
    s1BottleLabel = null;

    s2HimachalMultiplied = false;
    s2HimachalLabel = null;
    s2MeghalayaLabel = null;

    s3AreaCtrl.clear();
    s3ManureCtrl.clear();

    s4CoinSplit = false;
    s4CopperGrams = 0;
    s4NickelGrams = 0;
    s4AvailableChunks = ['2g', '2g', '2g', '2g'];
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
        if (s1SachetDivided && s1BottleDivided && s1SachetLabel == "Best Value") {
          success = true;
          msg = _t(
            "Surprise! The sachet costs ₹0.40/mL, while the bulk bottle costs ₹0.50/mL. The tiny sachet is actually the better deal!",
            "आश्चर्य! पाउच की कीमत ₹0.40/mL है, जबकि बड़ी बोतल की कीमत ₹0.50/mL है। छोटा पाउच वास्तव में बेहतर सौदा है!"
          );
        } else if (s1SachetDivided || s1BottleDivided || s1SachetLabel != null || s1BottleLabel != null) {
          msg = _t(
            "Wait! The Best Value is the item that costs *less* per mL. Compare carefully and place the sticker on the lower value.",
            "रुको! बेस्ट वैल्यू वह वस्तु है जिसकी कीमत प्रति mL *कम* है। ध्यान से तुलना करें।"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
      case 2:
        if (s2HimachalMultiplied && s2HimachalLabel == "More Expensive" && s2MeghalayaLabel == "Cheaper") {
          success = true;
          msg = _t(
            "Perfect conversion! By standardizing the weight to 1kg, Himachal tea costs ₹1000/kg, making it more expensive than Meghalaya's ₹800/kg.",
            "परफेक्ट! वजन को 1 किग्रा तक मानकीकृत करके, हिमाचल चाय ₹1000/किग्रा है, जो मेघालय की तुलना में अधिक महंगी है।"
          );
        } else if (s2HimachalMultiplied || s2HimachalLabel != null || s2MeghalayaLabel != null) {
          msg = _t(
            "Look at the final prices per kg! Drag the labels to the correct boxes based on the standardized 1kg price.",
            "प्रति किलोग्राम अंतिम कीमतों को देखें! मानकीकृत 1 किग्रा मूल्य के आधार पर लेबलों को सही बक्सों में खींचें।"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
        }
        break;
      case 3:
        if (s3AreaCtrl.text.trim() == "100000" && s3ManureCtrl.text.trim() == "23") {
          success = true;
          msg = _t(
            "Excellent! 100,000 sq ft is ~2.3 acres. At 10 tonnes/acre, the farmer needs 23 tonnes of manure.",
            "उत्कृष्ट! 100,000 वर्ग फुट ~2.3 एकड़ है। 10 टन/एकड़ के हिसाब से 23 टन खाद चाहिए।"
          );
        } else if (s3AreaCtrl.text.isNotEmpty || s3ManureCtrl.text.isNotEmpty) {
          msg = _t(
            "Check your math. Multiply 200 by 500 to find area, divide by 43560, then multiply the resulting acres by 10.",
            "अपने गणित की जाँच करें। 200 को 500 से गुणा करें और फिर खाद निकालें।"
          );
        } else {
          msg = _t("Please enter the calculations before verifying.", "कृपया सत्यापित करने से पहले गणना दर्ज करें।");
        }
        break;
      case 4:
        if (s4CopperGrams == 6 && s4NickelGrams == 2) {
          success = true;
          msg = _t(
            "Masterful metallurgy! 8g divided in 3:1 ratio means 6g Copper and 2g Nickel. Total metal value is exactly ₹5.",
            "उत्कृष्ट! 6g कॉपर और 2g निकेल। कुल धातु का मूल्य सिर्फ ₹5 है।"
          );
        } else if (s4CopperGrams > 0 || s4NickelGrams > 0 || s4CoinSplit) {
          msg = _t(
            "Wait! A 3:1 ratio means 4 total parts. Distribute the 2g chunks correctly (3 parts for Copper, 1 part for Nickel).",
            "रुको! 3:1 अनुपात का अर्थ है 4 कुल भाग। वज़न को सही ढंग से वितरित करें।"
          );
        } else {
          msg = _t("Please complete the interactions before verifying.", "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।");
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration, color: Color(0xFFEAB308), size: 80),
                const SizedBox(height: 16),
                Text(
                  _t("Congratulations!", "बधाई हो!"),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(
                    "You have successfully mastered Unit Conversions & Comparisons.",
                    "आपने इकाई रूपांतरण और तुलना में सफलतापूर्वक महारत हासिल कर ली है।"
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
    final sidebarWidth = screenWidth * 0.38;

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
                bottom: 90, // Leave room for the HUD feedback
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
                            label: Text(_t("Verify Task", "सत्यापित करें"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
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
                        const Icon(Icons.biotech, size: 80, color: Color(0xFFEAB308)),
                        const SizedBox(height: 24),
                        const Text(
                          "Unit Conversion & Comparison",
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Class 8 • Proportional Reasoning-2",
                          style: TextStyle(fontSize: 24, color: Colors.white70),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _enterLab,
                          icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                          label: const Text(
                            "Enter Lab",
                            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
  // SIDEBAR (Fully Scrollable)
  // =========================================================================
  Widget _buildSidebar() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0, bottom: 20, left: 20, right: 20), // Top padding avoids menu button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Header
            const Text(
              "Unit Conversion & Comparison",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              "Class 8 • Proportional Reasoning-2",
              style: TextStyle(fontSize: 14, color: Colors.white60),
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
                    DropdownMenuItem(value: 1, child: Text(_t("Step 1: Shampoo Bottles", "चरण 1: शैम्पू की बोतलें"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 2, child: Text(_t("Step 2: Tea Price", "चरण 2: चाय की कीमत"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 3, child: Text(_t("Step 3: Farming Area", "चरण 3: खेती (क्षेत्रफल)"), style: const TextStyle(fontSize: 14, color: Colors.white))),
                    DropdownMenuItem(value: 4, child: Text(_t("Step 4: Alloy Cost", "चरण 4: मिश्र धातु लागत"), style: const TextStyle(fontSize: 14, color: Colors.white))),
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
                label: Text(_t("Verify Task", "कार्य सत्यापित करें"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer (untouched translation as per prompt)
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
          "Consumers often assume that buying in bulk is always cheaper. Let's mathematically test this assumption! We have a 5mL shampoo sachet that costs ₹2, and a 200mL bulk bottle that costs ₹100. To find the true 'Value for Money', we must calculate the Unit Rate—the exact price for just 1mL of shampoo for both items.",
          "उपभोक्ता अक्सर मानते हैं कि थोक में खरीदना हमेशा सस्ता होता है। आइए गणितीय रूप से इसका परीक्षण करें! हमारे पास एक 5mL शैम्पू पाउच है जिसकी कीमत ₹2 है, और एक 200mL बोतल है जिसकी कीमत ₹100 है। सही 'पैसे का मूल्य' खोजने के लिए, हमें यूनिट दर की गणना करनी चाहिए—दोनों वस्तुओं के लिए केवल 1mL शैम्पू की सटीक कीमत।"
        );
      case 2: 
        return _t(
          "Let's compare the prices of two different tea brands. Himachal tea is sold in 200g packets for ₹200. Meghalaya tea is sold in 1kg packets for ₹800. We cannot compare 200g directly to 1kg accurately. We must scale the Himachal tea up so both are measured in kilograms (1000g). Since 1000 ÷ 200 = 5, we must multiply the Himachal quantity and price by 5.",
          "आइए दो अलग-अलग चाय ब्रांडों की कीमतों की तुलना करें। हिमाचल चाय 200 ग्राम के पैकेट में ₹200 में बेची जाती है। मेघालय चाय 1 किलोग्राम के पैकेट में ₹800 में बेची जाती है। हम 200 ग्राम की 1 किलोग्राम से सीधे सटीक तुलना नहीं कर सकते। हमें हिमाचल चाय को बढ़ाना होगा ताकि दोनों को किलोग्राम (1000 ग्राम) में मापा जा सके। चूँकि 1000 ÷ 200 = 5 है, हमें हिमाचल की मात्रा और कीमत को 5 से गुणा करना होगा।"
        );
      case 3: 
        return _t(
          "A farmer applies 10 tonnes of manure per acre. He has a rectangular plot measuring 200 ft by 500 ft.\n\nTo find out how much manure he needs, we first calculate the area in square feet, convert that to acres (1 Acre ≈ 43,560 sq ft), and then multiply by the 10 tonnes per acre rate!",
          "एक किसान प्रति एकड़ 10 टन खाद डालता है। उसके पास 200 फीट गुणा 500 फीट का एक आयताकार भूखंड है।\n\nउसे कितनी खाद की आवश्यकता है, यह जानने के लिए, हम पहले वर्ग फुट में क्षेत्रफल की गणना करते हैं, इसे एकड़ में बदलते हैं (1 एकड़ ≈ 43,560 वर्ग फुट), और फिर 10 टन प्रति एकड़ की दर से गुणा करते हैं!"
        );
      case 4: 
        return _t(
          "A ₹10 coin weighs 8 grams. It is an alloy made of Copper and Nickel in a 3:1 ratio.\n\nIf Copper costs ₹0.5 per gram and Nickel costs ₹1.0 per gram, what is the total metal value of the coin?\n\nFirst, we must use the ratio to find the exact weight of each individual metal in the coin.",
          "एक ₹10 के सिक्के का वजन 8 ग्राम है। यह कॉपर (तांबा) और निकेल का मिश्र धातु है जो 3:1 के अनुपात में है।\n\nयदि कॉपर की कीमत ₹0.5 प्रति ग्राम और निकेल की कीमत ₹1.0 प्रति ग्राम है, तो सिक्के का कुल धातु मूल्य क्या है?\n\nसबसे पहले, हमें सिक्के में प्रत्येक धातु का सटीक वजन खोजने के लिए अनुपात का उपयोग करना चाहिए।"
        );
      default: return "";
    }
  }

  Widget _buildSidebarTools() {
    switch (_currentStep) {
      case 1:
        return Column(
          children: [
            _buildDraggableItem(_t("÷ Divider", "÷ डिवाइडर"), Colors.indigo, Icons.safety_divider, id: "÷ Divider"),
            const SizedBox(height: 12),
            _buildDraggableItem(_t("Best Value", "बेस्ट वैल्यू"), const Color(0xFFEAB308), Icons.star, textColor: Colors.black, id: "Best Value"),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildDraggableItem(_t("×5", "×5"), Colors.indigo, Icons.close, id: "×5"),
            const SizedBox(height: 12),
            _buildDraggableItem(_t("More Expensive", "अधिक महंगी"), Colors.red, Icons.arrow_upward, id: "More Expensive"),
            const SizedBox(height: 12),
            _buildDraggableItem(_t("Cheaper", "सस्ती"), Colors.green, Icons.arrow_downward, id: "Cheaper"),
          ],
        );
      case 3:
        return Column(
          children: [
            _buildInputRow(_t("Area (L×W)", "क्षेत्रफल (L×W)"), _t("sq ft", "वर्ग फीट"), s3AreaCtrl),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t("Area ÷ 43560 =", "क्षेत्रफल ÷ 43560 ="), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  Text(s3AreaCtrl.text == "100000" ? _t("~2.3 Acres", "~2.3 एकड़") : "?", 
                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInputRow(_t("Total Manure", "कुल खाद"), _t("Tonnes", "टन"), s3ManureCtrl),
          ],
        );
      case 4:
        return Column(
          children: [
            _buildDraggableItem(_t("3:1 Splitter", "3:1 स्प्लिटर"), Colors.indigo, Icons.cut, id: "3:1 Splitter"),
            const SizedBox(height: 12),
            if (s4CoinSplit)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: s4AvailableChunks.map((chunk) => _buildDraggableItem(chunk, Colors.orange, Icons.circle, isSmall: true, id: chunk)).toList(),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
              child: Column(
                children: [
                  Text(_t("Intrinsic Value", "धातु मूल्य"), style: const TextStyle(color: Colors.greenAccent)),
                  const SizedBox(height: 8),
                  Text("₹${(s4CopperGrams * 0.5) + (s4NickelGrams * 1.0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDraggableItem(String label, Color bgColor, IconData icon, {Color textColor = Colors.white, bool isSmall = false, required String id}) {
    final child = Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12, horizontal: isSmall ? 16 : 0),
      width: isSmall ? null : double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isSmall) Icon(icon, color: textColor, size: 20),
          if (!isSmall) const SizedBox(width: 8),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16)),
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
          child: SizedBox(
            width: isSmall ? 80 : 200, 
            child: child
          )
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }

  Widget _buildInputRow(String label, String unit, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEAB308)),
                  decoration: InputDecoration(
                    border: InputBorder.none, 
                    hintText: _t("Enter value", "मान दर्ज करें"),
                    hintStyle: const TextStyle(color: Colors.white30)
                  ),
                  onChanged: (v) => setState((){}),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFF334155)))),
                child: Text(unit, style: const TextStyle(color: Colors.white60)),
              )
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
          right: _isSidebarOpen ? 24 : 290, // Dynamic padding to avoid floating tools overlap
          top: 40, 
          bottom: 80
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
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
            );
          }
        ),
      ),
    );
  }

  // --- Step 1 Layout ---
  Widget _buildStep1Workspace() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sachet Card
        _buildItemCard(
          title: _t("5mL Sachet", "5mL पाउच"), price: _t("Price: ₹2", "कीमत: ₹2"), color: Colors.orange, size: const Size(60, 90), topLabel: "5mL",
          isDivided: s1SachetDivided,
          dividedText: "₹0.40 / mL",
          labelTargetVal: s1SachetLabel == "Best Value" ? _t("Best Value", "बेस्ट वैल्यू") : s1SachetLabel,
          onDivideDrop: (d) { 
            if (d == "÷ Divider") {
              _playSound(_fxPlayer, _dropUrl);
              setState(() => s1SachetDivided = true);
            }
          },
          onLabelDrop: (d) { 
            if (d == "Best Value" || d == "More Expensive" || d == "Cheaper") {
              _playSound(_fxPlayer, _dropUrl);
              setState(() => s1SachetLabel = d);
            }
          }
        ),
        const SizedBox(width: 40),
        // Bottle Card
        _buildItemCard(
          title: _t("200mL Bottle", "200mL बोतल"), price: _t("Price: ₹100", "कीमत: ₹100"), color: Colors.blue, size: const Size(120, 180), topLabel: "200mL",
          isDivided: s1BottleDivided,
          dividedText: "₹0.50 / mL",
          labelTargetVal: s1BottleLabel == "Best Value" ? _t("Best Value", "बेस्ट वैल्यू") : s1BottleLabel,
          onDivideDrop: (d) { 
            if (d == "÷ Divider") {
               _playSound(_fxPlayer, _dropUrl);
               setState(() => s1BottleDivided = true);
            }
          },
          onLabelDrop: (d) { 
            if (d == "Best Value" || d == "More Expensive" || d == "Cheaper") {
              _playSound(_fxPlayer, _dropUrl);
              setState(() => s1BottleLabel = d);
            }
          }
        ),
      ],
    );
  }

  // --- Step 2 Layout ---
  Widget _buildStep2Workspace() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Himachal
        _buildItemCard(
          title: _t("Himachal Tea", "हिमाचल चाय"), price: s2HimachalMultiplied ? "1kg (₹1000)" : "200g (₹200)", priceColor: s2HimachalMultiplied ? Colors.green : Colors.white70, color: Colors.green.shade700, size: const Size(90, 120), topLabel: "200g", icon: Icons.eco,
          isDivided: s2HimachalMultiplied,
          dividedText: "1kg (₹1000)",
          hideDividePlaceholder: !s2HimachalMultiplied,
          labelTargetVal: s2HimachalLabel == "More Expensive" ? _t("More Expensive", "अधिक महंगी") : (s2HimachalLabel == "Cheaper" ? _t("Cheaper", "सस्ती") : s2HimachalLabel),
          onDivideDrop: (d) { 
            if (d == "×5") {
               _playSound(_fxPlayer, _dropUrl);
               setState(() => s2HimachalMultiplied = true);
            }
          },
          onLabelDrop: (d) { 
            if (d == "More Expensive" || d == "Cheaper") {
               _playSound(_fxPlayer, _dropUrl);
               setState(() => s2HimachalLabel = d);
            }
          }
        ),
        const SizedBox(width: 40),
        // Meghalaya
        _buildItemCard(
          title: _t("Meghalaya Tea", "मेघालय चाय"), price: "1kg (₹800)", priceColor: Colors.green, color: Colors.teal.shade800, size: const Size(150, 200), topLabel: "1kg", icon: Icons.eco,
          isDivided: true,
          dividedText: "1kg (₹800)",
          hideDividePlaceholder: true,
          labelTargetVal: s2MeghalayaLabel == "More Expensive" ? _t("More Expensive", "अधिक महंगी") : (s2MeghalayaLabel == "Cheaper" ? _t("Cheaper", "सस्ती") : s2MeghalayaLabel),
          onDivideDrop: (d) {},
          onLabelDrop: (d) { 
            if (d == "More Expensive" || d == "Cheaper") {
               _playSound(_fxPlayer, _dropUrl);
               setState(() => s2MeghalayaLabel = d);
            }
          }
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String title, required String price, required Color color, required Size size, required String topLabel, IconData? icon,
    required bool isDivided, required String dividedText, required String? labelTargetVal,
    required Function(String) onDivideDrop, required Function(String) onLabelDrop,
    bool hideDividePlaceholder = false, Color priceColor = Colors.white70
  }) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF334155)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            width: size.width, height: size.height,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3), width: 4))),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: Colors.white54, size: size.width * 0.4),
                Text(topLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          const Divider(color: Color(0xFF334155)),
          Text(price, style: TextStyle(color: priceColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Top Drop Target (Divider/Multiplier)
          if (!hideDividePlaceholder || !isDivided)
            DragTarget<String>(
              onAccept: onDivideDrop,
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty ? const Color(0xFFEAB308).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    border: Border.all(color: candidateData.isNotEmpty ? const Color(0xFFEAB308) : const Color(0xFF334155), style: isDivided ? BorderStyle.solid : BorderStyle.none),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(isDivided ? dividedText : "₹ [ ? ]", style: const TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                );
              },
            ),
          
          const SizedBox(height: 12),
          
          // Bottom Drop Target (Labels)
          DragTarget<String>(
            onAccept: onLabelDrop,
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: labelTargetVal != null ? (labelTargetVal == _t("Best Value", "बेस्ट वैल्यू") ? const Color(0xFFEAB308) : Colors.indigo) : Colors.white.withOpacity(0.05),
                  border: Border.all(color: candidateData.isNotEmpty ? const Color(0xFFEAB308) : const Color(0xFF334155), style: labelTargetVal != null ? BorderStyle.solid : BorderStyle.none),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(labelTargetVal ?? _t("Drop Label Here", "यहाँ लेबल रखें"), style: TextStyle(color: labelTargetVal != null ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Step 3 Layout ---
  Widget _buildStep3Workspace() {
    return Container(
      width: 500, height: 250,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        border: Border.all(color: Colors.green, width: 4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.agriculture, size: 100, color: Colors.green)),
          Positioned(
            top: 8, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(4)),
                child: Text(_t("LENGTH = 500 ft", "लंबाई = 500 फीट"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ),
            ),
          ),
          Positioned(
            left: -40, top: 110,
            child: Transform.rotate(
              angle: -1.5708,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(4)),
                child: Text(_t("WIDTH = 200 ft", "चौड़ाई = 200 फीट"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 4 Layout ---
  Widget _buildStep4Workspace() {
    return Column(
      children: [
        // Coin area
        DragTarget<String>(
          onAccept: (d) { 
            if (d == "3:1 Splitter") {
               _playSound(_fxPlayer, _dropUrl);
               setState(() => s4CoinSplit = true);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: candidateData.isNotEmpty ? const Color(0xFFEAB308).withOpacity(0.2) : const Color(0xFF0F172A),
                border: Border.all(color: candidateData.isNotEmpty ? Colors.white : const Color(0xFFEAB308), width: 4),
                boxShadow: const [BoxShadow(color: Colors.yellow, blurRadius: 20)],
              ),
              alignment: Alignment.center,
              child: s4CoinSplit 
                  ? Text(_t("Split\nApplied", "अलग\nकिया गया"), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_t("₹10 Coin (8g)", "₹10 सिक्का (8g)"), style: const TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Icon(Icons.monetization_on, color: Color(0xFFEAB308), size: 48),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 40),
        
        // Bowls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Copper
            _buildBowl(_t("Copper (₹0.5/g)", "कॉपर (₹0.5/g)"), Colors.orange, s4CopperGrams, (d) {
              if (d == "2g") {
                _playSound(_fxPlayer, _dropUrl);
                setState(() { s4CopperGrams += 2; s4AvailableChunks.removeLast(); });
              }
            }),
            const SizedBox(width: 40),
            // Nickel
            _buildBowl(_t("Nickel (₹1.0/g)", "निकेल (₹1.0/g)"), Colors.grey, s4NickelGrams, (d) {
              if (d == "2g") {
                _playSound(_fxPlayer, _dropUrl);
                setState(() { s4NickelGrams += 2; s4AvailableChunks.removeLast(); });
              }
            }),
          ],
        )
      ],
    );
  }

  Widget _buildBowl(String title, Color color, int grams, Function(String) onDrop) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        DragTarget<String>(
          onAccept: onDrop,
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 140, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, color.withOpacity(0.2)]),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(70), bottomRight: Radius.circular(70)),
                border: Border(bottom: BorderSide(color: color, width: 4), left: BorderSide(color: color, width: 4), right: BorderSide(color: color, width: 4)),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(grams > 0 ? "${grams}g" : "?", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
            );
          },
        ),
      ],
    );
  }
}