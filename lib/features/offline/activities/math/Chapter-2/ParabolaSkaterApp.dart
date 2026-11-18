// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- AUDIO CONFIGURATION ---
final AudioPlayer _clickPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);

const String _clickUrl = 'audio/math/click.mp3';
const String _successUrl = 'audio/math/success.mp3';
const String _errorUrl = 'audio/math/error.mp3';
const String _shutterUrl = 'audio/math/shutter.mp3';

void _playAudio(AudioPlayer player, String url) async {
  try {
    await player.stop();
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio play error: $e");
  }
}

void _playClick() => _playAudio(_clickPlayer, _clickUrl);
void _playSuccess() => _playAudio(_successPlayer, _successUrl);
void _playError() => _playAudio(_errorPlayer, _errorUrl);
void _playShutter() => _playAudio(_fxPlayer, _shutterUrl);

// --- DATA MODELS ---
class Track {
  final int id;
  final String eqn;
  final double a;
  final double c;
  final int zeroes;
  final String desc;

  const Track({
    required this.id,
    required this.eqn,
    required this.a,
    required this.c,
    required this.zeroes,
    required this.desc,
  });
}

const List<Track> tracks = [
  Track(
    id: 0,
    eqn: "y = x² - 4",
    a: 1,
    c: -4,
    zeroes: 2,
    desc: "Create a track that cuts the ground twice.",
  ),
  Track(
    id: 1,
    eqn: "y = x²",
    a: 1,
    c: 0,
    zeroes: 1,
    desc: "Create a track that touches the ground once.",
  ),
  Track(
    id: 2,
    eqn: "y = x² + 2",
    a: 1,
    c: 2,
    zeroes: 0,
    desc: "Create a track that floats above the ground.",
  ),
  Track(
    id: 3,
    eqn: "y = -x² + 3",
    a: -1,
    c: 3,
    zeroes: 2,
    desc: "Create an inverted track (a = -1).",
  ),
  Track(
    id: 4,
    eqn: "y = x² - 1",
    a: 1,
    c: -1,
    zeroes: 2,
    desc: "Create a shallow track.",
  ),
  Track(
    id: 5,
    eqn: "y = -x² - 2",
    a: -1,
    c: -2,
    zeroes: 0,
    desc: "Create a track completely underground.",
  ),
];

// --- LOCALIZATION ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE PARABOLA SKATER',
    'tagline': 'GEOMETRICAL MEANING OF ZEROES • CLASS 10',
    'init_btn': 'ENTER SKATE PARK',
    'header_title': 'The Parabola Skater',
    'header_subtitle': 'CLASS 10 • POLYNOMIALS',
    'lbl_objective': 'MISSION OBJECTIVE',
    'msg_objective':
        'Understand the geometrical meaning of the zeroes of a quadratic polynomial by observing where the skater\'s path cuts the X-axis.',
    'lbl_select_track': 'Select Mission',
    'btn_load': 'LOAD TRACK',
    'lbl_mission_goal': 'Mission Goal',
    'txt_target': 'Target',
    'lbl_adjust_track': 'Adjust Vertical Position (c)',
    'btn_skate': 'LAUNCH SKATER',
    'msg_count':
        'How many times did the skater touch/cross the Ground (X-axis)?',
    'msg_success': 'ZEROES IDENTIFIED',
    'btn_next': 'Next Track',
    'btn_restart': 'Exit Park',
    'txt_mission': 'Mission',
    'hint_step1': 'ACTION: Select a track to explore and click Load.',
    'hint_step2': 'ACTION: Adjust the slider (c) to match the target equation.',
    'hint_step3': 'ACTION: Count how many times the skater cuts the X-axis.',
    'hint_step4': 'ACTION: Mission accomplished! Proceed to the next track.',
  },
  'hi': {
    'app_title': 'परवलय स्केटर',
    'tagline': 'शून्यक का ज्यामितीय अर्थ • कक्षा 10',
    'init_btn': 'स्केट पार्क में प्रवेश करें',
    'header_title': 'परवलय स्केटर',
    'header_subtitle': 'कक्षा 10 • बहुपद',
    'lbl_objective': 'मिशन का उद्देश्य',
    'msg_objective':
        'यह देखें कि स्केटर का पथ X-अक्ष को कहाँ काटता है, और द्विघात बहुपद के शून्यकों का ज्यामितीय अर्थ समझें।',
    'lbl_select_track': 'मिशन चुनें',
    'btn_load': 'ट्रैक लोड करें',
    'lbl_mission_goal': 'मिशन लक्ष्य',
    'txt_target': 'लक्ष्य',
    'lbl_adjust_track': 'ऊर्ध्वाधर स्थिति समायोजित करें (c)',
    'btn_skate': 'स्केटर लॉन्च करें',
    'msg_count': 'स्केटर ने कितनी बार जमीन (X-अक्ष) को छुआ/काटा?',
    'msg_success': 'शून्यक पहचाने गए',
    'btn_next': 'अगला ट्रैक',
    'btn_restart': 'पार्क से बाहर निकलें',
    'txt_mission': 'मिशन',
    'hint_step1': 'कार्य: एक्सप्लोर करने के लिए एक ट्रैक चुनें और लोड करें।',
    'hint_step2':
        'कार्य: लक्ष्य समीकरण से मिलान करने के लिए स्लाइडर (c) को समायोजित करें।',
    'hint_step3': 'कार्य: गिनें कि स्केटर कितनी बार X-अक्ष को काटता है।',
    'hint_step4': 'कार्य: मिशन पूरा हुआ! अगले ट्रैक पर आगे बढ़ें।',
  },
};

class ParabolaSkaterApp extends StatefulWidget {
  const ParabolaSkaterApp({super.key});

  @override
  State<ParabolaSkaterApp> createState() => _ParabolaSkaterAppState();
}

class _ParabolaSkaterAppState extends State<ParabolaSkaterApp>
    with SingleTickerProviderStateMixin {
  bool _isStarted = false;
  String _lang = 'en';
  bool _sidebarOpen = true;

  // Track Logic
  int _step = 1; // 1: Select, 2: Adjust, 3: Count, 4: Complete
  Track _currentTrack = tracks[0];
  double _sliderC = 0.0;
  bool _isMatched = false;

  // Animation Logic
  late AnimationController _skaterController;
  double _skaterX = -5.0;
  bool _isAnimating = false;
  bool _showRoots = false;
  bool _showCelebration = false;

  // Pan and Zoom logic
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  double _previousZoom = 1.0;
  Offset _previousPan = Offset.zero;

  // HUD Scroller
  final ScrollController _hudScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _skaterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _skaterController.addListener(() {
      setState(() {
        _skaterX = -5.0 + (_skaterController.value * 10.0); // lerp from -5 to 5
      });
    });
    _skaterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _showRoots = true;
          _step = 3;
        });
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _skaterController.dispose();
    _hudScrollCtrl.dispose();
    super.dispose();
  }

  String t(String key) => i18n[_lang]![key] ?? key;

  void _loadTrack() {
    _playClick();
    setState(() {
      _step = 2;
      _sliderC = 0.0;
      _isMatched = (_sliderC == _currentTrack.c);
      _showRoots = false;
      _skaterX = -5.0;

      // Reset view
      _zoom = 1.0;
      _pan = Offset.zero;
    });
  }

  void _updateSlider(double val) {
    setState(() {
      _sliderC = val;
      // Precision matching due to double rounding
      _isMatched = (_sliderC - _currentTrack.c).abs() < 0.1;
    });
  }

  void _launchSkater() {
    _playClick();
    setState(() {
      _isAnimating = true;
      _showRoots = false;
    });
    _skaterController.forward(from: 0.0);
  }

  void _checkAnswer(int ans) {
    if (ans == _currentTrack.zeroes) {
      _playSuccess();
      setState(() {
        _step = 4;
        _showCelebration = true;
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
        }
      });
    } else {
      _playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect count. Try again!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _reset() {
    _playClick();
    setState(() {
      _step = 1;
      _showRoots = false;
      _showCelebration = false;
      _skaterX = -5.0;
      _sliderC = 0.0;
      _zoom = 1.0;
      _pan = Offset.zero;
      _isMatched = false;
    });
  }

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
            // Base layer: Panel and Canvas
            Row(children: [_buildSidePanel(), _buildCanvasArea()]),

            // Floating Mission Card (Visible when sidebar is closed)
            if (_isStarted)
              Positioned(
                top: 80,
                left: 16,
                child: AnimatedOpacity(
                  opacity: !_sidebarOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: _sidebarOpen,
                    child: _buildFloatingMissionCard(),
                  ),
                ),
              ),

            // top-left Menu Button
            if (_isStarted)
              Positioned(
                top: 16,
                left: 16,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFDB2777),
                  elevation: 8,
                  onPressed: () {
                    _playClick();
                    setState(() => _sidebarOpen = !_sidebarOpen);
                  },
                  child: Icon(
                    _sidebarOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),

            // Celebration Overlay (Z-Index fix: Added to the main stack)
            if (_showCelebration)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFF472B6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "PERFECT RUN!",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo[900]!.withOpacity(0.8),
                                border: Border.all(
                                  color: Colors.greenAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_currentTrack.zeroes} Zeroes Found",
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
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

            // Intro Curtain
            if (!_isStarted) _buildIntroCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetWidth = math.max(320.0, screenWidth * 0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _sidebarOpen ? targetWidth : 0,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withOpacity(0.95),
        border: Border(
          right: BorderSide(color: const Color(0xFFF472B6).withOpacity(0.3)),
        ),
      ),
      child: ClipRect(
        child: OverflowBox(
          minWidth: targetWidth,
          maxWidth: targetWidth,
          alignment: Alignment.topLeft,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 80,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Subtitle
                      Text(
                        t('header_title'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        t('header_subtitle'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF472B6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Controls Block (Language & Restart)
                      Row(
                        children: [
                          ...['en', 'hi'].map((lang) {
                            bool isActive = _lang == lang;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  _playClick();
                                  setState(() => _lang = lang);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFDB2777)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isActive
                                          ? const Color(0xFFDB2777)
                                          : Colors.white54,
                                    ),
                                  ),
                                  child: Text(
                                    lang.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.power_settings_new),
                            color: Colors.red[300],
                            tooltip: t('btn_restart'),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                            ),
                            onPressed: () {
                              _playClick();
                              setState(() {
                                _isStarted = false;
                                _sidebarOpen = true;
                              });
                              _reset();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Explore Interactive Content
                      _buildExploreContent(),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildSidebarFooter()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDescription() {
    String text = '';
    if (_step == 1)
      text = t('hint_step1');
    else if (_step == 2)
      text = t('hint_step2');
    else if (_step == 3)
      text = t('hint_step3');
    else if (_step == 4)
      text = t('hint_step4');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDB2777).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDB2777).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFF472B6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    final double maxW = MediaQuery.of(context).size.width - 32;

    return Container(
      width: math.min(320.0, maxW),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 100,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF472B6).withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Shrink-wrap vertically
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: Color(0xFFF472B6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  t('txt_mission').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Flexible(
            child: RawScrollbar(
              controller: _hudScrollCtrl,
              thumbVisibility: true,
              thumbColor: const Color(0xFFF472B6).withOpacity(0.8),
              radius: const Radius.circular(4),
              thickness: 4,
              child: SingleChildScrollView(
                controller: _hudScrollCtrl,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildStepDescription(), _buildStepContent()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E24),
        border: Border(
          top: BorderSide(color: const Color(0xFFF472B6).withOpacity(0.3)),
        ),
      ),
      child: const Center(
        child: Text(
          '© ZEROSCIENCELAB | Fall in Love with Math and Science',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildExploreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo[900]!.withOpacity(0.8),
                Colors.purple[900]!.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF472B6).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFFF472B6), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    t('lbl_objective'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9A8D4),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFF472B6), width: 2),
                  ),
                ),
                child: Text(
                  t('msg_objective'),
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Session Progress'.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFF9A8D4),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Step $_step/4',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _step / 4.0,
          backgroundColor: Colors.indigo[900],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF472B6)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),

        const SizedBox(height: 24),

        _buildStepDescription(),

        // Dynamic Interactive Zone
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: _buildStepContent(),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return Column(
          children: [
            Text(
              t('lbl_select_track'),
              style: const TextStyle(
                color: Color(0xFFF9A8D4),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.indigo[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Track>(
                  isExpanded: true,
                  value: _currentTrack,
                  dropdownColor: Colors.indigo[900],
                  items: tracks.map((t) {
                    final letter = String.fromCharCode(65 + t.id); // A, B, C...
                    return DropdownMenuItem(
                      value: t,
                      child: Text(
                        "${this.t('txt_mission')} $letter: ${t.eqn.replaceAll("y = ", "")}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    _playClick();
                    if (val != null) setState(() => _currentTrack = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB2777),
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: _loadTrack,
              child: Text(
                t('btn_load'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Text(
              t('lbl_mission_goal').toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${t('txt_target')}: y = ${_currentTrack.eqn.split('=')[1].trim()}",
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFF472B6),
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t('lbl_adjust_track'),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFF472B6),
                inactiveTrackColor: Colors.indigo[800],
                thumbColor: const Color(0xFFDB2777),
              ),
              child: Slider(
                value: _sliderC,
                min: -5,
                max: 5,
                divisions: 20, // Snaps every 0.5
                onChanged: _isAnimating ? null : _updateSlider,
              ),
            ),
            Text(
              "c = ${_sliderC.toStringAsFixed(1)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.skateboarding, color: Colors.white),
              label: Text(
                t('btn_skate'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMatched
                    ? const Color(0xFFDB2777)
                    : Colors.blueGrey[800],
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: _isMatched && !_isAnimating ? _launchSkater : null,
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            Text(
              t('msg_count'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [0, 1, 2].map((ans) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(60, 50),
                  ),
                  onPressed: () => _checkAnswer(ans),
                  child: Text(
                    ans.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
            const SizedBox(height: 8),
            Text(
              t('msg_success'),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB2777),
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: _reset,
              child: Text(
                t('btn_next'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildCanvasArea() {
    return Expanded(
      child: ClipRect(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onScaleStart: (details) {
                    _previousZoom = _zoom;
                    _previousPan = details.focalPoint;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _zoom = (_previousZoom * details.scale).clamp(0.2, 5.0);
                      _pan += details.focalPoint - _previousPan;
                      _previousPan = details.focalPoint;
                    });
                  },
                  child: CustomPaint(
                    painter: GraphPainter(
                      currentTrack: _step > 1 ? _currentTrack : null,
                      cValue: _sliderC,
                      skaterX: _skaterX,
                      isAnimating: _isAnimating,
                      showRoots: _showRoots,
                      isMatched: _isMatched,
                      zoom: _zoom,
                      pan: _pan,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCurtain() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F0E24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.skateboarding, size: 80, color: Color(0xFFF472B6)),
            const SizedBox(height: 16),
            Text(
              t('app_title'),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('tagline'),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFF9A8D4),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                t('init_btn'),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB2777),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
              ),
              onPressed: () {
                _playShutter();
                setState(() => _isStarted = true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- GRAPHICS / DRAWING LOGIC ---
class GraphPainter extends CustomPainter {
  final Track? currentTrack;
  final double cValue;
  final double skaterX;
  final bool isAnimating;
  final bool showRoots;
  final bool isMatched;
  final double zoom;
  final Offset pan;

  GraphPainter({
    required this.currentTrack,
    required this.cValue,
    required this.skaterX,
    required this.isAnimating,
    required this.showRoots,
    required this.isMatched,
    required this.zoom,
    required this.pan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double baseScale = size.height / 14;
    double effectiveScale = baseScale * zoom;

    double centerX = size.width / 2 + pan.dx;
    double centerY = size.height / 2 + pan.dy;

    // Helper to map math coordinates (x,y) to screen offsets based on scale/pan
    Offset toPixel(double x, double y) {
      return Offset(centerX + x * effectiveScale, centerY - y * effectiveScale);
    }

    // 1. Draw Grid
    Paint gridPaint = Paint()
      ..color = const Color(0xFF312E81).withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = -30; i <= 30; i++) {
      double px = centerX + i * effectiveScale;
      canvas.drawLine(Offset(px, -1000), Offset(px, 1000), gridPaint);

      double py = centerY - i * effectiveScale;
      canvas.drawLine(Offset(-1000, py), Offset(1000, py), gridPaint);

      // Draw axis coordinate labels
      if (i != 0) {
        _drawText(
          canvas,
          '$i',
          Offset(px + 4, centerY + 4),
          color: Colors.white38,
          fontSize: 10,
        );
        _drawText(
          canvas,
          '$i',
          Offset(centerX + 4, py + 4),
          color: Colors.white38,
          fontSize: 10,
        );
      }
    }

    // 2. Draw Axes
    Paint axisXPaint = Paint()
      ..color = Colors.red[400]!
      ..strokeWidth = 2;
    Paint axisYPaint = Paint()
      ..color = Colors.blue[400]!
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      axisXPaint,
    );
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      axisYPaint,
    );

    if (currentTrack == null) return;

    double a = currentTrack!.a;

    // 3. Draw Parabola Path
    Path path = Path();
    bool started = false;

    for (double x = -20; x <= 20; x += 0.2) {
      double y = a * x * x + cValue;
      Offset pt = toPixel(x, y);

      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    Paint curvePaint = Paint()
      ..color = isMatched ? const Color(0xFFF472B6) : Colors.white54
      ..strokeWidth = isMatched ? 4 : 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, curvePaint);

    // 3b. Draw Coordinate Points on Parabola
    Paint pointPaint = Paint()..color = Colors.yellowAccent;
    for (int x = -10; x <= 10; x++) {
      double y = a * x * x + cValue;
      Offset pt = toPixel(x.toDouble(), y);
      canvas.drawCircle(pt, 4, pointPaint);
      _drawText(
        canvas,
        '($x, ${y.toInt()})',
        Offset(pt.dx + 6, pt.dy - 16),
        color: Colors.yellowAccent,
        fontSize: 10,
      );
    }

    // 4. Draw Skater
    if (currentTrack != null) {
      double sy = a * skaterX * skaterX + cValue;
      Offset sPt = toPixel(skaterX, sy);

      Color skaterColor = (isAnimating || showRoots)
          ? Colors.greenAccent
          : Colors.pinkAccent;

      // Render the skater icon using TextPainter
      TextPainter skaterPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(Icons.skateboarding.codePoint),
          style: TextStyle(
            color: skaterColor,
            fontSize: 48,
            fontFamily: Icons.skateboarding.fontFamily,
            package: Icons.skateboarding.fontPackage,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      );
      skaterPainter.layout();

      // Adjust offset so the bottom of the skateboard aligns well with the drawn line
      Offset iconOffset = Offset(
        sPt.dx - skaterPainter.width / 2,
        sPt.dy - skaterPainter.height + 10,
      );

      skaterPainter.paint(canvas, iconOffset);
    }

    // 5. Draw Roots
    if (showRoots) {
      double val = -cValue / a;
      if (val > 0) {
        _drawRoot(canvas, math.sqrt(val), effectiveScale, centerX, centerY);
        _drawRoot(canvas, -math.sqrt(val), effectiveScale, centerX, centerY);
      } else if (val == 0) {
        _drawRoot(canvas, 0, effectiveScale, centerX, centerY);
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    Color color = Colors.white,
    double fontSize = 12,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  void _drawRoot(
    Canvas canvas,
    double x,
    double effectiveScale,
    double centerX,
    double centerY,
  ) {
    double px = centerX + x * effectiveScale;
    double py = centerY;

    Paint rootPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(px, py), 12, rootPaint);

    Paint fill = Paint()
      ..color = Colors.greenAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(px, py), 12, fill);

    _drawText(
      canvas,
      "(${x.toStringAsFixed(1)}, 0)",
      Offset(px - 20, py - 30),
      color: Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.cValue != cValue ||
        oldDelegate.skaterX != skaterX ||
        oldDelegate.isAnimating != isAnimating ||
        oldDelegate.showRoots != showRoots ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.currentTrack != currentTrack;
  }
}
