// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Minus Matters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const MinusMattersRemovalSquare(),
    ),
  );
}

class PieceData {
  final String id;
  String? label;
  bool isRemoved;
  double removeProgress;
  Offset removeTarget;
  AnimationController? animController;

  PieceData({
    required this.id,
    this.label,
    this.isRemoved = false,
    this.removeProgress = 0.0,
    this.removeTarget = Offset.zero,
    this.animController,
  });

  void reset() {
    label = null;
    isRemoved = false;
    removeProgress = 0.0;
    animController?.reset();
  }
}

class MinusMattersRemovalSquare extends StatefulWidget {
  const MinusMattersRemovalSquare({super.key});

  @override
  State<MinusMattersRemovalSquare> createState() =>
      _MinusMattersRemovalSquareState();
}

class _MinusMattersRemovalSquareState extends State<MinusMattersRemovalSquare>
    with TickerProviderStateMixin {
  // --- Game State ---
  bool _curtainOpen = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 300.0;

  int _a = 6;
  int _b = 2;
  int _scenario = 0; // 0: Label & Remove, 1: 29^2
  int _step = 0;
  String _lang = 'en';

  String? _selectedLabel;
  Offset _pan = Offset.zero;
  double _scale = 1.0;
  double _baseScale = 1.0;
  final GlobalKey _canvasKey = GlobalKey();

  // --- Pieces ---
  late Map<String, PieceData> _pieces;

  // --- Toast ---
  String _toastMessage = '';
  bool _toastVisible = false;
  Color _toastColor = Colors.green;

  // --- Inputs ---
  String _idP1 = '';
  String _idP2 = '';
  String _idP3 = '';
  final TextEditingController _inpA = TextEditingController();
  final TextEditingController _inpB = TextEditingController();
  final TextEditingController _inpA2 = TextEditingController();
  final TextEditingController _inp2AB = TextEditingController();
  final TextEditingController _inpB2 = TextEditingController();
  final TextEditingController _inpAns = TextEditingController();

  // --- Audio Players ---
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // --- Dictionary ---
  final Map<String, Map<String, dynamic>> _dict = {
    'en': {
      'title': 'Minus Matters',
      'subtitle': 'Class 9 • Exploring Algebraic Identities',
      'mission':
          'Derive (a-b)² = a² - 2ab + b² by removing two rectangles from an a × a square.',
      'mission2': 'Apply the derived formula to calculate 29² mentally.',
      'scenarios': ['Scenario 1: Label & Remove', 'Scenario 2: Apply to 29²'],
      'steps_0': [
        [
          'Identify the pieces',
          'Click a label below, then click the matching piece to assign it.',
        ],
        [
          'Remove the strips',
          'Click on the ab strip and the b(a-b) strip to remove them from the main square.',
        ],
        [
          'Build Identity',
          'The remaining piece is (a-b)². Build the formula on the right.',
        ],
      ],
      'steps_1': [
        ['Write 29 as (30-1).', 'Set a=30, b=1.'],
        ['Calculate terms.', 'Find a², 2ab, b².'],
        ['Final Answer', 'Input the values to verify.'],
      ],
      'labels': ['(a-b)²', 'ab', 'b(a-b)'],
      'btnValidate': 'VALIDATE MODEL',
      'feedbackCorrect': 'Excellent! Proceed to next step.',
      'feedbackWrong': 'That doesn\'t seem right. Check again.',
      'feedbackComplete': 'Mission Accomplished!',
      'wholeSide': 'Whole Side (a)',
      'stripWidth': 'Strip Width (b)',
      'enterLab': 'Enter Lab',
    },
    'hi': {
      'title': 'माइनस मैटर्स',
      'subtitle': 'कक्षा 9 • बीजगणितीय सर्वसमिकाएँ',
      'mission':
          'एक a × a वर्ग से दो आयत हटाकर (a-b)² = a² - 2ab + b² प्राप्त करें।',
      'mission2': '29² की गणना करने के लिए सूत्र लागू करें।',
      'scenarios': [
        'दृश्य 1: लेबल करें और निकालें',
        'दृश्य 2: 29² पर लागू करें',
      ],
      'steps_0': [
        [
          'टुकड़ों को पहचानें',
          'नीचे दिए गए लेबल पर क्लिक करें, फिर टुकड़े पर क्लिक करें।',
        ],
        [
          'स्ट्रिप्स निकालें',
          'ab और b(a-b) स्ट्रिप्स को हटाने के लिए उन पर क्लिक करें।',
        ],
        ['पहचान बनाएँ', 'बचा हुआ टुकड़ा (a-b)² है। दाईं ओर सूत्र बनाएँ।'],
      ],
      'steps_1': [
        ['29 को (30-1) के रूप में लिखें।', 'a=30, b=1 सेट करें।'],
        ['पदों की गणना करें।', 'a², 2ab, b² ज्ञात करें।'],
        ['अंतिम उत्तर', 'सत्यापित करने के लिए मान दर्ज करें।'],
      ],
      'labels': ['(a-b)²', 'ab', 'b(a-b)'],
      'btnValidate': 'सत्यापित करें',
      'feedbackCorrect': 'बहुत बढ़िया! अगले चरण पर जाएं।',
      'feedbackWrong': 'यह सही नहीं लग रहा है। फिर से जांचें।',
      'feedbackComplete': 'मिशन पूरा हुआ!',
      'wholeSide': 'पूरी भुजा (a)',
      'stripWidth': 'स्ट्रिप चौड़ाई (b)',
      'enterLab': 'लैब में प्रवेश करें',
    },
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initPieces();
  }

  void _initPieces() {
    _pieces = {
      'topStrip': PieceData(
        id: 'topStrip',
        removeTarget: const Offset(-200, -300),
        animController:
            AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 600),
            )..addListener(
              () => setState(() {
                _pieces['topStrip']!.removeProgress =
                    _pieces['topStrip']!.animController!.value;
              }),
            ),
      ),
      'sideStrip': PieceData(
        id: 'sideStrip',
        removeTarget: const Offset(300, 200),
        animController:
            AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 600),
            )..addListener(
              () => setState(() {
                _pieces['sideStrip']!.removeProgress =
                    _pieces['sideStrip']!.animController!.value;
              }),
            ),
      ),
      'corner': PieceData(id: 'corner'),
    };
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    for (var piece in _pieces.values) {
      piece.animController?.dispose();
    }
    _inpA.dispose();
    _inpB.dispose();
    _inpA2.dispose();
    _inp2AB.dispose();
    _inpB2.dispose();
    _inpAns.dispose();

    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  // --- Audio Methods ---
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class9/tap.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class9/page_open.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class9/dropdown.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class9/error_tone.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class9/shutter.mp3',
      ),
    );
  }

  void _showToast(String msg, {bool isError = false}) {
    setState(() {
      _toastMessage = msg;
      _toastColor = isError ? Colors.redAccent : Colors.green;
      _toastVisible = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _toastVisible = false);
      }
    });
  }

  void _resetLab() {
    playClick();
    setState(() {
      _curtainOpen = false;
      _scenario = 0;
      _step = 0;
      _a = 6;
      _b = 2;
      _pan = Offset.zero;
      _scale = 1.0;
      _baseScale = 1.0;
      for (var piece in _pieces.values) {
        piece.reset();
      }
      _selectedLabel = null;
      _idP1 = '';
      _idP2 = '';
      _idP3 = '';
      _inpA.clear();
      _inpB.clear();
      _inpA2.clear();
      _inp2AB.clear();
      _inpB2.clear();
      _inpAns.clear();
    });
  }

  void _changeVar(String v, int amt) {
    playClick();
    setState(() {
      if (v == 'a') {
        _a = (_a + amt).clamp(3, 10);
        if (_a <= _b) _b = _a - 1;
      } else {
        _b = (_b + amt).clamp(1, _a - 1);
      }
    });
  }

  void _loadScenario(int index) {
    playDropdown();
    setState(() {
      _scenario = index;
      _step = 0;
      for (var piece in _pieces.values) {
        piece.reset();
      }
      _pan = Offset.zero;
      _scale = 1.0;
      _baseScale = 1.0;
    });
  }

  void _validate() {
    final dict = _dict[_lang]!;

    if (_scenario == 0) {
      if (_step == 0) {
        if (_pieces['corner']?.label == '(a-b)²' &&
            _pieces['topStrip']?.label == 'ab' &&
            _pieces['sideStrip']?.label == 'b(a-b)') {
          playPageOpen();
          _showToast(dict['feedbackCorrect']);
          setState(() => _step++);
        } else {
          playError();
          _showToast(dict['feedbackWrong'], isError: true);
          setState(() {
            _pieces['corner']?.label = null;
            _pieces['topStrip']?.label = null;
            _pieces['sideStrip']?.label = null;
          });
        }
      } else if (_step == 1) {
        if (_pieces['topStrip']!.isRemoved &&
            _pieces['sideStrip']!.isRemoved &&
            !_pieces['corner']!.isRemoved) {
          playPageOpen();
          _showToast(dict['feedbackCorrect']);
          setState(() => _step++);
        } else {
          playError();
          _showToast("Remove the two strips first.", isError: true);
        }
      } else if (_step == 2) {
        if (_idP1 == 'a2' && _idP2 == '2ab' && _idP3 == 'b2') {
          playPageOpen();
          _showToast(dict['feedbackComplete']);
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) _loadScenario(1);
          });
        } else {
          playError();
          _showToast(dict['feedbackWrong'], isError: true);
        }
      }
    } else {
      if (_step == 0) {
        if (_inpA.text == '30' && _inpB.text == '1') {
          playPageOpen();
          _showToast(dict['feedbackCorrect']);
          setState(() => _step++);
        } else {
          playError();
          _showToast(dict['feedbackWrong'], isError: true);
        }
      } else if (_step == 1) {
        if (_inpA2.text == '900' &&
            _inp2AB.text == '60' &&
            _inpB2.text == '1') {
          playPageOpen();
          _showToast(dict['feedbackCorrect']);
          setState(() => _step++);
        } else {
          playError();
          _showToast(dict['feedbackWrong'], isError: true);
        }
      } else if (_step == 2) {
        if (_inpAns.text == '841') {
          playPageOpen();
          _showToast(dict['feedbackComplete']);
        } else {
          playError();
          _showToast(dict['feedbackWrong'], isError: true);
        }
      }
    }
  }

  void _handleTapLogic(Offset globalPosition) {
    if (_scenario != 0 || _step > 1) return;

    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localFocalPoint = renderBox.globalToLocal(globalPosition);

    final Size canvasSize = renderBox.size;
    final double unit = 40.0;

    // World coordinates origin calculation matches SquarePainter
    final double totalPixelSize = _a * unit;
    final Offset worldOrigin = Offset(
      canvasSize.width / 2 - totalPixelSize / 2,
      canvasSize.height / 2 - totalPixelSize / 2,
    );

    // Reversing the transform: point = (local - pan) / scale - origin
    final Offset worldPoint = (localFocalPoint - _pan) / _scale - worldOrigin;

    // Define Bounds
    final Rect topBounds = Rect.fromLTWH(0, 0, _a * unit, _b * unit);
    final Rect sideBounds = Rect.fromLTWH(
      (_a - _b) * unit,
      _b * unit,
      _b * unit,
      (_a - _b) * unit,
    );
    final Rect cornerBounds = Rect.fromLTWH(
      0,
      _b * unit,
      (_a - _b) * unit,
      (_a - _b) * unit,
    );

    String? tappedId;
    if (topBounds.contains(worldPoint) && !_pieces['topStrip']!.isRemoved) {
      tappedId = 'topStrip';
    } else if (sideBounds.contains(worldPoint) &&
        !_pieces['sideStrip']!.isRemoved) {
      tappedId = 'sideStrip';
    } else if (cornerBounds.contains(worldPoint) &&
        !_pieces['corner']!.isRemoved) {
      tappedId = 'corner';
    }

    if (tappedId != null) {
      if (_step == 0) {
        if (_selectedLabel != null) {
          playClick();
          setState(() {
            _pieces[tappedId!]!.label = _selectedLabel;
            _selectedLabel = null;
          });
        }
      } else if (_step == 1) {
        if (tappedId == 'topStrip' || tappedId == 'sideStrip') {
          playClick();
          setState(() {
            _pieces[tappedId!]!.isRemoved = true;
            _pieces[tappedId]!.animController!.forward(from: 0.0);
          });
        } else {
          playError();
          _showToast("Cannot remove this piece.", isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dict = _dict[_lang]!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildCanvasArea(dict),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: _buildSidebar(dict),
            ),

            // Sidebar Right Border Line & Drag Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth - 12 : -12,
              top: 0,
              bottom: 0,
              width: 12,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (!_isSidebarOpen) return;
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    if (_sidebarWidth < 300) _sidebarWidth = 300;
                    if (_sidebarWidth >
                        MediaQuery.of(context).size.width - 200) {
                      _sidebarWidth = MediaQuery.of(context).size.width - 200;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Menu Toggle (Fixed at top-left)
            Positioned(
              left: 16,
              top: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    playClick();
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      _isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Toast Notification
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              top: _toastVisible ? 32 : -100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _toastColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _toastColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    _toastMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Curtain Screen
            if (!_curtainOpen)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAB308).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEAB308)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.dashboard,
                              color: Color(0xFFEAB308),
                              size: 56,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Minus Matters: The (a−b)² Removal Square',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dict['subtitle'],
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () {
                          curtainScreen();
                          setState(() => _curtainOpen = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 10,
                        ),
                        child: Text(
                          dict['enterLab'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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

  Widget _buildCanvasArea(Map<String, dynamic> dict) {
    return Stack(
      children: [
        // Grid & Painter
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0F172A),
            child: GestureDetector(
              onScaleStart: (details) {
                _baseScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _pan += details.focalPointDelta;
                  // Correct scaling factor multiplication
                  _scale = (_baseScale * details.scale).clamp(0.5, 3.0);
                });
              },
              onTapUp: (details) {
                _handleTapLogic(details.globalPosition);
              },
              child: ClipRect(
                child: CustomPaint(
                  key: _canvasKey,
                  painter: SquarePainter(
                    a: _a.toDouble(),
                    b: _b.toDouble(),
                    pan: _pan,
                    scale: _scale,
                    pieces: _pieces,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),

        // Bottom HUD
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHUDControl(
                    dict['wholeSide'],
                    _a,
                    () => _changeVar('a', -1),
                    () => _changeVar('a', 1),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildHUDControl(
                    dict['stripWidth'],
                    _b,
                    () => _changeVar('b', -1),
                    () => _changeVar('b', 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHUDControl(
    String label,
    int value,
    VoidCallback onMinus,
    VoidCallback onPlus,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove, size: 20, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFEAB308),
                ),
              ),
            ),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar(Map<String, dynamic> dict) {
    return Container(
      color: const Color(0xFF1E293B),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 64,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.dashboard,
                        color: Color(0xFFEAB308),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dict['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Text(
                      dict['subtitle'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _buildLangBtn('EN', 'en'),
                              _buildLangBtn('HI', 'hi'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white70,
                          ),
                          onPressed: _resetLab,
                          tooltip: 'Reset',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scenario Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              dict['scenarios'][0],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              dict['scenarios'][1],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) _loadScenario(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mission Objective
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEAB308).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MISSION OBJECTIVE',
                          style: TextStyle(
                            color: Color(0xFFEAB308),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scenario == 0 ? dict['mission'] : dict['mission2'],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Steps
                  const Text(
                    'PROCEDURAL STEPS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildSteps(dict),

                  const SizedBox(height: 24),

                  // Interaction Panel
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: _buildInteractionPanel(dict),
                  ),
                ],
              ),
            ),

            // Validate Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: ElevatedButton(
                onPressed: _validate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  dict['btnValidate'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: const Text(
                '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white54,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangBtn(String title, String langVal) {
    bool isSelected = _lang == langVal;
    return GestureDetector(
      onTap: () {
        playClick();
        setState(() => _lang = langVal);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAB308) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSteps(Map<String, dynamic> dict) {
    List<dynamic> stepData = _scenario == 0 ? dict['steps_0'] : dict['steps_1'];
    return List.generate(stepData.length, (index) {
      bool isActive = index == _step;
      bool isDone = index < _step;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFEAB308).withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFFEAB308).withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFEAB308)
                    : (isDone ? Colors.green : Colors.white24),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? const Color(0xFF0F172A)
                              : Colors.white70,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stepData[index][0],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      stepData[index][1],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInteractionPanel(Map<String, dynamic> dict) {
    if (_scenario == 0) {
      if (_step == 0) {
        List<String> labels = List<String>.from(dict['labels']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Labels:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: labels.map((lbl) {
                bool isPlaced = _pieces.values.any((p) => p.label == lbl);
                bool isSelected = _selectedLabel == lbl;
                if (isPlaced) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    playClick();
                    setState(() => _selectedLabel = lbl);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEAB308)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEAB308)
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      lbl,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      } else if (_step == 1) {
        return const Text(
          'Click on the 3D strips on the canvas to remove them.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identity Assembly:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                children: [
                  const Text(
                    '(a-b)² = ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAB308),
                    ),
                  ),
                  _buildDropdown(_idP1, ['?', 'a2', 'b2'], (val) {
                    playDropdown();
                    setState(() => _idP1 = val!);
                  }),
                  const Text(
                    ' - ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  _buildDropdown(_idP2, ['?', '2ab', 'ab'], (val) {
                    playDropdown();
                    setState(() => _idP2 = val!);
                  }),
                  const Text(
                    ' + ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  _buildDropdown(_idP3, ['?', 'b2', 'a2'], (val) {
                    playDropdown();
                    setState(() => _idP3 = val!);
                  }),
                ],
              ),
            ),
          ],
        );
      }
    } else {
      if (_step == 0) {
        return Row(
          children: [
            Expanded(child: _buildInputRow('a =', _inpA, '30')),
            const SizedBox(width: 16),
            Expanded(child: _buildInputRow('b =', _inpB, '1')),
          ],
        );
      } else if (_step == 1) {
        return Column(
          children: [
            _buildInputRowWithHint('a² =', '(30×30)', _inpA2),
            const SizedBox(height: 8),
            _buildInputRowWithHint('2ab =', '(2×30×1)', _inp2AB),
            const SizedBox(height: 8),
            _buildInputRowWithHint('b² =', '(1×1)', _inpB2),
          ],
        );
      } else {
        return Column(
          children: [
            const Text(
              '29² = 900 - 60 + 1',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '= ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEAB308),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _inpAns,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAB308),
                    ),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAB308)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAB308)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? '?' : value,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl, String hint) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRowWithHint(
    String label,
    String hint,
    TextEditingController ctrl,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(hint, style: const TextStyle(color: Colors.white54)),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SquarePainter extends CustomPainter {
  final double a;
  final double b;
  final Offset pan;
  final double scale;
  final Map<String, PieceData> pieces;

  SquarePainter({
    required this.a,
    required this.b,
    required this.pan,
    required this.scale,
    required this.pieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw background grid
    _drawGrid(canvas, size);

    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    final double unit = 40.0;
    final double totalSize = a * unit;

    // Center the square
    canvas.translate(
      size.width / 2 - totalSize / 2,
      size.height / 2 - totalSize / 2,
    );

    // Bounding Boxes
    final Rect topRect = Rect.fromLTWH(0, 0, a * unit, b * unit);
    final Rect sideRect = Rect.fromLTWH(
      (a - b) * unit,
      b * unit,
      b * unit,
      (a - b) * unit,
    );
    final Rect cornerRect = Rect.fromLTWH(
      0,
      b * unit,
      (a - b) * unit,
      (a - b) * unit,
    );

    // Draw Pieces
    _drawPiece(
      canvas,
      pieces['corner']!,
      cornerRect,
      const Color(0xFF3B82F6),
    ); // Blue
    _drawPiece(
      canvas,
      pieces['topStrip']!,
      topRect,
      const Color(0xFFF59E0B),
    ); // Amber
    _drawPiece(
      canvas,
      pieces['sideStrip']!,
      sideRect,
      const Color(0xFFF97316),
    ); // Orange

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  void _drawPiece(Canvas canvas, PieceData piece, Rect baseRect, Color color) {
    if (piece.isRemoved && piece.removeProgress >= 1.0) return;

    canvas.save();

    // Animate removal
    if (piece.removeProgress > 0) {
      final Offset offset = piece.removeTarget * piece.removeProgress;
      canvas.translate(offset.dx, offset.dy);

      // Add slight rotation and scale down while flying away
      canvas.translate(baseRect.center.dx, baseRect.center.dy);
      canvas.rotate(piece.removeProgress * pi / 4);
      canvas.scale(1.0 - (piece.removeProgress * 0.5));
      canvas.translate(-baseRect.center.dx, -baseRect.center.dy);
    }

    final rRect = RRect.fromRectAndRadius(baseRect, const Radius.circular(8));

    // Shadow / 3D depth layer
    canvas.save();
    canvas.translate(6, 6);
    canvas.drawRRect(rRect, Paint()..color = Colors.black45);
    canvas.drawRRect(rRect, Paint()..color = color.withValues(alpha: 0.4));
    canvas.restore();

    // Main surface
    canvas.drawRRect(rRect, Paint()..color = color);

    // Highlight border for pseudo-3D
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw Label if assigned
    if (piece.label != null) {
      final textStyle = TextStyle(
        color: piece.id == 'corner' ? const Color(0xFFEAB308) : Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
        ],
      );
      final textSpan = TextSpan(text: piece.label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = Offset(
        baseRect.center.dx - textPainter.width / 2,
        baseRect.center.dy - textPainter.height / 2,
      );

      // Background pill for text
      final pillRect = Rect.fromCenter(
        center: baseRect.center,
        width: textPainter.width + 16,
        height: textPainter.height + 8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(16)),
        Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.8),
      );

      textPainter.paint(canvas, offset);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SquarePainter oldDelegate) {
    return true; // Always repaint to ensure state updates (like labels) render immediately
  }
}
