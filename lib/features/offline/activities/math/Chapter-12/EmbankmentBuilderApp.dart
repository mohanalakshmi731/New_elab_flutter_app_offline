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
      'app_title': 'THE EMBANKMENT BUILDER',
      'tagline': 'Volume Conservation: Cylinder to Hollow Cylinder',
      'init_btn': 'INITIALIZE SURVEY',
      'header_title': 'The Embankment Builder',
      'header_subtitle': 'Class 10 • Surface Areas & Volumes',
      'phase_label': 'CONSTRUCTION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Survey Verified',
      'success_desc':
          'You have successfully calculated the height of the embankment formed by the excavated earth!',
      'btn_restart': 'NEW PROJECT',
      's0': 'Initialize Grid. Drone surveying well site.',
      's1': 'Identify well parameters: r = 1.5m, h = 14m.',
      's2': 'Calculate Volume of excavated earth (V = πr²h).',
      's3': 'Establish embankment width (4m).',
      's4': 'Determine Outer Radius (R = 1.5 + 4 = 5.5m).',
      's5': 'Identify Embankment Area (Area = π(R² - r²)).',
      's6': 'Set up Volume Conservation equation.',
      's7': 'Substitute values into the equation.',
      's8': 'Begin excavation and embankment buildup.',
      's9': 'Finalize Height: H = 1.125m.',
      'btn_start': 'ACTIVATE SURVEY',
      'btn_dims': 'MARK WELL DIMS',
      'btn_v_well': 'CALCULATE EARTH VOL',
      'btn_width': 'SET EMBANKMENT WIDTH',
      'btn_outer_r': 'DETERMINE OUTER R',
      'btn_area_ann': 'CALC RING AREA',
      'btn_equate': 'EQUATE VOLUMES',
      'btn_substitute': 'SUBSTITUTE & SOLVE',
      'btn_excavate': 'EXECUTE EXCAVATION',
      'btn_verify': 'VERIFY FINAL HEIGHT',
      'msg_obs_ok': 'Survey site locked. Ready for excavation.',
      'msg_dims_ok': 'Well dimensions: Radius=1.5m, Depth=14m.',
      'msg_v_well_ok': 'Excavation Volume = 31.5π m³.',
      'msg_width_ok': 'Embankment width set to 4m.',
      'msg_outer_r_ok': 'Outer Radius R = 5.5m.',
      'msg_area_ok': 'Ring Base Area = 28π m².',
      'msg_eq_ok': 'Equation: 31.5π = 28π × H.',
      'msg_sub_ok': 'Simplified: H = 31.5 / 28.',
      'msg_exc_ok': 'Earth redistribution in progress...',
      'msg_final_ok': 'Embankment Height verified: 1.125m.',
      'msg_err': 'Calculation error. Check the geometry.',
      'q_solve_h': 'If 28H = 31.5, what is H?',
      // Calculations Panel Strings
      'calc_title': 'Calculations & Data',
      'awaiting_specs': 'Awaiting survey data...',
      'vol_well_title': '1. Volume of Earth Dug (Well)',
      'vol_well_form': 'V_well = πr²h',
      'vol_well_sub': '= π × (1.5)² × 14',
      'vol_well_res': '= 31.5π m³',
      'emb_title': '2. Volume of Embankment',
      'emb_form': 'V_emb = π(R² - r²)H',
      'emb_sub': '= π(5.5² - 1.5²)H',
      'emb_res': '= 28π × H m³',
      'eq_title': '3. Conservation Equation',
      'eq_step1': 'Earth Vol = Embankment Vol',
      'eq_step2': '31.5π = 28π × H',
      'eq_step3': 'H = 31.5 / 28',
      'eq_res': 'H = 1.125 m',
    },
    'hi': {
      'app_title': 'तटबंध निर्माता',
      'tagline': 'आयतन संरक्षण: बेलन से खोखले बेलन तक',
      'init_btn': 'सर्वेक्षण प्रारंभ करें',
      'header_title': 'तटबंध निर्माता',
      'header_subtitle': 'कक्षा 10 • पृष्ठीय क्षेत्रफल और आयतन',
      'phase_label': 'निर्माण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'सर्वेक्षण सत्यापित',
      'success_desc':
          'आपने खुदाई की गई मिट्टी से बने तटबंध की ऊंचाई की सफलतापूर्वक गणना कर ली है!',
      'btn_restart': 'नई परियोजना',
      's0': 'ग्रिड प्रारंभ करें। ड्रोन कुएं की साइट का सर्वेक्षण कर रहा है।',
      's1': 'कुएं के मापदंड पहचानें: r = 1.5m, h = 14m.',
      's2': 'खोदी गई मिट्टी के आयतन की गणना करें (V = πr²h)।',
      's3': 'तटबंध की चौड़ाई (4m) स्थापित करें।',
      's4': 'बाहरी त्रिज्या निर्धारित करें (R = 1.5 + 4 = 5.5m)।',
      's5': 'तटबंध क्षेत्र की पहचान करें (Area = π(R² - r²))।',
      's6': 'आयतन संरक्षण समीकरण सेट करें।',
      's7': 'समीकरण में मान प्रतिस्थापित करें।',
      's8': 'खुदाई और तटबंध निर्माण शुरू करें।',
      's9': 'ऊंचाई को अंतिम रूप दें: H = 1.125m.',
      'btn_start': 'सर्वेक्षण सक्रिय करें',
      'btn_dims': 'कुएं के आयाम चिह्नित करें',
      'btn_v_well': 'मिट्टी के आयतन की गणना',
      'btn_width': 'तटबंध की चौड़ाई सेट करें',
      'btn_outer_r': 'बाहरी R निर्धारित करें',
      'btn_area_ann': 'वलय क्षेत्र की गणना',
      'btn_equate': 'आयतन की तुलना करें',
      'btn_substitute': 'प्रतिस्थापित करें और हल करें',
      'btn_excavate': 'खुदाई निष्पादित करें',
      'btn_verify': 'अंतिम ऊंचाई सत्यापित करें',
      'msg_obs_ok': 'सर्वेक्षण स्थल लॉक। खुदाई के लिए तैयार।',
      'msg_dims_ok': 'कुएं के आयाम: त्रिज्या=1.5m, गहराई=14m.',
      'msg_v_well_ok': 'खुदाई का आयतन = 31.5π m³.',
      'msg_width_ok': 'तटबंध की चौड़ाई 4m सेट।',
      'msg_outer_r_ok': 'बाहरी त्रिज्या R = 5.5m.',
      'msg_area_ok': 'वलय आधार क्षेत्र = 28π m².',
      'msg_eq_ok': 'समीकरण: 31.5π = 28π × H.',
      'msg_sub_ok': 'सरलीकृत: H = 31.5 / 28.',
      'msg_exc_ok': 'मिट्टी का पुनर्वितरण प्रगति पर है...',
      'msg_final_ok': 'तटबंध की ऊंचाई सत्यापित: 1.125m.',
      'msg_err': 'गणना त्रुटि। ज्यामिति की जाँच करें।',
      'q_solve_h': 'यदि 28H = 31.5 है, तो H क्या है?',
      // Calculations Panel Strings
      'calc_title': 'गणनाएँ एवं डेटा',
      'awaiting_specs': 'सर्वेक्षण डेटा की प्रतीक्षा में...',
      'vol_well_title': '1. खोदी गई मिट्टी का आयतन (कुआँ)',
      'vol_well_form': 'V_well = πr²h',
      'vol_well_sub': '= π × (1.5)² × 14',
      'vol_well_res': '= 31.5π m³',
      'emb_title': '2. तटबंध का आयतन',
      'emb_form': 'V_emb = π(R² - r²)H',
      'emb_sub': '= π(5.5² - 1.5²)H',
      'emb_res': '= 28π × H m³',
      'eq_title': '3. संरक्षण समीकरण',
      'eq_step1': 'मिट्टी का आयतन = तटबंध का आयतन',
      'eq_step2': '31.5π = 28π × H',
      'eq_step3': 'H = 31.5 / 28',
      'eq_res': 'H = 1.125 m',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class EmbankmentBuilderApp extends StatefulWidget {
  const EmbankmentBuilderApp({super.key});

  @override
  State<EmbankmentBuilderApp> createState() => _EmbankmentBuilderAppState();
}

class _EmbankmentBuilderAppState extends State<EmbankmentBuilderApp>
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
  double excavateProgress = 0.0;
  late AnimationController _excavateController;
  late Animation<double> _excavateAnimation;

  // Input Controllers
  final TextEditingController _inpAns = TextEditingController();

  @override
  void initState() {
    super.initState();
    _excavateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _excavateController.dispose();
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
      if (isLeftPanelOpen) isRightPanelOpen = false; // Auto close right
    });
  }

  void toggleRightPanel() {
    AudioManager.playClick();
    setState(() {
      isRightPanelOpen = !isRightPanelOpen;
      if (isRightPanelOpen) isLeftPanelOpen = false; // Auto close left
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

        if (currentStep == 9) {
          _animateExcavation();
        }

        _inpAns.clear();

        if (currentStep == 10) {
          AudioManager.playSuccess();
          Timer(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              showSuccessModal = true;
            });
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

  void _animateExcavation() {
    _excavateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _excavateController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            excavateProgress = _excavateAnimation.value;
          });
        });
    _excavateController.forward(from: 0.0);
  }

  void verifyInput(String expectedValue, String successMsgKey) {
    if (_inpAns.text.trim() == expectedValue) {
      advanceStep(successMsgKey);
      if (!isRightPanelOpen) {
        toggleRightPanel();
      }
    } else {
      AudioManager.playError();
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void resetLab() {
    AudioManager.playError(); // Use error sound for reset action as fallback
    setState(() {
      currentStep = 0;
      excavateProgress = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      lang = 'en';
      _inpAns.clear();
      _excavateController.reset();
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
                const Icon(Icons.construction, size: 80, color: accentPink),
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
            // 1. कैनवास क्षेत्र (CANVAS AREA)
            Positioned.fill(child: _buildInteractiveCanvas()),

            // Bottom Gradient Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF020617), Colors.transparent],
                      stops: [0.0, 0.3],
                    ),
                  ),
                ),
              ),
            ),

            // 2. फ्लोटिंग मिशन कार्ड (Canvas Floating Card)
            if (!isLeftPanelOpen)
              Positioned(top: 85, left: 20, child: _buildFloatingCard()),

            // 3. राइट पैनल (Right Sidebar - Calculations)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: isRightPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildRightPanel(),
            ),

            // 4. लेफ्ट पैनल (Left Sidebar - Mission/Controls)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildLeftPanel(),
            ),

            // 5. फ्रंट स्क्रीन फ्लोटिंग बटन (Front Screen / Always Visible Buttons)
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

            // सफलता मोडल (Success Modal)
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
                        child: const Icon(Icons.construction, color: bgDark),
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
                  if (currentStep >= 3) ...[
                    Text(
                      AppStrings.get(lang, 'vol_well_title'),
                      style: const TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'vol_well_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'vol_well_sub'),
                      Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'vol_well_res'),
                      accentBlue,
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
                  if (currentStep >= 6) ...[
                    Text(
                      AppStrings.get(lang, 'emb_title'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'emb_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'emb_sub'),
                      Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'emb_res'),
                      accentPink,
                      isBold: true,
                      isHighlight: true,
                    ),
                    const SizedBox(height: 40),
                  ],
                  if (currentStep >= 7) ...[
                    Text(
                      AppStrings.get(lang, 'eq_title'),
                      style: const TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'eq_step1'),
                      Colors.white,
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'eq_step2'),
                      Colors.white70,
                    ),
                    if (currentStep >= 8) ...[
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'eq_step3'),
                        accentYellow,
                      ),
                    ],
                    if (currentStep >= 10) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'eq_res'),
                        accentGreen,
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

  // --- कैनवास क्षेत्र (CANVAS AREA - Realistic Update) ---
  Widget _buildInteractiveCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(5000), // Safe large boundary
          minScale: 0.1,
          maxScale: 4.0,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // विशाल बैकग्राउंड ग्रिड (Background Grid)
                Positioned.fill(child: CustomPaint(painter: GridPainter())),

                // दृश्य सामग्री (Scene Content)
                Center(
                  child: SizedBox(
                    width: 800, // Central focus area for Embankment
                    height: 600,
                    child: CustomPaint(
                      size: const Size(800, 600),
                      painter: EmbankmentPainter(
                        step: currentStep,
                        excavateProgress: excavateProgress,
                      ),
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
          text: AppStrings.get(lang, 'btn_v_well'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_v_well_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_width'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_width_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_outer_r'),
          color: accentPink,
          onPressed: () => advanceStep('msg_outer_r_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_area_ann'),
          color: accentGreen,
          onPressed: () {
            advanceStep('msg_area_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_equate'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_eq_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_substitute'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_excavate'),
          color: accentPink,
          onPressed: () => advanceStep('msg_exc_ok'),
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_h'),
          hint: 'H = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_verify'),
          onVerify: () => verifyInput('1.125', 'msg_final_ok'),
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

// --- कस्टम पेंटर्स (CUSTOM PAINTERS - Realistic Implementation) ---

class EmbankmentPainter extends CustomPainter {
  final int step;
  final double excavateProgress;

  EmbankmentPainter({required this.step, required this.excavateProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate Mapping & Scale for 800x600 Canvas
    double cx = 400; // Center X
    double groundY = 280; // Ground Level Y
    double scale = 20.0; // 1m = 20 pixels

    double rWell = 1.5 * scale; // 30 px
    double hWell = 14 * scale; // 280 px
    double wEmb = 4 * scale; // 80 px
    double rOuter = 5.5 * scale; // 110 px
    double hFinal = 1.125 * scale; // 22.5 px

    double wellEarthLevel = groundY + (hWell * excavateProgress);
    double embankmentLevel = groundY - (hFinal * excavateProgress);

    // Infinite Visual Boundaries
    double leftBoundary = -10000;
    double rightBoundary = 10000;
    double topBoundary = -10000;
    double bottomBoundary = 10000;

    // --- 1. Realistic Environment Rendering ---

    // Sky Background
    Paint skyPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF38BDF8).withOpacity(0.4),
            ],
          ).createShader(
            Rect.fromLTRB(leftBoundary, topBoundary, rightBoundary, groundY),
          );
    canvas.drawRect(
      Rect.fromLTRB(leftBoundary, topBoundary, rightBoundary, groundY),
      skyPaint,
    );

    // Underground Earth Background
    Paint earthPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF5D4037), const Color(0xFF1E100C)],
          ).createShader(
            Rect.fromLTRB(leftBoundary, groundY, rightBoundary, bottomBoundary),
          );
    canvas.drawRect(
      Rect.fromLTRB(leftBoundary, groundY, rightBoundary, bottomBoundary),
      earthPaint,
    );

    // Earth Strata (Subtle sedimentary layers)
    Paint strataPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 2;
    for (double y = groundY + 30; y < bottomBoundary; y += 40) {
      canvas.drawLine(
        Offset(leftBoundary, y),
        Offset(rightBoundary, y + math.sin(y) * 15),
        strataPaint,
      );
    }

    // Grass Top Layer
    Paint grassPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF4ADE80), const Color(0xFF166534)],
          ).createShader(
            Rect.fromLTRB(leftBoundary, groundY, rightBoundary, groundY + 12),
          );
    canvas.drawRect(
      Rect.fromLTRB(leftBoundary, groundY, rightBoundary, groundY + 12),
      grassPaint,
    );

    // --- 2. Well & Embankment Logic ---

    if (step >= 1) {
      // The Well Hole (Dark depth)
      Rect wellRect = Rect.fromLTRB(
        cx - rWell,
        groundY,
        cx + rWell,
        groundY + hWell,
      );
      Paint holePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black87, Colors.black45, Colors.black87],
        ).createShader(wellRect);
      canvas.drawRect(wellRect, holePaint);

      // Earth remaining inside the well
      if (excavateProgress < 1.0) {
        Rect earthInWell = Rect.fromLTRB(
          cx - rWell,
          wellEarthLevel,
          cx + rWell,
          groundY + hWell,
        );
        Paint soilPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF8D6E63), const Color(0xFF3E2723)],
          ).createShader(earthInWell);
        canvas.drawRect(earthInWell, soilPaint);

        // Highlight top surface of the soil inside
        canvas.drawLine(
          Offset(cx - rWell, wellEarthLevel),
          Offset(cx + rWell, wellEarthLevel),
          Paint()
            ..color = const Color(0xFFA1887F)
            ..strokeWidth = 3,
        );
      }

      // The Embankment (Excavated Earth on sides)
      if (step >= 4 && excavateProgress > 0) {
        Rect leftBlock = Rect.fromLTRB(
          cx - rOuter,
          embankmentLevel,
          cx - rWell,
          groundY,
        );
        Rect rightBlock = Rect.fromLTRB(
          cx + rWell,
          embankmentLevel,
          cx + rOuter,
          groundY,
        );

        Paint embPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF795548),
              const Color(0xFF4E342E),
            ], // Fresh soil color
          ).createShader(Rect.fromLTRB(0, embankmentLevel, 0, groundY));

        canvas.drawRect(leftBlock, embPaint);
        canvas.drawRect(rightBlock, embPaint);

        // Fresh soil top highlight
        Paint embHighlight = Paint()
          ..color = const Color(0xFFA1887F)
          ..strokeWidth = 3;
        canvas.drawLine(
          Offset(leftBlock.left, leftBlock.top),
          Offset(leftBlock.right, leftBlock.top),
          embHighlight,
        );
        canvas.drawLine(
          Offset(rightBlock.left, rightBlock.top),
          Offset(rightBlock.right, rightBlock.top),
          embHighlight,
        );

        // Edge lines for clarity
        Paint edgePaint = Paint()
          ..color = Colors.black54
          ..strokeWidth = 1;
        canvas.drawRect(leftBlock, edgePaint..style = PaintingStyle.stroke);
        canvas.drawRect(rightBlock, edgePaint..style = PaintingStyle.stroke);
      }
    }

    // --- 3. Dynamic Text Labels & Dimensions ---
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawLabel(
      String text,
      Offset pos,
      Color color, [
      double fontSize = 14,
    ]) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      );
      textPainter.layout();

      // Semi-transparent dark background for readability over complex textures
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            pos.dx - 6,
            pos.dy - 2,
            textPainter.width + 12,
            textPainter.height + 4,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.black.withOpacity(0.6),
      );

      textPainter.paint(canvas, pos);
    }

    void drawDimLine(Offset p1, Offset p2, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2;
      canvas.drawLine(p1, p2, paint);
      // Draw Caps
      if ((p1.dx - p2.dx).abs() < 1) {
        // Vertical
        canvas.drawLine(
          Offset(p1.dx - 6, p1.dy),
          Offset(p1.dx + 6, p1.dy),
          paint,
        );
        canvas.drawLine(
          Offset(p2.dx - 6, p2.dy),
          Offset(p2.dx + 6, p2.dy),
          paint,
        );
      } else {
        // Horizontal
        canvas.drawLine(
          Offset(p1.dx, p1.dy - 6),
          Offset(p1.dx, p1.dy + 6),
          paint,
        );
        canvas.drawLine(
          Offset(p2.dx, p2.dy - 6),
          Offset(p2.dx, p2.dy + 6),
          paint,
        );
      }
    }

    // Step 2 & 3: Well Dimensions (r, h)
    if (step >= 2 && excavateProgress < 0.5) {
      drawDimLine(
        Offset(cx, groundY + 20),
        Offset(cx + rWell, groundY + 20),
        accentBlue,
      );
      drawLabel(
        "r = 1.5m",
        Offset(cx + rWell / 2 - 35, groundY + 30),
        accentBlue,
      );

      drawDimLine(
        Offset(cx - rWell - 30, groundY),
        Offset(cx - rWell - 30, groundY + hWell),
        accentPink,
      );
      drawLabel(
        "h = 14m",
        Offset(cx - rWell - 100, groundY + hWell / 2 - 10),
        accentPink,
      );
    }

    // Step 4+: Embankment Width
    if (step >= 4 && step < 9) {
      drawDimLine(
        Offset(cx + rWell, groundY - 30),
        Offset(cx + rOuter, groundY - 30),
        accentYellow,
      );
      drawLabel(
        "Width = 4m",
        Offset(cx + rWell + wEmb / 2 - 40, groundY - 55),
        accentYellow,
      );
    }

    // Step 5+: Outer Radius & Height
    if (step >= 5 && excavateProgress > 0.8) {
      drawDimLine(
        Offset(cx, groundY + 40),
        Offset(cx + rOuter, groundY + 40),
        accentPink,
      );
      drawLabel(
        "R = 5.5m",
        Offset(cx + rOuter / 2 - 35, groundY + 50),
        accentPink,
        16,
      );

      // Height dimension marker
      double targetH = groundY - hFinal;
      drawDimLine(
        Offset(cx - rOuter - 30, groundY),
        Offset(cx - rOuter - 30, targetH),
        accentGreen,
      );
      drawLabel(
        step >= 10 ? "H = 1.125m" : "H = ?",
        Offset(cx - rOuter - 130, targetH - 10),
        accentGreen,
        16,
      );
    }
  }

  @override
  bool shouldRepaint(covariant EmbankmentPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.excavateProgress != excavateProgress;
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
