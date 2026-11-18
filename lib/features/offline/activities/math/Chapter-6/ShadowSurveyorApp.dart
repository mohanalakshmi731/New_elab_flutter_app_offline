// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as dart_math;
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

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
      'app_title': 'THE SHADOW SURVEYOR',
      'tagline': 'Applications of Similar Triangles',
      'init_btn': 'DEPLOY SURVEYOR',
      'header_title': 'The Shadow Surveyor',
      'header_subtitle': 'Class 10 • Triangles & Similarity',
      'phase_label': 'SURVEY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Height Confirmed',
      'success_desc': 'Target height successfully calculated using similarity!',
      'btn_restart': 'NEW SURVEY',
      's0': 'Locate Target: Inaccessible Tower.',
      's1': 'Deploy Reference: Place 2m Survey Pole.',
      's2': 'Observe Environment: Sun casts parallel rays.',
      's3': 'Measure Reference: Pole Shadow = 3m.',
      's4': 'Measure Target: Tower Shadow = 15m.',
      's5': 'Analyze: Identify Similar Triangles (AA).',
      's6': 'Formulate: Set up proportion equation.',
      's7': 'Substitute: Enter known measurements.',
      's8': 'Solve: Calculate Tower Height (H).',
      's9': 'Conclusion: Survey Complete.',
      'btn_locate': 'LOCATE TOWER',
      'btn_place_pole': 'PLACE POLE (2m)',
      'btn_cast_rays': 'OBSERVE SUN RAYS',
      'btn_meas_pole': 'MEASURE POLE SHADOW',
      'btn_meas_tower': 'MEASURE TOWER SHADOW',
      'btn_id_triangles': 'IDENTIFY TRIANGLES',
      'btn_setup_eq': 'SETUP EQUATION',
      'btn_substitute': 'SUBSTITUTE VALUES',
      'btn_verify': 'VERIFY CALCULATION',
      'btn_complete': 'FINALIZE REPORT',
      'msg_loc_ok': 'Target Tower locked.',
      'msg_pole_ok': '2m Survey Pole deployed.',
      'msg_rays_ok': 'Sun rays cast. Shadows formed.',
      'msg_meas_p_ok': 'Pole shadow measured: 3m.',
      'msg_meas_t_ok': 'Tower shadow measured: 15m.',
      'msg_tri_ok': 'Similar triangles confirmed via AA criterion.',
      'msg_eq_ok': 'Proportion equation established.',
      'msg_sub_ok': 'Values substituted into formula.',
      'msg_calc_ok': 'Calculation correct! H = 10m.',
      'msg_err': 'Incorrect value. Try again.',
      'q_solve': 'Solve for H: H = (2 * 15) / 3',
      'lbl_tower': 'TOWER',
      'lbl_pole': 'POLE',
      'lbl_sun': 'SUN',
      'data_title': 'DATA COLLECTION',
      'data_pole_h': 'Pole Height',
      'data_pole_s': 'Pole Shadow',
      'data_tower_s': 'Tower Shadow',
      'data_tower_h': 'Tower Height (H)',
      'data_pending': 'Pending...',
      'lbl_equation': 'PROPORTION EQUATION',
      'msg_waiting_data': 'Waiting for data collection...',
    },
    'hi': {
      'app_title': 'शैडो सर्वेयर',
      'tagline': 'समरूप त्रिभुजों के अनुप्रयोग',
      'init_btn': 'सर्वेयर तैनात करें',
      'header_title': 'शैडो सर्वेयर',
      'header_subtitle': 'कक्षा 10 • त्रिभुज और समरूपता',
      'phase_label': 'सर्वेक्षण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'ऊंचाई की पुष्टि',
      'success_desc':
          'समरूपता का उपयोग करके लक्ष्य की ऊंचाई की सफलतापूर्वक गणना की गई!',
      'btn_restart': 'नया सर्वेक्षण',
      's0': 'लक्ष्य का पता लगाएँ: दुर्गम टॉवर।',
      's1': 'संदर्भ तैनात करें: 2m पोल रखें।',
      's2': 'पर्यावरण का निरीक्षण करें: सूर्य की किरणें।',
      's3': 'संदर्भ मापें: पोल की छाया = 3m।',
      's4': 'लक्ष्य मापें: टॉवर की छाया = 15m।',
      's5': 'विश्लेषण: समरूप त्रिभुज (AA) पहचानें।',
      's6': 'सूत्र तैयार करें: अनुपात समीकरण सेट करें।',
      's7': 'प्रतिस्थापित करें: ज्ञात माप दर्ज करें।',
      's8': 'हल करें: टॉवर ऊंचाई (H) की गणना करें।',
      's9': 'निष्कर्ष: सर्वेक्षण पूर्ण।',
      'btn_locate': 'टॉवर खोजें',
      'btn_place_pole': 'पोल रखें (2m)',
      'btn_cast_rays': 'सूर्य की किरणें देखें',
      'btn_meas_pole': 'पोल की छाया मापें',
      'btn_meas_tower': 'टॉवर की छाया मापें',
      'btn_id_triangles': 'त्रिभुज पहचानें',
      'btn_setup_eq': 'समीकरण सेट करें',
      'btn_substitute': 'मान प्रतिस्थापित करें',
      'btn_verify': 'गणना जांचें',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_loc_ok': 'लक्ष्य टॉवर लॉक।',
      'msg_pole_ok': '2m सर्वेक्षण पोल तैनात।',
      'msg_rays_ok': 'सूर्य की किरणें और छाया बनीं।',
      'msg_meas_p_ok': 'पोल की छाया मापी गई: 3m।',
      'msg_meas_t_ok': 'टॉवर की छाया मापी गई: 15m।',
      'msg_tri_ok': 'AA मानदंड द्वारा समरूप त्रिभुज की पुष्टि की गई।',
      'msg_eq_ok': 'अनुपात समीकरण स्थापित।',
      'msg_sub_ok': 'सूत्र में मान प्रतिस्थापित किए गए।',
      'msg_calc_ok': 'गणना सही! H = 10m।',
      'msg_err': 'गलत मान। पुनः प्रयास करें।',
      'q_solve': 'H के लिए हल करें: H = (2 * 15) / 3',
      'lbl_tower': 'टॉवर',
      'lbl_pole': 'पोल',
      'lbl_sun': 'सूर्य',
      'data_title': 'डेटा संग्रह',
      'data_pole_h': 'पोल की ऊंचाई',
      'data_pole_s': 'पोल की छाया',
      'data_tower_s': 'टॉवर की छाया',
      'data_tower_h': 'टॉवर ऊंचाई (H)',
      'data_pending': 'लंबित...',
      'lbl_equation': 'अनुपात समीकरण',
      'msg_waiting_data': 'डेटा संग्रह की प्रतीक्षा है...',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ShadowSurveyorApp extends StatefulWidget {
  const ShadowSurveyorApp({super.key});

  @override
  State<ShadowSurveyorApp> createState() => _ShadowSurveyorAppState();
}

class _ShadowSurveyorAppState extends State<ShadowSurveyorApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';
  bool isPanelExpanded = true;
  bool isDataPanelExpanded = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Animation Controllers
  late AnimationController _rayAnimController;

  // Canvas Control
  final TransformationController _transformController =
      TransformationController();
  bool _isInitialPanSet = false;

  // Input Controller
  final TextEditingController _inpAns = TextEditingController();

  // Scroll Controller
  final ScrollController _exploreScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _rayAnimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _rayAnimController.dispose();
    _transformController.dispose();
    _inpAns.dispose();
    _exploreScrollCtrl.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void startGame() {
    playMathStart();
    setState(() {
      hasStarted = true;
    });
  }

  void switchLang(String newLang) {
    playMathClick();
    setState(() {
      lang = newLang;
    });
  }

  void showToast(
    String message, {
    bool isError = false,
    bool isSuccess = true,
  }) {
    if (isError) playMathError();
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
    if (currentStep < 9) {
      playMathClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Trigger specific animations based on step
        if (currentStep == 2) {
          _rayAnimController.forward(from: 0.0);
        }

        // Auto open data panel if step requires data observing
        if (currentStep == 1 && !isDataPanelExpanded) {
          isDataPanelExpanded = true;
          isPanelExpanded = false; // Mutually exclusive panels
        }

        if (currentStep == 9) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });

              // Automatically hide the success modal after 5 seconds
              Timer(const Duration(seconds: 5), () {
                if (mounted && showSuccessModal) {
                  setState(() {
                    showSuccessModal = false;
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  void checkCalculation() {
    if (_inpAns.text.trim() == '10') {
      advanceStep('msg_calc_ok');
    } else {
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void resetLab() {
    playMathStart();
    setState(() {
      currentStep = 0;
      showSuccessModal = false;
      hasStarted = false;
      isPanelExpanded = true;
      isDataPanelExpanded = false;
      _isInitialPanSet = false;
      _transformController.value = Matrix4.identity();
      _rayAnimController.reset();
      _inpAns.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive panel width
    final double panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth * 0.4).clamp(320.0, 450.0);

    final t = AppStrings.data[lang]!;

    if (!hasStarted) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentYellow.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 80,
                    color: accentYellow,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t['app_title']!,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: accentPink,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  t['tagline']!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: startGame,
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Text(
                      t['init_btn']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    shadowColor: accentPink.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // Core Layout: Responsive Side Panel + Canvas + Data Panel
            Positioned.fill(
              child: Row(
                children: [
                  // Animated Side Panel (Left)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isPanelExpanded ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildSidePanel(),
                      ),
                    ),
                  ),

                  // Interactive Canvas Area
                  Expanded(
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (!_isInitialPanSet) {
                            _isInitialPanSet = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final dx = -(4000 - constraints.maxWidth) / 2;
                              final dy = -(4000 - constraints.maxHeight) / 2;
                              _transformController.value = Matrix4.identity()
                                ..translate(dx, dy);
                            });
                          }
                          return InteractiveViewer(
                            transformationController: _transformController,
                            boundaryMargin: const EdgeInsets.all(2000),
                            minScale: 0.1,
                            maxScale: 5.0,
                            constrained: false,
                            child: Container(
                              width: 4000,
                              height: 4000,
                              alignment: Alignment.center,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(painter: GridPainter()),
                                  ),
                                  Center(child: _buildSceneGraphics()),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Animated Data Panel (Right)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isDataPanelExpanded ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerRight,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildDataPanel(t),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating HUD (Visible when sidebar is collapsed)
            if (!isPanelExpanded)
              Positioned(top: 80, left: 24, child: _buildFloatingHUD()),

            // // Top-Left Floating Button (Back / Reset)
            // Positioned(
            //   bottom: 24,
            //   left: 24,
            //   child: Material(
            //     color: Colors.white.withOpacity(0.1),
            //     shape: const CircleBorder(),
            //     clipBehavior: Clip.antiAlias,
            //     child: InkWell(
            //       onTap: () {
            //         HapticFeedback.lightImpact();
            //         if (Navigator.of(context).canPop()) {
            //           Navigator.of(context).pop();
            //         } else {
            //           resetLab();
            //         }
            //       },
            //       child: const Padding(
            //         padding: EdgeInsets.all(12),
            //         child: Icon(Icons.arrow_back, color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),

            // Bottom-Left Floating Menu Toggle
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                backgroundColor: accentBlue,
                elevation: 8,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playMathClick();
                  setState(() {
                    isPanelExpanded = !isPanelExpanded;
                    if (isPanelExpanded) {
                      isDataPanelExpanded = false;
                    }
                  });
                },
                child: Icon(
                  isPanelExpanded ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // Bottom-Right Floating Data Collection Toggle
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: accentYellow,
                elevation: 8,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playMathClick();
                  setState(() {
                    isDataPanelExpanded = !isDataPanelExpanded;
                    if (isDataPanelExpanded) {
                      isPanelExpanded = false;
                    }
                  });
                },
                child: Icon(
                  isDataPanelExpanded ? Icons.close : Icons.analytics,
                  color: bgDark,
                ),
              ),
            ),

            // Success Overlay Modal
            if (showSuccessModal) _buildSuccessModal(),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildSidePanel() {
    final t = AppStrings.data[lang]!;
    return Container(
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        border: Border(right: BorderSide(color: accentPink.withOpacity(0.3))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(
                top: 80, // Clear the top-left floating back button visually
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: accentBlue.withOpacity(0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentPink, Color(0xFFF43F5E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.straighten,
                          color: bgDark,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['header_title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['header_subtitle']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentPink,
                                letterSpacing: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLangToggles(),
                      IconButton(
                        onPressed: resetLab,
                        icon: const Icon(Icons.power_settings_new, size: 20),
                        color: accentRed,
                        style: IconButton.styleFrom(
                          backgroundColor: accentRed.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: accentRed.withOpacity(0.3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 90, // Bottom padding to clear floating menu toggle
              ),
              child: _buildExploreContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPanel(Map<String, String> t) {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        border: Border(left: BorderSide(color: accentYellow.withOpacity(0.3))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 80,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: accentYellow.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: accentYellow,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.analytics, color: bgDark, size: 20),
                ),
                Expanded(
                  child: Text(
                    t['data_title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDataRow(
                  t['data_pole_h']!,
                  currentStep >= 1 ? "2m" : t['data_pending']!,
                  currentStep >= 1,
                ),
                _buildDataRow(
                  t['data_pole_s']!,
                  currentStep >= 3 ? "3m" : t['data_pending']!,
                  currentStep >= 3,
                ),
                _buildDataRow(
                  t['data_tower_s']!,
                  currentStep >= 4 ? "15m" : t['data_pending']!,
                  currentStep >= 4,
                ),
                _buildDataRow(
                  t['data_tower_h']!,
                  currentStep >= 9 ? "10m" : t['data_pending']!,
                  currentStep >= 9,
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 20),

                Text(
                  t['lbl_equation']!,
                  style: const TextStyle(
                    color: accentYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                _buildEquationPanel(t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isAvailable ? accentYellow : Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: isAvailable ? accentYellow : Colors.white30,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: ['en', 'hi'].map((l) {
          bool isActive = lang == l;
          return GestureDetector(
            onTap: () => switchLang(l),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.white24 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.white54,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExploreContent() {
    final t = AppStrings.data[lang]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t['phase_label']!,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${t['step_label']} ${currentStep + 1}/10",
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
          value: (currentStep + 1) / 10,
          backgroundColor: Colors.black38,
          color: accentPink,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 20),

        // Steps List
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Text(
            t['mission_log']!.toUpperCase(),
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
            padding: EdgeInsets.zero,
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
                  "${index + 1}. ${t['s$index']}",
                  style: TextStyle(
                    color: isActive
                        ? accentPink
                        : isDone
                        ? Colors.white54
                        : Colors.white30,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        // Interaction Controls Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: _buildControlsArea(),
        ),
      ],
    );
  }

  Widget _buildFloatingHUD() {
    final t = AppStrings.data[lang]!;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 80,
        maxWidth: 280,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgPanel.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentBlue.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t['active_mission']!.toUpperCase(),
                    style: const TextStyle(
                      color: accentPink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${currentStep + 1}/10",
                    style: const TextStyle(
                      color: accentBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                t['s$currentStep']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: _buildControlsArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsArea() {
    final t = AppStrings.data[lang]!;
    switch (currentStep) {
      case 0:
        return _ControlButton(
          text: t['btn_locate']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_loc_ok'),
        );
      case 1:
        return _ControlButton(
          text: t['btn_place_pole']!,
          color: accentPink,
          onPressed: () => advanceStep('msg_pole_ok'),
        );
      case 2:
        return _ControlButton(
          text: t['btn_cast_rays']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_rays_ok'),
        );
      case 3:
        return _ControlButton(
          text: t['btn_meas_pole']!,
          color: accentGreen,
          onPressed: () => advanceStep('msg_meas_p_ok'),
        );
      case 4:
        return _ControlButton(
          text: t['btn_meas_tower']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_meas_t_ok'),
        );
      case 5:
        return _ControlButton(
          text: t['btn_id_triangles']!,
          color: accentPink,
          onPressed: () => advanceStep('msg_tri_ok'),
        );
      case 6:
        return _ControlButton(
          text: t['btn_setup_eq']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_eq_ok'),
        );
      case 7:
        return _ControlButton(
          text: t['btn_substitute']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 8:
        return Column(
          children: [
            Text(
              t['q_solve']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _inpAns,
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
                hintText: "H = ?",
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: checkCalculation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    t['btn_verify']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 9:
        return _ControlButton(
          text: t['btn_complete']!,
          color: accentYellow,
          onPressed: () => advanceStep(''),
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics() {
    final t = AppStrings.data[lang]!;
    return SizedBox(
      width: 500,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 320),
            painter: ShadowSurveyorPainter(
              step: currentStep,
              rayProgress: _rayAnimController.value,
            ),
          ),

          // --- LABELS & MEASUREMENTS ---
          // Sun Label
          if (currentStep >= 2)
            Positioned(
              left: 545,
              top: 5,
              child: Text(
                t['lbl_sun']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentYellow,
                  fontSize: 12,
                ),
              ),
            ),

          // Object Labels
          if (currentStep >= 0)
            Positioned(
              left: 410,
              top: 10,
              child: Text(
                t['lbl_tower']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ),
          if (currentStep >= 1)
            Positioned(
              left: 170,
              top: 180,
              child: Text(
                t['lbl_pole']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ),

          // Pole Measurements
          if (currentStep >= 3) ...[
            const Positioned(
              left: 190,
              top: 210,
              child: _MeasurementBadge(label: "h=2m", color: accentPink),
            ),
            const Positioned(
              left: 145,
              top: 275,
              child: _MeasurementBadge(label: "s=3m", color: accentPink),
            ),
          ],

          // Tower Measurements
          if (currentStep >= 4) ...[
            Positioned(
              left: 450,
              top: 120,
              child: _MeasurementBadge(
                label: currentStep >= 9 ? "H=10m" : "H=?",
                color: accentBlue,
              ),
            ),
            const Positioned(
              left: 310,
              top: 275,
              child: _MeasurementBadge(label: "S=15m", color: accentBlue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEquationPanel(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: currentStep >= 6
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tower Ratio
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Tower Height",
                      style: TextStyle(color: accentBlue, fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentStep >= 9 ? "10" : "H",
                      style: TextStyle(
                        color: currentStep >= 7 ? accentGreen : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      color: accentBlue,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Text(
                      currentStep >= 7 ? "15" : "S_tower",
                      style: TextStyle(
                        color: currentStep >= 7 ? accentGreen : Colors.white54,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                // Equality Sign
                const Text(
                  "=",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: accentYellow,
                  ),
                ),

                // Pole Ratio
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pole Height",
                      style: TextStyle(color: accentPink, fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentStep >= 7 ? "2" : "h",
                      style: TextStyle(
                        color: currentStep >= 7 ? accentGreen : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      color: accentPink,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Text(
                      currentStep >= 7 ? "3" : "s_pole",
                      style: TextStyle(
                        color: currentStep >= 7 ? accentGreen : Colors.white54,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: Text(
                t['msg_waiting_data']!,
                style: const TextStyle(
                  color: Colors.white30,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
    );
  }

  Widget _buildSuccessModal() {
    final t = AppStrings.data[lang]!;
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: bgDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGreen, width: 2),
              boxShadow: [
                BoxShadow(color: accentGreen.withOpacity(0.3), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: accentGreen, size: 80),
                const SizedBox(height: 20),
                Text(
                  t['badge_title']!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t['success_desc']!,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  onPressed: resetLab,
                  child: Text(
                    t['btn_restart']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _MeasurementBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MeasurementBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
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
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---

class ShadowSurveyorPainter extends CustomPainter {
  final int step;
  final double rayProgress; // 0.0 to 1.0

  ShadowSurveyorPainter({required this.step, required this.rayProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Setup Environment
    final paintGround = Paint()
      ..color = Colors.white24
      ..strokeWidth = 4;
    canvas.drawLine(const Offset(0, 260), const Offset(500, 260), paintGround);

    // Coordinate System (Flipped horizontally for visual effect)
    Offset towerBase = const Offset(440, 260);
    Offset towerTop = const Offset(440, 110);
    Offset towerShadowEnd = const Offset(195, 260);

    Offset poleBase = const Offset(180, 260);
    Offset poleTop = const Offset(180, 230);
    Offset poleShadowEnd = const Offset(135, 260);

    // 2. Draw Objects
    if (step >= 0) {
      // Draw Tower
      final towerPaint = Paint()
        ..color = accentBlue
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTRB(420, 110, 460, 260), towerPaint);

      final towerLine = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromLTRB(420, 110, 460, 260), towerLine);
    }

    if (step >= 1) {
      // Draw Pole
      final polePaint = Paint()
        ..color = accentPink
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(poleTop, poleBase, polePaint);
    }

    // 3. Draw Rays & Shadows
    if (step >= 2) {
      // Shadows
      final shadowPaint = Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.fill;

      // Animate shadows based on rayProgress
      if (rayProgress > 0) {
        // Tower Shadow
        Path towerShadow = Path();
        towerShadow.moveTo(towerBase.dx - 20, 260); // from left edge of tower
        towerShadow.lineTo(towerBase.dx - 20 - (225 * rayProgress), 260);
        towerShadow.lineTo(towerBase.dx - 20 - (225 * rayProgress) + 10, 265);
        towerShadow.lineTo(towerBase.dx - 20, 265);
        canvas.drawPath(towerShadow, shadowPaint);

        // Pole Shadow
        Path poleShadow = Path();
        poleShadow.moveTo(poleBase.dx, 260);
        poleShadow.lineTo(poleBase.dx - (45 * rayProgress), 260);
        poleShadow.lineTo(poleBase.dx - (45 * rayProgress) + 5, 263);
        poleShadow.lineTo(poleBase.dx, 263);
        canvas.drawPath(poleShadow, shadowPaint);

        // Sun & Rays
        canvas.drawCircle(
          const Offset(562, 35),
          20,
          Paint()
            ..color = accentYellow
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.drawCircle(
          const Offset(562, 35),
          15,
          Paint()..color = Colors.white,
        );

        // Ray to Tower
        Offset towerRayStart = Offset(
          towerTop.dx + (towerShadowEnd.dx - towerTop.dx) * -0.5,
          towerTop.dy + (towerShadowEnd.dy - towerTop.dy) * -0.5,
        );
        Offset currentTowerRay = Offset(
          towerRayStart.dx +
              (towerShadowEnd.dx - towerRayStart.dx) * rayProgress,
          towerRayStart.dy +
              (towerShadowEnd.dy - towerRayStart.dy) * rayProgress,
        );

        Offset poleRayStart = Offset(
          poleTop.dx + (poleShadowEnd.dx - poleTop.dx) * -1.0,
          poleTop.dy + (poleShadowEnd.dy - poleTop.dy) * -1.0,
        );
        Offset currentPoleRay = Offset(
          poleRayStart.dx + (poleShadowEnd.dx - poleRayStart.dx) * rayProgress,
          poleRayStart.dy + (poleShadowEnd.dy - poleRayStart.dy) * rayProgress,
        );

        final rayPaint = Paint()
          ..color = accentYellow.withOpacity(0.6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        _drawDashedLine(canvas, towerRayStart, currentTowerRay, rayPaint);
        _drawDashedLine(canvas, poleRayStart, currentPoleRay, rayPaint);
      }
    }

    // 4. Highlight Similar Triangles (Step 5+)
    if (step >= 5) {
      final highlightFill = Paint()
        ..color = accentGreen.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final highlightStroke = Paint()
        ..color = accentGreen
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Tower Triangle
      Path tTower = Path();
      tTower.moveTo(towerTop.dx - 20, towerTop.dy);
      tTower.lineTo(towerTop.dx - 20, towerBase.dy);
      tTower.lineTo(towerShadowEnd.dx, towerShadowEnd.dy);
      tTower.close();
      canvas.drawPath(tTower, highlightFill);
      canvas.drawPath(tTower, highlightStroke);

      // Pole Triangle
      Path tPole = Path();
      tPole.moveTo(poleTop.dx, poleTop.dy);
      tPole.lineTo(poleBase.dx, poleBase.dy);
      tPole.lineTo(poleShadowEnd.dx, poleShadowEnd.dy);
      tPole.close();
      canvas.drawPath(tPole, highlightFill);
      canvas.drawPath(tPole, highlightStroke);

      // 90 degree markers
      _drawRightAngle(canvas, Offset(towerTop.dx - 20, towerBase.dy), -1, -1);
      _drawRightAngle(canvas, poleBase, -1, -1);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 10, dashSpace = 5;
    double startX = p1.dx, startY = p1.dy;
    final double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    final double distance = (Offset(dx, dy)).distance;
    final double angle = (Offset(dx, dy)).direction;

    double drawnLength = 0;
    while (drawnLength < distance) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + dashWidth * dart_math.cos(angle),
          startY + dashWidth * dart_math.sin(angle),
        ),
        paint,
      );
      startX += (dashWidth + dashSpace) * dart_math.cos(angle);
      startY += (dashWidth + dashSpace) * dart_math.sin(angle);
      drawnLength += dashWidth + dashSpace;
    }
  }

  void _drawRightAngle(Canvas canvas, Offset corner, double dirX, double dirY) {
    const double size = 15;
    final paint = Paint()
      ..color = accentGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(corner.dx + size * dirX, corner.dy);
    path.lineTo(corner.dx + size * dirX, corner.dy + size * dirY);
    path.lineTo(corner.dx, corner.dy + size * dirY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShadowSurveyorPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.rayProgress != rayProgress;
  }
}

// Math Utility for CustomPainter
class Math {
  static double cos(double x) => dart_math.cos(x);
  static double sin(double x) => dart_math.sin(x);
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 30;
    // Draw an infinite-feeling grid from far left to right and top to bottom
    for (double i = -2000; i < size.width + 2000; i += step) {
      canvas.drawLine(Offset(i, -2000), Offset(i, size.height + 2000), paint);
    }
    for (double i = -2000; i < size.height + 2000; i += step) {
      canvas.drawLine(Offset(-2000, i), Offset(size.width + 2000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
