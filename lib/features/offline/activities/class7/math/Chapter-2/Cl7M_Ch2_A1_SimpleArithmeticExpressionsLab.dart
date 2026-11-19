// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SimpleArithmeticExpressions());
}

class SimpleArithmeticExpressions extends StatelessWidget {
  const SimpleArithmeticExpressions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Expression Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFEAB308),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'PlusJakartaSans',
      ),
      home: const SimpleArithmeticExpressionsLab(),
    );
  }
}

class SimpleArithmeticExpressionsLab extends StatefulWidget {
  const SimpleArithmeticExpressionsLab({Key? key}) : super(key: key);

  @override
  State<SimpleArithmeticExpressionsLab> createState() =>
      _SimpleArithmeticExpressionsLabState();
}

class _SimpleArithmeticExpressionsLabState
    extends State<SimpleArithmeticExpressionsLab>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String _clickSound =
      'audio/class7/mixkit_2568.mp3';
  final String _snapSound =
      'audio/class7/mixkit_392.mp3';
  final String _successSound =
      'audio/class7/mixkit_2018.mp3';
  final String _errorSound =
      'audio/class7/mixkit_2954.mp3';

  bool _isLabEntered = false;
  bool _isSidebarOpen = true;
  int _currentScenarioId = 1;
  bool _isCompleted = false;
  int _currentStepIndex = 0;
  String _s5State = 'assemble_two';

  Map<String, String> _slots = {};

  final List<String> _languages = ['en', 'hi'];
  int _currentLangIndex = 0;

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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  void _toggleLanguage() {
    _playSound(_clickSound);
    setState(() {
      _currentLangIndex = (_currentLangIndex + 1) % _languages.length;
    });
  }

  void _resetLab() {
    _playSound(_clickSound);
    setState(() {
      _isLabEntered = false;
      _currentScenarioId = 1;
      _currentLangIndex = 0;
      _resetScenario();
    });
  }

  void _resetScenario() {
    setState(() {
      _slots.clear();
      _isCompleted = false;
      _s5State = 'assemble_two';
      _currentStepIndex = 0;
    });
  }

  void _loadScenario(int id) {
    _playSound(_clickSound);
    setState(() {
      _currentScenarioId = id;
      _resetScenario();
      if (MediaQuery.of(context).size.width <= 768) {
        _isSidebarOpen = false;
      }
    });
  }

  void _validate() {
    _playSound(_clickSound);
    if (_isCompleted) return;

    bool success = false;
    String errorMessage = t('err_default');

    switch (_currentScenarioId) {
      case 1:
        if (_slots['s1_slot1'] == '13' &&
            _slots['s1_op'] == '+' &&
            _slots['s1_slot2'] == '2') {
          success = true;
        } else {
          errorMessage = t('s1_err2');
        }
        break;
      case 2:
        if (_slots['s2_L1'] == '10' &&
            _slots['s2_LO'] == '+_left' &&
            _slots['s2_L2'] == '2' &&
            _slots['s2_R1'] == '7' &&
            _slots['s2_RO'] == '+_right' &&
            _slots['s2_R2'] == '1') {
          success = true;
        } else {
          errorMessage = t('s2_err');
        }
        break;
      case 3:
        if (_slots['s3_jarLeft'] == '125' && _slots['s3_jarRight'] == '128') {
          success = true;
        } else {
          errorMessage = t('s3_err');
        }
        break;
      case 4:
        if (_slots['s4_s1'] == '100' &&
            _slots['s4_op1'] == '-' &&
            _slots['s4_s2'] == '15' &&
            _slots['s4_op2'] == '+' &&
            _slots['s4_s3'] == '56') {
          if (_slots['s4_bracket'] == '( )') {
            success = true;
          } else {
            errorMessage = t('s4_err3');
          }
        } else {
          errorMessage = t('s4_err2');
        }
        break;
      case 5:
        if (_s5State == 'assemble_two') {
          errorMessage = t('s5_err1');
        } else if (_s5State == 'assemble_one' &&
            _slots['s5_combined'] == '7x5') {
          success = true;
        } else {
          errorMessage = t('s5_err2');
        }
        break;
    }

    if (success) {
      _playSound(_successSound);
      setState(() {
        _isCompleted = true;
      });
      _showSuccessPopup();
    } else {
      _playSound(_errorSound);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEAB308), width: 2),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                t('val_success'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMathConclusion(),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t('continue'),
                style: const TextStyle(color: Color(0xFFEAB308), fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  String t(String key) {
    final lang = _languages[_currentLangIndex];
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'The Expression Machine',
      'app_subtitle': 'Class 7 • ARITHMETIC EXPRESSIONS',
      'btn_enter': 'Enter Lab',
      'select_scen': 'SELECT SCENARIO',
      'mission_obj': 'MISSION OBJECTIVE',
      'proc_steps': 'PROCEDURAL STEPS',
      'val_model': 'VALIDATE MODEL',
      'math_concl': 'MATHEMATICAL CONCLUSION',
      'btn_merge': 'MERGE',
      'btn_reset': 'Reset Activity',
      'footer_copy': '© ZeroScienceLab - Fall in love with math and Science',
      'val_success': 'Validation Successful',
      'continue': 'Continue',
      'err_default': 'Incorrect assembly. Please follow the instructions.',
      'scen1': '1. Juice Factory (Variables & Values)',
      'scen2': '2. Balancing Act (Comparisons)',
      'scen3': '3. Marble Logic (Differences)',
      'scen4': '4. Parts Factory (Brackets)',
      'scen5': '5. Parade Formation (Distribution)',
      's1_obj':
          'Understand that an expression has a specific value. Assemble: 13 + 2',
      's1_step1':
          "Drag the '13' block onto the first slot of the conveyor belt.",
      's1_step2':
          "Drag the '+' operator and drop it onto the belt next to the '13'.",
      's1_step3': "Drag the '2' block and drop it next to the '+'.",
      's1_step4': "CLICK the 'VALIDATE MODEL' button to start the Machine!",
      's1_concl': 'The expression 13 + 2 evaluates to a single value: 15.',
      's1_err2': 'Assemble 13 + 2 on the conveyor exactly from left to right.',
      's2_obj': 'Compare two different expressions: 10 + 2 vs 7 + 1.',
      's2_step1': 'Construct 10 + 2 on the left side of the scale.',
      's2_step2': 'Construct 7 + 1 on the right side.',
      's2_step3': "Observe which side exerts more 'weight' (value).",
      's2_step4': 'Validate the model to confirm the inequality.',
      's2_concl': 'Since 12 > 8, the expression 10 + 2 > 7 + 1.',
      's2_err': 'Assemble 10 + 2 on the left, and 7 + 1 on the right exactly.',
      's3_obj': 'Compare by differences without full calculation.',
      's3_step1': 'Left Jar starts with 1023. Right Jar with 1022.',
      's3_step2': "Drag bag '125' to Left. Drag bag '128' to Right.",
      's3_step3': 'Reason logically: Right started -1, but gained +3.',
      's3_step4': 'Validate to see final scale tilt.',
      's3_concl': 'Difference logic proves 1023 + 125 < 1022 + 128.',
      's3_err': 'Place the 125 bag on the left and 128 bag on the right.',
      's4_obj':
          'Discover why brackets are needed to control the order of operations.',
      's4_step1': 'Drag components to assemble 100 - 15 + 56.',
      's4_step2': "Click the 'VALIDATE' button. Observe the error!",
      's4_step3': 'Drag the Grouping Container ( ) over the 15 + 56 segment.',
      's4_step4': 'Validate again. The grouped part is processed first.',
      's4_concl':
          'Success! By using brackets 100 - (15 + 56) = 29, the machine correctly adds the cost of the items first.',
      's4_err2': 'Assemble 100 - 15 + 56 exactly in order.',
      's4_err3':
          'ERROR: 100 - 15 + 56 = 141. Wrong! Use brackets over 15 + 56.',
      's5_obj': 'Visually discover and understand the distributive property.',
      's5_step1':
          "DRAG the 'Scouts (4x5)' and 'Guides (3x5)' onto the parade ground.",
      's5_step2': "CLICK the 'MERGE' button to combine the rows.",
      's5_step3': "DRAG the 'Combined Block ((4+3)x5)' onto the parade ground.",
      's5_step4': 'Validate to complete the mission!',
      's5_concl':
          'Arranging the marchers as two separate groups (4 x 5 + 3 x 5) results in the exact same total number as arranging them in one combined group ((4 + 3) x 5). This is called the distributive property.',
      's5_err1': 'Merge the rows first!',
      's5_err2': 'Drag the combined block onto the parade ground.',
    },
    'hi': {
      'app_title': 'व्यंजक मशीन',
      'app_subtitle': 'कक्षा 7 • अंकगणितीय व्यंजक',
      'btn_enter': 'लैब में प्रवेश करें',
      'select_scen': 'परिदृश्य चुनें',
      'mission_obj': 'मिशन का उद्देश्य',
      'proc_steps': 'प्रक्रियात्मक कदम',
      'val_model': 'मॉडल को मान्य करें',
      'math_concl': 'गणितीय निष्कर्ष',
      'btn_merge': 'मिलाएं',
      'btn_reset': 'गतिविधि रीसेट करें',
      'footer_copy': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
      'val_success': 'सत्यापन सफल',
      'continue': 'जारी रखें',
      'err_default': 'गलत संयोजन। कृपया निर्देशों का पालन करें।',
      'scen1': '1. जूस फैक्ट्री (चर और मान)',
      'scen2': '2. द ग्रेट बैलेंसिंग एक्ट (तुलना)',
      'scen3': '3. मार्बल लॉजिक (अंतर)',
      'scen4': '4. द पार्ट्स फैक्ट्री (कोष्ठक)',
      'scen5': '5. परेड फॉर्मेशन (वितरण)',
      's1_obj':
          'समझें कि व्यंजक का एक विशिष्ट मान होता है। संयोजन करें: 13 + 2',
      's1_step1': "'13' ब्लॉक को कन्वेयर बेल्ट के पहले स्लॉट पर खींचें।",
      's1_step2':
          "'+' ऑपरेटर को खींचें और इसे '13' के बगल में बेल्ट पर छोड़ दें।",
      's1_step3': "'2' ब्लॉक को खींचें और इसे '+' के बगल में छोड़ दें।",
      's1_step4':
          "जूसर मशीन शुरू करने के लिए 'मॉडल को मान्य करें' बटन पर क्लिक करें!",
      's1_concl': 'व्यंजक 13 + 2 का मान 15 होता है।',
      's1_err2': 'बाएँ से दाएँ कन्वेयर पर 13 + 2 को ठीक से इकट्ठा करें।',
      's2_obj': 'दो अलग-अलग व्यंजकों की तुलना करें: 10 + 2 बनाम 7 + 1।',
      's2_step1': 'तराजू के बाईं ओर 10 + 2 बनाएँ।',
      's2_step2': 'दाईं ओर 7 + 1 बनाएँ।',
      's2_step3': "निरीक्षण करें कि किस तरफ अधिक 'वजन' (मान) है।",
      's2_step4': 'असमानता की पुष्टि करने के लिए मॉडल को मान्य करें।',
      's2_concl': 'चूंकि 12 > 8, व्यंजक 10 + 2 > 7 + 1।',
      's2_err': 'बाईं ओर 10 + 2, और दाईं ओर 7 + 1 को ठीक से इकट्ठा करें।',
      's3_obj': 'पूरी गणना किए बिना अंतरों से तुलना करें।',
      's3_step1': 'बायां जार 1023 से शुरू होता है। दायां जार 1022 से।',
      's3_step2': "बैग '125' को बाएँ खींचें। बैग '128' को दाएँ खींचें।",
      's3_step3':
          'तार्किक रूप से सोचें: दायां -1 से शुरू हुआ, लेकिन +3 प्राप्त किया।',
      's3_step4': 'अंतिम स्केल झुकाव देखने के लिए मान्य करें।',
      's3_concl': 'अंतर तर्क साबित करता है कि 1023 + 125 < 1022 + 128।',
      's3_err': 'बाईं ओर 125 का बैग और दाईं ओर 128 का बैग रखें।',
      's4_obj':
          'पता लगाएँ कि संचालन के क्रम को नियंत्रित करने के लिए कोष्ठक की आवश्यकता क्यों है।',
      's4_step1': '100 - 15 + 56 को संयोजित करने के लिए घटकों को खींचें।',
      's4_step2': "VALIDATE बटन पर क्लिक करें। त्रुटि देखें!",
      's4_step3': '15 + 56 के ऊपर Grouping Container ( ) को खींचें।',
      's4_step4':
          'फिर से मान्य करें। समूहीकृत भाग को पहले संसाधित किया जाता है।',
      's4_concl':
          'सफलता! कोष्ठक 100 - (15 + 56) = 29 का उपयोग करके, मशीन सही ढंग से पहले आइटम की लागत जोड़ती है।',
      's4_err2': '100 - 15 + 56 को ठीक से क्रम में इकट्ठा करें।',
      's4_err3':
          'त्रुटि! 100 - 15 + 56 = 141। गलत! 15 + 56 पर कोष्ठक का प्रयोग करें।',
      's5_obj': 'वितरण गुण को नेत्रहीन रूप से खोजें और समझें।',
      's5_step1':
          "'स्काउट्स (4x5)' और 'गाइड्स (3x5)' को परेड ग्राउंड पर खींचें।",
      's5_step2': "पंक्तियों को मिलाने के लिए 'मिलाएं' बटन पर क्लिक करें।",
      's5_step3': "परेड ग्राउंड पर 'संयुक्त ब्लॉक ((4+3)x5)' खींचें।",
      's5_step4': 'मिशन को पूरा करने के लिए मान्य करें!',
      's5_concl':
          'मार्च करने वालों को दो अलग-अलग समूहों (4 x 5 + 3 x 5) के रूप में व्यवस्थित करने से कुल संख्या वैसी ही होती है जैसी उन्हें एक संयुक्त समूह ((4 + 3) x 5) में व्यवस्थित करने पर होती है। इसे वितरण गुण (distributive property) कहा जाता है।',
      's5_err1': 'पहले पंक्तियों को मिलाएं!',
      's5_err2': 'संयुक्त ब्लॉक को परेड ग्राउंड पर खींचें।',
    },
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidebarWidth = size.width * 0.35;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: _buildCanvasArea(),
            ),
            if (!_isSidebarOpen)
              Positioned(top: 66, left: 16, child: _buildFloatingMissionCard()),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: const Color(0xFFEAB308),
                iconSize: 28,
                onPressed: () {
                  _playSound(_clickSound);
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFFEAB308).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _isLabEntered ? -size.height : 0,
              left: 0,
              right: 0,
              height: size.height,
              child: IgnorePointer(
                ignoring: _isLabEntered,
                child: _buildCurtainScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainScreen() {
    return Container(
      color: const Color(0xFF020617),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calculate_outlined,
              size: 80,
              color: Color(0xFFEAB308),
            ),
            const SizedBox(height: 24),
            Text(
              t('app_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('app_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                _playSound(_successSound);
                setState(() => _isLabEntered = true);
              },
              icon: const Icon(Icons.play_circle_fill, size: 28),
              label: Text(
                t('btn_enter'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 8,
                shadowColor: const Color(0xFFEAB308).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      color: const Color(0xFF0F172A),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(2500),
        minScale: 0.1,
        maxScale: 4.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildScenarioContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioContent() {
    switch (_currentScenarioId) {
      case 1:
        return _buildScenario1();
      case 2:
        return _buildScenario2();
      case 3:
        return _buildScenario3();
      case 4:
        return _buildScenario4();
      case 5:
        return _buildScenario5();
      default:
        return const SizedBox();
    }
  }

  Widget _buildScenario1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_slots.values.contains('13'))
              _buildDraggable('13', '13', Colors.blueAccent),
            const SizedBox(width: 20),
            if (!_slots.values.contains('+'))
              _buildDraggable('+', '+', Colors.orangeAccent),
            const SizedBox(width: 20),
            if (!_slots.values.contains('2'))
              _buildDraggable('2', '2', Colors.blueAccent),
          ],
        ),
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropZone('s1_slot1', ''),
              const SizedBox(width: 10),
              _buildDropZone('s1_op', ''),
              const SizedBox(width: 10),
              _buildDropZone('s1_slot2', ''),
              const SizedBox(width: 30),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 40,
                color: Colors.white54,
              ),
              const SizedBox(width: 30),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isCompleted ? Colors.green : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _isCompleted ? '15\nJuice' : 'Machine',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScenario2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_slots.values.contains('10'))
              _buildDraggable('10', '10', Colors.blueAccent),
            const SizedBox(width: 10),
            if (!_slots.values.contains('+_left'))
              _buildDraggable('+_left', '+', Colors.orangeAccent),
            const SizedBox(width: 10),
            if (!_slots.values.contains('2'))
              _buildDraggable('2', '2', Colors.blueAccent),
            const SizedBox(width: 40),
            if (!_slots.values.contains('7'))
              _buildDraggable('7', '7', Colors.green),
            const SizedBox(width: 10),
            if (!_slots.values.contains('+_right'))
              _buildDraggable('+_right', '+', Colors.orangeAccent),
            const SizedBox(width: 10),
            if (!_slots.values.contains('1'))
              _buildDraggable('1', '1', Colors.green),
          ],
        ),
        const SizedBox(height: 60),
        AnimatedRotation(
          turns: _isCompleted ? -0.05 : 0.0,
          duration: const Duration(seconds: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Left Pan',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropZone('s2_L1', ''),
                        const SizedBox(width: 5),
                        _buildDropZone('s2_LO', ''),
                        const SizedBox(width: 5),
                        _buildDropZone('s2_L2', ''),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Container(
                width: 20,
                height: 100,
                color: Colors.grey[600],
                child: const Center(
                  child: Icon(Icons.circle, size: 16, color: Colors.yellow),
                ),
              ),
              const SizedBox(width: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Right Pan',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropZone('s2_R1', ''),
                        const SizedBox(width: 5),
                        _buildDropZone('s2_RO', ''),
                        const SizedBox(width: 5),
                        _buildDropZone('s2_R2', ''),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScenario3() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_slots.values.contains('125'))
              _buildDraggable('125', 'Bag\n125', Colors.brown[400]!, size: 80),
            const SizedBox(width: 50),
            if (!_slots.values.contains('128'))
              _buildDraggable('128', 'Bag\n128', Colors.brown[400]!, size: 80),
          ],
        ),
        const SizedBox(height: 60),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // The Fulcrum
            Container(
              margin: const EdgeInsets.only(top: 10), // Push it slightly below the beam
              child: CustomPaint(
                size: const Size(60, 60),
                painter: _FulcrumPainter(),
              ),
            ),
            // The Seesaw Beam and Items
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: AnimatedRotation(
                turns: _isCompleted ? 0.05 : 0.0,
                alignment: Alignment.bottomCenter,
                duration: const Duration(seconds: 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDropZone('s3_jarLeft', '', size: 100),
                            const SizedBox(height: 10),
                            const Text(
                              'Raja: 1023',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 140), // Beam width spacing
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDropZone('s3_jarRight', '', size: 100),
                            const SizedBox(height: 10),
                            const Text(
                              'Joy: 1022',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // The Beam
                    Container(
                      height: 12,
                      width: 440,
                      decoration: BoxDecoration(
                        color: Colors.brown[600],
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScenario4() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Source Items
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_slots.values.contains('100'))
              _buildDraggable('100', '100', Colors.blue),
            const SizedBox(width: 10),
            if (!_slots.values.contains('-'))
              _buildDraggable('-', '-', Colors.orange),
            const SizedBox(width: 10),
            if (!_slots.values.contains('15'))
              _buildDraggable('15', '15', Colors.blue),
            const SizedBox(width: 10),
            if (!_slots.values.contains('+'))
              _buildDraggable('+', '+', Colors.orange),
            const SizedBox(width: 10),
            if (!_slots.values.contains('56'))
              _buildDraggable('56', '56', Colors.blue),
            const SizedBox(width: 30),
            if (!_slots.values.contains('( )'))
              _buildDraggable('( )', '( )', Colors.purpleAccent, width: 120),
          ],
        ),
        const SizedBox(height: 60),
        // Equation Assembly Board
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropZone('s4_s1', ''),
              const SizedBox(width: 5),
              _buildDropZone('s4_op1', ''),
              const SizedBox(width: 20),

              // New Bracket DragTarget Wrapper
              // This wraps the slots structurally instead of absolute positioning an overlay over them,
              // thus preventing it from consuming Drag events meant for the children slots.
              DragTarget<String>(
                onWillAccept: (data) =>
                    !_slots.containsKey('s4_bracket') && data == '( )',
                onAccept: (data) {
                  _playSound(_snapSound);
                  setState(() => _slots['s4_bracket'] = data);
                },
                builder: (context, candidateData, rejectedData) {
                  bool hasBracket = _slots.containsKey('s4_bracket');

                  // Allow clicking to remove the bracket
                  return GestureDetector(
                    onTap: () {
                      if (hasBracket && !_isCompleted) {
                        _playSound(_clickSound);
                        setState(() => _slots.remove('s4_bracket'));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasBracket
                              ? Colors.purpleAccent
                              : (candidateData.isNotEmpty
                                    ? Colors.purpleAccent
                                    : Colors.transparent),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: hasBracket
                            ? Colors.purpleAccent.withOpacity(0.15)
                            : Colors.transparent,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDropZone('s4_s2', ''),
                              const SizedBox(width: 5),
                              _buildDropZone('s4_op2', ''),
                              const SizedBox(width: 5),
                              _buildDropZone('s4_s3', ''),
                            ],
                          ),
                          if (hasBracket)
                            const Positioned(
                              left: -10,
                              child: Text(
                                '(',
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 50,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          if (hasBracket)
                            const Positioned(
                              right: -10,
                              child: Text(
                                ')',
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 50,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScenario5() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_s5State == 'assemble_two')
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_slots.values.contains('4x5'))
                _buildDraggable(
                  '4x5',
                  'Scouts\n4x5',
                  Colors.blueAccent,
                  width: 90,
                  height: 90,
                ),
              const SizedBox(width: 20),
              if (!_slots.values.contains('3x5'))
                _buildDraggable(
                  '3x5',
                  'Guides\n3x5',
                  Colors.greenAccent,
                  width: 70,
                  height: 90,
                ),
            ],
          ),
        if (_s5State == 'assemble_one')
          if (!_slots.values.contains('7x5'))
            _buildDraggable(
              '7x5',
              'Combined\n7x5',
              Colors.purpleAccent,
              width: 160,
              height: 90,
            ),
        const SizedBox(height: 60),
        Container(
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Parade Ground',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
              const SizedBox(height: 20),
              if (_s5State == 'assemble_two' || _s5State == 'ready_to_merge')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDropZone('s5_scouts', '', width: 90, height: 90),
                    const SizedBox(width: 10),
                    _buildDropZone('s5_guides', '', width: 70, height: 90),
                  ],
                ),
              if (_s5State == 'assemble_one' || _s5State == 'completed')
                _buildDropZone('s5_combined', '', width: 160, height: 90),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (_s5State == 'ready_to_merge')
          ElevatedButton.icon(
            onPressed: () {
              _playSound(_clickSound);
              setState(() {
                _s5State = 'assemble_one';
                _slots.clear();
              });
            },
            icon: const Icon(Icons.merge_type),
            label: Text(t('btn_merge')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
      ],
    );
  }

  Widget _buildDraggable(
    String id,
    String label,
    Color color, {
    double width = 60,
    double height = 60,
    double size = 0,
  }) {
    double w = size > 0 ? size : width;
    double h = size > 0 ? size : height;

    return Draggable<String>(
      data: id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: w * 1.1,
          height: h * 1.1,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone(
    String slotId,
    String label, {
    double width = 60,
    double height = 60,
    double size = 0,
    Color? color,
  }) {
    double w = size > 0 ? size : width;
    double h = size > 0 ? size : height;

    bool hasItem = _slots.containsKey(slotId);

    return DragTarget<String>(
      onWillAccept: (data) {
        if (hasItem) return false;
        // Prevent bracket dropping into standard drop zones
        if (data == '( )' && slotId != 's4_bracket') return false;
        return true;
      },
      onAccept: (data) {
        _playSound(_snapSound);
        setState(() {
          _slots[slotId] = data;
          if (_currentScenarioId == 5 &&
              _slots.containsKey('s5_scouts') &&
              _slots.containsKey('s5_guides')) {
            _s5State = 'ready_to_merge';
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        // Wrapping target in GestureDetector enables tapping to remove an item!
        return GestureDetector(
          onTap: () {
            if (hasItem && !_isCompleted) {
              _playSound(_clickSound);
              setState(() {
                _slots.remove(slotId);
                // Adjust Scenario 5 sub-states when un-dropping
                if (_currentScenarioId == 5 && _s5State == 'ready_to_merge') {
                  _s5State = 'assemble_two';
                }
              });
            }
          },
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: hasItem
                  ? Colors.grey[700]
                  : (color ?? Colors.grey[800]!.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: candidateData.isNotEmpty
                    ? Colors.yellow
                    : Colors.grey[600]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                hasItem ? _getLabelForData(_slots[slotId]!) : label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hasItem ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLabelForData(String data) {
    if (data == '+_left' || data == '+_right') return '+';
    return data;
  }

  Widget _buildSidebar(double width) {
    return Material(
      elevation: 16,
      color: const Color(0xFF1E293B),
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.white12)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 20,
                  right: 16,
                  bottom: 16,
                ),
                color: const Color(0xFF0F172A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science, color: Color(0xFFEAB308)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('app_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('app_subtitle'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleLanguage,
                          icon: const Icon(Icons.language, size: 16),
                          label: Text(
                            _languages[_currentLangIndex].toUpperCase(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetLab,
                          icon: const Icon(Icons.refresh),
                          color: Colors.white,
                          tooltip: t('btn_reset'),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white10,
                          ),
                        ),
                      ],
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
                      t('select_scen'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _currentScenarioId,
                          dropdownColor: const Color(0xFF0F172A),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white54,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          onChanged: (val) {
                            if (val != null) _loadScenario(val);
                          },
                          items: [
                            DropdownMenuItem(value: 1, child: Text(t('scen1'))),
                            DropdownMenuItem(value: 2, child: Text(t('scen2'))),
                            DropdownMenuItem(value: 3, child: Text(t('scen3'))),
                            DropdownMenuItem(value: 4, child: Text(t('scen4'))),
                            DropdownMenuItem(value: 5, child: Text(t('scen5'))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          color: Color(0xFFEAB308),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('mission_obj'),
                          style: const TextStyle(
                            color: Color(0xFFEAB308),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getObjectiveText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.list_alt,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('proc_steps'),
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._getSteps().map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4, right: 8),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _validate,
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          t('val_model'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isCompleted)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: Color(0xFF3B82F6),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t('math_concl'),
                                  style: const TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getMathConclusion(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Text(
                  t('footer_copy'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    final steps = _getSteps();
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes,
                color: Color(0xFFEAB308),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                t('mission_obj'),
                style: const TextStyle(
                  color: Color(0xFFEAB308),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getObjectiveText(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              const Icon(Icons.list_alt, color: Color(0xFF3B82F6), size: 16),
              const SizedBox(width: 8),
              Text(
                'STEP ${_currentStepIndex + 1} OF ${steps.length}',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            steps[_currentStepIndex],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentStepIndex > 0
                    ? () {
                        _playSound(_clickSound);
                        setState(() => _currentStepIndex--);
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                color: Colors.white,
                disabledColor: Colors.white24,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              if (_currentStepIndex == steps.length - 1)
                ElevatedButton(
                  onPressed: _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    t('val_model'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(),
              IconButton(
                onPressed: _currentStepIndex < steps.length - 1
                    ? () {
                        _playSound(_clickSound);
                        setState(() => _currentStepIndex++);
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                color: Colors.white,
                disabledColor: Colors.white24,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getObjectiveText() {
    return t('s${_currentScenarioId}_obj');
  }

  List<String> _getSteps() {
    switch (_currentScenarioId) {
      case 1:
        return [t('s1_step1'), t('s1_step2'), t('s1_step3'), t('s1_step4')];
      case 2:
        return [t('s2_step1'), t('s2_step2'), t('s2_step3'), t('s2_step4')];
      case 3:
        return [t('s3_step1'), t('s3_step2'), t('s3_step3'), t('s3_step4')];
      case 4:
        return [t('s4_step1'), t('s4_step2'), t('s4_step3'), t('s4_step4')];
      case 5:
        return [t('s5_step1'), t('s5_step2'), t('s5_step3'), t('s5_step4')];
      default:
        return [];
    }
  }

  String _getMathConclusion() {
    return t('s${_currentScenarioId}_concl');
  }
}

class _FulcrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey[700]!
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top tip
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw a small circle at the pivot
    final pivotPaint = Paint()..color = Colors.grey[300]!;
    canvas.drawCircle(Offset(size.width / 2, 5), 5, pivotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
