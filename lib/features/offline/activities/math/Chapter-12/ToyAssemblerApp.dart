// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;

// --- AUDIO MANAGER ---
class AudioManager {
  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback on Android
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  static Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource(_clickUrl));
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    try {
      await _successPlayer.stop();
      await _successPlayer.play(AssetSource(_successUrl));
    } catch (_) {}
  }

  static Future<void> playError() async {
    try {
      await _errorPlayer.stop();
      await _errorPlayer.play(AssetSource(_errorUrl));
    } catch (_) {}
  }

  static Future<void> playShutter() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.play(AssetSource(_shutterUrl));
    } catch (_) {}
  }
}

const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);
const Color accentYellow = Color(0xFFFACC15);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE TOY ASSEMBLER',
      'tagline': 'Surface Area of Combined Solids',
      'init_btn': 'INITIALIZE WORKSHOP',
      'header_title': 'The Toy Assembler',
      'header_subtitle': 'Class 10 • Surface Areas & Volumes',
      'phase_label': 'ASSEMBLY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Assembly Complete',
      'success_desc':
          'You have successfully calculated the total surface area of the combined solid toy!',
      'btn_restart': 'NEW ASSEMBLY',
      's0': 'Initialize Workspace. Load components.',
      's1':
          'Identify given dimensions: Total Height (15.5cm) & Radius (3.5cm).',
      's2': 'Analyze Hemisphere: Height equals its radius (3.5cm).',
      's3': 'Calculate Cone Height: h = Total - Radius (15.5 - 3.5 = 12cm).',
      's4': 'Identify need for Slant Height (l) of the cone.',
      's5': 'Calculate l: √(3.5² + 12²) = 12.5cm.',
      's6': 'Compute CSA of Hemisphere (2πr²).',
      's7': 'Compute CSA of Cone (πrl).',
      's8': 'Assemble Toy: Combine the components.',
      's9': 'Calculate Total Surface Area of the Toy.',
      'btn_start': 'LOAD COMPONENTS',
      'btn_dims': 'MARK DIMENSIONS',
      'btn_hemi': 'ANALYZE HEMISPHERE',
      'btn_cone_h': 'CALCULATE CONE HEIGHT',
      'btn_slant_id': 'IDENTIFY SLANT HEIGHT',
      'btn_slant_calc': 'CALCULATE l',
      'btn_csa_hemi': 'CALC HEMISPHERE CSA',
      'btn_csa_cone': 'CALC CONE CSA',
      'btn_assemble': 'ASSEMBLE TOY',
      'btn_total_area': 'VERIFY TOTAL AREA',
      'msg_obs_ok': 'Components loaded. Blueprint active.',
      'msg_dims_ok': 'Radius = 3.5cm. Total Height = 15.5cm.',
      'msg_hemi_ok': 'Hemisphere depth identified as 3.5cm.',
      'msg_cone_ok': 'Cone height h = 12cm.',
      'msg_slant_id_ok': 'Slant height l = √(r² + h²) required for CSA.',
      'msg_slant_calc_ok': 'Slant height l = 12.5cm.',
      'msg_csa_hemi_ok': 'Hemisphere CSA = 77 cm².',
      'msg_csa_cone_ok': 'Cone CSA = 137.5 cm².',
      'msg_assemble_ok': 'Components combined. Bases are hidden.',
      'msg_final_ok': 'Total Surface Area = 214.5 cm².',
      'msg_err': 'Calculation error. Check your math.',
      'q_solve_total': 'TSA = 77 + 137.5 = ?',
      // Calculations Panel Strings
      'calc_title': 'Calculations & Data',
      'awaiting_specs': 'Awaiting component analysis...',
      'hemi_csa_title': '1. Hemisphere CSA',
      'hemi_csa_form': 'CSA = 2πr²',
      'hemi_csa_sub': '= 2 × (22/7) × 3.5²',
      'hemi_csa_res': '= 77 cm²',
      'cone_csa_title': '2. Cone CSA',
      'cone_csa_form': 'CSA = πrl',
      'cone_csa_sub': '= (22/7) × 3.5 × 12.5',
      'cone_csa_res': '= 137.5 cm²',
      'tsa_title': '3. Total Surface Area',
      'tsa_form': 'TSA = CSA(Hemi) + CSA(Cone)',
      'tsa_sub': 'TSA = 77 + 137.5',
      'tsa_res': '= 214.5 cm²',
    },
    'hi': {
      'app_title': 'खिलौना असेंबलर',
      'tagline': 'संयुक्त ठोसों का पृष्ठीय क्षेत्रफल',
      'init_btn': 'वर्कशॉप प्रारंभ करें',
      'header_title': 'खिलौना असेंबलर',
      'header_subtitle': 'कक्षा 10 • पृष्ठीय क्षेत्रफल और आयतन',
      'phase_label': 'असेंबली चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'असेंबली पूर्ण',
      'success_desc':
          'आपने संयुक्त ठोस खिलौने के कुल पृष्ठीय क्षेत्रफल की सफलतापूर्वक गणना कर ली है!',
      'btn_restart': 'नई असेंबली',
      's0': 'कार्यक्षेत्र प्रारंभ करें। घटक लोड करें।',
      's1': 'दिए गए आयामों को पहचानें: कुल ऊंचाई (15.5cm) और त्रिज्या (3.5cm)।',
      's2':
          'गोलार्ध का विश्लेषण करें: ऊँचाई इसकी त्रिज्या (3.5cm) के बराबर होती है।',
      's3':
          'शंकु की ऊंचाई की गणना करें: h = कुल - त्रिज्या (15.5 - 3.5 = 12cm)।',
      's4': 'शंकु की तिर्यक ऊंचाई (l) की आवश्यकता को पहचानें।',
      's5': 'l की गणना करें: √(3.5² + 12²) = 12.5cm.',
      's6': 'गोलार्ध के CSA की गणना करें (2πr²)।',
      's7': 'शंकु के CSA की गणना करें (πrl)।',
      's8': 'खिलौना असेंबल करें: घटकों को मिलाएं।',
      's9': 'खिलौने के कुल पृष्ठीय क्षेत्रफल की गणना करें।',
      'btn_start': 'घटक लोड करें',
      'btn_dims': 'आयाम चिह्नित करें',
      'btn_hemi': 'गोलार्ध का विश्लेषण करें',
      'btn_cone_h': 'शंकु की ऊंचाई की गणना करें',
      'btn_slant_id': 'तिर्यक ऊंचाई पहचानें',
      'btn_slant_calc': 'l की गणना करें',
      'btn_csa_hemi': 'गोलार्ध CSA की गणना करें',
      'btn_csa_cone': 'शंकु CSA की गणना करें',
      'btn_assemble': 'खिलौना असेंबल करें',
      'btn_total_area': 'कुल क्षेत्रफल सत्यापित करें',
      'msg_obs_ok': 'घटक लोड किए गए। खाका सक्रिय।',
      'msg_dims_ok': 'त्रिज्या = 3.5cm. कुल ऊंचाई = 15.5cm.',
      'msg_hemi_ok': 'गोलार्ध की गहराई 3.5cm के रूप में पहचानी गई।',
      'msg_cone_ok': 'शंकु की ऊँचाई h = 12cm.',
      'msg_slant_id_ok': 'CSA के लिए तिर्यक ऊंचाई l = √(r² + h²) आवश्यक है।',
      'msg_slant_calc_ok': 'तिर्यक ऊंचाई l = 12.5cm.',
      'msg_csa_hemi_ok': 'गोलार्ध CSA = 77 cm².',
      'msg_csa_cone_ok': 'शंकु CSA = 137.5 cm².',
      'msg_assemble_ok': 'घटक संयुक्त। आधार छिपे हुए हैं।',
      'msg_final_ok': 'कुल पृष्ठीय क्षेत्रफल = 214.5 cm².',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      'q_solve_total': 'TSA = 77 + 137.5 = ?',
      // Calculations Panel Strings
      'calc_title': 'गणनाएँ एवं डेटा',
      'awaiting_specs': 'घटक विश्लेषण की प्रतीक्षा में...',
      'hemi_csa_title': '1. गोलार्ध CSA',
      'hemi_csa_form': 'CSA = 2πr²',
      'hemi_csa_sub': '= 2 × (22/7) × 3.5²',
      'hemi_csa_res': '= 77 cm²',
      'cone_csa_title': '2. शंकु CSA',
      'cone_csa_form': 'CSA = πrl',
      'cone_csa_sub': '= (22/7) × 3.5 × 12.5',
      'cone_csa_res': '= 137.5 cm²',
      'tsa_title': '3. कुल पृष्ठीय क्षेत्रफल',
      'tsa_form': 'TSA = CSA(गोलार्ध) + CSA(शंकु)',
      'tsa_sub': 'TSA = 77 + 137.5',
      'tsa_res': '= 214.5 cm²',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ToyAssemblerApp extends StatefulWidget {
  const ToyAssemblerApp({super.key});

  @override
  State<ToyAssemblerApp> createState() => _ToyAssemblerAppState();
}

class _ToyAssemblerAppState extends State<ToyAssemblerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Panels State
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Animation State
  double assemblyProgress = 0.0;
  late AnimationController _assemblyController;
  late Animation<double> _assemblyAnimation;

  // Input Controllers
  final TextEditingController _inpAns = TextEditingController();

  @override
  void initState() {
    super.initState();
    _assemblyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _assemblyController.dispose();
    _inpAns.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void startGame() {
    AudioManager.playShutter();
    setState(() {
      hasStarted = true;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
    });
  }

  void switchLang(String newLang) {
    AudioManager.playClick();
    setState(() {
      lang = newLang;
    });
  }

  void toggleLeftPanel() {
    AudioManager.playClick();
    setState(() {
      isLeftPanelOpen = !isLeftPanelOpen;
      if (isLeftPanelOpen) isRightPanelOpen = false;
    });
  }

  void toggleRightPanel() {
    AudioManager.playClick();
    setState(() {
      isRightPanelOpen = !isRightPanelOpen;
      if (isRightPanelOpen) isLeftPanelOpen = false;
    });
  }

  void showToast(
    String message, {
    bool isError = false,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isError
                  ? accentRed
                  : (isSuccess ? accentGreen : accentBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgPanel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? accentRed : (isSuccess ? accentGreen : accentBlue),
            width: 2,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void advanceStep(String msgKey) {
    if (currentStep < 10) {
      AudioManager.playClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Trigger animations
        if (currentStep == 9) {
          // Assembly happens after step 8 button is clicked
          _animateAssembly();
        }

        _inpAns.clear();

        if (currentStep == 10) {
          AudioManager.playSuccess();
          Timer(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              showSuccessModal = true;
            });
            // Auto dismiss after 5 seconds
            Timer(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  showSuccessModal = false;
                });
              }
            });
          });
        }
      });
    }
  }

  void _animateAssembly() {
    _assemblyAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _assemblyController,
            curve: Curves.easeInOutBack,
          ),
        )..addListener(() {
          setState(() {
            assemblyProgress = _assemblyAnimation.value;
          });
        });
    _assemblyController.forward(from: 0.0);
  }

  void verifyInput(String expectedValue, String successMsgKey) {
    if (_inpAns.text.trim() == expectedValue) {
      advanceStep(successMsgKey);
      if (!isRightPanelOpen) toggleRightPanel();
    } else {
      AudioManager.playError();
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void resetLab() {
    AudioManager.playError();
    setState(() {
      currentStep = 0;
      assemblyProgress = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      lang = 'en'; // Reset translation to en
      _inpAns.clear();
      _assemblyController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Scaffold(
          backgroundColor: bgDark,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.toys, size: 80, color: accentPink),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get(lang, 'app_title'),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: accentPink,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.get(lang, 'tagline'),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: startGame,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Text(
                      AppStrings.get(lang, 'init_btn'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // 1. CANVAS AREA
            Positioned.fill(child: _buildInteractiveCanvas()),

            // 2. FLOATING MISSION CARD
            if (!isLeftPanelOpen)
              Positioned(top: 85, left: 20, child: _buildFloatingCard()),

            // 3. RIGHT PANEL (Calculations)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: isRightPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildRightPanel(),
            ),

            // 4. LEFT PANEL (Mission/Controls)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildLeftPanel(),
            ),

            // 5. FRONT SCREEN FIXED FLOATING BUTTONS
            Positioned(
              top: 20,
              left: 20,
              child: _buildFloatingActionBtn(
                icon: isLeftPanelOpen ? Icons.menu_open : Icons.menu,
                onTap: toggleLeftPanel,
                color: accentPink,
                tooltip: 'Menu',
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFloatingActionBtn(
                icon: isRightPanelOpen ? Icons.close : Icons.data_usage_rounded,
                onTap: toggleRightPanel,
                color: accentBlue,
                tooltip: 'Data / Calculations',
              ),
            ),

            // SUCCESS MODAL
            if (showSuccessModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: bgDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentGreen, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: accentGreen.withOpacity(0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              color: accentGreen,
                              size: 80,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.get(lang, 'badge_title').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.get(lang, 'success_desc'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
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
    );
  }

  Widget _buildFloatingActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: bgPanel.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        ),
        elevation: 10,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get(lang, 'active_mission').toUpperCase(),
                style: const TextStyle(
                  color: accentPink,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${currentStep >= 10 ? 10 : currentStep + 1}/10",
                  style: const TextStyle(
                    color: accentBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentStep >= 10
                ? AppStrings.get(lang, 'badge_title')
                : AppStrings.get(lang, 's$currentStep'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildControlsArea(),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel,
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 75, 15, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.architecture, color: bgDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get(
                                lang,
                                'header_title',
                              ).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.get(lang, 'header_subtitle'),
                              style: const TextStyle(
                                color: accentPink,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LangBtn(
                              title: 'EN',
                              isActive: lang == 'en',
                              onTap: () => switchLang('en'),
                            ),
                            _LangBtn(
                              title: 'HI',
                              isActive: lang == 'hi',
                              onTap: () => switchLang('hi'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.power_settings_new),
                        color: Colors.white54,
                        iconSize: 24,
                        onPressed: resetLab,
                        tooltip: 'Restart Lab',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            // Moved Objective block above Phase block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black45,
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get(lang, 'active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: accentPink,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStep >= 10
                        ? AppStrings.get(lang, 'badge_title')
                        : AppStrings.get(lang, 's$currentStep'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildControlsArea(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get(lang, 'phase_label'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${currentStep >= 10 ? 10 : currentStep + 1}/10",
                        style: const TextStyle(
                          color: accentBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (currentStep >= 10 ? 10 : currentStep + 1) / 10,
                    backgroundColor: Colors.black38,
                    color: accentPink,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppStrings.get(lang, 'mission_log').toUpperCase(),
                      style: const TextStyle(
                        color: accentPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        bool isActive = index == currentStep;
                        bool isDone = index < currentStep;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? accentPink.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isActive
                                    ? accentPink
                                    : isDone
                                    ? accentGreen
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            "${index + 1}. ${AppStrings.get(lang, 's$index')}",
                            style: TextStyle(
                              color: isActive
                                  ? accentPink
                                  : isDone
                                  ? Colors.white54
                                  : Colors.white30,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel,
        border: const Border(left: BorderSide(color: Colors.white12, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Row(
              children: [
                const Icon(Icons.data_usage, color: accentBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.get(lang, 'calc_title').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep >= 7) ...[
                    // 1. Hemisphere CSA
                    Text(
                      AppStrings.get(lang, 'hemi_csa_title'),
                      style: const TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'hemi_csa_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'hemi_csa_sub'),
                      Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'hemi_csa_res'),
                      accentGreen,
                      isBold: true,
                      isHighlight: true,
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    Center(
                      child: Text(
                        AppStrings.get(lang, 'awaiting_specs'),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  if (currentStep >= 8) ...[
                    // 2. Cone CSA
                    Text(
                      AppStrings.get(lang, 'cone_csa_title'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'cone_csa_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'cone_csa_sub'),
                      Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'cone_csa_res'),
                      accentPink,
                      isBold: true,
                      isHighlight: true,
                    ),
                    const SizedBox(height: 40),
                  ],
                  if (currentStep >= 9) ...[
                    // 3. Total Surface Area
                    Text(
                      AppStrings.get(lang, 'tsa_title'),
                      style: const TextStyle(
                        color: accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'tsa_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'tsa_sub'),
                      Colors.white,
                    ),
                    if (currentStep >= 10) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'tsa_res'),
                        accentYellow,
                        isBold: true,
                        isHighlight: true,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathRow(
    String text,
    Color color, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isHighlight ? 12 : 8,
        horizontal: isHighlight ? 15 : 0,
      ),
      decoration: isHighlight
          ? BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border(left: BorderSide(color: color, width: 4)),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: isHighlight ? 18 : 15,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
    );
  }

  // --- कैनवास क्षेत्र (CANVAS AREA) ---
  Widget _buildInteractiveCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.1,
          maxScale: 4.0,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // विशाल बैकग्राउंड ग्रिड (Huge Background Grid)
                Positioned.fill(child: CustomPaint(painter: GridPainter())),

                // दृश्य सामग्री (Scene Content)
                Center(
                  child: SizedBox(
                    width: 500,
                    height:
                        380, // Maintaining the original dimensions for the painter scale
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: const Size(500, 380),
                          painter: ToyPainter(
                            step: currentStep,
                            assemblyProgress: assemblyProgress,
                          ),
                        ),

                        // --- LABELS & MEASUREMENTS OVERLAYS ---
                        // Step 1: Basic Dims
                        if (currentStep >= 1 && currentStep <= 8) ...[
                          const Positioned(
                            left: 170,
                            top: 220,
                            child: Text(
                              "r = 3.5cm",
                              style: TextStyle(
                                color: accentBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 80,
                            top: 120,
                            child: Text(
                              "Total\nH=15.5cm",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],

                        // Step 2: Hemisphere height
                        if (currentStep >= 2 && currentStep <= 8) ...[
                          const Positioned(
                            left: 270,
                            top: 270,
                            child: Text(
                              "r=3.5",
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],

                        // Step 3: Cone Height
                        if (currentStep >= 3 && currentStep <= 8) ...[
                          const Positioned(
                            left: 260,
                            top: 100,
                            child: Text(
                              "h = 12cm",
                              style: TextStyle(
                                color: accentPink,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],

                        // Step 4 & 5: Slant Height
                        if (currentStep >= 4 && currentStep <= 8) ...[
                          Positioned(
                            left: 140,
                            top: 80,
                            child: Transform.rotate(
                              angle: -0.3,
                              child: Text(
                                currentStep >= 5 ? "l = 12.5cm" : "l = ?",
                                style: const TextStyle(
                                  color: accentYellow,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Assembled Total
                        if (currentStep >= 9) ...[
                          const Positioned(
                            left: 310,
                            top: 150,
                            child: Text(
                              "Combined Toy",
                              style: TextStyle(
                                color: accentBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildControlsArea() {
    if (currentStep >= 10) {
      return _ControlButton(
        text: AppStrings.get(lang, 'btn_restart'),
        color: accentPink,
        onPressed: resetLab,
      );
    }

    switch (currentStep) {
      case 0:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_start'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_obs_ok'),
        );
      case 1:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_dims'),
          color: accentPink,
          onPressed: () => advanceStep('msg_dims_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_hemi'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_hemi_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_cone_h'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_cone_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_slant_id'),
          color: accentPink,
          onPressed: () => advanceStep('msg_slant_id_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_slant_calc'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_slant_calc_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_csa_hemi'),
          color: accentGreen,
          onPressed: () {
            advanceStep('msg_csa_hemi_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_csa_cone'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_csa_cone_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_assemble'),
          color: accentPink,
          onPressed: () {
            advanceStep('msg_assemble_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_total'),
          hint: 'Total = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_total_area'),
          onVerify: () => verifyInput('214.5', 'msg_final_ok'),
        );
      default:
        return const SizedBox();
    }
  }
}

// --- उप-विजेट्स (SUB-WIDGETS) ---

class _InputControlBlock extends StatelessWidget {
  final String question;
  final String hint;
  final TextEditingController controller;
  final String btnText;
  final VoidCallback onVerify;

  const _InputControlBlock({
    required this.question,
    required this.hint,
    required this.controller,
    required this.btnText,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            filled: true,
            fillColor: Colors.black45,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accentPink),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ControlButton(text: btnText, color: accentGreen, onPressed: onVerify),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == accentYellow ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _LangBtn({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

// --- कस्टम पेंटर्स (CUSTOM PAINTERS) ---

class ToyPainter extends CustomPainter {
  final int step;
  final double assemblyProgress;

  ToyPainter({required this.step, required this.assemblyProgress});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = 250;
    double jointY = 180;
    double r = 42;
    double h = 144;
    double hemiH = 42;

    double separation = 40 * (1 - assemblyProgress);
    double coneBaseY = jointY - separation / 2;
    double hemiBaseY = jointY + separation / 2;

    if (step >= 1) {
      // Visible elements from Step 1 onwards
      Path hemiPath = Path()
        ..moveTo(cx - r, hemiBaseY)
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, hemiBaseY), radius: r),
          0,
          math.pi,
          false,
        )
        ..close();

      canvas.drawPath(
        hemiPath,
        Paint()
          ..color = accentGreen.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        hemiPath,
        Paint()
          ..color = accentGreen
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      if (assemblyProgress < 1.0) {
        _drawDashedLine(
          canvas,
          Offset(cx - r, hemiBaseY),
          Offset(cx + r, hemiBaseY),
          Colors.white54,
          2,
        );
      }

      Path conePath = Path()
        ..moveTo(cx - r, coneBaseY)
        ..lineTo(cx + r, coneBaseY)
        ..lineTo(cx, coneBaseY - h)
        ..close();

      canvas.drawPath(
        conePath,
        Paint()
          ..color = accentPink.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        conePath,
        Paint()
          ..color = accentPink
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      if (assemblyProgress < 1.0) {
        _drawDashedLine(
          canvas,
          Offset(cx - r, coneBaseY),
          Offset(cx + r, coneBaseY),
          Colors.white54,
          2,
        );
      }
    }

    if (step >= 2 && step < 9) {
      canvas.drawLine(
        Offset(cx, coneBaseY),
        Offset(cx + r, coneBaseY),
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2,
      );
      canvas.drawCircle(Offset(cx, coneBaseY), 3, Paint()..color = accentBlue);

      _drawDimensionLine(
        canvas,
        Offset(cx - r - 30, coneBaseY - h),
        Offset(cx - r - 30, hemiBaseY + hemiH),
        Colors.white54,
      );
    }

    if (step >= 3 && step < 9) {
      _drawDimensionLine(
        canvas,
        Offset(cx + r + 20, hemiBaseY),
        Offset(cx + r + 20, hemiBaseY + hemiH),
        accentGreen,
      );
    }

    if (step >= 4 && step < 9) {
      _drawDimensionLine(
        canvas,
        Offset(cx + r + 20, coneBaseY - h),
        Offset(cx + r + 20, coneBaseY),
        accentPink,
      );
    }

    if (step >= 5 && step < 9) {
      canvas.drawLine(
        Offset(cx, coneBaseY - h),
        Offset(cx - r, coneBaseY),
        Paint()
          ..color = accentYellow
          ..strokeWidth = 4,
      );
    }

    if (step >= 9) {
      Path combined = Path()
        ..moveTo(cx - r, jointY)
        ..lineTo(cx, jointY - h)
        ..lineTo(cx + r, jointY)
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, jointY), radius: r),
          0,
          math.pi,
          false,
        )
        ..close();

      canvas.drawPath(
        combined,
        Paint()
          ..color = accentYellow
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );

      _drawDashedLine(
        canvas,
        Offset(cx - r, jointY),
        Offset(cx + r, jointY),
        Colors.white24,
        2,
      );
    }
  }

  void _drawDimensionLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(Offset(p1.dx - 5, p1.dy), Offset(p1.dx + 5, p1.dy), paint);
    canvas.drawLine(Offset(p2.dx - 5, p2.dy), Offset(p2.dx + 5, p2.dy), paint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double strokeWidth, {
    double dashWidth = 8,
    double dashSpace = 6,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    double totalLength = (end - start).distance;
    Offset direction = (end - start) / totalLength;
    double drawn = 0;
    while (drawn < totalLength) {
      final currentStart = start + direction * drawn;
      final currentEnd =
          start + direction * (drawn + dashWidth).clamp(0, totalLength);
      canvas.drawLine(currentStart, currentEnd, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant ToyPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.assemblyProgress != assemblyProgress;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 40;
    const double limit = 20000;

    for (double i = -limit; i <= limit; i += step) {
      canvas.drawLine(Offset(i, -limit), Offset(i, limit), paint);
      canvas.drawLine(Offset(-limit, i), Offset(limit, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
