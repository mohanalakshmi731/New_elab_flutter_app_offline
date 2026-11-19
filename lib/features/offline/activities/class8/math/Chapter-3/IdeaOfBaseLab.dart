// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class IdeaOfBaseLab extends StatefulWidget {
  const IdeaOfBaseLab({Key? key}) : super(key: key);

  @override
  State<IdeaOfBaseLab> createState() => _IdeaOfBaseLabState();
}

class LabSymbol {
  final String id;
  String type; // 'stroke', 'heel', 'coil', 'star'
  double x;
  double y;
  bool isSelected;
  bool isUpgraded;

  LabSymbol({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.isSelected = false,
    this.isUpgraded = false,
  });
}

class _IdeaOfBaseLabState extends State<IdeaOfBaseLab>
    with TickerProviderStateMixin {
  bool isDarkMode = true;
  String currentLang = 'en';
  bool isSidebarOpen = true;
  int currentStep = 0;
  double boardFontSize = 16.0;

  bool showShutter = true;
  bool showSettings = false;
  bool isTaskValidated = false;

  // Interaction State
  List<LabSymbol> symbols = [];
  bool isAnimating = false;

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Canvas fixed size for InteractiveViewer
  final double canvasWidth = 1200.0;
  final double canvasHeight = 800.0;

  // --- Translations Map ---
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'appTitle': "The Idea of a Base",
      'appSubtitle': "Class 8 • A Story of Numbers",
      'enterLab': "Enter Lab",
      'currentStage': "Current Stage",
      'validateModel': "Validate Model",
      'indVar': "Target Output",
      'labSettings': "Lab Settings",
      'interfaceTheme': "Interface Theme",
      'dark': "Dark",
      'light': "Light",
      'teacherBoardSize': "Text Size",
      'understood': "Understood",
      'lblHeel': "Add Heel (10)",
      'lblStroke': "Add Stroke (1)",
      'msgAlreadyUpgraded': "This symbol is already upgraded!",
      'msgNotEnoughGroup': "Not enough strokes to group! Need 5.",
      'msgNotEnoughTrade': "Not enough strokes to trade! Need 10.",
      'btn_pending': "Task Pending",
      'val0_success': "Excellent! You built 23 in Egyptian Hieroglyphs.",
      'val0_fail':
          "You have {heel} Heels and {stroke} Strokes. Need 2 Heels and 3 Strokes.",
      'val1_success': "Perfect! 13 in Base-5 is '2 Stars and 3 Strokes'.",
      'val1_fail': "Keep grouping! Select 5 strokes to make a Star.",
      'val2_success': "Great Trade! 13 strokes becomes 1 Heel and 3 Strokes.",
      'val2_fail': "Select 10 strokes to trade for a Heel Bone.",
      'val3_success':
          "Brilliant! Upgrading each symbol effectively multiplies by 10 (Result: 120).",
      'val3_fail':
          "Tap EVERY single symbol (the Heel and both Strokes) to upgrade them!",
      'scenarios': [
        {
          'opt': "1. Hieroglyphs (Base-10)",
          'title': "1. Hieroglyphs (Base-10)",
          'theory':
              "Mission: Construct the number 23 on the platform. Add the correct number of Heel Bones and Strokes.",
          'hudTask':
              "Spawn exactly 2 Heel Bones and 3 Strokes. Tap a symbol to remove it.",
        },
        {
          'opt': "2. The Base-5 Experiment",
          'title': "2. The Base-5 Experiment",
          'theory':
              "Mission: You have 13 strokes. Tap to select them. When 5 are selected, they group into a 'Star'. Find out how 13 is written in Base-5.",
          'hudTask':
              "Tap to select 5 strokes. They will group into 1 Star. Do this twice.",
        },
        {
          'opt': "3. Figure It Out (Trading)",
          'title': "3. Figure It Out (Trading)",
          'theory':
              "Mission: We added 8 strokes and 5 strokes, giving us 13 strokes. Perform the necessary trade to simplify the number (10 Strokes = 1 Heel).",
          'hudTask':
              "Tap to select 10 strokes. They will trade for 1 Heel Bone.",
        },
        {
          'opt': "4. Math Talk (x10)",
          'title': "4. Math Talk (Multiplying by 10)",
          'theory':
              "Mission: Multiply 12 (1 Heel, 2 Strokes) by 10. Tap each symbol to 'upgrade' it to the next power of 10.",
          'hudTask':
              "Tap the Heel Bone to upgrade it to a Coil, and tap the Strokes to upgrade them to Heel Bones.",
        },
      ],
    },
    'hi': {
      'appTitle': "आधार की अवधारणा",
      'appSubtitle': "कक्षा 8 • संख्या की कहानी",
      'enterLab': "प्रयोगशाला में प्रवेश करें",
      'currentStage': "वर्तमान चरण",
      'validateModel': "मॉडल जांचें",
      'indVar': "लक्ष्य आउटपुट",
      'labSettings': "प्रयोगशाला सेटिंग्स",
      'interfaceTheme': "इंटरफ़ेस थीम",
      'dark': "डार्क",
      'light': "लाइट",
      'teacherBoardSize': "टेक्स्ट आकार",
      'understood': "समझ गया",
      'lblHeel': "एड़ी जोड़ें (10)",
      'lblStroke': "स्ट्रोक जोड़ें (1)",
      'msgAlreadyUpgraded': "यह प्रतीक पहले से ही अपग्रेड हो चुका है!",
      'msgNotEnoughGroup': "समूह बनाने के लिए पर्याप्त स्ट्रोक नहीं! 5 चाहिए।",
      'msgNotEnoughTrade':
          "व्यापार करने के लिए पर्याप्त स्ट्रोक नहीं! 10 चाहिए।",
      'btn_pending': "कार्य लंबित है",
      'val0_success': "बहुत बढ़िया! आपने मिस्र की चित्रलिपि में 23 बनाया।",
      'val0_fail':
          "आपके पास {heel} एड़ी और {stroke} स्ट्रोक हैं। 2 एड़ी और 3 स्ट्रोक चाहिए।",
      'val1_success': "उत्तम! आधार-5 में 13 '2 तारे और 3 स्ट्रोक' है।",
      'val1_fail': "समूह बनाते रहें! तारा बनाने के लिए 5 स्ट्रोक चुनें।",
      'val2_success':
          "शानदार व्यापार! 13 स्ट्रोक 1 एड़ी और 3 स्ट्रोक बन जाते हैं।",
      'val2_fail': "एड़ी की हड्डी के लिए 10 स्ट्रोक का चयन करें।",
      'val3_success':
          "बहुत खूब! प्रत्येक प्रतीक को अपग्रेड करने से यह 10 से गुणा हो जाता है (परिणाम: 120)।",
      'val3_fail':
          "उन्हें अपग्रेड करने के लिए प्रत्येक प्रतीक (एड़ी और दोनों स्ट्रोक) पर टैप करें!",
      'scenarios': [
        {
          'opt': "1. चित्रलिपि (आधार-10)",
          'title': "1. चित्रलिपि (आधार-10)",
          'theory':
              "मिशन: मंच पर 23 संख्या का निर्माण करें। एड़ी की हड्डियों और स्ट्रोक की सही संख्या जोड़ें।",
          'hudTask':
              "ठीक 2 एड़ी की हड्डी और 3 स्ट्रोक उत्पन्न करें। इसे हटाने के लिए किसी प्रतीक पर टैप करें।",
        },
        {
          'opt': "2. आधार-5 प्रयोग",
          'title': "2. आधार-5 प्रयोग",
          'theory':
              "मिशन: आपके पास 13 स्ट्रोक हैं। उन्हें चुनने के लिए टैप करें। जब 5 का चयन किया जाता है, तो वे 'तारा' में समूहित हो जाते हैं।",
          'hudTask':
              "5 स्ट्रोक का चयन करने के लिए टैप करें। वे 1 तारे में समूहित हो जाएंगे। ऐसा दो बार करें।",
        },
        {
          'opt': "3. इसे समझें (व्यापार)",
          'title': "3. इसे समझें (व्यापार)",
          'theory':
              "मिशन: 8 स्ट्रोक और 5 स्ट्रोक मिलाकर 13 स्ट्रोक मिले। संख्या को सरल बनाने के लिए व्यापार करें (10 स्ट्रोक = 1 एड़ी)।",
          'hudTask':
              "10 स्ट्रोक का चयन करने के लिए टैप करें। वे 1 एड़ी की हड्डी के लिए व्यापार करेंगे।",
        },
        {
          'opt': "4. गणित वार्ता (x10)",
          'title': "4. गणित वार्ता (10 से गुणा)",
          'theory':
              "मिशन: 12 (1 एड़ी, 2 स्ट्रोक) को 10 से गुणा करें। प्रत्येक प्रतीक को अगले 10 की घात में 'अपग्रेड' करने के लिए उस पर टैप करें।",
          'hudTask':
              "एड़ी की हड्डी को कुंडल में अपग्रेड करने के लिए उस पर टैप करें, और स्ट्रोक को एड़ी की हड्डियों में अपग्रेड करने के लिए उन पर टैप करें।",
        },
      ],
    },
  };

  Color get bgColor =>
      isDarkMode ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
  Color get textColor =>
      isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textMuted =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get glassBg => isDarkMode
      ? const Color.fromRGBO(30, 41, 59, 0.85)
      : const Color.fromRGBO(255, 255, 255, 0.90);
  Color get glassBorder => isDarkMode
      ? const Color.fromRGBO(255, 255, 255, 0.2)
      : const Color.fromRGBO(0, 0, 0, 0.15);
  Color get primary => const Color(0xFFEAB308);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadStep(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'tap':
        url =
            'audio/class8/mixkit_2568.mp3';
        break;
      case 'merge':
        url =
            'audio/class8/mixkit_2004.mp3';
        break;
      case 'success':
        url =
            'audio/class8/mixkit_2013.mp3';
        break;
      case 'fail':
        url =
            'audio/class8/mixkit_2955.mp3';
        break;
    }
    if (url.isNotEmpty) {
      await _audioPlayer.play(AssetSource(url));
    }
  }

  void _loadStep(int step) {
    setState(() {
      currentStep = step;
      isTaskValidated = false;
      symbols.clear();
      isAnimating = false;

      if (step == 1 || step == 2) {
        _spawnRandomSymbols('stroke', 13);
      } else if (step == 3) {
        _spawnRandomSymbols('heel', 1);
        _spawnRandomSymbols('stroke', 2);
      }
    });
  }

  void _spawnRandomSymbols(String type, int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      symbols.add(
        LabSymbol(
          id:
              DateTime.now().microsecondsSinceEpoch.toString() +
              i.toString() +
              type,
          type: type,
          x: 0.2 + random.nextDouble() * 0.6,
          y: 0.2 + random.nextDouble() * 0.6,
        ),
      );
    }
  }

  void _handleSymbolTap(LabSymbol symbol) async {
    if (isAnimating || isTaskValidated) return;
    HapticFeedback.selectionClick();
    _playSound('tap');

    setState(() {
      if (currentStep == 0) {
        symbols.remove(symbol);
      } else if (currentStep == 1 || currentStep == 2) {
        symbol.isSelected = !symbol.isSelected;
        _checkGrouping();
      } else if (currentStep == 3) {
        if (symbol.isUpgraded) {
          _showScrollablePopup(false, i18n[currentLang]!['msgAlreadyUpgraded']);
          return;
        }

        if (symbol.type == 'stroke') {
          symbol.type = 'heel';
        } else if (symbol.type == 'heel') {
          symbol.type = 'coil';
        }
        symbol.isUpgraded = true;
      }
    });
  }

  void _checkGrouping() async {
    var selected = symbols.where((s) => s.isSelected).toList();

    if (currentStep == 1 && selected.length == 5) {
      _animateMerge(selected, 'star');
    } else if (currentStep == 1 && selected.length > 5) {
      _showScrollablePopup(false, i18n[currentLang]!['msgNotEnoughGroup']);
      for (var s in selected) {
        s.isSelected = false;
      }
    }

    if (currentStep == 2 && selected.length == 10) {
      _animateMerge(selected, 'heel');
    } else if (currentStep == 2 && selected.length > 10) {
      _showScrollablePopup(false, i18n[currentLang]!['msgNotEnoughTrade']);
      for (var s in selected) {
        s.isSelected = false;
      }
    }
  }

  void _animateMerge(List<LabSymbol> toMerge, String resultType) async {
    setState(() => isAnimating = true);
    _playSound('merge');

    double avgX = 0, avgY = 0;
    for (var s in toMerge) {
      avgX += s.x;
      avgY += s.y;
    }
    avgX /= toMerge.length;
    avgY /= toMerge.length;

    setState(() {
      for (var s in toMerge) {
        s.x = avgX;
        s.y = avgY;
      }
    });

    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      symbols.removeWhere((s) => toMerge.contains(s));
      symbols.add(
        LabSymbol(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: resultType,
          x: avgX,
          y: avgY,
        ),
      );
      isAnimating = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _validateModel() {
    final dict = i18n[currentLang]!;

    int strokes = symbols.where((s) => s.type == 'stroke').length;
    int heels = symbols.where((s) => s.type == 'heel').length;
    int coils = symbols.where((s) => s.type == 'coil').length;
    int stars = symbols.where((s) => s.type == 'star').length;

    bool success = false;
    String msg = "";

    if (currentStep == 0) {
      if (heels == 2 && strokes == 3) {
        success = true;
        msg = dict['val0_success'];
      } else {
        msg = dict['val0_fail']
            .replaceAll('{heel}', heels.toString())
            .replaceAll('{stroke}', strokes.toString());
      }
    } else if (currentStep == 1) {
      if (stars == 2 && strokes == 3) {
        success = true;
        msg = dict['val1_success'];
      } else {
        msg = dict['val1_fail'];
      }
    } else if (currentStep == 2) {
      if (heels == 1 && strokes == 3) {
        success = true;
        msg = dict['val2_success'];
      } else {
        msg = dict['val2_fail'];
      }
    } else if (currentStep == 3) {
      if (coils == 1 && heels == 2 && strokes == 0) {
        success = true;
        msg = dict['val3_success'];
      } else {
        msg = dict['val3_fail'];
      }
    }

    if (success) {
      HapticFeedback.heavyImpact();
      _playSound('success');
      setState(() => isTaskValidated = true);
      _showScrollablePopup(true, msg);
    } else {
      HapticFeedback.vibrate();
      _playSound('fail');
      _showScrollablePopup(false, msg);
    }
  }

  void _showScrollablePopup(bool success, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: _buildGlassPanel(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.greenAccent : Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  success ? "Success!" : "Notice",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (success && currentStep < 3) {
                      _loadStep(currentStep + 1);
                    } else if (success && currentStep == 3) {
                      _loadStep(0);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: success ? Colors.green : primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    success
                        ? (currentStep < 3 ? "Next Step" : "Restart Lab")
                        : "Try Again",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glassBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 30,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dict = i18n[currentLang]!;
    final scenarioData = dict['scenarios'][currentStep];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = max(screenWidth * 0.3, 320.0);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // --- 1. ZOOMABLE CANVAS (Background Layer) ---
            Positioned.fill(
              child: Container(
                color: bgColor,
                child: InteractiveViewer(
                  minScale: 0.2,
                  maxScale: 4.0,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(2000),
                  child: Container(
                    width: canvasWidth,
                    height: canvasHeight,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                          bgColor,
                        ],
                        radius: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Center Indicator
                        Positioned(
                          left: canvasWidth * 0.1,
                          top: canvasHeight * 0.1,
                          right: canvasWidth * 0.1,
                          bottom: canvasHeight * 0.1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white10,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // Render Symbols
                        ...symbols.map((sym) {
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: sym.x * canvasWidth - 30,
                            top: sym.y * canvasHeight - 30,
                            child: GestureDetector(
                              onTap: () => _handleSymbolTap(sym),
                              child: _buildSymbolWidget(sym),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. FLOATING MISSION CARD (When Sidebar Collapsed) ---
            if (!isSidebarOpen)
              Positioned(
                top: 80,
                left: 20,
                child: _buildGlassPanel(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment, color: primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Mission",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scenarioData['hudTask'],
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        if (currentStep == 0) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildPedestalBtn(
                                  dict['lblHeel'],
                                  'heel',
                                  compact: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPedestalBtn(
                                  dict['lblStroke'],
                                  'stroke',
                                  compact: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isTaskValidated
                                ? () {
                                    if (currentStep < 3) {
                                      _loadStep(currentStep + 1);
                                    } else {
                                      _loadStep(0);
                                    }
                                  }
                                : _validateModel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTaskValidated
                                  ? Colors.green
                                  : primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isTaskValidated
                                      ? Icons.check_circle
                                      : Icons.science,
                                  color: isTaskValidated
                                      ? Colors.white
                                      : Colors.black87,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isTaskValidated
                                      ? (currentStep < 3
                                            ? "Next Step"
                                            : "Restart Lab")
                                      : dict['validateModel'],
                                  style: TextStyle(
                                    color: isTaskValidated
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
              ),

            // --- 3. SCROLLABLE LEFT SIDEBAR (Z-Index Lower than Top Bar) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              child: Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  color: glassBg,
                  border: Border(right: BorderSide(color: glassBorder)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 20),
                  ],
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sidebar Header space to clear the menu button
                              const SizedBox(height: 60),

                              // App Title and controls inside sidebar
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.biotech,
                                          color: primary,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dict['appTitle'],
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                dict['appSubtitle'],
                                                style: TextStyle(
                                                  color: textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Moved Top Right Controls to here
                                    _buildGlassPanel(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Text(
                                              currentLang.toUpperCase(),
                                              style: TextStyle(
                                                color: primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () => setState(
                                              () => currentLang =
                                                  currentLang == 'en'
                                                  ? 'hi'
                                                  : 'en',
                                            ),
                                          ),
                                          // IconButton(
                                          //   icon: Icon(
                                          //     Icons.settings,
                                          //     color: textMuted,
                                          //   ),
                                          //   onPressed: () => setState(
                                          //     () => showSettings = true,
                                          //   ),
                                          // ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.refresh,
                                              color: textMuted,
                                            ),
                                            onPressed: () =>
                                                _loadStep(currentStep),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.white10,
                                thickness: 1,
                              ),

                              // Scrollable Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Step Dropdown
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: glassBorder),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: currentStep,
                                          dropdownColor: bgColor,
                                          isExpanded: true,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: primary,
                                          ),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onChanged: (val) {
                                            if (val != null) _loadStep(val);
                                          },
                                          items: List.generate(4, (index) {
                                            return DropdownMenuItem(
                                              value: index,
                                              child: Text(
                                                dict['scenarios'][index]['opt'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Target Output / Theory
                                    Text(
                                      dict['indVar'].toUpperCase(),
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      scenarioData['title'],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      scenarioData['theory'],
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.9),
                                        fontSize: boardFontSize,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: primary.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        scenarioData['hudTask'],
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Dynamic Buttons
                                    if (currentStep == 0)
                                      Column(
                                        children: [
                                          _buildPedestalBtn(
                                            dict['lblHeel'],
                                            'heel',
                                          ),
                                          const SizedBox(height: 16),
                                          _buildPedestalBtn(
                                            dict['lblStroke'],
                                            'stroke',
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              const Spacer(), // Pushes the footer to the bottom
                              // Footer Validation Button
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: glassBorder),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: isTaskValidated
                                          ? () {
                                              if (currentStep < 3) {
                                                _loadStep(currentStep + 1);
                                              } else {
                                                _loadStep(0);
                                              }
                                            }
                                          : _validateModel,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isTaskValidated
                                            ? Colors.green
                                            : primary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isTaskValidated
                                                ? Icons.check_circle
                                                : Icons.science,
                                            color: isTaskValidated
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isTaskValidated
                                                ? (currentStep < 3
                                                      ? "Next Step"
                                                      : "Restart Lab")
                                                : dict['validateModel'],
                                            style: TextStyle(
                                              color: isTaskValidated
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Copyright Footer
                                    Text(
                                      "© ZeroScienceLab - Fall in love with math and Science",
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
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

            // --- 4. TOP ACTION BAR (Overlay Layer - High Z-Index ensuring it stays visible over Sidebar) ---
            Positioned(
              top: 16,
              left: 16, // Fixed position, won't slide with sidebar
              child: IconButton(
                icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    isSidebarOpen = !isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // Settings Modal
            if (showSettings)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: _buildGlassPanel(
                    width: 350,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.settings, color: primary),
                                const SizedBox(width: 8),
                                Text(
                                  dict['labSettings'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: textColor),
                              onPressed: () =>
                                  setState(() => showSettings = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dict['interfaceTheme'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: primary,
                              ),
                              onPressed: () =>
                                  setState(() => isDarkMode = !isDarkMode),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dict['teacherBoardSize'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${boardFontSize.toInt()}px",
                              style: TextStyle(color: primary),
                            ),
                          ],
                        ),
                        Slider(
                          value: boardFontSize,
                          min: 14,
                          max: 32,
                          activeColor: primary,
                          onChanged: (val) =>
                              setState(() => boardFontSize = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Shutter Screen
            if (showShutter)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF020617), Color(0xFF0F172A)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.biotech, size: 40, color: primary),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        dict['appTitle'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dict['appSubtitle'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _playSound('tap');
                          setState(() => showShutter = false);
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                        label: Text(
                          dict['enterLab'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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

  Widget _buildPedestalBtn(String label, String type, {bool compact = false}) {
    return GestureDetector(
      onTap: () {
        if (isTaskValidated) return;
        HapticFeedback.selectionClick();
        _playSound('tap');
        setState(() {
          final random = Random();
          symbols.add(
            LabSymbol(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              type: type,
              x: 0.3 + random.nextDouble() * 0.4,
              y: 0.3 + random.nextDouble() * 0.4,
            ),
          );
        });
      },
      child: Container(
        width: double.infinity,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: glassBorder),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: FittedBox(child: _buildSymbolVisual(type, false)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: _buildSymbolVisual(type, false),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSymbolWidget(LabSymbol sym) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: sym.isSelected
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: sym.isSelected
            ? [const BoxShadow(color: Colors.white24, blurRadius: 15)]
            : [],
        border: sym.isSelected
            ? Border.all(color: Colors.white, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Center(child: _buildSymbolVisual(sym.type, sym.isUpgraded)),
    );
  }

  Widget _buildSymbolVisual(String type, bool isUpgraded) {
    Widget visual;
    switch (type) {
      case 'stroke':
        visual = Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.brown[400],
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
        break;
      case 'heel':
        visual = const Text(
          '∩',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
        break;
      case 'coil':
        visual = Icon(
          Icons.fingerprint,
          color: Colors.amber[600],
          size: 40,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2)),
          ],
        );
        break;
      case 'star':
        visual = const Icon(
          Icons.star,
          color: Colors.yellowAccent,
          size: 40,
          shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
        );
        break;
      default:
        visual = const SizedBox();
    }

    if (isUpgraded) {
      return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, double val, child) {
          return Transform.scale(
            scale: val,
            child: Transform.rotate(angle: val * pi * 2, child: child),
          );
        },
        child: visual,
      );
    }
    return visual;
  }
}
