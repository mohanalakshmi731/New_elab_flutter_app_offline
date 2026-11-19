// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart'; // Add this to pubspec.yaml

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VirtualLabApp());
}

class VirtualLabApp extends StatelessWidget {
  const VirtualLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZSL Virtual Lab | Positional Systems',
      themeMode: ThemeMode.system,
      home: const PositionalPlaceValueScreen(),
    );
  }
}

class PositionalPlaceValueScreen extends StatefulWidget {
  const PositionalPlaceValueScreen({super.key});

  @override
  State<PositionalPlaceValueScreen> createState() =>
      _PositionalPlaceValueScreenState();
}

class _PositionalPlaceValueScreenState extends State<PositionalPlaceValueScreen>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool isDarkMode = true;
  String currentLang = 'en';
  bool isSidebarOpen = true;
  int currentStep = 0;
  double boardFontSize = 16.0;

  bool showShutter = true;
  bool showSettings = false;
  bool isTaskValidated = false;

  // --- App Interaction State ---
  int col60 = 0;
  int col1 = 0;
  int clockH = 0;
  int clockM = 0;
  int clockS = 0;
  dynamic quizSelection;
  int? finalAnswer;

  // Audio Player
  late AudioPlayer _audioPlayer;

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  // --- Theme Colors ---
  Color get bgColor =>
      isDarkMode ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
  Color get textColor =>
      isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textMuted =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get glassBg => isDarkMode
      ? const Color.fromRGBO(15, 23, 42, 0.75)
      : const Color.fromRGBO(255, 255, 255, 0.85);
  Color get glassBorder => isDarkMode
      ? const Color.fromRGBO(255, 255, 255, 0.1)
      : const Color.fromRGBO(0, 0, 0, 0.1);
  Color get primary => const Color(0xFFeab308); // ZSL Yellow

  // --- Constants & Translations ---
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'shutter_title': 'Positional (Place Value) Systems',
      'class_chapter': 'Class 8 • A Story of Numbers',
      'btn_enter': 'Enter Virtual Lab',
      'btn_validate': 'Validate Model',
      'btn_pending': 'Task Pending',
      'settings_title': 'Lab Settings',
      'settings_theme': 'Theme Preference',
      'settings_font': 'Task Font Size',
      'col60': '60s Column',
      'col10': '10s (Chevron)',
      'col1': '1s (Wedge)',
      'allOfThem': 'All of them',
      'hours': 'Hours',
      'minutes': 'Minutes',
      'seconds': 'Seconds',
      'totSeconds': 'Total Seconds',
      'msgCorrect': 'Correct! Excellent Work.',
      'msgComplete': 'Lab Complete! You mastered Base-60.',
      'msgError': 'Not quite right. Review the steps and try again.',
      'error_title': 'Incorrect Model',
      'interactiveModel': 'Interactive Model',
      'understood': 'Understood',
      'scenarios': [
        {
          'title': "1. The Babylonian Revolution",
          'task':
              "Use the HUD controls to place '1' wedge in the 60s column and '20' (two 10s) in the 1s column.",
          'hud': "Place 1 in 60s, and 20 in 1s.",
        },
        {
          'title': "2. Figure It Out (Base 60)",
          'task': "Form the number 75 on the 3D clay tablet.",
          'hud': "Form 75 using base 60 logic.",
        },
        {
          'title': "3. The Ambiguity Problem",
          'task':
              "Look at the single wedge on the tablet. Select all possible values it could represent from the HUD.",
          'hud': "What does one wedge mean without zero?",
        },
        {
          'title': "4. Base-60 in the Modern World",
          'task':
              "Set the modern clock values on the HUD to match the challenge: 2 Hours, 45 Mins, 20 Secs.",
          'hud': "Set clock to 02:45:20",
        },
        {
          'title': "5. Solving the Time Problem",
          'task':
              "Calculate the total seconds for 2h 45m 20s and enter the final total in the HUD.",
          'hud': "Calculate total seconds.",
        },
      ],
    },
    'hi': {
      'shutter_title': 'स्थानीय मान प्रणाली',
      'class_chapter': 'कक्षा 8 • संख्या की कहानी',
      'btn_enter': 'वर्चुअल लैब में प्रवेश करें',
      'btn_validate': 'मॉडल मान्य करें',
      'btn_pending': 'कार्य लंबित है',
      'settings_title': 'लैब सेटिंग्स',
      'settings_theme': 'थीम प्राथमिकता',
      'settings_font': 'कार्य फ़ॉन्ट आकार',
      'col60': '60 का कॉलम',
      'col10': '10 (शेवरॉन)',
      'col1': '1 (वेज)',
      'allOfThem': 'ये सभी',
      'hours': 'घंटे',
      'minutes': 'मिनट',
      'seconds': 'सेकंड',
      'totSeconds': 'कुल सेकंड',
      'msgCorrect': 'सही! उत्कृष्ट कार्य।',
      'msgComplete': 'लैब पूरा हुआ! आपने बेस-60 में महारत हासिल कर ली है।',
      'msgError':
          'बिल्कुल सही नहीं। चरणों की समीक्षा करें और पुनः प्रयास करें।',
      'error_title': 'गलत मॉडल',
      'interactiveModel': 'इंटरएक्टिव मॉडल',
      'understood': 'समझ गया',
      'scenarios': [
        {
          'title': "1. बेबीलोनियन क्रांति",
          'task':
              "HUD नियंत्रणों का उपयोग करके 60 के कॉलम में '1' वेज और 1 के कॉलम में '20' (दो 10) रखें।",
          'hud': "60 के कॉलम में 1, और 1 के कॉलम में 20 रखें।",
        },
        {
          'title': "2. इसे हल करें (बेस 60)",
          'task': "3D मिट्टी की गोली पर 75 संख्या बनाएं।",
          'hud': "बेस 60 तर्क का उपयोग करके 75 बनाएं।",
        },
        {
          'title': "3. अस्पष्टता की समस्या",
          'task':
              "टैबलेट पर एकल वेज को देखें। HUD से इसके सभी संभावित मानों का चयन करें।",
          'hud': "शून्य के बिना एक वेज का क्या अर्थ है?",
        },
        {
          'title': "4. आधुनिक दुनिया में बेस-60",
          'task':
              "चुनौती से मेल खाने के लिए HUD पर आधुनिक घड़ी मान सेट करें: 2 घंटे, 45 मिनट, 20 सेकंड।",
          'hud': "घड़ी को 02:45:20 पर सेट करें।",
        },
        {
          'title': "5. समय की समस्या को हल करना",
          'task':
              "2 घंटे 45 मिनट 20 सेकंड के लिए कुल सेकंड की गणना करें और HUD में अंतिम कुल दर्ज करें।",
          'hud': "कुल सेकंड की गणना करें।",
        },
      ],
    },
  };

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
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0)).animate(
          CurvedAnimation(
            parent: _shutterController,
            curve: Curves.easeInOutCubic,
          ),
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
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'success') {
        url =
            'audio/class8/mixkit_2013.mp3';
      } else if (type == 'click') {
        url =
            'audio/class8/mixkit_2568.mp3';
      } else if (type == 'error') {
        url =
            'audio/class8/mixkit_2955.mp3';
      }

      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _loadStep(int step) {
    setState(() {
      currentStep = step;
      isTaskValidated = false;
      col60 = 0;
      col1 = 0;
      clockH = 0;
      clockM = 0;
      clockS = 0;
      quizSelection = null;
      finalAnswer = null;

      if (step == 2) {
        col1 = 1; // Prepopulate 1 wedge for the ambiguity quiz
      }
    });
  }

  void _validate() {
    bool isCorrect = false;
    if (currentStep == 0) {
      isCorrect = col60 == 1 && col1 == 20;
    } else if (currentStep == 1) {
      isCorrect = col60 == 1 && col1 == 15;
    } else if (currentStep == 2) {
      isCorrect = quizSelection == 'all';
    } else if (currentStep == 3) {
      isCorrect = clockH == 2 && clockM == 45 && clockS == 20;
    } else if (currentStep == 4) {
      isCorrect = finalAnswer == 9920;
    }

    if (isCorrect) {
      HapticFeedback.lightImpact();
      _playSound('success');
      setState(() => isTaskValidated = true);
    } else {
      HapticFeedback.vibrate();
      _playSound('error');
      _showAlert(
        i18n[currentLang]!['error_title']!,
        i18n[currentLang]!['msgError']!,
      );
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassBorder),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(msg, style: TextStyle(color: textColor.withOpacity(0.9))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              i18n[currentLang]!['understood'],
              style: TextStyle(color: primary),
            ),
          ),
        ],
      ),
    );
  }

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
            color: glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glassBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 30,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard(Map<String, dynamic> scenarioData) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder),
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
              Icon(Icons.track_changes, color: primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scenarioData['title'],
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scenarioData['task'],
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: "Reset Step",
                icon: Icon(Icons.refresh, color: textMuted, size: 22),
                onPressed: () {
                  _playSound('click');
                  _loadStep(currentStep);
                },
              ),
              ElevatedButton.icon(
                onPressed: !isTaskValidated
                    ? () {
                        _playSound('click');
                        _validate();
                      }
                    : () {
                        _playSound('click');
                        if (currentStep < 4) {
                          _loadStep(currentStep + 1);
                        } else {
                          _loadStep(0);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isTaskValidated
                      ? primary
                      : (isTaskValidated
                            ? Colors.green
                            : (isDarkMode ? Colors.white12 : Colors.black12)),
                  disabledBackgroundColor: isDarkMode
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
                  !isTaskValidated
                      ? Icons.play_arrow
                      : (isTaskValidated ? Icons.check_circle : Icons.lock),
                  color: !isTaskValidated ? Colors.black : Colors.white,
                  size: 18,
                ),
                label: Text(
                  !isTaskValidated
                      ? i18n[currentLang]!['btn_validate']!
                      : (currentStep < 4 ? "Next Step" : "Restart"),
                  style: TextStyle(
                    color: !isTaskValidated ? Colors.black : Colors.white,
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

  Widget _buildSidebar(
    Map<String, dynamic> scenarioData,
    Map<String, dynamic> dict,
    double width,
  ) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: glassBg,
        border: Border(right: BorderSide(color: glassBorder)),
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
                    border: Border(bottom: BorderSide(color: glassBorder)),
                    color: isDarkMode
                        ? Colors.black12
                        : Colors.black.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: Icon(Icons.menu_open, color: textColor, size: 28),
                        onPressed: () {
                          _playSound('click');
                          setState(() => isSidebarOpen = false);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.science,
                              color: primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dict['shutter_title'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dict['class_chapter'],
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
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: "Toggle Language",
                              icon: Text(
                                currentLang.toUpperCase(),
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(
                                  () => currentLang = currentLang == 'en'
                                      ? 'hi'
                                      : 'en',
                                );
                              },
                            ),
                            // Container(width: 1, height: 24, color: glassBorder),
                            // IconButton(
                            //   tooltip: "Settings",
                            //   icon: Icon(Icons.settings, color: textMuted),
                            //   onPressed: () {
                            //     _playSound('click');
                            //     setState(() => showSettings = true);
                            //   },
                            // ),
                            Container(width: 1, height: 24, color: glassBorder),
                            IconButton(
                              tooltip: "Reset Step",
                              icon: Icon(Icons.refresh, color: textMuted),
                              onPressed: () {
                                _playSound('click');
                                _loadStep(currentStep);
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
                        // Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: glassBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: currentStep,
                              dropdownColor: bgColor,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: primary,
                              ),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  _playSound('click');
                                  _loadStep(val);
                                }
                              },
                              items: List.generate(5, (index) {
                                return DropdownMenuItem(
                                  value: index,
                                  child: Text(
                                    dict['scenarios'][index]['title'],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Target Output Card
                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Target Output",
                              style: TextStyle(
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
                          scenarioData['title'],
                          style: TextStyle(
                            color: textColor,
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
                            scenarioData['task'],
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.blue[100]
                                  : Colors.blue[900],
                              fontSize: boardFontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Actions Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: !isTaskValidated
                                ? () {
                                    _playSound('click');
                                    _validate();
                                  }
                                : () {
                                    _playSound('click');
                                    if (currentStep < 4) {
                                      _loadStep(currentStep + 1);
                                    } else {
                                      _loadStep(0);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !isTaskValidated
                                  ? primary
                                  : Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  !isTaskValidated
                                      ? Icons.play_arrow
                                      : Icons.check_circle,
                                  color: !isTaskValidated
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  !isTaskValidated
                                      ? dict['btn_validate']
                                      : (currentStep < 4
                                            ? "Next Step"
                                            : "Restart Lab"),
                                  style: TextStyle(
                                    color: !isTaskValidated
                                        ? Colors.black
                                        : Colors.white,
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

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black12
                        : Colors.black.withOpacity(0.05),
                    border: Border(top: BorderSide(color: glassBorder)),
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

  // --- HUD Controls ---
  Widget _buildHUDContent(Map<String, dynamic> dict) {
    if (currentStep < 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHUDStepper(dict['col60']!, col60, (v) {
            _playSound('click');
            setState(() => col60 = math.max(0, col60 + v));
          }),
          Container(
            width: 1,
            height: 40,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildHUDStepper(dict['col10']!, (col1 ~/ 10), (v) {
            _playSound('click');
            setState(() => col1 = math.max(0, col1 + (v * 10)));
          }),
          Container(
            width: 1,
            height: 40,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildHUDStepper(dict['col1']!, (col1 % 10), (v) {
            _playSound('click');
            setState(() => col1 = math.max(0, col1 + v));
          }),
        ],
      );
    } else if (currentStep == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuizBtn(1, '1'),
          const SizedBox(width: 8),
          _buildQuizBtn(60, '60'),
          const SizedBox(width: 8),
          _buildQuizBtn(3600, '3600'),
          const SizedBox(width: 8),
          _buildQuizBtn('all', dict['allOfThem']!),
        ],
      );
    } else if (currentStep == 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHUDStepper(dict['hours']!, clockH, (v) {
            _playSound('click');
            setState(() => clockH = math.max(0, clockH + v));
          }),
          const SizedBox(width: 16),
          _buildHUDStepper(dict['minutes']!, clockM, (v) {
            _playSound('click');
            setState(() => clockM = math.max(0, clockM + v));
          }),
          const SizedBox(width: 16),
          _buildHUDStepper(dict['seconds']!, clockS, (v) {
            _playSound('click');
            setState(() => clockS = math.max(0, clockS + v));
          }),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dict['totSeconds']!, style: TextStyle(color: textMuted)),
          const SizedBox(height: 8),
          SizedBox(
            width: 150,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primary, width: 3),
                ),
              ),
              onChanged: (v) {
                _playSound('click');
                setState(() => finalAnswer = int.tryParse(v));
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildHUDStepper(String label, int val, Function(int) onMod) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          children: [
            _btnSmall('-', () => onMod(-1)),
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                '$val',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _btnSmall('+', () => onMod(1)),
          ],
        ),
      ],
    );
  }

  Widget _btnSmall(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF334155) : Colors.black12,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizBtn(dynamic val, String label) {
    bool isSelected = quizSelection == val;
    return InkWell(
      onTap: () {
        _playSound('click');
        setState(() => quizSelection = val);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(0.3)
              : (isDarkMode ? const Color(0xFF334155) : Colors.black12),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primary : textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Canvas Interaction Area ---
  Widget _buildInteractiveArea() {
    bool isTabletMode = currentStep < 3;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Perspective Container
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(-0.6)
            ..rotateZ(0.2),
          alignment: FractionalOffset.center,
          child: isTabletMode
              ? CustomPaint(
                  size: const Size(600, 450), // Upscaled size
                  painter: TabletPainter(col60: col60, col1: col1),
                )
              : CustomPaint(
                  size: const Size(600, 600), // Upscaled size
                  painter: SundialPainter(
                    h: clockH,
                    m: clockM,
                    s: clockS,
                    lang: currentLang,
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dict = i18n[currentLang]!;
    final scenarioData = dict['scenarios'][currentStep];
    final size = MediaQuery.of(context).size;
    final double sidebarWidth = math.max(size.width * 0.3, 300.0);

    return Scaffold(
      backgroundColor: bgColor,
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
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/offline_texture.png'),
                    opacity: 0.05,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1, // Full zoom out allowed
                  maxScale: 4.0,
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
              left: isSidebarOpen ? sidebarWidth : 0,
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
                        dict['interactiveModel'].toString().toUpperCase(),
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHUDContent(dict),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Floating Mission Card
            if (!isSidebarOpen)
              Positioned(
                top: 70,
                left: 16,
                child: _buildFloatingMissionCard(scenarioData),
              ),

            // 4. Floating Menu & Back
            if (!isSidebarOpen)
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
                        setState(() => isSidebarOpen = true);
                      },
                    ),
                  ],
                ),
              ),

            // 5. Scrollable 30% Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(scenarioData, dict, sidebarWidth),
            ),

            // 6. Settings Modal
            if (showSettings)
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
                                Icon(Icons.settings, color: primary),
                                const SizedBox(width: 8),
                                Text(
                                  dict['settings_title'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: textColor),
                              onPressed: () {
                                _playSound('click');
                                setState(() => showSettings = false);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dict['settings_theme'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: primary,
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(() => isDarkMode = !isDarkMode);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dict['settings_font'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${boardFontSize.toInt()}px",
                              style: TextStyle(color: primary),
                            ),
                          ],
                        ),
                        Slider(
                          value: boardFontSize,
                          min: 14,
                          max: 32,
                          activeColor: primary,
                          onChanged: (val) =>
                              setState(() => boardFontSize = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 7. Initial Shutter Overlay
            if (showShutter)
              SlideTransition(
                position: _shutterAnimation,
                child: Container(
                  color: const Color(0xFF020617),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hexagon_outlined, size: 80, color: primary),
                      const SizedBox(height: 24),
                      Text(
                        dict['shutter_title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dict['class_chapter'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _playSound('success');
                          _shutterController.forward().then((_) {
                            setState(() => showShutter = false);
                          });
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.black),
                        label: Text(
                          dict['btn_enter'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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

// ============================================================================
// NATIVE FLUTTER 2.5D PAINTERS
// ============================================================================

class TabletPainter extends CustomPainter {
  final int col60;
  final int col1;

  TabletPainter({required this.col60, required this.col1});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    // 1. Draw Clay Tablet Base (Rounded Rectangle with Depth)
    final RRect tabletBase = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 15), width: 450, height: 300),
      const Radius.circular(24),
    );
    final RRect tabletTop = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: 450, height: 300),
      const Radius.circular(24),
    );

    final Paint basePaint = Paint()..color = const Color(0xFF8B7355);
    final Paint topPaint = Paint()..color = const Color(0xFFBFAE98);

    canvas.drawRRect(tabletBase, basePaint);
    canvas.drawRRect(tabletTop, topPaint);

    // 2. Draw Column Divider
    final Paint dividerPaint = Paint()
      ..color = const Color(0xFF8A7B68)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, -120), const Offset(0, 120), dividerPaint);

    // 3. Draw Wedges
    double xStart60 = -180;
    double yStart60 = -60;
    for (int i = 0; i < col60; i++) {
      double dx = xStart60 + (i % 3) * 45;
      double dy = yStart60 + (i ~/ 3) * 60;
      _drawWedge(canvas, Offset(dx, dy));
    }

    int tens = col1 ~/ 10;
    int ones = col1 % 10;

    double xStart10s = 60;
    double yStart10s = -60;
    for (int i = 0; i < tens; i++) {
      double dx = xStart10s + (i % 3) * 45;
      double dy = yStart10s + (i ~/ 3) * 60;
      _drawChevron(canvas, Offset(dx, dy));
    }

    double xStart1s = 60;
    double yStart1s = 30; // Shift down for ones
    for (int i = 0; i < ones; i++) {
      double dx = xStart1s + (i % 4) * 38;
      double dy = yStart1s + (i ~/ 4) * 60;
      _drawWedge(canvas, Offset(dx, dy));
    }
  }

  void _drawWedge(Canvas canvas, Offset pos) {
    final Path path = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx - 12, pos.dy - 45)
      ..lineTo(pos.dx + 12, pos.dy - 45)
      ..close();

    final Paint paint = Paint()..color = const Color(0xFF4A3B2C);
    final Paint highlight = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, highlight);
  }

  void _drawChevron(Canvas canvas, Offset pos) {
    final Path path = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx - 30, pos.dy - 18)
      ..lineTo(pos.dx - 18, pos.dy)
      ..lineTo(pos.dx - 30, pos.dy + 18)
      ..close();

    final Paint paint = Paint()..color = const Color(0xFF4A3B2C);
    final Paint highlight = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, highlight);
  }

  @override
  bool shouldRepaint(covariant TabletPainter oldDelegate) {
    return oldDelegate.col60 != col60 || oldDelegate.col1 != col1;
  }
}

class SundialPainter extends CustomPainter {
  final int h;
  final int m;
  final int s;
  final String lang;

  SundialPainter({
    required this.h,
    required this.m,
    required this.s,
    required this.lang,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.2;

    // 1. Draw Brass Base
    final Paint brassBase = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFFCE48B), Color(0xFFC29B27)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(
      center.translate(0, 10),
      radius,
      Paint()..color = const Color(0xFF8B6508),
    );
    canvas.drawCircle(center, radius, brassBase);

    final Paint engravePaint = Paint()
      ..color = const Color(0xFF110A05)
      ..style = PaintingStyle.stroke;

    // 2. Concentric Rings
    canvas.drawCircle(center, radius * 0.96, engravePaint..strokeWidth = 6);
    canvas.drawCircle(center, radius * 0.92, engravePaint..strokeWidth = 3);
    canvas.drawCircle(center, radius * 0.62, engravePaint..strokeWidth = 3);
    canvas.drawCircle(center, radius * 0.58, engravePaint..strokeWidth = 2);
    canvas.drawCircle(center, radius * 0.22, engravePaint..strokeWidth = 2);

    // 3. Roman Numerals & Ticks
    const List<String> numerals = [
      "VI",
      "VII",
      "VIII",
      "IX",
      "X",
      "XI",
      "XII",
      "I",
      "II",
      "III",
      "IV",
      "V",
    ];

    for (int i = 0; i < 12; i++) {
      double angle = (i * math.pi) / 6 + math.pi / 2;

      // Draw Ticks
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawLine(
        Offset(radius * 0.58, 0),
        Offset(radius * 0.62, 0),
        engravePaint..strokeWidth = 4,
      );
      canvas.drawLine(
        Offset(radius * 0.92, 0),
        Offset(radius * 0.96, 0),
        engravePaint..strokeWidth = 4,
      );
      canvas.restore();

      // Draw Numerals
      double textR = radius * 0.77;
      Offset textPos =
          center + Offset(math.cos(angle) * textR, math.sin(angle) * textR);

      canvas.save();
      canvas.translate(textPos.dx, textPos.dy);
      canvas.rotate(angle + math.pi / 2);

      TextPainter tp = TextPainter(
        text: TextSpan(
          text: numerals[i],
          style: const TextStyle(
            color: Color(0xFF110A05),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // 4. Center Compass Rose
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final Path rosePath = Path();
    for (int i = 0; i < 8; i++) {
      canvas.rotate(math.pi / 4);
      rosePath.moveTo(0, 0);
      rosePath.lineTo(radius * 0.04, radius * 0.16);
      rosePath.lineTo(0, radius * 0.5);
      rosePath.lineTo(-radius * 0.04, radius * 0.16);
      rosePath.close();
    }
    canvas.drawPath(rosePath, Paint()..color = const Color(0xFF110A05));
    canvas.restore();

    // 5. Engraved "Sunny Hours"
    TextPainter titleTp = TextPainter(
      text: TextSpan(
        text: lang == 'en' ? "Sunny Hours" : "धूप के घंटे",
        style: const TextStyle(
          color: Color(0xFF110A05),
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titleTp.layout();
    titleTp.paint(canvas, center + Offset(-titleTp.width / 2, radius * 0.7));

    // 6. Draw 3D Gnomon (The shadow caster)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final Path gnomon = Path()
      ..moveTo(0, 0)
      ..lineTo(radius * 0.45, 0)
      ..lineTo(radius * 0.1, -radius * 0.3)
      ..close();

    // Draw Gnomon Shadow
    double shadowAngle =
        ((h % 12) + (m / 60.0)) * (math.pi / 6) - (math.pi / 2);
    canvas.save();
    canvas.rotate(shadowAngle);
    final Path shadowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(radius * 0.45, 0)
      ..lineTo(radius * 0.2, radius * 0.2)
      ..close();
    canvas.drawPath(shadowPath, Paint()..color = Colors.black.withOpacity(0.4));
    canvas.restore();

    // Solid Gnomon
    final Paint gnomonPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawPath(gnomon, gnomonPaint);
    canvas.drawPath(
      gnomon,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SundialPainter oldDelegate) {
    return oldDelegate.h != h ||
        oldDelegate.m != m ||
        oldDelegate.s != s ||
        oldDelegate.lang != lang;
  }
}
