// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: const AlgebraicModelingofPatternsandRelationships(),
    ),
  );
}

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'Algebraic Modeling of Patterns and Relationships',
    'app_subtitle': 'Class 7 • EXPRESSIONS USING LETTER-NUMBERS',
    'enter_lab': 'Enter Lab',
    'select_scenario': 'Select Scenario',
    'sc1_opt': '1. The Growing Matchstick Chain',
    'sc2_opt': '2. The Calendar Grid Mystery',
    'theory': 'Theory',
    'mission_obj': 'Mission Objective:',
    'procedural_steps': 'Procedural Steps',
    'squares': 'Squares',
    'matchsticks': 'Matchsticks',
    'sys_status': 'System Status',
    'await_input': 'Awaiting Input...',
    'lab_settings': 'Lab Settings',
    'theme': 'Theme',
    'switch_light': 'Switch to Light Mode',
    'switch_dark': 'Switch to Dark Mode',
    'tb_font': 'Teacher Board Font Size:',
    'scenario_summary': 'Scenario Summary',
    'validate_model': 'Validate Model',
    'convert_units': 'Convert Units',
    'step_word': 'STEP',
    'sc1_obj':
        'To discover the algebraic rule that describes the number of matchsticks needed to build a chain of squares.',
    'sc1_s1':
        'TAP the glowing outlines to build your first square. OBSERVE the counters update.',
    'sc1_s2':
        'Add a second square. Notice how many matchsticks you need this time.',
    'sc1_s3':
        'TAP the "Auto-Build +3" button to automatically add three more squares.',
    'sc1_s4': 'TAP the "Reveal Rule" button. WATCH the pattern breakdown.',
    'sc1_s5':
        'The formula is 3w + 1. Let\'s test it. DRAG the slider to change squares.',
    'sc1_sum':
        'Algebraic Modeling Summary:\n\nYou successfully observed a growing pattern of matchstick squares. By isolating the fixed \'starter\' matchstick (1) from the growing \'groups\' of 3, you derived the general algebraic formula:\n\n3w + 1\n\nThis powerful formula allows you to calculate the total matchsticks needed for ANY number of squares instantly!',
    'btn_autobuild': 'Auto-Build +3 Squares',
    'btn_reveal_rule': 'Reveal Rule',
    'num_squares_w': 'Number of Squares (w):',
    'click_glowing': 'Tap the 4 glowing outlines to form a square.',
    'build_next': 'Build the next square. You only need 3 more matchsticks!',
    'observe_pattern':
        'Observe the pattern as squares are added automatically.',
    'analyze_pattern': 'Analyze the pattern to find the algebraic formula.',
    'formula_active': 'Formula Active: Matchsticks = 3 × (Squares) + 1',
    'rem_first': ' matchsticks remaining for first square.',
    'exc_first': 'Excellent! 1 Square = 4 Matchsticks.',
    'rem_sec': ' matchsticks remaining for second square.',
    'great_sec': 'Great! 2 Squares = 7 Matchsticks. (Added 3)',
    'starter_msg': 'Starter Matchstick (1) + Groups of 3 for every square (3w)',
    'ready_valid': 'Ready for validation.',
    'sc2_obj':
        'To use algebra to prove why the sum of the diagonals in any 2x2 grid on a calendar is always equal.',
    'sc2_s1':
        'Tap on any tile to place the 2x2 selector. Watch the diagonal sums.',
    'sc2_s2': 'Are they always equal? Test 5 different spots on the calendar.',
    'sc2_s3':
        'Let\'s use algebra to prove why this works everywhere. TAP "Reveal Algebra".',
    'sc2_sum':
        'Calendar Grid Summary:\n\nBy assigning variables to the calendar cells, you proved that the sum of the diagonals in any 2x2 calendar grid is mathematically identical.\n\nBoth diagonals simplify exactly to:\n\n2a + 8\n\nAlgebra helps us prove that this isn\'t just a coincidence, but a universal rule!',
    'diag_down': 'Diagonal ↘',
    'diag_up': 'Diagonal ↙',
    'sel_area': 'Select a 2x2 area on the calendar.',
    'test_spots': 'Test 5 different spots.',
    'ready_reveal': 'Ready to reveal the algebraic magic.',
    'btn_reveal_alg': 'Reveal Algebra',
    'sel_fit': 'Selector must fit fully on the calendar.',
    'amazing_match': 'Amazing! They match!',
    'tested_spots': ' spots tested. They still match!',
    'validated': '🎉 Model Validated! Scenario Completed!',
  },
  'hi': {
    'app_title': 'पैटर्न और संबंधों का बीजीय मॉडलिंग',
    'app_subtitle': 'कक्षा 7 • अक्षर-संख्याओं का उपयोग करके व्यंजक',
    'enter_lab': 'लैब में प्रवेश करें',
    'select_scenario': 'परिदृश्य चुनें',
    'sc1_opt': '1. बढ़ती माचिस की श्रृंखला',
    'sc2_opt': '2. कैलेंडर ग्रिड का रहस्य',
    'theory': 'सिद्धांत',
    'mission_obj': 'मिशन का उद्देश्य:',
    'procedural_steps': 'प्रक्रियात्मक चरण',
    'squares': 'वर्ग',
    'matchsticks': 'माचिस की तीलियाँ',
    'sys_status': 'सिस्टम स्थिति',
    'await_input': 'इनपुट की प्रतीक्षा है...',
    'lab_settings': 'लैब सेटिंग्स',
    'theme': 'थीम',
    'switch_light': 'लाइट मोड पर जाएं',
    'switch_dark': 'डार्क मोड पर जाएं',
    'tb_font': 'टीचर बोर्ड फ़ॉन्ट आकार:',
    'scenario_summary': 'परिदृश्य सारांश',
    'validate_model': 'मॉडल मान्य करें',
    'convert_units': 'इकाइयों को बदलें',
    'step_word': 'चरण',
    'sc1_obj':
        'उन माचिस की तीलियों की संख्या का वर्णन करने वाले बीजीय नियम की खोज करना जो वर्गों की एक श्रृंखला बनाने के लिए आवश्यक हैं।',
    'sc1_s1':
        'अपना पहला वर्ग बनाने के लिए चमकती हुई रूपरेखाओं पर टैप करें। काउंटर अपडेट देखें।',
    'sc1_s2':
        'एक दूसरा वर्ग जोड़ें। ध्यान दें कि इस बार आपको कितनी तीलियों की आवश्यकता है।',
    'sc1_s3': 'तीन और वर्ग जोड़ने के लिए "ऑटो-बिल्ड +3" बटन पर टैप करें।',
    'sc1_s4':
        '"नियम दिखाएँ" बटन पर टैप करें। पैटर्न समझाने वाला एनिमेशन देखें।',
    'sc1_s5':
        'सूत्र 3w + 1 है। आइए इसका परीक्षण करें। वर्गों को बदलने के लिए स्लाइडर खींचें।',
    'sc1_sum':
        'बीजीय मॉडलिंग सारांश:\n\nआपने माचिस के वर्गों के बढ़ते पैटर्न को देखा। निश्चित \'स्टार्टर\' माचिस (1) को 3 के बढ़ते \'समूहों\' से अलग करके, आपने बीजीय सूत्र प्राप्त किया:\n\n3w + 1\n\nयह सूत्र आपको किसी भी संख्या में वर्गों के लिए आवश्यक कुल माचिस की गणना तुरंत करने की अनुमति देता है!',
    'btn_autobuild': 'ऑटो-बिल्ड +3 वर्ग',
    'btn_reveal_rule': 'नियम दिखाएँ',
    'num_squares_w': 'वर्गों की संख्या (w):',
    'click_glowing': 'एक वर्ग बनाने के लिए 4 चमकती रूपरेखाओं पर टैप करें।',
    'build_next': 'अगला वर्ग बनाएं। आपको केवल 3 और माचिस की आवश्यकता है!',
    'observe_pattern': 'स्वतः वर्ग जुड़ते ही पैटर्न का निरीक्षण करें।',
    'analyze_pattern': 'बीजीय सूत्र खोजने के लिए पैटर्न का विश्लेषण करें।',
    'formula_active': 'सूत्र सक्रिय: माचिस = 3 × (वर्ग) + 1',
    'rem_first': ' पहले वर्ग के लिए तीलियाँ शेष हैं।',
    'exc_first': 'उत्कृष्ट! 1 वर्ग = 4 माचिस।',
    'rem_sec': ' दूसरे वर्ग के लिए तीलियाँ शेष हैं।',
    'great_sec': 'बहुत बढ़िया! 2 वर्ग = 7 माचिस। (3 जोड़ा गया)',
    'starter_msg': 'स्टार्टर माचिस (1) + प्रत्येक वर्ग के लिए 3 के समूह (3w)',
    'ready_valid': 'सत्यापन के लिए तैयार।',
    'sc2_obj':
        'बीजगणित का उपयोग करके यह सिद्ध करना कि कैलेंडर पर 2x2 ग्रिड में विकर्णों का योग हमेशा बराबर क्यों होता है।',
    'sc2_s1':
        '2x2 चयनकर्ता रखने के लिए किसी भी टाइल पर टैप करें। विकर्ण योग देखें।',
    'sc2_s2':
        'क्या वे हमेशा बराबर होते हैं? 5 अलग-अलग स्थानों का परीक्षण करें।',
    'sc2_s3':
        'यह साबित करने के लिए बीजगणित का उपयोग करें कि यह हर जगह काम क्यों करता है। "बीजगणित दिखाएँ" टैप करें।',
    'sc2_sum':
        'कैलेंडर ग्रिड सारांश:\n\nकैलेंडर सेल में चर निर्दिष्ट करके, आपने साबित कर दिया कि 2x2 ग्रिड में विकर्णों का योग समान है।\n\nदोनों विकर्ण बिल्कुल सरल हो जाते हैं:\n\n2a + 8\n\nबीजगणित हमें यह साबित करने में मदद करता है कि यह एक सार्वभौमिक नियम है!',
    'diag_down': 'विकर्ण ↘',
    'diag_up': 'विकर्ण ↙',
    'sel_area': 'कैलेंडर पर 2x2 क्षेत्र चुनें।',
    'test_spots': '5 अलग-अलग स्थानों का परीक्षण करें।',
    'ready_reveal': 'बीजीय जादू प्रकट करने के लिए तैयार।',
    'btn_reveal_alg': 'बीजगणित दिखाएँ',
    'sel_fit': 'चयनकर्ता को कैलेंडर पर पूरी तरह फिट होना चाहिए।',
    'amazing_match': 'अद्भुत! वे मेल खाते हैं!',
    'tested_spots': ' स्थानों का परीक्षण किया गया। वे अभी भी मेल खाते हैं!',
    'validated': '🎉 मॉडल मान्य! परिदृश्य पूर्ण हुआ!',
  },
};

class AlgebraicModelingofPatternsandRelationships extends StatefulWidget {
  const AlgebraicModelingofPatternsandRelationships({super.key});

  @override
  State<AlgebraicModelingofPatternsandRelationships> createState() =>
      _AlgebraicModelingofPatternsandRelationshipsState();
}

class _AlgebraicModelingofPatternsandRelationshipsState
    extends State<AlgebraicModelingofPatternsandRelationships>
    with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  final bool _isDarkMode = true;
  String _currentLang = 'en';
  bool _showShutter = true;
  final double _sidebarFontSize = 14.0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> _sounds = {
    'startup':
        'audio/class7/mixkit_1430.mp3',
    'pop': 'audio/class7/mixkit_2568.mp3',
    'success':
        'audio/class7/mixkit_2018.mp3',
    'error':
        'audio/class7/mixkit_2954.mp3',
  };

  int _currentScenario = 1;
  int _currentStep = 1;
  bool _showSummaryModal = false;

  int _sc1Squares = 0;
  int _sc1Sticks = 0;
  int _sc1GhostsClicked = 0;
  int _sc1SliderValue = 1;
  final List<MatchstickData> _placedMatchsticks = [];
  List<MatchstickData> _ghostMatchsticks = [];
  bool _sc1RuleRevealed = false;

  int _sc2Selections = 0;
  int? _sc2SelectedDay;
  bool _sc2AlgebraRevealed = false;

  final TransformationController _transformController =
      TransformationController();
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _recenterCamera();
      });
    }
  }

  void _recenterCamera() {
    final size = MediaQuery.of(context).size;
    double sidebarWidth = size.width * 0.35;
    if (sidebarWidth < 300) sidebarWidth = 300;
    final viewerWidth = size.width - (_isSidebarOpen ? sidebarWidth : 0);

    double scale = 1.5; // More zoomed in

    double dx = (viewerWidth - 2000 * scale) / 2;
    double dy = (size.height - 2000 * scale) / 2;

    _transformController.value =
        Matrix4.identity()
          ..translate(dx, dy)
          ..scale(scale);
  }

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

  void _playSound(String type) async {
    if (_sounds.containsKey(type)) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer
            .play(AssetSource(_sounds[type]!))
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        // Ignore audio playback timeout/errors to prevent crashes
      }
    }
  }

  String _t(String key) {
    return i18n[_currentLang]?[key] ?? key;
  }

  void _toggleLanguage() {
    _playSound('pop');
    setState(() {
      if (_currentLang == 'en') {
        _currentLang = 'hi';
      } else if (_currentLang == 'hi') {
        _currentLang = 'en';
      }
      _updateHUDForStep();
    });
  }

  void _updateHUD(String message, String type) {
    setState(() {});
  }

  void _updateHUDForStep() {
    if (_currentScenario == 1) {
      if (_currentStep == 1) {
        _updateHUD(_t('click_glowing'), 'info');
      } else if (_currentStep == 2) {
        _updateHUD(_t('build_next'), 'info');
      } else if (_currentStep == 3) {
        _updateHUD(_t('observe_pattern'), 'info');
      } else if (_currentStep == 4) {
        _updateHUD(_t('analyze_pattern'), 'info');
      } else if (_currentStep == 5) {
        _updateHUD(_t('formula_active'), 'success');
      } else if (_currentStep == 6) {
        _updateHUD(_t('ready_valid'), 'info');
      }
    } else {
      if (_currentStep == 1) {
        _updateHUD(_t('sel_area'), 'info');
      } else if (_currentStep == 2) {
        _updateHUD(_t('test_spots'), 'info');
      } else if (_currentStep == 3) {
        _updateHUD(_t('ready_reveal'), 'success');
      } else if (_currentStep == 4) {
        _updateHUD(_t('ready_valid'), 'info');
      }
    }
  }

  void _resetActivity() {
    _playSound('pop');
    setState(() {
      _showShutter = true;
      _loadScenario(1);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _currentScenario = id;
      _currentStep = 1;
      _showSummaryModal = false;

      if (id == 1) {
        _sc1Squares = 0;
        _sc1Sticks = 0;
        _sc1GhostsClicked = 0;
        _sc1SliderValue = 1;
        _placedMatchsticks.clear();
        _sc1RuleRevealed = false;
        _setupSc1Step1();
      } else {
        _sc2Selections = 0;
        _sc2SelectedDay = null;
        _sc2AlgebraRevealed = false;
        _updateHUD(_t('sel_area'), 'info');
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _recenterCamera();
    });
  }

  void _setupSc1Step1() {
    _ghostMatchsticks = [
      MatchstickData(0, 0, isVertical: true),
      MatchstickData(1, 0, isVertical: true),
      MatchstickData(0, 0, isVertical: false),
      MatchstickData(0, 1, isVertical: false),
    ];
    _updateHUD(_t('click_glowing'), 'info');
  }

  void _setupSc1Step2() {
    _ghostMatchsticks = [
      MatchstickData(2, 0, isVertical: true),
      MatchstickData(1, 0, isVertical: false),
      MatchstickData(1, 1, isVertical: false),
    ];
    _updateHUD(_t('build_next'), 'info');
  }

  void _handleMatchstickTap(MatchstickData tappedGhost) {
    _playSound('pop');
    setState(() {
      _ghostMatchsticks.remove(tappedGhost);
      _placedMatchsticks.add(tappedGhost);
      _sc1Sticks++;

      if (_currentStep == 1) {
        _sc1GhostsClicked++;
        if (_sc1GhostsClicked < 4) {
          _updateHUD("${4 - _sc1GhostsClicked}${_t('rem_first')}", 'info');
        } else if (_sc1GhostsClicked == 4) {
          _sc1Squares = 1;
          _updateHUD(_t('exc_first'), 'success');
          _playSound('success');
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _currentStep = 2;
              _sc1GhostsClicked = 0;
              _setupSc1Step2();
            });
          });
        }
      } else if (_currentStep == 2) {
        if (_ghostMatchsticks.isNotEmpty) {
          _updateHUD("${_ghostMatchsticks.length}${_t('rem_sec')}", 'info');
        } else {
          _sc1Squares = 2;
          _updateHUD(_t('great_sec'), 'success');
          _playSound('success');
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _currentStep = 3;
              _updateHUD(_t('observe_pattern'), 'info');
            });
          });
        }
      }
    });
  }

  void _sc1AutoBuild() async {
    _playSound('pop');
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _playSound('pop');
        int startX = _sc1Squares;
        _placedMatchsticks.addAll([
          MatchstickData(startX + 1, 0, isVertical: true),
          MatchstickData(startX, 0, isVertical: false),
          MatchstickData(startX, 1, isVertical: false),
        ]);
        _sc1Squares++;
        _sc1Sticks += 3;
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _currentStep = 4;
      _updateHUD(_t('analyze_pattern'), 'info');
    });
  }

  void _sc1RevealRule() {
    _playSound('success');
    setState(() {
      _sc1RuleRevealed = true;
      _updateHUD(_t('starter_msg'), 'success');
      _currentStep = 5;
    });
  }

  void _sc1SliderChanged(double val) {
    int w = val.toInt();
    setState(() {
      _sc1SliderValue = w;
      _sc1Squares = w;
      _sc1Sticks = 3 * w + 1;

      _placedMatchsticks.clear();
      _placedMatchsticks.add(MatchstickData(0, 0, isVertical: true));
      for (int i = 0; i < w; i++) {
        _placedMatchsticks.addAll([
          MatchstickData(i + 1, 0, isVertical: true),
          MatchstickData(i, 0, isVertical: false),
          MatchstickData(i, 1, isVertical: false),
        ]);
      }

      if (w >= 5 && _currentStep == 5) {
        _playSound('success');
        _currentStep = 6;
        _updateHUD(_t('ready_valid'), 'info');
      }
    });
  }

  void _handleCalendarTap(int day) {
    if (day % 7 == 0 || day > 24) {
      _playSound('error');
      _updateHUD(_t('sel_fit'), 'warn');
      return;
    }

    _playSound('pop');
    setState(() {
      _sc2SelectedDay = day;

      if (_currentStep == 1) {
        _updateHUD(_t('amazing_match'), 'success');
        _playSound('success');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _currentStep = 2;
              _updateHUD("${_t('test_spots')} (0/5)", 'info');
            });
          }
        });
      } else if (_currentStep == 2) {
        _sc2Selections++;
        _updateHUD("$_sc2Selections/5 ${_t('tested_spots')}", 'info');
        if (_sc2Selections >= 5) {
          _playSound('success');
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _currentStep = 3;
                _updateHUD(_t('ready_reveal'), 'success');
              });
            }
          });
        }
      }
    });
  }

  void _sc2RevealAlgebra() {
    _playSound('success');
    setState(() {
      _sc2AlgebraRevealed = true;
      _currentStep = 4;
      _updateHUD(_t('ready_valid'), 'info');
    });
  }

  Color get _bgCol =>
      _isDarkMode ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
  Color get _panelCol => _isDarkMode ? const Color(0xFF0F172A) : Colors.white;
  Color get _textCol =>
      _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _yellow => const Color(0xFFEAB308);

  @override
  Widget build(BuildContext context) {
    if (_showShutter) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate, size: 80, color: _yellow),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _t('app_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _yellow,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t('app_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, color: Colors.black),
                label: Text(
                  _t('enter_lab'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _playSound('startup');
                  setState(() {
                    _showShutter = false;
                  });
                  _loadScenario(1);
                },
              ),
            ],
          ),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35;
    if (sidebarWidth < 300) sidebarWidth = 300;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: _bgCol,
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: _buildCanvasArea(),
            ),
            if (_currentScenario == 1) _buildSc1Counters(),
            if (!_isSidebarOpen)
              Positioned(top: 110, left: 20, child: _buildFloatingActionCard()),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: _panelCol.withOpacity(0.95),
                  border: Border(
                    right: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  boxShadow: [
                    if (_isSidebarOpen)
                      const BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              _buildSidebarHeader(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildScenarioSelector(),
                                      const SizedBox(height: 20),
                                      _buildTargetOutput(),
                                      const SizedBox(height: 20),
                                      _buildActionButtons(),
                                    ],
                                  ),
                                ),
                              ),
                              _buildSidebarFooter(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: _yellow,
                iconSize: 28,
                onPressed: () {
                  _playSound('pop');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _recenterCamera();
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _yellow.withOpacity(0.8)),
                  ),
                ),
              ),
            ),
            if (_showSummaryModal)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.8,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _panelCol,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _yellow, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _t('scenario_summary'),
                              style: TextStyle(
                                color: _yellow,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                _playSound('pop');
                                setState(() {
                                  _showSummaryModal = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                _t(
                                  _currentScenario == 1 ? 'sc1_sum' : 'sc2_sum',
                                ),
                                style: TextStyle(
                                  color: _textCol,
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(
                            _currentScenario == 1
                                ? Icons.navigate_next
                                : Icons.refresh,
                            color: Colors.black,
                          ),
                          label: Text(
                            _currentScenario == 1
                                ? "Next Scenario"
                                : "Restart Activity",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _yellow,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            _playSound('success');
                            setState(() {
                              _showSummaryModal = false;
                              if (_currentScenario == 1) {
                                _loadScenario(2);
                              } else {
                                _resetActivity();
                              }
                            });
                          },
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

  Widget _buildCanvasArea() {
    return InteractiveViewer(
      transformationController: _transformController,
      boundaryMargin: const EdgeInsets.all(5000),
      minScale: 0.2,
      maxScale: 4.0,
      constrained: false,
      child: Container(
        width: 2000,
        height: 2000,
        alignment: Alignment.center,
        child:
            _currentScenario == 1
                ? _buildMatchstickScene()
                : _buildCalendarScene(),
      ),
    );
  }

  Widget _buildMatchstickScene() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_sc1RuleRevealed || _currentStep >= 5)
          Positioned(
            top: 200,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _yellow),
              ),
              child: Text(
                _currentStep == 4 ? "M = 1 + 3w" : "3w + 1",
                style: TextStyle(
                  color: _textCol,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        GestureDetector(
          onTapUp: (details) {
            if (_currentStep > 2) return;
            Offset localPos = details.localPosition;
            double gridX = (localPos.dx - 1000) / 100.0;
            double gridY = (1000 - localPos.dy) / 100.0;

            MatchstickData? closest;
            double minDist = double.infinity;

            for (var ghost in _ghostMatchsticks) {
              double cx = ghost.x + (ghost.isVertical ? 0 : 0.5);
              double cy = ghost.y + (ghost.isVertical ? 0.5 : 0);

              double dist =
                  (cx - gridX) * (cx - gridX) + (cy - gridY) * (cy - gridY);

              // Large hit box for easier interaction
              if (dist < 1.5 && dist < minDist) {
                minDist = dist;
                closest = ghost;
              }
            }
            if (closest != null) _handleMatchstickTap(closest);
          },
          child: CustomPaint(
            size: const Size(2000, 2000),
            painter: MatchstickPainter(
              placed: _placedMatchsticks,
              ghosts: _ghostMatchsticks,
              highlightStarter: _sc1RuleRevealed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarScene() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_sc2AlgebraRevealed)
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _yellow),
              ),
              child: Column(
                children: [
                  Text(
                    "Diag 1: a + (a+8) = 2a + 8",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 28,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Diag 2: (a+1) + (a+7) = 2a + 8",
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 28,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: SizedBox(
              width: 7 * 80.0,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  int day = index + 1;
                  bool isSelected = false;
                  bool isDiag1 = false;
                  bool isDiag2 = false;

                  if (_sc2SelectedDay != null) {
                    int d = _sc2SelectedDay!;
                    if (day == d ||
                        day == d + 1 ||
                        day == d + 7 ||
                        day == d + 8) {
                      isSelected = true;
                      if (day == d || day == d + 8) isDiag1 = true;
                      if (day == d + 1 || day == d + 7) isDiag2 = true;
                    }
                  }

                  String cellText = day.toString();
                  if (_sc2AlgebraRevealed && _sc2SelectedDay != null) {
                    int d = _sc2SelectedDay!;
                    if (day == d) {
                      cellText = "a";
                    } else if (day == d + 1) {
                      cellText = "a+1";
                    } else if (day == d + 7) {
                      cellText = "a+7";
                    } else if (day == d + 8) {
                      cellText = "a+8";
                    } else {
                      cellText = "";
                    }
                  }

                  return GestureDetector(
                    onTap: () => _handleCalendarTap(day),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? _yellow.withOpacity(0.3)
                                : const Color(0xFFF1F5F9),
                        border: Border.all(
                          color:
                              isDiag1
                                  ? Colors.green
                                  : (isDiag2
                                      ? Colors.blue
                                      : Colors.grey.shade300),
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cellText,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.black87,
                          fontSize: _sc2AlgebraRevealed && isSelected ? 18 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSc1Counters() {
    return Positioned(
      top: 30,
      left: _isSidebarOpen ? MediaQuery.of(context).size.width * 0.35 + 20 : 80,
      child: Row(
        children: [
          _buildCounterCard(_t('squares'), _sc1Squares.toString(), _yellow),
          const SizedBox(width: 10),
          _buildCounterCard(
            _t('matchsticks'),
            _sc1Sticks.toString(),
            Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(String label, String val, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _panelCol.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: _textCol.withOpacity(0.7),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              color: col,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionCard() {
    List<String> stepKeys =
        _currentScenario == 1
            ? ['sc1_s1', 'sc1_s2', 'sc1_s3', 'sc1_s4', 'sc1_s5', 'ready_valid']
            : ['sc2_s1', 'sc2_s2', 'sc2_s3', 'ready_valid'];

    String currentInstruction =
        _currentStep <= stepKeys.length
            ? _t(stepKeys[_currentStep - 1])
            : _t('ready_valid');

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelCol.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _yellow.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: _yellow, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${_t('step_word')} $_currentStep",
                  style: TextStyle(
                    color: _yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentInstruction,
            style: TextStyle(
              color: _textCol.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          if (_buildActionButtonsList(isFloating: true).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            ..._buildActionButtonsList(isFloating: true),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 66, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.biotech, color: _yellow, size: 24),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('app_title'),
                  style: TextStyle(
                    color: _textCol,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _t('app_subtitle'),
                  style: TextStyle(
                    color: _textCol.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: _toggleLanguage,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language, color: _textCol, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _currentLang.toUpperCase(),
                              style: TextStyle(
                                color: _textCol,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: _resetActivity,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: _textCol, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "RESET",
                              style: TextStyle(
                                color: _textCol,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('select_scenario'),
          style: TextStyle(
            color: _textCol.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _bgCol,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _currentScenario,
              isExpanded: true,
              dropdownColor: _panelCol,
              icon: Icon(Icons.arrow_drop_down, color: _textCol),
              style: TextStyle(color: _textCol, fontSize: 14),
              onChanged: (val) {
                if (val != null) _loadScenario(val);
              },
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(
                    _t('sc1_opt'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(
                    _t('sc2_opt'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetOutput() {
    List<String> stepKeys =
        _currentScenario == 1
            ? ['sc1_s1', 'sc1_s2', 'sc1_s3', 'sc1_s4', 'sc1_s5']
            : ['sc2_s1', 'sc2_s2', 'sc2_s3'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.library_books, color: _yellow, size: 20),
            const SizedBox(width: 8),
            Text(
              _t('theory'),
              style: TextStyle(
                color: _textCol,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _bgCol.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            _t(_currentScenario == 1 ? 'sc1_obj' : 'sc2_obj'),
            style: TextStyle(
              color: _textCol.withOpacity(0.9),
              fontSize: _sidebarFontSize,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.format_list_numbered, color: _yellow, size: 20),
            const SizedBox(width: 8),
            Text(
              _t('procedural_steps'),
              style: TextStyle(
                color: _textCol,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(stepKeys.length, (index) {
          int stepNum = index + 1;
          bool isActive = stepNum == _currentStep;
          bool isPast = stepNum < _currentStep;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? _yellow
                      : (isPast ? _bgCol.withOpacity(0.5) : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? _yellow : Colors.white24,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_t('step_word')} $stepNum",
                  style: TextStyle(
                    color: isActive ? Colors.black : _textCol.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t(stepKeys[index]),
                  style: TextStyle(
                    color:
                        isActive
                            ? Colors.black
                            : _textCol.withOpacity(isPast ? 0.8 : 0.5),
                    fontSize: _sidebarFontSize,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildActionButtonsList(isFloating: false),
    );
  }

  List<Widget> _buildActionButtonsList({required bool isFloating}) {
    List<Widget> btns = [];

    if (_currentScenario == 1) {
      if (_currentStep == 3) {
        btns.add(
          _primaryBtn(_t('btn_autobuild'), Icons.auto_awesome, _sc1AutoBuild),
        );
      } else if (_currentStep == 4) {
        btns.add(
          _primaryBtn(_t('btn_reveal_rule'), Icons.search, _sc1RevealRule),
        );
      } else if (_currentStep == 5) {
        btns.add(
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bgCol,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_t('num_squares_w')} $_sc1SliderValue",
                  style: TextStyle(color: _yellow, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _sc1SliderValue.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  activeColor: _yellow,
                  inactiveColor: Colors.grey,
                  onChanged: _sc1SliderChanged,
                ),
                Center(
                  child: Text(
                    "M = 3($_sc1SliderValue) + 1 = ${3 * _sc1SliderValue + 1}",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (_currentStep >= 6) {
        btns.add(
          _primaryBtn(_t('validate_model'), Icons.check_circle, () {
            _playSound('pop');
            setState(() {
              _showSummaryModal = true;
            });
          }),
        );
      }
    } else {
      if (_currentStep == 1 || _currentStep == 2) {
        if (_sc2SelectedDay != null) {
          int d = _sc2SelectedDay!;
          btns.add(
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    _t('diag_down'),
                    "$d + ${d + 8} = ${d * 2 + 8}",
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoCard(
                    _t('diag_up'),
                    "${d + 1} + ${d + 7} = ${d * 2 + 8}",
                    Colors.blue,
                  ),
                ),
              ],
            ),
          );
        }
      } else if (_currentStep == 3) {
        btns.add(
          _primaryBtn(_t('btn_reveal_alg'), Icons.functions, _sc2RevealAlgebra),
        );
      } else if (_currentStep >= 4) {
        btns.add(
          _primaryBtn(_t('validate_model'), Icons.check_circle, () {
            _playSound('pop');
            setState(() {
              _showSummaryModal = true;
            });
          }),
        );
      }
    }

    return btns;
  }

  Widget _primaryBtn(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _yellow,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
      onPressed: onTap,
    );
  }

  Widget _infoCard(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _bgCol,
        border: Border.all(color: col.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: _textCol.withOpacity(0.7), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              color: col,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: const Center(
        child: Text(
          "© ZeroScienceLab - Fall in love with math and Science",
          style: TextStyle(color: Colors.grey, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MatchstickData {
  final int gridX;
  final int gridY;
  final bool isVertical;
  MatchstickData(this.gridX, this.gridY, {required this.isVertical});

  double get x => gridX * 1.0;
  double get y => gridY * 1.0;
}

class MatchstickPainter extends CustomPainter {
  final List<MatchstickData> placed;
  final List<MatchstickData> ghosts;
  final bool highlightStarter;

  MatchstickPainter({
    required this.placed,
    required this.ghosts,
    this.highlightStarter = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const double scale = 100.0;
    const double stickLength = 100.0;
    const double thickness = 12.0;
    const double headRadius = 14.0;

    void drawStick(MatchstickData data, bool isGhost, bool isHighlighted) {
      final paint =
          Paint()
            ..color =
                isGhost
                    ? Colors.yellow.withOpacity(0.3)
                    : (isHighlighted ? Colors.amber : const Color(0xFFDEB887))
            ..strokeWidth = thickness
            ..strokeCap = StrokeCap.round;

      final headPaint =
          Paint()
            ..color =
                isGhost
                    ? Colors.yellow.withOpacity(0.3)
                    : (isHighlighted
                        ? Colors.deepOrange
                        : const Color(0xFFCC2222))
            ..style = PaintingStyle.fill;

      double sx = center.dx + data.x * scale;
      double sy = center.dy - data.y * scale;

      Offset p1, p2, headPos;

      if (data.isVertical) {
        p1 = Offset(sx, sy);
        p2 = Offset(sx, sy - stickLength);
        headPos = p2;
      } else {
        p1 = Offset(sx, sy);
        p2 = Offset(sx + stickLength, sy);
        headPos = p2;
      }

      canvas.drawLine(p1, p2, paint);
      canvas.drawCircle(headPos, headRadius, headPaint);
    }

    for (var ghost in ghosts) {
      drawStick(ghost, true, false);
    }
    for (int i = 0; i < placed.length; i++) {
      bool isHighlight = highlightStarter && i == 0;
      drawStick(placed[i], false, isHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant MatchstickPainter oldDelegate) => true;
}
