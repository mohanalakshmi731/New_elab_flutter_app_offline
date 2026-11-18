// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui';

// --- GLOBAL AUDIO ENGINE ---
// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

// Local audio assets (assets/audio/class9/)
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer requested
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter opening requested

// Web-safe playback helper
void _playSound(AudioPlayer player, String url) async {
  try {
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio Playback Error: $e");
  }
}
// ---------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PolySorterApp());
}

class PolySorterApp extends StatelessWidget {
  const PolySorterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Poly-Sorter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'monospace', // Using standard monospace for math focus
      ),
      home: const PolySorterScreen(),
    );
  }
}

class PolySorterScreen extends StatefulWidget {
  const PolySorterScreen({Key? key}) : super(key: key);

  @override
  State<PolySorterScreen> createState() => _PolySorterScreenState();
}

class _PolySorterScreenState extends State<PolySorterScreen>
    with SingleTickerProviderStateMixin {
  // Core State
  int currentStep = 0;
  bool isGameInitialized = false;
  bool missionComplete = false;
  String currentLang = 'en';
  
  bool _sidebarOpen = true;
  bool _showShutter = true;
  bool _isStepTransitioning = false;

  // Drag & Drop State
  Map<int, Map<int, String>> filledSlots = {}; // stepId -> {slotIndex -> value}

  // Calc State
  final TextEditingController calcController = TextEditingController();

  late AnimationController _pulseController;

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _pulseController.dispose();
    calcController.dispose();
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    
    super.dispose();
  }

  // Reset Game Logic
  void resetGame({bool hard = false}) {
    setState(() {
      currentStep = 0;
      missionComplete = false;
      filledSlots.clear();
      calcController.clear();
      _isStepTransitioning = false;
      if (hard) {
        _showShutter = true;
      }
    });
  }

  // Advance Step
  void _handleSuccess() {
    HapticFeedback.heavyImpact();

    setState(() {
      _isStepTransitioning = true; // Instantly hide the floating HUD/Sidebar focus
      if (currentStep < labData.length - 1) {
        _playSound(_fxPlayer, _alertUrl); // Target acquired sound
        currentStep++;
        calcController.clear();
      } else {
        _playSound(_successPlayer, _successUrl); // Mission complete sound
        missionComplete = true;
      }
    });

    // Pause for cinematic transition so the user can see the visualization change
    int delayMs = missionComplete ? 3500 : 2500;
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _isStepTransitioning = false; // Reveal HUD for the new step
        });
      }
    });
  }

  // Snackbar Feedback
  void _showFeedback(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarWidth = screenW * 0.38; // Exactly 38% width for the sidebar

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expandable Sidebar Container
                // SingleChildScrollView applied horizontally ensures the width animation doesn't cause overflow issues
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: AppColors.bg.withOpacity(0.95),
                    border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: sidebarWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                        child: _buildSidebarContent(),
                      ),
                    ),
                  ),
                ),

                // Center Activity (Responsive Workspace)
                Expanded(
                  child: _buildVisualizationArea(),
                ),
              ],
            ),

            // Top Left Menu Button (Z-Index Front)
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _playSound(_clickPlayer, _clickUrl);
                      setState(() {
                        _sidebarOpen = !_sidebarOpen;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            // Floating HUD - Top Center
            if (!_sidebarOpen && !_showShutter && !_isStepTransitioning && !missionComplete)
              _buildFloatingHUD(screenW),

            // Mission Success Celebration Overlay (Scrollable & Blurry)
            if (missionComplete && !_showShutter && !_isStepTransitioning) 
              _buildCelebrationOverlay(),

            // Initial Curtain Overlay
            if (_showShutter) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildCurtain() {
    return Container(
      color: AppColors.bg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5 + (_pulseController.value * 0.3)),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Icon(Icons.layers, size: 60, color: Colors.white),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            i18n[currentLang]!['app_title']!.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            i18n[currentLang]!['tagline']!.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 3,
              color: Colors.white54,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              _playSound(_shutterPlayer, _shutterUrl); // Play specifically requested opening sound
              setState(() {
                _showShutter = false;
              });
            },
            icon: const Icon(Icons.play_arrow, color: Colors.black),
            label: Text(
              i18n[currentLang]!['init_btn']!.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spacer for floating top-left menu icon
          const SizedBox(height: 56),

          // Header Text
          Text(
            i18n[currentLang]!['app_title']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            i18n[currentLang]!['header_subtitle']!,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Settings Row (Lang Toggle & Reset)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: ['en', 'hi'].map((lang) {
                    bool isSelected = currentLang == lang;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _playSound(_clickPlayer, _clickUrl);
                        setState(() => currentLang = lang);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          lang.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error.withOpacity(0.6), width: 2.0),
                ),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new, color: AppColors.error),
                  tooltip: 'Reset System',
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _playSound(_clickPlayer, _clickUrl);
                    resetGame(hard: true);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Core Explorer Content
          _buildExploreContent(),

          const SizedBox(height: 32),

          // Footer
          const Center(
            child: Text(
              "© ZEROSCIENCELAB | Fall in Love with Math and Science",
              style: TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreContent() {
    final t = i18n[currentLang]!;
    
    if (missionComplete || _isStepTransitioning) {
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 24),
              Text(
                "VERIFYING INTEGRITY...",
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final stepData = labData[currentStep];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mission Objective
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: const BorderSide(color: AppColors.primary, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['mission_obj_title']!,
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                t['mission_obj_desc']!,
                style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // HUD Progress
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stepData.phase,
                    style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Step ${currentStep + 1}/${labData.length}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (currentStep + 1) / labData.length,
                backgroundColor: Colors.white10,
                color: AppColors.accent,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active Task Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.05),
            border: Border.all(color: AppColors.accent.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                t[stepData.titleKey]!,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t[stepData.instrKey]!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
              _buildInteractionArea(stepData),
            ],
          ),
        ),

        // Debris Field (Only for Drag tasks)
        if (stepData.type == 'drag' && stepData.debris != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t['avail_parts']!.toUpperCase(),
                      style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.touch_app, color: AppColors.accent, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: stepData.debris!.map((item) {
                    return Draggable<String>(
                      data: item,
                      onDragStarted: () {
                        HapticFeedback.selectionClick();
                        _playSound(_clickPlayer, _clickUrl); 
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: _DebrisItem(text: item, isDragging: true),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _DebrisItem(text: item),
                      ),
                      child: _DebrisItem(text: item),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    final t = i18n[currentLang]!;
    final stepData = labData[currentStep];
    
    // Dynamic width expansion for side-by-side layout when debris exists
    double hudWidth = stepData.debris != null && stepData.debris!.isNotEmpty 
        ? math.min(screenW * 0.85, 800.0) 
        : math.min(screenW * 0.45, 450.0);

    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          width: hudWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border(top: const BorderSide(color: AppColors.primary, width: 4)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(stepData.phase, style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(t[stepData.titleKey]!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(t[stepData.instrKey]!, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                
                // Horizontal Stack when debris exist to save height
                if (stepData.type == 'drag' && stepData.debris != null && stepData.debris!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildInteractionArea(stepData),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: _buildDebrisField(stepData.debris!, t),
                      ),
                    ],
                  )
                else
                  _buildInteractionArea(stepData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebrisField(List<String> debris, Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(t['avail_parts']!.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.touch_app, color: AppColors.primary, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: debris.toSet().map((term) {
              return Draggable<String>(
                data: term,
                feedback: Material(
                  color: Colors.transparent,
                  child: _DebrisItem(text: term, isDragging: true),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: _DebrisItem(text: term)),
                onDragStarted: () {
                  HapticFeedback.selectionClick();
                  _playSound(_clickPlayer, _clickUrl);
                },
                child: _DebrisItem(text: term),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionArea(LabStep stepData) {
    if (stepData.type == 'drag') {
      return Wrap(
        spacing: 8,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(stepData.template!.length, (index) {
          final tmpl = stepData.template![index];
          if (tmpl['type'] == 'static') {
            return Text(
              tmpl['label'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          } else {
            // Drop Zone
            String expected = tmpl['answer'];
            String? filledValue = filledSlots[currentStep]?[index];

            return DragTarget<String>(
              onWillAccept: (data) => filledValue == null,
              onAccept: (data) {
                if (data == expected) {
                  HapticFeedback.selectionClick();
                  _playSound(_clickPlayer, _clickUrl);
                  
                  setState(() {
                    filledSlots.putIfAbsent(currentStep, () => {})[index] = data;
                  });
                  
                  int requiredSlots = stepData.template!.where((t) => t['type'] == 'slot').length;
                  if (filledSlots[currentStep]?.length == requiredSlots) {
                    Future.delayed(const Duration(milliseconds: 400), () {
                      _handleSuccess();
                    });
                  }
                } else {
                  HapticFeedback.vibrate();
                  _playSound(_errorPlayer, _errorUrl); // Specifically requested error buzzer
                  _showFeedback(currentLang == 'en' ? "Incorrect Cargo" : "गलत कार्गो", isSuccess: false);
                }
              },
              builder: (context, candidateData, rejectedData) {
                bool isHovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: filledValue != null
                        ? AppColors.success.withOpacity(0.2)
                        : isHovering
                        ? AppColors.accent.withOpacity(0.2)
                        : const Color(0xFF2A2A3D), // Distinct background for drop zones
                    border: Border.all(
                      color: filledValue != null
                          ? AppColors.success
                          : isHovering
                          ? AppColors.accent
                          : Colors.white54, // Visible border
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: filledValue != null
                      ? Text(
                          filledValue,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          'Drop Here',
                          style: TextStyle(
                            color: isHovering
                                ? AppColors.accent
                                : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                );
              },
            );
          }
        }),
      );
    } else if (stepData.type == 'calc') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: TextField(
              controller: calcController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black54,
                hintText: '?',
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.accent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              if (int.tryParse(calcController.text) == stepData.target) {
                _handleSuccess();
              } else {
                HapticFeedback.vibrate();
                _playSound(_errorPlayer, _errorUrl); // Specifically requested error buzzer
                _showFeedback(currentLang == 'en' ? "Incorrect Value" : "गलत मान", isSuccess: false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text(
              'GO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    } else if (stepData.type == 'choice') {
      return Wrap(
        spacing: 12,
        children: stepData.options!.map((opt) {
          return OutlinedButton(
            onPressed: () {
              if (opt['correct']) {
                _handleSuccess();
              } else {
                HapticFeedback.vibrate();
                _playSound(_errorPlayer, _errorUrl); // Specifically requested error buzzer
                _showFeedback(currentLang == 'en' ? "Incorrect" : "गलत", isSuccess: false);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Text(opt['text']),
          );
        }).toList(),
      );
    }
    return const SizedBox();
  }

  Widget _buildVisualizationArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: RadialGradient(
          colors: [AppColors.primary.withOpacity(0.2), Colors.black],
          radius: 1.5,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _getVisualForStep(currentStep),
        ),
      ),
    );
  }

  Widget _getVisualForStep(int step) {
    if (step <= 2) {
      // Phase 1: Terms (1, 2, or 3 glowing blocks)
      int blocks = step + 1;
      return Row(
        key: ValueKey('blocks_$blocks'),
        mainAxisSize: MainAxisSize.min,
        children: List.generate(blocks, (index) {
          Color color = index == 0
              ? AppColors.accent
              : index == 1
              ? AppColors.secondary
              : AppColors.success;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(
                          0.5 + (_pulseController.value * 0.3),
                        ),
                        blurRadius: 15 + (_pulseController.value * 10),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'T${index + 1}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      );
    } else if (step == 3) {
      // Linear (Line)
      return AnimatedBuilder(
        key: const ValueKey('linear'),
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(
                    0.5 + (_pulseController.value * 0.5),
                  ),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          );
        },
      );
    } else if (step == 4) {
      // Quadratic (Square/Area)
      return AnimatedBuilder(
        key: const ValueKey('quadratic'),
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.3),
              border: Border.all(color: AppColors.accent, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(
                    0.2 + (_pulseController.value * 0.3),
                  ),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.crop_square, size: 80, color: AppColors.accent),
            ),
          );
        },
      );
    } else if (step == 5) {
      // Cubic (Volume/Cube)
      return SizedBox(
        key: const ValueKey('cubic'),
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: IsometricCubePainter(
            color: AppColors.accent,
            animationValue: _pulseController.value,
          ),
        ),
      );
    } else {
      // Abstract Complex Form
      return AnimatedBuilder(
        key: const ValueKey('abstract'),
        animation: _pulseController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _pulseController.value * math.pi * 2,
            child: Icon(
              Icons.dashboard_customize,
              size: 150,
              color: AppColors.secondary.withOpacity(0.8),
              shadows: [
                Shadow(
                  color: AppColors.secondary,
                  blurRadius: 20 + (_pulseController.value * 20),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.success.withOpacity(0.2), blurRadius: 80),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: AppColors.success, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      i18n[currentLang]!['mission_complete']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        shadows: [Shadow(color: AppColors.success, blurRadius: 20)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "ALL CARGO SORTED",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _playSound(_shutterPlayer, _shutterUrl);
                        resetGame(hard: true);
                      },
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      label: Text(
                        i18n[currentLang]!['restart_btn']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
    );
  }
}

class _DebrisItem extends StatelessWidget {
  final String text;
  final bool isDragging;

  const _DebrisItem({required this.text, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDragging
            ? AppColors.accent
            : AppColors.primary.withOpacity(0.1),
        border: Border.all(
          color: isDragging ? Colors.white : AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDragging ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class IsometricCubePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  IsometricCubePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double center = w / 2;
    double radius = (w / 2) * 0.8;

    // Angles for isometric projection
    double angle30 = math.pi / 6;

    // Center point
    Offset pCenter = Offset(center, center + (radius * math.sin(angle30)));

    // Outer vertices
    Offset pTop = Offset(center, center - radius);
    Offset pBottom = Offset(center, pCenter.dy + radius);
    Offset pLeft = Offset(
      center - radius * math.cos(angle30),
      center - radius * math.sin(angle30),
    );
    Offset pRight = Offset(
      center + radius * math.cos(angle30),
      center - radius * math.sin(angle30),
    );

    // Bottom side vertices
    Offset pBottomLeft = Offset(pLeft.dx, pLeft.dy + radius);
    Offset pBottomRight = Offset(pRight.dx, pRight.dy + radius);

    Paint paintTop = Paint()
      ..color = color.withOpacity(0.6 + (animationValue * 0.2))
      ..style = PaintingStyle.fill;
    Paint paintLeft = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    Paint paintRight = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Top face
    Path topFace = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pCenter.dx, pCenter.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();
    canvas.drawPath(topFace, paintTop);
    canvas.drawPath(topFace, strokePaint);

    // Left face
    Path leftFace = Path()
      ..moveTo(pLeft.dx, pLeft.dy)
      ..lineTo(pCenter.dx, pCenter.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();
    canvas.drawPath(leftFace, paintLeft);
    canvas.drawPath(leftFace, strokePaint);

    // Right face
    Path rightFace = Path()
      ..moveTo(pCenter.dx, pCenter.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..close();
    canvas.drawPath(rightFace, paintRight);
    canvas.drawPath(rightFace, strokePaint);

    // Glow effect
    canvas.drawShadow(topFace, color, 10 + (animationValue * 10), true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- DATA & CONSTANTS ---

class AppColors {
  static const Color bg = Color(0xFF0F172A);
  static const Color accent = Color(0xFF38BDF8);
  static const Color primary = Color(0xFF818CF8);
  static const Color secondary = Color(0xFFF472B6);
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);
}

class LabStep {
  final int id;
  final String type;
  final String titleKey;
  final String instrKey;
  final List<dynamic>? template;
  final List<String>? debris;
  final int? target;
  final List<Map<String, dynamic>>? options;
  final String phase;

  const LabStep({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.instrKey,
    this.template,
    this.debris,
    this.target,
    this.options,
    required this.phase,
  });
}

const List<LabStep> labData = [
  LabStep(
    id: 1,
    type: 'drag',
    titleKey: 's1_title',
    instrKey: 's1_instr',
    template: [
      {'type': 'slot', 'answer': '2x'},
    ],
    debris: ['2x', 'x+y', 'x+y+z'],
    phase: 'TERMS',
  ),
  LabStep(
    id: 2,
    type: 'drag',
    titleKey: 's2_title',
    instrKey: 's2_instr',
    template: [
      {'type': 'slot', 'answer': 'x²-1'},
    ],
    debris: ['x²-1', '3x', 'a+b+c'],
    phase: 'TERMS',
  ),
  LabStep(
    id: 3,
    type: 'drag',
    titleKey: 's3_title',
    instrKey: 's3_instr',
    template: [
      {'type': 'slot', 'answer': 'x²+x+1'},
    ],
    debris: ['x²+x+1', 'x', 'x+1'],
    phase: 'TERMS',
  ),
  LabStep(
    id: 4,
    type: 'drag',
    titleKey: 's4_title',
    instrKey: 's4_instr',
    template: [
      {'type': 'slot', 'answer': '3x+5'},
    ],
    debris: ['3x+5', 'x²', 'x³'],
    phase: 'DEGREE',
  ),
  LabStep(
    id: 5,
    type: 'drag',
    titleKey: 's5_title',
    instrKey: 's5_instr',
    template: [
      {'type': 'slot', 'answer': 'x²+4'},
    ],
    debris: ['x²+4', 'x+4', 'x³'],
    phase: 'DEGREE',
  ),
  LabStep(
    id: 6,
    type: 'drag',
    titleKey: 's6_title',
    instrKey: 's6_instr',
    template: [
      {'type': 'slot', 'answer': 'x³-x'},
    ],
    debris: ['x³-x', 'x²', '3x'],
    phase: 'DEGREE',
  ),
  LabStep(
    id: 7,
    type: 'drag',
    titleKey: 's7_title',
    instrKey: 's7_instr',
    template: [
      {'type': 'slot', 'answer': 'x²'},
      {'type': 'static', 'label': '+'},
      {'type': 'slot', 'answer': '3x'},
      {'type': 'static', 'label': '+'},
      {'type': 'slot', 'answer': '5'},
    ],
    debris: ['x²', '3x', '5'],
    phase: 'ANALYSIS',
  ),
  LabStep(
    id: 8,
    type: 'calc',
    titleKey: 's8_title',
    instrKey: 's8_instr',
    target: -4,
    phase: 'ANALYSIS',
  ),
  LabStep(
    id: 9,
    type: 'calc',
    titleKey: 's9_title',
    instrKey: 's9_instr',
    target: 0,
    phase: 'ANALYSIS',
  ),
  LabStep(
    id: 10,
    type: 'choice',
    titleKey: 's10_title',
    instrKey: 's10_instr',
    options: [
      {'text': 'Linear', 'correct': false},
      {'text': 'Quadratic', 'correct': true},
      {'text': 'Cubic', 'correct': false},
    ],
    phase: 'CONCLUSION',
  ),
];

const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE POLY-SORTER',
    'tagline': 'CLASSIFICATION STATION',
    'init_btn': 'START SORTING',
    'header_title': 'The Poly-Sorter',
    'header_subtitle': 'CLASS 9 • POLYNOMIALS - Classification',
    'guide_title': "Teacher's Guide",
    'avail_parts': 'Unclassified Cargo',
    'mission_complete': 'MISSION COMPLETE!',
    'restart_btn': 'Restart Mission',
    'mission_obj_title': 'MISSION OBJECTIVE',
    'mission_obj_desc':
        'Analyze incoming algebraic forms. Classify them by Terms and Degree to restore order.',
    'guide_intro':
        "This lab turns abstract algebra into a visual sorting game. Students must classify algebraic expressions based on their 'Terms' (Segments) and 'Degree' (Power/Shape).",
    'guide_step_1': 'Phase 1: Terminology',
    'guide_step_1_d':
        "Focus on counting segments separated by + or -. Monomial (1), Binomial (2), Trinomial (3).",
    'guide_step_2': 'Phase 2: Degrees',
    'guide_step_2_d':
        "Visualize the power. x¹ is a Line (1D). x² is a Square (2D). x³ is a Cube (3D).",
    'guide_step_3': 'Phase 3: Analysis',
    'guide_step_3_d':
        "Standard Form means organizing power from high to low (x³ → x² → x¹).",
    'guide_misc_t': 'Common Misconception',
    'guide_misc_d':
        "Students often confuse coefficients (multipliers) with exponents (powers). Degree determines shape.",
    'guide_ext_t': 'Classroom Extension',
    'guide_ext_d':
        "Ask students to sketch the difference between x, x², and x³ in the air with their hands.",
    's1_title': 'Identify Monomials',
    's1_instr': 'Drag expressions with ONE term to the scanner.',
    's2_title': 'Identify Binomials',
    's2_instr': 'Find expressions with TWO distinct terms.',
    's3_title': 'Identify Trinomials',
    's3_instr': 'Find expressions with THREE terms.',
    's4_title': 'Linear (Degree 1)',
    's4_instr': 'Find polynomials where max power is 1 (Lines).',
    's5_title': 'Quadratic (Degree 2)',
    's5_instr': 'Find polynomials where max power is 2 (Squares).',
    's6_title': 'Cubic (Degree 3)',
    's6_instr': 'Find polynomials where max power is 3 (Cubes).',
    's7_title': 'Standard Form',
    's7_instr': 'Rearrange 3x + x² + 5 into Standard Form.',
    's8_title': 'Coefficient Check',
    's8_instr': 'What is the coefficient of x² in 5x³ - 4x² + 7?',
    's9_title': 'Zero Polynomial',
    's9_instr': "What is the degree of the constant '5'?",
    's10_title': 'Master Sort',
    's10_instr': 'Classify: x² - 1. Is it Linear, Quadratic or Cubic?',
  },
  'hi': {
    'app_title': 'पॉली-सॉर्टर',
    'tagline': 'वर्गीकरण स्टेशन',
    'init_btn': 'सॉर्टिंग शुरू करें',
    'header_title': 'पॉली-सॉर्टर',
    'header_subtitle': 'कक्षा 9 • बहुपद – वर्गीकरण',
    'guide_title': 'शिक्षक गाइड',
    'avail_parts': 'अवर्गीकृत कार्गो',
    'mission_complete': 'मिशन पूर्ण!',
    'restart_btn': 'पुनरारंभ करें',
    'mission_obj_title': 'मिशन का उद्देश्य',
    'mission_obj_desc':
        'आने वाले बीजीय आकृतियों का विश्लेषण करें। उन्हें पदों और घात के आधार पर वर्गीकृत करें।',
    'guide_intro':
        "यह लैब अमूर्त बीजगणित को एक दृश्य गेम में बदल देती है। छात्रों को अभिव्यक्तियों को उनके 'पदों' और 'डिग्री' के आधार पर वर्गीकृत करना होगा।",
    'guide_step_1': 'चरण 1: शब्दावली',
    'guide_step_1_d':
        "+ या - द्वारा अलग किए गए खंडों को गिनने पर ध्यान दें। एकपदी (1), द्विपद (2), त्रिपद (3)।",
    'guide_step_2': 'चरण 2: डिग्री',
    'guide_step_2_d':
        "शक्ति की कल्पना करें। x¹ एक रेखा (1D) है। x² एक वर्ग (2D) है। x³ एक घन (3D) है।",
    'guide_step_3': 'चरण 3: विश्लेषण',
    'guide_step_3_d':
        "मानक रूप का अर्थ है उच्च से निम्न (x³ → x² → x¹) तक शक्ति को व्यवस्थित करना।",
    'guide_misc_t': 'आम गलतफहमी',
    'guide_misc_d':
        "छात्र अक्सर गुणांक और घातांक में भ्रमित हो जाते हैं। याद दिलाएं: डिग्री आकार तय करती है।",
    'guide_ext_t': 'कक्षा विस्तार',
    'guide_ext_d': "छात्रों से हवा में x¹, x², और x³ के आकार बनाने को कहें।",
    's1_title': 'एकपदी पहचानें',
    's1_instr': 'एक पद वाले व्यंजकों को स्कैनर तक खींचें।',
    's2_title': 'द्विपद पहचानें',
    's2_instr': 'दो अलग-अलग पदों वाले व्यंजक खोजें।',
    's3_title': 'त्रिपद पहचानें',
    's3_instr': 'तीन पदों वाले व्यंजक खोजें।',
    's4_title': 'रैखिक (डिग्री 1)',
    's4_instr': 'वे बहुपद खोजें जहाँ अधिकतम घात 1 (रेखाएँ) है।',
    's5_title': 'द्विघात (डिग्री 2)',
    's5_instr': 'वे बहुपद खोजें जहाँ अधिकतम घात 2 (वर्ग) है।',
    's6_title': 'त्रिघात (डिग्री 3)',
    's6_instr': 'वे बहुपद खोजें जहाँ अधिकतम घात 3 (घन) है।',
    's7_title': 'मानक रूप',
    's7_instr': '3x + x² + 5 को मानक रूप में पुनर्व्यवस्थित करें।',
    's8_title': 'गुणांक जाँच',
    's8_instr': '5x³ - 4x² + 7 में x² का गुणांक क्या है।',
    's9_title': 'शून्य बहुपद',
    's9_instr': "स्थिरांक '5' की डिग्री क्या है?",
    's10_title': 'मास्टर सॉर्ट',
    's10_instr': 'वर्गीकृत करें: x² - 1. क्या यह रैखिक, द्विघात या त्रिघात है?',
  },
};