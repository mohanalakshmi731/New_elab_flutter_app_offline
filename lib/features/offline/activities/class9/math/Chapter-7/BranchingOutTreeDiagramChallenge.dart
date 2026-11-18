// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BranchingOutTreeDiagramChallenge(),
    ),
  );
}

class BranchingOutTreeDiagramChallenge extends StatefulWidget {
  const BranchingOutTreeDiagramChallenge({super.key});

  @override
  State<BranchingOutTreeDiagramChallenge> createState() =>
      _BranchingOutTreeDiagramChallengeState();
}

class SlotDef {
  final String id;
  final int phase;
  final String accept; // 'label', 'prob', 'product'
  final String kind; // 'node', 'branch', 'leaf'
  final Offset pos; // Percentage coordinates 0-100
  final dynamic expect;

  SlotDef(this.id, this.phase, this.accept, this.kind, this.pos, this.expect);
}

class Outcome {
  final String label;
  final double prob;
  Outcome(this.label, this.prob);
}

class ScenarioDef {
  final String id;
  final String name;
  final String stage1Name;
  final List<Outcome> stage1Outcomes;
  final String stage2Name;
  final List<Outcome> stage2Outcomes;

  ScenarioDef(
    this.id,
    this.name,
    this.stage1Name,
    this.stage1Outcomes,
    this.stage2Name,
    this.stage2Outcomes,
  );
}

class _BranchingOutTreeDiagramChallengeState
    extends State<BranchingOutTreeDiagramChallenge>
    with TickerProviderStateMixin {
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  String _language = 'en';

  int _activeScenario = 0;
  int _activePhase = 0; // 0, 1, 2
  int _hintIdx = 0;

  Map<String, dynamic> _placements = {}; // Slot ID -> value
  List<bool> _scenariosCompleted = [false, false, false];

  bool _showReport = false;
  bool _flashSuccess = false;
  String _flashTitle = '';
  String _flashDesc = '';
  String _flashFeedback = '';

  final AudioPlayer _sfxPlayer1 = AudioPlayer();
  final AudioPlayer _sfxPlayer2 = AudioPlayer();
  final String sfxClick =
      'audio/class9/click.mp3';
  final String sfxShutter =
      'audio/class9/shutter.mp3';
  final String sfxSuccess =
      'audio/class9/success.mp3';
  final String sfxError =
      'audio/class9/error.mp3';

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  final List<ScenarioDef> _scenarios = [
    ScenarioDef(
      'two-coins',
      'Two Coin Tosses',
      'First Toss',
      [Outcome('H', 0.5), Outcome('T', 0.5)],
      'Second Toss',
      [Outcome('H', 0.5), Outcome('T', 0.5)],
    ),
    ScenarioDef(
      'coin-bag',
      'Coin then Bag Draw',
      'Coin Toss',
      [Outcome('H', 0.5), Outcome('T', 0.5)],
      'Bag: 3R, 2B',
      [Outcome('R', 0.6), Outcome('B', 0.4)],
    ),
    ScenarioDef(
      'two-days',
      'Two-Day Forecast',
      'Day 1',
      [Outcome('R', 0.4), Outcome('S', 0.6)],
      'Day 2',
      [Outcome('R', 0.4), Outcome('S', 0.6)],
    ),
  ];

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Branching Out: Tree Diagram Challenge",
      'tagline':
          "Class 9 • The Mathematics of Maybe — Introduction to Probability",
      'init_btn': "START MISSION",

      'board_title': "Teacher Guide",
      'obj_label': "Mission Objective",
      'scenario_label': "Scenario",
      'steps_label': "Instruction Sequence",
      'hint_label': "Hint / Evidence",
      'conc_label': "Learnt Conclusion",

      'scen_0': "Scenario 1 · Two Coin Tosses",
      'scen_1': "Scenario 2 · Coin then Bag Draw",
      'scen_2': "Scenario 3 · Two-Day Forecast",

      'btn_hint': "Hint",
      'btn_submit_stage': "Submit Stage",
      'btn_submit_tree': "Submit Tree",
      'btn_report': "Report",
      'btn_close_report': "Close Report",
      'btn_restart_exp': "Restart Exploration",

      'obj_desc':
          "Build a probability tree for a two-stage experiment: place outcome branches, label branch probabilities, and compute each leaf path probability as the product along its path.",
      'hint_desc':
          "Ask students what they expect at each branch. Branches leaving a node must total probability 1. A path probability is the product of the branches along that path.",
      'conc_desc':
          "A tree diagram lists every outcome of a multi-stage experiment. Branch probabilities at each node sum to 1, and each leaf (compound) outcome has probability equal to the product of branch probabilities along its path.",

      'ph0_t': "Stage 1 Branches",
      'ph1_t': "Stage 2 Branches",
      'ph2_t': "Path Probabilities",

      's0_1': "Stage 1: Add outcome branches + probabilities from START.",
      's0_2': "Stage 2: Add outcomes + probabilities from each node.",
      's0_3': "Compute each leaf path probability as a product.",

      'h_0_0':
          "Drag the outcome labels from the tray onto the two branch nodes (top branch first).",
      'h_0_1': "Each branch also needs a probability chip.",
      'h_0_2': "The two branches from START must total probability 1.",

      'h_1_0':
          "From each node, add BOTH second-stage outcomes so no path is missing.",
      'h_1_1': "The second stage repeats for every first-stage node.",
      'h_1_2': "Branches leaving each node must again sum to 1.",

      'h_2_0':
          "A leaf path probability = product of the branch probabilities along its path.",
      'h_2_1': "Multiply the two branch probabilities along the path.",
      'h_2_2':
          "Read the compound outcome beside each leaf as you drop its product.",

      'msg_err_fill': "Fill every branch first — cover all outcomes.",
      'msg_err_sum':
          "Branch probabilities leaving a node must sum to 1. Adjust the probability chips.",
      'msg_err_prod':
          "A path probability is the product along its branches. Check your math!",
      'msg_err_prob': "Check each branch probability against its outcome.",
      'msg_err_prob_1':
          "Red (R) has a probability of 0.6 and Blue (B) is 0.4. Ensure your probability chips match the colors!",
      'msg_err_prob_2':
          "Rain (R) has a probability of 0.4 and Sun (S) is 0.6. Check your probability chips!",

      'msg_ok_0': "Stage 1 branches built correctly.",
      'msg_ok_1': "Stage 2 branches added correctly.",
      'msg_ok_2': "Every path probability is correct.",

      'diag_observation': "Detailed Observation",
      'diag_pass':
          "You built the full probability tree and computed every path probability.",
      'diag_fail':
          "Part of the tree still needs work — your branches are kept, adjust and resubmit.",
    },
    'hi': {
      'app_title': "विस्तार: ट्री डायग्राम चुनौती",
      'tagline': "कक्षा 9 • प्रायिकता का परिचय",
      'init_btn': "मिशन शुरू करें",
      'board_title': "शिक्षक मार्गदर्शिका",
      'obj_label': "मिशन का उद्देश्य",
      'scenario_label': "परिदृश्य",
      'steps_label': "निर्देश अनुक्रम",
      'hint_label': "संकेत / प्रमाण",
      'conc_label': "निष्कर्ष",

      'scen_0': "परिदृश्य 1 · दो सिक्कों की उछाल",
      'scen_1': "परिदृश्य 2 · सिक्का फिर बैग",
      'scen_2': "परिदृश्य 3 · दो-दिन का पूर्वानुमान",

      'btn_hint': "संकेत",
      'btn_submit_stage': "चरण सबमिट करें",
      'btn_submit_tree': "ट्री सबमिट करें",
      'btn_report': "रिपोर्ट",
      'btn_close_report': "रिपोर्ट बंद करें",
      'btn_restart_exp': "पुनः अन्वेषण करें",

      'obj_desc':
          "दो-चरणीय प्रयोग के लिए प्रायिकता ट्री बनाएं: परिणाम शाखाएं रखें, शाखा प्रायिकताओं को लेबल करें, और प्रत्येक पथ के साथ गुणनफल के रूप में प्रत्येक लीफ पथ प्रायिकता की गणना करें।",
      'hint_desc':
          "छात्रों से पूछें कि वे प्रत्येक शाखा में क्या उम्मीद करते हैं। एक नोड से निकलने वाली शाखाओं की कुल प्रायिकता 1 होनी चाहिए। पथ प्रायिकता उस पथ के साथ शाखाओं का गुणनफल है।",
      'conc_desc':
          "एक ट्री डायग्राम बहु-चरणीय प्रयोग के हर परिणाम को सूचीबद्ध करता है। प्रत्येक नोड पर शाखा प्रायिकताओं का योग 1 होता है, और प्रत्येक लीफ (यौगिक) परिणाम की प्रायिकता उसके पथ के साथ शाखा प्रायिकताओं के गुणनफल के बराबर होती है।",

      'ph0_t': "चरण 1 शाखाएं",
      'ph1_t': "चरण 2 शाखाएं",
      'ph2_t': "पथ प्रायिकताएं",

      's0_1': "चरण 1: START से परिणाम शाखाएं + प्रायिकताएं जोड़ें।",
      's0_2': "चरण 2: प्रत्येक नोड से परिणाम + प्रायिकताएं जोड़ें।",
      's0_3': "गुणनफल के रूप में प्रत्येक लीफ पथ प्रायिकता की गणना करें।",

      'h_0_0':
          "ट्रे से परिणाम लेबल को दो शाखा नोड्स पर खींचें (ऊपरी शाखा पहले)।",
      'h_0_1': "प्रत्येक शाखा को प्रायिकता चिप की भी आवश्यकता होती है।",
      'h_0_2:': "START से निकलने वाली दो शाखाओं की कुल प्रायिकता 1 होनी चाहिए।",

      'h_1_0':
          "प्रत्येक नोड से, दोनों दूसरे चरण के परिणाम जोड़ें ताकि कोई पथ न छूटे।",
      'h_1_1': "दूसरा चरण हर पहले चरण के नोड के लिए दोहराया जाता है।",
      'h_1_2': "प्रत्येक नोड से निकलने वाली शाखाओं का योग फिर से 1 होना चाहिए।",

      'h_2_0':
          "एक लीफ पथ प्रायिकता = उसके पथ के साथ शाखा प्रायिकताओं का गुणनफल।",
      'h_2_1': "पथ के साथ दो शाखा प्रायिकताओं को गुणा करें।",
      'h_2_2':
          "उत्पाद को गिराते समय प्रत्येक पत्ती के बगल में यौगिक परिणाम पढ़ें।",

      'msg_err_fill': "पहले हर शाखा को भरें — सभी परिणामों को कवर करें।",
      'msg_err_sum':
          "किसी नोड से निकलने वाली शाखा प्रायिकताओं का योग 1 होना चाहिए।",
      'msg_err_prod':
          "पथ प्रायिकता इसकी शाखाओं का गुणनफल है। अपनी गणना जांचें!",
      'msg_err_prob':
          "उसके परिणाम के विरुद्ध प्रत्येक शाखा की प्रायिकता की जांच करें।",
      'msg_err_prob_1':
          "लाल (R) की प्रायिकता 0.6 है और नीले (B) की 0.4 है। जांचें कि चिप्स मेल खाते हैं!",
      'msg_err_prob_2':
          "बारिश (R) की प्रायिकता 0.4 है और धूप (S) की 0.6 है। अपनी प्रायिकता चिप्स की जाँच करें!",

      'msg_ok_0': "चरण 1 शाखाएं सही ढंग से बनाई गई हैं।",
      'msg_ok_1': "चरण 2 शाखाएं सही ढंग से जोड़ी गई हैं।",
      'msg_ok_2': "हर पथ की प्रायिकता सही है।",

      'diag_observation': "विस्तृत अवलोकन",
      'diag_pass':
          "आपने पूर्ण प्रायिकता ट्री बनाया और प्रत्येक पथ की प्रायिकता की गणना की।",
      'diag_fail':
          "ट्री के कुछ हिस्से पर अभी भी काम करने की आवश्यकता है — समायोजित करें और पुनः सबमिट करें।",
    },
  };

  String t(String key) => _text[_language]?[key] ?? _text['en']?[key] ?? key;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });

    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shutterAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _sfxPlayer1.dispose();
    _sfxPlayer2.dispose();
    _shutterController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playClick() {
    _sfxPlayer1.play(AssetSource(sfxClick), volume: 1.0);
  }

  void _playSuccess() {
    _sfxPlayer2.play(AssetSource(sfxSuccess), volume: 1.0);
  }

  void _playError() {
    _sfxPlayer2.play(AssetSource(sfxError), volume: 1.0);
  }

  void _startMission() {
    _sfxPlayer1.play(AssetSource(sfxShutter), volume: 1.0);
    _playSuccess();
    _shutterController.forward().then((_) {
      setState(() => _hasStarted = true);
    });
  }

  void _doReset() {
    _playClick();
    setState(() {
      _language = 'en';
      _hasStarted = false;
      _activeScenario = 0;
      _activePhase = 0;
      _hintIdx = 0;
      _placements.clear();
      _scenariosCompleted = [false, false, false];
      _showReport = false;
    });
    _shutterController.reverse();
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Tree Definition Engine ---
  List<SlotDef> _getSlots() {
    final s = _scenarios[_activeScenario];
    final s1 = s.stage1Outcomes;
    final s2 = s.stage2Outcomes;
    List<SlotDef> defs = [];

    // Stage 1
    defs.add(
      SlotDef(
        'node-s1-0',
        0,
        'label',
        'node',
        const Offset(37, 26),
        s1[0].label,
      ),
    );
    defs.add(
      SlotDef(
        'node-s1-1',
        0,
        'label',
        'node',
        const Offset(37, 74),
        s1[1].label,
      ),
    );
    defs.add(
      SlotDef(
        'branch-s1-0',
        0,
        'prob',
        'branch',
        const Offset(22, 38),
        s1[0].prob,
      ),
    );
    defs.add(
      SlotDef(
        'branch-s1-1',
        0,
        'prob',
        'branch',
        const Offset(22, 62),
        s1[1].prob,
      ),
    );

    // Stage 2
    defs.add(
      SlotDef(
        'node-s2-0-0',
        1,
        'label',
        'node',
        const Offset(69, 12),
        s2[0].label,
      ),
    );
    defs.add(
      SlotDef(
        'node-s2-0-1',
        1,
        'label',
        'node',
        const Offset(69, 39),
        s2[1].label,
      ),
    );
    defs.add(
      SlotDef(
        'node-s2-1-0',
        1,
        'label',
        'node',
        const Offset(69, 61),
        s2[0].label,
      ),
    );
    defs.add(
      SlotDef(
        'node-s2-1-1',
        1,
        'label',
        'node',
        const Offset(69, 88),
        s2[1].label,
      ),
    );

    defs.add(
      SlotDef(
        'branch-s2-0-0',
        1,
        'prob',
        'branch',
        const Offset(53, 19),
        s2[0].prob,
      ),
    );
    defs.add(
      SlotDef(
        'branch-s2-0-1',
        1,
        'prob',
        'branch',
        const Offset(53, 32.5),
        s2[1].prob,
      ),
    );
    defs.add(
      SlotDef(
        'branch-s2-1-0',
        1,
        'prob',
        'branch',
        const Offset(53, 67.5),
        s2[0].prob,
      ),
    );
    defs.add(
      SlotDef(
        'branch-s2-1-1',
        1,
        'prob',
        'branch',
        const Offset(53, 81),
        s2[1].prob,
      ),
    );

    // Leafs
    defs.add(
      SlotDef(
        'leaf-prod-0-0',
        2,
        'product',
        'leaf',
        const Offset(92, 12),
        (s1[0].prob * s2[0].prob * 100).round() / 100,
      ),
    );
    defs.add(
      SlotDef(
        'leaf-prod-0-1',
        2,
        'product',
        'leaf',
        const Offset(92, 39),
        (s1[0].prob * s2[1].prob * 100).round() / 100,
      ),
    );
    defs.add(
      SlotDef(
        'leaf-prod-1-0',
        2,
        'product',
        'leaf',
        const Offset(92, 61),
        (s1[1].prob * s2[0].prob * 100).round() / 100,
      ),
    );
    defs.add(
      SlotDef(
        'leaf-prod-1-1',
        2,
        'product',
        'leaf',
        const Offset(92, 88),
        (s1[1].prob * s2[1].prob * 100).round() / 100,
      ),
    );

    return defs;
  }

  List<Map<String, dynamic>> _getPool() {
    final s = _scenarios[_activeScenario];
    List<Map<String, dynamic>> pool = [];
    if (_activePhase == 0) {
      pool.add({'type': 'label', 'val': s.stage1Outcomes[0].label});
      pool.add({'type': 'label', 'val': s.stage1Outcomes[1].label});
      pool.add({'type': 'prob', 'val': s.stage1Outcomes[0].prob});
      pool.add({'type': 'prob', 'val': s.stage1Outcomes[1].prob});
    } else if (_activePhase == 1) {
      pool.add({'type': 'label', 'val': s.stage2Outcomes[0].label});
      pool.add({'type': 'label', 'val': s.stage2Outcomes[1].label});
      pool.add({'type': 'label', 'val': s.stage2Outcomes[0].label});
      pool.add({'type': 'label', 'val': s.stage2Outcomes[1].label});
      pool.add({'type': 'prob', 'val': s.stage2Outcomes[0].prob});
      pool.add({'type': 'prob', 'val': s.stage2Outcomes[1].prob});
      pool.add({'type': 'prob', 'val': s.stage2Outcomes[0].prob});
      pool.add({'type': 'prob', 'val': s.stage2Outcomes[1].prob});
    } else {
      List<double> prods = [];
      for (var s1 in s.stage1Outcomes) {
        for (var s2 in s.stage2Outcomes) {
          prods.add((s1.prob * s2.prob * 100).round() / 100);
        }
      }
      for (var p in prods) {
        pool.add({'type': 'product', 'val': p});
      }
      // Distractors
      pool.add({
        'type': 'product',
        'val':
            ((s.stage1Outcomes[0].prob + s.stage2Outcomes[0].prob) * 100)
                .round() /
            100,
      });
      pool.add({'type': 'product', 'val': s.stage1Outcomes[0].prob});
    }

    // Filter out placed ones
    Map<String, int> counts = {};
    for (var p in pool) {
      String key = "${p['type']}|${p['val']}";
      counts[key] = (counts[key] ?? 0) + 1;
    }

    for (var kv in _placements.entries) {
      var d = _getSlots().firstWhere((s) => s.id == kv.key);
      if (d.phase == _activePhase) {
        String key = "${d.accept}|${kv.value}";
        if (counts.containsKey(key) && counts[key]! > 0) {
          counts[key] = counts[key]! - 1;
        }
      }
    }

    List<Map<String, dynamic>> finalPool = [];
    counts.forEach((k, v) {
      for (int i = 0; i < v; i++) {
        var parts = k.split('|');
        var val = parts[0] == 'label' ? parts[1] : double.parse(parts[1]);
        finalPool.add({'type': parts[0], 'val': val});
      }
    });

    return finalPool;
  }

  void _submitPhase() {
    var defs = _getSlots();
    var currentDefs = defs.where((d) => d.phase == _activePhase).toList();

    // Check if all placed
    bool allPlaced = true;
    for (var d in currentDefs) {
      if (!_placements.containsKey(d.id)) allPlaced = false;
    }

    if (!allPlaced) {
      _playError();
      _showSnack(t('msg_err_fill'), Colors.redAccent);
      return;
    }

    bool eqVal(dynamic a, dynamic b) {
      if (a is double && b is double) return (a - b).abs() < 0.001;
      return a == b;
    }

    if (_activePhase == 0) {
      double p0 = _placements['branch-s1-0'];
      double p1 = _placements['branch-s1-1'];
      if ((p0 + p1 - 1.0).abs() > 0.001) {
        _playError();
        _showSnack(t('msg_err_sum'), Colors.orangeAccent);
        return;
      }

      var s1 = _scenarios[_activeScenario].stage1Outcomes;
      String l0 = _placements['node-s1-0'];
      String l1 = _placements['node-s1-1'];

      bool matchDirect =
          eqVal(l0, s1[0].label) &&
          eqVal(p0, s1[0].prob) &&
          eqVal(l1, s1[1].label) &&
          eqVal(p1, s1[1].prob);
      bool matchSwapped =
          eqVal(l0, s1[1].label) &&
          eqVal(p0, s1[1].prob) &&
          eqVal(l1, s1[0].label) &&
          eqVal(p1, s1[0].prob);

      if (!matchDirect && !matchSwapped) {
        _playError();
        if (_activeScenario == 1)
          _showSnack(t('msg_err_prob_1'), Colors.orangeAccent);
        else if (_activeScenario == 2)
          _showSnack(t('msg_err_prob_2'), Colors.orangeAccent);
        else
          _showSnack(t('msg_err_prob'), Colors.orangeAccent);
        return;
      }
    } else if (_activePhase == 1) {
      var s2 = _scenarios[_activeScenario].stage2Outcomes;
      for (int i = 0; i < 2; i++) {
        double p0 = _placements['branch-s2-$i-0'];
        double p1 = _placements['branch-s2-$i-1'];
        if ((p0 + p1 - 1.0).abs() > 0.001) {
          _playError();
          _showSnack(t('msg_err_sum'), Colors.orangeAccent);
          return;
        }

        String l0 = _placements['node-s2-$i-0'];
        String l1 = _placements['node-s2-$i-1'];
        bool matchDirect =
            eqVal(l0, s2[0].label) &&
            eqVal(p0, s2[0].prob) &&
            eqVal(l1, s2[1].label) &&
            eqVal(p1, s2[1].prob);
        bool matchSwapped =
            eqVal(l0, s2[1].label) &&
            eqVal(p0, s2[1].prob) &&
            eqVal(l1, s2[0].label) &&
            eqVal(p1, s2[0].prob);

        if (!matchDirect && !matchSwapped) {
          _playError();
          if (_activeScenario == 1)
            _showSnack(t('msg_err_prob_1'), Colors.orangeAccent);
          else if (_activeScenario == 2)
            _showSnack(t('msg_err_prob_2'), Colors.orangeAccent);
          else
            _showSnack(t('msg_err_prob'), Colors.orangeAccent);
          return;
        }
      }
    } else if (_activePhase == 2) {
      for (var d in currentDefs) {
        var parts = d.id.split('-');
        String i = parts[2], j = parts[3];
        double val = _placements[d.id];
        double p1 = _placements['branch-s1-$i'];
        double p2 = _placements['branch-s2-$i-$j'];
        if ((val - (p1 * p2)).abs() > 0.001) {
          _playError();
          _showSnack(t('msg_err_prod'), Colors.orangeAccent);
          return;
        }
      }
    }

    _playSuccess();
    _showSnack(t('msg_ok_$_activePhase'), Colors.green);

    if (_activePhase < 2) {
      setState(() => _activePhase++);
    } else {
      setState(() {
        _scenariosCompleted[_activeScenario] = true;
        if (_scenariosCompleted.every((e) => e)) {
          _flashSuccess = true;
          _flashTitle = "Quest Complete!";
          _flashDesc = t('diag_observation');
          _flashFeedback = t('conc_desc');
          _showReport = true;
        } else {
          int nextScen = _scenariosCompleted.indexOf(false);
          _activeScenario = nextScen;
          _activePhase = 0;
          _placements.clear();
          _showSnack(
            "Tree complete! Moving to next scenario...",
            Colors.greenAccent,
          );
        }
      });
    }
  }

  Widget _buildChip(String type, dynamic val, {bool isDragging = false}) {
    Color bg;
    if (type == 'label')
      bg = Colors.orange;
    else if (type == 'prob')
      bg = Colors.blue;
    else
      bg = Colors.yellow.shade600;

    Color fg = (type == 'product') ? Colors.black : Colors.white;

    return Container(
      width: type == 'label' ? 44 : (type == 'prob' ? 64 : 72),
      height: type == 'label' ? 44 : 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: type == 'label' ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: type != 'label' ? BorderRadius.circular(16) : null,
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow:
            isDragging
                ? [
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
      ),
      child: Text(
        type == 'label' ? val : val.toString(),
        style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD808152E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2C60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children:
                    _getPool().map((chipData) {
                      return Draggable<Map<String, dynamic>>(
                        data: chipData,
                        feedback: _buildChip(
                          chipData['type'],
                          chipData['val'],
                          isDragging: true,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildChip(chipData['type'], chipData['val']),
                        ),
                        child: _buildChip(chipData['type'], chipData['val']),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hintIdx++;
              });
              _showSnack(
                t('h_${_activePhase}_${_hintIdx % 3}'),
                Colors.white70,
              );
            },
            icon: const Icon(Icons.lightbulb, color: Colors.yellow),
            label: Text(t('btn_hint')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _submitPhase,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Text(
              t('btn_submit_stage').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          if (_hasStarted)
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width:
                      _isSidebarOpen
                          ? MediaQuery.of(context).size.width * 0.38
                          : 0,
                  child:
                      _isSidebarOpen
                          ? _buildSidebar()
                          : const SizedBox.shrink(),
                ),
                Expanded(child: _buildCanvas()),
              ],
            ),

          if (_hasStarted && !_showReport)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 40,
              left:
                  (_isSidebarOpen
                      ? MediaQuery.of(context).size.width * 0.38
                      : 0) +
                  32,
              right: 32,
              child: _buildHUD(),
            ),

          if (_hasStarted)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xD81E293B),
                onPressed: () {
                  _playClick();
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                child: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

          if (_showReport) _buildReportOverlay(),

          if (!_hasStarted)
            SlideTransition(
              position: _shutterAnimation,
              child: _buildShutterScreen(),
            ),
        ],
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_tree_outlined,
                    size: 80,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t('app_title').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('tagline'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _startMission,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      t('init_btn').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSlotActive(String id) =>
      _getSlots().firstWhere((s) => s.id == id).phase == _activePhase;

  List<SlotDef> _currentDefs() => _getSlots();

  Widget _buildCanvas() {
    return Container(
      color: const Color(0xFF071B3F),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(200),
                    minScale: 0.2,
                    maxScale: 3.0,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: TreePainter(),
                          ),
                          ..._currentDefs().map((d) {
                            double w =
                                d.kind == 'node'
                                    ? 48
                                    : (d.kind == 'branch' ? 56 : 64);
                            double h = d.kind == 'node' ? 48 : 40;

                            bool isFilled = _placements.containsKey(d.id);
                            bool isActive = _isSlotActive(d.id);

                            return Positioned(
                              left:
                                  (constraints.maxWidth * d.pos.dx / 100) -
                                  (w / 2),
                              top:
                                  (constraints.maxHeight * d.pos.dy / 100) -
                                  (h / 2),
                              child: DragTarget<Map<String, dynamic>>(
                                builder: (
                                  context,
                                  candidateData,
                                  rejectedData,
                                ) {
                                  bool isHovering = candidateData.isNotEmpty;

                                  Widget inner;
                                  if (isFilled) {
                                    inner = _buildChip(
                                      d.accept,
                                      _placements[d.id],
                                    );
                                  } else {
                                    String ph =
                                        d.accept == 'label'
                                            ? '?'
                                            : (d.accept == 'prob' ? 'p' : '×');
                                    inner = Text(
                                      ph,
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    );
                                  }

                                  return Container(
                                    width: w,
                                    height: h,
                                    decoration: BoxDecoration(
                                      color:
                                          isFilled
                                              ? Colors.transparent
                                              : (isActive
                                                  ? (isHovering
                                                      ? Colors.yellow
                                                          .withOpacity(0.3)
                                                      : Colors.yellow
                                                          .withOpacity(0.1))
                                                  : Colors.transparent),
                                      shape:
                                          d.kind == 'node'
                                              ? BoxShape.circle
                                              : BoxShape.rectangle,
                                      borderRadius:
                                          d.kind == 'node'
                                              ? null
                                              : BorderRadius.circular(16),
                                      border:
                                          isFilled
                                              ? null
                                              : Border.all(
                                                color:
                                                    isActive
                                                        ? Colors.yellow.shade600
                                                        : Colors.orange
                                                            .withOpacity(0.3),
                                                width: 2,
                                              ),
                                    ),
                                    alignment: Alignment.center,
                                    child: inner,
                                  );
                                },
                                onWillAcceptWithDetails: (details) {
                                  return isActive &&
                                      !isFilled &&
                                      details.data['type'] == d.accept;
                                },
                                onAcceptWithDetails: (details) {
                                  _playClick();
                                  setState(() {
                                    _placements[d.id] = details.data['val'];
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD80F172A),
        border: Border(right: BorderSide(color: Colors.white12)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                left: 64,
                top: 16,
                bottom: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
                color: Colors.black26,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.amber],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_tree,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('app_title').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          t('tagline').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language, size: 16),
                          color: Colors.white,
                          onPressed: () {
                            _playClick();
                            setState(
                              () => _language = _language == 'en' ? 'hi' : 'en',
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(
                            _language.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _doReset,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      t('reset'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Teacher Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t('board_title').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 32),

                  _buildContentCard(
                    Icons.my_location,
                    t('obj_label'),
                    t('obj_desc'),
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "SCENARIO",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2C60),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _activeScenario,
                        dropdownColor: const Color(0xFF0F2C60),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        items:
                            [0, 1, 2]
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(t('scen_$i')),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null && val != _activeScenario) {
                            _playClick();
                            setState(() {
                              _activeScenario = val;
                              _activePhase = 0;
                              _hintIdx = 0;
                              _placements.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "INSTRUCTION SEQUENCE",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...List.generate(3, (i) {
                    bool isActive = i == _activePhase;
                    bool isDone = i < _activePhase;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.white12
                                : const Color(0xFF0F2C60).withOpacity(0.5),
                        border: Border.all(
                          color: isActive ? Colors.orange : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle
                                : (isActive ? Icons.flash_on : Icons.lock),
                            color:
                                isDone
                                    ? Colors.green
                                    : (isActive
                                        ? Colors.yellow
                                        : Colors.white38),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t('s0_${i + 1}'),
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  _buildContentCard(
                    Icons.lightbulb,
                    t('hint_label'),
                    t('hint_desc'),
                    Colors.yellow,
                  ),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    Icons.school,
                    t('conc_label'),
                    t('conc_desc'),
                    Colors.purple,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xD80F172A),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: const Text(
                '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(
    IconData icon,
    String title,
    String body,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color.shade400),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color.shade400,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 350,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xD80F172A),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _flashSuccess ? Icons.check_circle : Icons.warning_rounded,
                color: _flashSuccess ? Colors.greenAccent : Colors.orangeAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _flashTitle.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _flashDesc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2C60),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Text(
                  _flashFeedback,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _doReset,
                icon: const Icon(Icons.refresh),
                label: Text(
                  t('btn_restart_exp').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    Offset root = Offset(size.width * 0.07, size.height * 0.50);
    Offset s1_0 = Offset(size.width * 0.37, size.height * 0.26);
    Offset s1_1 = Offset(size.width * 0.37, size.height * 0.74);

    Offset s2_0_0 = Offset(size.width * 0.69, size.height * 0.12);
    Offset s2_0_1 = Offset(size.width * 0.69, size.height * 0.39);
    Offset s2_1_0 = Offset(size.width * 0.69, size.height * 0.61);
    Offset s2_1_1 = Offset(size.width * 0.69, size.height * 0.88);

    canvas.drawLine(root, s1_0, paint);
    canvas.drawLine(root, s1_1, paint);

    canvas.drawLine(s1_0, s2_0_0, paint);
    canvas.drawLine(s1_0, s2_0_1, paint);
    canvas.drawLine(s1_1, s2_1_0, paint);
    canvas.drawLine(s1_1, s2_1_1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
