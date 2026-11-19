// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Make sure to add this to pubspec.yaml

class IndianSystemLab extends StatefulWidget {
  const IndianSystemLab({Key? key}) : super(key: key);

  @override
  State<IndianSystemLab> createState() => _IndianSystemLabState();
}

class _IndianSystemLabState extends State<IndianSystemLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showShutter = true;
  bool _isSidebarOpen = true;
  bool _isDarkTheme = true;
  int _currentStep = 1;
  String _currentLang = 'en';
  bool _showSettings = false;
  bool _isTaskValidated = false;

  // --- Interaction State ---
  bool _step1ZeroPlaced = false;
  bool _step2MoonAssigned = false;
  bool _step2EyesAssigned = false;
  List<int> _step3Sequence = [];
  bool _step4Exploded = false;
  bool _step5Validated = false;

  // Audio Player
  late AudioPlayer _audioPlayer;

  // --- Animations ---
  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;
  late AnimationController _romanFallController;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'The Indian System',
      'chapterMain': 'Class 8 • A Story of Numbers',
      'enterBtn': 'Enter Virtual Lab',
      'hudTitle': 'Interactive Task',
      'settingsTitle': 'Lab Settings',
      'settings_theme': 'Theme Preference',
      'missionObj': 'Target Output',
      'proceedBtn': 'Next Step',
      'finalBtn': 'Restart Lab',
      'validateBtn': 'Validate Model',
      'btn_pending': 'Task Pending',
      'understood': 'Understood',
      'scenarios': {
        1: {
          'title': 'Step 1: The Empty Space',
          'instruction':
              "Tap the empty space [ ? ] to place Zero (The Ultimate Placeholder) to resolve the ambiguity of 502.",
        },
        2: {
          'title': 'Step 2: Word-Numerals',
          'instruction': "Tap 'Moon' to assign 1, and 'Eyes' to assign 2.",
        },
        3: {
          'title': 'Step 3: Reverse Order',
          'instruction':
              "Tap the decoded values (1 and 2) in REVERSE order of their place value to form the number 21.",
        },
        4: {
          'title': 'Step 4: The 10 Symbols',
          'instruction':
              "Tap the glowing Shunya (Zero) orb to generate the modern 10 digits.",
        },
        5: {
          'title': 'Step 5: Ultimate System',
          'instruction':
              "Tap 'Validate Model' to compare Roman chaotic math vs Modern Structured math.",
        },
      },
      'canvas': {
        'moon': 'Moon',
        'eyes': 'Eyes',
        'phrase': "Phrase: 'Moon - Eyes'",
        'moon1': 'Moon = 1',
        'eyes2': 'Eyes = 2',
        'shunya': 'SHUNYA',
        'romanMath': 'Roman Math\n(No Place Value)',
        'indianMath': 'Indian System\n(Place Value + Zero)',
        'chaos': 'CHAOS!',
        'gridHeaders': ['Lakhs', 'T.Th', 'Th', 'H', 'T', 'O'],
        'mathMessage': 'Place-Value Columns Make Math Easy!',
      },
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'भारतीय प्रणाली',
      'chapterMain': 'कक्षा 8 • संख्या की कहानी',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'hudTitle': 'इंटरएक्टिव कार्य',
      'settingsTitle': 'लैब सेटिंग्स',
      'settings_theme': 'थीम प्राथमिकता',
      'missionObj': 'लक्षित आउटपुट',
      'proceedBtn': 'अगला चरण',
      'finalBtn': 'लैब पुनरारंभ करें',
      'validateBtn': 'मॉडल सत्यापित करें',
      'btn_pending': 'कार्य लंबित है',
      'understood': 'समझ गया',
      'scenarios': {
        1: {
          'title': 'चरण 1: रिक्त स्थान',
          'instruction':
              "502 के भ्रम को दूर करने के लिए शून्य (सबसे बड़ा प्लेसहोल्डर) रखने के लिए रिक्त स्थान [ ? ] पर क्लिक करें।",
        },
        2: {
          'title': 'चरण 2: शब्द-अंक',
          'instruction':
              "1 असाइन करने के लिए 'चंद्रमा' पर क्लिक करें, और 2 असाइन करने के लिए 'आँखें' पर क्लिक करें।",
        },
        3: {
          'title': 'चरण 3: विपरीत क्रम पठन',
          'instruction':
              "संख्या 21 बनाने के लिए डिकोड किए गए मानों (1 और 2) पर उनके स्थानीय मान के विपरीत (Reverse) क्रम में क्लिक करें।",
        },
        4: {
          'title': 'चरण 4: 10 प्रतीक',
          'instruction':
              "आधुनिक 10 अंक उत्पन्न करने के लिए चमकते हुए शून्य (Shunya) गोले पर क्लिक करें।",
        },
        5: {
          'title': 'चरण 5: सर्वश्रेष्ठ प्रणाली',
          'instruction':
              "रोमन अराजक गणित और आधुनिक संरचित गणित की तुलना करने के लिए 'मॉडल सत्यापित करें' पर क्लिक करें।",
        },
      },
      'canvas': {
        'moon': 'चंद्रमा',
        'eyes': 'आँखें',
        'phrase': "वाक्यांश: 'चंद्रमा - आँखें'",
        'moon1': 'चंद्रमा = 1',
        'eyes2': 'आँखें = 2',
        'shunya': 'शून्य',
        'romanMath': 'रोमन गणित\n(कोई स्थानीय मान नहीं)',
        'indianMath': 'भारतीय प्रणाली\n(स्थानीय मान + शून्य)',
        'chaos': 'अराजकता!',
        'gridHeaders': ['लाख', 'द.ह.', 'हज़ार', 'सैकड़ा', 'दहाई', 'इकाई'],
        'mathMessage': 'स्थानीय मान स्तंभ गणित को आसान बनाते हैं!',
      },
    },
  };

  Map<String, dynamic> get t => _translations[_currentLang]!;
  Map<String, dynamic> get tCanvas => t['canvas'];
  Map<String, dynamic> get currentScenario => t['scenarios'][_currentStep];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
          CurvedAnimation(
            parent: _shutterController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _romanFallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _shutterController.dispose();
    _romanFallController.dispose();
    super.dispose();
  }

  // --- Network Audio Tones ---
  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'success')
        url =
            'audio/class8/mixkit_2013.mp3';
      else if (type == 'click')
        url =
            'audio/class8/mixkit_2568.mp3';
      else if (type == 'error')
        url =
            'audio/class8/mixkit_2955.mp3';

      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _enterLab() {
    HapticFeedback.mediumImpact();
    _playSound('success');
    _shutterController.forward().then((_) {
      setState(() {
        _showShutter = false;
      });
    });
  }

  void _loadScenario(int step) {
    setState(() {
      _currentStep = step;
      _isTaskValidated = false;
      _step1ZeroPlaced = false;
      _step2MoonAssigned = false;
      _step2EyesAssigned = false;
      _step3Sequence = [];
      _step4Exploded = false;
      _step5Validated = false;
      _romanFallController.reset();
    });
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: bgPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderPanel),
        ),
        title: Text(
          title,
          style: TextStyle(color: textBase, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(msg, style: TextStyle(color: textBase.withOpacity(0.9))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t['understood'],
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  // --- Interaction Handlers ---
  void _handleStep1Zero() {
    HapticFeedback.lightImpact();
    _playSound('success');
    setState(() {
      _step1ZeroPlaced = true;
      _isTaskValidated = true;
    });
  }

  void _handleStep2Moon() {
    HapticFeedback.selectionClick();
    _playSound('click');
    setState(() {
      _step2MoonAssigned = true;
    });
    _checkStep2();
  }

  void _handleStep2Eyes() {
    HapticFeedback.selectionClick();
    _playSound('click');
    setState(() {
      _step2EyesAssigned = true;
    });
    _checkStep2();
  }

  void _checkStep2() {
    if (_step2MoonAssigned && _step2EyesAssigned) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _playSound('success');
        setState(() => _isTaskValidated = true);
      });
    }
  }

  void _handleStep3Selection(int id) {
    if (_step3Sequence.length >= 2) return;
    HapticFeedback.selectionClick();
    _playSound('click');
    setState(() {
      _step3Sequence.add(id);
    });

    if (_step3Sequence.length == 2) {
      if (_step3Sequence[0] == 2 && _step3Sequence[1] == 1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _playSound('success');
          setState(() => _isTaskValidated = true);
        });
      } else {
        HapticFeedback.vibrate();
        _playSound('error');
        _showAlert(
          "Incorrect Order",
          _currentLang == 'hi'
              ? "याद रखें: स्थानीय मान का विपरीत क्रम (Reverse order)। पुनः प्रयास करें।"
              : "Remember: reverse order of place value. Try again.",
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _currentStep == 3) {
            setState(() {
              _step3Sequence.clear();
            });
          }
        });
      }
    }
  }

  void _handleStep4Explode() {
    HapticFeedback.mediumImpact();
    _playSound('success');
    setState(() {
      _step4Exploded = true;
      _isTaskValidated = true;
    });
  }

  void _handleStep5Validate() {
    HapticFeedback.heavyImpact();
    _playSound('success');
    setState(() {
      _step5Validated = true;
      _isTaskValidated = true;
    });
    _romanFallController.forward();
  }

  // --- UI Components ---
  Color get bgBase =>
      _isDarkTheme ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
  Color get bgPanel => _isDarkTheme
      ? const Color.fromRGBO(15, 23, 42, 0.75)
      : const Color.fromRGBO(255, 255, 255, 0.85);
  Color get textBase =>
      _isDarkTheme ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textMuted =>
      _isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get borderPanel => _isDarkTheme
      ? const Color.fromRGBO(255, 255, 255, 0.1)
      : const Color.fromRGBO(0, 0, 0, 0.1);

  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: bgPanel,
            border: Border.all(color: borderPanel),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 30)],
          ),
          child: child,
        ),
      ),
    );
  }

  // --- FLOATING MISSION CARD (Visible when sidebar collapsed) ---
  Widget _buildFloatingMissionCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderPanel),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentScenario['title'],
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentScenario['instruction'],
            style: TextStyle(
              color: textBase.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Actions Row (Reset & Next Step/Validate)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: "Reset Step",
                icon: Icon(Icons.refresh, color: textMuted, size: 22),
                onPressed: () {
                  _playSound('click');
                  _loadScenario(_currentStep);
                },
              ),
              ElevatedButton.icon(
                onPressed: (_currentStep == 5 && !_isTaskValidated)
                    ? () {
                        _playSound('click');
                        _handleStep5Validate();
                      }
                    : (_isTaskValidated
                          ? () {
                              _playSound('click');
                              if (_currentStep < 5) {
                                _loadScenario(_currentStep + 1);
                              } else {
                                _loadScenario(1); // Restart
                              }
                            }
                          : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_currentStep == 5 && !_isTaskValidated)
                      ? Colors.amber
                      : (_isTaskValidated
                            ? Colors.green
                            : (_isDarkTheme ? Colors.white12 : Colors.black12)),
                  disabledBackgroundColor: _isDarkTheme
                      ? Colors.white12
                      : Colors.black12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  (_currentStep == 5 && !_isTaskValidated)
                      ? Icons.play_arrow
                      : (_isTaskValidated ? Icons.check_circle : Icons.lock),
                  color: (_currentStep == 5 && !_isTaskValidated)
                      ? Colors.black
                      : (_isTaskValidated ? Colors.white : textMuted),
                  size: 18,
                ),
                label: Text(
                  (_currentStep == 5 && !_isTaskValidated)
                      ? t['validateBtn']
                      : (_isTaskValidated
                            ? (_currentStep < 5
                                  ? t['proceedBtn']
                                  : t['finalBtn'])
                            : t['btn_pending']),
                  style: TextStyle(
                    color: (_currentStep == 5 && !_isTaskValidated)
                        ? Colors.black
                        : (_isTaskValidated ? Colors.white : textMuted),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 30% SIDEBAR LAYOUT ---
  Widget _buildSidebar(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgPanel,
        border: Border(right: BorderSide(color: borderPanel)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Header inside sidebar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderPanel)),
                    color: _isDarkTheme
                        ? Colors.black12
                        : Colors.black.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: Icon(Icons.menu_open, color: textBase, size: 28),
                        onPressed: () {
                          _playSound('click');
                          setState(() => _isSidebarOpen = false);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.science,
                              color: Colors.amber,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['titleMain'],
                                  style: TextStyle(
                                    color: textBase,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t['chapterMain'],
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: bgBase,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderPanel),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: "Toggle Language",
                              icon: Text(
                                _currentLang.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(
                                  () => _currentLang = _currentLang == 'en'
                                      ? 'hi'
                                      : 'en',
                                );
                              },
                            ),
                            // Container(width: 1, height: 24, color: borderPanel),
                            // IconButton(
                            //   tooltip: "Settings",
                            //   icon: Icon(Icons.settings, color: textMuted),
                            //   onPressed: () {
                            //     _playSound('click');
                            //     setState(() => _showSettings = true);
                            //   },
                            // ),
                            Container(width: 1, height: 24, color: borderPanel),
                            IconButton(
                              tooltip: "Reset Step",
                              icon: Icon(Icons.refresh, color: textMuted),
                              onPressed: () {
                                _playSound('click');
                                _loadScenario(_currentStep);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bgBase,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderPanel),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _currentStep,
                              dropdownColor: bgBase,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.amber,
                              ),
                              style: TextStyle(
                                color: textBase,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  _playSound('click');
                                  _loadScenario(val);
                                }
                              },
                              items: List.generate(5, (index) {
                                int step = index + 1;
                                return DropdownMenuItem(
                                  value: step,
                                  child: Text(t['scenarios'][step]['title']),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Target Output
                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t['missionObj'],
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentScenario['title'],
                          style: TextStyle(
                            color: textBase,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            currentScenario['instruction'],
                            style: TextStyle(
                              color: _isDarkTheme
                                  ? Colors.blue[100]
                                  : Colors.blue[900],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Action Buttons based on Validation
                        if (_currentStep == 5 && !_isTaskValidated)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _playSound('click');
                                _handleStep5Validate();
                              },
                              child: Text(
                                t['validateBtn'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isTaskValidated
                                  ? () {
                                      _playSound('click');
                                      if (_currentStep < 5) {
                                        _loadScenario(_currentStep + 1);
                                      } else {
                                        _loadScenario(1); // Restart
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTaskValidated
                                    ? Colors.green
                                    : (_isDarkTheme
                                          ? Colors.white12
                                          : Colors.black12),
                                disabledBackgroundColor: _isDarkTheme
                                    ? Colors.white12
                                    : Colors.black12,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isTaskValidated
                                        ? Icons.check_circle
                                        : Icons.lock,
                                    color: _isTaskValidated
                                        ? Colors.white
                                        : textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isTaskValidated
                                        ? (_currentStep < 5
                                              ? t['proceedBtn']
                                              : t['finalBtn'])
                                        : t['btn_pending'],
                                    style: TextStyle(
                                      color: _isTaskValidated
                                          ? Colors.white
                                          : textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Sidebar Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isDarkTheme
                        ? Colors.black12
                        : Colors.black.withOpacity(0.05),
                    border: Border(top: BorderSide(color: borderPanel)),
                  ),
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
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

  // --- CANVAS & INTERACTIVE AREA ---
  Widget _buildInteractiveArea() {
    return Container(
      color: Colors.black, // Dark canvas area
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Step Rendering
          if (_currentStep == 1) ...[
            _buildFloatingSprite(
              text: "5",
              xOffset: -80,
              yOffset: -50,
              color: Colors.amber,
            ),
            _step1ZeroPlaced
                ? _buildFloatingSprite(
                    text: "0",
                    xOffset: 0,
                    yOffset: -50,
                    color: Colors.greenAccent,
                  )
                : _buildFloatingSprite(
                    text: "[ ? ]",
                    xOffset: 0,
                    yOffset: -50,
                    color: Colors.redAccent,
                    onTap: _handleStep1Zero,
                  ),
            _buildFloatingSprite(
              text: "2",
              xOffset: 80,
              yOffset: -50,
              color: Colors.amber,
            ),
          ],

          if (_currentStep == 2) ...[
            _buildFloatingSprite(
              text: _step2MoonAssigned ? tCanvas['moon1'] : tCanvas['moon'],
              xOffset: -100,
              yOffset: -40,
              color: _step2MoonAssigned ? Colors.greenAccent : Colors.white,
              onTap: _step2MoonAssigned ? null : _handleStep2Moon,
              isBoxed: true,
            ),
            _buildFloatingSprite(
              text: _step2EyesAssigned ? tCanvas['eyes2'] : tCanvas['eyes'],
              xOffset: 100,
              yOffset: -40,
              color: _step2EyesAssigned ? Colors.greenAccent : Colors.white,
              onTap: _step2EyesAssigned ? null : _handleStep2Eyes,
              isBoxed: true,
            ),
          ],

          if (_currentStep == 3) ...[
            Positioned(
              top: 150,
              child: Text(
                tCanvas['phrase'],
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_step3Sequence.length == 2 &&
                _step3Sequence[0] == 2 &&
                _step3Sequence[1] == 1)
              _buildFloatingSprite(
                text: "21",
                xOffset: 0,
                yOffset: -20,
                color: Colors.amber,
                size: 70,
              )
            else ...[
              _buildFloatingSprite(
                text: tCanvas['moon'],
                xOffset: -100,
                yOffset: -40,
                color: _step3Sequence.contains(1)
                    ? Colors.greenAccent
                    : Colors.white,
                onTap: _step3Sequence.contains(1)
                    ? null
                    : () => _handleStep3Selection(1),
                isBoxed: true,
              ),
              _buildFloatingSprite(
                text: tCanvas['eyes'],
                xOffset: 100,
                yOffset: -40,
                color: _step3Sequence.contains(2)
                    ? Colors.greenAccent
                    : Colors.white,
                onTap: _step3Sequence.contains(2)
                    ? null
                    : () => _handleStep3Selection(2),
                isBoxed: true,
              ),
            ],
          ],

          if (_currentStep == 4) ...[
            if (!_step4Exploded)
              Positioned(
                left: 600 - 50,
                top: 400 - 50,
                child: GestureDetector(
                  onTap: _handleStep4Explode,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.8),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tCanvas['shunya'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...List.generate(10, (index) {
                final double angle = (index / 10) * 2 * math.pi;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 120.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, radius, child) {
                    return Positioned(
                      left: 600 + math.cos(angle) * radius - 20,
                      top: 400 + math.sin(angle) * radius - 40,
                      child: Text(
                        index.toString(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              }),
          ],

          if (_currentStep == 5) ...[
            // Roman Math (Left)
            AnimatedBuilder(
              animation: _romanFallController,
              builder: (context, child) {
                final double fallY = _romanFallController.value * 400;
                final double rotate = _romanFallController.value * 0.5;
                return Positioned(
                  left: 200,
                  top: 200 + fallY,
                  child: Transform.rotate(
                    angle: rotate,
                    child: Opacity(
                      opacity: 1.0 - _romanFallController.value,
                      child: Column(
                        children: [
                          if (_step5Validated)
                            Text(
                              tCanvas['chaos'],
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            tCanvas['romanMath'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.red.withOpacity(0.2),
                            child: const Text(
                              "CCXXXI\nx MDCCCLII",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Modern Math Grid (Right)
            if (_step5Validated)
              Positioned(right: 200, top: 150, child: _buildModernMathGrid())
            else
              Positioned(
                right: 200,
                top: 200,
                child: Column(
                  children: [
                    Text(
                      tCanvas['indianMath'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.green.withOpacity(0.2),
                      child: const Text(
                        "231\nx 1852",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernMathGrid() {
    List<String> headers = List<String>.from(tCanvas['gridHeaders']);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF052E16),
              border: Border.all(color: Colors.greenAccent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: headers
                      .map(
                        (h) => SizedBox(
                          width: 50,
                          child: Text(
                            h,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Divider(color: Colors.white24, thickness: 2),
                _buildMathRow(["", "", "", "2", "3", "1"], Colors.white),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      child: Text(
                        "x",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildMathRow(["", "", "1", "8", "5", "2"], Colors.white),
                  ],
                ),
                const Divider(color: Colors.white, thickness: 3),
                _buildMathRow(["", "", "", "4", "6", "2"], Colors.grey),
                _buildMathRow(["", "1", "1", "5", "5", "0"], Colors.grey),
                const Divider(color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    tCanvas['mathMessage'],
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMathRow(List<String> digits, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) {
        bool isZero = d == "0";
        return SizedBox(
          width: 50,
          child: Text(
            d,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isZero ? Colors.amber : color,
              fontSize: 24,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingSprite({
    required String text,
    required double xOffset,
    required double yOffset,
    required Color color,
    bool isBoxed = false,
    VoidCallback? onTap,
    double size = 40,
  }) {
    return _FloatingWidget(
      xOffset: xOffset,
      yOffset: yOffset,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Container(
            padding: isBoxed
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                : null,
            decoration: isBoxed
                ? BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  )
                : null,
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: size,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sidebarWidth = math.max(size.width * 0.3, 300.0);

    return Scaffold(
      backgroundColor: bgBase,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // 1. Center Interactive Canvas (Zoomable/Responsive)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: bgBase,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/offline_texture.png'),
                    opacity: 0.05,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1, // Ensure users can zoom fully out
                  maxScale: 4.0,
                  // FittedBox ensures the 1200x800 coordinate system perfectly fits the viewport without getting clamped
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 1200,
                      height: 800,
                      child: _buildInteractiveArea(),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Bottom Center HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 20,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Center(
                child: _buildGlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t['hudTitle'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentScenario['instruction'],
                        style: TextStyle(
                          color: textBase,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Floating Mission Card (Visible if Sidebar is Closed)
            if (!_isSidebarOpen)
              Positioned(
                top: 70,
                left: 16,
                child: SafeArea(child: _buildFloatingMissionCard()),
              ),

            // 4. Floating Menu & Back Buttons (Visible if Sidebar is Closed)
            if (!_isSidebarOpen)
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.4),
                      ),
                      onPressed: () {
                        _playSound('click');
                        setState(() => _isSidebarOpen = true);
                      },
                    ),
                  ],
                ),
              ),

            // 5. Scrollable 30% Sidebar (z-index overlapping front)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // 6. Settings Modal Overlay
            if (_showSettings)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: _buildGlassPanel(
                    width: 350,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.settings, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  t['settingsTitle'],
                                  style: TextStyle(
                                    color: textBase,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: textBase),
                              onPressed: () {
                                _playSound('click');
                                setState(() => _showSettings = false);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t['settings_theme'] ?? "Theme",
                              style: TextStyle(
                                color: textBase,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isDarkTheme
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(() => _isDarkTheme = !_isDarkTheme);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 7. Initial Shutter Overlay
            if (_showShutter)
              SlideTransition(
                position: _shutterAnimation,
                child: Container(
                  color: const Color(0xFF020617),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.science, size: 80, color: Colors.amber),
                      const SizedBox(height: 24),
                      Text(
                        t['titleMain'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t['chapterMain'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _enterLab,
                        icon: const Icon(Icons.play_arrow, color: Colors.black),
                        label: Text(
                          t['enterBtn'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Helper for Floating Animation ---
class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final double xOffset;
  final double yOffset;

  const _FloatingWidget({
    required this.child,
    required this.xOffset,
    required this.yOffset,
  });

  @override
  __FloatingWidgetState createState() => __FloatingWidgetState();
}

class __FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: 600 + widget.xOffset - 50,
          top: 400 + widget.yOffset - (_controller.value * 10),
          child: widget.child,
        );
      },
    );
  }
}
