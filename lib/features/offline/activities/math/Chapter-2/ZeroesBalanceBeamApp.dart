// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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

// --- डेटा मॉडल ---

class Polynomial {
  final int id;
  final String latex;
  final double a, b, c;
  final List<double> zeroes;
  final Map<String, double> display;
  final String type;

  const Polynomial({
    required this.id,
    required this.latex,
    required this.a,
    required this.b,
    required this.c,
    required this.zeroes,
    required this.display,
    required this.type,
  });
}

const List<Polynomial> polynomials = [
  Polynomial(
    id: 0,
    latex: "x² - 5x + 6",
    a: 1,
    b: -5,
    c: 6,
    zeroes: [3, 2],
    display: {'a': 1, 'b': -5, 'c': 6},
    type: "balanced",
  ),
  Polynomial(
    id: 1,
    latex: "x² - 4x + 5",
    a: 1,
    b: -4,
    c: 3,
    zeroes: [3, 1],
    display: {'a': 1, 'b': -4, 'c': 5},
    type: "unbalanced",
  ),
  Polynomial(
    id: 2,
    latex: "x² - 3x + 2",
    a: 1,
    b: -3,
    c: 2,
    zeroes: [2, 1],
    display: {'a': 1, 'b': -3, 'c': 2},
    type: "balanced",
  ),
  Polynomial(
    id: 3,
    latex: "x² - 2x - 4",
    a: 1,
    b: -3,
    c: -4,
    zeroes: [4, -1],
    display: {'a': 1, 'b': -2, 'c': -4},
    type: "unbalanced",
  ),
  Polynomial(
    id: 4,
    latex: "2x² - 7x + 3",
    a: 2,
    b: -7,
    c: 3,
    zeroes: [3, 0.5],
    display: {'a': 2, 'b': -7, 'c': 3},
    type: "balanced",
  ),
];

class UserMarker {
  final double x;
  String label;
  final Color color;

  UserMarker({
    required this.x,
    required this.label,
    this.color = const Color(0xFF10B981),
  });
}

// --- स्थानीयकरण (LOCALIZATION) ---

const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "THE ZEROES BALANCE BEAM",
    'tagline': "RELATIONSHIP BETWEEN ZEROES & COEFFICIENTS",
    'btn_enter': "ENTER LAB",
    'header_title': "The Zeroes Balance Beam",
    'header_subtitle': "Class 10 • POLYNOMIALS",
    'lbl_progress': "Experiment Progress",
    'lbl_mission_title': "MISSION CONTROL",
    'lbl_objective': "MISSION OBJECTIVE",
    'msg_objective':
        "Verify the mathematical relationship between the zeroes of a polynomial and its coefficients by analyzing its graph and equation.",
    'lbl_select_poly': "Select Polynomial",
    'msg_identify': "Identify components from the graph and equation",
    'lbl_coeff': "Coefficients (a, b, c)",
    'lbl_zeroes': "Zeroes (α, β)",
    'btn_verify_val': "VERIFY VALUES",
    'err_values': "Incorrect values. Check graph!",
    'msg_verify_sum': "Verify Sum: α + β = -b/a",
    'btn_verify_sum': "VERIFY SUM",
    'err_sum': "Sums do not match!",
    'msg_verify_prod': "Verify Product: α × β = c/a",
    'btn_verify_prod': "VERIFY PRODUCT",
    'err_prod': "Products do not match!",
    'msg_verdict': "RELATIONSHIP STATUS",
    'msg_verdict_desc':
        "Did the Alpha and Beta values of zeroes match the coefficients in Sum and Product?",
    'btn_next': "Next Isotope",
    'lbl_mission': "Mission Control",
    'lbl_insight': "Insight Unlocked",
    'lbl_proof': "Mathematical Proof",
    'lbl_analogy': "Real World Analogy",
    'btn_proceed': "PROCEED",
    'btn_load_curve': "LOAD TRAJECTORY",
    'btn_start_analysis': "START ANALYSIS",
    'msg_calc_roots': "Calculate roots using the Quadratic Formula:",
    'btn_verify_locate': "VERIFY & LOCATE",
    'btn_balanced': "BALANCED",
    'btn_unbalanced': "UNBALANCED",
    'lbl_success': "SUCCESS",
    'lbl_failed': "ANALYSIS FAILED",
    'msg_correct': "CORRECT DIAGNOSIS!",
    'msg_incorrect': "INCORRECT DIAGNOSIS",
    'msg_correct_desc': "The system is indeed balanced. Excellent analysis.",
    'msg_incorrect_desc':
        "Review the relationship between coefficients and zeroes again.",
    'lbl_sys_ready': "SYSTEM READY",
    'msg_select_instr': "Select a polynomial to begin analysis.",

    // मिशन (Mission Hints)
    'miss_1':
        "ACTION: Select a polynomial from the dropdown and start the analysis.",
    'miss_calc': "ACTION: Calculate theoretical roots using the formula.",
    'miss_1b':
        "ACTION: Tap on the red X-Axis exactly where the zeroes are located to place markers.",
    'miss_2':
        "ACTION: Extract coefficients from the equation and zeroes from the graph.",
    'miss_3': "ACTION: Calculate and compare the Sum of Zeroes with -b/a.",
    'miss_4': "ACTION: Calculate and compare the Product of Zeroes with c/a.",
    'miss_5':
        "ACTION: Decide if the system is balanced based on your calculations.",

    // प्रमाण
    'proof_step2_math': "P(x) = k(x - α)(x - β)",
    'proof_step2_analogy':
        "Just as a DNA signature determines a creature's traits, the coefficients (a,b,c) determine the graph's shape and zeroes.",
    'proof_step3_math': "α + β = -b/a",
    'proof_step3_analogy':
        "Think of a seesaw. The sum of the roots relates to the 'balance point' (axis of symmetry) at -b/2a.",
    'proof_step4_math': "α × β = c/a",
    'proof_step4_analogy':
        "The product of roots scales the height. It connects the width of the parabola to its vertical intercept (c).",
  },
  'hi': {
    'app_title': "शून्यक ग्राफ लैब",
    'tagline': "शून्यक और गुणांक के बीच संबंध",
    'btn_enter': "लैब में प्रवेश करें",
    'header_title': "शून्यक ग्राफ लैब",
    'header_subtitle': "कक्षा 10 • बहुपद",
    'lbl_progress': "प्रयोग प्रगति",
    'lbl_mission_title': "मिशन कंट्रोल",
    'lbl_objective': "मिशन का उद्देश्य",
    'msg_objective':
        "ग्राफ और समीकरण का विश्लेषण करके किसी बहुपद के शून्यकों और उसके गुणांकों के बीच गणितीय संबंध को सत्यापित करें।",
    'lbl_select_poly': "बहुपद चुनें",
    'msg_identify': "ग्राफ और समीकरण से घटकों को पहचानें",
    'lbl_coeff': "गुणांक (a, b, c)",
    'lbl_zeroes': "शून्यक (α, β)",
    'btn_verify_val': "मान सत्यापित करें",
    'err_values': "गलत मान। ग्राफ की जाँच करें!",
    'msg_verify_sum': "योग सत्यापित करें: α + β = -b/a",
    'btn_verify_sum': "योग सत्यापित करें",
    'err_sum': "योग मेल नहीं खाते!",
    'msg_verify_prod': "गुणनफल सत्यापित करें: α × β = c/a",
    'btn_verify_prod': "गुणनफल सत्यापित करें",
    'err_prod': "गुणनफल मेल नहीं खाते!",
    'msg_verdict': "संबंध की स्थिति",
    'msg_verdict_desc':
        "क्या चरण 3 और 4 में शून्यकों का योग और गुणनफल गुणांकों से मेल खाता था?",
    'btn_next': "अगला उदाहरण",
    'lbl_mission': "मिशन कंट्रोल",
    'lbl_insight': "अंतर्दृष्टि",
    'lbl_proof': "गणितीय प्रमाण",
    'lbl_analogy': "वास्तविक दुनिया सादृश्य",
    'btn_proceed': "आगे बढ़ें",
    'btn_load_curve': "वक्र लोड करें",
    'btn_start_analysis': "विश्लेषण शुरू करें",
    'msg_calc_roots': "द्विघाती सूत्र का उपयोग करके मूलों की गणना करें:",
    'btn_verify_locate': "सत्यापित करें और पता लगाएँ",
    'btn_balanced': "संतुलित",
    'btn_unbalanced': "असंतुलित",
    'lbl_success': "सफलता",
    'lbl_failed': "विश्लेषण विफल",
    'msg_correct': "सही निदान!",
    'msg_incorrect': "गलत निदान",
    'msg_correct_desc': "प्रणाली वास्तव में संतुलित है। उत्कृष्ट विश्लेषण।",
    'msg_incorrect_desc':
        "गुणांक और शून्य के बीच संबंध की फिर से समीक्षा करें।",
    'lbl_sys_ready': "सिस्टम तैयार",
    'msg_select_instr': "विश्लेषण शुरू करने के लिए एक बहुपद चुनें।",

    // मिशन (Mission Hints)
    'miss_1': "कार्य: विश्लेषण शुरू करने के लिए ड्रॉपडाउन से एक बहुपद चुनें।",
    'miss_calc': "कार्य: सूत्र का उपयोग करके सैद्धांतिक मूलों की गणना करें।",
    'miss_1b':
        "कार्य: मार्कर लगाने के लिए लाल X-अक्ष पर वहां टैप करें जहां शून्यक स्थित हैं।",
    'miss_2': "कार्य: समीकरण से गुणांक और ग्राफ से शून्यक निकालें।",
    'miss_3': "कार्य: शून्यकों के योग की गणना करें और उसकी -b/a से तुलना करें।",
    'miss_4':
        "कार्य: शून्यकों के गुणनफल की गणना करें और उसकी c/a से तुलना करें।",
    'miss_5': "कार्य: तय करें कि क्या आपके डेटा के आधार पर सिस्टम संतुलित है।",

    // प्रमाण
    'proof_step2_math': "P(x) = k(x - α)(x - β)",
    'proof_step2_analogy':
        "जिस तरह डीएनए हस्ताक्षर किसी जीव के लक्षणों को निर्धारित करता है, उसी तरह गुणांक (a,b,c) ग्राफ के आकार और शून्यक को निर्धारित करते हैं।",
    'proof_step3_math': "α + β = -b/a",
    'proof_step3_analogy':
        "सीसॉ (seesaw) के बारे में सोचें। मूलों का योग -b/2a पर 'संतुलन बिंदु' (सममित अक्ष) से संबंधित है।",
    'proof_step4_math': "α × β = c/a",
    'proof_step4_analogy':
        "मूलों का गुणनफल ऊंचाई को मापता है। यह परवलय की चौड़ाई को उसके ऊर्ध्वाधर अवरोधन (c) से जोड़ता है।",
  },
};

// --- मुख्य ऐप विजेट (MAIN APP WIDGET) ---

class ZeroesBalanceBeamApp extends StatefulWidget {
  const ZeroesBalanceBeamApp({super.key});

  @override
  State<ZeroesBalanceBeamApp> createState() => _ZeroesBalanceBeamAppState();
}

class _ZeroesBalanceBeamAppState extends State<ZeroesBalanceBeamApp> {
  bool _hasStarted = false;
  String _currentLang = 'en';
  bool _isPanelOpen = true; // साइड पैनल की स्थिति

  // ग्राफ स्टेट (Graph State)
  double scale = 40.0;
  double offsetX = 0.0;
  double offsetY = 0.0;

  // ऐप लॉजिक स्टेट (App Logic State)
  int step = 0;
  Polynomial? currentPoly;
  List<UserMarker> userMarkers = [];
  bool calculationMode = false;
  bool placingMode = false;
  double? hoverX;

  // मोडल / ओवरले (Modals / Overlays)
  bool showProofModal = false;
  String proofMath = "";
  String proofAnalogy = "";
  IconData proofIcon = Icons.info;
  int nextPendingStep = 0;

  bool showVerdictModal = false;
  bool isVerdictCorrect = false;

  // कंट्रोलर्स (Controllers)
  final TextEditingController calcRoot1Ctrl = TextEditingController();
  final TextEditingController calcRoot2Ctrl = TextEditingController();
  final TextEditingController inpACtrl = TextEditingController();
  final TextEditingController inpBCtrl = TextEditingController();
  final TextEditingController inpCCtrl = TextEditingController();
  final TextEditingController inpAlphaCtrl = TextEditingController();
  final TextEditingController inpBetaCtrl = TextEditingController();
  final TextEditingController inpSumZeroCtrl = TextEditingController();
  final TextEditingController inpSumCoeffCtrl = TextEditingController();
  final TextEditingController inpProdZeroCtrl = TextEditingController();
  final TextEditingController inpProdCoeffCtrl = TextEditingController();

  // त्रुटियां (Errors)
  bool calcError = false;
  bool identifyError = false;
  bool sumError = false;
  bool prodError = false;

  final ScrollController _sidebarScrollCtrl = ScrollController();
  final ScrollController _hudScrollCtrl = ScrollController();

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

    calcRoot1Ctrl.dispose();
    calcRoot2Ctrl.dispose();
    inpACtrl.dispose();
    inpBCtrl.dispose();
    inpCCtrl.dispose();
    inpAlphaCtrl.dispose();
    inpBetaCtrl.dispose();
    inpSumZeroCtrl.dispose();
    inpSumCoeffCtrl.dispose();
    inpProdZeroCtrl.dispose();
    inpProdCoeffCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _hudScrollCtrl.dispose();
    super.dispose();
  }

  String t(String key) {
    return i18n[_currentLang]?[key] ?? i18n['en']![key]!;
  }

  void _startGame() {
    _playShutter();
    setState(() {
      _hasStarted = true;
      step = 1;
    });
  }

  void _resetApp() {
    _playClick();
    setState(() {
      _hasStarted = false;
      currentPoly = null;
      step = 1;
      userMarkers.clear();
      calculationMode = false;
      placingMode = false;
      hoverX = null;
      scale = 40.0;
      offsetX = 0.0;
      offsetY = 0.0;
      showVerdictModal = false;

      calcRoot1Ctrl.clear();
      calcRoot2Ctrl.clear();
      inpACtrl.clear();
      inpBCtrl.clear();
      inpCCtrl.clear();
      inpAlphaCtrl.clear();
      inpBetaCtrl.clear();
      inpSumZeroCtrl.clear();
      inpSumCoeffCtrl.clear();
      inpProdZeroCtrl.clear();
      inpProdCoeffCtrl.clear();

      calcError = false;
      identifyError = false;
      sumError = false;
      prodError = false;
    });
  }

  // --- लॉजिक मेथड्स (LOGIC METHODS) ---

  void startCalculation(int polyId) {
    _playClick();
    setState(() {
      currentPoly = polynomials.firstWhere((p) => p.id == polyId);
      calculationMode = true;
      userMarkers.clear();
      scale = 40.0;
      offsetX = 0.0;
      offsetY = 0.0;
      calcError = false;
      calcRoot1Ctrl.clear();
      calcRoot2Ctrl.clear();
    });
  }

  void verifyCalculatedRoots() {
    double? v1 = double.tryParse(calcRoot1Ctrl.text);
    double? v2 = double.tryParse(calcRoot2Ctrl.text);

    if (v1 == null || v2 == null || currentPoly == null) {
      _playError();
      setState(() => calcError = true);
      return;
    }

    double r1 = currentPoly!.zeroes[0];
    double r2 = currentPoly!.zeroes[1];

    bool matchDirect = (v1 - r1).abs() < 0.2 && (v2 - r2).abs() < 0.2;
    bool matchReverse = (v1 - r2).abs() < 0.2 && (v2 - r1).abs() < 0.2;

    if (matchDirect || matchReverse) {
      _playSuccess();
      setState(() {
        calcError = false;
        calculationMode = false;
        placingMode = true;
      });
    } else {
      _playError();
      setState(() => calcError = true);
    }
  }

  void handleGraphTap(double tapGraphX) {
    if (!placingMode || currentPoly == null) return;

    // जाँचें कि क्या टैप शून्यक (zero) के करीब है
    bool isZero = currentPoly!.zeroes.any((z) => (z - tapGraphX).abs() < 0.2);
    bool alreadyPlaced = userMarkers.any((m) => (m.x - tapGraphX).abs() < 0.2);

    if (isZero && !alreadyPlaced) {
      _playClick();
      setState(() {
        userMarkers.add(UserMarker(x: tapGraphX, label: '?'));

        if (userMarkers.length == 2) {
          userMarkers.sort((a, b) => a.x.compareTo(b.x));
          if (currentPoly!.a > 0) {
            userMarkers[0].label = 'β';
            userMarkers[1].label = 'α';
          } else {
            userMarkers[0].label = 'α';
            userMarkers[1].label = 'β';
          }
        }
      });
    }
  }

  void loadCurve() {
    _playClick();
    setState(() {
      placingMode = false;
      step = 2;
    });
  }

  void validateInputs() {
    double? a = double.tryParse(inpACtrl.text);
    double? b = double.tryParse(inpBCtrl.text);
    double? c = double.tryParse(inpCCtrl.text);
    double? alpha = double.tryParse(inpAlphaCtrl.text);
    double? beta = double.tryParse(inpBetaCtrl.text);

    if (a == null ||
        b == null ||
        c == null ||
        alpha == null ||
        beta == null ||
        currentPoly == null) {
      _playError();
      setState(() => identifyError = true);
      return;
    }

    bool aOK = a == currentPoly!.display['a'];
    bool bOK = b == currentPoly!.display['b'];
    bool cOK = c == currentPoly!.display['c'];

    double r1 = currentPoly!.zeroes[0];
    double r2 = currentPoly!.zeroes[1];
    bool zDir = (alpha - r1).abs() < 0.2 && (beta - r2).abs() < 0.2;
    bool zRev = (alpha - r2).abs() < 0.2 && (beta - r1).abs() < 0.2;
    bool zOK = zDir || zRev;

    if (aOK && bOK && cOK && zOK) {
      _playSuccess();
      setState(() {
        identifyError = false;
        triggerProof('step2', Icons.biotech, 3);
      });
    } else {
      _playError();
      setState(() => identifyError = true);
    }
  }

  void validateSum() {
    double? uSum = double.tryParse(inpSumZeroCtrl.text);
    double? uCoeff = double.tryParse(inpSumCoeffCtrl.text);

    if (uSum == null || uCoeff == null || currentPoly == null) {
      _playError();
      setState(() => sumError = true);
      return;
    }

    double actualSum = currentPoly!.zeroes[0] + currentPoly!.zeroes[1];
    double targetCoeff =
        -currentPoly!.display['b']! / currentPoly!.display['a']!;

    if ((uSum - actualSum).abs() < 0.2 && (uCoeff - targetCoeff).abs() < 0.2) {
      _playSuccess();
      setState(() {
        sumError = false;
        triggerProof('step3', Icons.balance, 4);
      });
    } else {
      _playError();
      setState(() => sumError = true);
    }
  }

  void validateProduct() {
    double? uProd = double.tryParse(inpProdZeroCtrl.text);
    double? uCoeff = double.tryParse(inpProdCoeffCtrl.text);

    if (uProd == null || uCoeff == null || currentPoly == null) {
      _playError();
      setState(() => prodError = true);
      return;
    }

    double actualProd = currentPoly!.zeroes[0] * currentPoly!.zeroes[1];
    double targetCoeff =
        currentPoly!.display['c']! / currentPoly!.display['a']!;

    if ((uProd - actualProd).abs() < 0.2 &&
        (uCoeff - targetCoeff).abs() < 0.2) {
      _playSuccess();
      setState(() {
        prodError = false;
        triggerProof('step4', Icons.height, 5);
      });
    } else {
      _playError();
      setState(() => prodError = true);
    }
  }

  void triggerProof(String proofId, IconData icon, int nextStp) {
    setState(() {
      proofMath = t('proof_${proofId}_math');
      proofAnalogy = t('proof_${proofId}_analogy');
      proofIcon = icon;
      nextPendingStep = nextStp;
      showProofModal = true;
    });
  }

  void closeProof() {
    _playClick();
    setState(() {
      showProofModal = false;
      step = nextPendingStep;
    });
  }

  void submitVerdict(String choice) {
    bool correct = choice == currentPoly?.type;
    _playClick();
    setState(() {
      isVerdictCorrect = correct;
      showVerdictModal = true;
    });
  }

  void closeVerdict() {
    _playClick();
    setState(() {
      showVerdictModal = false;
      if (isVerdictCorrect) {
        step = 6; // निर्णय के बाद का UI (Post verdict UI)
      }
    });
  }

  // --- यूआई बिल्डिंग मेथड्स (UI BUILDING METHODS) ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. मुख्य लेआउट (Main Layout)
            Row(
              children: [
                // एनिमेटेड 40% साइड पैनल (Animated 40% Side Panel)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isPanelOpen
                      ? MediaQuery.of(context).size.width * 0.4
                      : 0,
                  child: ClipRect(
                    child: OverflowBox(
                      minWidth: MediaQuery.of(context).size.width * 0.4,
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                      alignment: Alignment.topLeft,
                      child: _buildSidePanel(),
                    ),
                  ),
                ),
                // विस्तृत कैनवास क्षेत्र (Expanded Canvas Area)
                Expanded(child: _buildCanvasArea()),
              ],
            ),

            // 2. स्टार्ट स्क्रीन ओवरले (Start Screen Overlay)
            if (!_hasStarted) _buildStartScreen(),

            // 3. फ्लोटिंग नेविगेशन कंट्रोल (Floating Navigation Controls)
            if (_hasStarted) ...[
              Positioned(
                top: 16,
                left: 16,
                child: _floatingButton(
                  icon: _isPanelOpen ? Icons.menu_open : Icons.menu,
                  onPressed: () {
                    _playClick();
                    setState(() {
                      _isPanelOpen = !_isPanelOpen;
                    });
                  },
                ),
              ),
              // फ्लोटिंग मिशन कार्ड जब साइडबार बंद हो (Floating Mission Card when sidebar is closed)
              if (!_isPanelOpen)
                Positioned(
                  top: 80,
                  left: 16,
                  child: _buildFloatingMissionCard(),
                ),
            ],

            // 4. मोडल / ओवरले (Modals / Overlays)
            if (showProofModal) _buildProofModal(),
            if (showVerdictModal) _buildVerdictModal(),
          ],
        ),
      ),
    );
  }

  Widget _floatingButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      color: const Color(0xFF050505),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, size: 80, color: Color(0xFF06B6D4)),
          const SizedBox(height: 20),
          Text(
            t('app_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t('tagline'),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF67E8F9),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.science, size: 24, color: Colors.white),
            label: Text(
              t('btn_enter'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: const Color(0xFF06B6D4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDescription() {
    String missionKey = 'miss_1';
    if (calculationMode) {
      missionKey = 'miss_calc';
    } else if (placingMode) {
      missionKey = 'miss_1b';
    } else if (step == 2) {
      missionKey = 'miss_2';
    } else if (step == 3) {
      missionKey = 'miss_3';
    } else if (step == 4) {
      missionKey = 'miss_4';
    } else if (step >= 5) {
      missionKey = 'miss_5';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
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
              t(missionKey),
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

  Widget _buildFloatingMissionCard() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 320,
        maxHeight: MediaQuery.of(context).size.height - 100,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFA18181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x6606B6D4)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: Color(0xFF22D3EE),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('lbl_mission_title').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF06B6D4),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _playClick();
                    setState(() => _isPanelOpen = true);
                  },
                  child: const Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: RawScrollbar(
                controller: _hudScrollCtrl,
                thumbVisibility: true,
                thumbColor: const Color(0xFF06B6D4).withOpacity(0.8),
                radius: const Radius.circular(4),
                thickness: 4,
                child: SingleChildScrollView(
                  controller: _hudScrollCtrl,
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepDescription(),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: _buildCurrentStepUI(),
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

  Widget _buildSidePanel() {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFA18181B),
        border: Border(right: BorderSide(color: Color(0x3306B6D4))),
      ),
      child: CustomScrollView(
        controller: _sidebarScrollCtrl,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 76),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('header_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('header_subtitle'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF22D3EE),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF18181B),
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              children: [
                                _langBtn('en', 'EN'),
                                _langBtn('hi', 'HI'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.power_settings_new),
                            color: Colors.red[400],
                            onPressed: _resetApp,
                            tooltip: "Reset Application",
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10, height: 1),

                // प्रगति और मिशन कार्ड (Progress and Mission Cards)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo[900]!.withOpacity(0.8),
                              Colors.purple[900]!.withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  color: Color(0xFF22D3EE),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t('lbl_objective'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF67E8F9),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.only(left: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFF06B6D4),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                t('msg_objective'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.assignment,
                            color: Color(0xFF22D3EE),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t('lbl_mission_title').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF06B6D4),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStepDescription(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t('lbl_progress').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF22D3EE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Step $step/5',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: step / 5.0,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF06B6D4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                // इंटरएक्टिव ज़ोन (Interactive Zone)
                Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: _buildCurrentStepUI(),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildSidebarFooter()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF09090B),
        border: Border(top: BorderSide(color: Color(0x3306B6D4))),
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

  Widget _langBtn(String code, String label) {
    bool active = _currentLang == code;
    return InkWell(
      onTap: () {
        _playClick();
        setState(() => _currentLang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0891B2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepUI() {
    if (step == 6) {
      return Column(
        children: [
          Text(
            t('msg_correct_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.greenAccent),
          ),
          const SizedBox(height: 20),
          _actionBtn(t('btn_next'), _resetApp, color: Colors.cyan),
        ],
      );
    }
    if (step == 5) return _buildStep5Verdict();
    if (step == 4) return _buildStep4Product();
    if (step == 3) return _buildStep3Sum();
    if (step == 2) return _buildStep2Identify();

    // चरण 1 भिन्नताएँ (Step 1 variations)
    if (calculationMode) return _buildStep1Calc();
    if (placingMode) return _buildStep1Locate();

    // प्रारंभिक चयन (Initial Select)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('lbl_select_poly').toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          dropdownColor: const Color(0xFF18181B),
          value: currentPoly?.id,
          items: polynomials
              .map(
                (p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(
                    p.latex,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            _playClick();
            if (v != null) {
              setState(
                () => currentPoly = polynomials.firstWhere((p) => p.id == v),
              );
            }
          },
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFF27272A),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        _actionBtn(t('btn_start_analysis'), () {
          if (currentPoly != null) startCalculation(currentPoly!.id);
        }),
      ],
    );
  }

  Widget _buildStep1Calc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "मूलों की गणना करें", // CALCULATE ROOTS
          style: TextStyle(
            fontSize: 12,
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "P(x) = ${currentPoly!.latex}",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          t('msg_calc_roots'),
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black45,
          child: const Column(
            children: [
              Text(
                "α = (-b + √(b²-4ac)) / 2a",
                style: TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "β = (-b - √(b²-4ac)) / 2a",
                style: TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "a = ${currentPoly!.a}, b = ${currentPoly!.b}, c = ${currentPoly!.c}",
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _inputField(calcRoot1Ctrl, "α")),
            const SizedBox(width: 8),
            Expanded(child: _inputField(calcRoot2Ctrl, "β")),
          ],
        ),
        if (calcError)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "गलत गणना!", // Incorrect Calculation!
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        _actionBtn(
          t('btn_verify_locate'),
          verifyCalculatedRoots,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStep1Locate() {
    return Column(
      children: [
        const Text(
          "मूलों का पता लगाएँ", // LOCATE ROOTS
          style: TextStyle(
            fontSize: 12,
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gps_fixed, color: Colors.redAccent, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "शून्यक को चिह्नित करने के लिए लाल X-अक्ष पर टैप करें", // Tap the Red X-Axis to mark zeroes
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badge(
              userMarkers.isNotEmpty ? userMarkers[0].label : 'α',
              userMarkers.isNotEmpty,
            ),
            const SizedBox(width: 16),
            _badge(
              userMarkers.length > 1 ? userMarkers[1].label : 'β',
              userMarkers.length > 1,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (userMarkers.length == 2)
          _actionBtn(t('btn_load_curve'), loadCurve, color: Colors.green),
      ],
    );
  }

  Widget _badge(String lbl, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.green.withOpacity(0.8) : Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? Colors.green : Colors.white24),
      ),
      child: Text(
        lbl,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStep2Identify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('msg_identify'),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          t('lbl_coeff'),
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _inputField(inpACtrl, "a")),
            const SizedBox(width: 4),
            Expanded(child: _inputField(inpBCtrl, "b")),
            const SizedBox(width: 4),
            Expanded(child: _inputField(inpCCtrl, "c")),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          t('lbl_zeroes'),
          style: const TextStyle(
            color: Colors.purpleAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _inputField(inpAlphaCtrl, "α")),
            const SizedBox(width: 8),
            Expanded(child: _inputField(inpBetaCtrl, "β")),
          ],
        ),
        if (identifyError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              t('err_values'),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        _actionBtn(t('btn_verify_val'), validateInputs, color: Colors.purple),
      ],
    );
  }

  Widget _buildStep3Sum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('msg_verify_sum'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "α + β",
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(inpSumZeroCtrl, ""),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "-b / a",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(inpSumCoeffCtrl, ""),
                ],
              ),
            ),
          ],
        ),
        if (sumError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              t('err_sum'),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        _actionBtn(t('btn_verify_sum'), validateSum, color: Colors.cyan),
      ],
    );
  }

  Widget _buildStep4Product() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('msg_verify_prod'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "α × β",
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(inpProdZeroCtrl, ""),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "c / a",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(inpProdCoeffCtrl, ""),
                ],
              ),
            ),
          ],
        ),
        if (prodError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              t('err_prod'),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        _actionBtn(t('btn_verify_prod'), validateProduct, color: Colors.purple),
      ],
    );
  }

  Widget _buildStep5Verdict() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.scale_outlined, size: 40, color: Colors.white54),
        const SizedBox(height: 8),
        Text(
          t('msg_verdict'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          t('msg_verdict_desc'),
          style: const TextStyle(color: Colors.white54, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _verdictBtn(t('btn_balanced'), 'balanced', Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _verdictBtn(t('btn_unbalanced'), 'unbalanced', Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _verdictBtn(String lbl, String choice, MaterialColor color) {
    return InkWell(
      onTap: () => submitVerdict(choice),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          lbl,
          style: TextStyle(color: color[300], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.black,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF06B6D4)),
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    VoidCallback onTap, {
    MaterialColor color = Colors.cyan,
  }) {
    return ElevatedButton(
      onPressed: () {
        _playClick();
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // --- कैनवास क्षेत्र (CANVAS AREA) ---

  Widget _buildCanvasArea() {
    return Stack(
      children: [
        GestureDetector(
          onScaleUpdate: (details) {
            if (!mounted) return;
            setState(() {
              if (details.scale == 1.0) {
                // पैनिंग (Panning)
                offsetX += details.focalPointDelta.dx;
                offsetY += details.focalPointDelta.dy;
              } else {
                // ज़ूमिंग (Zooming)
                scale *= details.scale;
                scale = scale.clamp(10.0, 200.0);
              }
            });
          },
          onTapUp: (details) {
            if (!placingMode || currentPoly == null) return;
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) {
                  double cx = constraints.maxWidth / 2 + offsetX;
                  double tapGraphX = (details.localPosition.dx - cx) / scale;

                  double cy = constraints.maxHeight / 2 + offsetY;
                  double tapGraphY = (cy - details.localPosition.dy) / scale;

                  if (tapGraphY.abs() < 1.5) {
                    handleGraphTap(tapGraphX);
                  }
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: GraphPainter(
                    scale: scale,
                    offsetX: offsetX,
                    offsetY: offsetY,
                    poly: currentPoly,
                    markers: userMarkers,
                    showCurve:
                        !placingMode &&
                        !calculationMode &&
                        step > 0 &&
                        currentPoly != null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- मोडल (MODALS) ---

  Widget _buildProofModal() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x668B5CF6)),
          boxShadow: const [
            BoxShadow(color: Color(0x268B5CF6), blurRadius: 30),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0x1A8B5CF6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.purpleAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t('lbl_insight').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('lbl_proof').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        left: BorderSide(color: Colors.purpleAccent, width: 3),
                      ),
                    ),
                    child: Text(
                      proofMath,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0x1A06B6D4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(proofIcon, color: Colors.cyanAccent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('lbl_analogy').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              proofAnalogy,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _actionBtn(
                    t('btn_proceed'),
                    closeProof,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerdictModal() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isVerdictCorrect
                ? Colors.green.withOpacity(0.5)
                : Colors.red.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: (isVerdictCorrect ? Colors.green : Colors.red).withOpacity(
                0.2,
              ),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isVerdictCorrect ? Colors.green : Colors.red)
                    .withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: const Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerdictCorrect ? Icons.check_circle : Icons.cancel,
                    color: isVerdictCorrect
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (isVerdictCorrect ? t('lbl_success') : t('lbl_failed'))
                        .toUpperCase(),
                    style: TextStyle(
                      color: isVerdictCorrect
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isVerdictCorrect
                        ? Icons.check_circle_outline
                        : Icons.highlight_off,
                    size: 60,
                    color: isVerdictCorrect
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isVerdictCorrect ? t('msg_correct') : t('msg_incorrect'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVerdictCorrect
                        ? t('msg_correct_desc')
                        : t('msg_incorrect_desc'),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _actionBtn(
                    "CONTINUE",
                    closeVerdict,
                    color: isVerdictCorrect ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ग्राफ पेंटर (GRAPH PAINTER) ---

class GraphPainter extends CustomPainter {
  final double scale;
  final double offsetX;
  final double offsetY;
  final Polynomial? poly;
  final List<UserMarker> markers;
  final bool showCurve;

  GraphPainter({
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.poly,
    required this.markers,
    required this.showCurve,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2 + offsetX;
    double cy = size.height / 2 + offsetY;

    // पृष्ठभूमि (Background)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF050505),
    );

    // ग्रिड लाइन्स (Grid lines)
    Paint gridPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;

    double startXGraph = (0 - cx) / scale;
    double endXGraph = (size.width - cx) / scale;
    for (int i = startXGraph.floor(); i <= endXGraph.ceil(); i++) {
      double px = cx + i * scale;
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint);
    }

    double startYGraph = (cy - size.height) / scale;
    double endYGraph = (cy - 0) / scale;
    for (int i = startYGraph.floor(); i <= endYGraph.ceil(); i++) {
      double py = cy - i * scale;
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint);
    }

    // अक्ष (Axes)
    Paint xAxisPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2; // लाल X (Red X)
    Paint yAxisPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2; // नीला Y (Blue Y)
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), xAxisPaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), yAxisPaint);

    // लेबल्स (Labels)
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = startXGraph.floor(); i <= endXGraph.ceil(); i++) {
      if (i == 0) continue;
      double px = cx + i * scale;
      if (px > 10 && px < size.width - 10) {
        tp.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
        );
        tp.layout();
        tp.paint(canvas, Offset(px - tp.width / 2, cy + 6));
        canvas.drawLine(Offset(px, cy), Offset(px, cy + 4), xAxisPaint);
      }
    }

    for (int i = startYGraph.floor(); i <= endYGraph.ceil(); i++) {
      if (i == 0) continue;
      double py = cy - i * scale;
      if (py > 10 && py < size.height - 10) {
        tp.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
        );
        tp.layout();
        tp.paint(canvas, Offset(cx - tp.width - 6, py - tp.height / 2));
        canvas.drawLine(Offset(cx, py), Offset(cx - 4, py), yAxisPaint);
      }
    }

    // वक्र (Curve)
    if (showCurve && poly != null) {
      Paint curvePaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      Path path = Path();
      bool first = true;
      for (double px = 0; px <= size.width; px += 2) {
        double gx = (px - cx) / scale;
        double gy = poly!.a * gx * gx + poly!.b * gx + poly!.c;
        double py = cy - gy * scale;

        if (py > -1000 && py < size.height + 1000) {
          if (first) {
            path.moveTo(px, py);
            first = false;
          } else {
            path.lineTo(px, py);
          }
        }
      }
      canvas.drawPath(path, curvePaint);
    }

    // मार्कर (Markers)
    for (var m in markers) {
      double mx = cx + m.x * scale;
      canvas.drawCircle(Offset(mx, cy), 6, Paint()..color = m.color);

      tp.text = TextSpan(
        text: m.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(mx - tp.width / 2, cy - 25));
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.poly != poly ||
        oldDelegate.markers.length != markers.length ||
        oldDelegate.showCurve != showCurve;
  }
}
