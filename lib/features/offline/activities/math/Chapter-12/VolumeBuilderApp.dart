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
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

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
      'app_title': 'THE VOLUME BUILDER',
      'tagline': 'Volume of Combined Solids',
      'init_btn': 'INITIALIZE WORKSHOP',
      'header_title': 'The Volume Builder',
      'header_subtitle': 'Class 10 • Surface Areas & Volumes',
      'phase_label': 'CONSTRUCTION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Volume Computed',
      'success_desc':
          'You have successfully calculated the total volume of the combined solid in terms of π!',
      'btn_restart': 'NEW CONSTRUCTION',
      's0': 'Initialize Workspace. Load solid blueprint.',
      's1': 'Identify dimensions: r = 1cm, h = 1cm.',
      's2': 'Analyze Hemisphere component.',
      's3': 'Compute Hemisphere Volume (2/3 πr³).',
      's4': 'Analyze Cone component.',
      's5': 'Compute Cone Volume (1/3 πr²h).',
      's6': 'Assemble Solid: Combine components.',
      's7': 'Set up Total Volume equation.',
      's8': 'Add the fractional volumes.',
      's9': 'Verify Final Volume in terms of π.',
      'btn_start': 'LOAD BLUEPRINT',
      'btn_dims': 'MARK DIMENSIONS',
      'btn_hemi': 'ANALYZE HEMISPHERE',
      'btn_v_hemi': 'CALCULATE HEMISPHERE VOL',
      'btn_cone': 'ANALYZE CONE',
      'btn_v_cone': 'CALCULATE CONE VOL',
      'btn_assemble': 'ASSEMBLE SOLID',
      'btn_setup_eq': 'SETUP TOTAL EQUATION',
      'btn_add_frac': 'ADD FRACTIONS',
      'btn_calc_total': 'VERIFY FINAL VOLUME',
      'msg_obs_ok': 'Blueprint active. Components separated.',
      'msg_dims_ok': 'Dimensions verified: r = 1cm, h = 1cm.',
      'msg_hemi_ok': 'Hemisphere isolated for analysis.',
      'msg_v_hemi_ok': 'Hemisphere Volume = 2/3 π cm³.',
      'msg_cone_ok': 'Cone isolated for analysis.',
      'msg_v_cone_ok': 'Cone Volume = 1/3 π cm³.',
      'msg_assemble_ok': 'Components combined successfully.',
      'msg_eq_ok': 'Equation structured: V = 2/3 π + 1/3 π.',
      'msg_add_ok': 'Fractions added: 3/3 π.',
      'msg_final_ok': 'Total Volume = 1π cm³.',
      'msg_err': 'Calculation error. Check your math.',
      'q_solve_total': 'V = (3/3)π. Enter coefficient of π:',
      // Calculations Panel Strings
      'calc_title': 'Calculations & Data',
      'awaiting_specs': 'Awaiting geometric analysis...',
      'hemi_vol_title': '1. Hemisphere Volume',
      'hemi_vol_form': 'V = (2/3)πr³',
      'hemi_vol_sub': '= (2/3)π(1)³',
      'hemi_vol_res': '= 2/3 π cm³',
      'cone_vol_title': '2. Cone Volume',
      'cone_vol_form': 'V = (1/3)πr²h',
      'cone_vol_sub': '= (1/3)π(1)²(1)',
      'cone_vol_res': '= 1/3 π cm³',
      'total_vol_title': '3. Total Volume',
      'total_vol_form': 'V = Vol(Hemi) + Vol(Cone)',
      'total_vol_sub': '= 2/3 π + 1/3 π',
      'total_vol_res1': '= 3/3 π',
      'total_vol_res2': '= 1π cm³',
    },
    'hi': {
      'app_title': 'वॉल्यूम बिल्डर',
      'tagline': 'संयुक्त ठोसों का आयतन',
      'init_btn': 'वर्कशॉप प्रारंभ करें',
      'header_title': 'वॉल्यूम बिल्डर',
      'header_subtitle': 'कक्षा 10 • पृष्ठीय क्षेत्रफल और आयतन',
      'phase_label': 'निर्माण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'आयतन की गणना पूर्ण',
      'success_desc':
          'आपने π के पदों में संयुक्त ठोस के कुल आयतन की सफलतापूर्वक गणना कर ली है!',
      'btn_restart': 'नया निर्माण',
      's0': 'कार्यक्षेत्र प्रारंभ करें। ठोस खाका लोड करें।',
      's1': 'आयाम पहचानें: r = 1cm, h = 1cm.',
      's2': 'अर्धगोलाकार घटक का विश्लेषण करें।',
      's3': 'अर्धगोले के आयतन की गणना करें (2/3 πr³)।',
      's4': 'शंकु घटक का विश्लेषण करें।',
      's5': 'शंकु के आयतन की गणना करें (1/3 πr²h)।',
      's6': 'ठोस असेंबल करें: घटकों को मिलाएं।',
      's7': 'कुल आयतन समीकरण सेट करें।',
      's8': 'भिन्नात्मक आयतनों को जोड़ें।',
      's9': 'π के संदर्भ में अंतिम आयतन सत्यापित करें।',
      'btn_start': 'खाका लोड करें',
      'btn_dims': 'आयाम चिह्नित करें',
      'btn_hemi': 'अर्धगोले का विश्लेषण करें',
      'btn_v_hemi': 'अर्धगोले के आयतन की गणना करें',
      'btn_cone': 'शंकु का विश्लेषण करें',
      'btn_v_cone': 'शंकु के आयतन की गणना करें',
      'btn_assemble': 'ठोस असेंबल करें',
      'btn_setup_eq': 'कुल समीकरण सेट करें',
      'btn_add_frac': 'भिन्न जोड़ें',
      'btn_calc_total': 'अंतिम आयतन सत्यापित करें',
      'msg_obs_ok': 'खाका सक्रिय। घटक अलग हो गए।',
      'msg_dims_ok': 'आयाम सत्यापित: r = 1cm, h = 1cm.',
      'msg_hemi_ok': 'विश्लेषण के लिए अर्धगोले को अलग किया गया।',
      'msg_v_hemi_ok': 'अर्धगोले का आयतन = 2/3 π cm³.',
      'msg_cone_ok': 'विश्लेषण के लिए शंकु को अलग किया गया।',
      'msg_v_cone_ok': 'शंकु का आयतन = 1/3 π cm³.',
      'msg_assemble_ok': 'घटकों को सफलतापूर्वक जोड़ा गया।',
      'msg_eq_ok': 'समीकरण संरचित: V = 2/3 π + 1/3 π.',
      'msg_add_ok': 'भिन्न जोड़े गए: 3/3 π.',
      'msg_final_ok': 'कुल आयतन = 1π cm³.',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      'q_solve_total': 'V = (3/3)π. π का गुणांक दर्ज करें:',
      // Calculations Panel Strings
      'calc_title': 'गणनाएँ एवं डेटा',
      'awaiting_specs': 'ज्यामितीय विश्लेषण की प्रतीक्षा में...',
      'hemi_vol_title': '1. अर्धगोले का आयतन',
      'hemi_vol_form': 'V = (2/3)πr³',
      'hemi_vol_sub': '= (2/3)π(1)³',
      'hemi_vol_res': '= 2/3 π cm³',
      'cone_vol_title': '2. शंकु का आयतन',
      'cone_vol_form': 'V = (1/3)πr²h',
      'cone_vol_sub': '= (1/3)π(1)²(1)',
      'cone_vol_res': '= 1/3 π cm³',
      'total_vol_title': '3. कुल आयतन',
      'total_vol_form': 'V = V(अर्धगोला) + V(शंकु)',
      'total_vol_sub': '= 2/3 π + 1/3 π',
      'total_vol_res1': '= 3/3 π',
      'total_vol_res2': '= 1π cm³',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class VolumeBuilderApp extends StatefulWidget {
  const VolumeBuilderApp({super.key});

  @override
  State<VolumeBuilderApp> createState() => _VolumeBuilderAppState();
}

class _VolumeBuilderAppState extends State<VolumeBuilderApp>
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
        if (currentStep == 7) {
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
            // Success Modal Auto-hide after 5 seconds
            Timer(const Duration(seconds: 5), () {
              if (!mounted) return;
              setState(() {
                showSuccessModal = false;
              });
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
      lang = 'en'; // Force reset back to English
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
                const Icon(Icons.category, size: 80, color: accentPink),
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
                    // 1. Hemisphere Volume
                    Text(
                      AppStrings.get(lang, 'hemi_vol_title'),
                      style: const TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'hemi_vol_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'hemi_vol_sub'),
                      Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'hemi_vol_res'),
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
                  if (currentStep >= 5) ...[
                    // 2. Cone Volume
                    Text(
                      AppStrings.get(lang, 'cone_vol_title'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'cone_vol_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'cone_vol_sub'),
                      Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'cone_vol_res'),
                      accentPink,
                      isBold: true,
                      isHighlight: true,
                    ),
                    const SizedBox(height: 40),
                  ],
                  if (currentStep >= 7) ...[
                    // 3. Total Volume
                    Text(
                      AppStrings.get(lang, 'total_vol_title'),
                      style: const TextStyle(
                        color: accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'total_vol_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'total_vol_sub'),
                      Colors.white,
                    ),
                    if (currentStep >= 8) ...[
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'total_vol_res1'),
                        Colors.white70,
                      ),
                    ],
                    if (currentStep >= 10) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'total_vol_res2'),
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
                    height: 380,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: const Size(500, 380),
                          painter: VolumePainter(
                            step: currentStep,
                            assemblyProgress: assemblyProgress,
                          ),
                        ),

                        // --- LABELS & MEASUREMENTS OVERLAYS ---
                        // Step 1+: Basic Dims
                        if (currentStep >= 1) ...[
                          Positioned(
                            left: 170,
                            top: currentStep >= 7
                                ? 160
                                : 160 - 40 * (1 - assemblyProgress),
                            child: const Text(
                              "h = 1cm",
                              style: TextStyle(
                                color: accentPink,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: currentStep >= 7
                                ? 210
                                : 210 + 40 * (1 - assemblyProgress),
                            child: const Text(
                              "r = 1cm",
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 14,
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
          text: AppStrings.get(lang, 'btn_v_hemi'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_v_hemi_ok');
            if (!isRightPanelOpen) toggleRightPanel(); // Auto-open math panel
          },
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_cone'),
          color: accentPink,
          onPressed: () => advanceStep('msg_cone_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_v_cone'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_v_cone_ok');
            if (!isRightPanelOpen) toggleRightPanel(); // Auto-open math panel
          },
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_assemble'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_assemble_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_setup_eq'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_eq_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_add_frac'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_add_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_total'),
          hint: '1',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_calc_total'),
          onVerify: () => verifyInput('1', 'msg_final_ok'),
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
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
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

class VolumePainter extends CustomPainter {
  final int step;
  final double assemblyProgress;

  VolumePainter({required this.step, required this.assemblyProgress});

  // Helper function to draw dashed lines
  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashLength = 8,
    double gapLength = 6,
  }) {
    final totalLength = (p2 - p1).distance;
    final direction = (p2 - p1) / totalLength;
    double current = 0;
    while (current < totalLength) {
      final start = p1 + direction * current;
      final end =
          p1 +
          direction *
              (current + dashLength > totalLength
                  ? totalLength
                  : current + dashLength);
      canvas.drawLine(start, end, paint);
      current += dashLength + gapLength;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate Mapping
    // r = 1, h = 1. Visually let's make 1 unit = 80 pixels.
    // Center X = 250, Base Y (joint) = 200.

    double cx = size.width / 2;
    double cy = 200;
    double scale = 80.0;
    double r = 1.0 * scale; // 80
    double h = 1.0 * scale; // 80

    // Separation Logic
    double sep = 40 * (1 - assemblyProgress);
    double coneBaseY = cy - sep / 2;
    double hemiBaseY = cy + sep / 2;

    // Opacity Logic
    double hemiOpacity = (step >= 2 && step <= 3)
        ? 0.8
        : (step >= 4 && step <= 5 ? 0.2 : 0.4);
    double coneOpacity = (step >= 4 && step <= 5)
        ? 0.8
        : (step >= 2 && step <= 3 ? 0.2 : 0.4);

    // If step >= 7, both are solid and united
    if (step >= 7) {
      hemiOpacity = 0.5;
      coneOpacity = 0.5;
    }

    if (step >= 1) {
      // Draw Hemisphere (Bottom)
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
          ..color = accentGreen.withOpacity(hemiOpacity)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        hemiPath,
        Paint()
          ..color = accentGreen
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Highlight Hemisphere Base if separated
      if (assemblyProgress < 1.0) {
        _drawDashedLine(
          canvas,
          Offset(cx - r, hemiBaseY),
          Offset(cx + r, hemiBaseY),
          Paint()
            ..color = Colors.white54
            ..strokeWidth = 2,
        );
      }

      // Draw Cone (Top)
      Path conePath = Path()
        ..moveTo(cx - r, coneBaseY)
        ..lineTo(cx + r, coneBaseY)
        ..lineTo(cx, coneBaseY - h)
        ..close();

      canvas.drawPath(
        conePath,
        Paint()
          ..color = accentPink.withOpacity(coneOpacity)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        conePath,
        Paint()
          ..color = accentPink
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Highlight Cone Base if separated
      if (assemblyProgress < 1.0) {
        _drawDashedLine(
          canvas,
          Offset(cx - r, coneBaseY),
          Offset(cx + r, coneBaseY),
          Paint()
            ..color = Colors.white54
            ..strokeWidth = 2,
        );
      }
    }

    // Step 2: Dimensions
    if (step >= 2) {
      // Radius marker on Hemisphere
      canvas.drawLine(
        Offset(cx, hemiBaseY),
        Offset(cx + r, hemiBaseY),
        Paint()
          ..color = accentGreen
          ..strokeWidth = 2,
      );
      canvas.drawCircle(Offset(cx, hemiBaseY), 3, Paint()..color = accentGreen);

      // Height marker on Cone
      canvas.drawLine(
        Offset(cx, coneBaseY),
        Offset(cx, coneBaseY - h),
        Paint()
          ..color = accentPink
          ..strokeWidth = 2,
      );
      canvas.drawCircle(Offset(cx, coneBaseY), 3, Paint()..color = accentPink);
    }

    // Step 7+: Assembly outline indicator
    if (step >= 7) {
      // Highlight the combined outline
      Path combined = Path()
        ..moveTo(cx - r, cy)
        ..lineTo(cx, cy - h)
        ..lineTo(cx + r, cy)
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          0,
          math.pi,
          false,
        )
        ..close();

      canvas.drawPath(
        combined,
        Paint()
          ..color = accentYellow
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );

      // Draw joint line as dotted to show it's internal
      _drawDashedLine(
        canvas,
        Offset(cx - r, cy),
        Offset(cx + r, cy),
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VolumePainter oldDelegate) {
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
