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
  runApp(const GlobalNumberPackersApp());
}

class GlobalNumberPackersApp extends StatefulWidget {
  const GlobalNumberPackersApp({super.key});

  @override
  State<GlobalNumberPackersApp> createState() => _GlobalNumberPackersAppState();
}

class _GlobalNumberPackersAppState extends State<GlobalNumberPackersApp>
    with TickerProviderStateMixin {
  bool _showShutter = true;
  bool _isSidebarOpen = true;
  int _currentScenario = 1;
  int _count = 0;
  bool _isCompleted = false;
  String _lang = 'EN';

  String? _feedbackMessage;
  bool _feedbackIsSuccess = false;
  bool _showFinalPopup = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Custom scenario state
  final List<Color> _blocks = [];
  bool _converted = false;
  int _phase = 1; // Used for Scenario 5
  final List<int> _commas = [];

  // --- Translation Dictionaries ---
  final Map<String, Map<String, String>> _translations = {
    'appTitle': {
      'en': 'The Global Number Packers',
      'hi': 'वैश्विक नंबर पैकर्स',
    },
    'appSubtitleLong': {
      'en': 'Class 7 • Indian vs. International Place Value Systems',
      'hi': 'कक्षा 7 • भारतीय बनाम अंतर्राष्ट्रीय प्रणालियाँ',
    },
    'appSubtitle': {
      'en': 'Class 7 • Indian vs. International',
      'hi': 'कक्षा 7 • भारतीय बनाम अंतर्राष्ट्रीय',
    },
    'enterLab': {'en': 'Enter Lab', 'hi': 'लैब में प्रवेश करें'},
    'selectScenario': {'en': 'SELECT SCENARIO', 'hi': 'परिदृश्य चुनें'},
    'missionObjective': {'en': 'Mission Objective', 'hi': 'मिशन का उद्देश्य'},
    'proceduralTask': {'en': 'Procedural Task', 'hi': 'प्रक्रियात्मक कार्य'},
    'taskPrefix': {'en': 'Task:', 'hi': 'कार्य:'},
    'interactiveControls': {
      'en': 'INTERACTIVE CONTROLS',
      'hi': 'इंटरैक्टिव नियंत्रण',
    },
    'validateModel': {'en': 'Validate Model', 'hi': 'मॉडल मान्य करें'},
    'validated': {'en': 'Validated', 'hi': 'मान्य किया गया'},
    'nextScenario': {'en': 'Next Scenario', 'hi': 'अगला परिदृश्य'},
    'finishLab': {'en': 'Finish Lab', 'hi': 'लैब समाप्त करें'},
    'labCompleted': {'en': 'Lab Completed!', 'hi': 'प्रयोगशाला पूरी हुई!'},
    'congrats': {
      'en':
          'Congratulations, you have successfully mastered both number systems!',
      'hi':
          'बधाई हो, आपने दोनों संख्या प्रणालियों में सफलतापूर्वक महारत हासिल कर ली है!',
    },
    'restartLab': {'en': 'Restart Lab', 'hi': 'पुनः प्रारंभ करें'},
    'footer': {
      'en': '© ZeroScienceLab - Fall in love with math and Science',
      'hi': '© ZeroScienceLab - Fall in love with math and Science',
    },
    // Scenarios
    'scen1': {
      'en': '1. The Indian Packing Warehouse',
      'hi': '1. भारतीय पैकिंग वेयरहाउस',
    },
    'scen2': {
      'en': '2. The International Shipping Dept.',
      'hi': '2. अंतर्राष्ट्रीय शिपिंग विभाग',
    },
    'scen3': {
      'en': '3. The Numeration Converter',
      'hi': '3. संख्यात्मक कनवर्टर',
    },
    'scen4': {
      'en': '4. The Global Data Report',
      'hi': '4. वैश्विक डेटा रिपोर्ट',
    },
    'scen5': {
      'en': '5. The Unformatted Number Puzzle',
      'hi': '5. बिना स्वरूपित संख्या पहेली',
    },

    // Place Values
    'arab': {'en': 'Arab', 'hi': 'अरब'},
    'crores': {'en': 'Crores', 'hi': 'करोड़'},
    'lakhs': {'en': 'Lakhs', 'hi': 'लाख'},
    'thousands': {'en': 'Thousands', 'hi': 'हज़ार'},
    'hundreds': {'en': 'Hundreds', 'hi': 'सौ'},
    'tens': {'en': 'Tens', 'hi': 'दहाई'},
    'ones': {'en': 'Ones', 'hi': 'इकाई'},
    'millions': {'en': 'Millions', 'hi': 'मिलियन'},

    'btnConvert': {'en': 'CONVERT SYSTEM', 'hi': 'सिस्टम बदलें'},
    'btnIndian': {'en': 'Indian Rules', 'hi': 'भारतीय नियम'},
    'btnIntl': {'en': 'International Rules', 'hi': 'अंतर्राष्ट्रीय नियम'},
    'current': {'en': 'Current:', 'hi': 'वर्तमान:'},
    'target': {'en': 'Target:', 'hi': 'लक्ष्य:'},
  };

  final Map<String, Map<String, String>> _validationMsgs = {
    'msgCorrect': {
      'en': 'Objective Complete! Excellent work.',
      'hi': 'उद्देश्य पूर्ण! बहुत बढ़िया।',
    },
    'msgWrong': {
      'en': 'Model inaccurate. Keep trying.',
      'hi': 'मॉडल गलत है। प्रयास जारी रखें।',
    },
    'msgPhase1Complete': {
      'en': 'Indian system correct! Now switch to International.',
      'hi': 'भारतीय प्रणाली सही है! अब अंतर्राष्ट्रीय पर स्विच करें।',
    },
  };

  final Map<int, Map<String, dynamic>> _scenarioData = {
    1: {
      'objective': {
        'en':
            'Physically construct a large number using the Indian place value system grouping.',
        'hi':
            'भारतीय स्थानीय मान प्रणाली के अनुसार एक बड़ी संख्या का निर्माण करें।',
      },
      'task': {
        'en':
            'Build 4,81,21,620 by adding the correct containers onto the warehouse belt.',
        'hi': 'गोदाम बेल्ट पर सही कंटेनरों को जोड़कर 4,81,21,620 बनाएं।',
      },
      'target': 48121620,
    },
    2: {
      'objective': {
        'en':
            'Construct the same quantity using the International place value system.',
        'hi':
            'अंतर्राष्ट्रीय स्थानीय मान प्रणाली का उपयोग करके समान मात्रा का निर्माण करें।',
      },
      'task': {
        'en':
            'Build 48,121,620 using International containers (Millions, Thousands).',
        'hi':
            'अंतर्राष्ट्रीय कंटेनरों (मिलियन, हजार) का उपयोग करके 48,121,620 बनाएं।',
      },
      'target': 48121620,
    },
    3: {
      'objective': {
        'en':
            'Understand that the total quantity remains the same when switching systems.',
        'hi': 'समझें कि सिस्टम बदलते समय कुल मात्रा समान रहती है।',
      },
      'task': {
        'en':
            'Click CONVERT to watch the machine repackage 1,02,03,04,050 into International format.',
        'hi':
            '1,02,03,04,050 को अंतर्राष्ट्रीय प्रारूप में बदलने के लिए CONVERT पर क्लिक करें।',
      },
      'target': 1020304050,
    },
    4: {
      'objective': {
        'en':
            'Convert an International report number (9,876,501,234) into the Indian System.',
        'hi':
            'एक अंतर्राष्ट्रीय रिपोर्ट संख्या (9,876,501,234) को भारतीय प्रणाली में बदलें।',
      },
      'task': {
        'en':
            'Add Indian containers to build the equivalent of 9 Billion, 876 Million, 501 Thousand, 234.',
        'hi':
            'भारतीय कंटेनरों को जोड़कर 9 बिलियन, 876 मिलियन... के बराबर बनाएं।',
      },
      'target': 9876501234,
    },
    5: {
      'objective': {
        'en':
            'Apply comma placement rules for both systems to an unformatted string of digits.',
        'hi':
            'अंकों की एक बिना स्वरूपित स्ट्रिंग पर दोनों प्रणालियों के लिए अल्पविराम प्लेसमेंट नियम लागू करें।',
      },
      'task': {
        'en':
            'Click the gaps between numbers to place commas. First for Indian, then International.',
        'hi': 'अल्पविराम लगाने के लिए संख्याओं के बीच के अंतराल पर क्लिक करें।',
      },
      'target': 0, // Handled specially
    },
  };

  String t(String key) {
    final l = _lang.toLowerCase();
    return _translations[key]?[l] ?? _translations[key]?['en'] ?? key;
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
      _blocks.clear();
      _converted = false;
      _phase = 1;
      _commas.clear();

      if (id == 3) {
        _count = 1020304050;
        for (int i = 0; i < 30; i++) {
          _blocks.add(const Color(0xFF6366F1));
        }
      } else if (id == 4) {
        _count = 4; // Start with 4 to save clicks as per HTML logic
      } else {
        _count = 0;
      }
    });
  }

  void _validate() {
    final langKey = _lang.toLowerCase();
    bool isCorrect = false;
    t('msgCorrect');

    if (_currentScenario == 3) {
      isCorrect = _converted;
    } else if (_currentScenario == 5) {
      final cStr = (_commas.toList()..sort()).join(",");
      if (_phase == 1) {
        // Target Indian: 34,50,00,543 -> Gaps at 1, 3, 5
        isCorrect = cStr == "1,3,5";
        if (isCorrect) {
          _playSound('success');
          setState(() {
            _feedbackIsSuccess = true;
            _feedbackMessage = _validationMsgs['msgPhase1Complete']![langKey]!;
            _phase = 2;
            _commas.clear();
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _feedbackMessage = null);
          });
          return; // Don't complete scenario yet
        }
      } else if (_phase == 2) {
        // Target Intl: 345,000,543 -> Gaps at 2, 5
        isCorrect = cStr == "2,5";
      }
    } else {
      final target = _scenarioData[_currentScenario]!['target'] as int;
      isCorrect = _count == target;
    }

    setState(() {
      if (isCorrect) {
        _playSound('success');
        _feedbackIsSuccess = true;
        _feedbackMessage = _validationMsgs['msgCorrect']![langKey]!;
        _isCompleted = true;
      } else {
        _playSound('error');
        _feedbackIsSuccess = false;
        _feedbackMessage = _validationMsgs['msgWrong']![langKey]!;

        // Reset blocks visually
        if (_currentScenario == 1 ||
            _currentScenario == 2 ||
            _currentScenario == 4) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted && !_isCompleted) {
              setState(() {
                if (_currentScenario == 4) {
                  _count = 4;
                } else {
                  _count = 0;
                }
                _blocks.clear();
              });
            }
          });
        }
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
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
    });
    _loadScenario(1);
  }

  String _formatNumber(int num, String system) {
    if (num == 0) return "0";
    String str = num.toString();
    if (system == 'indian') {
      // Format as Indian: ##,##,##,###
      String result = '';
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        result = str[i] + result;
        count++;
        if (i > 0 && ((count == 3) || (count > 3 && (count - 3) % 2 == 0))) {
          result = ',$result';
        }
      }
      return result;
    } else {
      // Format as International: ###,###,###
      String result = '';
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        result = str[i] + result;
        count++;
        if (i > 0 && count % 3 == 0) {
          result = ',$result';
        }
      }
      return result;
    }
  }

  void _addBlock(int val, Color color) {
    _playSound('click');
    setState(() {
      _count += val;
      _blocks.add(color);
      // Limit visual blocks to avoid clutter
      if (_blocks.length > 50) _blocks.removeAt(0);
    });
  }

  Widget _buildControls() {
    switch (_currentScenario) {
      case 1:
        // Indian: 4,81,21,620
        final btns1 = [
          {
            'val': 10000000,
            'label': 'crores',
            'prefix': '+1',
            'color': const Color(0xFF8B5CF6),
          },
          {
            'val': 1000000,
            'label': 'lakhs',
            'prefix': '+10',
            'color': const Color(0xFFEF4444),
          },
          {
            'val': 100000,
            'label': 'lakhs',
            'prefix': '+1',
            'color': const Color(0xFFF97316),
          },
          {
            'val': 10000,
            'label': 'thousands',
            'prefix': '+10',
            'color': const Color(0xFFEAB308),
          },
          {
            'val': 1000,
            'label': 'thousands',
            'prefix': '+1',
            'color': const Color(0xFF22C55E),
          },
          {
            'val': 100,
            'label': 'hundreds',
            'prefix': '+1',
            'color': const Color(0xFF0EA5E9),
          },
          {
            'val': 10,
            'label': 'tens',
            'prefix': '+1',
            'color': const Color(0xFF64748B),
          },
        ];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: btns1.map((b) => _buildBlockButton(b)).toList(),
        );

      case 2:
        // Intl: 48,121,620
        final btns2 = [
          {
            'val': 10000000,
            'label': 'millions',
            'prefix': '+10',
            'color': const Color(0xFF8B5CF6),
          },
          {
            'val': 1000000,
            'label': 'millions',
            'prefix': '+1',
            'color': const Color(0xFFEF4444),
          },
          {
            'val': 100000,
            'label': 'thousands',
            'prefix': '+100',
            'color': const Color(0xFFF97316),
          },
          {
            'val': 10000,
            'label': 'thousands',
            'prefix': '+10',
            'color': const Color(0xFFEAB308),
          },
          {
            'val': 1000,
            'label': 'thousands',
            'prefix': '+1',
            'color': const Color(0xFF22C55E),
          },
          {
            'val': 100,
            'label': 'hundreds',
            'prefix': '+1',
            'color': const Color(0xFF0EA5E9),
          },
          {
            'val': 10,
            'label': 'tens',
            'prefix': '+1',
            'color': const Color(0xFF64748B),
          },
        ];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: btns2.map((b) => _buildBlockButton(b)).toList(),
        );

      case 3:
        return Center(
          child: ElevatedButton.icon(
            onPressed: _converted
                ? null
                : () {
                    _playSound('click');
                    setState(() {
                      _converted = true;
                      for (int i = 0; i < _blocks.length; i++) {
                        _blocks[i] = const Color(0xFF14B8A6); // Turn teal
                      }
                    });
                  },
            icon: const Icon(Icons.settings, color: Colors.white),
            label: Text(
              t('btnConvert'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );

      case 4:
        // Indian: 9,87,65,01,234
        final btns4 = [
          {
            'val': 1000000000,
            'label': 'arab',
            'prefix': '+1',
            'color': const Color(0xFF4F46E5),
          },
          {
            'val': 100000000,
            'label': 'crores',
            'prefix': '+10',
            'color': const Color(0xFF8B5CF6),
          },
          {
            'val': 10000000,
            'label': 'crores',
            'prefix': '+1',
            'color': const Color(0xFFEF4444),
          },
          {
            'val': 1000000,
            'label': 'lakhs',
            'prefix': '+10',
            'color': const Color(0xFFF97316),
          },
          {
            'val': 100000,
            'label': 'lakhs',
            'prefix': '+1',
            'color': const Color(0xFFEAB308),
          },
          {
            'val': 10000,
            'label': 'thousands',
            'prefix': '+10',
            'color': const Color(0xFF22C55E),
          },
          {
            'val': 1000,
            'label': 'thousands',
            'prefix': '+1',
            'color': const Color(0xFF10B981),
          },
          {
            'val': 100,
            'label': 'hundreds',
            'prefix': '+1',
            'color': const Color(0xFF0EA5E9),
          },
          {
            'val': 10,
            'label': 'tens',
            'prefix': '+1',
            'color': const Color(0xFF64748B),
          },
        ];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: btns4.map((b) => _buildBlockButton(b)).toList(),
        );

      case 5:
        // Comma Puzzle
        String str = "345000543";
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _phase == 1
                        ? Colors.orange[500]
                        : Colors.orange[500]?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: _phase == 1
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Text(
                    t('btnIndian'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _phase == 2
                        ? Colors.blue[500]
                        : Colors.blue[500]?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: _phase == 2
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Text(
                    t('btnIntl'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[500]!, width: 2),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(str.length * 2 - 1, (index) {
                    if (index % 2 == 0) {
                      // Character
                      return Text(
                        str[index ~/ 2],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      );
                    } else {
                      // Gap
                      int gapIndex = index ~/ 2;
                      bool hasComma = _commas.contains(gapIndex);
                      return GestureDetector(
                        onTap: () {
                          _playSound('click');
                          setState(() {
                            if (hasComma) {
                              _commas.remove(gapIndex);
                            } else {
                              _commas.add(gapIndex);
                            }
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 36,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            hasComma ? "," : "",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[400],
                              height: 0.5,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBlockButton(Map<String, dynamic> b) {
    return ElevatedButton(
      onPressed: () => _addBlock(b['val'] as int, b['color'] as Color),
      style: ElevatedButton.styleFrom(
        backgroundColor: b['color'] as Color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Text(
        '${b['prefix']} ${t(b['label'] as String)}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusDisplay() {
    if (_currentScenario == 5) {
      return const SizedBox.shrink(); // Handled internally
    }

    String valStr = "";
    if (_currentScenario == 1 || _currentScenario == 4) {
      valStr = _formatNumber(_count, 'indian');
    } else if (_currentScenario == 2 || _currentScenario == 3) {
      if (_currentScenario == 3 && _converted) {
        valStr = _formatNumber(_count, 'intl');
      } else if (_currentScenario == 3 && !_converted) {
        valStr = _formatNumber(_count, 'indian');
      } else {
        valStr = _formatNumber(_count, 'intl');
      }
    }

    final target = _scenarioData[_currentScenario]!['target'] as int;
    String targetStr = _currentScenario == 1 || _currentScenario == 4
        ? _formatNumber(target, 'indian')
        : _formatNumber(target, 'intl');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal[500]!.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            valStr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.teal[400],
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          if (_currentScenario !=
              3) // S3 doesn't really need target display in same way
            Text(
              "${t('target')} $targetStr",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sidebarWidth = max(sw * 0.33, 320.0);
    final data = _scenarioData[_currentScenario]!;
    final langKey = _lang.toLowerCase();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1220), // Matched dark navy base
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
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: SizedBox(
                      width: 1200,
                      height: 800,
                      child: CustomPaint(
                        painter: WarehousePainter(
                          _blocks,
                          _currentScenario,
                          _count,
                        ),
                        willChange: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. Floating Mission Card (when sidebar is closed) ---
            if (!_isSidebarOpen && !_showShutter)
              Positioned(
                top: 70,
                left: 10,
                width: 280,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 70,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.track_changes, color: Colors.teal[500]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t('missionObjective'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.teal[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['objective'][langKey],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${t('taskPrefix')} ${data['task'][langKey]}",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),

                        Text(
                          t('interactiveControls'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusDisplay(),
                        if (_currentScenario != 5) const SizedBox(height: 12),
                        Center(child: _buildControls()),

                        const SizedBox(height: 16),

                        // Validate Button
                        ElevatedButton.icon(
                          onPressed: _isCompleted ? null : _validate,
                          icon: Icon(
                            _isCompleted
                                ? Icons.check_circle
                                : Icons.fact_check,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isCompleted ? t('validated') : t('validateModel'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCompleted
                                ? Colors.green[600]
                                : Colors.blueGrey[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: _isCompleted
                                    ? Colors.green[400]!
                                    : Colors.white24,
                              ),
                            ),
                          ),
                        ),

                        if (_isCompleted) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _nextScenario,
                            icon: Icon(
                              _currentScenario < 5
                                  ? Icons.arrow_forward
                                  : Icons.flag,
                              size: 18,
                            ),
                            label: Text(
                              _currentScenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[400],
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // --- 3. Sidebar (Completely Scrollable) ---
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
                          // Header
                          Container(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 60,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.teal[900]?.withOpacity(
                                          0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2,
                                        size: 34,
                                        color: Colors.teal[400],
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
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
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
                                const SizedBox(height: 6),
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

                          // Scrollable Content Body
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
                                          _playSound('click');
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
                                        color: Colors.teal[500],
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
                                              color: Colors.tealAccent,
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

                                  Text(
                                    t('interactiveControls'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatusDisplay(),
                                  if (_currentScenario != 5)
                                    const SizedBox(height: 16),
                                  Center(child: _buildControls()),

                                  const SizedBox(height: 24),

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
                                          : Colors.blueGrey[800],
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

            // --- 4. Menu Icon (Top Left) ---
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.tealAccent,
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
                      side: BorderSide(color: Colors.teal.withOpacity(0.8)),
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
                                color: Colors.teal[400],
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
                            Icons.inventory_2,
                            size: 80,
                            color: Colors.teal[400],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('appTitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.teal[400],
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
                              color: Colors.black,
                              size: 28,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[500],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.teal[500]!.withOpacity(0.5),
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
class WarehousePainter extends CustomPainter {
  final List<Color> blocks;
  final int scenario;
  final int count;

  // Vanishing Point details
  final double vpX = 0.0;
  final double vpY = -200.0;

  WarehousePainter(this.blocks, this.scenario, this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    // 1. Sky (Solid Dark Navy)
    final skyRect = Rect.fromLTRB(-cx, -cy, cx, -40);
    final skyPaint = Paint()..color = const Color(0xFF0C1220);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Central Platform Base (Replacing conveyor belt)
    final double pWidth = 760;
    final double pFrontY = 70;
    final double pBackY = 10;
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

    // 4. Crates Stacked in 1-Point Perspective
    final double boxSize = 60;
    final int cols = 10;
    // Center the crates exactly on the platform
    double startX = -((cols * (boxSize + 10)) - 10) / 2;

    int maxRows = (blocks.length / cols).ceil();

    // Custom Z-Sorting painter algorithm for 1-point perspective:
    // Outer objects must be drawn first so inner objects overlap their side faces correctly.
    for (int row = 0; row < maxRows; row++) {
      // Draw left half (Outside-In)
      for (int col = 0; col < 5; col++) {
        int i = row * cols + col;
        if (i < blocks.length) {
          _drawBlock(canvas, startX, row, col, boxSize, blocks[i]);
        }
      }
      // Draw right half (Outside-In)
      for (int col = cols - 1; col >= 5; col--) {
        int i = row * cols + col;
        if (i < blocks.length) {
          _drawBlock(canvas, startX, row, col, boxSize, blocks[i]);
        }
      }
    }

    // 5. Draw the "Machine" overlay for Scenario 3
    if (scenario == 3) {
      _drawMachine(canvas, size, count);
    }
  }

  void _drawBlock(
    Canvas canvas,
    double startX,
    int row,
    int col,
    double boxSize,
    Color color,
  ) {
    double x = startX + (col * (boxSize + 10));
    double y = 10 - (row * (boxSize + 5)); // Stack upwards
    _drawCrate(canvas, x, y, boxSize, color);
  }

  void _drawCrate(Canvas canvas, double x, double y, double size, Color color) {
    // Determine 3D depth relative to Vanishing Point
    final depthMultiplier = 0.20; // Extends 20% toward vanishing point

    // Front face corners
    final fTL = Offset(x, y);
    final fTR = Offset(x + size, y);
    final fBL = Offset(x, y + size);
    final fBR = Offset(x + size, y + size);

    // Back face corners (projected towards VP)
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
      ..color = _darken(color, 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 1. Draw Top Face
    final pathTop = Path()
      ..moveTo(fTL.dx, fTL.dy)
      ..lineTo(fTR.dx, fTR.dy)
      ..lineTo(bTR.dx, bTR.dy)
      ..lineTo(bTL.dx, bTL.dy)
      ..close();
    canvas.drawPath(pathTop, paintTop);
    canvas.drawPath(pathTop, paintBorder);

    // 2. Draw Side Face (Left or Right depending on position relative to VP)
    if (x + size / 2 > vpX) {
      // Crate is right of center -> Show Left Face
      final pathLeft = Path()
        ..moveTo(fTL.dx, fTL.dy)
        ..lineTo(bTL.dx, bTL.dy)
        ..lineTo(bBL.dx, bBL.dy)
        ..lineTo(fBL.dx, fBL.dy)
        ..close();
      canvas.drawPath(pathLeft, paintSide);
      canvas.drawPath(pathLeft, paintBorder);
    } else {
      // Crate is left of center -> Show Right Face
      final pathRight = Path()
        ..moveTo(fTR.dx, fTR.dy)
        ..lineTo(bTR.dx, bTR.dy)
        ..lineTo(bBR.dx, bBR.dy)
        ..lineTo(fBR.dx, fBR.dy)
        ..close();
      canvas.drawPath(pathRight, paintSide);
      canvas.drawPath(pathRight, paintBorder);
    }

    // 3. Draw Front Face
    final rectFront = Rect.fromLTWH(x, y, size, size);
    canvas.drawRect(rectFront, paintFront);
    canvas.drawRect(rectFront, paintBorder);

    // 4. Subtle Cross Marks (Crate Detail)
    canvas.drawLine(fTL, fBR, paintBorder);
    canvas.drawLine(fTR, fBL, paintBorder);
  }

  void _drawMachine(Canvas canvas, Size size, int count) {
    final boardPaint = Paint()
      ..color = const Color(0xFF0F172A).withOpacity(0.95);
    final borderPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: const Offset(0, -150),
      width: 450,
      height: 120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      boardPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      borderPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: const TextStyle(
          color: Colors.tealAccent,
          fontSize: 48,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -150 - textPainter.height / 2),
    );
  }

  Color _darken(Color c, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lighten(Color c, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(c);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  @override
  bool shouldRepaint(WarehousePainter oldDelegate) =>
      oldDelegate.blocks.length != blocks.length ||
      oldDelegate.scenario != scenario ||
      oldDelegate.count != count;
}
