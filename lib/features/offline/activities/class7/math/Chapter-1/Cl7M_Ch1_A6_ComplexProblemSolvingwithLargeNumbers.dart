// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ComplexProblemSolvingwithLargeNumbers(),
    ),
  );
}

class ComplexProblemSolvingwithLargeNumbers extends StatefulWidget {
  const ComplexProblemSolvingwithLargeNumbers({super.key});

  @override
  State<ComplexProblemSolvingwithLargeNumbers> createState() =>
      _ComplexProblemSolvingwithLargeNumbersState();
}

class _ComplexProblemSolvingwithLargeNumbersState
    extends State<ComplexProblemSolvingwithLargeNumbers>
    with TickerProviderStateMixin {
  // Global State
  bool _isCurtainVisible = true;
  bool _isCurtainRendered = true;
  int _scenario = 1;
  int _step = 1;
  bool _isSidebarOpen = true;
  bool _stepCompleted = false;

  // Default language set to EN
  String _language = 'EN';

  // Canvas Control State
  final TransformationController _transformationController =
      TransformationController();

  // Scenario 1 State
  int _daysPassed = 0;
  Timer? _fastForwardTimer;
  late AnimationController _scaleAnimController;

  // Scenario 2 State
  double _stadiumFillRatio = 0.0;
  bool _stadiumOverflow = false;

  // Audio Players
  late AudioPlayer _audioPlayerPop;
  late AudioPlayer _audioPlayerSuccess;
  late AudioPlayer _audioPlayerError;

  // Dictionary for Localized Strings
  final Map<String, Map<String, String>> _translations = {
    'EN': {
      'title': 'A Feel for Large Numbers: From Rice Grains to Global Journeys',
      'subtitle': 'Class 7 • Large Numbers Around Us',
      'enter_lab': 'Enter Virtual Lab',
      'short_title': 'A Feel for Large Numbers',
      'short_subtitle': 'Class 7 • Large Numbers',
      'select_scenario': 'Select Scenario',
      'scenario_1_name': '1: The Rice Lifetime Challenge',
      'scenario_2_name': '2: The Stadium Capacity',
      'scenario_1_title': 'The Rice Lifetime Challenge',
      'scenario_2_title': 'The Stadium Capacity Challenge',
      'mission_objective': 'MISSION OBJECTIVE',
      'procedure': 'PROCEDURE',
      'step': 'STEP',
      'validate_model': 'Validate Model',
      'next_step': 'Next Step',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'obj_1_1':
          'Determine if a person could taste 1,00,000 different varieties of rice in a 100-year lifetime.',
      'obj_1_2': 'Simulate tasting rice for an entire 100-year lifetime.',
      'obj_1_3': 'Compare the tasted rice with the remaining rice.',
      'obj_2_1':
          'Check if the 2011 population of Chintamani (75,000) fits in a 1,00,000 capacity stadium.',
      'obj_2_2': 'See what happens with the 2024 population (1,06,000).',
      'obj_2_3': 'Review the stadium capacity limits.',
      'step_1_1':
          "DRAG the 'Tasting Spoon' icon onto the first day of the calendar.",
      'step_1_2':
          "CLICK and HOLD the Fast Forward button to simulate the entire lifetime.",
      'step_1_3': "CLICK the \"Compare\" button.",
      'step_2_1': "DRAG the container of 75,000 people onto the stadium.",
      'step_2_2': "DRAG the new container of 1,06,000 people onto the stadium.",
      'step_2_3': "Observe the summary equation on the screen.",
      'remaining': 'Remaining',
      'tasted': 'Tasted',
      'comparison_scale': 'Comparison Scale',
      'tasting_spoon': 'Tasting Spoon\n(Drag Me)',
      'day_1': 'Day 1',
      'drop_spoon': 'Drop Spoon Here',
      'hold_fast_forward': 'Hold to Fast Forward 100 Years',
      'compare': 'Compare',
      'stadium_capacity': 'Stadium Capacity',
      'left_outside': 'LEFT OUTSIDE',
      'drop_here': 'DROP HERE',
      'stadium_entrance': 'STADIUM ENTRANCE',
      'summary': 'SUMMARY',
      's1_sum_1': '36,500 is much less than 1,00,000.',
      's1_sum_2':
          'You would not even taste half the varieties in a lifetime!\n\nThis shows us how truly massive a number like one lakh (1,00,000) is when put into the perspective of human daily experiences.',
      'proceed_s2': 'Proceed to Scenario 2',
      's2_sum_1': 'The 2024 population is greater than the stadium capacity:',
      's2_sum_2':
          'The 2024 population is 6,000 more than the stadium\'s one lakh capacity.\n\nVisualizing large crowds helps us grasp numbers that go beyond our everyday counting.',
      'restart_lab': 'Restart Lab',
      'zoom_in': 'Zoom In',
      'zoom_out': 'Zoom Out',
      'reset_view': 'Reset View',
      'reset_lab': 'Reset Lab',
      'chintamani': 'Chintamani',
      'cricket_stadium': 'Cricket Stadium',
      'chintamani_pop': 'CHINTAMANI\nPOPULATION',
    },
    'HI': {
      'title': 'बड़ी संख्याओं का एहसास: चावल के दानों से वैश्विक यात्राओं तक',
      'subtitle': 'कक्षा 7 • हमारे आसपास की बड़ी संख्याएँ',
      'enter_lab': 'वर्चुअल लैब में प्रवेश करें',
      'short_title': 'बड़ी संख्याओं का एहसास',
      'short_subtitle': 'कक्षा 7 • बड़ी संख्याएँ',
      'select_scenario': 'परिदृश्य चुनें',
      'scenario_1_name': '1: चावल जीवनकाल चुनौती',
      'scenario_2_name': '2: स्टेडियम की क्षमता',
      'scenario_1_title': 'चावल जीवनकाल चुनौती',
      'scenario_2_title': 'स्टेडियम की क्षमता चुनौती',
      'mission_objective': 'मिशन का उद्देश्य',
      'procedure': 'प्रक्रिया',
      'step': 'चरण',
      'validate_model': 'मॉडल को मान्य करें',
      'next_step': 'अगला कदम',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'obj_1_1':
          'निर्धारित करें कि क्या कोई व्यक्ति 100 साल के जीवनकाल में 1,00,000 विभिन्न प्रकार के चावल का स्वाद ले सकता है।',
      'obj_1_2': 'पूरे 100 साल के जीवनकाल के लिए चावल चखने का अनुकरण करें।',
      'obj_1_3': 'चखे गए चावल की तुलना बचे हुए चावल से करें।',
      'obj_2_1':
          'जांचें कि क्या चिंतामणि (75,000) की 2011 की आबादी 1,00,000 क्षमता वाले स्टेडियम में फिट बैठती है।',
      'obj_2_2': 'देखें कि 2024 की आबादी (1,06,000) के साथ क्या होता है।',
      'obj_2_3': 'स्टेडियम की क्षमता सीमा की समीक्षा करें।',
      'step_1_1': "'चखने वाले चम्मच' आइकन को कैलेंडर के पहले दिन पर खींचें।",
      'step_1_2':
          "पूरे जीवनकाल का अनुकरण करने के लिए फास्ट फॉरवर्ड बटन को दबाकर रखें।",
      'step_1_3': "\"तुलना करें\" बटन पर क्लिक करें।",
      'step_2_1': "75,000 लोगों के कंटेनर को स्टेडियम पर खींचें।",
      'step_2_2': "1,06,000 लोगों के नए कंटेनर को स्टेडियम पर खींचें।",
      'step_2_3': "स्क्रीन पर सारांश समीकरण का निरीक्षण करें।",
      'remaining': 'शेष',
      'tasted': 'चखा गया',
      'comparison_scale': 'तुलना पैमाना',
      'tasting_spoon': 'चखने का चम्मच\n(मुझे खींचें)',
      'day_1': 'दिन 1',
      'drop_spoon': 'चम्मच यहाँ छोड़ें',
      'hold_fast_forward': '100 साल आगे बढ़ाने के लिए दबाकर रखें',
      'compare': 'तुलना करें',
      'stadium_capacity': 'स्टेडियम की क्षमता',
      'left_outside': 'बाहर रह गए',
      'drop_here': 'यहाँ छोड़ें',
      'stadium_entrance': 'स्टेडियम',
      'summary': 'सारांश',
      's1_sum_1': '36,500, 1,00,000 से बहुत कम है।',
      's1_sum_2':
          'आप जीवन भर में आधी किस्मों का भी स्वाद नहीं ले पाएंगे!\n\nयह हमें दिखाता है कि मानव के दैनिक अनुभवों के परिप्रेक्ष्य में एक लाख (1,00,000) जैसी संख्या वास्तव में कितनी विशाल है।',
      'proceed_s2': 'परिदृश्य 2 पर आगे बढ़ें',
      's2_sum_1': '2024 की आबादी स्टेडियम की क्षमता से अधिक है:',
      's2_sum_2':
          '2024 की आबादी स्टेडियम की एक लाख क्षमता से 6,000 अधिक है।\n\nबड़ी भीड़ की कल्पना करने से हमें उन संख्याओं को समझने में मदद मिलती है जो हमारी रोज़मर्रा की गिनती से परे हैं।',
      'restart_lab': 'लैब को फिर से शुरू करें',
      'zoom_in': 'ज़ूम इन',
      'zoom_out': 'ज़ूम आउट',
      'reset_view': 'दृश्य रीसेट करें',
      'reset_lab': 'लैब रीसेट करें',
      'chintamani': 'चिंतामणि',
      'cricket_stadium': 'क्रिकेट स्टेडियम',
      'chintamani_pop': 'चिंतामणि\nजनसंख्या',
    },
  };

  // Function to get translation
  String _t(String key) {
    return _translations[_language]?[key] ?? key;
  }

  // Function to format numbers using the Indian Number System
  String _formatIndianNumber(int number) {
    String str = number.toString();
    if (str.length <= 3) return str;
    String result = str.substring(str.length - 3);
    str = str.substring(0, str.length - 3);
    while (str.length > 2) {
      result = '${str.substring(str.length - 2)},$result';
      str = str.substring(0, str.length - 2);
    }
    if (str.isNotEmpty) {
      result = '$str,$result';
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _scaleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _initAudio();
  }

  // Audio initialization
  Future<void> _initAudio() async {
    _audioPlayerPop = AudioPlayer();
    _audioPlayerSuccess = AudioPlayer();
    _audioPlayerError = AudioPlayer();
  }

  // Function to play sound
  void _playSound(String type) {
    try {
      if (type == 'pop') {
        _audioPlayerPop.play(
          AssetSource(
            'audio/class7/mixkit_1114.mp3',
          ),
        );
      } else if (type == 'success') {
        _audioPlayerSuccess.play(
          AssetSource(
            'audio/class7/mixkit_2013.mp3',
          ),
        );
      } else if (type == 'error') {
        _audioPlayerError.play(
          AssetSource(
            'audio/class7/mixkit_2954.mp3',
          ),
        );
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _transformationController.dispose();
    _fastForwardTimer?.cancel();
    _scaleAnimController.dispose();
    _audioPlayerPop.dispose();
    _audioPlayerSuccess.dispose();
    _audioPlayerError.dispose();
    super.dispose();
  }

  void _startLab() {
    _playSound('pop');
    setState(() {
      _isCurtainVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isCurtainRendered = false;
      });
    });
  }

  void _resetLab() {
    _playSound('pop');
    setState(() {
      _isCurtainRendered = true;
      _isCurtainVisible = true;
      _loadScenario(1);
    });
  }

  void _toggleLanguage() {
    _playSound('pop');
    setState(() {
      _language = _language == 'EN' ? 'HI' : 'EN';
    });
  }

  void _loadScenario(int scenarioId) {
    setState(() {
      _scenario = scenarioId;
      _step = 1;
      _stepCompleted = false;
      _daysPassed = 0;
      _stadiumFillRatio = 0.0;
      _stadiumOverflow = false;
      _scaleAnimController.reset();
      _fastForwardTimer?.cancel();
      _transformationController.value = Matrix4.identity();
    });
  }

  void _nextStep() {
    if (_step == 3) {
      _showSummaryDialog();
      return;
    }
    setState(() {
      _step++;
      _stepCompleted = false;
    });
  }

  void _showSummaryDialog() {
    _playSound('success');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: const Border(
                top: BorderSide(color: Colors.indigo, width: 8),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _loadScenario(_scenario == 1 ? 2 : 1);
                      });
                    },
                  ),
                ),
                Text(
                  _t('summary'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _scenario == 1
                        ? _buildS1Summary()
                        : _buildS2Summary(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _getStepsForCurrentScenario() {
    return _scenario == 1
        ? [_t('step_1_1'), _t('step_1_2'), _t('step_1_3')]
        : [_t('step_2_1'), _t('step_2_2'), _t('step_2_3')];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.1,
                      maxScale: 5.0,
                      boundaryMargin: const EdgeInsets.all(2000),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _scenario == 1
                              ? _buildScenario1Canvas()
                              : _buildScenario2Canvas(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Mission Card
            if (!_isSidebarOpen && !_isCurtainVisible)
              Positioned(top: 80, left: 16, child: _buildFloatingMissionCard()),

            // Left Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Menu Icon Button
            if (!_isCurtainVisible)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.orangeAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
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

            // Curtain Screen
            if (_isCurtainRendered)
              Positioned.fill(child: _buildCurtainScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainScreen() {
    return AnimatedOpacity(
      opacity: _isCurtainVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.biotech,
                  size: 100,
                  color: Colors.indigoAccent,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _t('title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('subtitle'),
                  style: const TextStyle(fontSize: 22, color: Colors.grey),
                ),
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  onPressed: _startLab,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _t('enter_lab'),
                    style: const TextStyle(fontSize: 22),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    String objective = _getObjective();
    List<String> steps = _getStepsForCurrentScenario();
    String currentInstruction = steps[_step - 1];

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: const Border(left: BorderSide(color: Colors.orange, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                _t('mission_objective'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            objective,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Text(
            "${_t('step')} $_step",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentInstruction,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          if (_stepCompleted) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _nextStep,
              icon: Icon(_step == 3 ? Icons.check_circle : Icons.arrow_forward),
              label: Text(_step == 3 ? _t('validate_model') : _t('next_step')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 70,
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.biotech,
                                  color: Colors.indigoAccent,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _t('short_title'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _t('short_subtitle'),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: _toggleLanguage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.indigo.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    _language,
                                    style: const TextStyle(
                                      color: Colors.indigoAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                                onPressed: _resetLab,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: _t('reset_lab'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _t('select_scenario'),
                            style: const TextStyle(
                              color: Colors.grey,
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
                              border: Border.all(color: Colors.indigo),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _scenario,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                onChanged: (val) {
                                  if (val != null) _loadScenario(val);
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text(_t('scenario_1_name')),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text(_t('scenario_2_name')),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _scenario == 1
                                  ? _t('scenario_1_title')
                                  : _t('scenario_2_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: const Border(
                                  left: BorderSide(
                                    color: Colors.orange,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _t('mission_objective'),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getObjective(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _t('procedure'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._buildStepsList(),
                          ],
                        ),
                      ),
                    ),
                    if (_stepCompleted)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _nextStep,
                          icon: Icon(
                            _step == 3
                                ? Icons.check_circle
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            _step == 3 ? _t('validate_model') : _t('next_step'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(top: BorderSide(color: Colors.white10)),
                      ),
                      child: Text(
                        _t('footer'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
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
    );
  }

  List<Widget> _buildStepsList() {
    List<String> steps = _getStepsForCurrentScenario();

    return List.generate(steps.length, (index) {
      bool isCurrent = _step == (index + 1);
      bool isPast = _step > (index + 1);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? Colors.orange
              : (isPast ? Colors.white10 : const Color(0xFF0F172A)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_t('step')} ${index + 1}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.black87 : Colors.grey,
                decoration: isPast ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[index],
              style: TextStyle(
                fontSize: 14,
                color: isCurrent ? Colors.black : Colors.white70,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                decoration: isPast ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getObjective() {
    if (_scenario == 1) {
      if (_step == 1) return _t('obj_1_1');
      if (_step == 2) return _t('obj_1_2');
      if (_step == 3) return _t('obj_1_3');
    } else {
      if (_step == 1) return _t('obj_2_1');
      if (_step == 2) return _t('obj_2_2');
      if (_step == 3) return _t('obj_2_3');
    }
    return "";
  }

  Widget _buildTooltipLabel(
    String text,
    Color bgColor, {
    Color textColor = Colors.white,
    double pointerHeight = 8,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ClipPath(
          clipper: TriangleClipper(),
          child: Container(width: 16, height: pointerHeight, color: bgColor),
        ),
      ],
    );
  }

  // ----------- Scenario 1: Rice Canvas -----------

  Widget _buildScenario1Canvas() {
    int remaining = 100000 - _daysPassed;
    int tasted = _daysPassed;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 800,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_step < 3)
                    Column(
                      children: [
                        _buildLabel(
                          "${_formatIndianNumber(remaining)}\n${_t('remaining')}",
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 250,
                          height: 200,
                          child: CustomPaint(
                            painter: GrainHillPainter(
                              fillPercentage: remaining / 100000,
                              color: Colors.amber[200]!,
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (_step == 3)
                    AnimatedBuilder(
                      animation: _scaleAnimController,
                      builder: (context, child) {
                        double rotation = _scaleAnimController.value * 0.2;
                        return SizedBox(
                          width: 600,
                          height: 500,
                          child: CustomPaint(
                            painter: BalanceScalePainter(
                              rotation: rotation,
                              tastedText: "36,500",
                              tastedLabel: _t('tasted'),
                              remainingText: "63,500",
                              remainingLabel: _t('remaining'),
                            ),
                          ),
                        );
                      },
                    ),

                  if (_step < 3)
                    Column(
                      children: [
                        _buildLabel(
                          "${_formatIndianNumber(tasted)}\n${_t('tasted')}",
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          height: 160,
                          child: CustomPaint(
                            painter: GrainHillPainter(
                              fillPercentage: tasted / 100000,
                              color: Colors.orange[300]!,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),

        if (_step == 1 && !_stepCompleted)
          Positioned(
            top: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Draggable<String>(
                  data: 'spoon',
                  feedback: Material(
                    color: Colors.transparent,
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        _t('tasting_spoon'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 200),
                DragTarget<String>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    if (details.data == 'spoon') {
                      _playSound('pop');
                      setState(() {
                        _daysPassed = 1;
                        _stepCompleted = true;
                      });
                      _playSound('success');
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty
                            ? Colors.indigo.withOpacity(0.5)
                            : Colors.white10,
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? Colors.orange
                              : Colors.grey,
                          width: 4,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 50,
                            color: Colors.indigoAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _t('day_1'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _t('drop_spoon'),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

        if (_step == 2 && !_stepCompleted)
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onLongPressStart: (_) {
                _playSound('pop');
                _fastForwardTimer = Timer.periodic(
                  const Duration(milliseconds: 40),
                  (timer) {
                    setState(() {
                      _daysPassed += 365;
                      if (_daysPassed >= 36500) {
                        _daysPassed = 36500;
                        _stepCompleted = true;
                        _fastForwardTimer?.cancel();
                        _playSound('success');
                      }
                    });
                  },
                );
              },
              onLongPressEnd: (_) {
                _fastForwardTimer?.cancel();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(color: Colors.amberAccent, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fast_forward,
                      size: 30,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _t('hold_fast_forward'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (_step == 3 && !_stepCompleted)
          Positioned(
            bottom: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                _playSound('pop');
                _scaleAnimController.forward().then((_) {
                  setState(() {
                    _stepCompleted = true;
                  });
                  _playSound('success');
                });
              },
              icon: const Icon(Icons.balance, size: 28),
              label: Text(_t('compare'), style: const TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ----------- Scenario 2: Stadium Canvas -----------

  Widget _buildScenario2Canvas() {
    String popText = _step == 1 ? "75,000" : "1,06,000";
    String popYear = _step == 1 ? "2011" : "2024";

    return SizedBox(
      width: 1000,
      height: 600,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Clean Pedestal Platform Background
          Positioned.fill(child: CustomPaint(painter: CleanFloorPainter())),

          // 2. Clean 3D Stadium
          Positioned(
            child: CustomPaint(
              size: const Size(
                1000,
                600,
              ), // Paint gets full access, draws centrally
              painter: Stadium3DPainter(
                fillRatio: _stadiumFillRatio,
                capacityText: _t('stadium_capacity'),
              ),
            ),
          ),

          // 3. Stadium Label - Hovering Top Center
          Positioned(
            top: 10,
            child: _buildTooltipLabel(
              _t('cricket_stadium'),
              const Color(0xFF1E293B),
            ),
          ),

          // 4. Draggable Container Bucket - Left
          if (_step < 3 && !_stepCompleted)
            Positioned(
              left: 50,
              top: 80,
              child: Draggable<String>(
                data: 'people',
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 0.8,
                    child: _buildDraggablePopulationContainer(
                      popText,
                      popYear,
                      _step == 1 ? 0.75 : 1.06,
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildDraggablePopulationContainer(
                    popText,
                    popYear,
                    _step == 1 ? 0.75 : 1.06,
                  ),
                ),
                child: _buildDraggablePopulationContainer(
                  popText,
                  popYear,
                  _step == 1 ? 0.75 : 1.06,
                ),
                onDragStarted: () => _playSound('pop'),
              ),
            ),

          // 5. Stadium Dropzone - Center Drop Location
          if (_step < 3 && !_stepCompleted)
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    if (details.data == 'people') {
                      _playSound('pop');
                      setState(() {
                        if (_step == 1) {
                          _stadiumFillRatio = 0.75;
                          _playSound('success');
                        } else {
                          _stadiumFillRatio = 1.06;
                          _stadiumOverflow = true;
                          _playSound('error');
                        }
                        _stepCompleted = true;
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return CustomPaint(
                      painter: DashedRectPainter(
                        color: candidateData.isNotEmpty
                            ? Colors.orange
                            : const Color(0xFF6366F1),
                      ),
                      child: Container(
                        width: 160,
                        height: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty
                              ? Colors.indigo.withOpacity(0.5)
                              : const Color(0xFF1E293B).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              color: candidateData.isNotEmpty
                                  ? Colors.orange
                                  : const Color(0xFF6366F1),
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('drop_here'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _t('stadium_entrance'),
                                  style: TextStyle(
                                    color: candidateData.isNotEmpty
                                        ? Colors.orangeAccent
                                        : const Color(0xFF6366F1),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 6. Overflow People - Bottom Right
          if (_stadiumOverflow)
            Positioned(
              right: 320,
              bottom: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444), // Red overflow color
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "+6,000",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 150,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: -4,
                      runSpacing: -4,
                      children: List.generate(
                        10, // Representative overflow group
                        (index) => const Icon(
                          Icons.person,
                          color: Color(0xFFEF4444),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Scenario 2 Custom Layout Widgets ---

  Widget _buildDraggablePopulationContainer(
    String popText,
    String popYear,
    double fillRatio,
  ) {
    return Column(
      children: [
        // Glass Bowl Container
        Container(
          width: 160,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(45),
            ),
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: fillRatio.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5), // Indigo blue fill
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(42),
                ),
              ),
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: List.generate(
                    (30 * fillRatio).toInt().clamp(0, 35),
                    (index) =>
                        const Icon(Icons.person, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Information Badge
        Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "${_t('chintamani_pop')} ($popYear)",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  popText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ----------- SUMMARIES -----------

  Widget _buildS1Summary() {
    return Column(
      children: [
        const Icon(Icons.lightbulb, color: Colors.amber, size: 60),
        const SizedBox(height: 20),
        Text(
          _t('s1_sum_1'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          _t('s1_sum_2'),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _loadScenario(2);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: Text(
            _t('proceed_s2'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildS2Summary() {
    return Column(
      children: [
        const Text(
          "Challenge Summary",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 40),
        // Equation Visual: [Full Stadium] - [Empty Stadium] = [People]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Item 1: Full Stadium
            Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 90,
                  child: CustomPaint(
                    painter: Stadium3DPainter(
                      fillRatio: 1.06,
                      isMini: true,
                      capacityText: _t('stadium_capacity'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "1,06,000",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 35),
              child: Text(
                "-",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
            ),
            // Item 2: Empty Stadium
            Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 90,
                  child: CustomPaint(
                    painter: Stadium3DPainter(
                      fillRatio: 0.0,
                      isMini: true,
                      capacityText: _t('stadium_capacity'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "1,00,000",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 35),
              child: Text(
                "=",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
            ),
            // Item 3: Remaining People
            Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 90,
                  child: Center(
                    child: Wrap(
                      spacing: -8,
                      runSpacing: -8,
                      children: List.generate(
                        8,
                        (i) => const Icon(
                          Icons.person,
                          color: Color(0xFFEF4444),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "6,000",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          _t('s2_sum_2'),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _loadScenario(1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: Text(
            _t('restart_lab'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// CUSTOM CLIPPERS & PAINTERS
// -----------------------------------------------------------------------------

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BalanceScalePainter extends CustomPainter {
  final double rotation;
  final String tastedText;
  final String tastedLabel;
  final String remainingText;
  final String remainingLabel;

  BalanceScalePainter({
    required this.rotation,
    required this.tastedText,
    required this.tastedLabel,
    required this.remainingText,
    required this.remainingLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cyPillarTop = size.height * 0.30;
    final cyBase = size.height * 0.80;

    final orangeColor = const Color(0xFFE57A44);
    final darkOrangeColor = const Color(0xFFC86035);
    final darkColor = const Color(0xFF2C2211);
    final tooltipColor = const Color(0xFF1E293B);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cyBase), width: 180, height: 50),
      Paint()..color = darkOrangeColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cyBase - 8), width: 180, height: 50),
      Paint()..color = orangeColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cyBase - 20), width: 130, height: 35),
      Paint()..color = darkOrangeColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cyBase - 25), width: 130, height: 35),
      Paint()..color = orangeColor,
    );

    final pillarPath = Path();
    pillarPath.moveTo(cx - 12, cyPillarTop);
    pillarPath.lineTo(cx + 12, cyPillarTop);
    pillarPath.lineTo(cx + 22, cyBase - 25);
    pillarPath.lineTo(cx - 22, cyBase - 25);
    pillarPath.close();
    canvas.drawPath(pillarPath, Paint()..color = orangeColor);

    final pillarShadow = Path();
    pillarShadow.moveTo(cx, cyPillarTop);
    pillarShadow.lineTo(cx + 12, cyPillarTop);
    pillarShadow.lineTo(cx + 22, cyBase - 25);
    pillarShadow.lineTo(cx, cyBase - 25);
    pillarShadow.close();
    canvas.drawPath(
      pillarShadow,
      Paint()..color = Colors.black.withOpacity(0.08),
    );

    final beamLength = size.width * 0.65;
    final halfBeam = beamLength / 2;
    final leftEnd = Offset(
      cx - math.cos(rotation) * halfBeam,
      cyPillarTop - math.sin(rotation) * halfBeam,
    );
    final rightEnd = Offset(
      cx + math.cos(rotation) * halfBeam,
      cyPillarTop + math.sin(rotation) * halfBeam,
    );

    canvas.save();
    canvas.translate(cx, cyPillarTop);
    canvas.rotate(rotation);
    final beamRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: beamLength, height: 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(beamRect, Paint()..color = orangeColor);
    final beamShadowRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: const Offset(0, 4), width: beamLength, height: 8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(
      beamShadowRect,
      Paint()..color = Colors.black.withOpacity(0.1),
    );
    canvas.restore();

    canvas.drawCircle(Offset(cx, cyPillarTop), 16, Paint()..color = darkColor);
    canvas.drawCircle(
      Offset(cx, cyPillarTop),
      8,
      Paint()..color = darkOrangeColor,
    );

    _drawPan(
      canvas,
      leftEnd,
      35,
      tastedText,
      tastedLabel,
      tooltipColor,
      darkColor,
    );
    _drawPan(
      canvas,
      rightEnd,
      50,
      remainingText,
      remainingLabel,
      tooltipColor,
      darkColor,
    );
  }

  void _drawPan(
    Canvas canvas,
    Offset topJoint,
    double domeRadius,
    String valText,
    String lblText,
    Color tooltipColor,
    Color darkColor,
  ) {
    const stringLength = 90.0;
    final panCenter = Offset(topJoint.dx, topJoint.dy + stringLength);

    canvas.drawLine(
      topJoint,
      panCenter,
      Paint()
        ..color = darkColor
        ..strokeWidth = 4,
    );
    canvas.drawCircle(topJoint, 8, Paint()..color = darkColor);

    canvas.drawOval(
      Rect.fromCenter(center: panCenter, width: 110, height: 25),
      Paint()..color = darkColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(panCenter.dx, panCenter.dy - 2),
        width: 100,
        height: 18,
      ),
      Paint()..color = darkColor.withOpacity(0.5),
    );

    final domePath = Path();
    domePath.moveTo(panCenter.dx - domeRadius, panCenter.dy - 5);
    domePath.arcToPoint(
      Offset(panCenter.dx + domeRadius, panCenter.dy - 5),
      radius: Radius.circular(domeRadius),
      clockwise: true,
    );
    domePath.close();
    canvas.drawPath(domePath, Paint()..color = Colors.white);

    final domeShadowPath = Path();
    domeShadowPath.moveTo(panCenter.dx - domeRadius + 5, panCenter.dy - 5);
    domeShadowPath.arcToPoint(
      Offset(panCenter.dx + domeRadius, panCenter.dy - 5),
      radius: Radius.circular(domeRadius),
      clockwise: true,
    );
    domeShadowPath.close();
    canvas.drawPath(
      domeShadowPath,
      Paint()..color = Colors.black.withOpacity(0.04),
    );

    final tipY = topJoint.dy - 10;
    _drawTooltip(
      canvas,
      Offset(topJoint.dx, tipY),
      valText,
      lblText,
      tooltipColor,
    );
  }

  void _drawTooltip(
    Canvas canvas,
    Offset pointerTip,
    String val,
    String lbl,
    Color bgColor,
  ) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: "$val\n",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: lbl,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    final tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    final boxWidth = tp.width + 40;
    final boxHeight = tp.height + 24;
    final boxCenter = Offset(pointerTip.dx, pointerTip.dy - boxHeight / 2 - 8);

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: boxCenter, width: boxWidth, height: boxHeight),
      const Radius.circular(12),
    );
    canvas.drawRRect(boxRect, Paint()..color = bgColor);

    final path = Path();
    path.moveTo(pointerTip.dx - 10, pointerTip.dy - 10);
    path.lineTo(pointerTip.dx + 10, pointerTip.dy - 10);
    path.lineTo(pointerTip.dx, pointerTip.dy);
    path.close();
    canvas.drawPath(path, Paint()..color = bgColor);

    tp.paint(
      canvas,
      Offset(boxCenter.dx - tp.width / 2, boxCenter.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant BalanceScalePainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.tastedLabel != tastedLabel ||
        oldDelegate.remainingLabel != remainingLabel;
  }
}

class GrainHillPainter extends CustomPainter {
  final double fillPercentage;
  final Color color;

  GrainHillPainter({required this.fillPercentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (fillPercentage <= 0.0) return;

    double scale = math.sqrt(fillPercentage);
    if (fillPercentage > 0 && scale < 0.1) scale = 0.1;

    double w = size.width * scale;
    double h = size.height * scale;

    Path path = Path();
    path.moveTo((size.width - w) / 2, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - (h * 1.5),
      (size.width + w) / 2,
      size.height,
    );
    path.close();

    final Rect rect = Rect.fromLTWH(0, size.height - h, size.width, h);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color, color.withOpacity(0.6)],
    );
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawPath(path, paint);

    canvas.save();
    canvas.clipPath(path);
    final dotPaint = Paint()..color = Colors.black.withOpacity(0.15);
    final math.Random rand = math.Random(42);
    int dots = (400 * fillPercentage).toInt();
    for (int i = 0; i < dots; i++) {
      double dx = (size.width - w) / 2 + rand.nextDouble() * w;
      double dy = size.height - rand.nextDouble() * h;
      canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GrainHillPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.color != color;
  }
}

// -----------------------------------------------------------------------------
// CLEAN PAINTERS FOR SCENARIO 2
// -----------------------------------------------------------------------------

class CleanFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 30;

    // Clean light stage background
    final path = Path()
      ..addOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 900, height: 450),
      );

    // Soft shadow
    canvas.drawShadow(path, Colors.black, 4.0, true);

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFF8FAFC), // Slate 50
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Redesigned 3D Stadium matching the image
class Stadium3DPainter extends CustomPainter {
  final double fillRatio;
  final bool isMini;
  final String capacityText;

  Stadium3DPainter({
    required this.fillRatio,
    this.isMini = false,
    required this.capacityText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Shift slightly up in main canvas
    final cy = size.height / 2 - (isMini ? 0 : 30);

    final double rx = isMini ? 60 : 320;
    final double ry = isMini ? 30 : 160;
    final double h = isMini ? 15 : 70; // Cylinder height

    // Colors extracted from the provided image
    final Color darkBandColor = const Color(0xFF475569); // Dark Slate Gray
    final Color lightBandColor = const Color(0xFFE2E8F0); // Light Slate Gray
    final Color topRimColor = const Color(0xFF3B82F6); // Blue rim
    final Color seatLightColor = const Color(0xFFCBD5E1); // Empty seats
    final Color fieldColor = const Color(0xFF94A3B8); // Field base
    final Color pitchColor = const Color(0xFFF8FAFC); // Cricket pitch
    final Color filledSeatColor = const Color(0xFF4F46E5); // Filled seat color
    final Color entranceDark = const Color(0xFF1E293B); // Entrance darkness

    // 1. Draw Outer Cylinder Bands - Bottom to Top
    // Shadow
    Path shadowPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, cy + h),
          width: rx * 2.1,
          height: ry * 2.1,
        ),
      );
    canvas.drawShadow(shadowPath, Colors.black, isMini ? 2 : 10, true);

    _drawCylinderBand(canvas, cx, cy, rx, ry, h * 0.75, h, darkBandColor);
    _drawCylinderBand(
      canvas,
      cx,
      cy,
      rx,
      ry,
      h * 0.55,
      h * 0.75,
      lightBandColor,
    );
    _drawCylinderBand(
      canvas,
      cx,
      cy,
      rx,
      ry,
      h * 0.30,
      h * 0.55,
      darkBandColor,
    );
    _drawCylinderBand(
      canvas,
      cx,
      cy,
      rx,
      ry,
      h * 0.10,
      h * 0.30,
      lightBandColor,
    );
    _drawCylinderBand(canvas, cx, cy, rx, ry, 0, h * 0.10, topRimColor);

    // Top Edge Rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.white,
    );

    // 2. Interior Setup - Tiers
    // Tier 1 - Outer
    double t1OutRx = rx * 0.95, t1OutRy = ry * 0.95, t1Y = 0;
    double t1InRx = rx * 0.80, t1InRy = ry * 0.80, t1InY = isMini ? 4 : 15;
    double w1Y1 = t1InY, w1Y2 = isMini ? 6 : 22;

    // Tier 2 - Middle
    double t2OutRx = rx * 0.80, t2OutRy = ry * 0.80, t2Y = w1Y2;
    double t2InRx = rx * 0.60, t2InRy = ry * 0.60, t2InY = isMini ? 10 : 37;
    double w2Y1 = t2InY, w2Y2 = isMini ? 12 : 44;

    // Tier 3 - Inner
    double t3OutRx = rx * 0.60, t3OutRy = ry * 0.60, t3Y = w2Y2;
    double t3InRx = rx * 0.35, t3InRy = ry * 0.35, t3InY = isMini ? 16 : 59;
    double w3Y1 = t3InY, w3Y2 = isMini ? 18 : 66;

    double fieldY = w3Y2;

    // Seat Paint with Gradient for Fill Ratio
    Paint getSeatPaint() {
      if (fillRatio == 0) return Paint()..color = seatLightColor;
      return Paint()
        ..shader =
            RadialGradient(
              colors: [filledSeatColor.withOpacity(0.8), seatLightColor],
              stops: [
                fillRatio.clamp(0.0, 1.0),
                fillRatio.clamp(0.0, 1.0) + 0.05,
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: rx * 2,
                height: ry * 2,
              ),
            );
    }

    Paint activeSeatPaint = getSeatPaint();

    // 3. Draw Tiers and Inner Walls
    void drawTierWithDividers(
      double oRx,
      double oRy,
      double oY,
      double iRx,
      double iRy,
      double iY,
    ) {
      Path tier = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(cx, cy + oY),
            width: oRx * 2,
            height: oRy * 2,
          ),
        )
        ..addOval(
          Rect.fromCenter(
            center: Offset(cx, cy + iY),
            width: iRx * 2,
            height: iRy * 2,
          ),
        )
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(tier, activeSeatPaint);

      // Stair lines
      if (!isMini) {
        final Paint linePaint = Paint()
          ..color = Colors.black12
          ..strokeWidth = 1.0;
        for (int i = 0; i < 36; i++) {
          double angle = i * math.pi / 18;
          Offset p1 = Offset(
            cx + math.cos(angle) * oRx,
            cy + oY + math.sin(angle) * oRy,
          );
          Offset p2 = Offset(
            cx + math.cos(angle) * iRx,
            cy + iY + math.sin(angle) * iRy,
          );
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    // Tier 1
    drawTierWithDividers(t1OutRx, t1OutRy, t1Y, t1InRx, t1InRy, t1InY);
    _drawInnerWall(canvas, cx, cy, t1InRx, t1InRy, w1Y1, w1Y2, darkBandColor);

    // Tier 2
    drawTierWithDividers(t2OutRx, t2OutRy, t2Y, t2InRx, t2InRy, t2InY);
    _drawInnerWall(canvas, cx, cy, t2InRx, t2InRy, w2Y1, w2Y2, darkBandColor);

    // Tier 3
    drawTierWithDividers(t3OutRx, t3OutRy, t3Y, t3InRx, t3InRy, t3InY);
    _drawInnerWall(canvas, cx, cy, t3InRx, t3InRy, w3Y1, w3Y2, darkBandColor);

    // 4. Field
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + fieldY),
        width: t3InRx * 2,
        height: t3InRy * 2,
      ),
      Paint()..color = fieldColor,
    );

    // Cricket Pitch
    if (!isMini) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + fieldY),
          width: t3InRx * 0.8,
          height: t3InRy * 0.8,
        ),
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy + fieldY), width: 60, height: 25),
        Paint()..color = pitchColor,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy + fieldY), width: 40, height: 15),
        Paint()..color = Colors.white,
      );
    }

    // 5. Entrances & Gauges - Not for mini view in Summary
    if (!isMini) {
      // Calculate ground positions accurately based on ellipse equation
      // Ground curve: y = cy + h + ry * sqrt(1 - ((x - cx) / rx)^2)

      // Left Entrance - Pseudo 3D
      double ratioLeft = 0;
      double ex = cx + rx * ratioLeft;
      double groundYLeft = cy + h + ry * math.sqrt(1 - ratioLeft * ratioLeft);
      double entHeight = 90;
      double ey =
          groundYLeft - entHeight / 2; // Center Y so bottom rests on ground

      // White block
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ex, ey),
            width: 120,
            height: entHeight,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.white,
      );
      // Blue frame
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ex, ey + 10),
            width: 100,
            height: entHeight - 20,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = topRimColor,
      );
      // Dark hole
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ex, groundYLeft - 20),
            width: 60,
            height: 40,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = entranceDark,
      );

      // Right Gauge Panel built into wall
      double ratioRight = 0.92;
      double px = cx + 30 + rx + 30 * ratioRight;
      double groundYRight =
          cy - 260 + h + ry * math.sqrt(1 - ratioRight * ratioRight);
      double panelHeight = 250;
      double py = groundYRight - panelHeight / 2; // Bottom rests on ground

      Rect panelRect = Rect.fromCenter(
        center: Offset(px, py),
        width: 200,
        height: panelHeight,
      );
      RRect rPanel = RRect.fromRectAndCorners(
        panelRect,
        topLeft: const Radius.circular(24),
        topRight: const Radius.circular(24),
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      );

      canvas.drawShadow(Path()..addRRect(rPanel), Colors.black, 12, true);
      canvas.drawRRect(rPanel, Paint()..color = Colors.white);

      _drawText(
        canvas,
        capacityText,
        Offset(px, py - 80),
        16,
        Colors.black87,
        true,
      );

      // Gauge arc
      Rect gaugeRect = Rect.fromCenter(
        center: Offset(px, py + 20),
        width: 140,
        height: 140,
      );
      canvas.drawArc(
        gaugeRect,
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      );

      // Fill arc
      if (fillRatio > 0) {
        double sweep = math.pi * fillRatio.clamp(0.0, 1.0);
        canvas.drawArc(
          gaugeRect,
          math.pi,
          sweep,
          false,
          Paint()
            ..color = fillRatio > 1.0
                ? const Color(0xFFEF4444)
                : filledSeatColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16
            ..strokeCap = StrokeCap.round,
        );
      }

      // Gauge Text
      String valStr = fillRatio == 0
          ? "0%"
          : (fillRatio > 1.0 ? "106%" : "${(fillRatio * 100).toInt()}%");
      Color valColor = fillRatio == 0
          ? Colors.black87
          : (fillRatio > 1.0 ? const Color(0xFFEF4444) : filledSeatColor);
      _drawText(canvas, valStr, Offset(px, py), 32, valColor, true);

      if (fillRatio > 1.0) {
        _drawText(
          canvas,
          "👤 6,000",
          Offset(px, py + 60),
          28,
          const Color(0xFFEF4444),
          true,
        );
        _drawText(
          canvas,
          'Overflowed',
          Offset(px, py + 100),
          26,
          const Color(0xFFEF4444),
          true,
        );
      }
    }
  }

  // Helper to draw outer cylinder segment
  void _drawCylinderBand(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    double yTop,
    double yBottom,
    Color color,
  ) {
    Path path = Path()
      ..moveTo(cx - rx, cy + yTop)
      ..lineTo(cx - rx, cy + yBottom)
      ..arcToPoint(
        Offset(cx + rx, cy + yBottom),
        radius: Radius.elliptical(rx, ry),
        clockwise: false,
      )
      ..lineTo(cx + rx, cy + yTop)
      ..arcToPoint(
        Offset(cx - rx, cy + yTop),
        radius: Radius.elliptical(rx, ry),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // Helper to draw inner bowl wall - upper half arc
  void _drawInnerWall(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    double yTop,
    double yBottom,
    Color color,
  ) {
    Path path = Path()
      ..moveTo(cx - rx, cy + yTop)
      ..arcToPoint(
        Offset(cx + rx + 10, cy + yTop),
        radius: Radius.elliptical(rx, ry),
        clockwise: true,
      )
      ..lineTo(cx + rx + 10, cy + yBottom)
      ..arcToPoint(
        Offset(cx - rx + 10, cy + yBottom),
        radius: Radius.elliptical(rx, ry),
        clockwise: false,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // Helper to draw text
  void _drawText(
    Canvas canvas,
    String text,
    Offset centerPos,
    double fontSize,
    Color color,
    bool isBold,
  ) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(centerPos.dx - tp.width / 2, centerPos.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant Stadium3DPainter oldDelegate) =>
      oldDelegate.fillRatio != fillRatio ||
      oldDelegate.isMini != isMini ||
      oldDelegate.capacityText != capacityText;
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    Path path = Path()..addRRect(rrect);
    Path dashPath = _dashPath(
      path,
      dashArray: CircularIntervalList<double>([8, 6]),
    );

    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}

class CircularIntervalList<T> {
  CircularIntervalList(this._vals);
  final List<T> _vals;
  int _idx = 0;
  T get next {
    if (_idx >= _vals.length) _idx = 0;
    return _vals[_idx++];
  }
}
