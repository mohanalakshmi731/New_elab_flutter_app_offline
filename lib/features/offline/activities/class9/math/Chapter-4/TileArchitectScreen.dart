// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui'; // Added this import to fix the ImageFilter error!

// --- GLOBAL AUDIO ENGINE ---
// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

// Local audio assets (assets/audio/class9/)
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer requested
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter opening requested

// Web-safe playback helper
void _playSound(AudioPlayer player, String url) async {
  try {
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio Playback Error: $e");
  }
}
// ---------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TileArchitectApp());
}

class TileArchitectApp extends StatelessWidget {
  const TileArchitectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Tile Architect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'monospace',
      ),
      home: const TileArchitectScreen(),
    );
  }
}

class TileArchitectScreen extends StatefulWidget {
  const TileArchitectScreen({super.key});

  @override
  State<TileArchitectScreen> createState() => _TileArchitectScreenState();
}

class _TileArchitectScreenState extends State<TileArchitectScreen> {
  // --- Core State ---
  String lang = 'en';
  int currentStep = 0;
  
  bool _sidebarOpen = true;
  bool _showShutter = true;
  bool _isStepTransitioning = false;

  // --- Mission Config ---
  int p = 3;
  int q = 2;
  int get b => p + q;
  int get c => p * q;

  // --- Tile Placement State ---
  int placedX2 = 0;
  int placedXH = 0;
  int placedXV = 0;
  int placed1 = 0;

  bool showProofPopup = false;

  final TransformationController _transformController = TransformationController();

  // --- Theming Colors ---
  final Map<String, Color> themeColors = {
    'bg': const Color(0xFF0F172A),
    'panel': const Color(0xFF1E293B),
    'primary': const Color(0xFF38BDF8),
    'text': const Color(0xFFF1F5F9),
    'muted': const Color(0xFF94A3B8),
    'accent': const Color(0xFFFACC15),
    'success': const Color(0xFF4ADE80),
    'error': const Color(0xFFF43F5E),
  };

  // --- Dictionary ---
  final Map<String, Map<String, String>> _i18n = {
    'en': {
      'app_title': 'THE TILE ARCHITECT',
      'app_subtitle': 'CLASS 9 • POLYNOMIALS - Factorisation',
      'init_btn': 'Initialize Lab',
      'obj_title': 'Mission Objective',
      'obj_desc': 'Build geometric rectangles to discover the factors of quadratic polynomials.',
      'lab_mission': 'TARGET POLYNOMIAL',
      'step_0': 'Mission Setup',
      'instr_0': "Click 'Configure' to set your target equation parameters.",
      'btn_0': 'Configure',
      'step_1': 'Placing Foundation',
      'instr_1': "Drag the Blue x² Tile to the center.",
      'step_2': 'Mid-Term Strategy',
      'instr_2': "Split {b}x into two groups that multiply to {c}.",
      'btn_2': 'Strategize',
      'step_3': 'Horizontal Alignment',
      'instr_3': "Drag {p} Green Tiles to the RIGHT edge.",
      'step_4': 'Vertical Alignment',
      'instr_4': "Drag {q} Green Tiles to the BOTTOM edge.",
      'step_5': 'Corner Completion',
      'instr_5': "Fill the gap with {c} Yellow Unit Tiles.",
      'step_6': 'Dimension Scan',
      'instr_6': "Structure complete. Verify dimensions.",
      'btn_6': 'Measure Sides',
      'step_7': 'Factor Theorem',
      'instr_7': "Verification needed. Calculate remainders.",
      'btn_7': 'Site Inspector',
      'step_8': 'Reverse Blueprint',
      'instr_8': "Challenge: (x+4)(x+1). How many tiles?",
      'btn_8': 'Start Quiz',
      'step_9': 'Final Inspection',
      'instr_9': "Victory! Master Tile Architect Badge Unlocked.",
      'btn_next': 'Next',
      'q_inv': "Configure target polynomial: x² + (p+q)x + pq",
      'lbl_width_factor': 'Width Factor (p)',
      'lbl_height_factor': 'Height Factor (q)',
      'btn_ok': 'Initialize Mission',
      'err_dim_limit': 'Dimensions must be between 1 and 5',
      'q_split': "Split {b}x into two groups that multiply to {c}.",
      'ph_num1': 'Num 1',
      'ph_num2': 'Num 2',
      'btn_verify': 'Verify',
      'fb_correct': 'Correct!',
      'fb_incorrect_split': "Incorrect. Hint: p+q={b} and p*q={c}.",
      'fb_incorrect_generic': 'Incorrect. Try again.',
      'q_factor': "Calculate P(-{q}) for x²+{b}x+{c}.",
      'ph_remainder': 'Remainder',
      'fb_incorrect_factor': 'Incorrect.',
      'q_quiz': "For (x+4)(x+1), which set of tiles is correct?",
      'quiz_opt_a': 'A) 5x, 4 units',
      'quiz_opt_b': 'B) 4x, 1 unit',
      'hud_area': 'Area',
      'hud_live_factors': 'Geometric Formula',
      'err_zone': 'Wrong Zone!',
      'msg_awesome': 'PERFECT!',
      'msg_cleared': 'FACTORIZATION COMPLETE',
      'restart_btn': 'Restart Mission',
      'proof_title': 'Insight',
      'proof_proceed': 'Proceed',
      'lbl_parts': 'AVAILABLE TILES',
      'fb_scan_result': 'Width: x+{p}, Height: x+{q}',
      'lbl_step': 'Step',
      'msg_stable': 'STRUCTURE STABLE',
    },
    'hi': {
      'app_title': 'टाइल आर्किटेक्ट',
      'app_subtitle': 'कक्षा 9 • बहुपद – गुणनखंडन',
      'init_btn': 'लैब शुरू करें',
      'obj_title': 'मिशन उद्देश्य',
      'obj_desc': 'द्विघात बहुपदों के गुणनखंड खोजने के लिए ज्यामितीय आयत बनाएं।',
      'lab_mission': 'वर्तमान मिशन',
      'step_0': 'मिशन सेटअप',
      'instr_0': "लक्ष्य समीकरण सेट करने के लिए 'कॉन्फ़िगर करें' पर क्लिक करें।",
      'btn_0': 'कॉन्फ़िगर करें',
      'step_1': 'नींव रखना',
      'instr_1': "नीले x² टाइल को केंद्र में खींचें।",
      'step_2': 'मध्य-अवधि रणनीति',
      'instr_2': "{b}x को दो समूहों में विभाजित करें जो {c} से गुणा होते हैं।",
      'btn_2': 'रणनीति बनाएं',
      'step_3': 'क्षैतिज संरेखण',
      'instr_3': "दाईं ओर {p} हरी टाइलें खींचें।",
      'step_4': 'लंबवत संरेखण',
      'instr_4': "नीचे {q} हरी टाइलें खींचें।",
      'step_5': 'कोना पूरा करना',
      'instr_5': "अंतर को भरने के लिए {c} पीली टाइलें खींचें।",
      'step_6': 'आयाम स्कैन',
      'instr_6': "संरचना पूर्ण। आयामों को सत्यापित करें।",
      'btn_6': 'भुजाएं मापें',
      'step_7': 'गुणनखंड प्रमेय',
      'instr_7': "सत्यापन की आवश्यकता है। शेषफल की गणना करें।",
      'btn_7': 'साइट इंस्पेक्टर',
      'step_8': 'विपरीत ब्लूप्रिंट',
      'instr_8': "चुनौती: (x+4)(x+1)। कितनी टाइलें?",
      'btn_8': 'प्रश्नोत्तरी शुरू करें',
      'step_9': 'अंतिम निरीक्षण',
      'instr_9': "जीत! आपने मास्टर टाइल आर्किटेक्ट बैज अनलॉक कर लिया है।",
      'btn_next': 'अगला',
      'q_inv': "कॉन्फ़िगर लक्ष्य बहुपद: x² + (p+q)x + pq",
      'lbl_width_factor': 'चौड़ाई (p)',
      'lbl_height_factor': 'ऊंचाई (q)',
      'btn_ok': 'शुरू करें',
      'err_dim_limit': 'आयाम 1 और 5 के बीच होने चाहिए',
      'q_split': "{b}x को दो समूहों में विभाजित करें जो {c} से गुणा होते हैं।",
      'ph_num1': 'संख्या 1',
      'ph_num2': 'संख्या 2',
      'btn_verify': 'सत्यापित करें',
      'fb_correct': 'सही!',
      'fb_incorrect_split': "गलत। संकेत: p+q={b} और p*q={c}।",
      'fb_incorrect_generic': 'गलत। पुनः प्रयास करें।',
      'q_factor': "x²+{b}x+{c} के लिए P(-{q}) की गणना करें।",
      'ph_remainder': 'शेषफल',
      'fb_incorrect_factor': 'गलत।',
      'q_quiz': "(x+4)(x+1) के लिए, टाइलों का कौन सा सेट सही है?",
      'quiz_opt_a': 'A) 5x, 4 इकाइयाँ',
      'quiz_opt_b': 'B) 4x, 1 इकाई',
      'hud_area': 'क्षेत्रफल',
      'hud_live_factors': 'ज्यामितीय सूत्र',
      'err_zone': 'गलत क्षेत्र!',
      'msg_awesome': 'उत्तम!',
      'msg_cleared': 'गुणनखंडन पूरा हुआ',
      'restart_btn': 'मिशन पुनरारंभ करें',
      'proof_title': 'अंतर्दृष्टि',
      'proof_proceed': 'आगे बढ़ें',
      'lbl_parts': 'उपलब्ध टाइलें',
      'fb_scan_result': 'चौड़ाई: x+{p}, ऊंचाई: x+{q}',
      'lbl_step': 'कदम',
      'msg_stable': 'संरचना स्थिर',
    },
  };

  String t(String key) {
    String text = _i18n[lang]?[key] ?? _i18n['en']![key] ?? key;
    return text
        .replaceAll('{p}', p.toString())
        .replaceAll('{q}', q.toString())
        .replaceAll('{b}', b.toString())
        .replaceAll('{c}', c.toString());
  }

  // --- Lifecycle ---
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
    _transformController.dispose();
    super.dispose();
  }

  // --- Action Handlers ---
  void handleAction() {
    _playSound(_clickPlayer, _clickUrl);
    if (currentStep == 0) {
      _showConfigModal();
    } else if (currentStep == 2) {
      _showSplitModal();
    } else if (currentStep == 6) {
      _showFeedback(t('fb_scan_result'), false);
      _playSound(_fxPlayer, _alertUrl);
      setState(() => showProofPopup = true);
    } else if (currentStep == 7) {
      _showFactorModal();
    } else if (currentStep == 8) {
      _showQuizModal();
    }
  }

  void _showFeedback(String msg, bool isError) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isError ? themeColors['error'] : themeColors['success'],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      ),
    );
  }

  void nextStep() {
    _playSound(_successPlayer, _successUrl);
    setState(() {
      showProofPopup = false;
      _isStepTransitioning = true;
      if (currentStep < 9) currentStep++;
      if (currentStep == 8) {
        placedX2 = placedXH = placedXV = placed1 = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isStepTransitioning = false);
    });
  }

  void resetLab() {
    setState(() {
      currentStep = 0;
      p = 3;
      q = 2;
      placedX2 = placedXH = placedXV = placed1 = 0;
      showProofPopup = false;
      _isStepTransitioning = false;
      // FIX: Removed _showShutter = true; from here so it doesn't block the screen when starting!
    });
  }

  void handleTileDrop(String type) {
    if (currentStep == 0) return;
    bool valid = false;

    if (currentStep == 1 && type == 'x2' && placedX2 == 0) {
      valid = true;
    } else if (currentStep == 3 && type == 'x' && placedXH < p) {
      valid = true;
    } else if (currentStep == 4 && type == 'x' && placedXV < q) {
      valid = true;
    } else if (currentStep == 5 && type == '1' && placed1 < c) {
      valid = true;
    }

    if (valid) {
      _playSound(_clickPlayer, _clickUrl);
      HapticFeedback.selectionClick();
      setState(() {
        if (type == 'x2') placedX2++;
        else if (type == 'x' && currentStep == 3) placedXH++;
        else if (type == 'x' && currentStep == 4) placedXV++;
        else if (type == '1') placed1++;
      });
      
      if ((currentStep == 1 && placedX2 == 1) ||
          (currentStep == 3 && placedXH == p) ||
          (currentStep == 4 && placedXV == q) ||
          (currentStep == 5 && placed1 == c)) {
        Future.delayed(const Duration(milliseconds: 400), () {
          _playSound(_fxPlayer, _alertUrl);
          setState(() => showProofPopup = true);
        });
      }
    } else {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showFeedback(t('err_zone'), true);
    }
  }

  List<String> _getDebrisForCurrentStep() {
    List<String> debris = [];
    if (currentStep == 1 && placedX2 == 0) debris.add('x²');
    if (currentStep == 3) {
      for (int i = 0; i < p - placedXH; i++) debris.add('x');
    }
    if (currentStep == 4) {
      for (int i = 0; i < q - placedXV; i++) debris.add('x');
    }
    if (currentStep == 5) {
      for (int i = 0; i < c - placed1; i++) debris.add('1');
    }
    return debris;
  }

  // --- Modals ---
  void _showConfigModal() {
    int tempP = p;
    int tempQ = q;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 450,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                decoration: BoxDecoration(
                  color: themeColors['panel'],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeColors['accent']!),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t('step_0'),
                          style: TextStyle(color: themeColors['text'], fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(t('q_inv'), style: TextStyle(color: themeColors['muted'], fontSize: 14)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildNumberInput(t('lbl_width_factor'), tempP, (v) => setModalState(() => tempP = v))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildNumberInput(t('lbl_height_factor'), tempQ, (v) => setModalState(() => tempQ = v))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            "x² + ${tempP + tempQ}x + ${tempP * tempQ}",
                            style: TextStyle(color: themeColors['primary'], fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColors['primary'],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (tempP > 0 && tempP <= 5 && tempQ > 0 && tempQ <= 5) {
                                _playSound(_successPlayer, _successUrl);
                                setState(() {
                                  p = tempP;
                                  q = tempQ;
                                });
                                Navigator.pop(ctx);
                                nextStep();
                              } else {
                                _playSound(_errorPlayer, _errorUrl);
                                _showFeedback(t('err_dim_limit'), true);
                              }
                            },
                            child: Text(t('btn_ok').toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSplitModal() {
    int n1 = 0;
    int n2 = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            decoration: BoxDecoration(
              color: themeColors['panel'],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeColors['accent']!),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t('step_2'), style: TextStyle(color: themeColors['text'], fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(t('q_split'), style: TextStyle(color: themeColors['muted'], fontSize: 14)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              hintText: t('ph_num1'),
                              filled: true,
                              fillColor: Colors.black45,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (v) => n1 = int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              hintText: t('ph_num2'),
                              filled: true,
                              fillColor: Colors.black45,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (v) => n2 = int.tryParse(v) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors['primary'],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if ((n1 == p && n2 == q) || (n1 == q && n2 == p)) {
                            _playSound(_fxPlayer, _alertUrl);
                            Navigator.pop(ctx);
                            _showFeedback(t('fb_correct'), false);
                            setState(() => showProofPopup = true);
                          } else {
                            _playSound(_errorPlayer, _errorUrl);
                            _showFeedback(t('fb_incorrect_split'), true);
                          }
                        },
                        child: Text(t('btn_verify').toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFactorModal() {
    int rem = -1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            decoration: BoxDecoration(
              color: themeColors['panel'],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeColors['accent']!),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t('step_7'), style: TextStyle(color: themeColors['text'], fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(t('q_factor'), style: TextStyle(color: themeColors['muted'], fontSize: 14)),
                    const SizedBox(height: 24),
                    TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                        hintText: t('ph_remainder'),
                        filled: true,
                        fillColor: Colors.black45,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) => rem = int.tryParse(v) ?? -1,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors['primary'],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (rem == 0) {
                            _playSound(_fxPlayer, _alertUrl);
                            Navigator.pop(ctx);
                            _showFeedback(t('fb_correct'), false);
                            setState(() => showProofPopup = true);
                          } else {
                            _playSound(_errorPlayer, _errorUrl);
                            _showFeedback(t('fb_incorrect_factor'), true);
                          }
                        },
                        child: Text(t('btn_verify').toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuizModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            decoration: BoxDecoration(
              color: themeColors['panel'],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeColors['accent']!),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t('step_8'), style: TextStyle(color: themeColors['text'], fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(t('q_quiz'), style: TextStyle(color: themeColors['muted'], fontSize: 14)),
                    const SizedBox(height: 24),
                    _quizBtn(ctx, t('quiz_opt_a'), true),
                    const SizedBox(height: 12),
                    _quizBtn(ctx, t('quiz_opt_b'), false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quizBtn(BuildContext ctx, String text, bool isCorrect) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: themeColors['primary']!),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          if (isCorrect) {
            _playSound(_fxPlayer, _alertUrl);
            Navigator.pop(ctx);
            setState(() => showProofPopup = true);
          } else {
            _playSound(_errorPlayer, _errorUrl);
            _showFeedback(t('fb_incorrect_generic'), true);
          }
        },
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildNumberInput(String label, int val, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, color: themeColors['muted'], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                onPressed: () {
                  _playSound(_clickPlayer, _clickUrl);
                  onChanged(val > 1 ? val - 1 : 1);
                },
              ),
              Text('$val', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: () {
                  _playSound(_clickPlayer, _clickUrl);
                  onChanged(val < 5 ? val + 1 : 5);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Main Build ---
  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarWidth = screenW * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: themeColors['bg'],
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: themeColors['panel'],
                    border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: sidebarWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                        child: _buildSidebarContent(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildWorkspaceArea(screenW),
                ),
              ],
            ),

            // Top Left Menu Button
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _playSound(_clickPlayer, _clickUrl);
                      setState(() {
                        _sidebarOpen = !_sidebarOpen;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

            if (showProofPopup && !_showShutter) _buildProofPopup(),
            if (currentStep >= 9 && !_isStepTransitioning && !_showShutter && !showProofPopup) 
              _buildCelebrationScreen(),
            if (_showShutter) _buildLoadingShutter(),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildSidebarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),

          Text(
            t('app_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            t('app_subtitle'),
            style: TextStyle(
              color: themeColors['primary'],
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Translation and Reset Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColors['accent']!.withOpacity(0.3)),
                ),
                child: Row(children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColors['error']!.withOpacity(0.6), width: 2.0),
                ),
                child: IconButton(
                  icon: Icon(Icons.power_settings_new, color: themeColors['error']),
                  tooltip: t('btn_reset'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() {
                      _showShutter = true;
                    });
                    resetLab();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildProgressHUD(),
          const SizedBox(height: 16),

          _buildJournal(),

          const SizedBox(height: 32),

          const Center(
            child: Text(
              "© ZEROSCIENCELAB | Fall in Love with Math and Science",
              style: TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // DEFINITION FOR LANG BTN TO FIX THE ERROR
  Widget _langBtn(String code, String label) {
    bool active = lang == code;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
        setState(() => lang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? themeColors['accent'] : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHUD() {
    double progress = ((currentStep + 1) / 10).clamp(0.0, 1.0);
    String phase = currentStep < 9 ? t('lab_mission') : t('msg_stable');
    bool isComplete = currentStep >= 9;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  phase,
                  style: TextStyle(
                    color: isComplete ? themeColors['success'] : themeColors['accent'], 
                    fontWeight: FontWeight.bold, 
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                isComplete ? '' : '${t('lbl_step')} ${currentStep + 1}/10',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: isComplete ? themeColors['success'] : themeColors['accent'],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildJournal() {
    if (currentStep >= 9) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: themeColors['success'], size: 64),
            const SizedBox(height: 16),
            Text(t('msg_stable'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: themeColors['success']), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(t('msg_cleared'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: themeColors['primary'], foregroundColor: Colors.black),
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_shutterPlayer, _shutterUrl);
                setState(() {
                  _showShutter = true;
                });
                resetLab();
              },
              icon: const Icon(Icons.refresh),
              label: Text(t('restart_btn')),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentStep + 1,
      itemBuilder: (context, index) {
        bool isActive = index == currentStep;
        bool isCompleted = index < currentStep;

        List<String> debris = [];
        if (isActive) debris = _getDebrisForCurrentStep();
        bool hasAction = isActive && [0, 2, 6, 7, 8].contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? themeColors['accent']!.withOpacity(0.05) : Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? themeColors['accent']! : (isCompleted ? themeColors['success']! : Colors.white10),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isActive ? themeColors['accent'] : (isCompleted ? themeColors['success'] : Colors.white24),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.black, size: 14)
                        : Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('step_$index').toUpperCase(),
                      style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(t('instr_$index'), style: const TextStyle(color: Colors.white60, fontSize: 14)),
              
              if (isActive && !_isStepTransitioning && !showProofPopup) ...[
                const SizedBox(height: 16),
                if (hasAction)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColors['accent'],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: handleAction,
                    child: Text(t('btn_$index'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                if (debris.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDebrisField(debris),
                ]
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebrisField(List<String> debris, {bool compact = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(t('lbl_parts').toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.touch_app, color: themeColors['primary'], size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: debris.toSet().map((term) {
              Color tColor = term == 'x²' ? Colors.blue : (term == 'x' ? Colors.green : Colors.yellow);
              return Draggable<String>(
                data: term == 'x²' ? 'x2' : term,
                feedback: Material(
                  color: Colors.transparent,
                  child: _debrisWidget(term, tColor, isDragging: true, compact: compact),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: _debrisWidget(term, tColor, compact: compact)),
                onDragStarted: () {
                  HapticFeedback.selectionClick();
                  _playSound(_clickPlayer, _clickUrl);
                },
                child: _debrisWidget(term, tColor, compact: compact),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _debrisWidget(String text, Color tColor, {bool isDragging = false, bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: tColor.withOpacity(0.2),
        border: Border.all(color: tColor.withOpacity(0.8), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging ? [BoxShadow(color: tColor.withOpacity(0.5), blurRadius: 10)] : [],
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: compact ? 13 : 14)),
    );
  }

  Widget _buildWorkspaceArea(double screenW) {
    return ClipRect(
      child: Stack(
        children: [
          // Background Grid
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // Interactive 2D Board
          InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.5,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: Container(
              // Shift the board right when HUD is visible to avoid overlapping the visuals
              padding: EdgeInsets.only(
                left: (!_sidebarOpen && !_showShutter && !_isStepTransitioning && !showProofPopup) 
                    ? math.min(screenW * 0.35, 380.0) 
                    : 0,
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 500,
                height: 500,
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (details) => currentStep > 0,
                  onAcceptWithDetails: (details) => handleTileDrop(details.data),
                  builder: (context, candidateData, rejectedData) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Origin Point Marker
                        if (currentStep >= 1)
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),

                        // 1. Foundation: x² (Blue Square)
                        if (placedX2 > 0)
                          Positioned(
                            left: 250 - 60,
                            top: 250 - 60,
                            child: _boardTile(120, 120, Colors.blue, 'x²'),
                          ),

                        // 2. Horizontal: x (Green Rectangles)
                        for (int i = 0; i < placedXH; i++)
                          Positioned(
                            left: 250 + 60 + (i * 30),
                            top: 250 - 60,
                            child: _boardTile(28, 120, Colors.green, 'x'),
                          ),

                        // 3. Vertical: x (Green Rectangles)
                        for (int i = 0; i < placedXV; i++)
                          Positioned(
                            left: 250 - 60,
                            top: 250 + 60 + (i * 30),
                            child: _boardTile(120, 28, Colors.green, 'x'),
                          ),

                        // 4. Units: 1 (Yellow Squares)
                        for (int i = 0; i < placed1; i++)
                          Positioned(
                            left: 250 + 60 + ((i % p) * 30),
                            top: 250 + 60 + ((i ~/ p) * 30),
                            child: _boardTile(28, 28, Colors.yellow, '1'),
                          ),

                        // 5. Measure Lines (Step 6)
                        if (currentStep >= 6 && currentStep < 8) ...[
                          Positioned(
                            left: 250 - 60,
                            top: 250 - 80,
                            child: Container(width: 120 + (p * 30), height: 2, color: Colors.white),
                          ),
                          Positioned(
                            left: 250 - 60,
                            top: 250 - 95,
                            child: SizedBox(
                              width: 120 + (p * 30),
                              child: Text('x + $p', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),

                          Positioned(
                            left: 250 - 80,
                            top: 250 - 60,
                            child: Container(width: 2, height: 120 + (q * 30), color: Colors.white),
                          ),
                          Positioned(
                            left: 250 - 120,
                            top: 250 - 60 + ((120 + (q * 30)) / 2) - 10,
                            child: SizedBox(
                              width: 30,
                              child: Text('x + $q', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Left Compact HUD
          if (!_sidebarOpen && !_showShutter && !_isStepTransitioning && !showProofPopup)
            _buildFloatingHUD(screenW),
        ],
      ),
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    if (currentStep >= 9) return const SizedBox.shrink(); 

    double hudWidth = math.min(screenW * 0.35, 380.0); // Constrained width so it doesn't overlap visuals

    return Positioned(
      bottom: 20,
      left: 20, // Bottom Left Placement
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        width: hudWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: themeColors['primary']!, width: 4),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('lab_mission').toUpperCase(), 
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                t('step_$currentStep').toUpperCase(), 
                style: const TextStyle(
                  color: Colors.white, 
                  fontFamily: 'monospace', 
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('instr_$currentStep'), 
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 12),
              
              if ([0, 2, 6, 7, 8].contains(currentStep))
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColors['accent'],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: handleAction,
                  child: Text(t('btn_$currentStep'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              
              if (_getDebrisForCurrentStep().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDebrisField(_getDebrisForCurrentStep(), compact: true),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _boardTile(double w, double h, Color c, String lbl) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c.withOpacity(0.9),
        border: Border.all(color: Colors.black87, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          lbl,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getProofMath() {
    if (currentStep == 1) return "Area = x * x = x²";
    if (currentStep == 3) return "Width = x + $p";
    if (currentStep == 4) return "Height = x + $q";
    if (currentStep == 5) return "Area = x² + ${b}x + $c";
    if (currentStep == 6) return "Area = (x+$p)(x+$q)";
    return "Completed.";
  }

  Widget _buildProofPopup() {
    double modalWidth = math.min(MediaQuery.of(context).size.width * 0.9, 450.0);

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        alignment: Alignment.center,
        child: Container(
          width: modalWidth,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
          decoration: BoxDecoration(
            color: themeColors['panel'],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColors['accent']!.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: themeColors['accent']!.withOpacity(0.2), blurRadius: 30)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: modalWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColors['accent']!.withOpacity(0.1),
                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: themeColors['accent'], size: 18),
                          const SizedBox(width: 8),
                          Text(t('proof_title').toUpperCase(), style: TextStyle(color: themeColors['accent'], fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Algebraic Concept",
                            style: TextStyle(color: themeColors['muted'], fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              _getProofMath(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black26,
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: themeColors['success'], foregroundColor: Colors.black),
                        onPressed: nextStep,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(t('proof_proceed'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationScreen() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Container(
              width: 450,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
              decoration: BoxDecoration(
                color: themeColors['bg'],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColors['success']!, width: 2),
                boxShadow: [BoxShadow(color: themeColors['success']!.withOpacity(0.2), blurRadius: 80)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, color: themeColors['accent'], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          t('msg_awesome'),
                          style: TextStyle(color: themeColors['success'], fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t('msg_cleared'),
                          style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColors['primary'],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _playSound(_shutterPlayer, _shutterUrl);
                            setState(() => _showShutter = true);
                            resetLab();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(t('restart_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShutter() {
    return Container(
      color: themeColors['bg'],
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColors['primary']!.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(color: themeColors['primary']!.withOpacity(0.3), blurRadius: 40),
                    ],
                  ),
                  child: Icon(Icons.layers, color: themeColors['primary'], size: 50),
                ),
                const SizedBox(height: 32),
                Text(
                  t('app_title').toUpperCase(),
                  style: TextStyle(color: themeColors['primary'], fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text(
                  t('app_subtitle').toUpperCase(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColors['primary'],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_shutterPlayer, _shutterUrl); 
                    setState(() => _showShutter = false);
                    resetLab();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(t('init_btn').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Background Grid lines
class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0;
    const double spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}