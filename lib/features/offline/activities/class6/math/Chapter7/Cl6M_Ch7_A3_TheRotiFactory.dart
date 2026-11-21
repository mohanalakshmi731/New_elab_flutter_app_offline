// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, use_super_parameters, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cl6M_Ch7_A3_TheRotiFactory());
}

// ==========================================
// TRANSLATIONS & I18N
// ==========================================
class I18n {
  static String currentLang = 'en';

  static final Map<String, Map<String, String>> _dict = {
    'en': {
      'resetBtn': 'Reset',
      'shutterTitle': 'Mixed Numbers & Improper Fractions',
      'appTitle': 'The Roti Factory',
      'appSubtitle': 'Class 6 • Math',
      'enterLab': 'Enter Simulation',
      'missionLbl': 'Mission:',
      'summaryTitle': 'Goal Reached!',
      'finishLab': 'Finish Lab',
      'nextScenario': 'Next Scenario',
      'finalDesc':
          'You have successfully mastered mixed numbers and improper fractions!',
      'lbl_btn_summarize': 'Summarize',
      'lbl_btn_check': 'Check Answer',
      'lbl_btn_menu': 'Select Slice Type',
      'lbl_plate_full': 'Full Roti Plate',
      'lbl_plate_partial': 'Partial Roti Plate',
      'lbl_empty': 'Empty',
      'lbl_whole_roti': '1 Whole Roti',
      'lbl_collection': 'Collection Area',
      'lbl_belt': 'Conveyor Belt',
      'lbl_slicer': 'Slicer Tool',
      'stepLabel': 'STEP',

      // Scenario 1
      's1_title': '1. Packing Half-Rotis',
      's1_obj':
          'Pack 5 half-rotis (5/2) into plates to see the equivalent mixed number.',
      's1_step1_task': 'DRAG a half-roti to a Full Plate.',
      's1_step1_out': 'Plate 1 has 1/2.',
      's1_step2_task': 'DRAG a second half-roti to the same plate.',
      's1_step2_out': 'They merged! Plate 1 is 1 Whole.',
      's1_step3_task': 'Pack the next 2 half-rotis into Plate 2.',
      's1_step3_out': 'Plate 2 is 1 Whole.',
      's1_step4_task': 'DRAG the last half-roti to the Partial Plate.',
      's1_step4_out': 'All pieces packed.',
      's1_step5_task': 'CLICK "Summarize".',
      's1_step5_out': '5/2 is equivalent to 2 1/2.',
      's1_hud1': 'Drag a half piece to Plate 1.',
      's1_hud2': 'Drag another half to Plate 1.',
      's1_hud3': 'Fill Plate 2 with two pieces.',
      's1_hud4': 'Drag the last piece to the Partial Plate.',
      's1_hud5': 'Click the Summarize button.',

      // Scenario 2
      's2_title': '2. Slicing for Quarters',
      's2_obj':
          'Slice 2 1/4 rotis into quarters to find the improper fraction.',
      's2_step1_task': 'DRAG the Slicer Tool onto the first whole roti.',
      's2_step1_out': 'Roti is cut into 4 quarters.',
      's2_step2_task': 'DRAG the Slicer Tool onto the second whole roti.',
      's2_step2_out': 'Second roti is cut into 4 quarters.',
      's2_step3_task': 'CLICK "Summarize".',
      's2_step3_out': 'Total 9 quarters. 2 1/4 is equivalent to 9/4.',
      's2_hud1': 'Drag the slicer to the left roti.',
      's2_hud2': 'Drag the slicer to the right roti.',
      's2_hud3': 'Click Summarize to count total quarters.',

      // Scenario 3
      's3_title': '3. Packing Thirds',
      's3_obj':
          'Pack 8 one-third pieces (8/3) into plates to find the mixed number.',
      's3_step1_task': 'Pack 3 pieces into Plate 1.',
      's3_step1_out': 'Plate 1 forms a Whole Roti.',
      's3_step2_task': 'Pack 3 more pieces into Plate 2.',
      's3_step2_out': 'Plate 2 forms a Whole Roti.',
      's3_step3_task': 'Pack the remaining 2 pieces into the Partial Plate.',
      's3_step3_out': 'Partial plate has 2/3.',
      's3_step4_task': 'CLICK "Summarize".',
      's3_step4_out': '8/3 is equivalent to 2 2/3.',
      's3_hud1': 'Drag 3 pieces to Plate 1.',
      's3_hud2': 'Drag 3 pieces to Plate 2.',
      's3_hud3': 'Drag remaining 2 pieces to Partial Plate.',
      's3_hud4': 'Click the Summarize button.',

      // Scenario 4
      's4_title': '4. The Fifth Slice',
      's4_obj':
          'Convert the mixed number 3 2/5 into an improper fraction by slicing.',
      's4_step1_task':
          'CLICK the Slicer Tool to open menu, then SELECT "Fifths".',
      's4_step1_out': 'Slicer set to cut fifths.',
      's4_step2_task': 'DRAG Slicer to cut ALL 3 whole rotis.',
      's4_step2_out': 'All rotis sliced into fifths.',
      's4_step3_task': 'DRAG all 17 pieces into the Collection Area.',
      's4_step3_out': '17 pieces collected. 3 2/5 = 17/5.',
      's4_hud1': 'Click the slicer and select "Fifths".',
      's4_hud2': 'Drag slicer over each whole roti.',
      's4_hud3': 'Drag all pieces to the box.',

      // Scenario 5
      's5_title': '5. Quartermaster Packing',
      's5_obj': 'Pack 11 quarter pieces (11/4) to find the mixed number.',
      's5_step1_task':
          'Pack quarters into Full Plates to make wholes (4 per plate).',
      's5_step1_out': 'Packed 2 Whole Rotis.',
      's5_step2_task': 'Pack leftover pieces onto the Partial Plate.',
      's5_step2_out': 'Partial plate has 3 quarters.',
      's5_step3_task': 'CLICK "Check Answer".',
      's5_step3_out': 'Correct! 11/4 is equivalent to 2 3/4.',
      's5_hud1': 'Drag pieces to plates. 4 make a whole.',
      's5_hud2': 'Place leftovers on partial plate.',
      's5_hud3': 'Click Check Answer to verify.',
    },
    'hi': {
      'resetBtn': 'रीसेट',
      'shutterTitle': 'मिश्रित और विषम भिन्न',
      'appTitle': 'रोटी की फैक्ट्री',
      'appSubtitle': 'कक्षा 6 • गणित',
      'enterLab': 'सिमुलेशन शुरू करें',
      'missionLbl': 'मिशन:',
      'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
      'finishLab': 'लैब समाप्त करें',
      'nextScenario': 'अगला परिदृश्य',
      'finalDesc': 'आपने मिश्रित और विषम भिन्नों को सफलतापूर्वक सीख लिया है!',
      'lbl_btn_summarize': 'संक्षेप करें',
      'lbl_btn_check': 'उत्तर जाँचें',
      'lbl_btn_menu': 'प्रकार चुनें',
      'lbl_plate_full': 'पूरी रोटी की प्लेट',
      'lbl_plate_partial': 'अधूरी प्लेट',
      'lbl_empty': 'खाली',
      'lbl_whole_roti': '1 पूरी रोटी',
      'lbl_collection': 'संग्रह क्षेत्र',
      'lbl_belt': 'कन्वेयर बेल्ट',
      'lbl_slicer': 'स्लाइसर टूल',
      'stepLabel': 'चरण',

      // Scenario 1
      's1_title': '1. आधी रोटियों की पैकिंग',
      's1_obj': '5 आधी रोटियों (5/2) को प्लेटों में पैक करें।',
      's1_step1_task': 'एक आधी रोटी को प्लेट 1 में खींचें।',
      's1_step1_out': 'प्लेट 1 में 1/2 है।',
      's1_step2_task': 'दूसरी आधी रोटी को प्लेट 1 में खींचें।',
      's1_step2_out': 'वे जुड़ गए! प्लेट 1 पूरी है।',
      's1_step3_task': 'अगली 2 आधी रोटियों को प्लेट 2 में खींचें।',
      's1_step3_out': 'प्लेट 2 पूरी है।',
      's1_step4_task': 'अंतिम आधी रोटी को अधूरी प्लेट में खींचें।',
      's1_step4_out': 'सभी टुकड़े पैक हो गए।',
      's1_step5_task': '"संक्षेप करें" पर क्लिक करें।',
      's1_step5_out': '5/2, 2 1/2 के बराबर है।',
      's1_hud1': 'एक आधे टुकड़े को प्लेट 1 पर खींचें।',
      's1_hud2': 'एक और आधे को प्लेट 1 पर खींचें।',
      's1_hud3': 'प्लेट 2 को दो टुकड़ों से भरें।',
      's1_hud4': 'अंतिम टुकड़े को अधूरी प्लेट पर खींचें।',
      's1_hud5': 'संक्षेप करें बटन पर क्लिक करें।',

      // Scenario 2
      's2_title': '2. चौथाई के लिए स्लाइसिंग',
      's2_obj': 'विषम भिन्न खोजने के लिए 2 1/4 रोटियों को चौथाई में काटें।',
      's2_step1_task': 'स्लाइसर को पहली पूरी रोटी पर खींचें।',
      's2_step1_out': 'रोटी 4 चौथाई में कट गई।',
      's2_step2_task': 'स्लाइसर को दूसरी पूरी रोटी पर खींचें।',
      's2_step2_out': 'दूसरी रोटी 4 चौथाई में कट गई।',
      's2_step3_task': '"संक्षेप करें" पर क्लिक करें।',
      's2_step3_out': 'कुल 9 चौथाई। 2 1/4, 9/4 के बराबर है।',
      's2_hud1': 'स्लाइसर को बाईं रोटी पर खींचें।',
      's2_hud2': 'स्लाइसर को दाईं रोटी पर खींचें।',
      's2_hud3': 'कुल चौथाई गिनने के लिए संक्षेप करें पर क्लिक करें।',

      // Scenario 3
      's3_title': '3. तिहाई की पैकिंग',
      's3_obj': '8 एक-तिहाई टुकड़ों (8/3) को प्लेटों में पैक करें।',
      's3_step1_task': 'प्लेट 1 में 3 टुकड़े पैक करें।',
      's3_step1_out': 'प्लेट 1 पूरी रोटी बनाती है।',
      's3_step2_task': 'प्लेट 2 में और 3 टुकड़े पैक करें।',
      's3_step2_out': 'प्लेट 2 पूरी रोटी बनाती है।',
      's3_step3_task': 'बाकी 2 टुकड़ों को अधूरी प्लेट में पैक करें।',
      's3_step3_out': 'अधूरी प्लेट में 2/3 है।',
      's3_step4_task': '"संक्षेप करें" पर क्लिक करें।',
      's3_step4_out': '8/3, 2 2/3 के बराबर है।',
      's3_hud1': '3 टुकड़ों को प्लेट 1 पर खींचें।',
      's3_hud2': '3 टुकड़ों को प्लेट 2 पर खींचें।',
      's3_hud3': 'बाकी 2 टुकड़ों को अधूरी प्लेट पर खींचें।',
      's3_hud4': 'संक्षेप करें बटन पर क्लिक करें।',

      // Scenario 4
      's4_title': '4. पांचवां टुकड़ा',
      's4_obj': 'मिश्रित संख्या 3 2/5 को विषम भिन्न में बदलें।',
      's4_step1_task':
          'मेनू खोलने के लिए स्लाइसर पर क्लिक करें, "पांचवां" (Fifths) चुनें।',
      's4_step1_out': 'स्लाइसर पांचवें हिस्से काटने के लिए सेट।',
      's4_step2_task': 'तीनों पूरी रोटियों को काटने के लिए स्लाइसर खींचें।',
      's4_step2_out': 'सभी रोटियां कट गईं।',
      's4_step3_task': 'सभी 17 टुकड़ों को संग्रह क्षेत्र में खींचें।',
      's4_step3_out': '17 टुकड़े एकत्र। 3 2/5 = 17/5.',
      's4_hud1': 'स्लाइसर पर क्लिक करें और "पांचवां" चुनें।',
      's4_hud2': 'हर पूरी रोटी पर स्लाइसर खींचें।',
      's4_hud3': 'सभी टुकड़ों को बॉक्स में खींचें।',

      // Scenario 5
      's5_title': '5. क्वार्टरमास्टर पैकिंग',
      's5_obj':
          'मिश्रित संख्या खोजने के लिए 11 चौथाई टुकड़ों (11/4) को पैक करें।',
      's5_step1_task': 'पूरी प्लेटों में चौथाई पैक करें (प्रति प्लेट 4)।',
      's5_step1_out': '2 पूरी रोटियां पैक कीं।',
      's5_step2_task': 'बचे हुए टुकड़ों को अधूरी प्लेट में पैक करें।',
      's5_step2_out': 'अधूरी प्लेट में 3 चौथाई हैं।',
      's5_step3_task': '"उत्तर जाँचें" पर क्लिक करें।',
      's5_step3_out': 'सही! 11/4, 2 3/4 के बराबर है।',
      's5_hud1': 'टुकड़ों को प्लेटों में खींचें। 4 से एक पूरी बनती है।',
      's5_hud2': 'बचे हुए टुकड़ों को अधूरी प्लेट पर रखें।',
      's5_hud3': 'उत्तर जाँचने के लिए क्लिक करें।',
    },
  };

  static String t(String key) {
    return _dict[currentLang]?[key] ?? _dict['en']?[key] ?? key;
  }
}

// ==========================================
// MODELS
// ==========================================
class Piece {
  int id;
  String type;
  double angle;
  double startAngle;
  double x;
  double y;
  double origX;
  double origY;
  String zone;
  String? plateId;

  Piece({
    required this.id,
    required this.type,
    required this.angle,
    required this.startAngle,
    required this.x,
    required this.y,
    required this.origX,
    required this.origY,
    required this.zone,
    this.plateId,
  });
}

class Plate {
  String id;
  String type;
  int capacity;
  List<int> pieces;
  bool isWhole;
  double x;
  double y;

  Plate({
    required this.id,
    required this.type,
    required this.capacity,
    required this.x,
    required this.y,
    this.isWhole = false,
  }) : pieces = [];
}

class WholeRoti {
  String id;
  bool sliced;
  double x;
  double y;

  WholeRoti({
    required this.id,
    required this.x,
    required this.y,
    this.sliced = false,
  });
}

class CollectionBox {
  double x;
  double y;
  double w;
  double h;
  int collected;
  CollectionBox({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.collected = 0,
  });
}

// ==========================================
// MAIN SCREEN (Stateful Widget)
// ==========================================
class Cl6M_Ch7_A3_TheRotiFactory extends StatefulWidget {
  const Cl6M_Ch7_A3_TheRotiFactory({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch7_A3_TheRotiFactory> createState() =>
      _Cl6M_Ch7_A3_TheRotiFactoryState();
}

class _Cl6M_Ch7_A3_TheRotiFactoryState extends State<Cl6M_Ch7_A3_TheRotiFactory>
    with SingleTickerProviderStateMixin {
  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // UI State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 300.0;

  // Canvas & Game State
  late AnimationController _gameLoop;
  final GlobalKey _canvasKey = GlobalKey();

  double _zoom = 1.0;
  double _initialZoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;

  int _scenario = 1;
  int _step = 0;

  // Game Entities
  final List<Piece> _pieces = [];
  final List<Plate> _plates = [];
  final List<WholeRoti> _wholes = [];
  CollectionBox? _collectionBox;

  String? _equation;
  bool _showSuccessPopup = false;

  // Interaction
  dynamic _activeDragId; // int for piece, String for 'slicer'
  double _dragOffX = 0;
  double _dragOffY = 0;
  double _slicerX = 0;
  double _slicerY = 0;
  bool _slicerMenuOpen = false;
  String _slicerType = 'quarters';

  // Drag Canvas state
  bool _isDraggingCanvas = false;
  double _dragStartX = 0;
  double _dragStartY = 0;

  // --- AUDIO METHODS ---
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitScreen();
      _loadScenario(1);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    playDropdown();
    setState(() {
      I18n.currentLang = I18n.currentLang == 'en' ? 'hi' : 'en';
    });
  }

  void _fitScreen() {
    if (_canvasKey.currentContext == null) return;
    final size =
        (_canvasKey.currentContext!.findRenderObject() as RenderBox).size;
    if (size.width == 0) return;
    double effectiveHeight = size.height - 60;
    double effectiveWidth = size.width - 20;
    _zoom = max(
      0.5,
      min(2.0, min(effectiveWidth / 900, effectiveHeight / 700)),
    );
    _panX = 0;
    _panY = 0;
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _pieces.clear();
      _plates.clear();
      _wholes.clear();
      _equation = null;
      _showSuccessPopup = false;
      _slicerMenuOpen = false;
      _collectionBox = null;
      _activeDragId = null;

      if (id == 1) {
        for (int i = 0; i < 5; i++) {
          _pieces.add(
            Piece(
              id: i,
              type: 'half',
              angle: pi,
              startAngle: 0,
              x: -300.0 + i * 150,
              y: -150,
              origX: -300.0 + i * 150,
              origY: -150,
              zone: 'belt',
            ),
          );
        }
        _plates.add(
          Plate(id: 'p1', type: 'full', capacity: 2, x: -250, y: 150),
        );
        _plates.add(Plate(id: 'p2', type: 'full', capacity: 2, x: 50, y: 150));
        _plates.add(
          Plate(id: 'p3', type: 'partial', capacity: 1, x: 350, y: 150),
        );
      } else if (id == 2) {
        _wholes.add(WholeRoti(id: 'w1', x: -200, y: 0));
        _wholes.add(WholeRoti(id: 'w2', x: 100, y: 0));
        _plates.add(
          Plate(id: 'p1', type: 'partial', capacity: 4, x: 350, y: 0),
        );
        _pieces.add(
          Piece(
            id: 0,
            type: 'quarter',
            angle: pi / 2,
            startAngle: 0,
            x: 350,
            y: 0,
            origX: 350,
            origY: 0,
            zone: 'p1',
            plateId: 'p1',
          ),
        );
        _plates[0].pieces.add(0);
        _slicerType = 'quarters';
      } else if (id == 3) {
        for (int i = 0; i < 8; i++) {
          _pieces.add(
            Piece(
              id: i,
              type: 'third',
              angle: pi * 2 / 3,
              startAngle: 0,
              x: -350.0 + i * 100,
              y: -150,
              origX: -350.0 + i * 100,
              origY: -150,
              zone: 'belt',
            ),
          );
        }
        _plates.add(
          Plate(id: 'p1', type: 'full', capacity: 3, x: -250, y: 150),
        );
        _plates.add(Plate(id: 'p2', type: 'full', capacity: 3, x: 50, y: 150));
        _plates.add(
          Plate(id: 'p3', type: 'partial', capacity: 2, x: 350, y: 150),
        );
      } else if (id == 4) {
        for (int i = 0; i < 3; i++) {
          _wholes.add(WholeRoti(id: 'w$i', x: -300.0 + i * 160, y: 0));
        }
        _plates.add(
          Plate(id: 'p1', type: 'partial', capacity: 5, x: 250, y: 0),
        );
        for (int i = 0; i < 2; i++) {
          _pieces.add(
            Piece(
              id: i,
              type: 'fifth',
              angle: pi * 2 / 5,
              startAngle: i * (pi * 2 / 5),
              x: 250,
              y: 0,
              origX: 250,
              origY: 0,
              zone: 'p1',
              plateId: 'p1',
            ),
          );
          _plates[0].pieces.add(i);
        }
        _slicerType = 'halves'; // start wrong
        _collectionBox = CollectionBox(x: -250, y: 180, w: 600, h: 100);
      } else if (id == 5) {
        for (int i = 0; i < 11; i++) {
          _pieces.add(
            Piece(
              id: i,
              type: 'quarter',
              angle: pi / 2,
              startAngle: 0,
              x: -400.0 + i * 80,
              y: -150,
              origX: -400.0 + i * 80,
              origY: -150,
              zone: 'belt',
            ),
          );
        }
        _plates.add(
          Plate(id: 'p1', type: 'full', capacity: 4, x: -250, y: 150),
        );
        _plates.add(Plate(id: 'p2', type: 'full', capacity: 4, x: 50, y: 150));
        _plates.add(
          Plate(id: 'p3', type: 'partial', capacity: 4, x: 350, y: 150),
        );
      }

      _fitScreen();
    });
  }

  void _triggerAction(String action) {
    if (action == 's1_summarize' ||
        action == 's2_summarize' ||
        action == 's3_summarize') {
      playPageOpen();
      setState(() {
        _step++;
      });
      if (action == 's1_summarize') _equation = "5/2 = 2 1/2";
      if (action == 's2_summarize') _equation = "2 1/4 = 9/4";
      if (action == 's3_summarize') _equation = "8/3 = 2 2/3";
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() => _showSuccessPopup = true),
      );
    } else if (action == 's4_summarize') {
      playPageOpen();
      setState(() {
        _equation = "3 2/5 = 17/5";
      });
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() => _showSuccessPopup = true),
      );
    } else if (action == 's5_check') {
      if (_plates[0].isWhole &&
          _plates[1].isWhole &&
          _plates[2].pieces.length == 3) {
        playPageOpen();
        setState(() {
          _step++;
          _equation = "11/4 = 2 3/4";
        });
        Future.delayed(
          const Duration(milliseconds: 800),
          () => setState(() => _showSuccessPopup = true),
        );
      } else {
        playError();
      }
    }
  }

  void _checkScenarioProgress() {
    if (_scenario == 1) {
      int wholeCount = _plates.where((p) => p.isWhole).length;
      bool hasAnyPieceInFull = _plates
          .where((p) => p.type == 'full' && p.pieces.isNotEmpty)
          .isNotEmpty;
      bool hasPartialPiece = _plates.any(
        (p) => p.type == 'partial' && p.pieces.isNotEmpty,
      );

      if (_step == 0 && hasAnyPieceInFull) _step = 1;
      if (_step == 1 && wholeCount >= 1) _step = 2;
      if (_step == 2 && wholeCount >= 2) _step = 3;
      if (_step == 3 && wholeCount >= 2 && hasPartialPiece) _step = 4;
    } else if (_scenario == 3) {
      int wholeCount = _plates.where((p) => p.isWhole).length;
      bool partialFilled = _plates.any(
        (p) => p.type == 'partial' && p.pieces.length == 2,
      );

      if (_step == 0 && wholeCount >= 1) _step = 1;
      if (_step == 1 && wholeCount >= 2) _step = 2;
      if (_step == 2 && wholeCount >= 2 && partialFilled) _step = 3;
    } else if (_scenario == 5) {
      int wholeCount = _plates.where((p) => p.isWhole).length;
      bool partialFilled = _plates.any(
        (p) => p.type == 'partial' && p.pieces.length == 3,
      );

      if (_step == 0 && wholeCount >= 2) _step = 1;
      if (_step == 1 && wholeCount >= 2 && partialFilled) _step = 2;
    }
  }

  void _sliceWhole(WholeRoti w) {
    playClick();
    setState(() {
      w.sliced = true;
      int count = _scenario == 2 ? 4 : 5;
      String type = _scenario == 2 ? 'quarter' : 'fifth';
      double angle = pi * 2 / count;

      for (int i = 0; i < count; i++) {
        _pieces.add(
          Piece(
            id: _pieces.length,
            type: type,
            angle: angle,
            startAngle: i * angle,
            x: w.x,
            y: w.y,
            origX: w.x + (Random().nextDouble() * 40 - 20),
            origY: w.y + (Random().nextDouble() * 40 - 20),
            zone: 'table',
          ),
        );
      }

      if (_scenario == 2) {
        bool allSliced = _wholes.every((wh) => wh.sliced);
        if (_step == 0) {
          _step++;
        } else if (_step == 1 && allSliced) {
          _step++;
        }
      } else if (_scenario == 4) {
        bool allSliced = _wholes.every((wh) => wh.sliced);
        if (allSliced && _step == 1) _step++;
      }
    });
  }

  // --- GESTURES ---
  Offset _getWorldCoord(Offset local) {
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    double wx = (local.dx - box.size.width / 2 - _panX) / _zoom;
    double wy = (local.dy - box.size.height / 2 - _panY) / _zoom;
    return Offset(wx, wy);
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    return sqrt(pow(pt.dx - cx, 2) + pow(pt.dy - cy, 2)) <= r;
  }

  bool _hitTestBox(double bx, double by, double bw, double bh, Offset pt) {
    return pt.dx >= bx && pt.dx <= bx + bw && pt.dy >= by && pt.dy <= by + bh;
  }

  void _onTapDown(TapDownDetails details) {
    if (_showCurtain || _showSuccessPopup) return;
    Offset wp = _getWorldCoord(details.localPosition);

    // Check Buttons First
    if (_scenario == 1 && _step == 4 && _hitTestBox(-60, 250, 120, 50, wp)) {
      _triggerAction('s1_summarize');
      return;
    }
    if (_scenario == 2 && _step == 2 && _hitTestBox(-60, 200, 120, 50, wp)) {
      _triggerAction('s2_summarize');
      return;
    }
    if (_scenario == 3 && _step == 3 && _hitTestBox(-60, 250, 120, 50, wp)) {
      _triggerAction('s3_summarize');
      return;
    }
    if (_scenario == 5 && _step == 2 && _hitTestBox(-80, 250, 160, 50, wp)) {
      _triggerAction('s5_check');
      return;
    }

    // S4 Slicer Menu Check
    if (_scenario == 4) {
      if (_slicerMenuOpen) {
        List<String> opts = ['halves', 'thirds', 'quarters', 'fifths'];
        bool clicked = false;
        for (int i = 0; i < opts.length; i++) {
          if (_hitTestBox(-100, -100 + i * 40.0, 200, 35, wp)) {
            playClick();
            setState(() {
              _slicerType = opts[i];
              _slicerMenuOpen = false;
              clicked = true;
              if (_step == 0 && _slicerType == 'fifths') _step++;
            });
            return;
          }
        }
        if (!clicked && !_hitTestBox(-110, -140, 220, 200, wp)) {
          setState(() => _slicerMenuOpen = false);
          return;
        }
      } else {
        bool isToolbox = _hitTestBox(-80, -270, 160, 100, wp);
        if (isToolbox && _step == 0) {
          playClick();
          setState(() {
            _slicerMenuOpen = true;
          });
          return;
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_showCurtain || _showSuccessPopup) return;

    Offset wp = _getWorldCoord(details.localFocalPoint);

    // Ignore scale start if touching a button (handled instantly by onTapDown)
    if (_scenario == 1 && _step == 4 && _hitTestBox(-60, 250, 120, 50, wp)) {
      return;
    }
    if (_scenario == 2 && _step == 2 && _hitTestBox(-60, 200, 120, 50, wp)) {
      return;
    }
    if (_scenario == 3 && _step == 3 && _hitTestBox(-60, 250, 120, 50, wp)) {
      return;
    }
    if (_scenario == 5 && _step == 2 && _hitTestBox(-80, 250, 160, 50, wp)) {
      return;
    }
    if (_scenario == 4) {
      if (_slicerMenuOpen && _hitTestBox(-110, -140, 220, 200, wp)) return;
      if (!_slicerMenuOpen &&
          _step == 0 &&
          _hitTestBox(-80, -270, 160, 100, wp))
        return;
    }

    bool hitDraggableObject = false;

    // S4 Slicer Icon check (Draggable)
    if (_scenario == 4 && !_slicerMenuOpen) {
      bool isSlicerIcon = _hitTestCircle(0, -210, 40, wp);
      if (isSlicerIcon && _step > 0) {
        if (_slicerType != 'fifths') {
          playError();
          return;
        }
        playClick();
        setState(() {
          _activeDragId = 'slicer';
          _dragOffX = 0;
          _dragOffY = 0;
        });
        hitDraggableObject = true;
      }
    }

    // S2 Slicer Drag Check
    if (!hitDraggableObject &&
        _scenario == 2 &&
        _hitTestCircle(0, -210, 40, wp)) {
      playClick();
      setState(() {
        _activeDragId = 'slicer';
        _dragOffX = 0;
        _dragOffY = 0;
      });
      hitDraggableObject = true;
    }

    // Drag Pieces Check (reverse order for top-most z-index)
    if (!hitDraggableObject) {
      for (int i = _pieces.length - 1; i >= 0; i--) {
        Piece p = _pieces[i];
        if (_hitTestCircle(p.x, p.y, 60, wp)) {
          Plate? plate = _plates.where((pl) => pl.id == p.zone).firstOrNull;
          if (plate == null || !plate.isWhole) {
            playClick();
            setState(() {
              _activeDragId = p.id;
              _dragOffX = p.x - wp.dx;
              _dragOffY = p.y - wp.dy;
              if (plate != null) {
                plate.pieces.remove(p.id);
                p.zone = 'dragging';
              }
            });
            hitDraggableObject = true;
            break;
          }
        }
      }
    }

    // If we didn't touch anything draggable, initiate canvas panning/zooming
    if (!hitDraggableObject) {
      _isDraggingCanvas = true;
      _dragStartX = details.localFocalPoint.dx - _panX;
      _dragStartY = details.localFocalPoint.dy - _panY;
      _initialZoom = _zoom;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isDraggingCanvas) {
      setState(() {
        if (details.scale != 1.0) {
          _zoom = (_initialZoom * details.scale).clamp(0.4, 3.0);
        }
        _panX = details.localFocalPoint.dx - _dragStartX;
        _panY = details.localFocalPoint.dy - _dragStartY;
      });
      return;
    }

    if (_activeDragId != null) {
      Offset wp = _getWorldCoord(details.localFocalPoint);
      setState(() {
        if (_activeDragId == 'slicer') {
          _slicerX = wp.dx;
          _slicerY = wp.dy;
        } else {
          Piece p = _pieces.firstWhere((x) => x.id == _activeDragId);
          p.x = wp.dx + _dragOffX;
          p.y = wp.dy + _dragOffY;
        }
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _isDraggingCanvas = false;

    if (_activeDragId != null) {
      setState(() {
        if (_activeDragId == 'slicer') {
          bool slicedAny = false;
          for (var w in _wholes) {
            if (!w.sliced &&
                _hitTestCircle(w.x, w.y, 60, Offset(_slicerX, _slicerY))) {
              _sliceWhole(w);
              slicedAny = true;
            }
          }
          if (!slicedAny) playError();
          _activeDragId = null;
          _slicerX = 0;
          _slicerY = 0;
        } else {
          Piece p = _pieces.firstWhere((x) => x.id == _activeDragId);
          bool snapped = false;

          // S4 Collection
          if (_scenario == 4 &&
              _collectionBox != null &&
              _hitTestBox(
                _collectionBox!.x,
                _collectionBox!.y,
                _collectionBox!.w,
                _collectionBox!.h,
                Offset(p.x, p.y),
              )) {
            p.zone = 'collection';
            snapped = true;
            playClick();
          } else {
            // Plate Snapping
            for (Plate plate in _plates) {
              if (_hitTestCircle(plate.x, plate.y, 80, Offset(p.x, p.y))) {
                if (plate.pieces.length < plate.capacity) {
                  plate.pieces.add(p.id);
                  p.zone = plate.id;
                  p.x = plate.x;
                  p.y = plate.y;
                  p.startAngle = plate.pieces.indexOf(p.id) * p.angle;
                  snapped = true;

                  if (plate.pieces.length == plate.capacity &&
                      plate.type == 'full') {
                    plate.isWhole = true;
                    playPageOpen();
                  } else {
                    playClick();
                  }

                  _checkScenarioProgress();
                  break;
                }
              }
            }
          }

          if (!snapped) {
            p.x = p.origX;
            p.y = p.origY;
            p.zone = 'belt';
            playError();
          }

          // S4 specific alignments
          if (_scenario == 4 && _collectionBox != null) {
            var collPieces = _pieces
                .where((x) => x.zone == 'collection')
                .toList();
            _collectionBox!.collected = collPieces.length;
            if (collPieces.isNotEmpty) {
              double spacing = (_collectionBox!.w - 120) / 16;
              for (int i = 0; i < collPieces.length; i++) {
                collPieces[i].x = _collectionBox!.x + 60 + i * spacing;
                collPieces[i].y = _collectionBox!.y + 50;
                collPieces[i].startAngle = pi * 1.5 - collPieces[i].angle / 2;
              }
            }
            if (_collectionBox!.collected == 17 && _step == 2) {
              _step++;
              Future.delayed(
                const Duration(milliseconds: 500),
                () => _triggerAction('s4_summarize'),
              );
            }
          }

          _activeDragId = null;
        }
      });
    }
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Fractions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily:
            'Plus Jakarta Sans', // Fallback to system sans if not imported
      ),
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Scaffold(body: _buildMainBody()),
      ),
    );
  }

  Widget _buildMainBody() {
    double screenWidth = MediaQuery.of(context).size.width;

    // Config Steps for Sidebar
    List<Map<String, String>> stepsConfig = [];
    int numSteps = _scenario == 1
        ? 5
        : (_scenario == 2
              ? 3
              : (_scenario == 3 ? 4 : (_scenario == 4 ? 3 : 3)));
    for (int i = 1; i <= numSteps; i++) {
      stepsConfig.add({
        'task': I18n.t('s${_scenario}_step${i}_task'),
        'outcome': I18n.t('s${_scenario}_step${i}_out'),
        'hud': I18n.t('s${_scenario}_hud$i'),
      });
    }
    String hudText = (_step < stepsConfig.length)
        ? stepsConfig[_step]['hud']!
        : "";

    return Stack(
      children: [
        // CANVAS AREA
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: _sidebarOpen ? _sidebarWidth : 0,
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: Container(
              key: _canvasKey,
              color: const Color(0xFF0F172A),
              child: CustomPaint(
                painter: LabPainter(
                  zoom: _zoom,
                  panX: _panX,
                  panY: _panY,
                  scenario: _scenario,
                  step: _step,
                  pieces: _pieces,
                  plates: _plates,
                  wholes: _wholes,
                  collectionBox: _collectionBox,
                  equation: _equation,
                  activeDragId: _activeDragId,
                  slicerX: _slicerX,
                  slicerY: _slicerY,
                  slicerMenuOpen: _slicerMenuOpen,
                  slicerType: _slicerType,
                ),
              ),
            ),
          ),
        ),

        // HUD overlay
        if (hudText.isNotEmpty && !_showCurtain)
          Positioned(
            bottom: 30,
            left: _sidebarOpen ? _sidebarWidth : 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE60F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFF59E0B), width: 3),
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0x33F59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          hudText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Next Scenario Button on Canvas (If done)
        if (_step == stepsConfig.length && _scenario < 5 && !_showSuccessPopup)
          Positioned(
            bottom: 30,
            right: 30,
            child: ElevatedButton.icon(
              onPressed: () {
                playClick();
                _loadScenario(_scenario + 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Text(''), // Hack for simple icon layout
              label: Row(
                children: [
                  Text(
                    I18n.t('nextScenario'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),

        // SIDEBAR
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: _sidebarOpen ? 0 : -_sidebarWidth,
          top: 0,
          bottom: 0,
          width: _sidebarWidth,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                right: BorderSide(color: Color(0x26FFFFFF), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(5, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Make completely sidebar scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Area merged inside scroll
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            60,
                            16,
                            16,
                          ), // Left padding for floating menu
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Activity icon placed in front of title
                                  const Icon(
                                    Icons.local_pizza,
                                    color: Color(0xFFF59E0B),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      I18n.t('appTitle'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 40.0,
                                  top: 4,
                                ),
                                child: Text(
                                  I18n.t('appSubtitle'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Language toggle and Reset placed below subtitle
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              I18n.currentLang == 'en'
                                                  ? 'EN'
                                                  : 'HI',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onPressed: _toggleLanguage,
                                        tooltip: "Toggle Language",
                                        constraints: const BoxConstraints(
                                          minWidth: 60,
                                          minHeight: 40,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Row(
                                          children: [
                                            const Icon(
                                              Icons.refresh,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              I18n.t('resetBtn'),
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          playClick();
                                          setState(() {
                                            _showCurtain = true;
                                          });
                                          _loadScenario(1);
                                        },
                                        tooltip: "Reset Lab",
                                        constraints: const BoxConstraints(
                                          minWidth: 80,
                                          minHeight: 40,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(
                          color: Colors.white24,
                          height: 1,
                          thickness: 1,
                        ),

                        // Main Content (Missions & Steps)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                I18n.t('missionLbl').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Scenario Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _scenario,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: [1, 2, 3, 4, 5]
                                        .map(
                                          (id) => DropdownMenuItem(
                                            value: id,
                                            child: Text(I18n.t('s${id}_title')),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        playDropdown();
                                        _loadScenario(val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Objective Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0x33FFFFFF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  I18n.t('s${_scenario}_obj'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Steps
                              ...List.generate(stepsConfig.length, (i) {
                                bool isActive = i == _step;
                                bool isPast = i < _step;
                                bool isFuture = i > _step;

                                Color bgColor = isActive
                                    ? const Color(0x1AF59E0B)
                                    : (isPast
                                          ? const Color(0x1A10B981)
                                          : const Color(0x1AFFFFFF));
                                Color borderColor = isActive
                                    ? const Color(0xFFF59E0B)
                                    : (isPast
                                          ? const Color(0xFF10B981)
                                          : Colors.transparent);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isPast)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF10B981),
                                          size: 24,
                                        )
                                      else
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? const Color(0xFFF59E0B)
                                                : Colors.white24,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${i + 1}',
                                              style: TextStyle(
                                                color: isActive
                                                    ? Colors.white
                                                    : Colors.white54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${I18n.t('stepLabel')} ${i + 1}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white54,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              stepsConfig[i]['task']!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isFuture
                                                    ? Colors.white54
                                                    : Colors.white,
                                                height: 1.4,
                                              ),
                                            ),
                                            if (isPast) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0x3310B981,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  stepsConfig[i]['outcome']!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF34D399),
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
                              }),
                            ],
                          ),
                        ),
                        // Footer attached to bottom
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: const Color(0xFF020617),
                          child: const Text(
                            '© ZeroScienceLab - Fall in love with math and Science',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white54,
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
        ),

        // Sidebar Resizer Handle (Drag right edge to widen/shrink)
        if (_sidebarOpen)
          Positioned(
            left: _sidebarWidth - 10,
            top: 0,
            bottom: 0,
            width: 20,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    _sidebarWidth = _sidebarWidth.clamp(
                      300.0,
                      screenWidth * 0.6,
                    );
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.0),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: VerticalDivider(color: Colors.transparent, width: 2),
                  ),
                ),
              ),
            ),
          ),

        // MENU BUTTON (Fixed Position)
        Positioned(
          top: 16,
          left: 16, // Completely fixed coordinates independent of sidebar logic
          child: GestureDetector(
            onTap: () {
              playClick();
              setState(() {
                _sidebarOpen = !_sidebarOpen;
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _sidebarOpen ? Icons.menu_open : Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // SUCCESS POPUP
        if (_showSuccessPopup)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        I18n.t('summaryTitle'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        I18n.t('finalDesc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_scenario < 5)
                        ElevatedButton.icon(
                          onPressed: () {
                            playClick();
                            _loadScenario(_scenario + 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Text(''),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                I18n.t('nextScenario'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            playClick();
                            _loadScenario(1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Text(''),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                I18n.t('finishLab'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check, color: Colors.white),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // CURTAIN SCREEN
        if (_showCurtain)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Block interactions behind
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_pizza,
                        size: 100,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        I18n.t('shutterTitle'),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        I18n.t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () {
                          curtainScreen();
                          setState(() {
                            _showCurtain = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 10,
                        ),
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          I18n.t('enterLab'),
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
            ),
          ),
      ],
    );
  }
}

// ==========================================
// CUSTOM PAINTER (NATIVE CANVAS ENGINE)
// ==========================================
class LabPainter extends CustomPainter {
  final double zoom;
  final double panX;
  final double panY;

  final int scenario;
  final int step;

  final List<Piece> pieces;
  final List<Plate> plates;
  final List<WholeRoti> wholes;
  final CollectionBox? collectionBox;
  final String? equation;

  final dynamic activeDragId;
  final double slicerX;
  final double slicerY;

  final bool slicerMenuOpen;
  final String slicerType;

  LabPainter({
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.scenario,
    required this.step,
    required this.pieces,
    required this.plates,
    required this.wholes,
    required this.collectionBox,
    required this.equation,
    required this.activeDragId,
    required this.slicerX,
    required this.slicerY,
    required this.slicerMenuOpen,
    required this.slicerType,
  });

  void drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double lineW,
  ) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    Paint p = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, p);
    p
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineW;
    canvas.drawRRect(rrect, p);
  }

  void drawTextOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fill,
    Color stroke, {
    bool bold = false,
  }) {
    TextStyle style = TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: fill,
      fontFamily: 'Plus Jakarta Sans',
    );
    TextSpan span = TextSpan(style: style, text: text);
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // Draw Stroke manually is tricky in basic CustomPainter, we'll draw shadows instead to mimic the outline
    if (stroke != Colors.transparent) {
      TextStyle strokeStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = stroke,
        fontFamily: 'Plus Jakarta Sans',
      );
      TextPainter tpStroke = TextPainter(
        text: TextSpan(style: strokeStyle, text: text),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tpStroke.layout();
      tpStroke.paint(
        canvas,
        Offset(x - tpStroke.width / 2, y - tpStroke.height / 2),
      );
    }

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void drawRotiSlice(
    Canvas canvas,
    double x,
    double y,
    double radius,
    double startAngle,
    double endAngle,
    bool isWhole,
  ) {
    canvas.save();
    canvas.translate(x, y);

    Paint fill = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    Paint crust = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Rect rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    if (isWhole) {
      canvas.drawCircle(Offset.zero, radius, fill);
      canvas.drawCircle(Offset.zero, radius, crust);
    } else {
      Path path = Path();
      path.moveTo(0, 0);
      path.arcTo(rect, startAngle, endAngle - startAngle, false);
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, crust);
    }

    // Spots
    canvas.save();
    if (isWhole) {
      canvas.clipPath(Path()..addOval(rect));
    } else {
      Path p = Path()
        ..moveTo(0, 0)
        ..arcTo(rect, startAngle, endAngle - startAngle, false)
        ..close();
      canvas.clipPath(p);
    }

    Paint spots = Paint()
      ..color = const Color(0x80B45309)
      ..style = PaintingStyle.fill;
    final points = [
      {'x': 0.2, 'y': 0.3, 'r': 0.15},
      {'x': -0.3, 'y': 0.1, 'r': 0.2},
      {'x': 0.4, 'y': -0.4, 'r': 0.1},
      {'x': -0.1, 'y': -0.5, 'r': 0.25},
      {'x': 0.1, 'y': 0.6, 'r': 0.12},
      {'x': -0.5, 'y': -0.2, 'r': 0.15},
      {'x': 0.6, 'y': 0.1, 'r': 0.1},
      {'x': -0.4, 'y': 0.5, 'r': 0.18},
    ];
    for (var p in points) {
      canvas.drawCircle(
        Offset(p['x']! * radius, p['y']! * radius),
        p['r']! * radius,
        spots,
      );
    }

    canvas.restore(); // unclip
    canvas.restore(); // untranslate
  }

  void drawPizzaCutter(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    // Handle
    drawRoundedRect(
      canvas,
      15,
      -45,
      12,
      40,
      6,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      2,
    );
    // Stem
    Path stem = Path()
      ..moveTo(21, -5)
      ..lineTo(10, 20)
      ..lineTo(5, 15)
      ..lineTo(21, -5)
      ..close();
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Guard
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 15),
      pi * 1.5,
      pi * 0.5,
      true,
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 15),
      pi * 1.5,
      pi * 0.5,
      true,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Blade
    canvas.drawCircle(
      Offset.zero,
      25,
      Paint()
        ..color = const Color(0xFFF8FAFC)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset.zero,
      25,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Pin
    canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFF0F172A));

    canvas.restore();
  }

  void drawPlate(
    Canvas canvas,
    double x,
    double y,
    double radius,
    String label,
  ) {
    drawRoundedRect(
      canvas,
      x - radius - 10,
      y + radius + 10,
      radius * 2 + 20,
      35,
      10,
      const Color(0xFFF1F5F9),
      const Color(0xFF94A3B8),
      2,
    );
    drawTextOutline(
      canvas,
      label,
      x,
      y + radius + 27,
      14,
      const Color(0xFF475569),
      Colors.transparent,
      bold: true,
    );

    // Rim
    canvas.drawCircle(
      Offset(x, y),
      radius + 15,
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawCircle(
      Offset(x, y),
      radius + 15,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    // Inner Base
    canvas.drawCircle(
      Offset(x, y),
      radius - 5,
      Paint()..color = const Color(0xFFF8FAFC),
    );
    canvas.drawCircle(
      Offset(x, y),
      radius - 5,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Shine
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, y), radius: radius + 5),
      pi * 1.2,
      pi * 0.5,
      false,
      Paint()
        ..color = const Color(0xCCFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    // Background Elements
    if (scenario == 1 || scenario == 3 || scenario == 5) {
      drawRoundedRect(
        canvas,
        -450,
        -200,
        900,
        100,
        8,
        const Color(0xFF334155),
        const Color(0xFF0F172A),
        4,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_belt'),
        0,
        -220,
        16,
        const Color(0xFFF8FAFC),
        Colors.transparent,
        bold: true,
      );
      // Belt Dots
      for (double i = -420; i < 420; i += 40) {
        canvas.drawCircle(
          Offset(i, -150),
          4,
          Paint()..color = const Color(0xFF64748B),
        );
      }
    }

    if (scenario == 2 || scenario == 4) {
      drawRoundedRect(
        canvas,
        -400,
        -100,
        800,
        200,
        15,
        const Color(0xFFC2410C),
        const Color(0xFF7C2D12),
        4,
      );
      // Toolbox
      drawRoundedRect(
        canvas,
        -80,
        -270,
        160,
        100,
        8,
        const Color(0xFF475569),
        const Color(0xFF0F172A),
        3,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_slicer'),
        0,
        -250,
        14,
        const Color(0xFFF8FAFC),
        Colors.transparent,
        bold: true,
      );
      if (activeDragId != 'slicer') drawPizzaCutter(canvas, 0, -210, 1.2);
    }

    // Plates
    for (var pl in plates) {
      String lbl = pl.type == 'full'
          ? I18n.t('lbl_plate_full')
          : I18n.t('lbl_plate_partial');
      drawPlate(canvas, pl.x, pl.y, 65, lbl);

      if (pl.isWhole) {
        drawTextOutline(
          canvas,
          I18n.t('lbl_whole_roti'),
          pl.x,
          pl.y,
          16,
          const Color(0xFF0F172A),
          const Color(0xFFF8FAFC),
          bold: true,
        );
        // Glow
        canvas.drawCircle(
          Offset(pl.x, pl.y),
          60,
          Paint()
            ..color = const Color(0x80FACC15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      } else if (pl.pieces.isEmpty) {
        drawTextOutline(
          canvas,
          I18n.t('lbl_empty'),
          pl.x,
          pl.y,
          14,
          const Color(0xFF94A3B8),
          Colors.transparent,
        );
      }
    }

    // Collection Box (S4)
    if (scenario == 4 && collectionBox != null) {
      drawRoundedRect(
        canvas,
        collectionBox!.x,
        collectionBox!.y,
        collectionBox!.w,
        collectionBox!.h,
        10,
        const Color(0x1A000000),
        const Color(0xFF64748B),
        3,
      );
      drawTextOutline(
        canvas,
        "${I18n.t('lbl_collection')}: ${collectionBox!.collected}/17",
        0,
        160,
        16,
        const Color(0xFFF8FAFC),
        Colors.transparent,
        bold: true,
      );
    }

    // Wholes
    for (var w in wholes) {
      if (!w.sliced) drawRotiSlice(canvas, w.x, w.y, 60, 0, 0, true);
    }

    // Pieces
    for (var p in pieces) {
      var plateOpt = plates.where((pl) => pl.id == p.zone).firstOrNull;
      if (plateOpt != null && plateOpt.isWhole) continue; // Drawn by plate

      bool isDragged = activeDragId == p.id;
      if (isDragged) {
        canvas.save();
        canvas.translate(0, 5); // visual drop shadow offset
        canvas.drawCircle(
          Offset(p.x, p.y),
          60,
          Paint()
            ..color = Colors.black45
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.restore();
      }

      drawRotiSlice(
        canvas,
        p.x,
        p.y,
        60,
        p.startAngle,
        p.startAngle + p.angle,
        false,
      );
    }

    // Whole Roti visual representations for full plates
    for (var pl in plates) {
      if (pl.isWhole) drawRotiSlice(canvas, pl.x, pl.y, 60, 0, 0, true);
    }

    // Dragged Slicer
    if (activeDragId == 'slicer') {
      drawPizzaCutter(canvas, slicerX, slicerY, 1.2);
    }

    // Slicer Menu (S4)
    if (slicerMenuOpen && scenario == 4) {
      drawRoundedRect(
        canvas,
        -110,
        -140,
        220,
        200,
        10,
        const Color(0xFFF8FAFC),
        const Color(0xFF0F172A),
        3,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_btn_menu'),
        0,
        -120,
        14,
        const Color(0xFF475569),
        Colors.transparent,
        bold: true,
      );
      List<String> opts = ['halves', 'thirds', 'quarters', 'fifths'];
      for (int i = 0; i < opts.length; i++) {
        double by = -90 + i * 40.0;
        drawRoundedRect(
          canvas,
          -90,
          by - 15,
          180,
          30,
          5,
          slicerType == opts[i]
              ? const Color(0xFFBAE6FD)
              : const Color(0xFFE2E8F0),
          const Color(0xFF94A3B8),
          1,
        );
        drawTextOutline(
          canvas,
          opts[i].toUpperCase(),
          0,
          by,
          14,
          const Color(0xFF0F172A),
          Colors.transparent,
          bold: true,
        );
      }
    }

    // Action Buttons
    if (scenario == 1 && step == 4) {
      drawRoundedRect(
        canvas,
        -60,
        250,
        120,
        50,
        25,
        const Color(0xFFF59E0B),
        const Color(0xFFB45309),
        4,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_btn_summarize'),
        0,
        275,
        16,
        Colors.white,
        Colors.transparent,
        bold: true,
      );
    }
    if (scenario == 2 && step == 2) {
      drawRoundedRect(
        canvas,
        -60,
        200,
        120,
        50,
        25,
        const Color(0xFFF59E0B),
        const Color(0xFFB45309),
        4,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_btn_summarize'),
        0,
        225,
        16,
        Colors.white,
        Colors.transparent,
        bold: true,
      );
    }
    if (scenario == 3 && step == 3) {
      drawRoundedRect(
        canvas,
        -60,
        250,
        120,
        50,
        25,
        const Color(0xFFF59E0B),
        const Color(0xFFB45309),
        4,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_btn_summarize'),
        0,
        275,
        16,
        Colors.white,
        Colors.transparent,
        bold: true,
      );
    }
    if (scenario == 5 && step == 2) {
      drawRoundedRect(
        canvas,
        -80,
        250,
        160,
        50,
        25,
        const Color(0xFF10B981),
        const Color(0xFF047857),
        4,
      );
      drawTextOutline(
        canvas,
        I18n.t('lbl_btn_check'),
        0,
        275,
        16,
        Colors.white,
        Colors.transparent,
        bold: true,
      );
    }

    // Equation Output
    if (equation != null) {
      drawRoundedRect(
        canvas,
        -150,
        -60,
        300,
        80,
        10,
        const Color(0xE6FFFFFF),
        const Color(0xFFF59E0B),
        4,
      );
      drawTextOutline(
        canvas,
        equation!,
        0,
        -20,
        36,
        const Color(0xFFB45309),
        Colors.transparent,
        bold: true,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
