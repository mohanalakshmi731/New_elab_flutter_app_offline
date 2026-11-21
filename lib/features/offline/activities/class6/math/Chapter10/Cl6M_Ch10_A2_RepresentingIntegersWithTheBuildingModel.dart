// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModel(),
    ),
  );
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': "Representing Integers with the Building Model",
    'appTitle': "Representing Integers",
    'appSubtitle': "Class 6 • THE OTHER SIDE OF ZERO",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Objective:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!",
    'finalDesc':
        "You have successfully explored integers using the Building Model!",
    'lbl_path_taken': "PATH TAKEN",
    'lbl_button_panel': "BUTTON PANEL",
    'lbl_higher': "HIGHER",
    'lbl_lower': "LOWER",
    'lbl_floor': "Floor",
    'f3_book': "Book Store",
    'f2_craft': "Craft Shop",
    'f1_food': "Food Court",
    'f0_hall': "Welcome Hall",
    'fm1_toy': "Toy Store",
    'fm2_stor': "Video Games",
    'fm3_cinema': "Cinema Centre",
    'fm4_park': "Parking",
    's1_summary':
        "You pressed the '+' button two times to go up two floors.\nFloors above the ground are positive numbers.\nThe higher the floor, the greater the number.",
    's2_summary':
        "You pressed the '–' button two times to go down two floors.\nFloors below the ground are negative numbers.\nThe lower the floor, the smaller the number.",
    's3_prompt':
        "Look at the building.\n\nJay is in the 'Craft Shop'\nand Aman is in the 'Toy Store'.\n\nCLICK on the character\nwho is on a higher floor.",
    's3_correct_msg': "CORRECT!\nFloor +2 is physically above Floor -1.",
    's3_math_summary':
        "SUMMARY: Any positive number is always greater\nthan any negative number because positive\nfloors are always above negative floors.",
    's4_summary':
        "To go from Floor +1 to Floor -3,\nyou had to move down 4 floors.\nThe movement was -4.",
    'lbl_s4_check': "Check Answer",
    'lbl_s4_target': "Target\nFloor: -3",
    'lbl_drag_minus': "[drag '-']",
    'lbl_s5_target': "Target\nFloor: 0",
    's5_summary':
        "SUMMARY: To cancel out being on\nFloor +3, you had to move -3 floors.\nThis brings you back to 0. We call -3\nthe 'inverse' of +3 because they cancel\neach other out.",
    's5_math': "Include:\nMathematically:\n(+3) + (-3) = 0",
    's1_title': "1. Welcome to the Building of Fun!",
    's1_obj':
        "Understand that the ground floor is represented by 0 and floors above it are represented by positive integers.",
    's1_step1_task':
        "The lift is at the 'Welcome Hall' (Floor 0). Your goal is to reach the 'Food Court' on Floor +1. DRAG the '+' button from the button panel and DROP it onto the lift's control panel.",
    's1_step1_out':
        "The '+' button snaps into the control panel, and the lift visually moves up one level from Floor 0 to Floor +1.",
    's1_step2_task':
        "You are now at the 'Food Court' (Floor +1). To reach the 'Craft Shop' (Floor +2), DRAG the '+' button and DROP it onto the lift's control panel again.",
    's1_step2_out':
        "The lift moves up one more level, from Floor +1 to Floor +2.",
    's1_step3_task': "Observe the summary.",
    's1_step3_out':
        "You pressed the '+' button two times to go up two floors. Floors above the ground are positive numbers.",
    's1_hud1': "Drag the '+' button and drop it onto the lift.",
    's1_hud2': "Drag the '+' button and drop it onto the lift again.",
    's1_hud3': "Observe the summary.",
    's2_title': "2. Exploring the Basement",
    's2_obj':
        "Understand that floors below the ground are represented by negative integers.",
    's2_step1_task':
        "The lift is at the 'Welcome Hall' (Floor 0). Your mission is to visit the 'Toy Store' on Floor -1. DRAG the '–' button from the button panel and DROP it onto the lift's control panel.",
    's2_step1_out':
        "The '–' button snaps into the control panel, and the lift visually moves down one level from Floor 0 to Floor -1.",
    's2_step2_task':
        "You are now at the 'Toy Store' (Floor -1). Let's go deeper to the 'Video Games' shop on Floor -2. DRAG the '–' button and DROP it onto the lift's control panel again.",
    's2_step2_out':
        "The lift moves down one more level, from Floor -1 to Floor -2.",
    's2_step3_task': "Observe the summary.",
    's2_step3_out':
        "You pressed the '–' button two times to go down two floors. Floors below the ground are negative numbers.",
    's2_hud1': "Drag the '–' button and drop it onto the lift.",
    's2_hud2': "Drag the '–' button and drop it onto the lift again.",
    's2_hud3': "Observe the summary.",
    's3_title': "3. Who is Higher?",
    's3_obj': "Visually compare a positive and a negative integer.",
    's3_step1_task':
        "Look at the building. Jay is in the 'Craft Shop' (+2) and Aman is in the 'Toy Store' (-1). CLICK on the character who is on a higher floor.",
    's3_step1_out': "Correct! Jay is on Floor +2 and Aman is on Floor -1.",
    's3_step2_task': "Observe the visual comparison.",
    's3_step2_out':
        "An animated vertical arrow reinforces that +2 is higher than -1.",
    's3_step3_task': "Observe the mathematical comparison.",
    's3_step3_out':
        "+2 > -1. Any positive number is always greater than any negative number.",
    's3_hud1': "Click on the character (Jay or Aman) who is on a higher floor.",
    's3_hud2': "Observe the arrow connecting the floors.",
    's3_hud3': "Observe the final mathematical comparison.",
    's4_title': "4. The Cinema Trip",
    's4_obj':
        "Starting from a positive floor, navigate to a negative floor by using the lift controls.",
    's4_step1_task':
        "You are at the 'Food Court' (Floor +1). Your friend is waiting at the 'Cinema Centre' on Floor -3. DRAG and DROP the correct buttons onto the lift's control panel to reach them.",
    's4_step1_out': "You dropped the '–' button four times.",
    's4_step2_task':
        "Once you have reached the correct floor (-3), CLICK the 'Check Answer' button below.",
    's4_step2_out': "Success! You reached Floor -3.",
    's4_step3_task': "Observe the movement summary.",
    's4_step3_out':
        "To go from Floor +1 to Floor -3, you had to move down 4 floors. The movement was -4.",
    's4_hud1': "Drag '–' to move down to Floor -3.",
    's4_hud2': "Click the 'Check Answer' button to confirm.",
    's4_hud3': "Observe the summary.",
    's5_title': "5. Back to the Ground Floor!",
    's5_obj':
        "Understand the concept of an additive inverse by returning to zero.",
    's5_step1_task':
        "Oh no! You are at the 'Book Store' on Floor +3, but you meant to stay at the 'Welcome Hall' on Floor 0. DRAG and DROP the correct buttons to cancel your movement.",
    's5_step1_out': "You dropped the '–' button three times.",
    's5_step2_task':
        "When the lift is back at the 'Welcome Hall' (0), CLICK the 'Check Answer' button below.",
    's5_step2_out': "Success! You returned to Floor 0.",
    's5_step3_task': "Observe the summary.",
    's5_step3_out':
        "To cancel out being on Floor +3, you had to move -3 floors. We call -3 the 'inverse' of +3.",
    's5_hud1': "Drag '–' to move down to Floor 0.",
    's5_hud2': "Click the 'Check Answer' button to confirm.",
    's5_hud3': "Observe the additive inverse concept.",
  },
  'hi': {
    'shutterTitle': "बिल्डिंग मॉडल के साथ पूर्णांकों का प्रतिनिधित्व",
    'appTitle': "पूर्णांकों का प्रतिनिधित्व",
    'appSubtitle': "कक्षा 6 • शून्य के दूसरी ओर",
    'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "उद्देश्य:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!",
    'finalDesc':
        "आपने मज़ेदार इमारत का उपयोग करके पूर्णांकों का सफलतापूर्वक पता लगाया है!",
    'lbl_path_taken': "लिया गया पथ",
    'lbl_button_panel': "बटन पैनल",
    'lbl_higher': "ऊपर",
    'lbl_lower': "नीचे",
    'lbl_floor': "मंजिल",
    'f3_book': "किताबों की दुकान",
    'f2_craft': "शिल्प की दुकान",
    'f1_food': "फ़ूड कोर्ट",
    'f0_hall': "स्वागत कक्ष",
    'fm1_toy': "खिलौनों की दुकान",
    'fm2_stor': "वीडियो गेम्स",
    'fm3_cinema': "सिनेमा केंद्र",
    'fm4_park': "पार्किंग",
    's1_summary':
        "आपने दो मंजिल ऊपर जाने के लिए '+' बटन को\nदो बार दबाया। जमीन के ऊपर की मंजिलें\nधनात्मक संख्याएं हैं। ऊँची मंजिल, बड़ी संख्या।",
    's2_summary':
        "आपने दो मंजिल नीचे जाने के लिए '–' बटन को\nदो बार दबाया। जमीन के नीचे की मंजिलें\nऋणात्मक संख्याएं हैं। निचली मंजिल, छोटी संख्या।",
    's3_prompt':
        "इमारत को देखें।\n\nजय 'शिल्प की दुकान' में है और\nअमन 'खिलौनों की दुकान' में है।\n\nऊँची मंजिल पर स्थित\nचरित्र पर क्लिक करें।",
    's3_correct_msg': "सही!\nमंजिल +2 शारीरिक रूप से मंजिल -1 के ऊपर है।",
    's3_math_summary':
        "सारांश: कोई भी धनात्मक संख्या हमेशा किसी भी ऋणात्मक\nसंख्या से बड़ी होती है क्योंकि धनात्मक मंजिलें हमेशा\nऋणात्मक मंजिलों के ऊपर होती हैं।",
    's4_summary':
        "मंजिल +1 से मंजिल -3 तक जाने के लिए,\nआपको 4 मंजिल नीचे जाना पड़ा।\nआंदोलन -4 था।",
    'lbl_s4_check': "उत्तर जांचें",
    'lbl_s4_target': "लक्ष्य\nमंजिल: -3",
    'lbl_drag_minus': "['-' खींचें]",
    'lbl_s5_target': "लक्ष्य\nमंजिल: 0",
    's5_summary':
        "सारांश: मंजिल +3 पर होने को रद्द करने के लिए,\nआपको -3 मंजिलें पार करनी पड़ीं। यह आपको 0\nपर वापस लाता है। हम -3 को +3 का 'प्रतिलोम' कहते हैं\nक्योंकि वे एक-दूसरे को रद्द कर देते हैं।",
    's5_math': "शामिल करें:\nगणितीय रूप से:\n(+3) + (-3) = 0",
    's1_title': "1. मज़ेदार इमारत में आपका स्वागत है!",
    's1_obj':
        "समझें कि भूतल को 0 द्वारा दर्शाया गया है और इसके ऊपर की मंजिलों को धनात्मक पूर्णांकों द्वारा दर्शाया गया है।",
    's1_step1_task':
        "लिफ्ट 'स्वागत कक्ष' (मंजिल 0) पर है। आपका लक्ष्य मंजिल +1 पर 'फ़ूड कोर्ट' तक पहुंचना है। बटन पैनल से '+' बटन खींचें और लिफ्ट के कंट्रोल पैनल पर छोड़ें।",
    's1_step1_out':
        "'+' बटन कंट्रोल पैनल में स्नैप हो जाता है, और लिफ्ट मंजिल 0 से मंजिल +1 तक एक स्तर ऊपर जाती है।",
    's1_step2_task':
        "अब आप 'फ़ूड कोर्ट' (मंजिल +1) पर हैं। 'शिल्प की दुकान' (मंजिल +2) तक पहुंचने के लिए, फिर से '+' बटन खींचें और लिफ्ट पर छोड़ें।",
    's1_step2_out': "लिफ्ट एक और स्तर ऊपर जाती है, मंजिल +1 से मंजिल +2 तक।",
    's1_step3_task': "सारांश देखें।",
    's1_step3_out':
        "आपने दो मंजिल ऊपर जाने के लिए '+' बटन को दो बार दबाया। जमीन के ऊपर की मंजिलें धनात्मक संख्याएं हैं। ऊँची मंजिल, बड़ी संख्या।",
    's1_hud1': "हरे '+' बटन को खींचकर लिफ्ट पर छोड़ें।",
    's1_hud2': "हरे '+' बटन को खींचकर फिर से लिफ्ट पर छोड़ें।",
    's1_hud3': "सारांश का निरीक्षण करें।",
    's2_title': "2. बेसमेंट की खोज",
    's2_obj':
        "समझें कि जमीन के नीचे की मंजिलों को ऋणात्मक पूर्णांकों द्वारा दर्शाया जाता है।",
    's2_step1_task':
        "लिफ्ट 'स्वागत कक्ष' (मंजिल 0) पर है। आपका मिशन मंजिल -1 पर 'खिलौनों की दुकान' जाना है। बटन पैनल से '–' बटन खींचें और लिफ्ट के कंट्रोल पैनल पर छोड़ें।",
    's2_step1_out':
        "'–' बटन कंट्रोल पैनल में स्नैप हो जाता है, और लिफ्ट मंजिल 0 से मंजिल -1 तक एक स्तर नीचे जाती है।",
    's2_step2_task':
        "अब आप 'खिलौनों की दुकान' (मंजिल -1) पर हैं। मंजिल -2 पर 'वीडियो गेम्स' की दुकान तक जाने के लिए '–' बटन खींचें और फिर से छोड़ें।",
    's2_step2_out': "लिफ्ट एक और स्तर नीचे जाती है, मंजिल -1 से मंजिल -2 तक।",
    's2_step3_task': "सारांश देखें।",
    's2_step3_out':
        "आपने दो मंजिल नीचे जाने के लिए '–' बटन को दो बार दबाया। जमीन के नीचे की मंजिलें ऋणात्मक संख्याएं हैं। निचली मंजिल, छोटी संख्या।",
    's2_hud1': "लाल '–' बटन को खींचकर लिफ्ट पर छोड़ें।",
    's2_hud2': "लाल '–' बटन को खींचकर फिर से लिफ्ट पर छोड़ें।",
    's2_hud3': "सारांश का निरीक्षण करें।",
    's3_title': "3. कौन ऊँचा है?",
    's3_obj': "एक धनात्मक और एक ऋणात्मक पूर्णांक की दृष्टि से तुलना करें।",
    's3_step1_task':
        "इमारत को देखें। जय 'शिल्प की दुकान' (+2) में है और अमन 'खिलौनों की दुकान' (-1) में है। उस चरित्र पर क्लिक करें जो ऊँची मंजिल पर है।",
    's3_step1_out': "सही! जय मंजिल +2 पर है और अमन मंजिल -1 पर है।",
    's3_step2_task': "दृश्य तुलना का निरीक्षण करें।",
    's3_step2_out':
        "एक एनिमेटेड ऊर्ध्वाधर तीर पुष्टि करता है कि +2, -1 से अधिक है।",
    's3_step3_task': "गणितीय तुलना का निरीक्षण करें।",
    's3_step3_out':
        "+2 > -1. कोई भी धनात्मक संख्या हमेशा किसी भी ऋणात्मक संख्या से बड़ी होती है।",
    's3_hud1': "उस चरित्र (जय या अमन) पर क्लिक करें जो ऊँची मंजिल पर है।",
    's3_hud2': "मंजिलों को जोड़ने वाले तीर का निरीक्षण करें।",
    's3_hud3': "अंतिम गणितीय तुलना का निरीक्षण करें।",
    's4_title': "4. सिनेमा की यात्रा",
    's4_obj':
        "लिफ्ट नियंत्रणों का उपयोग करके एक धनात्मक मंजिल से ऋणात्मक मंजिल तक जाएँ।",
    's4_step1_task':
        "आप 'फ़ूड कोर्ट' (मंजिल +1) पर हैं। आपका दोस्त 'सिनेमा केंद्र' (मंजिल -3) में आपका इंतजार कर रहा है। वहां पहुंचने के लिए सही बटनों को लिफ्ट के कंट्रोल पैनल पर खींचें और छोड़ें।",
    's4_step1_out': "आपने '–' बटन को चार बार गिराया।",
    's4_step2_task':
        "एक बार जब आप सही मंजिल (-3) पर पहुँच जाएँ, तो नीचे 'Check Answer' बटन पर क्लिक करें।",
    's4_step2_out': "सफलता! आप मंजिल -3 पर पहुँच गए।",
    's4_step3_task': "आंदोलन सारांश का निरीक्षण करें।",
    's4_step3_out':
        "मंजिल +1 से मंजिल -3 तक जाने के लिए, आपको 4 मंजिल नीचे जाना पड़ा। आंदोलन -4 था।",
    's4_hud1': "मंजिल -3 पर नीचे जाने के लिए '–' को खींचें।",
    's4_hud2': "पुष्टि करने के लिए 'Check Answer' बटन पर क्लिक करें।",
    's4_hud3': "सारांश का निरीक्षण करें।",
    's5_title': "5. वापस भूतल पर!",
    's5_obj': "शून्य पर लौटकर एक योज्य प्रतिलोम की अवधारणा को समझें।",
    's5_step1_task':
        "ओह नहीं! आप मंजिल +3 पर 'किताबों की दुकान' पर हैं, लेकिन आपको मंजिल 0 पर 'स्वागत कक्ष' में रहना था। अपनी गति को रद्द करने के लिए सही बटनों को खींचें और छोड़ें।",
    's5_step1_out': "आपने '–' बटन को तीन बार गिराया।",
    's5_step2_task':
        "जब लिफ्ट वापस 'स्वागत कक्ष' (0) पर आ जाए, तो 'Check Answer' बटन पर क्लिक करें।",
    's5_step2_out': "सफलता! आप मंजिल 0 पर लौट आए।",
    's5_step3_task': "सारांश देखें।",
    's5_step3_out':
        "मंजिल +3 पर होने को रद्द करने के लिए, आपको -3 मंजिलें पार करनी पड़ीं। हम -3 को +3 का 'प्रतिलोम' कहते हैं।",
    's5_hud1': "मंजिल 0 पर नीचे जाने के लिए '–' को खींचें।",
    's5_hud2': "पुष्टि करने के लिए 'Check Answer' बटन पर क्लिक करें।",
    's5_hud3': "योज्य प्रतिलोम अवधारणा का निरीक्षण करें।",
  },
};

// --- DATA MODELS ---
class FloorDef {
  final int level;
  final String nameKey;
  FloorDef(this.level, this.nameKey);
}

class StepConfig {
  final String task;
  final String outcome;
  final String hud;
  StepConfig(this.task, this.outcome, this.hud);
}

class ScenarioConfig {
  final String title;
  final String objective;
  final List<StepConfig> steps;
  ScenarioConfig(this.title, this.objective, this.steps);
}

final List<FloorDef> floorsS1 = [
  FloorDef(2, 'f2_craft'),
  FloorDef(1, 'f1_food'),
  FloorDef(0, 'f0_hall'),
  FloorDef(-1, 'fm1_toy'),
];
final List<FloorDef> floorsS2 = [
  FloorDef(0, 'f0_hall'),
  FloorDef(-1, 'fm1_toy'),
  FloorDef(-2, 'fm2_stor'),
];
final List<FloorDef> floorsS3 = [
  FloorDef(2, 'f2_craft'),
  FloorDef(1, 'f1_food'),
  FloorDef(0, 'f0_hall'),
  FloorDef(-1, 'fm1_toy'),
  FloorDef(-2, 'fm2_stor'),
];
final List<FloorDef> floorsS4 = [
  FloorDef(1, 'f1_food'),
  FloorDef(0, 'f0_hall'),
  FloorDef(-1, 'fm1_toy'),
  FloorDef(-2, 'fm2_stor'),
  FloorDef(-3, 'fm3_cinema'),
  FloorDef(-4, 'fm4_park'),
];
final List<FloorDef> floorsS5 = [
  FloorDef(3, 'f3_book'),
  FloorDef(2, 'f2_craft'),
  FloorDef(1, 'f1_food'),
  FloorDef(0, 'f0_hall'),
  FloorDef(-1, 'fm1_toy'),
];

// --- MAIN WIDGET ---
class Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModel
    extends StatefulWidget {
  const Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModel({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModel> createState() =>
      _Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModelState();
}

class _Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModelState
    extends State<Cl6M_Ch10_A2_RepresentingIntegersWithTheBuildingModel>
    with TickerProviderStateMixin {
  String _lang = 'en';
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350;
  bool _isCurtainOpen = false;
  bool _showSuccessPopup = false;

  // View state
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  double _panX = 0;
  double _panY = 0;

  // Game state
  int _scenario = 1;
  int _step = 0;
  double _liftFloor = 0;
  List<double> _path = [0];

  // Dragging
  String? _dragEntity;
  Offset _dragPos = Offset.zero;

  // S3 specifics
  String? _s3Hover;

  bool _isAnimating = false;

  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _renderController;

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _renderController =
        AnimationController(vsync: this, duration: const Duration(days: 365))
          ..addListener(() {
            setState(() {});
          })
          ..forward();

    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _renderController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  String t(String key) {
    return translations[_lang]?[key] ?? translations['en']?[key] ?? key;
  }

  void _toggleLanguage() {
    playClick();
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _resetLab() {
    playClick();
    setState(() {
      _isCurtainOpen = false;
      _showSuccessPopup = false;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _loadScenario(1);
    });
  }

  void _enterLab() {
    curtainScreen();
    setState(() {
      _isCurtainOpen = true;
    });
  }

  void _fitScreen() {
    setState(() {
      _zoom = 1.0;
      _baseZoom = 1.0;
      _panX = 0;
      if (_scenario == 1 || _scenario == 3) {
        _panY = 150;
      } else if (_scenario == 2) {
        _panY = -150;
      } else if (_scenario == 4) {
        _panY = -100;
      } else if (_scenario == 5) {
        _panY = 250;
      } else {
        _panY = 0;
      }
    });
  }

  void _loadScenario(int s) {
    setState(() {
      _scenario = s;
      _step = 0;
      _isAnimating = false;
      _dragEntity = null;
      _showSuccessPopup = false;
      _s3Hover = null;

      if (s == 1 || s == 2) {
        _liftFloor = 0;
        _path = [0];
      } else if (s == 4) {
        _liftFloor = 1;
        _path = [1];
      } else if (s == 5) {
        _liftFloor = 3;
        _path = [3];
      }
    });
    _fitScreen();
  }

  void _advanceStep() {
    setState(() => _step++);
  }

  void _checkScenarioSuccess() {
    ScenarioConfig cfg = _getScenarioConfig(_scenario);
    setState(() => _step = cfg.steps.length);
    if (_scenario == 5) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        playPageOpen();
        setState(() => _showSuccessPopup = true);
      });
    } else {
      playPageOpen();
    }
  }

  ScenarioConfig _getScenarioConfig(int id) {
    List<StepConfig> steps = [];
    for (int i = 1; i <= 3; i++) {
      steps.add(
        StepConfig(
          t('s${id}_step${i}_task'),
          t('s${id}_step${i}_out'),
          t('s${id}_hud$i'),
        ),
      );
    }
    return ScenarioConfig(t('s${id}_title'), t('s${id}_obj'), steps);
  }

  // Coordinate mapping
  Offset _getCanvasPoint(Offset screenPos) {
    final RenderBox renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(screenPos);

    double worldX = (localPos.dx - renderBox.size.width / 2 - _panX) / _zoom;
    double worldY = (localPos.dy - renderBox.size.height / 2 - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  // Pure pointer events for instant game interaction (clicking and dragging buttons)
  void _onPointerDown(PointerDownEvent event) {
    if (_isAnimating) return;
    final pt = _getCanvasPoint(event.position);

    double floorH = 180;
    double shaftX = -80;
    double shaftW = 160;

    if (_scenario == 1) {
      double cx = shaftX + shaftW + 60;
      double cy = 0 - (_liftFloor * floorH) - floorH / 2;
      if (_hitTestBox(cx - 35, cy - 80, 70, 160, pt)) {
        // Panel Hit Box
        if (_hitTestBox(cx - 20, cy - 55, 40, 40, pt)) {
          playClick();
          setState(() {
            _dragEntity = 'plus';
            _dragPos = pt;
          });
        }
        return;
      }
    } else if (_scenario == 2) {
      double cx = shaftX + shaftW + 90;
      double cy = -100 - (_liftFloor * floorH) - floorH / 2;
      if (_hitTestBox(cx - 40, cy - 50, 80, 80, pt)) {
        // Panel Hit Box
        if (_hitTestBox(cx - 20, cy - 15, 40, 40, pt)) {
          playClick();
          setState(() {
            _dragEntity = 'minus';
            _dragPos = pt;
          });
        }
        return;
      }
    } else if (_scenario == 3 && _step == 0) {
      double jayY = 0 - 2 * floorH;
      double amanY = 0 - (-1) * floorH;
      if (_hitTestBox(-40, jayY - 120, 80, 120, pt)) {
        playClick();
        _advanceStep();
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
        });
        return;
      } else if (_hitTestBox(110, amanY - 120, 80, 120, pt)) {
        playError();
        return; // Wrong choice
      }
    } else if (_scenario == 4 || _scenario == 5) {
      double refY = _scenario == 4 ? 0 : 200;
      double cx = shaftX + shaftW + 60;
      double cy = refY - (_liftFloor * floorH) - floorH / 2;

      if (_hitTestBox(cx - 35, cy - 80, 70, 160, pt)) {
        // Panel Hit Box
        if (_hitTestBox(cx - 20, cy + 15, 40, 40, pt)) {
          playClick();
          setState(() {
            _dragEntity = 'minus';
            _dragPos = pt;
          });
        }
        return;
      }

      // Check Answer Button
      if (_step <= 1 &&
          _hitTestBox(
            shaftX + shaftW / 2 - 90,
            refY - (_liftFloor * floorH) - 125,
            180,
            50,
            pt,
          )) {
        int correctFloor = _scenario == 4 ? -3 : 0;
        if (_liftFloor == correctFloor) {
          playPageOpen();
          _advanceStep();
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
          });
        } else {
          playError();
          setState(() {
            _liftFloor = _scenario == 4 ? 1 : 3;
            _path = [_liftFloor];
          });
        }
        return;
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final pt = _getCanvasPoint(event.position);

    if (_dragEntity != null) {
      setState(() => _dragPos = pt);
      return;
    }

    // Optional S3 Character Hover visual (since touch interface uses drag mostly for this)
    if (_scenario == 3 && _step == 0) {
      double floorH = 180;
      double jayY = 0 - 2 * floorH;
      double amanY = 0 - (-1) * floorH;
      String? newHover;
      if (_hitTestBox(-40, jayY - 120, 80, 120, pt)) {
        newHover = 'jay';
      } else if (_hitTestBox(110, amanY - 120, 80, 120, pt)) {
        newHover = 'aman';
      }

      if (_s3Hover != newHover) {
        setState(() => _s3Hover = newHover);
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_dragEntity != null) {
      final pt = _getCanvasPoint(event.position);
      double floorH = 180;
      double shaftX = -80;
      double lw = 140;
      double lh = floorH - 10;

      double liftY = 0;
      if (_scenario == 1) {
        liftY = 0 - (_liftFloor * floorH);
      } else if (_scenario == 2) {
        liftY = -100 - (_liftFloor * floorH);
      } else if (_scenario == 4) {
        liftY = 0 - (_liftFloor * floorH);
      } else if (_scenario == 5) {
        liftY = 200 - (_liftFloor * floorH);
      }

      if (_hitTestBox(shaftX + 10, liftY - lh / 2 - 20, lw, lh + 40, pt)) {
        bool canMove = false;
        double target = _liftFloor;

        if (_scenario == 1 && _dragEntity == 'plus' && _liftFloor < 2) {
          target = _liftFloor + 1;
          canMove = true;
        } else if (_scenario == 2 &&
            _dragEntity == 'minus' &&
            _liftFloor > -2) {
          target = _liftFloor - 1;
          canMove = true;
        } else if (_scenario == 4 &&
            _dragEntity == 'minus' &&
            _liftFloor > -4) {
          target = _liftFloor - 1;
          canMove = true;
        } else if (_scenario == 5 &&
            _dragEntity == 'minus' &&
            _liftFloor > -1) {
          target = _liftFloor - 1;
          canMove = true;
        }

        if (canMove) {
          playClick();
          _animateLift(target, () {
            if (!mounted) return;
            setState(() => _path.add(target));
            if (_scenario == 1) {
              if (_step == 0 && target == 1) {
                _advanceStep();
              } else if (_step == 1 && target == 2) {
                _advanceStep();
                Future.delayed(
                  const Duration(seconds: 1),
                  _checkScenarioSuccess,
                );
              }
            } else if (_scenario == 2) {
              if (_step == 0 && target == -1) {
                _advanceStep();
              } else if (_step == 1 && target == -2) {
                _advanceStep();
                Future.delayed(
                  const Duration(seconds: 1),
                  _checkScenarioSuccess,
                );
              }
            }
          });
        } else {
          playError();
        }
      } else {
        playError();
      }
      setState(() {
        _dragEntity = null;
      });
    }
  }

  // Gesture handling specifically limited to Pan & Zoom viewing adjustments
  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = _zoom;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_dragEntity != null) {
      return; // Ignore view panning if we are currently dragging a game entity
    }

    setState(() {
      if (details.scale != 1.0) {
        _zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
      }
      _panX += details.focalPointDelta.dx;
      _panY += details.focalPointDelta.dy;
    });
  }

  void _animateLift(double targetFloor, VoidCallback onDone) {
    setState(() => _isAnimating = true);

    double startFloor = _liftFloor;
    double dist = targetFloor - startFloor;
    int frames = 30;
    int f = 0;

    void tick() {
      f++;
      setState(() {
        _liftFloor = startFloor + (dist * (f / frames));
      });
      if (f >= frames) {
        setState(() {
          _liftFloor = targetFloor;
          _isAnimating = false;
        });
        onDone();
        _renderController.removeListener(tick);
      }
    }

    _renderController.addListener(tick);
  }

  @override
  Widget build(BuildContext context) {
    ScenarioConfig cfg = _getScenarioConfig(_scenario);
    String hudText = _step < cfg.steps.length ? cfg.steps[_step].hud : '';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                child: Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  child: ClipRect(
                    child: Container(
                      color: const Color(0xFF0F172A),
                      child: CustomPaint(
                        key: _canvasKey,
                        painter: LabPainter(
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          scenario: _scenario,
                          step: _step,
                          liftFloor: _liftFloor,
                          path: _path,
                          dragEntity: _dragEntity,
                          dragPos: _dragPos,
                          s3Hover: _s3Hover,
                          t: t,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 64,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row (Activity Icon + Title)
                      Row(
                        children: [
                          const Icon(
                            Icons.apartment,
                            color: Color(0xFF6366F1),
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t('appTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 48,
                        ), // align with title text
                        child: Text(
                          t('appSubtitle'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Language & Reset Controls
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _toggleLanguage,
                            icon: const Icon(Icons.g_translate, size: 16),
                            label: Text(
                              _lang == 'en' ? 'HINDI' : 'ENGLISH',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _resetLab,
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                              color: Colors.redAccent,
                            ),
                            label: Text(
                              t('resetBtn'),
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 24),

                      Text(
                        t('selectScenario'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _scenario,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            items: [1, 2, 3, 4, 5]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      t('s${s}_title'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                playDropdown();
                                _loadScenario(v);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Objective
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.track_changes,
                                  color: Colors.pinkAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t('learnLbl'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cfg.objective,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Steps
                      ...List.generate(cfg.steps.length, (i) {
                        bool isCompleted = i < _step;
                        bool isCurrent = i == _step;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : (isCompleted
                                      ? Colors.green.withOpacity(0.05)
                                      : const Color(
                                          0xFF0F172A,
                                        ).withOpacity(0.3)),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFF6366F1)
                                  : (isCompleted
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.transparent),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              else
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${t('stepLabel')} ${i + 1}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Action: ${cfg.steps[i].task}",
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white
                                            : (isCompleted
                                                  ? Colors.white70
                                                  : Colors.grey),
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isCompleted) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          "Observation: ${cfg.steps[i].outcome}",
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 13,
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

                      // Next Scenario Button
                      if (_step == cfg.steps.length && _scenario < 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              playClick();
                              _loadScenario(_scenario + 1);
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(t('nextScenario')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                      const Center(
                        child: Text(
                          "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sidebar Drag Resizer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth - 10 : -10,
              top: 0,
              bottom: 0,
              width: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                        300.0,
                        MediaQuery.of(context).size.width - 50,
                      );
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Menu Button (Fixed Top Left)
            Positioned(
              left: 12,
              top: 12,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
                  onPressed: () {
                    playClick();
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // HUD
            if (hudText.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: 30,
                left: _isSidebarOpen ? _sidebarWidth : 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            hudText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Success Popup (S5)
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t('finalDesc'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _resetLab,
                            icon: const Icon(Icons.refresh),
                            label: Text(t('finishLab')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                ),
              ),

            // Curtain Screen
            if (!_isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.business,
                          color: Color(0xFF6366F1),
                          size: 100,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('shutterTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _enterLab,
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(t('enterLab')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 40,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}

// --- CANVAS PAINTER ---
class LabPainter extends CustomPainter {
  final double zoom;
  final double panX;
  final double panY;
  final int scenario;
  final int step;
  final double liftFloor;
  final List<double> path;
  final String? dragEntity;
  final Offset dragPos;
  final String? s3Hover;
  final String Function(String) t;

  LabPainter({
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.scenario,
    required this.step,
    required this.liftFloor,
    required this.path,
    required this.dragEntity,
    required this.dragPos,
    required this.s3Hover,
    required this.t,
  });

  final double floorH = 180;
  final double shaftX = -80;
  final double shaftW = 160;
  final Color outlineColor = const Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _drawBuildingStandard(canvas, 0, floorsS1);
      _drawLiftStandard(canvas, 0 - liftFloor * floorH);
      _drawS1Panel(canvas, 0);
      _drawPathVertical(canvas, 0);
      if (step >= 2) {
        _drawSpeechBubble(canvas, t('s1_summary'), 0, 0 + 250, 500, 100, 'top');
      }
    } else if (scenario == 2) {
      _drawS2Building(canvas, -100);
      _drawS2Lift(canvas, -100 - liftFloor * floorH);
      _drawS2Panel(canvas, -100);
      _drawS2Path(canvas, -100);
      if (step >= 2) {
        _drawSpeechBubble(
          canvas,
          t('s2_summary'),
          0,
          -100 + 250,
          500,
          100,
          'top',
        );
      }
    } else if (scenario == 3) {
      _drawS3Building(canvas, 0);
      _drawS3Characters(canvas, 0);
    } else if (scenario == 4) {
      _drawBuildingStandard(canvas, 0, floorsS4);
      _drawLiftStandard(canvas, 0 - liftFloor * floorH);
      _drawMinusPanelAndLedger(canvas, 0);
      _drawPathVertical(canvas, 0);
      if (step < 2) _drawTargetBox(canvas, 0, -3);
      if (step == 0 || step == 1) {
        _drawCheckBtn(
          canvas,
          shaftX + shaftW / 2,
          0 - liftFloor * floorH - 100,
        );
      }
      if (step >= 2) {
        _drawSpeechBubble(canvas, t('s4_summary'), 0, 200, 400, 100, 'top');
      }
    } else if (scenario == 5) {
      _drawBuildingStandard(canvas, 200, floorsS5);
      _drawLiftStandard(canvas, 200 - liftFloor * floorH);
      _drawMinusPanelAndLedger(canvas, 200);
      _drawPathVertical(canvas, 200);
      if (step < 2) _drawTargetBox(canvas, 200, 0);
      if (step == 0 || step == 1) {
        _drawCheckBtn(
          canvas,
          shaftX + shaftW / 2,
          200 - liftFloor * floorH - 100,
        );
      }
      if (step >= 2) {
        double px = shaftX + shaftW + 180;
        _drawSpeechBubble(
          canvas,
          t('s5_summary'),
          px + 80,
          200 - 400,
          450,
          160,
          'left',
        );
        _drawSpeechBubble(
          canvas,
          t('s5_math'),
          px + 80,
          200 - 200,
          300,
          100,
          'left',
          bg: const Color(0xFFE0F2FE),
          border: const Color(0xFF3B82F6),
        );
        _drawArrow(
          canvas,
          px,
          200 - 3 * floorH,
          px,
          200,
          const Color(0xFF22C55E),
          14,
        );
        _drawRoundedRect(
          canvas,
          px - 60,
          200 - 1.5 * floorH,
          120,
          60,
          8,
          const Color(0xFFF8FAFC),
          outlineColor,
          3,
        );
        _drawText(
          canvas,
          "-3 Floors\n(Movement)",
          px,
          200 - 1.5 * floorH + 30,
          const Color(0xFF0F172A),
          14,
        );
        _drawCharacterSVG(canvas, px + 50, 200 + 20, 80, false, false);
      }
    }

    canvas.restore();
  }

  void _drawBuildingStandard(Canvas canvas, double zeroY, List<FloorDef> fls) {
    Paint p = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(const Rect.fromLTWH(-1000, -2000, 2000, 4000), p);
    p.color = const Color(0xFF334155);
    canvas.drawRect(const Rect.fromLTWH(-500, -2000, 1000, 4000), p);

    p.color = outlineColor;
    canvas.drawRect(Rect.fromLTWH(shaftX - 20, -2000, 20, 4000), p);
    canvas.drawRect(Rect.fromLTWH(shaftX + shaftW, -2000, 20, 4000), p);
    canvas.drawRect(const Rect.fromLTWH(-350, -2000, 20, 4000), p);

    for (var fl in fls) {
      double fy = zeroY - fl.level * floorH;
      p.color = outlineColor;
      canvas.drawRect(Rect.fromLTWH(-500, fy, 1000, 20), p);
      _drawRibbon(
        canvas,
        -380,
        fy - 40,
        fl.level > 0 ? "+${fl.level}" : "${fl.level}",
        t(fl.nameKey),
      );
    }
  }

  void _drawLiftStandard(Canvas canvas, double liftY) {
    double lx = shaftX + 10;
    double lw = shaftW - 20;
    double lh = floorH - 20;
    double drawY = liftY - lh / 2;

    _drawRoundedRect(
      canvas,
      lx,
      drawY,
      lw,
      lh,
      8,
      const Color(0xFFBFDBFE),
      outlineColor,
      4,
    );

    if (scenario == 1 || scenario == 5) {
      _drawKids(canvas, lx + lw / 2, drawY + lh / 2 - 20);
    } else {
      _drawCharacterSVG(
        canvas,
        lx + lw / 2 - 20,
        drawY + lh / 2,
        60,
        false,
        false,
      );
      _drawCharacterSVG(
        canvas,
        lx + lw / 2 + 20,
        drawY + lh / 2,
        60,
        false,
        false,
      );
    }

    bool isHovered =
        (dragEntity == 'plus' || dragEntity == 'minus') &&
        dragPos.dx > lx &&
        dragPos.dx < lx + lw &&
        dragPos.dy > drawY &&
        dragPos.dy < drawY + lh;

    if (isHovered) {
      _drawRoundedRect(
        canvas,
        lx - 5,
        drawY - 5,
        lw + 10,
        lh + 10,
        12,
        Colors.transparent,
        Colors.yellow,
        5,
      );
    }

    _drawLine(
      canvas,
      lx + lw / 2,
      drawY,
      lx + lw / 2,
      drawY + lh,
      outlineColor,
      3,
    );
    _drawRoundedRect(
      canvas,
      lx + lw / 2 - 20,
      drawY - 20,
      40,
      30,
      4,
      const Color(0xFF1E293B),
      outlineColor,
      3,
    );
    int fL = liftFloor.round();
    _drawText(
      canvas,
      fL > 0 ? "+$fL" : "$fL",
      lx + lw / 2,
      drawY - 5,
      Colors.white,
      16,
    );
  }

  void _drawS1Panel(Canvas canvas, double zeroY) {
    double cx = shaftX + shaftW + 60;
    double cy = zeroY - (liftFloor * floorH) - floorH / 2;

    _drawRoundedRect(
      canvas,
      cx - 35,
      cy - 80,
      70,
      160,
      16,
      const Color(0xFFF8FAFC),
      outlineColor,
      4,
    );

    bool isPlusDragged = dragEntity == 'plus';
    _drawButton(canvas, cx, cy - 35, 40, 'plus', isPlusDragged);
    _drawButton(canvas, cx, cy + 35, 40, 'minus', false);
    _drawText(canvas, t('lbl_button_panel'), cx, cy - 90, outlineColor, 10);

    if (isPlusDragged) {
      _drawButton(
        canvas,
        dragPos.dx,
        dragPos.dy,
        40,
        'plus',
        false,
        shadow: true,
      );
    }
  }

  void _drawMinusPanelAndLedger(Canvas canvas, double zeroY) {
    double cx = shaftX + shaftW + 60;
    double cy = zeroY - (liftFloor * floorH) - floorH / 2;

    _drawRoundedRect(
      canvas,
      cx - 35,
      cy - 80,
      70,
      160,
      16,
      const Color(0xFFF8FAFC),
      outlineColor,
      4,
    );

    bool isMinusDragged = dragEntity == 'minus';
    _drawButton(canvas, cx, cy - 35, 40, 'plus', false);
    _drawButton(canvas, cx, cy + 35, 40, 'minus_active', isMinusDragged);
    _drawText(canvas, t('lbl_button_panel'), cx, cy - 90, outlineColor, 10);

    if (isMinusDragged) {
      _drawButton(
        canvas,
        dragPos.dx,
        dragPos.dy,
        40,
        'minus_active',
        false,
        shadow: true,
      );
    }

    double lX = cx - 30;
    double lY = cy + 100;
    _drawRoundedRect(
      canvas,
      lX,
      lY,
      80,
      20 + path.length * 35,
      8,
      const Color(0xFFF8FAFC),
      outlineColor,
      3,
    );
    for (int i = 0; i < path.length; i++) {
      double ty = lY + 20 + i * 35;
      if (i > 0) {
        _drawText(
          canvas,
          t('lbl_drag_minus'),
          lX - 35,
          ty - 15,
          const Color(0xFF475569),
          10,
        );
        _drawArrow(
          canvas,
          lX - 5,
          ty - 25,
          lX - 5,
          ty - 10,
          outlineColor,
          2,
          head: 5,
        );
      }
      _drawRoundedRect(
        canvas,
        lX + 15,
        ty - 10,
        30,
        20,
        4,
        const Color(0xFFCBD5E1),
        outlineColor,
        2,
      );
      _drawText(
        canvas,
        path[i] > 0 ? "+${path[i].round()}" : "${path[i].round()}",
        lX + 30,
        ty,
        outlineColor,
        12,
      );
    }
  }

  void _drawPathVertical(Canvas canvas, double zeroY) {
    double px = shaftX + shaftW + 140;

    if (path.length > 1) {
      double startY = zeroY - (path[0] * floorH) - floorH / 2;
      double currentY = zeroY - (liftFloor * floorH) - floorH / 2;
      Color col = scenario == 1
          ? const Color(0xFF22C55E)
          : const Color(0xFF38BDF8);
      _drawArrow(canvas, px, startY, px, currentY, col, 8, head: 20);

      canvas.save();
      canvas.translate(px + 25, (startY + currentY) / 2);
      canvas.rotate(-pi / 2);
      _drawText(
        canvas,
        t('lbl_path_taken'),
        0,
        0,
        col == const Color(0xFF22C55E)
            ? const Color(0xFF166534)
            : const Color(0xFF0284C7),
        12,
      );
      canvas.restore();
    }

    for (var fl in path) {
      double y = zeroY - fl * floorH - floorH / 2;
      Paint p = Paint()
        ..color = const Color(0xFF1E3A8A)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, y), 18, p);
      p
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(px, y), 18, p);
      _drawText(
        canvas,
        fl > 0 ? "+${fl.round()}" : "${fl.round()}",
        px,
        y,
        Colors.white,
        14,
      );
    }
  }

  void _drawS2Building(Canvas canvas, double zeroY) {
    Paint p = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(const Rect.fromLTWH(-1000, -1000, 2000, 2000), p);

    for (var fl in floorsS2) {
      double fy = zeroY - fl.level * floorH;
      Color leftColor, rightColor;
      if (fl.level == 0) {
        leftColor = const Color(0xFFFEF3C7);
        rightColor = const Color(0xFFFEF3C7);
      } else if (fl.level == -1) {
        leftColor = const Color(0xFF78350F);
        rightColor = const Color(0xFF64748B);
      } else {
        leftColor = const Color(0xFF1E1B4B);
        rightColor = const Color(0xFF1E293B);
      }

      p.color = leftColor;
      canvas.drawRect(
        Rect.fromLTWH(-400, fy - floorH, 400 - shaftX.abs(), floorH),
        p,
      );
      p.color = rightColor;
      canvas.drawRect(
        Rect.fromLTWH(shaftX + shaftW, fy - floorH, 400, floorH),
        p,
      );

      p.color = const Color(0xFF475569);
      canvas.drawRect(Rect.fromLTWH(shaftX, fy - floorH, shaftW, floorH), p);
      p.color = const Color(0xFF334155);
      canvas.drawRect(Rect.fromLTWH(-400, fy, 800, 20), p);

      if (fl.level == -1) {
        p.color = const Color(0xFFB45309);
        canvas.drawRect(Rect.fromLTWH(-350, fy - 80, 200, 80), p);
        p.color = const Color(0xFFD97706);
        canvas.drawRect(Rect.fromLTWH(-340, fy - 60, 50, 50), p);
      } else if (fl.level == -2) {
        p.color = const Color(0xFF020617);
        canvas.drawRect(Rect.fromLTWH(-350, fy - 80, 200, 80), p);
        p.color = const Color(0xFF3B82F6);
        canvas.drawRect(Rect.fromLTWH(-340, fy - 70, 180, 60), p);
      }

      _drawRoundedRect(
        canvas,
        -320,
        fy - floorH + 40,
        100,
        100,
        8,
        const Color(0xFFF8FAFC),
        outlineColor,
        4,
      );
      _drawText(
        canvas,
        "${fl.level}",
        -270,
        fy - floorH + 80,
        outlineColor,
        48,
      );
      _drawText(
        canvas,
        fl.level == 0 ? t("f0_hall") : "${t('lbl_floor')} ${fl.level}",
        -270,
        fy - floorH + 115,
        outlineColor,
        16,
      );

      if (fl.level != 0) {
        _drawRoundedRect(
          canvas,
          -350,
          fy - 40,
          160,
          30,
          4,
          const Color(0xFFF8FAFC),
          outlineColor,
          2,
        );
        _drawText(canvas, t(fl.nameKey), -270, fy - 25, outlineColor, 14);
      }

      _drawRoundedRect(
        canvas,
        shaftX + shaftW / 2 - 35,
        fy - floorH + 20,
        70,
        35,
        4,
        const Color(0xFF020617),
        const Color(0xFF334155),
        3,
      );
      _drawText(
        canvas,
        "${fl.level}",
        shaftX + shaftW / 2,
        fy - floorH + 37.5,
        Colors.redAccent,
        22,
      );
    }
  }

  void _drawS2Lift(Canvas canvas, double liftY) {
    double lx = shaftX;
    double lw = shaftW;
    double lh = floorH - 20;
    double drawY = liftY - floorH + 20;

    _drawRoundedRect(
      canvas,
      lx + 10,
      drawY,
      lw - 20,
      lh,
      0,
      const Color(0xFFE2E8F0),
      const Color(0xFF475569),
      4,
    );
    Paint p = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRect(Rect.fromLTWH(lx + 15, drawY + 5, lw / 2 - 15, lh - 10), p);
    canvas.drawRect(
      Rect.fromLTWH(lx + lw / 2, drawY + 5, lw / 2 - 15, lh - 10),
      p,
    );
    _drawLine(
      canvas,
      lx + lw / 2,
      drawY + 5,
      lx + lw / 2,
      drawY + lh - 5,
      const Color(0xFF475569),
      3,
    );

    bool isHovered =
        (dragEntity == 'minus') &&
        dragPos.dx > lx &&
        dragPos.dx < lx + lw &&
        dragPos.dy > drawY &&
        dragPos.dy < drawY + lh;
    _drawRoundedRect(
      canvas,
      lx + lw / 2 - 25,
      drawY + lh / 2 - 25,
      50,
      50,
      8,
      isHovered ? const Color(0xFFE0E7FF) : const Color(0xFF94A3B8),
      const Color(0xFF64748B),
      3,
    );
    _drawLine(
      canvas,
      lx + lw / 2 - 10,
      drawY + lh / 2,
      lx + lw / 2 + 10,
      drawY + lh / 2,
      const Color(0xFF475569),
      4,
    );
  }

  void _drawS2Panel(Canvas canvas, double zeroY) {
    double cx = shaftX + shaftW + 90;
    double cy = zeroY - (liftFloor * floorH) - floorH / 2;

    _drawRoundedRect(
      canvas,
      cx - 15,
      cy + 30,
      30,
      40,
      0,
      const Color(0xFF94A3B8),
      const Color(0xFF64748B),
      2,
    );
    _drawRoundedRect(
      canvas,
      cx - 40,
      cy - 50,
      80,
      80,
      10,
      const Color(0xFFCBD5E1),
      const Color(0xFF64748B),
      4,
    );
    _drawText(canvas, t('lbl_button_panel'), cx, cy - 60, outlineColor, 12);

    bool isMinusDragged = dragEntity == 'minus';
    _drawButton(canvas, cx, cy - 10, 40, 'minus_active', isMinusDragged);

    if (isMinusDragged) {
      _drawButton(
        canvas,
        dragPos.dx,
        dragPos.dy,
        40,
        'minus_active',
        false,
        shadow: true,
      );
    }
  }

  void _drawS2Path(Canvas canvas, double zeroY) {
    double px = shaftX - 50;
    if (path.length > 1) {
      double startY = zeroY - (path[0] * floorH) - floorH / 2;
      double currentY = zeroY - (liftFloor * floorH) - floorH / 2;
      _drawArrow(
        canvas,
        px,
        startY,
        px,
        currentY,
        const Color(0xFF67E8F9),
        6,
        head: 15,
      );
    }
    for (var fl in path) {
      double py = zeroY - fl * floorH - floorH / 2;
      Paint p = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), 16, p);
      p
        ..color = const Color(0xFF67E8F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(px, py), 16, p);
      _drawText(canvas, "${fl.round()}", px, py, Colors.white, 16);
    }
    if (step >= 2) {
      String pStr =
          "${t('lbl_path_taken')}: ${path.map((e) => e.round().toString()).join(' -> ')}";
      _drawText(canvas, pStr, px + 100, zeroY + 2.5 * floorH, Colors.white, 18);
    }
  }

  void _drawS3Building(Canvas canvas, double zeroY) {
    double bx = -100;
    double bw = 380;
    double bh = 5 * floorH + 60;
    double startY = zeroY - (3 * floorH);

    Paint p = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(const Rect.fromLTWH(-2000, -2000, 4000, 4000), p);

    for (var fl in floorsS3) {
      double fy = zeroY - fl.level * floorH;
      _drawRoundedRect(
        canvas,
        bx - 180,
        fy - floorH / 2 - 30,
        150,
        60,
        8,
        const Color(0xFF1E293B),
        outlineColor,
        3,
      );
      _drawText(
        canvas,
        "${t('lbl_floor')} ${fl.level > 0 ? '+${fl.level}' : fl.level}",
        bx - 105,
        fy - floorH / 2 - 10,
        Colors.white,
        18,
      );
      _drawText(
        canvas,
        t(fl.nameKey),
        bx - 105,
        fy - floorH / 2 + 15,
        const Color(0xFFCBD5E1),
        14,
      );
    }

    _drawRoundedRect(
      canvas,
      bx,
      startY,
      bw,
      bh,
      0,
      const Color(0xFF312E81),
      outlineColor,
      6,
    );
    p.color = const Color(0xFF4338CA);
    canvas.drawRect(Rect.fromLTWH(bx - 20, startY - 20, bw + 40, 20), p);

    for (var fl in floorsS3) {
      double fy = zeroY - fl.level * floorH;
      Color roomColor = const Color(0xFFFEF3C7);
      if (fl.level == 2) {
        roomColor = const Color(0xFFF0FDF4);
      } else if (fl.level == 1) {
        roomColor = const Color(0xFFE0F2FE);
      } else if (fl.level == 0) {
        roomColor = const Color(0xFFFEF08A);
      } else if (fl.level == -1) {
        roomColor = const Color(0xFFBFDBFE);
      } else if (fl.level == -2) {
        roomColor = const Color(0xFFE2E8F0);
      }

      p.color = roomColor;
      canvas.drawRect(
        Rect.fromLTWH(bx + 10, fy - floorH + 10, bw - 20, floorH - 20),
        p,
      );
      _drawLine(canvas, bx, fy, bx + bw, fy, outlineColor, 6);

      if (fl.level == 2) {
        _drawRoundedRect(
          canvas,
          bx + 200,
          fy - 60,
          30,
          50,
          2,
          const Color(0xFFD97706),
          outlineColor,
          2,
        );
        p
          ..color = const Color(0xFFCBD5E1)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(bx + 215, fy - 75), 15, p);
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = outlineColor;
        canvas.drawCircle(Offset(bx + 215, fy - 75), 15, p);
      } else if (fl.level == 1) {
        _drawRoundedRect(
          canvas,
          bx + 100,
          fy - 80,
          80,
          50,
          4,
          const Color(0xFFF8FAFC),
          outlineColor,
          2,
        );
        p
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(bx + 140, fy - 55), 10, p);
      } else if (fl.level == 0) {
        _drawRoundedRect(
          canvas,
          bx + 140,
          fy - 100,
          100,
          100,
          0,
          const Color(0xFF38BDF8),
          outlineColor,
          3,
        );
        _drawLine(canvas, bx + 190, fy - 100, bx + 190, fy, outlineColor, 3);
      } else if (fl.level == -1) {
        _drawRoundedRect(
          canvas,
          bx + 30,
          fy - 50,
          160,
          50,
          0,
          const Color(0xFF3B82F6),
          outlineColor,
          3,
        );
        p
          ..color = const Color(0xFFF43F5E)
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(bx + 60, fy - 70, 20, 20), p);
      } else if (fl.level == -2) {
        _drawRoundedRect(
          canvas,
          bx + 40,
          fy - 70,
          60,
          70,
          4,
          const Color(0xFFB45309),
          outlineColor,
          3,
        );
        _drawRoundedRect(
          canvas,
          bx + 150,
          fy - 50,
          80,
          50,
          4,
          const Color(0xFFB45309),
          outlineColor,
          3,
        );
      }
    }
  }

  void _drawS3Characters(Canvas canvas, double zeroY) {
    double jayY = zeroY - 2 * floorH;
    double amanY = zeroY - (-1) * floorH;
    double jayX = 0;
    double amanX = 150;

    if (s3Hover == 'jay' && step == 0) {
      _drawRoundedRect(
        canvas,
        jayX - 40,
        jayY - 120,
        80,
        120,
        10,
        const Color(0x3322C55E),
        const Color(0xFF22C55E),
        4,
      );
    }
    _drawCharacterSVG(canvas, jayX, jayY - 60, 100, false, true);

    if (s3Hover == 'aman' && step == 0) {
      _drawRoundedRect(
        canvas,
        amanX - 40,
        amanY - 120,
        80,
        120,
        10,
        const Color(0x33EF4444),
        const Color(0xFFEF4444),
        4,
      );
    }
    _drawCharacterSVG(canvas, amanX, amanY - 60, 100, false, false);

    if (step == 0) {
      _drawSpeechBubble(
        canvas,
        t('s3_prompt'),
        jayX + 80,
        jayY - 220,
        300,
        160,
        'left',
        offset: 120,
        border: const Color(0xFF3B82F6),
      );
    }

    if (step >= 1) {
      double startY = amanY - 60;
      double endY = jayY - 20;
      double arrowX = 350;

      _drawArrow(
        canvas,
        arrowX,
        startY,
        arrowX,
        endY,
        const Color(0xFF4ADE80),
        28,
        head: 50,
      );
      _drawRoundedRect(
        canvas,
        arrowX - 45,
        endY - 40,
        90,
        35,
        6,
        const Color(0xFF166534),
        const Color(0xFF064E3B),
        2,
      );
      _drawText(canvas, t('lbl_higher'), arrowX, endY - 22.5, Colors.white, 16);

      _drawRoundedRect(
        canvas,
        arrowX - 45,
        startY + 10,
        90,
        35,
        6,
        const Color(0xFF166534),
        const Color(0xFF064E3B),
        2,
      );
      _drawText(
        canvas,
        t('lbl_lower'),
        arrowX,
        startY + 27.5,
        Colors.white,
        16,
      );

      if (step < 2) {
        _drawSpeechBubble(
          canvas,
          t('s3_correct_msg'),
          0,
          amanY + 30,
          300,
          70,
          'top',
          offset: 150,
          border: const Color(0xFF22C55E),
        );
      }
    }

    if (step >= 2) {
      Paint p = Paint()..color = const Color(0xD9FFFFFF);
      canvas.drawRect(const Rect.fromLTWH(-2000, -2000, 4000, 4000), p);

      _drawLine(canvas, -200, -320, 300, -320, outlineColor, 4);
      _drawArrow(canvas, 280, -320, 300, -320, outlineColor, 4, head: 15);
      _drawArrow(canvas, -180, -320, -200, -320, outlineColor, 4, head: 15);

      for (int n in [-2, -1, 0, 1, 2]) {
        double tx = 50 + n * -80;
        _drawLine(canvas, tx, -325, tx, -315, outlineColor, 4);
        _drawText(canvas, n > 0 ? "+$n" : "$n", tx, -290, outlineColor, 20);
      }

      Path arc = Path();
      arc.moveTo(130, -310);
      arc.quadraticBezierTo(180, -140, -110, -270);
      p
        ..color = const Color(0xFF4ADE80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15;
      canvas.drawPath(arc, p);
      _drawArrow(
        canvas,
        -80,
        -230,
        -110,
        -270,
        const Color(0xFF4ADE80),
        15,
        head: 35,
      );

      _drawRoundedRect(
        canvas,
        -180,
        -220,
        360,
        120,
        16,
        const Color(0xFF6366F1),
        outlineColor,
        4,
      );
      _drawText(canvas, "+2 > -1", 0, -160, Colors.white, 72);

      _drawRoundedRect(
        canvas,
        -250,
        50,
        600,
        120,
        12,
        const Color(0xFFF8FAFC),
        outlineColor,
        4,
      );
      List<String> msgs = t('s3_math_summary').split('\n');
      for (int i = 0; i < msgs.length; i++) {
        _drawText(
          canvas,
          msgs[i],
          50,
          90 + i * 28.0,
          outlineColor,
          18,
          align: TextAlign.center,
        );
      }
    }
  }

  void _drawTargetBox(Canvas canvas, double zeroY, double targetFloor) {
    _drawRoundedRect(
      canvas,
      shaftX + shaftW + 20,
      zeroY - (targetFloor * floorH) - 60,
      100,
      60,
      8,
      const Color(0xFFF8FAFC),
      outlineColor,
      3,
    );
    String tStr = targetFloor == -3 ? t('lbl_s4_target') : t('lbl_s5_target');
    List<String> txts = tStr.split('\n');
    for (int i = 0; i < txts.length; i++) {
      _drawText(
        canvas,
        txts[i],
        shaftX + shaftW + 70,
        zeroY - (targetFloor * floorH) - 40 + i * 20,
        outlineColor,
        14,
      );
    }
  }

  void _drawCheckBtn(Canvas canvas, double x, double y) {
    _drawRoundedRect(
      canvas,
      x - 90,
      y - 25,
      180,
      50,
      10,
      const Color(0xFF22C55E),
      const Color(0xFF14532D),
      4,
    );
    _drawText(canvas, t('lbl_s4_check'), x, y, Colors.white, 16);
  }

  // --- DRAWING UTILS ---
  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
  }

  void _drawArrow(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width, {
    double head = 15,
  }) {
    _drawLine(canvas, x1, y1, x2, y2, color, width);
    double angle = atan2(y2 - y1, x2 - x1);
    Path p = Path();
    p.moveTo(x2, y2);
    p.lineTo(x2 - head * cos(angle - pi / 6), y2 - head * sin(angle - pi / 6));
    p.lineTo(x2 - head * cos(angle + pi / 6), y2 - head * sin(angle + pi / 6));
    p.close();
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (strokeW > 0) {
      canvas.drawRRect(
        rect,
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
    Color color,
    double size, {
    TextAlign align = TextAlign.center,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
          fontFamily: 'sans-serif',
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    double dx = align == TextAlign.center ? x - tp.width / 2 : x;
    double dy = y - tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawSpeechBubble(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    double h,
    String pointDir, {
    double offset = 0,
    Color bg = Colors.white,
    Color border = const Color(0xFF0F172A),
  }) {
    _drawRoundedRect(canvas, x, y, w, h, 10, bg, Colors.transparent, 0);
    Path p = Path();
    if (pointDir == 'left') {
      p.moveTo(x + 3, y + offset);
      p.lineTo(x - 20, y + offset + 10);
      p.lineTo(x + 3, y + offset + 20);
    } else if (pointDir == 'top') {
      p.moveTo(x + offset, y + 3);
      p.lineTo(x + offset + 10, y - 20);
      p.lineTo(x + offset + 20, y + 3);
    }
    p.close();
    canvas.drawPath(
      p,
      Paint()
        ..color = bg
        ..style = PaintingStyle.fill,
    );

    // Border
    RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    Path pStroke = Path();
    if (pointDir == 'left') {
      pStroke.moveTo(x + 3, y + offset);
      pStroke.lineTo(x - 20, y + offset + 10);
      pStroke.lineTo(x + 3, y + offset + 20);
    } else if (pointDir == 'top') {
      pStroke.moveTo(x + offset, y + 3);
      pStroke.lineTo(x + offset + 10, y - 20);
      pStroke.lineTo(x + offset + 20, y + 3);
    }
    canvas.drawPath(
      pStroke,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    _drawText(canvas, text, x + w / 2, y + h / 2, const Color(0xFF0F172A), 16);
  }

  void _drawButton(
    Canvas canvas,
    double x,
    double y,
    double size,
    String type,
    bool isEmpty, {
    bool shadow = false,
  }) {
    double r = size / 2;
    Color bgColor = type == 'plus'
        ? const Color(0xFF6366F1)
        : const Color(0xFFCBD5E1);
    if (type == 'minus_active') bgColor = const Color(0xFF6366F1);

    if (isEmpty) {
      _drawRoundedRect(
        canvas,
        x - r,
        y - r,
        size,
        size,
        8,
        Colors.transparent,
        const Color(0xFF94A3B8),
        4,
      );
      return;
    }

    if (shadow) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - r, y - r, size, size),
          const Radius.circular(8),
        ),
        Paint()
          ..color = bgColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    _drawRoundedRect(
      canvas,
      x - r,
      y - r,
      size,
      size,
      8,
      bgColor,
      outlineColor,
      4,
    );

    Paint iconP = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    double iconS = size * 0.4;
    if (type == 'plus') {
      canvas.drawRect(
        Rect.fromLTWH(x - iconS / 2, y - iconS / 6, iconS, iconS / 3),
        iconP,
      );
      canvas.drawRect(
        Rect.fromLTWH(x - iconS / 6, y - iconS / 2, iconS / 3, iconS),
        iconP,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(x - iconS / 2, y - iconS / 6, iconS, iconS / 3),
        iconP,
      );
    }
  }

  void _drawCharacterSVG(
    Canvas canvas,
    double x,
    double y,
    double size,
    bool isHovered,
    bool isCorrect,
  ) {
    if (isHovered) {
      canvas.drawCircle(
        Offset(x, y),
        size / 2,
        Paint()
          ..color = isCorrect ? Colors.green : Colors.red
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
    Paint p = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y - size / 4), size / 5, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - size / 3, y, size * 2 / 3, size / 2),
        Radius.circular(size / 6),
      ),
      p,
    );
  }

  void _drawKids(Canvas canvas, double x, double y) {
    List<double> kx = [-30, -10, 10, 30];
    List<Color> kCol = [
      const Color(0xFF3B82F6),
      const Color(0xFF22C55E),
      const Color(0xFFF97316),
      const Color(0xFFEF4444),
    ];
    List<double> kH = [50, 60, 55, 65];

    for (int i = 0; i < 4; i++) {
      _drawRoundedRect(
        canvas,
        x + kx[i] - 8,
        y + 10,
        16,
        kH[i] - 10,
        4,
        kCol[i],
        outlineColor,
        2,
      );
      Paint p = Paint()
        ..color = const Color(0xFFFCA5A5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x + kx[i], y + 5), 8, p);
      p
        ..style = PaintingStyle.stroke
        ..color = outlineColor
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(x + kx[i], y + 5), 8, p);
    }
  }

  void _drawRibbon(Canvas canvas, double x, double y, String num, String name) {
    Path p = Path();
    p.moveTo(x, y - 25);
    p.lineTo(x + 80, y - 25);
    p.lineTo(x + 80, y + 25);
    p.lineTo(x, y + 25);
    p.lineTo(x + 20, y);
    p.close();
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF312E81)
        ..style = PaintingStyle.fill,
    );
    _drawText(canvas, num, x + 55, y, Colors.white, 24);
    _drawText(canvas, name, x + 40, y + 45, outlineColor, 14);
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
