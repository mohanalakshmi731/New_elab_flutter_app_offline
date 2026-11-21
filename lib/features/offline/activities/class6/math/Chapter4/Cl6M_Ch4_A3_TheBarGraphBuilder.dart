// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Bar Graph Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch4_A3_TheBarGraphBuilder(),
    ),
  );
}

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  // 1. Play standard click
  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // 2. Play a sound when a new page opens (Swoosh/Chime)
  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // 3. Play the Dropdown sound
  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // 4. Play an error sound (Soft thud)
  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // 5. Curtain opener sound
  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- TRANSLATIONS ---
final Map<String, Map<String, String>> tMap = {
  'en': {
    'shutterTitle': "The Bar Graph Builder",
    'appSubtitle': "Class 6 • Data Handling",
    'enterLab': "Enter Simulation",
    'appTitle': "The Bar Graph Builder",
    'selectScenario': "Select Scenario",
    'learnLbl': "Objective:",
    'stepLabel': "STEP",
    'nextScenario': "Next Scenario",
    'finishLab': "Finish Lab",
    'summaryTitle': "Goal Reached!",
    'finalDesc':
        "You have successfully learned how to build and read Bar Graphs!",

    's1_title': "1. The Fruit Sorter",
    's1_obj':
        "To understand the direct 1-to-1 relationship between a physical object and the height of a bar.",
    's1_step1_task':
        "DRAG the first apple from the belt into the 'Apples' bin.",
    's1_step1_out': "The bar above 'Apples' grows by one unit.",
    's1_step2_task': "DRAG the banana from the belt into the 'Bananas' bin.",
    's1_step2_out': "The bar above 'Bananas' grows to the '1' mark.",
    's1_step3_task': "DRAG all remaining fruits into their bins.",
    's1_step3_out': "Each drop makes the bar grow by one unit.",
    's1_step4_task': "CLICK on the tallest bar in the graph.",
    's1_step4_out': "The tallest bar shows the biggest amount!",
    's1_hud1': "Drag an Apple to its bin.",
    's1_hud2': "Drag a Banana to its bin.",
    's1_hud3': "Sort remaining fruits.",
    's1_hud4': "Click tallest bar.",
    'lbl_apples': "Apples",
    'lbl_bananas': "Bananas",
    'lbl_oranges': "Oranges",

    's2_title': "2. The Absentee Graph",
    's2_obj':
        "Learn to read values from a bar graph and understand axes/scale.",
    's2_step1_task':
        "How many students absent in Class II? CLICK top of 'Class II' bar.",
    's2_step1_out': "Connects to number 5 on vertical axis.",
    's2_step2_task': "Which class had most absentees? CLICK the tallest bar.",
    's2_step2_out': "Class VIII is tallest.",
    's2_step3_task':
        "Which class had zero absent? CLICK the label with no bar.",
    's2_step3_out': "Class V has no bar!",
    's2_hud1': "Click top of Class II bar.",
    's2_hud2': "Click tallest bar.",
    's2_hud3': "Click label of class with no bar.",
    'lbl_s2_title': "Absent Students per Class",
    'lbl_s2_xaxis': "Classes",
    'lbl_s2_yaxis': "No. of Students",

    's3_title': "3. The Big Order of Sweets",
    's3_obj': "Understand scale, where one unit represents more than one item.",
    's3_step1_task': "Scale is '1 block=10'. DRAG 10-crate to graph.",
    's3_step1_out': "Bar grows to '10'.",
    's3_step2_task': "DRAG another crate to same spot.",
    's3_step2_out': "Bar grows to '20'.",
    's3_step3_task': "DRAG final crate to reach 30.",
    's3_step3_out': "Making each block worth 10 lets us show large numbers!",
    's3_hud1': "Drag 1 crate to graph.",
    's3_hud2': "Drag another crate.",
    's3_hud3': "Drag last crate to reach 30.",
    'lbl_s3_scale': "Scale: 1 block = 10",
    'lbl_gj': "Gulab Jamun",

    's4_title': "4. Build Traffic Graph",
    's4_obj': "Construct a bar graph from a raw list, set scale, build bars.",
    's4_step1_task':
        "12 Bikes, 8 Cars, 4 Buses. DRAG labels to horizontal axis.",
    's4_step1_out': "Labels snap on X-axis.",
    's4_step2_task': "Choose best scale. CLICK a scale button.",
    's4_step2_out': "1 block = 2 vehicles chosen.",
    's4_step3_task': "CLICK '+' under Bike to reach 12.",
    's4_step3_out': "Bike bar rises to '12'.",
    's4_step4_task': "Build bars for Car (8) and Bus (4).",
    's4_step4_out': "Bars grow to correct heights.",
    's4_step5_task': "CLICK 'Check My Graph'.",
    's4_step5_out': "Perfect Graph!",
    's4_hud1': "Drag labels to axis.",
    's4_hud2': "Click '1 block = 2'.",
    's4_hud3': "Click '+' under Bike to 12.",
    's4_hud4': "Click '+' to Car 8, Bus 4.",
    's4_hud5': "Click Check.",
    'lbl_bikes': "Bikes",
    'lbl_cars': "Cars",
    'lbl_buses': "Buses",
    'lbl_buss': "Buses",
    'lbl_check': "Check Graph",
    'lbl_scale_sel': "Select Scale:",

    's5_title': "5. Tiger Population",
    's5_obj':
        "Identify appropriate scale for large numbers and construct graph.",
    's5_step1_task':
        "2010(1700), 2014(2200), 2018(3000). DRAG 'Year' labels to axis.",
    's5_step1_out': "Year labels placed.",
    's5_step2_task': "CLICK scale '1 block = 500'.",
    's5_step2_out': "Axis populates 500, 1000...",
    's5_step3_task': "Build 2010 bar (1700). CLICK '+' to add.",
    's5_step3_out': "Height adjusts to 1700.",
    's5_step4_task': "Build bars for 2014 (2200) and 2018 (3000).",
    's5_step4_out': "Bars grow to proper heights.",
    's5_step5_task': "CLICK 'Check My Graph'.",
    's5_step5_out': "Well done!",
    's5_hud1': "Drag years to axis.",
    's5_hud2': "Click '1 block = 500'.",
    's5_hud3': "Click '+' under 2010 to 1700.",
    's5_hud4': "Click '+' to 2014(2200), 2018(3000).",
    's5_hud5': "Click Check.",
    'lbl_y2010': "2010",
    'lbl_y2014': "2014",
    'lbl_y2018': "2018",
  },
  'hi': {
    'shutterTitle': "बार ग्राफ बिल्डर",
    'appSubtitle': "कक्षा 6 • डेटा हैंडलिंग",
    'enterLab': "सिमुलेशन दर्ज करें",
    'appTitle': "बार ग्राफ बिल्डर",
    'selectScenario': "परिदृश्य चुनें",
    'learnLbl': "परिणाम:",
    'stepLabel': "चरण",
    'nextScenario': "अगला परिदृश्य",
    'finishLab': "समाप्त करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finalDesc': "आपने बार ग्राफ बनाना और पढ़ना सीख लिया है!",

    's1_title': "1. फल छांटने वाला",
    's1_obj': "भौतिक वस्तु और ग्राफ की ऊंचाई के बीच संबंध को समझना।",
    's1_step1_task': "बेल्ट से सेब खींचें और 'सेब' बिन में डालें।",
    's1_step1_out': "बार ऊंचाई में 1 इकाई बढ़ता है।",
    's1_step2_task': "केला खींचें और 'केले' बिन में डालें।",
    's1_step2_out': "बार 1 के निशान तक बढ़ता है।",
    's1_step3_task': "सभी शेष फलों को खींचें और डालें।",
    's1_step3_out': "प्रत्येक फल से बार बढ़ता है।",
    's1_step4_task': "सबसे ऊंचे बार पर क्लिक करें।",
    's1_step4_out': "सबसे ऊंचा बार सबसे बड़ी मात्रा दिखाता है!",
    's1_hud1': "सेब को बिन में खींचें।",
    's1_hud2': "केले को बिन में खींचें।",
    's1_hud3': "बाकी फलों को छांटें।",
    's1_hud4': "सबसे ऊंचे बार पर क्लिक करें।",
    'lbl_apples': "सेब",
    'lbl_bananas': "केले",
    'lbl_oranges': "संतरे",

    's2_title': "2. अनुपस्थित छात्रों का ग्राफ",
    's2_obj': "बार ग्राफ से मान पढ़ना सीखें।",
    's2_step1_task':
        "कक्षा II में कितने अनुपस्थित थे? 'कक्षा II' बार पर क्लिक करें।",
    's2_step1_out': "रेखा संख्या 5 से जुड़ती है।",
    's2_step2_task':
        "किस कक्षा में सबसे अधिक अनुपस्थित थे? सबसे ऊंचे बार पर क्लिक करें।",
    's2_step2_out': "कक्षा VIII सबसे ऊंची है।",
    's2_step3_task':
        "किसमें शून्य अनुपस्थित थे? बिना बार वाले लेबल पर क्लिक करें।",
    's2_step3_out': "कक्षा V में कोई बार नहीं है!",
    's2_hud1': "कक्षा II बार पर क्लिक करें।",
    's2_hud2': "सबसे ऊंचे बार पर क्लिक करें।",
    's2_hud3': "बिना बार वाली कक्षा पर क्लिक करें।",
    'lbl_s2_title': "प्रति कक्षा अनुपस्थित छात्र",
    'lbl_s2_xaxis': "कक्षाएं",
    'lbl_s2_yaxis': "छात्रों की संख्या",

    's3_title': "3. मिठाइयों का बड़ा ऑर्डर",
    's3_obj': "पैमाने की अवधारणा समझें।",
    's3_step1_task': "पैमाना '1 ब्लॉक = 10' है। क्रेट ग्राफ पर खींचें।",
    's3_step1_out': "बार '10' तक बढ़ता है।",
    's3_step2_task': "एक और क्रेट खींचें।",
    's3_step2_out': "बार '20' तक बढ़ता है।",
    's3_step3_task': "30 तक पहुंचने के लिए अंतिम क्रेट खींचें।",
    's3_step3_out':
        "ब्लॉक को 10 के बराबर रखने से बड़ी संख्याएँ दिखाना आसान होता है!",
    's3_hud1': "1 क्रेट ग्राफ पर खींचें।",
    's3_hud2': "एक और क्रेट खींचें।",
    's3_hud3': "30 तक अंतिम क्रेट खींचें।",
    'lbl_s3_scale': "पैमाना: 1 ब्लॉक = 10",
    'lbl_gj': "गुलाब जामुन",

    's4_title': "4. ट्रैफिक ग्राफ बनाएं",
    's4_obj': "डेटा सूची से एक पूरा बार ग्राफ बनाएं।",
    's4_step1_task': "12 बाइक, 8 कारें, 4 बसें। लेबल क्षैतिज अक्ष पर खींचें।",
    's4_step1_out': "लेबल जगह पर आते हैं।",
    's4_step2_task': "स्केल बटन पर क्लिक करें।",
    's4_step2_out': "1 ब्लॉक = 2 चुना गया।",
    's4_step3_task': "'बाइक' बार को 12 तक बढ़ाने के लिए '+' पर क्लिक करें।",
    's4_step3_out': "बार 12 तक बढ़ता है।",
    's4_step4_task': "'कार' (8) और 'बस' (4) के लिए बार बनाएं।",
    's4_step4_out': "बार सही ऊंचाई तक बढ़ते हैं।",
    's4_step5_task': "'मेरा ग्राफ जांचें' पर क्लिक करें।",
    's4_step5_out': "परफेक्ट ग्राफ!",
    's4_hud1': "लेबल अक्ष पर खींचें।",
    's4_hud2': "'1 ब्लॉक = 2' पर क्लिक करें।",
    's4_hud3': "बाइक के नीचे '+' 12 तक।",
    's4_hud4': "कार 8 और बस 4 तक '+' करें।",
    's4_hud5': "जांचें पर क्लिक करें।",
    'lbl_bikes': "बाइक",
    'lbl_cars': "कार",
    'lbl_buses': "बस",
    'lbl_check': "ग्राफ जांचें",
    'lbl_scale_sel': "पैमाना चुनें:",

    's5_title': "5. बाघ जनसंख्या परियोजना",
    's5_obj': "बड़ी संख्याओं के लिए पैमाना पहचानें और ग्राफ बनाएं।",
    's5_step1_task': "2010(1700), 2014(2200), 2018(3000)। वर्ष लेबल खींचें।",
    's5_step1_out': "वर्ष लेबल रखे गए हैं।",
    's5_step2_task': "स्केल '1 ब्लॉक = 500' पर क्लिक करें।",
    's5_step2_out': "अक्ष भर जाता है।",
    's5_step3_task': "2010 के लिए बार बनाएं। '+' पर क्लिक करें।",
    's5_step3_out': "बार 1700 पर समायोजित होता है।",
    's5_step4_task': "2014 (2200) और 2018 (3000) के लिए बार बनाएं।",
    's5_step4_out': "बार उचित ऊंचाई तक बढ़ते हैं।",
    's5_step5_task': "'जांचें' बटन पर क्लिक करें।",
    's5_step5_out': "बहुत बढ़िया!",
    's5_hud1': "वर्ष लेबल अक्ष पर खींचें।",
    's5_hud2': "'1 ब्लॉक = 500' पर क्लिक करें।",
    's5_hud3': "2010 के नीचे '+' 1700 तक।",
    's5_hud4': "2014(2200) और 2018(3000) तक '+'।",
    's5_hud5': "जांचें पर क्लिक करें।",
    'lbl_y2010': "2010",
    'lbl_y2014': "2014",
    'lbl_y2018': "2018",
  },
};

String t(String lang, String key) =>
    tMap[lang]?[key] ?? tMap['en']?[key] ?? key;

// --- STATE MANAGEMENT ---
class Fruit {
  final int id;
  final String type;
  double x, y;
  Fruit(this.id, this.type, this.x, this.y);
}

class AppState {
  String lang = 'en';
  int scenario = 1;
  int step = 0;
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  String? activeDragEntity;
  double dragX = 0;
  double dragY = 0;

  // S1
  List<Fruit> s1Belt = [];
  Map<String, int> s1Bins = {'apple': 0, 'banana': 0, 'orange': 0};

  // S2
  bool s2C2Clicked = false;
  bool s2TallClicked = false;
  bool s2ZeroClicked = false;

  // S3
  int s3Crates = 0;

  // S4
  Map<String, bool> s4Labels = {'bike': false, 'car': false, 'bus': false};
  int? s4Scale;
  Map<String, int> s4Bars = {'bike': 0, 'car': 0, 'bus': 0};
  bool s4Checked = false;

  // S5
  Map<String, bool> s5Labels = {'y2010': false, 'y2014': false, 'y2018': false};
  int? s5Scale;
  Map<String, int> s5Bars = {'y2010': 0, 'y2014': 0, 'y2018': 0};
  bool s5Checked = false;

  bool isScenarioComplete(int id) {
    if (id == 1) return step >= 4;
    if (id == 2) return step >= 3;
    if (id == 3) return step >= 3;
    if (id == 4) return step >= 5;
    if (id == 5) return step >= 5;
    return false;
  }
}

// --- APP CONTROLLER ---
class Cl6M_Ch4_A3_TheBarGraphBuilder extends StatefulWidget {
  const Cl6M_Ch4_A3_TheBarGraphBuilder({super.key});
  @override
  State<Cl6M_Ch4_A3_TheBarGraphBuilder> createState() =>
      _Cl6M_Ch4_A3_TheBarGraphBuilderState();
}

class _Cl6M_Ch4_A3_TheBarGraphBuilderState
    extends State<Cl6M_Ch4_A3_TheBarGraphBuilder>
    with TickerProviderStateMixin {
  bool inCurtain = true;
  late AnimationController _pulseController;
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initScenario(1);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _initScenario(int id) {
    state.scenario = id;
    state.step = 0;
    state.activeDragEntity = null;
    state.zoom = 1.0;
    state.panX = 0;
    state.panY = 0;

    if (id == 1) {
      state.s1Bins = {'apple': 0, 'banana': 0, 'orange': 0};
      state.s1Belt.clear();
      List<String> fruits = [
        'apple',
        'apple',
        'apple',
        'apple',
        'apple',
        'banana',
        'banana',
        'banana',
        'orange',
        'orange',
        'orange',
        'orange',
      ];
      for (int i = 0; i < fruits.length; i++) {
        state.s1Belt.add(Fruit(i, fruits[i], -280.0 + i * 50, -200.0));
      }
    } else if (id == 2) {
      state.s2C2Clicked = false;
      state.s2TallClicked = false;
      state.s2ZeroClicked = false;
    } else if (id == 3) {
      state.s3Crates = 0;
    } else if (id == 4) {
      state.s4Labels = {'bike': false, 'car': false, 'bus': false};
      state.s4Scale = null;
      state.s4Bars = {'bike': 0, 'car': 0, 'bus': 0};
      state.s4Checked = false;
    } else if (id == 5) {
      state.s5Labels = {'y2010': false, 'y2014': false, 'y2018': false};
      state.s5Scale = null;
      state.s5Bars = {'y2010': 0, 'y2014': 0, 'y2018': 0};
      state.s5Checked = false;
    }
    setState(() {});
  }

  void _enterLab() {
    AudioEngine.curtainScreen();
    setState(() => inCurtain = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: inCurtain
            ? _buildCurtain()
            : LabScreen(
                state: state,
                onStateChanged: () => setState(() {}),
                onLoadScenario: _initScenario,
                onReset: () {
                  AudioEngine.playDropdown();
                  setState(() => inCurtain = true);
                  _initScenario(1);
                  state.sidebarWidth = 350.0;
                },
              ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.05),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 80,
                    color: Color(0xFF6366F1),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            t(state.lang, 'shutterTitle'),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t(state.lang, 'appSubtitle'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill, size: 28),
            label: Text(
              t(state.lang, 'enterLab'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 10,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
            ),
            onPressed: _enterLab,
          ),
        ],
      ),
    );
  }
}

// --- MAIN LAB SCREEN ---
class LabScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onStateChanged;
  final Function(int) onLoadScenario;
  final VoidCallback onReset;

  const LabScreen({
    super.key,
    required this.state,
    required this.onStateChanged,
    required this.onLoadScenario,
    required this.onReset,
  });

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gameLoop;
  final GlobalKey _canvasKey = GlobalKey();

  bool _allowPanZoom = true;
  double _initialZoom = 1.0;
  Offset _initialPan = Offset.zero;
  Offset _initialLocalFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.state.activeDragEntity != null) return;
    if (_canvasKey.currentContext == null) return;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(event.position);

    double cx = box.size.width / 2 + widget.state.panX;
    double cy = box.size.height / 2 + widget.state.panY;
    double worldX = (localPos.dx - cx) / widget.state.zoom;
    double worldY = (localPos.dy - cy) / widget.state.zoom;
    Offset pt = Offset(worldX, worldY);

    AppState s = widget.state;
    _allowPanZoom = true;

    // 1. CHECK INSTANT CLICKABLES
    if (s.scenario == 1) {
      if (s.step == 3 && _hitBox(pt, -130, 50, 60, 150)) {
        _allowPanZoom = false;
        _advance();
        return;
      }
    } else if (s.scenario == 2) {
      if (s.step == 0 && _hitBox(pt, -225, -150, 75, 300)) {
        s.s2C2Clicked = true;
        _allowPanZoom = false;
        _advance();
        return;
      } else if (s.step == 1 && _hitBox(pt, 225, -150, 75, 300)) {
        s.s2TallClicked = true;
        _allowPanZoom = false;
        _advance();
        return;
      } else if (s.step == 2 && _hitBox(pt, 0, 150, 75, 40)) {
        s.s2ZeroClicked = true;
        _allowPanZoom = false;
        _advance();
        _checkComplete();
        return;
      }
    } else if (s.scenario == 4) {
      if (s.step == 1) {
        List<int> vals = [1, 2, 5];
        for (int i = 0; i < 3; i++) {
          if (_hitBox(pt, -330, 50.0 + i * 45, 140, 35)) {
            _allowPanZoom = false;
            if (vals[i] == 2) {
              s.s4Scale = 2;
              _advance();
            } else {
              AudioEngine.playError();
            }
            widget.onStateChanged();
            return;
          }
        }
      } else if (s.step >= 2 && !s.s4Checked) {
        List<String> cats = ['bike', 'car', 'bus'];
        for (int i = 0; i < 3; i++) {
          double bx = -100.0 + i * 150.0 + 25;
          if (_hitBox(pt, bx + 30, 145, 40, 40)) {
            _allowPanZoom = false;
            s.s4Bars[cats[i]] = math.min(12, s.s4Bars[cats[i]]! + 2);
            AudioEngine.playClick();
            if (s.step == 2 && cats[i] == 'bike' && s.s4Bars['bike'] == 12) {
              _advance();
            }
            if (s.step == 3 && s.s4Bars['car'] == 8 && s.s4Bars['bus'] == 4) {
              _advance();
            }
            widget.onStateChanged();
            return;
          }
        }
        if (_hitBox(pt, 390, 50, 160, 50)) {
          _allowPanZoom = false;
          if (s.s4Bars['bike'] == 12 &&
              s.s4Bars['car'] == 8 &&
              s.s4Bars['bus'] == 4) {
            s.s4Checked = true;
            _advance();
            _checkComplete();
          } else {
            AudioEngine.playError();
          }
          widget.onStateChanged();
          return;
        }
      }
    } else if (s.scenario == 5) {
      if (s.step == 1) {
        List<int> vals = [100, 500, 1000];
        for (int i = 0; i < 3; i++) {
          if (_hitBox(pt, -330, 50.0 + i * 45, 140, 35)) {
            _allowPanZoom = false;
            if (vals[i] == 500) {
              s.s5Scale = 500;
              _advance();
            } else {
              AudioEngine.playError();
            }
            widget.onStateChanged();
            return;
          }
        }
      } else if (s.step >= 2 && !s.s5Checked) {
        List<String> cats = ['y2010', 'y2014', 'y2018'];
        Map<String, int> targets = {
          'y2010': 1700,
          'y2014': 2200,
          'y2018': 3000,
        };
        for (int i = 0; i < 3; i++) {
          double bx = -100.0 + i * 150.0 + 25;
          if (_hitBox(pt, bx + 30, 145, 40, 40)) {
            _allowPanZoom = false;
            int cur = s.s5Bars[cats[i]]!;
            int next = cur + 500;
            int target = targets[cats[i]]!;
            if (next >= target && cur < target) {
              s.s5Bars[cats[i]] = target;
            } else {
              s.s5Bars[cats[i]] = math.min(3000, next);
            }
            AudioEngine.playClick();
            if (s.step == 2 &&
                cats[i] == 'y2010' &&
                s.s5Bars['y2010'] == 1700) {
              _advance();
            }
            if (s.step == 3 &&
                s.s5Bars['y2014'] == 2200 &&
                s.s5Bars['y2018'] == 3000) {
              _advance();
            }
            widget.onStateChanged();
            return;
          }
        }
        if (_hitBox(pt, 390, 50, 160, 50)) {
          _allowPanZoom = false;
          if (s.s5Bars['y2010'] == 1700 &&
              s.s5Bars['y2014'] == 2200 &&
              s.s5Bars['y2018'] == 3000) {
            s.s5Checked = true;
            _advance();
            _checkComplete();
          } else {
            AudioEngine.playError();
          }
          widget.onStateChanged();
          return;
        }
      }
    }

    // 2. CHECK INSTANT DRAGGABLES
    if (s.scenario == 1) {
      for (var f in s.s1Belt) {
        if (_hitCircle(pt, f.x, f.y, 25)) {
          if ((s.step == 0 && f.type == 'apple') ||
              (s.step == 1 && f.type == 'banana') ||
              s.step == 2) {
            s.activeDragEntity = 'f_${f.id}';
            s.dragX = pt.dx;
            s.dragY = pt.dy;
            AudioEngine.playClick();
            _allowPanZoom = false;
            return;
          }
        }
      }
    } else if (s.scenario == 3) {
      if (s.step < 3 && _hitBox(pt, -250, -20, 100, 60)) {
        s.activeDragEntity = 'crate';
        s.dragX = pt.dx;
        s.dragY = pt.dy;
        AudioEngine.playClick();
        _allowPanZoom = false;
        return;
      }
    } else if (s.scenario == 4) {
      if (s.step == 0) {
        List<String> cats = ['bike', 'car', 'bus'];
        for (int i = 0; i < 3; i++) {
          if (!s.s4Labels[cats[i]]! &&
              _hitBox(pt, -350, -50.0 + i * 50, 100, 35)) {
            s.activeDragEntity = 's4_${cats[i]}';
            s.dragX = pt.dx;
            s.dragY = pt.dy;
            AudioEngine.playClick();
            _allowPanZoom = false;
            return;
          }
        }
      }
    } else if (s.scenario == 5) {
      if (s.step == 0) {
        List<String> cats = ['y2010', 'y2014', 'y2018'];
        for (int i = 0; i < 3; i++) {
          if (!s.s5Labels[cats[i]]! &&
              _hitBox(pt, -350, -50.0 + i * 50, 100, 35)) {
            s.activeDragEntity = 's5_${cats[i]}';
            s.dragX = pt.dx;
            s.dragY = pt.dy;
            AudioEngine.playClick();
            _allowPanZoom = false;
            return;
          }
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    AppState s = widget.state;
    if (s.activeDragEntity != null) {
      if (_canvasKey.currentContext == null) return;
      final RenderBox box =
          _canvasKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPos = box.globalToLocal(event.position);
      double cx = box.size.width / 2 + s.panX;
      double cy = box.size.height / 2 + s.panY;
      s.dragX = (localPos.dx - cx) / s.zoom;
      s.dragY = (localPos.dy - cy) / s.zoom;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    AppState s = widget.state;
    if (s.activeDragEntity != null) {
      Offset pt = Offset(s.dragX, s.dragY);

      if (s.scenario == 1) {
        if (s.activeDragEntity!.startsWith('f_')) {
          int id = int.parse(s.activeDragEntity!.split('_')[1]);
          int idx = s.s1Belt.indexWhere((f) => f.id == id);
          if (idx > -1) {
            var f = s.s1Belt[idx];
            Map<String, double> binCenters = {
              'apple': -220,
              'banana': -60,
              'orange': 100,
            };
            String? hitBin;
            binCenters.forEach((b, bx) {
              if (_hitBox(pt, bx - 70, -120, 140, 80)) hitBin = b;
            });
            if (hitBin == f.type) {
              s.s1Bins[hitBin!] = (s.s1Bins[hitBin!] ?? 0) + 1;
              s.s1Belt.removeAt(idx);
              if (s.step == 0 && hitBin == 'apple') {
                _advance();
              } else if (s.step == 1 && hitBin == 'banana') {
                _advance();
              } else if (s.step == 2 && s.s1Belt.isEmpty) {
                _advance();
              } else {
                AudioEngine.playClick(); // Dropped successfully but didn't trigger an advance check yet
              }
            } else {
              AudioEngine.playError();
            }
          }
        }
      } else if (s.scenario == 3) {
        if (_hitBox(pt, 0, -150, 200, 300)) {
          s.s3Crates++;
          if (s.step == 0 && s.s3Crates == 1) {
            _advance();
          } else if (s.step == 1 && s.s3Crates == 2) {
            _advance();
          } else if (s.step == 2 && s.s3Crates == 3) {
            _advance();
            _checkComplete();
          } else {
            AudioEngine.playClick();
          }
        } else {
          AudioEngine.playError();
        }
      } else if (s.scenario == 4) {
        String cat = s.activeDragEntity!.split('_')[1];
        int idx = ['bike', 'car', 'bus'].indexOf(cat);
        if (_hitBox(pt, -100.0 + idx * 150.0, 100, 150, 50)) {
          s.s4Labels[cat] = true;
          if (s.s4Labels['bike']! &&
              s.s4Labels['car']! &&
              s.s4Labels['bus']! &&
              s.step == 0) {
            _advance();
          } else {
            AudioEngine.playClick();
          }
        } else {
          AudioEngine.playError();
        }
      } else if (s.scenario == 5) {
        String cat = s.activeDragEntity!.split('_')[1];
        int idx = ['y2010', 'y2014', 'y2018'].indexOf(cat);
        if (_hitBox(pt, -100.0 + idx * 150.0, 100, 150, 50)) {
          s.s5Labels[cat] = true;
          if (s.s5Labels['y2010']! &&
              s.s5Labels['y2014']! &&
              s.s5Labels['y2018']! &&
              s.step == 0) {
            _advance();
          } else {
            AudioEngine.playClick();
          }
        } else {
          AudioEngine.playError();
        }
      }

      s.activeDragEntity = null;
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (!_allowPanZoom) return;
    if (_canvasKey.currentContext == null) return;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);

    _initialZoom = widget.state.zoom;
    _initialPan = Offset(widget.state.panX, widget.state.panY);
    _initialLocalFocal = localPos;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!_allowPanZoom) return;
    if (_canvasKey.currentContext == null) return;

    AppState s = widget.state;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);

    double newZoom = (_initialZoom * details.scale).clamp(0.4, 3.0);
    double scaleRatio = newZoom / _initialZoom;
    Offset screenCenter = Offset(box.size.width / 2, box.size.height / 2);

    s.panX =
        _initialPan.dx +
        (localPos.dx - _initialLocalFocal.dx) -
        (scaleRatio - 1.0) *
            (_initialLocalFocal.dx - screenCenter.dx - _initialPan.dx);
    s.panY =
        _initialPan.dy +
        (localPos.dy - _initialLocalFocal.dy) -
        (scaleRatio - 1.0) *
            (_initialLocalFocal.dy - screenCenter.dy - _initialPan.dy);
    s.zoom = newZoom;
  }

  bool _hitBox(Offset pt, double x, double y, double w, double h) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  bool _hitCircle(Offset pt, double x, double y, double r) {
    double dx = pt.dx - x;
    double dy = pt.dy - y;
    return (dx * dx + dy * dy) <= r * r;
  }

  void _advance() {
    AudioEngine.playClick();
    widget.state.step++;
    widget.onStateChanged();
  }

  void _checkComplete() {
    AudioEngine.playPageOpen();
    widget.onStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // CANVAS AREA
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: 0,
          left: widget.state.sidebarOpen ? widget.state.sidebarWidth : 0,
          child: Listener(
            onPointerDown: (e) {
              _handlePointerDown(e);
              widget.onStateChanged();
            },
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            child: GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              child: ClipRect(
                child: CustomPaint(
                  key: _canvasKey,
                  painter: LabPainter(state: widget.state),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),

        // HUD
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: 40,
          left: widget.state.sidebarOpen ? widget.state.sidebarWidth : 0,
          right: 0,
          child: IgnorePointer(child: Center(child: _buildHUD())),
        ),

        // SUCCESS POPUP
        if (widget.state.isScenarioComplete(widget.state.scenario))
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: widget.state.sidebarOpen ? widget.state.sidebarWidth : 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flag_circle,
                        color: Colors.greenAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t(widget.state.lang, 'summaryTitle'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t(widget.state.lang, 'finalDesc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          AudioEngine.playPageOpen();
                          if (widget.state.scenario < 5) {
                            widget.onLoadScenario(widget.state.scenario + 1);
                          } else {
                            widget.onReset();
                          }
                        },
                        child: Text(
                          widget.state.scenario < 5
                              ? t(widget.state.lang, 'nextScenario')
                              : t(widget.state.lang, 'finishLab'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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

        // SIDEBAR
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          left: widget.state.sidebarOpen ? 0 : -widget.state.sidebarWidth,
          width: widget.state.sidebarWidth,
          child: Container(
            color: const Color(0xFF1E293B),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 60,
                        ), // Clears space for the fixed floating menu btn
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bar_chart,
                                color: Color(0xFF6366F1),
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t(widget.state.lang, 'appTitle'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ).copyWith(top: 4),
                          child: Text(
                            t(widget.state.lang, 'appSubtitle'),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),

                        // Language Toggle and Reset Button Below Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ).copyWith(top: 16),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  AudioEngine.playClick();
                                  widget.state.lang = widget.state.lang == 'en'
                                      ? 'hi'
                                      : 'en';
                                  widget.onStateChanged();
                                },
                                icon: const Icon(Icons.translate, size: 16),
                                label: Text(widget.state.lang.toUpperCase()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF334155),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  minimumSize: const Size(0, 36),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: widget.onReset,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reset'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(
                                    0.2,
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Colors.white12, height: 1),
                        ),

                        // Dropdown and Steps Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t(
                                  widget.state.lang,
                                  'selectScenario',
                                ).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: widget.state.scenario,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF0F172A),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: [1, 2, 3, 4, 5]
                                        .map(
                                          (i) => DropdownMenuItem(
                                            value: i,
                                            child: Text(
                                              t(
                                                widget.state.lang,
                                                's${i}_title',
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      AudioEngine.playDropdown();
                                      widget.onLoadScenario(v!);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withOpacity(0.5),
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
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t(widget.state.lang, 'learnLbl'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t(
                                        widget.state.lang,
                                        's${widget.state.scenario}_obj',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSteps(),
                            ],
                          ),
                        ),

                        // Footer
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: const Color(0xFF0F172A),
                          alignment: Alignment.center,
                          child: const Text(
                            '© ZeroScienceLab - Fall in love with math and Science',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Resizer Handle
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    double newWidth =
                        widget.state.sidebarWidth + details.delta.dx;
                    newWidth = math.max(
                      300.0,
                      math.min(
                        newWidth,
                        MediaQuery.of(context).size.width * 0.6,
                      ),
                    );
                    setState(() {
                      widget.state.sidebarWidth = newWidth;
                    });
                  },
                  child: Container(
                    width: 10,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // FLOATING MENU BTN
        Positioned(
          top: 10,
          left: 10,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AudioEngine.playClick();
                widget.state.sidebarOpen = !widget.state.sidebarOpen;
                widget.onStateChanged();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  widget.state.sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSteps() {
    int sc = widget.state.scenario;
    int maxSteps = sc == 1
        ? 4
        : (sc == 2 || sc == 3)
        ? 3
        : 5;
    List<Widget> steps = [];

    for (int i = 0; i < maxSteps; i++) {
      bool isPast = i < widget.state.step;
      bool isCurrent = i == widget.state.step;

      Color bgColor = isCurrent
          ? const Color(0xFF6366F1).withOpacity(0.15)
          : (isPast
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.02));
      Color borderColor = isCurrent
          ? const Color(0xFF6366F1)
          : (isPast ? Colors.green.withOpacity(0.3) : Colors.white12);

      steps.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPast
                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                  : CircleAvatar(
                      radius: 12,
                      backgroundColor: isCurrent
                          ? const Color(0xFF6366F1)
                          : Colors.white24,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t(widget.state.lang, 'stepLabel')} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t(widget.state.lang, 's${sc}_step${i + 1}_task'),
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t(widget.state.lang, 's${sc}_step${i + 1}_out'),
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
    return Column(children: steps);
  }

  Widget _buildHUD() {
    int maxSteps = widget.state.scenario == 1
        ? 4
        : (widget.state.scenario == 2 || widget.state.scenario == 3)
        ? 3
        : 5;
    if (widget.state.step >= maxSteps) return const SizedBox.shrink();

    String hudText = t(
      widget.state.lang,
      's${widget.state.scenario}_hud${widget.state.step + 1}',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: Color(0xFF6366F1), width: 3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 28),
          const SizedBox(width: 12),
          Text(
            hudText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- CANVAS RENDERING ---
class LabPainter extends CustomPainter {
  final AppState state;
  LabPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawColor(const Color(0xFF0F172A), BlendMode.srcOver);

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

    // Render dragged entity
    if (state.activeDragEntity != null) {
      if (state.scenario == 1 && state.activeDragEntity!.startsWith('f_')) {
        int id = int.parse(state.activeDragEntity!.split('_')[1]);
        var f = state.s1Belt.firstWhere(
          (e) => e.id == id,
          orElse: () => Fruit(-1, '', 0, 0),
        );
        if (f.id != -1) {
          _drawFruit(canvas, f.type, state.dragX, state.dragY, 1.2);
        }
      } else if (state.scenario == 3 && state.activeDragEntity == 'crate') {
        _drawCrate(canvas, state.dragX, state.dragY, 1.2);
      } else if ((state.scenario == 4 || state.scenario == 5) &&
          state.activeDragEntity!.startsWith('s')) {
        String cat = state.activeDragEntity!.split('_')[1];
        String lbl = state.scenario == 4
            ? t(state.lang, cat == 'bus' ? 'lbl_buses' : 'lbl_${cat}s')
            : t(state.lang, 'lbl_$cat');
        _drawRoundedRect(
          canvas,
          state.dragX - 50,
          state.dragY - 17.5,
          100,
          35,
          6,
          const Color(0xFFFACC15),
          const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          lbl,
          state.dragX,
          state.dragY,
          fontSize: 16,
          color: const Color(0xFF0F172A),
        );
      }
    }

    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    _drawConveyor(canvas, -300, -200, 600);

    List<Color> binColors = [
      const Color(0xFFFCA5A5),
      const Color(0xFFFEF08A),
      const Color(0xFFFED7AA),
    ];
    List<String> labels = [
      t(state.lang, 'lbl_apples'),
      t(state.lang, 'lbl_bananas'),
      t(state.lang, 'lbl_oranges'),
    ];

    for (int i = 0; i < 3; i++) {
      double bx = -220.0 + i * 160.0;
      _drawRoundedRect(
        canvas,
        bx - 60,
        -100,
        120,
        50,
        8,
        binColors[i],
        const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        labels[i],
        bx,
        -75,
        fontSize: 14,
        color: const Color(0xFF0F172A),
      );
    }

    double gX = -150, gY = 50, gW = 300, gH = 150;
    _drawGrid(canvas, gX, gY, gW, gH, 6, 1, labels);

    double slotW = gW / 3;
    List<int> counts = [
      state.s1Bins['apple']!,
      state.s1Bins['banana']!,
      state.s1Bins['orange']!,
    ];
    int maxC = counts.reduce(math.max);

    for (int i = 0; i < 3; i++) {
      int c = counts[i];
      if (c > 0) {
        double barH = (c / 6) * gH;
        double bx = gX + i * slotW + 20;
        double bw = slotW - 40;

        if (c == 5 && c == maxC && state.step == 3) {
          canvas.drawShadow(
            Path()..addRect(Rect.fromLTWH(bx, gY + gH - barH, bw, barH)),
            const Color(0xFFFACC15),
            10,
            true,
          );
        }
        _drawRoundedRect(
          canvas,
          bx,
          gY + gH - barH,
          bw,
          barH,
          2,
          binColors[i],
          const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          c.toString(),
          bx + bw / 2,
          gY + gH - barH - 15,
          color: Colors.white,
          fontSize: 14,
        );
      }
    }

    for (var f in state.s1Belt) {
      if (state.activeDragEntity != 'f_${f.id}') {
        _drawFruit(canvas, f.type, f.x, f.y, 1.0);
      }
    }
  }

  void _renderS2(Canvas canvas) {
    double gX = -300, gY = -150, gW = 600, gH = 300;
    List<String> labels = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];
    List<int> data = [3, 5, 2, 4, 0, 1, 6, 7];

    _drawText(
      canvas,
      t(state.lang, 'lbl_s2_title'),
      0,
      gY - 40,
      fontSize: 24,
      color: Colors.white,
    );
    _drawGrid(
      canvas,
      gX,
      gY,
      gW,
      gH,
      8,
      1,
      labels,
      yLabel: t(state.lang, 'lbl_s2_yaxis'),
      xLabel: t(state.lang, 'lbl_s2_xaxis'),
    );

    double slotW = gW / labels.length;

    for (int i = 0; i < data.length; i++) {
      double barH = (data[i] / 8) * gH;
      double bx = gX + i * slotW + 15;
      double bw = slotW - 30;

      if (data[i] > 0) {
        Color c = const Color(0xFF38BDF8);
        if (state.step == 1 && i == 7 && state.s2TallClicked) {
          c = const Color(0xFFFACC15);
        }
        if (state.step == 1 && i == 7 && !state.s2TallClicked) {
          c = Color.lerp(
            const Color(0xFF38BDF8),
            Colors.white,
            0.5 * (math.sin(DateTime.now().millisecondsSinceEpoch / 200) + 1),
          )!;
        }

        _drawRoundedRect(
          canvas,
          bx,
          gY + gH - barH,
          bw,
          barH,
          2,
          c,
          const Color(0xFF0F172A),
        );

        if (i == 1 && state.s2C2Clicked) {
          _drawLine(
            canvas,
            gX,
            gY + gH - barH,
            bx,
            gY + gH - barH,
            Colors.redAccent,
            4,
            dashed: true,
          );
          canvas.drawCircle(
            Offset(gX, gY + gH - barH),
            6,
            Paint()..color = Colors.redAccent,
          );
          _drawText(
            canvas,
            "5",
            gX - 30,
            gY + gH - barH,
            fontSize: 20,
            color: Colors.redAccent,
          );
        }
      } else if (i == 4 && state.s2ZeroClicked) {
        canvas.save();
        canvas.translate(bx + bw / 2, gY + gH - 30);
        canvas.rotate(-0.2);
        _drawRoundedRect(
          canvas,
          -50,
          -15,
          100,
          30,
          4,
          const Color(0xFF22C55E),
          const Color(0xFF166534),
        );
        _drawText(canvas, "0 ABSENT", 0, 0, fontSize: 12, color: Colors.white);
        canvas.restore();
      }
    }
  }

  void _renderS3(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -300,
      -200,
      200,
      100,
      8,
      Colors.white,
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "ORDER:",
      -200,
      -170,
      fontSize: 20,
      color: const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "30 ${t(state.lang, 'lbl_gj')}",
      -200,
      -140,
      fontSize: 16,
      color: Colors.redAccent,
    );

    double gX = 0, gY = -150, gW = 200, gH = 300;
    _drawGrid(canvas, gX, gY, gW, gH, 40, 10, [t(state.lang, 'lbl_gj')]);

    _drawRoundedRect(
      canvas,
      gX + gW + 40,
      gY,
      200,
      40,
      8,
      const Color(0xFFFEF08A),
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      t(state.lang, 'lbl_s3_scale'),
      gX + gW + 140,
      gY + 20,
      fontSize: 14,
      color: const Color(0xFF0F172A),
    );

    int val = state.s3Crates * 10;
    if (val > 0) {
      double barH = (val / 40) * gH;
      _drawRoundedRect(
        canvas,
        gX + 50,
        gY + gH - barH,
        100,
        barH,
        2,
        const Color(0xFFD97706),
        const Color(0xFF0F172A),
      );
      for (int i = 1; i < state.s3Crates; i++) {
        _drawLine(
          canvas,
          gX + 50,
          gY + gH - i * (gH / 4),
          gX + 150,
          gY + gH - i * (gH / 4),
          const Color(0xFF0F172A),
          2,
        );
      }
    }

    if (state.step < 3 && state.activeDragEntity != 'crate') {
      _drawCrate(canvas, -200, 0, 1.5);
      _drawText(canvas, "DRAG ME", -200, 50, fontSize: 14, color: Colors.white);
    }
  }

  void _renderS4(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -400,
      -220,
      200,
      120,
      8,
      Colors.white,
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "DATA:",
      -300,
      -195,
      fontSize: 16,
      color: const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "12 ${t(state.lang, 'lbl_bikes')}",
      -300,
      -165,
      fontSize: 16,
      color: Colors.blue,
    );
    _drawText(
      canvas,
      "8 ${t(state.lang, 'lbl_cars')}",
      -300,
      -140,
      fontSize: 16,
      color: Colors.red,
    );
    _drawText(
      canvas,
      "4 ${t(state.lang, 'lbl_buses')}",
      -300,
      -115,
      fontSize: 16,
      color: Colors.green,
    );

    double gX = -100, gY = -200, gW = 450, gH = 300;
    int step = state.s4Scale ?? 2;

    if (state.s4Scale != null) {
      _drawGrid(canvas, gX, gY, gW, gH, 12, step, []);
    } else {
      _drawLine(canvas, gX, gY, gX, gY + gH, const Color(0xFF0F172A), 3);
      _drawLine(
        canvas,
        gX,
        gY + gH,
        gX + gW,
        gY + gH,
        const Color(0xFF0F172A),
        3,
      );
    }

    List<String> cats = ['bike', 'car', 'bus'];
    List<Color> colors = [Colors.blue, Colors.red, Colors.green];
    double slotW = gW / 3;

    for (int i = 0; i < 3; i++) {
      String cat = cats[i];
      double bx = gX + i * slotW + 25;

      if (state.s4Labels[cat]!) {
        _drawText(
          canvas,
          t(state.lang, cat == 'bus' ? 'lbl_buses' : 'lbl_${cat}s'),
          gX + (i + 0.5) * slotW,
          gY + gH + 25,
          fontSize: 16,
          color: Colors.white,
        );
      } else {
        _drawRoundedRect(
          canvas,
          gX + (i + 0.5) * slotW - 40,
          gY + gH + 10,
          80,
          30,
          4,
          const Color(0xFF334155),
          const Color(0xFF475569),
        );
        _drawText(
          canvas,
          "?",
          gX + (i + 0.5) * slotW,
          gY + gH + 25,
          fontSize: 16,
          color: const Color(0xFF64748B),
        );
      }

      if (state.s4Scale != null && state.s4Labels[cat]!) {
        int val = state.s4Bars[cat]!;
        if (val > 0) {
          double barH = (val / 12) * gH;
          _drawRoundedRect(
            canvas,
            bx,
            gY + gH - barH,
            slotW - 50,
            barH,
            2,
            colors[i],
            const Color(0xFF0F172A),
          );
          _drawText(
            canvas,
            val.toString(),
            bx + (slotW - 50) / 2,
            gY + gH - barH - 15,
            fontSize: 14,
            color: Colors.white,
          );
        }
        if (state.step >= 2 && !state.s4Checked) {
          _drawRoundedRect(
            canvas,
            bx + (slotW - 50) / 2 - 20,
            gY + gH + 45,
            40,
            40,
            20,
            Colors.white,
            const Color(0xFF0F172A),
          );
          _drawText(
            canvas,
            "+",
            bx + (slotW - 50) / 2,
            gY + gH + 65,
            fontSize: 24,
            color: const Color(0xFF0F172A),
          );
        }
      }
    }

    if (state.step == 0) {
      for (int i = 0; i < 3; i++) {
        if (!state.s4Labels[cats[i]]! &&
            state.activeDragEntity != 's4_${cats[i]}') {
          _drawRoundedRect(
            canvas,
            -350,
            -50.0 + i * 50,
            100,
            35,
            6,
            const Color(0xFFFACC15),
            const Color(0xFF0F172A),
          );
          _drawText(
            canvas,
            t(state.lang, cats[i] == 'bus' ? 'lbl_buses' : 'lbl_${cats[i]}s'),
            -300,
            -32.0 + i * 50,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          );
        }
      }
    }

    if (state.step == 1) {
      _drawRoundedRect(
        canvas,
        -350,
        0,
        180,
        200,
        8,
        Colors.white,
        const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        t(state.lang, 'lbl_scale_sel'),
        -260,
        25,
        fontSize: 16,
        color: const Color(0xFF0F172A),
      );
      List<int> s = [1, 2, 5];
      for (int i = 0; i < 3; i++) {
        _drawRoundedRect(
          canvas,
          -330,
          50.0 + i * 45,
          140,
          35,
          6,
          const Color(0xFFE2E8F0),
          const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          "1 block = ${s[i]}",
          -260,
          67.0 + i * 45,
          fontSize: 14,
          color: const Color(0xFF0F172A),
        );
      }
    }

    if (state.step >= 2 && !state.s4Checked && state.s4Bars['bike']! > 0) {
      _drawRoundedRect(
        canvas,
        gX + gW + 40,
        gY + gH - 50,
        160,
        50,
        25,
        const Color(0xFF22C55E),
        const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        t(state.lang, 'lbl_check'),
        gX + gW + 120,
        gY + gH - 25,
        fontSize: 14,
        color: Colors.white,
      );
    }

    if (state.s4Checked) {
      _drawRoundedRect(
        canvas,
        gX + gW / 2 - 100,
        -270,
        200,
        40,
        8,
        const Color(0xFF22C55E),
        const Color(0xFF166534),
      );
      _drawText(
        canvas,
        "Perfect Graph!",
        gX + gW / 2,
        -250,
        fontSize: 18,
        color: Colors.white,
      );
    }
  }

  void _renderS5(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -400,
      -220,
      200,
      120,
      8,
      Colors.white,
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "TIGERS:",
      -300,
      -195,
      fontSize: 16,
      color: const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "2010: 1700",
      -300,
      -165,
      fontSize: 16,
      color: Colors.orange,
    );
    _drawText(
      canvas,
      "2014: 2200",
      -300,
      -140,
      fontSize: 16,
      color: Colors.orange,
    );
    _drawText(
      canvas,
      "2018: 3000",
      -300,
      -115,
      fontSize: 16,
      color: Colors.orange,
    );

    double gX = -100, gY = -200, gW = 450, gH = 300;

    if (state.s5Scale != null) {
      _drawGrid(canvas, gX, gY, gW, gH, 3000, state.s5Scale!, []);
    } else {
      _drawLine(canvas, gX, gY, gX, gY + gH, const Color(0xFF0F172A), 3);
      _drawLine(
        canvas,
        gX,
        gY + gH,
        gX + gW,
        gY + gH,
        const Color(0xFF0F172A),
        3,
      );
    }

    List<String> cats = ['y2010', 'y2014', 'y2018'];
    double slotW = gW / 3;

    for (int i = 0; i < 3; i++) {
      String cat = cats[i];
      double bx = gX + i * slotW + 25;

      if (state.s5Labels[cat]!) {
        _drawText(
          canvas,
          t(state.lang, 'lbl_$cat'),
          gX + (i + 0.5) * slotW,
          gY + gH + 25,
          fontSize: 16,
          color: Colors.white,
        );
      } else {
        _drawRoundedRect(
          canvas,
          gX + (i + 0.5) * slotW - 40,
          gY + gH + 10,
          80,
          30,
          4,
          const Color(0xFF334155),
          const Color(0xFF475569),
        );
        _drawText(
          canvas,
          "?",
          gX + (i + 0.5) * slotW,
          gY + gH + 25,
          fontSize: 16,
          color: const Color(0xFF64748B),
        );
      }

      if (state.s5Scale != null && state.s5Labels[cat]!) {
        int val = state.s5Bars[cat]!;
        if (val > 0) {
          double barH = (val / 3000) * gH;
          _drawRoundedRect(
            canvas,
            bx,
            gY + gH - barH,
            slotW - 50,
            barH,
            2,
            Colors.orange,
            const Color(0xFF0F172A),
          );
          _drawText(
            canvas,
            val.toString(),
            bx + (slotW - 50) / 2,
            gY + gH - barH - 15,
            fontSize: 14,
            color: Colors.white,
          );
        }
        if (state.step >= 2 && !state.s5Checked) {
          _drawRoundedRect(
            canvas,
            bx + (slotW - 50) / 2 - 20,
            gY + gH + 45,
            40,
            40,
            20,
            Colors.white,
            const Color(0xFF0F172A),
          );
          _drawText(
            canvas,
            "+",
            bx + (slotW - 50) / 2,
            gY + gH + 65,
            fontSize: 24,
            color: const Color(0xFF0F172A),
          );
        }
      }
    }

    if (state.step == 0) {
      for (int i = 0; i < 3; i++) {
        if (!state.s5Labels[cats[i]]! &&
            state.activeDragEntity != 's5_${cats[i]}') {
          _drawRoundedRect(
            canvas,
            -350,
            -50.0 + i * 50,
            100,
            35,
            6,
            const Color(0xFFFACC15),
            const Color(0xFF0F172A),
          );
          _drawText(
            canvas,
            t(state.lang, 'lbl_${cats[i]}'),
            -300,
            -32.0 + i * 50,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          );
        }
      }
    }

    if (state.step == 1) {
      _drawRoundedRect(
        canvas,
        -350,
        0,
        180,
        200,
        8,
        Colors.white,
        const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        t(state.lang, 'lbl_scale_sel'),
        -260,
        25,
        fontSize: 16,
        color: const Color(0xFF0F172A),
      );
      List<int> s = [100, 500, 1000];
      for (int i = 0; i < 3; i++) {
        _drawRoundedRect(
          canvas,
          -330,
          50.0 + i * 45,
          140,
          35,
          6,
          const Color(0xFFE2E8F0),
          const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          "1 block = ${s[i]}",
          -260,
          67.0 + i * 45,
          fontSize: 14,
          color: const Color(0xFF0F172A),
        );
      }
    }

    if (state.step >= 2 && !state.s5Checked && state.s5Bars['y2010']! > 0) {
      _drawRoundedRect(
        canvas,
        gX + gW + 40,
        gY + gH - 50,
        160,
        50,
        25,
        const Color(0xFF22C55E),
        const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        t(state.lang, 'lbl_check'),
        gX + gW + 120,
        gY + gH - 25,
        fontSize: 14,
        color: Colors.white,
      );
    }
  }

  // --- DRAWING HELPERS ---
  void _drawGrid(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    int maxVal,
    int step,
    List<String> labels, {
    String? yLabel,
    String? xLabel,
  }) {
    Paint gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;
    int numLines = maxVal ~/ step;
    double pxPerStep = h / numLines;

    for (int i = 0; i <= numLines; i++) {
      double py = y + h - i * pxPerStep;
      canvas.drawLine(Offset(x, py), Offset(x + w, py), gridPaint);
      _drawText(
        canvas,
        (i * step).toString(),
        x - 15,
        py,
        fontSize: 14,
        color: Colors.white,
        align: TextAlign.right,
      );
    }

    _drawLine(canvas, x, y, x, y + h, const Color(0xFF0F172A), 3);
    _drawLine(canvas, x, y + h, x + w, y + h, const Color(0xFF0F172A), 3);

    if (labels.isNotEmpty) {
      double slotW = w / labels.length;
      for (int i = 0; i < labels.length; i++) {
        _drawText(
          canvas,
          labels[i],
          x + (i + 0.5) * slotW,
          y + h + 25,
          fontSize: 14,
          color: Colors.white,
        );
      }
    }

    if (yLabel != null) {
      canvas.save();
      canvas.translate(x - 50, y + h / 2);
      canvas.rotate(-math.pi / 2);
      _drawText(canvas, yLabel, 0, 0, fontSize: 16, color: Colors.white);
      canvas.restore();
    }
    if (xLabel != null) {
      _drawText(
        canvas,
        xLabel,
        x + w / 2,
        y + h + 55,
        fontSize: 16,
        color: Colors.white,
      );
    }
  }

  void _drawConveyor(Canvas canvas, double x, double y, double w) {
    _drawRoundedRect(
      canvas,
      x - 20,
      y - 25,
      w + 40,
      50,
      25,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
    );
    _drawRoundedRect(
      canvas,
      x,
      y - 15,
      w,
      30,
      15,
      const Color(0xFF1E293B),
      Colors.transparent,
    );
    Paint dot = Paint()..color = const Color(0xFF94A3B8);
    for (double wx = x + 15; wx < x + w; wx += 40) {
      canvas.drawCircle(Offset(wx, y), 5, dot);
    }
  }

  void _drawFruit(
    Canvas canvas,
    String type,
    double x,
    double y,
    double scale,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    Paint outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (type == 'apple') {
      Paint fill = Paint()..color = Colors.red;
      canvas.drawCircle(Offset.zero, 20, fill);
      canvas.drawCircle(Offset.zero, 20, outline);
      Path stem = Path()
        ..moveTo(0, -20)
        ..quadraticBezierTo(-5, -30, 5, -35);
      canvas.drawPath(
        stem,
        Paint()
          ..color = Colors.lightGreen
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else if (type == 'banana') {
      Paint fill = Paint()..color = Colors.yellowAccent;
      Path p = Path()
        ..moveTo(-15, -15)
        ..quadraticBezierTo(0, 25, 20, 10)
        ..quadraticBezierTo(5, 10, -15, -15);
      canvas.drawPath(p, fill);
      canvas.drawPath(p, outline);
    } else if (type == 'orange') {
      Paint fill = Paint()..color = Colors.orange;
      canvas.drawCircle(Offset.zero, 20, fill);
      canvas.drawCircle(Offset.zero, 20, outline);
      canvas.drawCircle(
        const Offset(0, -15),
        2,
        Paint()..color = Colors.deepOrange,
      );
    }
    canvas.restore();
  }

  void _drawCrate(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    _drawRoundedRect(
      canvas,
      -25,
      -20,
      50,
      40,
      4,
      const Color(0xFFD97706),
      const Color(0xFF0F172A),
    );
    _drawLine(canvas, -25, 0, 25, 0, const Color(0xFF0F172A), 2);
    _drawLine(canvas, -10, -20, -10, 20, const Color(0xFF0F172A), 2);
    _drawLine(canvas, 10, -20, 10, 20, const Color(0xFF0F172A), 2);
    _drawText(
      canvas,
      "10",
      0,
      0,
      fontSize: 18,
      color: Colors.white,
      strokeColor: const Color(0xFF0F172A),
    );
    canvas.restore();
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
  ) {
    RRect rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) canvas.drawRRect(rr, Paint()..color = fill);
    if (stroke != Colors.transparent) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color c,
    double w, {
    bool dashed = false,
  }) {
    Paint p = Paint()
      ..color = c
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    } else {
      double dx = x2 - x1, dy = y2 - y1;
      double dist = math.sqrt(dx * dx + dy * dy);
      double step = 8;
      for (double i = 0; i < dist; i += step * 2) {
        double p1x = x1 + dx * (i / dist);
        double p1y = y1 + dy * (i / dist);
        double p2x = x1 + dx * ((i + step) / dist).clamp(0.0, 1.0);
        double p2y = y1 + dy * ((i + step) / dist).clamp(0.0, 1.0);
        canvas.drawLine(Offset(p1x, p1y), Offset(p2x, p2y), p);
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 14,
    Color color = Colors.black,
    Color strokeColor = Colors.transparent,
    TextAlign align = TextAlign.center,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();

    double startX =
        x -
        (align == TextAlign.center
            ? tp.width / 2
            : (align == TextAlign.right ? tp.width : 0));
    double startY = y - tp.height / 2;

    if (strokeColor != Colors.transparent) {
      TextSpan strokeSpan = TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = strokeColor,
        ),
        text: text,
      );
      TextPainter tpStroke = TextPainter(
        text: strokeSpan,
        textAlign: align,
        textDirection: ui.TextDirection.ltr,
      );
      tpStroke.layout();
      tpStroke.paint(canvas, Offset(startX, startY));
    }

    tp.paint(canvas, Offset(startX, startY));
  }

  @override
  bool shouldRepaint(LabPainter oldDelegate) => true;
}
