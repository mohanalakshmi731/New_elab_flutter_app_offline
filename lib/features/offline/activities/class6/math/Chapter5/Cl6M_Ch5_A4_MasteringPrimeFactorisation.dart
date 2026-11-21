// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch5_A4_MasteringPrimeFactorisation(),
    ),
  );
}

// --- LOCALIZATION DATA ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': 'The Number Breaker Lab: Mastering Prime Factorisation',
    'appTitle': 'Mastering Prime Factorisation',
    'appSubtitle': 'Class 6 • THE NUMBER BREAKER LAB',
    'enterLab': 'Enter Lab',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'doneBtn': 'Done',
    'learnLbl': 'Observations:',
    'closeBtn': 'Close',
    'summaryTitle': 'Goal Reached!',
    'resetBtn': 'Reset Lab',
    'finishLab': 'Finish Lab',
    'nextScenario': 'Next Scenario',
    'finalDesc': 'You have successfully mastered Prime Factorisation!',
    'lbl_smasher': 'SMASHER PAD',
    'lbl_result_tray': 'RESULT TRAY',
    'lbl_combiner': 'COMBINER MACHINE',
    'lbl_break_4x9': 'Break into 4 x 9',
    'lbl_break_6x6': 'Break into 6 x 6',
    'lbl_root': 'ROOT',
    'lbl_check_coprime': 'Check Co-Prime',
    's1_title': '1. The Prime Smasher',
    's1_obj':
        'Understand the basic mechanic of breaking down a composite number into its fundamental prime components.',
    's1_step1_task':
        'DRAG the "12" block from the belt and DROP it onto the central "Smasher Pad".',
    's1_step1_out': 'The "12" block is placed on the pad.',
    's1_step2_task': 'CLICK the large red button with a hammer icon.',
    's1_step2_out':
        'The "12" block breaks into "2" (Prime, glowing) and "6" (Composite).',
    's1_step3_task': 'DRAG the composite "6" block back onto the Smasher Pad.',
    's1_step3_out': 'The "6" block is on the pad.',
    's1_step4_task': 'CLICK the red hammer button again.',
    's1_step4_out':
        'The "6" block breaks into "2" and "3". All blocks are now prime.',
    's1_step5_task': 'DRAG all glowing prime blocks into the "Result Tray".',
    's1_step5_out': '12 = 2 × 2 × 3. You found the prime factors!',
    's1_hud1': 'Drag the "12" block to the Smasher Pad.',
    's1_hud2': 'Tap the Smasher Pad to smash it.',
    's1_hud3': 'Drag the composite "6" to the pad.',
    's1_hud4': 'Tap the Smasher Pad again.',
    's1_hud5': 'Drag all glowing prime blocks to the tray.',
    's2_title': '2. The Two Paths',
    's2_obj':
        'Discover that the prime factorisation of a number is unique, regardless of the factors you start with.',
    's2_step1_task': 'DRAG a "36" block from the belt to each pad.',
    's2_step1_out': 'Both pads hold a "36" block.',
    's2_step2_task':
        'CLICK "Break into 4x9" (Left) and "Break into 6x6" (Right).',
    's2_step2_out': 'Blocks split into initial factors.',
    's2_step3_task':
        'Smash all composite blocks (4, 9, 6, 6) by dropping them on pads and tapping them.',
    's2_step3_out': 'Left has 2,2,3,3. Right has 2,3,2,3.',
    's2_step4_task': 'DRAG all primes to their respective Result Trays.',
    's2_step4_out': 'Both trays show the exact same prime factors: 2, 2, 3, 3.',
    's2_hud1': 'Drag "36" blocks to both pads.',
    's2_hud2': 'Tap the split buttons above the pads.',
    's2_hud3': 'Smash the remaining composite blocks.',
    's2_hud4': 'Drag all primes to the Result Trays.',
    's3_title': '3. The Factorisation Tree',
    's3_obj':
        'Visually organize the process of prime factorisation using a tree structure.',
    's3_step1_task':
        'DRAG the "56" block to the "ROOT" box on the tree canvas.',
    's3_step1_out': '"56" is at the root.',
    's3_step2_task': 'TAP on the "56" block.',
    's3_step2_out': 'It splits into "7" (Prime) and "8" (Composite).',
    's3_step3_task': 'TAP on the composite "8" block.',
    's3_step3_out': 'It splits into "2" and "4".',
    's3_step4_task': 'TAP on the composite "4" block.',
    's3_step4_out': 'It splits into two "2"s. The tree is complete.',
    's3_step5_task':
        'DRAG each glowing leaf block ("7", "2", "2", "2") to the Result Tray.',
    's3_step5_out': '56 = 2 × 2 × 2 × 7.',
    's3_hud1': 'Drag "56" to the ROOT.',
    's3_hud2': 'Tap "56" to branch it.',
    's3_hud3': 'Tap "8" to branch it.',
    's3_hud4': 'Tap "4" to branch it.',
    's3_hud5': 'Drag the glowing prime leaves to the tray.',
    's4_title': '4. The Number Reconstructor',
    's4_obj':
        'Apply the understanding of prime factors by constructing a composite number from its prime components.',
    's4_step1_task': 'DRAG the "3" prime block into the Combiner Machine.',
    's4_step1_out': 'The machine displays "3".',
    's4_step2_task': 'DRAG a "5" block into the machine.',
    's4_step2_out': 'Machine computes 3 × 5 = 15.',
    's4_step3_task': 'DRAG the second "5" block.',
    's4_step3_out': 'Machine computes 15 × 5 = 75.',
    's4_step4_task': 'DRAG the "7" block.',
    's4_step4_out':
        'Machine computes 75 × 7 = 525. Reverse factorisation works!',
    's4_hud1': 'Drag "3" into the Combiner.',
    's4_hud2': 'Drag a "5" into the Combiner.',
    's4_hud3': 'Drag another "5" into the Combiner.',
    's4_hud4': 'Drag "7" into the Combiner.',
    's5_title': '5. The Co-Prime Locksmith',
    's5_obj':
        'Use prime factorisation as a tool to determine if two numbers are co-prime.',
    's5_step1_task':
        'DRAG "40" to the Smasher Pad and smash it to get prime keys.',
    's5_step1_out': '40 transforms into prime keys: 2, 2, 2, 5.',
    's5_step2_task': 'DRAG these keys into Lock A (40).',
    's5_step2_out': 'Lock A is primed.',
    's5_step3_task': 'DRAG "231" to the Smasher Pad and smash it.',
    's5_step3_out': '231 transforms into keys: 3, 7, 11.',
    's5_step4_task': 'DRAG these keys into Lock B (231).',
    's5_step4_out': 'Lock B is primed.',
    's5_step5_task': 'CLICK the "Check Co-Prime" lever.',
    's5_step5_out':
        'No common prime factors found. They are Co-Prime! The chest opens.',
    's5_hud1': 'Smash "40" to get prime keys.',
    's5_hud2': 'Drag the keys to Lock A.',
    's5_hud3': 'Smash "231" to get prime keys.',
    's5_hud4': 'Drag the keys to Lock B.',
    's5_hud5': 'Tap the Check Co-Prime lever.',
  },
  'hi': {
    'shutterTitle':
        'द नंबर ब्रेकर लैब: अभाज्य गुणनखंड (Prime Factorisation) में महारत',
    'appTitle': 'अभाज्य गुणनखंड (Prime Factorisation)',
    'appSubtitle': 'कक्षा 6 • नंबर ब्रेकर लैब',
    'enterLab': 'लैब में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'doneBtn': 'पूर्ण',
    'learnLbl': 'निष्कर्ष:',
    'closeBtn': 'बंद करें',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'resetBtn': 'रीसेट करें',
    'finishLab': 'समाप्त करें',
    'nextScenario': 'अगला परिदृश्य',
    'finalDesc': 'आपने सफलतापूर्वक अभाज्य गुणनखंड में महारत हासिल कर ली है!',
    'lbl_smasher': 'स्मैशर पैड',
    'lbl_result_tray': 'परिणाम ट्रे',
    'lbl_combiner': 'कंबाइनर मशीन',
    'lbl_break_4x9': '4 x 9 में तोड़ें',
    'lbl_break_6x6': '6 x 6 में तोड़ें',
    'lbl_root': 'रूट (ROOT)',
    'lbl_check_coprime': 'सह-अभाज्य (Co-Prime) जांचें',
    's1_title': '1. प्राइम स्मैशर',
    's1_obj':
        'एक भाज्य (composite) संख्या को उसके अभाज्य (prime) घटकों में तोड़ने की मूल प्रक्रिया को समझें।',
    's1_step1_task': 'बेल्ट से "12" ब्लॉक को "स्मैशर पैड" पर खींचें और छोड़ें।',
    's1_step1_out': '"12" ब्लॉक पैड पर है।',
    's1_step2_task': 'हथौड़े के आइकन वाले बड़े लाल बटन पर क्लिक करें।',
    's1_step2_out': '"12" टूटकर "2" (अभाज्य) और "6" (भाज्य) बनता है।',
    's1_step3_task': 'भाज्य "6" ब्लॉक को वापस स्मैशर पैड पर खींचें।',
    's1_step3_out': '"6" ब्लॉक पैड पर है।',
    's1_step4_task': 'हथौड़ा बटन फिर से क्लिक करें।',
    's1_step4_out': '"6" टूटकर "2" और "3" बनता है। सभी ब्लॉक अभाज्य हैं।',
    's1_step5_task': 'सभी चमकते अभाज्य ब्लॉकों को "परिणाम ट्रे" में खींचें।',
    's1_step5_out': '12 = 2 × 2 × 3. आपने अभाज्य गुणनखंड खोज लिए!',
    's1_hud1': '"12" ब्लॉक को स्मैशर पैड पर खींचें।',
    's1_hud2': 'तोड़ने के लिए पैड पर टैप करें।',
    's1_hud3': '"6" को पैड पर खींचें।',
    's1_hud4': 'पैड पर फिर से टैप करें।',
    's1_hud5': 'सभी अभाज्य ब्लॉकों को ट्रे में खींचें।',
    's2_title': '2. दो रास्ते',
    's2_obj':
        'जानें कि किसी संख्या का अभाज्य गुणनखंड हमेशा अद्वितीय (unique) होता है।',
    's2_step1_task': 'बेल्ट से "36" ব্লক को दोनों पैड पर खींचें।',
    's2_step1_out': 'दोनों पैड पर "36" है।',
    's2_step2_task': '"4x9" (बाएं) और "6x6" (दाएं) बटनों पर क्लिक करें।',
    's2_step2_out': 'ब्लॉक प्रारंभिक गुणनखंडों में टूट गए।',
    's2_step3_task':
        'सभी भाज्य ब्लॉकों (4, 9, 6, 6) को पैड पर रखकर हथौड़े से तोड़ें।',
    's2_step3_out': 'बाएं: 2,2,3,3. दाएं: 2,3,2,3.',
    's2_step4_task': 'सभी अभाज्यों को उनकी परिणाम ट्रे में खींचें।',
    's2_step4_out': 'दोनों ट्रे समान अभाज्य गुणनखंड दिखाते हैं: 2, 2, 3, 3.',
    's2_hud1': '"36" ब्लॉकों को पैड पर खींचें।',
    's2_hud2': 'तोड़ने वाले बटनों पर क्लिक करें।',
    's2_hud3': 'शेष भाज्य ब्लॉकों को तोड़ें।',
    's2_hud4': 'सभी अभाज्यों को ट्रे में खींचें।',
    's3_title': '3. गुणनखंड ट्री',
    's3_obj':
        'ट्री संरचना का उपयोग करके अभाज्य गुणनखंडन की प्रक्रिया को व्यवस्थित करें।',
    's3_step1_task': '"56" ब्लॉक को ट्री कैनवस पर "ROOT" बॉक्स में खींचें।',
    's3_step1_out': '"56" रूट पर है।',
    's3_step2_task': '"56" ब्लॉक पर क्लिक करें।',
    's3_step2_out': 'यह "7" (अभाज्य) और "8" (भाज्य) में टूटता है।',
    's3_step3_task': 'भाज्य "8" ब्लॉक पर क्लिक करें।',
    's3_step3_out': 'यह "2" और "4" में टूटता है।',
    's3_step4_task': 'भाज्य "4" ब्लॉक पर क्लिक करें।',
    's3_step4_out': 'यह दो "2" में टूटता है। ट्री पूरा हुआ।',
    's3_step5_task':
        'प्रत्येक चमकते पत्ती (leaf) ब्लॉक को परिणाम ट्रे में खींचें।',
    's3_step5_out': '56 = 2 × 2 × 2 × 7.',
    's3_hud1': '"56" को ROOT पर खींचें।',
    's3_hud2': 'शाखा बनाने के लिए "56" पर टैप करें।',
    's3_hud3': '"8" पर टैप करें।',
    's3_hud4': '"4" पर टैप करें।',
    's3_hud5': 'अभाज्य पत्तियों को ट्रे में खींचें।',
    's4_title': '4. नंबर रिकंस्ट्रक्टर',
    's4_obj': 'अभाज्य घटकों से एक भाज्य संख्या का निर्माण करके समझ लागू करें।',
    's4_step1_task': '"3" अभाज्य ब्लॉक को मशीन में खींचें।',
    's4_step1_out': 'मशीन "3" दिखाती है।',
    's4_step2_task': '"5" ब्लॉक को मशीन में खींचें।',
    's4_step2_out': 'मशीन 3 × 5 = 15 की गणना करती है।',
    's4_step3_task': 'दूसरा "5" ब्लॉक खींचें।',
    's4_step3_out': 'मशीन 15 × 5 = 75 की गणना करती है।',
    's4_step4_task': '"7" ब्लॉक खींचें।',
    's4_step4_out': 'मशीन 75 × 7 = 525. रिवर्स फैक्टरिसेशन काम करता है!',
    's4_hud1': '"3" को मशीन में खींचें।',
    's4_hud2': 'एक "5" को मशीन में खींचें।',
    's4_hud3': 'दूसरे "5" को खींचें।',
    's4_hud4': '"7" को खींचें।',
    's5_title': '5. को-प्राइम लॉकस्मिथ',
    's5_obj':
        'यह निर्धारित करने के लिए कि क्या दो संख्याएं सह-अभाज्य (co-prime) हैं, अभाज्य गुणनखंड का उपयोग करें।',
    's5_step1_task': '"40" को स्मैशर पैड पर खींचें और हथौड़े से तोड़ें।',
    's5_step1_out': '40 अभाज्य चाबियों में बदल जाता है: 2, 2, 2, 5.',
    's5_step2_task': 'इन चाबियों को लॉक A (40) में खींचें।',
    's5_step2_out': 'लॉक A तैयार है।',
    's5_step3_task': '"231" को स्मैशर पैड पर खींचें और हथौड़े से तोड़ें।',
    's5_step3_out': '231 चाबियों में बदल जाता है: 3, 7, 11.',
    's5_step4_task': 'इन चाबियों को लॉक B (231) में खींचें।',
    's5_step4_out': 'लॉक B तैयार है।',
    's5_step5_task': '"सह-अभाज्य जांचें" लीवर पर क्लिक करें।',
    's5_step5_out':
        'कोई सामान्य अभाज्य गुणनखंड नहीं। वे सह-अभाज्य हैं! बॉक्स खुलता है।',
    's5_hud1': '"40" को तोड़कर चाबियां प्राप्त करें।',
    's5_hud2': 'चाबियों को लॉक A में खींचें।',
    's5_hud3': '"231" को तोड़ें।',
    's5_hud4': 'चाबियों को लॉक B में खींचें।',
    's5_hud5': 'लीवर पर टैप करें।',
  },
  'te': {
    'shutterTitle': 'నంబర్ బ్రేకర్ ల్యాబ్: ప్రధాన కారణాంకాల విభజన',
    'appTitle': 'ప్రధాన కారణాంకాల విభజన',
    'appSubtitle': 'క్లాస్ 6 • నంబర్ బ్రేకర్ ల్యాబ్',
    'enterLab': 'ల్యాబ్‌లోకి ప్రవేశించండి',
    'selectScenario': 'సన్నివేశాన్ని ఎంచుకోండి',
    'stepLabel': 'దశ',
    'doneBtn': 'పూర్తయింది',
    'learnLbl': 'పరిశీలనలు:',
    'closeBtn': 'మూసివేయి',
    'summaryTitle': 'లక్ష్యం చేరుకుంది!',
    'resetBtn': 'రీసెట్ చేయండి',
    'finishLab': 'ముగించండి',
    'nextScenario': 'తదుపరి సన్నివేశం',
    'finalDesc': 'మీరు విజయవంతంగా ప్రధాన కారణాంకాల విభజనను నేర్చుకున్నారు!',
    'lbl_smasher': 'స్మాషర్ ప్యాడ్',
    'lbl_result_tray': 'ఫలితాల ట్రే',
    'lbl_combiner': 'కంబైనర్ మెషిన్',
    'lbl_break_4x9': '4 x 9 గా విభజించండి',
    'lbl_break_6x6': '6 x 6 గా విభజించండి',
    'lbl_root': 'రూట్ (ROOT)',
    'lbl_check_coprime': 'కో-ప్రైమ్ (Co-Prime) చెక్',
    's1_title': '1. ప్రైమ్ స్మాషర్',
    's1_obj':
        'సంయుక్త సంఖ్యను దాని ప్రధాన భాగాలుగా విభజించే విధానాన్ని అర్థం చేసుకోండి.',
    's1_step1_task':
        '"12" బ్లాక్‌ను బెల్ట్ నుండి "స్మాషర్ ప్యాడ్" పైకి లాగండి.',
    's1_step1_out': '"12" బ్లాక్ ప్యాడ్ పై ఉంది.',
    's1_step2_task': 'సుత్తి చిహ్నం ఉన్న ఎరుపు బటన్‌ను క్లిక్ చేయండి.',
    's1_step2_out':
        '"12" బ్లాక్ "2" (ప్రధాన) మరియు "6" (సంయుక్త) గా విడిపోతుంది.',
    's1_step3_task': 'సంయుక్త "6" బ్లాక్‌ను తిరిగి స్మాషర్ ప్యాడ్ పైకి లాగండి.',
    's1_step3_out': '"6" ప్యాడ్ పై ఉంది.',
    's1_step4_task': 'మళ్లీ సుత్తి బటన్‌ను క్లిక్ చేయండి.',
    's1_step4_out':
        '"6" బ్లాక్ "2" మరియు "3" గా విడిపోతుంది. అన్నీ ప్రధాన సంఖ్యలే.',
    's1_step5_task':
        'మెరుస్తున్న ప్రధాన బ్లాక్‌లన్నింటినీ "ఫలితాల ట్రే" లోకి లాగండి.',
    's1_step5_out': '12 = 2 × 2 × 3. మీరు ప్రధాన కారణాంకాలను కనుగొన్నారు!',
    's1_hud1': '"12" బ్లాక్‌ను స్మాషర్ ప్యాడ్‌కి లాగండి.',
    's1_hud2': 'పగలగొట్టడానికి ప్యాడ్ పై టాప్ చేయండి.',
    's1_hud3': '"6" ని ప్యాడ్‌కి లాగండి.',
    's1_hud4': 'ప్యాడ్ పై మళ్లీ టాప్ చేయండి.',
    's1_hud5': 'ప్రధాన బ్లాక్‌లను ట్రేలోకి లాగండి.',
    's2_title': '2. రెండు మార్గాలు',
    's2_obj':
        'ఒక సంఖ్య యొక్క ప్రధాన కారణాంకాల విభజన ఎల్లప్పుడూ ప్రత్యేకమైనదని కనుగొనండి.',
    's2_step1_task': '"36" బ్లాక్‌ను రెండు ప్యాడ్‌లపైకి లాగండి.',
    's2_step1_out': 'రెండు ప్యాడ్‌లపై "36" ఉంది.',
    's2_step2_task': '"4x9" (ఎడమ) మరియు "6x6" (కుడి) బటన్‌లను క్లిక్ చేయండి.',
    's2_step2_out': 'బ్లాక్‌లు ప్రారంభ కారణాంకాలుగా విడిపోయాయి.',
    's2_step3_task':
        'మిగిలిన సంయుక్త బ్లాక్‌లన్నింటినీ ప్యాడ్‌లపై ఉంచి పగలగొట్టండి.',
    's2_step3_out': 'ఎడమ: 2,2,3,3. కుడి: 2,3,2,3.',
    's2_step4_task': 'అన్ని ప్రధాన సంఖ్యలను వాటి ట్రేలలోకి లాగండి.',
    's2_step4_out': 'రెండు ట్రేలు ఒకే ప్రధాన కారణాంకాలను చూపుతాయి: 2, 2, 3, 3.',
    's2_hud1': '"36" బ్లాక్‌లను ప్యాడ్‌లకు లాగండి.',
    's2_hud2': 'విభజన బటన్లను క్లిక్ చేయండి.',
    's2_hud3': 'మిగిలిన సంయుక్త బ్లాక్‌లను పగలగొట్టండి.',
    's2_hud4': 'ప్రధాన బ్లాక్‌లను ట్రేలకు లాగండి.',
    's3_title': '3. ఫ్యాక్టరైజేషన్ ట్రీ',
    's3_obj':
        'చెట్టు ఆకృతిని ఉపయోగించి ప్రధాన కారణాంకాల విభజనను దృశ్యమానంగా నిర్వహించండి.',
    's3_step1_task':
        '"56" బ్లాక్‌ను ట్రీ కాన్వాస్‌లోని "ROOT" బాక్స్‌కు లాగండి.',
    's3_step1_out': '"56" రూట్ వద్ద ఉంది.',
    's3_step2_task': '"56" బ్లాక్‌పై క్లిక్ చేయండి.',
    's3_step2_out': 'ఇది "7" మరియు "8" గా విడిపోతుంది.',
    's3_step3_task': '"8" బ్లాక్‌పై క్లిక్ చేయండి.',
    's3_step3_out': 'ఇది "2" మరియు "4" గా విడిపోతుంది.',
    's3_step4_task': '"4" బ్లాక్‌పై క్లిక్ చేయండి.',
    's3_step4_out': 'ఇది రెండు "2" లుగా విడిపోతుంది. ట్రీ పూర్తయింది.',
    's3_step5_task': 'మెరుస్తున్న ప్రతి ఆకు బ్లాక్‌ను ట్రేలోకి లాగండి.',
    's3_step5_out': '56 = 2 × 2 × 2 × 7.',
    's3_hud1': '"56" ని ROOT కు లాగండి.',
    's3_hud2': 'విభజించడానికి "56" పై క్లిక్ చేయండి.',
    's3_hud3': '"8" పై క్లిక్ చేయండి.',
    's3_hud4': '"4" పై క్లిక్ చేయండి.',
    's3_hud5': 'ఆకులను ట్రేలోకి లాగండి.',
    's4_title': '4. నంబర్ రీకన్‌స్ట్రక్టర్',
    's4_obj':
        'ప్రధాన భాగాల నుండి సంయుక్త సంఖ్యను నిర్మించడం ద్వారా అవగాహనను వర్తింపజేయండి.',
    's4_step1_task': '"3" ప్రధాన బ్లాక్‌ను మెషిన్‌లోకి లాగండి.',
    's4_step1_out': 'మెషిన్ "3" ని చూపుతుంది.',
    's4_step2_task': '"5" బ్లాక్‌ను మెషిన్‌లోకి లాగండి.',
    's4_step2_out': 'మెషిన్ 3 × 5 = 15 అని లెక్కిస్తుంది.',
    's4_step3_task': 'రెండవ "5" బ్లాక్‌ను లాగండి.',
    's4_step3_out': 'మెషిన్ 15 × 5 = 75 అని లెక్కిస్తుంది.',
    's4_step4_task': '"7" బ్లాక్‌ను లాగండి.',
    's4_step4_out': 'మెషిన్ 75 × 7 = 525. రివర్స్ ప్రాసెస్ పనిచేస్తుంది!',
    's4_hud1': '"3" ని మెషిన్‌లోకి లాగండి.',
    's4_hud2': 'ఒక "5" ని లాగండి.',
    's4_hud3': 'రెండవ "5" ని లాగండి.',
    's4_hud4': '"7" ని లాగండి.',
    's5_title': '5. కో-ప్రाइम లాక్‌స్మిత్',
    's5_obj':
        'రెండు సంఖ్యలు కో-ప్రైమ్ అని నిర్ధారించడానికి ప్రధాన కారణాంకాలను ఉపయోగించండి.',
    's5_step1_task': '"40" ని స్మాషర్ ప్యాడ్‌పైకి లాగి సుత్తితో కొట్టండి.',
    's5_step1_out': '40 ప్రధాన కీలుగా మారుతుంది: 2, 2, 2, 5.',
    's5_step2_task': 'ఈ కీలను లాక్ A లోకి లాగండి.',
    's5_step2_out': 'లాక్ A సిద్ధంగా ఉంది.',
    's5_step3_task': '"231" ని స్మాషర్ ప్యాడ్‌పైకి లాగి సుత్తితో కొట్టండి.',
    's5_step3_out': '231 కీలుగా మారుతుంది: 3, 7, 11.',
    's5_step4_task': 'ఈ కీలను లాక్ B లోకి లాగండి.',
    's5_step4_out': 'లాక్ B సిద్ధంగా ఉంది.',
    's5_step5_task': '"కో-ప్రైమ్ చెక్" లివర్‌ను క్లిక్ చేయండి.',
    's5_step5_out':
        'సాధారణ ప్రధాన కారణాంకాలు లేవు. అవి కో-ప్రైమ్! పెట్టె తెరుచుకుంటుంది.',
    's5_hud1': 'కీల కోసం "40" ని పగలగొట్టండి.',
    's5_hud2': 'కీలను లాక్ A కి లాగండి.',
    's5_hud3': '"231" ని పగలగొట్టండి.',
    's5_hud4': 'కీలను లాక్ B కి లాగండి.',
    's5_hud5': 'లివర్‌ను క్లిక్ చేయండి.',
  },
};

// --- MODELS ---
class GameEntity {
  String id;
  int val;
  double x;
  double y;
  bool isKey;
  bool leaf;
  String? parent;
  bool active;
  bool split;
  bool inTray;

  GameEntity({
    required this.id,
    required this.val,
    this.x = 0,
    this.y = 0,
    this.isKey = false,
    this.leaf = false,
    this.parent,
    this.active = true,
    this.split = false,
    this.inTray = false,
  });

  GameEntity clone() {
    return GameEntity(
      id: id,
      val: val,
      x: x,
      y: y,
      isKey: isKey,
      leaf: leaf,
      parent: parent,
      active: active,
      split: split,
      inTray: inTray,
    );
  }
}

class SimState {
  GameEntity? activeDragEntity;
  double dragX = 0;
  double dragY = 0;

  // Scenario 1
  List<GameEntity> s1Belt = [GameEntity(id: 'b12', val: 12)];
  GameEntity? s1Pad;
  List<GameEntity> s1Parked = [];
  List<GameEntity> s1Tray = [];

  // Scenario 2
  List<GameEntity> s2BeltL = [GameEntity(id: 'b36L', val: 36)];
  List<GameEntity> s2BeltR = [GameEntity(id: 'b36R', val: 36)];
  GameEntity? s2PadL;
  GameEntity? s2PadR;
  List<GameEntity> s2ParkedL = [];
  List<GameEntity> s2ParkedR = [];
  List<GameEntity> s2TrayL = [];
  List<GameEntity> s2TrayR = [];
  bool s2SplitL = false;
  bool s2SplitR = false;

  // Scenario 3
  List<GameEntity> s3Nodes = [
    GameEntity(
      id: 'n56',
      val: 56,
      x: 0,
      y: -180,
      parent: null,
      active: false,
      leaf: false,
    ),
  ];
  List<GameEntity> s3Tray = [];
  List<GameEntity> s3Belt = [GameEntity(id: 'b56', val: 56)];

  // Scenario 4
  List<GameEntity> s4Primes = [
    GameEntity(id: 'p3', val: 3, x: -250, y: -100),
    GameEntity(id: 'p5a', val: 5, x: -150, y: -100),
    GameEntity(id: 'p5b', val: 5, x: -250, y: 0),
    GameEntity(id: 'p7', val: 7, x: -150, y: 0),
  ];
  List<String> s4Consumed = [];
  int s4Total = 1;

  // Scenario 5
  bool s5ChestOpen = false;
  List<GameEntity> s5Belt40 = [GameEntity(id: 'b40', val: 40)];
  List<GameEntity> s5Belt231 = [GameEntity(id: 'b231', val: 231)];
  GameEntity? s5Pad;
  List<GameEntity> s5Keys = [];
  List<int> s5LockA = [];
  List<int> s5LockB = [];
  double s5ScannerX = -200;
  bool s5Scanning = false;

  void resetScenario(int sc) {
    activeDragEntity = null;
    dragX = 0;
    dragY = 0;
    if (sc == 1) {
      s1Belt = [GameEntity(id: 'b12', val: 12)];
      s1Pad = null;
      s1Parked = [];
      s1Tray = [];
    } else if (sc == 2) {
      s2BeltL = [GameEntity(id: 'b36L', val: 36)];
      s2BeltR = [GameEntity(id: 'b36R', val: 36)];
      s2PadL = null;
      s2PadR = null;
      s2ParkedL = [];
      s2ParkedR = [];
      s2TrayL = [];
      s2TrayR = [];
      s2SplitL = false;
      s2SplitR = false;
    } else if (sc == 3) {
      s3Nodes = [
        GameEntity(
          id: 'n56',
          val: 56,
          x: 0,
          y: -180,
          parent: null,
          active: false,
          leaf: false,
        ),
      ];
      s3Tray = [];
      s3Belt = [GameEntity(id: 'b56', val: 56)];
    } else if (sc == 4) {
      s4Primes = [
        GameEntity(id: 'p3', val: 3, x: -250, y: -100),
        GameEntity(id: 'p5a', val: 5, x: -150, y: -100),
        GameEntity(id: 'p5b', val: 5, x: -250, y: 0),
        GameEntity(id: 'p7', val: 7, x: -150, y: 0),
      ];
      s4Consumed = [];
      s4Total = 1;
    } else if (sc == 5) {
      s5ChestOpen = false;
      s5Belt40 = [GameEntity(id: 'b40', val: 40)];
      s5Belt231 = [GameEntity(id: 'b231', val: 231)];
      s5Pad = null;
      s5Keys = [];
      s5LockA = [];
      s5LockB = [];
      s5ScannerX = -200;
      s5Scanning = false;
    }
  }
}

// --- UTILS ---
bool isPrime(int num) {
  if (num < 2) return false;
  for (int i = 2; i * i <= num; i++) {
    if (num % i == 0) return false;
  }
  return true;
}

// --- MAIN APP WIDGET ---
class Cl6M_Ch5_A4_MasteringPrimeFactorisation extends StatefulWidget {
  const Cl6M_Ch5_A4_MasteringPrimeFactorisation({super.key});

  @override
  State<Cl6M_Ch5_A4_MasteringPrimeFactorisation> createState() =>
      _Cl6M_Ch5_A4_MasteringPrimeFactorisationState();
}

class _Cl6M_Ch5_A4_MasteringPrimeFactorisationState
    extends State<Cl6M_Ch5_A4_MasteringPrimeFactorisation>
    with TickerProviderStateMixin {
  late AnimationController _gameLoop;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;

  String _lang = 'en';
  int _scenario = 1;
  int _step = 0;

  double _zoom = 1.0;
  double _baseZoom = 1.0;
  double _panX = 0;
  double _panY = 0;

  final SimState _simState = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  bool _showSuccessPopup = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(() {
      if (_simState.s5Scanning) {
        setState(() {
          _simState.s5ScannerX += 10;
          if (_simState.s5ScannerX > 200) {
            _simState.s5Scanning = false;
            _simState.s5ChestOpen = true;
            _playSound('success');
            _advanceStep();
            Future.delayed(const Duration(milliseconds: 1000), () {
              setState(() => _showSuccessPopup = true);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) {
    String url = '';
    switch (type) {
      case 'tick':
      case 'snap':
        url = 'audio/class6/math/mixkit_1120.mp3'; // click
        break;
      case 'success':
        url = 'audio/class6/math/mixkit_2015.mp3'; // chime
        break;
      case 'error':
        url = 'audio/class6/science/error.mp3'; // fail
        break;
      case 'pop':
      case 'smash':
        url = 'audio/class6/math/mixkit_1702.mp3'; // smash
        break;
      case 'weld':
        url = 'audio/class6/math/mixkit_900.mp3'; // weld
        break;
    }
    if (url.isNotEmpty) {
      _audioPlayer.play(AssetSource(url), volume: 0.5);
    }
  }

  String t(String key) {
    return translations[_lang]?[key] ?? translations['en']?[key] ?? key;
  }

  void _toggleLang() {
    setState(() {
      if (_lang == 'en')
        _lang = 'hi';
      else if (_lang == 'hi')
        _lang = 'te';
      else
        _lang = 'en';
    });
    _playSound('pop');
  }

  void _loadScenario(int sc) {
    setState(() {
      _scenario = sc;
      _step = 0;
      _simState.resetScenario(sc);
      _showSuccessPopup = false;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
    });
    _playSound('pop');
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _checkSuccess() {
    int maxSteps = (_scenario == 2 || _scenario == 4) ? 4 : 5;
    setState(() {
      _step = maxSteps;
      _showSuccessPopup = true;
    });
  }

  // --- INTERACTION LOGIC ---
  Offset _screenToWorld(Offset localPt, Size size) {
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((localPt.dx - cx) / _zoom, (localPt.dy - cy) / _zoom);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    return (pt.dx - cx) * (pt.dx - cx) + (pt.dy - cy) * (pt.dy - cy) <= r * r;
  }

  void _handleDragStart(Offset worldPt) {
    SimState s = _simState;
    void start(GameEntity e, [bool isKey = false]) {
      setState(() {
        s.activeDragEntity = e.clone()..isKey = isKey;
        s.dragX = worldPt.dx;
        s.dragY = worldPt.dy;
      });
      _playSound('tick');
    }

    if (_scenario == 1) {
      for (var b in s.s1Belt) {
        if (_hitTestBox(-40, -220, 80, 80, worldPt)) {
          start(b);
          return;
        }
      }
      for (var p in s.s1Parked) {
        if (_hitTestBox(p.x - 30, p.y - 30, 60, 60, worldPt)) {
          start(p);
          return;
        }
      }
    } else if (_scenario == 2) {
      for (var b in s.s2BeltL) {
        if (_hitTestBox(-290, -280, 80, 80, worldPt)) {
          start(b);
          return;
        }
      }
      for (var b in s.s2BeltR) {
        if (_hitTestBox(210, -280, 80, 80, worldPt)) {
          start(b);
          return;
        }
      }
      for (var p in s.s2ParkedL) {
        if (_hitTestBox(p.x - 30, p.y - 30, 60, 60, worldPt)) {
          start(p);
          return;
        }
      }
      for (var p in s.s2ParkedR) {
        if (_hitTestBox(p.x - 30, p.y - 30, 60, 60, worldPt)) {
          start(p);
          return;
        }
      }
    } else if (_scenario == 3) {
      for (var b in s.s3Belt) {
        if (_hitTestBox(-280, -310, 80, 80, worldPt)) {
          start(b);
          return;
        }
      }
      for (var n in s.s3Nodes) {
        if (n.active &&
            n.leaf &&
            !n.inTray &&
            _hitTestBox(n.x - 30, n.y - 30, 60, 60, worldPt)) {
          start(n);
          return;
        }
      }
    } else if (_scenario == 4) {
      for (var p in s.s4Primes) {
        if (!s.s4Consumed.contains(p.id) &&
            _hitTestBox(p.x - 30, p.y - 30, 60, 60, worldPt)) {
          start(p);
          return;
        }
      }
    } else if (_scenario == 5) {
      for (var b in s.s5Belt40) {
        if (_hitTestBox(-230, 20, 80, 80, worldPt)) {
          start(b);
          return;
        }
      }
      for (var b in s.s5Belt231) {
        if (_hitTestBox(150, 20, 80, 80, worldPt)) {
          start(b);
          return;
        }
      }
      for (var k in s.s5Keys) {
        if (_hitTestBox(k.x - 30, k.y - 30, 60, 60, worldPt)) {
          start(k, true);
          return;
        }
      }
    }
  }

  void _handleDragEnd(Offset worldPt) {
    SimState s = _simState;
    if (s.activeDragEntity == null) return;
    GameEntity e = s.activeDragEntity!;
    bool hit = false;

    if (_scenario == 1) {
      if (_hitTestCircle(0, 50, 60, worldPt)) {
        if (e.id == 'b12') {
          s.s1Belt.clear();
          s.s1Pad = e;
          hit = true;
          if (_step == 0) _advanceStep();
        } else if (!isPrime(e.val)) {
          s.s1Parked.removeWhere((p) => p.id == e.id);
          s.s1Pad = e;
          hit = true;
          if (_step == 2) _advanceStep();
        }
      } else if (_hitTestBox(-175, 230, 350, 80, worldPt) && isPrime(e.val)) {
        s.s1Parked.removeWhere((p) => p.id == e.id);
        s.s1Tray.add(e);
        hit = true;
        if (s.s1Tray.length == 3 && _step == 4) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
          _playSound('success');
        }
      }
    } else if (_scenario == 2) {
      bool padL = _hitTestCircle(-250, -20, 60, worldPt);
      bool padR = _hitTestCircle(250, -20, 60, worldPt);
      bool trayL = _hitTestBox(-400, 150, 300, 80, worldPt);
      bool trayR = _hitTestBox(100, 150, 300, 80, worldPt);

      if (padL && e.id == 'b36L') {
        s.s2BeltL.clear();
        s.s2PadL = e;
        hit = true;
      } else if (padR && e.id == 'b36R') {
        s.s2BeltR.clear();
        s.s2PadR = e;
        hit = true;
      } else if (padL && !isPrime(e.val) && e.id.contains('L')) {
        s.s2ParkedL.removeWhere((p) => p.id == e.id);
        s.s2PadL = e;
        hit = true;
      } else if (padR && !isPrime(e.val) && e.id.contains('R')) {
        s.s2ParkedR.removeWhere((p) => p.id == e.id);
        s.s2PadR = e;
        hit = true;
      } else if (trayL && isPrime(e.val) && e.id.contains('L')) {
        s.s2ParkedL.removeWhere((p) => p.id == e.id);
        s.s2TrayL.add(e);
        hit = true;
      } else if (trayR && isPrime(e.val) && e.id.contains('R')) {
        s.s2ParkedR.removeWhere((p) => p.id == e.id);
        s.s2TrayR.add(e);
        hit = true;
      }

      if (_step == 0 && s.s2PadL != null && s.s2PadR != null) _advanceStep();
      if (_step == 3 && s.s2TrayL.length == 4 && s.s2TrayR.length == 4) {
        s.s2TrayL.sort((a, b) => a.val.compareTo(b.val));
        s.s2TrayR.sort((a, b) => a.val.compareTo(b.val));
        _advanceStep();
        Future.delayed(const Duration(seconds: 1), _checkSuccess);
        _playSound('success');
      }
    } else if (_scenario == 3) {
      if (e.id == 'b56' && _hitTestBox(-60, -220, 120, 40, worldPt)) {
        s.s3Belt.clear();
        s.s3Nodes[0].active = true;
        hit = true;
        if (_step == 0) _advanceStep();
      } else if (e.leaf && _hitTestBox(-200, 150, 400, 80, worldPt)) {
        var node = s.s3Nodes.firstWhere((n) => n.id == e.id);
        node.inTray = true;
        s.s3Tray.add(e);
        hit = true;
        if (s.s3Tray.length == 4 && _step == 4) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
          _playSound('success');
        }
      }
    } else if (_scenario == 4) {
      if (_hitTestBox(100 - 80, -100, 160, 50, worldPt)) {
        s.s4Consumed.add(e.id);
        s.s4Total *= e.val;
        hit = true;
        _playSound('weld');
        if (_step == 0 && e.id == 'p3')
          _advanceStep();
        else if (_step == 1 && e.val == 5)
          _advanceStep();
        else if (_step == 2 && e.val == 5)
          _advanceStep();
        else if (_step == 3 && e.val == 7) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
          _playSound('success');
        }
      }
    } else if (_scenario == 5) {
      bool p = _hitTestCircle(0, 120, 60, worldPt);
      bool lockA = _hitTestBox(-130, -180, 120, 100, worldPt);
      bool lockB = _hitTestBox(10, -180, 120, 100, worldPt);

      if (p && e.id == 'b40') {
        s.s5Belt40.clear();
        s.s5Pad = e;
        hit = true;
      } else if (p && e.id == 'b231') {
        s.s5Belt231.clear();
        s.s5Pad = e;
        hit = true;
      } else if (lockA && e.id.contains('k40')) {
        s.s5Keys.removeWhere((k) => k.id == e.id);
        s.s5LockA.add(e.val);
        hit = true;
        if (s.s5LockA.length == 4 && _step == 1) _advanceStep();
      } else if (lockB && e.id.contains('k231')) {
        s.s5Keys.removeWhere((k) => k.id == e.id);
        s.s5LockB.add(e.val);
        hit = true;
        if (s.s5LockB.length == 3 && _step == 3) _advanceStep();
      }
    }

    if (hit && _scenario != 4)
      _playSound('snap');
    else if (!hit)
      _playSound('error');

    setState(() {
      s.activeDragEntity = null;
    });
  }

  void _handleCanvasTap(Offset worldPt) {
    SimState s = _simState;

    if (_scenario == 1) {
      if ((_hitTestCircle(0, 50, 60, worldPt) ||
              _hitTestBox(90, 30, 60, 60, worldPt)) &&
          s.s1Pad != null) {
        _playSound('smash');
        int v = s.s1Pad!.val;
        s.s1Pad = null;
        if (v == 12) {
          s.s1Parked.addAll([
            GameEntity(id: 'p2a', val: 2, x: -90, y: 50),
            GameEntity(id: 'p6', val: 6, x: 90, y: 50),
          ]);
        }
        if (v == 6) {
          s.s1Parked.addAll([
            GameEntity(id: 'p2b', val: 2, x: 90, y: -30),
            GameEntity(id: 'p3', val: 3, x: 90, y: 50),
          ]);
        }
        setState(() {
          if (_step == 1 || _step == 3) _advanceStep();
        });
      }
    } else if (_scenario == 2) {
      if (_step == 1) {
        if (_hitTestBox(-320, -120, 140, 40, worldPt) &&
            s.s2PadL != null &&
            s.s2PadL!.val == 36) {
          s.s2PadL = null;
          s.s2SplitL = true;
          _playSound('pop');
          s.s2ParkedL.addAll([
            GameEntity(id: 'p4L', val: 4, x: -320, y: -30),
            GameEntity(id: 'p9L', val: 9, x: -180, y: -30),
          ]);
        }
        if (_hitTestBox(180, -120, 140, 40, worldPt) &&
            s.s2PadR != null &&
            s.s2PadR!.val == 36) {
          s.s2PadR = null;
          s.s2SplitR = true;
          _playSound('pop');
          s.s2ParkedR.addAll([
            GameEntity(id: 'p6Ra', val: 6, x: 180, y: -30),
            GameEntity(id: 'p6Rb', val: 6, x: 320, y: -30),
          ]);
        }
        if (s.s2SplitL && s.s2SplitR) setState(() => _advanceStep());
      }
      if ((_hitTestCircle(-250, -20, 60, worldPt) ||
              _hitTestBox(-180, -50, 60, 60, worldPt)) &&
          s.s2PadL != null &&
          s.s2PadL!.val != 36) {
        int v = s.s2PadL!.val;
        s.s2PadL = null;
        _playSound('smash');
        if (v == 4)
          s.s2ParkedL.addAll([
            GameEntity(id: 'p2L1', val: 2, x: -320, y: 60),
            GameEntity(id: 'p2L2', val: 2, x: -180, y: 60),
          ]);
        if (v == 9)
          s.s2ParkedL.addAll([
            GameEntity(id: 'p3L1', val: 3, x: -320, y: 60),
            GameEntity(id: 'p3L2', val: 3, x: -180, y: 60),
          ]);
      }
      if ((_hitTestCircle(250, -20, 60, worldPt) ||
              _hitTestBox(320, -50, 60, 60, worldPt)) &&
          s.s2PadR != null &&
          s.s2PadR!.val != 36) {
        int v = s.s2PadR!.val;
        s.s2PadR = null;
        _playSound('smash');
        if (v == 6) {
          String suff = s.s2ParkedR.length < 2 ? "1" : "2";
          s.s2ParkedR.addAll([
            GameEntity(id: 'p2R$suff', val: 2, x: 180, y: 60),
            GameEntity(id: 'p3R$suff', val: 3, x: 320, y: 60),
          ]);
        }
      }
      if (_step == 2 && s.s2ParkedL.length == 4 && s.s2ParkedR.length == 4)
        setState(() => _advanceStep());
    } else if (_scenario == 3) {
      for (var n in s.s3Nodes) {
        if (n.active &&
            !n.split &&
            !isPrime(n.val) &&
            _hitTestBox(n.x - 30, n.y - 30, 60, 60, worldPt)) {
          _playSound('pop');
          n.split = true;
          if (n.val == 56) {
            s.s3Nodes.addAll([
              GameEntity(
                id: 'n7',
                val: 7,
                x: -100,
                y: -80,
                parent: n.id,
                active: true,
                leaf: true,
              ),
              GameEntity(
                id: 'n8',
                val: 8,
                x: 100,
                y: -80,
                parent: n.id,
                active: true,
                leaf: false,
              ),
            ]);
            if (_step == 1) setState(() => _advanceStep());
          } else if (n.val == 8) {
            s.s3Nodes.addAll([
              GameEntity(
                id: 'n2a',
                val: 2,
                x: 40,
                y: 20,
                parent: n.id,
                active: true,
                leaf: true,
              ),
              GameEntity(
                id: 'n4',
                val: 4,
                x: 160,
                y: 20,
                parent: n.id,
                active: true,
                leaf: false,
              ),
            ]);
            if (_step == 2) setState(() => _advanceStep());
          } else if (n.val == 4) {
            s.s3Nodes.addAll([
              GameEntity(
                id: 'n2b',
                val: 2,
                x: 100,
                y: 120,
                parent: n.id,
                active: true,
                leaf: true,
              ),
              GameEntity(
                id: 'n2c',
                val: 2,
                x: 220,
                y: 120,
                parent: n.id,
                active: true,
                leaf: true,
              ),
            ]);
            if (_step == 3) setState(() => _advanceStep());
          }
        }
      }
    } else if (_scenario == 5) {
      if ((_hitTestCircle(0, 120, 60, worldPt) ||
              _hitTestBox(70, 70, 60, 60, worldPt)) &&
          s.s5Pad != null) {
        _playSound('smash');
        int v = s.s5Pad!.val;
        s.s5Pad = null;
        if (v == 40) {
          s.s5Keys.addAll([
            GameEntity(id: 'k40a', val: 2, x: -90, y: 180),
            GameEntity(id: 'k40b', val: 2, x: -30, y: 180),
            GameEntity(id: 'k40c', val: 2, x: 30, y: 180),
            GameEntity(id: 'k40d', val: 5, x: 90, y: 180),
          ]);
          if (_step == 0) setState(() => _advanceStep());
        }
        if (v == 231) {
          s.s5Keys.addAll([
            GameEntity(id: 'k231a', val: 3, x: -60, y: 180),
            GameEntity(id: 'k231b', val: 7, x: 0, y: 180),
            GameEntity(id: 'k231c', val: 11, x: 60, y: 180),
          ]);
          if (_step == 2) setState(() => _advanceStep());
        }
      }
      if (_step == 4 && _hitTestBox(-80, -260, 160, 40, worldPt)) {
        setState(() {
          s.s5Scanning = true;
          s.s5ScannerX = -200;
        });
        _playSound('weld');
      }
    }
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    int maxSteps = (_scenario == 2 || _scenario == 4) ? 4 : 5;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapUp: (details) {
                        if (_simState.activeDragEntity == null) {
                          RenderBox box =
                              _canvasKey.currentContext?.findRenderObject()
                                  as RenderBox;
                          Offset local = box.globalToLocal(
                            details.globalPosition,
                          );
                          Offset worldPt = _screenToWorld(
                            local,
                            constraints.biggest,
                          );
                          _handleCanvasTap(worldPt);
                        }
                      },
                      onScaleStart: (details) {
                        _baseZoom = _zoom;
                        RenderBox box =
                            _canvasKey.currentContext?.findRenderObject()
                                as RenderBox;
                        Offset local = box.globalToLocal(details.focalPoint);
                        Offset worldPt = _screenToWorld(
                          local,
                          constraints.biggest,
                        );
                        _handleDragStart(worldPt);
                      },
                      onScaleUpdate: (details) {
                        if (_simState.activeDragEntity != null) {
                          RenderBox box =
                              _canvasKey.currentContext?.findRenderObject()
                                  as RenderBox;
                          Offset local = box.globalToLocal(details.focalPoint);
                          Offset worldPt = _screenToWorld(
                            local,
                            constraints.biggest,
                          );
                          setState(() {
                            _simState.dragX = worldPt.dx;
                            _simState.dragY = worldPt.dy;
                          });
                        } else {
                          setState(() {
                            _panX += details.focalPointDelta.dx;
                            _panY += details.focalPointDelta.dy;
                            if (details.scale != 1.0) {
                              _zoom = (_baseZoom * details.scale).clamp(
                                0.4,
                                3.0,
                              );
                            }
                          });
                        }
                      },
                      onScaleEnd: (details) {
                        if (_simState.activeDragEntity != null) {
                          Offset worldPt = Offset(
                            _simState.dragX,
                            _simState.dragY,
                          );
                          _handleDragEnd(worldPt);
                        }
                      },
                      child: Container(
                        key: _canvasKey,
                        color: const Color(0xFF0F172A), // Dark bg
                        child: AnimatedBuilder(
                          animation: _gameLoop,
                          builder: (context, _) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: GamePainter(
                                state: _simState,
                                scenario: _scenario,
                                step: _step,
                                panX: _panX,
                                panY: _panY,
                                zoom: _zoom,
                                t: t,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // HUD overlay (moves with canvas)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              bottom: 40,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: (_step < maxSteps) ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: Color(0xFFA855F7), width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFA855F7),
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              t('s${_scenario}_hud${_step + 1}'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Fully Scrollable Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              child: Container(
                width: _sidebarWidth,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white12, width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header inside sidebar
                          Container(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 66,
                              bottom: 16,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.hexagon_outlined,
                                      color: Color(0xFFA855F7),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t('appTitle'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t('appSubtitle'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: _toggleLang,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _lang.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () => _loadScenario(1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.refresh,
                                              color: Colors.redAccent,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Reset',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('selectScenario').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _scenario,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF1E293B),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      items: List.generate(5, (index) {
                                        int sc = index + 1;
                                        return DropdownMenuItem(
                                          value: sc,
                                          child: Text(t('s${sc}_title')),
                                        );
                                      }),
                                      onChanged: (v) {
                                        if (v != null) _loadScenario(v);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF334155,
                                    ).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.track_changes,
                                            color: Colors.pinkAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            t('learnLbl'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t('s${_scenario}_obj'),
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
                                ...List.generate(maxSteps, (i) {
                                  bool isCompleted = i < _step;
                                  bool isCurrent = i == _step;
                                  bool isFuture = i > _step;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? const Color(
                                              0xFFA855F7,
                                            ).withOpacity(0.15)
                                          : (isCompleted
                                                ? Colors.green.withOpacity(0.05)
                                                : Colors.white.withOpacity(
                                                    0.02,
                                                  )),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCurrent
                                            ? const Color(0xFFA855F7)
                                            : (isCompleted
                                                  ? Colors.green.withOpacity(
                                                      0.3,
                                                    )
                                                  : Colors.white12),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isCompleted)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 24,
                                          )
                                        else
                                          Container(
                                            width: 24,
                                            height: 24,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isCurrent
                                                  ? const Color(0xFFA855F7)
                                                  : Colors.white24,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${i + 1}',
                                              style: TextStyle(
                                                color: isFuture
                                                    ? Colors.white54
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${t("stepLabel")} ${i + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                t(
                                                  's${_scenario}_step${i + 1}_task',
                                                ),
                                                style: TextStyle(
                                                  color: isFuture
                                                      ? Colors.white38
                                                      : (isCurrent
                                                            ? Colors.white
                                                            : Colors.white70),
                                                  fontSize: 14,
                                                  fontWeight: isCurrent
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              if (isCompleted) ...[
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    t(
                                                      's${_scenario}_step${i + 1}_out',
                                                    ),
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
                              ],
                            ),
                          ),
                          // Expanded Spacer to push the footer to the bottom
                          const Spacer(),
                          // Footer
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: const Color(0xFF020617),
                            alignment: Alignment.center,
                            child: const Text(
                              '© ZeroScienceLab - Fall in love with math and Science',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
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

            // Sidebar Resizer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: _isSidebarOpen ? _sidebarWidth - 5 : -10,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  if (!_isSidebarOpen) return;
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    _sidebarWidth = _sidebarWidth.clamp(
                      300.0,
                      MediaQuery.of(context).size.width * 0.6,
                    );
                  });
                },
                child: Container(
                  width: 15,
                  color: Colors
                      .transparent, // Invisible drag handle over the border
                  alignment: Alignment.center,
                  child: Container(width: 2, height: 40, color: Colors.white38),
                ),
              ),
            ),

            // Floating Menu Toggle Button
            Positioned(
              top: 16,
              left: 16,
              child: InkWell(
                onTap: () {
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                  _playSound('tick');
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Next Scenario Button / Overlay
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.greenAccent,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _scenario == 5
                                ? t('finalDesc')
                                : 'Great job! Ready for the next challenge?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA855F7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                _loadScenario(1);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _scenario < 5
                                      ? t('nextScenario')
                                      : t('finishLab'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _scenario < 5
                                      ? Icons.arrow_forward
                                      : Icons.flag,
                                  color: Colors.white,
                                ),
                              ],
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.hexagon_outlined,
                            color: Color(0xFFA855F7),
                            size: 100,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('shutterTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA855F7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                            ),
                            onPressed: () {
                              setState(() => _isCurtainOpen = true);
                              _playSound('success');
                            },
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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
          ],
        ),
      ),
    );
  }
}

// --- PAINTER ---
class GamePainter extends CustomPainter {
  final SimState state;
  final int scenario;
  final int step;
  final double panX;
  final double panY;
  final double zoom;
  final String Function(String) t;

  GamePainter({
    required this.state,
    required this.scenario,
    required this.step,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1)
      _renderScenario1(canvas);
    else if (scenario == 2)
      _renderScenario2(canvas);
    else if (scenario == 3)
      _renderScenario3(canvas);
    else if (scenario == 4)
      _renderScenario4(canvas);
    else if (scenario == 5)
      _renderScenario5(canvas);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    // The animation loop continuously drives state changes, so we return true.
    return true;
  }

  void _renderScenario1(Canvas canvas) {
    _drawConveyor(canvas, -100, -150, 200);
    for (var b in state.s1Belt) {
      if (state.activeDragEntity?.id != b.id)
        _drawNumberBlock(canvas, 0, -190, b.val);
    }

    bool padActive =
        state.s1Pad != null ||
        (state.activeDragEntity != null &&
            _hitTestBox(-80, 30, 160, 80, Offset(state.dragX, state.dragY)));
    _drawSmasherPad(canvas, 0, 50, 1.2, padActive);
    if (state.s1Pad != null) _drawNumberBlock(canvas, 0, 40, state.s1Pad!.val);

    _drawHammerBtn(canvas, 120, 60, 0);

    for (var p in state.s1Parked) {
      if (state.activeDragEntity?.id != p.id)
        _drawNumberBlock(canvas, p.x, p.y, p.val);
    }

    _drawResultTray(canvas, 0, 230, 350, state.s1Tray);

    if (state.activeDragEntity != null) {
      _drawNumberBlock(
        canvas,
        state.dragX,
        state.dragY,
        state.activeDragEntity!.val,
        1,
        state.activeDragEntity!.isKey,
      );
    }
  }

  void _renderScenario2(Canvas canvas) {
    void renderSide(
      bool isLeft,
      GameEntity? pad,
      List<GameEntity> parked,
      List<GameEntity> tray,
      List<GameEntity> belt,
      bool splitState,
    ) {
      double cx = isLeft ? -250 : 250;
      _drawConveyor(canvas, cx - 80, -200, 160);
      for (var b in belt) {
        if (state.activeDragEntity?.id != b.id)
          _drawNumberBlock(canvas, cx, -240, b.val, 0.8);
      }

      _drawSmasherPad(canvas, cx, -20, 1, pad != null);
      if (pad != null) _drawNumberBlock(canvas, cx, -30, pad.val, 0.8);
      _drawHammerBtn(canvas, cx + 100, -20, 0);

      if (!splitState &&
          step == 1 &&
          belt.isEmpty &&
          pad != null &&
          pad.val == 36) {
        _drawRoundedRect(
          canvas,
          cx - 70,
          -120,
          140,
          40,
          8,
          const Color(0xFF3B82F6),
          const Color(0xFF0F172A),
          3,
        );
        _drawText(
          canvas,
          isLeft ? t('lbl_break_4x9') : t('lbl_break_6x6'),
          cx,
          -100,
          14,
          Colors.white,
          bold: true,
        );
      }

      for (var p in parked) {
        if (state.activeDragEntity?.id != p.id)
          _drawNumberBlock(canvas, p.x, p.y, p.val, 0.8);
      }
      _drawResultTray(canvas, cx, 150, 300, tray);
    }

    renderSide(
      true,
      state.s2PadL,
      state.s2ParkedL,
      state.s2TrayL,
      state.s2BeltL,
      state.s2SplitL,
    );
    renderSide(
      false,
      state.s2PadR,
      state.s2ParkedR,
      state.s2TrayR,
      state.s2BeltR,
      state.s2SplitR,
    );

    _drawLine(
      canvas,
      0,
      -250,
      0,
      250,
      const Color(0xFF0F172A),
      2,
      dashed: true,
    );

    if (state.activeDragEntity != null) {
      _drawNumberBlock(
        canvas,
        state.dragX,
        state.dragY,
        state.activeDragEntity!.val,
        0.8,
      );
    }
  }

  void _renderScenario3(Canvas canvas) {
    _drawConveyor(canvas, -300, -230, 120);
    for (var b in state.s3Belt) {
      if (state.activeDragEntity?.id != b.id)
        _drawNumberBlock(canvas, -240, -270, b.val);
    }

    _drawRoundedRect(
      canvas,
      -60,
      -220,
      120,
      40,
      4,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      t('lbl_root'),
      0,
      -200,
      14,
      const Color(0xFF64748B),
      bold: true,
    );

    for (var n in state.s3Nodes) {
      if (n.parent != null) {
        var p = state.s3Nodes.firstWhere(
          (element) => element.id == n.parent,
          orElse: () => GameEntity(id: '', val: 0),
        );
        if (p.id.isNotEmpty && n.active)
          _drawLine(
            canvas,
            p.x,
            p.y + 30,
            n.x,
            n.y - 30,
            const Color(0xFF0F172A),
            4,
          );
      }
    }

    for (var n in state.s3Nodes) {
      if (n.active && !n.inTray && (state.activeDragEntity?.id != n.id)) {
        if (n.split)
          canvas.saveLayer(
            null,
            Paint()..color = Colors.white.withOpacity(0.5),
          );
        _drawNumberBlock(canvas, n.x, n.y, n.val, 0.9);
        if (n.split) canvas.restore();
      }
    }

    _drawResultTray(canvas, 0, 150, 400, state.s3Tray);

    if (state.activeDragEntity != null) {
      _drawNumberBlock(
        canvas,
        state.dragX,
        state.dragY,
        state.activeDragEntity!.val,
        0.9,
      );
    }
  }

  void _renderScenario4(Canvas canvas) {
    for (var p in state.s4Primes) {
      if (!state.s4Consumed.contains(p.id) &&
          state.activeDragEntity?.id != p.id) {
        _drawNumberBlock(canvas, p.x, p.y, p.val, 0.9);
      }
    }
    _drawCombinerMachine(canvas, 100, 0, state.s4Total);
    if (state.activeDragEntity != null) {
      _drawNumberBlock(
        canvas,
        state.dragX,
        state.dragY,
        state.activeDragEntity!.val,
        0.9,
      );
    }
  }

  void _renderScenario5(Canvas canvas) {
    _drawChest(canvas, 0, -150, state.s5ChestOpen);
    _drawLock(canvas, -70, -130, 40, 4, state.s5LockA);
    _drawLock(canvas, 70, -130, 231, 3, state.s5LockB);

    double cx = 0;
    double cy = 120;
    _drawConveyor(canvas, cx - 250, cy - 20, 120);
    for (var b in state.s5Belt40) {
      if (state.activeDragEntity?.id != b.id)
        _drawNumberBlock(canvas, cx - 190, cy - 60, b.val, 0.8);
    }
    _drawConveyor(canvas, cx + 130, cy - 20, 120);
    for (var b in state.s5Belt231) {
      if (state.activeDragEntity?.id != b.id)
        _drawNumberBlock(canvas, cx + 190, cy - 60, b.val, 0.8);
    }

    _drawSmasherPad(canvas, cx, cy, 1, state.s5Pad != null);
    if (state.s5Pad != null)
      _drawNumberBlock(canvas, cx, cy - 10, state.s5Pad!.val, 0.8);
    _drawHammerBtn(canvas, cx + 100, cy - 20, 0);

    for (var k in state.s5Keys) {
      if (state.activeDragEntity?.id != k.id)
        _drawNumberBlock(canvas, k.x, k.y, k.val, 0.8, true);
    }

    if (step >= 4 && !state.s5ChestOpen) {
      _drawRoundedRect(
        canvas,
        -80,
        -260,
        160,
        40,
        8,
        const Color(0xFF3B82F6),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        t('lbl_check_coprime'),
        0,
        -240,
        16,
        Colors.white,
        bold: true,
      );
    }

    if (state.s5Scanning) {
      canvas.drawRect(
        Rect.fromLTWH(state.s5ScannerX, -200, 20, 150),
        Paint()
          ..color = const Color(0x8038BDF8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    if (state.activeDragEntity != null) {
      _drawNumberBlock(
        canvas,
        state.dragX,
        state.dragY,
        state.activeDragEntity!.val,
        0.8,
        state.activeDragEntity!.isKey,
      );
    }
  }

  // --- DRAWING UTILS ---
  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double dashWidth = 8, dashSpace = 8;
      double distance = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
      double dx = (x2 - x1) / distance;
      double dy = (y2 - y1) / distance;
      double currX = x1, currY = y1;
      while (math.sqrt(math.pow(currX - x1, 2) + math.pow(currY - y1, 2)) <
          distance) {
        canvas.drawLine(
          Offset(currX, currY),
          Offset(currX + dx * dashWidth, currY + dy * dashWidth),
          paint,
        );
        currX += dx * (dashWidth + dashSpace);
        currY += dy * (dashWidth + dashSpace);
      }
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
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
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill.alpha > 0)
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    if (stroke.alpha > 0 && strokeW > 0)
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke,
      );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double size,
    Color color, {
    bool bold = false,
    Color stroke = Colors.transparent,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();

    if (stroke != Colors.transparent) {
      TextPainter tpStroke = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = stroke,
            fontSize: size,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tpStroke.layout();
      tpStroke.paint(
        canvas,
        Offset(x - tpStroke.width / 2, y - tpStroke.height / 2),
      );
    }

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawNumberBlock(
    Canvas canvas,
    double x,
    double y,
    int val, [
    double scale = 1,
    bool isKey = false,
  ]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    bool prime = isPrime(val);
    double s = 60;

    if (isKey) {
      Color fill = prime ? const Color(0xFFD8B4FE) : const Color(0xFFCBD5E1);
      Color stroke = prime ? const Color(0xFF7E22CE) : const Color(0xFF334155);

      Paint pFill = Paint()..color = fill;
      if (prime)
        pFill.maskFilter = const MaskFilter.blur(
          BlurStyle.solid,
          5,
        ); // Glow effect approx
      Paint pStroke = Paint()
        ..color = stroke
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(const Offset(-20, 0), 15, pFill);
      canvas.drawRect(const Rect.fromLTWH(-10, -5, 40, 10), pFill);
      canvas.drawRect(const Rect.fromLTWH(15, 5, 5, 10), pFill);
      canvas.drawRect(const Rect.fromLTWH(25, 5, 5, 10), pFill);

      canvas.drawCircle(const Offset(-20, 0), 15, pStroke);
      canvas.drawLine(const Offset(-10, -5), const Offset(30, -5), pStroke);
      canvas.drawLine(const Offset(-10, 5), const Offset(15, 5), pStroke);

      _drawText(
        canvas,
        val.toString(),
        -20,
        0,
        16,
        const Color(0xFF0F172A),
        bold: true,
      );
    } else {
      if (prime) {
        // Octagon
        Path path = Path();
        path.moveTo(-s / 2 + 10, -s / 2);
        path.lineTo(s / 2 - 10, -s / 2);
        path.lineTo(s / 2, -s / 2 + 10);
        path.lineTo(s / 2, s / 2 - 10);
        path.lineTo(s / 2 - 10, s / 2);
        path.lineTo(-s / 2 + 10, s / 2);
        path.lineTo(-s / 2, s / 2 - 10);
        path.lineTo(-s / 2, -s / 2 + 10);
        path.close();

        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFD8B4FE)
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8),
        ); // Glow
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF9333EA)
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke,
        );

        Paint innerStroke = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(-s / 2 + 10, -s / 2), Offset.zero, innerStroke);
        canvas.drawLine(Offset(s / 2, -s / 2 + 10), Offset.zero, innerStroke);
        canvas.drawLine(Offset(-s / 2, s / 2 - 10), Offset.zero, innerStroke);
        canvas.drawLine(Offset(s / 2 - 10, s / 2), Offset.zero, innerStroke);
      } else {
        // Rounded Rect Stone
        _drawRoundedRect(
          canvas,
          -s / 2,
          -s / 2,
          s,
          s,
          6,
          const Color(0xFF94A3B8),
          const Color(0xFF334155),
          4,
        );
        Paint cracks = Paint()
          ..color = Colors.black12
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(-s / 2 + 10, -s / 2),
          const Offset(-10, -10),
          cracks,
        );
        canvas.drawLine(const Offset(-10, -10), Offset(-s / 2, -5), cracks);
        canvas.drawLine(Offset(s / 2, s / 2 - 15), const Offset(10, 5), cracks);
        canvas.drawLine(const Offset(10, 5), Offset(15, s / 2), cracks);
      }
      _drawText(
        canvas,
        val.toString(),
        0,
        0,
        24,
        const Color(0xFF0F172A),
        bold: true,
      );
    }
    canvas.restore();
  }

  void _drawConveyor(Canvas canvas, double x, double y, double width) {
    _drawRoundedRect(
      canvas,
      x - 20,
      y - 25,
      width + 40,
      50,
      25,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      4,
    );
    _drawRoundedRect(
      canvas,
      x - 5,
      y - 18,
      width + 10,
      36,
      18,
      const Color(0xFF1E293B),
      Colors.transparent,
      0,
    );
    Paint pFill = Paint()..color = const Color(0xFF94A3B8);
    Paint pStroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double wx = x; wx < x + width; wx += 40) {
      canvas.drawCircle(Offset(wx, y), 8, pFill);
      canvas.drawCircle(Offset(wx, y), 8, pStroke);
    }
  }

  void _drawSmasherPad(
    Canvas canvas,
    double x,
    double y,
    double scale, [
    bool isActive = false,
  ]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    Paint fill = Paint()..color = const Color(0xFF64748B);
    Paint stroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawOval(const Rect.fromLTWH(-80, 0, 160, 60), fill);
    canvas.drawOval(const Rect.fromLTWH(-80, 0, 160, 60), stroke);

    canvas.drawOval(
      const Rect.fromLTWH(-80, -20, 160, 60),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawOval(const Rect.fromLTWH(-80, -20, 160, 60), stroke);

    Paint padFill = Paint()
      ..color = isActive ? const Color(0xFFFCA5A5) : const Color(0xFF94A3B8);
    if (isActive)
      padFill.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    canvas.drawOval(const Rect.fromLTWH(-50, -15, 100, 40), padFill);
    canvas.drawOval(const Rect.fromLTWH(-50, -15, 100, 40), stroke);

    _drawText(
      canvas,
      t('lbl_smasher'),
      0,
      50,
      12,
      const Color(0xFFF8FAFC),
      bold: true,
    );
    canvas.restore();
  }

  void _drawHammerBtn(Canvas canvas, double x, double y, double rot) {
    _drawRoundedRect(
      canvas,
      x - 30,
      y - 30,
      60,
      60,
      15,
      const Color(0xFFEF4444),
      const Color(0xFF0F172A),
      4,
    );
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rot);
    canvas.drawRect(
      const Rect.fromLTWH(-4, -15, 8, 30),
      Paint()..color = const Color(0xFFB45309),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-4, -15, 8, 30),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawRoundedRect(
      canvas,
      -15,
      -20,
      30,
      15,
      2,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      2,
    );
    canvas.restore();
  }

  void _drawResultTray(
    Canvas canvas,
    double x,
    double y,
    double width,
    List<GameEntity> blocks,
  ) {
    _drawRoundedRect(
      canvas,
      x - width / 2,
      y,
      width,
      80,
      10,
      Colors.white10,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      t('lbl_result_tray'),
      x,
      y + 95,
      14,
      const Color(0xFF94A3B8),
      bold: true,
    );
    double startX = x - width / 2 + 40;
    for (int i = 0; i < blocks.length; i++) {
      _drawNumberBlock(canvas, startX + i * 70, y + 40, blocks[i].val, 0.8);
    }
    if (blocks.isNotEmpty) {
      String eq = blocks.map((b) => b.val).join(" × ");
      int total = blocks.fold(1, (a, c) => a * c.val);
      _drawText(
        canvas,
        "$total = $eq",
        x,
        y - 20,
        20,
        const Color(0xFF4ADE80),
        bold: true,
      );
    }
  }

  void _drawCombinerMachine(Canvas canvas, double x, double y, int val) {
    canvas.save();
    canvas.translate(x, y);
    _drawRoundedRect(
      canvas,
      -100,
      -50,
      200,
      150,
      20,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      5,
    );

    Path funnel = Path()
      ..moveTo(-60, -50)
      ..lineTo(-80, -100)
      ..lineTo(80, -100)
      ..lineTo(60, -50)
      ..close();
    canvas.drawPath(funnel, Paint()..color = const Color(0xFF64748B));
    canvas.drawPath(
      funnel,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    _drawRoundedRect(
      canvas,
      -70,
      0,
      140,
      60,
      5,
      const Color(0xFF020617),
      const Color(0xFF475569),
      3,
    );
    _drawText(
      canvas,
      val.toString(),
      0,
      30,
      40,
      const Color(0xFF4ADE80),
      bold: true,
    );
    _drawText(
      canvas,
      t('lbl_combiner'),
      0,
      120,
      16,
      const Color(0xFFCBD5E1),
      bold: true,
    );
    canvas.restore();
  }

  void _drawChest(Canvas canvas, double x, double y, bool isOpen) {
    canvas.save();
    canvas.translate(x, y);
    _drawRoundedRect(
      canvas,
      -120,
      0,
      240,
      120,
      10,
      const Color(0xFFB45309),
      const Color(0xFF0F172A),
      4,
    );
    _drawLine(canvas, -120, 40, 120, 40, const Color(0xFF0F172A), 2);
    _drawLine(canvas, -120, 80, 120, 80, const Color(0xFF0F172A), 2);

    if (isOpen) {
      canvas.drawPath(
        Path()..addRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(-120, -100, 240, 100),
            topLeft: const Radius.circular(60),
            topRight: const Radius.circular(60),
          ),
        ),
        Paint()..color = const Color(0xFF92400E),
      );
      canvas.drawPath(
        Path()..addRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(-120, -100, 240, 100),
            topLeft: const Radius.circular(60),
            topRight: const Radius.circular(60),
          ),
        ),
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      Paint coinFill = Paint()..color = const Color(0xFFFACC15);
      Paint coinStroke = Paint()
        ..color = const Color(0xFFCA8A04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      math.Random rng = math.Random(42); // Deterministic
      for (int i = 0; i < 30; i++) {
        Offset pos = Offset(
          -90 + rng.nextDouble() * 180,
          -10 + rng.nextDouble() * 30,
        );
        canvas.drawCircle(pos, 8, coinFill);
        canvas.drawCircle(pos, 8, coinStroke);
      }
    } else {
      canvas.drawPath(
        Path()..addRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(-120, -40, 240, 40),
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
          ),
        ),
        Paint()..color = const Color(0xFFB45309),
      );
      canvas.drawPath(
        Path()..addRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(-120, -40, 240, 40),
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
          ),
        ),
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    canvas.restore();
  }

  void _drawLock(
    Canvas canvas,
    double x,
    double y,
    int val,
    int holes,
    List<int> insertedKeys,
  ) {
    canvas.save();
    canvas.translate(x, y);
    _drawRoundedRect(
      canvas,
      -60,
      -50,
      120,
      100,
      15,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      4,
    );

    Path loop = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(-30, -80, 60, 30),
          topLeft: const Radius.circular(30),
          topRight: const Radius.circular(30),
        ),
      );
    canvas.drawPath(
      loop,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    _drawText(
      canvas,
      val.toString(),
      0,
      -20,
      24,
      const Color(0xFF0F172A),
      bold: true,
    );

    double w = 30;
    double startX = -((holes * w) / 2) + w / 2;
    for (int i = 0; i < holes; i++) {
      double kx = startX + i * w;
      double ky = 20;
      if (i < insertedKeys.length) {
        _drawNumberBlock(canvas, kx, ky, insertedKeys[i], 0.4, true);
      } else {
        Paint p = Paint()..color = const Color(0xFF0F172A);
        canvas.drawCircle(Offset(kx, ky - 3), 5, p);
        canvas.drawPath(
          Path()
            ..moveTo(kx - 2, ky - 3)
            ..lineTo(kx - 2, ky + 8)
            ..lineTo(kx + 2, ky + 8)
            ..lineTo(kx + 2, ky - 3)
            ..close(),
          p,
        );
      }
    }
    canvas.restore();
  }
}
