// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

// --- TRANSLATIONS DICTIONARY ---
final Map<String, Map<String, String>> _translations = {
  'app_title': {'EN': 'LADDER CLIMBER', 'HI': 'सीढ़ी चढ़ने वाला'},
  'app_subtitle': {
    'EN': 'Class 10 • Arithmetic Progression',
    'HI': 'कक्षा 10 • समांतर श्रेढ़ी',
  },
  'mission_phase': {'EN': 'MISSION PHASE', 'HI': 'मिशन चरण'},
  'step': {'EN': 'Step', 'HI': 'चरण'},
  'console_log': {'EN': 'CONSOLE LOG', 'HI': 'कंसोल लॉग'},
  'footer': {
    'EN': '© ZeroScienceLab - Fall in love with math and Science',
    'HI': '© ZeroScienceLab - Fall in love with math and Science',
  },
  'click_bottom_rung': {
    'EN': 'Click on the bottom-most rung.',
    'HI': 'सबसे निचली सीढ़ी पर क्लिक करें।',
  },
  'click_space_first_rungs': {
    'EN': 'Click the space between first rungs.',
    'HI': 'पहली सीढ़ियों के बीच की जगह पर क्लिक करें।',
  },
  'select_target_slot': {
    'EN': "Select the target slot 'Rung 20'.",
    'HI': "लक्ष्य स्लॉट 'सीढ़ी 20' चुनें।",
  },
  'select_correct_formula': {
    'EN': 'Select correct formula:',
    'HI': 'सही सूत्र चुनें:',
  },
  'how_many_gaps': {
    'EN': 'To reach step 20, how many gaps?',
    'HI': 'चरण 20 तक पहुंचने के लिए, कितने अंतराल?',
  },
  'confirm': {'EN': 'CONFIRM', 'HI': 'पुष्टि करें'},
  'click_variables': {
    'EN': 'Click variables to fill slots.',
    'HI': 'स्लॉट भरने के लिए चर पर क्लिक करें।',
  },
  'compute_gaps': {'EN': 'COMPUTE GAPS', 'HI': 'अंतराल की गणना करें'},
  'add_base_height': {'EN': 'ADD BASE HEIGHT', 'HI': 'आधार ऊंचाई जोड़ें'},
  'launch_drone': {'EN': 'LAUNCH DRONE', 'HI': 'ड्रोन लॉन्च करें'},
  'depth_of_10th': {
    'EN': 'Depth of 10th rung? (a=0, d=-5)',
    'HI': '10वीं सीढ़ी की गहराई? (a=0, d=-5)',
  },
  'submit': {'EN': 'SUBMIT', 'HI': 'जमा करें'},
  'log_1': {
    'EN': "1. Inspect Foundation: Identify 'a'.",
    'HI': "1. नींव का निरीक्षण करें: 'a' पहचानें।",
  },
  'log_2': {
    'EN': "2. Measure Gap: Identify 'd'.",
    'HI': "2. अंतर मापें: 'd' पहचानें।",
  },
  'log_3': {
    'EN': "3. Define Target: Select Rung 20.",
    'HI': "3. लक्ष्य निर्धारित करें: सीढ़ी 20 चुनें।",
  },
  'log_4': {
    'EN': "4. Formula Computer: Select formula.",
    'HI': "4. सूत्र कंप्यूटर: सूत्र चुनें।",
  },
  'log_5': {'EN': "5. Logic Check: n-1.", 'HI': "5. तर्क जांच: n-1।"},
  'log_6': {
    'EN': "6. Substitute Parameters.",
    'HI': "6. मापदंडों को प्रतिस्थापित करें।",
  },
  'log_7': {
    'EN': "7. Calculate Gap Height.",
    'HI': "7. गैप की ऊंचाई की गणना करें।",
  },
  'log_8': {
    'EN': "8. Final Height Calculation.",
    'HI': "8. अंतिम ऊंचाई की गणना।",
  },
  'log_9': {
    'EN': "9. Place Flag: Launch Drone.",
    'HI': "9. झंडा लगाएं: ड्रोन लॉन्च करें।",
  },
  'log_10': {
    'EN': "10. Descending Ladder Challenge.",
    'HI': "10. उतरती सीढ़ी की चुनौती।",
  },
  'safety_cert': {
    'EN': 'SAFETY CERT: EXPERT',
    'HI': 'सुरक्षा प्रमाण पत्र: विशेषज्ञ',
  },
  'activity_complete': {'EN': 'Activity Complete!', 'HI': 'गतिविधि पूरी हुई!'},
  'new_project': {'EN': 'NEW PROJECT', 'HI': 'नया प्रोजेक्ट'},
  'toast_valid_a': {'EN': 'Valid: a = 10', 'HI': 'मान्य: a = 10'},
  'toast_valid_d': {'EN': 'Valid: d = 5', 'HI': 'मान्य: d = 5'},
  'toast_target': {
    'EN': 'Target Identified: n = 20',
    'HI': 'लक्ष्य पहचाना गया: n = 20',
  },
  'toast_formula_loaded': {'EN': 'Formula Loaded.', 'HI': 'सूत्र लोड हो गया।'},
  'toast_incorrect_formula': {
    'EN': 'Incorrect Formula. Try again.',
    'HI': 'गलत सूत्र। पुनः प्रयास करें।',
  },
  'toast_correct_n1': {'EN': 'Correct! n - 1 = 19.', 'HI': 'सही! n - 1 = 19.'},
  'toast_equation_ready': {'EN': 'Equation Ready.', 'HI': 'समीकरण तैयार है।'},
  'toast_gap_height': {'EN': 'Gap Height = 95', 'HI': 'गैप की ऊंचाई = 95'},
  'toast_total_height': {'EN': 'Total Height = 105', 'HI': 'कुल ऊंचाई = 105'},
  'toast_sim_matches': {
    'EN': 'Simulation Matches Calculation!',
    'HI': 'सिमुलेशन गणना से मेल खाता है!',
  },
  'toast_activity_complete': {
    'EN': 'Activity Complete.',
    'HI': 'गतिविधि पूरी हुई।',
  },
  'toast_try_again': {'EN': 'Try Again.', 'HI': 'पुनः प्रयास करें।'},
  'canvas_gap': {'EN': 'GAP', 'HI': 'अंतराल'},
  'canvas_target': {'EN': 'TARGET', 'HI': 'लक्ष्य'},
  'canvas_h10': {'EN': 'Height = 10 ft', 'HI': 'ऊंचाई = 10 फीट'},
  'canvas_g5': {'EN': 'Gap = 5 ft', 'HI': 'अंतर = 5 फीट'},
  'canvas_f105': {'EN': 'FLAG = 105 ft', 'HI': 'झंडा = 105 फीट'},
  'canvas_hq': {'EN': 'Height = ?', 'HI': 'ऊंचाई = ?'},
  'canvas_dq': {'EN': 'Depth = ?', 'HI': 'गहराई = ?'},
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LadderClimberApp());
}

class LadderClimberApp extends StatelessWidget {
  const LadderClimberApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ladder Climber | Class 10 Math',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'sans-serif', // Default modern sans-serif fallback
      ),
      home: const MissionActivityScreen(),
    );
  }
}

class MissionActivityScreen extends StatefulWidget {
  const MissionActivityScreen({Key? key}) : super(key: key);

  @override
  State<MissionActivityScreen> createState() => _MissionActivityScreenState();
}

class _MissionActivityScreenState extends State<MissionActivityScreen>
    with SingleTickerProviderStateMixin {
  bool isSidebarOpen = true;
  int currentStep = 0;
  bool isActivityComplete = false;
  String selectedLang = 'EN';

  // Step variables
  double nMinus1SliderValue = 0;
  Map<String, bool> slotsFilled = {'a': false, 'n': false, 'd': false};
  TextEditingController descentController = TextEditingController();

  // Drone / Animation
  late AnimationController _droneController;
  late Animation<double> _droneAnimation;
  double _droneCurrentY = 0;

  // Interaction State Flags
  bool rung1Inspected = false;
  bool gap1Inspected = false;
  bool targetInspected = false;
  bool droneLaunched = false;

  final TransformationController _transformationController =
      TransformationController();

  // Color Palette
  final Color cBg = const Color(0xFF020617);
  final Color cPink = const Color(0xFFF472B6);
  final Color cBlue = const Color(0xFF3B82F6);
  final Color cGreen = const Color(0xFF22C55E);
  final Color cPanel = const Color(0xEE0F172A);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _droneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _droneAnimation =
        Tween<double>(begin: 0, end: 105).animate(
          CurvedAnimation(parent: _droneController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            _droneCurrentY = _droneAnimation.value;
          });
        });

    // Center ladder initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetCamera();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _droneController.dispose();
    descentController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  // Translation Helper
  String t(String key) {
    return _translations[key]?[selectedLang] ?? key;
  }

  void _resetCamera() {
    final Matrix4 matrix = Matrix4.identity()
      ..translate(-1500.0, -1800.0) // Adjust based on canvas size
      ..scale(0.8);
    _transformationController.value = matrix;
  }

  void _resetActivity() {
    playMathStart();
    setState(() {
      isActivityComplete = false;
      currentStep = 0;
      rung1Inspected = false;
      gap1Inspected = false;
      targetInspected = false;
      droneLaunched = false;
      nMinus1SliderValue = 0;
      slotsFilled = {'a': false, 'n': false, 'd': false};
      descentController.clear();
      _droneCurrentY = 0;
      _droneController.reset();
    });
    _resetCamera();
  }

  void _nextStep() {
    if (currentStep < 9) {
      setState(() {
        currentStep++;
      });
      _handleCameraForStep(currentStep);
    }
  }

  void _handleCameraForStep(int step) {
    if (step == 0) {
      _resetCamera();
    } else if (step == 2) {
      // Pan to top target
      final Matrix4 matrix = Matrix4.identity()
        ..translate(-1500.0, -300.0)
        ..scale(0.8);
      _transformationController.value = matrix;
    } else if (step == 8) {
      // Pan back to see drone launch
      final Matrix4 matrix = Matrix4.identity()
        ..translate(-1500.0, -1000.0)
        ..scale(0.4);
      _transformationController.value = matrix;
    } else if (step == 9) {
      // Descending challenge - Pan to descending ladder
      final Matrix4 matrix = Matrix4.identity()
        ..translate(-1500.0, -2800.0)
        ..scale(0.8);
      _transformationController.value = matrix;
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        backgroundColor: color.withOpacity(0.9),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.35;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // 1. Center Activity (Canvas Area)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildCanvasArea(),
            ),

            // 2. Sidebar Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: cPanel,
                  border: Border(
                    right: BorderSide(color: cBlue.withOpacity(0.3), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: _buildSidebar(),
              ),
            ),

            // 3. Floating Mission Card (when sidebar is closed)
            if (!isSidebarOpen)
              Positioned(
                top: 80,
                left: 16,
                width: 280,
                child: _buildFloatingMissionCard(),
              ),

            // 4. Success Modal Overlay
            if (isActivityComplete)
              Positioned.fill(child: _buildSuccessModal()),

            // 5. Menu Icon (Fixed Position, Front Z-Index)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: cPink,
                foregroundColor: Colors.black,
                onPressed: () {
                  playMathClick();
                  setState(() {
                    isSidebarOpen = !isSidebarOpen;
                  });
                },
                child: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCanvasArea() {
    return Container(
      color: cBg,
      child: Stack(
        children: [
          // Background Grid
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: GridPainter()),
            ),
          ),

          // Interactive 3D/2D Space
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.1,
              maxScale: 3.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(4000),
              child: SizedBox(
                width: 4000,
                height: 4000,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (currentStep < 9) _buildAscendingLadder(),
                    if (currentStep == 9) _buildDescendingLadder(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAscendingLadder() {
    const double baseY = 2800;
    const double pixelsPerUnit = 20;

    List<Widget> elements = [];

    // Rails
    elements.add(
      Positioned(
        left: 1940,
        top: baseY - (25 * 5 * pixelsPerUnit) - 200,
        width: 20,
        height: 25 * 5 * pixelsPerUnit + 400,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade700, Colors.grey.shade500],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
    elements.add(
      Positioned(
        left: 2040,
        top: baseY - (25 * 5 * pixelsPerUnit) - 200,
        width: 20,
        height: 25 * 5 * pixelsPerUnit + 400,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade700, Colors.grey.shade500],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    // Rungs & Gaps
    for (int n = 1; n <= 25; n++) {
      double heightInUnits = 10 + (n - 1) * 5.0;
      double yPos = baseY - (heightInUnits * pixelsPerUnit);

      bool isRung1 = n == 1;
      bool isRung20 = n == 20;

      // Rung Widget
      elements.add(
        Positioned(
          left: 1940,
          top: yPos,
          width: 120,
          height: 20,
          child: GestureDetector(
            onTap: () {
              if (currentStep == 0 && isRung1) {
                playMathClick();
                setState(() {
                  rung1Inspected = true;
                });
                _showToast(t('toast_valid_a'), cGreen);
                Future.delayed(const Duration(seconds: 2), _nextStep);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: cPink,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (currentStep == 0 && isRung1)
                    BoxShadow(
                      color: cPink.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Gap Widget (Clickable area between rungs)
      if (n < 25) {
        double gapYPos = baseY - ((heightInUnits + 2.5) * pixelsPerUnit);
        bool isFirstGap = n == 1;
        elements.add(
          Positioned(
            left: 1960,
            top: gapYPos - 40,
            width: 80,
            height: 80, // clickable height
            child: GestureDetector(
              onTap: () {
                if (currentStep == 1 && isFirstGap) {
                  playMathClick();
                  setState(() {
                    gap1Inspected = true;
                  });
                  _showToast(t('toast_valid_d'), cGreen);
                  Future.delayed(const Duration(seconds: 2), _nextStep);
                }
              },
              child: Container(
                color: (currentStep == 1 && isFirstGap)
                    ? cBlue.withOpacity(0.3)
                    : Colors.transparent,
                child: (currentStep == 1 && isFirstGap)
                    ? Center(
                        child: Text(
                          t('canvas_gap'),
                          style: const TextStyle(
                            color: Colors.white24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      }

      // Rung 20 Target Overlay
      if (isRung20) {
        elements.add(
          Positioned(
            left: 1920,
            top: yPos - 30,
            width: 160,
            height: 80,
            child: GestureDetector(
              onTap: () {
                if (currentStep == 2) {
                  playMathClick();
                  setState(() {
                    targetInspected = true;
                  });
                  _showToast(t('toast_target'), cGreen);
                  Future.delayed(const Duration(seconds: 2), _nextStep);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: (currentStep == 2 && !targetInspected)
                      ? Colors.white.withOpacity(0.3)
                      : Colors.transparent,
                  border: (currentStep == 2 && !targetInspected)
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: (currentStep == 2 && !targetInspected)
                    ? Center(
                        child: Text(
                          t('canvas_target'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      }
    }

    // Drone
    double droneVisualY = baseY - (_droneCurrentY * pixelsPerUnit);
    elements.add(
      Positioned(
        left: 1950,
        top: droneVisualY - 40, // offset drone above calculation point
        width: 100,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.cyan.withOpacity(0.8), blurRadius: 20),
            ],
          ),
          child: const Icon(Icons.flight, color: Colors.black, size: 40),
        ),
      ),
    );

    // Labels & Tapes
    if (rung1Inspected || currentStep > 0) {
      elements.add(
        Positioned(
          left: 2100,
          top: baseY - (10 * pixelsPerUnit) - 15,
          child: _buildCanvasLabel(t('canvas_h10'), cPink),
        ),
      );
    }
    if (gap1Inspected || currentStep > 1) {
      elements.add(
        Positioned(
          left: 2100,
          top: baseY - (12.5 * pixelsPerUnit) - 15,
          child: _buildCanvasLabel(t('canvas_g5'), cBlue),
        ),
      );
    }
    if (targetInspected || currentStep > 2) {
      elements.add(
        Positioned(
          left: 2100,
          top: baseY - (105 * pixelsPerUnit) - 15,
          child: _buildCanvasLabel(
            currentStep >= 8 ? t('canvas_f105') : t('canvas_hq'),
            Colors.white,
          ),
        ),
      );
    }

    // Drone Flag (Step 8 completed)
    if (droneLaunched && _droneAnimation.isCompleted) {
      elements.add(
        Positioned(
          left: 2000,
          top: baseY - (105 * pixelsPerUnit) - 80,
          child: Icon(Icons.flag, color: cGreen, size: 80),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: elements);
  }

  Widget _buildDescendingLadder() {
    const double baseY = 1000;
    const double pixelsPerUnit = 20;

    List<Widget> elements = [];

    // Rails
    elements.add(
      Positioned(
        left: 1940,
        top: baseY - 100,
        width: 20,
        height: 15 * 5 * pixelsPerUnit + 400,
        child: Container(color: Colors.grey.shade600),
      ),
    );
    elements.add(
      Positioned(
        left: 2040,
        top: baseY - 100,
        width: 20,
        height: 15 * 5 * pixelsPerUnit + 400,
        child: Container(color: Colors.grey.shade600),
      ),
    );

    // Rungs (Descending) a = 0, d = -5
    for (int n = 1; n <= 15; n++) {
      double depthInUnits = 0 + (n - 1) * -5.0; // 0, -5, -10...
      // Since it's negative, the visual Y goes DOWN (increases in value)
      double yPos = baseY - (depthInUnits * pixelsPerUnit);

      elements.add(
        Positioned(
          left: 1940,
          top: yPos,
          width: 120,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      );

      if (n == 10) {
        elements.add(
          Positioned(
            left: 2100,
            top: yPos - 15,
            child: _buildCanvasLabel(t('canvas_dq'), Colors.redAccent),
          ),
        );
      }
    }

    // Drone at base
    double droneVisualY = baseY - (_droneCurrentY * pixelsPerUnit);
    elements.add(
      Positioned(
        left: 1950,
        top: droneVisualY - 40,
        width: 100,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.flight, color: Colors.black, size: 40),
        ),
      ),
    );

    return Stack(clipBehavior: Clip.none, children: elements);
  }

  Widget _buildCanvasLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  // Helper function to build language toggle buttons
  Widget _buildLangBtn(String lang, bool isSelected) {
    return GestureDetector(
      onTap: () {
        playMathClick();
        setState(() {
          selectedLang = lang;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          lang,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  // --- CONTROLS / UI AREAS ---

  Widget _buildSidebar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Block (Title, Activity Icon, Back Button, Reset & Language)
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 62,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: cBlue.withOpacity(0.3)),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Row 1: Activity Icon + Title + Back Button
                        Row(
                          children: [
                            // Activity Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: cPink,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.stairs,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('app_title'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    t('app_subtitle'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: cPink,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 2: Reset Button + Language Toggles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Language Toggles
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade700),
                              ),
                              child: Row(
                                children: [
                                  _buildLangBtn('EN', selectedLang == 'EN'),
                                  _buildLangBtn('HI', selectedLang == 'HI'),
                                ],
                              ),
                            ),
                            // Reset Button
                            InkWell(
                              onTap: _resetActivity,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.power_settings_new,
                                  size: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content Area (Expands to push footer down if short)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t('mission_phase'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "${t('step')} ${currentStep + 1}/10",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: cBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (currentStep + 1) / 10,
                              backgroundColor: Colors.black.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(cPink),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Active Controls
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cBlue.withOpacity(0.3)),
                            ),
                            child: _buildControlsForStep(),
                          ),

                          const SizedBox(height: 24),

                          // Console Log
                          Text(
                            t('console_log'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStepLog(),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        t('footer'),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white54,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingMissionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cPanel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cPink.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cPink,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${t('step').toUpperCase()} ${currentStep + 1}/10",
                style: TextStyle(
                  fontSize: 10,
                  color: cPink,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildControlsForStep(),
        ],
      ),
    );
  }

  Widget _buildControlsForStep() {
    switch (currentStep) {
      case 0:
        return _buildInstruction(t('click_bottom_rung'), cPink);
      case 1:
        return _buildInstruction(t('click_space_first_rungs'), cBlue);
      case 2:
        return _buildInstruction(t('select_target_slot'), Colors.white);
      case 3:
        return Column(
          children: [
            Text(
              t('select_correct_formula'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildFormulaBtn("a_n = a + nd", false),
            _buildFormulaBtn("a_n = a + (n-1)d", true),
            _buildFormulaBtn("a_n = a - nd", false),
          ],
        );
      case 4:
        return Column(
          children: [
            Text(
              t('how_many_gaps'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: nMinus1SliderValue,
              min: 0,
              max: 20,
              divisions: 20,
              activeColor: cPink,
              label: nMinus1SliderValue.round().toString(),
              onChanged: (val) {
                setState(() {
                  nMinus1SliderValue = val;
                });
              },
            ),
            Text(
              nMinus1SliderValue.round().toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cPink,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: nMinus1SliderValue == 19
                  ? () {
                      playMathClick();
                      _showToast(t('toast_correct_n1'), cGreen);
                      _nextStep();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cPink,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: Text(t('confirm')),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            Text(
              t('click_variables'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cPink,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 8,
              children: [
                _buildVarChip('a', '10'),
                _buildVarChip('n', '19'),
                _buildVarChip('d', '5'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 8,
                children: [
                  const Text(
                    "a_20 = ",
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                  _buildSlot('a'),
                  const Text(" + (", style: TextStyle(fontFamily: 'monospace')),
                  _buildSlot('n'),
                  const Text(")", style: TextStyle(fontFamily: 'monospace')),
                  _buildSlot('d'),
                ],
              ),
            ),
          ],
        );
      case 6:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
                  children: [
                    const TextSpan(text: "10 + "),
                    TextSpan(
                      text: "(19)(5)",
                      style: TextStyle(
                        color: cPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                playMathClick();
                _showToast(t('toast_gap_height'), cGreen);
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(t('compute_gaps')),
            ),
          ],
        );
      case 7:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
                  children: [
                    const TextSpan(text: "10 + "),
                    TextSpan(
                      text: "95",
                      style: TextStyle(
                        color: cGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                playMathClick();
                _showToast(t('toast_total_height'), cGreen);
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cGreen,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(t('add_base_height')),
            ),
          ],
        );
      case 8:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cGreen.withOpacity(0.2),
                border: Border.all(color: cGreen.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "a_20 = 105 ft",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                playMathClick();
                setState(() {
                  droneLaunched = true;
                });
                _droneController.forward().then((_) {
                  _showToast(t('toast_sim_matches'), cGreen);
                  Future.delayed(const Duration(seconds: 2), _nextStep);
                });
              },
              icon: const Icon(Icons.flight_takeoff),
              label: Text(t('launch_drone')),
              style: ElevatedButton.styleFrom(
                backgroundColor: cPink,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
      case 9:
        return Column(
          children: [
            Text(
              t('depth_of_10th'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descentController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "-?",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (descentController.text.trim() == "-45") {
                  playMathSuccess();
                  _showToast(t('toast_activity_complete'), cGreen);

                  // Animate drone down
                  _droneAnimation =
                      Tween<double>(begin: _droneCurrentY, end: -45).animate(
                        CurvedAnimation(
                          parent: _droneController..reset(),
                          curve: Curves.easeInOut,
                        ),
                      )..addListener(() {
                        setState(() {
                          _droneCurrentY = _droneAnimation.value;
                        });
                      });
                  _droneController.forward().then((_) {
                    setState(() {
                      isActivityComplete = true;
                    });
                  });
                } else {
                  playMathError();
                  _showToast(t('toast_try_again'), Colors.redAccent);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(t('submit')),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildInstruction(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 10)],
        ),
      ),
    );
  }

  Widget _buildFormulaBtn(String formula, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (isCorrect) {
              playMathClick();
              _showToast(t('toast_formula_loaded'), cGreen);
              _nextStep();
            } else {
              playMathError();
              _showToast(t('toast_incorrect_formula'), Colors.redAccent);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.white24),
            ),
            elevation: 0,
          ),
          child: Text(
            formula,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildVarChip(String id, String val) {
    bool used = slotsFilled[id]!;
    return GestureDetector(
      onTap: used
          ? null
          : () {
              playMathClick();
              setState(() {
                slotsFilled[id] = true;
              });
              if (slotsFilled.values.every((v) => v)) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showToast(t('toast_equation_ready'), cGreen);
                  _nextStep();
                });
              }
            },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: used ? Colors.grey.shade800 : cBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          "$id ($val)",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: used ? Colors.white54 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(String id) {
    bool filled = slotsFilled[id]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? cGreen.withOpacity(0.2) : Colors.black.withOpacity(0.3),
        border: Border.all(
          color: filled ? cGreen : Colors.white54,
          style: filled ? BorderStyle.solid : BorderStyle.none,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        filled
            ? (id == 'a'
                  ? '10'
                  : id == 'n'
                  ? '19'
                  : '5')
            : (id == 'n' ? 'n-1' : id),
        style: TextStyle(
          color: filled ? cGreen : Colors.white54,
          fontWeight: filled ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildStepLog() {
    List<String> stepsText = [
      t('log_1'),
      t('log_2'),
      t('log_3'),
      t('log_4'),
      t('log_5'),
      t('log_6'),
      t('log_7'),
      t('log_8'),
      t('log_9'),
      t('log_10'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(stepsText.length, (index) {
        bool isActive = index == currentStep;
        bool isCompleted = index < currentStep;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? cPink.withOpacity(0.1)
                : Colors.white.withOpacity(0.03),
            border: Border(
              left: BorderSide(
                color: isActive
                    ? cPink
                    : isCompleted
                    ? cGreen
                    : Colors.transparent,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            stepsText[index],
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? cPink
                  : isCompleted
                  ? Colors.white54
                  : Colors.white30,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSuccessModal() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: cPanel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cGreen),
              boxShadow: [
                BoxShadow(
                  color: cGreen.withOpacity(0.2),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: cGreen, size: 80),
                const SizedBox(height: 16),
                Text(
                  t('safety_cert'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t('activity_complete'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _resetActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    t('new_project'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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

// Background Grid Drawer
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
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
