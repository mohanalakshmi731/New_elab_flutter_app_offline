// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NumberCompositionApp());
}

class NumberCompositionApp extends StatefulWidget {
  const NumberCompositionApp({super.key});

  @override
  State<NumberCompositionApp> createState() => _NumberCompositionAppState();
}

class _NumberCompositionAppState extends State<NumberCompositionApp>
    with TickerProviderStateMixin {
  bool _showShutter = true;
  bool _isSidebarOpen = true;
  int _currentScenario = 1;
  bool _isCompleted = false;
  String _lang = 'EN';

  String? _feedbackMessage;
  bool _feedbackIsSuccess = false;
  bool _showFinalPopup = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- Core Activity State ---
  final Map<int, int> _blockCounts = {10000: 0, 1000: 0, 100: 0, 10: 0, 1: 0};

  final Map<int, Color> _blockColors = {
    10000: const Color(0xFF3B82F6), // Blue
    1000: const Color(0xFF22C55E), // Green
    100: const Color(0xFFEAB308), // Yellow
    10: const Color(0xFFF97316), // Orange
    1: const Color(0xFFEF4444), // Red
  };

  // Drag Offsets for floating panels
  Offset _dispenserOffset = Offset.zero;
  Offset _exchangerOffset = Offset.zero;

  // --- Translation Dictionaries ---
  final Map<String, Map<String, String>> _t = {
    'appTitle': {'en': 'Number Composition', 'hi': 'संख्या रचना'},
    'appSubtitleLong': {
      'en': 'Class 7 • The Place Value Machine',
      'hi': 'कक्षा 7 • स्थानीय मान मशीन',
    },
    'appSubtitle': {
      'en': 'Class 7 • The Place Value Machine',
      'hi': 'कक्षा 7 • स्थानीय मान मशीन',
    },
    'enterLab': {'en': 'Enter Lab', 'hi': 'लैब में प्रवेश करें'},
    'selectScenario': {
      'en': 'SELECT ACTIVITY SCENARIO',
      'hi': 'गतिविधि परिदृश्य चुनें',
    },
    'missionObjective': {'en': 'Mission Objective', 'hi': 'मिशन का उद्देश्य'},
    'proceduralTask': {'en': 'Procedural Task', 'hi': 'प्रक्रियात्मक कार्य'},
    'taskPrefix': {'en': 'Task:', 'hi': 'कार्य:'},
    'validateModel': {'en': 'Validate Model', 'hi': 'मॉडल मान्य करें'},
    'validated': {'en': 'Model Validated', 'hi': 'मॉडल मान्य किया गया'},
    'nextScenario': {'en': 'Next Scenario', 'hi': 'अगला परिदृश्य'},
    'finishLab': {'en': 'Finish Lab', 'hi': 'लैब समाप्त करें'},
    'labCompleted': {'en': 'Lab Completed!', 'hi': 'प्रयोगशाला पूरी हुई!'},
    'congrats': {
      'en':
          'Congratulations, you have successfully mastered Number Composition & Decomposition!',
      'hi': 'बधाई हो, आपने संख्या रचना में सफलतापूर्वक महारत हासिल कर ली है!',
    },
    'restartLab': {'en': 'Restart Lab', 'hi': 'पुनः प्रारंभ करें'},
    'footer': {
      'en': '© ZeroScienceLab - Fall in love with math and Science',
      'hi': '© ZeroScienceLab - Fall in love with math and Science',
    },
    'targetNumber': {'en': 'TARGET', 'hi': 'लक्ष्य'},
    'currentTotal': {'en': 'CURRENT', 'hi': 'वर्तमान'},
    'blockCount': {'en': 'BLOCKS USED', 'hi': 'प्रयुक्त ब्लॉक'},
    'brokenBadge': {'en': 'BROKEN', 'hi': 'खराब'},
    'exchangerTitle': {'en': 'The Exchanger', 'hi': 'एक्सचेंजर'},
    'dispensersTitle': {'en': 'Block Dispensers', 'hi': 'ब्लॉक डिस्पेंसर'},

    // Scenarios
    'scen1': {'en': '1. The Systematic Builder', 'hi': '1. व्यवस्थित निर्माता'},
    'scen2': {'en': '2. The Creative Workaround', 'hi': '2. रचनात्मक समाधान'},
    'scen3': {'en': '3. The Exchanger', 'hi': '3. एक्सचेंजर'},
    'scen4': {'en': '4. The Minimalist Challenge', 'hi': '4. न्यूनतम चुनौती'},
    'scen5': {'en': '5. The Creative Constraint', 'hi': '5. रचनात्मक बाधा'},
  };

  final Map<String, Map<String, String>> _validationMsgs = {
    'msgCorrect': {
      'en': 'Objective Complete! Excellent work.',
      'hi': 'उद्देश्य पूर्ण! बहुत बढ़िया।',
    },
    'msgWrong': {
      'en': 'Total inaccurate. Check your blocks.',
      'hi': 'कुल गलत है। अपने ब्लॉकों की जाँच करें।',
    },
    'msgNotEfficient': {
      'en':
          'Correct total, but not the most efficient! Use larger blocks to reduce count.',
      'hi':
          'कुल सही है, लेकिन यह सबसे कुशल तरीका नहीं है! बड़े ब्लॉकों का उपयोग करें।',
    },
  };

  final Map<int, Map<String, dynamic>> _scenarioData = {
    1: {
      'objective': {
        'en':
            'Build the number 5,072 using the most efficient method (standard place value).',
        'hi':
            'सबसे कुशल विधि (मानक स्थानीय मान) का उपयोग करके संख्या 5,072 बनाएं।',
      },
      'task': {
        'en':
            'Click the dispenser buttons to add blocks. Build 5,072 using the fewest blocks possible (14 blocks).',
        'hi':
            'ब्लॉक जोड़ने के लिए डिस्पेंसर पर क्लिक करें। संभवतः सबसे कम ब्लॉकों (14) का उपयोग करके 5,072 बनाएं।',
      },
      'target': 5072,
      'broken': <int>[],
      'minBlocks': 14,
    },
    2: {
      'objective': {
        'en':
            'Build the number 5,072 without using the \'1000\' block dispenser.',
        'hi': '\'1000\' ब्लॉक डिस्पेंसर का उपयोग किए बिना संख्या 5,072 बनाएं।',
      },
      'task': {
        'en':
            'The \'1000\' dispenser is broken! Use the \'+10\' button next to the \'100\' blocks to add stacks and build 5,072.',
        'hi':
            '\'1000\' डिस्पेंसर खराब है! 5,072 बनाने के लिए \'100\' ब्लॉकों के साथ \'+10\' बटन का उपयोग करें।',
      },
      'target': 5072,
      'broken': <int>[1000],
      'minBlocks': null,
    },
    3: {
      'objective': {
        'en':
            'Build the number 3,241 by using the \'Exchanger\' tool to decompose a larger block.',
        'hi':
            'बड़े ब्लॉक को विघटित करने के लिए \'एक्सचेंजर\' टूल का उपयोग करके 3,241 बनाएं।',
      },
      'task': {
        'en':
            'The \'10\' dispenser is broken. Build 3,300, then click exchange (1x100 ➔ 10x10). Finally, remove extra 10s to get 3,241.',
        'hi':
            '\'10\' डिस्पेंसर खराब है। 3,300 बनाएं, फिर एक्सचेंज पर क्लिक करें। अंत में, अतिरिक्त 10 हटाएं।',
      },
      'target': 3241,
      'broken': <int>[10],
      'minBlocks': null,
    },
    4: {
      'objective': {
        'en':
            'Minimalist Challenge: Build the number 8,300 using the absolute fewest possible blocks.',
        'hi':
            'न्यूनतम चुनौती: संभवतः सबसे कम ब्लॉकों का उपयोग करके संख्या 8,300 बनाएं।',
      },
      'task': {
        'en':
            'All dispensers are working. Your mission is to make the Current Total 8,300 using only 11 blocks.',
        'hi':
            'सभी डिस्पेंसर काम कर रहे हैं। आपका मिशन केवल 11 ब्लॉकों का उपयोग करके 8,300 बनाना है।',
      },
      'target': 8300,
      'broken': <int>[],
      'minBlocks': 11,
    },
    5: {
      'objective': {
        'en':
            'Creative Constraint: Build 40,629 with the \'1000\' and \'10\' dispensers broken.',
        'hi':
            'रचनात्मक बाधा: \'1000\' और \'10\' डिस्पेंसर टूटे होने के साथ 40,629 बनाएं।',
      },
      'task': {
        'en':
            'You must use the 10000, 100, and 1 dispensers, along with the Exchanger tool, to build the exact number.',
        'hi':
            'सटीक संख्या बनाने के लिए आपको एक्सचेंजर टूल के साथ 10000, 100 और 1 डिस्पेंसर का उपयोग करना होगा।',
      },
      'target': 40629,
      'broken': <int>[1000, 10],
      'minBlocks': null,
    },
  };

  String t(String key) {
    final l = _lang.toLowerCase();
    return _t[key]?[l] ?? _t[key]?['en'] ?? key;
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
    String url = '';
    if (type == 'click') {
      url = 'audio/class7/mixkit_1120.mp3';
    } else if (type == 'success') {
      url = 'audio/class7/mixkit_2015.mp3';
    } else if (type == 'error') {
      url = 'audio/class7/mixkit_2964.mp3';
    } else if (type == 'entry') {
      url = 'audio/class7/mixkit_2574.mp3';
    } else if (type == 'exchange') {
      url = 'audio/class7/mixkit_1090.mp3';
    }

    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _loadScenario(int id) {
    setState(() {
      _currentScenario = id;
      _isCompleted = false;
      _feedbackMessage = null;
      _showFinalPopup = false;
      _blockCounts.updateAll((key, value) => 0); // Clear blocks
    });
  }

  int get _currentTotal {
    int total = 0;
    _blockCounts.forEach((val, count) => total += (val * count));
    return total;
  }

  int get _blocksUsed {
    int count = 0;
    _blockCounts.forEach((val, c) => count += c);
    return count;
  }

  void _addBlocks(int val, int amount) {
    final broken =
        _scenarioData[_currentScenario]!['broken'] as List<int>? ?? [];
    if (broken.contains(val)) return;

    _playSound('click');
    setState(() {
      _blockCounts[val] = (_blockCounts[val] ?? 0) + amount;
    });
  }

  void _removeBlocks(int val, int amount) {
    if ((_blockCounts[val] ?? 0) >= amount) {
      _playSound('click');
      setState(() {
        _blockCounts[val] = _blockCounts[val]! - amount;
      });
    }
  }

  void _exchangeBlock(int val) {
    if ((_blockCounts[val] ?? 0) > 0) {
      _playSound('exchange');
      setState(() {
        _blockCounts[val] = _blockCounts[val]! - 1;
        int nextVal = val ~/ 10;
        _blockCounts[nextVal] = (_blockCounts[nextVal] ?? 0) + 10;
      });
    }
  }

  void _validate() {
    final langKey = _lang.toLowerCase();
    final data = _scenarioData[_currentScenario]!;
    final target = data['target'] as int;
    final minBlocks = data['minBlocks'] as int?;

    bool isCorrect = false;
    String feedback = '';

    if (_currentTotal != target) {
      feedback = _validationMsgs['msgWrong']![langKey]!;
    } else {
      if (minBlocks != null && _blocksUsed > minBlocks) {
        feedback = _validationMsgs['msgNotEfficient']![langKey]!;
      } else {
        isCorrect = true;
        feedback = _validationMsgs['msgCorrect']![langKey]!;
      }
    }

    setState(() {
      if (isCorrect) {
        _playSound('success');
        _feedbackIsSuccess = true;
        _feedbackMessage = feedback;
        _isCompleted = true;
      } else {
        _playSound('error');
        _feedbackIsSuccess = false;
        _feedbackMessage = feedback;
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _feedbackMessage = null);
    });
  }

  void _nextScenario() {
    _playSound('click');
    if (_currentScenario < 5) {
      _loadScenario(_currentScenario + 1);
    } else {
      _playSound('success');
      setState(() {
        _showFinalPopup = true;
      });
    }
  }

  void _resetLab() {
    _playSound('click');
    setState(() {
      _showFinalPopup = false;
      _showShutter = true;
      _lang = 'EN';
      _dispenserOffset = Offset.zero;
      _exchangerOffset = Offset.zero;
    });
    _loadScenario(1);
  }

  String _formatNumber(int num) {
    if (num == 0) return "0";
    String str = num.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      // Indian Place Value Formatting
      if (i > 0 && ((count == 3) || (count > 3 && (count - 3) % 2 == 0))) {
        result = ',$result';
      }
    }
    return result;
  }

  // --- UI Components ---

  Widget _buildDispensers() {
    final broken =
        _scenarioData[_currentScenario]!['broken'] as List<int>? ?? [];
    final vals = [10000, 1000, 100, 10, 1];

    return Container(
      width: 230,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          MouseRegion(
            cursor: SystemMouseCursors.move,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _dispenserOffset += details.delta;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.drag_indicator,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.widgets, color: Colors.indigo[400], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      t('dispensersTitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...vals.map((val) {
            bool isBroken = broken.contains(val);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  // Value Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _blockColors[val],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _formatNumber(val),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (isBroken)
                        Container(
                          width: 60,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t('brokenBadge'),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Actions
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isBroken
                                ? null
                                : () => _addBlocks(val, 1),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white10,
                            ),
                            child: const Text(
                              '+1',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isBroken
                                ? null
                                : () => _addBlocks(val, 10),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white10,
                            ),
                            child: const Text(
                              '+10',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () => _removeBlocks(val, 1),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.red.withOpacity(0.2),
                              foregroundColor: Colors.red[200],
                            ),
                            child: const Icon(Icons.remove, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExchanger() {
    final vals = [10000, 1000, 100, 10]; // Cannot exchange 1s

    return Container(
      width: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          MouseRegion(
            cursor: SystemMouseCursors.move,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _exchangerOffset += details.delta;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.drag_indicator,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.swap_horiz, color: Colors.amber[400], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t('exchangerTitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...vals.map((val) {
            bool hasBlocks = (_blockCounts[val] ?? 0) > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: hasBlocks ? () => _exchangeBlock(val) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '1 x $val',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward, size: 14),
                    ),
                    Text(
                      '10 x ${val ~/ 10}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    final target = _scenarioData[_currentScenario]!['target'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Target
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('targetNumber'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatNumber(target),
                style: TextStyle(
                  color: Colors.indigo[400],
                  fontSize: 24,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          // Current
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('currentTotal'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatNumber(_currentTotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          // Blocks
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('blockCount'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _blocksUsed.toString(),
                style: TextStyle(
                  color: Colors.teal[400],
                  fontSize: 24,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildFloatingMissionCard() {
  //   final langKey = _lang.toLowerCase();
  //   final data = _scenarioData[_currentScenario]!;

  //   return Positioned(
  //     top: 80,
  //     left: 16,
  //     width: 320,
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.black.withOpacity(0.85),
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: Colors.white24),
  //         boxShadow: const [
  //           BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.track_changes, color: Colors.indigo[400], size: 20),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   t('missionObjective'),
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 16,
  //                     color: Colors.indigo[300],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             data['objective'][langKey],
  //             style: const TextStyle(color: Colors.white, fontSize: 13),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             "${t('taskPrefix')} ${data['task'][langKey]}",
  //             style: TextStyle(
  //               color: Colors.grey[400],
  //               fontSize: 12,
  //               fontStyle: FontStyle.italic,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton.icon(
  //             onPressed: _isCompleted ? null : _validate,
  //             icon: Icon(
  //               _isCompleted ? Icons.check_circle : Icons.fact_check,
  //               size: 18,
  //               color: Colors.white,
  //             ),
  //             label: Text(
  //               _isCompleted ? t('validated') : t('validateModel'),
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 14,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: _isCompleted
  //                   ? Colors.green[600]
  //                   : Colors.indigo[600],
  //               foregroundColor: Colors.white,
  //               minimumSize: const Size(double.infinity, 44),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //           ),
  //           if (_isCompleted) ...[
  //             const SizedBox(height: 8),
  //             ElevatedButton.icon(
  //               onPressed: _nextScenario,
  //               icon: Icon(
  //                 _currentScenario < 5 ? Icons.arrow_forward : Icons.flag,
  //                 size: 18,
  //               ),
  //               label: Text(
  //                 _currentScenario < 5 ? t('nextScenario') : t('finishLab'),
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 14,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.teal[400],
  //                 minimumSize: const Size(double.infinity, 44),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sidebarWidth = max(sw * 0.30, 300.0); // 30% width
    final data = _scenarioData[_currentScenario]!;
    final langKey = _lang.toLowerCase();

    // Default initial top margin for draggable panels
    final initialTop = screenHeight * 0.12;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1220),
        body: Stack(
          children: [
            // --- 1. Canvas Area ---
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  left: _isSidebarOpen && !_showShutter ? sidebarWidth : 0,
                ),
                color: const Color(0xFF0C1220),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Center(
                        child: SizedBox(
                          width: 1400,
                          height: 900,
                          child: CustomPaint(
                            painter: CompositionPainter(
                              // Force redraw by copying the map
                              blockCounts: Map.from(_blockCounts),
                              colors: _blockColors,
                            ),
                            willChange: true,
                          ),
                        ),
                      ),
                    ),

                    // Floating Panels on Canvas (Draggable)
                    Positioned(
                      left: 16 + _dispenserOffset.dx,
                      top: initialTop + _dispenserOffset.dy,
                      child: _buildDispensers(),
                    ),
                    Positioned(
                      right: 16 - _exchangerOffset.dx,
                      top: initialTop + _exchangerOffset.dy,
                      child: _buildExchanger(),
                    ),

                    // Bottom HUD
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(child: _buildHUD()),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. Floating Mission Card (when sidebar is closed) ---
            // if (!_isSidebarOpen && !_showShutter) _buildFloatingMissionCard(),

            // --- 3. Sidebar (Left, 30% Width, Scrollable) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen && !_showShutter ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: const Color(0xFF1E293B),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header space (accounting for absolute Menu icon)
                          Container(
                            padding: const EdgeInsets.only(
                              left: 20, // Space for menu icon
                              right: 20,
                              top: 70,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[900]?.withOpacity(
                                          0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.view_in_ar,
                                        size: 28,
                                        color: Colors.indigo[400],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            t('appSubtitle'),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[400],
                                              letterSpacing: 1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _playSound('click');
                                        setState(
                                          () => _lang = _lang == 'EN'
                                              ? 'HI'
                                              : 'EN',
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _lang,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                      onPressed: _resetLab,
                                      tooltip: t('restartLab'),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Scrollable Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('selectScenario'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        onTap: () => _playSound('click'),
                                        isExpanded: true,
                                        value: _currentScenario,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: _scenarioData.entries
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e.key,
                                                child: Text(
                                                  t('scen${e.key}'),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) _loadScenario(val);
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.track_changes,
                                        color: Colors.indigo[400],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('missionObjective'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['objective'][langKey],
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      height: 1.4,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.format_list_numbered,
                                              color: Colors.indigoAccent,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t('proceduralTask'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data['task'][langKey],
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                  const Divider(color: Colors.white12),
                                  const SizedBox(height: 16),

                                  // Validate Button
                                  ElevatedButton.icon(
                                    onPressed: _isCompleted ? null : _validate,
                                    icon: Icon(
                                      _isCompleted
                                          ? Icons.check_circle
                                          : Icons.fact_check,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      _isCompleted
                                          ? t('validated')
                                          : t('validateModel'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isCompleted
                                          ? Colors.green[600]
                                          : Colors.indigo[600],
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(
                                        double.infinity,
                                        56,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: _isCompleted
                                              ? Colors.green[400]!
                                              : Colors.white24,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_isCompleted) ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _nextScenario,
                                      icon: Icon(
                                        _currentScenario < 5
                                            ? Icons.arrow_forward
                                            : Icons.flag,
                                        color: Colors.black,
                                      ),
                                      label: Text(
                                        _currentScenario < 5
                                            ? t('nextScenario')
                                            : t('finishLab'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal[400],
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                top: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Text(
                              t('footer'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 4. Menu Icon (Top Left, always fixed and over everything) ---
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16, // Fixed position, won't slide with sidebar
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.orangeAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playSound('click');
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

            // --- Feedback Overlay ---
            if (_feedbackMessage != null && !_showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: MediaQuery.of(context).size.height * 0.2,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _feedbackIsSuccess
                            ? Colors.green[700]
                            : Colors.red[700],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _feedbackIsSuccess
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _feedbackMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // --- 5. Success Final Popup ---
            if (_showFinalPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                        maxHeight: 600,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.celebration,
                                size: 80,
                                color: Colors.indigo[400],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                t('labCompleted'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('congrats'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _resetLab,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.black,
                                ),
                                label: Text(
                                  t('restartLab'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[400],
                                  minimumSize: const Size(double.infinity, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // --- 6. Shutter / Curtain Intro Screen ---
            if (_showShutter)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.view_in_ar,
                            size: 80,
                            color: Colors.indigo[400],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('appTitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo[400],
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              t('appSubtitleLong'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            onPressed: () {
                              _playSound('entry');
                              setState(() {
                                _showShutter = false;
                              });
                            },
                            icon: const Icon(
                              Icons.science,
                              color: Colors.white,
                              size: 28,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[600],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.indigo[600]!.withOpacity(0.5),
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
}

// --- Custom Painter for Neat 1-Point Perspective Environment ---
class CompositionPainter extends CustomPainter {
  final Map<int, int> blockCounts;
  final Map<int, Color> colors;

  // Vanishing Point details
  final double vpX = 0.0;
  final double vpY = -300.0;

  CompositionPainter({required this.blockCounts, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    // 1. Sky (Solid Dark Navy)
    final skyRect = Rect.fromLTRB(-cx, -cy, cx, -60);
    final skyPaint = Paint()..color = const Color(0xFF0C1220);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Central Platform Base
    final double pWidth = 1000;
    final double pFrontY = 120;
    final double pBackY = -60;
    final double pHeight = 24;

    // Mathematically calculate top face corners aiming at Vanishing Point
    final double progBack = (pFrontY - pBackY) / (pFrontY - vpY);
    final double blX = -pWidth / 2 + (vpX - (-pWidth / 2)) * progBack;
    final double brX = pWidth / 2 + (vpX - (pWidth / 2)) * progBack;

    final pathPlatformTop = Path()
      ..moveTo(-pWidth / 2, pFrontY)
      ..lineTo(pWidth / 2, pFrontY)
      ..lineTo(brX, pBackY)
      ..lineTo(blX, pBackY)
      ..close();

    canvas.drawPath(pathPlatformTop, Paint()..color = const Color(0xFF293548));

    // Platform Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 1; i < 5; i++) {
      double x = -pWidth / 2 + (pWidth / 5) * i;
      double progXBack = (pFrontY - pBackY) / (pFrontY - vpY);
      double bx = x + (vpX - x) * progXBack;
      canvas.drawLine(Offset(x, pFrontY), Offset(bx, pBackY), gridPaint);
    }

    final pathPlatformFront = Path()
      ..moveTo(-pWidth / 2, pFrontY)
      ..lineTo(pWidth / 2, pFrontY)
      ..lineTo(pWidth / 2, pFrontY + pHeight)
      ..lineTo(-pWidth / 2, pFrontY + pHeight)
      ..close();

    canvas.drawPath(
      pathPlatformFront,
      Paint()..color = const Color(0xFF1D2638),
    );

    // 3. Render Blocks by Denomination Sections
    // Areas: 10000 (Far Left), 1000 (Mid Left), 100 (Center), 10 (Mid Right), 1 (Far Right)

    // We render blocks from back to front (Y-sorting inside each category) to respect 3D overlap.
    _renderCategory(canvas, 10000, -350, 70); // Large Cubes
    _renderCategory(canvas, 1000, -150, 50); // Medium Cubes
    _renderCategory(canvas, 100, 50, 40, isFlat: true); // Flat Plates
    _renderCategory(canvas, 10, 220, 20, isRod: true); // Vertical Rods
    _renderCategory(canvas, 1, 350, 15); // Small Cubes
  }

  void _renderCategory(
    Canvas canvas,
    int val,
    double centerX,
    double size, {
    bool isFlat = false,
    bool isRod = false,
  }) {
    int count = blockCounts[val] ?? 0;
    if (count == 0) return;

    Color color = colors[val]!;

    // Arrange in a grid
    int cols = 5;
    if (val == 1) cols = 10;
    if (val == 10) cols = 8;

    double spacingX = size * 1.2;
    double spacingY = size * 1.2;
    if (isFlat) spacingY = size * 0.4;

    // Back to front rendering logic
    List<Map<String, dynamic>> items = [];
    for (int i = 0; i < count; i++) {
      int col = i % cols;
      int row = i ~/ cols;

      double x = centerX - ((cols * spacingX) / 2) + (col * spacingX);
      double yBase =
          100 - (row * spacingY); // Higher row number = stacked higher

      // Calculate pseudo depth for Y-sorting (elements higher up might need to be drawn in front or behind depending on stacking strategy)
      // We will stack them upwards and slightly backwards for a nice isometric feel
      double zShift = row * (size * 0.2);
      double actualY = yBase - zShift;

      items.add({
        'x': x,
        'y': actualY,
        'sizeX': size,
        'sizeY': isFlat ? size * 0.2 : (isRod ? size * 3 : size),
        'row': row,
      });
    }

    // Sort: draw lowest rows first
    items.sort((a, b) => a['row'].compareTo(b['row']));

    for (var item in items) {
      _draw3DShape(
        canvas,
        item['x'],
        item['y'],
        item['sizeX'],
        item['sizeY'],
        color,
      );
    }
  }

  void _draw3DShape(
    Canvas canvas,
    double x,
    double y,
    double sizeX,
    double sizeY,
    Color color,
  ) {
    final depthMultiplier = 0.25;

    final fTL = Offset(x, y - sizeY);
    final fTR = Offset(x + sizeX, y - sizeY);
    final fBL = Offset(x, y);
    final fBR = Offset(x + sizeX, y);

    final bTL = Offset(
      fTL.dx + (vpX - fTL.dx) * depthMultiplier,
      fTL.dy + (vpY - fTL.dy) * depthMultiplier,
    );
    final bTR = Offset(
      fTR.dx + (vpX - fTR.dx) * depthMultiplier,
      fTR.dy + (vpY - fTR.dy) * depthMultiplier,
    );
    final bBL = Offset(
      fBL.dx + (vpX - fBL.dx) * depthMultiplier,
      fBL.dy + (vpY - fBL.dy) * depthMultiplier,
    );
    final bBR = Offset(
      fBR.dx + (vpX - fBR.dx) * depthMultiplier,
      fBR.dy + (vpY - fBR.dy) * depthMultiplier,
    );

    final paintFront = Paint()..color = color;
    final paintTop = Paint()..color = _lighten(color, 0.15);
    final paintSide = Paint()..color = _darken(color, 0.15);
    final paintBorder = Paint()
      ..color = _darken(color, 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Top Face
    final pathTop = Path()
      ..moveTo(fTL.dx, fTL.dy)
      ..lineTo(fTR.dx, fTR.dy)
      ..lineTo(bTR.dx, bTR.dy)
      ..lineTo(bTL.dx, bTL.dy)
      ..close();
    canvas.drawPath(pathTop, paintTop);
    canvas.drawPath(pathTop, paintBorder);

    // Side Face (Left or Right)
    if (x + sizeX / 2 > vpX) {
      // Show Left Face
      final pathLeft = Path()
        ..moveTo(fTL.dx, fTL.dy)
        ..lineTo(bTL.dx, bTL.dy)
        ..lineTo(bBL.dx, bBL.dy)
        ..lineTo(fBL.dx, fBL.dy)
        ..close();
      canvas.drawPath(pathLeft, paintSide);
      canvas.drawPath(pathLeft, paintBorder);
    } else {
      // Show Right Face
      final pathRight = Path()
        ..moveTo(fTR.dx, fTR.dy)
        ..lineTo(bTR.dx, bTR.dy)
        ..lineTo(bBR.dx, bBR.dy)
        ..lineTo(fBR.dx, fBR.dy)
        ..close();
      canvas.drawPath(pathRight, paintSide);
      canvas.drawPath(pathRight, paintBorder);
    }

    // Front Face
    final rectFront = Rect.fromLTRB(fTL.dx, fTL.dy, fBR.dx, fBR.dy);
    canvas.drawRect(rectFront, paintFront);
    canvas.drawRect(rectFront, paintBorder);

    // Shine effect
    final shinePath = Path()
      ..moveTo(fTL.dx + 2, fTL.dy + 2)
      ..lineTo(fTR.dx - 2, fTL.dy + 2)
      ..lineTo(fTL.dx + 2, fBL.dy - 2)
      ..close();
    canvas.drawPath(shinePath, Paint()..color = Colors.white.withOpacity(0.1));
  }

  Color _darken(Color c, [double amount = .1]) {
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lighten(Color c, [double amount = .1]) {
    final hsl = HSLColor.fromColor(c);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  @override
  bool shouldRepaint(CompositionPainter oldDelegate) => true;
}
