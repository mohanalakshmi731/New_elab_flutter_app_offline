// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const RoyalTilerApp());
}

// ==========================================
// AUDIO CONFIGURATION
// ==========================================
// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
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

// ==========================================
// 1. DATA MODELS (Lightweight structs)
// ==========================================

class MathStep {
  final int id, a, b, q, r;
  MathStep(this.id, this.a, this.b, this.q, this.r);
}

class PlacedTile {
  final double x, y, size;
  final Color color;
  double scale = 0.0;
  PlacedTile(this.x, this.y, this.size, this.color);
}

class AppTheme {
  final Color bg, panel, text, muted, accent, primary, floor;
  AppTheme({
    required this.bg,
    required this.panel,
    required this.text,
    required this.muted,
    required this.accent,
    required this.primary,
    required this.floor,
  });
}

// ==========================================
// 2. SINGLE MAIN APPLICATION CLASS
// ==========================================

class RoyalTilerApp extends StatefulWidget {
  const RoyalTilerApp({super.key});

  @override
  State<RoyalTilerApp> createState() => _RoyalTilerAppState();
}

class _RoyalTilerAppState extends State<RoyalTilerApp>
    with TickerProviderStateMixin {
  // --- STATE VARIABLES ---
  bool showShutter = true;
  String currentLang = 'en';
  String currentThemeName = 'royal_dark';
  bool isPanelOpen = true; // Controls the 30% side panel

  int origW = 20, origH = 8;
  int currW = 20, currH = 8;
  int currX = 0, currY = 0;
  int colorIdx = 0;
  bool isGameActive = false;
  bool isFinished = false;

  List<MathStep> mathSteps = [];
  int currentStepIdx = 0;
  int tilesPlacedInStep = 0;
  List<PlacedTile> placedTiles = [];

  final List<Color> tileColors = [
    const Color(0xFFF59E0B),
    const Color(0xFF3B82F6),
    const Color(0xFFEC4899),
    const Color(0xFF10B981),
    const Color(0xFF8B5CF6),
  ];

  Map<String, AppTheme> themes = {
    'royal_dark': AppTheme(
      bg: const Color(0xFF0F172A),
      panel: const Color(0xFF1E293B),
      text: const Color(0xFFF8FAFC),
      muted: const Color(0xFF94A3B8),
      accent: const Color(0xFFF59E0B),
      primary: const Color(0xFF3B82F6),
      floor: const Color(0xFF020617),
    ),
  };

  AppTheme get theme => themes[currentThemeName]!;
  String t(String key) => I18N[currentLang]?[key] ?? key;

  // --- CONTROLLERS ---
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  late AnimationController _animCtrl;
  final TransformationController _transformationController =
      TransformationController();
  final TextEditingController wCtrl = TextEditingController(text: "20");
  final TextEditingController hCtrl = TextEditingController(text: "8");
  final ScrollController _hudScrollCtrl = ScrollController();
  final ScrollController _sidebarScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0,
      end: -20,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _animCtrl.dispose();
    _transformationController.dispose();
    wCtrl.dispose();
    hCtrl.dispose();
    _hudScrollCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // --- LOGIC METHODS ---
  void setLang(String lang) {
    _playClick();
    setState(() => currentLang = lang);
  }

  void togglePanel() {
    _playClick();
    setState(() => isPanelOpen = !isPanelOpen);
  }

  void startGame(int w, int h) {
    if (w <= 0 || h <= 0) {
      _playError();
      return;
    }
    _playClick();
    setState(() {
      origW = w;
      origH = h;
      currW = w;
      currH = h;
      currX = 0;
      currY = 0;
      colorIdx = 0;
      placedTiles.clear();
      isGameActive = true;
      isFinished = false;

      mathSteps.clear();
      int a = math.max(w, h);
      int b = math.min(w, h);
      int id = 1;
      while (b > 0) {
        int q = a ~/ b;
        int r = a % b;
        mathSteps.add(MathStep(id++, a, b, q, r));
        a = b;
        b = r;
      }
      currentStepIdx = 0;
      tilesPlacedInStep = 0;
    });
    _transformationController.value = Matrix4.identity();
  }

  void placeNextTile() {
    if (!isGameActive || isFinished || currW == 0 || currH == 0) return;
    if (currentStepIdx >= mathSteps.length) return;

    _playClick();
    setState(() {
      MathStep step = mathSteps[currentStepIdx];
      int size = math.min(currW, currH);

      for (var t in placedTiles) {
        t.scale = 1.0;
      }

      placedTiles.add(
        PlacedTile(
          currX.toDouble(),
          currY.toDouble(),
          size.toDouble(),
          tileColors[colorIdx % tileColors.length],
        ),
      );

      if (currW >= currH) {
        currX += size;
        currW -= size;
      } else {
        currY += size;
        currH -= size;
      }

      tilesPlacedInStep++;
      if (tilesPlacedInStep >= step.q) {
        currentStepIdx++;
        tilesPlacedInStep = 0;
        colorIdx++;
      }

      if (currW == 0 || currH == 0) {
        isFinished = true;
        isGameActive = false;
        _playSuccess();
      }
    });

    if (placedTiles.isNotEmpty) {
      placedTiles.last.scale = 0.01;
      _animCtrl.forward(from: 0.0);
    }
  }

  void resetLab() {
    _playClick();
    setState(() {
      isGameActive = false;
      isFinished = false;
      placedTiles.clear();
      mathSteps.clear();
      currW = origW;
      currH = origH;
      isPanelOpen = true; // Auto-open panel on reset
    });
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: MaterialApp(
        title: 'Royal Tiler',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: theme.bg, useMaterial3: true),
        home: showShutter ? _buildShutterScreen() : _buildDashboardScreen(),
      ),
    );
  }

  // --- SHUTTER SCREEN ---
  Widget _buildShutterScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _bounceAnim.value),
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 100,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t('app_title').toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t('tagline').toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  _playShutter();
                  setState(() => showShutter = false);
                },
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                label: Text(
                  t('init_btn').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DASHBOARD SCREEN ---
  Widget _buildDashboardScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate 30% of the screen width, clamping to a minimum 320 for usability
    final double targetPanelWidth = math.max(320.0, screenWidth * 0.3);

    return Scaffold(
      body: Stack(
        children: [
          // Base Layer: Full-screen Interactive Canvas Area
          Positioned.fill(
            child: Container(color: theme.bg, child: _buildCanvasArea()),
          ),

          // Overlay Side Panel (Animated Slide In/Out) - ON LEFT
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: isPanelOpen ? 0 : -targetPanelWidth,
            width: targetPanelWidth,
            child: Container(
              decoration: BoxDecoration(
                color: theme.panel.withOpacity(0.95),
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                boxShadow: [
                  if (isPanelOpen)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRect(child: _buildSidePanelContent()),
            ),
          ),

          // Celebration Overlay
          if (isFinished)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t('msg_gcd'),
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${t('gcd_val')} ${mathSteps.isNotEmpty ? mathSteps.last.b : math.min(origW, origH)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: resetLab,
                        icon: const Icon(Icons.refresh),
                        label: Text(t('btn_restart')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // FLOATING MISSION CARD
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            top: 80,
            left: (!isPanelOpen && !isFinished) ? 20 : -400,
            child: _buildFloatingMissionCard(),
          ),

          // Floating Action Buttons (Top Left)
          Positioned(
            top: 24,
            left: 24,
            child: _buildFloatingButton(
              icon: isPanelOpen ? Icons.menu_open : Icons.menu,
              tooltip: t('tooltip_toggle'),
              onTap: togglePanel,
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGET BUILDERS ---

  Widget _buildStepDescription() {
    String text = '';
    if (!isGameActive && !isFinished) {
      text = t('hint_setup');
    } else if (isGameActive) {
      text = t('hint_place');
    } else if (isFinished) {
      text = t('hint_done');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: theme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.text.withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
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
        color: const Color(0xFF020617),
        border: Border(top: BorderSide(color: theme.accent.withOpacity(0.3))),
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

  Widget _buildFloatingMissionCard() {
    return Container(
      width: 280,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 120,
      ),
      decoration: BoxDecoration(
        color: theme.panel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.assignment, color: theme.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  t('mission_title').toUpperCase(),
                  style: TextStyle(
                    color: theme.text,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
              thumbColor: theme.accent.withOpacity(0.8),
              radius: const Radius.circular(4),
              thickness: 4,
              child: SingleChildScrollView(
                controller: _hudScrollCtrl,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepDescription(),
                    isGameActive
                        ? _buildFloatingRoadmapContent()
                        : _buildSetupContent(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(MathStep step, bool isDone, bool isActive) {
    String desc = t('step_desc')
        .replaceAll('{a}', step.a.toString())
        .replaceAll('{b}', step.b.toString())
        .replaceAll('{q}', step.q.toString())
        .replaceAll('{s}', step.q > 1 ? 's' : '');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? theme.accent.withOpacity(0.15)
            : (isDone
                  ? Colors.green.withOpacity(0.05)
                  : Colors.black.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? theme.accent
              : (isDone ? Colors.green.withOpacity(0.3) : Colors.transparent),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${t('step_label')} ${step.id}",
                style: TextStyle(
                  color: isActive ? theme.accent : theme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isDone)
                const Icon(Icons.check_circle, color: Colors.green, size: 18)
              else if (isActive)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: "${step.a}",
                  style: TextStyle(color: theme.muted),
                ),
                TextSpan(
                  text: " = ",
                  style: TextStyle(color: theme.text),
                ),
                TextSpan(
                  text: "${step.b}",
                  style: TextStyle(color: theme.primary),
                ),
                TextSpan(
                  text: "(${step.q}) + ",
                  style: TextStyle(color: theme.text),
                ),
                TextSpan(
                  text: "${step.r}",
                  style: const TextStyle(color: Colors.pinkAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(color: theme.muted, fontSize: 13, height: 1.4),
          ),
          if (isActive && step.q > 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('progress_label').toUpperCase(),
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$tilesPlacedInStep / ${step.q}",
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: tilesPlacedInStep / step.q,
                backgroundColor: Colors.black.withOpacity(0.3),
                color: theme.accent,
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingRoadmapContent() {
    if (mathSteps.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: theme.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  t('roadmap_title').toUpperCase(),
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${math.min(currentStepIdx + 1, mathSteps.length)}/${mathSteps.length}",
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mathSteps.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, i) {
            return _buildStepItem(
              mathSteps[i],
              i < currentStepIdx,
              i == currentStepIdx,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.panel.withOpacity(0.9),
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: theme.text, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanelContent() {
    return CustomScrollView(
      controller: _sidebarScrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 80,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section inside Side Panel
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.accent, Colors.orange.shade700],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('header_title'),
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t('header_subtitle'),
                            style: TextStyle(
                              color: theme.muted,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Toggles and Actions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLanguageToggle(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _playClick();
                            setState(() {
                              showShutter = true;
                              resetLab();
                            });
                          },
                          tooltip: t('btn_restart'),
                          icon: Icon(
                            Icons.power_settings_new,
                            color: Colors.red.shade400,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status & Progress Indicator
                _buildStatusCard(),
                const SizedBox(height: 16),

                // Hint / Action Card
                _buildStepDescription(),

                // Dynamic Content: Setup Configuration OR Roadmap Progress
                if (!isGameActive) _buildSetupPanel() else _buildRoadmapPanel(),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildSidebarFooter()],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['en', 'hi'].map((lang) {
          bool isActive = currentLang == lang;
          return GestureDetector(
            onTap: () => setLang(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? theme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lang.toUpperCase(),
                style: TextStyle(
                  color: isActive ? Colors.white : theme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('lab_status_header'),
            style: TextStyle(
              color: theme.muted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currW x $currH",
                style: TextStyle(
                  color: theme.text,
                  fontSize: 36,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isGameActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isGameActive ? t('status_active') : t('status_ready'),
                  style: TextStyle(
                    color: isGameActive ? Colors.green : Colors.blueAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Refactored to separate the setup functionality core from its side-panel styling
  Widget _buildSetupPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.bg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: _buildSetupContent(),
    );
  }

  // Pure Setup UI Content that is reused in the floating card and sidebar panel
  Widget _buildSetupContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.tune, color: theme.text, size: 18),
            const SizedBox(width: 8),
            Text(
              t('setup_algo').toUpperCase(),
              style: TextStyle(
                color: theme.text,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildInput(t('width_label'), wCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildInput(t('height_label'), hCtrl)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              int w = int.tryParse(wCtrl.text) ?? 20;
              int h = int.tryParse(hCtrl.text) ?? 8;
              startGame(w, h);
              // Auto-collapse the panel once setup is done to show the mission card
              setState(() => isPanelOpen = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              t('btn_generate').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapPanel() {
    return Container(
      decoration: BoxDecoration(
        color: theme.bg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('roadmap_title').toUpperCase(),
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${math.min(currentStepIdx + 1, mathSteps.length)}/${mathSteps.length}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mathSteps.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, i) {
              return _buildStepItem(
                mathSteps[i],
                i < currentStepIdx,
                i == currentStepIdx,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.text,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasArea() {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 5.0,
      panEnabled: true,
      scaleEnabled: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: placeNextTile,
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, child) {
            if (placedTiles.isNotEmpty) {
              if (_animCtrl.isAnimating) {
                double t = _animCtrl.value;
                double scale =
                    1 + 1.7 * math.pow(t - 1, 3) + 0.7 * math.pow(t - 1, 2);
                placedTiles.last.scale = math.max(0.0, scale.clamp(0.0, 1.2));
              } else if (_animCtrl.isCompleted) {
                placedTiles.last.scale = 1.0;
              }
            }

            return CustomPaint(
              painter: Pseudo3DPainter(
                theme: theme,
                origW: origW,
                origH: origH,
                placedTiles: placedTiles,
                isGameActive: isGameActive,
                currW: currW,
                currH: currH,
                currX: currX,
                currY: currY,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// 4. CUSTOM PAINTER CLASS
// ==========================================

class Pseudo3DPainter extends CustomPainter {
  final AppTheme theme;
  final int origW, origH;
  final int currW, currH, currX, currY;
  final bool isGameActive;
  final List<PlacedTile> placedTiles;

  Pseudo3DPainter({
    required this.theme,
    required this.origW,
    required this.origH,
    required this.currW,
    required this.currH,
    required this.currX,
    required this.currY,
    required this.isGameActive,
    required this.placedTiles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double cellSize = 40.0;
    double ext = 2000.0;
    for (double i = -ext; i < size.width + ext; i += cellSize) {
      canvas.drawLine(Offset(i, -ext), Offset(i, size.height + ext), gridPaint);
    }
    for (double i = -ext; i < size.height + ext; i += cellSize) {
      canvas.drawLine(Offset(-ext, i), Offset(size.width + ext, i), gridPaint);
    }

    if (!isGameActive && origW == 20 && origH == 8 && placedTiles.isEmpty) {
      return;
    }

    double scale = math.min(
      size.width * 0.8 / origW,
      size.height * 0.8 / origH,
    );

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-origW / 2, -origH / 2);

    if (isGameActive) {
      final baseRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, origW.toDouble(), origH.toDouble()),
        const Radius.circular(0.2),
      );
      canvas.drawRRect(baseRect, Paint()..color = theme.muted.withOpacity(0.2));
      canvas.drawRRect(
        baseRect,
        Paint()
          ..color = theme.muted.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / scale,
      );

      if (currW > 0 && currH > 0) {
        final remRect = Rect.fromLTWH(
          currX.toDouble(),
          currY.toDouble(),
          currW.toDouble(),
          currH.toDouble(),
        );
        canvas.drawRect(
          remRect,
          Paint()..color = Colors.white.withOpacity(0.1),
        );
        canvas.drawRect(
          remRect,
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4 / scale,
        );
      }
    }

    for (var tile in placedTiles) {
      double tSize = tile.size * tile.scale;
      double cX = tile.x + (tile.size - tSize) / 2;
      double cY = tile.y + (tile.size - tSize) / 2;

      canvas.drawRect(
        Rect.fromLTWH(cX + 0.2, cY + 0.2, tSize, tSize),
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );

      final rect = Rect.fromLTWH(cX, cY, tSize, tSize);
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tile.color.withOpacity(0.8),
          tile.color,
          tile.color.withOpacity(0.6),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

      canvas.drawRect(
        rect.deflate(0.05),
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / scale,
      );

      if (tile.scale > 0.8) {
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: "${tile.size.toInt()}x${tile.size.toInt()}",
            style: TextStyle(
              color: Colors.white,
              fontSize: math.max(1.0, tSize * 0.2),
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(cX + tSize / 2 - tp.width / 2, cY + tSize / 2 - tp.height / 2),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(Pseudo3DPainter oldDelegate) => true;
}

// ==========================================
// 5. LOCALIZATION DATA (I18N)
// ==========================================

const Map<String, Map<String, String>> I18N = {
  'en': {
    'header_title': "The Royal Tiler",
    'header_subtitle': "CLASS 10 • REAL NUMBERS\nEuclid’s Division Algorithm",
    'lab_status_header': "CURRENT TILE",
    'btn_generate': "GENERATE ROADMAP",
    'btn_reset': "RESET LAB",
    'btn_restart': "Restart Activity",
    'hud_equation': "Euclid's Division Lemma",
    'msg_gcd': "GCD FOUND!",
    'hint_setup': "ACTION: Enter Width and Height, then Generate Roadmap.",
    'hint_place': "ACTION: Tap the workspace to place the next tile.",
    'hint_done': "ACTION: GCD Found! Reset the lab to try new dimensions.",
    'mission_title': "CURRENT MISSION",
    'btn_place_tile': "Place Tile",
    'tooltip_roadmap': "Show Roadmap",
    'app_title': "THE ROYAL TILER",
    'tagline': "MASTERING EUCLID'S ALGORITHM",
    'init_btn': "START LAB",
    'gcd_val': "GCD =",
    'roadmap_title': "ALGORITHM ROADMAP",
    'step_label': "Step",
    'progress_label': "PROGRESS",
    'setup_algo': "SETUP ALGORITHM",
    'width_label': "Width (A)",
    'height_label': "Height (B)",
    'status_active': "Active",
    'status_ready': "Ready",
    'tooltip_toggle': "Toggle Panel",
    'step_desc': "Subtract {b}x{b} square ({q} time{s}) from {a}x{b}.",
  },
  'hi': {
    'header_title': "शाही टाइलर (The Royal Tiler)",
    'header_subtitle':
        "कक्षा 10 • वास्तविक संख्याएँ\nयूक्लिड का विभाजन एल्गोरिदम",
    'lab_status_header': "वर्तमान टाइल",
    'btn_generate': "रोडमैप बनाएं",
    'btn_reset': "रीसेट करें",
    'btn_restart': "पुनः आरंभ करें",
    'hud_equation': "यूक्लिड विभाजन प्रमेयिका",
    'msg_gcd': "HCF मिला!",
    'hint_setup': "कार्य: चौड़ाई और ऊंचाई दर्ज करें, फिर रोडमैप बनाएं।",
    'hint_place': "कार्य: अगली टाइल लगाने के लिए स्क्रीन पर टैप करें।",
    'hint_done': "कार्य: HCF मिला! नया आकार आज़माने के लिए रीसेट करें।",
    'mission_title': "वर्तमान मिशन",
    'btn_place_tile': "टाइल लगाएं",
    'tooltip_roadmap': "रोडमैप दिखाएं",
    'app_title': "शाही टाइलर",
    'tagline': "यूक्लिड के एल्गोरिदम में महारत",
    'init_btn': "लैब शुरू करें",
    'gcd_val': "HCF =",
    'roadmap_title': "एल्गोरिदम रोडमैप",
    'step_label': "चरण",
    'progress_label': "प्रगति",
    'setup_algo': "एल्गोरिदम सेटअप",
    'width_label': "चौड़ाई (A)",
    'height_label': "ऊंचाई (B)",
    'status_active': "सक्रिय",
    'status_ready': "तैयार",
    'tooltip_toggle': "पैनल टॉगल करें",
    'step_desc': "{a}x{b} क्षेत्र से {b}x{b} वर्ग को {q} बार घटाएं।",
  },
};
