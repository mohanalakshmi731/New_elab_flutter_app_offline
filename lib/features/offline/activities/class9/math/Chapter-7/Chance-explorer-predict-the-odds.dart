// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Chance Explorer: Predict the Odds',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071B3F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF97316),
          secondary: Color(0xFFFACC15),
          surface: Color(0xFF0B234D),
        ),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const ChanceExplorerPredictOdds(),
    ),
  );
}

class ChanceExplorerPredictOdds extends StatefulWidget {
  const ChanceExplorerPredictOdds({super.key});

  @override
  State<ChanceExplorerPredictOdds> createState() =>
      _ChanceExplorerPredictOddsState();
}

class _ChanceExplorerPredictOddsState extends State<ChanceExplorerPredictOdds>
    with TickerProviderStateMixin {
  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class9/click.mp3';
  static const String _successUrl =
      'audio/class9/success.mp3';
  static const String _errorUrl =
      'audio/class9/error.mp3';
  static const String _fxUrl =
      'audio/class9/shutter.mp3';

  void _playClick() => _clickPlayer.play(AssetSource(_clickUrl));
  void _playSuccess() => _successPlayer.play(AssetSource(_successUrl));
  void _playError() => _errorPlayer.play(AssetSource(_errorUrl));
  void _playFx() => _fxPlayer.play(AssetSource(_fxUrl));

  // === State Variables ===
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  String _language = 'en';

  // Phase State
  int _activePhase = 0; // 0: Predict, 1: Toss, 2: Compute
  int _activeScenario = 0;

  // Weather Scenario State
  String _weather = 'cloudy';
  double _subjectiveValue = 0.0;
  bool _subjectiveSubmitted = false;

  // Coin Toss Scenario State
  final List<String> _coinTossResults = [];
  int _tossCount = 0;
  int _headsCount = 0;

  // Experiment/Compute State
  final TextEditingController _computeController = TextEditingController();
  bool _experimentSubmitted = false;
  bool _experimentCorrect = false;

  int _hintIdx = 0;
  String _flashMessage = '';
  bool _showFlash = false;
  Timer? _flashTimer;

  bool _showDiagnostics = false;
  bool _diagPassed = false;
  List<String> _diagStrengths = [];
  List<String> _diagImprovements = [];

  late AnimationController _coinAnimController;
  late Animation<double> _coinAnim;

  // === Dictionaries ===
  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': 'Chance Explorer: Predict the Odds',
      'tagline': 'Class 9 • The Mathematics of Maybe',
      'init_btn': 'START MISSION',
      'board_title': 'Teacher Board',
      'obj_label': 'Mission Objective',
      'steps_label': 'Instruction Sequence',
      'obj_desc':
          'Identify random events and explain the difference between a subjective forecast and an objective (experimental) probability.',
      'phase_label': 'Current Phase',
      'pip_0': 'Predict',
      'pip_1': 'Toss ×20',
      'pip_2': 'Compute',
      's1_title': 'Scenario 1 · Subjective Rain Forecast',
      's2_title': 'Scenario 2 · Coin Toss Randomness',
      's1_slider_title': 'Your Subjective Probability of Rain',
      's3_title': 'Compute Experimental Probability of Heads',
      'w_clear': 'Clear',
      'w_cloudy': 'Cloudy',
      'w_stormy': 'Stormy',
      'w_desc_sunny':
          'Bright clear sky — rain is unlikely. Set a low estimate.',
      'w_desc_cloudy':
          'Grey cloud cover — rain is uncertain. Estimate somewhere in the middle.',
      'w_desc_stormy':
          'Dark storm clouds — rain is very likely. Set a high estimate.',
      's1_0': '0 · Impossible',
      's1_05': '0.5 · Even',
      's1_1': '1 · Certain',
      'lbl_tosses': 'Tosses',
      'lbl_heads': 'Heads',
      'lbl_tails': 'Tails',
      'status_drag': 'Drag the slider to set your estimate, then press Submit.',
      'status_compute':
          'Enter your calculated decimal (e.g. 0.55), then press Submit.',
      's2_desc':
          'Tap the coin to toss it. Repeat until you have 20 random outcomes.',
      'btn_prev': 'Prev',
      'btn_next': 'Next',
      'btn_hint': 'Hint',
      'btn_submit': 'Submit',
      'btn_report': 'Report',
      'btn_close_report': 'Close Report',
      'btn_restart_exp': 'Restart Exploration',
      'btn_reset': 'Reset Activity',
      'hint_lbl': 'Hint / Evidence',
      'learnt_lbl': 'Learnt Conclusion',
      'hint_def':
          'Ask students what they expect before each action. Focus on visible cause and effect.',
      'learnt_desc':
          'A subjective probability is a personal estimate. An experimental probability comes from data — and over many trials it settles near the theoretical value 0.5.',
      'diag_title_pass': 'Investigation Complete!',
      'diag_sub_pass':
          'You compared a subjective forecast with real experimental data.',
      'diag_title_fail': 'Keep Exploring',
      'diag_sub_fail': 'Some steps still need work — adjust and resubmit.',
      'diag_str': 'Strengths',
      'diag_nxt': 'Next Steps',
      'str_prob': 'You framed rain as a clear likelihood between 0 and 1.',
      'imp_prob':
          'Set a subjective probability strictly between 0 and 1 before submitting.',
      'str_fluency': 'You completed the full 20-trial coin experiment.',
      'imp_fluency': 'Finish all 20 coin tosses to gather enough random data.',
      'str_math': 'Your experimental probability heads÷20 was accurate.',
      'imp_math': 'Recompute P(Heads) as heads count divided by 20.',
      'str_logic': 'You connected the data back to the theoretical 0.5.',
      'imp_logic': 'Compare your experimental result with the theoretical 0.5.',
      'st_0_0': 'Study the weather scene.',
      'st_0_1': 'Drag the slider between 0 and 1.',
      'st_0_2': 'Press Submit to record your subjective forecast.',
      'st_1_0': 'Tap the coin to toss it.',
      'st_1_1': 'Keep tossing until 20 outcomes are recorded.',
      'st_1_2': 'Press Submit to confirm 20 tosses are done.',
      'st_1_3': 'Read heads vs tails on the charts.',
      'st_2_0': 'Calculate heads ÷ 20.',
      'st_2_1': 'Type your decimal answer.',
      'st_2_2': 'Press Submit and compare with the theoretical 0.5.',
    },
    'hi': {
      'app_title': 'संभावना अन्वेषक: बाधाओं की भविष्यवाणी करें',
      'tagline': 'कक्षा 9 • शायद का गणित',
      'init_btn': 'मिशन शुरू करें',
      'board_title': 'शिक्षक बोर्ड',
      'obj_label': 'मिशन का उद्देश्य',
      'steps_label': 'अनुदेश अनुक्रम',
      'obj_desc':
          'यादृच्छिक घटनाओं की पहचान करें और व्यक्तिपरक पूर्वानुमान और वस्तुनिष्ठ (प्रयोगात्मक) प्रायिकता के बीच अंतर स्पष्ट करें।',
      'phase_label': 'वर्तमान चरण',
      'pip_0': 'भविष्यवाणी',
      'pip_1': '20 उछाल',
      'pip_2': 'गणना',
      's1_title': 'परिदृश्य 1 · व्यक्तिपरक वर्षा का पूर्वानुमान',
      's2_title': 'परिदृश्य 2 · सिक्का उछाल की यादृच्छिकता',
      's1_slider_title': 'बारिश की आपकी व्यक्तिपरक संभावना',
      's3_title': 'चित की प्रायोगिक प्रायिकता की गणना करें',
      'w_clear': 'साफ़',
      'w_cloudy': 'बादल',
      'w_stormy': 'तूफानी',
      'w_desc_sunny':
          'उज्ज्वल साफ आकाश — बारिश की संभावना नहीं है। कम अनुमान सेट करें।',
      'w_desc_cloudy':
          'धूसर बादल कवर — बारिश अनिश्चित है। बीच में कहीं अनुमान लगाएं।',
      'w_desc_stormy':
          'काले तूफानी बादल — बारिश की बहुत संभावना है। उच्च अनुमान सेट करें।',
      's1_0': '0 · असंभव',
      's1_05': '0.5 · सम',
      's1_1': '1 · निश्चित',
      'lbl_tosses': 'उछाल',
      'lbl_heads': 'चित',
      'lbl_tails': 'पट',
      'status_drag':
          'अपना अनुमान सेट करने के लिए स्लाइडर खींचें, फिर सबमिट दबाएं।',
      'status_compute':
          'अपना परिकलित दशमलव दर्ज करें (जैसे 0.55), फिर सबमिट दबाएं।',
      's2_desc':
          'सिक्के को उछालने के लिए टैप करें। जब तक आपके पास 20 यादृच्छिक परिणाम न आ जाएं, तब तक दोहराएं।',
      'btn_prev': 'पिछला',
      'btn_next': 'अगला',
      'btn_hint': 'संकेत',
      'btn_submit': 'सबमिट',
      'btn_report': 'रिपोर्ट',
      'btn_close_report': 'रिपोर्ट बंद करें',
      'btn_restart_exp': 'अन्वेषण पुनः शुरू करें',
      'btn_reset': 'रीसेट गतिविधि',
      'hint_lbl': 'संकेत / साक्ष्य',
      'learnt_lbl': 'सीखा हुआ निष्कर्ष',
      'hint_def':
          'छात्रों से पूछें कि वे प्रत्येक कार्रवाई से पहले क्या उम्मीद करते हैं। दृश्यमान कारण और प्रभाव पर ध्यान दें।',
      'learnt_desc':
          'एक व्यक्तिपरक संभावना एक व्यक्तिगत अनुमान है। एक प्रयोगात्मक संभावना डेटा से आती है — और कई परीक्षणों के बाद यह सैद्धांतिक मूल्य 0.5 के पास स्थिर हो जाती है।',
      'diag_title_pass': 'अन्वेषण पूर्ण!',
      'diag_sub_pass':
          'आपने वास्तविक प्रायोगिक डेटा के साथ व्यक्तिपरक पूर्वानुमान की तुलना की।',
      'diag_title_fail': 'अन्वेषण जारी रखें',
      'diag_sub_fail':
          'कुछ चरणों में अभी भी काम की आवश्यकता है — समायोजित करें और पुनः सबमिट करें।',
      'diag_str': 'ताकत',
      'diag_nxt': 'अगले कदम',
      'str_prob':
          'आपने बारिश को 0 और 1 के बीच एक स्पष्ट संभावना के रूप में तैयार किया।',
      'imp_prob':
          'सबमिट करने से पहले 0 और 1 के बीच एक व्यक्तिपरक संभावना निर्धारित करें।',
      'str_fluency': 'आपने 20-परीक्षण का पूरा सिक्का प्रयोग पूरा कर लिया है।',
      'imp_fluency':
          'पर्याप्त यादृच्छिक डेटा एकत्र करने के लिए सभी 20 सिक्के उछालना समाप्त करें।',
      'str_math': 'आपकी प्रयोगात्मक संभावना चित÷20 सटीक थी।',
      'imp_math':
          'चित की गिनती को 20 से विभाजित करके P(चित) की पुनः गणना करें।',
      'str_logic': 'आपने डेटा को सैद्धांतिक 0.5 से जोड़ा है।',
      'imp_logic': 'अपने प्रयोगात्मक परिणाम की सैद्धांतिक 0.5 से तुलना करें।',
      'st_0_0': 'मौसम दृश्य का अध्ययन करें।',
      'st_0_1': 'स्लाइडर को 0 और 1 के बीच खींचें।',
      'st_0_2': 'अपना व्यक्तिपरक पूर्वानुमान रिकॉर्ड करने के लिए सबमिट दबाएं।',
      'st_1_0': 'सिक्के को उछालने के लिए उस पर टैप करें।',
      'st_1_1': '20 परिणाम रिकॉर्ड होने तक उछालते रहें।',
      'st_1_2': '20 उछाल पूरे होने की पुष्टि करने के लिए सबमिट दबाएं।',
      'st_1_3': 'चार्ट पर चित बनाम पट पढ़ें।',
      'st_2_0': 'चित ÷ 20 की गणना करें।',
      'st_2_1': 'अपना दशमलव उत्तर टाइप करें।',
      'st_2_2': 'सबमिट दबाएं और सैद्धांतिक 0.5 के साथ तुलना करें।',
    },
  };

  String t(String key) => _text[_language]?[key] ?? _text['en']?[key] ?? key;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    });

    _coinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _coinAnim = Tween<double>(begin: 0, end: 5 * math.pi).animate(
      CurvedAnimation(parent: _coinAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _coinAnimController.dispose();
    _computeController.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  // === Logic Methods ===

  void _showFlashMessage(String msg) {
    setState(() {
      _flashMessage = msg;
      _showFlash = true;
    });
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showFlash = false);
    });
  }

  void _goPhase(int phase) {
    _playClick();
    setState(() {
      _activePhase = phase.clamp(0, 2);
      _activeScenario = _activePhase == 0 ? 0 : 1;
    });
  }

  void _tossCoin() {
    if (_activePhase != 1 ||
        _tossCount >= 20 ||
        _coinAnimController.isAnimating) {
      return;
    }

    _playFx();
    _coinAnimController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _tossCount++;
        bool isHeads = math.Random().nextBool();
        _coinTossResults.add(isHeads ? 'H' : 'T');
        if (isHeads) _headsCount++;

        if (_tossCount >= 20) {
          _showFlashMessage(
            '20 tosses complete! Now compute experimental probability.',
          );
          _playSuccess();
        }
      });
    });
  }

  void _doSubmit() {
    FocusScope.of(context).unfocus();
    if (_activePhase == 0) {
      if (_subjectiveValue > 0 && _subjectiveValue <= 1) {
        _playSuccess();
        setState(() => _subjectiveSubmitted = true);
        _showFlashMessage('Good estimation! Now explore by tossing the coin.');
        _goPhase(1);
      } else {
        _playError();
        _showFlashMessage('Select a valid probability on the slider (0 to 1).');
      }
    } else if (_activePhase == 1) {
      if (_tossCount >= 20) {
        _playSuccess();
        _showFlashMessage('20 tosses complete. Move on to compute.');
        _goPhase(2);
      } else {
        _playError();
        _showFlashMessage(
          'Complete all 20 coin tosses first ($_tossCount/20).',
        );
      }
    } else {
      double? val = double.tryParse(_computeController.text);
      if (val == null || val < 0 || val > 1) {
        _playError();
        _showFlashMessage('Type a decimal between 0 and 1 for P(Heads).');
        return;
      }
      setState(() {
        _experimentSubmitted = true;
        double correctP = _headsCount / 20.0;
        _experimentCorrect = (val - correctP).abs() < 0.01;
      });
      _validateActivity();
    }
  }

  void _doHint() {
    _playClick();
    List<String> hints = [
      'Drag the slider all the way to feel the range: 0 means impossible, 1 means certain.',
      'Each toss is independent — a run of heads does not change the next toss.',
      'Count the heads shown, then divide by 20. (Example: 11 ÷ 20 = 0.55)',
    ];
    _showFlashMessage('💡 ${hints[_activePhase]}');
    setState(() => _hintIdx++);
  }

  void _doReset() {
    _playClick();
    setState(() {
      _language = 'en';
      _weather = 'cloudy';
      _subjectiveValue = 0;
      _subjectiveSubmitted = false;
      _coinTossResults.clear();
      _tossCount = 0;
      _headsCount = 0;
      _computeController.clear();
      _experimentSubmitted = false;
      _experimentCorrect = false;
      _showDiagnostics = false;
      _hasStarted = false;
      _goPhase(0);
    });
  }

  void _validateActivity() {
    int subjOk =
        (_subjectiveSubmitted && _subjectiveValue > 0 && _subjectiveValue <= 1)
        ? 1
        : 0;
    double tossFrac = math.min(1.0, _tossCount / 20.0);
    int expOk = _experimentCorrect ? 1 : 0;

    bool passed = (subjOk == 1 && tossFrac >= 1 && expOk == 1);
    if (passed) {
      _playSuccess();
    } else {
      _playError();
    }

    List<String> strengths = [];
    List<String> improvements = [];

    if (subjOk >= 0.8) {
      strengths.add('str_prob');
    } else {
      improvements.add('imp_prob');
    }
    if (tossFrac >= 0.8) {
      strengths.add('str_fluency');
    } else {
      improvements.add('imp_fluency');
    }
    if (expOk == 1) {
      strengths.add('str_math');
    } else {
      improvements.add('imp_math');
    }

    double logicScore = passed
        ? 1.0
        : (subjOk == 1 && tossFrac >= 1 ? 0.6 : 0.3);
    if (logicScore >= 0.8) {
      strengths.add('str_logic');
    } else {
      improvements.add('imp_logic');
    }

    setState(() {
      _diagPassed = passed;
      _diagStrengths = strengths;
      _diagImprovements = improvements;
      _showDiagnostics = true;
    });
  }

  // === UI Builders ===

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2C60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('s1_title'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF97316),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: _weather == 'sunny'
                      ? [Colors.blue.shade300, Colors.blue.shade100]
                      : _weather == 'stormy'
                      ? [const Color(0xFF1E3A5F), const Color(0xFF334155)]
                      : [const Color(0xFF2A5FB0), const Color(0xFF5B9BD5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Icon(
                  _weather == 'sunny'
                      ? Icons.wb_sunny
                      : _weather == 'stormy'
                      ? Icons.flash_on
                      : Icons.cloud,
                  size: 64,
                  color: _weather == 'sunny'
                      ? Colors.yellow
                      : _weather == 'stormy'
                      ? Colors.grey.shade400
                      : Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t('w_desc_$_weather'),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _weatherBtn('sunny', Icons.wb_sunny, t('w_clear')),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _weatherBtn('cloudy', Icons.cloud, t('w_cloudy')),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _weatherBtn('stormy', Icons.flash_on, t('w_stormy')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherBtn(String type, IconData icon, String label) {
    bool isSel = _weather == type;
    return GestureDetector(
      onTap: () {
        if (!_subjectiveSubmitted) {
          _playClick();
          setState(() => _weather = type);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF97316) : const Color(0xFF0B234D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSel ? const Color(0xFFF97316) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: isSel ? Colors.white : Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSel ? Colors.white : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2C60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t('s1_slider_title'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFF97316),
              inactiveTrackColor: Colors.blueGrey.shade800,
              thumbColor: Colors.white,
              valueIndicatorColor: const Color(0xFFF97316),
            ),
            child: Slider(
              value: _subjectiveValue,
              min: 0,
              max: 1,
              divisions: 100,
              label: _subjectiveValue.toStringAsFixed(2),
              onChanged: _subjectiveSubmitted
                  ? null
                  : (v) => setState(() => _subjectiveValue = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('s1_0'),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              Text(
                t('s1_05'),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              Text(
                t('s1_1'),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t('status_drag'),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinCard() {
    int tailsCount = _tossCount - _headsCount;

    return Opacity(
      opacity: _activePhase >= 1 ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2C60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              t('s2_title'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFF97316),
              ),
            ),
            Text(
              t('s2_desc'),
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _tossCoin,
              child: AnimatedBuilder(
                animation: _coinAnimController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_coinAnim.value),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _coinTossResults.isEmpty ||
                                  _coinAnimController.isAnimating
                              ? '?'
                              : _coinTossResults.last,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statBox(t('lbl_tosses'), _tossCount.toString()),
                const SizedBox(width: 8),
                _statBox(t('lbl_heads'), _headsCount.toString()),
                const SizedBox(width: 8),
                _statBox(t('lbl_tails'), tailsCount.toString()),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar(
                    t('lbl_heads'),
                    _headsCount,
                    math.max(1, math.max(_headsCount, tailsCount)),
                    const Color(0xFFF97316),
                  ),
                  const SizedBox(width: 16),
                  _bar(
                    t('lbl_tails'),
                    tailsCount,
                    math.max(1, math.max(_headsCount, tailsCount)),
                    Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 50,
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0B234D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _coinTossResults
                      .map(
                        (r) => Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: r == 'H'
                                ? const Color(0xFFF97316).withOpacity(0.3)
                                : Colors.blue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: r == 'H'
                                  ? const Color(0xFFF97316)
                                  : Colors.blue,
                            ),
                          ),
                          child: Text(
                            r,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B234D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFACC15),
              ),
            ),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, int val, int maxVal, Color color) {
    double pct = val / maxVal;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 40 * pct,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComputeCard() {
    return Opacity(
      opacity: _activePhase == 2 ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2C60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('s3_title'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFF97316),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'P(Heads) = heads ÷ 20',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _computeController,
              enabled: _activePhase == 2 && !_experimentSubmitted,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0B234D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF97316)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('status_compute'),
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
            if (_experimentSubmitted && _experimentCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Experimental P(Heads) = ${(_headsCount / 20).toStringAsFixed(2)}. Theoretical = 0.50.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(double width) {
    return SizedBox(
      width: width,
      // Wrap the ENTIRE sidebar in a SingleChildScrollView as requested
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.casino,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('app_title'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          t('tagline'),
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons placed right below header
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
                      t('btn_reset'),
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

            // Main Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.co_present, color: Color(0xFFF97316)),
                      const SizedBox(width: 8),
                      Text(
                        t('board_title').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  // Mission Objective
                  _sidebarSection(
                    Icons.flag,
                    t('obj_label'),
                    Text(
                      t('obj_desc'),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),

                  // Scenario Select
                  _sidebarSection(
                    Icons.map,
                    'Scenario',
                    DropdownButtonFormField<int>(
                      value: _activeScenario,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0B234D),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0B234D),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(
                            t('s1_title'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            t('s2_title'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _playClick();
                          _goPhase(val == 0 ? 0 : (_tossCount >= 20 ? 2 : 1));
                        }
                      },
                    ),
                  ),

                  _sidebarSection(
                    Icons.checklist,
                    t('steps_label'),
                    Column(
                      children: List.generate(3, (i) {
                        List<String> steps = [
                          if (_activePhase == 0) ...[
                            'st_0_0',
                            'st_0_1',
                            'st_0_2',
                          ],
                          if (_activePhase == 1) ...[
                            'st_1_0',
                            'st_1_1',
                            'st_1_2',
                            'st_1_3',
                          ],
                          if (_activePhase == 2) ...[
                            'st_2_0',
                            'st_2_1',
                            'st_2_2',
                          ],
                        ];
                        if (i >= steps.length) return const SizedBox.shrink();

                        bool isDone = false;
                        bool isActive = false;

                        if (_activePhase == 0) {
                          if (_subjectiveSubmitted) {
                            isDone = true;
                          } else if (i == 0) {
                            isActive = _subjectiveValue == 0;
                          } else if (i == 1) {
                            isActive =
                                _subjectiveValue > 0 && !_subjectiveSubmitted;
                          } else if (i == 2) {
                            isActive =
                                _subjectiveValue > 0 && !_subjectiveSubmitted;
                          }
                        } else if (_activePhase == 1) {
                          if (_tossCount >= 20) {
                            if (i < 3) isDone = true;
                            if (i == 3) isActive = true;
                          } else {
                            if (i == 0) {
                              isActive = _tossCount == 0;
                            }
                            if (i == 1) {
                              isActive = _tossCount > 0 && _tossCount < 20;
                            }
                          }
                        } else {
                          if (_experimentSubmitted && _experimentCorrect) {
                            isDone = true;
                          } else if (i < 2) {
                            isActive = true;
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFF97316).withOpacity(0.1)
                                : Colors.white.withOpacity(0.05),
                            border: Border(
                              left: BorderSide(
                                color: isDone
                                    ? Colors.green
                                    : (isActive
                                          ? const Color(0xFFF97316)
                                          : Colors.transparent),
                                width: 3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${i + 1}. ${t(steps[i])}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDone
                                        ? Colors.green
                                        : (isActive
                                              ? Colors.white
                                              : Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  _sidebarSection(
                    Icons.lightbulb,
                    t('hint_lbl'),
                    Text(
                      t('hint_def'),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  _sidebarSection(
                    Icons.school,
                    t('learnt_lbl'),
                    Text(
                      t('learnt_desc'),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _actionBtn(
                        Icons.arrow_back_ios,
                        t('btn_prev'),
                        () => _goPhase(_activePhase - 1),
                        _activePhase > 0,
                        isGhost: true,
                      ),
                      _actionBtn(
                        Icons.arrow_forward_ios,
                        t('btn_next'),
                        () => _goPhase(_activePhase + 1),
                        (_activePhase == 0 && _subjectiveSubmitted) ||
                            (_activePhase == 1 && _tossCount >= 20),
                        isGhost: true,
                      ),
                      _actionBtn(
                        Icons.lightbulb,
                        t('btn_hint'),
                        _doHint,
                        true,
                        isGhost: true,
                        iconColor: Colors.yellow,
                      ),
                      _actionBtn(
                        Icons.check,
                        _activePhase == 2 ? 'Submit Answer' : t('btn_submit'),
                        _doSubmit,
                        true,
                        isPrimary: true,
                      ),
                      _actionBtn(
                        Icons.pie_chart,
                        t('btn_report'),
                        () {
                          _playClick();
                          setState(() => _showDiagnostics = true);
                        },
                        _diagPassed || _experimentSubmitted,
                        isSecondary: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '© ZEROSCIENCELAB - Fall in Love with Math and Science',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarSection(IconData icon, String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B234D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFFF97316)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316),
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool enabled, {
    bool isGhost = false,
    bool isPrimary = false,
    bool isSecondary = false,
    Color? iconColor,
  }) {
    Color bg = isPrimary
        ? const Color(0xFFF97316)
        : isSecondary
        ? const Color(0xFFFACC15)
        : Colors.white.withOpacity(0.1);
    Color fg = isPrimary
        ? Colors.white
        : isSecondary
        ? const Color(0xFF08152E)
        : Colors.white;
    if (!enabled) bg = bg.withOpacity(0.3);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: isGhost ? Border.all(color: Colors.white12) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: !enabled ? fg.withOpacity(0.5) : (iconColor ?? fg),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: !enabled ? fg.withOpacity(0.5) : fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Main Build ===

  @override
  Widget build(BuildContext context) {
    // Left sidebar takes up 38% of the screen width as requested
    final double sidebarWidth = MediaQuery.of(context).size.width * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Base background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [Color(0xFF0E2A5E), Color(0xFF071B3F)],
                ),
              ),
            ),

            // Main Layout Row
            Row(
              children: [
                // Left Sidebar - SAFELY ANIMATED using horizontal SingleChildScrollView constraint isolation!
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.white12)),
                  ),
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: _buildSidebar(sidebarWidth),
                    ),
                  ),
                ),

                // Center Activity Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Phase HUD (Language and Reset removed and placed in sidebar)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('phase_label').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFF97316),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _activePhase == 0
                                        ? 'Predict'
                                        : _activePhase == 1
                                        ? 'Toss ×20'
                                        : 'Compute',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Main Interactive Content Area
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Col: Weather & Slider
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildWeatherCard(),
                                      const SizedBox(height: 12),
                                      _buildSliderCard(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right Col: Coin & Compute
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildCoinCard(),
                                      const SizedBox(height: 12),
                                      _buildComputeCard(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Left Menu Button
            Positioned(
              top: 16,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _playClick();
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                ),
              ),
            ),

            // Bottom Left Back Button removed as requested

            // Flash Feedback Overlay
            if (_showFlash)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF97316),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _flashMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

            // Start Screen Overlay (Wrapped safely in SingleChildScrollView to prevent layout overflows)
            if (!_hasStarted)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF071B3F),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.casino,
                            size: 80,
                            color: Color(0xFFF97316),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('app_title').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF97316),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('tagline'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            onPressed: () {
                              _playClick();
                              setState(() => _hasStarted = true);
                              _showFlashMessage(
                                'Welcome! Drag the slider to begin.',
                              );
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Color(0xFF08152E),
                            ),
                            label: Text(
                              t('init_btn'),
                              style: const TextStyle(
                                color: Color(0xFF08152E),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Diagnostics Modal Overlay (Scrollable)
            if (_showDiagnostics)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF071B3F),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _diagPassed
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _diagPassed
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _diagPassed ? Icons.check : Icons.warning,
                                    size: 32,
                                    color: _diagPassed
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _diagPassed
                                            ? t('diag_title_pass')
                                            : t('diag_title_fail'),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _diagPassed
                                            ? t('diag_sub_pass')
                                            : t('diag_sub_fail'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_diagStrengths.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  t('diag_str'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._diagStrengths.map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          t(s),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_diagImprovements.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  t('diag_nxt'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF97316),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._diagImprovements.map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFFF97316),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          t(s),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _playClick();
                                      setState(() => _showDiagnostics = false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white12,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: Text(
                                      t('btn_close_report'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _doReset,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF97316),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: Text(
                                      t('btn_restart_exp'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
