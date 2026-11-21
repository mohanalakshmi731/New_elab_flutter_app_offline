// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto', color: Color(0xFFF8FAFC)),
        ),
      ),
      home: const Cl6M_Ch4_A5_TheHonestPictureDataEthics(),
    ),
  );
}

// --- ENTITY CLASSES ---

class TapeMeasure {
  double x = -50;
  double y = 350;
  double w = 100;
  double h = 150;
  bool horiz = false;
  String? val;
}

class SimStateS1 {
  TapeMeasure tape = TapeMeasure();
  List<String> measuredH = [];
  List<String> measuredW = [];
}

class SimStateS2 {
  double yBase = 1000;
}

class SimStateS3 {
  int blocksPlacedL = 0;
  int blockRejectsR = 0;
}

class SimStateS4 {
  double yBase = 0;
  String shape = 'bar'; // 'bar' or 'car'
  Color color = const Color(0xFFEF4444);
}

class SimStateS5 {
  String orientation = 'vertical'; // 'vertical' or 'horizontal'
  double scale = 200;
}

class SimState {
  String activeDrag = '';
  double dragX = 0;
  double dragY = 0;

  SimStateS1 s1 = SimStateS1();
  SimStateS2 s2 = SimStateS2();
  SimStateS3 s3 = SimStateS3();
  SimStateS4 s4 = SimStateS4();
  SimStateS5 s5 = SimStateS5();
}

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  static Future<void> tick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  static Future<void> snap() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  static Future<void> success() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  static Future<void> error() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  static Future<void> pop() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- LOCALIZATION ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'appTitle': 'The Honest Picture',
    'subtitle': 'Visual Design & Ethics',
    'enter': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'mission': 'Mission Objective:',
    'stepLabel': 'Step',
    'summaryBtn': 'Summary',
    'checkBtn': 'Check My Work',
    'submitBtn': 'Submit Design',
    'nextBtn': 'Next Scenario',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',

    's1_title': '1. The Case of the Warped Mountains',
    's1_obj':
        'Visually discover how using non-uniform shapes (triangles) in a graph can distort the perception of data.',
    's1_hud1': 'Measure heights on the bar graph.',
    's1_hud2': 'Measure heights on the triangle graph.',
    's1_hud3': 'Rotate tape and measure widths on the bar graph.',
    's1_hud4': 'Measure base widths on the triangle graph.',
    's1_hud5': 'Click \'Summary\' to review findings.',
    's1_t1':
        'DRAG the measuring tape. Measure the height of the \'Everest\' and \'Elbrus\' bars.',
    's1_o1': 'Everest is slightly >1.5x taller than Elbrus.',
    's1_t2': 'Measure the heights of the triangles on the right.',
    's1_o2': 'The heights match the bar graph exactly.',
    's1_t3':
        'Click the rotate button on the tape. Measure the WIDTH of the bars.',
    's1_o3': 'The widths of both bars are identical.',
    's1_t4': 'Measure the WIDTH of the bases of the triangles.',
    's1_o4': 'The Everest triangle has a much wider base!',
    's1_t5': 'CLICK the \'Summary\' button.',
    's1_o5': 'Review completed.',
    's1_summary_title': 'The Distortion Effect',
    's1_summary_desc':
        'You found the problem! The triangle graph is misleading. Even though the heights are correct, making taller mountains wider makes the difference seem much bigger than it really is.',

    's2_title': '2. The Incredible Shrinking Difference',
    's2_obj':
        'Understand how a truncated Y-axis (one that doesn\'t start at 0) can exaggerate differences in a bar graph.',
    's2_hud1': 'Observe the dramatic height difference.',
    's2_hud2': 'Slide the Y-axis base down to 0.',
    's2_hud3': 'Slide back and forth to see the effect.',
    's2_hud4': 'Click \'Summary\' to review.',
    's2_t1':
        'Look at the tiger graph. The 2022 bar looks huge compared to 2006. Notice the Y-axis starts at 1000.',
    's2_o1': 'Observed the truncated axis.',
    's2_t2': 'DRAG the slider at the bottom of the Y-axis to \'0\'.',
    's2_o2': 'The relative difference shrinks dramatically.',
    's2_t3': 'DRAG the slider back and forth.',
    's2_o3': 'Internalized the cause and effect of the axis baseline.',
    's2_t4': 'CLICK the \'Summary\' button.',
    's2_o4': 'Review completed.',
    's2_summary_title': 'Always Start at Zero',
    's2_summary_desc':
        'You fixed the graph! By starting the numbers at 0, you can see the real difference.',

    's3_title': '3. The Pictograph Puzzle',
    's3_obj':
        'Learn that a pictograph\'s scale must be chosen carefully to allow for clear and accurate representation of data.',
    's3_hud1': 'Observe the left graph (Scale=6).',
    's3_hud2': 'Drag blocks to confirm the exact count.',
    's3_hud3': 'Observe the right graph (Scale=10) with sliced icons.',
    's3_hud4': 'Try to drop blocks on the sliced icon.',
    's3_hud5': 'Click \'Summary\' to review.',
    's3_t1': 'Observe the left graph. Scale is 6 dogs per icon.',
    's3_o1': '6 exact icons = 36 dogs.',
    's3_t2': 'DRAG blocks from the toolbox onto Village B (left).',
    's3_o2': '36 blocks fit perfectly over 6 icons.',
    's3_t3': 'Look at the right graph. Scale is 10 dogs per icon.',
    's3_o3': 'Icons are sliced, making them hard to read.',
    's3_t4': 'Try to drag blocks onto Village B (right).',
    's3_o4': 'It\'s confusing. Blocks don\'t map clearly to sliced pictures.',
    's3_t5': 'CLICK the \'Summary\' button.',
    's3_o5': 'Review completed.',
    's3_summary_title': 'The Perfect Scale',
    's3_summary_desc':
        'You\'ve discovered why choosing the right scale is important! Exact multiples make it easy to read.',

    's4_title': '4. The Great Traffic Exaggeration',
    's4_obj':
        'Apply techniques of data distortion to create a deliberately misleading bar graph.',
    's4_hud1': 'Observe the traffic data.',
    's4_hud2':
        'Use tools to build a misleading graph. Set Y-axis high, select Car shape.',
    's4_hud3': 'Click \'Check My Work\'.',
    's4_t1': 'Goal: Make traffic between 7-8am look HUGE compared to 6-7am.',
    's4_o1': 'Mission accepted.',
    's4_t2':
        'Use the UI overlays on canvas: Slide Y-axis base high. Toggle shape to \'Car\'.',
    's4_o2': 'Graph is visually distorted.',
    's4_t3': 'CLICK the \'Check My Work\' button in the sidebar.',
    's4_o3': 'AI flagged the misleading techniques correctly.',
    's4_summary_title': 'Master of Illusion',
    's4_summary_desc':
        'You successfully used misleading techniques! The AI Honesty Checker flagged the truncated axis and the distorted 2D shape.',

    's5_title': '5. The Honest River Chart',
    's5_obj':
        'Apply principles of good visual design to create the clearest and most honest graph.',
    's5_hud1': 'Observe the river length data.',
    's5_hud2': 'Set orientation to Horizontal, Scale to 1000, Y-base to 0.',
    's5_hud3': 'Click \'Submit Design\'.',
    's5_t1': 'Goal: Create the BEST possible bar graph.',
    's5_o1': 'Mission accepted.',
    's5_t2':
        'Use the UI overlays: Set orientation to \'Horizontal\'. Adjust scale. Ensure Y-axis is at 0.',
    's5_o2': 'A clean, horizontal bar graph is created.',
    's5_t3': 'CLICK \'Submit Design\'.',
    's5_o3': 'AI approved the honest design.',
    's5_summary_title': 'Ethical Data Designer',
    's5_summary_desc':
        'Excellent choices! Horizontal bars are perfect for length, the axis starts at 0 for honest comparison.',

    'c_s1_barTitle': 'Tallest Mountains (Bar Graph)',
    'c_s1_triTitle': 'Tallest Mountains (Infographic)',
    'c_s1_elbrus': 'Elbrus',
    'c_s1_everest': 'Everest',
    'c_s2_title': 'Tiger Population in India',
    'c_s2_yStart': 'Y-Axis Start Value: ',
    'c_s3_title': 'Mudhol Hounds by Village',
    'c_s3_scale6': 'Scale: 1 Icon = 6 Dogs',
    'c_s3_scale10': 'Scale: 1 Icon = 10 Dogs',
    'c_s3_villB': 'Village B (36)',
    'c_s3_villC': 'Village C (12)',
    'c_s3_toolbox': 'Toolbox: Counting Blocks (1 block = 1 dog)',
    'c_s3_drag': 'DRAG',
    'c_s4_title': 'Traffic Data (Delhi Crossing)',
    'c_s4_6am': '6-7 a.m.',
    'c_s4_7am': '7-8 a.m.',
    'c_s4_barShape': 'Bar Shape',
    'c_s4_stdBar': 'Standard Bar',
    'c_s4_carIcon': 'Car Icon (Distorts Width)',
    'c_s5_title': 'Longest Rivers Data',
    'c_s5_nile': 'Nile',
    'c_s5_amazon': 'Amazon',
    'c_s5_yangtze': 'Yangtze',
    'c_s5_orient': 'Orientation',
    'c_s5_vert': 'Vertical Bars',
    'c_s5_horiz': 'Horizontal Bars',
    'c_s5_scaleLbl': 'Scale (1 unit = km): ',
    'c_s1_tapeMeasureH': 'Measure H',
    'c_s1_tapeMeasureW': 'Measure W',
    'c_s1_tapeUnits': 'units',
  },
  'hi': {
    'appTitle': 'सच्ची तस्वीर',
    'subtitle': 'दृश्य डिज़ाइन और नैतिकता',
    'enter': 'सिमुलेशन दर्ज करें',
    'selectScenario': 'परिदृश्य चुनें',
    'मिशन': 'मिशन उद्देश्य:',
    'stepLabel': 'कदम',
    'summaryBtn': 'सारांश',
    'checkBtn': 'मेरा काम जाँचें',
    'submitBtn': 'डिज़ाइन सबमिट करें',
    'nextBtn': 'अगला परिदृश्य',
    'footer': '© ZeroScienceLab - विज्ञान और गणित से प्यार करें',

    's1_title': '1. मुड़े हुए पहाड़ों का मामला',
    's1_obj':
        'पता लगाएँ कि एक ग्राफ़ में त्रिकोण का उपयोग डेटा की धारणा को कैसे विकृत कर सकता है।',
    's1_hud1': 'बार ग्राफ़ पर ऊँचाई मापें।',
    's1_hud2': 'त्रिकोण ग्राफ़ पर ऊँचाई मापें।',
    's1_hud3': 'टेप घुमाएँ और बार ग्राफ़ पर चौड़ाई मापें।',
    's1_hud4': 'त्रिकोण ग्राफ़ पर आधार चौड़ाई मापें।',
    's1_hud5': 'निष्कर्षों की समीक्षा करने के लिए सारांश पर क्लिक करें।',
    's1_t1': 'मापने वाले टेप को खींचें। एवरेस्ट और एल्ब्रस बार की ऊँचाई मापें।',
    's1_o1': 'एवरेस्ट एल्ब्रस से थोड़ा >1.5x लंबा है।',
    's1_t2': 'दाईं ओर के त्रिकोणों की ऊँचाई मापें।',
    's1_o2': 'ऊँचाई बार ग्राफ़ से बिल्कुल मेल खाती है।',
    's1_t3': 'टेप पर रोटेट बटन पर क्लिक करें। बार की चौड़ाई मापें।',
    's1_o3': 'दोनों बार की चौड़ाई समान है।',
    's1_t4': 'त्रिकोणों के आधारों की चौड़ाई मापें।',
    's1_o4': 'एवरेस्ट त्रिकोण का आधार बहुत चौड़ा है!',
    's1_t5': 'सारांश बटन पर क्लिक करें।',
    's1_o5': 'समीक्षा पूरी हुई।',
    's1_summary_title': 'विरूपण प्रभाव',
    's1_summary_desc':
        'आपको समस्या मिल गई! त्रिकोण ग्राफ़ भ्रामक है। भले ही ऊँचाई सही हो, ऊँचे पहाड़ों को चौड़ा बनाने से अंतर वास्तविकता से कहीं अधिक बड़ा लगता है।',

    's2_title': '2. अविश्वसनीय सिकुड़ता अंतर',
    's2_obj':
        'समझें कि कैसे एक छोटा Y-अक्ष बार ग्राफ़ में अंतर को बढ़ा-चढ़ा कर पेश कर सकता है।',
    's2_hud1': 'ऊँचाई के नाटकीय अंतर को देखें।',
    's2_hud2': 'Y-अक्ष के आधार को नीचे 0 पर स्लाइड करें।',
    's2_hud3': 'प्रभाव देखने के लिए आगे-पीछे स्लाइड करें।',
    's2_hud4': 'समीक्षा करने के लिए सारांश पर क्लिक करें।',
    's2_t1':
        'बाघ के ग्राफ़ को देखें। ध्यान दें कि Y-अक्ष 1000 से शुरू होता है।',
    's2_o1': 'कटे हुए अक्ष को देखा गया।',
    's2_t2': 'Y-अक्ष के नीचे वाले स्लाइडर को 0 पर खींचें।',
    's2_o2': 'सापेक्ष अंतर नाटकीय रूप से सिकुड़ जाता है।',
    's2_t3': 'स्लाइडर को आगे-पीछे खींचें।',
    's2_o3': 'अक्ष बेसलाइन के कारण और प्रभाव को समझा।',
    's2_t4': 'सारांश बटन पर क्लिक करें।',
    's2_o4': 'समीक्षा पूरी हुई।',
    's2_summary_title': 'हमेशा शून्य से शुरू करें',
    's2_summary_desc':
        'आपने ग्राफ़ को ठीक कर दिया! 0 से शुरू करके, आप वास्तविक अंतर देख सकते हैं।',

    's3_title': '3. पिक्टोग्राफ पहेली',
    's3_obj':
        'जानें कि डेटा के स्पष्ट प्रतिनिधित्व की अनुमति देने के लिए पैमाने को सावधानीपूर्वक चुना जाना चाहिए।',
    's3_hud1': 'बाएं ग्राफ़ का निरीक्षण करें।',
    's3_hud2': 'सटीक गणना की पुष्टि करने के लिए ब्लॉक खींचें।',
    's3_hud3': 'कटे हुए आइकन के साथ दाएं ग्राफ़ का निरीक्षण करें।',
    's3_hud4': 'कटे हुए आइकन पर ब्लॉक छोड़ने का प्रयास करें।',
    's3_hud5': 'समीक्षा करने के लिए सारांश पर क्लिक करें।',
    's3_t1': 'बाएं ग्राफ़ का निरीक्षण करें। पैमाना प्रति आइकन 6 कुत्ते है।',
    's3_o1': '6 सटीक आइकन = 36 कुत्ते।',
    's3_t2': 'टूलबॉक्स से ब्लॉक्स को विलेज बी पर खींचें।',
    's3_o2': '36 ब्लॉक 6 आइकन पर पूरी तरह से फिट होते हैं।',
    's3_t3': 'दाएं ग्राफ़ को देखें। पैमाना प्रति आइकन 10 कुत्ते है।',
    's3_o3': 'आइकन कटे हुए हैं, जिससे उन्हें पढ़ना मुश्किल हो जाता है।',
    's3_t4': 'विलेज बी पर ब्लॉक खींचने का प्रयास करें।',
    's3_o4': 'यह भ्रमित करने वाला है।',
    's3_t5': 'सारांश बटन पर क्लिक करें।',
    's3_o5': 'समीक्षा पूरी हुई।',
    's3_summary_title': 'सही पैमाना',
    's3_summary_desc':
        'आपने खोज लिया है कि सही पैमाना चुनना क्यों महत्वपूर्ण है!',

    's4_title': '4. महान यातायात अतिशयोक्ति',
    's4_obj':
        'जानबूझकर भ्रामक बार ग्राफ़ बनाने के लिए डेटा विरूपण की तकनीकों को लागू करें।',
    's4_hud1': 'यातायात डेटा का निरीक्षण करें।',
    's4_hud2': 'भ्रामक ग्राफ़ बनाने के लिए टूल का उपयोग करें।',
    's4_hud3': 'मेरा काम जाँचें पर क्लिक करें।',
    's4_t1': 'लक्ष्य: यातायात को विशाल दिखाना।',
    's4_o1': 'मिशन स्वीकार किया गया।',
    's4_t2': 'Y-अक्ष आधार को ऊंचा स्लाइड करें। आकार को कार में टॉगल करें।',
    's4_o2': 'ग्राफ़ दृष्टिगत रूप से विकृत है।',
    's4_t3': 'साइडबार में मेरा काम जाँचें बटन पर क्लिक करें।',
    's4_o3': 'एआई ने भ्रामक तकनीकों को सही ढंग से चिह्नित किया।',
    's4_summary_title': 'भ्रम का उस्ताद',
    's4_summary_desc': 'आपने भ्रामक तकनीकों का सफलतापूर्वक उपयोग किया!',

    's5_title': '5. ईमानदार नदी चार्ट',
    's5_obj':
        'सबसे स्पष्ट और सबसे ईमानदार ग्राफ़ बनाने के लिए अच्छे दृश्य डिज़ाइन के सिद्धांतों को लागू करें।',
    's5_hud1': 'नदी की लंबाई के डेटा का निरीक्षण करें।',
    's5_hud2': 'अभिविन्यास को क्षैतिज सेट करें।',
    's5_hud3': 'डिज़ाइन सबमिट करें पर क्लिक करें।',
    's5_t1': 'लक्ष्य: सर्वोत्तम संभव बार ग्राफ़ बनाना।',
    's5_o1': 'मिशन स्वीकार किया गया।',
    's5_t2': 'यूआई ओवरले का उपयोग करें: क्षैतिज पर सेट करें।',
    's5_o2': 'एक साफ, क्षैतिज बार ग्राफ़ बनाया गया है।',
    's5_t3': 'डिज़ाइन सबमिट करें पर क्लिक करें।',
    's5_o3': 'एआई ने ईमानदार डिजाइन को मंजूरी दी।',
    's5_summary_title': 'नैतिक डेटा डिजाइनर',
    's5_summary_desc':
        'उत्कृष्ट विकल्प! आप डेटा के एक नैतिक प्रस्तुतकर्ता हैं!',

    'c_s1_barTitle': 'सबसे ऊंचे पहाड़ (बार ग्राफ)',
    'c_s1_triTitle': 'सबसे ऊंचे पहाड़ (इन्फोग्राफिक)',
    'c_s1_elbrus': 'एल्ब्रस',
    'c_s1_everest': 'एवरेस्ट',
    'c_s2_title': 'भारत में बाघों की आबादी',
    'c_s2_yStart': 'Y-Axis Start Value: ',
    'c_s3_title': 'गांव के अनुसार मुधोल हाउंड्स',
    'c_s3_scale6': 'पैमाना: 1 आइकन = 6 कुत्ते',
    'c_s3_scale10': 'पैमाना: 1 आइकन = 10 कुत्ते',
    'c_s3_villB': 'गाँव बी (36)',
    'c_s3_villC': 'गाँव सी (12)',
    'c_s3_toolbox': 'टूलबॉक्स: गिनती ब्लॉक',
    'c_s3_drag': 'खींचें',
    'c_s4_title': 'यातायात डेटा',
    'c_s4_6am': '6-7 सुबह',
    'c_s4_7am': '7-8 सुबह',
    'c_s4_barShape': 'बार आकार',
    'c_s4_stdBar': 'मानक बार',
    'c_s4_carIcon': 'कार आइकन',
    'c_s5_title': 'सबसे लंबी नदियाँ',
    'c_s5_nile': 'नील',
    'c_s5_amazon': 'अमेज़न',
    'c_s5_yangtze': 'यांग्त्ज़ी',
    'c_s5_orient': 'अभिविन्यास',
    'c_s5_vert': 'लंबवत बार',
    'c_s5_horiz': 'क्षैतिज बार',
    'c_s5_scaleLbl': 'पैमाना (किमी): ',
    'c_s1_tapeMeasureH': 'ऊँचाई मापें',
    'c_s1_tapeMeasureW': 'चौड़ाई मापें',
    'c_s1_tapeUnits': 'इकाई',
  },
};

// --- MAIN SCREEN ---
class Cl6M_Ch4_A5_TheHonestPictureDataEthics extends StatefulWidget {
  const Cl6M_Ch4_A5_TheHonestPictureDataEthics({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch4_A5_TheHonestPictureDataEthics> createState() =>
      _Cl6M_Ch4_A5_TheHonestPictureDataEthicsState();
}

class _Cl6M_Ch4_A5_TheHonestPictureDataEthicsState
    extends State<Cl6M_Ch4_A5_TheHonestPictureDataEthics> {
  String lang = 'en';
  bool showCurtain = true;
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;

  double zoom = 1.0;
  double _baseZoom = 1.0; // Added for smooth, non-exponential scaling
  double panX = 0;
  double panY = 0;

  int scenario = 1;
  int step = 0;

  SimState state = SimState();

  final GlobalKey _canvasKey = GlobalKey();

  Timer? _obsTimer;

  String t(String key) => i18n[lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _obsTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _resetLab() {
    AudioEngine.error();
    setState(() {
      scenario = 1;
      step = 0;
      zoom = 1.0;
      panX = 0;
      panY = 0;
      state = SimState();
      showCurtain = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => showCurtain = false);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      scenario = id;
      step = 0;
      zoom = 1.0;
      panX = 0;
      panY = 0;
      _obsTimer?.cancel();
      AudioEngine.pop();
    });

    _autoAdvanceChecks();
  }

  void _advanceStep() {
    if (!mounted) return;
    setState(() {
      step++;
      _obsTimer?.cancel();
    });
    _autoAdvanceChecks();
  }

  void _autoAdvanceChecks() {
    if ((scenario == 2 && step == 0) ||
        (scenario == 3 && step == 0) ||
        (scenario == 4 && step == 0) ||
        (scenario == 5 && step == 0)) {
      _obsTimer = Timer(const Duration(seconds: 3), () {
        AudioEngine.success();
        _advanceStep();
      });
    }
    if (scenario == 3 && step == 2) {
      _obsTimer = Timer(const Duration(seconds: 2), () {
        AudioEngine.success();
        _advanceStep();
      });
    }
  }

  void _triggerFooterAction() {
    AudioEngine.success();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              scenario == 4
                  ? Icons.warning_rounded
                  : Icons.check_circle_rounded,
              color: scenario == 4 ? Colors.redAccent : Colors.greenAccent,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('s${scenario}_summary_title'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          t('s${scenario}_summary_desc'),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (scenario < 5) _loadScenario(scenario + 1);
            },
            child: const Text(
              "Got it!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Offset _getWorldCoord(Offset screenLocal, Size size) {
    return Offset(
      (screenLocal.dx - size.width / 2 - panX) / zoom,
      (screenLocal.dy - size.height / 2 - panY) / zoom,
    );
  }

  // Expanded hit test with padding for extremely forgiving touch targets
  bool _hitTestBox(
    double bx,
    double by,
    double bw,
    double bh,
    Offset wPt, {
    double padding = 0,
  }) {
    return wPt.dx >= bx - padding &&
        wPt.dx <= bx + bw + padding &&
        wPt.dy >= by - padding &&
        wPt.dy <= by + bh + padding;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = zoom;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final RenderBox box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final Offset localPt = event.localPosition;
    final Offset wPt = _getWorldCoord(localPt, box.size);

    if (scenario == 1) {
      double btnX =
          state.s1.tape.x + (state.s1.tape.horiz ? state.s1.tape.h / 2 : -60);
      double btnY =
          state.s1.tape.y + (state.s1.tape.horiz ? -60 : state.s1.tape.h / 2);

      // Added massive 30px hit slop for the rotate button so it's super easy to tap
      if (_hitTestBox(btnX - 20, btnY - 20, 40, 40, wPt, padding: 30.0)) {
        setState(() {
          state.s1.tape.horiz = !state.s1.tape.horiz;
          state.s1.tape.h = 150;
          state.s1.tape.val = state.s1.tape.horiz
              ? t('c_s1_tapeMeasureW')
              : t('c_s1_tapeMeasureH');
          AudioEngine.pop();
        });
        return;
      }

      double hitW = state.s1.tape.horiz ? state.s1.tape.h : 60;
      double hitH = state.s1.tape.horiz ? 60 : state.s1.tape.h;
      double cx = state.s1.tape.horiz ? 0 : -30;
      double cy = state.s1.tape.horiz ? -30 : 0;

      // Added 30px hit slop for dragging the tape measure
      if (_hitTestBox(
        state.s1.tape.x + cx,
        state.s1.tape.y + cy,
        hitW,
        hitH,
        wPt,
        padding: 30.0,
      )) {
        state.activeDrag = 's1_tape';
        state.dragX = wPt.dx - state.s1.tape.x;
        state.dragY = wPt.dy - state.s1.tape.y;
        AudioEngine.tick();
      }
    } else if (scenario == 2) {
      double handleX = -150 + (state.s2.yBase / 1000) * 300;
      // Added 30px hit slop for the slider handle
      if (_hitTestBox(handleX - 20, 335, 40, 40, wPt, padding: 30.0)) {
        state.activeDrag = 's2_slider';
        AudioEngine.tick();
      }
    } else if (scenario == 3) {
      // Added 20px hit slop for the blocks
      if (_hitTestBox(-50, 250, 100, 100, wPt, padding: 20.0)) {
        state.activeDrag = 's3_block';
        AudioEngine.tick();
      }
    }
  }

  void _handlePointerUpdate(ScaleUpdateDetails details) {
    if (state.activeDrag.isEmpty) {
      setState(() {
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
        zoom = max(0.2, min(3.0, _baseZoom * details.scale));
      });
      return;
    }

    final RenderBox box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final Offset localPt = box.globalToLocal(details.focalPoint);
    final Offset wPt = _getWorldCoord(localPt, box.size);

    setState(() {
      if (state.activeDrag == 's1_tape') {
        double rawX = wPt.dx - state.dragX;
        double rawY = wPt.dy - state.dragY;
        bool snapped = false;

        if (!state.s1.tape.horiz) {
          if ((rawX - (-410)).abs() < 80 && (rawY - 100).abs() < 150) {
            state.s1.tape.x = -450;
            state.s1.tape.y = 9;
            state.s1.tape.h = 191;
            state.s1.tape.val = "5642m";
            snapped = true;
            if (!state.s1.measuredH.contains('elb_b')) {
              state.s1.measuredH.add('elb_b');
            }
          } else if ((rawX - (-260)).abs() < 80 && (rawY - 50).abs() < 200) {
            state.s1.tape.x = -300;
            state.s1.tape.y = -100;
            state.s1.tape.h = 300;
            state.s1.tape.val = "8848m";
            snapped = true;
            if (!state.s1.measuredH.contains('eve_b')) {
              state.s1.measuredH.add('eve_b');
            }
          } else if ((rawX - 295).abs() < 100 && (rawY - 100).abs() < 150) {
            state.s1.tape.x = 200;
            state.s1.tape.y = 9;
            state.s1.tape.h = 191;
            state.s1.tape.val = "5642m";
            snapped = true;
            if (!state.s1.measuredH.contains('elb_t')) {
              state.s1.measuredH.add('elb_t');
            }
          } else if ((rawX - 550).abs() < 150 && (rawY - 50).abs() < 200) {
            state.s1.tape.x = 400;
            state.s1.tape.y = -100;
            state.s1.tape.h = 300;
            state.s1.tape.val = "8848m";
            snapped = true;
            if (!state.s1.measuredH.contains('eve_t')) {
              state.s1.measuredH.add('eve_t');
            }
          } else {
            state.s1.tape.x = rawX;
            state.s1.tape.y = rawY;
            state.s1.tape.h = 150;
            state.s1.tape.val = t('c_s1_tapeMeasureH');
          }
        } else {
          if ((rawX - (-410)).abs() < 80 && (rawY - 200).abs() < 100) {
            state.s1.tape.x = -450;
            state.s1.tape.y = 230;
            state.s1.tape.h = 80;
            state.s1.tape.val = "80 ${t('c_s1_tapeUnits')}";
            snapped = true;
            if (!state.s1.measuredW.contains('elb_b')) {
              state.s1.measuredW.add('elb_b');
            }
          } else if ((rawX - (-260)).abs() < 80 && (rawY - 200).abs() < 100) {
            state.s1.tape.x = -300;
            state.s1.tape.y = 230;
            state.s1.tape.h = 80;
            state.s1.tape.val = "80 ${t('c_s1_tapeUnits')}";
            snapped = true;
            if (!state.s1.measuredW.contains('eve_b')) {
              state.s1.measuredW.add('eve_b');
            }
          } else if ((rawX - 295).abs() < 100 && (rawY - 200).abs() < 100) {
            state.s1.tape.x = 200;
            state.s1.tape.y = 230;
            state.s1.tape.h = 191;
            state.s1.tape.val = "191 ${t('c_s1_tapeUnits')}";
            snapped = true;
            if (!state.s1.measuredW.contains('elb_t')) {
              state.s1.measuredW.add('elb_t');
            }
          } else if ((rawX - 550).abs() < 150 && (rawY - 200).abs() < 100) {
            state.s1.tape.x = 400;
            state.s1.tape.y = 230;
            state.s1.tape.h = 300;
            state.s1.tape.val = "300 ${t('c_s1_tapeUnits')}";
            snapped = true;
            if (!state.s1.measuredW.contains('eve_t')) {
              state.s1.measuredW.add('eve_t');
            }
          } else {
            state.s1.tape.x = rawX;
            state.s1.tape.y = rawY;
            state.s1.tape.h = 150;
            state.s1.tape.val = t('c_s1_tapeMeasureW');
          }
        }

        if (snapped && state.s1.measuredH.length == 2 && step == 0) {
          _advanceStep();
        }
        if (snapped && state.s1.measuredH.length == 4 && step == 1) {
          _advanceStep();
        }
        if (snapped && state.s1.measuredW.length == 2 && step == 2) {
          _advanceStep();
        }
        if (snapped && state.s1.measuredW.length == 4 && step == 3) {
          _advanceStep();
        }
      } else if (state.activeDrag == 's2_slider') {
        double relX = wPt.dx - (-150);
        state.s2.yBase = max(0, min(1000, (relX / 300 * 1000).roundToDouble()));
        if (state.s2.yBase == 0 && step == 1) _advanceStep();
        if (state.s2.yBase > 500 && step == 2) _advanceStep();
      } else if (state.activeDrag == 's3_block') {
        state.dragX = wPt.dx;
        state.dragY = wPt.dy;
      }
    });
  }

  void _handlePointerUp(ScaleEndDetails details) {
    if (state.activeDrag.isEmpty) return;

    if (state.activeDrag == 's1_tape' || state.activeDrag == 's2_slider') {
      AudioEngine.snap();
    } else if (state.activeDrag == 's3_block') {
      Offset wPt = Offset(state.dragX, state.dragY);
      if (_hitTestBox(-400, -100, 300, 250, wPt)) {
        setState(() => state.s3.blocksPlacedL = 36);
        AudioEngine.success();
        if (step == 1) _advanceStep();
      } else if (_hitTestBox(100, -100, 300, 250, wPt)) {
        setState(() => state.s3.blockRejectsR++);
        AudioEngine.error();
        if (step == 3) _advanceStep();
      } else {
        AudioEngine.pop();
      }
    }
    setState(() => state.activeDrag = '');
  }

  // Generate dynamic steps based on current scenario
  List<Map<String, String>> _getSteps() {
    List<Map<String, String>> steps = [];
    int maxSteps = scenario == 1
        ? 5
        : scenario == 2
        ? 4
        : scenario == 3
        ? 5
        : 3;
    for (int i = 1; i <= maxSteps; i++) {
      steps.add({
        'hud': t('s${scenario}_hud$i'),
        'task': t('s${scenario}_t$i'),
        'outcome': t('s${scenario}_o$i'),
      });
    }
    return steps;
  }

  Widget _buildSidebar() {
    List<Map<String, String>> steps = _getSteps();
    bool showFooter = false;
    String footerBtn = "";

    if (scenario == 1 && step == 4) {
      showFooter = true;
      footerBtn = t('summaryBtn');
    }
    if (scenario == 2 && step == 3) {
      showFooter = true;
      footerBtn = t('summaryBtn');
    }
    if (scenario == 3 && step == 4) {
      showFooter = true;
      footerBtn = t('summaryBtn');
    }
    if (scenario == 4 && step == 2) {
      showFooter = true;
      footerBtn = t('checkBtn');
    }
    if (scenario == 5 && step == 2) {
      showFooter = true;
      footerBtn = t('submitBtn');
    }

    return Container(
      color: const Color(0xFF1E293B),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 66,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.local_activity,
                      color: Color(0xFF6366F1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('appTitle'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t('subtitle'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.language, size: 16),
                              label: Text(
                                lang.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  lang = lang == 'en' ? 'hi' : 'en';
                                  if (state.s1.tape.val == 'Measure H' ||
                                      state.s1.tape.val == 'Measure W' ||
                                      state.s1.tape.val == 'ऊँचाई मापें' ||
                                      state.s1.tape.val == 'चौड़ाई मापें') {
                                    state.s1.tape.val = state.s1.tape.horiz
                                        ? t('c_s1_tapeMeasureW')
                                        : t('c_s1_tapeMeasureH');
                                  }
                                });
                                AudioEngine.pop();
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(
                                  0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: _resetLab,
                              tooltip: "Reset Simulation",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('selectScenario').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        value: scenario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        items: [1, 2, 3, 4, 5]
                            .map(
                              (id) => DropdownMenuItem(
                                value: id,
                                child: Text(
                                  t('s${id}_title'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) _loadScenario(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Color(0xFF6366F1),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('mission'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF818CF8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('s${scenario}_obj'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(steps.length, (i) {
                    bool isCompleted = i < step;
                    bool isCurrent = i == step;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : (isCompleted
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.02)),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF6366F1)
                              : (isCompleted ? Colors.green : Colors.white10),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green
                                  : (isCurrent
                                        ? const Color(0xFF6366F1)
                                        : Colors.white12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : Text(
                                    "${i + 1}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${t('stepLabel')} ${i + 1}".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  steps[i]['task']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isCurrent
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Observation: ${steps[i]['outcome']}",
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (showFooter)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _triggerFooterAction,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        footerBtn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  t('footer'),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayControls() {
    if (scenario == 4) {
      return Positioned(
        right: 40,
        top: 40,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${t('c_s2_yStart')} ${state.s4.yBase.toInt()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              Slider(
                value: state.s4.yBase,
                min: 0,
                max: 20,
                activeColor: const Color(0xFF6366F1),
                onChanged: (v) {
                  setState(() => state.s4.yBase = v);
                  // Removed audio tick on slider drag to prevent network lag loop
                  if (step == 1) _advanceStep();
                },
                onChangeEnd: (v) =>
                    AudioEngine.snap(), // Play sound only when user stops dragging
              ),
              const SizedBox(height: 12),
              Text(
                t('c_s4_barShape'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: state.s4.shape,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'bar',
                    child: Text(
                      t('c_s4_stdBar'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'car',
                    child: Text(
                      t('c_s4_carIcon'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => state.s4.shape = v);
                  AudioEngine.tick();
                  if (step == 1) _advanceStep();
                },
              ),
            ],
          ),
        ),
      );
    }
    if (scenario == 5) {
      return Positioned(
        right: 40,
        top: 40,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('c_s5_orient'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: state.s5.orientation,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'vertical',
                    child: Text(
                      t('c_s5_vert'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'horizontal',
                    child: Text(
                      t('c_s5_horiz'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => state.s5.orientation = v);
                  AudioEngine.tick();
                  if (step == 1) _advanceStep();
                },
              ),
              const SizedBox(height: 12),
              Text(
                "${t('c_s5_scaleLbl')} ${state.s5.scale.toInt()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              Slider(
                value: state.s5.scale,
                min: 100,
                max: 1000,
                divisions: 9,
                activeColor: const Color(0xFF6366F1),
                onChanged: (v) {
                  setState(() => state.s5.scale = v);
                  // Removed audio tick on slider drag to prevent network lag loop
                  if (step == 1) _advanceStep();
                },
                onChangeEnd: (v) =>
                    AudioEngine.snap(), // Play sound only when user stops dragging
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;

    // Ensure sidebar width is sane
    sidebarWidth = max(250, min(sidebarWidth, screenW * 0.5));
    double canvasLeft = sidebarOpen ? sidebarWidth : 0;

    String? hudTxt;
    List<Map<String, String>> steps = _getSteps();
    if (step < steps.length) hudTxt = steps[step]['hud'];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // --- CANVAS AREA ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: canvasLeft,
              top: 0,
              bottom: 0,
              right: 0,
              child: Stack(
                children: [
                  Listener(
                    onPointerDown: _handlePointerDown,
                    child: GestureDetector(
                      behavior: HitTestBehavior
                          .opaque, // Ensures flawless tap tracking
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _handlePointerUpdate,
                      onScaleEnd: _handlePointerUp,
                      child: Container(
                        key: _canvasKey,
                        color: const Color(0xFF0F172A),
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomPaint(
                          painter: LabPainter(
                            state: state,
                            scenario: scenario,
                            step: step,
                            zoom: zoom,
                            panX: panX,
                            panY: panY,
                            lang: lang,
                            t: t,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // HUD
                  if (hudTxt != null)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: const Border(
                              top: BorderSide(
                                color: Color(0xFF6366F1),
                                width: 3,
                              ),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info, color: Color(0xFF818CF8)),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  hudTxt,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // S4 / S5 UI Overlays
                  _buildOverlayControls(),
                ],
              ),
            ),

            // --- SIDEBAR ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // --- RIGHT BORDER LINE ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              width: 1,
              child: Container(color: Colors.white24),
            ),

            // --- RESIZER HANDLE ---
            if (sidebarOpen)
              Positioned(
                left: sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        sidebarWidth += details.delta.dx;
                        sidebarWidth = max(
                          250,
                          min(sidebarWidth, screenW * 0.5),
                        );
                      });
                    },
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // --- MENU BUTTON ---
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                onPressed: () {
                  setState(() => sidebarOpen = !sidebarOpen);
                  AudioEngine.pop();
                },
                child: Icon(
                  sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // --- CURTAIN SCREEN ---
            if (showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 80,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t('appTitle'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t('subtitle'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            AudioEngine.success();
                            setState(() => showCurtain = false);
                            _loadScenario(1);
                          },
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                          ),
                          label: Text(
                            t('enter'),
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
              ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class LabPainter extends CustomPainter {
  final SimState state;
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;
  final String lang;
  final String Function(String) t;

  LabPainter({
    required this.state,
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.lang,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderS1(canvas);
    } else if (scenario == 2) {
      _renderS2(canvas);
    } else if (scenario == 3) {
      _renderS3(canvas);
    } else if (scenario == 4) {
      _renderS4(canvas);
    } else if (scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill, [
    Color? stroke,
    double strokeW = 1,
  ]) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (stroke != null) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    TextAlign align = TextAlign.center,
    bool bold = true,
  }) {
    final style = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    double dx = x;
    if (align == TextAlign.center) {
      dx = x - tp.width / 2;
    } else if (align == TextAlign.right) {
      dx = x - tp.width;
    }

    tp.paint(canvas, Offset(dx, y - tp.height / 2));
  }

  // --- S1 ---
  void _renderS1(Canvas canvas) {
    final Color tCol = Colors.white;

    // Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = -1000; i < 1000; i += 50) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), gridPaint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), gridPaint);
    }

    double baseLine = 200;
    _drawLine(canvas, -600, baseLine, 600, baseLine, tCol, 4);

    double everestH = 300, elbrusH = 191, barW = 80;

    // Bar Graph
    _drawText(canvas, t('c_s1_barTitle'), -350, -150, 20, tCol);
    _drawRoundedRect(
      canvas,
      -450,
      baseLine - elbrusH,
      barW,
      elbrusH,
      0,
      const Color(0xFF3B82F6),
      const Color(0xFF1E3A8A),
      2,
    );
    _drawText(canvas, t('c_s1_elbrus'), -410, baseLine + 20, 16, tCol);

    _drawRoundedRect(
      canvas,
      -300,
      baseLine - everestH,
      barW,
      everestH,
      0,
      const Color(0xFF3B82F6),
      const Color(0xFF1E3A8A),
      2,
    );
    _drawText(canvas, t('c_s1_everest'), -260, baseLine + 20, 16, tCol);

    // Triangle Graph
    _drawText(canvas, t('c_s1_triTitle'), 300, -150, 20, tCol);

    final triPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    final triStroke = Paint()
      ..color = const Color(0xFF064E3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path p1 = Path()
      ..moveTo(200, baseLine)
      ..lineTo(200 + elbrusH / 2, baseLine - elbrusH)
      ..lineTo(200 + elbrusH, baseLine)
      ..close();
    canvas.drawPath(p1, triPaint);
    canvas.drawPath(p1, triStroke);
    _drawText(
      canvas,
      t('c_s1_elbrus'),
      200 + elbrusH / 2,
      baseLine + 20,
      16,
      tCol,
    );

    Path p2 = Path()
      ..moveTo(400, baseLine)
      ..lineTo(400 + everestH / 2, baseLine - everestH)
      ..lineTo(400 + everestH, baseLine)
      ..close();
    canvas.drawPath(p2, triPaint);
    canvas.drawPath(p2, triStroke);
    _drawText(
      canvas,
      t('c_s1_everest'),
      400 + everestH / 2,
      baseLine + 20,
      16,
      tCol,
    );

    // Targets Highlight
    if (step == 0) {
      canvas.drawRect(
        Rect.fromLTWH(-450, baseLine - elbrusH - 10, barW, 20),
        Paint()..color = Colors.yellow.withOpacity(0.3),
      );
      canvas.drawRect(
        Rect.fromLTWH(-300, baseLine - everestH - 10, barW, 20),
        Paint()..color = Colors.yellow.withOpacity(0.3),
      );
    }

    // Tape Measure
    final tape = state.s1.tape;
    tape.val ??= t('c_s1_tapeMeasureH');

    canvas.save();
    canvas.translate(tape.x, tape.y);
    double w = tape.horiz ? tape.h : tape.w;
    double h = tape.horiz ? tape.w : tape.h;
    double drawW = tape.horiz ? w : 60;
    double drawH = tape.horiz ? 60 : h;
    double cx = tape.horiz ? 0 : -30;
    double cy = tape.horiz ? -30 : 0;

    // Shadow & Body
    final RRect tRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx, cy, drawW, drawH),
      const Radius.circular(4),
    );
    canvas.drawShadow(Path()..addRRect(tRRect), Colors.black, 10, true);
    canvas.drawRRect(tRRect, Paint()..color = const Color(0xDAFACC15));
    canvas.drawRRect(
      tRRect,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final markPaint = Paint()
      ..color = const Color(0xFFB45309)
      ..strokeWidth = 1;
    if (!tape.horiz) {
      for (double i = 10; i < drawH; i += 10) {
        canvas.drawLine(
          Offset(cx, cy + i),
          Offset(cx + (i % 50 == 0 ? 20 : 10), cy + i),
          markPaint,
        );
      }
      canvas.save();
      canvas.translate(cx + 30, cy + drawH / 2);
      canvas.rotate(-pi / 2);
      _drawText(canvas, tape.val!, 0, 0, 16, Colors.white);
      canvas.restore();
    } else {
      for (double i = 10; i < drawW; i += 10) {
        canvas.drawLine(
          Offset(cx + i, cy + drawH),
          Offset(cx + i, cy + drawH - (i % 50 == 0 ? 20 : 10)),
          markPaint,
        );
      }
      _drawText(canvas, tape.val!, cx + drawW / 2, cy + 30, 16, Colors.white);
    }
    canvas.restore();

    // Rotate Button
    double btnX = tape.x + (tape.horiz ? tape.h / 2 : -60);
    double btnY = tape.y + (tape.horiz ? -60 : tape.h / 2);
    _drawRoundedRect(
      canvas,
      btnX - 20,
      btnY - 20,
      40,
      40,
      20,
      const Color(0xFFEF4444),
      const Color(0xFFB91C1C),
      2,
    );
    _drawText(canvas, "↻", btnX, btnY, 20, Colors.white);
  }

  // --- S2 ---
  void _renderS2(Canvas canvas) {
    final Color tCol = Colors.white;
    double baseLine = 250;
    double yStart = state.s2.yBase;

    _drawLine(canvas, -200, baseLine, 300, baseLine, tCol, 4);
    _drawLine(canvas, -200, -250, -200, baseLine, tCol, 4);

    double val2006 = 1400, val2022 = 3700, maxVal = 4000, pixelRange = 450;
    double scaleFactor = max(0, pixelRange / (maxVal - yStart));
    if (scaleFactor.isInfinite) scaleFactor = 0;

    double h2006 = max(0, (val2006 - yStart) * scaleFactor);
    double h2022 = max(0, (val2022 - yStart) * scaleFactor);

    _drawText(canvas, t('c_s2_title'), 50, -300, 24, tCol);

    _drawRoundedRect(
      canvas,
      -100,
      baseLine - h2006,
      100,
      h2006,
      0,
      const Color(0xFFF59E0B),
      const Color(0xFFB45309),
      2,
    );
    _drawText(canvas, "2006", -50, baseLine + 25, 18, tCol);
    _drawText(canvas, "1400", -50, baseLine - h2006 - 15, 16, tCol);

    _drawRoundedRect(
      canvas,
      100,
      baseLine - h2022,
      100,
      h2022,
      0,
      const Color(0xFFF59E0B),
      const Color(0xFFB45309),
      2,
    );
    _drawText(canvas, "2022", 150, baseLine + 25, 18, tCol);
    _drawText(canvas, "3700", 150, baseLine - h2022 - 15, 16, tCol);

    for (double i = yStart; i <= maxVal; i += 1000) {
      double y = baseLine - (i - yStart) * scaleFactor;
      if (y > -250 && y <= baseLine) {
        _drawLine(canvas, -205, y, -195, y, tCol, 2);
        _drawText(
          canvas,
          "${i.toInt()}",
          -215,
          y,
          14,
          tCol,
          align: TextAlign.right,
        );
      }
    }

    double sliderY = 350;
    _drawText(
      canvas,
      "${t('c_s2_yStart')}${yStart.toInt()}",
      0,
      sliderY - 25,
      16,
      tCol,
    );
    _drawLine(canvas, -150, sliderY, 150, sliderY, const Color(0xFF64748B), 6);
    double handleX = -150 + (yStart / 1000) * 300;
    _drawRoundedRect(
      canvas,
      handleX - 10,
      sliderY - 15,
      20,
      30,
      5,
      const Color(0xFF6366F1),
      const Color(0xFF4338CA),
      2,
    );
  }

  void _drawDogIcon(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(size / 100, size / 100);

    final Paint outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint cTan = Paint()
      ..color = const Color(0xFFDF9D53)
      ..style = PaintingStyle.fill;
    final Paint cCream = Paint()
      ..color = const Color(0xFFF3D9C9)
      ..style = PaintingStyle.fill;
    final Paint cRed = Paint()
      ..color = const Color(0xFFFF5D5D)
      ..style = PaintingStyle.fill;
    final Paint cBlue = Paint()
      ..color = const Color(0xFF00A3E7)
      ..style = PaintingStyle.fill;

    void drawP(Paint fill, Path p) {
      canvas.drawPath(p, fill);
      canvas.drawPath(p, outline);
    }

    // Tail
    drawP(
      cTan,
      Path()
        ..moveTo(80, 60)
        ..quadraticBezierTo(95, 40, 90, 30)
        ..quadraticBezierTo(100, 50, 85, 70),
    );
    // Back Legs & Paws
    drawP(
      cTan,
      Path()
        ..moveTo(35, 60)
        ..quadraticBezierTo(10, 60, 15, 90)
        ..lineTo(35, 90),
    );
    drawP(
      cTan,
      Path()
        ..moveTo(65, 60)
        ..quadraticBezierTo(90, 60, 85, 90)
        ..lineTo(65, 90),
    );
    drawP(
      cTan,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(25, 93), width: 20, height: 10),
      ),
    );
    drawP(
      cTan,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(75, 93), width: 20, height: 10),
      ),
    );
    // Body & Belly
    drawP(
      cTan,
      Path()
        ..moveTo(35, 50)
        ..lineTo(30, 90)
        ..lineTo(70, 90)
        ..lineTo(65, 50),
    );
    drawP(
      cCream,
      Path()
        ..moveTo(42, 60)
        ..quadraticBezierTo(50, 50, 58, 60)
        ..lineTo(58, 90)
        ..lineTo(42, 90),
    );
    // Front Legs & Paws
    drawP(
      cTan,
      Path()
        ..moveTo(32, 55)
        ..lineTo(32, 90)
        ..lineTo(44, 90)
        ..lineTo(44, 55),
    );
    drawP(
      cTan,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(38, 93), width: 20, height: 10),
      ),
    );
    drawP(
      cTan,
      Path()
        ..moveTo(56, 55)
        ..lineTo(56, 90)
        ..lineTo(68, 90)
        ..lineTo(68, 55),
    );
    drawP(
      cTan,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(62, 93), width: 20, height: 10),
      ),
    );
    // Collar
    drawP(
      cBlue,
      Path()
        ..moveTo(32, 45)
        ..quadraticBezierTo(50, 60, 68, 45)
        ..lineTo(64, 52)
        ..quadraticBezierTo(50, 68, 36, 52)
        ..close(),
    );
    // Head base
    drawP(
      cTan,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(50, 32), width: 52, height: 44),
      ),
    );
    // Ears
    drawP(
      cTan,
      Path()
        ..moveTo(30, 18)
        ..quadraticBezierTo(5, 15, 18, 45)
        ..quadraticBezierTo(25, 50, 30, 35),
    );
    drawP(
      cTan,
      Path()
        ..moveTo(70, 18)
        ..quadraticBezierTo(95, 15, 82, 45)
        ..quadraticBezierTo(75, 50, 70, 35),
    );
    // Face mask
    drawP(
      cCream,
      Path()
        ..moveTo(46, 12)
        ..quadraticBezierTo(50, 10, 54, 12)
        ..lineTo(62, 28)
        ..quadraticBezierTo(76, 28, 70, 42)
        ..quadraticBezierTo(66, 50, 50, 46)
        ..quadraticBezierTo(34, 50, 30, 42)
        ..quadraticBezierTo(24, 28, 38, 28)
        ..close(),
    );
    // Tongue
    drawP(
      cRed,
      Path()
        ..moveTo(45, 46)
        ..lineTo(45, 54)
        ..arcToPoint(
          const Offset(55, 54),
          radius: const Radius.circular(5),
          clockwise: false,
        )
        ..lineTo(55, 46),
    );
    // Nose
    drawP(
      Paint()
        ..color = const Color(0xFF623B1E)
        ..style = PaintingStyle.fill,
      Path()
        ..moveTo(46, 34)
        ..quadraticBezierTo(50, 32, 54, 34)
        ..quadraticBezierTo(56, 40, 50, 42)
        ..quadraticBezierTo(44, 40, 46, 34),
    );
    canvas.drawLine(const Offset(50, 42), const Offset(50, 46), outline);
    // Eyes
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(38, 25), width: 8, height: 8),
      pi * 1.1,
      pi,
      false,
      outline,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(62, 25), width: 8, height: 8),
      pi * 1.1,
      pi,
      false,
      outline,
    );
    canvas.restore();
  }

  // --- S3 ---
  void _renderS3(Canvas canvas) {
    final Color tCol = Colors.white;
    _drawText(canvas, t('c_s3_title'), 0, -250, 24, tCol);

    double lX = -400, rX = 100, yPos = -100;

    // Left Box
    _drawRoundedRect(
      canvas,
      lX,
      yPos,
      300,
      250,
      10,
      const Color(0xFF1E293B),
      tCol,
      2,
    );
    _drawText(canvas, t('c_s3_scale6'), lX + 150, yPos - 20, 16, tCol);
    _drawText(canvas, t('c_s3_villB'), lX + 150, yPos + 30, 18, tCol);
    for (int i = 0; i < 6; i++) {
      _drawDogIcon(
        canvas,
        lX + 15 + i * 45,
        yPos + 45,
        45,
        const Color(0xFF6366F1),
      );
    }
    _drawText(canvas, t('c_s3_villC'), lX + 150, yPos + 140, 18, tCol);
    for (int i = 0; i < 2; i++) {
      _drawDogIcon(
        canvas,
        lX + 15 + i * 45,
        yPos + 155,
        45,
        const Color(0xFF6366F1),
      );
    }

    // Right Box
    _drawRoundedRect(
      canvas,
      rX,
      yPos,
      300,
      250,
      10,
      const Color(0xFF1E293B),
      tCol,
      2,
    );
    _drawText(canvas, t('c_s3_scale10'), rX + 150, yPos - 20, 16, tCol);
    _drawText(canvas, t('c_s3_villB'), rX + 150, yPos + 30, 18, tCol);
    for (int i = 0; i < 3; i++) {
      _drawDogIcon(
        canvas,
        rX + 15 + i * 45,
        yPos + 45,
        45,
        const Color(0xFF6366F1),
      );
    }

    // Sliced dog (0.6)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(rX + 15 + 3 * 45, yPos + 45, 45 * 0.6, 45));
    _drawDogIcon(
      canvas,
      rX + 15 + 3 * 45,
      yPos + 45,
      45,
      const Color(0xFF6366F1),
    );
    canvas.restore();

    _drawText(canvas, t('c_s3_villC'), rX + 150, yPos + 140, 18, tCol);
    _drawDogIcon(canvas, rX + 15, yPos + 155, 45, const Color(0xFF6366F1));

    // Sliced dog (0.2)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(rX + 15 + 45, yPos + 155, 45 * 0.2, 45));
    _drawDogIcon(canvas, rX + 15 + 45, yPos + 155, 45, const Color(0xFF6366F1));
    canvas.restore();

    // Toolbox
    double tbY = 250;
    _drawText(canvas, t('c_s3_toolbox'), 0, tbY - 30, 16, tCol);
    _drawRoundedRect(
      canvas,
      -50,
      tbY,
      100,
      100,
      10,
      const Color(0xFF3B82F6),
      const Color(0xFF1E3A8A),
      4,
    );
    _drawText(canvas, t('c_s3_drag'), 0, tbY + 50, 18, Colors.white);

    if (state.activeDrag == 's3_block') {
      _drawRoundedRect(
        canvas,
        state.dragX - 25,
        state.dragY - 25,
        50,
        50,
        5,
        const Color(0xFF60A5FA),
        const Color(0xFF1E3A8A),
        3,
      );
    }

    if (state.s3.blocksPlacedL > 0) {
      for (int k = 0; k < 6; k++) {
        _drawRoundedRect(
          canvas,
          lX + 20 + k * 45 - 5,
          yPos + 55,
          50,
          50,
          4,
          const Color(0x6622C55E),
          const Color(0xFF166534),
          2,
        );
        _drawText(
          canvas,
          "6",
          lX + 20 + k * 45 + 20,
          yPos + 80,
          18,
          Colors.white,
        );
      }
    }
    if (state.s3.blockRejectsR > 0) {
      _drawText(canvas, "???", rX + 150, yPos + 80, 40, Colors.white);
    }
  }

  void _drawCar(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color color,
  ) {
    canvas.save();
    canvas.translate(x, y);
    _drawRoundedRect(
      canvas,
      0,
      h * 0.4,
      w,
      h * 0.6,
      5,
      color,
      const Color(0xFF0F172A),
      2,
    );
    _drawRoundedRect(
      canvas,
      w * 0.2,
      0,
      w * 0.6,
      h * 0.5,
      5,
      color,
      const Color(0xFF0F172A),
      2,
    );
    _drawRoundedRect(
      canvas,
      w * 0.25,
      h * 0.1,
      w * 0.2,
      h * 0.3,
      2,
      const Color(0xFFBAE6FD),
    );
    _drawRoundedRect(
      canvas,
      w * 0.55,
      h * 0.1,
      w * 0.2,
      h * 0.3,
      2,
      const Color(0xFFBAE6FD),
    );

    final wPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(w * 0.25, h), w * 0.15, wPaint);
    canvas.drawCircle(Offset(w * 0.75, h), w * 0.15, wPaint);
    canvas.restore();
  }

  // --- S4 ---
  void _renderS4(Canvas canvas) {
    final Color tCol = Colors.white;
    _drawText(canvas, t('c_s4_title'), 0, -300, 24, tCol);

    double baseLine = 150;
    _drawLine(canvas, -200, baseLine, 200, baseLine, tCol, 4);
    _drawLine(canvas, -200, -150, -200, baseLine, tCol, 4);

    double val6am = 20, val7am = 100, scaleFactor = 2.5;
    double h6am = max(0, (val6am - state.s4.yBase) * scaleFactor);
    double h7am = max(0, (val7am - state.s4.yBase) * scaleFactor);

    if (state.s4.shape == 'bar') {
      _drawRoundedRect(
        canvas,
        -100,
        baseLine - h6am,
        50,
        h6am,
        0,
        state.s4.color,
        Colors.black,
        2,
      );
      _drawRoundedRect(
        canvas,
        50,
        baseLine - h7am,
        50,
        h7am,
        0,
        state.s4.color,
        Colors.black,
        2,
      );
    } else {
      _drawCar(canvas, -125, baseLine - h6am, h6am, h6am, state.s4.color);
      _drawCar(canvas, 0, baseLine - h7am, h7am, h7am, state.s4.color);
    }

    _drawText(canvas, t('c_s4_6am'), -75, baseLine + 25, 16, tCol);
    _drawText(canvas, t('c_s4_7am'), 75, baseLine + 25, 16, tCol);
  }

  // --- S5 ---
  void _renderS5(Canvas canvas) {
    final Color tCol = Colors.white;
    _drawText(canvas, t('c_s5_title'), 0, -300, 24, tCol);

    List<Map<String, dynamic>> data = [
      {'n': t('c_s5_nile'), 'v': 6650.0},
      {'n': t('c_s5_amazon'), 'v': 6400.0},
      {'n': t('c_s5_yangtze'), 'v': 6300.0},
    ];

    double baseLine = 150;
    double startX = -250, startY = -150;

    if (state.s5.orientation == 'vertical') {
      _drawLine(canvas, startX, baseLine, 300, baseLine, tCol, 4);
      _drawLine(canvas, startX, -200, startX, baseLine, tCol, 4);

      for (int i = 0; i < data.length; i++) {
        double h = data[i]['v'] / state.s5.scale * 10;
        _drawRoundedRect(
          canvas,
          startX + 50 + i * 80,
          baseLine - h,
          50,
          h,
          0,
          const Color(0xFF0EA5E9),
          const Color(0xFF0284C7),
          2,
        );
        _drawText(
          canvas,
          data[i]['n'],
          startX + 75 + i * 80,
          baseLine + 25,
          16,
          tCol,
        );
      }
    } else {
      _drawLine(canvas, startX, baseLine, startX, -250, tCol, 4); // Y
      _drawLine(canvas, startX, baseLine, 350, baseLine, tCol, 4); // X

      for (int i = 0; i < data.length; i++) {
        double w = data[i]['v'] / state.s5.scale * 10;
        _drawRoundedRect(
          canvas,
          startX,
          startY + i * 80,
          w,
          50,
          0,
          const Color(0xFF0EA5E9),
          const Color(0xFF0284C7),
          2,
        );
        _drawText(
          canvas,
          data[i]['n'],
          startX - 40,
          startY + 25 + i * 80,
          16,
          tCol,
          align: TextAlign.right,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
