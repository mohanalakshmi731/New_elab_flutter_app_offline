// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui';

// --- GLOBAL AUDIO ENGINE ---
// Dedicated audio players
final AudioPlayer _clickPlayer = AudioPlayer();
final AudioPlayer _successPlayer = AudioPlayer();
final AudioPlayer _errorPlayer = AudioPlayer();
final AudioPlayer _shutterPlayer = AudioPlayer();

// Local audio assets (assets/audio/class9/)
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter requested

// Web-safe playback helper - Stops previous overlapping track and plays fresh
void _playSound(AudioPlayer player, String url) async {
  try {
    await player.stop();
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio Playback Error: $e");
  }
}
// ---------------------------

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'IDENTITY CRISIS',
    'app_subtitle': 'CLASS 9 • POLYNOMIALS',
    'btn_start_lab': 'Launch Simulation',
    'btn_reset': 'Reboot System',
    'btn_proceed': 'PROCEED',
    'btn_restart': 'RESTART SIMULATION',
    'sys_reset': 'System Reset',
    'lbl_step': 'Step',
    'lbl_proof': 'VISUAL PROOF',
    'lbl_parts': 'AVAILABLE PARTS',
    'msg_stable': 'BRIDGE STABLE!',
    'msg_cleared': 'TRAFFIC CLEARED',
    'msg_testing': 'TESTING BRIDGE INTEGRITY...',
    'lbl_sys_status': 'SYSTEM STATUS',
    'lbl_objective': 'OBJECTIVE',
    'err_logic': 'Logic Error!',
    'err_mismatch': 'Structural Mismatch!',
    'err_calc': 'Calculation Error!',
    'opt_rat': 'Rational',
    'opt_irr': 'Irrational',
    'opt_yes': 'YES',
    'opt_no': 'NO',
    
    // Step Data Translations
    'ph_1': 'PHASE 1: FOUNDATION',
    'title_1': 'Engineering Briefing',
    'instr_1': 'The bridge is broken. Initialize the Canvas to analyze the debris field.',
    'act_1': 'Initialize Canvas',
    'proof_1': 'Systems Online',
    'psub_1': 'Analysis complete. Prepare for reconstruction.',
    
    'title_2': 'The Square Foundation',
    'instr_2': 'Reconstruct the area model for (x+y)². Drag the blocks into the grid.',
    'proof_2': '(x+y)² = x² + 2xy + y²',
    'psub_2': 'Area = Length × Width',
    
    'title_3': 'Substructure Stability',
    'instr_3': 'Next segment has a negative load. Complete the grid for (x-y)².',
    'proof_3': '(x-y)² = x² - 2xy + y²',
    'psub_3': 'Negative Mixed Terms',
    
    'ph_2': 'PHASE 2: ADVANCED',
    'title_4': 'Difference of Squares',
    'instr_4': 'Vertical support needed. Build the grid for (x+y)(x-y).',
    'proof_4': '(x+y)(x-y) = x² - y²',
    'psub_4': 'Notice how the positive and negative mixed terms cancel out.',
    
    'title_5': 'Variable Pathing',
    'instr_5': 'Connect the variable paths. Fill the grid for (x+a)(x+b).',
    'proof_5': '(x+a)(x+b) = x² + (a+b)x + ab',
    'psub_5': 'Sum of constants goes with x, product stands alone.',
    
    'ph_3': 'PHASE 3: MASTER CLASS',
    'title_6': 'Trinomial Expansion',
    'instr_6': 'Mega-Span Gap. Complete the 3x3 grid for (x+y+z)².',
    'proof_6': '(x+y+z)² = x² + y² + z² + 2xy + 2yz + 2zx',
    'psub_6': '3 squares and 6 mixed rectangles.',
    
    'ph_4': 'PHASE 4: APPLICATION',
    'title_7': 'Heavy Load Test',
    'instr_7': 'A 11130kg truck approaches. Calculate 105 × 106.',
    'proof_7': '10000 + 600 + 500 + 30 = 11130',
    'psub_7': 'Applying (x+a)(x+b) for mental math.',
    
    'title_8': 'Compression Check',
    'instr_8': 'Reconstruct the square grid for (2x+3y)².',
    'proof_8': '4x² + 12xy + 9y² = (2x+3y)²',
    'psub_8': 'Reverse Engineering the identity.',
    
    'title_9': 'Logic Glitch: Pi',
    'instr_9': 'System Error. Is π rational or irrational?',
    'proof_9': 'π is an Irrational Number',
    'psub_9': 'Decimal representation never settles into a repeating pattern.',
    
    'ph_5': 'PHASE 5: GRAND OPENING',
    'title_10': 'Final Inspection',
    'instr_10': 'Bridge integrity 100%. Is an algebraic identity true for ALL values?',
    'proof_10': 'Structure Certified',
    'psub_10': 'An identity must hold true universally.',
  },
  'hi': {
    'app_title': 'पहचान संकट',
    'app_subtitle': 'कक्षा 9 • बहुपद',
    'btn_start_lab': 'सिमुलेशन शुरू करें',
    'btn_reset': 'सिस्टम रीबूट करें',
    'btn_proceed': 'आगे बढ़ें',
    'btn_restart': 'सिमुलेशन पुनरारंभ करें',
    'sys_reset': 'सिस्टम रीसेट',
    'lbl_step': 'कदम',
    'lbl_proof': 'दृश्य प्रमाण',
    'lbl_parts': 'उपलब्ध हिस्से',
    'msg_stable': 'पुल स्थिर है!',
    'msg_cleared': 'यातायात साफ़',
    'msg_testing': 'पुल की अखंडता का परीक्षण...',
    'lbl_sys_status': 'सिस्टम स्थिति',
    'lbl_objective': 'उद्देश्य',
    'err_logic': 'तर्क त्रुटि!',
    'err_mismatch': 'संरचनात्मक बेमेल!',
    'err_calc': 'गणना त्रुटि!',
    'opt_rat': 'परिमेय',
    'opt_irr': 'अपरिमेय',
    'opt_yes': 'हाँ',
    'opt_no': 'नहीं',

    // Step Data Translations
    'ph_1': 'चरण 1: आधार',
    'title_1': 'इंजीनियरिंग ब्रीफिंग',
    'instr_1': 'पुल टूट गया है। मलबे का विश्लेषण करने के लिए कैनवास प्रारंभ करें।',
    'act_1': 'कैनवास प्रारंभ करें',
    'proof_1': 'सिस्टम ऑनलाइन',
    'psub_1': 'विश्लेषण पूरा हुआ। पुनर्निर्माण के लिए तैयार रहें।',
    
    'title_2': 'वर्गाकार आधार',
    'instr_2': '(x+y)² के लिए क्षेत्र मॉडल का पुनर्निर्माण करें। ब्लॉक को ग्रिड में खींचें।',
    'proof_2': '(x+y)² = x² + 2xy + y²',
    'psub_2': 'क्षेत्रफल = लंबाई × चौड़ाई',
    
    'title_3': 'उपसंरचना स्थिरता',
    'instr_3': 'अगले खंड में नकारात्मक भार है। (x-y)² के लिए ग्रिड पूरा करें।',
    'proof_3': '(x-y)² = x² - 2xy + y²',
    'psub_3': 'नकारात्मक मिश्रित पद',
    
    'ph_2': 'चरण 2: उन्नत',
    'title_4': 'वर्गों का अंतर',
    'instr_4': 'लंबवत समर्थन की आवश्यकता है। (x+y)(x-y) के लिए ग्रिड बनाएं।',
    'proof_4': '(x+y)(x-y) = x² - y²',
    'psub_4': 'ध्यान दें कि धनात्मक और ऋणात्मक मिश्रित पद कैसे कट जाते हैं।',
    
    'title_5': 'परिवर्तनीय पथ',
    'instr_5': 'परिवर्तनीय पथों को कनेक्ट करें। (x+a)(x+b) के लिए ग्रिड भरें।',
    'proof_5': '(x+a)(x+b) = x² + (a+b)x + ab',
    'psub_5': 'स्थिरांकों का योग x के साथ जाता है, गुणनफल अकेला रहता है।',
    
    'ph_3': 'चरण 3: मास्टर क्लास',
    'title_6': 'त्रिपद विस्तार',
    'instr_6': 'मेगा-स्पैन गैप। (x+y+z)² के लिए 3x3 ग्रिड पूरा करें।',
    'proof_6': '(x+y+z)² = x² + y² + z² + 2xy + 2yz + 2zx',
    'psub_6': '3 वर्ग और 6 मिश्रित आयत।',
    
    'ph_4': 'चरण 4: अनुप्रयोग',
    'title_7': 'भारी भार परीक्षण',
    'instr_7': '11130kg का एक ट्रक आ रहा है। 105 × 106 की गणना करें।',
    'proof_7': '10000 + 600 + 500 + 30 = 11130',
    'psub_7': 'मानसिक गणित के लिए (x+a)(x+b) लागू करना।',
    
    'title_8': 'संपीड़न जांच',
    'instr_8': '(2x+3y)² के लिए वर्गाकार ग्रिड का पुनर्निर्माण करें।',
    'proof_8': '4x² + 12xy + 9y² = (2x+3y)²',
    'psub_8': 'सर्वसमिका की रिवर्स इंजीनियरिंग।',
    
    'title_9': 'लॉजिक ग्लिच: पाई',
    'instr_9': 'सिस्टम त्रुटि। क्या π परिमेय है या अपरिमेय?',
    'proof_9': 'π एक अपरिमेय संख्या है',
    'psub_9': 'दशमलव निरूपण कभी भी दोहराए जाने वाले पैटर्न में नहीं आता है।',
    
    'ph_5': 'चरण 5: भव्य उद्घाटन',
    'title_10': 'अंतिम निरीक्षण',
    'instr_10': 'पुल की अखंडता 100%। क्या एक बीजगणितीय सर्वसमिका सभी मानों के लिए सत्य है?',
    'proof_10': 'संरचना प्रमाणित',
    'psub_10': 'एक सर्वसमिका सार्वभौमिक रूप से सत्य होनी चाहिए।',
  }
};

void main() {
  runApp(const IdentityCrisisApp());
}

class IdentityCrisisApp extends StatelessWidget {
  const IdentityCrisisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identity Crisis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1B4B),
        fontFamily: 'monospace',
      ),
      home: const IdentityCrisisScreen(),
    );
  }
}

// --- CORE APP SCREEN ---
class IdentityCrisisScreen extends StatefulWidget {
  const IdentityCrisisScreen({super.key});

  @override
  State<IdentityCrisisScreen> createState() => _IdentityCrisisScreenState();
}

class _IdentityCrisisScreenState extends State<IdentityCrisisScreen> with TickerProviderStateMixin {
  // Theme Colors
  final Color bgTheme = const Color(0xFF1E1B4B);
  final Color panelColor = const Color(0xFF131130);
  final Color accentTheme = const Color(0xFFFACC15);
  final Color primaryTheme = const Color(0xFF38BDF8);
  final Color successTheme = const Color(0xFF4ADE80);
  final Color errorTheme = const Color(0xFFF43F5E);

  String _currentLang = 'en';
  int appStep = 0;
  Map<int, String> currentGridState = {};
  
  bool _sidebarOpen = true;
  bool _showShutter = true;
  bool _isStepTransitioning = false; // Controls the disappearance of the HUD during transitions

  late AnimationController _pulseController;
  late AnimationController _truckController;

  String t(String key) => i18n[_currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    // Enforce Landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Immersive Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    // Revert to Portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Revert System UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _pulseController.dispose();
    _truckController.dispose();

    super.dispose();
  }

  void _handleSuccess() {
    HapticFeedback.heavyImpact();
    _playSound(_successPlayer, _successUrl);

    setState(() {
      _isStepTransitioning = true; // Instantly hide the floating HUD/Sidebar focus
      currentGridState.clear();
      appStep++; // Immediately advance step so the bridge segment turns solid
      
      if (appStep >= labData.length) {
        _truckController.forward();
      }
    });

    // Extended 4.5s delay on final step allows truck to fully cross before showing overlay
    int delayMs = (appStep >= labData.length) ? 4500 : 2500;
    
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _isStepTransitioning = false; // Reveal HUD for the new step (or full screen overlay)
        });
      }
    });
  }

  void checkGridCompletion(GridConfig config) {
    if (currentGridState.length == config.slots.length) {
      bool allCorrect = true;
      for (int i = 0; i < config.slots.length; i++) {
        if (currentGridState[i] != config.slots[i].answer) {
          allCorrect = false;
          break;
        }
      }
      if (allCorrect) {
        _handleSuccess();
      }
    }
  }

  void resetApp() {
    setState(() {
      appStep = 0;
      currentGridState.clear();
      _isStepTransitioning = false;
      _truckController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    // Exactly 38% Sidebar Width
    double sidebarWidth = screenW * 0.38;

    return Scaffold(
      backgroundColor: bgTheme,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expandable Sidebar Container
                // By using SingleChildScrollView horizontally, it prevents overflow bounds issues during animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: panelColor,
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

                // Center Activity (Responsive Workspace)
                Expanded(
                  child: _buildWorkspace(screenW),
                ),
              ],
            ),

            // Top Left Menu Button (Z-Index Front)
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            // Final Simulation Complete Overlay (Full Screen)
            if (appStep >= labData.length && !_isStepTransitioning && !_showShutter)
              _buildCompleteOverlay(),
            
            // Loading Shutter Overlay (Curtain)
            if (_showShutter) _buildLoadingShutter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spacer to push the title content completely below the floating menu icon
          const SizedBox(height: 56),

          // Title and Subtitle
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
              color: primaryTheme,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Settings Row: Toggle & Reset Button on the SAME LINE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentTheme.withOpacity(0.3)),
                ),
                child: Row(children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: errorTheme.withOpacity(0.6),
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.power_settings_new, color: errorTheme),
                  tooltip: t('btn_reset'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() {
                      _showShutter = true;
                    });
                    resetApp();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress HUD
          _buildProgressHUD(),
          const SizedBox(height: 16),

          // Build/Journal Content (Directly stacked inside the scroll column)
          _buildJournal(),

          const SizedBox(height: 32),

          // Footer
          const Center(
            child: Text(
              "© ZEROSCIENCELAB | Fall in Love with Math and Science",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    bool active = _currentLang == code;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
        setState(() => _currentLang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? accentTheme : Colors.transparent,
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
    double progress = (appStep / 10).clamp(0.0, 1.0);
    String phase = appStep < labData.length ? t(labData[appStep].phaseKey) : t('msg_stable');
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
                  style: TextStyle(color: accentTheme, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${t('lbl_step')} ${math.min(appStep + 1, 10)}/10', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: accentTheme,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildJournal() {
    if (appStep >= labData.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFACC15)),
              const SizedBox(height: 24),
              Text(
                t('msg_testing'),
                style: TextStyle(color: accentTheme, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appStep + 1,
      itemBuilder: (context, index) {
        bool isActive = index == appStep;
        LabStep stepData = labData[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? accentTheme.withOpacity(0.05) : Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? accentTheme : (index < appStep ? successTheme : Colors.white10),
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
                      color: isActive ? accentTheme : (index < appStep ? successTheme : Colors.white24),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('${stepData.id}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t(stepData.titleKey),
                      style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  if (index < appStep) Icon(Icons.check, color: successTheme, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(t(stepData.instrKey), style: const TextStyle(color: Colors.white60, fontSize: 14)),
              
              if (isActive && !_isStepTransitioning) ...[
                const SizedBox(height: 16),
                // VERTICAL Stacking for Sidebar Content
                _buildInteractiveArea(stepData),
                if (stepData.debris.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDebrisField(stepData.debris),
                ]
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveArea(LabStep step) {
    if (step.type == StepType.action) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTheme,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: _handleSuccess,
        child: Text(t(step.actionBtnKey), style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    } else if (step.type == StepType.gridPuzzle) {
      return _buildGridPuzzle(step.gridConfig!);
    } else if (step.type == StepType.calc) {
      return _buildCalcBox(step.targetVal!);
    } else if (step.type == StepType.choice) {
      return Row(
        children: step.options!.map((opt) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryTheme,
                  side: BorderSide(color: primaryTheme),
                ),
                onPressed: () {
                  if (opt.correct) {
                    _handleSuccess();
                  } else {
                    HapticFeedback.vibrate();
                    _playSound(_errorPlayer, _errorUrl);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('err_logic')), backgroundColor: errorTheme));
                  }
                },
                child: FittedBox(fit: BoxFit.scaleDown, child: Text(t(opt.textKey), style: const TextStyle(fontSize: 12))),
              ),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox();
  }

  Widget _buildGridPuzzle(GridConfig config) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.cols,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: config.cols >= 3 ? 1.8 : 2.4, // Prevents vertical overflow for 3x3 grids
      ),
      itemCount: config.slots.length,
      itemBuilder: (context, index) {
        String? filledData = currentGridState[index];
        GridSlot slotData = config.slots[index];

        return DragTarget<String>(
          onWillAcceptWithDetails: (details) => filledData == null,
          onAcceptWithDetails: (details) {
            if (details.data == slotData.answer) {
              HapticFeedback.selectionClick();
              _playSound(_clickPlayer, _clickUrl); // Placement click
              setState(() { currentGridState[index] = details.data; });
              checkGridCompletion(config);
            } else {
              HapticFeedback.vibrate();
              _playSound(_errorPlayer, _errorUrl); // Error buzzer
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('err_mismatch')), backgroundColor: errorTheme));
            }
          },
          builder: (context, candidateData, rejectedData) {
            bool isHovered = candidateData.isNotEmpty;
            return Container(
              decoration: BoxDecoration(
                // Distinct visible background for empty drag zones
                color: filledData != null ? slotData.color.withOpacity(0.8) : (isHovered ? Colors.white30 : const Color(0xFF2A2A3D)),
                border: Border.all(
                  // Visible border for empty zones
                  color: filledData != null ? slotData.color : (isHovered ? accentTheme : Colors.white54),
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    filledData ?? (isHovered ? '?' : ''),
                    style: TextStyle(
                      color: filledData != null ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalcBox(int targetVal) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (val) {
                if (int.tryParse(val) == targetVal) {
                  _handleSuccess();
                } else {
                  HapticFeedback.vibrate();
                  _playSound(_errorPlayer, _errorUrl);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('err_calc')), backgroundColor: errorTheme));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebrisField(List<String> debris) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent, // Match screenshot styling
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(t('lbl_parts'), style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.touch_app, color: primaryTheme, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: debris.toSet().map((term) {
              return Draggable<String>(
                data: term,
                feedback: Material(
                  color: Colors.transparent,
                  child: _debrisWidget(term, isDragging: true),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: _debrisWidget(term)),
                onDragStarted: () {
                  HapticFeedback.selectionClick();
                },
                child: _debrisWidget(term),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _debrisWidget(String text, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primaryTheme.withOpacity(0.1),
        border: Border.all(color: primaryTheme.withOpacity(0.6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging ? [BoxShadow(color: primaryTheme.withOpacity(0.5), blurRadius: 10)] : [],
      ),
      child: Text(
        text, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
      ),
    );
  }

  Widget _buildWorkspace(double screenW) {
    return Stack(
      children: [
        // Bridge Visualizer Area
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _truckController]),
            builder: (context, child) {
              return CustomPaint(
                painter: BridgePainter(
                  currentStep: appStep,
                  pulse: _pulseController.value,
                  truckProgress: _truckController.value,
                ),
                child: Container(),
              );
            },
          ),
        ),

        // Closed Sidebar HUD - Automatically hidden during transitions
        if (!_sidebarOpen && !_showShutter && !_isStepTransitioning) ...[
          _buildFloatingHUD(screenW),
        ]
      ],
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    if (appStep >= labData.length) {
      return const SizedBox.shrink(); // Avoid drawing floating HUD on final complete state
    }

    LabStep step = labData[appStep];
    
    // Dynamic width calculation that expands significantly for 3x3 grids
    bool isLargeGrid = step.gridConfig != null && step.gridConfig!.cols >= 3;
    double hudWidth = step.debris.isNotEmpty 
        ? math.min(screenW * 0.92, isLargeGrid ? 900.0 : 750.0) 
        : math.min(screenW * 0.45, 450.0);

    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
          width: hudWidth, // Adapts width depending on step content
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border(top: BorderSide(color: primaryTheme, width: 4)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t(step.phaseKey), style: TextStyle(color: accentTheme, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(t(step.titleKey), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(t(step.instrKey), style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                
                // Side-by-Side Horizontal Layout to completely prevent vertical stretching!
                if (step.debris.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isLargeGrid ? 6 : 5, // Give 3x3 grids slightly more room
                        child: _buildInteractiveArea(step),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildDebrisField(step.debris),
                      ),
                    ],
                  )
                else
                  _buildInteractiveArea(step),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            // FIX: Added SingleChildScrollView to prevent vertical overflow on small landscape screens
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                // FIX: Reduced padding slightly to save vertical space
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: bgTheme,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: successTheme, width: 2),
                  boxShadow: [
                    BoxShadow(color: successTheme.withOpacity(0.2), blurRadius: 80),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FIX: Reduced icon size from 80 to 64
                    Icon(Icons.verified, color: successTheme, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      t('msg_stable'),
                      style: TextStyle(
                        color: successTheme,
                        fontSize: 28, // Scaled down slightly
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
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
                        backgroundColor: primaryTheme,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _playSound(_shutterPlayer, _shutterUrl);
                        setState(() {
                          _showShutter = true;
                        });
                        resetApp();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        t('btn_restart'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildLoadingShutter() {
    return Container(
      color: bgTheme,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryTheme, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: primaryTheme.withOpacity(0.5),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              t('app_title').toUpperCase(),
              style: TextStyle(
                color: accentTheme,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('app_subtitle').toUpperCase(),
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 3,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTheme,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_shutterPlayer, _shutterUrl); // Powerful Start Sound Effect
                setState(() {
                  _showShutter = false;
                });
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                t('btn_start_lab').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BRIDGE VISUALIZER PAINTER ---
class BridgePainter extends CustomPainter {
  final int currentStep;
  final double pulse;
  final double truckProgress;

  BridgePainter({required this.currentStep, required this.pulse, required this.truckProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = const Color(0xFF0F0518);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }

    final double bridgeY = size.height * 0.6;
    final double bridgeThickness = 20.0;
    final double leftCliffEnd = size.width * 0.15;
    final double rightCliffStart = size.width * 0.85;
    final double gapWidth = rightCliffStart - leftCliffEnd;
    final double segmentWidth = gapWidth / 10;

    final Paint cliffPaint = Paint()..color = const Color(0xFF2D3748);
    // Left Cliff
    canvas.drawRect(Rect.fromLTWH(0, bridgeY, leftCliffEnd, size.height - bridgeY), cliffPaint);
    // Right Cliff
    canvas.drawRect(Rect.fromLTWH(rightCliffStart, bridgeY, size.width - rightCliffStart, size.height - bridgeY), cliffPaint);

    final Paint solidSegment = Paint()..color = const Color(0xFF38BDF8);
    final Paint glowSegment = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.4 + (pulse * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw Segments
    for (int i = 0; i < 10; i++) {
      double segX = leftCliffEnd + (i * segmentWidth);
      Rect segRect = Rect.fromLTWH(segX + 2, bridgeY, segmentWidth - 4, bridgeThickness);

      if (i < currentStep) {
        canvas.drawRect(segRect, solidSegment);
      } else if (i == currentStep) {
        canvas.drawRect(segRect, glowSegment);
      }
    }

    // Draw Truck (NEW UI)
    if (currentStep >= 10) {
      double truckX = leftCliffEnd + (gapWidth * truckProgress) - 80;
      
      // Trailer Cargo
      final Paint trailerPaint = Paint()..color = const Color(0xFFE2E8F0); // Light steel
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(truckX, bridgeY - 45, 55, 40), const Radius.circular(4)), 
        trailerPaint
      );
      
      // Truck Cab
      final Paint cabPaint = Paint()..color = const Color(0xFFFACC15); // Yellow cab
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(truckX + 58, bridgeY - 32, 22, 27), const Radius.circular(4)), 
        cabPaint
      );
      
      // Cab Window
      final Paint windowPaint = Paint()..color = const Color(0xFF38BDF8); // Cyan window
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(truckX + 66, bridgeY - 28, 10, 10), const Radius.circular(2)), 
        windowPaint
      );
      
      // Wheels
      final Paint wheelPaint = Paint()..color = const Color(0xFF1E293B);
      final Paint wheelRim = Paint()..color = Colors.grey..style = PaintingStyle.stroke..strokeWidth = 2;
      
      void drawWheel(double x, double y) {
        canvas.drawCircle(Offset(x, y), 8, wheelPaint);
        canvas.drawCircle(Offset(x, y), 4, wheelRim);
      }
      
      drawWheel(truckX + 12, bridgeY - 5);
      drawWheel(truckX + 42, bridgeY - 5);
      drawWheel(truckX + 68, bridgeY - 5);
    }
  }

  @override
  bool shouldRepaint(covariant BridgePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep || oldDelegate.pulse != pulse || oldDelegate.truckProgress != truckProgress;
  }
}

// --- DATA MODELS & CONTENT ---
enum StepType { action, gridPuzzle, calc, choice }

class ChoiceOpt {
  final String textKey;
  final bool correct;
  ChoiceOpt(this.textKey, this.correct);
}

class GridSlot {
  final String answer; // Math notation, does not need translation
  final Color color;
  GridSlot(this.answer, this.color);
}

class GridConfig {
  final int cols;
  final List<GridSlot> slots;
  GridConfig(this.cols, this.slots);
}

class LabStep {
  final int id;
  final String phaseKey;
  final String titleKey;
  final String instrKey;
  final StepType type;
  final String actionBtnKey;
  final List<String> debris; // Math terms
  final GridConfig? gridConfig;
  final int? targetVal;
  final List<ChoiceOpt>? options;
  final String proofTextKey;
  final String proofSubtextKey;

  LabStep({
    required this.id,
    required this.phaseKey,
    required this.titleKey,
    required this.instrKey,
    required this.type,
    this.actionBtnKey = '',
    this.debris = const [],
    this.gridConfig,
    this.targetVal,
    this.options,
    required this.proofTextKey,
    required this.proofSubtextKey,
  });
}

// Data Definition mapped to i18n
final List<LabStep> labData = [
  LabStep(
    id: 1,
    phaseKey: "ph_1",
    titleKey: "title_1",
    instrKey: "instr_1",
    type: StepType.action,
    actionBtnKey: "act_1",
    proofTextKey: "proof_1",
    proofSubtextKey: "psub_1",
  ),
  LabStep(
    id: 2,
    phaseKey: "ph_1",
    titleKey: "title_2",
    instrKey: "instr_2",
    type: StepType.gridPuzzle,
    gridConfig: GridConfig(2, [
      GridSlot("x²", Colors.blue), GridSlot("xy", Colors.green),
      GridSlot("xy", Colors.green), GridSlot("y²", Colors.orange)
    ]),
    debris: ["x²", "xy", "y²"],
    proofTextKey: "proof_2",
    proofSubtextKey: "psub_2",
  ),
  LabStep(
    id: 3,
    phaseKey: "ph_1",
    titleKey: "title_3",
    instrKey: "instr_3",
    type: StepType.gridPuzzle,
    gridConfig: GridConfig(2, [
      GridSlot("x²", Colors.blue), GridSlot("-xy", Colors.red),
      GridSlot("-xy", Colors.red), GridSlot("y²", Colors.orange)
    ]),
    debris: ["x²", "y²", "-xy", "2xy"],
    proofTextKey: "proof_3",
    proofSubtextKey: "psub_3",
  ),
  LabStep(
    id: 4,
    phaseKey: "ph_2",
    titleKey: "title_4",
    instrKey: "instr_4",
    type: StepType.gridPuzzle,
    gridConfig: GridConfig(2, [
      GridSlot("x²", Colors.blue), GridSlot("-xy", Colors.red),
      GridSlot("+xy", Colors.green), GridSlot("-y²", Colors.red)
    ]),
    debris: ["x²", "-xy", "+xy", "-y²", "y²"],
    proofTextKey: "proof_4",
    proofSubtextKey: "psub_4",
  ),
  LabStep(
    id: 5,
    phaseKey: "ph_2",
    titleKey: "title_5",
    instrKey: "instr_5",
    type: StepType.gridPuzzle,
    gridConfig: GridConfig(2, [
      GridSlot("x²", Colors.indigo), GridSlot("bx", Colors.pink),
      GridSlot("ax", Colors.pink), GridSlot("ab", Colors.deepOrange)
    ]),
    debris: ["x²", "ax", "bx", "ab", "a²"],
    proofTextKey: "proof_5",
    proofSubtextKey: "psub_5",
  ),
  LabStep(
    id: 6,
    phaseKey: "ph_3",
    titleKey: "title_6",
    instrKey: "instr_6",
    type: StepType.gridPuzzle,
    gridConfig: GridConfig(3, [
      GridSlot("x²", Colors.blue), GridSlot("xy", Colors.green), GridSlot("zx", Colors.purple),
      GridSlot("xy", Colors.green), GridSlot("y²", Colors.orange), GridSlot("yz", Colors.red),
      GridSlot("zx", Colors.purple), GridSlot("yz", Colors.red), GridSlot("z²", Colors.deepOrange),
    ]),
    debris: ["x²", "y²", "z²", "xy", "yz", "zx", "2xy"],
    proofTextKey: "proof_6",
    proofSubtextKey: "psub_6",
  ),
  LabStep(
    id: 7,
    phaseKey: "ph_4",
    titleKey: "title_7",
    instrKey: "instr_7",
    type: StepType.calc,
    targetVal: 11130,
    proofTextKey: "proof_7",
    proofSubtextKey: "psub_7",
  ),
  LabStep(
    id: 8,
    phaseKey: "ph_4",
    titleKey: "title_8",
    instrKey: "instr_8",
    type: StepType.gridPuzzle,
    gridConfig: GridConfig(2, [
      GridSlot("4x²", Colors.blue), GridSlot("6xy", Colors.teal),
      GridSlot("6xy", Colors.teal), GridSlot("9y²", Colors.orange)
    ]),
    debris: ["4x²", "6xy", "9y²", "2x"],
    proofTextKey: "proof_8",
    proofSubtextKey: "psub_8",
  ),
  LabStep(
    id: 9,
    phaseKey: "ph_4",
    titleKey: "title_9",
    instrKey: "instr_9",
    type: StepType.choice,
    options: [ChoiceOpt("opt_rat", false), ChoiceOpt("opt_irr", true)],
    proofTextKey: "proof_9",
    proofSubtextKey: "psub_9",
  ),
  LabStep(
    id: 10,
    phaseKey: "ph_5",
    titleKey: "title_10",
    instrKey: "instr_10",
    type: StepType.choice,
    options: [ChoiceOpt("opt_yes", true), ChoiceOpt("opt_no", false)],
    proofTextKey: "proof_10",
    proofSubtextKey: "psub_10",
  ),
];