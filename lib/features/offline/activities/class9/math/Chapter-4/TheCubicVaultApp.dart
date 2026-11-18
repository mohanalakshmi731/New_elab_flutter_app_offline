// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui';

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

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE CUBIC VAULT',
    'app_subtitle': 'CLASS 9 • POLYNOMIALS (Visual)',
    'btn_start_lab': 'Initialize Vault',
    'btn_reset': 'Reboot System',
    'btn_proceed': 'PROCEED',
    'btn_restart': 'RESTART SIMULATION',
    'lbl_step': 'Step',
    'lbl_proof': 'VISUAL ANALYSIS',
    'lbl_parts': 'AVAILABLE CARGO',
    'msg_stable': 'VAULT SEALED!',
    'msg_cleared': 'VOLUME VERIFIED',
    'lbl_sys_status': 'VAULT STATUS',
    'err_logic': 'Incorrect Logic!',
    'err_mismatch': 'Structural Mismatch!',
    'err_calc': 'Incorrect. Formula is (a+b)³',
    
    // Step Data Translations
    'ph_setup': 'SETUP',
    'ph_construct': 'CONSTRUCTION',
    'ph_analyze': 'ANALYSIS',
    'ph_apply': 'APPLICATION',
    'ph_conclude': 'CONCLUSION',
    
    'title_1': 'Define Specs',
    'instr_1': 'Set the dimensions for the Main Core (a) and Extension (b).',
    'act_1': 'Initialize Blueprint',
    
    'title_2': 'Load The Core',
    'instr_2': 'Place the main reactor core (a³) at the origin.',
    'pf_t_2': 'The Core Established',
    'pf_d_2': 'You have placed the central foundation. This is the largest single component of the volume.',
    'pf_a_2': "Like the master bedroom in a house extension - it's the biggest room you start with.",
    
    'title_3': 'Primary Expansion',
    'instr_3': 'Attach the 3 primary slabs (a²b) to the faces of the core.',
    'pf_t_3': 'Surface Expansion',
    'pf_d_3': "Three slab-like extensions cover the main faces. They add thickness 'b' to the area 'a²'.",
    'pf_a_3': 'Like adding thick soundproofing panels to the walls and ceiling.',
    
    'title_4': 'Secondary Support',
    'instr_4': 'Install the 3 connector beams (ab²) to fill the edge gaps.',
    'pf_t_4': 'Edge Reinforcement',
    'pf_d_4': 'These long beams fill the gaps along the edges created by the slabs.',
    'pf_a_4': 'Think of these as the structural pillars connecting the panels together.',
    
    'title_5': 'Seal The Corner',
    'instr_5': 'Place the final keystone (b³) to seal the vault.',
    'pf_t_5': 'Corner Sealed',
    'pf_d_5': 'The final cornerstone fills the last remaining void at the very corner, completing the larger cube.',
    'pf_a_5': 'The final locking nut that secures the entire assembly.',
    
    'title_6': 'Volumetric Scan',
    'instr_6': 'Verify the total volume matches (a+b)³.',
    'act_6': 'Run Verification',
    'pf_t_6': 'Volume Verified',
    'pf_d_6': 'We have summed all component volumes to equal the total volume of the new cube.',
    'pf_a_6': 'The whole package is exactly the sum of its parts.',
    
    'title_7': 'Explosion Test',
    'instr_7': "Use the 'Explode View' toggle to inspect internal structure.",
    'act_7': 'Test Complete',
    
    'title_8': 'Numeric Check',
    'instr_8': 'If a=10 and b=2, calculate total volume. Volume formula is (a+b)³.',
    
    'title_9': 'Final Certification',
    'instr_9': 'Does (a+b)³ = a³ + b³? (Common Error Check)',
    
    'opt_yes': 'YES',
    'opt_no': 'NO',
  },
  'hi': {
    'app_title': 'क्यूबिक तिजोरी',
    'app_subtitle': 'कक्षा 9 • बहुपद (दृश्य)',
    'btn_start_lab': 'तिजोरी शुरू करें',
    'btn_reset': 'सिस्टम रीबूट करें',
    'btn_proceed': 'आगे बढ़ें',
    'btn_restart': 'सिमुलेशन पुनरारंभ करें',
    'lbl_step': 'कदम',
    'lbl_proof': 'दृश्य विश्लेषण',
    'lbl_parts': 'उपलब्ध कार्गो',
    'msg_stable': 'तिजोरी सील!',
    'msg_cleared': 'आयतन सत्यापित',
    'lbl_sys_status': 'तिजोरी की स्थिति',
    'err_logic': 'तर्क त्रुटि!',
    'err_mismatch': 'संरचनात्मक बेमेल!',
    'err_calc': 'गलत। सूत्र (a+b)³ है',
    
    // Step Data Translations
    'ph_setup': 'स्थापना',
    'ph_construct': 'निर्माण',
    'ph_analyze': 'विश्लेषण',
    'ph_apply': 'अनुप्रयोग',
    'ph_conclude': 'निष्कर्ष',
    
    'title_1': 'विनिर्देश परिभाषित करें',
    'instr_1': 'मुख्य कोर (a) और विस्तार (b) के लिए आयाम निर्धारित करें।',
    'act_1': 'ब्लूप्रिंट आरंभ करें',
    
    'title_2': 'कोर लोड करें',
    'instr_2': 'मुख्य रिएक्टर कोर (a³) को मूल पर रखें।',
    'pf_t_2': 'कोर स्थापित',
    'pf_d_2': 'आपने केंद्रीय नींव रखी है। यह आयतन का सबसे बड़ा एकल घटक है।',
    'pf_a_2': "जैसे घर के विस्तार में मास्टर बेडरूम - यह सबसे बड़ा कमरा है जिससे आप शुरुआत करते हैं।",
    
    'title_3': 'प्राथमिक विस्तार',
    'instr_3': 'कोर के चेहरों पर 3 प्राथमिक स्लैब (a²b) संलग्न करें।',
    'pf_t_3': 'सतह विस्तार',
    'pf_d_3': "तीन स्लैब जैसे विस्तार मुख्य चेहरों को कवर करते हैं। वे क्षेत्र 'a²' में मोटाई 'b' जोड़ते हैं।",
    'pf_a_3': 'जैसे दीवारों और छत पर मोटे साउंडप्रूफिंग पैनल जोड़ना।',
    
    'title_4': 'द्वितीयक समर्थन',
    'instr_4': 'किनारे के अंतराल को भरने के लिए 3 कनेक्टर बीम (ab²) स्थापित करें।',
    'pf_t_4': 'एज सुदृढीकरण',
    'pf_d_4': 'ये लंबे बीम स्लैब द्वारा बनाए गए किनारों के साथ अंतराल को भरते हैं।',
    'pf_a_4': 'इन्हें पैनलों को एक साथ जोड़ने वाले संरचनात्मक खंभों के रूप में सोचें।',
    
    'title_5': 'कोना सील करें',
    'instr_5': 'तिजोरी को सील करने के लिए अंतिम कीस्टोन (b³) रखें।',
    'pf_t_5': 'कोना सील',
    'pf_d_5': 'अंतिम आधारशिला बिल्कुल कोने में अंतिम शेष शून्य को भर देती है, जिससे बड़ा घन पूरा हो जाता है।',
    'pf_a_5': 'अंतिम लॉकिंग नट जो संपूर्ण असेंबली को सुरक्षित करता है।',
    
    'title_6': 'वॉल्यूमेट्रिक स्कैन',
    'instr_6': 'सत्यापित करें कि कुल आयतन (a+b)³ से मेल खाता है।',
    'act_6': 'सत्यापन चलाएं',
    'pf_t_6': 'आयतन सत्यापित',
    'pf_d_6': 'हमने नए घन के कुल आयतन के बराबर सभी घटक आयतनों का योग कर लिया है।',
    'pf_a_6': 'संपूर्ण पैकेज बिल्कुल उसके भागों का योग है।',
    
    'title_7': 'विस्फोट परीक्षण',
    'instr_7': "आंतरिक संरचना का निरीक्षण करने के लिए 'विस्फोट दृश्य' टॉगल का उपयोग करें।",
    'act_7': 'परीक्षण पूर्ण',
    
    'title_8': 'संख्यात्मक जांच',
    'instr_8': 'यदि a=10 और b=2, कुल आयतन की गणना करें। आयतन का सूत्र (a+b)³ है।',
    
    'title_9': 'अंतिम प्रमाणन',
    'instr_9': 'क्या (a+b)³ = a³ + b³ है? (सामान्य त्रुटि जांच)',
    
    'opt_yes': 'हाँ',
    'opt_no': 'नहीं',
  },
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TheCubicVaultApp());
}

class TheCubicVaultApp extends StatelessWidget {
  const TheCubicVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Cubic Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1B4B), // Cosmic Theme bg
        fontFamily: 'monospace',
      ),
      home: const TheCubicVaultScreen(),
    );
  }
}

// --- CORE APP SCREEN ---
class TheCubicVaultScreen extends StatefulWidget {
  const TheCubicVaultScreen({super.key});

  @override
  State<TheCubicVaultScreen> createState() => _TheCubicVaultScreenState();
}

class _TheCubicVaultScreenState extends State<TheCubicVaultScreen>
    with TickerProviderStateMixin {
  
  // Theme Colors
  final Color bgTheme = const Color(0xFF1E1B4B);
  final Color panelColor = const Color(0xFF131130);
  final Color accentTheme = const Color(0xFFFACC15);
  final Color primaryTheme = const Color(0xFF38BDF8);
  final Color successTheme = const Color(0xFF4ADE80);
  final Color errorTheme = const Color(0xFFF43F5E);

  int appStep = 0;
  String? currentSlotState;
  bool showingProof = false;
  
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;
  bool _isStepTransitioning = false;

  late AnimationController _pulseController;
  late AnimationController _explodeController;
  bool isExploded = false;

  Offset _panOffset = Offset.zero; // State variable for making the canvas draggable

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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _explodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    _explodeController.dispose();
    super.dispose();
  }

  void _handleTaskComplete(LabStep step) {
    HapticFeedback.heavyImpact();
    if (step.proof != null) {
      _playSound(_fxPlayer, _alertUrl); // Target acquired
      setState(() => showingProof = true);
    } else {
      _advanceStep();
    }
  }

  void _advanceStep() {
    _playSound(_successPlayer, _successUrl);
    setState(() {
      showingProof = false;
      _isStepTransitioning = true;
      currentSlotState = null;
      appStep++;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isStepTransitioning = false;
        });
      }
    });
  }

  void checkDragCompletion(String answer) {
    if (currentSlotState == answer) {
      _handleTaskComplete(labData[appStep]);
    } else {
      currentSlotState = null;
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl); // Custom Error buzzer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('err_mismatch')),
          backgroundColor: errorTheme,
        ),
      );
    }
  }

  void toggleExplode() {
    HapticFeedback.selectionClick();
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      isExploded = !isExploded;
      if (isExploded) {
        _explodeController.forward();
      } else {
        _explodeController.reverse();
      }
    });
  }

  void resetApp() {
    setState(() {
      appStep = 0;
      currentSlotState = null;
      showingProof = false;
      isExploded = false;
      _isStepTransitioning = false;
      _panOffset = Offset.zero; // Reset pan
      _explodeController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarWidth = screenW * 0.38; // 38% exactly

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgTheme,
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expandable Sidebar Container
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

                // Center Activity
                Expanded(
                  child: _buildWorkspace(screenW),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            // Overlays
            if (showingProof && !_showShutter) _buildProofModal(),
            if (appStep >= labData.length && !_isStepTransitioning && !_showShutter && !showingProof) 
              _buildCelebrationOverlay(),
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

          // Settings Row
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

          // Build/Journal Content
          _buildJournal(),

          const SizedBox(height: 32),

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
    double progress = ((appStep + 1) / labData.length).clamp(0.0, 1.0);
    String phase = appStep < labData.length 
        ? t(labData[appStep].phaseKey) 
        : t('msg_stable');
    bool isComplete = appStep >= labData.length;

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
                    color: isComplete ? successTheme : accentTheme, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                isComplete ? '' : '${t('lbl_step')} ${appStep + 1}/${labData.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: isComplete ? successTheme : accentTheme,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildJournal() {
    if (appStep >= labData.length) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: successTheme, size: 64),
            const SizedBox(height: 16),
            Text(t('msg_stable'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: successTheme), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(t('msg_cleared'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryTheme, foregroundColor: Colors.black),
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_shutterPlayer, _shutterUrl);
                setState(() {
                  _showShutter = true;
                });
                resetApp();
              },
              icon: const Icon(Icons.refresh),
              label: Text(t('btn_restart')),
            )
          ],
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
        bool isCompleted = index < appStep;
        LabStep stepData = labData[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? accentTheme.withOpacity(0.05) : Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? accentTheme : (isCompleted ? successTheme : Colors.white10),
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
                      color: isActive ? accentTheme : (isCompleted ? successTheme : Colors.white24),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.black, size: 14)
                        : Text('${stepData.id}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t(stepData.titleKey),
                      style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(t(stepData.instrKey), style: const TextStyle(color: Colors.white60, fontSize: 14)),
              
              if (isActive && !_isStepTransitioning && !showingProof) ...[
                const SizedBox(height: 16),
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

  Widget _buildInteractiveArea(LabStep step, {bool compact = false}) {
    if (step.type == StepType.action) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTheme,
          foregroundColor: Colors.black,
          minimumSize: Size(double.infinity, compact ? 40 : 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _handleTaskComplete(step),
        child: Text(t(step.actionBtnKey), style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    } else if (step.type == StepType.drag && step.template != null) {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: step.template!.map((item) {
          if (!item.isSlot) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                t(item.text),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: compact ? 14 : 18),
              ),
            );
          } else {
            return DragTarget<String>(
              onWillAcceptWithDetails: (details) => currentSlotState == null,
              onAcceptWithDetails: (details) {
                setState(() => currentSlotState = details.data);
                checkDragCompletion(item.text);
              },
              builder: (context, candidateData, rejectedData) {
                bool isHovered = candidateData.isNotEmpty;
                return Container(
                  width: compact ? 60 : 70,
                  height: compact ? 36 : 40,
                  decoration: BoxDecoration(
                    color: currentSlotState != null
                        ? successTheme.withOpacity(0.2)
                        : (isHovered ? accentTheme.withOpacity(0.1) : const Color(0xFF2A2A3D)),
                    border: Border.all(
                      color: currentSlotState != null
                          ? successTheme
                          : (isHovered ? accentTheme : Colors.white54),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    currentSlotState ?? (isHovered ? '?' : ''),
                    style: TextStyle(
                      color: currentSlotState != null ? successTheme : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 14 : 16,
                    ),
                  ),
                );
              },
            );
          }
        }).toList(),
      );
    } else if (step.type == StepType.calc) {
      return Container(
        padding: EdgeInsets.all(compact ? 6 : 8),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '?',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black45,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textAlign: TextAlign.center,
                onSubmitted: (val) {
                  if (int.tryParse(val) == step.targetVal) {
                    _handleTaskComplete(step);
                  } else {
                    HapticFeedback.vibrate();
                    _playSound(_errorPlayer, _errorUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t('err_calc')), backgroundColor: errorTheme),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
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
                  padding: EdgeInsets.symmetric(vertical: compact ? 10 : 16),
                ),
                onPressed: () {
                  if (opt.correct) {
                    _handleTaskComplete(step);
                  } else {
                    HapticFeedback.vibrate();
                    _playSound(_errorPlayer, _errorUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t('err_logic')), backgroundColor: errorTheme),
                    );
                  }
                },
                child: Text(t(opt.textKey), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox();
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(t('lbl_parts').toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.touch_app, color: primaryTheme, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 6,
            runSpacing: 6,
            children: debris.toSet().map((term) {
              return Draggable<String>(
                data: term,
                feedback: Material(
                  color: Colors.transparent,
                  child: _debrisWidget(term, isDragging: true, compact: compact),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: _debrisWidget(term, compact: compact)),
                onDragStarted: () {
                  HapticFeedback.selectionClick();
                  _playSound(_clickPlayer, _clickUrl);
                },
                child: _debrisWidget(term, compact: compact),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _debrisWidget(String text, {bool isDragging = false, bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: primaryTheme.withOpacity(0.1),
        border: Border.all(color: primaryTheme.withOpacity(0.6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging ? [BoxShadow(color: primaryTheme.withOpacity(0.5), blurRadius: 10)] : [],
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: compact ? 13 : 14)),
    );
  }

  Widget _buildWorkspace(double screenW) {
    return ClipRect( // Added ClipRect to ensure the Vault doesn't render over the sidebar
      child: Stack(
        children: [
          // Background with panning gesture listener
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _panOffset += details.delta;
                  // Clamp panning so the vault doesn't get dragged off-screen entirely
                  _panOffset = Offset(
                    _panOffset.dx.clamp(-screenW * 0.6, screenW * 0.6),
                    _panOffset.dy.clamp(-MediaQuery.of(context).size.height * 0.6, MediaQuery.of(context).size.height * 0.6)
                  );
                });
              },
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseController, _explodeController]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: VaultPainter(
                      currentStep: appStep,
                      pulse: _pulseController.value,
                      explodeFactor: _explodeController.value,
                      panOffset: _panOffset,
                    ),
                  );
                },
              ),
            ),
          ),

          // Explode View Toggle
          if (appStep >= 6 && appStep < labData.length && !_showShutter)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Text('Explode View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Switch(
                      value: isExploded,
                      onChanged: (val) => toggleExplode(),
                      activeColor: accentTheme,
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Left Compact HUD - Shown when sidebar is closed
          if (!_sidebarOpen && !_showShutter && !_isStepTransitioning && !showingProof) ...[
            _buildFloatingHUD(screenW),
          ]
        ],
      ),
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    if (appStep >= labData.length) return const SizedBox.shrink(); 

    LabStep step = labData[appStep];
    double hudWidth = math.min(screenW * 0.35, 380.0); // Constrained width so it doesn't overlap visuals

    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        width: hudWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: primaryTheme, width: 4),
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
                t(step.phaseKey).toUpperCase(),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                t(step.titleKey).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t(step.instrKey),
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 12),
              
              _buildInteractiveArea(step, compact: true),
              
              if (step.debris.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDebrisField(step.debris, compact: true),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofModal() {
    LabProof? proof = labData[appStep].proof;
    if (proof == null) return const SizedBox();

    double modalWidth = math.min(MediaQuery.of(context).size.width * 0.9, 500.0);

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        alignment: Alignment.center,
        child: Container(
          width: modalWidth,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.95, // Dynamically adjust to screen height
          ),
          decoration: BoxDecoration(
            color: bgTheme,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentTheme.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: accentTheme.withOpacity(0.2), blurRadius: 30)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FittedBox(
              fit: BoxFit.scaleDown, // Ensures content shrinks to fit instead of scrolling
              alignment: Alignment.center,
              child: SizedBox(
                width: modalWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentTheme.withOpacity(0.1),
                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.balance, color: accentTheme, size: 18),
                          const SizedBox(width: 8),
                          Text(t('lbl_proof'), style: TextStyle(color: accentTheme, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(proof.icon, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t(proof.titleKey),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              proof.math,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t(proof.textKey),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryTheme.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryTheme.withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.lightbulb, color: primaryTheme, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t(proof.analogyKey),
                                    style: TextStyle(color: primaryTheme, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                                  ),
                                ),
                              ],
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
                        style: ElevatedButton.styleFrom(backgroundColor: successTheme, foregroundColor: Colors.black),
                        onPressed: _advanceStep,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(t('btn_proceed'), style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Container(
              width: 450,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.95, // Dynamically adjust to screen height
              ),
              decoration: BoxDecoration(
                color: bgTheme,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: successTheme, width: 2),
                boxShadow: [
                  BoxShadow(color: successTheme.withOpacity(0.2), blurRadius: 80),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Ensures content shrinks to fit instead of scrolling
                  alignment: Alignment.center,
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: successTheme, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          t('msg_stable'),
                          style: TextStyle(
                            color: successTheme,
                            fontSize: 28,
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
        ),
      ),
    );
  }

  Widget _buildLoadingShutter() {
    return Container(
      color: bgTheme,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown, // Prevent overflow on short screens
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) {
                    return Transform.scale(
                      scale: 0.9 + (_pulseController.value * 0.1),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentTheme.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: accentTheme.withOpacity(
                                0.3 + (_pulseController.value * 0.4),
                              ),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: Icon(Icons.layers, color: accentTheme, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  t('app_title').toUpperCase(),
                  style: TextStyle(
                    color: accentTheme,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t('app_subtitle').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 3,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTheme,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_shutterPlayer, _shutterUrl); // Powerful Start Sound Effect
                    setState(() {
                      _showShutter = false;
                    });
                    resetApp(); // Trigger game start
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
        ),
      ),
    );
  }
}

// --- VAULT VISUALIZER PAINTER (Isometric 3D) ---
class VaultPainter extends CustomPainter {
  final int currentStep;
  final double pulse;
  final double explodeFactor;
  final Offset panOffset;

  VaultPainter({
    required this.currentStep,
    required this.pulse,
    required this.explodeFactor,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF281C58), Color(0xFF0F0518), Colors.black],
        stops: [0.0, 0.6, 1.0],
        radius: 1.0,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Adjusted Y-center upwards slightly so it avoids colliding with the new bottom-left HUD position
    Offset center = Offset(size.width * 0.5 + panOffset.dx, size.height * 0.55 + panOffset.dy);

    // Dimensions
    double a = 80.0;
    double b = 30.0;
    double offset = -(a + b) / 2; // to center the final cube

    List<IsoBlock> blocks = [];

    // Step 2 (Index 1): The Core a³
    if (currentStep >= 1) {
      blocks.add(
        IsoBlock(
          x: offset,
          y: offset,
          z: offset,
          w: a,
          h: a,
          d: a,
          color: Colors.lightBlue,
          opacity: (currentStep == 1) ? 0.6 + pulse * 0.4 : 1.0,
        ),
      );
    }

    // Step 3 (Index 2): 3 x a²b Slabs
    if (currentStep >= 2) {
      Color c = Colors.purpleAccent;
      double op = (currentStep == 2) ? 0.6 + pulse * 0.4 : 1.0;
      // Right face (+x)
      blocks.add(
        IsoBlock(
          x: offset + a,
          y: offset,
          z: offset,
          w: b,
          h: a,
          d: a,
          color: c,
          opacity: op,
        ),
      );
      // Top face (+y)
      blocks.add(
        IsoBlock(
          x: offset,
          y: offset + a,
          z: offset,
          w: a,
          h: b,
          d: a,
          color: c,
          opacity: op,
        ),
      );
      // Front face (+z)
      blocks.add(
        IsoBlock(
          x: offset,
          y: offset,
          z: offset + a,
          w: a,
          h: a,
          d: b,
          color: c,
          opacity: op,
        ),
      );
    }

    // Step 4 (Index 3): 3 x ab² Beams
    if (currentStep >= 3) {
      Color c = const Color(0xFFF43F5E); // Reddish for beams to stand out
      double op = (currentStep == 3) ? 0.6 + pulse * 0.4 : 1.0;
      // Top-Right gap
      blocks.add(
        IsoBlock(
          x: offset + a,
          y: offset + a,
          z: offset,
          w: b,
          h: b,
          d: a,
          color: c,
          opacity: op,
        ),
      );
      // Front-Right gap
      blocks.add(
        IsoBlock(
          x: offset + a,
          y: offset,
          z: offset + a,
          w: b,
          h: a,
          d: b,
          color: c,
          opacity: op,
        ),
      );
      // Top-Front gap
      blocks.add(
        IsoBlock(
          x: offset,
          y: offset + a,
          z: offset + a,
          w: a,
          h: b,
          d: b,
          color: c,
          opacity: op,
        ),
      );
    }

    // Step 5 (Index 4): The Keystone b³
    if (currentStep >= 4) {
      blocks.add(
        IsoBlock(
          x: offset + a,
          y: offset + a,
          z: offset + a,
          w: b,
          h: b,
          d: b,
          color: Colors.yellow,
          opacity: (currentStep == 4) ? 0.6 + pulse * 0.4 : 1.0,
        ),
      );
    }

    // Apply Explosion logic
    if (explodeFactor > 0 && blocks.isNotEmpty) {
      for (var block in blocks) {
        // Block center relative to assembly center (0,0,0) since we used 'offset'
        double cx = block.x + block.w / 2;
        double cy = block.y + block.h / 2;
        double cz = block.z + block.d / 2;

        // Push outward
        block.x += cx * explodeFactor * 0.8;
        block.y += cy * explodeFactor * 0.8;
        block.z += cz * explodeFactor * 0.8;
      }
    }

    // Sort blocks by depth (Painter's algorithm).
    blocks.sort((b1, b2) => (b1.x + b1.y + b1.z).compareTo(b2.x + b2.y + b2.z));

    for (var block in blocks) {
      _drawIsoBlock(canvas, center, block);
    }
  }

  void _drawIsoBlock(Canvas canvas, Offset origin, IsoBlock b) {
    // Projection helper
    Offset proj(double x, double y, double z) {
      // Standard isometric projection angles
      double sx = origin.dx + (x - z) * 0.866025; // cos(30)
      double sy = origin.dy - y + (x + z) * 0.5; // sin(30)
      return Offset(sx, sy);
    }

    // 8 Vertices
    proj(b.x, b.y, b.z);
    Offset p100 = proj(b.x + b.w, b.y, b.z);
    Offset p010 = proj(b.x, b.y + b.h, b.z);
    Offset p110 = proj(b.x + b.w, b.y + b.h, b.z);
    Offset p001 = proj(b.x, b.y, b.z + b.d);
    Offset p101 = proj(b.x + b.w, b.y, b.z + b.d);
    Offset p011 = proj(b.x, b.y + b.h, b.z + b.d);
    Offset p111 = proj(b.x + b.w, b.y + b.h, b.z + b.d);

    // Colors
    Paint topPaint = Paint()..color = b.color.withOpacity(b.opacity);
    Paint leftPaint = Paint()
      ..color = _darken(b.color, 0.2).withOpacity(b.opacity);
    Paint rightPaint = Paint()
      ..color = _darken(b.color, 0.4).withOpacity(b.opacity);
    Paint edgePaint = Paint()
      ..color = Colors.white.withOpacity(b.opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Top Face (y + h)
    Path topFace = Path()
      ..moveTo(p010.dx, p010.dy)
      ..lineTo(p110.dx, p110.dy)
      ..lineTo(p111.dx, p111.dy)
      ..lineTo(p011.dx, p011.dy)
      ..close();
    canvas.drawPath(topFace, topPaint);
    canvas.drawPath(topFace, edgePaint);

    // Left Face (Front-Left, +z face)
    Path leftFace = Path()
      ..moveTo(p001.dx, p001.dy)
      ..lineTo(p101.dx, p101.dy)
      ..lineTo(p111.dx, p111.dy)
      ..lineTo(p011.dx, p011.dy)
      ..close();
    canvas.drawPath(leftFace, leftPaint);
    canvas.drawPath(leftFace, edgePaint);

    // Right Face (Front-Right, +x face)
    Path rightFace = Path()
      ..moveTo(p100.dx, p100.dy)
      ..lineTo(p101.dx, p101.dy)
      ..lineTo(p111.dx, p111.dy)
      ..lineTo(p110.dx, p110.dy)
      ..close();
    canvas.drawPath(rightFace, rightPaint);
    canvas.drawPath(rightFace, edgePaint);
  }

  Color _darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  bool shouldRepaint(covariant VaultPainter oldDelegate) {
    return oldDelegate.currentStep != currentStep ||
        oldDelegate.pulse != pulse ||
        oldDelegate.explodeFactor != explodeFactor ||
        oldDelegate.panOffset != panOffset;
  }
}

class IsoBlock {
  double x, y, z, w, h, d;
  Color color;
  double opacity;
  IsoBlock({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
    required this.h,
    required this.d,
    required this.color,
    this.opacity = 1.0,
  });
}

// --- DATA MODELS & CONTENT ---
enum StepType { action, drag, calc, choice }

class ChoiceOpt {
  final String textKey;
  final bool correct;
  ChoiceOpt(this.textKey, this.correct);
}

class DragTemplateItem {
  final bool isSlot;
  final String text;
  DragTemplateItem({required this.isSlot, required this.text});
}

class LabProof {
  final String icon;
  final String titleKey;
  final String math;
  final String textKey;
  final String analogyKey;
  LabProof({
    required this.icon,
    required this.titleKey,
    required this.math,
    required this.textKey,
    required this.analogyKey,
  });
}

class LabStep {
  final int id;
  final String phaseKey;
  final String titleKey;
  final String instrKey;
  final StepType type;
  final String actionBtnKey;
  final List<String> debris;
  final List<DragTemplateItem>? template;
  final int? targetVal;
  final List<ChoiceOpt>? options;
  final LabProof? proof;

  LabStep({
    required this.id,
    required this.phaseKey,
    required this.titleKey,
    required this.instrKey,
    required this.type,
    this.actionBtnKey = '',
    this.debris = const [],
    this.template,
    this.targetVal,
    this.options,
    this.proof,
  });
}

// Data Definition mapped to i18n
final List<LabStep> labData = [
  LabStep(
    id: 1,
    phaseKey: "ph_setup",
    titleKey: "title_1",
    instrKey: "instr_1",
    type: StepType.action,
    actionBtnKey: "act_1",
  ),
  LabStep(
    id: 2,
    phaseKey: "ph_construct",
    titleKey: "title_2",
    instrKey: "instr_2",
    type: StepType.drag,
    template: [
      DragTemplateItem(isSlot: false, text: "Core:"),
      DragTemplateItem(isSlot: true, text: "a³"),
    ],
    debris: ["a³"],
    proof: LabProof(
      icon: "📦",
      titleKey: "pf_t_2",
      math: "V = a × a × a = a³",
      textKey: "pf_d_2",
      analogyKey: "pf_a_2",
    ),
  ),
  LabStep(
    id: 3,
    phaseKey: "ph_construct",
    titleKey: "title_3",
    instrKey: "instr_3",
    type: StepType.drag,
    template: [
      DragTemplateItem(isSlot: false, text: "3 x"),
      DragTemplateItem(isSlot: true, text: "a²b"),
    ],
    debris: ["a²b"],
    proof: LabProof(
      icon: "🥞",
      titleKey: "pf_t_3",
      math: "V = 3 × (a² · b) = 3a²b",
      textKey: "pf_d_3",
      analogyKey: "pf_a_3",
    ),
  ),
  LabStep(
    id: 4,
    phaseKey: "ph_construct",
    titleKey: "title_4",
    instrKey: "instr_4",
    type: StepType.drag,
    template: [
      DragTemplateItem(isSlot: false, text: "3 x"),
      DragTemplateItem(isSlot: true, text: "ab²"),
    ],
    debris: ["ab²", "a²b", "b³", "a³"],
    proof: LabProof(
      icon: "📏",
      titleKey: "pf_t_4",
      math: "V = 3 × (a · b²) = 3ab²",
      textKey: "pf_d_4",
      analogyKey: "pf_a_4",
    ),
  ),
  LabStep(
    id: 5,
    phaseKey: "ph_construct",
    titleKey: "title_5",
    instrKey: "instr_5",
    type: StepType.drag,
    template: [
      DragTemplateItem(isSlot: false, text: "Corner:"),
      DragTemplateItem(isSlot: true, text: "b³"),
    ],
    debris: ["b³"],
    proof: LabProof(
      icon: "🔐",
      titleKey: "pf_t_5",
      math: "V = b × b × b = b³",
      textKey: "pf_d_5",
      analogyKey: "pf_a_5",
    ),
  ),
  LabStep(
    id: 6,
    phaseKey: "ph_analyze",
    titleKey: "title_6",
    instrKey: "instr_6",
    type: StepType.action,
    actionBtnKey: "act_6",
    proof: LabProof(
      icon: "✅",
      titleKey: "pf_t_6",
      math: "(a+b)³ = a³ + 3a²b + 3ab² + b³",
      textKey: "pf_d_6",
      analogyKey: "pf_a_6",
    ),
  ),
  LabStep(
    id: 7,
    phaseKey: "ph_analyze",
    titleKey: "title_7",
    instrKey: "instr_7",
    type: StepType.action,
    actionBtnKey: "act_7",
  ),
  LabStep(
    id: 8,
    phaseKey: "ph_apply",
    titleKey: "title_8",
    instrKey: "instr_8",
    type: StepType.calc,
    targetVal: 1728, // (10+2)^3
  ),
  LabStep(
    id: 9,
    phaseKey: "ph_conclude",
    titleKey: "title_9",
    instrKey: "instr_9",
    type: StepType.choice,
    options: [ChoiceOpt("opt_yes", false), ChoiceOpt("opt_no", true)],
  ),
];