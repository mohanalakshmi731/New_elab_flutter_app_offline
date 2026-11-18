// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LCMHCFApp()),
  );
}

class LCMHCFApp extends StatelessWidget {
  const LCMHCFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainCircuitLab();
  }
}

// --- AUDIO CONFIGURATION ---
// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
final AudioPlayer _clickPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);

const String _clickUrl = 'audio/math/click.mp3';
const String _successUrl = 'audio/math/success.mp3';
const String _errorUrl = 'audio/math/error.mp3';
const String _shutterUrl = 'audio/math/shutter.mp3';

void _playAudio(AudioPlayer player, String url) async {
  try {
    await player.stop();
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio play error: $e");
  }
}

void _playClick() => _playAudio(_clickPlayer, _clickUrl);
void _playSuccess() => _playAudio(_successPlayer, _successUrl);
void _playError() => _playAudio(_errorPlayer, _errorUrl);
void _playShutter() => _playAudio(_fxPlayer, _shutterUrl);

// --- LOCALIZATION DATA ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE LCM-HCF CIRCUIT',
    'tagline': 'CONNECTING THE NUMBERS',
    'init_btn': 'POWER ON LAB',
    'header_title': 'The LCM-HCF Circuit',
    'header_subtitle': 'CLASS 10 • REAL NUMBERS - HCF & LCM Relationship.',
    'btn_start_lab': 'Open Circuit',
    'setup_title': 'Circuit Setup',
    'btn_init': 'Initialize Circuit',
    'btn_restart': 'Restart Activity',
    'hud_theorem': 'Circuit Logic',
    'hud_status': 'Status',
    'msg_verified': 'VERIFIED!',
    'step_wait': 'Waiting for Input...',
    'step_done': 'Circuit Balanced! \nRelationship Verified.',

    // UI Elements
    'num_a_label': 'Number A',
    'num_b_label': 'Number B',
    'inputs_label': 'INPUTS',
    'step_1': '1. Click HCF Chip',
    'step_2': '2. Click LCM Chip',
    'step_3': '3. Click Left Tank (A×B)',
    'step_4': '4. Click Right Tank (H×L)',
    'num_a_short': 'Num A',
    'num_b_short': 'Num B',
    'hcf_label': 'HCF',
    'lcm_label': 'LCM',
    'prod_ab_label': 'Product A×B',
    'prod_hl_label': 'Product H×L',
    'theorem_formula': 'HCF × LCM = A × B',
    'mission_title': 'CURRENT MISSION',
    'btn_view_lab': 'VIEW LAB',

    // Readouts
    'readout_input_a': 'INPUT A',
    'readout_input_b': 'INPUT B',
    'readout_hcf': 'HCF',
    'readout_lcm': 'LCM',
    'readout_hcf_calc': 'HCF CALCULATED',
    'readout_lcm_calc': 'LCM CALCULATED',
    'readout_prod_ab': 'PRODUCT A×B',
    'readout_prod_hl': 'PRODUCT H×L',

    // Challenges
    'chal_hcf_title': 'CALCULATE HCF',
    'chal_hcf_desc': 'Find HCF of {A} and {B}',
    'chal_lcm_title': 'CALCULATE LCM',
    'chal_lcm_desc': 'Find LCM of {A} and {B}',
    'chal_tank_n_title': 'POWER LEFT TANK',
    'chal_tank_n_desc':
        'Calculate the Product of Inputs to fill the first tank.\n\nMultiply: {A} × {B}',
    'chal_tank_n_hint': 'Goal: Find the total value of the input numbers.',
    'chal_tank_f_title': 'POWER RIGHT TANK',
    'chal_tank_f_desc':
        'Now calculate the Product of HCF & LCM to fill the second tank.\n\nMultiply: {H} × {L}',
    'chal_tank_f_hint':
        'Verification: This result must match the Left Tank!\nPrevious Result: {P}',

    // Buttons & Keypad
    'btn_enter': 'ENTER',
    'btn_del': 'DEL',

    // Hints & Descriptions
    'hint_step1': 'Step 1: Prime Factorization',
    'hint_step2_hcf': 'Step 2: Take smallest power of common primes.',
    'hint_step2_lcm': 'Step 2: Take highest power of every prime.',
    'hint_setup': 'Enter two numbers and initialize the circuit to begin.',
    'hint_task_0':
        'ACTION: Click the Purple HCF Chip to calculate the Highest Common Factor.',
    'hint_task_1':
        'ACTION: Click the Pink LCM Chip to calculate the Lowest Common Multiple.',
    'hint_task_2':
        'ACTION: Click the Left Tank to calculate the Product of A and B.',
    'hint_task_3':
        'ACTION: Click the Right Tank to calculate the Product of HCF and LCM.',
    'hint_task_4':
        'MISSION ACCOMPLISHED: The equation is balanced and verified!',
  },
  'hi': {
    'app_title': 'LCM-HCF सर्किट',
    'tagline': 'संख्याओं को जोड़ना',
    'init_btn': 'लैब चालू करें',
    'header_title': 'LCM-HCF सर्किट',
    'header_subtitle':
        'कक्षा 10 • वास्तविक संख्याएँ – महत्तम समापवर्तक (HCF) और लघुत्तम समापवर्त्य (LCM) का संबंध.',
    'btn_start_lab': 'सर्किट खोलें',
    'setup_title': 'सर्किट सेटअप',
    'btn_init': 'सर्किट शुरू करें',
    'btn_restart': 'पुनः आरंभ करें',
    'hud_theorem': 'सर्किट लॉजिक',
    'hud_status': 'स्थिति',
    'msg_verified': 'सत्यापित!',
    'step_wait': 'इनपुट की प्रतीक्षा...',
    'step_done': 'सर्किट संतुलित! \nसंबंध सत्यापित।',

    // UI Elements
    'num_a_label': 'संख्या A',
    'num_b_label': 'संख्या B',
    'inputs_label': 'इनपुट्स',
    'step_1': '1. HCF चिप पर क्लिक करें',
    'step_2': '2. LCM चिप पर क्लिक करें',
    'step_3': '3. बाएं टैंक पर क्लिक करें (A×B)',
    'step_4': '4. दाएं टैंक पर क्लिक करें (H×L)',
    'num_a_short': 'संख्या A',
    'num_b_short': 'संख्या B',
    'hcf_label': 'HCF (म.स.प.)',
    'lcm_label': 'LCM (ल.स.प.)',
    'prod_ab_label': 'गुणनफल A×B',
    'prod_hl_label': 'गुणनफल H×L',
    'theorem_formula': 'HCF × LCM = A × B',
    'mission_title': 'वर्तमान मिशन',
    'btn_view_lab': 'लैब देखें',

    // Readouts
    'readout_input_a': 'इनपुट A',
    'readout_input_b': 'इनपुट B',
    'readout_hcf': 'HCF (म.स.प.)',
    'readout_lcm': 'LCM (ल.स.प.)',
    'readout_hcf_calc': 'HCF की गणना की गई',
    'readout_lcm_calc': 'LCM की गणना की गई',
    'readout_prod_ab': 'गुणनफल A×B',
    'readout_prod_hl': 'गुणनफल H×L',

    // Challenges
    'chal_hcf_title': 'HCF की गणना करें',
    'chal_hcf_desc': '{A} और {B} का HCF ज्ञात करें',
    'chal_lcm_title': 'LCM की गणना करें',
    'chal_lcm_desc': '{A} और {B} का LCM ज्ञात करें',
    'chal_tank_n_title': 'बाएं टैंक को भरें',
    'chal_tank_n_desc':
        'पहले टैंक को भरने के लिए इनपुट्स का गुणनफल निकालें।\n\nगुणा करें: {A} × {B}',
    'chal_tank_n_hint': 'लक्ष्य: इनपुट संख्याओं का कुल मान ज्ञात करें।',
    'chal_tank_f_title': 'दाएं टैंक को भरें',
    'chal_tank_f_desc':
        'अब दूसरे टैंक को भरने के लिए HCF और LCM का गुणनफल निकालें।\n\nगुणा करें: {H} × {L}',
    'chal_tank_f_hint':
        'सत्यापन: यह परिणाम बाएं टैंक से मेल खाना चाहिए!\nपिछला परिणाम: {P}',

    // Buttons & Keypad
    'btn_enter': 'दर्ज करें',
    'btn_del': 'मिटाएं',

    // Hints & Descriptions
    'hint_step1': 'चरण 1: अभाज्य गुणनखंडन (Prime Factorization)',
    'hint_step2_hcf':
        'चरण 2: उभयनिष्ठ अभाज्य संख्याओं की सबसे छोटी घात (power) लें।',
    'hint_step2_lcm':
        'चरण 2: प्रत्येक अभाज्य संख्या की सबसे बड़ी घात (power) लें।',
    'hint_setup': 'शुरू करने के लिए दो संख्याएँ दर्ज करें और सर्किट चालू करें।',
    'hint_task_0':
        'कार्य: HCF (म.स.प.) की गणना करने के लिए बैंगनी चिप पर क्लिक करें।',
    'hint_task_1':
        'कार्य: LCM (ल.स.प.) की गणना करने के लिए गुलाबी चिप पर क्लिक करें।',
    'hint_task_2':
        'कार्य: गुणनफल (A × B) की गणना के लिए बाएं टैंक पर क्लिक करें।',
    'hint_task_3':
        'कार्य: गुणनफल (HCF × LCM) की गणना के लिए दाएं टैंक पर क्लिक करें।',
    'hint_task_4': 'मिशन पूरा हुआ: समीकरण संतुलित और सत्यापित है!',
  },
};

// --- MAIN WIDGET ---
class MainCircuitLab extends StatefulWidget {
  const MainCircuitLab({super.key});

  @override
  State<MainCircuitLab> createState() => _MainCircuitLabState();
}

class _MainCircuitLabState extends State<MainCircuitLab>
    with TickerProviderStateMixin {
  // App State
  bool isPoweredOn = false;
  String lang = 'en';
  bool isSidebarOpen = true;

  // Logic State
  bool circuitReady = false;
  int currentStep = 0;
  int numA = 12;
  int numB = 18;

  // Readout overlay
  String readoutLabel = '';
  String readoutValue = '';
  bool showReadout = false;
  Timer? readoutTimer;

  // Challenge Modal State
  bool showChallenge = false;
  String challengeType = '';
  String currentInput = '';
  bool showHint = false;
  bool isErrorShake = false;

  // Animators
  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;
  late TransformationController _transformController;

  // Circuit Component Animations
  double tankNFill = 0.0;
  double tankFFill = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shutterAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
          CurvedAnimation(
            parent: _shutterController,
            curve: Curves.easeInOutCubic,
          ),
        );
    _transformController = TransformationController();
  }

  @override
  void dispose() {
    _shutterController.dispose();
    _transformController.dispose();
    readoutTimer?.cancel();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // --- MATH LOGIC ---
  int calcGCD(int a, int b) => b == 0 ? a : calcGCD(b, a % b);
  int calcLCM(int a, int b) => (a * b) ~/ calcGCD(a, b);
  int get hcfVal => calcGCD(numA, numB);
  int get lcmVal => calcLCM(numA, numB);

  Map<int, int> getPrimeFactors(int n) {
    Map<int, int> factors = {};
    int d = 2;
    int temp = n;
    while (d * d <= temp) {
      while (temp % d == 0) {
        factors[d] = (factors[d] ?? 0) + 1;
        temp = temp ~/ d;
      }
      d++;
    }
    if (temp > 1) factors[temp] = (factors[temp] ?? 0) + 1;
    return factors;
  }

  // Localization Helpers
  String _t(String key) => i18n[lang]?[key] ?? key;

  String _tVars(String key, Map<String, String> vars) {
    String text = _t(key);
    vars.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  // --- ACTIONS ---
  void powerOn() {
    _playShutter();
    setState(() => isPoweredOn = true);
    _shutterController.forward();
  }

  void _centerCanvas() {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    double scale = 0.45;

    double dx = (screenW / 2) - (1000 * scale);
    double dy = (screenH / 2) - (1000 * scale);

    if (isSidebarOpen) {
      dx += (screenW * 0.4) / 2;
    }

    _transformController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  void startCircuit() {
    if (numA < 1 || numB < 1) {
      _playError();
      return;
    }
    _playClick();
    setState(() {
      circuitReady = true;
      currentStep = 0;
      tankNFill = 0.0;
      tankFFill = 0.0;
    });

    _centerCanvas();
  }

  void resetCircuit() {
    _playClick();
    setState(() {
      circuitReady = false;
      currentStep = 0;
      tankNFill = 0.0;
      tankFFill = 0.0;
      showReadout = false;
      showChallenge = false;
    });
  }

  void triggerReadout(String label, String val) {
    setState(() {
      readoutLabel = label;
      readoutValue = val;
      showReadout = true;
    });
    readoutTimer?.cancel();
    readoutTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => showReadout = false);
    });
  }

  void handleComponentClick(String type) {
    if (!circuitReady) return;
    _playClick();

    if (type == 'hcf' && currentStep == 0) {
      openChallenge('hcf');
    } else if (type == 'lcm' && currentStep == 1) {
      openChallenge('lcm');
    } else if (type == 'prod_n' && currentStep == 2) {
      openChallenge('prod_n');
    } else if (type == 'prod_f' && currentStep == 3) {
      openChallenge('prod_f');
    } else {
      if (type == 'num_a') {
        triggerReadout(_t('readout_input_a'), numA.toString());
      }
      if (type == 'num_b') {
        triggerReadout(_t('readout_input_b'), numB.toString());
      }
      if (type == 'hcf' && currentStep > 0) {
        triggerReadout(_t('readout_hcf'), hcfVal.toString());
      }
      if (type == 'lcm' && currentStep > 1) {
        triggerReadout(_t('readout_lcm'), lcmVal.toString());
      }
      if (type == 'prod_n' && currentStep > 2) {
        triggerReadout(_t('readout_prod_ab'), (numA * numB).toString());
      }
      if (type == 'prod_f' && currentStep > 3) {
        triggerReadout(_t('readout_prod_hl'), (hcfVal * lcmVal).toString());
      }
    }
  }

  void openChallenge(String type) {
    setState(() {
      challengeType = type;
      currentInput = '';
      showHint = false;
      showChallenge = true;
    });
  }

  void submitChallenge() {
    int userVal = int.tryParse(currentInput) ?? -1;
    bool isCorrect = false;

    if (challengeType == 'hcf') {
      isCorrect = (userVal == hcfVal);
    } else if (challengeType == 'lcm') {
      isCorrect = (userVal == lcmVal);
    } else if (challengeType == 'prod_n') {
      isCorrect = (userVal == (numA * numB));
    } else if (challengeType == 'prod_f') {
      isCorrect = (userVal == (hcfVal * lcmVal));
    }

    if (isCorrect) {
      _playSuccess();
      setState(() {
        showChallenge = false;
        if (challengeType == 'hcf') {
          triggerReadout(_t('readout_hcf_calc'), hcfVal.toString());
          currentStep = 1;
        } else if (challengeType == 'lcm') {
          triggerReadout(_t('readout_lcm_calc'), lcmVal.toString());
          currentStep = 2;
        } else if (challengeType == 'prod_n') {
          triggerReadout(_t('readout_prod_ab'), (numA * numB).toString());
          tankNFill = 1.0;
          currentStep = 3;
        } else if (challengeType == 'prod_f') {
          triggerReadout(_t('readout_prod_hl'), (hcfVal * lcmVal).toString());
          tankFFill = 1.0;
          currentStep = 4;
          Timer(const Duration(seconds: 1), () {
            triggerReadout(
              _t('msg_verified'),
              '${numA * numB} = ${hcfVal * lcmVal}',
            );
          });
        }
      });
    } else {
      _playError();
      setState(() => isErrorShake = true);
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => isErrorShake = false);
      });
    }
  }

  // --- BUILDERS ---

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidePanelWidth = screenWidth * 0.40; // 40% of the screen

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Base Layer (Canvas)
            _buildMainCanvas(sidePanelWidth),

            // 2. Left Side Panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isSidebarOpen ? 0 : -sidePanelWidth,
              top: 0,
              bottom: 0,
              width: sidePanelWidth,
              child: _buildSidePanel(),
            ),

            // 3. Readout Overlay
            if (showReadout)
              Positioned.fill(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF0EA5E9),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x800EA5E9),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                readoutLabel,
                                style: const TextStyle(
                                  color: Color(0xFF22D3EE),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                readoutValue,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 80,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white54,
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // 4. Floating Mission Card Layered Below Buttons
            if (!isSidebarOpen)
              Positioned(
                top:
                    110, // Dropped down to avoid overlapping the top center HUD
                left: 20,
                bottom: 24,
                width:
                    sidePanelWidth -
                    40, // Matches sidebar width footprint visually
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.yellow.shade400,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          circuitReady
                                              ? Icons.assignment_late
                                              : Icons.settings,
                                          color: Colors.yellow.shade400,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          circuitReady
                                              ? _t('mission_title')
                                              : _t('setup_title').toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.yellow.shade400,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _playClick();
                                        setState(() {
                                          isSidebarOpen = true;
                                          if (circuitReady) _centerCanvas();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade400,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _t('btn_view_lab'),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (!circuitReady) ...[
                                  _buildStepDescription(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: numA.toString(),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 10,
                                                ),
                                            filled: true,
                                            fillColor: Color(0xFF0F172A),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF0EA5E9),
                                              ),
                                            ),
                                          ),
                                          onChanged: (v) =>
                                              numA = int.tryParse(v) ?? 1,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: numB.toString(),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 10,
                                                ),
                                            filled: true,
                                            fillColor: Color(0xFF0F172A),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF0EA5E9),
                                              ),
                                            ),
                                          ),
                                          onChanged: (v) =>
                                              numB = int.tryParse(v) ?? 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        startCircuit();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0EA5E9,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(_t('btn_init')),
                                    ),
                                  ),
                                ] else ...[
                                  _buildStepDescription(),
                                  _stepItem(
                                    0,
                                    _t('step_1'),
                                    Icons.memory,
                                    Colors.blue,
                                    compact: true,
                                  ),
                                  _stepItem(
                                    1,
                                    _t('step_2'),
                                    Icons.account_tree,
                                    Colors.cyan,
                                    compact: true,
                                  ),
                                  _stepItem(
                                    2,
                                    _t('step_3'),
                                    Icons.battery_4_bar,
                                    Colors.purple,
                                    compact: true,
                                  ),
                                  _stepItem(
                                    3,
                                    _t('step_4'),
                                    Icons.battery_full,
                                    Colors.green,
                                    compact: true,
                                  ),
                                  if (currentStep >= 4) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: resetCircuit,
                                        icon: const Icon(Icons.refresh),
                                        label: Text(_t('btn_restart')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade600,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 5. Floating Menu Button (Top Left)
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                heroTag: 'menuBtn',
                shape: const CircleBorder(),
                backgroundColor: isSidebarOpen
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                elevation: 8,
                highlightElevation: 12,
                onPressed: () {
                  _playClick();
                  setState(() {
                    isSidebarOpen = !isSidebarOpen;
                    if (circuitReady) {
                      _centerCanvas();
                    }
                  });
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isSidebarOpen ? Icons.close : Icons.menu,
                    key: ValueKey(isSidebarOpen),
                  ),
                ),
              ),
            ),

            // 6. Challenge Modal Overlay
            if (showChallenge) _buildChallengeModal(),

            // 7. Shutter Curtain Overlay
            SlideTransition(
              position: _shutterAnimation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.memory,
                        size: 100,
                        color: Color(0xFF22D3EE),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _t('app_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t('tagline'),
                        style: const TextStyle(
                          color: Color(0xFFA5F3FC),
                          fontSize: 16,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: powerOn,
                        icon: const Icon(Icons.power_settings_new),
                        label: Text(_t('init_btn')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          shadowColor: const Color(0xFF0EA5E9),
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

  // --- SUB-WIDGETS ---

  Widget _buildStepDescription() {
    String text = '';
    if (!circuitReady)
      text = _t('hint_setup');
    else if (currentStep == 0)
      text = _t('hint_task_0');
    else if (currentStep == 1)
      text = _t('hint_task_1');
    else if (currentStep == 2)
      text = _t('hint_task_2');
    else if (currentStep == 3)
      text = _t('hint_task_3');
    else
      text = _t('hint_task_4');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF22D3EE),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.98),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 5),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 80,
                bottom: 40,
                left: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  Text(
                    _t('header_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _t('header_subtitle'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Controls: Lang & Restart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF475569)),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: ['en', 'hi']
                              .map(
                                (l) => GestureDetector(
                                  onTap: () {
                                    _playClick();
                                    setState(() => lang = l);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: lang == l
                                          ? const Color(0xFF0EA5E9)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      l.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: lang == l
                                            ? Colors.white
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _playClick();
                          setState(() {
                            circuitReady = false;
                            isPoweredOn = false;
                            _shutterController.reverse();
                          });
                        },
                        icon: const Icon(Icons.power_settings_new),
                        color: const Color(0xFFEF4444),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x33EF4444),
                        ),
                        tooltip: _t('btn_restart'),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 40,
                    thickness: 1.5,
                    color: Color(0xFF334155),
                  ),

                  // Main Content Area
                  if (!circuitReady) ...[
                    // Setup UI
                    Text(
                      _t('setup_title').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStepDescription(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('num_a_label'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: numA.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF0F172A),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF0EA5E9),
                                    ),
                                  ),
                                ),
                                onChanged: (v) => numA = int.tryParse(v) ?? 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('num_b_label'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: numB.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF0F172A),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF0EA5E9),
                                    ),
                                  ),
                                ),
                                onChanged: (v) => numB = int.tryParse(v) ?? 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          startCircuit();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_t('btn_init')),
                      ),
                    ),
                  ] else ...[
                    // Logic & Steps UI
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('inputs_label'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'A: $numA | B: $numB',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: resetCircuit,
                            icon: const Icon(Icons.refresh),
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStepDescription(),
                    _stepItem(0, _t('step_1'), Icons.memory, Colors.blue),
                    _stepItem(1, _t('step_2'), Icons.account_tree, Colors.cyan),
                    _stepItem(
                      2,
                      _t('step_3'),
                      Icons.battery_4_bar,
                      Colors.purple,
                    ),
                    _stepItem(
                      3,
                      _t('step_4'),
                      Icons.battery_full,
                      Colors.green,
                    ),
                    if (currentStep >= 4) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: resetCircuit,
                          icon: const Icon(Icons.refresh),
                          label: Text(_t('btn_restart')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            _buildSidebarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        border: Border(
          top: BorderSide(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
        ),
      ),
      child: const Center(
        child: Text(
          '© ZEROSCIENCELAB | Fall in Love with Math and Science',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _stepItem(
    int stepIndex,
    String label,
    IconData icon,
    MaterialColor color, {
    bool compact = false,
  }) {
    bool isDone = currentStep > stepIndex;
    bool isActive = currentStep == stepIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: compact ? 6 : 8),
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF0F172A)
            : isActive
            ? const Color(0xFF334155)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.yellow.shade400 : const Color(0xFF334155),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.yellow.shade900.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDone
                ? Colors.green.withOpacity(0.2)
                : isActive
                ? color.withOpacity(0.2)
                : const Color(0xFF334155),
            foregroundColor: isDone
                ? Colors.green.shade400
                : isActive
                ? color.shade400
                : const Color(0xFF94A3B8),
            radius: compact ? 12 : 16,
            child: Icon(isDone ? Icons.check : icon, size: compact ? 12 : 16),
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: isDone ? const Color(0xFF64748B) : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CIRCUIT BOARD CANVAS ---
  Widget _buildMainCanvas(double sidePanelWidth) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Interactive 2D Circuit
          InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.1,
            maxScale: 2.0,
            child: SizedBox(
              width: 2000,
              height: 2000,
              child: CustomPaint(
                painter: CircuitGridPainter(),
                child: Stack(
                  children: [
                    // Wires
                    CustomPaint(
                      painter: CircuitWirePainter(
                        nodes: {
                          'A': const Offset(600, 600),
                          'B': const Offset(1400, 600),
                          'HCF': const Offset(800, 1000),
                          'LCM': const Offset(1200, 1000),
                          'TANK_N': const Offset(600, 1400),
                          'TANK_F': const Offset(1400, 1400),
                        },
                      ),
                      child: Container(),
                    ),

                    // Interactive Components
                    _buildNodeComp(
                      600,
                      600,
                      'num_a',
                      _t('num_a_short'),
                      numA.toString(),
                      Colors.lightBlue,
                    ),
                    _buildNodeComp(
                      1400,
                      600,
                      'num_b',
                      _t('num_b_short'),
                      numB.toString(),
                      Colors.blue,
                    ),

                    _buildChipComp(
                      800,
                      1000,
                      'hcf',
                      _t('hcf_label'),
                      currentStep > 0 ? hcfVal.toString() : '?',
                      Colors.purple,
                      currentStep == 0,
                    ),
                    _buildChipComp(
                      1200,
                      1000,
                      'lcm',
                      _t('lcm_label'),
                      currentStep > 1 ? lcmVal.toString() : '?',
                      Colors.pink,
                      currentStep == 1,
                    ),

                    _buildTankComp(
                      600,
                      1400,
                      'prod_n',
                      _t('prod_ab_label'),
                      currentStep > 2 ? (numA * numB).toString() : '0',
                      Colors.indigo,
                      tankNFill,
                      currentStep == 2,
                    ),
                    _buildTankComp(
                      1400,
                      1400,
                      'prod_f',
                      _t('prod_hl_label'),
                      currentStep > 3 ? (hcfVal * lcmVal).toString() : '0',
                      Colors.teal,
                      tankFFill,
                      currentStep == 3,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // HUD Top Center: Logic theorem correctly centered to available canvas area
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            top: 24,
            left: isSidebarOpen ? sidePanelWidth : 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.5),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _t('hud_theorem').toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('theorem_formula'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Toolbar Bottom Right
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              children: [
                _toolBtn(Icons.zoom_in, () {
                  _playClick();
                  _transformController.value =
                      _transformController.value.clone()..scale(1.2);
                }),
                const SizedBox(height: 8),
                _toolBtn(Icons.zoom_out, () {
                  _playClick();
                  _transformController.value =
                      _transformController.value.clone()..scale(0.8);
                }),
                const SizedBox(height: 8),
                _toolBtn(Icons.center_focus_strong, () {
                  _playClick();
                  _centerCanvas();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Icon(icon, color: const Color(0xFF22D3EE)),
      ),
    );
  }

  // --- COMPONENT BUILDERS FOR CANVAS ---
  Widget _buildNodeComp(
    double x,
    double y,
    String type,
    String label,
    String val,
    Color color,
  ) {
    return Positioned(
      left: x - 100,
      top: y - 80,
      width: 200,
      height: 160,
      child: GestureDetector(
        onTap: () => handleComponentClick(type),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: const Color(0xFF475569), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  val,
                  style: TextStyle(
                    color: color,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipComp(
    double x,
    double y,
    String type,
    String label,
    String val,
    Color color,
    bool isActive,
  ) {
    return Positioned(
      left: x - 120,
      top: y - 120,
      width: 240,
      height: 240,
      child: GestureDetector(
        onTap: () => handleComponentClick(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B),
            border: Border.all(
              color: isActive ? color : const Color(0xFF475569),
              width: isActive ? 6 : 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.memory,
                  size: 48,
                  color: isActive ? color : const Color(0xFF64748B),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (val != '?') ...[
                  const SizedBox(height: 8),
                  Text(
                    val,
                    style: TextStyle(
                      color: color,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTankComp(
    double x,
    double y,
    String type,
    String label,
    String val,
    Color color,
    double fillRatio,
    bool isActive,
  ) {
    return Positioned(
      left: x - 150,
      top: y - 200,
      width: 300,
      height: 400,
      child: GestureDetector(
        onTap: () => handleComponentClick(type),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? color : Colors.white24,
                    width: isActive ? 4 : 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 30,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.bottomCenter,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(seconds: 1),
                  curve: Curves.bounceOut,
                  heightFactor: fillRatio,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.8),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        fillRatio > 0 ? val : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
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

  // --- CHALLENGE MODAL ---
  Widget _buildChallengeModal() {
    String title = '';
    String desc = '';
    Widget hintWidget = const SizedBox();

    if (challengeType == 'hcf') {
      title = _t('chal_hcf_title');
      desc = _tVars('chal_hcf_desc', {
        'A': numA.toString(),
        'B': numB.toString(),
      });
      hintWidget = _buildFactorHint(true);
    } else if (challengeType == 'lcm') {
      title = _t('chal_lcm_title');
      desc = _tVars('chal_lcm_desc', {
        'A': numA.toString(),
        'B': numB.toString(),
      });
      hintWidget = _buildFactorHint(false);
    } else if (challengeType == 'prod_n') {
      title = _t('chal_tank_n_title');
      desc = _tVars('chal_tank_n_desc', {
        'A': numA.toString(),
        'B': numB.toString(),
      });
      hintWidget = Text(
        _t('chal_tank_n_hint'),
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      );
    } else if (challengeType == 'prod_f') {
      title = _t('chal_tank_f_title');
      desc = _tVars('chal_tank_f_desc', {
        'H': hcfVal.toString(),
        'L': lcmVal.toString(),
      });
      hintWidget = Text(
        _tVars('chal_tank_f_hint', {'P': (numA * numB).toString()}),
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      );
    }

    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.translationValues(isErrorShake ? 10 : 0, 0, 0),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _playClick();
                          setState(() => showChallenge = false);
                        },
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF1E293B), // Ensure visibility
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 50, // slightly compact
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isErrorShake
                                  ? Colors.red
                                  : const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            currentInput.isEmpty ? '_' : currentInput,
                            style: TextStyle(
                              fontSize: 28, // slightly compact
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: isErrorShake
                                  ? Colors.red
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showHint) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        border: Border.all(color: Colors.yellow.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: hintWidget,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Keypad
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Important for SingleChildScrollView
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 2.2, // slightly compact
                    children: [
                      for (int i = 1; i <= 9; i++)
                        _keyBtn(i.toString(), () => _typeKey(i.toString())),
                      _keyBtn(_t('btn_del'), () {
                        _playClick();
                        if (currentInput.isNotEmpty) {
                          setState(
                            () => currentInput = currentInput.substring(
                              0,
                              currentInput.length - 1,
                            ),
                          );
                        }
                      }, isRed: true),
                      _keyBtn('0', () => _typeKey('0')),
                      _keyBtn('💡', () {
                        _playClick();
                        setState(() => showHint = !showHint);
                      }, isYellow: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _t('btn_enter'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _typeKey(String k) {
    _playClick();
    if (currentInput.length < 6) setState(() => currentInput += k);
  }

  Widget _keyBtn(
    String label,
    VoidCallback tap, {
    bool isRed = false,
    bool isYellow = false,
  }) {
    Color bg = Colors.white;
    Color fg = const Color(0xFF475569);
    Color border = const Color(0xFFE2E8F0);
    if (isRed) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFEF4444);
      border = const Color(0xFFFEE2E2);
    }
    if (isYellow) {
      bg = const Color(0xFFFEFCE8);
      fg = const Color(0xFFCA8A04);
      border = const Color(0xFFFEF08A);
    }

    return InkWell(
      onTap: tap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildFactorHint(bool isHCF) {
    Map<int, int> mapA = getPrimeFactors(numA);
    Map<int, int> mapB = getPrimeFactors(numB);

    String strA = mapA.entries
        .map((e) => '${e.key}${e.value > 1 ? '^${e.value}' : ''}')
        .join(' × ');
    String strB = mapB.entries
        .map((e) => '${e.key}${e.value > 1 ? '^${e.value}' : ''}')
        .join(' × ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('hint_step1'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.amber, width: 2)),
            ),
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$numA = $strA\n$numB = $strB',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Text(
          isHCF ? _t('hint_step2_hcf') : _t('hint_step2_lcm'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// --- PAINTERS FOR CANVAS ---
class CircuitGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.5)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircuitWirePainter extends CustomPainter {
  final Map<String, Offset> nodes;
  CircuitWirePainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawWire(String from, String to) {
      if (nodes.containsKey(from) && nodes.containsKey(to)) {
        canvas.drawLine(nodes[from]!, nodes[to]!, paint);
      }
    }

    // A -> HCF & LCM
    drawWire('A', 'HCF');
    drawWire('A', 'LCM');
    // B -> HCF & LCM
    drawWire('B', 'HCF');
    drawWire('B', 'LCM');

    // A/B to Tank N
    drawWire('A', 'TANK_N');
    drawWire('B', 'TANK_N');

    // HCF/LCM to Tank F
    drawWire('HCF', 'TANK_F');
    drawWire('LCM', 'TANK_F');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
