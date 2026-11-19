// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const Cl8MCh9A1HalvingDoublingASquare());
  });
}

class AppColors {
  static const Color bgBase = Color(0xFF061024);
  static const Color bgPrimary = Color(0xFF0A1936);
  static const Color bgSidebar = Color(0xFF1E293B);
  static const Color bgCanvas = Color(0xFF0F172A);
  static const Color bgSecondary = Color(0xFF0F254A);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFF97316);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFACC15);
  static const Color piece1 = Color(0xFF3B82F6);
  static const Color piece2 = Color(0xFFF97316);
  static const Color boardGradStart = Color(0xFF0E2A5E);
  static const Color boardGradEnd = Color(0xFF071B3F);
  static const Color border = Color(0xFF1E293B);
}

class SoundManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class8/mixkit_2073.mp3',
      ),
    );
  }

  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class8/gotitem.mp3',
      ),
    );
  }

  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class8/mixkit_1491.mp3',
      ),
    );
  }

  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class8/mixkit_946.mp3',
      ),
    );
  }

  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class8/mixkit_2574.mp3',
      ),
    );
  }
}

final Map<String, Map<String, String>> i18n = {
  "en": {
    "app_title": "Halving & Doubling a Square",
    "app_subtitle": "Class 8 • The Baudhāyana–Pythagoras Theorem",
    "start_mission": "Start Mission",
    "nav_prev": "Prev",
    "nav_next": "Next",
    "nav_submit": "Submit",
    "nav_report": "Report",
    "ui_scenario": "Scenario",
    "ui_objective": "Mission Objective",
    "ui_sequence": "Instruction Sequence",
    "ui_learnt": "Learnt Conclusion",
    "ui_navigation": "Controls",
    "scen_1": "S1 · Halve a square",
    "scen_2": "S2 · Build a double square",
    "scen_3": "S3 · Predict side c = a√2",
    "hint_0":
        "The diagonal of a square cuts it into two identical right triangles.",
    "hint_1":
        "The square built on the diagonal is a diamond. It is made of four half-triangles.",
    "hint_2":
        "The side of the doubled square equals the diagonal of the original.",
    "step_s1_1": "Look at the diagonal drawn across the square.",
    "step_s1_2": "Drag both triangles onto the two dashed halves.",
    "step_s1_3": "Submit to confirm the two halves are equal.",
    "step_s2_1": "See the diamond outline — the square on the diagonal.",
    "step_s2_2": "Drag all four triangles into the four dashed wedges.",
    "step_s2_3": "Submit: the area becomes 8, double the original 4.",
    "step_s3_1": "Tile the doubled square with the four triangles.",
    "step_s3_2": "Slide the side predictor until c² ≈ 8 (c ≈ 2.83).",
    "step_s3_3": "Submit to check both the tiling and the predicted side.",
    "mission_desc":
        "Show that the diagonal halves a square into two equal right triangles, and that the square built on the diagonal has double the area — so its side is a√2.",
    "learnt_desc":
        "Diagonal-square area = 2 × original. If original side = a, the diagonal (and the doubled square's side) = a√2. Here a = 2, so c = 2√2 ≈ 2.83.",
    "board_desc":
        "Drag each triangle onto a dashed target. On drop it snaps into place.",
    "area_readout_title": "Area Readout",
    "side_title": "Predict the side of the doubled square",
    "side_label": "Predicted side c (units)",
    "side_hint": "The doubled square has area 8. Its side is c with c² = 8.",
    "prove_title": "What you are proving",
    "prove_note":
        "A square's diagonal splits it into two equal right triangles. The square built on that diagonal has double the area.",
    "s1_tag": "§2.2 · S1",
    "s1_board": "Halve the square along its diagonal",
    "s1_area_text":
        "Original square: side 2 → area = 4. Diagonal splits it into 2 equal triangles, each area 2.",
    "s1_eq": "each triangle = ½ × 4 = 2",
    "s2_tag": "§2.2 · S2",
    "s2_board": "Build the square of DOUBLE area on the diagonal",
    "s2_area_text":
        "Four equal triangles (area 2 each) fill the tilted square built on the diagonal: 4 × 2 = 8.",
    "s2_eq": "doubled square area = 8 = 2 × 4",
    "s3_tag": "§2.2 · S3",
    "s3_board": "Predict the side c = a√2, then verify by tiling",
    "s3_area_text":
        "The doubled square has area 8, so its side c satisfies c² = 8. Therefore c = √8 = 2√2 ≈ 2.83.",
    "s3_eq": "c = a√2 = 2√2 ≈ 2.83",
    "glabel_orig": "original square (area 4)",
    "glabel_diag": "square on the diagonal (double area)",
    "flash_scen": "Scenario complete! Proceed to the next one.",
    "flash_scen_err": "Not quite done. Follow the steps!",
    "flash_all": "Mission Complete! View your report.",
    "flash_reset": "Activity reset to a neutral state.",
    "diag_title_pass": "Concept Mastered!",
    "diag_sub_pass":
        "You proved that the square on the diagonal has double the area, and side a√2.",
    "diag_title_fail": "Keep Reasoning",
    "diag_sub_fail":
        "Some steps still need work — your work is kept, adjust and try again.",
    "diag_prob": "Problem Solving",
    "diag_proc": "Procedural Fluency",
    "ui_close": "Close Report",
  },
  "hi": {
    "app_title": "एक वर्ग को आधा और दुगुना करना",
    "app_subtitle": "कक्षा 8 • बौधायन-पाइथागोरस प्रमेय",
    "start_mission": "मिशन शुरू करें",
    "nav_prev": "पिछला",
    "nav_next": "अगला",
    "nav_submit": "सबमिट",
    "nav_report": "रिपोर्ट",
    "ui_scenario": "परिदृश्य",
    "ui_objective": "मिशन का उद्देश्य",
    "ui_sequence": "निर्देश क्रम",
    "ui_learnt": "सीखा गया निष्कर्ष",
    "ui_navigation": "नियंत्रण",
    "scen_1": "S1 · एक वर्ग को आधा करें",
    "scen_2": "S2 · दुगुना वर्ग बनाएं",
    "scen_3": "S3 · भुजा c = a√2 की भविष्यवाणी करें",
    "hint_0": "एक वर्ग का विकर्ण उसे दो समान समकोण त्रिभुजों में काटता है।",
    "hint_1":
        "विकर्ण पर बना वर्ग एक समचतुर्भुज है। यह चार आधे त्रिभुजों से बना है।",
    "hint_2": "दुगुने वर्ग की भुजा मूल के विकर्ण के बराबर होती है।",
    "step_s1_1": "वर्ग में खींचे गए विकर्ण को देखें।",
    "step_s1_2": "दोनों त्रिभुजों को दो धराशायी हिस्सों पर खींचें।",
    "step_s1_3": "पुष्टि करने के लिए सबमिट करें कि दोनों हिस्से समान हैं।",
    "step_s2_1": "हीरे की रूपरेखा देखें - विकर्ण पर वर्ग।",
    "step_s2_2": "सभी चार त्रिभुजों को चार धराशायी वेजेज में खींचें।",
    "step_s2_3": "सबमिट करें: क्षेत्रफल 8 हो जाता है, मूल 4 का दुगुना।",
    "step_s3_1": "चार त्रिभुजों के साथ दुगुने वर्ग को टाइल करें।",
    "step_s3_2":
        "भुजा भविष्यवक्ता को तब तक स्लाइड करें जब तक c² ≈ 8 (c ≈ 2.83)।",
    "step_s3_3":
        "टाइलिंग और अनुमानित भुजा दोनों की जांच करने के लिए सबमिट करें।",
    "mission_desc":
        "दिखाएँ कि विकर्ण वर्ग को दो समान समकोण त्रिभुजों में आधा कर देता है, और विकर्ण पर बने वर्ग का क्षेत्रफल दोगुना होता है — इसलिए इसकी भुजा a√2 है।",
    "learnt_desc":
        "विकर्ण-वर्ग का क्षेत्रफल = 2 × मूल। यदि मूल भुजा = a, विकर्ण (और दोगुने वर्ग की भुजा) = a√2। यहाँ a = 2, इसलिए c = 2√2 ≈ 2.83।",
    "board_desc":
        "प्रत्येक त्रिभुज को एक धराशायी लक्ष्य पर खींचें। ड्रॉप पर यह जगह पर स्नैप हो जाता है।",
    "area_readout_title": "क्षेत्रफल पठन",
    "side_title": "दुगुने वर्ग की भुजा की भविष्यवाणी करें",
    "side_label": "अनुमानित भुजा c (इकाइयां)",
    "side_hint": "दुगुने वर्ग का क्षेत्रफल 8 है। इसकी भुजा c है और c² = 8 है।",
    "prove_title": "आप क्या साबित कर रहे हैं",
    "prove_note":
        "एक वर्ग का विकर्ण उसे दो समान समकोण त्रिभुजों में विभाजित करता है। उस विकर्ण पर बने वर्ग का क्षेत्रफल दुगुना होता है।",
    "s1_tag": "§2.2 · S1",
    "s1_board": "वर्ग को उसके विकर्ण के अनुदिश आधा करें",
    "s1_area_text":
        "मूल वर्ग: भुजा 2 → क्षेत्रफल = 4। विकर्ण इसे 2 समान त्रिभुजों में विभाजित करता है, प्रत्येक का क्षेत्रफल 2।",
    "s1_eq": "प्रत्येक त्रिभुज = ½ × 4 = 2",
    "s2_tag": "§2.2 · S2",
    "s2_board": "विकर्ण पर दुगुने क्षेत्रफल का वर्ग बनाएँ",
    "s2_area_text":
        "चार समान त्रिभुज (प्रत्येक का क्षेत्रफल 2) विकर्ण पर बने झुके हुए वर्ग को भरते हैं: 4 × 2 = 8।",
    "s2_eq": "दुगुने वर्ग का क्षेत्रफल = 8 = 2 × 4",
    "s3_tag": "§2.2 · S3",
    "s3_board":
        "भुजा c = a√2 की भविष्यवाणी करें, फिर टाइलिंग द्वारा सत्यापित करें",
    "s3_area_text":
        "दुगुने वर्ग का क्षेत्रफल 8 है, इसलिए इसकी भुजा c संतुष्ट करती है c² = 8। इसलिए c = √8 = 2√2 ≈ 2.83।",
    "s3_eq": "c = a√2 = 2√2 ≈ 2.83",
    "glabel_orig": "मूल वर्ग (क्षेत्रफल 4)",
    "glabel_diag": "विकर्ण पर वर्ग (दुगुना क्षेत्रफल)",
    "flash_scen": "परिदृश्य पूरा हुआ! अगले पर जाएं।",
    "flash_scen_err": "अभी पूरा नहीं हुआ। चरणों का पालन करें!",
    "flash_all": "मिशन पूरा हुआ! अपनी रिपोर्ट देखें।",
    "flash_reset": "गतिविधि तटस्थ स्थिति में रीसेट हो गई।",
    "diag_title_pass": "अवधारणा में महारत!",
    "diag_sub_pass":
        "आपने सिद्ध किया कि विकर्ण पर बने वर्ग का क्षेत्रफल दोगुना और भुजा a√2 है।",
    "diag_title_fail": "तर्क जारी रखें",
    "diag_sub_fail":
        "कुछ चरणों में अभी भी काम करने की आवश्यकता है — आपका कार्य रखा गया है, समायोजित करें और पुनः प्रयास करें।",
    "diag_prob": "समस्या समाधान",
    "diag_proc": "प्रक्रियात्मक प्रवाह",
    "ui_close": "रिपोर्ट बंद करें",
  },
};

const double L = 120.0;
final List<Offset> baseTri = [
  const Offset(-L / 3, -L / 3),
  const Offset(2 * L / 3, -L / 3),
  const Offset(-L / 3, 2 * L / 3),
];

Offset rotatePoint(Offset p, double deg) {
  double r = deg * math.pi / 180.0;
  double c = math.cos(r);
  double s = math.sin(r);
  return Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c);
}

Offset calculateCentroid(List<Offset> pts) {
  double x = 0, y = 0;
  for (var p in pts) {
    x += p.dx;
    y += p.dy;
  }
  return Offset(x / pts.length, y / pts.length);
}

bool isPointInPolygon(Offset pt, List<Offset> poly) {
  bool c = false;
  int i, j = poly.length - 1;
  for (i = 0; i < poly.length; j = i++) {
    if (((poly[i].dy > pt.dy) != (poly[j].dy > pt.dy)) &&
        (pt.dx <
            (poly[j].dx - poly[i].dx) *
                    (pt.dy - poly[i].dy) /
                    (poly[j].dy - poly[i].dy) +
                poly[i].dx)) {
      c = !c;
    }
  }
  return c;
}

class TransformData {
  final double cx;
  final double cy;
  final double deg;
  TransformData(this.cx, this.cy, this.deg);
}

TransformData findBestTransform(List<Offset> target) {
  Offset c = calculateCentroid(target);
  double bestDeg = 0;
  double bestCost = double.infinity;

  List<double> angles = [0, 90, 180, 270];
  for (double deg in angles) {
    double cost = 0;
    List<Offset> rp = baseTri.map((p) {
      Offset q = rotatePoint(p, deg);
      return Offset(q.dx + c.dx, q.dy + c.dy);
    }).toList();

    List<bool> used = [false, false, false];
    for (Offset p in rp) {
      int bm = -1;
      double md = double.infinity;
      for (int j = 0; j < target.length; j++) {
        if (used[j]) continue;
        double d = (p - target[j]).distance;
        if (d < md) {
          md = d;
          bm = j;
        }
      }
      if (bm != -1) used[bm] = true;
      cost += md;
    }

    if (cost < bestCost) {
      bestCost = cost;
      bestDeg = deg;
    }
  }
  return TransformData(c.dx, c.dy, bestDeg);
}

class SlotDef {
  final int id;
  final List<Offset> targetPoly;
  late TransformData tf;
  SlotDef(this.id, this.targetPoly) {
    tf = findBestTransform(targetPoly);
  }
}

class Piece {
  final int id;
  final String kind;
  Offset position;
  double rotation;
  int? snappedSlotId;
  bool isDragging = false;
  bool isCorrect = false;

  Piece({
    required this.id,
    required this.kind,
    required this.position,
    this.rotation = 0,
  });

  List<Offset> get currentWorldPoly {
    return baseTri.map((p) {
      Offset rp = rotatePoint(p, rotation);
      return Offset(rp.dx + position.dx, rp.dy + position.dy);
    }).toList();
  }
}

class ScenarioConfig {
  final String key;
  final List<SlotDef> slots;
  final List<int> needSlots;
  final int pieceCount;
  final bool showSide;
  final double sideTarget;
  final String frameType;

  ScenarioConfig({
    required this.key,
    required this.slots,
    required this.needSlots,
    required this.pieceCount,
    this.showSide = false,
    this.sideTarget = 0.0,
    required this.frameType,
  });
}

class Cl8MCh9A1HalvingDoublingASquare extends StatefulWidget {
  const Cl8MCh9A1HalvingDoublingASquare({super.key});

  @override
  State<Cl8MCh9A1HalvingDoublingASquare> createState() =>
      _Cl8MCh9A1HalvingDoublingASquareState();
}

class _Cl8MCh9A1HalvingDoublingASquareState
    extends State<Cl8MCh9A1HalvingDoublingASquare>
    with TickerProviderStateMixin {
  // App State
  bool _isCurtainOpen = true;
  String _lang = 'en';
  bool _isSidebarOpen = true;
  double _sidebarWidth = 340.0;
  bool _showDiagnostics = false;
  String _flashMessage = "";

  // Game State
  int _activeScenario = 0;
  List<Map<int, int>> _placements = [{}, {}, {}];
  List<double> _sideVals = [250, 250, 283];
  List<bool> _scenarioCorrect = [false, false, false];

  final List<Piece> _currentPieces = [];
  late List<ScenarioConfig> _scenarios;

  // Viewport State
  final GlobalKey _canvasKey = GlobalKey();
  Offset _viewportOffset = const Offset(0, 0);
  double _viewportScale = 1.0;
  Offset? _lastFocalPoint;
  Piece? _draggedPiece;

  // Geometry Constants
  final Offset sqOrigin = const Offset(80, 100);
  late Offset A, B, C, d2;
  final Offset O = const Offset(360, 200);
  late Offset pR, pD, pL, pU;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initGeometry();
    _loadScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _initGeometry() {
    A = sqOrigin;
    B = Offset(sqOrigin.dx + L, sqOrigin.dy);
    C = Offset(sqOrigin.dx + L, sqOrigin.dy + L);
    d2 = Offset(sqOrigin.dx, sqOrigin.dy + L);

    pR = Offset(O.dx + L, O.dy);
    pD = Offset(O.dx, O.dy + L);
    pL = Offset(O.dx - L, O.dy);
    pU = Offset(O.dx, O.dy - L);

    List<SlotDef> straightSlots = [
      SlotDef(0, [A, B, C]),
      SlotDef(1, [A, C, d2]),
    ];

    List<SlotDef> tiltSlots = [
      SlotDef(0, [O, pR, pD]),
      SlotDef(1, [O, pD, pL]),
      SlotDef(2, [O, pL, pU]),
      SlotDef(3, [O, pU, pR]),
    ];

    _scenarios = [
      ScenarioConfig(
        key: 's1',
        slots: straightSlots,
        needSlots: [0, 1],
        pieceCount: 2,
        frameType: 'straight',
      ),
      ScenarioConfig(
        key: 's2',
        slots: tiltSlots,
        needSlots: [0, 1, 2, 3],
        pieceCount: 4,
        frameType: 'tilt',
      ),
      ScenarioConfig(
        key: 's3',
        slots: tiltSlots,
        needSlots: [0, 1, 2, 3],
        pieceCount: 4,
        showSide: true,
        sideTarget: 2 * math.sqrt1_2 * 2,
        frameType: 'tilt',
      ),
    ];
  }

  void _loadScenario(int index) {
    if (index < 0 || index >= _scenarios.length) return;
    _activeScenario = index;
    ScenarioConfig cfg = _scenarios[index];
    _currentPieces.clear();

    Map<int, int> currentPlace = _placements[index];

    for (int i = 0; i < cfg.pieceCount; i++) {
      String kind = (i % 2 == 0) ? 't1' : 't2';
      Offset trayPos = Offset(100.0 + (i * 130), 400.0);

      Piece p = Piece(id: i, kind: kind, position: trayPos);

      if (currentPlace.containsKey(i)) {
        int slotId = currentPlace[i]!;
        SlotDef slot = cfg.slots.firstWhere((s) => s.id == slotId);
        p.position = Offset(slot.tf.cx, slot.tf.cy);
        p.rotation = slot.tf.deg;
        p.snappedSlotId = slotId;
        p.isCorrect = _scenarioCorrect[index];
      }

      _currentPieces.add(p);
    }

    _viewportOffset = const Offset(0, 0);
    _viewportScale = 1.0;

    setState(() {});
  }

  void _showFlash(String msg) {
    setState(() {
      _flashMessage = msg;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _flashMessage = "";
        });
      }
    });
  }

  void _checkSubmit() {
    if (_scenarioCorrect[_activeScenario]) return;

    ScenarioConfig cfg = _scenarios[_activeScenario];
    Map<int, int> place = _placements[_activeScenario];

    bool allPlaced = cfg.needSlots.every((sId) => place.containsValue(sId));
    bool sideOk = true;

    if (cfg.showSide) {
      double target = 283;
      if ((_sideVals[_activeScenario] - target).abs() > 8) {
        sideOk = false;
      }
    }

    if (allPlaced && sideOk) {
      SoundManager.playPageOpen();
      setState(() {
        _scenarioCorrect[_activeScenario] = true;
        for (var p in _currentPieces) {
          p.isCorrect = true;
        }
      });

      if (_scenarioCorrect.every((c) => c)) {
        _showFlash(i18n[_lang]!['flash_all']!);
        _showDiagnostics = true;
      } else {
        _showFlash(i18n[_lang]!['flash_scen']!);
      }
    } else {
      SoundManager.playError();
      _showFlash(i18n[_lang]!['flash_scen_err']!);
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_scenarioCorrect[_activeScenario]) return;

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localPos = box.globalToLocal(details.focalPoint);
    Offset worldPos = (localPos - _viewportOffset) / _viewportScale;

    _lastFocalPoint = localPos;
    _draggedPiece = null;

    for (int i = _currentPieces.length - 1; i >= 0; i--) {
      if (isPointInPolygon(worldPos, _currentPieces[i].currentWorldPoly)) {
        _draggedPiece = _currentPieces[i];
        SoundManager.playClick();

        setState(() {
          _draggedPiece!.isDragging = true;
          _currentPieces.removeAt(i);
          _currentPieces.add(_draggedPiece!);

          if (_draggedPiece!.snappedSlotId != null) {
            _placements[_activeScenario].remove(_draggedPiece!.id);
            _draggedPiece!.snappedSlotId = null;
          }
        });
        return;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_lastFocalPoint == null) return;

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localPos = box.globalToLocal(details.focalPoint);
    Offset delta = localPos - _lastFocalPoint!;

    if (_draggedPiece != null) {
      setState(() {
        _draggedPiece!.position += delta / _viewportScale;
        _draggedPiece!.rotation = 0;
      });
    } else {
      setState(() {
        _viewportOffset += delta;
        if (details.scale != 1.0) {
          double newScale = (_viewportScale * details.scale).clamp(0.5, 3.0);
          Offset focalWorld = (localPos - _viewportOffset) / _viewportScale;
          _viewportScale = newScale;
          _viewportOffset = localPos - focalWorld * _viewportScale;
        }
      });
    }
    _lastFocalPoint = localPos;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggedPiece != null) {
      _snapPiece(_draggedPiece!);
      setState(() {
        _draggedPiece!.isDragging = false;
        _draggedPiece = null;
      });
    }
    _lastFocalPoint = null;
  }

  void _snapPiece(Piece p) {
    ScenarioConfig cfg = _scenarios[_activeScenario];
    double snapDist = 40.0;
    SlotDef? bestSlot;
    double bestD = double.infinity;

    List<int> occupied = _placements[_activeScenario].values.toList();

    for (SlotDef slot in cfg.slots) {
      if (occupied.contains(slot.id)) continue;
      double d = (p.position - Offset(slot.tf.cx, slot.tf.cy)).distance;
      if (d < bestD && d < snapDist) {
        bestD = d;
        bestSlot = slot;
      }
    }

    if (bestSlot != null) {
      SoundManager.playPageOpen();
      setState(() {
        p.position = Offset(bestSlot!.tf.cx, bestSlot.tf.cy);
        p.rotation = bestSlot.tf.deg;
        p.snappedSlotId = bestSlot.id;
        _placements[_activeScenario][p.id] = bestSlot.id;
      });
    } else {
      SoundManager.playError();
      setState(() {
        p.position = Offset(100.0 + (p.id * 130), 400.0);
        p.rotation = 0;
        p.snappedSlotId = null;
        _placements[_activeScenario].remove(p.id);
      });
    }
  }

  String getT(String key) => i18n[_lang]![key] ?? key;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halving & Doubling',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgCanvas,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            _buildCanvasArea(),
            _buildSidebar(),
            _buildMenuToggle(),

            if (_flashMessage.isNotEmpty)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _flashMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

            if (_isCurtainOpen) _buildCurtain(),
            if (_showDiagnostics) _buildDiagnosticsModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: 0,
      left: _isSidebarOpen ? _sidebarWidth : 0,
      child: Container(
        color: AppColors.bgCanvas,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      key: _canvasKey,
                      dragStartBehavior:
                          DragStartBehavior.down, // Instant dragging
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: ClipRect(
                        child: CustomPaint(
                          painter: BoardPainter(
                            scenario: _scenarios[_activeScenario],
                            pieces: _currentPieces,
                            viewportOffset: _viewportOffset,
                            viewportScale: _viewportScale,
                            placedSlots: _placements[_activeScenario].values
                                .toList(),
                          ),
                        ),
                      ),
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

  Widget _buildReadoutCard() {
    String tag = getT('${_scenarios[_activeScenario].key}_tag');
    String desc = getT('${_scenarios[_activeScenario].key}_area_text');
    String eq = getT('${_scenarios[_activeScenario].key}_eq');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getT('area_readout_title'),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              eq.replaceAll(RegExp(r'<[^>]*>'), ''),
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getT('side_title'),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getT('side_label'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          SliderTheme(
            data: const SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.accent,
            ),
            child: Slider(
              value: _sideVals[_activeScenario],
              min: 200,
              max: 400,
              onChanged: _scenarioCorrect[_activeScenario]
                  ? null
                  : (v) {
                      setState(() => _sideVals[_activeScenario] = v);
                    },
            ),
          ),
          Center(
            child: Text(
              'c = ${(_sideVals[_activeScenario] / 100).toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      left: _isSidebarOpen ? 0 : -_sidebarWidth,
      width: _sidebarWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bgSidebar,
              border: Border(
                right: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 36),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.school,
                        color: AppColors.accent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getT('app_title'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getT('app_subtitle'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          SoundManager.playClick();
                          setState(() {
                            _lang = _lang == 'en' ? 'hi' : 'en';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            border: Border.all(color: AppColors.textSecondary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _lang.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.textSecondary),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            SoundManager.playClick();
                            setState(() {
                              _activeScenario = 0;
                              _placements = [{}, {}, {}];
                              _scenarioCorrect = [false, false, false];
                              _sideVals = [250, 250, 283];
                              _showDiagnostics = false;
                              _isCurtainOpen = true;
                              _loadScenario(0);
                            });
                            _showFlash(getT('flash_reset'));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSidebarCard(
                    getT('ui_scenario'),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _activeScenario,
                        isExpanded: true,
                        dropdownColor: AppColors.bgPrimary,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        items: [0, 1, 2]
                            .map(
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(getT('scen_${i + 1}')),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          SoundManager.playDropdown();
                          if (v != null && v != _activeScenario) {
                            _loadScenario(v);
                          }
                        },
                      ),
                    ),
                  ),

                  _buildSidebarCard(
                    getT('ui_objective'),
                    Text(
                      getT('mission_desc'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  _buildSidebarCard(getT('ui_sequence'), _buildStepsList()),
                  _buildSidebarCard(
                    getT('ui_learnt'),
                    Text(
                      getT('learnt_desc'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  _buildReadoutCard(),
                  if (_scenarios[_activeScenario].showSide) _buildSideCard(),

                  _buildSidebarCard(
                    getT('ui_navigation'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        _sidebarNavBtn(
                          Icons.chevron_left,
                          getT('nav_prev'),
                          _activeScenario == 0,
                          () {
                            SoundManager.playClick();
                            _loadScenario(_activeScenario - 1);
                          },
                        ),
                        _sidebarNavBtn(
                          Icons.chevron_right,
                          getT('nav_next'),
                          !_scenarioCorrect[_activeScenario] ||
                              _activeScenario == 2,
                          () {
                            SoundManager.playClick();
                            _loadScenario(_activeScenario + 1);
                          },
                        ),
                        _sidebarNavBtn(
                          Icons.check_circle,
                          getT('nav_submit'),
                          _scenarioCorrect[_activeScenario],
                          () {
                            SoundManager.playClick();
                            _checkSubmit();
                          },
                          primary: true,
                        ),
                        _sidebarNavBtn(
                          Icons.bar_chart,
                          getT('nav_report'),
                          !_scenarioCorrect.every((c) => c),
                          () {
                            SoundManager.playClick();
                            setState(() => _showDiagnostics = true);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      '© ZEROSCIENCELAB - Fall in love with math and Science',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                    300.0,
                    MediaQuery.of(context).size.width * 0.6,
                  );
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarCard(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _sidebarNavBtn(
    IconData icon,
    String text,
    bool disabled,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Material(
        color: primary ? AppColors.accent : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: primary ? Colors.transparent : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: primary ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: primary ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    List<Widget> steps = [];
    int active = 0;
    List<int> done = [];
    int placedCount = _placements[_activeScenario].length;

    if (_activeScenario == 0) {
      if (placedCount > 0) {
        done.add(0);
      }
      if (placedCount == 2) {
        done.add(1);
      }
      active = placedCount == 2 ? 2 : (placedCount > 0 ? 1 : 0);
    } else if (_activeScenario == 1) {
      if (placedCount > 0) {
        done.add(0);
      }
      if (placedCount == 4) {
        done.add(1);
      }
      active = placedCount == 4 ? 2 : (placedCount > 0 ? 1 : 0);
    } else {
      if (placedCount == 4) {
        done.add(0);
      }
      if ((_sideVals[2] - 283).abs() <= 8) {
        done.add(1);
      }
      if (placedCount == 4 && (_sideVals[2] - 283).abs() <= 8) {
        active = 2;
      } else if (placedCount == 4) {
        active = 1;
      }
    }

    for (int k = 0; k < 3; k++) {
      String? t = i18n[_lang]!['step_s${_activeScenario + 1}_${k + 1}'];
      if (t == null) {
        continue;
      }

      bool isSolved = _scenarioCorrect[_activeScenario];
      Color bgColor = AppColors.bgBase;
      Color textColor = AppColors.textSecondary;
      Color borderColor = Colors.transparent;

      if (isSolved) {
        textColor = AppColors.success;
        borderColor = AppColors.success;
      } else if (k == active) {
        bgColor = AppColors.accent.withValues(alpha: 0.15);
        textColor = AppColors.textPrimary;
        borderColor = AppColors.accent;
      } else if (done.contains(k)) {
        textColor = AppColors.success;
        borderColor = AppColors.success;
      }

      steps.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: borderColor, width: 4)),
          ),
          child: Text(
            '${k + 1}. $t',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: steps,
    );
  }

  Widget _buildMenuToggle() {
    return Positioned(
      top: 10,
      left: 10,
      child: SafeArea(
        child: Material(
          color: AppColors.bgPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
          ),
          child: InkWell(
            onTap: () {
              SoundManager.playClick();
              setState(() => _isSidebarOpen = !_isSidebarOpen);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                _isSidebarOpen ? Icons.menu_open : Icons.menu,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Positioned.fill(
      child: Container(
        color: AppColors.bgBase,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.grid_view,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                getT('app_title'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                getT('app_subtitle'),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  SoundManager.curtainScreen();
                  setState(() => _isCurtainOpen = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  getT('start_mission'),
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
    );
  }

  Widget _buildDiagnosticsModal() {
    bool passed = _scenarioCorrect.every((c) => c);
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: passed
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.error.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: passed ? AppColors.success : AppColors.error,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        passed ? Icons.check : Icons.priority_high,
                        color: passed ? AppColors.success : AppColors.error,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getT(
                              passed ? 'diag_title_pass' : 'diag_title_fail',
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            getT(passed ? 'diag_sub_pass' : 'diag_sub_fail'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    SoundManager.playClick();
                    setState(() => _showDiagnostics = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgSecondary,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.textSecondary),
                    ),
                  ),
                  child: Text(getT('ui_close')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final ScenarioConfig scenario;
  final List<Piece> pieces;
  final Offset viewportOffset;
  final double viewportScale;
  final List<int> placedSlots;

  BoardPainter({
    required this.scenario,
    required this.pieces,
    required this.viewportOffset,
    required this.viewportScale,
    required this.placedSlots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    canvas.translate(viewportOffset.dx, viewportOffset.dy);
    canvas.scale(viewportScale, viewportScale);

    final bgRect = Rect.fromLTWH(0, 0, 800, 600);
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(const Offset(400, 300), 500, [
        AppColors.boardGradStart,
        AppColors.boardGradEnd,
      ]);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(16)),
      bgPaint,
    );

    final linePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (scenario.frameType == 'straight') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(80, 100, L, L),
          const Radius.circular(3),
        ),
        linePaint,
      );
      _drawDashedLine(
        canvas,
        const Offset(80, 100),
        Offset(80 + L, 100 + L),
        dashPaint,
      );
    } else {
      final path = Path()
        ..moveTo(360 + L, 200)
        ..lineTo(360, 200 + L)
        ..lineTo(360 - L, 200)
        ..lineTo(360, 200 - L)
        ..close();
      canvas.drawPath(path, linePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(80, 100, L, L),
          const Radius.circular(3),
        ),
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _drawDashedLine(
        canvas,
        const Offset(80, 100),
        Offset(80 + L, 100 + L),
        dashPaint,
      );
    }

    final slotOutline = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final slotFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (var slot in scenario.slots) {
      Path p = Path()..moveTo(slot.targetPoly[0].dx, slot.targetPoly[0].dy);
      for (int i = 1; i < slot.targetPoly.length; i++) {
        p.lineTo(slot.targetPoly[i].dx, slot.targetPoly[i].dy);
      }
      p.close();

      canvas.drawPath(p, slotFill);
      if (placedSlots.contains(slot.id)) {
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.white12
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else {
        _drawDashedPath(canvas, p, slotOutline);
      }
    }

    for (var piece in pieces) {
      final poly = piece.currentWorldPoly;
      Path p = Path()..moveTo(poly[0].dx, poly[0].dy);
      for (int i = 1; i < poly.length; i++) {
        p.lineTo(poly[i].dx, poly[i].dy);
      }
      p.close();

      Color pColor = piece.kind == 't1' ? AppColors.piece1 : AppColors.piece2;
      if (piece.isCorrect) {
        pColor = AppColors.success;
      } else if (piece.snappedSlotId != null) {
        pColor = pColor.withValues(alpha: 0.85);
      }

      canvas.drawPath(
        p,
        Paint()
          ..color = pColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        p,
        Paint()
          ..color = AppColors.bgPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double distance = (p2 - p1).distance;
    double dashes = distance / (dashWidth + dashSpace);
    Offset dir = (p2 - p1) / distance;

    for (int i = 0; i < dashes; i++) {
      Offset start = p1 + dir * (i * (dashWidth + dashSpace));
      Offset end = start + dir * dashWidth;
      if ((end - p1).distance > distance) end = p2;
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    Path dashedPath = Path();
    const dashWidth = 6.0;
    const dashSpace = 5.0;

    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
