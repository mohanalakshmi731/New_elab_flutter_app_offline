// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UnderstandingQuotientSizeinFractionDivision(),
    ),
  );
}

class UnderstandingQuotientSizeinFractionDivision extends StatefulWidget {
  const UnderstandingQuotientSizeinFractionDivision({super.key});

  @override
  State<UnderstandingQuotientSizeinFractionDivision> createState() =>
      _UnderstandingQuotientSizeinFractionDivisionState();
}

class _UnderstandingQuotientSizeinFractionDivisionState
    extends State<UnderstandingQuotientSizeinFractionDivision>
    with SingleTickerProviderStateMixin {
  // --- UI State ---
  bool _isSidebarOpen = true;
  String _lang = 'en'; // 'en', 'hi', 'te'
  bool _showCurtain = true;
  bool _showSuccessPopup = false;
  bool _showPredictionPopup = false;

  // --- Popup Drag State ---
  Offset _predictionPopupPos = const Offset(0, 0);
  Offset _successPopupPos = const Offset(0, 0);
  bool _popupsInitialized = false;

  // --- Simulation State ---
  int _scenario = 1;
  double _ribbonLength = 6.0;
  double _stickLength = 2.0;
  bool _stickSnapped = false;
  int _measuredCount = 0;
  String _prediction = '';
  bool _labCompleted = false;

  // --- Animation & Controllers ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;

  // Audio Pool for overlapping sounds without timeout crashes
  final List<AudioPlayer> _audioPlayers = List.generate(
    4,
    (_) => AudioPlayer(),
  );
  int _currentPlayerIndex = 0;

  final TransformationController _transformController =
      TransformationController();

  // --- Constants ---
  final double _unitPixels = 80.0;
  final Map<int, Map<String, double>> _scenarioConfigs = {
    1: {'ribbon': 6.0, 'stick': 2.0},
    2: {'ribbon': 4.0, 'stick': 0.5},
    3: {'ribbon': 5.0, 'stick': 1.0},
    4: {'ribbon': 3.0, 'stick': 0.25},
    5: {'ribbon': 6.0, 'stick': 1.5},
  };

  // --- Translations ---
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'Understanding Quotient Size in Fraction Division',
      'appSubtitle': 'Class 7 • WORKING WITH FRACTIONS',
      'enterLab': 'Enter Lab',
      'selectScenario': 'Select Scenario',
      'stepLabel': 'STEP',
      'learnLbl': 'What We Learn:',
      'resetBtn': 'Reset Lab',
      'finishLab': 'Finish Lab',
      'nextScenario': 'Next Scenario',
      'measureBtn': 'MEASURE',
      'doneBtn': 'DONE',
      'labCompleted': 'Lab Completed!',
      'finalDesc':
          'You have mastered the concept of quotient size in fraction division! You observed that dividing by a fraction less than 1 increases the quotient, while dividing by a number greater than 1 decreases it.',
      'unitRef': '1-Unit',
      'activeSlotLbl': 'Active Tool',
      'quotientTitle': 'Digital Counter',
      'greaterBtn': 'GREATER',
      'smallerBtn': 'SMALLER',
      'predQ':
          'Look at the measuring stick.\nWill the final quotient be GREATER or SMALLER than {target}?',
      'correctTxt': 'Correct!',
      'incorrectTxt': 'Incorrect!',
      'actualIs': 'The quotient is {actual}.',
      'predWas': 'Your prediction was {feedback}.',
      'isGreaterThan': '{actual} is GREATER THAN {target}.',
      'isSmallerThan': '{actual} is SMALLER THAN {target}.',
      'taskInst': 'Task Instructions:',
      'expOut': 'Expected Outcome:',
      'summaryTitle': 'What We Learnt',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'compGreater': 'GREATER THAN',
      'compSmaller': 'SMALLER THAN',
      'compEqual': 'EQUAL TO',
      'sumBoxDiv': 'Dividend (Ribbon Length) = {div}',
      'sumBoxDsr': 'Divisor (Stick Length) = {dsr}',
      'sumBoxQ': 'Quotient (How many times it fit) = {q}',

      's1_title': '1. The Long Stick Challenge',
      's1_obj':
          'To visually understand that dividing by a number greater than 1 results in a quotient that is smaller than the dividend.',
      's1_step1_task':
          'A 6-unit long red ribbon appears on the workbench. A reference \'1-Unit\' block is shown above it. DRAG the \'2-Unit Measuring Stick\' from the tool rack and DROP it into the \'Active Tool\' slot.',
      's1_step1_out':
          'The 2-Unit Measuring Stick is selected and ready for use. The stick is visibly twice as long as the 1-Unit reference block.',
      's1_step2_task':
          'CLICK the \'MEASURE\' button repeatedly until the entire 6-unit ribbon is measured.',
      's1_step2_out':
          'With each click, a 2-unit segment is laid out along the ribbon. The \'Quotient Counter\' increases by 1 with each click. The process stops after 3 clicks when the ribbon is fully measured.',
      's1_step3_task': 'Observe the final result and the summary.',
      's1_step3_out': 'The Quotient Counter clearly shows \'3\'.',
      's1_sum':
          'When the divisor is > 1, the quotient is smaller than the dividend.',

      's2_title': '2. The Short Stick Surprise',
      's2_obj':
          'To visually understand that dividing by a fraction less than 1 results in a quotient that is larger than the dividend.',
      's2_step1_task':
          'A new 4-unit long blue ribbon appears. DRAG the \'1/2-Unit Measuring Stick\' from the tool rack and DROP it into the \'Active Tool\' slot.',
      's2_step1_out':
          'The 1/2-Unit Measuring Stick is selected. It is visibly half the length of the 1-Unit reference block.',
      's2_step2_task':
          'CLICK the \'MEASURE\' button repeatedly until the entire 4-unit ribbon is measured.',
      's2_step2_out':
          'With each click, a 1/2-unit segment is laid out. The \'Quotient Counter\' increases by 1 with each click. The process stops after 8 clicks.',
      's2_step3_task': 'Observe the final result and the summary.',
      's2_step3_out': 'The Quotient Counter clearly shows \'8\'.',
      's2_sum':
          'When the divisor is < 1, the quotient is larger than the dividend.',

      's3_title': '3. The Perfect Match',
      's3_obj':
          'To visually understand that dividing by 1 results in a quotient that is equal to the dividend.',
      's3_step1_task':
          'A 5-unit long green ribbon appears. DRAG the \'1-Unit Measuring Stick\' from the tool rack and DROP it into the \'Active Tool\' slot.',
      's3_step1_out':
          'The 1-Unit Measuring Stick is selected. It is the same length as the 1-Unit reference block.',
      's3_step2_task':
          'CLICK the \'MEASURE\' button repeatedly until the entire 5-unit ribbon is measured.',
      's3_step2_out':
          'With each click, a 1-unit segment is laid out. The \'Quotient Counter\' increases by 1 with each click. The process stops after 5 clicks.',
      's3_step3_task': 'Observe the final result and the summary.',
      's3_step3_out': 'The Quotient Counter clearly shows \'5\'.',
      's3_sum':
          'When the divisor is = 1, the quotient is equal to the dividend.',

      's4_title': '4. The Tiny Cutter Task',
      's4_obj':
          'To apply the learned concept and predict the outcome when dividing by a fraction less than 1.',
      's4_step1_task':
          'A 3-unit long yellow ribbon and a \'1/4-Unit Measuring Stick\' are displayed. A question appears: \'Look at the measuring stick. Will the final quotient be GREATER or SMALLER than 3?\' CLICK your prediction.',
      's4_step1_out':
          'The user clicks either the \'GREATER\' or \'SMALLER\' button based on their visual assessment of the stick size relative to 1 unit.',
      's4_step2_task':
          'Now, test your prediction. DRAG the \'1/4-Unit Measuring Stick\' to the \'Active Tool\' slot and CLICK the \'MEASURE\' button until the ribbon is full.',
      's4_step2_out':
          'The user performs the measurement. The counter rapidly increases and stops at 12.',
      's4_step3_task': 'Check the result.',
      's4_step3_out': 'The lab provides feedback on the prediction.',
      's4_sum':
          'Remember, dividing by a fraction smaller than 1 gives a bigger result.',

      's5_title': '5. The Giant Measurer Mission',
      's5_obj':
          'To apply the learned concept and predict the outcome when dividing by an improper fraction (a number greater than 1).',
      's5_step1_task':
          'A 6-unit long purple ribbon and a \'3/2-Unit Measuring Stick\' (1.5 units) are displayed. A question appears: \'Look at the measuring stick. Will the final quotient be GREATER or SMALLER than 6?\' CLICK your prediction.',
      's5_step1_out':
          'The user clicks either the \'GREATER\' or \'SMALLER\' button.',
      's5_step2_task':
          'Test your prediction. DRAG the \'3/2-Unit Measuring Stick\' to the \'Active Tool\' slot and CLICK the \'MEASURE\' button until the ribbon is full.',
      's5_step2_out':
          'The user performs the measurement. The counter increases and stops at 4.',
      's5_step3_task': 'Check the result.',
      's5_step3_out': 'The lab provides feedback on the prediction.',
      's5_sum':
          'Remember, dividing by a number bigger than 1 gives a smaller result.',
    },
    'hi': {
      'appTitle': 'भिन्न विभाजन में भागफल का आकार समझना',
      'appSubtitle': 'कक्षा 7 • भिन्नों के साथ काम करना',
      'enterLab': 'लैब में प्रवेश करें',
      'selectScenario': 'परिदृश्य चुनें',
      'stepLabel': 'कदम',
      'learnLbl': 'हम क्या सीखते हैं:',
      'resetBtn': 'लैब रीसेट करें',
      'finishLab': 'लैब समाप्त करें',
      'nextScenario': 'अगला परिदृश्य',
      'measureBtn': 'मापें',
      'doneBtn': 'हो गया',
      'labCompleted': 'लैब पूरी हुई!',
      'finalDesc':
          'आपने भिन्न विभाजन में भागफल के आकार की अवधारणा में महारत हासिल कर ली है! आपने देखा कि 1 से छोटी भिन्न से भाग देने पर भागफल बढ़ता है, जबकि 1 से बड़ी संख्या से भाग देने पर यह घटता है।',
      'unitRef': '1-यूनिट',
      'activeSlotLbl': 'सक्रिय टूल',
      'quotientTitle': 'डिजिटल काउंटर',
      'greaterBtn': 'बड़ा',
      'smallerBtn': 'छोटा',
      'predQ':
          'मापने वाली छड़ी को देखें।\nक्या अंतिम भागफल {target} से बड़ा होगा या छोटा?',
      'correctTxt': 'सही!',
      'incorrectTxt': 'गलत!',
      'actualIs': 'भागफल {actual} है।',
      'predWas': 'आपकी भविष्यवाणी {feedback} थी।',
      'isGreaterThan': '{actual}, {target} से बड़ा है।',
      'isSmallerThan': '{actual}, {target} से छोटा है।',
      'taskInst': 'कार्य निर्देश:',
      'expOut': 'अपेक्षित परिणाम:',
      'summaryTitle': 'हमने क्या सीखा',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'compGreater': 'से बड़ा है',
      'compSmaller': 'से छोटा है',
      'compEqual': 'के बराबर है',
      'sumBoxDiv': 'लाभांश (रिबन की लंबाई) = {div}',
      'sumBoxDsr': 'भाजक (छड़ी की लंबाई) = {dsr}',
      'sumBoxQ': 'भागफल (यह कितनी बार फिट हुआ) = {q}',

      's1_title': '1. लंबी छड़ी की चुनौती',
      's1_obj':
          'यह समझना कि 1 से बड़ी संख्या से भाग देने पर भागफल लाभांश से छोटा होता है।',
      's1_step1_task':
          'वर्कबेंच पर एक 6-यूनिट लंबा लाल रिबन दिखाई देता है। इसके ऊपर एक संदर्भ \'1-यूनिट\' ब्लॉक दिखाया गया है। टूल रैक से \'2-यूनिट मापने वाली छड़ी\' को खींचें (DRAG) और इसे \'सक्रिय टूल\' स्लॉट में छोड़ें (DROP)।',
      's1_step1_out':
          '2-यूनिट मापने वाली छड़ी का चयन हो गया है और उपयोग के लिए तैयार है। यह छड़ी 1-यूनिट संदर्भ ब्लॉक से स्पष्ट रूप से दोगुनी लंबी है।',
      's1_step2_task':
          'पूरे 6-यूनिट रिबन के मापे जाने तक \'मापें\' (MEASURE) बटन पर बार-बार क्लिक करें।',
      's1_step2_out':
          'हर क्लिक के साथ, रिबन के साथ एक 2-यूनिट का खंड बिछाया जाता है। हर क्लिक के साथ \'भागफल काउंटर\' 1 से बढ़ जाता है। जब रिबन पूरी तरह से माप लिया जाता है, तो प्रक्रिया 3 क्लिक के बाद रुक जाती है।',
      's1_step3_task': 'अंतिम परिणाम और सारांश का निरीक्षण करें।',
      's1_step3_out': 'भागफल काउंटर स्पष्ट रूप से \'3\' दिखाता है।',
      's1_sum': 'जब भाजक > 1 होता है, तो भागफल लाभांश से छोटा होता है।',

      's2_title': '2. छोटी छड़ी का आश्चर्य',
      's2_obj':
          'यह समझना कि 1 से छोटी भिन्न से भाग देने पर भागफल लाभांश से बड़ा होता है।',
      's2_step1_task':
          'एक नया 4-यूनिट लंबा नीला रिबन दिखाई देता है। टूल रैक से \'1/2-यूनिट मापने वाली छड़ी\' को खींचें और इसे \'सक्रिय टूल\' स्लॉट में छोड़ें।',
      's2_step1_out':
          '1/2-यूनिट मापने वाली छड़ी का चयन हो गया है। यह स्पष्ट रूप से 1-यूनिट संदर्भ ब्लॉक की आधी लंबाई की है।',
      's2_step2_task':
          'पूरे 4-यूनिट रिबन के मापे जाने तक \'मापें\' (MEASURE) बटन पर बार-बार क्लिक करें।',
      's2_step2_out':
          'हर क्लिक के साथ, एक 1/2-यूनिट खंड बिछाया जाता है। भागफल काउंटर 1 से बढ़ता है। प्रक्रिया 8 क्लिक के बाद रुक जाती है।',
      's2_step3_task': 'अंतिम परिणाम और सारांश का निरीक्षण करें।',
      's2_step3_out': 'भागफल काउंटर स्पष्ट रूप से \'8\' दिखाता है।',
      's2_sum': 'जब भाजक < 1 होता है, तो भागफल लाभांश से बड़ा होता है।',

      's3_title': '3. उत्तम मिलान',
      's3_obj': 'यह समझना कि 1 से भाग देने पर भागफल लाभांश के बराबर होता है।',
      's3_step1_task':
          'एक 5-यूनिट लंबा हरा रिबन दिखाई देता है। टूल रैक से \'1-यूनिट मापने वाली छड़ी\' को खींचें और इसे \'सक्रिय टूल\' स्लॉट में छोड़ें।',
      's3_step1_out':
          '1-यूनिट मापने वाली छड़ी का चयन हो गया है। यह 1-यूनिट संदर्भ ब्लॉक के समान लंबाई की है।',
      's3_step2_task':
          'पूरे 5-यूनिट रिबन के मापे जाने तक \'मापें\' (MEASURE) बटन पर बार-बार क्लिक करें।',
      's3_step2_out':
          'हर क्लिक के साथ, एक 1-यूनिट खंड बिछाया जाता है। भागफल काउंटर 1 से बढ़ता है। प्रक्रिया 5 क्लिक के बाद रुक जाती है।',
      's3_step3_task': 'अंतिम परिणाम और सारांश का निरीक्षण करें।',
      's3_step3_out': 'भागफल काउंटर स्पष्ट रूप से \'5\' दिखाता है।',
      's3_sum': 'जब भाजक = 1 होता है, तो भागफल लाभांश के बराबर होता है।',

      's4_title': '4. छोटे कटर का कार्य',
      's4_obj': '1 से छोटी भिन्न से भाग देते समय परिणाम की भविष्यवाणी करना।',
      's4_step1_task':
          'एक 3-यूनिट लंबा पीला रिबन और एक \'1/4-यूनिट छड़ी\' प्रदर्शित की जाती है। एक प्रश्न आता है: \'छड़ी को देखें। क्या भागफल 3 से बड़ा या छोटा होगा?\' अपनी भविष्यवाणी पर क्लिक करें।',
      's4_step1_out':
          'उपयोगकर्ता 1 यूनिट के सापेक्ष छड़ी के आकार के आधार पर \'बड़ा\' या \'छोटा\' बटन पर क्लिक करता है।',
      's4_step2_task':
          'अब, अपनी भविष्यवाणी का परीक्षण करें। \'1/4-यूनिट छड़ी\' को सक्रिय टूल स्लॉट में खींचें और रिबन भरने तक \'मापें\' (MEASURE) बटन पर क्लिक करें।',
      's4_step2_out':
          'उपयोगकर्ता माप करता है। काउंटर तेजी से बढ़ता है और 12 पर रुकता है।',
      's4_step3_task': 'परिणाम जांचें।',
      's4_step3_out':
          'लैब उपयोगकर्ता की भविष्यवाणी पर प्रतिक्रिया प्रदान करती है।',
      's4_sum':
          'याद रखें, 1 से छोटी भिन्न से भाग देने पर बड़ा परिणाम मिलता है।',

      's5_title': '5. विशाल मापक मिशन',
      's5_obj': '1 से बड़ी भिन्न से भाग देते समय परिणाम की भविष्यवाणी करना।',
      's5_step1_task':
          'एक 6-यूनिट लंबा बैंगनी रिबन और एक \'3/2-यूनिट छड़ी\' (1.5 यूनिट) प्रदर्शित की जाती है। एक प्रश्न आता है: \'छड़ी को देखें। क्या भागफल 6 से बड़ा या छोटा होगा?\' भविष्यवाणी पर क्लिक करें।',
      's5_step1_out': 'उपयोगकर्ता \'बड़ा\' या \'छोटा\' बटन पर क्लिक करता है।',
      's5_step2_task':
          'भविष्यवाणी का परीक्षण करें। \'3/2-यूनिट छड़ी\' को सक्रिय टूल स्लॉट में खींचें और रिबन भरने तक \'मापें\' (MEASURE) बटन पर क्लिक करें।',
      's5_step2_out':
          'उपयोगकर्ता माप करता है। काउंटर बढ़ता है और 4 पर रुकता है।',
      's5_step3_task': 'परिणाम जांचें।',
      's5_step3_out':
          'लैब उपयोगकर्ता की भविष्यवाणी पर प्रतिक्रिया प्रदान करती है।',
      's5_sum':
          'याद रखें, 1 से बड़ी संख्या से भाग देने पर छोटा परिणाम मिलता है।',
    },
  };

  String t(String key) =>
      _translations[_lang]?[key] ?? _translations['en']![key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Curtain opens by translating out (0 to -1.0)
    _curtainAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.0),
    ).animate(
      CurvedAnimation(parent: _curtainController, curve: Curves.easeInOutCubic),
    );

    _loadScenario(1);
    _playSound('curtain');
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainController.dispose();
    for (var player in _audioPlayers) {
      player.dispose();
    }
    _transformController.dispose();
    super.dispose();
  }

  // --- Audio ---
  void _playSound(String type) {
    String url = '';
    switch (type) {
      case 'click':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'snap':
        url =
            'audio/class7/mixkit_392.mp3';
        break;
      case 'success':
        url =
            'audio/class7/mixkit_2018.mp3';
        break;
      case 'error':
        url =
            'audio/class7/mixkit_2955.mp3';
        break;
      case 'curtain':
        url =
            'audio/class7/mixkit_2020.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        _audioPlayers[_currentPlayerIndex].play(AssetSource(url)).catchError((e) {
          debugPrint("Audio Error for '$type': $e");
        });
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _audioPlayers.length;
      } catch (e) {
        debugPrint("Synchronous audio Error: $e");
      }
    }
  }

  // --- Logic ---
  int get _currentStep {
    if (_scenario <= 3) {
      if (!_stickSnapped) return 0;
      if (!_labCompleted) return 1;
      return 3;
    } else {
      if (_prediction.isEmpty) return 0;
      if (!_labCompleted) return 1;
      return 3;
    }
  }

  void _loadScenario(int scenario) {
    setState(() {
      _scenario = scenario;
      _ribbonLength = _scenarioConfigs[scenario]!['ribbon']!;
      _stickLength = _scenarioConfigs[scenario]!['stick']!;
      _stickSnapped = false;
      _measuredCount = 0;
      _prediction = '';
      _labCompleted = false;
      _showSuccessPopup = false;

      if (_scenario == 4 || _scenario == 5) {
        _showPredictionPopup = true;
      } else {
        _showPredictionPopup = false;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCanvas();
      if (!_popupsInitialized) {
        _initPopupPositions();
        _popupsInitialized = true;
      }
    });
  }

  void _initPopupPositions() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _predictionPopupPos = Offset(size.width / 2 - 160, size.height / 2 - 110);
      _successPopupPos = Offset(size.width / 2 - 200, size.height / 2 - 140);
    });
  }

  void _handleReset() {
    _playSound('error');
    setState(() {
      _showSuccessPopup = false;
      _showCurtain = true;
    });

    _curtainController.reverse().then((_) {
      setState(() {
        _lang = 'en';
      });
      _loadScenario(1);
    });
  }

  void _centerCanvas() {
    final Size screenSize = MediaQuery.of(context).size;
    double availableWidth =
        _isSidebarOpen ? (screenSize.width * 0.65) : screenSize.width;
    double availableHeight = screenSize.height;

    double targetX = 1000;
    double targetY = 600;

    double scale = 0.8;

    _transformController.value =
        Matrix4.identity()
          ..translate(
            availableWidth / 2 - (targetX * scale),
            availableHeight / 2 - (targetY * scale),
          )
          ..scale(scale);
  }

  void _handleSnap(double draggedStickLength) {
    if (draggedStickLength == _stickLength && !_stickSnapped) {
      setState(() {
        _stickSnapped = true;
      });
      _playSound('snap');
      HapticFeedback.mediumImpact();
    }
  }

  void _handleMeasure() {
    if (!_stickSnapped) return;
    int maxMeasurements = (_ribbonLength / _stickLength).round();

    if (_measuredCount < maxMeasurements) {
      setState(() {
        _measuredCount++;
      });
      _playSound('snap');
      HapticFeedback.lightImpact();

      if (_measuredCount == maxMeasurements) {
        _playSound('success');
        setState(() {
          _labCompleted = true;
        });
      }
    }
  }

  void _handlePrediction(String choice) {
    setState(() {
      _prediction = choice;
      _showPredictionPopup = false;
    });
    _playSound('success');
  }

  int _getRackIndex(double length) {
    List<double> order = [0.25, 0.5, 1.0, 1.5, 2.0];
    return order.indexOf(length);
  }

  String _formatFractionText(double val) {
    if (val == 0.25) return "1/4";
    if (val == 0.5) return "1/2";
    if (val == 0.75) return "3/4";
    if (val == 1.5) return "3/2";
    return val.toInt().toString();
  }

  void _toggleLanguage() {
    _playSound('click');
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // 1. Canvas Area
          Positioned.fill(child: _buildCanvasArea()),

          // 2. Left Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -sw * 0.35,
            top: 0,
            bottom: 0,
            width: sw * 0.35,
            child: _buildSidebar(),
          ),

          // 3. Floating Menu Button
          Positioned(
            top: 16,
            left: 16,
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
                Future.delayed(
                  const Duration(milliseconds: 300),
                  _centerCanvas,
                );
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

          // 4. Action/Interaction Overlays on Canvas
          if (_labCompleted)
            Positioned(
              bottom: 30,
              right: 30,
              child: _buildNextFinishButtonOverlay(),
            ),

          // 5. Overlay Effects (Popups - Draggable & Compact)
          if (_showPredictionPopup) _buildDraggablePredictionPopup(),
          if (_showSuccessPopup) _buildDraggableSuccessPopup(),

          // 6. Curtain
          if (_showCurtain)
            SlideTransition(
              position: _curtainAnimation,
              child: _buildCurtain(),
            ),
        ],
      ),
    );
  }

  Widget _buildNextFinishButtonOverlay() {
    bool isNext = _scenario < 5;
    return ElevatedButton.icon(
      onPressed: () {
        _playSound('click');
        if (isNext) {
          _loadScenario(_scenario + 1);
        } else {
          setState(() {
            _showSuccessPopup = true;
          });
        }
      },
      icon: Icon(
        isNext ? Icons.arrow_forward : Icons.flag,
        color: Colors.white,
      ),
      label: Text(
        isNext ? t('nextScenario') : t('finishLab'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isNext ? Colors.green.shade600 : Colors.amber.shade600,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
      ),
    );
  }

  Widget _buildCanvasArea() {
    double ribbonStartX = -(_ribbonLength * _unitPixels) / 2;
    double ox = 1000;
    double oy = 600;

    return Container(
      color: const Color(0xFF0F172A),
      child: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(2000),
        minScale: 0.2,
        maxScale: 3.0,
        constrained: false,
        panEnabled: true,
        scaleEnabled: true,
        child: SizedBox(
          width: 2000,
          height: 1200,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Base Visuals Painted natively on Canvas Layer
              Positioned.fill(
                child: CustomPaint(
                  painter: LabCanvasPainter(
                    ribbonLength: _ribbonLength,
                    stickLength: _stickLength,
                    scenario: _scenario,
                    unitPixels: _unitPixels,
                    measuredCount: _measuredCount,
                    labCompleted: _labCompleted,
                    stickSnapped: _stickSnapped,
                    t: t,
                  ),
                ),
              ),

              // Render all static inactive sticks inside the rack as widgets so text aligns perfectly
              ...List.generate(5, (i) {
                List<double> allSticks = [0.25, 0.5, 1.0, 1.5, 2.0];
                double len = allSticks[i];
                if (len == _stickLength && !_stickSnapped)
                  return const SizedBox.shrink(); // Hide the active stick if not snapped, draggable handles it

                double sx = ox + 30 + i * 60 + 6;
                double stickH = len * _unitPixels;
                double sy = oy - 180 - stickH + 15;

                return Positioned(
                  left: sx,
                  top: sy,
                  child: Opacity(
                    opacity:
                        (len == _stickLength && _stickSnapped)
                            ? 0.0
                            : 0.6, // Invisible if active is snapped
                    child: _buildStickWidget(
                      length: len,
                      horizontal: false,
                      isGhost: false,
                    ),
                  ),
                );
              }),

              // Ghost Sticks (Measurements on Ribbon)
              for (int i = 0; i < _measuredCount; i++)
                Positioned(
                  left: ox + ribbonStartX + (i * _stickLength * _unitPixels),
                  top: oy + 100,
                  child: _buildStickWidget(
                    length: _stickLength,
                    horizontal: true,
                    isGhost: true,
                  ),
                ),

              // The Native Draggable active stick in the rack
              if (!_stickSnapped)
                Positioned(
                  left: ox + 30 + (_getRackIndex(_stickLength) * 60) + 6,
                  top: oy - 180 - (_stickLength * _unitPixels) + 15,
                  child: Draggable<double>(
                    data: _stickLength,
                    // Feedback scales with viewer naturally if placed inside the stack properly.
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: 1.05,
                        child: _buildStickWidget(
                          length: _stickLength,
                          horizontal: true,
                          isGhost: false,
                          highlight: true,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildStickWidget(
                        length: _stickLength,
                        horizontal: false,
                        isGhost: false,
                      ),
                    ),
                    onDragStarted: () => _playSound('click'),
                    onDragEnd: (details) {
                      if (!details.wasAccepted) {
                        _playSound('error');
                      }
                    },
                    // Disable dragging if it's not the correct step yet
                    maxSimultaneousDrags:
                        ((_scenario <= 3 && _currentStep == 0) ||
                                (_scenario >= 4 && _currentStep == 1))
                            ? 1
                            : 0,
                    child: _buildStickWidget(
                      length: _stickLength,
                      horizontal: false,
                      isGhost: false,
                    ),
                  ),
                ),

              // Active Slot Native DragTarget
              Positioned(
                left: ox + ribbonStartX - 20,
                top: oy - 40,
                width: 160,
                height: 80,
                child: DragTarget<double>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              candidateData.isNotEmpty
                                  ? Colors.greenAccent
                                  : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                  onWillAcceptWithDetails:
                      (details) => details.data == _stickLength,
                  onAcceptWithDetails: (details) => _handleSnap(details.data),
                ),
              ),

              // Snapped Active Stick
              if (_stickSnapped &&
                  _measuredCount < (_ribbonLength / _stickLength).round())
                Positioned(
                  left: ox + ribbonStartX,
                  top: oy - 20,
                  child: _buildStickWidget(
                    length: _stickLength,
                    horizontal: true,
                    isGhost: false,
                    highlight: true,
                  ),
                ),

              // Native Measure Button & Counter
              Positioned(
                left: ox + ribbonStartX + (_ribbonLength * _unitPixels) + 60,
                top: oy + 40,
                child: _buildDigitalCounterInteractive(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCounterInteractive() {
    bool btnReady =
        _stickSnapped &&
        _measuredCount < (_ribbonLength / _stickLength).round();

    return Container(
      width: 200,
      height: 80,
      color: Colors.transparent,
      child: Stack(
        children: [
          // Text Screen Native overlay
          Positioned(
            left: 20,
            top: 20,
            child: IgnorePointer(
              child: Text(
                _measuredCount.toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
                ),
              ),
            ),
          ),
          // Interactive Native Measure Button
          Positioned(
            left: 95,
            top: 20,
            width: 90,
            height: 40,
            child: GestureDetector(
              onTap: () {
                if (btnReady) {
                  _playSound('click');
                  _handleMeasure();
                } else {
                  _playSound('error');
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      btnReady
                          ? Colors.green.shade600
                          : Colors.blueGrey.shade700,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        btnReady
                            ? Colors.green.shade900
                            : Colors.blueGrey.shade900,
                    width: 2,
                  ),
                  boxShadow:
                      btnReady
                          ? [
                            const BoxShadow(
                              color: Colors.black54,
                              offset: Offset(2, 4),
                              blurRadius: 4,
                            ),
                          ]
                          : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  btnReady ? t('measureBtn') : t('doneBtn'),
                  style: TextStyle(
                    color: btnReady ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickWidget({
    required double length,
    required bool horizontal,
    required bool isGhost,
    bool highlight = false,
  }) {
    double w = horizontal ? length * _unitPixels : 28;
    double h = horizontal ? 28 : length * _unitPixels;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color:
            isGhost ? Colors.indigo.withOpacity(0.4) : Colors.yellow.shade600,
        border: Border.all(
          color: isGhost ? Colors.white30 : Colors.brown.shade800,
          width: isGhost ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow:
            highlight
                ? [
                  BoxShadow(
                    color: Colors.amber.shade500,
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
                : [],
      ),
      // Perfectly center text in all sticks, handles narrow width nicely using FittedBox
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            _formatFractionText(length),
            style: TextStyle(
              color: isGhost ? Colors.white70 : Colors.brown.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index, int currentStep, String task, String outcome) {
    bool isCompleted = index < currentStep;
    bool isActive = index == currentStep;
    bool isUpcoming = index > currentStep;

    Color bgColor =
        isActive
            ? Colors.indigo.withOpacity(0.1)
            : (isCompleted
                ? Colors.green.withOpacity(0.05)
                : Colors.white.withOpacity(0.02));
    Color borderColor =
        isActive
            ? Colors.indigo.shade400
            : (isCompleted ? Colors.green.shade400 : Colors.white24);

    return Opacity(
      opacity: isUpcoming ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isActive
                  ? [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted
                        ? Colors.transparent
                        : (isActive
                            ? Colors.indigo.shade500
                            : Colors.blueGrey.shade700),
              ),
              alignment: Alignment.center,
              child:
                  isCompleted
                      ? const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 28,
                      )
                      : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Label
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white24, width: 1),
                      ),
                    ),
                    child: Text(
                      "${t('stepLabel')} ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Task
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: "${t('taskInst')} ",
                          style: TextStyle(
                            color: Colors.indigo.shade300,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: task),
                      ],
                    ),
                  ),
                  // Outcome
                  if (isCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.green.shade400,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t('expOut'),
                                style: TextStyle(
                                  color: Colors.green.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            outcome,
                            style: TextStyle(
                              color: Colors.greenAccent.shade100,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    int currentStep = _currentStep;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: const Border(
          right: BorderSide(color: Colors.white24, width: 1),
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.science,
                        color: Colors.indigoAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('appTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Buttons placed right below Title/Subtitle as requested
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.language,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          _lang.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: _toggleLanguage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent.shade400,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          t('resetBtn'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade400,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // Content Pad
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scenario Dropdown in Sidebar
                  Text(
                    t('selectScenario').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.indigo.withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario,
                        dropdownColor: const Color(0xFF1E293B),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        items:
                            [1, 2, 3, 4, 5].map((int val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text(
                                  t('s${val}_title'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            _playSound('click');
                            _loadScenario(val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Objective
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Colors.pinkAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('learnLbl'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t('s${_scenario}_obj'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // HTML-styled Multi-Steps
                  _buildStep(
                    0,
                    currentStep,
                    t('s${_scenario}_step1_task'),
                    t('s${_scenario}_step1_out'),
                  ),
                  _buildStep(
                    1,
                    currentStep,
                    t('s${_scenario}_step2_task'),
                    t('s${_scenario}_step2_out'),
                  ),
                  _buildStep(
                    2,
                    currentStep,
                    t('s${_scenario}_step3_task'),
                    t('s${_scenario}_step3_out'),
                  ),

                  // Completion Summary Output
                  if (_labCompleted) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('summaryTitle'),
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (_scenario == 4 || _scenario == 5) ...[
                            Text(
                              "${t('actualIs').replaceAll('{actual}', _measuredCount.toString())} ${t('predWas').replaceAll('{feedback}', _prediction == (_scenario == 4 ? 'greater' : 'smaller') ? t('correctTxt') : t('incorrectTxt'))}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (_scenario == 4
                                      ? t('isGreaterThan')
                                      : t('isSmallerThan'))
                                  .replaceAll(
                                    '{actual}',
                                    _measuredCount.toString(),
                                  )
                                  .replaceAll(
                                    '{target}',
                                    (_scenario == 4 ? '3' : '6'),
                                  ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          Text(
                            t('s${_scenario}_sum'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.black26,
              alignment: Alignment.center,
              child: Text(
                t('footer'),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggablePredictionPopup() {
    int target = _scenario == 4 ? 3 : 6;
    return Positioned(
      left: _predictionPopupPos.dx,
      top: _predictionPopupPos.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _predictionPopupPos += details.delta;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320, // More Compact
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.indigo.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Icon(
                  Icons.help_outline,
                  color: Colors.indigoAccent,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  t('predQ').replaceAll('{target}', target.toString()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _playSound('click');
                          _handlePrediction('greater');
                        },
                        icon: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          t('greaterBtn'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _playSound('click');
                          _handlePrediction('smaller');
                        },
                        icon: const Icon(
                          Icons.trending_down,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          t('smallerBtn'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSuccessPopup() {
    return Positioned(
      left: _successPopupPos.dx,
      top: _successPopupPos.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _successPopupPos += details.delta;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 350, // More Compact
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.greenAccent.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t('labCompleted'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t('finalDesc'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _handleReset,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    t('resetBtn'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade500,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

  Widget _buildCurtain() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF020617),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science, color: Colors.indigoAccent, size: 100),
          const SizedBox(height: 30),
          Text(
            t('appTitle'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            t('appSubtitle'),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () {
              _playSound('click');
              _curtainController.forward().then((_) {
                setState(() => _showCurtain = false);
              });
            },
            icon: const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 28,
            ),
            label: Text(
              t('enterLab'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 10,
              shadowColor: Colors.indigoAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Canvas Drawing Engine ---
class LabCanvasPainter extends CustomPainter {
  final double ribbonLength;
  final double stickLength;
  final int scenario;
  final double unitPixels;
  final int measuredCount;
  final bool labCompleted;
  final bool stickSnapped;

  final String Function(String) t;

  LabCanvasPainter({
    required this.ribbonLength,
    required this.stickLength,
    required this.scenario,
    required this.unitPixels,
    required this.measuredCount,
    required this.labCompleted,
    required this.stickSnapped,
    required this.t,
  });

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color,
    double fontSize, {
    bool italic = false,
    bool bold = false,
  }) {
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        fontFamily: 'sans-serif',
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawTextLeft(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color,
    double fontSize,
    bool isBold,
  ) {
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'sans-serif',
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }

  void _draw3DBlock(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double dx,
    double dy,
    Color top,
    Color front,
    Color side, {
    bool drawLines = false,
    Color? strokeColor,
  }) {
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = strokeColor ?? Colors.black.withOpacity(0.5)
          ..strokeWidth = 1.5;

    // Top Face
    Path topPath =
        Path()
          ..moveTo(x, y)
          ..lineTo(x + dx, y + dy)
          ..lineTo(x + w + dx, y + dy)
          ..lineTo(x + w, y)
          ..close();
    canvas.drawPath(topPath, fillPaint..color = top);
    canvas.drawPath(topPath, strokePaint);

    // Side Face
    Path sidePath =
        Path()
          ..moveTo(x + w, y)
          ..lineTo(x + w + dx, y + dy)
          ..lineTo(x + w + dx, y + h + dy)
          ..lineTo(x + w, y + h)
          ..close();
    canvas.drawPath(sidePath, fillPaint..color = side);
    canvas.drawPath(sidePath, strokePaint);

    // Front Face
    Rect frontRect = Rect.fromLTWH(x, y, w, h);
    canvas.drawRect(frontRect, fillPaint..color = front);
    canvas.drawRect(frontRect, strokePaint);

    if (drawLines) {
      final Paint linePaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.white54
            ..strokeWidth = 1;
      for (int i = 1; i < ribbonLength; i++) {
        canvas.drawLine(
          Offset(x + i * unitPixels, y),
          Offset(x + i * unitPixels + dx, y + dy),
          linePaint,
        );
      }
    }
  }

  void _drawSummaryBox(
    Canvas canvas,
    double ox,
    double ribbonStartX,
    double oy,
  ) {
    int targetVal =
        (scenario == 4) ? 3 : ((scenario == 5) ? 6 : ribbonLength.toInt());
    int qVal = measuredCount;
    bool isGreater = qVal > targetVal;

    Color compColor;
    if (isGreater) {
      compColor = const Color(0xFF10B981);
    } else if (qVal < targetVal)
      compColor = const Color(0xFFEF4444);
    else
      compColor = const Color(0xFF3B82F6);

    String compText =
        isGreater
            ? t('compGreater')
            : (qVal < targetVal ? t('compSmaller') : t('compEqual'));

    double sx = ox + ribbonStartX;
    double sy = oy + 160;
    double sw = 420;
    double sh = 95;

    // Background Rect
    canvas.drawShadow(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx, sy, sw, sh),
          const Radius.circular(12),
        ),
      ),
      Colors.black.withOpacity(0.3),
      15,
      true,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx, sy, sw, sh),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx, sy, sw, sh),
        const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    String formatFraction(double val) {
      if (val == 0.25) return "1/4";
      if (val == 0.5) return "1/2";
      if (val == 0.75) return "3/4";
      if (val == 1.5) return "3/2";
      return val.toInt().toString();
    }

    // Text Lines
    String line1 = t(
      'sumBoxDiv',
    ).replaceAll('{div}', ribbonLength.toInt().toString());
    String line2 = t(
      'sumBoxDsr',
    ).replaceAll('{dsr}', formatFraction(stickLength));
    String line3 = t('sumBoxQ').replaceAll('{q}', measuredCount.toString());

    _drawTextLeft(canvas, line1, sx + 20, sy + 15, Colors.white, 14, false);
    _drawTextLeft(canvas, line2, sx + 20, sy + 40, Colors.white, 14, false);
    _drawTextLeft(canvas, line3, sx + 20, sy + 65, Colors.white, 14, true);

    // Arrow Connecting Counter to Ribbon logic
    double cx = ox + ribbonStartX + (ribbonLength * unitPixels) + 60;
    double cy = oy - 60;
    double counterMidX = cx + 100;
    double counterBottomY = cy + 80;
    double ribbonRightX = ox + ribbonStartX + (ribbonLength * unitPixels);

    Paint arrowPaint =
        Paint()
          ..color = compColor
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    Path arrowPath =
        Path()
          ..moveTo(counterMidX - 40, counterBottomY + 10)
          ..lineTo(counterMidX - 40, counterBottomY + 40)
          ..lineTo(ribbonRightX + 20, counterBottomY + 40);
    canvas.drawPath(arrowPath, arrowPaint);

    // Arrowhead
    Path arrowHead =
        Path()
          ..moveTo(ribbonRightX + 20, counterBottomY + 40 - 8)
          ..lineTo(ribbonRightX + 20, counterBottomY + 40 + 8)
          ..lineTo(ribbonRightX + 5, counterBottomY + 40)
          ..close();
    canvas.drawPath(
      arrowHead,
      Paint()
        ..color = compColor
        ..style = PaintingStyle.fill,
    );

    // Label Box on Arrow
    double lx = counterMidX - 110;
    double ly = counterBottomY + 22;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lx, ly, 160, 36),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lx, ly, 160, 36),
        const Radius.circular(8),
      ),
      Paint()
        ..color = compColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(canvas, compText, lx + 80, ly + 18, compColor, 13, bold: true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double ox = 1000;
    const double oy = 600;

    double deskY = -250;

    // 1. Draw Table Background
    Path tableTop =
        Path()
          ..moveTo(ox - 2000, oy + deskY + 600)
          ..lineTo(ox + 2000, oy + deskY + 600)
          ..lineTo(ox + 2400, oy + deskY)
          ..lineTo(ox - 1600, oy + deskY)
          ..close();
    canvas.drawPath(
      tableTop,
      Paint()
        ..color = const Color(0xFF30261E)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      tableTop,
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.drawRect(
      Rect.fromLTWH(ox - 2000, oy + deskY + 600, 4000, 100),
      Paint()..color = const Color(0xFF1F1812),
    );

    // 2. Draw Tool Rack Base
    double rx = 0;
    double ry = -180;
    _draw3DBlock(
      canvas,
      ox + rx,
      oy + ry,
      360,
      40,
      30,
      -30,
      const Color(0xFF475569),
      const Color(0xFF334155),
      const Color(0xFF1E293B),
    );

    for (int i = 0; i < 5; i++) {
      double slotX = ox + rx + 30 + i * 60;
      Path slot =
          Path()
            ..moveTo(slotX, oy + ry)
            ..lineTo(slotX + 20, oy + ry)
            ..lineTo(slotX + 20 + 18, oy + ry - 18)
            ..lineTo(slotX + 18, oy + ry - 18)
            ..close();
      canvas.drawPath(slot, Paint()..color = Colors.black.withOpacity(0.4));
    }

    // 3. Draw 1-Unit Reference Block
    double ribbonStartX = -(ribbonLength * unitPixels) / 2;
    _draw3DBlock(
      canvas,
      ox + ribbonStartX,
      oy - 100,
      unitPixels,
      30,
      20,
      -20,
      const Color(0xFF64748B),
      const Color(0xFF475569),
      const Color(0xFF334155),
    );
    _drawText(
      canvas,
      t('unitRef'),
      ox + ribbonStartX + unitPixels / 2,
      oy - 100 + 15,
      Colors.white,
      13,
      bold: true,
    );

    // 4. Draw Active Slot Base
    double maxW = 2 * unitPixels;
    _draw3DBlock(
      canvas,
      ox + ribbonStartX - 10,
      oy - 20,
      maxW + 20,
      10,
      30,
      -30,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      const Color(0xFF020617),
    );
    _drawText(
      canvas,
      t('activeSlotLbl'),
      ox + ribbonStartX + maxW / 2,
      oy - 20 - 35,
      const Color(0xFF94A3B8),
      12,
      italic: true,
    );

    // 5. Draw Ribbon
    List<Color> ribbonTops = [
      const Color(0xFFF87171),
      const Color(0xFF60A5FA),
      const Color(0xFF34D399),
      const Color(0xFFFACC15),
      const Color(0xFFC084FC),
    ];
    List<Color> ribbonFronts = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFEAB308),
      const Color(0xFFA855F7),
    ];
    List<Color> ribbonSides = [
      const Color(0xFFB91C1C),
      const Color(0xFF1D4ED8),
      const Color(0xFF047857),
      const Color(0xFFA16207),
      const Color(0xFF7E22CE),
    ];

    int cIdx = scenario - 1;
    canvas.drawShadow(
      Path()..addRect(
        Rect.fromLTWH(
          ox + ribbonStartX,
          oy + 100 + 5,
          ribbonLength * unitPixels,
          15,
        ),
      ),
      Colors.black.withOpacity(0.2),
      10,
      true,
    );
    _draw3DBlock(
      canvas,
      ox + ribbonStartX,
      oy + 100,
      ribbonLength * unitPixels,
      15,
      25,
      -25,
      ribbonTops[cIdx],
      ribbonFronts[cIdx],
      ribbonSides[cIdx],
      drawLines: true,
      strokeColor: Colors.black.withOpacity(0.3),
    );

    // 6. Draw Digital Counter Base
    double cx = ribbonStartX + (ribbonLength * unitPixels) + 60;
    double cy = 100 - 60;
    _draw3DBlock(
      canvas,
      ox + cx,
      oy + cy,
      200,
      80,
      20,
      -20,
      const Color(0xFF475569),
      const Color(0xFF334155),
      const Color(0xFF1E293B),
      strokeColor: Colors.black.withOpacity(0.6),
    );

    canvas.drawRect(
      Rect.fromLTWH(ox + cx + 10, oy + cy + 15, 70, 50),
      Paint()..color = const Color(0xFF020617),
    );
    canvas.drawRect(
      Rect.fromLTWH(ox + cx + 10, oy + cy + 15, 70, 50),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      t('quotientTitle'),
      ox + cx + 100,
      oy + cy - 25,
      const Color(0xFF94A3B8),
      11,
      bold: true,
    );

    // 7. Draw Summary Board
    if (labCompleted) {
      _drawSummaryBox(canvas, ox, ribbonStartX, oy);
    }
  }

  @override
  bool shouldRepaint(covariant LabCanvasPainter oldDelegate) {
    return oldDelegate.ribbonLength != ribbonLength ||
        oldDelegate.stickLength != stickLength ||
        oldDelegate.scenario != scenario ||
        oldDelegate.measuredCount != measuredCount ||
        oldDelegate.labCompleted != labCompleted ||
        oldDelegate.stickSnapped != stickSnapped;
  }
}
