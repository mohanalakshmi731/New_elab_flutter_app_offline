// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Added for Audio interactions

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RemovingBracketsPrecededSubtraction());
}

// Global Audio Manager
class AudioManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _startPlayer = AudioPlayer();
  static final AudioPlayer _successPlayer = AudioPlayer();
  static final AudioPlayer _correctPlayer = AudioPlayer();
  static final AudioPlayer _incorrectPlayer = AudioPlayer();
  static final AudioPlayer _resetPlayer = AudioPlayer();

  // Pool for overlapping flip sounds
  static final List<AudioPlayer> _flipPlayers = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  static int _flipIndex = 0;

  // Mixkit Child-friendly Audio URLs
  static const String sndClick =
      'audio/class7/mixkit_2568.mp3'; // Pop
  static const String sndStart =
      'audio/class7/mixkit_2018.mp3'; // Upbeat start
  static const String sndFlip =
      'audio/class7/mixkit_1003.mp3'; // Magical wand shimmer
  static const String sndSuccess =
      'audio/class7/mixkit_2013.mp3'; // Level up magical
  static const String sndCorrect =
      'audio/class7/mixkit_2000.mp3'; // Happy bell
  static const String sndIncorrect =
      'audio/class7/mixkit_2003.mp3'; // Gentle error
  static const String sndReset =
      'audio/class7/mixkit_1492.mp3'; // Swoosh / Reset

  static void playClick() => _clickPlayer.play(AssetSource(sndClick));
  static void playStart() => _startPlayer.play(AssetSource(sndStart));
  static void playSuccess() => _successPlayer.play(AssetSource(sndSuccess));
  static void playCorrect() => _correctPlayer.play(AssetSource(sndCorrect));
  static void playIncorrect() => _incorrectPlayer.play(AssetSource(sndIncorrect));
  static void playReset() => _resetPlayer.play(AssetSource(sndReset));

  static void playFlip() {
    _flipIndex = (_flipIndex + 1) % _flipPlayers.length;
    _flipPlayers[_flipIndex].play(AssetSource(sndFlip));
  }
}

// Global Custom Models
class BracketTerm {
  final String label;
  final double relativeX;
  final bool initialPositive;

  BracketTerm({
    required this.label,
    required this.relativeX,
    required this.initialPositive,
  });
}

class Scenario {
  final int index;
  final String title;
  final String mission;
  final String description;
  final int initialValue;
  final bool isMinusGate; // True: Red Gate (-), False: Green Gate (+)
  final List<BracketTerm> terms;
  final String equationBefore;
  final String equationAfter;
  final int finalValue;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  Scenario({
    required this.index,
    required this.title,
    required this.mission,
    required this.description,
    required this.initialValue,
    required this.isMinusGate,
    required this.terms,
    required this.equationBefore,
    required this.equationAfter,
    required this.finalValue,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

// Particles / Sparks definition
class Spark {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double maxLife;
  double life;

  Spark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;

  void update() {
    x += vx;
    y += vy;
    vy += 0.12; // Gravity effect
    life -= 1.0;
  }
}

// Custom Scroll Behavior to ensure Drag-to-Pan works on Web and Desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class RemovingBracketsPrecededSubtraction extends StatefulWidget {
  const RemovingBracketsPrecededSubtraction({super.key});

  @override
  State<RemovingBracketsPrecededSubtraction> createState() =>
      _RemovingBracketsPrecededSubtractionState();
}

class _RemovingBracketsPrecededSubtractionState
    extends State<RemovingBracketsPrecededSubtraction>
    with TickerProviderStateMixin {
  // Navigator and ScaffoldMessenger state keys for global safely guided access
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Curtain State
  bool _isCurtainRaised = false;

  late List<Scenario> _scenarios;
  int _currentScenarioIndex = 0;
  int _currentStep = 1; // 1: Setup, 2: Run/Transition, 3: Success Reveal

  bool _isSidebarOpen = true;
  bool _isPlaying = false;
  double _conveyorProgress = 0.0; // 0.0 to 1.0
  double _simulationSpeed = 1.0; // Speed modifier

  late AnimationController _animationController;
  late AnimationController _curtainPulseController;

  // Track state of term sign flips inside current run
  late List<bool> _termsFlipped;

  // Active particles/sparks list
  final List<Spark> _sparks = [];
  Timer? _sparkTimer;

  // Interactive Zoom and Pan controller
  final TransformationController _transformationController =
      TransformationController();

  // Questionnaire status
  int? _selectedAnswerIndex;
  bool _questionAnswered = false;
  bool _isAnswerCorrect = false;

  // Localization and Global State Controls
  bool _isHindi = false;

  // Helper method for translation
  String tr(String en, String hi) => _isHindi ? hi : en;

  void _fullReset() {
    AudioManager.playReset();
    setState(() {
      _isCurtainRaised = false;
      _isHindi = false;
      _buildScenarios(); // Rebuild for English
      _initializeScenario(0);
    });
  }

  void _buildScenarios() {
    _scenarios = [
      Scenario(
        index: 0,
        title: tr("The Basic Flip", "बेसिक फ्लिप"),
        mission: tr(
          "To visually understand how 100 - (15 + 56) is equivalent to 100 - 15 - 56.",
          "दृश्य रूप से समझने के लिए कि 100 - (15 + 56) 100 - 15 - 56 के बराबर कैसे है।",
        ),
        description: tr(
          "Observe the red subtraction gate inverting the sign of positive terms inside the glass bracket crate.",
          "ग्लास ब्रैकेट क्रेट के अंदर धनात्मक पदों के चिह्न को उलटने वाले लाल घटाव गेट का निरीक्षण करें।",
        ),
        initialValue: 100,
        isMinusGate: true,
        terms: [
          BracketTerm(label: "15", relativeX: -60, initialPositive: true),
          BracketTerm(label: "56", relativeX: 60, initialPositive: true),
        ],
        equationBefore: "100 - (15 + 56)",
        equationAfter: "100 - 15 - 56",
        finalValue: 29,
        questionText: tr(
          "When the blue (+15) and (+56) blocks went through the red MINUS gate, what happened?",
          "जब नीले (+15) और (+56) ब्लॉक लाल MINUS गेट से गुजरे, तो क्या हुआ?",
        ),
        options: [
          tr(
            "They flipped to red (-15) and (-56) blocks!",
            "वे लाल (-15) और (-56) ब्लॉक में बदल गए!",
          ),
          tr("They stayed positive and blue.", "वे सकारात्मक और नीले रहे।"),
          tr(
            "They merged into a single (+71) block.",
            "वे एक एकल (+71) ब्लॉक में विलीन हो गए।",
          ),
        ],
        correctOptionIndex: 0,
        explanation: tr(
          "Correct! The red Minus gate acts as a Sign Flipper, reversing the sign of every term inside the brackets.",
          "सही! लाल माइनस गेट एक साइन फ्लिपर के रूप में कार्य करता है, जो कोष्ठक के अंदर हर पद के चिह्न को उलट देता है।",
        ),
      ),
      Scenario(
        index: 1,
        title: tr("The Double Flip", "डबल फ्लिप"),
        mission: tr(
          "To visually understand how 500 - (250 - 100) is equivalent to 500 - 250 + 100.",
          "दृश्य रूप से समझने के लिए कि 500 - (250 - 100) 500 - 250 + 100 के बराबर कैसे है।",
        ),
        description: tr(
          "Watch a negative term inside the crate change into a positive term when crossing the subtraction sign.",
          "क्रेट के अंदर एक ऋणात्मक पद को घटाव के चिह्न को पार करते समय धनात्मक पद में बदलते हुए देखें।",
        ),
        initialValue: 500,
        isMinusGate: true,
        terms: [
          BracketTerm(label: "250", relativeX: -60, initialPositive: true),
          BracketTerm(label: "100", relativeX: 60, initialPositive: false),
        ],
        equationBefore: "500 - (250 - 100)",
        equationAfter: "500 - 250 + 100",
        finalValue: 350,
        questionText: tr(
          "Why did the red (-100) block turn into a blue (+100) block after passing the minus gate?",
          "माइनस गेट से गुजरने के बाद लाल (-100) ब्लॉक नीले (+100) ब्लॉक में क्यों बदल गया?",
        ),
        options: [
          tr(
            "Because subtracting a negative is the same as adding a positive!",
            "क्योंकि एक ऋणात्मक को घटाना एक धनात्मक को जोड़ने के समान है!",
          ),
          tr("The gate ran out of red paint.", "गेट का लाल रंग खत्म हो गया।"),
          tr("It was a random glitch.", "यह एक यादृच्छिक गड़बड़ी थी।"),
        ],
        correctOptionIndex: 0,
        explanation: tr(
          "Excellent! Reversing a negative term (- -100) creates a positive term (+100). Thus, a - (b - c) = a - b + c.",
          "उत्कृष्ट! एक ऋणात्मक पद (- -100) को उलटने से एक धनात्मक पद (+100) बनता है। इस प्रकार, a - (b - c) = a - b + c।",
        ),
      ),
      Scenario(
        index: 2,
        title: tr("Multi-Term Mystery", "बहु-पद रहस्य"),
        mission: tr(
          "To visually understand how 150 - (50 + 30 - 20) is equivalent to 150 - 50 - 30 + 20.",
          "दृश्य रूप से समझने के लिए कि 150 - (50 + 30 - 20) 150 - 50 - 30 + 20 के बराबर कैसे है।",
        ),
        description: tr(
          "Verify that the subtraction sign outside reverses the signs of all terms, no matter how many are inside.",
          "सत्यापित करें कि बाहर का घटाव चिह्न सभी पदों के चिह्नों को उलट देता है, चाहे अंदर कितने भी हों।",
        ),
        initialValue: 150,
        isMinusGate: true,
        terms: [
          BracketTerm(label: "50", relativeX: -85, initialPositive: true),
          BracketTerm(label: "30", relativeX: 0, initialPositive: true),
          BracketTerm(label: "20", relativeX: 85, initialPositive: false),
        ],
        equationBefore: "150 - (50 + 30 - 20)",
        equationAfter: "150 - 50 - 30 + 20",
        finalValue: 90,
        questionText: tr(
          "How many signs were flipped inside the brackets during this 3-term scenario?",
          "इस 3-पद परिदृश्य के दौरान कोष्ठक के अंदर कितने चिह्न उल्टे गए?",
        ),
        options: [
          tr("All three signs were flipped!", "तीनों चिह्न उल्टे गए थे!"),
          tr(
            "Only the first sign was flipped.",
            "केवल पहला चिह्न उल्टा गया था。",
          ),
          tr(
            "None of the signs were flipped.",
            "कोई भी चिह्न उल्टा नहीं गया था।",
          ),
        ],
        correctOptionIndex: 0,
        explanation: tr(
          "Spot on! The subtraction sign outside the bracket flips the sign of every single term inside, no matter the quantity.",
          "बिल्कुल सही! ब्रैकेट के बाहर घटाव का चिह्न अंदर के हर एक पद के चिह्न को उलट देता है, चाहे मात्रा कुछ भी हो।",
        ),
      ),
      Scenario(
        index: 3,
        title: tr("The Friendly Gate", "मित्रतापूर्ण गेट"),
        mission: tr(
          "To visually understand why 300 + (100 - 40) is equivalent to 300 + 100 - 40.",
          "दृश्य रूप से समझने के लिए कि 300 + (100 - 40) 300 + 100 - 40 के बराबर क्यों है।",
        ),
        description: tr(
          "Observe the green PLUS gate, demonstrating that addition preceding brackets does not change any signs inside.",
          "हरे PLUS गेट का निरीक्षण करें, यह प्रदर्शित करते हुए कि कोष्ठक से पहले जोड़ अंदर किसी भी चिह्न को नहीं बदलता है।",
        ),
        initialValue: 300,
        isMinusGate: false,
        terms: [
          BracketTerm(label: "100", relativeX: -60, initialPositive: true),
          BracketTerm(label: "40", relativeX: 60, initialPositive: false),
        ],
        equationBefore: "300 + (100 - 40)",
        equationAfter: "300 + 100 - 40",
        finalValue: 360,
        questionText: tr(
          "Why did the blocks NOT change color as they passed through the Green Gate?",
          "ग्रीन गेट से गुजरते समय ब्लॉकों ने रंग क्यों नहीं बदला?",
        ),
        options: [
          tr(
            "Because it is a PLUS (+) gate, which does not flip signs!",
            "क्योंकि यह एक PLUS (+) गेट है, जो चिह्नों को नहीं उलटता है!",
          ),
          tr("The gate was powered down.", "गेट की बिजली बंद थी।"),
          tr(
            "Green represents an error.",
            "हरा रंग एक त्रुटि का प्रतिनिधित्व करता है।",
          ),
        ],
        correctOptionIndex: 0,
        explanation: tr(
          "Perfect! A plus sign preceding a bracket does not change any signs inside. a + (b - c) remains a + b - c.",
          "उत्तम! कोष्ठक से पहले एक प्लस चिह्न अंदर किसी भी चिह्न को नहीं बदलता है। a + (b - c) रहता है a + b - c।",
        ),
      ),
      Scenario(
        index: 4,
        title: tr("Negatives Out Front", "सामने नकारात्मक"),
        mission: tr(
          "To visually understand why 80 - (-20 + 30) is equivalent to 80 + 20 - 30.",
          "दृश्य रूप से समझने के लिए कि 80 - (-20 + 30) 80 + 20 - 30 के बराबर क्यों है।",
        ),
        description: tr(
          "Observe how an initial negative term inside brackets flips to positive first when subtracted.",
          "देखें कि कैसे कोष्ठक के अंदर एक प्रारंभिक ऋणात्मक पद घटाए जाने पर पहले धनात्मक में बदल जाता है।",
        ),
        initialValue: 80,
        isMinusGate: true,
        terms: [
          BracketTerm(label: "20", relativeX: -60, initialPositive: false),
          BracketTerm(label: "30", relativeX: 60, initialPositive: true),
        ],
        equationBefore: "80 - (-20 + 30)",
        equationAfter: "80 + 20 - 30",
        finalValue: 70,
        questionText: tr(
          "The first term was already negative (-20) inside the bracket. What did it become after passing?",
          "ब्रैकेट के अंदर पहला पद पहले से ही ऋणात्मक (-20) था। गुजरने के बाद यह क्या हो गया?",
        ),
        options: [
          tr("It flipped to positive (+20)!", "यह धनात्मक (+20) में बदल गया!"),
          tr("It stayed negative (-20).", "यह ऋणात्मक (-20) रहा।"),
          tr("It dissolved to zero.", "यह शून्य में विलीन हो गया।"),
        ],
        correctOptionIndex: 0,
        explanation: tr(
          "Amazing! The minus sign flipped the negative term into a positive term: -(-20) = +20.",
          "अद्भुत! माइनस चिह्न ने ऋणात्मक पद को धनात्मक पद में बदल दिया: -(-20) = +20।",
        ),
      ),
    ];
  }

  Widget _buildLangButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        AudioManager.playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.cyanAccent : Colors.white54,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Forced Landscape & Fullscreen Mode on start
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Setup pulsing animation for curtain button
    _curtainPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initial build of scenarios
    _buildScenarios();

    // Duration for standard run distance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _initializeScenario(_currentScenarioIndex);

    _animationController.addListener(() {
      setState(() {
        _conveyorProgress = _animationController.value;
        _checkConveyorThresholds();
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        AudioManager.playSuccess();
        setState(() {
          _isPlaying = false;
          _currentStep = 3;
        });
        _showSuccessDialog();
      }
    });

    // Particle/Spark Engine Timer
    _sparkTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_sparks.isNotEmpty) {
        setState(() {
          for (int i = _sparks.length - 1; i >= 0; i--) {
            _sparks[i].update();
            if (_sparks[i].life <= 0) {
              _sparks.removeAt(i);
            }
          }
        });
      }
    });
  }

  void _initializeScenario(int index) {
    _currentScenarioIndex = index;
    final sc = _scenarios[index];
    _termsFlipped = List.generate(sc.terms.length, (_) => false);
    _currentStep = 1;
    _conveyorProgress = 0.0;
    _isPlaying = false;
    _animationController.reset();
    _selectedAnswerIndex = null;
    _questionAnswered = false;
    _isAnswerCorrect = false;
    _sparks.clear();
  }

  void _checkConveyorThresholds() {
    final sc = _scenarios[_currentScenarioIndex];
    const double startX = 200.0;
    const double endX = 850.0;
    const double gateX = 625.0;

    double crateX = startX + _conveyorProgress * (endX - startX);

    for (int i = 0; i < sc.terms.length; i++) {
      double termGlobalX = crateX + sc.terms[i].relativeX;
      if (termGlobalX >= gateX && !_termsFlipped[i]) {
        _termsFlipped[i] = true;
        AudioManager.playFlip(); // Play flip sound effect
        _spawnSparks(
          gateX,
          230,
          sc.isMinusGate ? Colors.redAccent : Colors.greenAccent,
        );
      }
    }
  }

  void _spawnSparks(double x, double y, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 25; i++) {
      double angle = rand.nextDouble() * 2 * math.pi;
      double speed = 1.5 + rand.nextDouble() * 4.5;
      _sparks.add(
        Spark(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 1.5,
          color: color,
          size: 3.0 + rand.nextDouble() * 5.0,
          maxLife: 15.0 + rand.nextInt(20),
        ),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _animationController.dispose();
    _curtainPulseController.dispose();
    _sparkTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  void _raiseCurtain() {
    AudioManager.playSuccess();
    setState(() {
      _isCurtainRaised = true;
    });
  }

  // Simulation Controls
  void _startSimulation() {
    if (_currentStep == 3) {
      _resetSimulation();
    }
    AudioManager.playStart();
    setState(() {
      _isPlaying = true;
      _currentStep = 2;
    });
    _animationController.duration = Duration(
      milliseconds: (6000 / _simulationSpeed).round(),
    );
    _animationController.forward(from: _conveyorProgress);
  }

  void _pauseSimulation() {
    AudioManager.playClick();
    setState(() {
      _isPlaying = false;
    });
    _animationController.stop();
  }

  void _resetSimulation() {
    AudioManager.playReset();
    setState(() {
      _initializeScenario(_currentScenarioIndex);
    });
  }

  // Triggered when slider interaction ends to avoid sound spam
  void _changeSpeedEnd(double speed) {
    AudioManager.playClick();
    setState(() {
      if (_isPlaying) {
        _animationController.duration = Duration(
          milliseconds: (6000 / _simulationSpeed).round(),
        );
        _animationController.forward(from: _conveyorProgress);
      }
    });
  }

  void _handleAnswer(int index) {
    if (_questionAnswered) return;
    final sc = _scenarios[_currentScenarioIndex];

    bool isCorrect = (index == sc.correctOptionIndex);

    if (isCorrect) {
      AudioManager.playCorrect();
    } else {
      AudioManager.playIncorrect();
    }

    setState(() {
      _selectedAnswerIndex = index;
      _questionAnswered = true;
      _isAnswerCorrect = isCorrect;
    });
  }

  void _showSuccessDialog() {
    final sc = _scenarios[_currentScenarioIndex];
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.cyanAccent, width: 2),
              ),
              title: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr("Challenge Solved!", "चुनौती हल हो गई!"),
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.cyanAccent.shade100,
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 450,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        "Excellent work! You successfully navigated the brackets through the gate.",
                        "उत्कृष्ट कार्य! आपने गेट के माध्यम से कोष्ठकों को सफलतापूर्वक नेविगेट किया।",
                      ),
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            tr(
                              "Mathematical Transformation:",
                              "गणितीय परिवर्तन:",
                            ),
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${sc.equationBefore}  ➡  ${sc.equationAfter}",
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${tr("Final Calculated Value:", "अंतिम गणना मान:")} ${sc.finalValue}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sc.isMinusGate
                          ? tr(
                              "Takeaway: Because the brackets were preceded by a subtraction sign (-), every term inside flipped its sign.",
                              "निष्कर्ष: चूंकि कोष्ठक से पहले घटाव का चिह्न (-) था, इसलिए अंदर के प्रत्येक पद का चिह्न उलट गया।",
                            )
                          : tr(
                              "Takeaway: Because the brackets were preceded by an addition sign (+), the terms remained exactly unchanged.",
                              "निष्कर्ष: चूंकि कोष्ठक से पहले जोड़ का चिह्न (+) था, इसलिए पद बिल्कुल अपरिवर्तित रहे।",
                            ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    AudioManager.playReset();
                    Navigator.of(context).pop();
                    _resetSimulation();
                  },
                  child: Text(
                    tr("Replay Scenario", "परिदृश्य फिर से चलाएं"),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    AudioManager.playClick();
                    Navigator.of(context).pop();
                    if (_currentScenarioIndex < _scenarios.length - 1) {
                      setState(() {
                        _initializeScenario(_currentScenarioIndex + 1);
                      });
                    } else {
                      setState(() {
                        _initializeScenario(0);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.shade700,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    _currentScenarioIndex < _scenarios.length - 1
                        ? tr("Next Challenge ➔", "अगली चुनौती ➔")
                        : tr("Start Over ➔", "फिर से शुरू करें ➔"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: tr(
        "Removing Brackets Preceded by Subtraction",
        "घटाव से पहले वाले कोष्ठक हटाना",
      ),
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(), // Enables Drag on Desktop/Web
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0F172A),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF1E293B),
        ),
      ),
      home: Builder(
        builder: (builderContext) {
          final double screenWidth = MediaQuery.of(builderContext).size.width;
          final double screenHeight = MediaQuery.of(builderContext).size.height;
          final double sidebarWidth = _isSidebarOpen
              ? math.max(300.0, screenWidth * 0.3)
              : 0.0;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
            },
            child: Scaffold(
              body: Stack(
                children: [
                  // MAIN APP CONTENT (Underneath Curtain)
                  Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF080D1A), Color(0xFF131B2F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // MAIN INTERACTIVE CANVAS
                      Positioned.fill(
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.only(
                            left: _isSidebarOpen ? sidebarWidth : 0,
                          ),
                          child: ClipRect(
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  transformationController:
                                      _transformationController,
                                  minScale: 0.1, // Unrestricted zooming
                                  maxScale: 4.0, // Unrestricted zooming
                                  boundaryMargin: const EdgeInsets.all(
                                    double.infinity,
                                  ), // Infinite Pan bounds
                                  panEnabled: true,
                                  scaleEnabled: true,
                                  child: Container(
                                    // Make sure background grabs pointers so transparent space is dragable
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Container(
                                        width: 1300,
                                        height: 600,
                                        margin: const EdgeInsets.only(top: 20),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter:
                                                    GridBackgroundPainter(),
                                              ),
                                            ),
                                            Positioned(
                                              top: 30,
                                              left: 20,
                                              right: 20,
                                              child: _buildEquationTracker(),
                                            ),
                                            // Master Isometric Factory Painter
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: FactoryPainter(
                                                  progress: _conveyorProgress,
                                                  scenario:
                                                      _scenarios[_currentScenarioIndex],
                                                  termsFlipped: _termsFlipped,
                                                  sparks: _sparks,
                                                  isHindi: _isHindi,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                if (!_isSidebarOpen)
                                  Positioned(
                                    top: 70,
                                    left: 16,
                                    width: 280,
                                    child: _buildFloatingMissionCard(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // SLIDING NAVIGATION SIDEBAR
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: _isSidebarOpen ? 0 : -sidebarWidth,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: sidebarWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 15,
                                offset: const Offset(5, 0),
                              ),
                            ],
                            border: const Border(
                              right: BorderSide(
                                color: Colors.white12,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: _buildSidebarContent(
                            builderContext,
                            sidebarWidth,
                          ),
                        ),
                      ),

                      // FIXED SIDEBAR COLLAPSE BUTTON
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: Icon(
                            _isSidebarOpen ? Icons.menu_open : Icons.menu,
                          ),
                          color: Colors.orangeAccent,
                          iconSize: 26,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            AudioManager.playClick();
                            setState(() {
                              _isSidebarOpen = !_isSidebarOpen;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.85),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.orange.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // CURTAIN RAISE OVERLAY (Rendered on top)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeInOutCubic,
                    top: _isCurtainRaised ? -screenHeight : 0,
                    left: 0,
                    right: 0,
                    height: screenHeight,
                    child: _buildCurtainScreen(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurtainScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Dark slate
            Color(0xFF1E3A8A), // Deep blue
            Color(0xFF020617), // Very dark
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero Icon with gentle glow
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    size: 60,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  tr(
                    "Removing Brackets Preceded by Subtraction",
                    "घटाव से पहले वाले कोष्ठक हटाना",
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    tr(
                      "CLASS 7 • ARITHMETIC EXPRESSIONS",
                      "कक्षा 7 • अंकगणितीय व्यंजक",
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Animated Enter Button
                AnimatedBuilder(
                  animation: _curtainPulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_curtainPulseController.value * 0.05),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: _curtainPulseController.value * 5,
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _raiseCurtain,
                          icon: const Icon(Icons.rocket_launch, size: 28),
                          label: Text(
                            tr("ENTER LAB", "प्रयोगशाला में प्रवेश करें"),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.orangeAccent,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    final sc = _scenarios[_currentScenarioIndex];

    String stepInstruction = tr(
      "Setup: Review the equation.",
      "सेटअप: समीकरण की समीक्षा करें।",
    );
    if (_currentStep == 2) {
      stepInstruction = tr(
        "Running: Watch the terms passing the gate.",
        "चल रहा है: गेट से गुजरने वाले पदों को देखें।",
      );
    }
    if (_currentStep == 3) {
      stepInstruction = tr(
        "Done: Challenge Solved!",
        "हो गया: चुनौती हल हो गई!",
      );
    }

    return Card(
      color: Colors.black.withOpacity(0.85),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.cyanAccent.withOpacity(0.4), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
            Row(
              children: [
                const Icon(
                  Icons.rocket_launch,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${tr("Challenge #", "चुनौती #")}${sc.index + 1}: ${sc.title}",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Instructions
            Text(
              "${tr("Mission: ", "मिशन: ")}${sc.mission}",
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "${tr("Status: ", "स्थिति: ")}$stepInstruction",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Challenge Selector
            _buildScenarioDropdown(),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPlaying ? _pauseSimulation : _startSimulation,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 14,
                      color: Colors.black,
                    ),
                    label: Text(
                      _isPlaying
                          ? tr("PAUSE", "रोकें")
                          : tr("START", "शुरू करें"),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying
                          ? Colors.amber
                          : Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _resetSimulation,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  color: Colors.redAccent,
                  tooltip: tr("Reset Challenge", "चुनौती रीसेट करें"),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white10,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquationTracker() {
    final sc = _scenarios[_currentScenarioIndex];
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr("Expression:  ", "व्यंजक:  "),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${sc.initialValue} ",
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sc.isMinusGate ? "- " : "+ ",
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 20,
                  color: sc.isMinusGate ? Colors.redAccent : Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Opacity(
                opacity: (1.0 - _conveyorProgress * 1.5).clamp(0.0, 1.0),
                child: const Text(
                  "(",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 22,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...List.generate(sc.terms.length, (idx) {
                final term = sc.terms[idx];
                final isFlipped = _termsFlipped[idx];

                String prefix = "";
                if (idx > 0) {
                  if (term.initialPositive) {
                    prefix = isFlipped ? " - " : " + ";
                  } else {
                    prefix = isFlipped ? " + " : " - ";
                  }
                } else {
                  if (!term.initialPositive) {
                    prefix = isFlipped ? " + " : " - ";
                  } else {
                    prefix = isFlipped ? " - " : "";
                  }
                }

                Color termColor = Colors.white;
                if (isFlipped) {
                  bool isCurrentlyPositive = term.initialPositive
                      ? !sc.isMinusGate
                      : sc.isMinusGate;
                  termColor = isCurrentlyPositive
                      ? Colors.cyanAccent
                      : Colors.redAccent;
                } else {
                  termColor = term.initialPositive
                      ? Colors.cyanAccent.shade100
                      : Colors.redAccent.shade100;
                }

                return Row(
                  children: [
                    Text(
                      prefix,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 18,
                        color: isFlipped
                            ? (prefix.contains('-')
                                  ? Colors.redAccent
                                  : Colors.cyanAccent)
                            : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedScale(
                      scale: isFlipped ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        term.label,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 18,
                          color: termColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              Opacity(
                opacity: (1.0 - _conveyorProgress * 1.5).clamp(0.0, 1.0),
                child: const Text(
                  ")",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 22,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_currentStep == 3) ...[
                const Text(
                  "  =  ",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 18,
                    color: Colors.yellowAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sc.finalValue.toString(),
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 22,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, double width) {
    if (width < 50) return const SizedBox();
    final sc = _scenarios[_currentScenarioIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 76, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.precision_manufacturing,
                color: Colors.orangeAccent,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        "Removing Brackets Preceded by Subtraction",
                        "घटाव से पहले वाले ब्रैकेट हटाना",
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.orangeAccent.shade200,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      tr(
                        "Class 7 • ARITHMETIC EXPRESSIONS",
                        "कक्षा 7 • अंकगणितीय व्यंजक",
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language Toggle & Reset Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    _buildLangButton("EN", !_isHindi, () {
                      setState(() {
                        _isHindi = false;
                        _buildScenarios(); // Rebuild scenarios for EN
                      });
                    }),
                    _buildLangButton("HI", _isHindi, () {
                      setState(() {
                        _isHindi = true;
                        _buildScenarios(); // Rebuild scenarios for HI
                      });
                    }),
                  ],
                ),
              ),
              IconButton(
                onPressed: _fullReset,
                icon: const Icon(Icons.restore, color: Colors.redAccent),
                tooltip: tr("Full Reset", "पूर्ण रीसेट"),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 24),

          Text(
            tr("Challenge Selectors", "चुनौती चयनकर्ता"),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 8),
          _buildScenarioDropdown(),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      color: Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr("Mission Objective", "मिशन का उद्देश्य"),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sc.mission,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            tr("Lab Controls", "प्रयोगशाला नियंत्रण"),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isPlaying
                              ? _pauseSimulation
                              : _startSimulation,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                          ),
                          label: Text(
                            _isPlaying
                                ? tr("PAUSE", "रोकें")
                                : tr("START", "शुरू करें"),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPlaying
                                ? Colors.amberAccent
                                : Colors.greenAccent.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _resetSimulation,
                        icon: const Icon(
                          Icons.restart_alt,
                          color: Colors.redAccent,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        tooltip: tr("Reset Crate", "क्रेट रीसेट करें"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Text(
                        tr("Speed:", "गति:"),
                        style: const TextStyle(fontSize: 11),
                      ),
                      Expanded(
                        child: Slider(
                          min: 0.5,
                          max: 2.5,
                          divisions: 4,
                          value: _simulationSpeed,
                          onChanged: (val) {
                            setState(() => _simulationSpeed = val);
                          },
                          onChangeEnd: _changeSpeedEnd,
                          activeColor: Colors.cyanAccent,
                        ),
                      ),
                      Text(
                        "${_simulationSpeed}x",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            tr("Active Reflection", "सक्रिय प्रतिबिंब"),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 8),
          _buildReflectionBox(),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          Center(
            child: Text(
              tr(
                "© ZeroScienceLab - Fall in love with math and Science",
                "© ज़ीरोसाइंसलैब - गणित और विज्ञान से प्यार करें",
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _currentScenarioIndex,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          items: _scenarios.map((sc) {
            return DropdownMenuItem<int>(
              value: sc.index,
              child: Text(
                "${tr("Challenge", "चुनौती")} ${sc.index + 1}: ${sc.title}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              AudioManager.playClick();
              setState(() {
                _initializeScenario(val);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildReflectionBox() {
    final sc = _scenarios[_currentScenarioIndex];
    return Card(
      color: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _questionAnswered
              ? (_isAnswerCorrect
                    ? Colors.green.withOpacity(0.4)
                    : Colors.red.withOpacity(0.4))
              : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sc.questionText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(sc.options.length, (idx) {
              bool isSelected = _selectedAnswerIndex == idx;
              Color tileColor = Colors.transparent;
              Color textColor = Colors.white70;
              IconData? icon;

              if (_questionAnswered) {
                if (idx == sc.correctOptionIndex) {
                  tileColor = Colors.green.withOpacity(0.15);
                  textColor = Colors.greenAccent;
                  icon = Icons.check_circle_outline;
                } else if (isSelected) {
                  tileColor = Colors.red.withOpacity(0.15);
                  textColor = Colors.redAccent;
                  icon = Icons.cancel_outlined;
                }
              } else if (isSelected) {
                tileColor = Colors.cyan.withOpacity(0.15);
                textColor = Colors.cyanAccent;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: InkWell(
                  onTap: () => _handleAnswer(idx),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.cyanAccent.withOpacity(0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${String.fromCharCode(65 + idx)}. ${sc.options[idx]}",
                            style: TextStyle(fontSize: 11, color: textColor),
                          ),
                        ),
                        if (icon != null)
                          Icon(icon, size: 16, color: textColor),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_questionAnswered) ...[
              const SizedBox(height: 8),
              Text(
                sc.explanation,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Color _lighten(Color color, [double amount = 0.15]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color color, [double amount = 0.15]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

class FactoryPainter extends CustomPainter {
  final double progress;
  final Scenario scenario;
  final List<bool> termsFlipped;
  final List<Spark> sparks;
  final bool isHindi;

  FactoryPainter({
    required this.progress,
    required this.scenario,
    required this.termsFlipped,
    required this.sparks,
    required this.isHindi,
  });

  String tr(String en, String hi) => isHindi ? hi : en;

  @override
  void paint(Canvas canvas, Size size) {
    // Vertically centered relative to new height
    final double midY = size.height * 0.65;
    final double depthX = 25.0;
    final double depthY = -15.0;

    // Synchronized track values for the longer canvas width
    final double gateX = 625.0;
    const double startX = 200.0;
    // Adjusted endX so terms stop nicely on the conveyor belt and do not drift too far
    const double endX = 850.0;
    double crateX = startX + progress * (endX - startX);

    // 1. DRAW CONVEYOR BELT
    _drawConveyorBelt(canvas, size, midY, depthX, depthY);

    // 2. DRAW INITIAL VALUE STACK
    _drawOutsideStack(canvas, size, midY, depthX, depthY);

    // 3. DRAW CRATE
    _drawBracketsCrate(canvas, size, crateX, midY, depthX, depthY, gateX);

    // 4. DRAW SIGN FLIPPER GATE
    _drawGate(canvas, size, gateX, midY, depthX, depthY);

    // 5. DRAW LABELS & BADGES
    _drawBadgesAndPills(canvas, size, crateX, gateX, midY);

    // 6. DRAW SPARKS
    _drawSparks(canvas);
  }

  void _drawIsometricBlock({
    required Canvas canvas,
    required double x,
    required double y,
    required double w,
    required double h,
    required double dX,
    required double dY,
    required Color color,
    double opacity = 1.0,
    bool isCrate = false,
  }) {
    final paintFront = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final paintTop = Paint()
      ..color = _lighten(color).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final paintRight = Paint()
      ..color = _darken(color).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    Path top = Path()
      ..moveTo(x, y)
      ..lineTo(x + w, y)
      ..lineTo(x + w + dX, y + dY)
      ..lineTo(x + dX, y + dY)
      ..close();
    canvas.drawPath(top, paintTop);

    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paintFront);

    Path right = Path()
      ..moveTo(x + w, y)
      ..lineTo(x + w + dX, y + dY)
      ..lineTo(x + w + dX, y + dY + h)
      ..lineTo(x + w, y + h)
      ..close();
    canvas.drawPath(right, paintRight);

    if (isCrate) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.5 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(top, linePaint);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), linePaint);
      canvas.drawPath(right, linePaint);
    }
  }

  void _drawStackBlock({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double w,
    required double h,
    required double dX,
    required double dY,
    required Color color,
    required double scaleX,
  }) {
    double x = cx - w / 2;
    double y = cy - h;

    _drawIsometricBlock(
      canvas: canvas,
      x: x,
      y: y,
      w: w,
      h: h,
      dX: dX,
      dY: dY,
      color: color,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double i = 0; i <= w; i += 12) {
      canvas.drawLine(Offset(x + i, y), Offset(x + i, y + h), gridPaint);
    }
    for (double i = 0; i <= h; i += 12) {
      canvas.drawLine(Offset(x, y + i), Offset(x + w, y + i), gridPaint);
    }

    for (double i = 0; i <= h; i += 12) {
      canvas.drawLine(
        Offset(x + w, y + i),
        Offset(x + w + dX, y + i + dY),
        gridPaint,
      );
    }
    for (double i = 0; i <= dX; i += dX / 3) {
      canvas.drawLine(
        Offset(x + w + i, y + (i / dX) * dY),
        Offset(x + w + i, y + (i / dX) * dY + h),
        gridPaint,
      );
    }
  }

  void _drawConveyorBelt(
    Canvas canvas,
    Size size,
    double midY,
    double depthX,
    double depthY,
  ) {
    double left = 30;
    double right = size.width + 450;
    double topY = midY;
    double thickness = 18;

    _drawIsometricBlock(
      canvas: canvas,
      x: left,
      y: topY,
      w: right - left,
      h: thickness,
      dX: depthX,
      dY: depthY,
      color: const Color(0xFF2C3E50),
    );
  }

  void _drawOutsideStack(
    Canvas canvas,
    Size size,
    double midY,
    double depthX,
    double depthY,
  ) {
    double w = 55;
    double h = 45;
    double cx = 80;
    double cy = midY;

    _drawStackBlock(
      canvas: canvas,
      cx: cx,
      cy: cy,
      w: w,
      h: h,
      dX: depthX * 0.8,
      dY: depthY * 0.8,
      color: Colors.blueAccent.shade700,
      scaleX: 1.0,
    );
  }

  void _drawGate(
    Canvas canvas,
    Size size,
    double gateX,
    double midY,
    double depthX,
    double depthY,
  ) {
    double gW = 40;
    double gH = 180;
    double gX = gateX - gW / 2;
    double gY = midY - gH;

    Color gateColor = scenario.isMinusGate
        ? const Color(0xFF991B1B)
        : Colors.green.shade800;

    _drawIsometricBlock(
      canvas: canvas,
      x: gX,
      y: gY,
      w: gW,
      h: gH,
      dX: depthX,
      dY: depthY,
      color: gateColor,
      opacity: 0.65,
    );

    double capH = 20;
    _drawIsometricBlock(
      canvas: canvas,
      x: gX,
      y: gY - capH,
      w: gW,
      h: capH,
      dX: depthX,
      dY: depthY,
      color: Colors.white,
    );

    final capSymbolPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    if (scenario.isMinusGate) {
      canvas.drawRect(
        Rect.fromLTWH(gX + 8, gY - capH + 8, gW - 16, 4),
        capSymbolPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(gX + 8, gY - capH + 8, gW - 16, 4),
        capSymbolPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(gX + gW / 2 - 2, gY - capH + 2, 4, 16),
        capSymbolPaint,
      );
    }
  }

  void _drawBracketsCrate(
    Canvas canvas,
    Size size,
    double crateX,
    double midY,
    double depthX,
    double depthY,
    double gateX,
  ) {
    double cW = 240;
    double cH = 100;
    double cX = crateX - cW / 2;
    double cY = midY - cH;

    double distancePastGate = crateX - gateX;
    double crateOpacity = 1.0;
    if (distancePastGate > 0) {
      crateOpacity = (1.0 - distancePastGate / 120.0).clamp(0.0, 1.0);
    }

    if (crateOpacity > 0.05) {
      _drawIsometricBlock(
        canvas: canvas,
        x: cX,
        y: cY,
        w: cW,
        h: cH,
        dX: depthX,
        dY: depthY,
        color: const Color(0xFF60A5FA),
        opacity: 0.15 * crateOpacity,
        isCrate: true,
      );

      _drawText(
        canvas: canvas,
        text: "(",
        x: cX + 20,
        y: cY + cH / 2,
        color: Colors.white.withOpacity(0.8 * crateOpacity),
        fontSize: 80,
      );
      _drawText(
        canvas: canvas,
        text: ")",
        x: cX + cW - 20,
        y: cY + cH / 2,
        color: Colors.white.withOpacity(0.8 * crateOpacity),
        fontSize: 80,
      );
    }

    for (int i = 0; i < scenario.terms.length; i++) {
      final term = scenario.terms[i];
      double termGlobalX = crateX + term.relativeX;

      double flipProgress = 0.0;
      if (termGlobalX < gateX - 45) {
        flipProgress = 0.0;
      } else if (termGlobalX > gateX + 45) {
        flipProgress = 1.0;
      } else {
        flipProgress = (termGlobalX - (gateX - 45)) / 90.0;
      }

      bool flipped = termsFlipped[i];
      bool isNowPositive = term.initialPositive;
      if (flipped) {
        isNowPositive = scenario.isMinusGate
            ? !term.initialPositive
            : term.initialPositive;
      }

      Color blockColor = isNowPositive
          ? Colors.blueAccent.shade700
          : Colors.redAccent.shade700;
      double scaleX = math.cos(flipProgress * math.pi).abs();
      double w = 35 * scaleX;
      double h = 55;

      _drawStackBlock(
        canvas: canvas,
        cx: termGlobalX,
        cy: midY,
        w: w,
        h: h,
        dX: depthX * 0.7 * scaleX,
        dY: depthY * 0.7,
        color: blockColor,
        scaleX: scaleX,
      );
    }
  }

  void _drawBadgesAndPills(
    Canvas canvas,
    Size size,
    double crateX,
    double gateX,
    double midY,
  ) {
    // 1. OUTSIDE STACK LABELS
    _drawBadgeBox(canvas, scenario.initialValue.toString(), 80, midY - 30);
    _drawPillLabel(
      canvas,
      tr("OUTSIDE STACK", "बाहरी स्टैक"),
      80,
      midY - 90,
      Colors.lightBlueAccent,
    );
    _drawPointerLine(canvas, 80, midY - 50, 80, midY - 75);

    // 2. CRATE LABELS
    double distancePastGate = crateX - gateX;
    double crateOpacity = (1.0 - distancePastGate / 120.0).clamp(0.0, 1.0);

    if (crateOpacity > 0.05) {
      _drawPillLabel(
        canvas,
        tr("GLASS CRATE (BRACKETS)", "ग्लास क्रेट (कोष्ठक)"),
        crateX,
        midY - 120,
        Colors.cyanAccent.shade100,
        opacity: crateOpacity,
      );
      _drawPointerLine(
        canvas,
        crateX,
        midY - 100,
        crateX,
        midY - 110,
        opacity: crateOpacity,
      );
    }

    for (int i = 0; i < scenario.terms.length; i++) {
      final term = scenario.terms[i];
      double termGlobalX = crateX + term.relativeX;
      _drawBadgeBox(canvas, term.label, termGlobalX, midY - 30);
    }

    // 3. GATE LABEL
    _drawPillLabel(
      canvas,
      tr("SIGN FLIPPER GATE", "साइन फ्लिपर गेट"),
      gateX,
      midY - 260,
      Colors.redAccent.shade100,
    );
    _drawPointerLine(canvas, gateX, midY - 250, gateX, midY - 205);

    // 4. CONVEYOR BELT LABEL
    _drawPillLabel(
      canvas,
      tr("CONVEYOR BELT", "कन्वेयर बेल्ट"),
      size.width / 1,
      midY + 45,
      Colors.white,
    );
  }

  void _drawBadgeBox(Canvas canvas, String text, double cx, double cy) {
    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double w = 44;
    double h = 28;
    Rect rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    canvas.drawRRect(rRect, bgPaint);
    canvas.drawRRect(rRect, borderPaint);

    _drawText(
      canvas: canvas,
      text: text,
      x: cx,
      y: cy,
      color: Colors.white,
      fontSize: 16,
      isBold: true,
    );
  }

  void _drawPillLabel(
    Canvas canvas,
    String text,
    double cx,
    double cy,
    Color textColor, {
    double opacity = 1.0,
  }) {
    final bgPaint = Paint()
      ..color = const Color(0xFF141F36).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF2B3A4F).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    double w = tp.width + 24;
    double h = 26;
    Rect rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(13));

    canvas.drawRRect(rRect, bgPaint);
    canvas.drawRRect(rRect, borderPaint);

    _drawText(
      canvas: canvas,
      text: text,
      x: cx,
      y: cy,
      color: textColor.withOpacity(opacity),
      fontSize: 12,
      isBold: true,
      isCourier: false,
    );
  }

  void _drawPointerLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2, {
    double opacity = 1.0,
  }) {
    final paint = Paint()
      ..color = Colors.white24.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required double x,
    required double y,
    required Color color,
    required double fontSize,
    bool isBold = false,
    bool isCourier = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: isCourier ? 'Courier' : null,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawSparks(Canvas canvas) {
    for (final spark in sparks) {
      final paint = Paint()
        ..color = spark.color.withOpacity(spark.life / spark.maxLife)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(spark.x, spark.y), spark.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FactoryPainter oldDelegate) => true;
}
