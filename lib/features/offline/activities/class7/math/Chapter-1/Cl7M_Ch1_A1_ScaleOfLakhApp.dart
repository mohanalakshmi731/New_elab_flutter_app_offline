// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScaleOfLakhApp());
}

class ScaleOfLakhApp extends StatefulWidget {
  const ScaleOfLakhApp({super.key});

  @override
  State<ScaleOfLakhApp> createState() => _ScaleOfLakhAppState();
}

class _ScaleOfLakhAppState extends State<ScaleOfLakhApp>
    with TickerProviderStateMixin {
  bool _showShutter = true;
  bool _isSidebarOpen = true;
  int _currentScenario = 1;
  int _count = 0;
  int _day = 0;
  int _rate = 1;
  bool _isCompleted = false;
  String _lang = 'EN';

  String? _feedbackMessage;
  bool _feedbackIsSuccess = false;
  bool _showFinalPopup = false;

  Timer? _simTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Data for 100k points (Scenario 1)
  late Float32List _ricePoints;

  // --- Translation Dictionaries ---
  final Map<String, Map<String, String>> _translations = {
    'appTitle': {'en': 'The Scale of a Lakh', 'hi': 'एक लाख का पैमाना'},
    'appSubtitleLong': {
      'en': 'Class 7 • Understanding and Visualizing Large Numbers',
      'hi': 'कक्षा 7 • बड़ी संख्याओं को समझना और देखना',
    },
    'appSubtitle': {
      'en': 'Class 7 • Large Numbers',
      'hi': 'कक्षा 7 • बड़ी संख्याएँ',
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
          'Congratulations, you have successfully visualized the scale of a Lakh!',
      'hi': 'बधाई हो, आपने सफलतापूर्वक एक लाख के पैमाने की कल्पना की है!',
    },
    'restartLab': {'en': 'Restart Lab', 'hi': 'पुनः प्रारंभ करें'},
    'footer': {
      'en': '© ZeroScienceLab - Fall in love with math and Science',
      'hi': '© ZeroScienceLab - Fall in love with math and Science',
    },
    'grains': {'en': 'Grains', 'hi': 'दाने'},
    'seated': {'en': 'Seated', 'hi': 'बैठे हैं'},
    'varietyDay': {'en': 'Variety/Day', 'hi': 'किस्म/दिन'},
    'varietiesDay': {'en': 'Varieties / Day', 'hi': 'किस्में / दिन'},
    'simulateLife': {'en': 'Simulate Lifetime', 'hi': 'जीवनकाल अनुकरण करें'},
    'days': {'en': 'Days:', 'hi': 'दिन:'},
    'tasted': {'en': 'Tasted:', 'hi': 'चखा:'},
    'stackHeight': {'en': 'Stack Height:', 'hi': 'ढेर की ऊंचाई:'},
    'current': {'en': 'Current:', 'hi': 'वर्तमान:'},
    'target': {'en': 'Target:', 'hi': 'लक्ष्य:'},
    'varieties': {'en': 'Varieties', 'hi': 'किस्में'},
  };

  final Map<String, Map<String, String>> _validationMsgs = {
    'objComplete': {
      'en': 'Objective Complete! You hit the target.',
      'hi': 'उद्देश्य पूर्ण! लक्ष्य हासिल किया।',
    },
    'objCompleteLife': {
      'en': 'Surpassed the 1,00,000 goal in a lifetime!',
      'hi': 'जीवनकाल में 1,00,000 पार किया!',
    },
    'modelInacc': {'en': 'Model inaccurate.', 'hi': 'मॉडल गलत है।'},
    'shortTarget': {
      'en': 'Short of the target.',
      'hi': 'आप लक्ष्य से पीछे हैं।',
    },
    'exceedTarget': {
      'en': 'Exceeded the target.',
      'hi': 'आपने लक्ष्य पार कर लिया है।',
    },
    'failLife': {
      'en': 'Fell short! Select higher rate.',
      'hi': 'पीछे रह गए! उच्च दर चुनें।',
    },
  };

  final Map<int, Map<String, dynamic>> _scenarioData = {
    1: {
      'title': {
        'en': '1. The One Lakh Rice Field',
        'hi': '1. एक लाख चावल का खेत',
      },
      'objective': {
        'en':
            'Visually comprehend the sheer quantity of 1,00,000 by filling a virtual field with rice grains.',
        'hi': 'वर्चुअल खेत को चावल के दानों से भरकर 1,00,000 को समझें।',
      },
      'task': {
        'en': 'Add 1,00,000 grains to the field. Start with chunks of 10,000.',
        'hi': '10,000 के टुकड़ों में दाने जोड़ें।',
      },
      'target': 100000,
    },
    2: {
      'title': {'en': '2. The Stadium Sell-Out', 'hi': '2. स्टेडियम सेल-आउट'},
      'objective': {
        'en':
            'Understand that the perception of a large number\'s size is relative to its container.',
        'hi': 'समझें कि बड़ी संख्या कंटेनर के सापेक्ष होती है।',
      },
      'task': {
        'en':
            'Adjust the slider to seat exactly 1,00,000 people in the 1,32,000 capacity stadium.',
        'hi': '1,00,000 लोगों को बैठाने के लिए स्लाइडर को समायोजित करें।',
      },
      'target': 100000,
    },
    3: {
      'title': {
        'en': '3. The Place Value Builder',
        'hi': '3. स्थानीय मान निर्माता',
      },
      'objective': {
        'en':
            'Understand the composition of a 5-digit number by building it with physical blocks.',
        'hi': 'ब्लॉकों के साथ बनाकर 5-अंकीय संख्या को समझें।',
      },
      'task': {
        'en':
            'Build the number 75,432 using the fewest possible clicks on the place value buttons.',
        'hi': 'न्यूनतम क्लिक का उपयोग करके 75,432 संख्या बनाएं।',
      },
      'target': 75432,
    },
    4: {
      'title': {'en': '4. The Lifetime of Rice', 'hi': '4. चावल का जीवनकाल'},
      'objective': {
        'en':
            'Determine if it\'s possible to taste 1,00,000 varieties of rice in a 100-year lifetime (36,500 days).',
        'hi':
            'निर्धारित करें कि क्या 100 साल के जीवनकाल में 1,00,000 किस्मों का स्वाद लेना संभव है।',
      },
      'task': {
        'en':
            'Select a rate of varieties per day to reach 1,00,000 in a lifetime.',
        'hi': 'जीवन भर में 1,00,000 तक पहुँचने के लिए दर का चयन करें।',
      },
      'target': 100000,
    },
    5: {
      'title': {
        'en': '5. The Coin Skyscraper',
        'hi': '5. सिक्का गगनचुंबी इमारत',
      },
      'objective': {
        'en':
            'Estimate and build a stack of 1mm coins to match the height of the 180-meter Statue of Unity.',
        'hi':
            '180 मीटर स्टैच्यू की ऊंचाई से मेल खाने के लिए सिक्कों के ढेर का निर्माण करें।',
      },
      'task': {
        'en': 'Add coins to build a 180m stack. Note: 1 coin = 1mm.',
        'hi': '180 मीटर का ढेर बनाने के लिए सिक्के जोड़ें। 1 सिक्का = 1 मिमी।',
      },
      'target': 180000,
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

    _generateRicePoints();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _simTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateRicePoints() {
    final rand = Random();
    _ricePoints = Float32List(100000 * 2);
    for (int i = 0; i < 100000; i++) {
      _ricePoints[i * 2] = rand.nextDouble() * 1000 - 500; // X
      _ricePoints[i * 2 + 1] = rand.nextDouble() * 800 - 400; // Y
    }
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
    _simTimer?.cancel();
    setState(() {
      _currentScenario = id;
      _count = 0;
      _day = 0;
      _rate = 1;
      _isCompleted = false;
      _feedbackMessage = null;
    });
  }

  void _validate() {
    final target = _scenarioData[_currentScenario]!['target'] as int;
    final langKey = _lang.toLowerCase();
    bool isCorrect = false;
    String msgKey = 'objComplete';

    if (_currentScenario == 4) {
      isCorrect = _count >= target;
      if (isCorrect) msgKey = 'objCompleteLife';
    } else {
      isCorrect = _count == target;
    }

    setState(() {
      if (isCorrect) {
        _playSound('success');
        _feedbackIsSuccess = true;
        _feedbackMessage = _validationMsgs[msgKey]![langKey]!;
        _isCompleted = true;
      } else {
        _playSound('error');
        _feedbackIsSuccess = false;

        msgKey = 'modelInacc';
        if (_count < target) msgKey = 'shortTarget';
        if (_count > target) msgKey = 'exceedTarget';
        if (_currentScenario == 4 && _count < target) msgKey = 'failLife';

        _feedbackMessage = _validationMsgs[msgKey]![langKey]!;

        // Snap back for scenarios 3 and 5
        if (_currentScenario == 3 || _currentScenario == 5) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() => _count = 0);
              _playSound('click');
            }
          });
        }
      }
    });

    // Hide feedback after delay
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

  Widget _buildControls() {
    switch (_currentScenario) {
      case 1:
        return ElevatedButton.icon(
          onPressed: () {
            _playSound('click');
            if (_count < 100000) setState(() => _count += 10000);
          },
          icon: const Icon(Icons.add, color: Colors.black),
          label: Text(
            '+10,000 ${t('grains')}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[600],
            minimumSize: const Size(double.infinity, 50),
          ),
        );
      case 2:
        return Column(
          children: [
            Slider(
              value: _count.toDouble(),
              min: 0,
              max: 132000,
              divisions: 132,
              activeColor: Colors.yellow[600],
              onChangeStart: (_) => _playSound('click'), // Added sound
              onChanged: (val) {
                setState(() => _count = val.toInt());
              },
              onChangeEnd: (_) => _playSound('click'), // Added sound
            ),
            Text(
              '${_count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / 132,000 ${t('seated')}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      case 3:
        final vals = [10000, 1000, 100, 10, 1];
        final colors = [
          Colors.blue,
          Colors.teal,
          Colors.green,
          Colors.orange,
          Colors.deepOrange,
        ];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(
            5,
            (i) => ElevatedButton(
              onPressed: () {
                _playSound('click');
                setState(() => _count += vals[i]);
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors[i]),
              child: Text(
                '+${vals[i]}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      case 4:
        return Column(
          children: [
            DropdownButtonFormField<int>(
              onTap: () =>
                  _playSound('click'), // Added click sound on dropdown open
              value: _rate,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: t('varietiesDay'),
                labelStyle: const TextStyle(color: Colors.white70),
              ),
              items: [1, 2, 3]
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        '$v ${t('varietyDay')}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  _playSound('click'); // Sound on selection
                  setState(() => _rate = val);
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _day > 0 && _day < 36500
                  ? null
                  : () {
                      _playSound('click');
                      setState(() => _day = 0);
                      _simTimer?.cancel();
                      _simTimer = Timer.periodic(
                        const Duration(milliseconds: 20),
                        (timer) {
                          setState(() {
                            _day += 365;
                            if (_day >= 36500) {
                              _day = 36500;
                              timer.cancel();
                            }
                            _count = _day * _rate;
                          });
                        },
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                t('simulateLife'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      case 5:
        final vals = [1000, 10000, 100000];
        return Row(
          children: vals
              .map(
                (v) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _playSound('click');
                        setState(() => _count += v);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[600],
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        '+${v >= 1000 ? '${v ~/ 1000}k' : v}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusDisplay() {
    String statusText = "";
    if (_currentScenario == 4) {
      statusText =
          "${t('days')} ${_day.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} | ${t('tasted')} ${_count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / 100,000";
    } else if (_currentScenario == 5) {
      statusText =
          "${t('stackHeight')} ${(_count * 0.001).toStringAsFixed(1)}m / 180m";
    } else {
      final target = _scenarioData[_currentScenario]!['target'] as int;
      statusText =
          "${t('current')} ${_count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / ${t('target')} ${target.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sidebarWidth = max(sw * 0.35, 340.0);
    final data = _scenarioData[_currentScenario]!;
    final langKey = _lang.toLowerCase();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
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
                color: const Color(0xFF0F172A),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.2,
                  maxScale: 5.0,
                  child: Center(
                    child: SizedBox(
                      width: 1000,
                      height: 800,
                      child: CustomPaint(
                        painter: _getPainterForScenario(),
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
                left: 10, // give space for the menu button
                width: 280, // Keeps it compact
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 70,
                  ),
                  padding: const EdgeInsets.all(16),
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
                            Icon(
                              Icons.track_changes,
                              color: Colors.yellow[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t('missionObjective'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.yellow,
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
                        _buildControls(),
                        const SizedBox(height: 12),
                        _buildStatusDisplay(),

                        const SizedBox(height: 16),

                        // Validate Button
                        ElevatedButton.icon(
                          onPressed: _isCompleted ? null : _validate,
                          icon: Icon(
                            _isCompleted
                                ? Icons.check_circle
                                : Icons.fact_check,
                            size: 18,
                            color: _isCompleted
                                ? Colors.green[400]
                                : Colors.white,
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
                                : Colors.black45,
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
                              backgroundColor: Colors.yellow[600],
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

            // --- Feedback Overlay ---
            if (_feedbackMessage != null && !_showShutter)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.2,
                left: 0,
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
                              top: 70,
                              bottom: 16,
                            ), // space for menu icon
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row with Icon and Title
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow[900]?.withOpacity(
                                          0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.bubble_chart,
                                        size: 34,
                                        color: Colors.yellow[600],
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
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            t('appSubtitle'),
                                            style: TextStyle(
                                              fontSize: 12,
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

                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Language Toggle
                                    InkWell(
                                      onTap: () {
                                        _playSound('click');
                                        setState(() {
                                          _lang = _lang == 'EN' ? 'HI' : 'EN';
                                        });
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
                                    const SizedBox(width: 8),
                                    // Reset Action
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
                                  // Scenario Selector
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
                                        onTap: () => _playSound(
                                          'click',
                                        ), // Added click sound
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
                                                  e.value['title'][langKey],
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
                                          _playSound(
                                            'click',
                                          ); // Sound on selection change
                                          if (val != null) {
                                            _loadScenario(val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.track_changes,
                                        color: Colors.yellow[700],
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
                                              color: Colors.orangeAccent,
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

                                  // Interactive Controls
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
                                  _buildControls(),
                                  const SizedBox(height: 16),
                                  _buildStatusDisplay(),

                                  const SizedBox(height: 24),

                                  // Validate Button
                                  ElevatedButton.icon(
                                    onPressed: _isCompleted ? null : _validate,
                                    icon: Icon(
                                      _isCompleted
                                          ? Icons.check_circle
                                          : Icons.fact_check,
                                      size: 20,
                                    ),
                                    label: Text(
                                      _isCompleted
                                          ? t('validated')
                                          : t('validateModel'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isCompleted
                                          ? Colors.green[600]
                                          : Colors.black45,
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
                                        backgroundColor: Colors.yellow[600],
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
                                color: Colors.yellow[600],
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
                                  backgroundColor: Colors.yellow[600],
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
                          Text(
                            t('appTitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.yellow[600],
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
                              backgroundColor: Colors.yellow[600],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.yellow[600]!.withOpacity(0.5),
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

  CustomPainter _getPainterForScenario() {
    switch (_currentScenario) {
      case 1:
        return FieldPainter(_count, _ricePoints);
      case 2:
        return StadiumPainter(_count);
      case 3:
        return BlocksPainter(_count);
      case 4:
        return TimelinePainter(_count, _day, t('varieties'));
      case 5:
        return CoinStackPainter(_count);
      default:
        return FieldPainter(0, _ricePoints);
    }
  }
}

// --- Custom Painters for Scenarios ---

class FieldPainter extends CustomPainter {
  final int count;
  final Float32List points;

  FieldPainter(this.count, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    // Field Background
    final Rect fieldRect = Rect.fromCenter(
      center: Offset.zero,
      width: 1000,
      height: 800,
    );
    final paintBg = Paint()..color = const Color(0xFF5C4018);
    canvas.drawRect(fieldRect, paintBg);

    // Grid lines for texture
    final gridPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (double x = -500; x <= 500; x += 80) {
      canvas.drawLine(Offset(x, -400), Offset(x, 400), gridPaint);
    }
    for (double y = -400; y <= 400; y += 50) {
      canvas.drawLine(Offset(-500, y), Offset(500, y), gridPaint);
    }

    final borderPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(fieldRect, borderPaint);

    if (count > 0) {
      // Draw points extremely fast using drawRawPoints
      final Paint ricePaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      // Draw only up to count
      final int elementsToDraw = min(count, 100000) * 2;
      final Float32List activePoints = Float32List.view(
        points.buffer,
        0,
        elementsToDraw,
      );

      canvas.drawRawPoints(PointMode.points, activePoints, ricePaint);
    }
  }

  @override
  bool shouldRepaint(FieldPainter oldDelegate) => oldDelegate.count != count;
}

class StadiumPainter extends CustomPainter {
  final int count;
  StadiumPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    final bgPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 600, height: 400),
      bgPaint,
    );

    final pitchPaint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 300, height: 200),
      pitchPaint,
    );

    final perc = count / 132000.0;
    if (perc > 0) {
      canvas.save();
      final crowdPaint = Paint()
        ..color = Colors.yellow[600]!.withOpacity(0.9)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, 0);
      path.arcTo(
        Rect.fromCenter(center: Offset.zero, width: 600, height: 600),
        -pi / 2,
        (pi * 2 * perc),
        false,
      );
      path.lineTo(0, 0);

      canvas.clipPath(path);

      final fillPath = Path()
        ..addOval(Rect.fromCenter(center: Offset.zero, width: 600, height: 400))
        ..addOval(
          Rect.fromCenter(center: Offset.zero, width: 300, height: 200),
        );
      fillPath.fillType = PathFillType.evenOdd;

      canvas.drawPath(fillPath, crowdPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StadiumPainter oldDelegate) => oldDelegate.count != count;
}

class BlocksPainter extends CustomPainter {
  final int count;
  BlocksPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    int remains = count;
    final blocks = [
      {
        'val': 10000,
        'color': const Color(0xFF3B82F6),
        'w': 80.0,
        'h': 80.0,
        'sp': 5.0,
      },
      {
        'val': 1000,
        'color': const Color(0xFF14B8A6),
        'w': 80.0,
        'h': 10.0,
        'sp': 2.0,
      },
      {
        'val': 100,
        'color': const Color(0xFF22C55E),
        'w': 10.0,
        'h': 80.0,
        'sp': 2.0,
      },
      {
        'val': 10,
        'color': const Color(0xFFEAB308),
        'w': 10.0,
        'h': 10.0,
        'sp': 2.0,
      },
      {
        'val': 1,
        'color': const Color(0xFFF97316),
        'w': 3.0,
        'h': 3.0,
        'sp': 2.0,
      },
    ];

    double startY = -200;

    for (var blk in blocks) {
      int val = blk['val'] as int;
      int num = remains ~/ val;
      remains %= val;

      if (num > 0) {
        final paint = Paint()..color = blk['color'] as Color;
        double w = blk['w'] as double;
        double h = blk['h'] as double;
        double sp = blk['sp'] as double;

        double startX = -300;
        for (int i = 0; i < num; i++) {
          canvas.drawRect(Rect.fromLTWH(startX, startY, w, h), paint);
          startX += w + sp;
          if (startX > 300) {
            startX = -300;
            startY += h + sp;
          }
        }
        startY += h + 20; // Row spacing
      }
    }
  }

  @override
  bool shouldRepaint(BlocksPainter oldDelegate) => oldDelegate.count != count;
}

class TimelinePainter extends CustomPainter {
  final int count;
  final int day;
  final String varietiesText;

  TimelinePainter(this.count, this.day, this.varietiesText);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    const double w = 600;

    // Base Line
    final linePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-w / 2, 0), const Offset(w / 2, 0), linePaint);

    // End posts
    canvas.drawRect(
      Rect.fromLTWH(-w / 2 - 5, -20, 10, 40),
      Paint()..color = const Color(0xFF22C55E),
    );
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - 5, -20, 10, 40),
      Paint()..color = const Color(0xFFEF4444),
    );

    // Progress
    double perc = min(1.0, day / 36500.0);
    double curX = (-w / 2) + (perc * w);

    final highlightPaint = Paint()
      ..color = const Color(0xFFEAB308)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-w / 2, 0), Offset(curX, 0), highlightPaint);

    // Marker
    final path = Path()
      ..moveTo(curX, 0)
      ..lineTo(curX - 10, -25)
      ..lineTo(curX + 10, -25)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFEAB308));

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text:
            "${count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} $varietiesText",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(curX - textPainter.width / 2, -55));
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) =>
      oldDelegate.count != count ||
      oldDelegate.day != day ||
      oldDelegate.varietiesText != varietiesText;
}

class CoinStackPainter extends CustomPainter {
  final int count;
  CoinStackPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    // Ground
    final groundPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 4;
    canvas.drawLine(
      const Offset(-300, 200),
      const Offset(300, 200),
      groundPaint,
    );

    // Statue Scale (180m = 360px tall)
    canvas.drawRect(
      Rect.fromLTWH(-150, 200 - 360, 60, 360),
      Paint()..color = const Color(0xFF475569),
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: "180m",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-120 - textPainter.width / 2, 200 - 180));

    // Stack
    const double maxPixels = 360;
    double stackHeight = min((count / 180000.0) * maxPixels, maxPixels);
    const double coinWidth = 70;
    const double stackX = 50;
    const double baseBottom = 200;

    if (count > 0 && stackHeight > 0) {
      // Main Body
      canvas.drawRect(
        Rect.fromLTWH(
          stackX - coinWidth / 2,
          baseBottom - stackHeight,
          coinWidth,
          stackHeight,
        ),
        Paint()..color = const Color(0xFFFBBF24),
      );

      // Texture lines
      final linePaint = Paint()
        ..color = const Color(0xFFB45309)
        ..strokeWidth = 1;
      for (double y = baseBottom; y > baseBottom - stackHeight; y -= 4) {
        canvas.drawLine(
          Offset(stackX - coinWidth / 2, y),
          Offset(stackX + coinWidth / 2, y),
          linePaint,
        );
      }

      // Top Ellipse
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(stackX, baseBottom - stackHeight),
          width: coinWidth,
          height: 10,
        ),
        Paint()..color = const Color(0xFFFCD34D),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(stackX, baseBottom - stackHeight),
          width: coinWidth,
          height: 10,
        ),
        Paint()
          ..color = const Color(0xFFB45309)
          ..style = PaintingStyle.stroke,
      );

      // Bottom Curve
      final path = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(stackX, baseBottom),
            width: coinWidth,
            height: 10,
          ),
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB45309)
          ..style = PaintingStyle.stroke,
      );

      // Label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: "${(count * 0.001).toStringAsFixed(1)}m",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          stackX + coinWidth / 2 + 15,
          baseBottom - max(stackHeight / 2, 10),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CoinStackPainter oldDelegate) =>
      oldDelegate.count != count;
}
