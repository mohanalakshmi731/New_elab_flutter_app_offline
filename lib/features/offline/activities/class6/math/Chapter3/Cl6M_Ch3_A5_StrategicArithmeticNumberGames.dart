// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Strategic Arithmetic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch3_A5_StrategicArithmeticNumberGames(),
    ),
  );
}

// --- LOCALIZATION DATA ---
const Map<String, Map<String, String>> t = {
  'en': {
    'shutterTitle': 'Strategic Arithmetic & Number Games',
    'appTitle': 'Strategic Arithmetic',
    'appSubtitle': 'Class 6 • EXPLORING NUMBER PLAY',
    'enterLab': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'learnLbl': 'Goal:',
    'nextScenario': 'Next Scenario',
    'finishLab': 'Finish Lab',
    'summaryTitle': 'Challenge Complete!',
    'finalDesc':
        'You have successfully explored the playful and strategic side of mathematics!',

    's1_title': '1. The Taller Neighbours',
    's1_obj':
        'Arrange 5 children of different heights to match the target sequence of taller neighbours: 0, 1, 2, 1, 0.',
    's1_step1_task':
        'DRAG the shortest child (Height 1) to the middle slot (Slot 3).',
    's1_step1_out':
        "The middle child has a '0' as they have no neighbours yet.",
    's1_step2_task':
        'DRAG the two tallest children (Heights 4, 5) to the slots on either side (Slots 2 and 4).',
    's1_step2_out':
        'The middle child now points to 2 taller neighbours. The tall children each have 0 taller neighbours.',
    's1_step3_task':
        'DRAG the remaining two children (Heights 2, 3) to the empty end slots (Slots 1 and 5).',
    's1_step3_out':
        "Sequence 0, 1, 2, 1, 0 achieved! The tallest people at the ends always have a '0'.",
    's1_hud1': 'Drag the shortest child to the center.',
    's1_hud2': 'Drag the two tallest to the sides of the center.',
    's1_hud3': 'Drag the rest to the ends.',
    'lbl_s1_target': 'TARGET: 0, 1, 2, 1, 0',
    'lbl_s1_current': 'CURRENT: ',
    'lbl_s1_slot': 'Slot',

    's2_title': '2. Supercell Grid',
    's2_obj':
        "Place numbered blocks into grids. A block becomes a 'supercell' if it is larger than all its adjacent neighbours.",
    's2_step1_task': "DRAG '577' into the middle grid cell (3x1 grid).",
    's2_step1_out': 'It is placed, but needs neighbours to compare.',
    's2_step2_task': "DRAG '200' into the left grid cell.",
    's2_step2_out':
        '577 is larger than 200, but the right side is still empty.',
    's2_step3_task': "DRAG '345' into the right grid cell.",
    's2_step3_out': 'Supercell Activated! 577 is larger than both neighbours.',
    's2_step4_task':
        'In the 5x1 grid, arrange 1, 2, 3, 4, 5 to create 3 supercells.',
    's2_step4_out':
        'Optimal arrangement creates peaks and valleys (e.g., 5, 1, 4, 2, 3) resulting in maximum supercells.',
    's2_hud1': 'Place 577 in the center.',
    's2_hud2': 'Place 200 on the left.',
    's2_hud3': 'Place 345 on the right.',
    's2_hud4': 'Arrange 1 to 5 to get 3 glowing supercells.',
    'lbl_s2Supercells': 'Supercells:',

    's3_title': '3. The Kaprekar 6174 Machine',
    's3_obj':
        "Process 4 digits by sorting and subtracting to discover Kaprekar's constant.",
    's3_step1_task':
        'DRAG all 4 tiles (6, 3, 8, 2) into the machine\'s top input funnel.',
    's3_step1_out': 'Tiles loaded.',
    's3_step2_task': "CLICK the 'Process' button.",
    's3_step2_out': 'Sorted to Largest (8632) and Smallest (2368).',
    's3_step3_task': "CLICK the 'Subtract' button.",
    's3_step3_out': '8632 - 2368 = 6264.',
    's3_step4_task':
        'DRAG the result block back into the input funnel. Process and Subtract.',
    's3_step4_out': 'Loop completed: 6642 - 2466 = 4176.',
    's3_step5_task':
        'Repeat the loop until the result gets stuck in a constant loop.',
    's3_step5_out':
        'Constant 6174 Reached! Feeding it back always yields 6174.',
    's3_hud1': 'Drag all 4 individual tiles into the funnel.',
    's3_hud2': 'Click Process.',
    's3_hud3': 'Click Subtract.',
    's3_hud4': 'Drag the result block back to the funnel.',
    's3_hud5': 'Keep looping until 6174.',
    'lbl_s3Input': 'INPUT',
    'lbl_s3Large': 'Large (A)',
    'lbl_s3Small': 'Small (B)',
    'lbl_s3Res': 'Result (A - B)',
    'lbl_s3_process': 'PROCESS',
    'lbl_s3_sub': 'SUBTRACT',

    's4_title': '4. The Game of 21',
    's4_obj':
        'Play against the computer to reach exactly 21. Discover the winning strategy.',
    's4_step1_task':
        'You go first. Click +1, +2, or +3 to move your piece along the path.',
    's4_step1_out': 'The computer counter-moves.',
    's4_step2_task':
        'Keep playing. Try to win against the smart computer. Observe its safe spots.',
    's4_step2_out':
        'The computer always targets multiples of 4 away from the goal (1, 5, 9, 13, 17).',
    's4_step3_task':
        "CLICK 'Let PC Start'. Now use the strategy to win by landing on the safe spots.",
    's4_step3_out':
        'Strategy Master! You won by maintaining control of the safe positions.',
    's4_hud1': 'Click +1, +2, or +3.',
    's4_hud2': 'Keep playing and try to win.',
    's4_hud3': 'Let PC start and use strategy.',
    'lbl_s4Pcstart': 'Let PC Start',
    'lbl_s4Sum': 'SUM:',
    'lbl_s4_p1': 'YOU',
    'lbl_s4_p2': 'PC',
    'lbl_s4_safe': 'SAFE SPOTS:',

    's5_title': '5. The Collatz Journey',
    's5_obj':
        'Send numbers through a machine to test the Collatz Conjecture (Even: ÷2, Odd: x3+1).',
    's5_step1_task': "Type '12' on the numpad and click Launch.",
    's5_step1_out': '12 is launched.',
    's5_step2_task': 'Watch the number travel the EVEN (÷2) path.',
    's5_step2_out': '12 becomes 6. 6 becomes 3.',
    's5_step3_task': "Watch the '3' travel the ODD (x3+1) path.",
    's5_step3_out': '3 becomes 10.',
    's5_step4_task': 'Wait for the sequence to resolve.',
    's5_step4_out': 'Sequence reaches 1! (4, 2, 1 loop).',
    's5_step5_task':
        'Launch other numbers (e.g., 7 or 15) to see if they reach 1.',
    's5_step5_out':
        'Every number tested eventually leads to 1. This remains an unsolved mathematical mystery!',
    's5_hud1': 'Type 12 and launch.',
    's5_hud2': 'Observe the Even path.',
    's5_hud3': 'Observe the Odd path.',
    's5_hud4': 'Wait for the sequence to hit 1.',
    's5_hud5': 'Try launching other numbers.',
    'lbl_s5_even': 'EVEN: ÷2',
    'lbl_s5_odd': 'ODD: x3+1',
    'lbl_s5_launch': 'LAUNCH',
    'lbl_s5_seq': 'Sequence:',
    'lbl_s5_bin': 'Bin of 1s',
  },
  'hi': {
    'shutterTitle': 'रणनीतिक अंकगणित और संख्या खेल',
    'appTitle': 'रणनीतिक अंकगणित',
    'appSubtitle': 'कक्षा 6 • संख्या खेल की खोज',
    'enterLab': 'सिमुलेशन दर्ज करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'learnLbl': 'लक्ष्य:',
    'nextScenario': 'अगला परिदृश्य',
    'finishLab': 'समाप्त करें',
    'summaryTitle': 'चुनौती पूर्ण!',
    'finalDesc':
        'आपने गणित के चंचल और रणनीतिक पक्ष का सफलतापूर्वक पता लगाया है!',

    's1_title': '1. लंबे पड़ोसी',
    's1_obj':
        '5 बच्चों को व्यवस्थित करें ताकि लक्ष्य अनुक्रम: 0, 1, 2, 1, 0 मेल खा सके।',
    's1_step1_task': 'सबसे छोटे बच्चे को बीच में खींचें।',
    's1_step1_out': "बीच के बच्चे का '0' है क्योंकि अभी कोई पड़ोसी नहीं है।",
    's1_step2_task': 'दो सबसे लंबे बच्चों को बीच के दोनों ओर खींचें।',
    's1_step2_out': 'बीच वाले के 2 लंबे पड़ोसी हैं।',
    's1_step3_task': 'बाकी बच्चों को किनारे के स्लॉट में खींचें।',
    's1_step3_out': 'अनुक्रम 0, 1, 2, 1, 0 प्राप्त हुआ!',
    's1_hud1': 'सबसे छोटे बच्चे को केंद्र में खींचें।',
    's1_hud2': 'दो सबसे लंबे बच्चों को केंद्र के किनारों पर खींचें।',
    's1_hud3': 'बाकी को सिरों पर खींचें।',
    'lbl_s1_target': 'लक्ष्य: 0, 1, 2, 1, 0',
    'lbl_s1_current': 'वर्तमान: ',
    'lbl_s1_slot': 'स्लॉट',

    's2_title': '2. सुपरसेल ग्रिड',
    's2_obj':
        "ब्लॉक रखें। एक ब्लॉक 'सुपरसेल' बनता है यदि यह अपने पड़ोसियों से बड़ा हो।",
    's2_step1_task': "'577' को बीच के सेल में खींचें।",
    's2_step1_out': 'रखा गया, लेकिन तुलना की आवश्यकता है।',
    's2_step2_task': "'200' को बाएँ सेल में खींचें।",
    's2_step2_out': '577 बड़ा है, लेकिन दाहिना भाग खाली है।',
    's2_step3_task': "'345' को दाएँ सेल में खींचें।",
    's2_step3_out': 'सुपरसेल सक्रिय! 577 बड़ा है।',
    's2_step4_task':
        '5x1 ग्रिड में, 3 सुपरसेल बनाने के लिए 1, 2, 3, 4, 5 व्यवस्थित करें।',
    's2_step4_out': 'इष्टतम व्यवस्था चोटियाँ बनाती है।',
    's2_hud1': 'केंद्र में 577 रखें।',
    's2_hud2': 'बाईं ओर 200 रखें।',
    's2_hud3': 'दाईं ओर 345 रखें।',
    's2_hud4': '3 सुपरसेल प्राप्त करने के लिए व्यवस्थित करें।',
    'lbl_s2Supercells': 'सुपरसेल:',

    's3_title': '3. कप्रेकर 6174 मशीन',
    's3_obj': "कप्रेकर स्थिरांक खोजने के लिए 4 अंकों को संसाधित करें।",
    's3_step1_task': 'सभी 4 टाइलों को इनपुट फ़नल में खींचें।',
    's3_step1_out': 'टाइलें लोड की गईं।',
    's3_step2_task': "'प्रोसेस' बटन पर क्लिक करें।",
    's3_step2_out': 'बड़े और छोटे में क्रमबद्ध।',
    's3_step3_task': "'घटाएँ' बटन पर क्लिक करें।",
    's3_step3_out': '8632 - 2368 = 6264.',
    's3_step4_task': 'परिणाम ब्लॉक को वापस खींचें।',
    's3_step4_out': 'लूप पूरा हुआ।',
    's3_step5_task': 'लूप को तब तक दोहराएं जब तक कि 6174 न मिल जाए।',
    's3_step5_out': 'स्थिरांक 6174 पर पहुँच गया!',
    's3_hud1': 'टाइलों को फ़नल में खींचें।',
    's3_hud2': 'प्रोसेस पर क्लिक करें।',
    's3_hud3': 'घटाएँ पर क्लिक करें।',
    's3_hud4': 'परिणाम को फ़नल में वापस खींचें।',
    's3_hud5': '6174 तक लूप करते रहें।',
    'lbl_s3Input': 'इनपुट',
    'lbl_s3Large': 'बड़ा (A)',
    'lbl_s3Small': 'छोटा (B)',
    'lbl_s3Res': 'परिणाम',
    'lbl_s3_process': 'प्रक्रिया',
    'lbl_s3_sub': 'घटाएँ',

    's4_title': '4. 21 का खेल',
    's4_obj': '21 तक पहुँचने के लिए खेलें। जीतने की रणनीति खोजें।',
    's4_step1_task': '+1, +2, या +3 पर क्लिक करें।',
    's4_step1_out': 'कंप्यूटर अपनी चाल चलता है।',
    's4_step2_task':
        'खेलते रहें। स्मार्ट कंप्यूटर के सुरक्षित स्थानों का निरीक्षण करें।',
    's4_step2_out': 'कंप्यूटर 4 के गुणकों को लक्षित करता है।',
    's4_step3_task': "'पीसी शुरू करे' पर क्लिक करें। रणनीति का उपयोग करें।",
    's4_step3_out': 'रणनीति मास्टर! आपने जीत हासिल की।',
    's4_hud1': '+1, +2, या +3 पर क्लिक करें।',
    's4_hud2': 'जीतने की कोशिश करें।',
    's4_hud3': 'पीसी को शुरू करने दें।',
    'lbl_s4Pcstart': 'पीसी शुरू करे',
    'lbl_s4Sum': 'योग:',
    'lbl_s4_p1': 'आप',
    'lbl_s4_p2': 'पीसी',
    'lbl_s4_safe': 'सुरक्षित स्थान:',

    's5_title': '5. कोलैट्ज़ यात्रा',
    's5_obj':
        'कोलैट्ज़ कंजेक्चर का परीक्षण करने के लिए मशीन के माध्यम से संख्याएँ भेजें।',
    's5_step1_task': "'12' टाइप करें और लॉन्च पर क्लिक करें।",
    's5_step1_out': '12 लॉन्च किया गया।',
    's5_step2_task': 'संख्या को सम पथ पर देखें।',
    's5_step2_out': '12, 6 बन जाता है। 6, 3 बन जाता है।',
    's5_step3_task': "'3' को विषम पथ पर देखें।",
    's5_step3_out': '3, 10 बन जाता है।',
    's5_step4_task': 'अनुक्रम के हल होने की प्रतीक्षा करें।',
    's5_step4_out': 'अनुक्रम 1 पर पहुँचता है!',
    's5_step5_task': 'अन्य संख्याएँ लॉन्च करें।',
    's5_step5_out': 'परीक्षण की गई प्रत्येक संख्या 1 की ओर ले जाती है!',
    's5_hud1': '12 टाइप करें और लॉन्च करें।',
    's5_hud2': 'सम पथ का निरीक्षण करें।',
    's5_hud3': 'विषम पथ का निरीक्षण करें।',
    's5_hud4': '1 तक पहुँचने की प्रतीक्षा करें।',
    's5_hud5': 'अन्य संख्याओं को लॉन्च करें।',
    'lbl_s5_even': 'सम: ÷2',
    'lbl_s5_odd': 'विषम: x3+1',
    'lbl_s5_launch': 'लॉन्च',
    'lbl_s5_seq': 'अनुक्रम:',
    'lbl_s5_bin': '1 का बिन',
  },
};

// --- GAME STATE ---
class GameState {
  String lang = 'en';
  bool isCurtainOpen = false;
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  int scenario = 1;
  int step = 0;
  bool showSuccessPopup = false;

  // Simulator specifics
  bool animating = false;
  List<int?> s1Slots = [null, null, null, null, null];
  List<int> s1Counts = [0, 0, 0, 0, 0];

  List<int?> s2Grid3 = [null, null, null];
  List<int?> s2Grid5 = [null, null, null, null, null];
  int s2Supercells = 0;

  List<int> s3Input = [];
  String? s3Large;
  String? s3Small;
  int? s3Res;
  bool s3Subtracted = false;

  int s4Sum = 0;
  bool s4PcStart = false;
  String s4Turn = 'player';
  int s4Games = 0;

  String s5Input = "";
  List<int> s5History = [];
  int? s5Num;
  double s5AnimPhase = 0;

  String? activeDragEntity;
  double dragX = 0;
  double dragY = 0;
}

// --- MAIN SCREEN ---
class Cl6M_Ch3_A5_StrategicArithmeticNumberGames extends StatefulWidget {
  const Cl6M_Ch3_A5_StrategicArithmeticNumberGames({super.key});

  @override
  State<Cl6M_Ch3_A5_StrategicArithmeticNumberGames> createState() =>
      _Cl6M_Ch3_A5_StrategicArithmeticNumberGamesState();
}

class _Cl6M_Ch3_A5_StrategicArithmeticNumberGamesState
    extends State<Cl6M_Ch3_A5_StrategicArithmeticNumberGames>
    with TickerProviderStateMixin {
  final GameState state = GameState();
  final GlobalKey _canvasKey = GlobalKey();

  late AnimationController _gameLoop;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Gesture tracking base variables
  double _baseZoom = 1.0;

  // Audio paths
  final String tickSound = 'audio/class6/math/click.mp3';
  final String snapSound = 'audio/class6/math/click.mp3';
  final String successSound = 'audio/class6/math/success.mp3';
  final String errorSound = 'audio/class6/math/mixkit_2955.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(() {
            if (mounted) setState(() {});
          })
          ..forward();

    _fitCanvas();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Safe async audio playback handles Web Audio Context issues smoothly without type-errors
  Future<void> playSound(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  String tr(String key) {
    final langMap = t[state.lang];
    if (langMap != null) {
      final val = langMap[key];
      if (val != null) return val;
    }
    return key;
  }

  void toggleLanguage() {
    setState(() {
      state.lang = state.lang == 'en' ? 'hi' : 'en';
      playSound(tickSound);
    });
  }

  void _fitCanvas() {
    state.zoom = 1.0;
    state.panX = 0.0;
    state.panY = 0.0;
  }

  void loadScenario(int id) {
    setState(() {
      state.scenario = id;
      state.step = 0;
      state.showSuccessPopup = false;
      state.animating = false;
      state.activeDragEntity = null;

      if (id == 1) {
        state.s1Slots = [null, null, null, null, null];
        state.s1Counts = [0, 0, 0, 0, 0];
      }
      if (id == 2) {
        state.s2Grid3 = [null, null, null];
        state.s2Grid5 = [null, null, null, null, null];
        state.s2Supercells = 0;
      }
      if (id == 3) {
        state.s3Input = [];
        state.s3Large = null;
        state.s3Small = null;
        state.s3Res = null;
        state.s3Subtracted = false;
      }
      if (id == 4) {
        state.s4Sum = 0;
        state.s4PcStart = false;
        state.s4Turn = 'player';
        state.s4Games = 0;
      }
      if (id == 5) {
        state.s5Input = "";
        state.s5History = [];
        state.s5Num = null;
        state.s5AnimPhase = 0;
      }

      _fitCanvas();
      playSound(tickSound);
    });
  }

  void advanceStep() {
    setState(() {
      state.step++;
    });
  }

  void checkSuccess() {
    int maxSteps = state.scenario == 2
        ? 4
        : (state.scenario == 4 ? 3 : (state.scenario == 1 ? 3 : 5));
    if (state.step >= maxSteps) {
      playSound(successSound);
      setState(() {
        state.showSuccessPopup = true;
      });
    }
  }

  // Interaction Logic
  Offset _getWorldPoint(Offset screenPos) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final size = box.size;
    double worldX = (screenPos.dx - size.width / 2 - state.panX) / state.zoom;
    double worldY = (screenPos.dy - size.height / 2 - state.panY) / state.zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTest(Offset pt, double x, double y, double w, double h) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  // Uses raw Pointer Down to instantly catch clicks, bypassing gesture delays
  void _handlePointerDown(Offset localPosition) {
    if (state.showSuccessPopup) return;

    Offset pt = _getWorldPoint(localPosition);
    bool picked = false;

    if (!state.animating) {
      if (state.scenario == 1) {
        List<int> available = [
          1,
          2,
          3,
          4,
          5,
        ].where((h) => !state.s1Slots.contains(h)).toList();
        double invStartX = -300;
        double invY = 250;

        for (int i = 0; i < available.length; i++) {
          int h = available[i];
          if (_hitTest(
            pt,
            invStartX + i * 150 - 20,
            invY - h * 30 - 20,
            40,
            h * 30 + 20.0,
          )) {
            setState(() {
              state.activeDragEntity = 's1_c_$h';
              state.dragX = pt.dx;
              state.dragY = pt.dy;
            });
            playSound(tickSound);
            picked = true;
            break;
          }
        }
        if (!picked) {
          double startX = -(5 * 80 + 4 * 20) / 2;
          for (int i = 0; i < 5; i++) {
            if (state.s1Slots[i] != null &&
                _hitTest(pt, startX + i * 100, 80 - 150, 80, 200)) {
              setState(() {
                state.activeDragEntity = 's1_c_${state.s1Slots[i]}';
                state.dragX = pt.dx;
                state.dragY = pt.dy;
                state.s1Slots[i] = null;
                _recalcS1Counts();
              });
              playSound(tickSound);
              picked = true;
              break;
            }
          }
        }
      } else if (state.scenario == 2) {
        List<int?> grid = state.step < 3 ? state.s2Grid3 : state.s2Grid5;
        int len = grid.length;
        double startX = -(len * 90 + (len - 1) * 10) / 2;
        List<int> inv = [
          if (state.step < 3) ...[577, 200, 345] else ...[1, 2, 3, 4, 5],
        ].where((v) => !grid.contains(v)).toList();
        double invStX = state.step < 3 ? -150 : -250;

        for (int i = 0; i < inv.length; i++) {
          if (_hitTest(pt, invStX + i * 110, 100, 80, 80)) {
            setState(() {
              state.activeDragEntity = 's2_b_${inv[i]}';
              state.dragX = pt.dx;
              state.dragY = pt.dy;
            });
            playSound(tickSound);
            picked = true;
            break;
          }
        }
        if (!picked) {
          for (int i = 0; i < len; i++) {
            if (grid[i] != null &&
                _hitTest(pt, startX + i * 100, -100, 90, 90)) {
              setState(() {
                state.activeDragEntity = 's2_b_${grid[i]}';
                state.dragX = pt.dx;
                state.dragY = pt.dy;
                grid[i] = null;
                _recalcS2Supercells();
              });
              playSound(tickSound);
              picked = true;
              break;
            }
          }
        }
      } else if (state.scenario == 3) {
        if (_hitTest(pt, -250, 50, 120, 50)) {
          if (state.s3Input.length != 4) {
            playSound(errorSound); // Ensure feedback on misclick
          } else {
            _triggerS3Process();
          }
          picked = true;
          return;
        }
        if (_hitTest(pt, 130, 50, 120, 50)) {
          if (state.s3Large == null ||
              state.s3Small == null ||
              state.s3Subtracted) {
            playSound(errorSound);
          } else {
            _triggerS3Subtract();
          }
          picked = true;
          return;
        }

        if (state.step == 0) {
          // Explicitly define as List<int?> to support assigning null safely
          List<int?> available = <int?>[6, 3, 8, 2];
          for (var v in state.s3Input) {
            int idx = available.indexOf(v);
            if (idx != -1) available[idx] = null;
          }
          for (int i = 0; i < 4; i++) {
            if (available[i] != null &&
                _hitTest(pt, -100 + i * 50.0, 250, 40, 50)) {
              setState(() {
                state.activeDragEntity = 's3_t_${available[i]}';
                state.dragX = pt.dx;
                state.dragY = pt.dy;
              });
              playSound(tickSound);
              picked = true;
              break;
            }
          }
        } else if (state.step >= 3 && state.s3Res != null) {
          String rStr = state.s3Res!.toString().padLeft(4, '0');
          // Safely initialize as List<String?> so it handles runtime null inserts properly!
          List<String?> available = List<String?>.from(rStr.split(''));
          for (var v in state.s3Input) {
            int idx = available.indexOf(v.toString());
            if (idx != -1) available[idx] = null;
          }
          for (int i = 0; i < 4; i++) {
            if (available[i] != null &&
                _hitTest(pt, -100 + i * 50.0, 250, 40, 50)) {
              setState(() {
                state.activeDragEntity = 's3_t_${available[i]}';
                state.dragX = pt.dx;
                state.dragY = pt.dy;
              });
              playSound(tickSound);
              picked = true;
              break;
            }
          }
        }
      } else if (state.scenario == 4) {
        for (int i = 0; i < 3; i++) {
          if (_hitTest(pt, -200 + i * 150.0, 295, 100, 50)) {
            if (state.s4Turn != 'player') {
              playSound(errorSound);
            } else {
              _triggerS4Play(i + 1);
            }
            picked = true;
          }
        }
        if (state.step >= 2 && _hitTest(pt, -350, -250, 180, 50)) {
          setState(() {
            state.s4PcStart = !state.s4PcStart;
            state.s4Sum = 0;
          });
          playSound(tickSound);
          if (state.s4PcStart) {
            _triggerS4PCTurn();
          } else {
            state.s4Turn = 'player';
          }
          picked = true;
        }
      } else if (state.scenario == 5) {
        if (_hitTest(pt, -220, -200, 100, 60)) {
          if (state.s5Input.isEmpty) {
            playSound(errorSound);
          } else {
            _triggerS5Launch();
          }
          picked = true;
          return;
        }
        List<String> keys = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          'C',
          '0',
          '<',
        ];
        for (int i = 0; i < keys.length; i++) {
          int row = i ~/ 3;
          int col = i % 3;
          if (_hitTest(pt, -400 + col * 55.0, -120 + row * 55.0, 45, 45)) {
            setState(() {
              if (keys[i] == 'C') {
                state.s5Input = "";
              } else if (keys[i] == '<') {
                state.s5Input = state.s5Input.isNotEmpty
                    ? state.s5Input.substring(0, state.s5Input.length - 1)
                    : "";
              } else if (state.s5Input.length < 4) {
                state.s5Input += keys[i];
              }
            });
            playSound(tickSound);
            picked = true;
          }
        }
      }
    }

    if (!picked) {
      setState(() {
        state.activeDragEntity = null;
      });
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = state.zoom;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (state.activeDragEntity != null) {
      Offset pt = _getWorldPoint(details.localFocalPoint);
      setState(() {
        state.dragX = pt.dx;
        state.dragY = pt.dy;
      });
    } else {
      // Seamlessly handle pan and smooth zoom mapping if dragging background
      setState(() {
        if (details.scale != 1.0) {
          state.zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
        }
        state.panX += details.focalPointDelta.dx;
        state.panY += details.focalPointDelta.dy;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (state.activeDragEntity != null) {
      Offset pt = Offset(state.dragX, state.dragY);
      bool dropped = false;

      if (state.activeDragEntity!.startsWith('s1_c_')) {
        int h = int.parse(state.activeDragEntity!.split('_')[2]);
        double startX = -(5 * 80 + 4 * 20) / 2;
        for (int i = 0; i < 5; i++) {
          if (_hitTest(pt, startX + i * 100, 80 - 150, 80, 200)) {
            setState(() {
              state.s1Slots[i] = h;
              dropped = true;
              _recalcS1Counts();
            });
            playSound(snapSound);

            // Flexible robust validation criteria: prevents locks
            bool step0Met = state.s1Slots[2] == 1;
            bool step1Met = state.s1Slots.where((e) => e != null).length >= 3;
            String cStr = state.s1Counts.join(',');

            // Accept either valid sequence configuration based on confusing text goals
            bool step2Met =
                !state.s1Slots.contains(null) &&
                (cStr == '0,1,2,1,0' || cStr == '1,0,2,0,1');

            if (state.step == 0 && step0Met) advanceStep();
            if (state.step == 1 && step1Met) advanceStep();
            if (state.step == 2 && step2Met) {
              advanceStep();
              Future.delayed(const Duration(seconds: 1), checkSuccess);
            } else if (state.step == 2 &&
                !state.s1Slots.contains(null) &&
                !step2Met) {
              playSound(errorSound);
            }
            break;
          }
        }
      } else if (state.activeDragEntity!.startsWith('s2_b_')) {
        int v = int.parse(state.activeDragEntity!.split('_')[2]);
        List<int?> grid = state.step < 3 ? state.s2Grid3 : state.s2Grid5;
        int len = grid.length;
        double startX = -(len * 90 + (len - 1) * 10) / 2;
        for (int i = 0; i < len; i++) {
          if (_hitTest(pt, startX + i * 100, -100, 90, 90) && grid[i] == null) {
            setState(() {
              grid[i] = v;
              dropped = true;
              _recalcS2Supercells();
            });
            playSound(snapSound);

            // Flexible step validation so user doesn't get blocked
            bool s0 = grid[1] == 577;
            bool s1 = grid.where((e) => e != null).length >= 2 && s0;
            bool s2 = grid.where((e) => e != null).length >= 3 && s0;

            if (state.step == 0 && s0) advanceStep();
            if (state.step == 1 && s1) advanceStep();
            if (state.step == 2 && s2) {
              advanceStep();
              playSound(successSound);
            }
            if (state.step == 3 && !grid.contains(null)) {
              if (state.s2Supercells == 3) {
                advanceStep();
                Future.delayed(const Duration(seconds: 1), checkSuccess);
              } else {
                playSound(errorSound);
              }
            }
            break;
          }
        }
      } else if (state.activeDragEntity!.startsWith('s3_t_')) {
        int v = int.parse(state.activeDragEntity!.split('_')[2]);
        if (_hitTest(pt, -150, -200, 300, 100)) {
          setState(() {
            state.s3Input.add(v);
            dropped = true;
          });
          playSound(snapSound);
          if (state.step == 0 && state.s3Input.length == 4) advanceStep();
        }
      }

      if (!dropped) playSound(errorSound);
      setState(() {
        state.activeDragEntity = null;
      });
    }
  }

  // State Logic Helpers
  void _recalcS1Counts() {
    for (int j = 0; j < 5; j++) {
      if (state.s1Slots[j] != null) {
        int c = 0;
        int curr = state.s1Slots[j]!;
        if (j > 0 &&
            state.s1Slots[j - 1] != null &&
            state.s1Slots[j - 1]! > curr) {
          c++;
        }
        if (j < 4 &&
            state.s1Slots[j + 1] != null &&
            state.s1Slots[j + 1]! > curr) {
          c++;
        }
        state.s1Counts[j] = c;
      } else {
        state.s1Counts[j] = 0;
      }
    }
  }

  void _recalcS2Supercells() {
    List<int?> grid = state.step < 3 ? state.s2Grid3 : state.s2Grid5;
    int sc = 0;
    for (int j = 0; j < grid.length; j++) {
      if (grid[j] == null) continue;
      int? l = j > 0 ? grid[j - 1] : null;
      int? r = j < grid.length - 1 ? grid[j + 1] : null;
      if ((l == null || grid[j]! > l) && (r == null || grid[j]! > r)) sc++;
    }
    state.s2Supercells = sc;
  }

  void _triggerS3Process() {
    if (state.s3Input.length != 4) return;
    setState(() {
      state.s3Subtracted = false;
      state.animating = true;
      playSound(tickSound);
      List<int> nums = List.from(state.s3Input);
      nums.sort((a, b) => b.compareTo(a));
      state.s3Large = nums.join('');
      nums.sort((a, b) => a.compareTo(b));
      state.s3Small = nums.join('');
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          state.animating = false;
          playSound(snapSound);
          if (state.step == 1) advanceStep();
        });
      }
    });
  }

  void _triggerS3Subtract() {
    if (state.s3Large == null || state.s3Small == null || state.s3Subtracted) {
      return;
    }
    setState(() {
      state.s3Subtracted = true;
      // Added ultra-safe numeric parsing to avoid edge-case locks
      int largeVal = int.tryParse(state.s3Large!) ?? 0;
      int smallVal = int.tryParse(state.s3Small!) ?? 0;
      state.s3Res = largeVal - smallVal;

      playSound(successSound);
      if (state.step == 2) {
        advanceStep();
      } else if (state.step == 3) {
        advanceStep();
      }

      if (state.s3Res == 6174 && state.step == 4) {
        advanceStep();
        Future.delayed(const Duration(seconds: 1), checkSuccess);
      }
      state.s3Input = [];
    });
  }

  void _triggerS4Play(int val) {
    if (state.animating || state.s4Turn != 'player') return;
    setState(() {
      state.s4Sum += val;
      playSound(snapSound);
    });
    if (state.s4Sum >= 21) {
      _checkS4Win('player');
      return;
    }
    _triggerS4PCTurn();
  }

  void _triggerS4PCTurn() {
    setState(() {
      state.s4Turn = 'pc';
      state.animating = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      List<int> targets = [21, 17, 13, 9, 5, 1];
      int add = 1;
      if (state.s4PcStart && state.s4Sum == 0) {
        add = 2; // Mistake to allow win
      } else {
        for (int t in targets) {
          if (t > state.s4Sum && t - state.s4Sum <= 3) {
            add = t - state.s4Sum;
            break;
          }
        }
      }
      setState(() {
        state.s4Sum += add;
        state.animating = false;
        playSound(tickSound);
      });
      if (state.s4Sum >= 21) {
        _checkS4Win('pc');
      } else {
        setState(() {
          state.s4Turn = 'player';
        });
      }
    });
  }

  void _checkS4Win(String winner) {
    setState(() {
      state.s4Games++;
      state.animating = true;
    });
    if (winner == 'player') {
      playSound(successSound);
      if (state.step == 2 && state.s4PcStart) {
        advanceStep();
        Future.delayed(const Duration(seconds: 1), checkSuccess);
      }
    } else {
      playSound(errorSound);
    }

    if (state.step == 0) advanceStep();
    if (state.step == 1 && state.s4Games > 1) advanceStep();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          state.s4Sum = 0;
          state.animating = false;
          if (state.s4PcStart) {
            _triggerS4PCTurn();
          } else {
            state.s4Turn = 'player';
          }
        });
      }
    });
  }

  void _triggerS5Launch() {
    if (state.animating || state.s5Input.isEmpty) return;
    int n = int.tryParse(state.s5Input) ?? 0;
    if (n <= 1) {
      playSound(errorSound);
      setState(() {
        state.s5Input = "";
      });
      return;
    }

    if (state.step == 0 && n != 12) {
      playSound(errorSound);
      setState(() {
        state.s5Input = "";
      });
      return;
    }
    if (state.step == 0 && n == 12) advanceStep();

    setState(() {
      state.animating = true;
      state.s5History = [n];
      state.s5Num = n;
      state.s5Input = "";
    });

    void loop() {
      if (!mounted) return;
      setState(() {
        state.s5AnimPhase = 0;
        playSound(snapSound);
      });
      Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          state.s5AnimPhase += 0.05;
        });
        if (state.s5AnimPhase >= 1.0) {
          timer.cancel();
          setState(() {
            state.s5Num = (state.s5Num! % 2 == 0)
                ? state.s5Num! ~/ 2
                : state.s5Num! * 3 + 1;
            state.s5History.add(state.s5Num!);
            if (state.step == 1 && state.s5Num! % 2 != 0) {
              advanceStep();
            } else if (state.step == 2 && state.s5Num == 10) {
              advanceStep();
            }
          });
          if (state.s5Num == 1) {
            setState(() {
              state.animating = false;
            });
            playSound(successSound);
            if (state.step == 3) {
              advanceStep();
            } else if (state.step == 4) {
              advanceStep();
              Future.delayed(const Duration(seconds: 1), checkSuccess);
            }
          } else {
            Future.delayed(const Duration(milliseconds: 200), loop);
          }
        }
      });
    }

    loop();
  }

  // UI Building
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: state.sidebarOpen ? state.sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Listener(
                onPointerDown: (event) =>
                    _handlePointerDown(event.localPosition),
                child: GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: Container(
                    key: _canvasKey,
                    color: const Color(0xFF0F172A),
                    child: ClipRect(
                      child: CustomPaint(
                        painter: StrategicArithmeticPainter(
                          state: state,
                          t: tr,
                          time:
                              _gameLoop.value *
                              2 *
                              pi, // use animation for rotation
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: state.sidebarOpen ? 0 : -state.sidebarWidth,
              width: state.sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildSidebarHeader(),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tr(
                                                'selectScenario',
                                              ).toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white54,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _buildScenarioDropdown(),
                                            const SizedBox(height: 20),
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0F172A),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white10,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.track_changes,
                                                        color: Colors.redAccent,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        tr('learnLbl'),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .yellowAccent,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    tr(
                                                      's${state.scenario}_obj',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            _buildStepsList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.white10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '© ZeroScienceLab - Fall in love with math and Science',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white54,
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
                    ),
                    // Resizer
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          state.sidebarWidth =
                              (state.sidebarWidth + details.delta.dx).clamp(
                                300.0,
                                MediaQuery.of(context).size.width * 0.6,
                              );
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(width: 8, color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Menu Button fixed dynamically on screen top left
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                onPressed: () {
                  setState(() {
                    state.sidebarOpen = !state.sidebarOpen;
                    playSound(tickSound);
                  });
                },
                child: Icon(
                  state.sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // HUD overlay (Wrapped in IgnorePointer to avoid intercepting clicks meant for canvas buttons below)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 20,
              left: state.sidebarOpen ? state.sidebarWidth : 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _getCurrentHudText().isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: Colors.indigoAccent, width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.indigoAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _getCurrentHudText(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

            // Success Popup
            if (state.showSuccessPopup)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr('summaryTitle'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.scenario == 5 ? tr('finalDesc') : "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          onPressed: () {
                            if (state.scenario < 5) {
                              loadScenario(state.scenario + 1);
                            } else {
                              setState(() {
                                state.showSuccessPopup = false;
                                state.isCurtainOpen = true;
                              });
                            }
                          },
                          child: Text(
                            state.scenario < 5
                                ? tr('nextScenario')
                                : tr('finishLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Curtain Screen
            if (!state.isCurtainOpen)
              Container(
                color: const Color(0xFF0F172A),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.extension,
                        color: Colors.indigoAccent,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tr('shutterTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            state.isCurtainOpen = true;
                          });
                          playSound(tickSound);
                        },
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          tr('enterLab'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 66,
        bottom: 16,
      ), // Padding to account for the FAB
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
        color: Color(0xFF0F172A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.extension, color: Colors.indigoAccent, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('appTitle'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('appSubtitle'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Language and Reset Buttons positioned under the subtitle
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.withOpacity(0.2),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(
                  Icons.language,
                  size: 16,
                  color: Colors.indigoAccent,
                ),
                label: Text(
                  state.lang.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigoAccent,
                  ),
                ),
                onPressed: toggleLanguage,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  "Reset",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () => loadScenario(state.scenario),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: state.scenario,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int i) {
            return DropdownMenuItem<int>(
              value: i,
              child: Text(
                tr('s${i}_title'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: (int? val) {
            if (val != null) loadScenario(val);
          },
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    int maxSteps = state.scenario == 2
        ? 4
        : (state.scenario == 4 ? 3 : (state.scenario == 1 ? 3 : 5));
    List<Widget> children = [];
    for (int i = 0; i < maxSteps; i++) {
      bool isCurrent = i == state.step;
      bool isDone = i < state.step;

      Color bg = isCurrent
          ? Colors.indigo.withOpacity(0.2)
          : (isDone
                ? Colors.green.withOpacity(0.1)
                : Colors.white.withOpacity(0.05));
      Color border = isCurrent
          ? Colors.indigoAccent
          : (isDone ? Colors.green : Colors.transparent);

      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green
                      : (isCurrent ? Colors.indigoAccent : Colors.white24),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tr('stepLabel')} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('s${state.scenario}_step${i + 1}_task'),
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isDone) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tr('s${state.scenario}_step${i + 1}_out'),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: children);
  }

  String _getCurrentHudText() {
    int maxSteps = state.scenario == 2
        ? 4
        : (state.scenario == 4 ? 3 : (state.scenario == 1 ? 3 : 5));
    if (state.step < maxSteps) {
      return tr('s${state.scenario}_hud${state.step + 1}');
    }
    return "";
  }
}

// --- CUSTOM PAINTER (SCENARIOS 1-5) ---
class StrategicArithmeticPainter extends CustomPainter {
  final GameState state;
  final String Function(String) t;
  final double time;

  StrategicArithmeticPainter({
    required this.state,
    required this.t,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      _renderS1(canvas);
    } else if (state.scenario == 2) {
      _renderS2(canvas);
    } else if (state.scenario == 3) {
      _renderS3(canvas);
    } else if (state.scenario == 4) {
      _renderS4(canvas);
    } else if (state.scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  // --- DRAWING HELPERS ---
  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    double fontSize,
    Color color, {
    bool bold = true,
    TextAlign align = TextAlign.center,
  }) {
    final span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'monospace',
      ),
      text: text,
    );
    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        pos.dx - (align == TextAlign.center ? tp.width / 2 : 0),
        pos.dy - tp.height / 2,
      ),
    );
  }

  void _drawRRect(
    Canvas canvas,
    Rect rect,
    double radius,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (strokeW > 0) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }
  }

  // --- SCENARIO 1 ---
  void _renderS1(Canvas canvas) {
    // Grass
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -1500, 2000, 3000),
      Paint()..color = const Color(0xFF064E3B),
    );
    // Path
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 100, 2000, 1100),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawLine(
      const Offset(-2000, 100),
      const Offset(2000, 100),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 6,
    );

    _drawText(
      canvas,
      t('lbl_s1_target'),
      const Offset(0, -250),
      24,
      Colors.white,
    );
    _drawText(
      canvas,
      t('lbl_s1_current') + state.s1Counts.join(", "),
      const Offset(0, -200),
      20,
      Colors.white,
    );

    double slotW = 80;
    double gap = 20;
    double startX = -(5 * slotW + 4 * gap) / 2;

    void drawChild(double cx, double cy, int hLevel) {
      double h = hLevel * 30.0;
      double w = 40;
      double headR = 15;
      List<Color> colors = [
        Colors.red[300]!,
        Colors.amber[300]!,
        Colors.green[300]!,
        Colors.blue[300]!,
        Colors.purple[300]!,
      ];
      Color c = colors[hLevel - 1];

      _drawRRect(
        canvas,
        Rect.fromLTWH(cx - w / 2, cy - h, w, h),
        10,
        c,
        const Color(0xFF0F172A),
        3,
      );
      canvas.drawCircle(
        Offset(cx, cy - h - headR),
        headR,
        Paint()..color = Colors.amber[100]!,
      );
      canvas.drawCircle(
        Offset(cx, cy - h - headR),
        headR,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        Offset(cx - 5, cy - h - headR - 2),
        2,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        Offset(cx + 5, cy - h - headR - 2),
        2,
        Paint()..color = const Color(0xFF0F172A),
      );
    }

    for (int i = 0; i < 5; i++) {
      double sx = startX + i * (slotW + gap);
      double sy = 80;
      _drawRRect(
        canvas,
        Rect.fromLTWH(sx, sy, slotW, 20),
        10,
        Colors.blueGrey,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        "${t('lbl_s1_slot')} ${i + 1}",
        Offset(sx + slotW / 2, sy + 40),
        16,
        Colors.white,
      );

      if (state.s1Slots[i] != null) {
        drawChild(sx + slotW / 2, sy, state.s1Slots[i]!);
        _drawRRect(
          canvas,
          Rect.fromLTWH(
            sx + slotW / 2 - 15,
            sy - (state.s1Slots[i]! * 30) - 70,
            30,
            30,
          ),
          15,
          Colors.white,
          const Color(0xFF0F172A),
          3,
        );
        _drawText(
          canvas,
          state.s1Counts[i].toString(),
          Offset(sx + slotW / 2, sy - (state.s1Slots[i]! * 30) - 55),
          18,
          Colors.black,
        );
      }
    }

    // Lines
    for (int i = 0; i < 5; i++) {
      int? curr = state.s1Slots[i];
      if (curr == null) continue;
      double sx1 = startX + i * (slotW + gap) + slotW / 2;
      double sy1 = 80 - curr * 30 - 30;
      int left = i > 0 ? state.s1Slots[i - 1] ?? 0 : 0;
      int right = i < 4 ? state.s1Slots[i + 1] ?? 0 : 0;

      if (left > curr) {
        double sx2 = startX + (i - 1) * (slotW + gap) + slotW / 2;
        double sy2 = 80 - left * 30 - 30;
        canvas.drawLine(
          Offset(sx1, sy1),
          Offset(sx2, sy2),
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 3,
        );
      }
      if (right > curr) {
        double sx2 = startX + (i + 1) * (slotW + gap) + slotW / 2;
        double sy2 = 80 - right * 30 - 30;
        canvas.drawLine(
          Offset(sx1, sy1),
          Offset(sx2, sy2),
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 3,
        );
      }
    }

    // Inventory
    List<int> available = [
      1,
      2,
      3,
      4,
      5,
    ].where((h) => !state.s1Slots.contains(h)).toList();
    for (int i = 0; i < available.length; i++) {
      drawChild(-300 + i * 150.0, 250, available[i]);
    }

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('s1_c_')) {
      int h = int.parse(state.activeDragEntity!.split('_')[2]);
      drawChild(state.dragX, state.dragY + (h * 30), h);
    }
  }

  // --- SCENARIO 2 ---
  void _renderS2(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -1500, 2000, 3000),
      Paint()..color = const Color(0xFF1E293B),
    );

    void drawBlock(int val, double x, double y, bool isSuper) {
      if (isSuper) {
        canvas.drawShadow(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, 80, 80),
              const Radius.circular(8),
            ),
          ),
          Colors.lightBlueAccent,
          20,
          true,
        );
      }
      _drawRRect(
        canvas,
        Rect.fromLTWH(x, y, 80, 80),
        8,
        isSuper ? Colors.lightBlue[100]! : Colors.blueGrey[200]!,
        isSuper ? Colors.lightBlue[700]! : const Color(0xFF0F172A),
        isSuper ? 5 : 3,
      );
      _drawText(
        canvas,
        val.toString(),
        Offset(x + 40, y + 40),
        24,
        Colors.black,
      );
    }

    void drawGrid(List<int?> grid) {
      int len = grid.length;
      double startX = -(len * 90 + (len - 1) * 10) / 2;
      for (int i = 0; i < len; i++) {
        double px = startX + i * 100;
        _drawRRect(
          canvas,
          Rect.fromLTWH(px, -100, 90, 90),
          10,
          const Color(0xFF334155),
          const Color(0xFF0F172A),
          4,
        );
        if (grid[i] != null) {
          int? l = i > 0 ? grid[i - 1] : null;
          int? r = i < len - 1 ? grid[i + 1] : null;
          bool isSuper =
              (l == null || grid[i]! > l) && (r == null || grid[i]! > r);
          drawBlock(grid[i]!, px + 5, -95, isSuper && (l != null || r != null));
        }
      }
    }

    if (state.step < 3) {
      drawGrid(state.s2Grid3);
      List<int> inv = [
        577,
        200,
        345,
      ].where((v) => !state.s2Grid3.contains(v)).toList();
      for (int i = 0; i < inv.length; i++) {
        drawBlock(inv[i], -150 + i * 110.0, 100, false);
      }
    } else {
      drawGrid(state.s2Grid5);
      List<int> inv = [
        1,
        2,
        3,
        4,
        5,
      ].where((v) => !state.s2Grid5.contains(v)).toList();
      for (int i = 0; i < inv.length; i++) {
        drawBlock(inv[i], -250 + i * 110.0, 100, false);
      }
      _drawText(
        canvas,
        "${t('lbl_s2Supercells')} ${state.s2Supercells} / 3",
        const Offset(0, -160),
        24,
        Colors.white,
      );
    }

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('s2_b_')) {
      int v = int.parse(state.activeDragEntity!.split('_')[2]);
      drawBlock(v, state.dragX - 40, state.dragY - 40, false);
    }
  }

  // --- SCENARIO 3 ---
  void _renderS3(Canvas canvas) {
    void drawGear(double x, double y, double r, int teeth, double rot) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      Path p = Path();
      for (int i = 0; i < teeth; i++) {
        double a1 = (i / teeth) * pi * 2;
        double a2 = ((i + 0.5) / teeth) * pi * 2;
        p.lineTo(cos(a1) * r, sin(a1) * r);
        p.lineTo(cos(a1) * (r + 10), sin(a1) * (r + 10));
        p.lineTo(cos(a2) * (r + 10), sin(a2) * (r + 10));
        p.lineTo(cos(a2) * r, sin(a2) * r);
      }
      p.close();
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.blueGrey
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        Offset.zero,
        r / 2,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.restore();
    }

    double rot = state.animating ? time * 2 : 0;
    drawGear(-150, -50, 40, 8, rot);
    drawGear(150, 0, 50, 10, -rot * 0.8);

    // Machine
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-200, -100, 400, 300),
      20,
      Colors.amber[700]!,
      const Color(0xFF0F172A),
      6,
    );
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-160, -60, 320, 220),
      10,
      Colors.white,
      const Color(0xFF0F172A),
      4,
    );

    // Funnel
    Path f = Path()
      ..moveTo(-100, -100)
      ..lineTo(-150, -200)
      ..lineTo(150, -200)
      ..lineTo(100, -100)
      ..close();
    canvas.drawPath(f, Paint()..color = Colors.blueGrey[300]!);
    canvas.drawPath(
      f,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    _drawText(
      canvas,
      t('lbl_s3Input'),
      const Offset(0, -150),
      20,
      Colors.black,
    );

    // Displays
    for (int i = 0; i < 3; i++) {
      _drawRRect(
        canvas,
        Rect.fromLTWH(-140, -40 + i * 60.0, 280, 50),
        5,
        Colors.blueGrey[100]!,
        const Color(0xFF0F172A),
        2,
      );
    }
    _drawText(
      canvas,
      "${t('lbl_s3Large')}: ${state.s3Large ?? ''}",
      const Offset(0, -15),
      24,
      Colors.black,
    );
    _drawText(
      canvas,
      "${t('lbl_s3Small')}: ${state.s3Small ?? ''}",
      const Offset(0, 45),
      24,
      Colors.black,
    );
    _drawText(
      canvas,
      "${t('lbl_s3Res')}: ${state.s3Res ?? ''}",
      const Offset(0, 105),
      24,
      Colors.red,
    );

    // Buttons
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-250, 50, 120, 50),
      10,
      state.step == 1 ? Colors.green : Colors.blueGrey,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      t('lbl_s3_process'),
      const Offset(-190, 75),
      16,
      Colors.white,
    );
    _drawRRect(
      canvas,
      const Rect.fromLTWH(130, 50, 120, 50),
      10,
      (state.step == 2 || state.step == 4) ? Colors.red : Colors.blueGrey,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, t('lbl_s3_sub'), const Offset(190, 75), 16, Colors.white);

    void drawTile(String v, double x, double y) {
      _drawRRect(
        canvas,
        Rect.fromLTWH(x, y, 40, 50),
        5,
        Colors.yellow[200]!,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, v, Offset(x + 20, y + 25), 24, Colors.black);
    }

    if (state.step == 0) {
      // Initialize gracefully mapped to typed array
      List<int?> av = <int?>[6, 3, 8, 2];
      for (var v in state.s3Input) {
        int idx = av.indexOf(v);
        if (idx != -1) av[idx] = null;
      }
      for (int i = 0; i < 4; i++) {
        if (av[i] != null) drawTile(av[i].toString(), -100 + i * 50.0, 250);
      }
    } else if (state.step >= 3 && state.s3Res != null && state.step != 5) {
      // Extract gracefully handling generic boundaries and explicitly mapping values
      List<String?> av = List<String?>.from(
        state.s3Res!.toString().padLeft(4, '0').split(''),
      );
      for (var v in state.s3Input) {
        int idx = av.indexOf(v.toString());
        if (idx != -1) av[idx] = null;
      }
      for (int i = 0; i < 4; i++) {
        if (av[i] != null) drawTile(av[i]!, -100 + i * 50.0, 250);
      }
    }

    for (int i = 0; i < state.s3Input.length; i++) {
      drawTile(state.s3Input[i].toString(), -80 + i * 40.0, -180);
    }

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('s3_t_')) {
      drawTile(
        state.activeDragEntity!.split('_')[2],
        state.dragX - 20,
        state.dragY - 25,
      );
    }
  }

  // --- SCENARIO 4 ---
  void _renderS4(Canvas canvas) {
    Path p = Path()
      ..moveTo(-300, -150)
      ..quadraticBezierTo(0, -150, 150, -50)
      ..quadraticBezierTo(300, 50, 0, 150)
      ..quadraticBezierTo(-300, 250, 300, 250);
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round,
    );

    Offset getPt(int i) {
      double p = i / 21;
      if (p < 0.33) {
        return Offset(-300 + (p / 0.33) * 450, -150 + (p / 0.33) * 100);
      } else if (p < 0.66) {
        return Offset(
          150 - ((p - 0.33) / 0.33) * 150,
          -50 + ((p - 0.33) / 0.33) * 200,
        );
      } else {
        return Offset(
          ((p - 0.66) / 0.34) * 300,
          150 + ((p - 0.66) / 0.34) * 100,
        );
      }
    }

    for (int i = 1; i <= 21; i++) {
      Offset pt = getPt(i);
      bool safe = [1, 5, 9, 13, 17].contains(i);
      Color c = i <= state.s4Sum ? Colors.blue : Colors.blueGrey;
      if (i == 21) c = Colors.amber;
      if (safe && state.step >= 2) {
        canvas.drawShadow(
          Path()..addOval(Rect.fromCircle(center: pt, radius: 20)),
          Colors.green,
          15,
          true,
        );
        c = Colors.greenAccent;
      }
      _drawRRect(
        canvas,
        Rect.fromCircle(center: pt, radius: 20),
        20,
        c,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, i.toString(), pt, 16, Colors.black);
    }

    _drawText(
      canvas,
      "${t('lbl_s4Sum')} ${state.s4Sum} / 21",
      const Offset(0, -250),
      32,
      Colors.white,
    );

    bool canPlay = state.s4Turn == 'player' && !state.animating;
    for (int i = 1; i <= 3; i++) {
      _drawRRect(
        canvas,
        Rect.fromLTWH(-150 + (i - 1) * 150.0 - 50, 320 - 25, 100, 50),
        10,
        canPlay ? Colors.blue : Colors.blueGrey,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(
        canvas,
        "+$i",
        Offset(-150 + (i - 1) * 150.0, 320),
        24,
        Colors.white,
      );
    }

    if (state.step >= 2) {
      _drawRRect(
        canvas,
        const Rect.fromLTWH(-350, -250, 180, 50),
        10,
        state.s4PcStart ? Colors.green : Colors.blueGrey,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        t('lbl_s4Pcstart'),
        const Offset(-260, -225),
        16,
        Colors.white,
      );
    }
  }

  // --- SCENARIO 5 ---
  void _renderS5(Canvas canvas) {
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-420, -200, 180, 60),
      10,
      Colors.white,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      state.s5Input.isEmpty ? "0" : state.s5Input,
      const Offset(-330, -170),
      32,
      Colors.black,
    );
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-220, -200, 100, 60),
      10,
      Colors.redAccent,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      t('lbl_s5_launch'),
      const Offset(-170, -170),
      18,
      Colors.white,
    );

    List<String> keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'C',
      '0',
      '<',
    ];
    for (int i = 0; i < keys.length; i++) {
      int row = i ~/ 3;
      int col = i % 3;
      double kx = -400 + col * 55.0;
      double ky = -120 + row * 55.0;
      _drawRRect(
        canvas,
        Rect.fromLTWH(kx, ky, 45, 45),
        8,
        const Color(0xFF334155),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        keys[i],
        Offset(kx + 22.5, ky + 22.5),
        20,
        Colors.white,
      );
    }

    canvas.drawPath(
      Path()
        ..moveTo(-50, -100)
        ..quadraticBezierTo(-180, 0, -50, 150),
      Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      t('lbl_s5_even'),
      const Offset(-170, 20),
      14,
      Colors.lightBlueAccent,
    );
    canvas.drawPath(
      Path()
        ..moveTo(50, -100)
        ..quadraticBezierTo(180, 0, 50, 150),
      Paint()
        ..color = Colors.pinkAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      t('lbl_s5_odd'),
      const Offset(170, 20),
      14,
      Colors.pinkAccent,
    );

    _drawRRect(
      canvas,
      const Rect.fromLTWH(-100, -150, 200, 50),
      10,
      Colors.blueGrey,
      const Color(0xFF0F172A),
      4,
    );
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-100, 150, 200, 50),
      10,
      Colors.blueGrey,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      "${t('lbl_s5_seq')} ${state.s5History.join(" → ")}",
      const Offset(0, 250),
      16,
      Colors.white,
    );

    if (state.animating && state.s5Num != null) {
      double p = state.s5AnimPhase;
      double x, y;
      if (state.s5Num! % 2 == 0) {
        x = -50 + sin(p * pi) * (-90);
        y = -100 + p * 250;
      } else {
        x = 50 + sin(p * pi) * (90);
        y = -100 + p * 250;
      }
      _drawRRect(
        canvas,
        Rect.fromCircle(center: Offset(x, y), radius: 20),
        20,
        Colors.amber,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, state.s5Num.toString(), Offset(x, y), 18, Colors.black);
    }

    _drawRRect(
      canvas,
      const Rect.fromLTWH(200, 50, 100, 100),
      10,
      Colors.white24,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      t('lbl_s5_bin'),
      const Offset(250, 160),
      14,
      Colors.white,
    );
    if (state.s5History.contains(1)) {
      for (int i = 0; i < 5; i++) {
        _drawRRect(
          canvas,
          Rect.fromLTWH(210 + i * 15.0, 120 - i * 5.0, 20, 20),
          10,
          Colors.amber,
          const Color(0xFF0F172A),
          2,
        );
        _drawText(
          canvas,
          "1",
          Offset(220 + i * 15.0, 130 - i * 5.0),
          12,
          Colors.black,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant StrategicArithmeticPainter oldDelegate) => true;
}
