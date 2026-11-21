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
    const MaterialApp(
      home: Cl6M_Ch7_A4_EquivalentFractionsSimplestForm(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Localization Dictionary
const Map<String, Map<String, String>> tMap = {
  'en': {
    'shutterTitle': 'The Magic Fraction Factory: Equivalent Fractions',
    'appTitle': 'Equivalent Fractions & Simplest Form',
    'appSubtitle': 'Class 6 • THE MAGIC FRACTION FACTORY',
    'enterLab': 'Enter Factory',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'learnLbl': 'Objective:',
    'summaryTitle': 'Goal Reached!',
    'finalDesc':
        'You have successfully explored Equivalent Fractions and Simplest Form!',
    'nextScenario': 'Next Scenario',
    'finishLab': 'Finish Lab',
    'lbl_drag': 'DRAG',
    'lbl_success': 'SUCCESS!',
    'lbl_failure': 'FAILURE',
    'lbl_equal': 'EQUIVALENT!',
    'lbl_fuse': 'FUSE',
    'lbl_slice': 'SLICE & SERVE',
    's1_title': '1. The Equal-Share Calibrator',
    's1_obj':
        'Visually prove that the share 1/2 is exactly the same amount as the share 2/4 using the Balance Scale.',
    's2_title': '2. The Fraction Wall Builder',
    's2_obj':
        'Find combinations of identical smaller fraction pieces that perfectly match the length of a 2/3 bar.',
    's3_title': '3. The Simplifier Ray',
    's3_obj':
        "Understand 'simplest form' by visually grouping the pieces of a 4/8 chocolate bar into the largest possible equal parts.",
    's4_title': '4. The Pizza Party Problem',
    's4_obj':
        'Provide an equivalent share to 8 hungry bots using new, uncut pizzas.',
    's5_title': '5. The Chocolate Packaging Line',
    's5_obj':
        'Simplify a 6/9 fraction to its lowest terms and place it in the correctly labeled packaging box.',
    's1_hud1': 'Drag the 1/2 machine lever down.',
    's1_step1_task':
        "On the left, DRAG the 'Distribute' lever down to give 1 bar to 2 bots.",
    's1_step1_out': 'The machine gives 1/2 to each Bot.',
    's1_hud2': 'Drag the 2/4 machine lever down.',
    's1_step2_task':
        "On the right, DRAG the 'Distribute' lever down to give 2 bars to 4 bots.",
    's1_step2_out': 'The machine gives 2/4 to each Bot.',
    's1_hud3': 'Drag the 1/2 piece to the left scale pan.',
    's1_step3_task':
        'DRAG the 1/2 chocolate piece from the left Bot onto the left pan of the scale.',
    's1_step3_out': 'The left pan tips down.',
    's1_hud4': 'Drag the 2/4 piece to the right scale pan.',
    's1_step4_task':
        'DRAG the 2/4 chocolate piece from the right Bot onto the right pan.',
    's1_step4_out': 'The scale perfectly balances! 1/2 is equivalent to 2/4.',
    's2_hud1': 'Drag 1/6 pieces to match the 2/3 bar length.',
    's2_step1_task':
        'DRAG 1/6 pieces one by one and place them to perfectly match the 2/3 bar.',
    's2_step1_out': 'Four 1/6 pieces (4/6) perfectly equal 2/3.',
    's2_hud2': "Click 'Reset Row' button.",
    's2_step2_task': "CLICK the 'Reset Row' button.",
    's2_step2_out': 'Row cleared.',
    's2_hud3': 'Drag 1/9 pieces to match the 2/3 bar length.',
    's2_step3_task':
        'Find another set. DRAG 1/9 pieces to perfectly match the 2/3 bar.',
    's2_step3_out':
        'Six 1/9 pieces (6/9) perfectly equal 2/3. Fractions with the same length are equivalent!',
    's3_hud1': 'Drag the Simplifier Ray over the chocolate bar.',
    's3_step1_task':
        "DRAG the 'Simplifier Ray' and hover it over the 4/8 chocolate bar.",
    's3_step1_out': 'The ray is aimed at the 4/8 bar.',
    's3_hud2': 'Click the FUSE button.',
    's3_step2_task':
        "CLICK the 'FUSE' button to fuse the pieces into their simplest form.",
    's3_step2_out':
        'The 4/8 pieces fused into 1/2. Simplifying makes the same amount with the fewest pieces.',
    's4_hud1': 'Drag 2 whole pizzas to Table B.',
    's4_step1_task':
        'You have a 1/4 share. Give 8 bots an equivalent share. DRAG 2 uncut pizzas to Table B.',
    's4_step1_out': '2 pizzas placed. 8 * (1/4) = 2 whole pizzas.',
    's4_hud2': 'Drag the Slicer tool to the pizzas.',
    's4_step2_task': "DRAG the 'Pizza Slicer' tool onto the pizzas at Table B.",
    's4_step2_out': 'Slicer ready.',
    's4_hud3': 'Click SLICE & SERVE button.',
    's4_step3_task': "CLICK the 'SLICE & SERVE' button to divide them.",
    's4_step3_out':
        'Each bot gets 2/8. A 2/8 slice is equal to your 1/4 slice!',
    's5_hud1': 'Drag Simplifier Ray over 6/9 bar and FUSE.',
    's5_step1_task':
        "DRAG the 'Simplifier Ray' over the 6/9 bar and CLICK 'FUSE'.",
    's5_step1_out': '6/9 is simplified to 2/3.',
    's5_hud2': 'Drag the 2/3 bar to the correct box.',
    's5_step2_task':
        'DRAG the simplified 2/3 chocolate bar and DROP it into the correct box.',
    's5_step2_out': 'Packaged correctly! 6/9 in its simplest form is 2/3.',
  },
  'hi': {
    'shutterTitle': 'जादुई भिन्न फैक्टरी: समतुल्य भिन्न',
    'appTitle': 'समतुल्य भिन्न और सरलतम रूप',
    'appSubtitle': 'कक्षा 6 • जादुई भिन्न फैक्टरी',
    'enterLab': 'फैक्टरी में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'learnLbl': 'उद्देश्य:',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'finalDesc': 'आपने समतुल्य भिन्न और सरलतम रूप का सफलतापूर्वक पता लगाया है!',
    'nextScenario': 'अगला परिदृश्य',
    'finishLab': 'समाप्त करें',
    'lbl_drag': 'खींचें',
    'lbl_success': 'सफलता!',
    'lbl_failure': 'विफलता',
    'lbl_equal': 'समान!',
    'lbl_fuse': 'जोड़ें',
    'lbl_slice': 'काटें और परोसें',
    's1_title': '1. समान-भाग कैलिब्रेटर',
    's1_obj': 'दृष्टिगत रूप से साबित करें कि 1/2 और 2/4 समान मात्राएँ हैं।',
    's2_title': '2. भिन्न दीवार निर्माता',
    's2_obj':
        '2/3 बार की लंबाई से पूरी तरह मेल खाने वाले छोटे टुकड़ों के संयोजन खोजें।',
    's3_title': '3. सरलीकृत किरण',
    's3_obj':
        "4/8 चॉकलेट बार के टुकड़ों को सबसे बड़े संभव समान भागों में समूहित करके 'सरलतम रूप' को समझें।",
    's4_title': '4. पिज्जा पार्टी की समस्या',
    's4_obj':
        '8 भूखे बॉट्स को पूरे पिज्जा का उपयोग करके एक समान हिस्सा प्रदान करें।',
    's5_title': '5. चॉकलेट पैकेजिंग लाइन',
    's5_obj':
        '6/9 भिन्न को उसके निम्नतम पदों तक सरल करें और इसे सही बॉक्स में रखें।',
    's1_hud1': '1/2 मशीन लीवर को नीचे खींचें।',
    's1_step1_task':
        "बाईं ओर, 2 बॉट्स को 1 बार देने के लिए 'वितरित करें' लीवर को नीचे खींचें।",
    's1_step1_out': 'मशीन प्रत्येक बॉट को 1/2 देती है।',
    's1_hud2': '2/4 मशीन लीवर को नीचे खींचें।',
    's1_step2_task':
        "दाईं ओर, 4 बॉट्स को 2 बार देने के लिए लीवर को नीचे खींचें।",
    's1_step2_out': 'मशीन प्रत्येक बॉट को 2/4 देती है।',
    's1_hud3': '1/2 टुकड़े को बाएं तराजू पर खींचें।',
    's1_step3_task':
        'बाएं बॉट से 1/2 चॉकलेट के टुकड़े को तराजू के बाएं पलड़े पर खींचें।',
    's1_step3_out': 'बायां पलड़ा नीचे झुकता है।',
    's1_hud4': '2/4 टुकड़े को दाएं तराजू पर खींचें।',
    's1_step4_task':
        'दाएं बॉट से 2/4 चॉकलेट के टुकड़े को दाएं पलड़े पर खींचें।',
    's1_step4_out': 'तराजू पूरी तरह से संतुलित है! 1/2, 2/4 के समतुल्य है।',
    's2_hud1': '2/3 लंबाई से मेल खाने के लिए 1/6 टुकड़े खींचें।',
    's2_step1_task':
        '2/3 बार से पूरी तरह मेल खाने के लिए 1/6 टुकड़ों को एक-एक करके खींचें और रखें।',
    's2_step1_out': 'चार 1/6 टुकड़े (4/6) 2/3 के बराबर हैं।',
    's2_hud2': "'रीसेट पंक्ति' बटन पर क्लिक करें।",
    's2_step2_task': "'रीसेट पंक्ति' बटन पर क्लिक करें।",
    's2_step2_out': 'पंक्ति साफ़ हो गई।',
    's2_hud3': '2/3 लंबाई से मेल खाने के लिए 1/9 टुकड़े खींचें।',
    's2_step3_task':
        'एक और सेट खोजें। 2/3 बार से मेल खाने के लिए 1/9 टुकड़ों को खींचें।',
    's2_step3_out':
        'छह 1/9 टुकड़े (6/9) 2/3 के बराबर हैं। समान लंबाई वाले भिन्न समतुल्य होते हैं!',
    's3_hud1': 'चॉकलेट बार पर सरलीकृत किरण खींचें।',
    's3_step1_task':
        "'सरलीकृत किरण' को खींचें और इसे 4/8 चॉकलेट बार के ऊपर घुमाएं।",
    's3_step1_out': 'किरण का लक्ष्य 4/8 बार है।',
    's3_hud2': 'FUSE बटन पर क्लिक करें।',
    's3_step2_task':
        "टुकड़ों को उनके सरलतम रूप में जोड़ने के लिए 'FUSE' बटन पर क्लिक करें।",
    's3_step2_out':
        '4/8 टुकड़े 1/2 में जुड़ गए। सरल करने से सबसे कम टुकड़ों के साथ समान मात्रा बनती है।',
    's4_hud1': 'टेबल B पर 2 पूरे पिज्जा खींचें।',
    's4_step1_task':
        'आपके पास 1/4 हिस्सा है। 8 बॉट्स को एक समान हिस्सा दें। टेबल B पर 2 बिना कटे पिज्जा खींचें।',
    's4_step1_out': '2 पिज्जा रखे गए। 8 * (1/4) = 2 पूरे पिज्जा।',
    's4_hud2': 'स्लाइसर टूल को पिज्जा पर खींचें।',
    's4_step2_task': "टेबल B पर पिज्जा पर 'पिज्जा स्लाइसर' टूल खींचें।",
    's4_step2_out': 'स्लाइसर तैयार है।',
    's4_hud3': 'SLICE & SERVE बटन पर क्लिक करें।',
    's4_step3_task':
        "उन्हें विभाजित करने के लिए 'SLICE & SERVE' बटन पर क्लिक करें।",
    's4_step3_out':
        'प्रत्येक बॉट को 2/8 मिलता है। एक 2/8 स्लाइस आपके 1/4 स्लाइस के बराबर है!',
    's5_hud1': '6/9 बार पर सरलीकृत किरण खींचें और FUSE करें।',
    's5_step1_task':
        "6/9 बार पर 'सरलीकृत किरण' खींचें और 'FUSE' पर क्लिक करें।",
    's5_step1_out': '6/9 को 2/3 में सरल किया गया है।',
    's5_hud2': '2/3 बार को सही बॉक्स में खींचें।',
    's5_step2_task':
        'सरलीकृत 2/3 चॉकलेट बार को खींचें और इसे सही बॉक्स में छोड़ें।',
    's5_step2_out': 'सही ढंग से पैक किया गया! अपने सरलतम रूप में 6/9, 2/3 है।',
  },
};

/// Audio Engine
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  // 1. Play a click sound
  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // 2. Play a sound when a new page/scenario opens (Swoosh/Chime)
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

  // 5. Play curtain opening sound
  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

/// Simulation State Data
class SimState {
  bool s1Lever1 = false, s1Lever2 = false, s1BotsL = false, s1BotsR = false;
  bool s1ScaleL = false, s1ScaleR = false;
  int s1ScaleBalance = 0;

  List<Map<String, dynamic>> s2RowPieces = [];

  bool s3RayHover = false, s3Fused = false;
  double s3RayX = 0, s3RayY = 0;

  int s4PizzasB = 0;
  bool s4SlicerReady = false, s4Sliced = false, s4Served = false;

  List<int> s5BarState = [6, 9];
  bool s5RayHover = false, s5Boxed = false;
  double s5RayX = 0, s5RayY = 0, s5BoxAnim = 0;

  String? activeDragEntity;
  double dragX = 0, dragY = 0;
  bool animating = false;
  double animProgress = 0;
}

/// Main Application Widget
class Cl6M_Ch7_A4_EquivalentFractionsSimplestForm extends StatefulWidget {
  const Cl6M_Ch7_A4_EquivalentFractionsSimplestForm({Key? key})
    : super(key: key);

  @override
  _Cl6M_Ch7_A4_EquivalentFractionsSimplestFormState createState() =>
      _Cl6M_Ch7_A4_EquivalentFractionsSimplestFormState();
}

class _Cl6M_Ch7_A4_EquivalentFractionsSimplestFormState
    extends State<Cl6M_Ch7_A4_EquivalentFractionsSimplestForm>
    with TickerProviderStateMixin {
  String lang = 'en';
  bool isCurtainOpen = false;
  bool sidebarOpen = true;
  double sidebarWidth = 350;

  double zoom = 1.0;
  double _baseZoom = 1.0;
  double panX = 0, panY = 0;
  bool _isInteracting = false;

  int scenario = 1;
  int step = 0;

  SimState sim = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  late AnimationController _gameLoopController;
  late AnimationController _actionController;

  String t(String key) => tMap[lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _actionController.addListener(() {
      setState(() {
        sim.animProgress = _actionController.value;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sidebarWidth = max(300, MediaQuery.of(context).size.width * 0.3);
      _fitScreen();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoopController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _fitScreen() {
    if (_canvasKey.currentContext == null) return;
    final RenderBox rb =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = rb.size;
    zoom = max(0.6, min(3.0, min(size.width / 1000, size.height / 800)));
    panX = 0;
    panY = 0;
  }

  Offset _getCanvasPoint(Offset localPosition) {
    if (_canvasKey.currentContext == null) return const Offset(0, 0);
    final RenderBox rb =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    double worldX = (localPosition.dx - rb.size.width / 2 - panX) / zoom;
    double worldY = (localPosition.dy - rb.size.height / 2 - panY) / zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _triggerAction(String actionType) async {
    if (actionType == 's2_resetRow') {
      AudioEngine.playClick();
      sim.s2RowPieces.clear();
      if (scenario == 2 && step == 1) _advanceStep();
    } else if (actionType == 's3_fuse') {
      AudioEngine.playClick();
      sim.animating = true;
      _actionController.forward(from: 0.0).then((_) {
        AudioEngine.playPageOpen();
        setState(() {
          sim.animating = false;
          sim.s3Fused = true;
          sim.s3RayHover = false;
        });
        _advanceStep();
        _checkScenarioSuccess();
      });
    } else if (actionType == 's4_slice') {
      AudioEngine.playClick();
      setState(() {
        sim.s4Sliced = true;
        sim.s4SlicerReady = false;
      });
      if (step == 1) _advanceStep();
    } else if (actionType == 's4_serve') {
      AudioEngine.playClick();
      sim.animating = true;
      _actionController.forward(from: 0.0).then((_) {
        AudioEngine.playPageOpen();
        setState(() {
          sim.animating = false;
          sim.s4Served = true;
        });
        _advanceStep();
        _checkScenarioSuccess();
      });
    } else if (actionType == 's5_fuse') {
      AudioEngine.playClick();
      sim.animating = true;
      _actionController.forward(from: 0.0).then((_) {
        AudioEngine.playPageOpen();
        setState(() {
          sim.animating = false;
          sim.s5BarState = [2, 3];
          sim.s5RayHover = false;
        });
        _advanceStep();
      });
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (sim.animating) return;

    _baseZoom = zoom;
    _isInteracting = false;
    final pt = _getCanvasPoint(details.localFocalPoint);

    setState(() {
      if (scenario == 1) {
        if (_hitTestBox(-210, -130, 20, 60, pt) && !sim.s1Lever1) {
          sim.s1Lever1 = true;
          _isInteracting = true;
          AudioEngine.playClick();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() => sim.s1BotsL = true);
            if (step == 0) _advanceStep();
          });
        } else if (_hitTestBox(390, -130, 20, 60, pt) && !sim.s1Lever2) {
          sim.s1Lever2 = true;
          _isInteracting = true;
          AudioEngine.playClick();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() => sim.s1BotsR = true);
            if (step == 1) _advanceStep();
          });
        } else if (sim.s1BotsL &&
            _hitTestBox(-395, 140, 50, 30, pt) &&
            !sim.s1ScaleL) {
          sim.activeDragEntity = 's1_p1';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        } else if (sim.s1BotsR &&
            _hitTestBox(175, 140, 30, 30, pt) &&
            !sim.s1ScaleR) {
          sim.activeDragEntity = 's1_p2';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        }
      } else if (scenario == 2) {
        if (_hitTestBox(-350, 20, 120, 40, pt)) {
          _triggerAction('s2_resetRow');
          _isInteracting = true;
          return;
        }
        List<Map<String, dynamic>> tray = [
          {
            'val': 1 / 4,
            'label': '1/4',
            'color': const Color(0xfffca5a5),
            'y': -110.0,
          },
          {
            'val': 1 / 5,
            'label': '1/5',
            'color': const Color(0xfffde047),
            'y': -60.0,
          },
          {
            'val': 1 / 6,
            'label': '1/6',
            'color': const Color(0xff86efac),
            'y': -10.0,
          },
          {
            'val': 1 / 9,
            'label': '1/9',
            'color': const Color(0xffd8b4fe),
            'y': 40.0,
          },
        ];
        for (var tp in tray) {
          double pw = (tp['val'] as double) * 420;
          if (_hitTestBox(170, tp['y'] as double, pw, 40, pt)) {
            sim.activeDragEntity =
                "s2p_${tp['label']}_${tp['val']}_${tp['color'].value}";
            sim.dragX = pt.dx;
            sim.dragY = pt.dy;
            _isInteracting = true;
            AudioEngine.playClick();
          }
        }
      } else if (scenario == 3) {
        if (_hitTestBox(350, -50, 140, 140, pt) && !sim.s3Fused) {
          sim.activeDragEntity = 's3_ray';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        }
        if (sim.s3RayHover &&
            _hitTestBox(sim.s3RayX + 40, sim.s3RayY - 30, 80, 40, pt)) {
          _triggerAction('s3_fuse');
          _isInteracting = true;
          return;
        }
      } else if (scenario == 4) {
        if (_hitTestBox(-100, -200, 200, 250, pt) && sim.s4PizzasB < 2) {
          sim.activeDragEntity = 's4_pizza';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        } else if (_hitTestBox(120, 80, 80, 80, pt) &&
            sim.s4PizzasB == 2 &&
            !sim.s4Sliced) {
          sim.activeDragEntity = 's4_slicer';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        } else if (sim.s4Sliced &&
            !sim.s4Served &&
            _hitTestBox(250, 60, 200, 50, pt)) {
          _triggerAction('s4_serve');
          _isInteracting = true;
          return;
        }
      } else if (scenario == 5) {
        if (_hitTestBox(350, -150, 120, 120, pt) && sim.s5BarState[0] == 6) {
          sim.activeDragEntity = 's5_ray';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        } else if (sim.s5RayHover &&
            _hitTestBox(sim.s5RayX + 40, sim.s5RayY - 30, 80, 40, pt)) {
          _triggerAction('s5_fuse');
          _isInteracting = true;
          return;
        } else if (sim.s5BarState[0] == 2 &&
            _hitTestBox(-135, -150, 270, 90, pt) &&
            !sim.s5Boxed) {
          sim.activeDragEntity = 's5_bar';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          _isInteracting = true;
          AudioEngine.playClick();
        }
      }
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_isInteracting) {
      if (sim.activeDragEntity != null) {
        final pt = _getCanvasPoint(details.localFocalPoint);
        setState(() {
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
        });
      }
    } else {
      // Pan and smooth Zoom
      setState(() {
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
        zoom = max(0.4, min(3.0, _baseZoom * details.scale));
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (sim.activeDragEntity == null) return;

    final pt = Offset(sim.dragX, sim.dragY);
    setState(() {
      if (sim.activeDragEntity == 's1_p1') {
        if (_hitTestBox(-150, 50, 80, 80, pt)) {
          sim.s1ScaleL = true;
          sim.s1ScaleBalance = -1;
          AudioEngine.playClick();
          if (step == 2) _advanceStep();
        } else {
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity == 's1_p2') {
        if (_hitTestBox(70, 50, 80, 80, pt)) {
          sim.s1ScaleR = true;
          sim.s1ScaleBalance = 0;
          AudioEngine.playPageOpen();
          if (step == 3) {
            _advanceStep();
            _checkScenarioSuccess();
          }
        } else {
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity!.startsWith('s2p_')) {
        if (_hitTestBox(-350, -70, 420, 80, pt)) {
          List<String> parts = sim.activeDragEntity!.split('_');
          double val = double.parse(parts[2]);
          Color color = Color(int.parse(parts[3]));
          String label = parts[1];
          double currentLen = sim.s2RowPieces.fold(
            0.0,
            (sum, p) => sum + p['val'],
          );

          if (currentLen + val <= 2 / 3 + 0.01) {
            sim.s2RowPieces.add({
              'type': label,
              'val': val,
              'color': color,
              'x': currentLen * 420,
              'label': label,
            });
            double newLen = sim.s2RowPieces.fold(
              0.0,
              (sum, p) => sum + p['val'],
            );
            if ((newLen - 2 / 3).abs() < 0.01) {
              AudioEngine.playPageOpen();
              if (label == '1/6' && step == 0) _advanceStep();
              if (label == '1/9' && step == 2) {
                _advanceStep();
                _checkScenarioSuccess();
              }
            } else {
              AudioEngine.playClick();
            }
          } else {
            AudioEngine.playError();
          }
        } else {
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity == 's3_ray') {
        if (_hitTestBox(-140, -80, 320, 120, pt)) {
          sim.s3RayHover = true;
          sim.s3RayX = -50;
          sim.s3RayY = -120;
          AudioEngine.playClick();
          if (step == 0) _advanceStep();
        } else {
          sim.s3RayHover = false;
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity == 's4_pizza') {
        if (_hitTestBox(200, -150, 300, 200, pt)) {
          sim.s4PizzasB++;
          AudioEngine.playClick();
          if (sim.s4PizzasB == 2 && step == 0) _advanceStep();
        } else {
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity == 's4_slicer') {
        if (_hitTestBox(200, -150, 300, 200, pt) && sim.s4PizzasB == 2) {
          _triggerAction('s4_slice');
        } else {
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity == 's5_ray') {
        if (_hitTestBox(-135, -150, 270, 90, pt)) {
          sim.s5RayHover = true;
          sim.s5RayX = 50;
          sim.s5RayY = -150;
          AudioEngine.playClick();
        } else {
          sim.s5RayHover = false;
          AudioEngine.playError();
        }
      } else if (sim.activeDragEntity == 's5_bar') {
        if (_hitTestBox(140, 100, 120, 80, pt)) {
          sim.s5Boxed = true;
          sim.s5BoxAnim = 1;
          AudioEngine.playPageOpen();
          _triggerAction('s5_box_anim');
          if (step == 1) {
            _advanceStep();
            _checkScenarioSuccess();
          }
        } else {
          AudioEngine.playError();
        }
      }
      sim.activeDragEntity = null;
    });
  }

  int _getStepsForScenario(int s) {
    if (s == 1) return 4;
    if (s == 2) return 3;
    if (s == 3) return 2;
    if (s == 4) return 3;
    if (s == 5) return 2;
    return 0;
  }

  void _advanceStep() => setState(() => step++);

  void _checkScenarioSuccess() {
    if (step >= _getStepsForScenario(scenario)) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {}); // refresh to show popup
      });
    }
  }

  void _loadScenario(int s) {
    AudioEngine.playPageOpen();
    setState(() {
      scenario = s;
      step = 0;
      sim = SimState();
      _fitScreen();
    });
  }

  void _resetLab() {
    AudioEngine.playClick();
    setState(() {
      isCurtainOpen = false;
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          isCurtainOpen = true;
        });
        _loadScenario(1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final int totalSteps = _getStepsForScenario(scenario);
    final bool isCompleted = step >= totalSteps;
    final String hudText = (step < totalSteps)
        ? t('s${scenario}_hud${step + 1}')
        : "";

    // The key architectural change to remove the Gesture Arena delay is using a Listener
    // at the root instead of a GestureDetector for the immersive mode reset.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) =>
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xff0f172a),
        body: Stack(
          children: [
            // Canvas Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _gameLoopController,
                    builder: (context, _) {
                      return CustomPaint(
                        key: _canvasKey,
                        painter: FractionPainter(
                          sim,
                          scenario,
                          zoom,
                          panX,
                          panY,
                          t,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Fully Scrollable Sidebar Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Detailed Header Area
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 66,
                                  bottom: 16,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Icon(
                                        Icons.auto_fix_high,
                                        color: Color(0xFF6366f1),
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            t('appSubtitle'),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              // Language Toggle Button
                                              InkWell(
                                                onTap: () {
                                                  AudioEngine.playClick();
                                                  setState(() {
                                                    lang = lang == 'en'
                                                        ? 'hi'
                                                        : 'en';
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF334155,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white24,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.language,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        lang.toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Reset Lab Button
                                              InkWell(
                                                onTap: _resetLab,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.redAccent
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.refresh,
                                                        color: Colors.redAccent,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'RESET',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.redAccent,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
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
                              ),

                              // Main Sidebar Content Area (Expanded to fill remaining space)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t('selectScenario').toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white54,
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
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            dropdownColor: const Color(
                                              0xFF0F172A,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            value: scenario,
                                            items: [1, 2, 3, 4, 5]
                                                .map(
                                                  (s) => DropdownMenuItem(
                                                    value: s,
                                                    child: Text(
                                                      t('s${s}_title'),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                AudioEngine.playDropdown();
                                                _loadScenario(val);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                                  Icons.track_changes,
                                                  color: Colors.redAccent,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  t('learnLbl'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              t('s${scenario}_obj'),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ...List.generate(totalSteps, (i) {
                                        bool past = i < step;
                                        bool active = i == step;
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: active
                                                ? const Color(
                                                    0xFF6366f1,
                                                  ).withOpacity(0.15)
                                                : (past
                                                      ? const Color(
                                                          0xFF10b981,
                                                        ).withOpacity(0.1)
                                                      : Colors.white10),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: active
                                                  ? const Color(0xFF6366f1)
                                                  : (past
                                                        ? const Color(
                                                            0xFF10b981,
                                                          ).withOpacity(0.5)
                                                        : Colors.white12),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              past
                                                  ? const Icon(
                                                      Icons.check_circle,
                                                      color: Color(0xFF10b981),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 12,
                                                      backgroundColor: active
                                                          ? const Color(
                                                              0xFF6366f1,
                                                            )
                                                          : Colors.white24,
                                                      child: Text(
                                                        '${i + 1}',
                                                        style: TextStyle(
                                                          color: active
                                                              ? Colors.white
                                                              : Colors.white54,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      '${t('stepLabel')} ${i + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      t(
                                                        's${scenario}_step${i + 1}_task',
                                                      ),
                                                      style: TextStyle(
                                                        color: active
                                                            ? Colors.white
                                                            : Colors.white70,
                                                        fontSize: 13,
                                                        fontWeight: active
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    if (past) ...[
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF10b981,
                                                          ).withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF10b981,
                                                            ).withOpacity(0.3),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          t(
                                                            's${scenario}_step${i + 1}_out',
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF10b981,
                                                                ),
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
                                      }),
                                    ],
                                  ),
                                ),
                              ),

                              // Footer Fixed visually at the bottom
                              Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  border: Border(
                                    top: BorderSide(color: Colors.white12),
                                  ),
                                ),
                                child: const Text(
                                  '© ZeroScienceLab | Fall in Love with Math and Science',
                                  style: TextStyle(
                                    color: Colors.white54,
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
              ),
            ),

            // Sidebar Resizer Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      sidebarWidth = max(
                        300,
                        min(sw * 0.6, sidebarWidth + details.delta.dx),
                      );
                      _fitScreen();
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Menu Button (Top Left)
            Positioned(
              top: 10,
              left: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                child: Icon(sidebarOpen ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  AudioEngine.playClick();
                  setState(() {
                    sidebarOpen = !sidebarOpen;
                  });
                  Future.delayed(const Duration(milliseconds: 300), _fitScreen);
                },
              ),
            ),

            // HUD
            if (hudText.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: sidebarOpen ? sidebarWidth : 0,
                right: 0,
                bottom: 30,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF6366f1), width: 4),
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
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF6366f1),
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            hudText,
                            style: const TextStyle(
                              color: Colors.white,
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

            // Success Popup / Next Button
            if (isCompleted)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: sidebarOpen ? sidebarWidth : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  alignment: Alignment.center,
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
                        const Icon(
                          Icons.star,
                          color: Color(0xFF10b981),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t('summaryTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (scenario == 5)
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF10b981),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scenario < 5
                                ? const Color(0xFF6366f1)
                                : Colors.amber,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: Icon(
                            scenario < 5 ? Icons.arrow_forward : Icons.flag,
                          ),
                          label: Text(
                            scenario < 5 ? t('nextScenario') : t('finishLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (scenario < 5) {
                              _loadScenario(scenario + 1);
                            } else {
                              _resetLab();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Curtain Screen
            if (!isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_fix_high,
                            color: Color(0xFF6366f1),
                            size: 100,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('shutterTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366f1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            icon: const Icon(
                              Icons.play_circle_fill,
                              size: 28,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              AudioEngine.curtainScreen();
                              setState(() => isCurtainOpen = true);
                              _loadScenario(1);
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
}

/// Custom Canvas Painter for all Scenarios
class FractionPainter extends CustomPainter {
  final SimState sim;
  final int scenario;
  final double zoom;
  final double panX, panY;
  final String Function(String) t;

  static const Color outlineColor = Color(0xFF0F172A);

  FractionPainter(
    this.sim,
    this.scenario,
    this.zoom,
    this.panX,
    this.panY,
    this.t,
  );

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

  // Common Drawing Methods
  void _drawRRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke, [
    double strokeW = 2,
  ]) {
    final rect = RRect.fromRectAndRadius(
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
    if (stroke != Colors.transparent && strokeW > 0) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fill, [
    Color? stroke,
    double strokeW = 3,
    bool bold = true,
  ]) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontFamily: 'monospace',
    );
    if (stroke != null && stroke != Colors.transparent) {
      final p1 = TextPainter(
        text: TextSpan(
          text: text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeW
              ..color = stroke,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      p1.paint(canvas, Offset(x - p1.width / 2, y - p1.height / 2));
    }
    final p2 = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(color: fill),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    p2.paint(canvas, Offset(x - p2.width / 2, y - p2.height / 2));
  }

  void _drawChocolateBar(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    int totalPieces,
    int highPieces, {
    bool noLines = false,
    double scale = 1.0,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    _drawRRect(
      canvas,
      4,
      4,
      w,
      h,
      6,
      Colors.black38,
      Colors.transparent,
      0,
    ); // shadow
    _drawRRect(
      canvas,
      0,
      0,
      w,
      h,
      6,
      const Color(0xFF5c4033),
      outlineColor,
      4,
    ); // base

    double pW = w / totalPieces;
    if (highPieces > 0) {
      canvas.clipRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, pW * highPieces, h),
          topLeft: const Radius.circular(6),
          bottomLeft: const Radius.circular(6),
          topRight: Radius.circular(highPieces == totalPieces ? 6 : 0),
          bottomRight: Radius.circular(highPieces == totalPieces ? 6 : 0),
        ),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, 0, pW * highPieces, h),
        Paint()..color = const Color(0xFFa0522d),
      );
    }

    if (!noLines) {
      for (int i = 1; i < totalPieces; i++) {
        _drawLine(canvas, i * pW, 0, i * pW, h, outlineColor, 3);
        _drawLine(
          canvas,
          (i - 1) * pW + 2,
          2,
          i * pW - 2,
          2,
          Colors.white24,
          2,
        );
        _drawLine(
          canvas,
          (i - 1) * pW + 2,
          2,
          (i - 1) * pW + 2,
          h - 2,
          Colors.white24,
          2,
        );
      }
      _drawLine(
        canvas,
        (totalPieces - 1) * pW + 2,
        2,
        w - 2,
        2,
        Colors.white24,
        2,
      );
      _drawLine(
        canvas,
        (totalPieces - 1) * pW + 2,
        2,
        (totalPieces - 1) * pW + 2,
        h - 2,
        Colors.white24,
        2,
      );
    } else {
      _drawRRect(
        canvas,
        3,
        3,
        w - 6,
        h - 6,
        4,
        Colors.white10,
        Colors.transparent,
        0,
      );
    }
    canvas.restore();
  }

  void _drawBot(
    Canvas canvas,
    double x,
    double y,
    double scale, [
    String label = "",
  ]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    _drawLine(canvas, -15, -40, -25, -60, outlineColor, 3);
    canvas.drawCircle(const Offset(-25, -60), 5, Paint()..color = Colors.amber);
    _drawLine(canvas, 15, -40, 25, -60, outlineColor, 3);
    canvas.drawCircle(const Offset(25, -60), 5, Paint()..color = Colors.amber);

    _drawRRect(
      canvas,
      -35,
      -45,
      70,
      50,
      10,
      const Color(0xFFcbd5e1),
      outlineColor,
      4,
    ); // Head
    _drawRRect(
      canvas,
      -20,
      -35,
      15,
      15,
      4,
      outlineColor,
      Colors.transparent,
      0,
    ); // L eye
    _drawRRect(
      canvas,
      5,
      -35,
      15,
      15,
      4,
      outlineColor,
      Colors.transparent,
      0,
    ); // R eye
    canvas.drawCircle(
      const Offset(-12, -27),
      3,
      Paint()..color = const Color(0xFF38bdf8),
    );
    canvas.drawCircle(
      const Offset(13, -27),
      3,
      Paint()..color = const Color(0xFF38bdf8),
    );
    _drawRRect(
      canvas,
      -15,
      -12,
      30,
      8,
      4,
      outlineColor,
      Colors.transparent,
      0,
    ); // Mouth

    _drawRRect(
      canvas,
      -40,
      5,
      80,
      60,
      15,
      const Color(0xFF94a3b8),
      outlineColor,
      4,
    ); // Body
    _drawRRect(
      canvas,
      -50,
      40,
      100,
      10,
      5,
      Colors.white,
      outlineColor,
      3,
    ); // Plate
    if (label.isNotEmpty) {
      _drawText(canvas, label, 0, -70, 20, Colors.white, outlineColor, 4);
    }
    canvas.restore();
  }

  void _drawMachine(Canvas canvas, double x, double y, String label) {
    canvas.save();
    canvas.translate(x, y);
    _drawRRect(
      canvas,
      -80,
      -100,
      160,
      140,
      20,
      const Color(0xFF475569),
      outlineColor,
      5,
    );
    _drawRRect(
      canvas,
      -60,
      -80,
      120,
      60,
      10,
      const Color(0xFF1e293b),
      outlineColor,
      4,
    );
    _drawText(
      canvas,
      label,
      0,
      -50,
      22,
      const Color(0xFF38bdf8),
      Colors.transparent,
      0,
    );
    _drawRRect(
      canvas,
      -40,
      40,
      80,
      60,
      0,
      const Color(0xFF64748b),
      outlineColor,
      4,
    ); // chute
    canvas.restore();
  }

  void _drawLever(Canvas canvas, double x, double y, bool isDown) {
    canvas.save();
    canvas.translate(x, y);
    _drawRRect(
      canvas,
      -10,
      -30,
      20,
      60,
      5,
      const Color(0xFF334155),
      outlineColor,
      3,
    );
    if (isDown) {
      _drawLine(canvas, 0, 0, 0, 40, const Color(0xFF94a3b8), 8);
      canvas.drawCircle(const Offset(0, 45), 15, Paint()..color = Colors.red);
      canvas.drawCircle(
        const Offset(0, 45),
        15,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      _drawLine(canvas, 0, 0, 0, -40, const Color(0xFF94a3b8), 8);
      canvas.drawCircle(const Offset(0, -45), 15, Paint()..color = Colors.red);
      canvas.drawCircle(
        const Offset(0, -45),
        15,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.restore();
  }

  void _drawBalanceScale(Canvas canvas, double x, double y, int tipState) {
    canvas.save();
    canvas.translate(x, y);
    _drawRRect(
      canvas,
      -50,
      130,
      100,
      20,
      10,
      const Color(0xFFb45309),
      outlineColor,
      4,
    );
    _drawLine(canvas, 0, 130, 0, 20, const Color(0xFFd97706), 15);
    _drawLine(canvas, 0, 130, 0, 20, outlineColor, 4);
    canvas.drawCircle(const Offset(0, 20), 12, Paint()..color = Colors.amber);

    double angle = tipState * (pi / 12);
    canvas.rotate(angle);
    _drawRRect(
      canvas,
      -120,
      15,
      240,
      10,
      5,
      const Color(0xFFd97706),
      outlineColor,
      4,
    ); // Arm

    void drawPan(double px, double py) {
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(-angle);
      _drawLine(canvas, 0, 0, -30, 60, const Color(0xFF94a3b8), 3);
      _drawLine(canvas, 0, 0, 30, 60, const Color(0xFF94a3b8), 3);
      _drawRRect(
        canvas,
        -40,
        60,
        80,
        15,
        0,
        const Color(0xFFcbd5e1),
        outlineColor,
        3,
      );
      canvas.restore();
    }

    drawPan(-110, 20);
    drawPan(110, 20);
    canvas.restore();
  }

  void _drawRayGun(Canvas canvas, double x, double y, bool active) {
    canvas.save();
    canvas.translate(x, y);
    if (active) {
      final path = Path()
        ..moveTo(0, 30)
        ..lineTo(-100, 200)
        ..lineTo(100, 200)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFF4ade80).withOpacity(0.4),
      );
    }
    _drawRRect(
      canvas,
      -20,
      -40,
      40,
      70,
      20,
      const Color(0xFF64748b),
      outlineColor,
      4,
    );
    _drawRRect(
      canvas,
      -30,
      -10,
      60,
      20,
      10,
      const Color(0xFF38bdf8),
      outlineColor,
      4,
    );
    _drawRRect(
      canvas,
      -10,
      -70,
      20,
      40,
      5,
      const Color(0xFF1e293b),
      outlineColor,
      3,
    ); // handle
    _drawRRect(
      canvas,
      -15,
      30,
      30,
      20,
      5,
      const Color(0xFF94a3b8),
      outlineColor,
      4,
    ); // nozzle
    canvas.drawCircle(
      Offset.zero,
      12,
      Paint()..color = active ? Colors.green : Colors.red,
    );
    canvas.restore();
  }

  void _drawPizza(
    Canvas canvas,
    double x,
    double y,
    double radius,
    int slicesTotal,
    int slicesPresent,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()..color = const Color(0xFFd97706),
    ); // Crust
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset.zero,
      radius - 8,
      Paint()..color = const Color(0xFFfef08a),
    ); // Cheese
    canvas.drawCircle(
      Offset.zero,
      radius - 8,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final peps = [
      const Offset(-20, -10),
      const Offset(20, -20),
      const Offset(5, 25),
      const Offset(-25, 15),
    ];
    for (var p in peps) {
      canvas.drawCircle(p, 6, Paint()..color = Colors.red);
    }

    if (slicesTotal > 1) {
      double angle = (pi * 2) / slicesTotal;
      for (int i = 0; i < slicesTotal; i++) {
        if (i >= slicesPresent && slicesPresent != slicesTotal) {
          final path = Path()
            ..moveTo(0, 0)
            ..arcTo(
              Rect.fromCircle(center: Offset.zero, radius: radius + 2),
              i * angle,
              angle,
              false,
            )
            ..close();
          canvas.drawPath(
            path,
            Paint()..color = const Color(0xFF1e293b),
          ); // Clear out missing slice
        } else {
          _drawLine(
            canvas,
            0,
            0,
            radius * cos(i * angle),
            radius * sin(i * angle),
            outlineColor,
            2,
          );
        }
      }
    }
    canvas.restore();
  }

  void _drawSlicer(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    _drawRRect(
      canvas,
      20,
      -10,
      60,
      20,
      10,
      const Color(0xFF1e293b),
      outlineColor,
      3,
    );
    _drawLine(canvas, 0, 0, 30, 0, const Color(0xFF94a3b8), 6);
    _drawRRect(
      canvas,
      10,
      -20,
      10,
      40,
      5,
      const Color(0xFFcbd5e1),
      outlineColor,
      3,
    );
    canvas.drawCircle(
      const Offset(-15, 0),
      25,
      Paint()..color = const Color(0xFFf1f5f9),
    );
    canvas.drawCircle(
      const Offset(-15, 0),
      25,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(-15, 0),
      4,
      Paint()..color = const Color(0xFF475569),
    );
    canvas.restore();
  }

  void _drawPackagingBox(
    Canvas canvas,
    double x,
    double y,
    String label,
    bool closed,
  ) {
    canvas.save();
    canvas.translate(x, y);
    if (!closed) {
      _drawRRect(
        canvas,
        -50,
        -40,
        100,
        40,
        0,
        const Color(0xFFb45309),
        outlineColor,
        3,
      ); // back flap
    }
    _drawRRect(
      canvas,
      -60,
      0,
      120,
      80,
      5,
      const Color(0xFFd97706),
      outlineColor,
      4,
    ); // body
    _drawRRect(
      canvas,
      -30,
      20,
      60,
      40,
      4,
      Colors.white,
      outlineColor,
      3,
    ); // label
    _drawText(canvas, label, 0, 40, 18, outlineColor, Colors.transparent, 0);
    if (!closed) {
      _drawRRect(
        canvas,
        -60,
        0,
        120,
        30,
        0,
        const Color(0xFFd97706),
        outlineColor,
        3,
      );
    } else {
      _drawRRect(
        canvas,
        -60,
        -30,
        120,
        30,
        0,
        const Color(0xFFd97706),
        outlineColor,
        3,
      ); // closed flap
    }
    canvas.restore();
  }

  // --- Scenarios Rendering ---
  void _renderS1(Canvas canvas) {
    const bgW = Color(0xFF1e293b);
    _drawRRect(canvas, -450, -250, 300, 450, 20, bgW, outlineColor, 4);
    _drawMachine(canvas, -300, -100, "1 Bar\n2 Bots");
    _drawLever(canvas, -200, -100, sim.s1Lever1);

    _drawBot(canvas, -370, 150, 0.8, sim.s1BotsL ? "1/2" : "");
    _drawBot(canvas, -230, 150, 0.8, sim.s1BotsL ? "1/2" : "");
    if (sim.s1BotsL) {
      if (!sim.s1ScaleL && sim.activeDragEntity != 's1_p1') {
        _drawChocolateBar(canvas, -395, 140, 50, 30, 2, 1);
      }
      _drawChocolateBar(canvas, -255, 140, 50, 30, 2, 1);
    }

    _drawRRect(canvas, 150, -250, 300, 450, 20, bgW, outlineColor, 4);
    _drawMachine(canvas, 300, -100, "2 Bars\n4 Bots");
    _drawLever(canvas, 400, -100, sim.s1Lever2);

    _drawBot(canvas, 190, 150, 0.6, sim.s1BotsR ? "2/4" : "");
    _drawBot(canvas, 260, 150, 0.6, sim.s1BotsR ? "2/4" : "");
    _drawBot(canvas, 330, 150, 0.6, sim.s1BotsR ? "2/4" : "");
    _drawBot(canvas, 400, 150, 0.6, sim.s1BotsR ? "2/4" : "");
    if (sim.s1BotsR) {
      if (!sim.s1ScaleR && sim.activeDragEntity != 's1_p2') {
        _drawChocolateBar(canvas, 175, 140, 30, 30, 4, 2);
      }
      _drawChocolateBar(canvas, 245, 140, 30, 30, 4, 2);
      _drawChocolateBar(canvas, 315, 140, 30, 30, 4, 2);
      _drawChocolateBar(canvas, 385, 140, 30, 30, 4, 2);
    }

    _drawBalanceScale(canvas, 0, 50, sim.s1ScaleBalance);
    double angle = sim.s1ScaleBalance * (pi / 12);
    double panLX = -110 * cos(angle);
    double panLY = 50 + 20 - 110 * sin(angle);
    double panRX = 110 * cos(angle);
    double panRY = 50 + 20 + 110 * sin(angle);

    if (sim.s1ScaleL) {
      _drawChocolateBar(canvas, panLX - 25, panLY + 50, 50, 30, 2, 1);
    }
    if (sim.s1ScaleR) {
      _drawChocolateBar(canvas, panRX - 15, panRY + 50, 30, 30, 4, 2);
    }

    if (sim.s1ScaleL && sim.s1ScaleR && !sim.animating) {
      _drawText(canvas, "=", 0, -20, 80, Colors.amber, outlineColor, 5);
    }

    if (sim.activeDragEntity == 's1_p1') {
      _drawChocolateBar(canvas, sim.dragX - 25, sim.dragY - 15, 50, 30, 2, 1);
    }
    if (sim.activeDragEntity == 's1_p2') {
      _drawChocolateBar(canvas, sim.dragX - 15, sim.dragY - 15, 30, 30, 4, 2);
    }
  }

  void _renderS2(Canvas canvas) {
    double fX = -350, fY = -150, fW = 420, fH = 200;
    _drawRRect(
      canvas,
      fX - 20,
      fY - 20,
      fW + 40,
      fH + 40,
      10,
      const Color(0xFF334155),
      outlineColor,
      5,
    );

    double tW = (2 / 3) * fW;
    _drawRRect(
      canvas,
      fX,
      fY,
      fW,
      60,
      4,
      const Color(0xFFcbd5e1),
      outlineColor,
      3,
    );
    _drawRRect(
      canvas,
      fX,
      fY,
      tW,
      60,
      4,
      const Color(0xFF38bdf8),
      outlineColor,
      3,
    );
    _drawText(
      canvas,
      "2/3",
      fX + tW / 2,
      fY + 30,
      24,
      outlineColor,
      Colors.transparent,
      0,
    );

    _drawRRect(canvas, fX, fY + 80, fW, 60, 4, Colors.black12, outlineColor, 3);
    for (int i = 1; i < 18; i++) {
      _drawLine(
        canvas,
        fX + i * (fW / 18),
        fY + 80,
        fX + i * (fW / 18),
        fY + 140,
        Colors.black26,
        1,
      );
    }

    for (var p in sim.s2RowPieces) {
      double pw = p['val'] * fW;
      _drawRRect(
        canvas,
        fX + p['x'],
        fY + 80,
        pw,
        60,
        4,
        p['color'],
        outlineColor,
        3,
      );
      _drawText(
        canvas,
        p['label'],
        fX + p['x'] + pw / 2,
        fY + 110,
        18,
        outlineColor,
        Colors.transparent,
        0,
      );
    }

    double trayX = 150, trayY = -150;
    _drawRRect(
      canvas,
      trayX,
      trayY - 20,
      250,
      300,
      10,
      const Color(0xFFd97706),
      outlineColor,
      4,
    );
    _drawText(
      canvas,
      "FRACTION TRAY",
      trayX + 125,
      trayY,
      18,
      Colors.white,
      outlineColor,
      3,
    );

    final trayPieces = [
      {
        'val': 1 / 4,
        'label': '1/4',
        'color': const Color(0xfffca5a5),
        'y': trayY + 40,
      },
      {
        'val': 1 / 5,
        'label': '1/5',
        'color': const Color(0xfffde047),
        'y': trayY + 90,
      },
      {
        'val': 1 / 6,
        'label': '1/6',
        'color': const Color(0xff86efac),
        'y': trayY + 140,
      },
      {
        'val': 1 / 9,
        'label': '1/9',
        'color': const Color(0xffd8b4fe),
        'y': trayY + 190,
      },
    ];

    for (var tp in trayPieces) {
      double pw = (tp['val'] as double) * fW;
      _drawRRect(
        canvas,
        trayX + 20,
        tp['y'] as double,
        pw,
        40,
        4,
        tp['color'] as Color,
        outlineColor,
        3,
      );
      _drawText(
        canvas,
        tp['label'] as String,
        trayX + 20 + pw / 2,
        (tp['y'] as double) + 20,
        16,
        outlineColor,
        Colors.transparent,
        0,
      );
    }

    _drawRRect(canvas, fX, fY + 170, 120, 40, 8, Colors.red, outlineColor, 3);
    _drawText(
      canvas,
      "Reset Row",
      fX + 60,
      fY + 190,
      16,
      Colors.white,
      Colors.transparent,
      0,
    );

    double currentLen = sim.s2RowPieces.fold(0.0, (sum, p) => sum + p['val']);
    if ((currentLen - 2 / 3).abs() < 0.01) {
      _drawRRect(
        canvas,
        fX,
        fY + 80,
        tW,
        60,
        4,
        Colors.transparent,
        Colors.green,
        5,
      );
      _drawText(
        canvas,
        t('lbl_equal'),
        fX + fW / 2,
        fY + 200,
        24,
        Colors.green,
        outlineColor,
        4,
      );
    }

    if (sim.activeDragEntity != null &&
        sim.activeDragEntity!.startsWith('s2p_')) {
      List<String> parts = sim.activeDragEntity!.split('_');
      double val = double.parse(parts[2]);
      Color color = Color(int.parse(parts[3]));
      String label = parts[1];
      double pw = val * fW;
      _drawRRect(
        canvas,
        sim.dragX - pw / 2,
        sim.dragY - 20,
        pw,
        40,
        4,
        color,
        outlineColor,
        3,
      );
      _drawText(
        canvas,
        label,
        sim.dragX,
        sim.dragY,
        16,
        outlineColor,
        Colors.transparent,
        0,
      );
    }
  }

  void _renderS3(Canvas canvas) {
    double cx = -300, cy = 50, cw = 600;
    _drawRRect(
      canvas,
      cx,
      cy,
      cw,
      60,
      30,
      const Color(0xFF475569),
      outlineColor,
      5,
    );
    for (double i = 0; i < cw; i += 40) {
      canvas.drawCircle(
        Offset(cx + 30 + i, cy + 30),
        8,
        Paint()..color = const Color(0xFF94a3b8),
      );
    }

    double barW = 320, barH = 120;
    double barX = cx + cw / 2 - barW / 2, barY = cy - barH - 10;

    if (!sim.s3Fused) {
      _drawChocolateBar(canvas, barX, barY, barW, barH, 8, 4);
      _drawText(
        canvas,
        "4/8",
        barX + barW / 2,
        barY - 30,
        32,
        Colors.white,
        Colors.transparent,
        0,
      );
    } else {
      if (sim.animating) {
        _drawChocolateBar(canvas, barX, barY, barW, barH, 8, 4);
        canvas.drawRect(
          Rect.fromLTWH(barX, barY, barW, barH),
          Paint()..color = Colors.white.withOpacity(sin(sim.animProgress * pi)),
        );
      } else {
        _drawChocolateBar(canvas, barX, barY, barW, barH, 2, 1);
        _drawText(
          canvas,
          "1/2",
          barX + barW / 2,
          barY - 30,
          32,
          Colors.green,
          outlineColor,
          4,
        );
      }
    }

    _drawRRect(
      canvas,
      350,
      -50,
      140,
      140,
      10,
      const Color(0xFF334155),
      outlineColor,
      4,
    );
    if (sim.activeDragEntity != 's3_ray') _drawRayGun(canvas, 420, 20, false);

    if (sim.activeDragEntity == 's3_ray' || sim.s3RayHover) {
      double rx = sim.activeDragEntity != null ? sim.dragX : sim.s3RayX;
      double ry = sim.activeDragEntity != null ? sim.dragY : sim.s3RayY;
      bool active = sim.animating && sim.activeDragEntity != 's3_ray';
      _drawRayGun(canvas, rx, ry, active);

      if (sim.s3RayHover && !sim.s3Fused && !sim.animating) {
        _drawRRect(
          canvas,
          rx + 40,
          ry - 30,
          80,
          40,
          8,
          Colors.green,
          outlineColor,
          3,
        );
        _drawText(
          canvas,
          t('lbl_fuse'),
          rx + 80,
          ry - 10,
          16,
          Colors.white,
          Colors.transparent,
          0,
        );
      }
    }
  }

  void _renderS4(Canvas canvas) {
    _drawRRect(
      canvas,
      -400,
      -150,
      200,
      200,
      20,
      const Color(0xFFd97706),
      outlineColor,
      5,
    );
    _drawText(
      canvas,
      "Table A (You)",
      -300,
      -180,
      20,
      Colors.white,
      Colors.transparent,
      0,
    );
    _drawPizza(canvas, -300, -50, 60, 4, 1);
    _drawText(canvas, "1/4", -300, 40, 20, outlineColor, Colors.transparent, 0);

    _drawRRect(
      canvas,
      -100,
      -200,
      200,
      250,
      10,
      const Color(0xFF475569),
      outlineColor,
      5,
    );
    _drawRRect(
      canvas,
      -80,
      -180,
      160,
      180,
      5,
      const Color(0xFF1e293b),
      outlineColor,
      4,
    );
    _drawPizza(canvas, 0, -90, 60, 1, 1);
    _drawText(canvas, "OVEN", 0, 20, 18, Colors.white, Colors.transparent, 0);

    _drawRRect(
      canvas,
      200,
      -150,
      300,
      200,
      20,
      const Color(0xFFd97706),
      outlineColor,
      5,
    );
    _drawText(
      canvas,
      "Table B (8 Bots)",
      350,
      -180,
      20,
      Colors.white,
      Colors.transparent,
      0,
    );

    for (int i = 0; i < 4; i++) {
      _drawBot(canvas, 240 + i * 70.0, -200, 0.4);
    }
    for (int i = 0; i < 4; i++) {
      _drawBot(canvas, 240 + i * 70.0, 100, 0.4);
    }

    final pCenters = [const Offset(280, -50), const Offset(420, -50)];
    for (int i = 0; i < sim.s4PizzasB; i++) {
      if (sim.s4Served && !sim.animating) {
        _drawText(
          canvas,
          "Served!",
          350,
          -50,
          24,
          Colors.green,
          outlineColor,
          4,
        );
      } else if (sim.animating && sim.s4Served) {
        _drawPizza(canvas, pCenters[i].dx, pCenters[i].dy, 60, 4, 4);
        canvas.drawRect(
          Rect.fromCenter(center: pCenters[i], width: 140, height: 140),
          Paint()..color = Colors.white.withOpacity(sin(sim.animProgress * pi)),
        );
      } else {
        _drawPizza(
          canvas,
          pCenters[i].dx,
          pCenters[i].dy,
          60,
          sim.s4Sliced ? 4 : 1,
          sim.s4Sliced ? 4 : 1,
        );
      }
    }

    if (sim.s4Served && !sim.animating) {
      for (int i = 0; i < 4; i++) {
        _drawText(
          canvas,
          "2/8",
          240 + i * 70.0,
          -160,
          14,
          Colors.white,
          outlineColor,
          3,
        );
      }
      for (int i = 0; i < 4; i++) {
        _drawText(
          canvas,
          "2/8",
          240 + i * 70.0,
          140,
          14,
          Colors.white,
          outlineColor,
          3,
        );
      }
    }

    _drawRRect(
      canvas,
      120,
      80,
      80,
      80,
      10,
      const Color(0xFF334155),
      outlineColor,
      4,
    );
    if (sim.activeDragEntity != 's4_slicer') _drawSlicer(canvas, 160, 120);

    if (sim.s4PizzasB == 2 &&
        !sim.s4Sliced &&
        sim.activeDragEntity != 's4_slicer') {
      _drawText(
        canvas,
        "Drag Slicer Here",
        350,
        40,
        16,
        Colors.amber,
        outlineColor,
        3,
      );
    }

    if (sim.s4Sliced && !sim.s4Served) {
      _drawRRect(canvas, 250, 60, 200, 50, 10, Colors.green, outlineColor, 4);
      _drawText(
        canvas,
        t('lbl_slice'),
        350,
        85,
        18,
        Colors.white,
        Colors.transparent,
        0,
      );
    }

    if (sim.activeDragEntity == 's4_pizza') {
      _drawPizza(canvas, sim.dragX, sim.dragY, 60, 1, 1);
    }
    if (sim.activeDragEntity == 's4_slicer') {
      _drawSlicer(canvas, sim.dragX, sim.dragY);
    }
  }

  void _renderS5(Canvas canvas) {
    double cx = -300, cy = -50, cw = 600;
    _drawRRect(
      canvas,
      cx,
      cy,
      cw,
      60,
      30,
      const Color(0xFF475569),
      outlineColor,
      5,
    );
    for (double i = 0; i < cw; i += 40) {
      canvas.drawCircle(
        Offset(cx + 30 + i, cy + 30),
        8,
        Paint()..color = const Color(0xFF94a3b8),
      );
    }

    double barW = 270, barH = 90;
    double barX = cx + cw / 2 - barW / 2, barY = cy - barH - 10;

    if (!sim.s5Boxed || sim.animating) {
      double drawX = sim.activeDragEntity == 's5_bar'
          ? sim.dragX - barW / 2
          : barX;
      double drawY = sim.activeDragEntity == 's5_bar'
          ? sim.dragY - barH / 2
          : barY;

      if (sim.s5BarState[0] == 6) {
        _drawChocolateBar(canvas, drawX, drawY, barW, barH, 9, 6);
        _drawText(
          canvas,
          "6/9",
          drawX + barW / 2,
          drawY - 20,
          24,
          Colors.white,
          Colors.transparent,
          0,
        );
      } else {
        if (sim.animating && sim.activeDragEntity != 's5_bar') {
          _drawChocolateBar(canvas, drawX, drawY, barW, barH, 9, 6);
          canvas.drawRect(
            Rect.fromLTWH(drawX, drawY, barW, barH),
            Paint()
              ..color = Colors.white.withOpacity(sin(sim.animProgress * pi)),
          );
        } else {
          _drawChocolateBar(canvas, drawX, drawY, barW, barH, 3, 2);
          _drawText(
            canvas,
            "2/3",
            drawX + barW / 2,
            drawY - 20,
            24,
            Colors.green,
            outlineColor,
            4,
          );
        }
      }
    }

    _drawRRect(
      canvas,
      350,
      -150,
      120,
      120,
      10,
      const Color(0xFF334155),
      outlineColor,
      4,
    );
    if (sim.activeDragEntity != 's5_ray') _drawRayGun(canvas, 410, -90, false);

    final boxes = [
      {'x': -200.0, 'label': "1/3", 'closed': false},
      {'x': 0.0, 'label': "1/2", 'closed': false},
      {'x': 200.0, 'label': "2/3", 'closed': sim.s5Boxed},
    ];

    for (var b in boxes) {
      double bx = b['x'] as double;
      double by = 150;
      if (sim.s5BoxAnim > 0 && b['label'] == "2/3") {
        canvas.save();
        canvas.translate(bx, by);
        double s = 1 + sin(sim.s5BoxAnim * pi) * 0.1;
        canvas.scale(s, s);
        _drawPackagingBox(
          canvas,
          0,
          0,
          b['label'] as String,
          b['closed'] as bool,
        );
        canvas.restore();
      } else {
        _drawPackagingBox(
          canvas,
          bx,
          by,
          b['label'] as String,
          b['closed'] as bool,
        );
      }
      if (b['closed'] == true && b['label'] == "2/3") {
        canvas.drawCircle(
          Offset(bx + 30, by - 20),
          15,
          Paint()..color = Colors.green,
        );
        canvas.drawCircle(
          Offset(bx + 30, by - 20),
          15,
          Paint()
            ..color = outlineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.drawPath(
          Path()
            ..moveTo(bx + 25, by - 20)
            ..lineTo(bx + 28, by - 17)
            ..lineTo(bx + 35, by - 25),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }
    }

    if (sim.activeDragEntity == 's5_ray' || sim.s5RayHover) {
      double rx = sim.activeDragEntity != null ? sim.dragX : sim.s5RayX;
      double ry = sim.activeDragEntity != null ? sim.dragY : sim.s5RayY;
      bool active = sim.animating && sim.activeDragEntity != 's5_ray';
      _drawRayGun(canvas, rx, ry, active);

      if (sim.s5RayHover && sim.s5BarState[0] == 6 && !sim.animating) {
        _drawRRect(
          canvas,
          rx + 40,
          ry - 30,
          80,
          40,
          8,
          Colors.green,
          outlineColor,
          3,
        );
        _drawText(
          canvas,
          t('lbl_fuse'),
          rx + 80,
          ry - 10,
          16,
          Colors.white,
          Colors.transparent,
          0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FractionPainter oldDelegate) => true;
}
