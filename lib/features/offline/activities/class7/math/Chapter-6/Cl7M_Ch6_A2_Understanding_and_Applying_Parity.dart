// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParityMachineLab(),
    ),
  );
}

class ParityContainer {
  final int id;
  final int val;
  final String type;
  final Color color;
  ParityContainer(this.id, this.val, this.type, this.color);
}

class BlockData {
  final double startX;
  final double startY;
  double scatterX = 0;
  double scatterY = 0;
  double pairX = 0;
  double pairY = 0;
  double endX = 0;
  double endY = 0;
  final Color color;
  final bool isLeftover;

  BlockData({
    required this.startX,
    required this.startY,
    required this.color,
    this.isLeftover = false,
  });
}

class ParityMachineLab extends StatefulWidget {
  const ParityMachineLab({super.key});

  @override
  State<ParityMachineLab> createState() => _ParityMachineLabState();
}

class _ParityMachineLabState extends State<ParityMachineLab>
    with TickerProviderStateMixin {
  // Config & State
  bool isShutterOpen = true;
  bool isSidebarOpen = true;
  int scenario = 1;
  int step = 0;
  bool actionValidated = false;
  Set<int> completedScenarios = {};
  bool globalSuccessShown = false;
  String currentLang = 'en';

  // HUD Feedback
  String feedbackMsg = '';
  String feedbackType = '';
  Timer? feedbackTimer;

  // Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _machinePlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _alertPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Audio URLs
  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _machineUrl =
      'audio/class7/mixkit_2570.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';

  // Transforms
  double panX = 0;
  double panY = 0;
  double zoom = 1.0;
  double _baseZoom = 1.0;

  // App Logic State
  final List<ParityContainer> allContainers = [
    ParityContainer(1, 4, 'even', const Color(0xff3b82f6)),
    ParityContainer(2, 6, 'even', const Color(0xff3b82f6)),
    ParityContainer(3, 3, 'odd', const Color(0xffef4444)),
    ParityContainer(4, 5, 'odd', const Color(0xffef4444)),
    ParityContainer(5, 1, 'odd', const Color(0xffef4444)),
    ParityContainer(6, 3, 'odd', const Color(0xffef4444)),
    ParityContainer(7, 5, 'odd', const Color(0xffef4444)),
    ParityContainer(8, 7, 'odd', const Color(0xffef4444)),
    ParityContainer(9, 9, 'odd', const Color(0xffef4444)),
    ParityContainer(10, 11, 'odd', const Color(0xffef4444)),
    ParityContainer(11, 13, 'odd', const Color(0xffef4444)),
    ParityContainer(12, 15, 'odd', const Color(0xffef4444)),
  ];

  List<int> allowedContainers = [];
  List<int?> beltSlots = [null, null, null, null, null];

  String machineState = 'idle'; // 'idle', 'running', 'done'
  int machineOutputPairs = 0;
  bool machineOutputLeftover = false;
  String machineText = 'WAITING';
  int s4Fails = 0;

  // S5 Variables
  int s5c1Count = 0;
  int s5c5Count = 0;
  int s5c10Count = 0;
  int s5v1Total = 0;
  int s5v5Total = 0;
  int s5v10Total = 0;
  int s5ExpClicks = 0;
  int lastS5Click = 0;

  List<Offset> s5Coins = [];

  // Machine Animation state
  late AnimationController _machineAnimController;
  List<BlockData> activeBlocks = [];

  String activeDragType = '';
  int activeDragId = -1;
  Offset activeDragPos = Offset.zero;
  int activeHoverSlot = -1;

  // Themes / Colors
  final Color zslDark = const Color(0xff020617);
  final Color panelBg = const Color(0xff1e293b).withOpacity(0.9);
  final Color laserBlue = const Color(0xff3b82f6);
  final Color laserGreen = const Color(0xff22c55e);
  final Color laserRed = const Color(0xffef4444);
  final Color laserYellow = const Color(0xfffbbf24);

  // Translations Map
  final Map<String, Map<String, dynamic>> _t = {
    'en': {
      'title': "The Parity Machine",
      'subtitle': "Class 7 • Number Play",
      'enterLab': "Start Mission",
      'selectMission': "Select Mission",
      'objective': "Objective",
      'missionSteps': "Logic Log",
      'missionCompleted': "Mission Completed!",
      'restartMission': "Restart Mission",
      'targetLabel': "TARGET",
      'sumLabel': "SUM",
      'activateBtn': "ACTIVATE",

      'fb_success': "Action registered.",
      'fb_error': "Action invalid.",
      'fb_s4_fail': "Sum is ODD! Target 30 is EVEN.",
      'fb_s5_fail': "Parity mismatch! Cannot reach target.",

      's1Obj': "To understand that the sum of two even numbers is always even.",
      's2Obj': "To understand that the sum of two odd numbers is always even.",
      's3Obj':
          "To understand that the sum of an even number and an odd number is always odd.",
      's4Obj':
          "To prove that the sum of five odd numbers must be odd, making a target of 30 (even) impossible.",
      's5Obj':
          "To deduce that adding an odd amount (₹1) + an odd amount (₹5) + an even amount (₹10) results in an EVEN sum, making an odd target (₹205) impossible.",

      'scen1Title': "1. The Even Sum",
      's1h1': "DRAG the blue container with 4 blocks onto the conveyor belt.",
      's1t1':
          "A container holding 4 blocks is on a shelf. The conveyor belt has a drop-zone.",
      's1h2': "DRAG the blue container with 6 blocks onto the conveyor belt.",
      's1t2':
          "A second container with 6 blocks is available to be dragged and dropped.",
      's1h3':
          "CLICK the 'ACTIVATE' button to send blocks into the Parity Machine.",
      's1t3':
          "The belt animates, and the blocks tumble into a large, transparent machine.",
      's1h4': "Observe the Parity Machine's output.",
      's1t4':
          "The machine arranges the 10 blocks into 5 neat pairs. There are no leftover blocks.",
      's1Sum':
          "Even (4) + Even (6) = Even (10). Because both starting numbers were even, their sum is also perfectly paired.",

      'scen2Title': "2. The Odd Couple",
      's2h1': "DRAG the red container with 3 blocks onto the conveyor belt.",
      's2t1':
          "Notice that odd containers have one block sitting on top, signifying the 'leftover'.",
      's2h2': "DRAG the red container with 5 blocks onto the conveyor belt.",
      's2t2':
          "A second red container holds 4 blocks, with a 5th block on its lid.",
      's2h3': "CLICK the 'ACTIVATE' button.",
      's2t3':
          "The conveyor belt animates, sending all blocks into the machine.",
      's2h4': "Observe how the machine handles the 'leftover' blocks.",
      's2t4':
          "Inside the machine, the two 'leftover' blocks are placed together to form a new pair.",
      's2Sum':
          "When you add two odd numbers, their 'leftover' blocks pair up perfectly. Thus, Odd + Odd = Even.",

      'scen3Title': "3. The Odd One Out",
      's3h1':
          "DRAG the blue container (4) and the red container (5) onto the belt.",
      's3t1':
          "We are combining one perfect set of pairs (even) with one set that has a leftover (odd).",
      's3h2': "CLICK the 'ACTIVATE' button.",
      's3t2':
          "What do you predict will happen to the single leftover block? Will it find a partner?",
      's3h3': "Observe the machine's output.",
      's3t3':
          "The machine couldn't pair up the final block, so it remains unmatched.",
      's3Sum':
          "Because there is only one leftover block between the two numbers, it remains unmatched. Thus, Even + Odd = Odd.",

      'scen4Title': "4. Kishor's Card Challenge",
      's4h1':
          "DRAG 5 odd containers to fill all slots. Try to reach a sum of 30.",
      's4t1':
          "The shelf only contains ODD numbers. Can you choose 5 of them to add up to exactly 30?",
      's4h2': "CLICK the 'ACTIVATE' button to test your combination.",
      's4t2': "Watch the parity result carefully.",
      's4h3':
          "TRY different combinations of 5 odd containers. Observe the result.",
      's4t3':
          "No matter which 5 odd numbers you pick, the result is ALWAYS an odd number. Since 30 is EVEN, this puzzle is impossible!",
      's4Sum':
          "You proved it's impossible! The sum of 5 odd numbers will always have one leftover block without a partner.",

      'scen5Title': "5. Lakpa's Piggy Bank",
      's5h1': "CLICK the '₹1' dispenser to add an ODD number of ₹1 coins.",
      's5t1':
          "Adding an ODD number of ₹1 coins will result in an ODD amount of money.",
      's5h2': "CLICK the '₹5' dispenser to add an ODD number of ₹5 coins.",
      's5t2':
          "Adding an ODD number of ₹5 coins will ALSO result in an ODD amount of money.",
      's5h3': "CLICK the '₹10' dispenser to add an EVEN number of ₹10 coins.",
      's5t3':
          "Adding an EVEN number of ₹10 coins will result in an EVEN amount of money.",
      's5h4': "Observe the parity of the final sum. Can you ever reach ₹205?",
      's5t4':
          "Look at the math: ODD + ODD + EVEN. Since the total is always EVEN, it can never equal 205!",
      's5Sum':
          "Brilliant deduction! ODD + ODD = EVEN. Then EVEN + EVEN = EVEN. Reaching an odd target like 205 is impossible.",

      'geoMaster': "Parity Master!",
      'geoMasterText':
          "You have successfully mastered the rules of parity for addition and multiplication!",
    },
    'hi': {
      'title': "द पैरिटी मशीन",
      'subtitle': "कक्षा 7 • संख्या खेल",
      'enterLab': "मिशन प्रारंभ करें",
      'selectMission': "मिशन चुनें",
      'objective': "उद्देश्य",
      'missionSteps': "तर्क लॉग",
      'missionCompleted': "मिशन पूरा हुआ!",
      'restartMission': "मिशन रीस्टार्ट",
      'targetLabel': "लक्ष्य",
      'sumLabel': "योग",
      'activateBtn': "सक्रिय करें",

      'fb_success': "कार्रवाई पंजीकृत।",
      'fb_error': "अमान्य कार्रवाई।",
      'fb_s4_fail': "योग विषम है! लक्ष्य 30 सम है।",
      'fb_s5_fail': "पैरिटी बेमेल! लक्ष्य तक नहीं पहुँच सकते।",

      's1Obj': "यह समझना कि दो सम संख्याओं का योग हमेशा सम होता है।",
      's2Obj': "यह समझना कि दो विषम संख्याओं का योग हमेशा सम होता है।",
      's3Obj':
          "यह समझना कि एक सम संख्या और एक विषम संख्या का योग हमेशा विषम होता है।",
      's4Obj':
          "यह साबित करना कि पांच विषम संख्याओं का योग विषम होना चाहिए, जिससे 30 (सम) का लक्ष्य असंभव हो जाता है।",
      's5Obj':
          "यह निष्कर्ष निकालना कि एक विषम राशि (₹1) + एक विषम राशि (₹5) + एक सम राशि (₹10) जोड़ने पर एक सम योग प्राप्त होता है, जिससे एक विषम लक्ष्य (₹205) असंभव हो जाता है।",

      'scen1Title': "1. सम योग",
      's1h1': "4 ब्लॉक वाले नीले कंटेनर को कन्वेयर बेल्ट पर खींचें।",
      's1t1':
          "शेल्फ पर 4 ब्लॉक वाला एक कंटेनर है। कन्वेयर बेल्ट में एक ड्रॉप-ज़ोन है।",
      's1h2': "6 ब्लॉक वाले नीले कंटेनर को कन्वेयर बेल्ट पर खींचें।",
      's1t2': "6 ब्लॉक वाला एक दूसरा कंटेनर खींचने के लिए उपलब्ध है।",
      's1h3': "मशीन में ब्लॉक भेजने के लिए 'ACTIVATE' बटन पर क्लिक करें।",
      's1t3':
          "बेल्ट एनिमेट होता है, और ब्लॉक एक पारदर्शी मशीन में गिर जाते हैं।",
      's1h4': "पैरिटी मशीन के आउटपुट का निरीक्षण करें।",
      's1t4':
          "मशीन 10 ब्लॉकों को 5 पूर्ण जोड़ों में क्रमबद्ध करती है। कोई ब्लॉक नहीं बचा है।",
      's1Sum':
          "सम (4) + सम (6) = सम (10)। चूँकि दोनों शुरुआती संख्याएँ सम थीं, इसलिए उनका योग भी पूर्णतः युग्मित है।",

      'scen2Title': "2. विषम जोड़ी",
      's2h1': "3 ब्लॉक वाले लाल कंटेनर को कन्वेयर बेल्ट पर खींचें।",
      's2t1':
          "ध्यान दें कि विषम कंटेनरों के ऊपर एक ब्लॉक बैठा होता है, जो 'बचे हुए' को दर्शाता है।",
      's2h2': "5 ब्लॉक वाले लाल कंटेनर को कन्वेयर बेल्ट पर खींचें।",
      's2t2':
          "एक दूसरे लाल कंटेनर में 4 ब्लॉक हैं, जिसके ढक्कन पर 5वां ब्लॉक है।",
      's2h3': "'ACTIVATE' बटन पर क्लिक करें।",
      's2t3':
          "कन्वेयर बेल्ट एनिमेट होता है, सभी ब्लॉकों को मशीन में डाल देता है।",
      's2h4': "निरीक्षण करें कि मशीन 'बचे हुए' ब्लॉकों को कैसे संभालती है।",
      's2t4':
          "मशीन के अंदर, दो 'बचे हुए' ब्लॉकों को एक नया जोड़ा बनाने के लिए एक साथ रखा जाता है।",
      's2Sum':
          "जब आप दो विषम संख्याएं जोड़ते हैं, तो उनके 'बचे हुए' ब्लॉक पूरी तरह से जुड़ जाते हैं। इस प्रकार, विषम + विषम = सम।",

      'scen3Title': "3. अलग-थलग",
      's3h1': "नीले कंटेनर (4) और लाल कंटेनर (5) को बेल्ट पर खींचें।",
      's3t1':
          "हम एक पूर्ण सेट (सम) को एक बचे हुए (विषम) सेट के साथ मिला रहे हैं।",
      's3h2': "'ACTIVATE' बटन पर क्लिक करें।",
      's3t2': "आप क्या अनुमान लगाते हैं कि एक बचे हुए ब्लॉक का क्या होगा?",
      's3h3': "मशीन के आउटपुट का निरीक्षण करें।",
      's3t3': "मशीन अंतिम ब्लॉक को नहीं जोड़ सकी, इसलिए यह बेजोड़ रहता है।",
      's3Sum':
          "चूंकि दो संख्याओं के बीच केवल एक बचा हुआ ब्लॉक है, यह बेजोड़ रहता है। इस प्रकार, सम + विषम = विषम।",

      'scen4Title': "4. किशोर की कार्ड चुनौती",
      's4h1':
          "सभी स्लॉट भरने के लिए 5 विषम कंटेनरों को खींचें। 30 के लक्ष्य तक पहुँचने का प्रयास करें।",
      's4t1':
          "शेल्फ में केवल विषम संख्याएं हैं। क्या आप ठीक 30 जोड़ने के लिए उनमें से 5 चुन सकते हैं?",
      's4h2': "परीक्षण करने के लिए 'ACTIVATE' बटन पर क्लिक करें।",
      's4t2': "पैरिटी परिणाम को ध्यान से देखें।",
      's4h3': "विभिन्न संयोजनों का प्रयास करें। परिणाम देखें।",
      's4t3':
          "आप कोई भी 5 विषम संख्याएं चुनें, परिणाम हमेशा एक विषम संख्या होती है। चूंकि 30 सम है, यह असंभव है!",
      's4Sum':
          "आपने साबित कर दिया कि यह असंभव है! 5 विषम संख्याओं के योग में हमेशा एक बचा हुआ ब्लॉक होगा।",

      'scen5Title': "5. लकपा का गुल्लक",
      's5h1':
          "₹1 के सिक्कों की विषम संख्या जोड़ने के लिए '₹1' डिस्पेंसर पर क्लिक करें।",
      's5t1': "₹1 के सिक्कों की विषम संख्या जोड़ने से विषम राशि प्राप्त होगी।",
      's5h2':
          "₹5 के सिक्कों की विषम संख्या जोड़ने के लिए '₹5' डिस्पेंसर पर क्लिक करें।",
      's5t2':
          "₹5 के सिक्कों की विषम संख्या जोड़ने से भी विषम राशि प्राप्त होगी।",
      's5h3':
          "₹10 के सिक्कों की सम संख्या जोड़ने के लिए '₹10' डिस्पेंसर पर क्लिक करें।",
      's5t3': "₹10 के सिक्कों की सम संख्या जोड़ने से सम राशि प्राप्त होगी।",
      's5h4':
          "अंतिम योग की पैरिटी का निरीक्षण करें। क्या आप ₹205 तक पहुँच सकते हैं?",
      's5t4':
          "गणित को देखें: विषम + विषम + सम। चूंकि कुल हमेशा सम होता है, यह 205 के बराबर नहीं हो सकता!",
      's5Sum':
          "विषम + विषम = सम। फिर सम + सम = सम। अंतिम योग सम होना चाहिए, इसलिए 205 तक पहुंचना असंभव है।",

      'geoMaster': "पैरिटी मास्टर!",
      'geoMasterText':
          "आपने जोड़ और गुणा के लिए पैरिटी के नियमों में महारत हासिल कर ली है!",
    },
  };

  String t(String key) {
    return _t[currentLang]?[key] ?? _t['en']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _machineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _machineAnimController.addListener(() {
      setState(() {});
    });

    _playSound(_shutterUrl, _alertPlayer);
    loadScenario(1);
  }

  @override
  void dispose() {
    feedbackTimer?.cancel();
    _machineAnimController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String url, AudioPlayer player) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void showFeedback(String msg, String type) {
    setState(() {
      feedbackMsg = msg;
      feedbackType = type;
    });
    feedbackTimer?.cancel();
    feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => feedbackMsg = '');
      }
    });
  }

  void loadScenario(int id) {
    _playSound(_shutterUrl, _alertPlayer);
    setState(() {
      scenario = id;
      step = 0;
      actionValidated = false;

      machineState = 'idle';
      machineText = 'WAITING';
      machineOutputPairs = 0;
      machineOutputLeftover = false;
      s4Fails = 0;

      s5c1Count = 0;
      s5c5Count = 0;
      s5c10Count = 0;
      s5v1Total = 0;
      s5v5Total = 0;
      s5v10Total = 0;
      s5ExpClicks = 0;
      s5Coins.clear();

      activeDragType = '';
      activeDragId = -1;
      activeHoverSlot = -1;

      beltSlots = [null, null, null, null, null];

      if (scenario == 1) {
        allowedContainers = [1, 2];
      } else if (scenario == 2) {
        allowedContainers = [3, 4];
      } else if (scenario == 3) {
        allowedContainers = [1, 4];
      } else if (scenario == 4) {
        allowedContainers = [5, 6, 7, 8, 9, 10, 11, 12];
      } else {
        allowedContainers = [];
      }

      panX = 0;
      panY = 0;
      zoom = 1.0;
    });
  }

  void resetLab() {
    _playSound(_shutterUrl, _alertPlayer);
    setState(() {
      completedScenarios.clear();
      globalSuccessShown = false;
      currentLang = 'en';
      isShutterOpen = true;
      loadScenario(1);
    });
  }

  void markStepComplete() {
    if (actionValidated) return;
    setState(() {
      actionValidated = true;
      _playSound(_successUrl, _successPlayer);
      HapticFeedback.heavyImpact();
      showFeedback(t('fb_success'), 'success');
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        actionValidated = false;
        step++;

        int reqSteps = scenario == 4 ? 4 : (scenario == 5 ? 5 : 4);
        if (step >= reqSteps) {
          completedScenarios.add(scenario);
          if (completedScenarios.length >= 5 && !globalSuccessShown) {
            globalSuccessShown = true;
            _playSound(_successUrl, _successPlayer);
          }
        }
      });
    });
  }

  Offset screenToLogical(Offset screenPos, Size canvasSize) {
    double scale = math.min(canvasSize.width, canvasSize.height) / 800.0 * zoom;
    double cx = canvasSize.width / 2 + panX;
    double cy = canvasSize.height / 2 + panY;
    return Offset((screenPos.dx - cx) / scale, (screenPos.dy - cy) / scale);
  }

  Offset getBeltSlotPos(int i) {
    if (scenario == 4) return Offset(-380.0 + i * 90, 150.0);
    return Offset(-250.0 + i * 120, 150.0);
  }

  Offset getShelfPos(int holdIdx) {
    int row = holdIdx ~/ 5;
    int col = holdIdx % 5;
    double shelfY = row == 0 ? -190.0 : 30.0;
    return Offset(-430.0 + col * 75, shelfY);
  }

  void handleTapDown(TapDownDetails details, Size canvasSize) {
    if (actionValidated) return;
    Offset pt = screenToLogical(details.localPosition, canvasSize);

    // Scenario 5 Dispensers
    if (scenario == 5) {
      Rect d1Rect = const Rect.fromLTWH(-250 - 95, -100 - 35, 220, 70);
      Rect d5Rect = const Rect.fromLTWH(-250 - 95, 0 - 35, 220, 70);
      Rect d10Rect = const Rect.fromLTWH(-250 - 95, 100 - 35, 220, 70);

      if (d1Rect.contains(pt)) {
        addS5Coins(1);
      } else if (d5Rect.contains(pt)) {
        addS5Coins(5);
      } else if (d10Rect.contains(pt)) {
        addS5Coins(10);
      }
      return;
    }

    // Activate Button
    Rect btnRect = const Rect.fromLTWH(-300 - 80, 240 - 25, 160, 50);
    if (btnRect.contains(pt)) {
      int expectedCount = scenario == 4 ? 5 : 2;
      int count = beltSlots.where((v) => v != null).length;
      if (count == expectedCount && machineState == 'idle') {
        triggerActivate();
      }
    }
  }

  void handleScaleStart(ScaleStartDetails details, Size canvasSize) {
    if (actionValidated || machineState != 'idle') return;
    _baseZoom = zoom;
    Offset pt = screenToLogical(details.localFocalPoint, canvasSize);

    bool hitElement = false;

    if (scenario <= 4) {
      for (int cid in allowedContainers) {
        Offset pos;
        int slotIdx = beltSlots.indexOf(cid);
        if (slotIdx != -1) {
          pos = getBeltSlotPos(slotIdx);
        } else {
          pos = getShelfPos(allowedContainers.indexOf(cid));
        }

        if (pt.dx > pos.dx - 40 &&
            pt.dx < pos.dx + 40 &&
            pt.dy > pos.dy - 100 &&
            pt.dy < pos.dy + 20) {
          setState(() {
            activeDragType = 'cont';
            activeDragId = cid;
            activeDragPos = pt;
            activeHoverSlot = -1;
          });
          _playSound(_clickUrl, _clickPlayer);
          hitElement = true;
          return;
        }
      }
    }

    if (!hitElement) {
      activeDragType = 'canvas';
    }
  }

  void handleScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (activeDragType.isEmpty) return;

    if (activeDragType == 'canvas') {
      setState(() {
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
        if (details.scale != 1.0) zoom = _baseZoom * details.scale;
      });
      return;
    }

    Offset pt = screenToLogical(details.localFocalPoint, canvasSize);

    setState(() {
      activeDragPos = pt;

      if (activeDragType == 'cont') {
        int slotsNum = scenario == 4 ? 5 : 2;
        activeHoverSlot = -1;
        for (int i = 0; i < slotsNum; i++) {
          if ((pt - getBeltSlotPos(i)).distance < 50) {
            if (beltSlots[i] != null && beltSlots[i] != activeDragId) continue;
            activeHoverSlot = i;
            break;
          }
        }
      }
    });
  }

  void handleScaleEnd(ScaleEndDetails details) {
    if (activeDragType.isEmpty || activeDragType == 'canvas') {
      setState(() => activeDragType = '');
      return;
    }

    setState(() {
      if (activeDragType == 'cont') {
        if (activeHoverSlot != -1) {
          int destSlot = activeHoverSlot;

          if (scenario == 1) {
            if (step == 0 && activeDragId != 1) {
              _playSound(_errorUrl, _errorPlayer);
              activeDragType = '';
              return;
            }
            if (step == 1 && activeDragId != 2) {
              _playSound(_errorUrl, _errorPlayer);
              activeDragType = '';
              return;
            }
          } else if (scenario == 2) {
            if (step == 0 && activeDragId != 3) {
              _playSound(_errorUrl, _errorPlayer);
              activeDragType = '';
              return;
            }
            if (step == 1 && activeDragId != 4) {
              _playSound(_errorUrl, _errorPlayer);
              activeDragType = '';
              return;
            }
          } else if (scenario == 3) {
            if (step == 0 && activeDragId != 1) {
              _playSound(_errorUrl, _errorPlayer);
              activeDragType = '';
              return;
            }
          }

          int oldSlot = beltSlots.indexOf(activeDragId);
          int? destCont = beltSlots[destSlot];

          if (oldSlot != -1) beltSlots[oldSlot] = destCont;
          beltSlots[destSlot] = activeDragId;

          _playSound(_clickUrl, _clickPlayer);

          int count = beltSlots.where((v) => v != null).length;

          if (scenario != 4) {
            if (count == 1 && step == 0) markStepComplete();
            if (count == 2 && step == 1) markStepComplete();
          } else {
            if (count == 1 && step == 0) markStepComplete();
            if (count == 5 && step == 1) markStepComplete();
          }
        } else {
          int oldSlot = beltSlots.indexOf(activeDragId);
          if (oldSlot != -1) beltSlots[oldSlot] = null;
          _playSound(_errorUrl, _errorPlayer);
        }
      }
      activeDragType = '';
    });
  }

  void triggerActivate() {
    if (actionValidated || machineState != 'idle') return;

    int expectedFills = scenario == 4 ? 5 : 2;
    int sum = 0;
    for (int i = 0; i < expectedFills; i++) {
      if (beltSlots[i] != null) {
        sum += allContainers.firstWhere((c) => c.id == beltSlots[i]).val;
      }
    }

    _playSound(_machineUrl, _machinePlayer);
    setState(() {
      machineState = 'running';
      machineText = 'PROCESSING';
    });

    if (scenario == 1 && step == 2) {
      markStepComplete();
    } else if (scenario == 2 && step == 2) {
      markStepComplete();
    } else if (scenario == 3 && step == 1) {
      markStepComplete();
    } else if (scenario == 4 && step == 1) {
      markStepComplete();
    }

    // Prepare internal blocks
    activeBlocks.clear();
    for (int i = 0; i < expectedFills; i++) {
      if (beltSlots[i] == null) continue;
      ParityContainer cont = allContainers.firstWhere(
        (c) => c.id == beltSlots[i],
      );
      for (int j = 0; j < cont.val; j++) {
        double sx = (math.Random().nextDouble() * 80) - 40;
        double sy = 60 - (math.Random().nextDouble() * 40);
        activeBlocks.add(BlockData(startX: sx, startY: sy, color: cont.color));
      }
    }

    int pairs = sum ~/ 2;
    bool hasLeftover = sum % 2 != 0;

    for (int i = 0; i < pairs; i++) {
      int col = i ~/ 5;
      int row = i % 5;
      double bx = col * 40 - 15;
      double by = 60 - row * 24;
      activeBlocks[i * 2].pairX = bx - 12;
      activeBlocks[i * 2].pairY = by;
      activeBlocks[i * 2 + 1].pairX = bx + 12;
      activeBlocks[i * 2 + 1].pairY = by;
    }
    if (hasLeftover) {
      activeBlocks.last.pairX = 0;
      activeBlocks.last.pairY = -20;
      activeBlocks.last.endX = 0;
      activeBlocks.last.endY = 220; // bin
    }

    for (int i = 0; i < activeBlocks.length; i++) {
      if (hasLeftover && i == activeBlocks.length - 1) continue;
      activeBlocks[i].endX = activeBlocks[i].pairX + 250;
      activeBlocks[i].endY = activeBlocks[i].pairY + 60;
    }

    _machineAnimController.forward(from: 0.0).then((_) {
      setState(() {
        machineOutputPairs = pairs;
        machineOutputLeftover = hasLeftover;
        machineText = hasLeftover ? 'ODD' : 'EVEN';
        machineState = 'done';

        if (scenario == 4) {
          if (hasLeftover) {
            s4Fails++;
            _playSound(_errorUrl, _errorPlayer);
            showFeedback(t('fb_s4_fail'), 'error');
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (!mounted) return;
              if (s4Fails >= 3) {
                markStepComplete();
              } else {
                setState(() {
                  beltSlots = [null, null, null, null, null];
                  machineState = 'idle';
                  machineText = 'WAITING';
                });
              }
            });
          }
        } else {
          _playSound(_successUrl, _successPlayer);
          markStepComplete();
        }
      });
    });
  }

  void addS5Coins(int val) {
    if (scenario != 5 || actionValidated) return;

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastS5Click < 300) return;
    lastS5Click = now;

    bool didAction = false;
    int addAmt = 0;

    if (val == 1 && step >= 0) {
      addAmt = s5c1Count == 0 ? 3 : 2;
      setState(() {
        s5c1Count += addAmt;
        s5v1Total = s5c1Count * 1;
      });
      didAction = true;
    } else if (val == 5) {
      if (step < 1) {
        _playSound(_errorUrl, _errorPlayer);
        return;
      }
      addAmt = s5c5Count == 0 ? 1 : 2;
      setState(() {
        s5c5Count += addAmt;
        s5v5Total = s5c5Count * 5;
      });
      didAction = true;
    } else if (val == 10) {
      if (step < 2) {
        _playSound(_errorUrl, _errorPlayer);
        return;
      }
      addAmt = s5c10Count == 0 ? 2 : 2;
      setState(() {
        s5c10Count += addAmt;
        s5v10Total = s5c10Count * 10;
      });
      didAction = true;
    }

    if (didAction) {
      _playSound(_clickUrl, _clickPlayer);
      for (int i = 0; i < addAmt; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (!mounted) return;
          setState(() {
            s5Coins.add(
              Offset(
                (math.Random().nextDouble() * 100) - 50,
                (math.Random().nextDouble() * 60) - 30,
              ),
            );
          });
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted && s5Coins.isNotEmpty) {
              setState(() => s5Coins.removeAt(0));
            }
          });
        });
      }

      if (s5c1Count > 0 && step == 0) markStepComplete();
      if (s5c5Count > 0 && step == 1) markStepComplete();
      if (s5c10Count > 0 && step == 2) markStepComplete();

      if (step == 3) {
        s5ExpClicks++;
        if (s5ExpClicks >= 3) markStepComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = math.min(screenWidth * 0.30, 420.0);
    if (sidebarWidth < 280) sidebarWidth = 280;

    return Scaffold(
      backgroundColor: zslDark,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap:
            () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Canvas Area
            Positioned.fill(
              left: isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: GestureDetector(
                  onTapDown:
                      (details) => handleTapDown(
                        details,
                        Size(
                          screenWidth - (isSidebarOpen ? sidebarWidth : 0),
                          MediaQuery.of(context).size.height,
                        ),
                      ),
                  onScaleStart:
                      (details) => handleScaleStart(
                        details,
                        Size(
                          screenWidth - (isSidebarOpen ? sidebarWidth : 0),
                          MediaQuery.of(context).size.height,
                        ),
                      ),
                  onScaleUpdate:
                      (details) => handleScaleUpdate(
                        details,
                        Size(
                          screenWidth - (isSidebarOpen ? sidebarWidth : 0),
                          MediaQuery.of(context).size.height,
                        ),
                      ),
                  onScaleEnd: handleScaleEnd,
                  child: Container(
                    color: const Color(0xff090e17),
                    child: CustomPaint(
                      painter: ParityCanvasPainter(
                        scenario: scenario,
                        step: step,
                        zoom: zoom,
                        panX: panX,
                        panY: panY,
                        beltSlots: beltSlots,
                        allowedContainers: allowedContainers,
                        allContainers: allContainers,
                        machineState: machineState,
                        machineText: machineText,
                        machineOutputPairs: machineOutputPairs,
                        machineOutputLeftover: machineOutputLeftover,
                        animValue: _machineAnimController.value,
                        activeBlocks: activeBlocks,
                        s5Coins: s5Coins,
                        s5c1Count: s5c1Count,
                        s5c5Count: s5c5Count,
                        s5c10Count: s5c10Count,
                        s5v1Total: s5v1Total,
                        s5v5Total: s5v5Total,
                        s5v10Total: s5v10Total,
                        activeDragType: activeDragType,
                        activeDragId: activeDragId,
                        activeDragPos: activeDragPos,
                        activeHoverSlot: activeHoverSlot,
                        actionValidated: actionValidated,
                        s4Fails: s4Fails,
                        activateBtnText: t('activateBtn'),
                        targetLabel: t('targetLabel'),
                        sumLabel: t('sumLabel'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Target UI Overlay (Scenario 4) floated centrally
            if (scenario == 4 && (!isSidebarOpen || isSidebarOpen))
              Positioned(
                top: 16,
                left:
                    isSidebarOpen
                        ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 120
                        : screenWidth / 2 - 120,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: machineState == 'done' ? laserRed : laserYellow,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      "${t('targetLabel')}: 30  |  ${t('sumLabel')}: ${beltSlots.where((e) => e != null).fold(0, (sum, id) => sum + allContainers.firstWhere((c) => c.id == id).val)}",
                      style: TextStyle(
                        color: machineState == 'done' ? laserRed : laserYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

            // Floating Active Step Card (Top Left on Canvas when Sidebar is Closed)
            if (!isSidebarOpen)
              Positioned(
                left: 16,
                top: 80,
                width: 280,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: laserBlue.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assistant_navigation,
                              color: laserBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${t('missionSteps')} - ${step + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getActiveStepHudText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getActiveStepTxtText(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Interactive Mini HUD (Only HUD text at bottom center)
            Positioned(
              bottom: 24,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    minWidth: 320,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: panelBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: laserBlue.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: laserBlue.withOpacity(0.15),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getActiveStepHudText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      if (feedbackMsg.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          feedbackMsg,
                          style: TextStyle(
                            color:
                                feedbackType == 'success'
                                    ? Colors.green
                                    : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Top-Left Front Control (Menu Toggle ONLY)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: panelBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    () => setState(() {
                      isSidebarOpen = !isSidebarOpen;
                      _playSound(_clickUrl, _clickPlayer);
                    }),
              ),
            ),

            // Global Success Modal
            if (globalSuccessShown)
              Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        width: 450,
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: panelBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: laserBlue, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calculate,
                              size: 80,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('geoMaster'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('geoMasterText'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: Text(t('restartMission')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: laserBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: resetLab,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 32,
                        top: 32,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() => globalSuccessShown = false);
                            _playSound(_clickUrl, _clickPlayer);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Shutter Curtain Overlay (Topmost)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: isShutterOpen ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: _buildShutterScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: zslDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: laserBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: laserBlue.withOpacity(0.6), blurRadius: 40),
              ],
            ),
            child: const Icon(Icons.calculate, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            t('title'),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            t('subtitle'),
            style: const TextStyle(fontSize: 18, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              _playSound(_successUrl, _successPlayer);
              setState(() {
                isShutterOpen = false;
              });
            },
            icon: const Icon(Icons.power_settings_new),
            label: Text(t('enterLab')),
            style: ElevatedButton.styleFrom(
              backgroundColor: laserBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              shadowColor: laserBlue.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 80,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: laserBlue, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        t('subtitle'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _playSound(_clickUrl, _clickPlayer);
                      setState(() {
                        if (currentLang == 'en') {
                          currentLang = 'hi';
                        } else {
                          currentLang = 'en';
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.language,
                            color: Colors.white54,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentLang.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.restart_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Reset',
                    onPressed: resetLab,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              t('selectMission'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: zslDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: scenario,
                  isExpanded: true,
                  dropdownColor: zslDark,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text(t('scen1Title'))),
                    DropdownMenuItem(value: 2, child: Text(t('scen2Title'))),
                    DropdownMenuItem(value: 3, child: Text(t('scen3Title'))),
                    DropdownMenuItem(value: 4, child: Text(t('scen4Title'))),
                    DropdownMenuItem(value: 5, child: Text(t('scen5Title'))),
                  ],
                  onChanged: (val) {
                    if (val != null) loadScenario(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Objective Box Re-added per prompt instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.track_changes, color: laserBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t('objective'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getObjectiveText(scenario),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                const Icon(
                  Icons.format_list_numbered,
                  color: Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t('missionSteps'),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._buildStepsList(),

            if (step >= _getStepsCount(scenario))
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: laserGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: laserGreen.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: laserGreen, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      t('missionCompleted'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSummaryText(scenario),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Footer required by prompt (Now scrolls naturally at bottom)
            const Center(
              child: Text(
                "© ZeroScienceLab - Fall in love with math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActiveStepHudText() {
    List<Map<String, String>> steps = _getStepsForScenario(scenario);
    if (step < steps.length) {
      return steps[step]['hud']!.replaceAll(RegExp(r'<[^>]*>'), '');
    }
    return t('missionCompleted');
  }

  String _getActiveStepTxtText() {
    List<Map<String, String>> steps = _getStepsForScenario(scenario);
    if (step < steps.length) {
      return steps[step]['txt']!;
    }
    return "";
  }

  String _getObjectiveText(int scen) => t('s${scen}Obj');

  int _getStepsCount(int scen) {
    switch (scen) {
      case 1:
        return 4;
      case 2:
        return 4;
      case 3:
        return 3;
      case 4:
        return 3;
      case 5:
        return 4;
      default:
        return 0;
    }
  }

  List<Map<String, String>> _getStepsForScenario(int scen) {
    List<Map<String, String>> s = [];
    int count = _getStepsCount(scen);
    for (int i = 1; i <= count; i++) {
      s.add({"hud": t("s${scen}h$i"), "txt": t("s${scen}t$i")});
    }
    return s;
  }

  String _getSummaryText(int scen) => t('s${scen}Sum');

  List<Widget> _buildStepsList() {
    List<Map<String, String>> stepsData = _getStepsForScenario(scenario);
    List<Widget> children = [];

    for (int i = 0; i < stepsData.length; i++) {
      bool isPast = i < step;
      bool isActive = i == step;

      Color bgColor =
          isActive
              ? laserBlue.withOpacity(0.2)
              : (isPast ? Colors.white.withOpacity(0.05) : Colors.transparent);
      Color borderColor = isActive ? laserBlue : Colors.white.withOpacity(0.1);
      Color textColor =
          isPast ? Colors.white54 : (isActive ? Colors.white : Colors.white38);

      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPast
                  ? Icon(Icons.check_circle, color: laserGreen, size: 28)
                  : Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? laserBlue : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only showing the txt (2nd para) inside the sidebar logic log as requested
                    Text(
                      stepsData[i]['txt']!,
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
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
      );
    }
    return children;
  }
}

class ParityCanvasPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;

  final List<int?> beltSlots;
  final List<int> allowedContainers;
  final List<ParityContainer> allContainers;

  final String machineState;
  final String machineText;
  final int machineOutputPairs;
  final bool machineOutputLeftover;
  final double animValue; // 0.0 to 1.0 from AnimationController
  final List<BlockData> activeBlocks;

  final int s5c1Count;
  final int s5c5Count;
  final int s5c10Count;
  final int s5v1Total;
  final int s5v5Total;
  final int s5v10Total;
  final List<Offset> s5Coins;

  final String activeDragType;
  final int activeDragId;
  final Offset activeDragPos;
  final int activeHoverSlot;
  final bool actionValidated;
  final int s4Fails;

  final String activateBtnText;
  final String targetLabel;
  final String sumLabel;

  ParityCanvasPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.beltSlots,
    required this.allowedContainers,
    required this.allContainers,
    required this.machineState,
    required this.machineText,
    required this.machineOutputPairs,
    required this.machineOutputLeftover,
    required this.animValue,
    required this.activeBlocks,
    required this.s5Coins,
    required this.s5c1Count,
    required this.s5c5Count,
    required this.s5c10Count,
    required this.s5v1Total,
    required this.s5v5Total,
    required this.s5v10Total,
    required this.activeDragType,
    required this.activeDragId,
    required this.activeDragPos,
    required this.activeHoverSlot,
    required this.actionValidated,
    required this.s4Fails,
    required this.activateBtnText,
    required this.targetLabel,
    required this.sumLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scale = math.min(size.width, size.height) / 800.0 * zoom;
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(scale, scale);

    // Grid
    Paint gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (int i = -1000; i <= 1000; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), -1000),
        Offset(i.toDouble(), 1000),
        gridPaint,
      );
      canvas.drawLine(
        Offset(-1000, i.toDouble()),
        Offset(1000, i.toDouble()),
        gridPaint,
      );
    }

    if (scenario <= 4) {
      _drawScenarios1to4(canvas);
    } else {
      _drawScenario5(canvas);
    }
  }

  void _drawScenarios1to4(Canvas canvas) {
    // Storage Shelf
    Color shelfMainColor = const Color(0xff334155);
    Paint shelfMain = Paint()..color = shelfMainColor;
    Paint shelfSide = Paint()..color = const Color(0xff1e293b);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-470, -190, 400, 10),
        const Radius.circular(4),
      ),
      shelfMain,
    );
    Path p1 =
        Path()
          ..moveTo(-440, -180)
          ..lineTo(-420, -150)
          ..lineTo(-400, -180)
          ..close();
    canvas.drawPath(p1, shelfSide);
    Path p2 =
        Path()
          ..moveTo(-160, -180)
          ..lineTo(-140, -150)
          ..lineTo(-120, -180)
          ..close();
    canvas.drawPath(p2, shelfSide);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-470, 30, 400, 10),
        const Radius.circular(4),
      ),
      shelfMain,
    );
    Path p3 =
        Path()
          ..moveTo(-440, 40)
          ..lineTo(-420, 70)
          ..lineTo(-400, 40)
          ..close();
    canvas.drawPath(p3, shelfSide);
    Path p4 =
        Path()
          ..moveTo(-160, 40)
          ..lineTo(-140, 70)
          ..lineTo(-120, 40)
          ..close();
    canvas.drawPath(p4, shelfSide);

    // Conveyor System
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-480, 150, 600, 20),
        const Radius.circular(10),
      ),
      shelfSide,
    ); // Base

    // Moving belt dashes
    double beltOffset =
        (machineState == 'running' && animValue < 0.4) ? animValue * 200 : 0;
    _drawDashedLine(
      canvas,
      const Offset(-460, 150),
      const Offset(100, 150),
      Paint()
        ..color = const Color(0xff94a3b8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
      beltOffset,
    );

    canvas.drawCircle(
      const Offset(-460, 160),
      10,
      Paint()..color = const Color(0xff0f172a),
    );
    canvas.drawCircle(
      const Offset(100, 160),
      10,
      Paint()..color = const Color(0xff0f172a),
    );
    canvas.drawRect(const Rect.fromLTWH(-440, 170, 10, 130), shelfMain);
    canvas.drawRect(const Rect.fromLTWH(-80, 170, 10, 130), shelfMain);

    // Machine Base
    canvas.save();
    canvas.translate(230, 0);

    // Output Tray
    Path tPath =
        Path()
          ..moveTo(140, 130)
          ..lineTo(480, 130)
          ..lineTo(480, 150)
          ..lineTo(140, 150)
          ..close();
    canvas.drawPath(tPath, shelfMain);
    canvas.drawPath(
      tPath,
      Paint()
        ..color = const Color(0xff475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRect(const Rect.fromLTWH(250, 150, 10, 150), shelfMain);
    canvas.drawRect(const Rect.fromLTWH(400, 150, 10, 150), shelfMain);

    // Core Machine
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-140, -80, 280, 280),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xff1e293b),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-140, -80, 280, 280),
        const Radius.circular(16),
      ),
      Paint()
        ..color = shelfMainColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Leftover Bin
    canvas.save();
    canvas.translate(0, 200);
    Path bPath =
        Path()
          ..moveTo(-50, 0)
          ..lineTo(50, 0)
          ..lineTo(40, 60)
          ..lineTo(-40, 60)
          ..close();
    canvas.drawPath(bPath, Paint()..color = const Color(0xff020617));
    canvas.drawPath(
      bPath,
      Paint()
        ..color = shelfMainColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _drawText(
      canvas,
      "LEFTOVER",
      const Offset(0, 35),
      fontSize: 12,
      color: Colors.redAccent,
    );
    canvas.restore();

    // Internal Dark Window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-110, -50, 220, 180),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xff020617),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-110, -50, 220, 180),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xff0f172a)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Machine Internals (Animated Blocks)
    if (machineState == 'running' && animValue >= 0.2) {
      // 0.2 to 0.4: scale down entering containers
      // 0.4 to 0.6: scatter
      // 0.6 to 0.8: pair
      // 0.8 to 1.0: output
      double pScatter = (animValue - 0.4) / 0.2;
      if (pScatter < 0) pScatter = 0;
      if (pScatter > 1) pScatter = 1;
      double pPair = (animValue - 0.6) / 0.2;
      if (pPair < 0) pPair = 0;
      if (pPair > 1) pPair = 1;
      double pOut = (animValue - 0.8) / 0.2;
      if (pOut < 0) pOut = 0;
      if (pOut > 1) pOut = 1;

      for (int i = 0; i < activeBlocks.length; i++) {
        BlockData b = activeBlocks[i];
        double cx = b.startX, cy = b.startY;

        if (animValue >= 0.4) {
          // move to pair
          double ePair =
              pPair < 0.5 ? 2 * pPair * pPair : -1 + (4 - 2 * pPair) * pPair;
          cx = b.startX + ePair * (b.pairX - b.startX);
          cy = b.startY + ePair * (b.pairY - b.startY);

          if (animValue >= 0.8) {
            // move to output
            double eOut =
                pOut < 0.5 ? 2 * pOut * pOut : -1 + (4 - 2 * pOut) * pOut;
            cx = b.pairX + eOut * (b.endX - b.pairX);
            cy = b.pairY + eOut * (b.endY - b.pairY);
          }
        }

        _drawGlowCube(canvas, Offset(cx, cy), b.color, 0.8);
      }
    } else if (machineState == 'done') {
      // Static output
      for (int i = 0; i < machineOutputPairs; i++) {
        int col = i ~/ 5;
        int row = i % 5;
        double bx = 250 + col * 40 - 15;
        double by = 120 - row * 24;
        _drawGlowCube(
          canvas,
          Offset(bx - 12, by),
          const Color(0xff3b82f6),
          0.8,
        );
        _drawGlowCube(
          canvas,
          Offset(bx + 12, by),
          const Color(0xff3b82f6),
          0.8,
        );
      }
      if (machineOutputLeftover) {
        _drawGlowCube(
          canvas,
          const Offset(0, 220),
          const Color(0xffef4444),
          0.8,
        );
      }
    }

    // Front Overlay to hide stuff entering
    Path mFront =
        Path()
          ..moveTo(-140, -20)
          ..lineTo(-110, -20)
          ..lineTo(-110, 180)
          ..lineTo(-140, 180)
          ..close();
    canvas.drawPath(mFront, Paint()..color = const Color(0xff1e293b));
    canvas.drawPath(
      mFront,
      Paint()
        ..color = shelfMainColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Top Display Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-80, -160, 160, 50),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xff020617),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-80, -160, 160, 50),
        const Radius.circular(6),
      ),
      Paint()
        ..color = shelfMainColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    Color textColor = const Color(0xff3b82f6);
    if (machineText == 'EVEN') {
      textColor = const Color(0xff22c55e);
    } else if (machineText == 'ODD') {
      textColor = const Color(0xffef4444);
    }
    // Text Shadow manually
    _drawText(
      canvas,
      machineText,
      const Offset(0, -125),
      fontSize: 24,
      color: textColor.withOpacity(0.5),
      blur: 10,
    );
    _drawText(
      canvas,
      machineText,
      const Offset(0, -125),
      fontSize: 24,
      color: textColor,
    );

    canvas.restore();

    // Belt Slots Highlights
    int slotsNum = scenario == 4 ? 5 : 2;
    for (int i = 0; i < slotsNum; i++) {
      Offset sp = _getBeltSlotPos(i);
      bool highlight = activeDragType == 'cont' && activeHoverSlot == i;
      Color fC =
          highlight
              ? const Color(0xff3b82f6).withOpacity(0.2)
              : Colors.transparent;
      Color sC =
          highlight
              ? const Color(0xff3b82f6).withOpacity(0.8)
              : Colors.transparent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sp.dx - 35, sp.dy - 85, 70, 90),
          const Radius.circular(4),
        ),
        Paint()..color = fC,
      );
      _drawDashedRect(
        canvas,
        Rect.fromLTWH(sp.dx - 35, sp.dy - 85, 70, 90),
        Paint()
          ..color = sC
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Containers
    for (int cid in allowedContainers) {
      ParityContainer cont = allContainers.firstWhere((c) => c.id == cid);
      double fx = 0, fy = 0;
      bool isDragging = activeDragType == 'cont' && activeDragId == cid;

      if (isDragging) {
        fx = activeDragPos.dx;
        fy = activeDragPos.dy;
      } else {
        int slotIdx = beltSlots.indexOf(cid);
        if (slotIdx != -1) {
          if (machineState == 'idle') {
            fx = _getBeltSlotPos(slotIdx).dx;
            fy = _getBeltSlotPos(slotIdx).dy;
          } else if (machineState == 'running' && animValue < 0.4) {
            // Entering animation
            double pMove = animValue / 0.4;
            double startX = _getBeltSlotPos(slotIdx).dx;
            fx = startX + pMove * (220 - startX);
            fy = 150.0;
          } else {
            continue; // Hidden inside machine
          }
        } else {
          int holdIdx = allowedContainers.indexOf(cid);
          fx = _getShelfPos(holdIdx).dx;
          fy = _getShelfPos(holdIdx).dy;
        }
      }

      double opacity = 1.0;
      if (machineState == 'running' &&
          animValue > 0.2 &&
          animValue < 0.4 &&
          beltSlots.contains(cid)) {
        opacity = 1 - ((animValue - 0.2) / 0.2); // fade out as entering
      }

      canvas.save();
      canvas.translate(fx, fy);
      _drawContainer(canvas, cont, opacity);
      canvas.restore();
    }

    // Activate Button
    int expectedCount = scenario == 4 ? 5 : 2;
    int count = beltSlots.where((v) => v != null).length;

    canvas.save();
    canvas.translate(-300, 240);
    if (count == expectedCount && machineState == 'idle' && !actionValidated) {
      _drawButton(
        canvas,
        const Offset(0, 0),
        activateBtnText,
        const Color(0xff22c55e),
      );
    }
    canvas.restore();
  }

  void _drawScenario5(Canvas canvas) {
    // Piggy Bank Art
    canvas.save();
    canvas.translate(150, 0);
    canvas.drawOval(
      const Rect.fromLTWH(-140, -110, 280, 220),
      Paint()
        ..color = const Color(0xffec4899).withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-140, -110, 280, 220),
      Paint()
        ..color = const Color(0xffdb2777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    canvas.drawOval(
      const Rect.fromLTWH(120, -40, 40, 80),
      Paint()
        ..color = const Color(0xffec4899).withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      const Rect.fromLTWH(120, -40, 40, 80),
      Paint()
        ..color = const Color(0xffdb2777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    canvas.drawCircle(
      const Offset(145, -15),
      5,
      Paint()..color = const Color(0xff9d174d),
    );
    canvas.drawCircle(
      const Offset(145, 15),
      5,
      Paint()..color = const Color(0xff9d174d),
    );

    Path ear =
        Path()
          ..moveTo(40, -100)
          ..lineTo(60, -150)
          ..lineTo(80, -90)
          ..close();
    canvas.drawPath(
      ear,
      Paint()
        ..color = const Color(0xffec4899).withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      ear,
      Paint()
        ..color = const Color(0xffdb2777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -110, 80, 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xff831843),
    );

    // Dropping Coins
    for (Offset p in s5Coins) {
      canvas.drawCircle(
        Offset(p.dx - 30, p.dy - 150),
        15,
        Paint()..color = const Color(0xffeab308),
      );
      canvas.drawCircle(
        Offset(p.dx - 30, p.dy - 150),
        15,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.restore();

    // Target UI
    canvas.save();
    canvas.translate(150, -200);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-120, -30, 240, 60),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xff020617),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-120, -30, 240, 60),
        const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xffef4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      "Target Total:",
      const Offset(0, -5),
      fontSize: 18,
      color: const Color(0xffcbd5e1),
    );
    _drawText(
      canvas,
      "₹205 (ODD)",
      const Offset(0, 20),
      fontSize: 24,
      color: const Color(0xffef4444),
    );
    canvas.restore();

    // Calc Panel
    canvas.save();
    canvas.translate(150, 200);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-220, -40, 440, 90),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xff1e293b).withOpacity(0.8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-220, -40, 440, 90),
        const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xff475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    int overall = s5v1Total + s5v5Total + s5v10Total;
    bool isEven = overall % 2 == 0;

    _drawText(
      canvas,
      "₹$s5v1Total + ₹$s5v5Total + ₹$s5v10Total = ₹$overall",
      const Offset(0, -15),
      fontSize: 16,
    );
    _drawText(
      canvas,
      "${s5v1Total % 2 == 0 ? 'EVEN' : 'ODD'} + ${s5v5Total % 2 == 0 ? 'EVEN' : 'ODD'} + ${s5v10Total % 2 == 0 ? 'EVEN' : 'ODD'} = ${isEven ? 'EVEN' : 'ODD'}",
      const Offset(0, 10),
      fontSize: 14,
      color: const Color(0xff94a3b8),
    );
    _drawText(
      canvas,
      "TOTAL PARITY: ${isEven ? 'EVEN' : 'ODD'}",
      const Offset(0, 35),
      fontSize: 22,
      color: isEven ? const Color(0xff3b82f6) : const Color(0xffef4444),
    );
    canvas.restore();

    // Dispensers
    canvas.save();
    canvas.translate(-250, -100);
    _drawDispenser(
      canvas,
      0,
      "₹1",
      "(ODD Total)",
      const Color(0xffa855f7),
      s5c1Count,
      s5v1Total,
      s5v1Total % 2 == 0 ? 'EVEN' : 'ODD',
      s5c1Count == 0 ? 3 : 2,
    );
    _drawDispenser(
      canvas,
      100,
      "₹5",
      "(ODD Total)",
      const Color(0xff3b82f6),
      s5c5Count,
      s5v5Total,
      s5v5Total % 2 == 0 ? 'EVEN' : 'ODD',
      s5c5Count == 0 ? 1 : 2,
    );
    _drawDispenser(
      canvas,
      200,
      "₹10",
      "(EVEN Total)",
      const Color(0xff22c55e),
      s5c10Count,
      s5v10Total,
      s5v10Total % 2 == 0 ? 'EVEN' : 'ODD',
      s5c10Count == 0 ? 2 : 2,
    );
    canvas.restore();
  }

  void _drawDispenser(
    Canvas canvas,
    double dy,
    String title,
    String parityLabel,
    Color btnColor,
    int count,
    int total,
    String parity,
    int addAmt,
  ) {
    canvas.save();
    canvas.translate(0, dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-110, -35, 220, 70),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xff1e293b),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-110, -35, 220, 70),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xff475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawText(
      canvas,
      "$title Coins",
      const Offset(-95, -15),
      fontSize: 16,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      parityLabel,
      const Offset(95, -15),
      fontSize: 11,
      color: btnColor,
      align: TextAlign.right,
    );
    _drawText(
      canvas,
      "$count x $title = ₹$total ($parity)",
      const Offset(-95, 10),
      fontSize: 13,
      color: const Color(0xff94a3b8),
      align: TextAlign.left,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, -3, 80, 26),
        const Radius.circular(6),
      ),
      Paint()..color = btnColor,
    );
    _drawText(
      canvas,
      "+ $addAmt Coin${addAmt > 1 ? 's' : ''}",
      const Offset(55, 10),
      fontSize: 12,
    );

    canvas.restore();
  }

  void _drawContainer(Canvas canvas, ParityContainer cont, double opacity) {
    if (opacity <= 0) return;
    int pairs = cont.val ~/ 2;
    bool hasLeftover = cont.val % 2 != 0;
    int maxRows = pairs + (hasLeftover ? 1 : 0);
    double contH = math.max(85, maxRows * 25 + 20).toDouble();

    Paint strokeP =
        Paint()
          ..color = const Color(0xff475569).withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    Path bgPath =
        Path()
          ..moveTo(-30, -contH)
          ..lineTo(-30, 0)
          ..arcToPoint(const Offset(-25, 5), radius: const Radius.circular(5))
          ..lineTo(25, 5)
          ..arcToPoint(const Offset(30, 0), radius: const Radius.circular(5))
          ..lineTo(30, -contH);
    canvas.drawPath(
      bgPath,
      Paint()..color = Colors.white.withOpacity(0.1 * opacity),
    );
    canvas.drawPath(bgPath, strokeP);

    for (int i = 0; i < pairs; i++) {
      double y = -25 - i * 25;
      _drawGlowCube(canvas, Offset(-13, y), cont.color, opacity);
      _drawGlowCube(canvas, Offset(13, y), cont.color, opacity);
    }
    if (hasLeftover) {
      double y = -25 - pairs * 25;
      _drawGlowCube(canvas, Offset(0, y), cont.color, opacity);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-30, -contH, 60, contH + 5),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.white.withOpacity(0.2 * opacity),
    );

    canvas.drawCircle(
      const Offset(0, 20),
      14,
      Paint()..color = const Color(0xff0f172a).withOpacity(opacity),
    );
    canvas.drawCircle(const Offset(0, 20), 14, strokeP);
    _drawText(
      canvas,
      "${cont.val}",
      const Offset(0, 20),
      fontSize: 14,
      opacity: opacity,
    );
  }

  void _drawGlowCube(
    Canvas canvas,
    Offset pos,
    Color baseColor,
    double opacity,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-11, -7, 22, 22),
        const Radius.circular(3),
      ),
      Paint()..color = baseColor.withOpacity(0.4 * opacity),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-11, -11, 22, 22),
        const Radius.circular(3),
      ),
      Paint()..color = baseColor.withOpacity(opacity),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, -9, 18, 18),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withOpacity(0.3 * opacity),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -9, 10, 4),
        const Radius.circular(1),
      ),
      Paint()..color = Colors.white.withOpacity(0.6 * opacity),
    );

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    double fontSize = 16,
    Color color = Colors.white,
    double opacity = 1.0,
    TextAlign align = TextAlign.center,
    double blur = 0,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color.withOpacity(opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'sans-serif',
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    double dx =
        align == TextAlign.center
            ? pos.dx - tp.width / 2
            : (align == TextAlign.right ? pos.dx - tp.width : pos.dx);

    if (blur > 0) {
      canvas.save();
      tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
      canvas.restore();
    }

    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  void _drawButton(Canvas canvas, Offset center, String label, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    Rect r = const Rect.fromLTWH(-80, -25, 160, 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(25)),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(25)),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(canvas, label, const Offset(0, 0), fontSize: 18);
    canvas.restore();
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    double offset,
  ) {
    double dashWidth = 10;
    double dashSpace = 10;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;

    double startDraw = offset % (dashWidth + dashSpace);
    double x = p1.dx + dx * startDraw;
    double y = p1.dy + dy * startDraw;
    double drawn = startDraw;

    while (drawn < distance) {
      double drawL = math.min(dashWidth, distance - drawn);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dx * drawL, y + dy * drawL),
        paint,
      );
      x += dx * (drawL + dashSpace);
      y += dy * (drawL + dashSpace);
      drawn += drawL + dashSpace;
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    Path path =
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
    canvas.drawPath(path, paint);
  }

  Offset _getBeltSlotPos(int i) {
    if (scenario == 4) return Offset(-380.0 + i * 90, 150.0);
    return Offset(-250.0 + i * 120, 150.0);
  }

  Offset _getShelfPos(int holdIdx) {
    int row = holdIdx ~/ 5;
    int col = holdIdx % 5;
    double shelfY = row == 0 ? -190.0 : 30.0;
    return Offset(-430.0 + col * 75, shelfY);
  }

  @override
  bool shouldRepaint(covariant ParityCanvasPainter oldDelegate) => true;
}
