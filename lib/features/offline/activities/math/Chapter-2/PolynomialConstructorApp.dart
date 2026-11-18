// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'POLYNOMIAL CONSTRUCTOR',
    'tagline': 'FORMING QUADRATIC POLYNOMIALS • CLASS 10',
    'init_btn': 'ENTER CONSTRUCTOR',
    'header_title': 'Polynomial Constructor',
    'header_subtitle': 'CLASS 10 • POLYNOMIALS',
    'nav_context': 'Why Learn This?',
    'nav_lab': 'Explore',
    'nav_report': 'Outcomes',
    'ctx_title': 'Context & Applications',
    'btn_start_lab': 'Enter Lab',
    'post_title': 'Analysis & Outcomes',
    'btn_restart': 'Reset Lab',
    'lbl_progress': 'Construction Progress',
    'hud_status': 'System Status',
    'lbl_select_zeroes': 'Select Zeroes (α, β)',
    'btn_load': 'LOAD MATERIALS',
    'msg_process': 'Calculate Components',
    'btn_process': 'CHECK & ACTIVATE',
    'btn_assemble': 'ASSEMBLE POLYNOMIAL',
    'btn_verify': 'VERIFY INTEGRITY',
    'msg_success': 'CONSTRUCTION COMPLETE',
    'btn_next': 'New Construction',
    'lbl_click_graph': 'Click on the Red X-Axis line to mark your zeroes.',
    'btn_confirm_sel': 'CONFIRM SELECTION',
    'btn_clear_sel': 'Clear Selection',
    'mission_title': 'MISSION OBJECTIVE',
    'mission_desc':
        'Construct a quadratic polynomial by determining the Sum and Product of its zeroes (α, β).',
    'step_0_t': 'SYSTEM READY',
    'step_0_d': 'Select raw materials (zeroes) to begin.',
    'step_1_t': 'INITIALIZATION',
    'step_1_d': 'Select raw zero components.',
    'step_2_t': 'SYNTHESIS',
    'step_2_d': 'Calculate Sum and Product.',
    'step_3_t': 'ASSEMBLY',
    'step_3_d': 'Place components into formula.',
    'step_4_t': 'VERIFICATION',
    'step_4_d': 'Check trajectory.',
    'step_5_t': 'COMPLETE',
    'step_5_d': 'Polynomial created.',
    'ctx_1_t': 'Trajectory Design',
    'ctx_1_d':
        'Defining a flight path knowing launch and landing points (zeroes).',
    'ctx_2_t': 'Bridge Building',
    'ctx_2_d': 'Shaping an arch given the span width and anchor points.',
    'ctx_3_t': 'Business',
    'ctx_3_d': 'Modeling profit curves knowing breakeven points.',
    'out_1_t': 'Formula',
    'out_1_d': 'p(x) = x² - (α+β)x + αβ',
    'out_2_t': 'Sign Change',
    'out_2_d': 'Note the negative sign before the Sum term.',
    'out_3_t': 'Family of Curves',
    'out_3_d': "Multiplying by 'k' changes the width but not the zeroes.",
    'out_h_obs': 'Observation',
    'out_h_res': 'Learning Outcome',
    'out_r1_o': 'Graph cuts X-axis at α, β',
    'out_r1_r': 'Geometric meaning of zeroes.',
    'out_r2_o': 'Coeff of x is -(α+β)',
    'out_r2_r': "Relationship between Sum & 'b'.",
    'out_r3_o': 'Constant term is αβ',
    'out_r3_r': "Relationship between Product & 'c'.",
    'out_r4_o': 'Final Form: x² - Sx + P',
    'out_r4_r': 'Structure of a quadratic polynomial.',
  },
  'hi': {
    'app_title': 'बहुपद निर्माता',
    'tagline': 'द्विघात बहुपद बनाना • कक्षा 10',
    'init_btn': 'निर्माता में प्रवेश करें',
    'header_title': 'बहुपद निर्माता',
    'header_subtitle': 'कक्षा 10 • बहुपद',
    'nav_context': 'क्यों सीखें?',
    'nav_lab': 'अन्वेषण',
    'nav_report': 'निष्कर्ष',
    'ctx_title': 'संदर्भ और अनुप्रयोग',
    'btn_start_lab': 'लैब में प्रवेश',
    'post_title': 'विश्लेषण और परिणाम',
    'btn_restart': 'लैब रीसेट करें',
    'lbl_progress': 'निर्माण प्रगति',
    'hud_status': 'सिस्टम स्थिति',
    'lbl_select_zeroes': 'शून्यक चुनें (α, β)',
    'btn_load': 'सामग्री लोड करें',
    'msg_process': 'घटकों की गणना करें',
    'btn_process': 'जाँचें और सक्रिय करें',
    'btn_assemble': 'बहुपद असेंबल करें',
    'btn_verify': 'सत्यापित करें',
    'msg_success': 'निर्माण पूरा हुआ',
    'btn_next': 'नया निर्माण',
    'lbl_click_graph':
        'अपने शून्यक को चिह्नित करने के लिए लाल X-अक्ष रेखा पर क्लिक करें।',
    'btn_confirm_sel': 'चयन की पुष्टि करें',
    'btn_clear_sel': 'चयन साफ़ करें',
    'mission_title': 'मिशन का उद्देश्य',
    'mission_desc':
        'दिए गए शून्यकों (α, β) के योग और गुणनफल का निर्धारण करके एक द्विघात बहुपद का निर्माण करें।',
    'step_0_t': 'सिस्टम तैयार',
    'step_0_d': 'शुरू करने के लिए कच्ची सामग्री (शून्यक) चुनें।',
    'step_1_t': 'आरंभीकरण',
    'step_1_d': 'कच्चे शून्यक घटक चुनें।',
    'step_2_t': 'संश्लेषण',
    'step_2_d': 'योग और गुणनफल की गणना करें।',
    'step_3_t': 'असेंबली',
    'step_3_d': 'घटकों को सूत्र में रखें।',
    'step_4_t': 'सत्यापन',
    'step_4_d': 'प्रक्षेपवक्र की जाँच करें।',
    'step_5_t': 'पूर्ण',
    'step_5_d': 'बहुपद बनाया गया।',
    'ctx_1_t': 'प्रक्षेपवक्र डिजाइन',
    'ctx_1_d': 'लॉन्च और लैंडिंग बिंदुओं को जानकर उड़ान पथ परिभाषित करना।',
    'ctx_2_t': 'पुल निर्माण',
    'ctx_2_d':
        'स्पैन चौड़ाई और एंकर बिंदुओं को देखते हुए एक आर्च को आकार देना।',
    'ctx_3_t': 'व्यापार',
    'ctx_3_d': 'ब्रेकईवन बिंदुओं को जानकर लाभ वक्र मॉडलिंग।',
    'out_1_t': 'सूत्र',
    'out_1_d': 'p(x) = x² - (α+β)x + αβ',
    'out_2_t': 'चिह्न परिवर्तन',
    'out_2_d': 'योग पद से पहले ऋणात्मक चिह्न पर ध्यान दें।',
    'out_3_t': 'वक्रों का परिवार',
    'out_3_d': "'k' से गुणा करने पर चौड़ाई बदलती है लेकिन शून्यक नहीं।",
    'out_h_obs': 'अवलोकन',
    'out_h_res': 'सीखने का परिणाम',
    'out_r1_o': 'ग्राफ X-अक्ष को α, β पर काटता है',
    'out_r1_r': 'शून्यक का ज्यामितीय अर्थ।',
    'out_r2_o': 'x का गुणांक -(α+β) है',
    'out_r2_r': "योग और 'b' के बीच संबंध।",
    'out_r3_o': 'अचर पद αβ है',
    'out_r3_r': "गुणनफल और 'c' के बीच संबंध।",
    'out_r4_o': 'अंतिम रूप: x² - Sx + P',
    'out_r4_r': 'द्विघात बहुपद की संरचना।',
  },
};

// दृश्य प्रमाण प्रणाली के लिए डेटा मॉडल (Data Model for the Visual Proof System)
class ProofData {
  final String title;
  final String math;
  final String analogy;
  final String icon;
  final Color color;
  ProofData({
    required this.title,
    required this.math,
    required this.analogy,
    required this.icon,
    required this.color,
  });
}

final Map<int, ProofData> proofDataMap = {
  1: ProofData(
    title: "FOUNDATION SET",
    math:
        "The zeroes α and β represent the points where the graph intersects the X-axis (y=0).",
    analogy:
        "Like placing two anchor points on the ground. These are the foundations upon which our polynomial bridge will be built.",
    icon: "🏗️",
    color: const Color(0xFF8B5CF6), // Violet
  ),
  2: ProofData(
    title: "COMPONENTS MIXED",
    math:
        "In ax² + bx + c, Sum S = -b/a and Product P = c/a. We calculated the raw materials needed for the equation.",
    analogy:
        "We are mixing the ingredients (cement & steel) in precise ratios. 'Sum' and 'Product' are the recipes for the structure's shape.",
    icon: "🥣",
    color: const Color(0xFF06B6D4), // Cyan
  ),
  3: ProofData(
    title: "FRAMEWORK ASSEMBLED",
    math:
        "The polynomial is formed using k[x² - Sx + P]. We substituted our calculated Sum and Product.",
    analogy:
        "Pouring the concrete into the mold. The framework x² - Sx + P gives our raw materials a specific parabolic shape.",
    icon: "📐",
    color: const Color(0xFF10B981), // Emerald
  ),
  4: ProofData(
    title: "STRUCTURAL INTEGRITY",
    math:
        "The curve passes exactly through (α, 0) and (β, 0). This confirms p(α) = 0 and p(β) = 0.",
    analogy:
        "The bridge stands perfectly on its foundations. The math holds up, and the structure is stable!",
    icon: "🌉",
    color: const Color(0xFF10B981), // Success
  ),
};

class PolynomialConstructorApp extends StatefulWidget {
  const PolynomialConstructorApp({super.key});

  @override
  State<PolynomialConstructorApp> createState() =>
      _PolynomialConstructorAppState();
}

class _PolynomialConstructorAppState extends State<PolynomialConstructorApp>
    with TickerProviderStateMixin {
  bool isPoweredOn = false;
  String lang = 'en';
  bool isSidePanelOpen = true;

  int currentStep = 1; // 1 से 5 तक
  int? alpha;
  int? beta;
  final TextEditingController _sumController = TextEditingController();
  final TextEditingController _prodController = TextEditingController();
  bool showStep2Error = false;

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;
  late TransformationController _transformController;
  late AnimationController _parabolaController;
  bool _showEquationOverlay = false;
  Timer? _equationTimer;

  // ड्रैग करने योग्य प्रूफ मोडल स्थिति (Draggable Proof Modal State)
  bool showProofModal = false;
  int currentProofStep = 1;
  double proofX = 0.0;
  double proofY = 0.0;

  // जश्न (Celebration) स्थिति
  bool showCelebration = false;

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

  void _playSound(AudioPlayer player, String url) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void playClick() => _playSound(_clickPlayer, _clickUrl);
  void playSuccess() => _playSound(_successPlayer, _successUrl);
  void playError() => _playSound(_errorPlayer, _errorUrl);
  void playShutter() => _playSound(_fxPlayer, _shutterUrl);

  @override
  void initState() {
    super.initState();
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

    // एक बहुत बड़ा वर्चुअल कैनवास (4000x4000) सेट किया है
    _transformController = TransformationController();
    _transformController.value = Matrix4.identity()
      ..translate(
        -1000.0,
        -1000.0,
      ); // केंद्र (2000, 2000) पर देखने के लिए ऑफसेट

    // सही तरीके से (0,0) पर केन्द्रित करने के लिए UI रेंडर होने के बाद कॉल करें
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerGraph();
    });

    _parabolaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _parabolaController.addListener(() {
      setState(() {});
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _shutterController.dispose();
    _transformController.dispose();
    _parabolaController.dispose();
    _sumController.dispose();
    _prodController.dispose();
    _equationTimer?.cancel();

    // Dispose Audio players
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  String _t(String key) => i18n[lang]?[key] ?? i18n['en']![key] ?? key;

  // ग्राफ़ को (0,0) पर केन्द्रित करने के लिए Helper Function
  void _centerGraph() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final panelWidth = max(size.width * 0.4, 320.0);
    // यदि पैनल खुला है तो दिखाई देने वाले क्षेत्र के केंद्र की गणना करें
    double cx = isSidePanelOpen
        ? (size.width + panelWidth) / 2
        : size.width / 2;
    double cy = size.height / 2;
    _transformController.value = Matrix4.identity()
      ..translate(cx - 2000.0, cy - 2000.0);
  }

  // --- क्रियाएँ (ACTIONS) ---
  void powerOn() {
    playShutter();
    setState(() => isPoweredOn = true);
    _shutterController.forward();
  }

  void handleCanvasTap(TapUpDetails details) {
    if (currentStep != 1) return;

    final Offset mathCoords = details.localPosition;

    final double worldX = (mathCoords.dx - 2000.0) / 60.0;
    final double worldY = (2000.0 - mathCoords.dy) / 60.0;

    if (worldY.abs() < 1.0) {
      int snapX = worldX.round();
      setState(() {
        if (alpha == null) {
          alpha = snapX;
          playClick();
        } else if (beta == null) {
          beta = snapX;
          playClick();
        } else {
          alpha = snapX;
          beta = null;
          playClick();
        }
      });
    }
  }

  void resetSelection() {
    playClick();
    setState(() {
      alpha = null;
      beta = null;
    });
  }

  void confirmZeroes() {
    playClick();
    if (alpha != null && beta != null) {
      openProofModal(1);
    }
  }

  void validateSumProd() {
    if (alpha == null || beta == null) return;
    int actualS = alpha! + beta!;
    int actualP = alpha! * beta!;

    int? userS = int.tryParse(_sumController.text);
    int? userP = int.tryParse(_prodController.text);

    if (userS == actualS && userP == actualP) {
      playClick();
      setState(() => showStep2Error = false);
      openProofModal(2);
    } else {
      playError();
      setState(() => showStep2Error = true);
    }
  }

  void assemblePolynomial() {
    playClick();
    openProofModal(3);
  }

  void verifyIntegrity() {
    playClick();
    // Do not trigger visual parabola drawing yet, trigger only after modal completion
    openProofModal(4);
  }

  void resetLab() {
    playClick();
    setState(() {
      alpha = null;
      beta = null;
      currentStep = 1;
      _sumController.clear();
      _prodController.clear();
      showStep2Error = false;
      _parabolaController.reset();
      _centerGraph();
      _showEquationOverlay = false;
      _equationTimer?.cancel();
    });
  }

  // --- प्रूफ मोडल लॉजिक (PROOF MODAL LOGIC) ---
  void openProofModal(int step) {
    final size = MediaQuery.of(context).size;
    setState(() {
      currentProofStep = step;
      showProofModal = true;
      // Calculate center to place Proof Modal by Default
      // (assuming modal width is ~450 and height is ~350)
      proofX = (size.width - 450) / 2;
      proofY = (size.height - 350) / 2;

      // Prevent overflow boundaries
      if (proofX < 0) proofX = 20;
      if (proofY < 0) proofY = 20;
    });
  }

  void closeProofModal() {
    setState(() {
      showProofModal = false;
      if (currentProofStep == 4) {
        playSuccess();
        // TRIGGER visual Parabola animation ONLY AFTER proceed button
        _parabolaController.forward(from: 0.0);
        showCelebration = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showCelebration = false;
              currentStep = 5;
            });
          }
        });
      } else {
        playClick();
        currentStep = currentProofStep + 1;
        // फॉर्मूला ओवरले को 5 सेकंड के लिए दिखाएँ (Step 3 या 4 में प्रवेश करने पर)
        if (currentStep == 3 || currentStep == 4) {
          _showEquationOverlay = true;
          _equationTimer?.cancel();
          _equationTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _showEquationOverlay = false;
              });
            }
          });
        }
      }
    });
  }

  // --- निर्माणकर्ता (BUILDERS) ---
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    // 40% साइड पैनल की चौड़ाई (कम से कम 320px)
    final panelWidth = max(sw * 0.4, 320.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. पूर्ण स्क्रीन कैनवास (Full Screen Canvas)
            Positioned.fill(child: _buildMainCanvas(panelWidth)),

            // 2. 40% साइड पैनल (40% Side Panel)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isSidePanelOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: _buildSidePanel(),
            ),

            // 2.5 फ्लोटिंग मिशन कार्ड (Floating Mission Card)
            Positioned(
              left: 20,
              top: 70,
              child: AnimatedOpacity(
                opacity: !isSidePanelOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: isSidePanelOpen,
                  child: _buildLabControls(isFloating: true),
                ),
              ),
            ),

            // 4. फ्लोटिंग मेनू बटन (Floating Menu Button - top Left)
            Positioned(top: 16, left: 16, child: _buildFloatingMenuButton()),

            // 5. ड्रैग करने योग्य प्रूफ मोडल (Draggable Proof Modal)
            if (showProofModal) _buildDraggableProofModal(),

            // 6. जश्न का ओवरले (Celebration Overlay)
            if (showCelebration)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'SUCCESS!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white54,
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF10B981),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x8010B981),
                                      blurRadius: 30,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Matches Zeroes',
                                  style: TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontSize: 24,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // 7. इंट्रो शटर (Intro Shutter)
            SlideTransition(
              position: _shutterAnimation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF020617),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.dashboard_customize,
                          size: 100,
                          color: Color(0xFF8B5CF6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _t('app_title'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(color: Color(0xFF8B5CF6), blurRadius: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _t('tagline'),
                          style: const TextStyle(
                            color: Color(0xFFC4B5FD),
                            fontSize: 16,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: powerOn,
                          icon: const Icon(Icons.construction),
                          label: Text(_t('init_btn')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
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
                            shadowColor: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
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

  // --- सब-विजेट्स (SUB-WIDGETS) ---
  Widget _buildFloatingMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: IconButton(
        icon: Icon(isSidePanelOpen ? Icons.menu_open : Icons.menu),
        color: Colors.white,
        tooltip: 'Toggle Panel',
        onPressed: () {
          playClick();
          setState(() {
            isSidePanelOpen = !isSidePanelOpen;
            // जब भी पैनल टॉगल हो, ग्राफ़ को दोबारा सेंटर करें
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _centerGraph();
            });
          });
        },
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: const Border(right: BorderSide(color: Color(0xFF334155))),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      // SingleChildScrollView covers everything, so the footer scrolls with the rest of the content if overflowed
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // शीर्ष हेडर स्पेसिंग (बटन के लिए जगह)
            const SizedBox(height: 60),
            _buildPanelHeader(),
            // मुख्य सामग्री क्षेत्र
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildExploreContent(),
            ),
            const SizedBox(height: 30),

            // Sidebar Footer inside scroll
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF020617),
                border: Border(top: BorderSide(color: Color(0xFF334155))),
              ),
              child: const Text(
                "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('header_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('header_subtitle'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFFA78BFA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // भाषा टॉगल (Language Toggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['en', 'hi']
                      .map(
                        (l) => GestureDetector(
                          onTap: () {
                            playClick();
                            setState(() => lang = l);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: lang == l
                                  ? const Color(0xFF8B5CF6)
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
                  playClick();
                  setState(() {
                    resetLab();
                    isPoweredOn = false;
                    _shutterController.reverse();
                  });
                },
                icon: const Icon(Icons.power_settings_new),
                color: const Color(0xFFF87171),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF451A1A),
                ),
                tooltip: _t('btn_restart'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF334155), height: 1),
        ],
      ),
    );
  }

  Widget _buildExploreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // मिशन उद्देश्य कार्ड (Mission Objective Card)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.track_changes,
                  color: Color(0xFFC4B5FD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('mission_title'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC4B5FD),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('mission_desc'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildLabControls(isFloating: false),
      ],
    );
  }

  // --- लैब कंट्रोल्स का विजेट (Lab Controls Widget) ---
  Widget _buildLabControls({bool isFloating = false}) {
    return Container(
      width: isFloating ? 300 : double.infinity,
      decoration: BoxDecoration(
        color: isFloating
            ? const Color(0xFF0F172A).withOpacity(0.95)
            : const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFloating
              ? const Color(0xFF8B5CF6).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
        boxShadow: isFloating
            ? const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('step_${currentStep}_t'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC4B5FD),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t('step_${currentStep}_d'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (currentStep == 1) ...[
            Text(
              _t('lbl_click_graph'),
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'α: ${alpha ?? '?'}',
                    style: TextStyle(
                      color: alpha != null
                          ? const Color(0xFFC4B5FD)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'β: ${beta ?? '?'}',
                    style: TextStyle(
                      color: beta != null
                          ? const Color(0xFF67E8F9)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (alpha != null && beta != null)
                    ? confirmZeroes
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  disabledBackgroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _t('btn_confirm_sel'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: resetSelection,
              child: Center(
                child: Text(
                  _t('btn_clear_sel'),
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ),
          ] else if (currentStep == 2) ...[
            Text(
              _t('msg_process'),
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputCard(
                    'Sum (α + β)',
                    _sumController,
                    Colors.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputCard(
                    'Product (αβ)',
                    _prodController,
                    Colors.deepPurple,
                  ),
                ),
              ],
            ),
            if (showStep2Error)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Incorrect. Try: S = ${alpha! + beta!}, P = ${alpha! * beta!}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: validateSumProd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _t('btn_process'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (currentStep == 3) ...[
            const Text(
              'Insert Components into Blueprint',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                      color: Color(0xFF94A3B8),
                    ),
                    children: [
                      const TextSpan(text: 'x² - ('),
                      TextSpan(
                        text: '${alpha! + beta!}',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ')x + ('),
                      TextSpan(
                        text: '${alpha! * beta!}',
                        style: const TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ')'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: assemblePolynomial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _t('btn_assemble'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (currentStep == 4) ...[
            const Text(
              'Constructed Polynomial',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              _buildPolynomialString(alpha! + beta!, alpha! * beta!),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyIntegrity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _t('btn_verify'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (currentStep == 5) ...[
            const Center(
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _t('msg_success'),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: resetLab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _t('btn_next'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputCard(
    String label,
    TextEditingController ctrl,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black54,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  String _buildPolynomialString(int s, int p) {
    String sSign = s < 0 ? '+' : '-';
    String pSign = p < 0 ? '-' : '+';
    return 'p(x) = x² $sSign ${s.abs()}x $pSign ${p.abs()}';
  }

  // --- कैनवास और प्रूफ मोडल (CANVAS & PROOF MODAL) ---
  Widget _buildMainCanvas(double panelWidth) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // इंटरेक्टिव 2D कैनवास (Interactive 2D Canvas)
          InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.1,
            maxScale: 5.0,
            child: SizedBox(
              width: 4000,
              height: 4000,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: handleCanvasTap,
                child: CustomPaint(
                  painter: CartesianPainter(
                    alpha: alpha,
                    beta: beta,
                    step: currentStep,
                    parabolaProgress: _parabolaController.value,
                  ),
                ),
              ),
            ),
          ),

          // समीकरण ओवरले (Equation Overlay) (Step 3+)
          if (currentStep >= 3 && alpha != null && beta != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              top:
                  180, // Set to 180 to clear the floating HUD and Mission elements safely
              // साइड पैनल बंद होने पर भी फ्लोटिंग कार्ड (width ~320px) से बचने के लिए सुरक्षित क्षेत्र
              left: isSidePanelOpen ? panelWidth : 340.0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showEquationOverlay ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x808B5CF6), blurRadius: 20),
                        ],
                      ),
                      child: Text(
                        _buildPolynomialString(alpha! + beta!, alpha! * beta!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // (HUD Status Top Right)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, right: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF8B5CF6), width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('hud_status').toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFA78BFA),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStep >= 4
                            ? 'STABLE'
                            : currentStep == 5
                            ? 'COMPLETE'
                            : 'BUILDING',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableProofModal() {
    final data = proofDataMap[currentProofStep];
    if (data == null) return const SizedBox();

    return Positioned(
      left: proofX,
      top: proofY,
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: data.color),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  proofX += details.delta.dx;
                  proofY += details.delta.dy;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.color.withOpacity(0.8),
                      const Color(0xFF0F172A),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  border: Border(
                    bottom: BorderSide(color: data.color.withOpacity(0.3)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: data.color.withOpacity(0.5),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.title,
                          style: TextStyle(
                            color: data.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.drag_handle,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            // मुख्य भाग (Body)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mathematical Model',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      data.math,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Real-World Logic',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: data.color.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data.analogy,
                            style: TextStyle(
                              fontSize: 12,
                              color: data.color.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // आगे बढ़ने का बटन (Footer Action)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: closeProofModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PROCEED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
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
}

// --- कार्टीजियन ग्रिड पेंटर (CARTESIAN GRID PAINTER) ---
class CartesianPainter extends CustomPainter {
  final int? alpha;
  final int? beta;
  final int step;
  final double parabolaProgress;

  // 4000x4000 कैनवास का आभासी केंद्र (Virtual center)
  final Offset origin = const Offset(2000, 2000);
  final double scale = 60.0; // पिक्सेल प्रति इकाई (pixels per unit)

  CartesianPainter({
    required this.alpha,
    required this.beta,
    required this.step,
    required this.parabolaProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. ग्रिड बनाएँ (Draw Grid)
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;

    // केंद्र से बाहर की ओर ग्रिड लाइनें (Grid lines spanning outward from origin)
    for (double i = 0; i < 2000; i += scale) {
      canvas.drawLine(
        Offset(origin.dx + i, 0),
        Offset(origin.dx + i, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(origin.dx - i, 0),
        Offset(origin.dx - i, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, origin.dy + i),
        Offset(size.width, origin.dy + i),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, origin.dy - i),
        Offset(size.width, origin.dy - i),
        gridPaint,
      );
    }

    // 2. अक्ष बनाएँ (Draw Axes)
    final xAxisPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2; // लाल (Red)
    final yAxisPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2; // नीला (Blue)

    canvas.drawLine(
      Offset(0, origin.dy),
      Offset(size.width, origin.dy),
      xAxisPaint,
    );
    canvas.drawLine(
      Offset(origin.dx, 0),
      Offset(origin.dx, size.height),
      yAxisPaint,
    );

    // टिक मार्क्स और संख्याएँ (Tick Marks & Numbers)
    const textStyle = TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 10,
      fontFamily: 'monospace',
    );
    for (int i = -30; i <= 30; i++) {
      if (i == 0) continue;
      // X अक्ष (X Axis)
      double px = origin.dx + i * scale;
      canvas.drawLine(
        Offset(px, origin.dy - 4),
        Offset(px, origin.dy + 4),
        xAxisPaint,
      );
      _drawText(canvas, i.toString(), Offset(px, origin.dy + 12), textStyle);

      // Y अक्ष (Y Axis)
      double py = origin.dy - i * scale;
      canvas.drawLine(
        Offset(origin.dx - 4, py),
        Offset(origin.dx + 4, py),
        yAxisPaint,
      );
      _drawText(canvas, i.toString(), Offset(origin.dx - 12, py), textStyle);
    }
    _drawText(canvas, '0', Offset(origin.dx - 8, origin.dy + 8), textStyle);

    // 3. चयनित बिंदु बनाएँ (Draw Selected Points)
    if (alpha != null) {
      _drawPoint(canvas, alpha!, 0, 'α = $alpha', const Color(0xFF8B5CF6));
    }
    if (beta != null) {
      _drawPoint(canvas, beta!, 0, 'β = $beta', const Color(0xFF06B6D4));
    }

    // 4. परवलय बनाएँ (Draw Parabola - Step 4)
    if (step >= 4 && alpha != null && beta != null && parabolaProgress > 0) {
      _drawParabola(canvas, alpha!, beta!, parabolaProgress);
    }
  }

  void _drawPoint(Canvas canvas, int x, int y, String label, Color color) {
    Offset pos = Offset(origin.dx + x * scale, origin.dy - y * scale);

    // चमक (Glow)
    canvas.drawCircle(
      pos,
      10,
      Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // बिंदु (Point)
    canvas.drawCircle(pos, 6, Paint()..color = color);

    // लेबल का बैकग्राउंड (Label Background)
    Rect bgRect = Rect.fromCenter(
      center: Offset(pos.dx, pos.dy - 25),
      width: 50,
      height: 20,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );

    // पाठ (Text)
    _drawText(
      canvas,
      label,
      Offset(pos.dx, pos.dy - 25),
      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  void _drawParabola(Canvas canvas, int a, int b, double progress) {
    // परवलय समीकरण (Parabola equation): y = (x - a)(x - b)
    final paint = Paint()
      ..color =
          const Color(0xFF10B981) // हरा (Emerald)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.solid,
        2,
      ); // हल्की चमक (Slight glow)

    final path = Path();

    // हम तार्किक रूप से x = -20 से x = +20 तक खींचते हैं
    const double drawStart = -20.0;
    const double drawEnd = 20.0;
    double currentMaxX = drawStart + (drawEnd - drawStart) * progress;

    bool first = true;
    for (double x = drawStart; x <= currentMaxX; x += 0.1) {
      double y = (x - a) * (x - b);
      Offset pos = Offset(origin.dx + x * scale, origin.dy - y * scale);

      // सीमा क्लिपिंग ताकि पथ बाहर न जाए (Basic bounds clipping)
      if (pos.dy < 0 || pos.dy > 4000) {
        first = true;
        continue;
      }

      if (first) {
        path.moveTo(pos.dx, pos.dy);
        first = false;
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CartesianPainter oldDelegate) {
    return oldDelegate.alpha != alpha ||
        oldDelegate.beta != beta ||
        oldDelegate.step != step ||
        oldDelegate.parabolaProgress != parabolaProgress;
  }
}
