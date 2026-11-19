// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

/// Main Entry Point for standalone testing
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Cl8MCh12A6VisualisingData(),
  ));
}

/// Constants and Colors
class AppColors {
  static const Color bg = Color(0xFF020617);
  static const Color panel = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);
  static const Color text = Color(0xFFF8FAFC);
  static const Color subtext = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF06B6D4);
  static const Color primary = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color crosshair = Color(0xFFFBBF24);
}

class SeriesColor {
  static const Color cyan = Color(0xFF06B6D4);
  static const Color amber = Color(0xFFFBBF24);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color rose = Color(0xFFF43F5E);
  static const Color emerald = Color(0xFF22C55E);
  static const Color sky = Color(0xFF38BDF8);
}

/// Models
class Series {
  final String id;
  final String label;
  final Color color;
  final List<double>? data;
  final List<double>? table;

  Series({required this.id, required this.label, required this.color, this.data, this.table});
}

class ReadingTarget {
  final String id;
  final String seriesId;
  final int categoryIndex;
  final double tol;
  final String label;

  ReadingTarget({required this.id, required this.seriesId, required this.categoryIndex, required this.tol, required this.label});
}

class TrendSegment {
  final String id;
  final String seriesId;
  final int fromIndex;
  final int toIndex;
  final String label;

  TrendSegment({required this.id, required this.seriesId, required this.fromIndex, required this.toIndex, required this.label});
}

class Scenario {
  final String id;
  final String mode; // 'read' or 'build'
  final List<String> categories;
  final double yMin, yMax, yStep;
  final String yUnit;
  final List<Series> series;
  final List<ReadingTarget>? readingTargets;
  final List<TrendSegment>? trendSegments;
  final List<String>? judgementChips;
  final int? selectedSeriesCount;

  Scenario({
    required this.id, required this.mode, required this.categories,
    required this.yMin, required this.yMax, required this.yStep, required this.yUnit,
    required this.series, this.readingTargets, this.trendSegments, this.judgementChips, this.selectedSeriesCount,
  });
}

class StepStateData {
  Map<String, double> plottedPoints = {}; // "$seriesId_$categoryIndex" -> value
  Map<String, double> readings = {};      // targetId -> value
  Map<String, String> trendChips = {};    // segmentId -> "increasing" | "decreasing" | "flat"
  Map<String, bool> judgements = {};      // chipId -> true/false
  List<String> selectedSeriesIds = [];
  String? activeTargetId;
  String? activeSeriesId;
}

/// The Main Widget
class Cl8MCh12A6VisualisingData extends StatefulWidget {
  const Cl8MCh12A6VisualisingData({super.key});

  @override
  State<Cl8MCh12A6VisualisingData> createState() => _Cl8MCh12A6VisualisingDataState();
}

class _Cl8MCh12A6VisualisingDataState extends State<Cl8MCh12A6VisualisingData> with TickerProviderStateMixin {
  int currentStep = 0;
  bool isSidebarOpen = true;
  bool isCompleted = false;
  String currentLang = 'en';
  late StepStateData stepState;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation controller for the shutter/splash screen
  bool showSplash = true;
  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  // Zoom/Pan controllers
  final TransformationController _transformationController = TransformationController();

  // Data
  final List<Scenario> _scenarios = [
    Scenario(
      id: "EX-L-01", mode: "read",
      categories: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
      yMin: 15, yMax: 40, yStep: 5, yUnit: "°C",
      series: [
        Series(id: "punjab", label: "Punjab", color: SeriesColor.amber, data: [19,22,27,31,35,38,35,33,31,27,23,20]),
        Series(id: "kerala", label: "Kerala", color: SeriesColor.cyan, data: [30,31,32,33,31,30,29,30,31,30,29,30]),
      ],
      readingTargets: [
        ReadingTarget(id: "punjab-jan", seriesId: "punjab", categoryIndex: 0, tol: 2, label: "Punjab • Jan"),
        ReadingTarget(id: "punjab-jun", seriesId: "punjab", categoryIndex: 5, tol: 2, label: "Punjab • Jun"),
        ReadingTarget(id: "kerala-apr", seriesId: "kerala", categoryIndex: 3, tol: 2, label: "Kerala • Apr"),
        ReadingTarget(id: "kerala-jul", seriesId: "kerala", categoryIndex: 6, tol: 2, label: "Kerala • Jul"),
      ],
      trendSegments: [
        TrendSegment(id: "punjab-jan-jun", seriesId: "punjab", fromIndex: 0, toIndex: 5, label: "Punjab: Jan → Jun"),
        TrendSegment(id: "kerala-year", seriesId: "kerala", fromIndex: 0, toIndex: 11, label: "Kerala: Jan → Dec"),
      ],
    ),
    Scenario(
      id: "EX-L-02", mode: "build",
      categories: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],
      yMin: 0, yMax: 40, yStep: 5, yUnit: "",
      series: [
        Series(id: "visiting", label: "Visiting", color: SeriesColor.cyan, table: [16,19,10,14,20,22,35]),
        Series(id: "purchasing", label: "Purchasing", color: SeriesColor.amber, table: [10,8,7,11,12,16,26]),
      ],
    ),
    Scenario(
      id: "EX-L-03", mode: "build",
      categories: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
      yMin: 0, yMax: 30, yStep: 5, yUnit: "days",
      series: [
        Series(id: "mangaluru", label: "Mangaluru", color: SeriesColor.cyan, table: [0.1,0,0.1,1.8,6.2,24.1,27.7,24.5,14,8.8,3.9,0.9]),
        Series(id: "portblair", label: "Port Blair", color: SeriesColor.amber, table: [2.4,1.3,0.9,3.3,15.5,18.7,17.3,18.8,16.8,14.1,11.3,5.4]),
        Series(id: "rameswaram", label: "Rameswaram", color: SeriesColor.rose, table: [2.6,1.3,1.9,3.4,2.5,0.4,1,1,1.9,8.1,10.4,7.8]),
      ],
    ),
    Scenario(
      id: "EX-L-04", mode: "build",
      categories: ["2016","2017","2018","2019","2020","2021","2022","2023","2024","2025"],
      yMin: 0, yMax: 32, yStep: 4, yUnit: "₹/kg",
      series: [
        Series(id: "an-islands", label: "A&N Islands", color: SeriesColor.cyan, table: [16,12,12,12,13.88,18.22,18.73,20.63,19.73,20.99]),
        Series(id: "assam", label: "Assam", color: SeriesColor.amber, table: [6,12,12,12,12,15,14,12.02,13.72,12.35]),
        Series(id: "gujarat", label: "Gujarat", color: SeriesColor.violet, table: [16.5,14.75,14.75,14.75,13,14.45,14.28,14.54,14.8,19.2]),
        Series(id: "mizoram", label: "Mizoram", color: SeriesColor.rose, table: [20,20,22,22,20,22,25,27.65,29.03,29.8]),
        Series(id: "uttar-pradesh", label: "Uttar Pradesh", color: SeriesColor.emerald, table: [16.15,16.97,16.18,18.24,18.96,20.63,21.3,25.39,26.9,24.81]),
        Series(id: "west-bengal", label: "West Bengal", color: SeriesColor.sky, table: [9.47,11.65,11.63,11.43,11.11,12.79,16.14,18.43,21.66,23.99]),
      ],
      selectedSeriesCount: 3,
    ),
    Scenario(
      id: "EX-L-05", mode: "read",
      categories: ["2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024"],
      yMin: 0, yMax: 3200, yStep: 400, yUnit: "",
      series: [
        Series(id: "world", label: "World", color: SeriesColor.violet, data: [80,90,100,110,200,300,450,600,1200,1800,2300,2900,2800]),
      ],
      readingTargets: [
        ReadingTarget(id: "world-2023", seriesId: "world", categoryIndex: 11, tol: 150, label: "World • 2023"),
        ReadingTarget(id: "world-2024", seriesId: "world", categoryIndex: 12, tol: 150, label: "World • 2024"),
      ],
      trendSegments: [
        TrendSegment(id: "world-2023-2024", seriesId: "world", fromIndex: 11, toIndex: 12, label: "World: 2023 → 2024"),
      ],
      judgementChips: [
        "always-increasing"
      ],
    ),
    Scenario(
      id: "EX-L-08", mode: "read",
      categories: ["6","10","20","30","40","50","60","70","75"],
      yMin: 7, yMax: 10, yStep: 0.5, yUnit: "h",
      series: [
        Series(id: "sleep", label: "Average sleep", color: SeriesColor.cyan, data: [9.5,9.0,8.5,8.2,8.0,8.0,8.2,8.4,8.5]),
      ],
      readingTargets: [
        ReadingTarget(id: "age-6", seriesId: "sleep", categoryIndex: 0, tol: 0.5, label: "Age 6"),
        ReadingTarget(id: "age-40", seriesId: "sleep", categoryIndex: 4, tol: 0.5, label: "Age 40"),
        ReadingTarget(id: "age-75", seriesId: "sleep", categoryIndex: 8, tol: 0.5, label: "Age 75"),
      ],
      trendSegments: [
        TrendSegment(id: "age-6-40", seriesId: "sleep", fromIndex: 0, toIndex: 4, label: "Age 6 → 40"),
        TrendSegment(id: "age-40-75", seriesId: "sleep", fromIndex: 4, toIndex: 8, label: "Age 40 → 75"),
      ],
    ),
  ];

  final Map<String, dynamic> _i18n = {
    'en': {
      'appTitle': 'TALES BY DOTS AND LINES',
      'tagline': 'PLOT. READ. INTERPRET.',
      'initBtn': 'START MISSION',
      'headerTitle': 'Line Graph Plot & Interpret Lab',
      'boardTitle': 'Teacher Board',
      'objLabel': 'Mission Objective',
      'objDesc': 'Plot exact values and interpret line graph trends.',
      'stepInfoLabel': 'Current Step',
      'dataReadouts': 'Data Readouts',
      'sourceCardTitle': 'Source Data',
      'btnPrev': 'Prev', 'btnNext': 'Next',
      'msgMissionComplete': 'MISSION ACCOMPLISHED',
      'finalSubtitle': 'You built and read 6 line graphs and caught the trap.',
      'msgStepComplete': 'Step Complete!',
      'btnRestart': 'RESTART',
      'verifyBtn': 'VERIFY',
      
      // Errors
      'msgNeedSelectionCount': 'Pick exactly 3 states.',
      'msgNeedAllPoints': 'Place every point before VERIFY.',
      'msgPointsOff': 'Some points don\'t match the table.',
      'msgNeedReadings': 'Read all targets first.',
      'msgReadingsOff': 'A reading is off. Try again.',
      'msgNeedTrend': 'Classify every segment.',
      'msgNeedJudgement': 'Judge the claim.',
      
      // Chips
      'lblIncreasing': 'Increasing', 'lblDecreasing': 'Decreasing', 'lblFlat': 'Flat',
      'lblValid': 'Valid', 'lblInvalid': 'Invalid',
      'lblSelectSeries': 'Select 3 States', 'lblSelectedCount': 'Selected',
      'lblDragBuildHint': 'Drag point to match table height.',
      'lblDragReadHint': 'Drag crosshair to read target value.',
      'lblClassifySegment': 'Classify segment',
      'lblJudgeClaim': 'Is this claim valid?',
      'spaceJamClaim': '“World space objects always increased 2012–2024.”',
      'proofModalTitleTxt': 'The Trap', 'proceedBtn': 'PROCEED', 'closeBtn': 'CLOSE',
      'conceptLabel': 'Core Concepts',
      'concepts': [
        "Read continuous line graphs.",
        "Build line graphs from tables.",
        "Identify trends (increasing, flat, decreasing).",
        "Understand dual-axis graphs."
      ],
      'steps': [
        {'title': 'Step 1/6: Temperatures', 'instruction': 'Read 4 target temperatures, then classify 2 trends.'},
        {'title': 'Step 2/6: Shop Visitors', 'instruction': 'Plot exact table heights for Visiting and Purchasing.'},
        {'title': 'Step 3/6: Rainy Days', 'instruction': 'Plot 12 months for 3 cities at exact heights.'},
        {'title': 'Step 4/6: Salt Price', 'instruction': 'Select 3 states, then plot all 10 years.'},
        {'title': 'Step 5/6: Space Jam', 'instruction': 'Read 2023 and 2024 values, classify segment, and judge the claim.'},
        {'title': 'Step 6/6: Night Sleep', 'instruction': 'Read sleep hours at 3 ages, then classify both halves.'},
      ]
    },
    'hi': {
      'appTitle': 'बिंदुओं और रेखाओं की कहानी',
      'tagline': 'अंकित करें। पढ़ें। व्याख्या करें।',
      'initBtn': 'मिशन शुरू करें',
      'headerTitle': 'रेखा ग्राफ अंकन प्रयोगशाला',
      'boardTitle': 'शिक्षक बोर्ड',
      'objLabel': 'उद्देश्य',
      'objDesc': 'सटीक मान अंकित करें और प्रवृत्तियों को समझें।',
      'conceptLabel': 'मुख्य अवधारणाएं',
      'concepts': [
        "निरंतर रेखा ग्राफ़ पढ़ें।",
        "तालिकाओं से रेखा ग्राफ़ बनाएं।",
        "रुझानों (बढ़ना, स्थिर, घटना) की पहचान करें।",
        "दोहरे-अक्ष ग्राफ़ को समझें।"
      ],
      'stepInfoLabel': 'वर्तमान चरण',
      'dataReadouts': 'डेटा रीडआउट्स',
      'sourceCardTitle': 'स्रोत डेटा',
      'btnPrev': 'पिछला', 'btnNext': 'अगला',
      'msgMissionComplete': 'मिशन पूरा हुआ',
      'finalSubtitle': 'आपने 6 ग्राफ बनाए और झांसा पकड़ा।',
      'msgStepComplete': 'चरण पूर्ण!',
      'btnRestart': 'पुनः आरंभ',
      'verifyBtn': 'सत्यापित करें',
      
      'msgNeedSelectionCount': 'ठीक 3 राज्य चुनें।',
      'msgNeedAllPoints': 'सभी बिंदु रखें।',
      'msgPointsOff': 'सटीक मिलान करें।',
      'msgNeedReadings': 'सभी लक्ष्य पढ़ें।',
      'msgReadingsOff': 'रीडिंग गलत है।',
      'msgNeedTrend': 'खंडों को वर्गीकृत करें।',
      'msgNeedJudgement': 'दावे को परखें।',
      
      'lblIncreasing': 'बढ़ता', 'lblDecreasing': 'घटता', 'lblFlat': 'समान',
      'lblValid': 'वैध', 'lblInvalid': 'अमान्य',
      'lblSelectSeries': '3 राज्य चुनें', 'lblSelectedCount': 'चुना गया',
      'lblDragBuildHint': 'ऊंचाई तक खींचें।',
      'lblDragReadHint': 'मान तक खींचें।',
      'lblClassifySegment': 'वर्गीकृत करें',
      'lblJudgeClaim': 'दावा सही है?',
      'spaceJamClaim': '“2012–24 अंतरिक्ष वस्तुएं हमेशा बढ़ती रहीं।”',
      'proofModalTitleTxt': 'झांसा', 'proceedBtn': 'आगे बढ़ें', 'closeBtn': 'बंद करें',
      
      'steps': [
        {'title': 'चरण 1/6: तापमान', 'instruction': '4 तापमान पढ़ें, 2 प्रवृत्तियां जांचें।'},
        {'title': 'चरण 2/6: आगंतुक', 'instruction': 'सटीक बिंदु अंकित करें।'},
        {'title': 'चरण 3/6: वर्षा', 'instruction': '12 महीने अंकित करें।'},
        {'title': 'चरण 4/6: नमक मूल्य', 'instruction': '3 राज्य, 10 वर्ष अंकित करें।'},
        {'title': 'चरण 5/6: स्पेस जैम', 'instruction': '2023-24 पढ़ें, दावा परखें।'},
        {'title': 'चरण 6/6: नींद', 'instruction': '3 आयु पर नींद पढ़ें, वर्गीकृत करें।'},
      ]
    }
  };

  // Toast / Messages state
  String? toastMessage;
  Color toastColor = Colors.transparent;
  IconData? toastIcon;

  // Interaction State
  DragState? activeDrag;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _shutterController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _shutterAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOutQuart)
    );

    _loadStep(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _shutterController.dispose();
    _transformationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String t(String key) => _i18n[currentLang][key] ?? key;
  String tStep(int stepIndex, String key) => (_i18n[currentLang]['steps'] as List)[stepIndex][key];

  void _playSound(String type) async {
    try {
      // Using the bundled sound effects in assets/audio/class8/ for the exact requirement
      String url = '';
      if (type == 'intro') {
        url = 'audio/class8/mixkit_2018.mp3';
      } else if (type == 'click') url = 'audio/class8/mixkit_2568.mp3';
      else if (type == 'success') url = 'audio/class8/mixkit_2000.mp3';
      else if (type == 'error') url = 'audio/class8/mixkit_2955.mp3';
      else if (type == 'pop') url = 'audio/class8/mixkit_2972.mp3';
      
      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url), mode: PlayerMode.lowLatency);
      }
    } catch (e) {
      // Ignore audio errors if offline
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    setState(() {
      toastMessage = msg;
      toastColor = isError ? AppColors.error : AppColors.success;
      toastIcon = isError ? Icons.warning_amber_rounded : Icons.check_circle;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && toastMessage == msg) {
        setState(() => toastMessage = null);
      }
    });
  }

  void _loadStep(int stepIndex) {
    setState(() {
      currentStep = stepIndex;
      stepState = StepStateData();
      final sc = _scenarios[currentStep];
      if (sc.mode == 'read' && sc.readingTargets != null && sc.readingTargets!.isNotEmpty) {
        stepState.activeTargetId = sc.readingTargets![0].id;
        stepState.activeSeriesId = sc.readingTargets![0].seriesId;
      }
      _transformationController.value = Matrix4.identity(); // reset zoom
    });
  }

  void _toggleSidebar() {
    _playSound('click');
    setState(() => isSidebarOpen = !isSidebarOpen);
  }

  void _toggleLanguage() {
    _playSound('click');
    setState(() => currentLang = currentLang == 'en' ? 'hi' : 'en');
  }

  void _validateStep() {
    final sc = _scenarios[currentStep];
    if (sc.mode == 'build') {
      if (sc.selectedSeriesCount != null && stepState.selectedSeriesIds.length != sc.selectedSeriesCount) {
        _playSound('error');
        _showToast(t('msgNeedSelectionCount'), isError: true);
        return;
      }
      
      final seriesList = sc.selectedSeriesCount != null 
          ? sc.series.where((s) => stepState.selectedSeriesIds.contains(s.id)).toList()
          : sc.series;
          
      int totalNeeded = seriesList.fold(0, (sum, s) => sum + (s.table?.length ?? 0));
      int placed = stepState.plottedPoints.length;
      if (placed < totalNeeded) {
        _playSound('error');
        _showToast(t('msgNeedAllPoints'), isError: true);
        return;
      }

      bool isMismatch = false;
      for (var s in seriesList) {
        for (int i = 0; i < s.table!.length; i++) {
          double? plottedVal = stepState.plottedPoints["${s.id}_$i"];
          if (plottedVal == null || (plottedVal - s.table![i]).abs() > 0.1) {
            isMismatch = true;
          }
        }
      }

      if (isMismatch) {
        _playSound('error');
        _showToast(t('msgPointsOff'), isError: true);
        return;
      }
    } else {
      // Read Mode
      for (var rt in sc.readingTargets ?? []) {
        if (!stepState.readings.containsKey(rt.id)) {
          _playSound('error');
          _showToast(t('msgNeedReadings'), isError: true);
          return;
        }
        final s = sc.series.firstWhere((s) => s.id == rt.seriesId);
        final trueVal = s.data![rt.categoryIndex];
        if ((stepState.readings[rt.id]! - trueVal).abs() > rt.tol) {
          _playSound('error');
          _showToast(t('msgReadingsOff'), isError: true);
          return;
        }
      }

      for (var ts in sc.trendSegments ?? []) {
        if (!stepState.trendChips.containsKey(ts.id)) {
          _playSound('error');
          _showToast(t('msgNeedTrend'), isError: true);
          return;
        }
        
        // Derive correctness
        final s = sc.series.firstWhere((s) => s.id == ts.seriesId);
        final startVal = s.data![ts.fromIndex];
        final endVal = s.data![ts.toIndex];
        String expected = "flat";
        if (endVal > startVal) {
          expected = "increasing";
        } else if (endVal < startVal) expected = "decreasing";

        if (stepState.trendChips[ts.id] != expected) {
          _playSound('error');
          _showToast(t('msgWrong'), isError: true);
          return;
        }
      }

      for (var jc in sc.judgementChips ?? []) {
        if (!stepState.judgements.containsKey(jc)) {
          _playSound('error');
          _showToast(t('msgNeedJudgement'), isError: true);
          return;
        }
        // Logic specific to step 5 trap
        if (jc == 'always-increasing' && stepState.judgements[jc] == true) {
          _playSound('error');
          _showToast(t('msgWrong'), isError: true);
          return;
        }
      }
    }

    _playSound('success');
    _showToast(t('msgStepComplete'));

    if (sc.id == 'EX-L-05') {
      // Show Proof Modal for the trap
      _showProofModal();
    } else {
      _advanceStep();
    }
  }

  void _advanceStep() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (currentStep < _scenarios.length - 1) {
        _loadStep(currentStep + 1);
      } else {
        setState(() => isCompleted = true);
        _playSound('success');
      }
    });
  }

  void _showProofModal() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.accent)),
        title: Text(t('proofModalTitleTxt'), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('spaceJamClaim'), style: const TextStyle(color: AppColors.subtext, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            const Text("World 2023 ≈ 2900 \nWorld 2024 ≈ 2800", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            const Text("2800 < 2900. The segment is decreasing. The claim is invalid.", style: TextStyle(color: AppColors.subtext)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () {
              Navigator.pop(ctx);
              _advanceStep();
            },
            child: Text(t('proceedBtn'), style: const TextStyle(color: AppColors.bg, fontWeight: FontWeight.bold)),
          )
        ],
      );
    });
  }

  Widget _buildToast() {
    if (toastMessage == null) return const SizedBox.shrink();
    return Positioned(
      top: 24, left: 0, right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.panel.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: toastColor, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(toastIcon, color: toastColor, size: 28),
              const SizedBox(width: 12),
              Text(toastMessage!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // Handle Graph Gestures
  void _onCanvasPanUpdate(DragUpdateDetails details, Size canvasSize, Scenario sc) {
    if (activeDrag == null) return;
    
    // Convert local position to data coordinate
    final rect = Rect.fromLTWH(60, 40, canvasSize.width - 100, canvasSize.height - 100);
    double y = rect.bottom - details.localPosition.dy;
    double val = sc.yMin + (y / rect.height) * (sc.yMax - sc.yMin);

    if (activeDrag!.type == DragType.point) {
      val = math.max(sc.yMin, math.min(sc.yMax, val));
      
      // Magnetic snap
      final s = sc.series.firstWhere((s) => s.id == activeDrag!.seriesId);
      final targetVal = s.table![activeDrag!.catIndex];
      final threshold = (sc.yMax - sc.yMin) * 0.05;
      if ((val - targetVal).abs() <= threshold) {
        val = targetVal;
      } else {
        val = (val * 10).roundToDouble() / 10;
      }
      
      setState(() {
        stepState.plottedPoints["${s.id}_${activeDrag!.catIndex}"] = val;
      });
    } else if (activeDrag!.type == DragType.crosshair) {
      double x = details.localPosition.dx - rect.left;
      double catRatio = x / rect.width;
      double catFloat = math.max(0, math.min(sc.categories.length - 1, catRatio * (sc.categories.length - 1)));
      
      final s = sc.series.firstWhere((s) => s.id == activeDrag!.seriesId);
      int idx0 = catFloat.floor();
      int idx1 = math.min(idx0 + 1, sc.categories.length - 1);
      double frac = catFloat - idx0;
      double interpolatedVal = s.data![idx0] + (s.data![idx1] - s.data![idx0]) * frac;

      setState(() {
        activeDrag!.catFloat = catFloat;
        activeDrag!.interpolatedValue = interpolatedVal;
      });
    }
  }

  void _onCanvasPanStart(DragStartDetails details, Size canvasSize, Scenario sc) {
    final rect = Rect.fromLTWH(60, 40, canvasSize.width - 100, canvasSize.height - 100);
    
    if (sc.mode == 'build') {
      final seriesList = sc.selectedSeriesCount != null 
          ? sc.series.where((s) => stepState.selectedSeriesIds.contains(s.id)).toList()
          : sc.series;

      // Find closest dock or point
      for (var s in seriesList) {
        for (int i = 0; i < sc.categories.length; i++) {
          if (s.table != null && i < s.table!.length) {
            double currentVal = stepState.plottedPoints["${s.id}_$i"] ?? sc.yMin - (sc.yMax - sc.yMin) * 0.1; // Dock is slightly below
            
            double px = rect.left + (i / (sc.categories.length - 1)) * rect.width;
            double py = rect.bottom - ((currentVal - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;
            
            if ((Offset(px, py) - details.localPosition).distance < 40) { // Hit test radius
              _playSound('click');
              setState(() {
                activeDrag = DragState(type: DragType.point, seriesId: s.id, catIndex: i);
              });
              return;
            }
          }
        }
      }
    } else if (sc.mode == 'read') {
      if (stepState.activeSeriesId == null) return;
      
      final s = sc.series.firstWhere((s) => s.id == stepState.activeSeriesId);
      double catFloat = activeDrag?.catFloat ?? 0.0;
      int idx0 = catFloat.floor();
      int idx1 = math.min(idx0 + 1, sc.categories.length - 1);
      double frac = catFloat - idx0;
      double currentVal = s.data![idx0] + (s.data![idx1] - s.data![idx0]) * frac;

      double px = rect.left + (catFloat / (sc.categories.length - 1)) * rect.width;
      double py = rect.bottom - ((currentVal - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;

      if ((Offset(px, py) - details.localPosition).distance < 50) {
        _playSound('click');
        setState(() {
          activeDrag = DragState(type: DragType.crosshair, seriesId: stepState.activeSeriesId!);
          activeDrag!.catFloat = catFloat;
          activeDrag!.interpolatedValue = currentVal;
        });
      }
    }
  }

  void _onCanvasPanEnd(DragEndDetails details, Scenario sc) {
    if (activeDrag == null) return;

    if (activeDrag!.type == DragType.point) {
      _playSound('pop');
    } else if (activeDrag!.type == DragType.crosshair) {
      // Check if snapped to target
      int nearestIdx = activeDrag!.catFloat.round();
      if ((activeDrag!.catFloat - nearestIdx).abs() <= 0.15) {
        var target = sc.readingTargets?.where((t) => t.id == stepState.activeTargetId).firstOrNull;
        if (target != null && target.categoryIndex == nearestIdx && target.seriesId == activeDrag!.seriesId) {
          final s = sc.series.firstWhere((s) => s.id == target.seriesId);
          setState(() {
            stepState.readings[target.id] = s.data![nearestIdx];
            // Auto advance target
            var nextTarget = sc.readingTargets?.where((t) => !stepState.readings.containsKey(t.id)).firstOrNull;
            if (nextTarget != null) {
              stepState.activeTargetId = nextTarget.id;
              stepState.activeSeriesId = nextTarget.seriesId;
            }
          });
          _playSound('pop');
        }
      }
    }

    setState(() => activeDrag = null);
  }

  Widget _buildCanvas(Scenario sc) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = Size(math.max(800, constraints.maxWidth), math.max(600, constraints.maxHeight));
        return InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(1000),
          minScale: 0.5,
          maxScale: 3.0,
          panEnabled: activeDrag == null,
          scaleEnabled: activeDrag == null,
          child: Listener(
            onPointerDown: (event) => _onCanvasPanStart(DragStartDetails(globalPosition: event.position, localPosition: event.localPosition), size, sc),
            onPointerMove: (event) {
              if (activeDrag != null) {
                _onCanvasPanUpdate(DragUpdateDetails(globalPosition: event.position, localPosition: event.localPosition, delta: event.delta), size, sc);
              }
            },
            onPointerUp: (event) {
              if (activeDrag != null) _onCanvasPanEnd(DragEndDetails(), sc);
            },
            child: CustomPaint(
              size: size,
              painter: GraphPainter(
                sc: sc, 
                stepState: stepState,
                activeDrag: activeDrag,
                themeColor: AppColors.text,
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildSidebar(Scenario sc) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: isSidebarOpen ? 0 : -MediaQuery.of(context).size.width * 0.35,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel.withOpacity(0.95),
          border: const Border(right: BorderSide(color: AppColors.border, width: 2)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 32), // Space for menu toggle button overlay
            Text(t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(t('tagline'), style: const TextStyle(color: AppColors.accent, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.border),
                    onPressed: _toggleLanguage,
                    icon: const Icon(Icons.language, color: AppColors.text, size: 16),
                    label: Text(currentLang == 'en' ? 'English' : 'हिंदी', style: const TextStyle(color: AppColors.text)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.border),
                    onPressed: () { 
                      _playSound('click'); 
                      setState(() {
                        currentLang = 'en';
                        showSplash = true;
                        _shutterController.reverse();
                        _loadStep(0);
                      });
                    },
                    icon: const Icon(Icons.refresh, color: AppColors.warning, size: 16),
                    label: Text(t('btnRestart'), style: const TextStyle(color: AppColors.warning)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(t('objLabel').toUpperCase(), style: const TextStyle(color: AppColors.subtext, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t('objDesc'), style: const TextStyle(color: AppColors.text, fontSize: 14)),
            const SizedBox(height: 16),
            
            Text(t('conceptLabel').toUpperCase(), style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...((_i18n[currentLang]['concepts'] as List).map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 14))),
                  ],
                ),
              ),
            )).toList()),
            const SizedBox(height: 16),
            
            Text(t('stepInfoLabel').toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tStep(currentStep, 'title'), style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(tStep(currentStep, 'instruction'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSourceTable(sc),
            
            // Controls
            _buildControls(sc),
            const SizedBox(height: 24),
            
            // Validate / Nav Buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _validateStep,
              child: Text(t('verifyBtn'), style: const TextStyle(color: AppColors.bg, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentStep > 0 ? () { _playSound('click'); _loadStep(currentStep - 1); } : null,
                    child: Text(t('btnPrev'), style: const TextStyle(color: AppColors.text)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentStep < _scenarios.length - 1 ? () { _playSound('click'); _loadStep(currentStep + 1); } : null,
                    child: Text(t('btnNext'), style: const TextStyle(color: AppColors.text)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              alignment: Alignment.center,
              child: const Text("© ZeroScienceLab - Fall in love with math and Science", style: TextStyle(color: AppColors.subtext, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTable(Scenario sc) {
    List<TableRow> rows = [];
    
    // Header Row
    List<Widget> headerCells = [
      const Padding(padding: EdgeInsets.all(8), child: Text(''))
    ];
    for (var c in sc.categories) {
      headerCells.add(Padding(
        padding: const EdgeInsets.all(8),
        child: Text(c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)
      ));
    }
    rows.add(TableRow(
      decoration: const BoxDecoration(color: Colors.black26),
      children: headerCells
    ));
    
    // Data Rows
    for (var s in sc.series) {
      List<double> dataList = sc.mode == 'build' ? (s.table ?? []) : (s.data ?? []);
      if (dataList.isEmpty) continue;
      
      List<Widget> cells = [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(s.label, style: TextStyle(color: s.color, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.left)
        )
      ];
      for (var v in dataList) {
        cells.add(Padding(
          padding: const EdgeInsets.all(8),
          child: Text(v.toString(), style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)
        ));
      }
      rows.add(TableRow(children: cells));
    }

    if (rows.length == 1) return const SizedBox(); // No data rows
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('sourceCardTitle').toUpperCase(), style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: const TableBorder.symmetric(inside: BorderSide(color: Colors.white12)),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: rows,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildControls(Scenario sc) {
    List<Widget> items = [];

    if (sc.mode == 'build') {
      if (sc.selectedSeriesCount != null) {
        items.add(Text("${t('lblSelectSeries')} (${t('lblSelectedCount')}: ${stepState.selectedSeriesIds.length}/${sc.selectedSeriesCount})", style: const TextStyle(color: AppColors.subtext, fontSize: 12, fontWeight: FontWeight.bold)));
        items.add(const SizedBox(height: 8));
        items.add(Wrap(
          spacing: 8, runSpacing: 8,
          children: sc.series.map((s) {
            bool picked = stepState.selectedSeriesIds.contains(s.id);
            bool disabled = !picked && stepState.selectedSeriesIds.length >= sc.selectedSeriesCount!;
            return FilterChip(
              label: Text(s.label),
              selected: picked,
              selectedColor: s.color.withOpacity(0.3),
              checkmarkColor: s.color,
              onSelected: disabled ? null : (v) {
                _playSound('click');
                setState(() {
                  if (v) {
                    stepState.selectedSeriesIds.add(s.id);
                  } else {
                    stepState.selectedSeriesIds.remove(s.id);
                    stepState.plottedPoints.removeWhere((k, _) => k.startsWith("${s.id}_"));
                  }
                });
              },
            );
          }).toList()
        ));
      }
      items.add(const SizedBox(height: 12));
      items.add(Text(t('lblDragBuildHint'), style: const TextStyle(color: AppColors.subtext, fontSize: 12)));
    } else {
      // Read Mode Targets
      if (sc.readingTargets != null) {
        for (var rt in sc.readingTargets!) {
          bool done = stepState.readings.containsKey(rt.id);
          bool active = stepState.activeTargetId == rt.id;
          items.add(
            GestureDetector(
              onTap: () {
                _playSound('click');
                setState(() { stepState.activeTargetId = rt.id; stepState.activeSeriesId = rt.seriesId; });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active ? AppColors.warning.withOpacity(0.15) : (done ? AppColors.success.withOpacity(0.1) : Colors.black26),
                  border: Border.all(color: active ? AppColors.warning : (done ? AppColors.success : AppColors.border)),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  children: [
                    Icon(done ? Icons.check_circle : Icons.gps_fixed, color: done ? AppColors.success : AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(rt.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Text(done ? "${stepState.readings[rt.id]!.toStringAsFixed(1)} ${sc.yUnit}" : t('lblTargetPending'), style: const TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          );
        }
        items.add(Text(t('lblDragReadHint'), style: const TextStyle(color: AppColors.subtext, fontSize: 12)));
        items.add(const SizedBox(height: 16));
      }

      // Trend Chips
      if (sc.trendSegments != null) {
        for (var ts in sc.trendSegments!) {
          items.add(Text("${t('lblClassifySegment')}: ${ts.label}", style: const TextStyle(color: AppColors.subtext, fontSize: 12, fontWeight: FontWeight.bold)));
          items.add(const SizedBox(height: 8));
          items.add(Wrap(
            spacing: 8,
            children: ['increasing', 'decreasing', 'flat'].map((val) {
              bool selected = stepState.trendChips[ts.id] == val;
              String lblKey = val == 'increasing' ? 'lblIncreasing' : (val == 'decreasing' ? 'lblDecreasing' : 'lblFlat');
              return ChoiceChip(
                label: Text(t(lblKey)),
                selected: selected,
                selectedColor: AppColors.accent.withOpacity(0.3),
                onSelected: (v) {
                  _playSound('click');
                  setState(() => stepState.trendChips[ts.id] = val);
                },
              );
            }).toList()
          ));
          items.add(const SizedBox(height: 16));
        }
      }

      // Judgement Chips
      if (sc.judgementChips != null) {
        for (var jc in sc.judgementChips!) {
          items.add(Text(t('lblJudgeClaim'), style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)));
          items.add(Text(t('spaceJamClaim'), style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)));
          items.add(const SizedBox(height: 8));
          items.add(Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(t('lblValid')),
                selected: stepState.judgements[jc] == true,
                selectedColor: AppColors.accent.withOpacity(0.3),
                onSelected: (v) { _playSound('click'); setState(() => stepState.judgements[jc] = true); },
              ),
              ChoiceChip(
                label: Text(t('lblInvalid')),
                selected: stepState.judgements[jc] == false,
                selectedColor: AppColors.accent.withOpacity(0.3),
                onSelected: (v) { _playSound('click'); setState(() => stepState.judgements[jc] = false); },
              )
            ],
          ));
        }
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }

  @override
  Widget build(BuildContext context) {
    final sc = _scenarios[currentStep];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(fit: StackFit.expand,
          children: [
            // Center Canvas
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.only(left: isSidebarOpen ? MediaQuery.of(context).size.width * 0.35 : 0),
                child: _buildCanvas(sc),
              ),
            ),
            
            // Left Sidebar
            _buildSidebar(sc),

            // Top Left Menu Toggle
            Positioned(
              top: 16, left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent)
                ),
                child: IconButton(
                  icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu, color: AppColors.accent),
                  onPressed: _toggleSidebar,
                ),
              ),
            ),

            // Toast
            _buildToast(),

            // Success Completion Overlay
            if (isCompleted)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, size: 80, color: AppColors.warning),
                        const SizedBox(height: 16),
                        Text(t('msgMissionComplete'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(t('finalSubtitle'), style: const TextStyle(color: AppColors.subtext, fontSize: 18)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          onPressed: () {
                            _playSound('click');
                            setState(() { isCompleted = false; _loadStep(0); });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: Text(t('btnRestart'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            // Shutter Intro
            if (showSplash)
              SlideTransition(
                position: _shutterAnimation,
                child: Container(
                  color: AppColors.bg,
                  width: double.infinity, height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.show_chart, size: 80, color: AppColors.accent),
                        const SizedBox(height: 16),
                        Text(t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(t('tagline'), style: const TextStyle(color: AppColors.accent, fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            _playSound('intro');
                            _shutterController.forward().then((_) => setState(() => showSplash = false));
                          },
                          icon: const Icon(Icons.play_arrow, color: AppColors.bg),
                          label: Text(t('initBtn'), style: const TextStyle(color: AppColors.bg, fontSize: 20, fontWeight: FontWeight.bold)),
                        )
                      ],
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

/// Helper Enums
enum DragType { point, crosshair }

class DragState {
  final DragType type;
  final String seriesId;
  final int catIndex; // used for point
  double catFloat; // used for crosshair
  double interpolatedValue; // used for crosshair

  DragState({required this.type, required this.seriesId, this.catIndex = 0, this.catFloat = 0.0, this.interpolatedValue = 0.0});
}

/// Custom Graph Painter
class GraphPainter extends CustomPainter {
  final Scenario sc;
  final StepStateData stepState;
  final DragState? activeDrag;
  final Color themeColor;

  GraphPainter({required this.sc, required this.stepState, this.activeDrag, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(60, 40, size.width - 100, size.height - 100);
    
    // Draw Grid & Axes
    final gridPaint = Paint()..color = AppColors.border..strokeWidth = 1;
    final axisPaint = Paint()..color = AppColors.subtext..strokeWidth = 2;
    
    // Y Grid lines
    for (double v = sc.yMin; v <= sc.yMax; v += sc.yStep) {
      double y = rect.bottom - ((v - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
      
      TextPainter tp = TextPainter(
        text: TextSpan(text: "${v == v.toInt() ? v.toInt() : v.toStringAsFixed(1)} ${sc.yUnit}", style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.left - tp.width - 10, y - tp.height / 2));
    }

    // X Grid lines & categories
    for (int i = 0; i < sc.categories.length; i++) {
      double x = rect.left + (i / (sc.categories.length - 1)) * rect.width;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
      
      TextPainter tp = TextPainter(
        text: TextSpan(text: sc.categories[i], style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, rect.bottom + 10));
    }

    // Axes bounds
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.right, rect.bottom), axisPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left, rect.top), axisPaint);

    // Plot Series Data
    if (sc.mode == 'build') {
      final seriesList = sc.selectedSeriesCount != null 
          ? sc.series.where((s) => stepState.selectedSeriesIds.contains(s.id)).toList()
          : sc.series;

      for (var s in seriesList) {
        final linePaint = Paint()..color = s.color.withOpacity(0.5)..strokeWidth = 4..style = PaintingStyle.stroke;
        final pointPaint = Paint()..color = s.color..style = PaintingStyle.fill;
        
        List<Offset> points = [];
        for (int i = 0; i < sc.categories.length; i++) {
          if (stepState.plottedPoints.containsKey("${s.id}_$i")) {
            double v = stepState.plottedPoints["${s.id}_$i"]!;
            double px = rect.left + (i / (sc.categories.length - 1)) * rect.width;
            double py = rect.bottom - ((v - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;
            points.add(Offset(px, py));
            canvas.drawCircle(Offset(px, py), 8, pointPaint);
          }
        }
        
        // Draw Connecting Lines
        for (int j = 0; j < points.length - 1; j++) {
          canvas.drawLine(points[j], points[j+1], linePaint);
        }

        // Draw active drag dock or hint
        if (activeDrag?.type == DragType.point && activeDrag?.seriesId == s.id) {
          // Label above point
          double v = stepState.plottedPoints["${s.id}_${activeDrag!.catIndex}"] ?? sc.yMin;
          double px = rect.left + (activeDrag!.catIndex / (sc.categories.length - 1)) * rect.width;
          double py = rect.bottom - ((v - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;
          
          canvas.drawCircle(Offset(px, py), 12, Paint()..color = Colors.white.withOpacity(0.5));
          
          TextPainter tp = TextPainter(
            text: TextSpan(text: v.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(px - tp.width/2, py - 30));
        } else {
          // Draw docks for missing points
          for (int i = 0; i < sc.categories.length; i++) {
            if (!stepState.plottedPoints.containsKey("${s.id}_$i") && s.table != null && i < s.table!.length) {
              double px = rect.left + (i / (sc.categories.length - 1)) * rect.width;
              double py = rect.bottom + 20; // Dock area slightly below X axis
              canvas.drawCircle(Offset(px, py), 8, Paint()..color = s.color.withOpacity(0.5));
              // Just draw the first missing point as dock to guide them linearly like the HTML does
              break; 
            }
          }
        }
      }
    } else if (sc.mode == 'read') {
      // Draw Static Lines
      for (var s in sc.series) {
        final linePaint = Paint()..color = s.color..strokeWidth = 4..style = PaintingStyle.stroke;
        final pointPaint = Paint()..color = s.color..style = PaintingStyle.fill;
        List<Offset> pts = [];
        
        for (int i = 0; i < s.data!.length; i++) {
          double px = rect.left + (i / (sc.categories.length - 1)) * rect.width;
          double py = rect.bottom - ((s.data![i] - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;
          pts.add(Offset(px, py));
          canvas.drawCircle(Offset(px, py), 6, pointPaint);
        }
        
        Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
        for (int j = 1; j < pts.length; j++) {
          path.lineTo(pts[j].dx, pts[j].dy);
        }
        canvas.drawPath(path, linePaint);
      }

      // Draw Crosshair
      if (stepState.activeSeriesId != null) {
        double catFloat = activeDrag?.catFloat ?? 0.0;
        double currentVal = activeDrag?.interpolatedValue ?? sc.series.firstWhere((s)=>s.id == stepState.activeSeriesId).data![0];
        
        double px = rect.left + (catFloat / (sc.categories.length - 1)) * rect.width;
        double py = rect.bottom - ((currentVal - sc.yMin) / (sc.yMax - sc.yMin)) * rect.height;
        
        canvas.drawLine(Offset(px, rect.top), Offset(px, rect.bottom), Paint()..color = AppColors.crosshair.withOpacity(0.5)..strokeWidth = 2);
        canvas.drawLine(Offset(rect.left, py), Offset(rect.right, py), Paint()..color = AppColors.crosshair.withOpacity(0.5)..strokeWidth = 2);
        
        canvas.drawCircle(Offset(px, py), 10, Paint()..color = AppColors.crosshair);
        canvas.drawCircle(Offset(px, py), 14, Paint()..color = AppColors.crosshair.withOpacity(0.3));

        // Label
        int idxRounded = catFloat.round();
        String catStr = sc.categories[math.max(0, math.min(sc.categories.length-1, idxRounded))];
        TextPainter tp = TextPainter(
          text: TextSpan(text: "$catStr ≈ ${currentVal.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(px + 15, py - 15));
      }
    }
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) => true;
}
