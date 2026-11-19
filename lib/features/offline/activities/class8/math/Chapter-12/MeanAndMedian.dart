// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class MeanAndMedianActivity extends StatefulWidget {
  const MeanAndMedianActivity({super.key});

  @override
  State<MeanAndMedianActivity> createState() => _MeanAndMedianActivityState();
}

class ScenarioConfig {
  final String id;
  final String mode; // 'bars', 'dials', 'freq'
  final List<double> baseTargets;
  final int insertCount;
  final bool hasUnknown;
  final double? targetMean;
  final double maxVal;
  final bool showRibbons;
  final bool showMedianSort;
  
  final double targetReportedAverage;
  final int targetTreeCount;
  final double errorOffset;
  final double avgMin;
  final double avgMax;
  final double avgStep;
  final int countMin;
  final int countMax;

  final List<int> freqValues;
  final List<int> freqTargets;
  final int maxFreq;

  ScenarioConfig({
    required this.id,
    required this.mode,
    this.baseTargets = const [],
    this.insertCount = 0,
    this.hasUnknown = false,
    this.targetMean,
    this.maxVal = 20,
    this.showRibbons = false,
    this.showMedianSort = false,
    
    this.targetReportedAverage = 0,
    this.targetTreeCount = 0,
    this.errorOffset = 0,
    this.avgMin = 0,
    this.avgMax = 100,
    this.avgStep = 1,
    this.countMin = 0,
    this.countMax = 100,

    this.freqValues = const [],
    this.freqTargets = const [],
    this.maxFreq = 20,
  });
}

class BarData {
  String id;
  double value;
  String role; // 'base', 'inserted', 'unknown'
  BarData({required this.id, required this.value, required this.role});
}

class FreqData {
  int value;
  int frequency;
  FreqData({required this.value, required this.frequency});
}

class _MeanAndMedianActivityState extends State<MeanAndMedianActivity> {
  int currentStep = 0; // 0 to 9
  String language = 'EN';
  bool isSidebarOpen = true;
  bool isShutterOpen = false;
  bool showSuccess = false;

  // State
  List<BarData> bars = [];
  List<FreqData> freqBars = [];
  double reportedAverage = 20.0;
  int treeCount = 5;
  bool medianSortOn = false;

  final List<ScenarioConfig> scenarios = [
    ScenarioConfig(id: "EX-M-01", mode: "bars", baseTargets: [3, 7], maxVal: 16),
    ScenarioConfig(id: "EX-M-02", mode: "bars", baseTargets: [6, 7, 8], maxVal: 16, showRibbons: true),
    ScenarioConfig(id: "EX-M-04", mode: "bars", baseTargets: [10, 10, 11, 17], maxVal: 24, showRibbons: true),
    ScenarioConfig(id: "EX-M-07", mode: "bars", baseTargets: [6, 6, 10, 22], insertCount: 1, maxVal: 28),
    ScenarioConfig(id: "EX-M-08", mode: "bars", baseTargets: [9, 9, 9], insertCount: 3, maxVal: 18),
    ScenarioConfig(id: "EX-M-12", mode: "bars", baseTargets: [42, 40, 39, 33, 48, 38, 42, 35, 32], targetMean: 39.2, hasUnknown: true, maxVal: 56),
    ScenarioConfig(id: "EX-M-13", mode: "dials", targetReportedAverage: 25.6, targetTreeCount: 15, errorOffset: 3, avgMin: 20, avgMax: 30, avgStep: 0.1, countMin: 5, countMax: 25),
    ScenarioConfig(id: "EX-M-11", mode: "bars", baseTargets: [3, 7, 8, 11, 13], insertCount: 1, maxVal: 20, showMedianSort: true),
    ScenarioConfig(id: "EX-M-14", mode: "freq", freqValues: [3, 4, 5, 6, 7, 8, 9, 10], freqTargets: [3, 11, 9, 7, 3, 1, 1, 1], maxFreq: 14),
    ScenarioConfig(id: "FIO-7", mode: "bars", baseTargets: [8, 13, 10, 4, 5, 20, 10], targetMean: 10.375, hasUnknown: true, maxVal: 26),
  ];

  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  
  static const String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class8/mixkit_2018.mp3';
  static const String _shutterUrl = 'audio/class8/mixkit_2574.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    super.dispose();
  }

  void playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _loadScenario(int index) {
    ScenarioConfig sc = scenarios[index];
    bars.clear();
    freqBars.clear();
    medianSortOn = false;
    
    if (sc.mode == 'bars') {
      for (int i = 0; i < sc.baseTargets.length; i++) {
        bars.add(BarData(id: 'base_$i', value: 0, role: 'base'));
      }
      if (sc.hasUnknown) {
        bars.add(BarData(id: 'unknown_0', value: 0, role: 'unknown'));
      }
    } else if (sc.mode == 'dials') {
      reportedAverage = 20.0;
      treeCount = 5;
    } else if (sc.mode == 'freq') {
      for (int i = 0; i < sc.freqValues.length; i++) {
        freqBars.add(FreqData(value: sc.freqValues[i], frequency: 0));
      }
    }
  }

  void resetLab() {
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentStep = 0;
      showSuccess = false;
      isShutterOpen = false;
      language = 'EN';
      _loadScenario(currentStep);
    });
  }

  void toggleLanguage(String newLang) {
    if (language == newLang) return;
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      language = newLang;
    });
  }

  void insertBar() {
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      bars.add(BarData(id: 'inserted_${bars.length}', value: 0, role: 'inserted'));
    });
  }

  void adjustFreq(int value, int delta) {
    playSound(_clickPlayer, _clickUrl);
    setState(() {
      for (var f in freqBars) {
        if (f.value == value) {
          f.frequency = math.max(0, math.min(scenarios[currentStep].maxFreq, f.frequency + delta));
        }
      }
    });
  }

  // --- DERIVATIONS ---
  double get derivedMean {
    ScenarioConfig sc = scenarios[currentStep];
    if (sc.mode == 'freq') {
      double sum = 0; int count = 0;
      for (var f in freqBars) { sum += (f.value * f.frequency); count += f.frequency; }
      return count == 0 ? 0 : sum / count;
    }
    if (bars.isEmpty) return 0;
    double sum = bars.fold(0.0, (prev, b) => prev + b.value);
    return sum / bars.length;
  }

  double get derivedMedian {
    ScenarioConfig sc = scenarios[currentStep];
    List<double> vals = [];
    if (sc.mode == 'freq') {
      for (var f in freqBars) {
        for (int i = 0; i < f.frequency; i++) {
          vals.add(f.value.toDouble());
        }
      }
    } else {
      vals = bars.map((b) => b.value).toList();
    }
    if (vals.isEmpty) return 0;
    vals.sort();
    int mid = vals.length ~/ 2;
    if (vals.length % 2 != 0) return vals[mid];
    return (vals[mid - 1] + vals[mid]) / 2.0;
  }
  
  double get derivedSum {
    ScenarioConfig sc = scenarios[currentStep];
    if (sc.mode == 'freq') {
      return freqBars.fold(0.0, (prev, f) => prev + (f.value * f.frequency));
    }
    return bars.fold(0.0, (prev, b) => prev + b.value);
  }

  int get derivedCount {
    if (scenarios[currentStep].mode == 'freq') {
      return freqBars.fold(0, (prev, f) => prev + f.frequency);
    }
    return bars.length;
  }

  double get derivedLhsSum {
    double m = derivedMean;
    return bars.where((b) => b.value < m).fold(0.0, (prev, b) => prev + (m - b.value));
  }

  double get derivedRhsSum {
    double m = derivedMean;
    return bars.where((b) => b.value > m).fold(0.0, (prev, b) => prev + (b.value - m));
  }

  double get baseMean {
    var baseBars = bars.where((b) => b.role == 'base').toList();
    if (baseBars.isEmpty) return 0;
    return baseBars.fold(0.0, (prev, b) => prev + b.value) / baseBars.length;
  }

  double get baseMedian {
    var baseBars = bars.where((b) => b.role == 'base').map((b) => b.value).toList();
    if (baseBars.isEmpty) return 0;
    baseBars.sort();
    int mid = baseBars.length ~/ 2;
    if (baseBars.length % 2 != 0) return baseBars[mid];
    return (baseBars[mid - 1] + baseBars[mid]) / 2.0;
  }

  // --- VALIDATION ---
  bool near(double a, double b, [double eps = 0.005]) => (a - b).abs() < eps;
  bool sortedEq(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    List<double> sa = List.from(a)..sort();
    List<double> sb = List.from(b)..sort();
    for (int i=0; i<sa.length; i++) {
      if (!near(sa[i], sb[i])) return false;
    }
    return true;
  }

  bool get isStepComplete {
    ScenarioConfig sc = scenarios[currentStep];
    var vals = bars.map((b) => b.value).toList();
    
    if (sc.id == 'EX-M-01') return derivedCount == 2 && near(derivedMean, 5) && sortedEq(vals, [3, 7]);
    if (sc.id == 'EX-M-02') return derivedCount == 3 && near(derivedMean, 7) && near(derivedLhsSum, 1) && near(derivedRhsSum, 1);
    if (sc.id == 'EX-M-04') return derivedCount == 4 && near(derivedMean, 12) && near(derivedLhsSum, 5) && near(derivedRhsSum, 5);
    if (sc.id == 'EX-M-07') {
      var ins = bars.where((b) => b.role == 'inserted').map((b) => b.value).toList();
      return near(baseMean, 11) && ins.isNotEmpty && near(ins[0], 17) && near(derivedMean, 12.2) && derivedCount == 5;
    }
    if (sc.id == 'EX-M-08') {
      var ins = bars.where((b) => b.role == 'inserted').map((b) => b.value).toList();
      return near(baseMean, 9) && near(derivedMean, 9) && ins.length == 3 && sortedEq(ins, [7, 7, 13]);
    }
    if (sc.id == 'EX-M-12') {
      var unk = bars.where((b) => b.role == 'unknown').firstOrNull;
      return derivedCount == 10 && near(derivedMean, 39.2) && unk != null && near(unk.value, 43);
    }
    if (sc.id == 'EX-M-13') {
      double repTot = reportedAverage * treeCount;
      double corTot = repTot - 3;
      double corAvg = treeCount == 0 ? 0 : corTot / treeCount;
      return near(repTot, 384) && near(corTot, 381) && near(corAvg, 25.4);
    }
    if (sc.id == 'EX-M-11') {
      var ins = bars.where((b) => b.role == 'inserted').firstOrNull;
      return near(baseMedian, 8) && ins != null && near(ins.value, 11) && near(derivedMedian, 9.5) && derivedCount == 6;
    }
    if (sc.id == 'EX-M-14') {
      return derivedCount == 36 && near(derivedMean, 5.22, 0.01) && near(derivedMedian, 5);
    }
    if (sc.id == 'FIO-7') {
      var unk = bars.where((b) => b.role == 'unknown').firstOrNull;
      return derivedCount == 8 && near(derivedMean, 10.375) && unk != null && near(unk.value, 13);
    }
    return false;
  }

  // --- TRANSLATIONS ---
  String get tTitle => language == 'EN' ? "MEAN & MEDIAN LAB" : "माध्य और माध्यिका लैब";
  String get tSubtitle => language == 'EN' ? "CLASS 8 • TALES BY DOTS AND LINES" : "कक्षा 8 • बिंदुओं और रेखाओं की कहानियाँ";
  
  String stepTitle(int index) {
    if (language == 'EN') {
      switch (index) {
        case 0: return "Step 1/10: Two Numbers";
        case 1: return "Step 2/10: Balance Ribbons";
        case 2: return "Step 3/10: Bigger Balance";
        case 3: return "Step 4/10: Insert a Value";
        case 4: return "Step 5/10: Deviations That Cancel";
        case 5: return "Step 6/10: Find the Missing Weight";
        case 6: return "Step 7/10: Correct a Reporting Error";
        case 7: return "Step 8/10: Median Shifts on Insertion";
        case 8: return "Step 9/10: Frequency Table";
        case 9: return "Step 10/10: Figure It Out";
      }
    } else {
      switch (index) {
        case 0: return "चरण 1/10: दो संख्याएँ";
        case 1: return "चरण 2/10: संतुलन रिबन";
        case 2: return "चरण 3/10: बड़ा संतुलन";
        case 3: return "चरण 4/10: एक मान जोड़ें";
        case 4: return "चरण 5/10: विचलन जो रद्द हो जाते हैं";
        case 5: return "चरण 6/10: लापता वजन खोजें";
        case 6: return "चरण 7/10: रिपोर्टिंग त्रुटि सुधारें";
        case 7: return "चरण 8/10: सम्मिलन पर माध्यिका बदलती है";
        case 8: return "चरण 9/10: आवृत्ति सारणी";
        case 9: return "चरण 10/10: पता लगाएं";
      }
    }
    return "";
  }

  String stepSource(int index) {
    switch (index) {
      case 0: return "Target: 3, 7";
      case 1: return "Target: 6, 7, 8";
      case 2: return "Target: 10, 10, 11, 17";
      case 3: return "Base: 6, 6, 10, 22 → insert 17";
      case 4: return "Base mean MUST BE 9 → insert 7, 7, 13";
      case 5: return "42, 40, 39, 33, 48, 38, 42, 35, 32, w — mean 39.2";
      case 6: return "n = 15 trees, reported average 25.6, one tree overstated by 3";
      case 7: return "Base: 3, 7, 8, 11, 13 → insert 11";
      case 8: return "values 3–10, frequencies 3,11,9,7,3,1,1,1 (n = 36)";
      case 9: return "8, 13, 10, 4, 5, 20, y, 10 — mean 10.375";
    }
    return "";
  }

  String stepInstruction(int index) {
    if (language == 'EN') {
      switch (index) {
        case 0: return "Drag the two bar tops until their heights read 3 and 7. The mean is the value exactly halfway between them.";
        case 1: return "Drag the three bars to heights 6, 7 and 8. Watch the LHS/RHS ribbons: the bar below the mean and the bar above the mean should each show a distance of 1.";
        case 2: return "Drag the four bars to heights 10, 10, 11 and 17. Read the total distance below the mean (LHS) and above the mean (RHS) from the ribbons — they should be equal.";
        case 3: return "First drag the four BASE bars to 6, 6, 10 and 22 (mean 11). Then press + Insert Bar and drag the new bar to height 17. Watch the mean move to 12.2.";
        case 4: return "FIRST, build any three base bars whose mean is exactly 9. THEN, insert three new bars at heights 7, 7, and 13. The final mean should stay at 9.";
        case 5: return "Drag the nine known bars to their exact weights. Then drag the dashed unknown bar (w) up or down until the live mean reads exactly 39.2.";
        case 6: return "Set the Reported Average dial to 25.6 and the Tree Count dial to 15. Read the derived reported total, then confirm the corrected total and corrected average.";
        case 7: return "Drag the five base bars to 3, 7, 8, 11 and 13, then use Sort by Value to confirm the median is 8. Now insert a bar to 11, and re-check the median.";
        case 8: return "Drag each frequency bin's stack top up or down until its height matches the target frequency shown in the source card for that value.";
        case 9: return "Drag the seven known bars to their exact values. Then drag the dashed unknown bar (y) until the live mean reads exactly 10.375.";
      }
    } else {
      switch (index) {
        case 0: return "दोनों बार को तब तक खींचें जब तक उनकी ऊँचाई 3 और 7 न हो जाए। माध्य वह मान है जो ठीक उनके बीच में है।";
        case 1: return "तीनों बार को 6, 7 और 8 ऊँचाई पर खींचें। LHS/RHS रिबन देखें: माध्य से नीचे और ऊपर वाले बार दोनों की दूरी 1 दिखनी चाहिए।";
        case 2: return "चारों बार को 10, 10, 11 और 17 ऊँचाई पर खींचें। रिबन से माध्य से नीचे (LHS) और ऊपर (RHS) की कुल दूरी पढ़ें — वे बराबर होनी चाहिए।";
        case 3: return "पहले चार आधार बार को 6, 6, 10 और 22 (माध्य 11) पर खींचें। फिर + बार जोड़ें दबाएं और नए बार को 17 ऊँचाई पर खींचें। माध्य 12.2 पर जाते देखें।";
        case 4: return "पहले, कोई भी तीन आधार बार बनाएं जिनका माध्य ठीक 9 हो। फिर, 7, 7, और 13 की ऊंचाई पर तीन नए बार जोड़ें। अंतिम माध्य 9 पर ही रहना चाहिए।";
        case 5: return "नौ ज्ञात बार को उनके सटीक वजन पर खींचें। फिर डैश वाले अज्ञात बार (w) को तब तक खींचें जब तक लाइव माध्य ठीक 39.2 न हो जाए।";
        case 6: return "रिपोर्ट किया औसत डायल को 25.6 और पेड़ गणना डायल को 15 पर सेट करें। व्युत्पन्न रिपोर्ट किया कुल पढ़ें, फिर 3 किग्रा की अधिकता हटाने के बाद सही किया कुल और औसत की पुष्टि करें।";
        case 7: return "पांच आधार बार को 3, 7, 8, 11 और 13 पर खींचें, फिर 'मान अनुसार क्रमबद्ध करें' से पुष्टि करें कि माध्यिका 8 है। अब + बार जोड़ें दबाएं, नए बार को 11 ऊँचाई पर खींचें, और माध्यिका फिर जांचें।";
        case 8: return "हर आवृत्ति बिन के स्टैक शीर्ष को तब तक खींचें जब तक उसकी ऊँचाई स्रोत कार्ड में दिखाई गई लक्ष्य आवृत्ति से मेल न खाए।";
        case 9: return "सातों ज्ञात बार को उनके सटीक मान पर खींचें। फिर अज्ञात बार (y) को तब तक खींचें जब लाइव माध्य ठीक 10.375 न हो जाए।";
      }
    }
    return "";
  }

  // --- UI BUILDING ---
  
  Widget _buildLanguageAndControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => toggleLanguage('EN'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: language == 'EN' ? Colors.yellow : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Text("EN", style: TextStyle(color: language == 'EN' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                GestureDetector(
                  onTap: () => toggleLanguage('HI'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: language == 'HI' ? Colors.yellow : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Text("HI", style: TextStyle(color: language == 'HI' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 28), onPressed: resetLab)
        ],
      ),
    );
  }

  Widget buildSidebar() {
    ScenarioConfig sc = scenarios[currentStep];
    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.95),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.cyanAccent, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tTitle, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(tSubtitle, style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLanguageAndControls(),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stepTitle(currentStep), style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text(stepInstruction(currentStep), style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                    child: Text("Source: ${stepSource(currentStep)}", style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Text(language == 'EN' ? "DATA READOUTS" : "डेटा रीडआउट्स", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Column(
                children: [
                  _readoutRow(language == 'EN' ? 'Count (n)' : 'गणना (n)', derivedCount.toString()),
                  if (sc.mode != 'dials') _readoutRow(language == 'EN' ? 'Sum' : 'योग', derivedSum.toStringAsFixed(1)),
                  if (sc.mode != 'dials') _readoutRow(language == 'EN' ? 'Mean' : 'माध्य', derivedMean.toStringAsFixed(3), color: Colors.indigoAccent),
                  if (sc.mode != 'dials') _readoutRow(language == 'EN' ? 'Median' : 'माध्यिका', derivedMedian.toStringAsFixed(2), color: Colors.orangeAccent),
                  if (sc.showRibbons) _readoutRow(language == 'EN' ? 'LHS (below)' : 'LHS (नीचे)', derivedLhsSum.toStringAsFixed(2), color: Colors.lightBlueAccent),
                  if (sc.showRibbons) _readoutRow(language == 'EN' ? 'RHS (above)' : 'RHS (ऊपर)', derivedRhsSum.toStringAsFixed(2), color: Colors.orangeAccent),
                  if (sc.mode == 'dials') ...[
                     _readoutRow(language == 'EN' ? 'Reported Total' : 'रिपोर्ट किया गया कुल', (reportedAverage * treeCount).toStringAsFixed(1)),
                     _readoutRow(language == 'EN' ? 'Corrected Total' : 'सही किया गया कुल', ((reportedAverage * treeCount) - 3).toStringAsFixed(1)),
                     _readoutRow(language == 'EN' ? 'Corrected Avg' : 'सही किया गया औसत', (((reportedAverage * treeCount) - 3) / (treeCount==0?1:treeCount)).toStringAsFixed(2), color: Colors.indigoAccent),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (isStepComplete)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.black),
                label: Text(language == 'EN' ? "VERIFY STEP" : "सत्यापित करें", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  playSound(_successPlayer, _successUrl);
                  if (currentStep < 9) {
                    setState(() {
                      currentStep++;
                      _loadScenario(currentStep);
                    });
                  } else {
                    setState(() => showSuccess = true);
                  }
                },
              )
          ]
        )
      )
    );
  }

  Widget _readoutRow(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildControlsPanel() {
    ScenarioConfig sc = scenarios[currentStep];
    return Positioned(
      bottom: 20, left: isSidebarOpen ? (MediaQuery.of(context).size.width * 0.35) + 20 : 20, right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (sc.insertCount > 0)
            ElevatedButton.icon(
              icon: const Icon(Icons.add), label: Text("${language == 'EN' ? 'Insert Bar' : 'बार जोड़ें'} (${sc.insertCount - bars.where((b)=>b.role=='inserted').length})"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white),
              onPressed: bars.where((b)=>b.role=='inserted').length < sc.insertCount ? insertBar : null,
            ),
          const SizedBox(width: 16),
          if (sc.showMedianSort)
            ElevatedButton.icon(
              icon: const Icon(Icons.sort), label: Text(language == 'EN' ? 'Sort by Value' : 'मान अनुसार क्रमबद्ध करें'),
              style: ElevatedButton.styleFrom(backgroundColor: medianSortOn ? Colors.orangeAccent : Colors.blueGrey, foregroundColor: Colors.white),
              onPressed: () {
                playSound(_clickPlayer, _clickUrl);
                setState(() => medianSortOn = !medianSortOn);
              },
            ),
        ],
      )
    );
  }

  Widget buildDialsMode() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Reported Average: ${reportedAverage.toStringAsFixed(1)}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: reportedAverage, min: 20, max: 30, divisions: 100, activeColor: Colors.cyanAccent,
            onChanged: (v) => setState(() => reportedAverage = v),
          ),
          const SizedBox(height: 20),
          Text("Tree Count (n): $treeCount", style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: treeCount.toDouble(), min: 5, max: 25, divisions: 20, activeColor: Colors.orangeAccent,
            onChanged: (v) => setState(() => treeCount = v.toInt()),
          ),
        ],
      )
    );
  }

  Widget buildFreqMode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: freqBars.map((f) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4), // Tighter padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f.frequency.toString(), style: const TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: 32, height: f.frequency * 20.0, // Slightly thinner bars to save space
                    decoration: BoxDecoration(color: Colors.cyan.shade600, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  ),
                  const SizedBox(height: 8),
                  Text("v=${f.value}", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => adjustFreq(f.value, -1),
                        child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 28),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => adjustFreq(f.value, 1),
                        child: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 28),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ),
      )
    );
  }

  void _handleBarDrag(Offset local, ScenarioConfig sc, double canvasWidth, double canvasHeight) {
    List<BarData> renderBars = List.from(bars);
    if (medianSortOn) {
      renderBars.sort((a, b) => a.value.compareTo(b.value));
    }

    double barWidth = 40;
    double spacing = 20;
    double totalWidth = renderBars.length * barWidth + (renderBars.length - 1) * spacing;
    
    // Scale down if it exceeds canvas width (with 40px padding)
    if (totalWidth > canvasWidth - 40) {
      double scale = (canvasWidth - 40) / totalWidth;
      barWidth *= scale;
      spacing *= scale;
      totalWidth = canvasWidth - 40;
    }

    double startX = (canvasWidth - totalWidth) / 2;

    for (int i = 0; i < renderBars.length; i++) {
      double x1 = startX + i * (barWidth + spacing);
      double x2 = x1 + barWidth;
      
      // Expand hit area by exactly half the spacing to prevent overlapping adjacent bars!
      if (local.dx >= x1 - (spacing / 2) && local.dx <= x2 + (spacing / 2)) {
        double baselineY = canvasHeight - 100;
        double maxHeight = canvasHeight - 140;
        
        // Map Y coordinate directly to a value
        double h = baselineY - local.dy;
        double newVal = (h / maxHeight) * sc.maxVal;
        
        setState(() {
          renderBars[i].value = math.max(0, math.min(sc.maxVal, newVal.roundToDouble()));
        });
        break;
      }
    }
  }

  Widget buildBarsMode() {
    ScenarioConfig sc = scenarios[currentStep];
    return LayoutBuilder(
      builder: (context, constraints) {
        double cw = constraints.maxWidth;
        double ch = constraints.maxHeight;
        
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // Ensures the entire canvas captures taps, not just the painted bars
          onPanDown: (details) => _handleBarDrag(details.localPosition, sc, cw, ch),
          onPanUpdate: (details) => _handleBarDrag(details.localPosition, sc, cw, ch),
          child: SizedBox(
            width: cw,
            height: ch,
            child: CustomPaint(
              size: Size(cw, ch),
              painter: BarDataPainter(
                bars: bars,
                maxVal: sc.maxVal,
                mean: derivedMean,
                showRibbons: sc.showRibbons,
                medianSortOn: medianSortOn,
                targetMean: sc.hasUnknown ? sc.targetMean : null,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35;
    ScenarioConfig sc = scenarios[currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: GridPatternPainter()),
            ),
          ),
          
          // Main Interactive Area
          Positioned.fill(
            child: Row(
              children: [
                if (isSidebarOpen) SizedBox(width: sidebarWidth),
                Expanded(
                  child: Center(
                    child: sc.mode == 'dials' 
                        ? buildDialsMode() 
                        : sc.mode == 'freq' 
                            ? buildFreqMode() 
                            : buildBarsMode(),
                  ),
                )
              ]
            ),
          ),
          
          if (sc.mode == 'bars') buildControlsPanel(),

          // Sidebar Container
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isSidebarOpen ? 0 : -sidebarWidth,
            top: 0, bottom: 0, width: sidebarWidth,
            child: buildSidebar(),
          ),
          
          // Sidebar Edge Toggle Button
          if (isShutterOpen)
            Positioned(
              left: 16, top: 16,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
                onPressed: () {
                  playSound(_clickPlayer, _clickUrl);
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
              ),
            ),
          
          if (showSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.yellow, width: 3)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 90),
                          const SizedBox(height: 20),
                          Text(language == 'EN' ? "Lab Completed!" : "लैब पूर्ण!", style: const TextStyle(color: Colors.yellow, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text("Mission Accomplished! You have balanced all scenarios and recomputed the mean and median live.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, color: Colors.black),
                            label: Text(language == 'EN' ? "Restart Lab" : "लैब पुनरारंभ करें", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                            onPressed: resetLab,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // HTML-like Smooth Shutter sliding up
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutQuart,
            top: isShutterOpen ? -MediaQuery.of(context).size.height : 0,
            left: 0, right: 0, height: MediaQuery.of(context).size.height,
            child: Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 4), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 40)]),
                      child: const Icon(Icons.bar_chart, color: Colors.cyanAccent, size: 60),
                    ),
                    const SizedBox(height: 32),
                    Text(tTitle, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(tSubtitle, style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, letterSpacing: 5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 60),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        playSound(_fxPlayer, _shutterUrl);
                        setState(() => isShutterOpen = true);
                      },
                      icon: const Icon(Icons.play_circle_fill, color: Colors.black, size: 28),
                      label: Text(language == 'EN' ? "START MISSION" : "मिशन शुरू करें", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    )
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}

class BarDataPainter extends CustomPainter {
  final List<BarData> bars;
  final double maxVal;
  final double mean;
  final bool showRibbons;
  final bool medianSortOn;
  final double? targetMean;

  BarDataPainter({
    required this.bars, required this.maxVal, required this.mean, 
    required this.showRibbons, required this.medianSortOn, this.targetMean
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    List<BarData> renderBars = List.from(bars);
    if (medianSortOn) {
      renderBars.sort((a, b) => a.value.compareTo(b.value));
    }

    double barWidth = 40;
    double spacing = 20;
    double totalWidth = renderBars.length * barWidth + (renderBars.length - 1) * spacing;
    
    // Scale down if it exceeds canvas width (with 40px padding)
    if (totalWidth > size.width - 40) {
      double scale = (size.width - 40) / totalWidth;
      barWidth *= scale;
      spacing *= scale;
      totalWidth = size.width - 40;
    }

    double startX = (size.width - totalWidth) / 2;
    double baselineY = size.height - 100;
    double maxHeight = size.height - 140;

    Paint basePaint = Paint()..color = Colors.cyan.shade600..style = PaintingStyle.fill;
    Paint insertPaint = Paint()..color = Colors.purple.shade500..style = PaintingStyle.fill;
    Paint unkPaint = Paint()..color = Colors.orange.shade500..style = PaintingStyle.fill;
    Paint strokePaint = Paint()..color = Colors.white54..style = PaintingStyle.stroke..strokeWidth = 2;

    // Draw Mean Line
    double meanY = baselineY - (mean / maxVal) * maxHeight;
    Paint meanLinePaint = Paint()..color = Colors.indigoAccent..strokeWidth = 3;
    canvas.drawLine(Offset(startX - 20, meanY), Offset(startX + totalWidth + 20, meanY), meanLinePaint);

    if (targetMean != null) {
      double tMeanY = baselineY - (targetMean! / maxVal) * maxHeight;
      Paint tMeanLinePaint = Paint()..color = Colors.orangeAccent..strokeWidth = 2;
      canvas.drawLine(Offset(startX - 20, tMeanY), Offset(startX + totalWidth + 20, tMeanY), tMeanLinePaint);
    }

    Paint lhsRibbon = Paint()..color = Colors.lightBlueAccent.withOpacity(0.5)..style = PaintingStyle.fill;
    Paint rhsRibbon = Paint()..color = Colors.orangeAccent.withOpacity(0.5)..style = PaintingStyle.fill;

    for (int i = 0; i < renderBars.length; i++) {
      double x = startX + i * (barWidth + spacing);
      double h = (renderBars[i].value / maxVal) * maxHeight;
      double y = baselineY - h;

      Rect barRect = Rect.fromLTWH(x, y, barWidth, h);
      Paint p = renderBars[i].role == 'inserted' ? insertPaint : renderBars[i].role == 'unknown' ? unkPaint : basePaint;
      
      canvas.drawRect(barRect, p);
      canvas.drawRect(barRect, strokePaint);

      // Draw Ribbon
      if (showRibbons) {
        if (renderBars[i].value < mean) {
          canvas.drawRect(Rect.fromLTWH(x + barWidth/2 - 5, y, 10, meanY - y), lhsRibbon);
        } else if (renderBars[i].value > mean) {
          canvas.drawRect(Rect.fromLTWH(x + barWidth/2 - 5, meanY, 10, y - meanY), rhsRibbon);
        }
      }

      // Draw text
      TextPainter tp = TextPainter(
        text: TextSpan(text: renderBars[i].value.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, Offset(x + (barWidth - tp.width)/2, y - 24));
    }
  }

  @override
  bool shouldRepaint(covariant BarDataPainter oldDelegate) => true;
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 50) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += 50) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
