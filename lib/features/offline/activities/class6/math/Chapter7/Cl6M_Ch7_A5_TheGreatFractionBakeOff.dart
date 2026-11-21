// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: library_private_types_in_public_api, use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Comparing Fractions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const Cl6M_Ch7_A5_TheGreatFractionBakeOff(),
    ),
  );
}

// --- SIMULATION STATE ---
class SimState {
  // S1
  bool s1RotiLPlaced = false;
  bool s1RotiRPlaced = false;
  bool s1CutL = false;
  bool s1CutR = false;
  bool s1PanLPlaced = false;
  bool s1PanRPlaced = false;
  double s1Tilt = 0;

  // S2
  bool s2Poured1 = false;
  bool s2Poured2 = false;
  bool s2ShelfL = false;
  bool s2ShelfR = false;

  // S3
  bool s3ChikkiAPlaced = false;
  bool s3ChikkiBPlaced = false;
  bool s3MatL = false;
  bool s3MatR = false;
  bool s3Equalized = false;

  // S4
  bool s4Poured1 = false;
  bool s4Poured2 = false;
  bool s4ShelfL = false;
  bool s4ShelfR = false;
  bool s4Equalized = false;
  String? s4Symbol;

  // S5
  bool s5SugarA = false;
  bool s5SugarB = false;
  bool s5Equalized = false;
  bool s5WinnerClicked = false;

  void resetScenario(int id) {
    if (id == 1) {
      s1RotiLPlaced = s1RotiRPlaced = s1CutL = s1CutR = s1PanLPlaced =
          s1PanRPlaced = false;
      s1Tilt = 0;
    } else if (id == 2) {
      s2Poured1 = s2Poured2 = s2ShelfL = s2ShelfR = false;
    } else if (id == 3) {
      s3ChikkiAPlaced = s3ChikkiBPlaced = s3MatL = s3MatR = s3Equalized = false;
    } else if (id == 4) {
      s4Poured1 = s4Poured2 = s4ShelfL = s4ShelfR = s4Equalized = false;
      s4Symbol = null;
    } else if (id == 5) {
      s5SugarA = s5SugarB = s5Equalized = s5WinnerClicked = false;
    }
  }
}

// --- TRANSLATIONS ---
final Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle':
        "The Great Fraction Bake-Off: Visualizing and Comparing Shares",
    'appTitle': "The Great Fraction Bake-Off",
    'appSubtitle': "Class 6 • COMPARING FRACTIONS",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Mission Objective:",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc': "You have successfully visualized and compared fractions!",
    'lbl_slicer': "Activate Slicer",
    'lbl_pour': "Pour Juice",
    'lbl_equalizer': "Fraction Equalizer",
    'lbl_recipeA': "Recipe A",
    'lbl_recipeB': "Recipe B",
    'lbl_winner': "Winner!",
    // Scenarios
    's1_title': "1. The Roti Sharing Challenge",
    's1_obj':
        "Visually understand that sharing one whole item with more people results in a smaller individual share (1/2 > 1/4).",
    's1_step1_task':
        "DRAG a 'Roti' from the tray and DROP it onto the left table (2 children).",
    's1_step1_out': "The Roti is placed on the table.",
    's1_step2_task': "CLICK the 'Activate Slicer' button above the left table.",
    's1_step2_out': "The roti is cut into 2 equal halves. Each gets 1/2.",
    's1_step3_task':
        "DRAG another 'Roti' to the right table (4 children). CLICK the 'Activate Slicer' button.",
    's1_step3_out': "The roti is cut into 4 equal quarters. Each gets 1/4.",
    's1_step4_task':
        "DRAG one '1/2' piece of roti onto the left pan of the Comparison Scale.",
    's1_step4_out': "The 1/2 piece sits on the scale.",
    's1_step5_task': "DRAG one '1/4' piece of roti onto the right pan.",
    's1_step5_out':
        "Observation: The scale tilts left! 1/2 is heavier/bigger than 1/4.",
    's1_hud1': "Drag a roti to the left table.",
    's1_hud2': "Click 'Activate Slicer'.",
    's1_hud3': "Drag a roti to the right table and slice it.",
    's1_hud4': "Drag a 1/2 piece to the left pan.",
    's1_hud5': "Drag a 1/4 piece to the right pan.",

    's2_title': "2. The Juice Jugs",
    's2_obj':
        "Understand that when denominators are the same, the fraction with the larger numerator is greater (4/7 > 3/7).",
    's2_step1_task':
        "DRAG the 'Magic Pourer' to Group 1 (3 Glasses for 7 kids).",
    's2_step1_out': "Pourer is ready.",
    's2_step2_task': "CLICK the 'Pour' button.",
    's2_step2_out': "Juice is equally distributed. Each glass filled to 3/7.",
    's2_step3_task':
        "DRAG the 'Magic Pourer' to Group 2 (4 Glasses for 7 kids). CLICK 'Pour'.",
    's2_step3_out': "Each glass is filled to 4/7.",
    's2_step4_task':
        "DRAG one glass from Group 1 to the left side of the Comparison Shelf.",
    's2_step4_out': "Glass 3/7 is on the shelf.",
    's2_step5_task':
        "DRAG one glass from Group 2 to the right side of the shelf.",
    's2_step5_out':
        "Observation: The 4/7 glass clearly has more liquid. 4/7 > 3/7.",
    's2_hud1': "Drag Magic Pourer to Group 1.",
    's2_hud2': "Click Pour.",
    's2_hud3': "Pour juice for Group 2.",
    's2_hud4': "Drag a 3/7 glass to the shelf.",
    's2_hud5': "Drag a 4/7 glass to the shelf.",

    's3_title': "3. The Chikki Equalizer",
    's3_obj':
        "Learn how to compare fractions with different denominators by finding a common fractional unit.",
    's3_step1_task': "DRAG 1 chikki bar and DROP it on Scenario A.",
    's3_step1_out': "Chikki is sliced. Each gets 1/2.",
    's3_step2_task': "DRAG 5 chikki bars and DROP them on Scenario B.",
    's3_step2_out': "Chikkis are sliced into 5/8 for each child.",
    's3_step3_task':
        "DRAG one share from Scenario A (1/2) to the left side of the Comparison Mat.",
    's3_step3_out': "1/2 piece is on the mat.",
    's3_step4_task': "DRAG one share from Scenario B (5/8) to the right side.",
    's3_step4_out': "Both are on the mat. They are hard to compare visually.",
    's3_step5_task':
        "CLICK the 'Fraction Equalizer' button to make the pieces the same size.",
    's3_step5_out':
        "Observation: 1/2 is equalized into 4/8. Now it's easy to see 5/8 > 4/8.",
    's3_hud1': "Drag 1 chikki to Scenario A.",
    's3_hud2': "Drag 5 chikkis to Scenario B.",
    's3_hud3': "Drag a 1/2 piece to the mat.",
    's3_hud4': "Drag a 5/8 pile to the mat.",
    's3_hud5': "Click the Fraction Equalizer.",

    's4_title': "4. The Sugarcane Juice-Off",
    's4_obj':
        "Compare 3/4 and 7/10 to determine which group gets a larger share.",
    's4_step1_task': "DRAG the Magic Pourer to pour juice for both Groups.",
    's4_step1_out': "Glasses filled to 3/4 and 7/10.",
    's4_step2_task': "DRAG a glass from each group to the Comparison Shelf.",
    's4_step2_out': "Glasses placed. Very close!",
    's4_step3_task': "DRAG the 'Fraction Equalizer' tool onto the glasses.",
    's4_step3_out':
        "Gridlines added! 3/4 becomes 15/20 and 7/10 becomes 14/20.",
    's4_step4_task': "DRAG the correct symbol (<, >, =) into the box.",
    's4_step4_out': "Observation: 15/20 is greater. 3/4 > 7/10.",
    's4_hud1': "Pour juice for both groups.",
    's4_hud2': "Drag glasses to the shelf.",
    's4_hud3': "Drag Equalizer tool onto glasses.",
    's4_hud4': "Drag > symbol into the box.",

    's5_title': "5. The Recipe Challenge",
    's5_obj':
        "Compare 2/3 and 5/6 to determine which recipe requires more sugar.",
    's5_step1_task': "DRAG the Sugar Bag to Cup A (2/3).",
    's5_step1_out': "Cup A filled to 2/3.",
    's5_step2_task': "DRAG the Sugar Bag to Cup B (5/6).",
    's5_step2_out': "Cup B filled to 5/6.",
    's5_step3_task': "DRAG the Equalizer Tool to the cups.",
    's5_step3_out': "2/3 is equalized to 4/6.",
    's5_step4_task': "CLICK on the recipe card that uses more sugar.",
    's5_step4_out': "Observation: Recipe B (5/6) uses more sugar!",
    's5_hud1': "Fill Cup A.",
    's5_hud2': "Fill Cup B.",
    's5_hud3': "Use the Equalizer Tool.",
    's5_hud4': "Click the winning recipe.",
  },
  'hi': {
    'shutterTitle': "महान अंश बेक-ऑफ़: भिन्नों की तुलना",
    'appTitle': "महान अंश बेक-ऑफ़",
    'appSubtitle': "कक्षा 6 • भिन्नों की तुलना",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc': "आपने भिन्नों की सफलतापूर्वक तुलना की है!",
    'lbl_slicer': "स्लाइसर",
    'lbl_pour': "डालें",
    'lbl_equalizer': "इक्वलाइज़र",
    'lbl_recipeA': "पकाने की विधि A",
    'lbl_recipeB': "पकाने की विधि B",
    'lbl_winner': "विजेता!",

    's1_title': "1. रोटी बाँटने की चुनौती",
    's1_obj':
        "नेत्रहीन रूप से समझें कि अधिक लोगों के साथ बाँटने पर हिस्सा छोटा हो जाता है (1/2 > 1/4)।",
    's1_step1_task': "ट्रे से एक 'रोटी' खींचें और बाएँ टेबल पर छोड़ें।",
    's1_step1_out': "रोटी टेबल पर रखी गई है।",
    's1_step2_task': "बाएँ टेबल के ऊपर 'स्लाइसर' बटन पर क्लिक करें।",
    's1_step2_out':
        "रोटी 2 बराबर भागों में कट गई है। प्रत्येक को 1/2 मिलता है।",
    's1_step3_task': "दाएँ टेबल पर एक और रोटी खींचें और स्लाइसर सक्रिय करें।",
    's1_step3_out': "रोटी 4 भागों में कट गई। प्रत्येक को 1/4 मिलता है।",
    's1_step4_task': "रोटी का एक 1/2 टुकड़ा बाएँ पलड़े पर खींचें।",
    's1_step4_out': "1/2 टुकड़ा रखा गया।",
    's1_step5_task': "रोटी का एक 1/4 टुकड़ा दाएँ पलड़े पर खींचें।",
    's1_step5_out': "अवलोकन: पलड़ा बायीं ओर झुकता है! 1/2 भारी है।",
    's1_hud1': "बाएँ टेबल पर रोटी खींचें।",
    's1_hud2': "स्लाइसर पर क्लिक करें।",
    's1_hud3': "दाएँ टेबल पर रोटी खींचें और काटें।",
    's1_hud4': "1/2 टुकड़ा बाएँ पलड़े पर रखें।",
    's1_hud5': "1/4 टुकड़ा दाएँ पलड़े पर रखें।",

    's2_title': "2. जूस जग",
    's2_obj':
        "समझें कि जब हर समान होते हैं, तो बड़ा अंश बड़ा होता है (4/7 > 3/7)।",
    's2_step1_task': "समूह 1 पर 'मैजिक पोरर' खींचें।",
    's2_step1_out': "पोरर तैयार है।",
    's2_step2_task': "'डालें' बटन पर क्लिक करें।",
    's2_step2_out': "जूस बँट गया। प्रत्येक गिलास 3/7 तक भर गया।",
    's2_step3_task': "समूह 2 पर पोरर खींचें और 'डालें' पर क्लिक करें।",
    's2_step3_out': "प्रत्येक गिलास 4/7 तक भर गया।",
    's2_step4_task': "समूह 1 के गिलास को शेल्फ के बायीं ओर खींचें।",
    's2_step4_out': "3/7 गिलास शेल्फ पर है।",
    's2_step5_task': "समूह 2 के गिलास को शेल्फ के दायीं ओर खींचें।",
    's2_step5_out': "अवलोकन: 4/7 गिलास में अधिक जूस है। 4/7 > 3/7।",
    's2_hud1': "पोरर समूह 1 पर लाएँ।",
    's2_hud2': "जूस डालें।",
    's2_hud3': "समूह 2 के लिए डालें।",
    's2_hud4': "शेल्फ पर 3/7 गिलास रखें।",
    's2_hud5': "शेल्फ पर 4/7 गिलास रखें।",

    's3_title': "3. चिक्की इक्वलाइज़र",
    's3_obj': "समान हर खोजकर विभिन्न हर वाले भिन्नों की तुलना करना सीखें।",
    's3_step1_task': "1 चिक्की को परिदृश्य A पर खींचें।",
    's3_step1_out': "चिक्की कट गई। 1/2 हिस्सा।",
    's3_step2_task': "5 चिक्की को परिदृश्य B पर खींचें।",
    's3_step2_out': "चिक्की 5/8 में कट गई।",
    's3_step3_task': "परिदृश्य A (1/2) से एक हिस्सा मैट के बायीं ओर खींचें।",
    's3_step3_out': "1/2 हिस्सा मैट पर है।",
    's3_step4_task': "परिदृश्य B (5/8) से एक हिस्सा दायीं ओर खींचें।",
    's3_step4_out': "तुलना करना कठिन है।",
    's3_step5_task':
        "टुकड़ों को समान करने के लिए 'इक्वलाइज़र' बटन पर क्लिक करें।",
    's3_step5_out': "अवलोकन: 1/2, 4/8 बन गया। 5/8 > 4/8।",
    's3_hud1': "A पर 1 चिक्की खींचें।",
    's3_hud2': "B पर 5 चिक्की खींचें।",
    's3_hud3': "मैट पर 1/2 रखें।",
    's3_hud4': "मैट पर 5/8 रखें।",
    's3_hud5': "इक्वलाइज़र पर क्लिक करें।",

    's4_title': "4. गन्ने का रस",
    's4_obj':
        "यह निर्धारित करने के लिए 3/4 और 7/10 की तुलना करें कि किसे बड़ा हिस्सा मिलता है।",
    's4_step1_task': "दोनों समूहों के लिए जूस डालें।",
    's4_step1_out': "गिलास 3/4 और 7/10 तक भर गए।",
    's4_step2_task': "प्रत्येक समूह से एक गिलास शेल्फ पर खींचें।",
    's4_step2_out': "गिलास रखे गए।",
    's4_step3_task': "गिलासों पर 'इक्वलाइज़र' टूल खींचें।",
    's4_step3_out': "3/4, 15/20 बन गया और 7/10, 14/20 बन गया।",
    's4_step4_task': "बॉक्स में सही प्रतीक (<, >, =) खींचें।",
    's4_step4_out': "अवलोकन: 15/20 बड़ा है। 3/4 > 7/10।",
    's4_hud1': "दोनों के लिए जूस डालें।",
    's4_hud2': "शेल्फ पर गिलास रखें।",
    's4_hud3': "इक्वलाइज़र टूल का उपयोग करें।",
    's4_hud4': "> प्रतीक को बॉक्स में खींचें।",

    's5_title': "5. पकाने की चुनौती",
    's5_obj': "2/3 और 5/6 की तुलना करें।",
    's5_step1_task': "चीनी के बैग को कप A पर खींचें।",
    's5_step1_out': "कप A, 2/3 भर गया।",
    's5_step2_task': "चीनी के बैग को कप B पर खींचें।",
    's5_step2_out': "कप B, 5/6 भर गया।",
    's5_step3_task': "कप पर इक्वलाइज़र टूल खींचें।",
    's5_step3_out': "2/3, 4/6 हो गया।",
    's5_step4_task': "अधिक चीनी वाले कार्ड पर क्लिक करें।",
    's5_step4_out': "अवलोकन: B (5/6) में अधिक चीनी है!",
    's5_hud1': "कप A भरें।",
    's5_hud2': "कप B भरें।",
    's5_hud3': "इक्वलाइज़र टूल का उपयोग करें।",
    's5_hud4': "विजेता कार्ड पर क्लिक करें।",
  },
};

// --- MAIN WIDGET ---
class Cl6M_Ch7_A5_TheGreatFractionBakeOff extends StatefulWidget {
  const Cl6M_Ch7_A5_TheGreatFractionBakeOff({Key? key}) : super(key: key);

  @override
  _Cl6M_Ch7_A5_TheGreatFractionBakeOffState createState() =>
      _Cl6M_Ch7_A5_TheGreatFractionBakeOffState();
}

class _Cl6M_Ch7_A5_TheGreatFractionBakeOffState
    extends State<Cl6M_Ch7_A5_TheGreatFractionBakeOff>
    with SingleTickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _animCtrl;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // State Vars
  String _lang = 'en';
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _showSuccessPopup = false;

  int _scenario = 1;
  int _step = 0;

  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;
  double _baseZoom = 1.0;

  SimState sim = SimState();
  String? _activeDragEntity;
  double _dragX = 0;
  double _dragY = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _animCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

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

  String t(String key) {
    return translations[_lang]?[key] ?? translations['en']![key] ?? key;
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _showSuccessPopup = false;
      sim.resetScenario(id);
      _activeDragEntity = null;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
    _checkScenarioSuccess();
  }

  void _checkScenarioSuccess() {
    int maxSteps = _scenario == 1
        ? 5
        : _scenario == 2
        ? 5
        : _scenario == 3
        ? 5
        : _scenario == 4
        ? 4
        : 4;
    if (_step >= maxSteps) {
      if (_scenario == 5) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          playPageOpen();
          setState(() {
            _showSuccessPopup = true;
          });
        });
      } else {
        playPageOpen(); // Sound to celebrate scenario completion
        setState(() {});
      }
    }
  }

  // --- GESTURE LOGIC ---
  bool hitTestBox(
    double ptX,
    double ptY,
    double x,
    double y,
    double w,
    double h, [
    double pad = 15,
  ]) {
    return ptX > (x - pad) &&
        ptX < (x + w + pad) &&
        ptY > (y - pad) &&
        ptY < (y + h + pad);
  }

  bool hitTestCircle(
    double ptX,
    double ptY,
    double x,
    double y,
    double r, [
    double pad = 15,
  ]) {
    return math.sqrt(math.pow(ptX - x, 2) + math.pow(ptY - y, 2)) < (r + pad);
  }

  void _handleTapUp(TapUpDetails details) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(details.globalPosition);
    final ptX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
    final ptY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;

    bool success = false;

    if (_scenario == 1) {
      if (_step == 1 &&
          sim.s1RotiLPlaced &&
          !sim.s1CutL &&
          hitTestBox(ptX, ptY, -370, -125, 120, 35)) {
        sim.s1CutL = true;
        _advanceStep();
        success = true;
      }
      if (_step == 2 &&
          sim.s1RotiRPlaced &&
          !sim.s1CutR &&
          hitTestBox(ptX, ptY, 260, -125, 120, 35)) {
        sim.s1CutR = true;
        _advanceStep();
        success = true;
      }
    } else if (_scenario == 2) {
      if (_step == 1 && hitTestBox(ptX, ptY, -310, 60, 100, 35)) {
        sim.s2Poured1 = true;
        _advanceStep();
        success = true;
      }
      if (_step == 3 && hitTestBox(ptX, ptY, 210, 60, 100, 35)) {
        sim.s2Poured2 = true;
        _advanceStep();
        success = true;
      }
    } else if (_scenario == 3) {
      if (_step == 4 && hitTestBox(ptX, ptY, -80, 280, 160, 45)) {
        sim.s3Equalized = true;
        _advanceStep();
        success = true;
      }
    } else if (_scenario == 5) {
      if (_step == 3 && hitTestBox(ptX, ptY, 60, -180, 160, 200)) {
        sim.s5WinnerClicked = true;
        _advanceStep();
        success = true;
      }
    }

    if (success) playClick();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = _zoom;
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(details.focalPoint);
    final ptX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
    final ptY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;

    if (_scenario == 1) {
      if (_step == 0 &&
          !sim.s1RotiLPlaced &&
          hitTestCircle(ptX, ptY, -50, 190, 30)) {
        _activeDragEntity = 'r_full_L';
      }
      if (_step == 2 &&
          !sim.s1RotiRPlaced &&
          hitTestCircle(ptX, ptY, 50, 190, 30)) {
        _activeDragEntity = 'r_full_R';
      }
      if (_step == 3 && hitTestCircle(ptX, ptY, -310, -20, 35)) {
        _activeDragEntity = 'r_half';
      }
      if (_step == 4 && hitTestCircle(ptX, ptY, 320, -20, 35)) {
        _activeDragEntity = 'r_quat';
      }
    } else if (_scenario == 2) {
      if (_step == 0 && hitTestBox(ptX, ptY, -15, 20, 30, 60)) {
        _activeDragEntity = 'pourer';
      }
      if (_step == 2 && hitTestBox(ptX, ptY, -15, 20, 30, 60)) {
        _activeDragEntity = 'pourer';
      }
      if (_step == 4 && hitTestBox(ptX, ptY, -360, -75, 240, 40)) {
        _activeDragEntity = 'g3';
      }
      if (_step == 5 && hitTestBox(ptX, ptY, 140, -75, 240, 40)) {
        _activeDragEntity = 'g4';
      }
    } else if (_scenario == 3) {
      if (_step == 0 && hitTestBox(ptX, ptY, -30, -100, 60, 30)) {
        _activeDragEntity = 'chkA';
      }
      if (_step == 1 && hitTestBox(ptX, ptY, -30, -80, 60, 30)) {
        _activeDragEntity = 'chkB';
      }
      if (_step == 2 && hitTestBox(ptX, ptY, -290, -45, 80, 40)) {
        _activeDragEntity = 'p12';
      }
      if (_step == 3 && hitTestBox(ptX, ptY, 140, -45, 100, 60)) {
        _activeDragEntity = 'p58';
      }
    } else if (_scenario == 4) {
      if (_step == 0 && hitTestBox(ptX, ptY, -40, 50, 80, 50)) {
        _activeDragEntity = 'pourer_s4';
      }
      if (_step == 1 &&
          !sim.s4ShelfL &&
          hitTestBox(ptX, ptY, -300, -160, 100, 120)) {
        _activeDragEntity = 'g3_s4';
      }
      if (_step == 1 &&
          !sim.s4ShelfR &&
          hitTestBox(ptX, ptY, 200, -160, 100, 120)) {
        _activeDragEntity = 'g4_s4';
      }
      if (_step == 2 && hitTestBox(ptX, ptY, 200, 80, 180, 80)) {
        _activeDragEntity = 'eq_s4';
      }
      if (_step == 3) {
        if (hitTestBox(ptX, ptY, -100, 220, 60, 60)) {
          _activeDragEntity = 'sym_<';
        }
        if (hitTestBox(ptX, ptY, -30, 220, 60, 60)) {
          _activeDragEntity = 'sym_>';
        }
        if (hitTestBox(ptX, ptY, 40, 220, 60, 60)) {
          _activeDragEntity = 'sym_=';
        }
      }
    } else if (_scenario == 5) {
      if ((_step == 0 || _step == 1) &&
          hitTestBox(ptX, ptY, -30, 100, 60, 80)) {
        _activeDragEntity = 'sugar';
      }
      if (_step == 2 && hitTestBox(ptX, ptY, -70, 120, 140, 45)) {
        _activeDragEntity = 'eq';
      }
    }

    if (_activeDragEntity != null) {
      playClick(); // Sound for picking up an item
      setState(() {
        _dragX = ptX;
        _dragY = ptY;
      });
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_activeDragEntity != null) {
      final RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final localPos = box.globalToLocal(details.focalPoint);
        setState(() {
          _dragX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
          _dragY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;
        });
      }
    } else {
      setState(() {
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
        _zoom = (_baseZoom * details.scale).clamp(0.3, 3.0);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_activeDragEntity != null) {
      final ptX = _dragX;
      final ptY = _dragY;

      bool success = false;

      if (_activeDragEntity == 'r_full_L') {
        if (hitTestBox(ptX, ptY, -400, -60, 180, 80)) {
          sim.s1RotiLPlaced = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'r_full_R') {
        if (hitTestBox(ptX, ptY, 220, -60, 200, 80)) {
          sim.s1RotiRPlaced = true;
          success = true;
        }
      } else if (_activeDragEntity == 'r_half') {
        if (hitTestBox(ptX, ptY, -130, -100, 100, 100)) {
          sim.s1PanLPlaced = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'r_quat') {
        if (hitTestBox(ptX, ptY, 30, -100, 100, 100)) {
          sim.s1PanRPlaced = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'pourer') {
        if (_step == 0 && hitTestBox(ptX, ptY, -380, -100, 240, 120)) {
          _advanceStep();
          success = true;
        } else if (_step == 2 && hitTestBox(ptX, ptY, 130, -100, 260, 120)) {
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'g3') {
        if (hitTestBox(ptX, ptY, -150, 60, 150, 100)) {
          sim.s2ShelfL = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'g4') {
        if (hitTestBox(ptX, ptY, 0, 60, 150, 100)) {
          sim.s2ShelfR = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'chkA') {
        if (hitTestBox(ptX, ptY, -310, -100, 120, 100)) {
          sim.s3ChikkiAPlaced = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'chkB') {
        if (hitTestBox(ptX, ptY, 130, -100, 220, 100)) {
          sim.s3ChikkiBPlaced = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'p12') {
        if (hitTestBox(ptX, ptY, -200, 80, 200, 180)) {
          sim.s3MatL = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'p58') {
        if (hitTestBox(ptX, ptY, 0, 80, 200, 180)) {
          sim.s3MatR = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'pourer_s4') {
        if (hitTestBox(ptX, ptY, -400, -200, 800, 200)) {
          sim.s4Poured1 = true;
          sim.s4Poured2 = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'g3_s4') {
        if (hitTestBox(ptX, ptY, -300, 0, 300, 250)) {
          sim.s4ShelfL = true;
          if (sim.s4ShelfR) _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'g4_s4') {
        if (hitTestBox(ptX, ptY, 0, 0, 300, 250)) {
          sim.s4ShelfR = true;
          if (sim.s4ShelfL) _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'eq_s4') {
        if (hitTestBox(ptX, ptY, -250, 0, 500, 250)) {
          sim.s4Equalized = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity!.startsWith('sym_')) {
        if (hitTestBox(ptX, ptY, -100, 30, 200, 150)) {
          String sym = _activeDragEntity!.split('_')[1];
          if (sym == '>') {
            sim.s4Symbol = sym;
            _advanceStep();
            success = true;
          }
        }
      } else if (_activeDragEntity == 'sugar') {
        if (_step == 0 && hitTestBox(ptX, ptY, -220, -180, 160, 200)) {
          sim.s5SugarA = true;
          _advanceStep();
          success = true;
        } else if (_step == 1 && hitTestBox(ptX, ptY, 60, -180, 160, 200)) {
          sim.s5SugarB = true;
          _advanceStep();
          success = true;
        }
      } else if (_activeDragEntity == 'eq') {
        if (hitTestBox(ptX, ptY, -220, -180, 440, 200)) {
          sim.s5Equalized = true;
          _advanceStep();
          success = true;
        }
      }

      if (success) {
        playClick(); // Drop success
      } else {
        playError(); // Dropped outside valid zone
      }

      setState(() {
        _activeDragEntity = null;
      });
    }
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: _sidebarOpen ? _sidebarWidth : 0,
              child: ClipRect(
                child: GestureDetector(
                  onTapUp: _handleTapUp,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: CustomPaint(
                      key: _canvasKey,
                      painter: FractionPainter(
                        sim: sim,
                        scenario: _scenario,
                        step: _step,
                        panX: _panX,
                        panY: _panY,
                        zoom: _zoom,
                        activeDragEntity: _activeDragEntity,
                        dragX: _dragX,
                        dragY: _dragY,
                        t: t,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ),

            // HUD OVERLAY
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 30,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _getHudText().isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
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
                            blurRadius: 15,
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
                              _getHudText(),
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
            ),

            // NEXT SCENARIO BUTTON (Overlay on canvas)
            if (_step == _getMaxSteps() && _scenario < 5 && !_showSuccessPopup)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: 30,
                right: 30,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  icon: const Text(''), // Workaround to put icon on right
                  label: Row(
                    children: [
                      Text(
                        t('nextScenario'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  onPressed: () {
                    playPageOpen();
                    _loadScenario(_scenario + 1);
                  },
                ),
              ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: const Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 20),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 62,
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Context (Icon + Title, Lang/Reset Sub-buttons)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.pie_chart,
                                          color: Colors.indigoAccent,
                                          size: 36,
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
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                t('appSubtitle'),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      playClick();
                                                      setState(() {
                                                        _lang = _lang == 'en'
                                                            ? 'hi'
                                                            : 'en';
                                                      });
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white10,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.language,
                                                            size: 14,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            _lang.toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  InkWell(
                                                    onTap: () {
                                                      playClick();
                                                      _loadScenario(1);
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.redAccent
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.refresh,
                                                            size: 14,
                                                            color: Colors
                                                                .redAccent,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            'Reset',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .redAccent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Colors.white12,
                                      height: 40,
                                      thickness: 1,
                                    ),

                                    // Controls & Steps
                                    Text(
                                      t('selectScenario').toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white54,
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
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _scenario,
                                          isExpanded: true,
                                          dropdownColor: const Color(
                                            0xFF0F172A,
                                          ),
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          onChanged: (val) {
                                            if (val != null) {
                                              playDropdown();
                                              _loadScenario(val);
                                            }
                                          },
                                          items: [1, 2, 3, 4, 5].map((i) {
                                            return DropdownMenuItem<int>(
                                              value: i,
                                              child: Text(t('s${i}_title')),
                                            );
                                          }).toList(),
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
                                        border: Border.all(
                                          color: Colors.white12,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.my_location,
                                                color: Colors.pinkAccent,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                t('learnLbl'),
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
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ..._buildSteps(),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Footer
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                color: const Color(0xFF0F172A),
                                alignment: Alignment.center,
                                child: const Text(
                                  '© ZeroScienceLab | Fall in love with Math and Science',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Resizer Handle
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        setState(() {
                          _sidebarWidth += details.delta.dx;
                          if (_sidebarWidth < 350) _sidebarWidth = 350;
                          if (_sidebarWidth >
                              MediaQuery.of(context).size.width * 0.6) {
                            _sidebarWidth =
                                MediaQuery.of(context).size.width * 0.6;
                          }
                        });
                      },
                      child: Container(
                        width: 10,
                        height: double.infinity,
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
                  ],
                ),
              ),
            ),

            // MENU BUTTON
            Positioned(
              top: 10,
              left: 10,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                  onPressed: () {
                    playClick();
                    setState(() {
                      _sidebarOpen = !_sidebarOpen;
                    });
                  },
                ),
              ),
            ),

            // CURTAIN RAISER
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.pie_chart,
                          color: Colors.indigoAccent,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t('shutterTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            curtainScreen();
                            setState(() {
                              _showCurtain = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // SUCCESS POPUP
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 40,
                            child: Icon(
                              Icons.flag,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(
                              Icons.restart_alt,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              playClick();
                              setState(() {
                                _showSuccessPopup = false;
                                _showCurtain = true;
                                _loadScenario(1);
                              });
                            },
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

  int _getMaxSteps() => _scenario == 1
      ? 5
      : _scenario == 2
      ? 5
      : _scenario == 3
      ? 5
      : _scenario == 4
      ? 4
      : 4;

  String _getHudText() {
    int s = _step;
    if (s >= _getMaxSteps()) return '';
    return t('s${_scenario}_hud${s + 1}');
  }

  List<Widget> _buildSteps() {
    int maxSteps = _getMaxSteps();
    List<Widget> list = [];
    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < _step;
      bool isActive = i == _step;
      bool isFuture = i > _step;

      Color bgColor = isActive
          ? Colors.indigoAccent.withOpacity(0.1)
          : (isCompleted
                ? Colors.green.withOpacity(0.05)
                : Colors.white.withOpacity(0.02));
      Color borderColor = isActive
          ? Colors.indigoAccent
          : (isCompleted ? Colors.green.withOpacity(0.3) : Colors.transparent);

      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else if (isActive)
                CircleAvatar(
                  backgroundColor: Colors.indigoAccent,
                  radius: 12,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 12,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('stepLabel')} ${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isFuture ? Colors.white30 : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: isFuture
                              ? Colors.white30
                              : (isActive
                                    ? Colors.indigo.shade200
                                    : Colors.white),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Action: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: t('s${_scenario}_step${i + 1}_task')),
                        ],
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.greenAccent,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Observation: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: t('s${_scenario}_step${i + 1}_out'),
                              ),
                            ],
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
    return list;
  }
}

// --- CUSTOM PAINTER ---
class FractionPainter extends CustomPainter {
  final SimState sim;
  final int scenario;
  final int step;
  final double panX;
  final double panY;
  final double zoom;
  final String? activeDragEntity;
  final double dragX;
  final double dragY;
  final Function(String) t;

  FractionPainter({
    required this.sim,
    required this.scenario,
    required this.step,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.activeDragEntity,
    required this.dragX,
    required this.dragY,
    required this.t,
  });

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

  @override
  bool shouldRepaint(covariant FractionPainter oldDelegate) => true;

  // --- DRAWING HELPERS ---
  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill, [
    Color? stroke,
    double lineW = 1,
  ]) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    final Paint fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, fillPaint);
    if (stroke != null) {
      final Paint strokePaint = Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineW;
      canvas.drawRRect(rect, strokePaint);
    }
  }

  void _drawTextOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawKid(Canvas canvas, double x, double y, Color color) {
    // Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 20), width: 32, height: 10),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Torso
    final Path torso = Path();
    torso.moveTo(x - 16, y + 25);
    torso.lineTo(x - 16, y + 5);
    torso.arcToPoint(Offset(x + 16, y + 5), radius: const Radius.circular(16));
    torso.lineTo(x + 16, y + 25);
    torso.close();

    final Paint torsoPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(x, y - 10), Offset(x, y + 20), [
        color,
        const Color(0xFF0F172A),
      ]);
    canvas.drawPath(torso, torsoPaint);

    // Head
    final Paint headPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x - 4, y - 22),
        12,
        [Colors.yellow.shade200, Colors.amber, Colors.brown.shade700],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(Offset(x, y - 18), 11, headPaint);
  }

  void _drawSurface(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color color,
  ) {
    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y + 5, w, h),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    final Paint paint = Paint()
      ..shader = ui.Gradient.linear(Offset(x, y), Offset(x, y + h), [
        color,
        const Color(0xFF1E293B),
      ]);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        x,
        y,
        x + w,
        y + h,
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawDropZone(Canvas canvas, double x, double y, double r) {
    final Paint paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final Path dashPath = Path();
    for (double i = 0; i < math.pi * 2; i += 0.4) {
      dashPath.addArc(Rect.fromCircle(center: Offset(x, y), radius: r), i, 0.2);
    }
    canvas.drawPath(dashPath, paint);
  }

  void _drawRoti(
    Canvas canvas,
    double x,
    double y,
    double radius,
    int pieces,
    bool isCut,
  ) {
    canvas.drawCircle(
      Offset(x, y + 4),
      radius,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    final Paint basePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x - radius * 0.2, y - radius * 0.2),
        radius,
        [
          Colors.yellow.shade200,
          Colors.yellow.shade600,
          Colors.yellow.shade800,
        ],
        [0.0, 0.8, 1.0],
      );
    canvas.drawCircle(Offset(x, y), radius, basePaint);
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = Colors.brown.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Texture
    final Paint texPaint = Paint()..color = Colors.brown.withOpacity(0.15);
    for (int i = 0; i < 8; i++) {
      double a = i * (math.pi * 2 / 8) + 0.5;
      double r = radius * 0.5 + (i % 2 == 0 ? 0 : radius * 0.2);
      canvas.drawCircle(
        Offset(x + r * math.cos(a), y + r * math.sin(a)),
        radius * 0.15,
        texPaint,
      );
    }

    if (isCut) {
      final Paint cutPaint = Paint()
        ..color = Colors.brown.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (int i = 0; i < pieces; i++) {
        double a = (math.pi * 2 / pieces) * i;
        canvas.drawLine(
          Offset(x, y),
          Offset(x + radius * math.cos(a), y + radius * math.sin(a)),
          cutPaint,
        );
      }
    }
  }

  void _drawRotiPiece(
    Canvas canvas,
    double x,
    double y,
    double radius,
    int pieceIndex,
    int totalPieces,
  ) {
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, y + 4), radius: radius),
      (math.pi * 2 / totalPieces) * pieceIndex,
      math.pi * 2 / totalPieces,
      true,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    double startAngle = (math.pi * 2 / totalPieces) * pieceIndex;
    double sweepAngle = math.pi * 2 / totalPieces;

    final Paint basePaint = Paint()
      ..shader = ui.Gradient.radial(Offset(x, y), radius, [
        Colors.yellow.shade200,
        Colors.yellow.shade800,
      ]);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, y), radius: radius),
      startAngle,
      sweepAngle,
      true,
      basePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, y), radius: radius),
      startAngle,
      sweepAngle,
      true,
      Paint()
        ..color = Colors.brown.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawScale(Canvas canvas, double x, double y, double tiltAngle) {
    const Color colDark = Color(0xFF0F172A);
    const Color colSilverLight = Color(0xFFCBD5E1);
    const Color colSilverDark = Color(0xFF475569);

    // Base
    _drawRoundedRect(
      canvas,
      x - 40,
      y + 100,
      80,
      20,
      5,
      colSilverDark,
      colDark,
      2,
    );
    // Pillar
    _drawRoundedRect(
      canvas,
      x - 10,
      y - 20,
      20,
      120,
      3,
      colSilverLight,
      colDark,
      2,
    );

    // Beam & Pans
    canvas.save();
    canvas.translate(x, y - 20);
    canvas.rotate(tiltAngle);

    // Beam
    _drawRoundedRect(canvas, -100, -5, 200, 10, 5, colSilverLight, colDark, 2);

    void drawPan(double px, double py, double rotFix) {
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rotFix);

      // Strings
      final Paint strPaint = Paint()
        ..color = colSilverLight
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset.zero, const Offset(-25, 60), strPaint);
      canvas.drawLine(Offset.zero, const Offset(25, 60), strPaint);

      // Pan Base
      final Rect panRect = Rect.fromCenter(
        center: const Offset(0, 60),
        width: 60,
        height: 20,
      );
      canvas.drawOval(
        panRect,
        Paint()
          ..color = Colors.black45
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawOval(
        panRect,
        Paint()
          ..shader = ui.Gradient.radial(const Offset(0, 60), 30, [
            const Color(0xFFF1F5F9),
            const Color(0xFF94A3B8),
          ]),
      );
      canvas.drawOval(
        panRect,
        Paint()
          ..color = colDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      canvas.restore();
    }

    drawPan(-90, 0, -tiltAngle);
    drawPan(90, 0, -tiltAngle);
    canvas.restore();

    // Pivot pin
    canvas.drawCircle(Offset(x, y - 20), 6, Paint()..color = Colors.red);
    canvas.drawCircle(
      Offset(x, y - 20),
      6,
      Paint()
        ..color = Colors.red.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawGlass(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double fillRatio,
    int markings,
    String label,
  ) {
    final strokePaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Back Rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x + w / 2, y), width: w, height: w * 0.3),
      Paint()..color = Colors.white10,
    );

    // Liquid
    if (fillRatio > 0) {
      double liqH = h * fillRatio;
      double liqY = y + h - liqH;

      final Path liqPath = Path();
      liqPath.moveTo(x + 2, liqY);
      liqPath.lineTo(x + 2, y + h - w * 0.15);
      liqPath.addArc(
        Rect.fromCenter(
          center: Offset(x + w / 2, y + h - w * 0.15),
          width: w - 4,
          height: w * 0.3,
        ),
        math.pi,
        math.pi,
      );
      liqPath.lineTo(x + w - 2, liqY);

      final Paint liqPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, 0),
          Offset(x + w, 0),
          [
            Colors.yellow.shade700,
            Colors.yellow.shade200,
            Colors.yellow.shade800,
          ],
          [0.0, 0.2, 1.0],
        );
      canvas.drawPath(liqPath, liqPaint);

      // Meniscus
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + w / 2, liqY),
          width: w - 4,
          height: w * 0.3,
        ),
        Paint()..color = Colors.yellow.shade400,
      );
    }

    // Glass Body
    final Path body = Path();
    body.moveTo(x, y);
    body.lineTo(x, y + h - w * 0.15);
    body.addArc(
      Rect.fromCenter(
        center: Offset(x + w / 2, y + h - w * 0.15),
        width: w,
        height: w * 0.3,
      ),
      math.pi,
      math.pi,
    );
    body.lineTo(x + w, y);

    final Paint glassPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(x, y),
        Offset(x + w, y),
        [Colors.white54, Colors.white10, Colors.white30],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(body, glassPaint);
    canvas.drawPath(body, strokePaint);

    // Front Rim
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x + w / 2, y), width: w, height: w * 0.3),
      0,
      math.pi,
      false,
      strokePaint,
    );

    if (markings > 0) {
      for (int i = 1; i < markings; i++) {
        double my = y + h - (h / markings) * i;
        canvas.drawLine(Offset(x + w - 10, my), Offset(x + w, my), strokePaint);
      }
    }

    if (label.isNotEmpty) {
      _drawTextOutline(
        canvas,
        label,
        x + w / 2,
        y + h + 25,
        16,
        Colors.white,
        bold: true,
      );
    }
  }

  void _drawPourer(Canvas canvas, double x, double y) {
    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 20, y - 25, 40, 60),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Handle
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x + 15, y - 5), width: 36, height: 36),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Spout
    final Path spout = Path();
    spout.moveTo(x - 15, y - 30);
    spout.lineTo(x - 30, y - 35);
    spout.lineTo(x - 15, y - 10);
    canvas.drawPath(spout, Paint()..color = Colors.white70);

    // Jug Body
    _drawRoundedRect(
      canvas,
      x - 15,
      y - 30,
      30,
      60,
      5,
      Colors.white.withOpacity(0.9),
      Colors.white,
      2,
    );

    // Liquid
    canvas.drawRect(
      Rect.fromLTWH(x - 12, y, 24, 28),
      Paint()..color = Colors.yellow.shade600,
    );
  }

  void _drawChikki(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    bool isCut,
    bool equalized,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2, y + 4, w, h),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final Paint basePaint = Paint()
      ..shader = ui.Gradient.linear(Offset(x, y), Offset(x + w, y + h), [
        Colors.amber.shade600,
        Colors.brown.shade600,
      ]);
    _drawRoundedRect(canvas, x, y, w, h, 4, Colors.transparent); // just bounds
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(4),
      ),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.brown.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Texture dots (simple representation)
    final Paint dotPaint = Paint()
      ..color = Colors.brown.shade900.withOpacity(0.4);
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(x + 5 + i * (w / 6), y + h / 2), 2, dotPaint);
    }

    final Paint cutPaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    if (isCut) {
      canvas.drawLine(Offset(x + w / 2, y), Offset(x + w / 2, y + h), cutPaint);
    }
    if (equalized) {
      cutPaint.strokeWidth = 2;
      double dashWidth = 4, dashSpace = 4;
      double sy = y;
      while (sy < y + h) {
        canvas.drawLine(
          Offset(x + w / 4, sy),
          Offset(x + w / 4, sy + dashWidth),
          cutPaint,
        );
        canvas.drawLine(
          Offset(x + 3 * w / 4, sy),
          Offset(x + 3 * w / 4, sy + dashWidth),
          cutPaint,
        );
        sy += dashWidth + dashSpace;
      }
      double sx = x;
      while (sx < x + w) {
        canvas.drawLine(
          Offset(sx, y + h / 2),
          Offset(sx + dashWidth, y + h / 2),
          cutPaint,
        );
        sx += dashWidth + dashSpace;
      }
    }
  }

  void _drawSugarBag(Canvas canvas, double x, double y) {
    canvas.drawRect(
      Rect.fromLTWH(x, y + 10, 60, 70),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    final Path bag = Path();
    bag.moveTo(x + 10, y);
    bag.lineTo(x + 50, y);
    bag.quadraticBezierTo(x + 60, y + 40, x + 60, y + 80);
    bag.lineTo(x, y + 80);
    bag.quadraticBezierTo(x, y + 40, x + 10, y);

    final Paint fill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(x, y),
        Offset(x + 60, y),
        [const Color(0xFFF1F5F9), Colors.white, const Color(0xFFCBD5E1)],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(bag, fill);
    canvas.drawPath(
      bag,
      Paint()
        ..color = Colors.blueGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawRoundedRect(canvas, x + 10, y + 30, 40, 20, 3, Colors.red);
    _drawTextOutline(
      canvas,
      "SUGAR",
      x + 30,
      y + 40,
      10,
      Colors.white,
      bold: true,
    );
  }

  void _drawMeasuringCup(
    Canvas canvas,
    double x,
    double y,
    double fillRatio,
    int markings,
    String label,
  ) {
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x - 5, y + 40), width: 40, height: 40),
      math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = Colors.blueGrey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    _drawRoundedRect(
      canvas,
      x,
      y,
      60,
      80,
      5,
      Colors.white30,
      const Color(0xFF0F172A),
      2,
    );

    if (fillRatio > 0) {
      double h = 80 * fillRatio;
      _drawRoundedRect(canvas, x + 2, y + 80 - h, 56, h - 2, 0, Colors.white);
    }

    if (markings > 0) {
      final Paint linePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 2;
      for (int i = 1; i < markings; i++) {
        double my = y + 80 - (80 / markings) * i;
        canvas.drawLine(Offset(x + 45, my), Offset(x + 60, my), linePaint);
      }
    }

    _drawTextOutline(
      canvas,
      label,
      x + 30,
      y + 105,
      16,
      Colors.white,
      bold: true,
    );
  }

  // --- SCENARIO RENDERS ---
  void _renderS1(Canvas canvas) {
    _drawSurface(canvas, -120, 160, 240, 80, const Color(0xFF94A3B8));
    if (!sim.s1RotiLPlaced) _drawRoti(canvas, -50, 190, 30, 1, false);
    if (!sim.s1RotiRPlaced) _drawRoti(canvas, 50, 190, 30, 1, false);

    double tY = -60;
    // Left Table
    _drawSurface(canvas, -400, tY, 180, 80, Colors.brown.shade700);
    _drawKid(canvas, -360, tY - 30, Colors.red);
    _drawKid(canvas, -260, tY - 30, Colors.blue);
    if (sim.s1RotiLPlaced) {
      if (!sim.s1PanLPlaced) {
        _drawRoti(canvas, -310, tY + 40, 35, 2, sim.s1CutL);
      } else {
        _drawRotiPiece(canvas, -310, tY + 40, 35, 1, 2);
      }
    } else {
      _drawDropZone(canvas, -310, tY + 40, 35);
    }
    if (sim.s1RotiLPlaced && !sim.s1CutL) {
      _drawRoundedRect(
        canvas,
        -370,
        tY - 90,
        120,
        35,
        8,
        Colors.green,
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_slicer'),
        -310,
        tY - 72,
        12,
        Colors.white,
        bold: true,
      );
    }

    // Right Table
    _drawSurface(canvas, 220, tY, 200, 80, Colors.brown.shade700);
    for (int i = 0; i < 4; i++) {
      _drawKid(
        canvas,
        250 + i * 40,
        tY - 30,
        [Colors.red, Colors.blue, Colors.green, Colors.yellow][i],
      );
    }
    if (sim.s1RotiRPlaced) {
      if (!sim.s1PanRPlaced) {
        _drawRoti(canvas, 320, tY + 40, 35, 4, sim.s1CutR);
      } else {
        _drawRotiPiece(canvas, 320, tY + 40, 35, 1, 4);
        _drawRotiPiece(canvas, 320, tY + 40, 35, 2, 4);
        _drawRotiPiece(canvas, 320, tY + 40, 35, 3, 4);
      }
    } else {
      _drawDropZone(canvas, 320, tY + 40, 35);
    }
    if (sim.s1RotiRPlaced && !sim.s1CutR) {
      _drawRoundedRect(
        canvas,
        260,
        tY - 90,
        120,
        35,
        8,
        Colors.green,
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_slicer'),
        320,
        tY - 72,
        12,
        Colors.white,
        bold: true,
      );
    }

    // Scale
    double tilt = (sim.s1PanLPlaced && sim.s1PanRPlaced) ? -0.2 : 0;
    _drawScale(canvas, 0, tY - 20, tilt);

    if (sim.s1PanLPlaced) {
      canvas.save();
      canvas.translate(0, tY - 40);
      canvas.rotate(tilt);
      _drawRotiPiece(canvas, -90, 50, 35, 0, 2);
      _drawTextOutline(canvas, '1/2', -90, -10, 18, Colors.white, bold: true);
      canvas.restore();
    }
    if (sim.s1PanRPlaced) {
      canvas.save();
      canvas.translate(0, tY - 40);
      canvas.rotate(tilt);
      _drawRotiPiece(canvas, 90, 50, 35, 0, 4);
      _drawTextOutline(canvas, '1/4', 90, -10, 18, Colors.white, bold: true);
      canvas.restore();
    }

    if (step >= 5) {
      _drawTextOutline(
        canvas,
        "1/2 > 1/4",
        0,
        -200,
        40,
        Colors.white,
        bold: true,
      );
    }

    // Drags
    if (activeDragEntity == 'r_full_L' || activeDragEntity == 'r_full_R') {
      _drawRoti(canvas, dragX, dragY, 35, 1, false);
    }
    if (activeDragEntity == 'r_half') {
      _drawRotiPiece(canvas, dragX, dragY, 35, 0, 2);
    }
    if (activeDragEntity == 'r_quat') {
      _drawRotiPiece(canvas, dragX, dragY, 35, 0, 4);
    }
  }

  void _renderS2(Canvas canvas) {
    _drawTextOutline(
      canvas,
      "Group 1 (3 Glasses)",
      -260,
      -170,
      20,
      Colors.white,
      bold: true,
    );
    _drawTextOutline(
      canvas,
      "Group 2 (4 Glasses)",
      260,
      -170,
      20,
      Colors.white,
      bold: true,
    );

    _drawSurface(canvas, -380, -60, 240, 60, Colors.blueGrey);
    for (int i = 0; i < 7; i++) {
      _drawKid(canvas, -350 + i * 35, -100, Colors.red);
      _drawGlass(
        canvas,
        -360 + i * 35,
        -75,
        25,
        40,
        sim.s2Poured1 ? 3 / 7 : 0,
        7,
        '',
      );
    }
    if (!sim.s2Poured1 && step == 0) {
      canvas.drawRect(
        Rect.fromLTWH(-380, -75, 240, 80),
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else if (!sim.s2Poured1 && step == 1) {
      _drawPourer(canvas, -260, 10);
      _drawRoundedRect(
        canvas,
        -310,
        60,
        100,
        35,
        8,
        Colors.green,
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_pour'),
        -260,
        77,
        14,
        Colors.white,
        bold: true,
      );
    }

    _drawSurface(canvas, 130, -60, 260, 60, Colors.blueGrey);
    for (int i = 0; i < 7; i++) {
      _drawKid(canvas, 150 + i * 35, -100, Colors.blue);
      _drawGlass(
        canvas,
        140 + i * 35,
        -75,
        25,
        40,
        sim.s2Poured2 ? 4 / 7 : 0,
        7,
        '',
      );
    }
    if (sim.s2Poured1 && !sim.s2Poured2 && step == 2) {
      canvas.drawRect(
        Rect.fromLTWH(130, -75, 260, 80),
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else if (sim.s2Poured1 && !sim.s2Poured2 && step == 3) {
      _drawPourer(canvas, 260, 10);
      _drawRoundedRect(
        canvas,
        210,
        60,
        100,
        35,
        8,
        Colors.green,
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_pour'),
        260,
        77,
        14,
        Colors.white,
        bold: true,
      );
    }

    _drawSurface(canvas, -30, 60, 60, 20, Colors.blueGrey.shade300);
    if (step == 0 || step == 2) _drawPourer(canvas, 0, 50);

    _drawSurface(canvas, -150, 150, 300, 20, Colors.blueGrey.shade400);
    if (sim.s2ShelfL) _drawGlass(canvas, -100, 30, 60, 120, 3 / 7, 7, '3/7');
    if (sim.s2ShelfR) _drawGlass(canvas, 40, 30, 60, 120, 4 / 7, 7, '4/7');

    if (step >= 5) {
      _drawTextOutline(
        canvas,
        "4/7 > 3/7",
        0,
        200,
        40,
        Colors.white,
        bold: true,
      );
    }

    if (activeDragEntity == 'pourer') _drawPourer(canvas, dragX, dragY);
    if (activeDragEntity == 'g3') {
      _drawGlass(canvas, dragX - 30, dragY - 60, 60, 120, 3 / 7, 7, '');
    }
    if (activeDragEntity == 'g4') {
      _drawGlass(canvas, dragX - 30, dragY - 60, 60, 120, 4 / 7, 7, '');
    }
  }

  void _renderS3(Canvas canvas) {
    _drawTextOutline(
      canvas,
      "Scenario A: 2 Kids",
      -250,
      -170,
      20,
      Colors.white,
      bold: true,
    );
    _drawTextOutline(
      canvas,
      "Scenario B: 8 Kids",
      250,
      -170,
      20,
      Colors.white,
      bold: true,
    );

    _drawKid(canvas, -280, -90, Colors.red);
    _drawKid(canvas, -220, -90, Colors.red);
    _drawSurface(canvas, -310, -50, 120, 50, Colors.blueGrey.shade100);
    if (sim.s3ChikkiAPlaced) {
      _drawChikki(canvas, -290, -45, 80, 40, true, false);
    } else {
      _drawRoundedRect(canvas, -290, -45, 80, 40, 5, Colors.black12);
    }

    for (int i = 0; i < 8; i++) {
      _drawKid(canvas, 150 + i * 25, -90, Colors.blue);
    }
    _drawSurface(canvas, 130, -50, 220, 50, Colors.blueGrey.shade100);
    if (sim.s3ChikkiBPlaced) {
      for (int i = 0; i < 5; i++) {
        _drawChikki(canvas, 140 + i * 10, -45 + i * 5, 60, 30, false, false);
      }
    } else {
      _drawRoundedRect(canvas, 140, -45, 200, 40, 5, Colors.black12);
    }

    if (step < 2) {
      _drawSurface(canvas, -40, -90, 80, 50, Colors.blueGrey.shade300);
      _drawChikki(canvas, -30, -100, 60, 30, false, false);
      _drawChikki(canvas, -30, -80, 60, 30, false, false);
    }

    // Comparison Mat
    _drawRoundedRect(
      canvas,
      -200,
      80,
      400,
      180,
      15,
      Colors.yellow.shade800,
      Colors.brown.shade800,
      4,
    );

    if (sim.s3MatL) {
      _drawChikki(canvas, -150, 120, 80, 80, false, sim.s3Equalized);
      _drawTextOutline(
        canvas,
        sim.s3Equalized ? '4/8' : '1/2',
        -110,
        230,
        20,
        Colors.white,
        bold: true,
      );
    }
    if (sim.s3MatR) {
      for (int i = 0; i < 5; i++) {
        _drawChikki(
          canvas,
          60 + (i % 2) * 45,
          120 + (i ~/ 2) * 35,
          40,
          30,
          false,
          false,
        );
      }
      _drawTextOutline(canvas, '5/8', 100, 230, 20, Colors.white, bold: true);
    }

    if (step == 4) {
      _drawRoundedRect(
        canvas,
        -80,
        280,
        160,
        45,
        22,
        Colors.green,
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_equalizer'),
        0,
        302,
        14,
        Colors.white,
        bold: true,
      );
      _drawTextOutline(canvas, "?", 0, 170, 40, Colors.white, bold: true);
    }
    if (step >= 5) {
      _drawTextOutline(canvas, ">", 0, 170, 50, Colors.white, bold: true);
      _drawTextOutline(
        canvas,
        "5/8 > 4/8",
        0,
        310,
        28,
        Colors.white,
        bold: true,
      );
    }

    if (activeDragEntity == 'chkA' || activeDragEntity == 'chkB') {
      _drawChikki(canvas, dragX, dragY, 60, 30, false, false);
    }
    if (activeDragEntity == 'p12') {
      _drawChikki(canvas, dragX - 40, dragY - 40, 80, 80, false, false);
    }
    if (activeDragEntity == 'p58') {
      for (int i = 0; i < 5; i++) {
        _drawChikki(
          canvas,
          dragX - 20 + (i % 2) * 20,
          dragY - 20 + (i ~/ 2) * 15,
          40,
          30,
          false,
          false,
        );
      }
    }
  }

  void _renderS4(Canvas canvas) {
    _drawTextOutline(
      canvas,
      "Group 1: 4 Kids",
      -250,
      -160,
      20,
      Colors.white,
      bold: true,
    );
    for (int i = 0; i < 4; i++) {
      _drawKid(
        canvas,
        -320 + i * 45,
        -110,
        [Colors.red, Colors.blue, Colors.green, Colors.yellow][i],
      );
    }
    _drawSurface(canvas, -360, -90, 220, 50, Colors.brown.shade700);
    if (!sim.s4Poured1) _drawDropZone(canvas, -250, -65, 20);
    if (!sim.s4ShelfL) {
      _drawGlass(
        canvas,
        -270,
        -140,
        40,
        80,
        sim.s4Poured1 ? 3 / 4 : 0,
        4,
        sim.s4Poured1 ? '3/4' : '',
      );
    }

    _drawTextOutline(
      canvas,
      "Group 2: 10 Kids",
      250,
      -160,
      20,
      Colors.white,
      bold: true,
    );
    for (int i = 0; i < 5; i++) {
      _drawKid(canvas, 170 + i * 40, -125, Colors.blueGrey);
    }
    for (int i = 0; i < 5; i++) {
      _drawKid(canvas, 170 + i * 40, -100, Colors.blue);
    }
    _drawSurface(canvas, 140, -90, 220, 50, Colors.brown.shade700);
    if (!sim.s4Poured2) _drawDropZone(canvas, 250, -65, 20);
    if (!sim.s4ShelfR) {
      _drawGlass(
        canvas,
        230,
        -140,
        40,
        80,
        sim.s4Poured2 ? 7 / 10 : 0,
        10,
        sim.s4Poured2 ? '7/10' : '',
      );
    }

    if (step == 0) {
      _drawSurface(canvas, -40, 80, 80, 20, Colors.blueGrey.shade300);
      _drawPourer(canvas, 0, 70);
    }

    _drawSurface(canvas, -240, 160, 480, 30, Colors.blueGrey.shade400);

    if (!sim.s4ShelfL && step >= 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-140, 40, 70, 120),
          const Radius.circular(5),
        ),
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (sim.s4ShelfL) {
      _drawGlass(
        canvas,
        -140,
        40,
        70,
        120,
        3 / 4,
        sim.s4Equalized ? 20 : 4,
        sim.s4Equalized ? '15/20' : '3/4',
      );
    }

    if (!sim.s4ShelfR && step >= 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(70, 40, 70, 120),
          const Radius.circular(5),
        ),
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (sim.s4ShelfR) {
      _drawGlass(
        canvas,
        70,
        40,
        70,
        120,
        7 / 10,
        sim.s4Equalized ? 20 : 10,
        sim.s4Equalized ? '14/20' : '7/10',
      );
    }

    if (step == 2) {
      _drawRoundedRect(
        canvas,
        220,
        100,
        140,
        45,
        10,
        Colors.amber.shade600,
        const Color(0xFF0F172A),
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_equalizer'),
        290,
        123,
        14,
        Colors.white,
        bold: true,
      );
    }

    if (step >= 3) {
      _drawRoundedRect(
        canvas,
        -35,
        70,
        70,
        70,
        8,
        Colors.blueGrey.shade700,
        Colors.white,
        2,
      );
      if (sim.s4Symbol != null) {
        _drawTextOutline(
          canvas,
          sim.s4Symbol!,
          0,
          105,
          44,
          Colors.white,
          bold: true,
        );
      }
    }

    if (step == 3 && activeDragEntity?.startsWith('sym_') != true) {
      ['<', '>', '='].asMap().forEach((i, s) {
        _drawRoundedRect(
          canvas,
          -100 + i * 70.0,
          220,
          60,
          60,
          10,
          Colors.white,
          const Color(0xFF0F172A),
          2,
        );
        _drawTextOutline(
          canvas,
          s,
          -70 + i * 70.0,
          250,
          32,
          const Color(0xFF0F172A),
          bold: true,
        );
      });
    }

    if (step >= 4) {
      _drawTextOutline(
        canvas,
        "3/4 > 7/10",
        0,
        260,
        44,
        Colors.white,
        bold: true,
      );
    }

    if (activeDragEntity == 'pourer_s4') _drawPourer(canvas, dragX, dragY);
    if (activeDragEntity == 'eq_s4') {
      _drawRoundedRect(
        canvas,
        dragX - 70,
        dragY - 22,
        140,
        45,
        10,
        Colors.amber.shade600,
        const Color(0xFF0F172A),
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_equalizer'),
        dragX,
        dragY,
        14,
        Colors.white,
        bold: true,
      );
    }
    if (activeDragEntity == 'g3_s4') {
      _drawGlass(canvas, dragX - 35, dragY - 60, 70, 120, 3 / 4, 4, '');
    }
    if (activeDragEntity == 'g4_s4') {
      _drawGlass(canvas, dragX - 35, dragY - 60, 70, 120, 7 / 10, 10, '');
    }
    if (activeDragEntity != null && activeDragEntity!.startsWith('sym_')) {
      String s = activeDragEntity!.split('_')[1];
      _drawRoundedRect(
        canvas,
        dragX - 30,
        dragY - 30,
        60,
        60,
        10,
        Colors.white,
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        s,
        dragX,
        dragY,
        32,
        const Color(0xFF0F172A),
        bold: true,
      );
    }
  }

  void _renderS5(Canvas canvas) {
    double rW = 160, rH = 200;

    _drawRoundedRect(
      canvas,
      -220,
      -180,
      rW,
      rH,
      12,
      Colors.yellow.shade200,
      const Color(0xFF0F172A),
      3,
    );
    _drawTextOutline(
      canvas,
      t('lbl_recipeA'),
      -140,
      -140,
      20,
      const Color(0xFF0F172A),
      bold: true,
    );
    _drawTextOutline(
      canvas,
      "Sugar: 2/3 c",
      -140,
      -100,
      16,
      const Color(0xFF0F172A),
      bold: true,
    );
    _drawMeasuringCup(
      canvas,
      -170,
      -50,
      sim.s5SugarA ? 2 / 3 : 0,
      sim.s5Equalized ? 6 : 3,
      sim.s5Equalized ? '4/6' : '2/3',
    );

    _drawRoundedRect(
      canvas,
      60,
      -180,
      rW,
      rH,
      12,
      Colors.yellow.shade200,
      const Color(0xFF0F172A),
      3,
    );
    _drawTextOutline(
      canvas,
      t('lbl_recipeB'),
      140,
      -140,
      20,
      const Color(0xFF0F172A),
      bold: true,
    );
    _drawTextOutline(
      canvas,
      "Sugar: 5/6 c",
      140,
      -100,
      16,
      const Color(0xFF0F172A),
      bold: true,
    );
    _drawMeasuringCup(canvas, 110, -50, sim.s5SugarB ? 5 / 6 : 0, 6, '5/6');

    if (step < 2) {
      _drawSurface(canvas, -50, 160, 100, 30, Colors.blueGrey.shade400);
      _drawSugarBag(canvas, -30, 100);
    }

    if (step == 2) {
      _drawRoundedRect(
        canvas,
        -70,
        120,
        140,
        45,
        10,
        Colors.amber.shade600,
        const Color(0xFF0F172A),
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_equalizer'),
        0,
        142,
        14,
        Colors.white,
        bold: true,
      );
    }

    if (sim.s5WinnerClicked) {
      _drawTextOutline(
        canvas,
        t('lbl_winner'),
        140,
        -210,
        32,
        Colors.green,
        bold: true,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(55, -185, rW + 10, rH + 10),
          const Radius.circular(12),
        ),
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }

    if (activeDragEntity == 'sugar') {
      _drawSugarBag(canvas, dragX - 30, dragY - 40);
    }
    if (activeDragEntity == 'eq') {
      _drawRoundedRect(
        canvas,
        dragX - 70,
        dragY - 22,
        140,
        45,
        10,
        Colors.amber.shade600,
        const Color(0xFF0F172A),
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_equalizer'),
        dragX,
        dragY,
        14,
        Colors.white,
        bold: true,
      );
    }
  }
}
