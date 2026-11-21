// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: library_private_types_in_public_api, use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZSL Virtual Lab',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const Cl6M_Ch4_A1_CollectingandOrganizingData(),
    ),
  );
}

// --- LOCALIZATION DATA ---
final Map<String, Map<String, String>> tMap = {
  'en': {
    'shutterTitle': 'Collecting and Organizing Data',
    'appTitle': 'Collecting & Organizing Data',
    'appSubtitle': 'Class 6 • THE BUSY FRUIT STAND',
    'enterLab': 'Enter Virtual Lab',
    'settings': 'Settings',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'doneBtn': 'Done',
    'learnLbl': 'Learning:',
    'summaryTitle': 'Goal Reached!',
    'resetBtn': 'Reset Lab',
    'finishLab': 'Finish Lab',
    'nextScenario': 'Next Scenario',
    'finalDesc':
        'You have successfully learned how to collect, organize, and interpret data!',
    's1_title': '1. The Messy Fruit Basket',
    's1_obj':
        'To understand that counting items in a jumbled, unorganized collection is difficult and slow.',
    's1_step1_task': 'TAP on every single APPLE in the basket to count them.',
    's1_step1_out': 'It\'s hard to count when things are mixed up!',
    's1_step2_task': 'TAP on every single BANANA in the basket.',
    's1_step2_out':
        'That was slow and confusing, wasn\'t it? It\'s hard to understand data when it\'s not organized.',
    's1_hud1': 'Find and tap all 10 apples.',
    's1_hud2': 'Find and tap all 8 bananas.',
    's2_title': '2. Sorting the Stall',
    's2_obj':
        'To learn that organizing data by grouping makes it easy to see and count quantities.',
    's2_step1_task':
        'DRAG each fruit from the basket and DROP it into the correct crate.',
    's2_step1_out': 'Grouping similar items makes counting much easier.',
    's2_step2_task': 'TAP on the crate with the MOST fruit.',
    's2_step2_out':
        'By organizing the fruit, we can easily see how many of each we have. This is the first step in handling data!',
    's2_hud1': 'Sort the fruits into their crates.',
    's2_hud2': 'Tap the crate with the most fruit.',
    's3_title': '3. Tally Up the Sales!',
    's3_obj':
        'To learn how to use tally marks to create a frequency table as data is collected.',
    's3_step1_task':
        'When a customer wants a fruit, TAP the \'+\' button in the correct row on the clipboard.',
    's3_step1_out':
        'A diagonal line is drawn for the 5th tally. This helps count by fives!',
    's3_step2_task': 'Continue adding tallies for all customers.',
    's3_step2_out':
        'Tally marks are a fast way to count things. This is called a frequency table.',
    's3_hud1': 'Tap \'+\' to tally the customer\'s choice.',
    's3_hud2': 'Keep tallying the remaining customers.',
    's4_title': '4. The Class Pet Vote',
    's4_obj':
        'To independently collect and organize data into a frequency table using tally marks.',
    's4_step1_task':
        'TAP on a student to ask their choice, then TAP the correct row on your clipboard.',
    's4_step1_out':
        'You have collected raw data and organized it with tallies.',
    's4_step2_task':
        'TAP the \'-\' or \'+\' arrows to set the correct Frequency. Tap \'Check My Work\'.',
    's4_step2_out':
        'You successfully converted tallies into a frequency table!',
    's4_hud1': 'Tap students to reveal pets, then tap clipboard to tally.',
    's4_hud2': 'Set the total frequencies and tap Check.',
    's5_title': '5. Toy Factory Inspector',
    's5_obj':
        'To collect data from a moving source, organize it, and answer questions.',
    's5_step1_task':
        'As each car passes, TAP the button that matches its color to count it.',
    's5_step1_out': 'You built a frequency table in real-time.',
    's5_step2_task':
        'DRAG the icon of the LEAST common car into the answer box.',
    's5_step2_out': 'You found the minimum value.',
    's5_step3_task':
        'DRAG the icon of the MOST common car into the answer box.',
    's5_step3_out':
        'You can easily interpret data when it\'s organized in a table!',
    's5_hud1': 'Tap the matching color button when a car passes.',
    's5_hud2': 'Drag the least common car icon to the box.',
    's5_hud3': 'Drag the most common car icon to the box.',
    'lbl_apples': 'Apples',
    'lbl_bananas': 'Bananas',
    'lbl_oranges': 'Oranges',
    'lbl_tally': 'Tally Marks',
    'lbl_freq': 'Frequency',
    'lbl_fruit': 'Fruit',
    'lbl_pet': 'Pet',
    'lbl_dog': 'Dog',
    'lbl_cat': 'Cat',
    'lbl_fish': 'Fish',
    'lbl_rabbit': 'Rabbit',
    'lbl_check': 'Check My Work',
    'lbl_least': 'Least Common?',
    'lbl_most': 'Most Common?',
    'lbl_raw_data': 'Raw Data',
    'lbl_org_data': 'Organized Data',
    'lbl_car_color': 'Car Color',
  },
  'hi': {
    'shutterTitle': 'आंकड़ों का प्रबंधन',
    'appTitle': 'आंकड़ों का प्रबंधन',
    'appSubtitle': 'कक्षा 6 • व्यस्त फलों की दुकान',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'settings': 'सेटिंग्स',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'doneBtn': 'पूर्ण',
    'learnLbl': 'सीख:',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'resetBtn': 'रीसेट करें',
    'finishLab': 'समाप्त करें',
    'nextScenario': 'अगला परिदृश्य',
    'finalDesc':
        'आपने आंकड़ों को इकट्ठा करना, व्यवस्थित करना और समझना सफलतापूर्वक सीख लिया है!',
    's1_title': '1. अव्यवस्थित फलों की टोकरी',
    's1_obj': 'यह समझना कि अव्यवस्थित वस्तुओं को गिनना मुश्किल और धीमा है।',
    's1_step1_task': 'टोकरी में सभी सेबों पर टैप करके उन्हें गिनें।',
    's1_step1_out': 'जब चीजें मिली-जुली होती हैं तो गिनना मुश्किल होता है!',
    's1_step2_task': 'टोकरी में सभी केलों पर टैप करें।',
    's1_step2_out':
        'यह धीमा और भ्रमित करने वाला था। आंकड़ों को तब समझना मुश्किल है जब वे व्यवस्थित न हों।',
    's1_hud1': 'सभी 10 सेब खोजें और टैप करें।',
    's1_hud2': 'सभी 8 केले खोजें और टैप करें।',
    's2_title': '2. दुकान को व्यवस्थित करना',
    's2_obj':
        'यह सीखना कि समूह बनाकर आंकड़ों को व्यवस्थित करने से गिनना आसान हो जाता है।',
    's2_step1_task':
        'प्रत्येक फल को टोकरी से खींचें (DRAG) और सही क्रेट में छोड़ें (DROP)।',
    's2_step1_out': 'समान वस्तुओं का समूह बनाने से गिनना आसान हो जाता है।',
    's2_step2_task': 'सबसे अधिक फल वाले क्रेट पर टैप करें।',
    's2_step2_out':
        'फलों को व्यवस्थित करके हम आसानी से देख सकते हैं। यह आंकड़ों के प्रबंधन का पहला कदम है!',
    's2_hud1': 'फलों को उनके क्रेट में व्यवस्थित करें।',
    's2_hud2': 'सबसे अधिक फल वाले क्रेट पर टैप करें।',
    's3_title': '3. बिक्री की मिलान (Tally) करें!',
    's3_obj':
        'आंकड़े एकत्र करते समय बारंबारता सारणी बनाने के लिए मिलान चिह्नों का उपयोग करना सीखना।',
    's3_step1_task':
        'जब कोई ग्राहक फल मांगता है, तो क्लिपबोर्ड पर सही पंक्ति में \'+\' बटन पर टैप करें।',
    's3_step1_out':
        '5वें मिलान (tally) के लिए एक तिरछी रेखा खींची जाती है। इससे 5 की गिनती आसान होती है!',
    's3_step2_task': 'सभी ग्राहकों के लिए मिलान (tallies) जोड़ना जारी रखें।',
    's3_step2_out':
        'मिलान चिह्न गिनने का एक तेज़ तरीका है। इसे बारंबारता सारणी कहा जाता है।',
    's3_hud1': 'ग्राहक की पसंद के लिए \'+\' पर टैप करें।',
    's3_hud2': 'बाकी ग्राहकों के लिए मिलान करते रहें।',
    's4_title': '4. कक्षा के पालतू जानवर का वोट',
    's4_obj':
        'मिलान चिह्नों का उपयोग करके स्वतंत्र रूप से आंकड़े एकत्र करना और व्यवस्थित करना।',
    's4_step1_task':
        'छात्र की पसंद पूछने के लिए उस पर टैप करें, फिर क्लिपबोर्ड पर सही पंक्ति पर टैप करें।',
    's4_step1_out':
        'आपने कच्चे आंकड़े एकत्र किए और मिलान (tallies) के साथ व्यवस्थित किए।',
    's4_step2_task':
        'बारंबारता सेट करने के लिए \'-\' या \'+\' तीर टैप करें। \'Check My Work\' टैप करें।',
    's4_step2_out': 'आपने सफलतापूर्वक मिलान को बारंबारता सारणी में बदल दिया!',
    's4_hud1': 'छात्रों पर टैप करें, फिर क्लिपबोर्ड पर टैप करें।',
    's4_hud2': 'कुल बारंबारता सेट करें और Check पर टैप करें।',
    's5_title': '5. खिलौना फैक्ट्री इंस्पेक्टर',
    's5_obj':
        'चलते हुए स्रोत से आंकड़े एकत्र करना, व्यवस्थित करना और उत्तर देना।',
    's5_step1_task':
        'जैसे ही प्रत्येक कार गुजरती है, उसे गिनने के लिए उसके रंग वाले बटन पर टैप करें।',
    's5_step1_out': 'आपने वास्तविक समय में एक बारंबारता सारणी बनाई।',
    's5_step2_task': 'सबसे कम सामान्य कार के आइकन को उत्तर बॉक्स में खींचें।',
    's5_step2_out': 'आपने न्यूनतम मूल्य खोज लिया।',
    's5_step3_task': 'सबसे अधिक सामान्य कार के आइकन को उत्तर बॉक्स में खींचें।',
    's5_step3_out':
        'जब आंकड़े व्यवस्थित होते हैं out तो आप आसानी से समझ सकते हैं!',
    's5_hud1': 'कार के रंग से मेल खाने वाले बटन पर टैप करें।',
    's5_hud2': 'सबसे कम सामान्य कार के आइकन को बॉक्स में खींचें।',
    's5_hud3': 'सबसे अधिक सामान्य कार के आइकन को बॉक्स में खींचें।',
    'lbl_apples': 'सेब',
    'lbl_bananas': 'केले',
    'lbl_oranges': 'संतरे',
    'lbl_tally': 'मिलान चिह्न',
    'lbl_freq': 'बारंबारता',
    'lbl_fruit': 'फल',
    'lbl_pet': 'पालतू',
    'lbl_dog': 'कुत्ता',
    'lbl_cat': 'बिल्ली',
    'lbl_fish': 'मछली',
    'lbl_rabbit': 'खरगोश',
    'lbl_check': 'उत्तर जांचें',
    'lbl_least': 'सबसे कम?',
    'lbl_most': 'सबसे अधिक?',
    'lbl_raw_data': 'कच्चे आंकड़े',
    'lbl_org_data': 'व्यवस्थित आंकड़े',
    'lbl_car_color': 'कार का रंग',
  },
};

// --- DATA MODELS ---
class LabEntity {
  double x, y;
  String type;
  bool clicked;
  bool inCrate;
  LabEntity({
    required this.x,
    required this.y,
    required this.type,
    this.clicked = false,
    this.inCrate = false,
  });
}

class Student {
  double x, y;
  String pet;
  bool asked;
  Student({
    required this.x,
    required this.y,
    required this.pet,
    this.asked = false,
  });
}

class Car {
  double x;
  String color;
  Car({required this.x, required this.color});
}

// --- AUDIO ENGINE ---
class AudioEngine {
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // 1. Child friendly click tone
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // 2. Play a sound when a new page opens (Swoosh/Chime)
  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // 3. Play the Dropdown sound
  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // 4. Play an error sound (Soft thud)
  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // 5. Curtain screen sound
  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- MAIN APP ---
class Cl6M_Ch4_A1_CollectingandOrganizingData extends StatefulWidget {
  const Cl6M_Ch4_A1_CollectingandOrganizingData({Key? key}) : super(key: key);
  @override
  _Cl6M_Ch4_A1_CollectingandOrganizingDataState createState() =>
      _Cl6M_Ch4_A1_CollectingandOrganizingDataState();
}

class _Cl6M_Ch4_A1_CollectingandOrganizingDataState
    extends State<Cl6M_Ch4_A1_CollectingandOrganizingData>
    with SingleTickerProviderStateMixin {
  final AudioEngine _audio = AudioEngine();
  late AnimationController _tickController;
  final GlobalKey _canvasKey = GlobalKey();

  String _lang = 'en';
  bool _showCurtain = true;
  bool _showSuccessPopup = false;

  double _sidebarWidth = 350.0;
  bool _sidebarOpen = true;
  bool _isDraggingSidebar = false;

  // Camera state
  double _zoom = 1.0;
  double _initialZoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;

  // Game state
  int _scenario = 1;
  int _step = 0;

  // Scen 1
  final List<LabEntity> _s1Fruits = [];
  Map<String, int> _s1Counts = {'apple': 0, 'banana': 0, 'orange': 0};

  // Scen 2
  final List<LabEntity> _s2Fruits = [];
  Map<String, int> _s2Crates = {'apple': 0, 'banana': 0, 'orange': 0};

  // Scen 3
  final List<String> _s3CustQueue = [];
  int _s3CustIdx = 0;
  Map<String, int> _s3Tallies = {'apple': 0, 'banana': 0, 'orange': 0};

  // Scen 4
  final List<Student> _s4Students = [];
  Map<String, int> _s4Tallies = {'dog': 0, 'cat': 0, 'fish': 0, 'rabbit': 0};
  int? _s4SelectedStudent;
  Map<String, int> _s4UserFreq = {'dog': 0, 'cat': 0, 'fish': 0, 'rabbit': 0};

  // Scen 5
  final List<Car> _s5Cars = [];
  int _s5CarIdx = 0;
  Map<String, int> _s5Tallies = {'red': 0, 'blue': 0, 'green': 0};
  double _s5BeltOffset = 0.0;
  Map<int, String?> _s5Answered = {1: null, 2: null};
  bool _s5Animating = false;

  // Dragging interaction state
  int? _activeDragEntityIdx;
  String? _dragType;
  Offset _dragPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _tickController.addListener(() {
      setState(() {
        if (_scenario == 5) _s5BeltOffset += 1.5;
        if (_scenario == 5 && _step == 0 && _s5CarIdx < _s5Cars.length) {
          if (_s5Cars[_s5CarIdx].x < 0) _s5Cars[_s5CarIdx].x += 4;
        }
      });
    });

    _loadScenario(1, playSound: false);
  }

  @override
  void dispose() {
    _tickController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String t(String key) => tMap[_lang]?[key] ?? key;

  void _enforceImmersive() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _toggleLang() {
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
      _audio.playDropdown();
    });
  }

  void _loadScenario(int id, {bool playSound = true}) {
    if (playSound) _audio.playPageOpen();
    setState(() {
      _scenario = id;
      _step = 0;
      _showSuccessPopup = false;
      _zoom = 0.8;
      _panX = 0;
      _panY = 0;

      final rand = Random();
      if (id == 1) {
        _s1Counts = {'apple': 0, 'banana': 0, 'orange': 0};
        _s1Fruits.clear();
        for (int i = 0; i < 10; i++) {
          _s1Fruits.add(
            LabEntity(
              x: -160 + rand.nextDouble() * 320,
              y: -110 + rand.nextDouble() * 220,
              type: 'apple',
            ),
          );
        }
        for (int i = 0; i < 8; i++) {
          _s1Fruits.add(
            LabEntity(
              x: -160 + rand.nextDouble() * 320,
              y: -110 + rand.nextDouble() * 220,
              type: 'banana',
            ),
          );
        }
        for (int i = 0; i < 6; i++) {
          _s1Fruits.add(
            LabEntity(
              x: -160 + rand.nextDouble() * 320,
              y: -110 + rand.nextDouble() * 220,
              type: 'orange',
            ),
          );
        }
        _s1Fruits.shuffle();
      } else if (id == 2) {
        _s2Crates = {'apple': 0, 'banana': 0, 'orange': 0};
        _s2Fruits.clear();
        for (int i = 0; i < 10; i++) {
          _s2Fruits.add(
            LabEntity(
              x: -360 + rand.nextDouble() * 220,
              y: -110 + rand.nextDouble() * 220,
              type: 'apple',
            ),
          );
        }
        for (int i = 0; i < 8; i++) {
          _s2Fruits.add(
            LabEntity(
              x: -360 + rand.nextDouble() * 220,
              y: -110 + rand.nextDouble() * 220,
              type: 'banana',
            ),
          );
        }
        for (int i = 0; i < 6; i++) {
          _s2Fruits.add(
            LabEntity(
              x: -360 + rand.nextDouble() * 220,
              y: -110 + rand.nextDouble() * 220,
              type: 'orange',
            ),
          );
        }
        _s2Fruits.shuffle();
      } else if (id == 3) {
        _s3CustIdx = 0;
        _s3Tallies = {'apple': 0, 'banana': 0, 'orange': 0};
        _s3CustQueue.clear();
        List<String> options = [
          'apple',
          'apple',
          'banana',
          'orange',
          'apple',
          'banana',
          'orange',
          'apple',
        ];
        for (int i = 0; i < 6; i++) {
          _s3CustQueue.add(options[rand.nextInt(options.length)]);
        }
      } else if (id == 4) {
        _s4SelectedStudent = null;
        _s4Tallies = {'dog': 0, 'cat': 0, 'fish': 0, 'rabbit': 0};
        _s4UserFreq = {'dog': 0, 'cat': 0, 'fish': 0, 'rabbit': 0};
        _s4Students.clear();
        List<String> pets = ['dog', 'cat', 'fish', 'rabbit'];
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 5; c++) {
            _s4Students.add(
              Student(
                x: -400.0 + c * 90,
                y: -100.0 + r * 100,
                pet: pets[rand.nextInt(pets.length)],
              ),
            );
          }
        }
      } else if (id == 5) {
        _s5CarIdx = 0;
        _s5Tallies = {'red': 0, 'blue': 0, 'green': 0};
        _s5Cars.clear();
        _s5Answered = {1: null, 2: null};
        _s5Animating = false;
        List<String> colors = [
          'red',
          'red',
          'blue',
          'green',
          'green',
          'blue',
          'red',
          'green',
          'red',
        ];
        for (int i = 0; i < 20; i++) {
          _s5Cars.add(
            Car(x: -600.0, color: colors[rand.nextInt(colors.length)]),
          );
        }
      }
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _checkScenarioComplete() {
    int maxSteps =
        (_scenario == 1 || _scenario == 2 || _scenario == 4 || _scenario == 3)
        ? 2
        : 3;
    if (_step >= maxSteps) {
      _audio.playPageOpen();
      setState(() {
        _showSuccessPopup = true;
      });
    }
  }

  Offset _screenToWorld(Offset screenPoint) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    final size = renderBox.size;
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((screenPoint.dx - cx) / _zoom, (screenPoint.dy - cy) / _zoom);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  bool _hitTestCircle(double x, double y, double r, Offset pt) {
    double dx = pt.dx - x;
    double dy = pt.dy - y;
    return dx * dx + dy * dy < r * r;
  }

  void _handlePointerDown(PointerDownEvent event) {
    Offset pt = _screenToWorld(event.localPosition);
    bool actionHandled = false;

    setState(() {
      if (_scenario == 1) {
        for (var f in _s1Fruits) {
          if (!f.clicked && _hitTestCircle(f.x, f.y, 40, pt)) {
            actionHandled = true;
            if ((_step == 0 && f.type == 'apple') ||
                (_step == 1 && f.type == 'banana')) {
              f.clicked = true;
              _s1Counts[f.type] = (_s1Counts[f.type] ?? 0) + 1;
              _audio.playClick();
              if (_step == 0 && _s1Counts['apple']! >= 10) {
                _audio.playPageOpen();
                _advanceStep();
              } else if (_step == 1 && _s1Counts['banana']! >= 8) {
                _advanceStep();
                Future.delayed(
                  const Duration(milliseconds: 500),
                  _checkScenarioComplete,
                );
              }
            } else {
              _audio.playError();
            }
          }
        }
      } else if (_scenario == 2) {
        if (_step == 1) {
          if (_hitTestBox(50, -160, 400, 80, pt)) {
            actionHandled = true;
            _advanceStep();
            _audio.playPageOpen();
            Future.delayed(
              const Duration(milliseconds: 500),
              _checkScenarioComplete,
            );
          } else if (_hitTestBox(50, -40, 400, 80, pt) ||
              _hitTestBox(50, 80, 400, 80, pt)) {
            actionHandled = true;
            _audio.playError();
          }
        }
      } else if (_scenario == 3) {
        if (_step == 0 && _s3CustIdx < _s3CustQueue.length) {
          String want = _s3CustQueue[_s3CustIdx];
          double rowY = -70;
          List<String> fruits = ['apple', 'banana', 'orange'];
          for (int i = 0; i < 3; i++) {
            if (_hitTestBox(350, rowY - 20, 40, 40, pt)) {
              actionHandled = true;
              if (fruits[i] == want) {
                _s3Tallies[want] = (_s3Tallies[want] ?? 0) + 1;
                _s3CustIdx++;
                _audio.playClick();
                if (_s3CustIdx >= _s3CustQueue.length) {
                  _advanceStep();
                  _audio.playPageOpen();
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    _checkScenarioComplete,
                  );
                }
              } else {
                _audio.playError();
              }
            }
            rowY += 80;
          }
        }
      } else if (_scenario == 4) {
        if (_step == 0) {
          // Select student
          for (int i = 0; i < _s4Students.length; i++) {
            if (!_s4Students[i].asked &&
                _hitTestCircle(_s4Students[i].x, _s4Students[i].y, 40, pt)) {
              _s4SelectedStudent = i;
              actionHandled = true;
              _audio.playClick();
              break;
            }
          }
          // Tap row
          if (!actionHandled && _s4SelectedStudent != null) {
            String p = _s4Students[_s4SelectedStudent!].pet;
            double rowY = -90;
            List<String> pets = ['dog', 'cat', 'fish', 'rabbit'];
            for (int i = 0; i < 4; i++) {
              if (_hitTestBox(170, rowY - 25, 260, 50, pt)) {
                actionHandled = true;
                if (pets[i] == p) {
                  _s4Tallies[p] = (_s4Tallies[p] ?? 0) + 1;
                  _s4Students[_s4SelectedStudent!].asked = true;
                  _s4SelectedStudent = null;
                  _audio.playClick();
                  bool allAsked = _s4Students.every((s) => s.asked);
                  if (allAsked) {
                    _advanceStep();
                    _audio.playPageOpen();
                  }
                } else {
                  _audio.playError();
                }
                break;
              }
              rowY += 50;
            }
          }
        } else if (_step == 1) {
          // User input frequencies
          List<String> pList = ['dog', 'cat', 'fish', 'rabbit'];
          double rowY = -90;
          for (int i = 0; i < 4; i++) {
            if (_hitTestBox(350, rowY - 15, 30, 30, pt)) {
              // Decrement left box half
              actionHandled = true;
              _s4UserFreq[pList[i]] = max(0, (_s4UserFreq[pList[i]] ?? 0) - 1);
              _audio.playClick();
              break;
            } else if (_hitTestBox(380, rowY - 15, 30, 30, pt)) {
              // Increment right box half
              actionHandled = true;
              _s4UserFreq[pList[i]] = min(20, (_s4UserFreq[pList[i]] ?? 0) + 1);
              _audio.playClick();
              break;
            }
            rowY += 50;
          }
          // Check button
          if (!actionHandled && _hitTestBox(200, 140, 160, 40, pt)) {
            actionHandled = true;
            bool allCorrect = true;
            for (var pet in pList) {
              if (_s4UserFreq[pet] != _s4Tallies[pet]) allCorrect = false;
            }
            if (allCorrect) {
              _advanceStep();
              _audio.playPageOpen();
              Future.delayed(
                const Duration(milliseconds: 500),
                _checkScenarioComplete,
              );
            } else {
              _audio.playError();
            }
          }
        }
      } else if (_scenario == 5) {
        if (_step == 0 && _s5CarIdx < _s5Cars.length) {
          var c = _s5Cars[_s5CarIdx];
          if (c.x >= 0) {
            List<String> colors = ['red', 'blue', 'green'];
            for (int i = 0; i < 3; i++) {
              double bx = -130.0 + i * 130;
              if (_hitTestBox(bx - 40, 120, 80, 80, pt)) {
                actionHandled = true;
                if (colors[i] == c.color) {
                  _s5Tallies[c.color] = (_s5Tallies[c.color] ?? 0) + 1;
                  _s5CarIdx++;
                  _audio.playClick();
                  if (_s5CarIdx >= _s5Cars.length) {
                    _advanceStep();
                    _audio.playPageOpen();
                  }
                } else {
                  _audio.playError();
                }
              }
            }
          }
        }
      }
    });

    if (!actionHandled) {
      _audio.playClick(); // General canvas tap fallback
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount > 1) {
      _activeDragEntityIdx = null; // stop drag if pinch
    }

    _initialZoom = _zoom;
    Offset pt = _screenToWorld(details.localFocalPoint);

    setState(() {
      if (_scenario == 2 && _step == 0) {
        for (int i = _s2Fruits.length - 1; i >= 0; i--) {
          var f = _s2Fruits[i];
          if (!f.inCrate && _hitTestCircle(f.x, f.y, 40, pt)) {
            _activeDragEntityIdx = i;
            _dragType = f.type;
            _dragPos = pt;
            _audio.playClick();
            return;
          }
        }
      } else if (_scenario == 5 && _step >= 1 && !_s5Animating) {
        List<String> colors = ['red', 'blue', 'green'];
        for (int i = 0; i < 3; i++) {
          double ix = 380.0 + i * 70;
          if (_hitTestBox(ix - 40, 40, 80, 60, pt)) {
            _activeDragEntityIdx = 999; // arbitrary token
            _dragType = colors[i];
            _dragPos = pt;
            _audio.playClick();
            return;
          }
        }
      }
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_activeDragEntityIdx != null && details.pointerCount == 1) {
      setState(() {
        _dragPos = _screenToWorld(details.localFocalPoint);
      });
    } else {
      setState(() {
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;

        if (details.scale != 1.0) {
          double oldZoom = _zoom;
          _zoom = (_initialZoom * details.scale).clamp(0.4, 2.5);

          final RenderBox? renderBox =
              _canvasKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            Offset center = Offset(
              renderBox.size.width / 2,
              renderBox.size.height / 2,
            );
            Offset focal = details.localFocalPoint - center;
            _panX -= focal.dx * (_zoom / oldZoom - 1);
            _panY -= focal.dy * (_zoom / oldZoom - 1);
          }
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_activeDragEntityIdx != null) {
      Offset pt = _dragPos;
      setState(() {
        if (_scenario == 2 && _step == 0) {
          bool dropped = false;
          List<Map<String, dynamic>> crates = [
            {'id': 'apple', 'y': -160.0},
            {'id': 'banana', 'y': -40.0},
            {'id': 'orange', 'y': 80.0},
          ];
          for (var c in crates) {
            if (_hitTestBox(50, c['y'], 400, 80, pt)) {
              if (c['id'] == _dragType) {
                _s2Crates[_dragType!] = (_s2Crates[_dragType!] ?? 0) + 1;
                _s2Fruits[_activeDragEntityIdx!].inCrate = true;
                _audio.playClick();
                dropped = true;
                int total = _s2Crates.values.fold(0, (sum, val) => sum + val);
                if (total >= _s2Fruits.length) {
                  _advanceStep();
                  _audio.playPageOpen();
                }
              } else {
                _audio.playError();
                dropped = true; // prevent tick
              }
            }
          }
          if (!dropped) _audio.playClick();
        } else if (_scenario == 5 && _step >= 1) {
          if (_hitTestBox(-325, -130, 100, 60, pt)) {
            int minV = _s5Tallies.values.reduce(min);
            int maxV = _s5Tallies.values.reduce(max);
            int val = _s5Tallies[_dragType!] ?? 0;
            if (_step == 1 && val == minV) {
              _s5Answered[1] = _dragType;
              _s5Animating = true;
              _audio.playPageOpen();
              Future.delayed(const Duration(milliseconds: 1200), () {
                setState(() {
                  _s5Animating = false;
                  _advanceStep();
                });
              });
            } else if (_step == 2 && val == maxV) {
              _s5Answered[2] = _dragType;
              _s5Animating = true;
              _audio.playPageOpen();
              Future.delayed(const Duration(milliseconds: 1200), () {
                setState(() {
                  _s5Animating = false;
                  _advanceStep();
                  _checkScenarioComplete();
                });
              });
            } else {
              _audio.playError();
            }
          } else {
            _audio.playClick();
          }
        }
        _activeDragEntityIdx = null;
        _dragType = null;
      });
    }
  }

  Widget _buildSidebarItem(int index, String hud, String task, String out) {
    bool isCompleted = index < _step;
    bool isActive = index == _step;
    bool isFuture = index > _step;

    Color bgColor = isFuture
        ? const Color(0xFF1E293B).withOpacity(0.5)
        : (isActive
              ? const Color(0xFF312E81)
              : const Color(0xFF064E3B).withOpacity(0.6));
    Color borderColor = isActive
        ? const Color(0xFF6366F1)
        : (isCompleted ? const Color(0xFF10B981) : Colors.transparent);
    Color textColor = isFuture ? Colors.grey : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompleted)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24)
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF334155),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
                  '${t('stepLabel')} ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Action: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: task),
                    ],
                  ),
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF022C22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${t('learnLbl')} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: out),
                        ],
                      ),
                      style: const TextStyle(
                        color: Color(0xFF6EE7B7),
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
    );
  }

  String _getHudText() {
    int maxSteps =
        (_scenario == 1 || _scenario == 2 || _scenario == 4 || _scenario == 3)
        ? 2
        : 3;
    if (_step >= maxSteps) return "";
    return t('s${_scenario}_hud${_step + 1}');
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;

    String currentHud = _getHudText();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _enforceImmersive,
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Layer
            AnimatedPositioned(
              duration: Duration(milliseconds: _isDraggingSidebar ? 0 : 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Listener(
                onPointerDown: _handlePointerDown,
                child: GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: ClipRect(
                    child: Container(
                      key: _canvasKey,
                      color: const Color(0xFF0F172A), // Dark canvas background
                      child: CustomPaint(
                        painter: LabPainter(
                          lang: _lang,
                          tMap: tMap,
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          scenario: _scenario,
                          step: _step,
                          s1Fruits: _s1Fruits,
                          s1Counts: _s1Counts,
                          s2Fruits: _s2Fruits,
                          s2Crates: _s2Crates,
                          s3CustQueue: _s3CustQueue,
                          s3CustIdx: _s3CustIdx,
                          s3Tallies: _s3Tallies,
                          s4Students: _s4Students,
                          s4Tallies: _s4Tallies,
                          s4SelectedStudent: _s4SelectedStudent,
                          s4UserFreq: _s4UserFreq,
                          s5Cars: _s5Cars,
                          s5CarIdx: _s5CarIdx,
                          s5Tallies: _s5Tallies,
                          s5BeltOffset: _s5BeltOffset,
                          s5Answered: _s5Answered,
                          activeDragEntityIdx: _activeDragEntityIdx,
                          dragType: _dragType,
                          dragPos: _dragPos,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar Layer
            AnimatedPositioned(
              duration: Duration(milliseconds: _isDraggingSidebar ? 0 : 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 66,
                          bottom: 16,
                        ),
                        color: const Color(0xFF0F172A),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.bar_chart,
                                            color: Color(0xFF6366F1),
                                            size: 30,
                                          ),
                                          Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        t('appSubtitle'),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
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
                                IconButton(
                                  icon: Row(
                                    children: [
                                      const Icon(
                                        Icons.language,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _lang.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: _toggleLang,
                                  tooltip: 'Toggle Language',
                                ),

                                IconButton(
                                  icon: Row(
                                    children: [
                                      const Icon(
                                        Icons.refresh,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        t('resetBtn'),
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    _audio.playDropdown();
                                    setState(() {
                                      _showCurtain = true;
                                    });
                                    _loadScenario(1);
                                  },
                                  tooltip: t('resetBtn'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Scrollable content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('selectScenario'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF334155),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _audio.playDropdown();
                                      _loadScenario(val);
                                    }
                                  },
                                  items: [1, 2, 3, 4, 5]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            t('s${e}_title'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location,
                                        color: Colors.pinkAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Objective:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t('s${_scenario}_obj'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Steps
                            _buildSidebarItem(
                              0,
                              t('s${_scenario}_hud1'),
                              t('s${_scenario}_step1_task'),
                              t('s${_scenario}_step1_out'),
                            ),
                            if (_scenario != 5)
                              _buildSidebarItem(
                                1,
                                t('s${_scenario}_hud2'),
                                t('s${_scenario}_step2_task'),
                                t('s${_scenario}_step2_out'),
                              ),
                            if (_scenario == 5)
                              _buildSidebarItem(
                                1,
                                t('s${_scenario}_hud2'),
                                t('s${_scenario}_step2_task'),
                                t('s${_scenario}_step2_out'),
                              ),
                            if (_scenario == 5)
                              _buildSidebarItem(
                                2,
                                t('s${_scenario}_hud3'),
                                t('s${_scenario}_step3_task'),
                                t('s${_scenario}_step3_out'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            color: const Color(0xFF0F172A),
                            child: const Text(
                              '© ZeroScienceLab - Fall in love with math and Science',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
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

            // Sidebar Resizer Handle
            AnimatedPositioned(
              duration: Duration(milliseconds: _isDraggingSidebar ? 0 : 300),
              curve: Curves.easeInOut,
              left: (_sidebarOpen ? _sidebarWidth : 0) - 10,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) {
                  setState(() {
                    _isDraggingSidebar = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    _sidebarWidth = _sidebarWidth.clamp(300.0, sw * 0.6);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDraggingSidebar = false;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    color: Colors.transparent,
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
              ),
            ),

            // Menu Toggle Button - Fixed at Top Left
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  setState(() {
                    _sidebarOpen = !_sidebarOpen;
                    _audio.playClick();
                  });
                },
              ),
            ),

            // HUD
            if (currentHud.isNotEmpty)
              AnimatedPositioned(
                duration: Duration(milliseconds: _isDraggingSidebar ? 0 : 300),
                curve: Curves.easeInOut,
                bottom: 30,
                left: _sidebarOpen ? _sidebarWidth : 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6366F1), width: 3),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info,
                            color: Color(0xFF818CF8),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              currentHud,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

            // Curtain Layer
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(minHeight: sh),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF6366F1),
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.bar_chart,
                              color: Color(0xFF6366F1),
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            t('shutterTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                            ),
                            onPressed: () {
                              _audio.curtainScreen();
                              setState(() => _showCurtain = false);
                            },
                            icon: const Icon(Icons.play_circle_fill, size: 28),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 20,
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

            // Success Popup
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x6610B981),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('finalDesc'),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _scenario < 5
                                  ? const Color(0xFF6366F1)
                                  : Colors.amber,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              _audio.playClick();
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                _loadScenario(1);
                                setState(() => _showCurtain = true);
                              }
                            },
                            icon: Icon(
                              _scenario < 5
                                  ? Icons.arrow_forward
                                  : Icons.refresh,
                            ),
                            label: Text(
                              _scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
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
          ],
        ),
      ),
    );
  }
}

// --- CANVAS PAINTER ---
class LabPainter extends CustomPainter {
  final String lang;
  final Map<String, Map<String, String>> tMap;
  final double zoom;
  final double panX;
  final double panY;

  final int scenario;
  final int step;

  final List<LabEntity> s1Fruits;
  final Map<String, int> s1Counts;

  final List<LabEntity> s2Fruits;
  final Map<String, int> s2Crates;

  final List<String> s3CustQueue;
  final int s3CustIdx;
  final Map<String, int> s3Tallies;

  final List<Student> s4Students;
  final Map<String, int> s4Tallies;
  final int? s4SelectedStudent;
  final Map<String, int> s4UserFreq;

  final List<Car> s5Cars;
  final int s5CarIdx;
  final Map<String, int> s5Tallies;
  final double s5BeltOffset;
  final Map<int, String?> s5Answered;

  final int? activeDragEntityIdx;
  final String? dragType;
  final Offset dragPos;

  LabPainter({
    required this.lang,
    required this.tMap,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.scenario,
    required this.step,
    required this.s1Fruits,
    required this.s1Counts,
    required this.s2Fruits,
    required this.s2Crates,
    required this.s3CustQueue,
    required this.s3CustIdx,
    required this.s3Tallies,
    required this.s4Students,
    required this.s4Tallies,
    required this.s4SelectedStudent,
    required this.s4UserFreq,
    required this.s5Cars,
    required this.s5CarIdx,
    required this.s5Tallies,
    required this.s5BeltOffset,
    required this.s5Answered,
    this.activeDragEntityIdx,
    this.dragType,
    required this.dragPos,
  });

  String t(String key) => tMap[lang]?[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderS1(canvas);
    } else if (scenario == 2) {
      _renderS2(canvas);
    } else if (scenario == 3) {
      _renderS3(canvas);
    } else if (scenario == 4) {
      _renderS4(canvas);
    } else if (scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  // Draw Helpers
  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke, [
    double sw = 1.0,
  ]) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && sw > 0) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
    }
  }

  void _drawTextWithOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fill, [
    TextAlign align = TextAlign.center,
    FontWeight weight = FontWeight.bold,
  ]) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fill,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    double dx = x;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, y - tp.height / 2));
  }

  void _drawEmoji(
    Canvas canvas,
    String emoji,
    double x,
    double y,
    double size,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawApple(Canvas canvas, double x, double y, double size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(size / 40.0);

    // Shadow
    canvas.drawCircle(
      const Offset(0, 5),
      20,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Body
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()
        ..color = const Color(0xFF991B1B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Stem
    canvas.drawRect(
      const Rect.fromLTWH(-2, -28, 4, 12),
      Paint()..color = const Color(0xFF78350F),
    );
    // Leaf
    canvas.drawOval(
      const Rect.fromLTWH(0, -29, 16, 8),
      Paint()..color = const Color(0xFF22C55E),
    );
    canvas.drawOval(
      const Rect.fromLTWH(0, -29, 16, 8),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  void _drawBanana(Canvas canvas, double x, double y, double size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(size / 40.0);

    canvas.drawCircle(
      const Offset(0, 5),
      15,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    Path path = Path();
    path.moveTo(-20, -15);
    path.quadraticBezierTo(0, 25, 20, 15);
    path.quadraticBezierTo(5, 10, -20, -15);
    canvas.drawPath(path, Paint()..color = const Color(0xFFFACC15));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFCA8A04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(-18, -13),
      3,
      Paint()..color = const Color(0xFF166534),
    );

    canvas.restore();
  }

  void _drawOrange(Canvas canvas, double x, double y, double size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(size / 40.0);

    canvas.drawCircle(
      const Offset(0, 5),
      18,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset.zero,
      18,
      Paint()..color = const Color(0xFFF97316),
    );
    canvas.drawCircle(
      Offset.zero,
      18,
      Paint()
        ..color = const Color(0xFFC2410C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(0, -16),
      2,
      Paint()..color = const Color(0xFF22C55E),
    );

    canvas.restore();
  }

  void _drawCar(Canvas canvas, double x, double y, String color, double size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(size / 60.0);

    Color fill = color == 'red'
        ? const Color(0xFFEF4444)
        : (color == 'blue' ? const Color(0xFF3B82F6) : const Color(0xFF22C55E));
    Color stroke = const Color(0xFF0F172A);

    _drawRoundedRect(canvas, -30, -10, 60, 20, 5, fill, stroke, 3);
    _drawRoundedRect(canvas, -15, -25, 30, 20, 5, fill, stroke, 3);

    canvas.drawRect(
      const Rect.fromLTWH(-10, -20, 8, 10),
      Paint()..color = const Color(0xFFE0F2FE),
    );
    canvas.drawRect(
      const Rect.fromLTWH(2, -20, 8, 10),
      Paint()..color = const Color(0xFFE0F2FE),
    );

    canvas.drawCircle(
      const Offset(-15, 10),
      8,
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(
      const Offset(-15, 10),
      8,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(15, 10),
      8,
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(
      const Offset(15, 10),
      8,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();
  }

  void _drawTallyMarks(Canvas canvas, double x, double y, int count) {
    final Paint p = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    int groups = count ~/ 5;
    int rem = count % 5;

    for (int g = 0; g < groups; g++) {
      double bx = x + g * 35;
      for (int i = 0; i < 4; i++) {
        canvas.drawLine(
          Offset(bx + i * 6, y - 12),
          Offset(bx + i * 6, y + 12),
          p,
        );
      }
      canvas.drawLine(Offset(bx - 4, y + 15), Offset(bx + 22, y - 15), p);
    }
    double bx = x + groups * 35;
    for (int i = 0; i < rem; i++) {
      canvas.drawLine(
        Offset(bx + i * 6, y - 12),
        Offset(bx + i * 6, y + 12),
        p,
      );
    }
  }

  void _drawFruitHighlight(Canvas canvas, double x, double y) {
    canvas.drawCircle(
      Offset(x + 15, y - 15),
      10,
      Paint()..color = const Color(0xFF22C55E),
    );
    final Path path = Path()
      ..moveTo(x + 10, y - 15)
      ..lineTo(x + 14, y - 11)
      ..lineTo(x + 20, y - 19);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  // SCENARIO 1
  void _renderS1(Canvas canvas) {
    // Basket background
    _drawRoundedRect(
      canvas,
      -200,
      -150,
      400,
      300,
      20,
      const Color(0xFFD97706),
      const Color(0xFF92400E),
      6,
    );
    _drawRoundedRect(
      canvas,
      -180,
      -130,
      360,
      260,
      10,
      const Color(0xFFB45309),
      Colors.transparent,
    );

    for (var f in s1Fruits) {
      int a = f.clicked ? 75 : 255;
      canvas.saveLayer(
        Rect.fromLTWH(-500, -500, 1000, 1000),
        Paint()..color = Color.fromARGB(a, 255, 255, 255),
      );
      if (f.type == 'apple') {
        _drawApple(canvas, f.x, f.y, 45);
      } else if (f.type == 'banana') {
        _drawBanana(canvas, f.x, f.y, 45);
      } else {
        _drawOrange(canvas, f.x, f.y, 45);
      }
      canvas.restore();
      if (f.clicked) _drawFruitHighlight(canvas, f.x, f.y);
    }

    bool isApples = step == 0;
    int cur = isApples ? (s1Counts['apple'] ?? 0) : (s1Counts['banana'] ?? 0);
    int tot = isApples ? 10 : 8;
    String text = isApples ? "Apples: $cur / $tot" : "Bananas: $cur / $tot";

    _drawRoundedRect(
      canvas,
      -150,
      -250,
      300,
      70,
      35,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      4,
    );
    _drawTextWithOutline(canvas, text, 0, -215, 24, const Color(0xFF0F172A));
    if (isApples) {
      _drawApple(canvas, -100, -215, 30);
    } else {
      _drawBanana(canvas, -100, -215, 30);
    }
  }

  // SCENARIO 2
  void _renderS2(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -400,
      -150,
      300,
      300,
      20,
      const Color(0xFFD97706),
      const Color(0xFF92400E),
      6,
    );
    _drawTextWithOutline(
      canvas,
      t('lbl_raw_data'),
      -250,
      -180,
      20,
      Colors.white,
    );

    for (int i = 0; i < s2Fruits.length; i++) {
      var f = s2Fruits[i];
      if (!f.inCrate && activeDragEntityIdx != i) {
        if (f.type == 'apple') {
          _drawApple(canvas, f.x, f.y, 40);
        } else if (f.type == 'banana') {
          _drawBanana(canvas, f.x, f.y, 40);
        } else {
          _drawOrange(canvas, f.x, f.y, 40);
        }
      }
    }

    _drawTextWithOutline(
      canvas,
      t('lbl_org_data'),
      250,
      -180,
      20,
      Colors.white,
    );

    List<Map<String, dynamic>> crates = [
      {'id': 'apple', 'lbl': t('lbl_apples'), 'y': -120.0},
      {'id': 'banana', 'lbl': t('lbl_bananas'), 'y': 0.0},
      {'id': 'orange', 'lbl': t('lbl_oranges'), 'y': 120.0},
    ];

    for (var c in crates) {
      double cy = c['y'];
      bool isTarget = step == 1 && c['id'] == 'apple';

      if (isTarget) {
        canvas.drawRect(
          Rect.fromLTWH(40, cy - 50, 420, 100),
          Paint()
            ..color = Colors.yellow.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
        );
      }

      _drawRoundedRect(
        canvas,
        50,
        cy - 40,
        400,
        80,
        10,
        const Color(0xFFE2E8F0),
        const Color(0xFF94A3B8),
        4,
      );
      _drawTextWithOutline(
        canvas,
        c['lbl'],
        110,
        cy,
        18,
        const Color(0xFF0F172A),
      );
      _drawRoundedRect(
        canvas,
        180,
        cy - 30,
        250,
        60,
        5,
        const Color(0xFFCBD5E1),
        Colors.transparent,
      );

      int count = s2Crates[c['id']] ?? 0;
      for (int i = 0; i < count; i++) {
        double fx = 210.0 + (i % 7) * 35;
        double fy = cy - 15 + (i ~/ 7) * 25;
        if (c['id'] == 'apple') {
          _drawApple(canvas, fx, fy, 30);
        } else if (c['id'] == 'banana') {
          _drawBanana(canvas, fx, fy, 30);
        } else {
          _drawOrange(canvas, fx, fy, 30);
        }
      }

      _drawRoundedRect(
        canvas,
        440,
        cy - 25,
        50,
        50,
        25,
        const Color(0xFF334155),
        Colors.transparent,
      );
      _drawTextWithOutline(canvas, count.toString(), 465, cy, 20, Colors.white);
    }

    if (activeDragEntityIdx != null && dragType != null) {
      if (dragType == 'apple') {
        _drawApple(canvas, dragPos.dx, dragPos.dy, 50);
      } else if (dragType == 'banana') {
        _drawBanana(canvas, dragPos.dx, dragPos.dy, 50);
      } else {
        _drawOrange(canvas, dragPos.dx, dragPos.dy, 50);
      }
    }
  }

  // SCENARIO 3
  void _renderS3(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -500,
      50,
      1000,
      300,
      0,
      const Color(0xFF8B5A2B),
      const Color(0xFF3F2A14),
      6,
    );

    if (s3CustIdx < s3CustQueue.length) {
      String want = s3CustQueue[s3CustIdx];
      canvas.drawCircle(
        const Offset(-200, -50),
        40,
        Paint()..color = const Color(0xFFFBBF24),
      );
      _drawRoundedRect(
        canvas,
        -240,
        -10,
        80,
        100,
        20,
        const Color(0xFF6366F1),
        const Color(0xFF312E81),
        3,
      );

      _drawRoundedRect(
        canvas,
        -150,
        -180,
        100,
        80,
        15,
        Colors.white,
        const Color(0xFF0F172A),
        3,
      );
      Path p = Path()
        ..moveTo(-100, -100)
        ..lineTo(-120, -80)
        ..lineTo(-80, -100);
      canvas.drawPath(p, Paint()..color = Colors.white);

      if (want == 'apple') {
        _drawApple(canvas, -100, -140, 50);
      } else if (want == 'banana') {
        _drawBanana(canvas, -100, -140, 50);
      } else {
        _drawOrange(canvas, -100, -140, 50);
      }
    }

    _drawRoundedRect(
      canvas,
      100,
      -200,
      320,
      380,
      10,
      const Color(0xFFFDE047),
      const Color(0xFFA16207),
      4,
    );
    _drawRoundedRect(
      canvas,
      210,
      -210,
      100,
      30,
      5,
      const Color(0xFFCBD5E1),
      const Color(0xFF475569),
      3,
    );
    _drawRoundedRect(
      canvas,
      120,
      -160,
      280,
      320,
      0,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      2,
    );

    _drawTextWithOutline(
      canvas,
      t('lbl_fruit'),
      160,
      -130,
      16,
      const Color(0xFF0F172A),
    );
    _drawTextWithOutline(
      canvas,
      t('lbl_tally'),
      270,
      -130,
      16,
      const Color(0xFF0F172A),
    );
    if (step == 1) {
      _drawTextWithOutline(
        canvas,
        t('lbl_freq'),
        370,
        -130,
        16,
        const Color(0xFF0F172A),
      );
    }
    canvas.drawLine(
      const Offset(120, -110),
      const Offset(400, -110),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 2,
    );

    double rowY = -70;
    List<String> fruits = ['apple', 'banana', 'orange'];
    for (var f in fruits) {
      if (f == 'apple') {
        _drawApple(canvas, 160, rowY, 40);
      } else if (f == 'banana') {
        _drawBanana(canvas, 160, rowY, 40);
      } else {
        _drawOrange(canvas, 160, rowY, 40);
      }

      _drawTallyMarks(canvas, 220, rowY, s3Tallies[f] ?? 0);

      if (step == 0) {
        bool isNext =
            (s3CustIdx < s3CustQueue.length && s3CustQueue[s3CustIdx] == f);
        Color btnC = isNext ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0);
        _drawRoundedRect(
          canvas,
          350,
          rowY - 20,
          40,
          40,
          8,
          btnC,
          const Color(0xFF0F172A),
          2,
        );
        _drawTextWithOutline(
          canvas,
          "+",
          370,
          rowY,
          24,
          const Color(0xFF0F172A),
        );
      } else if (step == 1) {
        _drawTextWithOutline(
          canvas,
          (s3Tallies[f] ?? 0).toString(),
          370,
          rowY,
          20,
          const Color(0xFF22C55E),
        );
      }
      canvas.drawLine(
        Offset(120, rowY + 40),
        Offset(400, rowY + 40),
        Paint()
          ..color = const Color(0xFFCBD5E1)
          ..strokeWidth = 1,
      );
      rowY += 80;
    }
  }

  // SCENARIO 4
  void _renderS4(Canvas canvas) {
    for (int i = 0; i < s4Students.length; i++) {
      var st = s4Students[i];
      canvas.saveLayer(
        Rect.fromLTWH(st.x - 60, st.y - 60, 120, 120),
        Paint()..color = Color.fromARGB(st.asked ? 128 : 255, 255, 255, 255),
      );
      _drawRoundedRect(
        canvas,
        st.x - 25,
        st.y - 25,
        50,
        50,
        25,
        const Color(0xFF3B82F6),
        const Color(0xFF1E3A8A),
        2,
      );
      _drawEmoji(canvas, '👦', st.x, st.y, 35);

      if (st.asked || s4SelectedStudent == i) {
        _drawRoundedRect(
          canvas,
          st.x + 10,
          st.y - 50,
          40,
          30,
          8,
          Colors.white,
          const Color(0xFF0F172A),
          2,
        );
        String em = st.pet == 'dog'
            ? '🐶'
            : st.pet == 'cat'
            ? '🐱'
            : st.pet == 'fish'
            ? '🐟'
            : '🐰';
        _drawEmoji(canvas, em, st.x + 30, st.y - 35, 20);
      }
      canvas.restore();

      if (s4SelectedStudent == i && step == 0) {
        _drawRoundedRect(
          canvas,
          st.x - 30,
          st.y - 30,
          60,
          60,
          30,
          Colors.transparent,
          const Color(0xFFFACC15),
          4,
        );
      }
    }

    _drawRoundedRect(
      canvas,
      150,
      -200,
      300,
      400,
      10,
      const Color(0xFFFDE047),
      const Color(0xFFA16207),
      4,
    );
    _drawRoundedRect(
      canvas,
      170,
      -180,
      260,
      340,
      0,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      2,
    );

    _drawTextWithOutline(
      canvas,
      t('lbl_pet'),
      210,
      -150,
      16,
      const Color(0xFF0F172A),
    );
    _drawTextWithOutline(
      canvas,
      t('lbl_tally'),
      300,
      -150,
      16,
      const Color(0xFF0F172A),
    );
    _drawTextWithOutline(
      canvas,
      t('lbl_freq'),
      390,
      -150,
      16,
      const Color(0xFF0F172A),
    );
    canvas.drawLine(
      const Offset(170, -130),
      const Offset(430, -130),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 2,
    );

    double rowY = -90;
    List<String> pets = ['dog', 'cat', 'fish', 'rabbit'];
    for (var p in pets) {
      if (s4SelectedStudent != null &&
          s4Students[s4SelectedStudent!].pet == p &&
          step == 0) {
        canvas.drawRect(
          Rect.fromLTWH(170, rowY - 25, 260, 50),
          Paint()..color = const Color(0xFFFEF08A),
        );
      }

      String em = p == 'dog'
          ? '🐶'
          : p == 'cat'
          ? '🐱'
          : p == 'fish'
          ? '🐟'
          : '🐰';
      _drawEmoji(canvas, em, 190, rowY, 24);
      _drawTextWithOutline(
        canvas,
        t('lbl_$p'),
        220,
        rowY,
        14,
        const Color(0xFF0F172A),
        TextAlign.left,
      );
      _drawTallyMarks(canvas, 270, rowY, s4Tallies[p] ?? 0);

      if (step == 1) {
        _drawRoundedRect(
          canvas,
          350,
          rowY - 15,
          60,
          30,
          4,
          Colors.white,
          const Color(0xFF0F172A),
          2,
        );
        _drawTextWithOutline(canvas, "-", 365, rowY, 18, Colors.red);
        _drawTextWithOutline(canvas, "+", 395, rowY, 18, Colors.green);
        _drawTextWithOutline(
          canvas,
          (s4UserFreq[p] ?? 0).toString(),
          380,
          rowY,
          16,
          const Color(0xFF0F172A),
        );
      }

      canvas.drawLine(
        Offset(170, rowY + 25),
        Offset(430, rowY + 25),
        Paint()
          ..color = const Color(0xFFCBD5E1)
          ..strokeWidth = 1,
      );
      rowY += 50;
    }

    if (step == 1) {
      _drawRoundedRect(
        canvas,
        200,
        rowY + 30,
        160,
        40,
        8,
        const Color(0xFF22C55E),
        const Color(0xFF166534),
        3,
      );
      _drawTextWithOutline(
        canvas,
        t('lbl_check'),
        280,
        rowY + 50,
        16,
        Colors.white,
      );
    }
  }

  // SCENARIO 5
  void _renderS5(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -500,
      -100,
      1000,
      150,
      10,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      6,
    );
    for (int i = 0; i < 15; i++) {
      double off = (s5BeltOffset + i * 80) % 1000;
      _drawRoundedRect(
        canvas,
        -500 + off,
        -90,
        10,
        130,
        5,
        const Color(0xFF1E293B),
        Colors.transparent,
      );
    }

    if (step == 0 && s5CarIdx < s5Cars.length) {
      var car = s5Cars[s5CarIdx];
      _drawCar(canvas, car.x, -25, car.color, 100);
    }

    _drawRoundedRect(
      canvas,
      -200,
      100,
      400,
      120,
      15,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      4,
    );
    List<String> colors = ['red', 'blue', 'green'];
    for (int i = 0; i < 3; i++) {
      double bx = -130.0 + i * 130;
      Color c = colors[i] == 'red'
          ? const Color(0xFFEF4444)
          : (colors[i] == 'blue'
                ? const Color(0xFF3B82F6)
                : const Color(0xFF22C55E));
      _drawRoundedRect(
        canvas,
        bx - 40,
        120,
        80,
        80,
        40,
        c,
        const Color(0xFF0F172A),
        4,
      );
      _drawTextWithOutline(canvas, "+", bx, 160, 40, Colors.white);
    }

    _drawRoundedRect(
      canvas,
      350,
      -200,
      200,
      200,
      10,
      Colors.white,
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      t('lbl_car_color'),
      400,
      -170,
      14,
      const Color(0xFF0F172A),
    );
    _drawTextWithOutline(
      canvas,
      t('lbl_freq'),
      500,
      -170,
      14,
      const Color(0xFF0F172A),
    );
    canvas.drawLine(
      const Offset(350, -150),
      const Offset(550, -150),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 2,
    );

    for (int i = 0; i < 3; i++) {
      double ry = -120.0 + i * 40;
      _drawCar(canvas, 400, ry, colors[i], 50);
      _drawTextWithOutline(
        canvas,
        (s5Tallies[colors[i]] ?? 0).toString(),
        500,
        ry,
        18,
        const Color(0xFF0F172A),
      );
    }

    if (step >= 1) {
      int curSubStep = step == 1 ? 1 : 2;
      String prompt = curSubStep == 1 ? t('lbl_least') : t('lbl_most');
      _drawRoundedRect(
        canvas,
        -400,
        -200,
        250,
        150,
        10,
        const Color(0xFFFEF08A),
        const Color(0xFFA16207),
        4,
      );
      _drawTextWithOutline(
        canvas,
        prompt,
        -275,
        -160,
        18,
        const Color(0xFF0F172A),
      );
      _drawRoundedRect(
        canvas,
        -325,
        -130,
        100,
        60,
        5,
        Colors.white,
        const Color(0xFF0F172A),
        2,
      );

      if (s5Answered[curSubStep] != null) {
        _drawCar(canvas, -275, -100, s5Answered[curSubStep]!, 60);
      }

      for (int i = 0; i < 3; i++) {
        double ix = 380.0 + i * 70;
        if (!(activeDragEntityIdx != null && dragType == colors[i])) {
          _drawRoundedRect(
            canvas,
            ix - 30,
            50,
            60,
            40,
            5,
            const Color(0xFFE2E8F0),
            const Color(0xFF94A3B8),
            2,
          );
          _drawCar(canvas, ix, 70, colors[i], 50);
        }
      }
    }

    if (activeDragEntityIdx != null && dragType != null && scenario == 5) {
      _drawCar(canvas, dragPos.dx, dragPos.dy, dragType!, 60);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
