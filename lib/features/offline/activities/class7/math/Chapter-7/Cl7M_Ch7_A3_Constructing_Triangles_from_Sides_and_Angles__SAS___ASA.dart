// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TriangleBlueprintApp());
}

/// Translations Data
class Translations {
  static const Map<String, Map<String, dynamic>> data = {
    'en': {
      'appTitle': 'The Triangle Blueprint: Constructing with Sides and Angles',
      'appSubtitle': 'Class 7 • A TALE OF THREE INTERSECTING LINES',
      'enterLab': 'Enter Lab',
      'selectScenario': 'Select Scenario',
      'objectiveLbl': 'Objective:',
      'blueprintSpecs': 'Blueprint Specifications',
      'baseText': 'Base:',
      'side2Text': 'Side 2:',
      'angLText': '∠ 1:',
      'angRText': '∠ 2:',
      'connectBtn': 'Connect',
      'doneTaskBtn': "I'm Done",
      'checkBtn': 'Check My Work',
      'nextScenario': 'Next Challenge',
      'successTitle': 'Geometry Master!',
      'successDesc':
          'You successfully constructed the triangle using blueprint rules!',
      'restartLab': 'Restart Lab',
      'stepLabel': 'OBSERVATION',
      'completed': 'Completed!',
      'hud_complete':
          'Task: Construction looks complete! CLICK Check My Work to validate.',
      'hud_error':
          'Measurements don\'t match the blueprint! Red lines indicate your errors. Try again.',
      'validation_error': 'Measurements don\'t match blueprint! Try again.',
      's1_title': '1. The SAS Blueprint (Solved Challenge)',
      's1_obj':
          'To construct a unique triangle given two side lengths (6 cm and 4 cm) and the included angle (50°).',
      's1_hud_1':
          'Task: A ruler is on the screen. CLICK the ruler to activate the line tool. DRAG your cursor on the canvas to draw the first side of the triangle with a length of 6 cm.',
      's1_text_1':
          'Task: A ruler is on the screen. CLICK the ruler to activate the line tool. DRAG your cursor on the canvas to draw the first side of the triangle with a length of 6 cm.\n\nObserved: A straight line segment, labeled \'6 cm\', is drawn on the virtual canvas.',
      's1_hud_2':
          'Task: DRAG the protractor from the toolbox and DROP it onto the left endpoint of the 6 cm line.',
      's1_text_2':
          'Task: DRAG the protractor from the toolbox and DROP it onto the left endpoint of the 6 cm line.\n\nObserved: The protractor\'s center point is perfectly aligned with the left vertex.',
      's1_hud_3':
          'Task: A handle appears on the protractor. CLICK and DRAG the handle to rotate a new line until the angle indicator reads 50°.',
      's1_text_3':
          'Task: A handle appears on the protractor. CLICK and DRAG the handle to rotate a new line until the angle indicator reads 50°.\n\nObserved: A new ray is drawn from the vertex at a perfect 50° angle.',
      's1_hud_4':
          'Task: CLICK the ruler again. DRAG along the new 50° ray, starting from the vertex, to measure and draw the second side with a length of 4 cm.',
      's1_text_4':
          'Task: CLICK the ruler again. DRAG along the new 50° ray, starting from the vertex, to measure and draw the second side with a length of 4 cm.\n\nObserved: The ray is replaced by a solid 4 cm line segment.',
      's1_hud_5':
          'Task: The two endpoints are now fixed. CLICK the glowing "Connect" button to draw the final side and complete the triangle.',
      's1_text_5':
          'Task: The two endpoints are now fixed. CLICK the glowing "Connect" button to draw the final side and complete the triangle.\n\nObserved: The third side is drawn, connecting the two open endpoints. The triangle is now a closed shape.',
      's1_sum':
          'It\'s a complete triangle! The initial three measurements (SAS) uniquely determined the entire shape.',

      's2_title': '2. The ASA Blueprint (Solved Challenge)',
      's2_obj':
          'To construct a unique triangle given two angles (40° and 70°) and the included side (8 cm).',
      's2_hud_1':
          'Task: CLICK the ruler. DRAG on the canvas to draw the included side with a length of 8 cm.',
      's2_text_1':
          'Task: CLICK the ruler. DRAG on the canvas to draw the included side with a length of 8 cm.\n\nObserved: An 8 cm base line is established.',
      's2_hud_2':
          'Task: DRAG the protractor and DROP it on the left endpoint of the 8 cm line. CLICK and DRAG the handle to create a 40° angle.',
      's2_text_2':
          'Task: DRAG the protractor and DROP it on the left endpoint of the 8 cm line. CLICK and DRAG the handle to create a 40° angle.\n\nObserved: A long ray is drawn from the left vertex at a 40° angle.',
      's2_hud_3':
          'Task: Now, DRAG the protractor and DROP it on the right endpoint of the 8 cm line. CLICK and DRAG the handle to create a 70° angle.',
      's2_text_3':
          'Task: Now, DRAG the protractor and DROP it on the right endpoint of the 8 cm line. CLICK and DRAG the handle to create a 70° angle.\n\nObserved: A second long ray is drawn from the right vertex, intersecting the first.',
      's2_hud_4':
          'Task: The intersection of the two rays forms the third vertex. CLICK the glowing intersection point to finalize the shape.',
      's2_text_4':
          'Task: The intersection of the two rays forms the third vertex. CLICK the glowing intersection point to finalize the shape.\n\nObserved: The triangle is formed, showing ASA creates a unique shape.',
      's2_sum':
          'The intersection defined the final vertex perfectly based on the ASA rules.',

      's3_title': '3. The Obtuse SAS Blueprint (Solved Challenge)',
      's3_obj':
          'To demonstrate that the SAS principle works for any angle by constructing a triangle with sides 5 cm, 3 cm, and an included angle of 120°.',
      's3_hud_1':
          'Task: Use the ruler to DRAW the base side with a length of 5 cm.',
      's3_text_1':
          'Task: Use the ruler to DRAW the base side with a length of 5 cm.\n\nObserved: A 5 cm line segment is on the canvas.',
      's3_hud_2': 'Task: DRAG the protractor to the left endpoint.',
      's3_text_2':
          'Task: DRAG the protractor to the left endpoint.\n\nObserved: Protractor placed.',
      's3_hud_3': 'Task: DRAG the handle to create a wide 120° angle.',
      's3_text_3':
          'Task: DRAG the handle to create a wide 120° angle.\n\nObserved: A ray is drawn at a 120° angle, showing an obtuse angle.',
      's3_hud_4':
          'Task: Use the ruler to MEASURE and DRAW the second side of 3 cm along the 120° ray.',
      's3_text_4':
          'Task: Use the ruler to MEASURE and DRAW the second side of 3 cm along the 120° ray.\n\nObserved: Side drawn correctly.',
      's3_hud_5':
          'Task: CLICK the "Connect" button to complete the wide-angled triangle.',
      's3_text_5':
          'Task: CLICK the "Connect" button to complete the wide-angled triangle.\n\nObserved: The final side is drawn, forming an obtuse triangle.',
      's3_sum': 'Even with an obtuse angle, SAS provides a perfect blueprint.',

      's4_title': '4. The Surveyor\'s Challenge (Unsolved)',
      's4_obj':
          'You are a surveyor. Use your tools to map a plot of land defined by these measurements: Angle = 30°, Included Side = 9 cm, Angle = 80°.',
      's4_hud_1':
          'Task: A blueprint panel shows the required measurements. Use the tools to construct the triangle on the canvas.',
      's4_text_1':
          'Task: A blueprint panel shows the required measurements. Use the tools to construct the triangle on the canvas.\n\nThe system waits for the user to form a closed triangle.',
      's4_sum':
          'Excellent surveying! The triangle matches the ASA blueprint perfectly.',

      's5_title': '5. The Architect\'s Challenge (Unsolved)',
      's5_obj':
          'You are an architect designing a support beam. Construct the triangular beam using these specifications: Side = 7 cm, Included Angle = 90°, Side = 7 cm.',
      's5_hud_1':
          'Task: The blueprint panel shows the required measurements. Use the ruler and protractor to build the specified right-angled isosceles triangle.',
      's5_text_1':
          'Task: The blueprint panel shows the required measurements. Use the ruler and protractor to build the specified right-angled isosceles triangle.',
      's5_sum':
          'Perfect architecture! The support beam matches the SAS specifications.',
    },
    'hi': {
      'appTitle': 'त्रिभुज ब्लूप्रिंट: भुजाओं और कोणों के साथ निर्माण',
      'appSubtitle': 'कक्षा 7 • तीन प्रतिच्छेदी रेखाओं की कहानी',
      'enterLab': 'लैब में प्रवेश करें',
      'selectScenario': 'दृश्य चुनें',
      'objectiveLbl': 'उद्देश्य:',
      'blueprintSpecs': 'ब्लूप्रिंट विनिर्देश',
      'baseText': 'आधार:',
      'side2Text': 'भुजा 2:',
      'angLText': '∠ 1:',
      'angRText': '∠ 2:',
      'connectBtn': 'जोड़ें',
      'doneTaskBtn': 'मैं कर चुका हूँ',
      'checkBtn': 'मेरा काम जांचें',
      'nextScenario': 'अगली चुनौती',
      'successTitle': 'ज्यामिति के उस्ताद!',
      'successDesc':
          'आपने ब्लूप्रिंट नियमों का उपयोग करके सफलतापूर्वक त्रिभुज का निर्माण किया!',
      'restartLab': 'लैब फिर से शुरू करें',
      'stepLabel': 'अवलोकन',
      'completed': 'पूरा हुआ!',
      'hud_complete':
          'कार्य: निर्माण पूरा लग रहा है! सत्यापित करने के लिए Check My Work पर क्लिक करें।',
      'hud_error':
          'माप ब्लूप्रिंट से मेल नहीं खाते! लाल रेखाएं आपकी त्रुटियों को दर्शाती हैं। पुनः प्रयास करें।',
      'validation_error': 'माप ब्लूप्रिंट से मेल नहीं खाते! पुनः प्रयास करें।',
      's1_title': '1. SAS ब्लूप्रिंट (हल की गई चुनौती)',
      's1_obj':
          'दो भुजाओं की लंबाई (6 सेमी और 4 सेमी) और शामिल कोण (50°) दिए जाने पर एक अद्वितीय त्रिभुज का निर्माण करना।',
      's1_hud_1':
          'कार्य: स्क्रीन पर एक पैमाना है। लाइन टूल को सक्रिय करने के लिए पैमाने पर क्लिक करें। 6 सेमी की लंबाई वाले त्रिभुज की पहली भुजा बनाने के लिए कैनवास पर अपना कर्सर खींचें।',
      's1_text_1':
          'कार्य: स्क्रीन पर एक पैमाना है। लाइन टूल को सक्रिय करने के लिए पैमाने पर क्लिक करें। 6 सेमी की लंबाई वाले त्रिभुज की पहली भुजा बनाने के लिए कैनवास पर अपना कर्सर खींचें।\n\nदेखा गया: \'6 सेमी\' लेबल वाला एक सीधा रेखाखंड आभासी कैनवास पर खींचा गया है।',
      's1_hud_2':
          'कार्य: टूलबॉक्स से चांदा खींचें और इसे 6 सेमी लाइन के बाएँ अंतिम बिंदु पर छोड़ दें।',
      's1_text_2':
          'कार्य: टूलबॉक्स से चांदा खींचें और इसे 6 सेमी लाइन के बाएँ अंतिम बिंदु पर छोड़ दें।\n\nदेखा गया: चांदा का केंद्र बिंदु पूरी तरह से बाएँ शीर्ष के साथ संरेखित है।',
      's1_hud_3':
          'कार्य: चांदे पर एक हैंडल दिखाई देता है। जब तक कोण संकेतक 50° न पढ़ ले, तब तक एक नई लाइन को घुमाने के लिए हैंडल को क्लिक करें और खींचें।',
      's1_text_3':
          'कार्य: चांदे पर एक हैंडल दिखाई देता है। जब तक कोण संकेतक 50° न पढ़ ले, तब तक एक नई लाइन को घुमाने के लिए हैंडल को क्लिक करें और खींचें।\n\nदेखा गया: एक आदर्श 50° कोण पर शीर्ष से एक नई किरण खींची जाती है।',
      's1_hud_4':
          'कार्य: पैमाने पर फिर से क्लिक करें। 4 सेमी की लंबाई वाली दूसरी भुजा को मापने और खींचने के लिए, शीर्ष से शुरू करते हुए, नई 50° किरण के साथ खींचें।',
      's1_text_4':
          'कार्य: पैमाने पर फिर से क्लिक करें। 4 सेमी की लंबाई वाली दूसरी भुजा को मापने और खींचने के लिए, शीर्ष से शुरू करते हुए, नई 50° किरण के साथ खींचें।\n\nदेखा गया: किरण को एक ठोस 4 सेमी रेखाखंड से बदल दिया जाता है।',
      's1_hud_5':
          'कार्य: दोनों अंतिम बिंदु अब तय हो गए हैं। अंतिम भुजा खींचने और त्रिभुज को पूरा करने के लिए चमकते "Connect" बटन पर क्लिक करें।',
      's1_text_5':
          'कार्य: दोनों अंतिम बिंदु अब तय हो गए हैं। अंतिम भुजा खींचने और त्रिभुज को पूरा करने के लिए चमकते "Connect" बटन पर क्लिक करें।\n\nदेखा गया: तीसरी भुजा खींची जाती है, जिससे दोनों खुले सिरे जुड़ जाते हैं। त्रिभुज अब एक बंद आकार है।',
      's1_sum':
          'यह एक पूर्ण त्रिभुज है! प्रारंभिक तीन मापों (SAS) ने पूरी आकृति को विशिष्ट रूप से निर्धारित किया।',

      's2_title': '2. ASA ब्लूप्रिंट (हल की गई चुनौती)',
      's2_obj':
          'दो कोण (40° और 70°) और शामिल भुजा (8 सेमी) दिए जाने पर एक अद्वितीय त्रिभुज का निर्माण करना।',
      's2_hud_1':
          'कार्य: पैमाने पर क्लिक करें। 8 सेमी की लंबाई के साथ शामिल भुजा को खींचने के लिए कैनवास पर खींचें।',
      's2_text_1':
          'कार्य: पैमाने पर क्लिक करें। 8 सेमी की लंबाई के साथ शामिल भुजा को खींचने के लिए कैनवास पर खींचें।\n\nदेखा गया: 8 सेमी आधार रेखा स्थापित हो गई है।',
      's2_hud_2':
          'कार्य: 8 सेमी लाइन के बाएँ अंतिम बिंदु पर चांदा खींचें और छोड़ें। 40° का कोण बनाने के लिए हैंडल को क्लिक करें और खींचें।',
      's2_text_2':
          'कार्य: 8 सेमी लाइन के बाएँ अंतिम बिंदु पर चांदा खींचें और छोड़ें। 40° का कोण बनाने के लिए हैंडल को क्लिक करें और खींचें।\n\nदेखा गया: बाएँ शीर्ष से 40° के कोण पर एक लंबी किरण खींची जाती है।',
      's2_hud_3':
          'कार्य: अब, 8 सेमी लाइन के दाएँ अंतिम बिंदु पर चांदा खींचें और छोड़ें। 70° का कोण बनाने के लिए हैंडल को क्लिक करें और खींचें।',
      's2_text_3':
          'कार्य: अब, 8 सेमी लाइन के दाएँ अंतिम बिंदु पर चांदा खींचें और छोड़ें। 70° का कोण बनाने के लिए हैंडल को क्लिक करें और खींचें।\n\nदेखा गया: दाएँ शीर्ष से दूसरी लंबी किरण खींची जाती है, जो पहली को काटती है।',
      's2_hud_4':
          'कार्य: दोनों किरणों का प्रतिच्छेदन तीसरे शीर्ष का निर्माण करता है। आकृति को अंतिम रूप देने के लिए चमकते प्रतिच्छेदन बिंदु पर क्लिक करें।',
      's2_text_4':
          'कार्य: दोनों किरणों का प्रतिच्छेदन तीसरे शीर्ष का निर्माण करता है। आकृति को अंतिम रूप देने के लिए चमकते प्रतिच्छेदन बिंदु पर क्लिक करें।\n\nदेखा गया: त्रिभुज बन जाता है, यह दर्शाता है कि ASA एक अद्वितीय आकृति बनाता है।',
      's2_sum':
          'प्रतिच्छेदन ने ASA नियमों के आधार पर अंतिम शीर्ष को पूरी तरह से परिभाषित किया।',

      's3_title': '3. अधिककोण SAS ब्लूप्रिंट (हल की गई चुनौती)',
      's3_obj':
          'यह प्रदर्शित करने के लिए कि SAS सिद्धांत किसी भी कोण के लिए 5 सेमी, 3 सेमी भुजाओं और 120° के शामिल कोण वाले त्रिभुज का निर्माण करके काम करता है।',
      's3_hud_1':
          'कार्य: 5 सेमी लंबाई के साथ आधार भुजा खींचने के लिए पैमाने का उपयोग करें।',
      's3_text_1':
          'कार्य: 5 सेमी लंबाई के साथ आधार भुजा खींचने के लिए पैमाने का उपयोग करें।\n\nदेखा गया: कैनवास पर 5 सेमी का रेखाखंड है।',
      's3_hud_2': 'कार्य: चांदे को बाएँ अंतिम बिंदु पर खींचें।',
      's3_text_2':
          'कार्य: चांदे को बाएँ अंतिम बिंदु पर खींचें।\n\nदेखा गया: चांदा रखा गया।',
      's3_hud_3': 'कार्य: एक विस्तृत 120° कोण बनाने के लिए हैंडल को खींचें।',
      's3_text_3':
          'कार्य: एक विस्तृत 120° कोण बनाने के लिए हैंडल को खींचें।\n\nदेखा गया: 120° कोण पर एक किरण खींची जाती है, जो एक अधिककोण को दर्शाती है।',
      's3_hud_4':
          'कार्य: 120° किरण के साथ 3 सेमी की दूसरी भुजा को मापने और खींचने के लिए पैमाने का उपयोग करें।',
      's3_text_4':
          'कार्य: 120° किरण के साथ 3 सेमी की दूसरी भुजा को मापने और खींचने के लिए पैमाने का उपयोग करें।\n\nदेखा गया: भुजा सही ढंग से खींची गई।',
      's3_hud_5':
          'कार्य: चौड़े कोण वाले त्रिभुज को पूरा करने के लिए "Connect" बटन पर क्लिक करें।',
      's3_text_5':
          'कार्य: चौड़े कोण वाले त्रिभुज को पूरा करने के लिए "Connect" बटन पर क्लिक करें।\n\nदेखा गया: अंतिम भुजा खींची जाती है, जिससे एक अधिककोण त्रिभुज बनता है।',
      's3_sum': 'अधिककोण के साथ भी, SAS एक सटीक ब्लूप्रिंट प्रदान करता है।',

      's4_title': '4. सर्वेक्षक की चुनौती (अनसुलझी)',
      's4_obj':
          'आप एक सर्वेक्षक हैं। इन मापों द्वारा परिभाषित भूमि के एक भूखंड को मैप करने के लिए अपने उपकरणों का उपयोग करें: कोण = 30°, शामिल भुजा = 9 सेमी, कोण = 80°।',
      's4_hud_1':
          'कार्य: एक ब्लूप्रिंट पैनल आवश्यक माप दिखाता है। कैनवास पर त्रिभुज बनाने के लिए उपकरणों का उपयोग करें।',
      's4_text_1':
          'कार्य: एक ब्लूप्रिंट पैनल आवश्यक माप दिखाता है। कैनवास पर त्रिभुज बनाने के लिए उपकरणों का उपयोग करें।\n\nसिस्टम उपयोगकर्ता द्वारा एक बंद त्रिभुज बनाने की प्रतीक्षा करता है।',
      's4_sum':
          'उत्कृष्ट सर्वेक्षण! त्रिभुज पूरी तरह से ASA ब्लूप्रिंट से मेल खाता है।',

      's5_title': '5. वास्तुकार की चुनौती (अनसुलझी)',
      's5_obj':
          'आप एक वास्तुकार हैं। इन विनिर्देशों का उपयोग करके त्रिकोणीय बीम का निर्माण करें: भुजा = 7 सेमी, शामिल कोण = 90°, भुजा = 7 सेमी।',
      's5_hud_1':
          'कार्य: ब्लूप्रिंट पैनल आवश्यक माप दिखाता है। निर्दिष्ट समकोण समद्विबाहु त्रिभुज बनाने के लिए पैमाने और चांदे का उपयोग करें।',
      's5_text_1':
          'कार्य: ब्लूप्रिंट पैनल आवश्यक माप दिखाता है। निर्दिष्ट समकोण समद्विबाहु त्रिभुज बनाने के लिए पैमाने और चांदे का उपयोग करें।',
      's5_sum':
          'बिल्कुल सही वास्तुकला! समर्थन बीम SAS विनिर्देशों से मेल खाता है।',
    },
  };
}

class TriangleBlueprintApp extends StatelessWidget {
  const TriangleBlueprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const TriangleBlueprintScreen(),
    );
  }
}

class TriangleBlueprintScreen extends StatefulWidget {
  const TriangleBlueprintScreen({super.key});

  @override
  State<TriangleBlueprintScreen> createState() =>
      _TriangleBlueprintScreenState();
}

class _TriangleBlueprintScreenState extends State<TriangleBlueprintScreen>
    with TickerProviderStateMixin {
  // Config
  static const double CM_TO_PX = 30.0;
  static const double BASE_Y = 100.0;
  static const double START_X = -120.0;

  // Custom Color Palette
  static const Color cZslDark = Color(0xFF020617);
  static const Color cZslPanel = Color(0xD91E293B);
  static const Color cEmerald = Color(0xFF10B981);
  static const Color cIndigo = Color(0xFF6366F1);
  static const Color cAmber = Color(0xFFF59E0B);
  static const Color cRose = Color(0xFFF43F5E);
  static const Color cCyan = Color(0xFF38BDF8);

  // Audio Players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _sndPop =
      'audio/class7/mixkit_2568.mp3';
  final String _sndSuccess =
      'audio/class7/mixkit_2000.mp3';
  final String _sndError =
      'audio/class7/mixkit_2570.mp3';
  final String _sndSnap =
      'audio/class7/mixkit_2568.mp3';

  // Animation for pulsing
  late AnimationController _pulseController;

  // State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;

  // Viewport / Tool State
  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _pan = Offset.zero;
  String _activeTool = '';

  // Scenario Data
  int _scenario = 1;
  final Map<int, Map<String, dynamic>> _scenarios = {
    1: {
      'base': 6.0,
      'angL': -50.0,
      'side2': 4.0,
      'type': 'SAS',
      'unsolved': false,
      'steps': 5,
    },
    2: {
      'base': 8.0,
      'angL': -40.0,
      'angR': -110.0,
      'type': 'ASA',
      'angL_val': 40,
      'angR_val': 70,
      'unsolved': false,
      'steps': 4,
    },
    3: {
      'base': 5.0,
      'angL': -120.0,
      'side2': 3.0,
      'type': 'SAS',
      'unsolved': false,
      'steps': 5,
    },
    4: {
      'base': 9.0,
      'angL': -30.0,
      'angR': -100.0,
      'type': 'ASA',
      'angL_val': 30,
      'angR_val': 80,
      'unsolved': true,
      'steps': 1,
    },
    5: {
      'base': 7.0,
      'angL': -90.0,
      'side2': 7.0,
      'type': 'SAS',
      'unsolved': true,
      'steps': 1,
    },
  };

  // Construction State
  String _phase = 'draw_base';
  double? _baseLen;
  double? _tempBase;
  double? _rayL;
  double? _tempAngleL;
  double? _rayR;
  double? _tempAngleR;
  double? _side2Len;
  double? _tempSide2;
  Offset? _protractorPos;
  String? _protractorSide;

  // Validation State
  bool _allCorrect = false;

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
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pulseController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  String t(String key) {
    return Translations.data[_lang]?[key] ?? key;
  }

  void _toggleLang() {
    _playSound(_sndPop);
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
  }

  void _resetLab() {
    _playSound(_sndPop);
    setState(() {
      _showCurtain = true;
      _scenario = 1;
      _isSidebarOpen = true;
      _lang = 'en'; // Strict language reset
      _resetConstructionState();
    });
  }

  void _loadScenario(int id) {
    _playSound(_sndPop);
    setState(() {
      _scenario = id;
      _resetConstructionState();
    });
  }

  void _resetConstructionState() {
    _phase = 'draw_base';
    _activeTool = '';
    _baseLen = null;
    _tempBase = null;
    _rayL = null;
    _tempAngleL = null;
    _rayR = null;
    _tempAngleR = null;
    _side2Len = null;
    _tempSide2 = null;
    _protractorPos = null;
    _protractorSide = null;
    _allCorrect = false;
    _showSuccessPopup = false;
    _scale = 1.0;
    _baseScale = 1.0;
    _pan = Offset.zero;
  }

  void _selectTool(String tool) {
    if (_phase == 'complete' || _phase == 'analyzed') return;
    _playSound(_sndPop);
    setState(() {
      _activeTool = _activeTool == tool ? '' : tool;
    });
  }

  int get pseudoStep {
    if (_phase == 'draw_base') return 0;
    if (_phase == 'place_protractor_l' || _phase == 'set_angle_l') return 1;
    if (_phase == 'draw_side2' ||
        _phase == 'place_protractor_r' ||
        _phase == 'set_angle_r') {
      return 2;
    }
    if (_phase == 'connect' || _phase == 'intersect') return 3;
    if (_phase == 'complete' || _phase == 'analyzed') return 4;
    return 0;
  }

  int get currentStepIndex {
    var cfg = _scenarios[_scenario]!;
    if (cfg['unsolved']) {
      return (_phase == 'analyzed' && _allCorrect) ? 1 : 0;
    }
    int pStep = pseudoStep;
    if (cfg['type'] == 'SAS') {
      if (pStep == 1 && _phase == 'set_angle_l') pStep = 2;
      if (_phase == 'draw_side2') pStep = 3;
      if (_phase == 'connect') pStep = 4;
      if (_phase == 'complete' || _phase == 'analyzed') pStep = 5;
    }
    return pStep;
  }

  // --- Scale & Drag Interaction Logic ---
  Offset _screenToWorld(Offset screenPoint, Size canvasSize) {
    double cx = canvasSize.width / 2;
    double cy = canvasSize.height / 2;
    double worldX = (screenPoint.dx - cx - _pan.dx) / _scale;
    double worldY = (screenPoint.dy - cy - _pan.dy) / _scale;
    return Offset(worldX, worldY);
  }

  void _handleScaleStart(ScaleStartDetails details, Size canvasSize) {
    _baseScale = _scale;

    // Disable tool interactions if zooming with 2 fingers or panning with no tool
    bool isStartInteractive =
        _phase == 'set_angle_l' ||
        _phase == 'set_angle_r' ||
        _phase == 'intersect';
    if (details.pointerCount > 1 ||
        (_activeTool == '' && !isStartInteractive)) {
      return;
    }

    Offset worldPt = _screenToWorld(details.localFocalPoint, canvasSize);

    if (_phase == 'place_protractor_l' && _activeTool == 'protractor') {
      if ((worldPt.dx - START_X).abs() < 100 &&
          (worldPt.dy - BASE_Y).abs() < 60) {
        setState(() {
          _protractorPos = const Offset(START_X, BASE_Y);
          _protractorSide = 'left';
          _phase = 'set_angle_l';
          _activeTool = '';
        });
        _playSound(_sndSnap);
      }
    } else if (_phase == 'place_protractor_r' && _activeTool == 'protractor') {
      if ((worldPt.dx - (START_X + _baseLen! * CM_TO_PX)).abs() < 100 &&
          (worldPt.dy - BASE_Y).abs() < 60) {
        setState(() {
          _protractorPos = Offset(START_X + _baseLen! * CM_TO_PX, BASE_Y);
          _protractorSide = 'right';
          _phase = 'set_angle_r';
          _activeTool = '';
        });
        _playSound(_sndSnap);
      }
    } else if (_phase == 'intersect') {
      Offset c = _calculateIntersection();
      if ((worldPt - c).distance < 50) {
        setState(() {
          _phase = 'complete';
        });
        _playSound(_sndSuccess);
        _autoProceedIfNeeded();
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    // If no tool is selected AND not setting an angle OR using 2 fingers -> Pan & Zoom the canvas
    bool isUpdateInteractive =
        _phase == 'set_angle_l' || _phase == 'set_angle_r';
    if (details.pointerCount > 1 ||
        (_activeTool == '' && !isUpdateInteractive)) {
      setState(() {
        _pan += details.focalPointDelta;
        if (details.scale != 1.0) {
          _scale = (_baseScale * details.scale).clamp(0.2, 4.0);
        }
      });
      return;
    }

    // Active tool drawing interactions
    Offset worldPt = _screenToWorld(details.localFocalPoint, canvasSize);
    var cfg = _scenarios[_scenario]!;
    bool isUnsolved = cfg['unsolved'];

    setState(() {
      if (_phase == 'draw_base' && _activeTool == 'ruler') {
        double dx = worldPt.dx - START_X;
        double len = (dx.abs() / CM_TO_PX);
        len = (len * 2).round() / 2; // snap to 0.5cm
        if (!isUnsolved && (len - cfg['base']).abs() < 0.6) len = cfg['base'];
        _tempBase = max(1.0, len);
      } else if (_phase == 'set_angle_l' && _protractorPos != null) {
        double angle = atan2(
          worldPt.dy - _protractorPos!.dy,
          worldPt.dx - _protractorPos!.dx,
        );
        double deg = (angle * 180 / pi).roundToDouble();
        if (deg > 0) deg = 0; // clamp above ground
        if (!isUnsolved && (deg - cfg['angL']).abs() < 6) deg = cfg['angL'];
        _tempAngleL = deg;
      } else if (_phase == 'set_angle_r' && _protractorPos != null) {
        double angle = atan2(
          worldPt.dy - _protractorPos!.dy,
          worldPt.dx - _protractorPos!.dx,
        );
        double deg = (angle * 180 / pi).roundToDouble();
        if (deg > 0) deg = 0;
        if (!isUnsolved && (deg - cfg['angR']).abs() < 6) deg = cfg['angR'];
        _tempAngleR = deg;
      } else if (_phase == 'draw_side2' && _activeTool == 'ruler') {
        double rayRad = (isUnsolved ? _rayL! : cfg['angL']) * pi / 180;
        double vx = worldPt.dx - START_X;
        double vy = worldPt.dy - BASE_Y;
        double proj = vx * cos(rayRad) + vy * sin(rayRad);
        double len = max(1.0, proj / CM_TO_PX);
        len = (len * 2).round() / 2;
        if (!isUnsolved && (len - cfg['side2']).abs() < 0.6) len = cfg['side2'];
        _tempSide2 = len;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    bool isEndInteractive = _phase == 'set_angle_l' || _phase == 'set_angle_r';
    if (_activeTool == '' && !isEndInteractive) return;

    var cfg = _scenarios[_scenario]!;
    bool isUnsolved = cfg['unsolved'];

    setState(() {
      if (_phase == 'draw_base' && _tempBase != null) {
        if (isUnsolved || _tempBase == cfg['base']) {
          _baseLen = _tempBase;
          _tempBase = null;
          _phase = 'place_protractor_l';
          _activeTool = '';
          _playSound(_sndSnap);
        } else {
          _tempBase = null;
          _playSound(_sndError);
        }
      } else if (_phase == 'set_angle_l' && _tempAngleL != null) {
        if (isUnsolved || _tempAngleL == cfg['angL']) {
          _rayL = _tempAngleL;
          _tempAngleL = null;
          _protractorPos = null;
          _phase = cfg['type'] == 'SAS' ? 'draw_side2' : 'place_protractor_r';
          _playSound(_sndSnap);
        } else {
          _tempAngleL = null;
          _playSound(_sndError);
        }
      } else if (_phase == 'set_angle_r' && _tempAngleR != null) {
        if (isUnsolved || _tempAngleR == cfg['angR']) {
          _rayR = _tempAngleR;
          _tempAngleR = null;
          _protractorPos = null;
          _phase = 'intersect';
          _playSound(_sndSnap);
        } else {
          _tempAngleR = null;
          _playSound(_sndError);
        }
      } else if (_phase == 'draw_side2' && _tempSide2 != null) {
        if (isUnsolved || _tempSide2 == cfg['side2']) {
          _side2Len = _tempSide2;
          _tempSide2 = null;
          _phase = 'connect';
          _activeTool = '';
          _playSound(_sndSnap);
        } else {
          _tempSide2 = null;
          _playSound(_sndError);
        }
      }
    });
  }

  Offset _calculateIntersection() {
    double pxBase = _baseLen! * CM_TO_PX;
    double a1 = _rayL! * pi / 180;
    double a2 = _rayR! * pi / 180;
    double t1 = pxBase / (cos(a1) - sin(a1) / tan(a2));
    return Offset(START_X + t1 * cos(a1), BASE_Y + t1 * sin(a1));
  }

  void _triggerConnect() {
    _playSound(_sndSuccess);
    setState(() {
      _phase = 'complete';
    });
    _autoProceedIfNeeded();
  }

  void _triggerCheck() {
    var cfg = _scenarios[_scenario]!;

    bool isBaseCorrect =
        _baseLen != null && (_baseLen! - cfg['base']).abs() < 0.2;
    bool isAngLCorrect = _rayL != null && (_rayL! - cfg['angL']).abs() < 2;
    bool isAngRCorrect =
        cfg['type'] == 'ASA'
            ? (_rayR != null && (_rayR! - cfg['angR']).abs() < 2)
            : true;
    bool isSide2Correct =
        cfg['type'] == 'SAS'
            ? (_side2Len != null && (_side2Len! - cfg['side2']).abs() < 0.2)
            : true;

    bool allCorrect =
        isBaseCorrect && isAngLCorrect && isAngRCorrect && isSide2Correct;

    setState(() {
      _phase = 'analyzed';
      _allCorrect = allCorrect;
    });

    if (allCorrect) {
      _playSound(_sndSuccess);
    } else {
      _playSound(_sndError);
      int currentScen = _scenario;
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _scenario == currentScen && _phase == 'analyzed') {
          _loadScenario(_scenario);
        }
      });
    }
  }

  void _autoProceedIfNeeded() {
    var cfg = _scenarios[_scenario]!;
    int currentScen = _scenario;
    if (!cfg['unsolved']) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _scenario == currentScen) {
          setState(() {
            _phase = 'analyzed';
            _allCorrect = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35;
    if (sidebarWidth < 340) {
      sidebarWidth = 340;
    }

    String activeHUD = _getHUDText();
    var cfg = _scenarios[_scenario]!;
    int totalSteps = cfg['steps'];
    int stepIdx = currentStepIndex;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: cZslDark,
        body: Stack(
          children: [
            // --- 1. Canvas Area (Adjusts width depending on sidebar state) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onScaleStart:
                    (d) => _handleScaleStart(
                      d,
                      Size(
                        screenWidth - (_isSidebarOpen ? sidebarWidth : 0),
                        MediaQuery.of(context).size.height,
                      ),
                    ),
                onScaleUpdate:
                    (d) => _handleScaleUpdate(
                      d,
                      Size(
                        screenWidth - (_isSidebarOpen ? sidebarWidth : 0),
                        MediaQuery.of(context).size.height,
                      ),
                    ),
                onScaleEnd: (d) => _handleScaleEnd(d),
                child: Container(
                  color: cZslDark,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CanvasPainter(
                          scale: _scale,
                          pan: _pan,
                          scenario: cfg,
                          phase: _phase,
                          baseLen: _baseLen,
                          tempBase: _tempBase,
                          rayL: _rayL,
                          tempAngleL: _tempAngleL,
                          rayR: _rayR,
                          tempAngleR: _tempAngleR,
                          side2Len: _side2Len,
                          tempSide2: _tempSide2,
                          protractorPos: _protractorPos,
                          protractorSide: _protractorSide,
                          allCorrect: _allCorrect,
                          pulseValue: _pulseController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),
            ),

            // --- Canvas Mini HUD (Bottom Center) ---
            if (activeHUD.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                bottom: 24, // Neatly at the bottom edge
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: cZslPanel.withValues(
                        alpha: 0.95,
                      ), // Semi-transparent
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cIndigo.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: cIndigo.withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: cCyan),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activeHUD
                                .replaceAll('Task: ', '')
                                .replaceAll('<b>', '')
                                .replaceAll('</b>', ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- 2. Toolbar (Left of canvas, right of sidebar when open) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _isSidebarOpen ? sidebarWidth + 16 : 16,
              top: 80,
              child: Column(
                children: [
                  _buildToolButton(Icons.straighten, 'ruler'),
                  const SizedBox(height: 8),
                  _buildToolButton(Icons.architecture, 'protractor'),
                ],
              ),
            ),

            // --- Floating Action Buttons (Bottom Right safely above HUD) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              right: 20,
              bottom: 80,
              child: _buildActionButtons(),
            ),

            // --- 3. Sidebar Container (Fully Scrollable) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: cZslPanel,
                  border: const Border(
                    right: BorderSide(color: Colors.white12),
                  ),
                  boxShadow: [
                    if (_isSidebarOpen)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 80, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Texts
                            Text(
                              t('appTitle'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Language and Reset Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleLang,
                                    icon: const Icon(
                                      Icons.language,
                                      size: 16,
                                      color: Colors.white,
                                    ), // Globe Icon
                                    label: Text(
                                      _lang.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cIndigo.withValues(
                                        alpha: 0.2,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: cIndigo.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _resetLab,
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: cRose,
                                    ),
                                    label: const Text(
                                      'Reset',
                                      style: TextStyle(color: cRose),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cRose.withValues(
                                        alpha: 0.1,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: cRose.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Scenario Selector
                            Text(
                              t('selectScenario').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.indigoAccent.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                  onChanged: (val) {
                                    if (val != null) _loadScenario(val);
                                  },
                                  items:
                                      [1, 2, 3, 4, 5].map((id) {
                                        return DropdownMenuItem<int>(
                                          value: id,
                                          child: Text(
                                            t('s${id}_title'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Objective
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cIndigo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: cIndigo.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.indigoAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('objectiveLbl'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t('s${_scenario}_obj'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Blueprint Specs
                            if (cfg['unsolved'] == true)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.architecture,
                                          color: Colors.blueAccent,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t('blueprintSpecs').toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _buildSpecItem(
                                          t('baseText'),
                                          '${cfg['base']} cm',
                                        ),
                                        _buildSpecItem(
                                          t('angLText'),
                                          '${cfg['angL_val'] ?? cfg['angL'].abs()}°',
                                        ),
                                        if (cfg['type'] == 'SAS')
                                          _buildSpecItem(
                                            t('side2Text'),
                                            '${cfg['side2']} cm',
                                          )
                                        else
                                          _buildSpecItem(
                                            t('angRText'),
                                            '${cfg['angR_val']}°',
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Observation Steps Logic mapping to HTML list structure
                      if (cfg['unsolved'] == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: List.generate(totalSteps, (index) {
                              bool isPast = index < stepIdx;
                              bool isActive = index == stepIdx;

                              Color bgColor =
                                  isPast
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : (isActive
                                          ? cIndigo.withValues(alpha: 0.15)
                                          : Colors.white.withValues(
                                            alpha: 0.02,
                                          ));
                              Color borderColor =
                                  isActive
                                      ? cIndigo.withValues(alpha: 0.6)
                                      : Colors.white12;
                              Color iconColor =
                                  isPast
                                      ? cEmerald
                                      : (isActive
                                          ? Colors.white
                                          : Colors.white30);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.only(
                                        right: 12,
                                        top: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isPast
                                                ? Colors.transparent
                                                : (isActive
                                                    ? cIndigo
                                                    : Colors.white12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child:
                                            isPast
                                                ? const Icon(
                                                  Icons.check_circle,
                                                  color: cEmerald,
                                                  size: 28,
                                                )
                                                : Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: iconColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${t('stepLabel')} ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _getStepObservationText(index),
                                            style: TextStyle(
                                              color:
                                                  isPast
                                                      ? Colors.white54
                                                      : (isActive
                                                          ? Colors.white
                                                          : Colors.white30),
                                              fontSize: 13,
                                              height: 1.4,
                                              decoration:
                                                  isPast
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                      // Final Summary Panel
                      if ((!cfg['unsolved'] && _phase == 'complete') ||
                          (_phase == 'analyzed' &&
                              (!cfg['unsolved'] || _allCorrect)))
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cEmerald.withValues(alpha: 0.1),
                            border: Border.all(
                              color: cEmerald.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: cEmerald,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t('completed'),
                                    style: const TextStyle(
                                      color: cEmerald,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t('s${_scenario}_sum'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: const Text(
                          '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 4. Fixed Menu Button (Top Left) ---
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: cAmber,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound(_sndPop);
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cAmber.withValues(alpha: 0.8)),
                  ),
                ),
              ),
            ),

            // --- 6. Success Modal ---
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(32),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: cZslPanel,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: cEmerald.withValues(alpha: 0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: cEmerald,
                              ),
                              child: const Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t('successTitle'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('successDesc'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playSound(_sndPop);
                                setState(() {
                                  _showSuccessPopup = false;
                                  _resetConstructionState();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(t('restartLab')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cIndigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

            // --- 7. Curtain Raiser (Intro Screen) ---
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_showCurtain,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0.0,
                    end:
                        _showCurtain
                            ? 0.0
                            : -MediaQuery.of(context).size.height,
                  ),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubic,
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset(0, val),
                      child: child,
                    );
                  },
                  child: Container(
                    color: cZslDark,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.architecture,
                            size: 80,
                            color: cIndigo,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('appTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
                              _playSound(_sndSuccess);
                              setState(() {
                                _showCurtain = false;
                              });
                            },
                            icon: const Icon(Icons.play_circle_fill, size: 24),
                            label: Text(t('enterLab')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }

  String _getStepObservationText(int index) {
    var cfg = _scenarios[_scenario]!;
    if (cfg['unsolved']) {
      return t('s${_scenario}_text_1');
    }
    String key = 's${_scenario}_text_${index + 1}';
    return t(key)
        .replaceAll('Task: ', '')
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('<br><br>', '\n\n')
        .replaceAll('<span class=\'text-emerald-500 font-semibold\'>', '')
        .replaceAll('</span>', '');
  }

  String _getHUDText() {
    var cfg = _scenarios[_scenario]!;
    if (cfg['unsolved']) {
      if (_phase == 'analyzed' && _allCorrect) return "";
      if (_phase == 'complete') return t('hud_complete');
      if (_phase == 'analyzed' && !_allCorrect) return t('hud_error');
      return t('s${_scenario}_hud_1');
    } else {
      if (_phase == 'analyzed' ||
          (_phase == 'complete' && currentStepIndex >= cfg['steps'])) {
        return "";
      }
      return t('s${_scenario}_hud_${currentStepIndex + 1}');
    }
  }

  Widget _buildSpecItem(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    bool isUnsolved = _scenarios[_scenario]!['unsolved'];

    if (_phase == 'connect') {
      return _buildPrimaryBtn(
        t('connectBtn'),
        Icons.polyline,
        cIndigo,
        _triggerConnect,
      );
    }

    if (_phase == 'complete') {
      if (isUnsolved) {
        return _buildPrimaryBtn(
          t('checkBtn'),
          Icons.fact_check,
          cEmerald,
          _triggerCheck,
        );
      } else {
        if (_scenario < 5) {
          return _buildPrimaryBtn(
            t('nextScenario'),
            Icons.arrow_forward,
            cEmerald,
            () => _loadScenario(_scenario + 1),
          );
        } else {
          return _buildPrimaryBtn(
            t('doneTaskBtn'),
            Icons.check_circle,
            cIndigo,
            () {
              _playSound(_sndSuccess);
              setState(() => _showSuccessPopup = true);
            },
          );
        }
      }
    }

    if (_phase == 'analyzed') {
      if (isUnsolved && !_allCorrect) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cRose.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            t('validation_error'),
            style: const TextStyle(
              color: cRose,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      if (_scenario < 5) {
        return _buildPrimaryBtn(
          t('nextScenario'),
          Icons.arrow_forward,
          cEmerald,
          () => _loadScenario(_scenario + 1),
        );
      } else {
        return _buildPrimaryBtn(
          t('doneTaskBtn'),
          Icons.check_circle,
          cIndigo,
          () {
            _playSound(_sndSuccess);
            setState(() => _showSuccessPopup = true);
          },
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildPrimaryBtn(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        elevation: 8,
        shadowColor: color.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String toolId) {
    bool isActive = _activeTool == toolId;

    return InkWell(
      onTap: () {
        _selectTool(toolId);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? cIndigo.withValues(alpha: 0.2) : cZslPanel,
          border: Border.all(color: isActive ? cIndigo : Colors.white12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isActive ? Colors.indigoAccent : Colors.white),
      ),
    );
  }
}

/// Custom Canvas Rendering
class CanvasPainter extends CustomPainter {
  final double scale;
  final Offset pan;
  final Map<String, dynamic> scenario;
  final String phase;

  final double? baseLen;
  final double? tempBase;
  final double? rayL;
  final double? tempAngleL;
  final double? rayR;
  final double? tempAngleR;
  final double? side2Len;
  final double? tempSide2;

  final Offset? protractorPos;
  final String? protractorSide;
  final bool allCorrect;
  final double pulseValue;

  CanvasPainter({
    required this.scale,
    required this.pan,
    required this.scenario,
    required this.phase,
    this.baseLen,
    this.tempBase,
    this.rayL,
    this.tempAngleL,
    this.rayR,
    this.tempAngleR,
    this.side2Len,
    this.tempSide2,
    this.protractorPos,
    this.protractorSide,
    required this.allCorrect,
    required this.pulseValue,
  });

  static const double CM_TO_PX = 30.0;
  static const double BASE_Y = 100.0;
  static const double START_X = -120.0;

  static const Color cEmerald = Color(0xFF10B981);
  static const Color cIndigo = Color(0xFF6366F1);
  static const Color cAmber = Color(0xFFF59E0B);
  static const Color cRose = Color(0xFFF43F5E);
  static const Color cCyan = Color(0xFF38BDF8);

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 10;
    const double dashSpace = 10;
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double distance = sqrt(dx * dx + dy * dy);
    double dashCount = distance / (dashWidth + dashSpace);

    double xStep = dx / dashCount;
    double yStep = dy / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startX = p1.dx + xStep * i;
      double startY = p1.dy + yStep * i;
      double endX = startX + xStep * (dashWidth / (dashWidth + dashSpace));
      double endY = startY + yStep * (dashWidth / (dashWidth + dashSpace));
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Setup World Transform
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(scale, scale);

    // 2. Draw Grid
    final gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += CM_TO_PX) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    // Colors
    Color bColor = cCyan;
    Color lColor = cAmber;
    Color rColor = cAmber;
    Color sColor = cCyan;

    if (phase == 'analyzed' && scenario['unsolved']) {
      bColor =
          (baseLen != null && (baseLen! - scenario['base']).abs() < 0.2)
              ? cEmerald
              : cRose;
      lColor =
          (rayL != null && (rayL! - scenario['angL']).abs() < 2)
              ? cEmerald
              : cRose;
      if (scenario['type'] == 'ASA') {
        rColor =
            (rayR != null && (rayR! - scenario['angR']).abs() < 2)
                ? cEmerald
                : cRose;
      } else {
        sColor =
            (side2Len != null && (side2Len! - scenario['side2']).abs() < 0.2)
                ? cEmerald
                : cRose;
      }
    }

    // 3. Draw Target Blueprint (if Analyzed & Unsolved)
    if (phase == 'analyzed' && scenario['unsolved']) {
      final bpPaint =
          Paint()
            ..color = cCyan.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;

      double bpPx = scenario['base'] * CM_TO_PX;
      Offset b1 = const Offset(START_X, BASE_Y);
      Offset b2 = Offset(START_X + bpPx, BASE_Y);
      Offset c;
      double a1 = scenario['angL'] * pi / 180;
      if (scenario['type'] == 'SAS') {
        double s2px = scenario['side2'] * CM_TO_PX;
        c = Offset(START_X + s2px * cos(a1), BASE_Y + s2px * sin(a1));
      } else {
        double a2 = scenario['angR'] * pi / 180;
        double t1 = bpPx / (cos(a1) - sin(a1) / tan(a2));
        c = Offset(START_X + t1 * cos(a1), BASE_Y + t1 * sin(a1));
      }

      // Draw Dashed Blueprint Lines
      _drawDashedLine(canvas, b1, b2, bpPaint);
      _drawDashedLine(canvas, b2, c, bpPaint);
      _drawDashedLine(canvas, c, b1, bpPaint);
    }

    // 4. Draw User Construction
    final drawPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final fillPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Base
    double? activeBase = baseLen ?? tempBase;
    if (activeBase != null) {
      double px = activeBase * CM_TO_PX;
      drawPaint.color = bColor;
      canvas.drawLine(
        const Offset(START_X, BASE_Y),
        Offset(START_X + px, BASE_Y),
        drawPaint,
      );
      canvas.drawCircle(const Offset(START_X, BASE_Y), 6, fillPaint);
      canvas.drawCircle(Offset(START_X + px, BASE_Y), 6, fillPaint);
      _drawText(
        canvas,
        '${activeBase.toStringAsFixed(1)} cm',
        Offset(START_X + px / 2, BASE_Y + 25),
        Colors.white,
      );
    }

    // Ray L
    double? activeRayL = rayL ?? tempAngleL;
    if (activeRayL != null && activeBase != null) {
      double rad = activeRayL * pi / 180;
      final rayPaint =
          Paint()
            ..color = cIndigo.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      _drawDashedLine(
        canvas,
        const Offset(START_X, BASE_Y),
        Offset(START_X + 1000 * cos(rad), BASE_Y + 1000 * sin(rad)),
        rayPaint,
      );

      drawPaint.color = lColor;
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(START_X, BASE_Y), radius: 50),
        0,
        rad,
        false,
        drawPaint,
      );
      _drawText(
        canvas,
        '${activeRayL.abs().round()}°',
        Offset(START_X + 65 * cos(rad / 2), BASE_Y + 65 * sin(rad / 2)),
        lColor,
      );
    }

    // Side 2
    double? activeSide2 = side2Len ?? tempSide2;
    if (activeSide2 != null && activeRayL != null && activeBase != null) {
      double rad = activeRayL * pi / 180;
      double s2px = activeSide2 * CM_TO_PX;
      Offset endPt = Offset(
        START_X + s2px * cos(rad),
        BASE_Y + s2px * sin(rad),
      );

      drawPaint.color = sColor;
      canvas.drawLine(const Offset(START_X, BASE_Y), endPt, drawPaint);
      canvas.drawCircle(endPt, 6, fillPaint);

      canvas.save();
      canvas.translate(
        START_X + (s2px / 2) * cos(rad),
        BASE_Y + (s2px / 2) * sin(rad),
      );
      canvas.rotate(rad);
      _drawText(
        canvas,
        '${activeSide2.toStringAsFixed(1)} cm',
        const Offset(0, -15),
        sColor == cCyan ? Colors.white : sColor,
      );
      canvas.restore();
    }

    // Ray R
    double? activeRayR = rayR ?? tempAngleR;
    if (activeRayR != null && activeBase != null) {
      double px = activeBase * CM_TO_PX;
      double rad = activeRayR * pi / 180;
      Offset startR = Offset(START_X + px, BASE_Y);
      final rayPaint =
          Paint()
            ..color = cIndigo.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      _drawDashedLine(
        canvas,
        startR,
        Offset(startR.dx + 1000 * cos(rad), startR.dy + 1000 * sin(rad)),
        rayPaint,
      );

      int displayDeg = (180 - activeRayR.abs()).round();
      drawPaint.color = rColor;
      canvas.drawArc(
        Rect.fromCircle(center: startR, radius: 50),
        -pi,
        rad + pi,
        false,
        drawPaint,
      );
      double midRad = (-pi + rad) / 2;
      _drawText(
        canvas,
        '$displayDeg°',
        Offset(startR.dx + 65 * cos(midRad), startR.dy + 65 * sin(midRad)),
        rColor,
      );
    }

    // Protractor UI
    if (protractorPos != null) {
      canvas.save();
      canvas.translate(protractorPos!.dx, protractorPos!.dy);

      // Arc
      final pFill =
          Paint()
            ..color = cIndigo.withValues(alpha: 0.15)
            ..style = PaintingStyle.fill;
      final pStroke =
          Paint()
            ..color = cIndigo
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 140),
        0,
        -pi,
        true,
        pFill,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 140),
        0,
        -pi,
        false,
        pStroke,
      );
      canvas.drawLine(const Offset(-150, 0), const Offset(150, 0), pStroke);
      canvas.drawCircle(Offset.zero, 5, fillPaint);

      // Ticks
      final tickPaint =
          Paint()
            ..color = Colors.white54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
      for (int i = 0; i <= 180; i += 10) {
        double rad = -i * pi / 180;
        bool isMajor = i % 30 == 0;
        canvas.drawLine(
          Offset(130 * cos(rad), 130 * sin(rad)),
          Offset(
            (isMajor ? 120 : 125) * cos(rad),
            (isMajor ? 120 : 125) * sin(rad),
          ),
          tickPaint,
        );
        if (isMajor) {
          canvas.save();
          canvas.translate(110 * cos(rad), 110 * sin(rad));
          _drawText(
            canvas,
            i.toString(),
            Offset.zero,
            Colors.white54,
            fontSize: 10,
          );
          canvas.restore();
        }
      }

      // Interactive Handle Line
      if (phase == 'set_angle_l' || phase == 'set_angle_r') {
        double angle =
            phase == 'set_angle_l' ? (tempAngleL ?? -90) : (tempAngleR ?? -90);
        double rad = angle * pi / 180;
        final hPaint =
            Paint()
              ..color = cAmber
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
        canvas.drawLine(
          Offset.zero,
          Offset(180 * cos(rad), 180 * sin(rad)),
          hPaint,
        );

        // Handle (Pulsing)
        Offset hPt = Offset(140 * cos(rad), 140 * sin(rad));
        double dynamicPulse = 1.0 + (pulseValue * 0.2); // slight pulse factor
        canvas.drawCircle(
          hPt,
          16 * dynamicPulse,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
        canvas.drawCircle(hPt, 6, Paint()..color = cAmber);

        // Live Angle Text
        int displayAngle =
            phase == 'set_angle_l'
                ? angle.abs().round()
                : (180 - angle.abs()).round();
        double txtRad = phase == 'set_angle_l' ? rad / 2 : (-pi + rad) / 2;
        _drawText(
          canvas,
          '$displayAngle°',
          Offset(80 * cos(txtRad), 80 * sin(txtRad)),
          cAmber,
          fontSize: 18,
        );

        // Highlight active drawing arc
        final drawArcPaint =
            Paint()
              ..color = cAmber
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
        if (phase == 'set_angle_l') {
          canvas.drawArc(
            Rect.fromCircle(center: Offset.zero, radius: 60),
            0,
            rad,
            false,
            drawArcPaint,
          );
        } else {
          canvas.drawArc(
            Rect.fromCircle(center: Offset.zero, radius: 60),
            -pi,
            rad + pi,
            false,
            drawArcPaint,
          );
        }
      }

      canvas.restore();
    }

    // Intersection Point (Pulsing glowing target)
    if (phase == 'intersect' && rayL != null && rayR != null) {
      double pxBase = baseLen! * CM_TO_PX;
      double a1 = rayL! * pi / 180;
      double a2 = rayR! * pi / 180;
      double t1 = pxBase / (cos(a1) - sin(a1) / tan(a2));
      Offset ix = Offset(START_X + t1 * cos(a1), BASE_Y + t1 * sin(a1));

      double pRadius = 12 + (pulseValue * 4);
      canvas.drawCircle(
        ix,
        pRadius,
        Paint()..color = cEmerald.withValues(alpha: 0.4),
      );
      canvas.drawCircle(ix, 6, Paint()..color = cEmerald);
    }

    // Final Triangle Overlay
    if (phase == 'complete' ||
        (phase == 'analyzed' && (!scenario['unsolved'] || allCorrect))) {
      Offset c;
      double px = baseLen! * CM_TO_PX;
      if (scenario['type'] == 'SAS') {
        double rad = rayL! * pi / 180;
        double s2px = side2Len! * CM_TO_PX;
        c = Offset(START_X + s2px * cos(rad), BASE_Y + s2px * sin(rad));
      } else {
        double a1 = rayL! * pi / 180;
        double a2 = rayR! * pi / 180;
        double t1 = px / (cos(a1) - sin(a1) / tan(a2));
        c = Offset(START_X + t1 * cos(a1), BASE_Y + t1 * sin(a1));
      }

      Path tri =
          Path()
            ..moveTo(START_X, BASE_Y)
            ..lineTo(START_X + px, BASE_Y)
            ..lineTo(c.dx, c.dy)
            ..close();

      canvas.drawPath(
        tri,
        Paint()
          ..color = cEmerald.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        tri,
        Paint()
          ..color = cEmerald
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color, {
    double fontSize = 16,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(position.dx - tp.width / 2, position.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
