// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrowniePanLabApp());
}

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': 'The Brownie Pan Baker',
    'appSubtitle': 'Class 7 • VISUALIZING FRACTION MULTIPLICATION',
    'enterLab': 'Enter Lab',
    'objectiveLbl': 'Mission Objective:',
    'selectScenario': 'Select Scenario',
    'checkWorkBtn': 'Check My Work',
    'nextBtn': 'Next Step',
    'stepLabel': 'STEP',
    'successTitle': 'Master Baker!',
    'successDesc': 'You successfully calculated the fraction product visually!',
    'continueBtn': 'Awesome!',
    'errModel': 'Numbers are correct, but visual model is wrong! Fix the grid.',
    'errNumbers': 'Check your numbers and visual model!',
    'correctMsg': 'Correct!',
    'simplifyingMsg': 'Simplifying to 3/10...',
    'chapterComplete': 'Chapter Complete!',
    's5_success':
        '6/20 simplifies to 3/10! You have mastered fraction multiplication.',
    'finishBtn': 'Finish',
    'trayText': 'NUMBER TRAY (DRAG TILES TO FRACTION)',
    'modeShadeBtn': 'Shade Columns',
    'modeSelectBtn': 'Select Rows',
    'clearBtn': 'Clear Tiles',
    'langBtn': 'EN',
    'resetBtn': 'Reset',

    's1_title': '1. The Simple Slice: 1/2 × 1/4',
    's1_obj':
        'To visually calculate the product of two unit fractions by finding a part of a part.',
    's1_h1':
        "A brownie pan representing '1 whole' is on your screen. The first fraction is 1/2. DRAG the vertical slider on the right to divide the pan into 2 equal columns.",
    's1_t1':
        "<b>Observation:</b> The brownie pan is visually split by a vertical line into two equal columns.<br><b>Learnt:</b> The denominator 2 tells us to divide the whole into 2 equal parts.",
    's1_h2':
        "Now we need to represent 1/2. CLICK on one of the two columns to shade it.",
    's1_t2':
        "<b>Observation:</b> One of the two columns becomes shaded, visually representing 1/2 of the whole pan.<br><b>Learnt:</b> The numerator 1 tells us to select 1 of those parts.",
    's1_h3':
        "The second fraction is 1/4. We need to find 1/4 of the 1/2 we just shaded. DRAG the horizontal slider at the bottom to divide the entire pan into 4 equal rows.",
    's1_t3':
        "<b>Observation:</b> The brownie pan is now split by three horizontal lines into four equal rows, creating a grid.<br><b>Learnt:</b> We are finding a fraction of a fraction by dividing the whole pan again by the second denominator (4).",
    's1_h4':
        "To find the answer, we need to identify the area that is part of both the 1/2 column and 1 of the 4 rows. CLICK on the top row to select it.",
    's1_t4':
        "<b>Observation:</b> The piece that was already shaded blue and is also in the top row becomes a darker, cross-hatched pattern.<br><b>Learnt:</b> This double-shaded overlapping area represents 1/4 of the 1/2.",
    's1_h5':
        "The answer is the fraction represented by the double-shaded piece. Count the number of double-shaded pieces (numerator), then count the total number of pieces in the whole pan (denominator).",
    's1_t5':
        "<b>Observation:</b> There is 1 double-shaded piece and 8 total pieces in the pan.<br><b>Learnt:</b> The lab explicitly shows that 1/2 of 1/4 is 1/8. We found this by taking a fraction of another fraction. The total pieces (8) = 2 × 4. The overlapping pieces (1) = 1 × 1.",

    's2_title': '2. The Baker\'s Dozen: 2/3 × 3/5',
    's2_obj': 'To visually calculate the product of two non-unit fractions.',
    's2_h1':
        "Let's calculate 2/3 × 3/5. First, represent 2/3. DRAG the vertical slider to divide the brownie pan into 3 columns.",
    's2_t1':
        "<b>Observation:</b> The pan is divided into 3 equal columns.<br><b>Learnt:</b> The vertical slider interaction slices the 3D brownie pan into 3 columns.",
    's2_h2':
        "Now, CLICK on 2 of the 3 columns to shade them, representing 2/3.",
    's2_t2':
        "<b>Observation:</b> Two of the three columns are shaded light blue. A label '2/3' appears over the shaded area.<br><b>Learnt:</b> The user clicks two columns, and they fill with a light blue color.",
    's2_h3':
        "Next, we need to find 3/5 of our shaded 2/3 area. DRAG the horizontal slider to divide the entire pan into 5 rows.",
    's2_t3':
        "<b>Observation:</b> The pan is now divided into a 3x5 grid of 15 total pieces.<br><b>Learnt:</b> The horizontal slider interaction slices the pan into 5 rows, creating the grid.",
    's2_h4':
        "To represent 3/5, CLICK any row to select. Drag over multiple rows to select 3 rows of the pan.",
    's2_t4':
        "<b>Observation:</b> A transparent yellow selection box covers the 3 rows. The area where this selection overlaps with the blue shaded columns becomes double-shaded in a dark green, cross-hatched pattern.<br><b>Learnt:</b> The overlapping region automatically changes color to dark green indicating the product area.",
    's2_h5':
        "Count the double-shaded pieces for the numerator and the total pieces for the denominator to find the final product.",
    's2_t5':
        "<b>Observation:</b> The student observes 6 double-shaded pieces and 15 total pieces.<br><b>Learnt:</b> This shows that 2/3 × 3/5 = 6/15. The visual model reinforces that the numerators (2 and 3) multiply to give the number of overlapping parts (6), and the denominators (3 and 5) multiply to give the total parts in the whole (15).",

    's3_title': '3. More Than a Whole: 3/2 × 1/4',
    's3_obj':
        'To visualize multiplying an improper fraction by a proper fraction.',
    's3_h1':
        "We need to represent the improper fraction 3/2. DRAG the vertical slider to divide the brownie pan into 2 columns.",
    's3_t1':
        "<b>Observation:</b> The pan is divided into 2 columns.<br><b>Learnt:</b> The vertical slider slices the pan into 2 columns.",
    's3_h2': "Now, try to shade 3 halves. CLICK on the columns to shade them.",
    's3_t2':
        "<b>Observation:</b> The user clicks the first column, then the second. When they try to click a third time, a new, identical brownie pan appears to the right, and the system prompts them to continue. The user then shades the first column of the second pan.<br><b>Learnt:</b> After shading the first two halves, a '+' icon appears. Clicking it causes a second pan to slide in from the right. The user can then shade the third half. A label '3/2' appears over the entire shaded area.",
    's3_h3':
        "Now we must find 1/4 of this entire shaded area. DRAG the horizontal slider to divide both pans into 4 rows.",
    's3_t3':
        "<b>Observation:</b> Both brownie pans are sliced horizontally into 4 rows.<br><b>Learnt:</b> The horizontal cutting animation applies across both 3D models simultaneously.",
    's3_h4':
        "To find 1/4 of the shaded area, CLICK on the top row across both pans.",
    's3_t4':
        "<b>Observation:</b> The pieces in the top row that were previously shaded blue are now double-shaded in dark green.<br><b>Learnt:</b> Clicking the top row of either pan applies a transparent yellow overlay to that row across both pans. The 3 pieces that overlap with the blue shading turn dark green.",
    's3_h5':
        "Count the double-shaded pieces. For the denominator, count how many total pieces make up one whole brownie pan.",
    's3_t5':
        "<b>Observation:</b> The student observes 3 double-shaded pieces. They observe that one whole pan is made of 8 pieces.<br><b>Learnt:</b> This demonstrates that 3/2 × 1/4 = 3/8. Even with improper fractions, the area model works. The denominator is always based on the number of equal parts in a single whole.",

    's4_title': '4. Your Turn to Bake: 2/5 × 1/3',
    's4_obj':
        'Apply the learned visual method to multiply two fractions without step-by-step guidance.',
    's4_h1':
        "Your challenge is to solve 2/5 × 1/3. Use the tool toggle (above the pan) and sliders to physically model the problem. Click 'Next Step' when you're done modeling.",
    's4_t1':
        "<b>Observation:</b> You divided the pan into 5 columns, shaded 2, and then divided it into 3 rows.<br><b>Learnt:</b> We can physically build the grid to calculate any two proper fractions.",
    's4_h2':
        "Now, identify the overlapping area that represents the answer. DRAG the correct number tiles into the numerator and denominator boxes to form the final fraction. CLICK 'Check My Work' when you are done.",
    's4_t2':
        "<b>Observation:</b> You identified the 2 double-shaded pieces and the 15 total pieces in the whole.<br><b>Learnt:</b> We can extract the final fraction by dragging the correct numbers to construct 2/15.",

    's5_title': '5. The Master Baker Challenge: 3/4 × 2/5',
    's5_obj':
        'Solve a more complex multiplication problem independently to solidify the concept.',
    's5_h1':
        "Here is your final challenge: 3/4 × 2/5. Use the explicit tool toggle above the pan to find the product visually. Click 'Next Step' when you are ready.",
    's5_t1':
        "<b>Observation:</b> You set up a grid of 4 columns (shading 3) and 5 rows (selecting 2).<br><b>Learnt:</b> Mastering this confirms that a/b × c/d visually forms an intersecting area of (a×c) over a total area of (b×d).",
    's5_h2':
        "Determine the numerator and denominator by counting the relevant pieces. DRAG the number tiles to build your answer and CLICK 'Check My Work'.",
    's5_t2':
        "<b>Observation:</b> You counted 6 double-shaded pieces out of 20 total pieces.<br><b>Learnt:</b> The product is 6/20. You have mastered the area model for fraction multiplication!",
  },
  'hi': {
    'appTitle': 'ब्राउनी पैन बेकर',
    'appSubtitle': 'कक्षा 7 • भिन्नों के गुणा का दृश्य रूप',
    'enterLab': 'लैब में प्रवेश करें',
    'objectiveLbl': 'मिशन उद्देश्य:',
    'selectScenario': 'दृश्य चुनें',
    'checkWorkBtn': 'मेरा काम जांचें',
    'nextBtn': 'अगला कदम',
    'stepLabel': 'कदम',
    'successTitle': 'मास्टर बेकर!',
    'successDesc': 'आपने सफलतापूर्वक अंश गुणन की दृश्य रूप से गणना की!',
    'continueBtn': 'बहुत बढ़िया!',
    'errModel': 'संख्याएँ सही हैं, लेकिन दृश्य मॉडल गलत है! ग्रिड को ठीक करें।',
    'errNumbers': 'अपनी संख्याओं और दृश्य मॉडल की जाँच करें!',
    'correctMsg': 'सही!',
    'simplifyingMsg': '3/10 में सरल किया जा रहा है...',
    'chapterComplete': 'अध्याय पूर्ण!',
    's5_success':
        '6/20 सरल होकर 3/10 हो जाता है! आपने भिन्न गुणन में महारत हासिल कर ली है।',
    'finishBtn': 'समाप्त',
    'trayText': 'संख्या ट्रे (टाइल्स को खींचें)',
    'modeShadeBtn': 'कॉलम रंगें',
    'modeSelectBtn': 'पंक्तियाँ चुनें',
    'clearBtn': 'टाइल्स साफ़ करें',
    'langBtn': 'HI',
    'resetBtn': 'रीसेट',

    's1_title': '1. सरल स्लाइस: 1/2 × 1/4',
    's1_obj':
        'एक भाग का भाग खोजकर दो इकाई भिन्नों के गुणनफल की दृश्य रूप से गणना करना।',
    's1_h1':
        "एक ब्राउनी पैन जो '1 पूरे' को दर्शाता है, आपकी स्क्रीन पर है। पहला भिन्न 1/2 है। पैन को 2 समान कॉलम में विभाजित करने के लिए दाईं ओर वर्टिकल स्लाइडर को खींचें।",
    's1_t1':
        "<b>अवलोकन:</b> ब्राउनी पैन एक ऊर्ध्वाधर रेखा द्वारा दो समान कॉलम में विभाजित हो जाता है।<br><b>सीखा:</b> 1/2 का हर 2 हमें पूरे को 2 समान भागों में विभाजित करने के लिए कहता है।",
    's1_h2':
        "अब हमें 1/2 को दर्शाने की आवश्यकता है। इसे रंगने के लिए दो कॉलम में से एक पर क्लिक करें।",
    's1_t2':
        "<b>अवलोकन:</b> दो कॉलम में से एक शेड हो जाता है, जो पूरे पैन के 1/2 भाग को दृश्य रूप से दर्शाता है।<br><b>सीखा:</b> अंश 1 हमें उन भागों में से 1 का चयन करने के लिए कहता है।",
    's1_h3':
        "दूसरा भिन्न 1/4 है। हमें अभी शेड किए गए 1/2 का 1/4 खोजना है। पूरे पैन को 4 समान पंक्तियों में विभाजित करने के लिए नीचे दिए गए क्षैतिज स्लाइडर को खींचें।",
    's1_t3':
        "<b>अवलोकन:</b> ब्राउनी पैन अब तीन क्षैतिज रेखाओं द्वारा चार समान पंक्तियों में विभाजित हो गया है, जिससे एक ग्रिड बन गया है।<br><b>सीखा:</b> हम दूसरे हर (4) द्वारा पूरे पैन को फिर से विभाजित करके एक भिन्न का भिन्न खोज रहे हैं।",
    's1_h4':
        "उत्तर खोजने के लिए, हमें उस क्षेत्र की पहचान करनी होगी जो 1/2 कॉलम और 4 पंक्तियों में से 1 दोनों का हिस्सा है। इसे चुनने के लिए शीर्ष पंक्ति पर क्लिक करें।",
    's1_t4':
        "<b>अवलोकन:</b> वह टुकड़ा जो पहले से ही नीले रंग से शेड किया गया था और शीर्ष पंक्ति में भी है, वह गहरे रंग का, क्रॉस-हैच पैटर्न बन जाता है।<br><b>सीखा:</b> यह डबल-शेडेड ओवरलैपिंग क्षेत्र 1/2 के 1/4 को दर्शाता है।",
    's1_h5':
        "उत्तर डबल-शेडेड टुकड़े द्वारा दर्शाया गया भिन्न है। डबल-शेडेड टुकड़ों की संख्या (अंश) गिनें, फिर पूरे पैन में टुकड़ों की कुल संख्या (हर) गिनें।",
    's1_t5':
        "<b>अवलोकन:</b> 1 डबल-शेडेड टुकड़ा और पैन में कुल 8 टुकड़े हैं।<br><b>सीखा:</b> लैब स्पष्ट रूप से दिखाती है कि 1/4 का 1/2, 1/8 होता है। कुल टुकड़े (8) = 2 × 4. ओवरलैपिंग टुकड़े (1) = 1 × 1.",

    's2_title': '2. बेकर्स दर्जन: 2/3 × 3/5',
    's2_obj': 'दो गैर-इकाई भिन्नों के गुणनफल की दृश्य रूप से गणना करना।',
    's2_h1':
        "आइए 2/3 × 3/5 की गणना करें। पहले, 2/3 का प्रतिनिधित्व करें। ब्राउनी पैन को 3 कॉलम में विभाजित करने के लिए ऊर्ध्वाधर स्लाइडर को खींचें।",
    's2_t1':
        "<b>अवलोकन:</b> पैन को 3 समान कॉलम में विभाजित किया गया है।<br><b>सीखा:</b> ऊर्ध्वाधर स्लाइडर इंटरैक्शन 3D ब्राउनी पैन को 3 कॉलम में काटता है।",
    's2_h2':
        "अब, 2/3 का प्रतिनिधित्व करते हुए, उन्हें छायांकित करने के लिए 3 में से 2 कॉलम पर क्लिक करें।",
    's2_t2':
        "<b>अवलोकन:</b> तीन कॉलम में से दो हल्के नीले रंग में छायांकित हैं। छायांकित क्षेत्र के ऊपर '2/3' लेबल दिखाई देता है।<br><b>सीखा:</b> उपयोगकर्ता दो कॉलम पर क्लिक करता है, और वे हल्के नीले रंग से भर जाते हैं।",
    's2_h3':
        "इसके बाद, हमें अपने छायांकित 2/3 क्षेत्र का 3/5 खोजना होगा। पूरे पैन को 5 पंक्तियों में विभाजित करने के लिए क्षैतिज स्लाइडर को खींचें।",
    's2_t3':
        "<b>अवलोकन:</b> पैन अब कुल 15 टुकड़ों के 3x5 ग्रिड में विभाजित है।<br><b>सीखा:</b> क्षैतिज स्लाइडर इंटरैक्शन पैन को 5 पंक्तियों में काटता है, जिससे ग्रिड बनता है।",
    's2_h4':
        "3/5 का प्रतिनिधित्व करने के लिए, चयन करने के लिए किसी भी पंक्ति पर क्लिक करें।",
    's2_t4':
        "<b>अवलोकन:</b> एक पारदर्शी पीला चयन बॉक्स 3 पंक्तियों को कवर करता है। वह क्षेत्र जहाँ यह चयन नीले छायांकित कॉलम के साथ ओवरलैप होता है, गहरे हरे रंग में डबल-छायांकित हो जाता है।<br><b>सीखा:</b> ओवरलैपिंग क्षेत्र स्वचालित रूप से गहरे हरे रंग में बदल जाता है।",
    's2_h5':
        "अंतिम गुणनफल खोजने के लिए अंश के लिए डबल-छायांकित टुकड़ों और हर के लिए कुल टुकड़ों की गिनती करें।",
    's2_t5':
        "<b>अवलोकन:</b> छात्र 6 डबल-छायांकित टुकड़े और 15 कुल टुकड़े देखता है।<br><b>सीखा:</b> यह दर्शाता है कि 2/3 × 3/5 = 6/15। अंश (2 और 3) गुणा होकर (6) देते हैं, और हर (3 और 5) गुणा होकर (15) देते हैं।",

    's3_title': '3. एक पूरे से अधिक: 3/2 × 1/4',
    's3_obj': 'एक उचित भिन्न से एक अनुचित भिन्न को गुणा करने की कल्पना करना।',
    's3_h1':
        "हमें अनुचित भिन्न 3/2 का प्रतिनिधित्व करने की आवश्यकता है। ब्राउनी पैन को 2 कॉलम में विभाजित करने के लिए वर्टिकल स्लाइडर को खींचें।",
    's3_t1':
        "<b>अवलोकन:</b> पैन को 2 कॉलम में विभाजित किया गया है।<br><b>सीखा:</b> ऊर्ध्वाधर स्लाइडर पैन को 2 कॉलम में काटता है।",
    's3_h2':
        "अब, 3 हिस्सों को शेड करने का प्रयास करें। उन्हें छायांकित करने के लिए कॉलम पर क्लिक करें।",
    's3_t2':
        "<b>अवलोकन:</b> जब वे तीसरी बार क्लिक करने का प्रयास करते हैं, तो दाईं ओर एक नया पैन दिखाई देता है। उपयोगकर्ता फिर दूसरे पैन के पहले कॉलम को छायांकित करता है।<br><b>सीखा:</b> एक दूसरा पैन दाईं ओर से स्लाइड होता है। पूरे छायांकित क्षेत्र के ऊपर '3/2' लेबल दिखाई देता है।",
    's3_h3':
        "अब हमें इस पूरे छायांकित क्षेत्र का 1/4 खोजना होगा। दोनों पैन को 4 पंक्तियों में विभाजित करने के लिए क्षैतिज स्लाइडर को खींचें।",
    's3_t3':
        "<b>अवलोकन:</b> दोनों ब्राउनी पैन 4 पंक्तियों में क्षैतिज रूप से काटे गए हैं।<br><b>सीखा:</b> क्षैतिज कटिंग एनीमेशन एक साथ दोनों 3D मॉडल पर लागू होता है।",
    's3_h4':
        "छायांकित क्षेत्र का 1/4 खोजने के लिए, दोनों पैन में शीर्ष पंक्ति पर क्लिक करें।",
    's3_t4':
        "<b>अवलोकन:</b> नीले रंग के साथ ओवरलैप होने वाले 3 टुकड़े गहरे हरे रंग में बदल जाते हैं।<br><b>सीखा:</b> क्लिक करने से दोनों पैन में ओवरले लागू होता है।",
    's3_h5':
        "डबल-शेडेड टुकड़ों को गिनें। हर के लिए, गिनें कि कुल कितने टुकड़े एक पूरे ब्राउनी पैन बनाते हैं।",
    's3_t5':
        "<b>अवलोकन:</b> छात्र 3 डबल-छायांकित टुकड़े देखता है। एक पूरा पैन 8 टुकड़ों से बना है।<br><b>सीखा:</b> यह दर्शाता है कि 3/2 × 1/4 = 3/8। हर हमेशा एक पूरे में समान भागों की संख्या पर आधारित होता है।",

    's4_title': '4. आपकी बारी: 2/5 × 1/3',
    's4_obj':
        'चरण-दर-चरण मार्गदर्शन के बिना दो भिन्नों को गुणा करने के लिए सीखी गई दृश्य विधि को लागू करें।',
    's4_h1':
        "आपकी चुनौती 2/5 × 1/3 को हल करना है। समस्या को मॉडल करने के लिए उपकरण और स्लाइडर्स का उपयोग करें। हो जाने पर 'अगला कदम' पर क्लिक करें।",
    's4_t1':
        "<b>अवलोकन:</b> आपने पैन को 5 कॉलम में विभाजित किया, 2 को छायांकित किया, और फिर इसे 3 पंक्तियों में विभाजित किया।<br><b>सीखा:</b> हम किसी भी दो उचित भिन्नों की गणना करने के लिए ग्रिड का निर्माण कर सकते हैं।",
    's4_h2':
        "अब, ओवरलैपिंग क्षेत्र की पहचान करें। अंतिम भिन्न बनाने के लिए अंश और हर बॉक्स में सही संख्या टाइलें खींचें। हो जाने पर 'मेरा काम जांचें' पर क्लिक करें।",
    's4_t2':
        "<b>अवलोकन:</b> आपने पूरे हिस्से में 2 डबल-शेडेड टुकड़ों और 15 कुल टुकड़ों की पहचान की।<br><b>सीखा:</b> हम 2/15 के निर्माण के लिए सही संख्याओं को खींचकर अंतिम भिन्न निकाल सकते हैं।",

    's5_title': '5. मास्टर चुनौती: 3/4 × 2/5',
    's5_obj':
        'अवधारणा को ठोस बनाने के लिए स्वतंत्र रूप से एक अधिक जटिल गुणन समस्या को हल करें।',
    's5_h1':
        "यहाँ आपकी अंतिम चुनौती है: 3/4 × 2/5। दृश्य रूप से खोजने के लिए पैन के ऊपर टूल का उपयोग करें। तैयार होने पर 'अगला कदम' पर क्लिक करें।",
    's5_t1':
        "<b>अवलोकन:</b> आपने 4 कॉलम (3 शेड) और 5 पंक्तियों (2 चयन) का ग्रिड स्थापित किया है।<br><b>सीखा:</b> इसमें महारत हासिल करना इस बात की पुष्टि करता है कि a/b × c/d दृष्टिगत रूप से (b×d) के कुल क्षेत्रफल पर (a×c) का एक प्रतिच्छेदन क्षेत्र बनाता है।",
    's5_h2':
        "प्रासंगिक टुकड़ों की गिनती करके अंश और हर निर्धारित करें। अपना उत्तर बनाने के लिए संख्या टाइलें खींचें और 'मेरा काम जांचें' पर क्लिक करें।",
    's5_t2':
        "<b>अवलोकन:</b> आपने 20 कुल टुकड़ों में से 6 डबल-शेडेड टुकड़ों की गिनती की।<br><b>सीखा:</b> गुणनफल 6/20 है। आपने भिन्न गुणन के लिए क्षेत्र मॉडल में महारत हासिल कर ली है!",
  },
};

class Pan {
  double x, y, w, h;
  int cols, rows;
  Set<int> shadedCols;
  Set<int> selectedRows;

  Pan(this.x, this.y, this.w, this.h, this.cols, this.rows)
    : shadedCols = {},
      selectedRows = {};
}

class BrowniePanLabApp extends StatelessWidget {
  const BrowniePanLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366f1),
          secondary: Color(0xFFf59e0b),
          surface: Color(0xFF1E293B),
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const MultiplicationofTwoFractions(),
    );
  }
}

class MultiplicationofTwoFractions extends StatefulWidget {
  const MultiplicationofTwoFractions({super.key});

  @override
  State<MultiplicationofTwoFractions> createState() =>
      _MultiplicationofTwoFractionsState();
}

class _MultiplicationofTwoFractionsState
    extends State<MultiplicationofTwoFractions> {
  bool _isSidebarOpen = true;
  bool _isShutterOpen = false;
  bool _isSuccessPopupVisible = false;
  Offset _popupOffset = const Offset(150, 100);

  String _lang = 'en';
  int _scenario = 1;
  int _step = 0;
  String _mode = 'shade';

  List<Pan> pans = [];
  int vSliderVal = 1;
  int hSliderVal = 1;

  String fbNum = "";
  String fbDen = "";
  String feedbackText = "";
  Color feedbackColor = Colors.transparent;

  bool _addPanBtnActive = false;
  bool _showFinalAnswer = false;

  final TransformationController _transformationController =
      TransformationController();

  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _snapPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback
  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _alertUrl =
      'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';
  static const String _snapUrl =
      'audio/class7/mixkit_392.mp3';

  String getString(String key) =>
      translations[_lang]?[key] ?? translations['en']![key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _transformationController.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      switch (type) {
        case 'click':
          await _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          await _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          await _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'alert':
          await _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'pop':
          await _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'shutter':
          await _shutterPlayer.play(AssetSource(_shutterUrl));
          break;
        case 'snap':
          await _snapPlayer.play(AssetSource(_snapUrl));
          break;
      }
    } catch (e) {
      debugPrint("Audio Play Error: $e");
    }
  }

  void _loadScenario(int s) {
    setState(() {
      _scenario = s;
      _step = 0;
      vSliderVal = 1;
      hSliderVal = 1;
      fbNum = "";
      fbDen = "";
      feedbackText = "";
      _mode = 'shade';
      _addPanBtnActive = false;
      _showFinalAnswer = false;

      // Coordinate System: Fixed workspace of 1200x800 for optimal pan/zoom tracking
      if (s == 3) {
        pans = [Pan(250, 110, 240, 240, 1, 1)];
      } else {
        pans = [Pan(380, 110, 240, 240, 1, 1)];
      }
      _transformationController.value = Matrix4.identity();
    });
  }

  void _toggleLanguage() {
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
    _playSound('alert');
  }

  void _resetLab() {
    _playSound('click');
    setState(() {
      _lang = 'en';
      _isShutterOpen = false; // Shutter covers the screen again
      _isSuccessPopupVisible = false;
      _scenario = 1;
    });
    _loadScenario(1);
  }

  void _advanceStep() {
    _playSound('success');
    setState(() {
      _step++;
    });
  }

  void _checkStepValidation() {
    if (_scenario == 1) {
      if (_step == 0 && vSliderVal == 2) {
        _advanceStep();
      } else if (_step == 1 && pans[0].shadedCols.length == 1) {
        _advanceStep();
      } else if (_step == 2 && hSliderVal == 4) {
        _advanceStep();
      } else if (_step == 3 &&
          pans[0].selectedRows.length == 1 &&
          pans[0].selectedRows.contains(0)) {
        _advanceStep();
        setState(() {
          _showFinalAnswer = true;
          fbNum = "1";
          fbDen = "8";
        });
        _playSound('success');
        // Scenario advances naturally after exactly 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _scenario == 1) _loadScenario(_scenario + 1);
        });
      }
    } else if (_scenario == 2) {
      if (_step == 0 && vSliderVal == 3) {
        _advanceStep();
      } else if (_step == 1 && pans[0].shadedCols.length == 2) {
        _advanceStep();
      } else if (_step == 2 && hSliderVal == 5) {
        _advanceStep();
      } else if (_step == 3 && pans[0].selectedRows.length == 3) {
        _advanceStep();
        setState(() {
          _showFinalAnswer = true;
          fbNum = "6";
          fbDen = "15";
        });
        _playSound('success');
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _scenario == 2) _loadScenario(_scenario + 1);
        });
      }
    } else if (_scenario == 3) {
      if (_step == 0 && vSliderVal == 2) {
        _advanceStep();
      } else if (_step == 1) {
        if (pans[0].shadedCols.length == 2 && pans.length == 1) {
          setState(() {
            _addPanBtnActive = true;
          });
        }
        if (pans.length == 2 && pans[1].shadedCols.length == 1) {
          _advanceStep();
          setState(() {
            _addPanBtnActive = false;
          });
        }
      } else if (_step == 2 && hSliderVal == 4) {
        _advanceStep();
      } else if (_step == 3 &&
          pans[0].selectedRows.length == 1 &&
          pans[0].selectedRows.contains(0)) {
        _advanceStep();
        setState(() {
          _showFinalAnswer = true;
          fbNum = "3";
          fbDen = "8";
        });
        _playSound('success');
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _scenario == 3) _loadScenario(_scenario + 1);
        });
      }
    }
  }

  void _checkWork() {
    int num = int.tryParse(fbNum) ?? 0;
    int den = int.tryParse(fbDen) ?? 0;
    bool isCorrectModel = false;
    int correctN = 0;
    int correctD = 0;

    if (_scenario == 4) {
      correctN = 2;
      correctD = 15;
      isCorrectModel =
          (vSliderVal == 5 &&
              pans[0].shadedCols.length == 2 &&
              hSliderVal == 3 &&
              pans[0].selectedRows.length == 1) ||
          (vSliderVal == 3 &&
              pans[0].shadedCols.length == 1 &&
              hSliderVal == 5 &&
              pans[0].selectedRows.length == 2);
    } else if (_scenario == 5) {
      correctN = 6;
      correctD = 20;
      isCorrectModel =
          (vSliderVal == 4 &&
              pans[0].shadedCols.length == 3 &&
              hSliderVal == 5 &&
              pans[0].selectedRows.length == 2) ||
          (vSliderVal == 5 &&
              pans[0].shadedCols.length == 2 &&
              hSliderVal == 4 &&
              pans[0].selectedRows.length == 3);
    }

    if (num == correctN && den == correctD && isCorrectModel) {
      _playSound('success');
      setState(() {
        feedbackColor = Colors.greenAccent;
        if (_scenario == 5) {
          feedbackText =
              "${getString('correctMsg')} $correctN/$correctD. ${getString('simplifyingMsg')}";
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _isSuccessPopupVisible = true;
              });
            }
          });
        } else {
          feedbackText = "${getString('correctMsg')} $correctN/$correctD";
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted && _scenario == 4) _loadScenario(_scenario + 1);
          });
        }
      });
    } else if (num == correctN && den == correctD && !isCorrectModel) {
      _playSound('error');
      setState(() {
        feedbackColor = Colors.orangeAccent;
        feedbackText = getString('errModel');
      });
    } else {
      _playSound('error');
      setState(() {
        feedbackColor = Colors.redAccent;
        feedbackText = getString('errNumbers');
        fbNum = "";
        fbDen = "";
      });
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            feedbackText = "";
          });
        }
      });
    }
  }

  void _handleTapOnPan(Offset localPos) {
    if (_scenario < 4 && _step == 4) return;

    bool tapped = false;
    for (int pIdx = 0; pIdx < pans.length; pIdx++) {
      Pan p = pans[pIdx];
      if (localPos.dx >= p.x &&
          localPos.dx <= p.x + p.w &&
          localPos.dy >= p.y &&
          localPos.dy <= p.y + p.h) {
        int col = ((localPos.dx - p.x) / (p.w / p.cols)).floor();
        int row = ((localPos.dy - p.y) / (p.h / p.rows)).floor();

        setState(() {
          if (_scenario >= 4) {
            if (_mode == 'shade') {
              if (p.shadedCols.contains(col)) {
                p.shadedCols.remove(col);
              } else {
                p.shadedCols.add(col);
              }
            } else {
              if (p.selectedRows.contains(row)) {
                p.selectedRows.remove(row);
              } else {
                p.selectedRows.add(row);
              }
            }
          } else {
            bool shadeActive =
                (_scenario == 1 && _step == 1) ||
                (_scenario == 2 && _step == 1) ||
                (_scenario == 3 && _step == 1);
            bool selectActive =
                (_scenario == 1 && _step == 3) ||
                (_scenario == 2 && _step == 3) ||
                (_scenario == 3 && _step == 3);

            if (shadeActive && hSliderVal == 1) {
              if (p.shadedCols.contains(col)) {
                p.shadedCols.remove(col);
              } else {
                p.shadedCols.add(col);
              }
            } else if (selectActive) {
              for (var pan in pans) {
                pan.selectedRows.add(row);
              }
            }
          }
        });
        tapped = true;
      }
    }
    if (tapped) {
      _playSound('snap');
      if (_scenario < 4) _checkStepValidation();
    }
  }

  Widget _buildVSlider(Pan targetPan) {
    bool isActive = (_scenario < 4 && _step == 0) || (_scenario >= 4);
    if (_scenario < 4 && _step == 4) isActive = false;

    double trackHeight = targetPan.h;
    double startY = targetPan.y;
    double startX = pans.last.x + pans.last.w + 40;

    double thumbY = startY + ((vSliderVal - 1) / 5) * trackHeight;

    return Positioned(
      left: startX - 20,
      top: startY - 20,
      width: 40,
      height: trackHeight + 40,
      child: GestureDetector(
        onVerticalDragUpdate:
            isActive
                ? (details) {
                  double localY = details.localPosition.dy - 20;
                  double ratio = localY / trackHeight;
                  int newVal = (ratio * 5 + 1).round().clamp(1, 6);
                  if (newVal != vSliderVal) {
                    setState(() {
                      vSliderVal = newVal;
                      for (var p in pans) {
                        p.cols = newVal;
                        p.shadedCols.clear();
                      }
                      if (_scenario == 3 && pans.length > 1) {
                        pans.removeLast();
                        _addPanBtnActive = false;
                      }
                    });
                    _playSound('click');
                    if (_scenario < 4) _checkStepValidation();
                  }
                }
                : null,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 20,
                child: Container(
                  width: 8,
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                top: thumbY - startY + 20 - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? const Color(0xFFf43f5e)
                            : const Color(0xFF64748b),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    vSliderVal.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHSlider(Pan firstPan) {
    bool isActive = (_scenario < 4 && _step == 2) || (_scenario >= 4);
    if (_scenario < 4 && _step == 4) isActive = false;

    double trackWidth = pans.last.x + pans.last.w - firstPan.x;
    double startX = firstPan.x;
    double startY = firstPan.y + firstPan.h + 40;

    double thumbX = startX + ((hSliderVal - 1) / 5) * trackWidth;

    return Positioned(
      left: startX - 20,
      top: startY - 20,
      width: trackWidth + 40,
      height: 40,
      child: GestureDetector(
        onHorizontalDragUpdate:
            isActive
                ? (details) {
                  double localX = details.localPosition.dx - 20;
                  double ratio = localX / trackWidth;
                  int newVal = (ratio * 5 + 1).round().clamp(1, 6);
                  if (newVal != hSliderVal) {
                    setState(() {
                      hSliderVal = newVal;
                      for (var p in pans) {
                        p.rows = newVal;
                        p.selectedRows.clear();
                      }
                    });
                    _playSound('click');
                    if (_scenario < 4) _checkStepValidation();
                  }
                }
                : null,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 20,
                child: Container(
                  height: 8,
                  width: trackWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: thumbX - startX + 20 - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? const Color(0xFF3b82f6)
                            : const Color(0xFF64748b),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hSliderVal.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFractionBox() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DragTarget<String>(
          builder:
              (context, candidateData, rejectedData) => Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      candidateData.isNotEmpty
                          ? Colors.white24
                          : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 2,
                    style: BorderStyle.none,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  fbNum.isEmpty ? "_" : fbNum,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          onAcceptWithDetails: (details) {
            setState(() {
              if (fbNum.length < 2) fbNum += details.data;
            });
            _playSound('snap');
          },
        ),
        Container(
          width: 100,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
        ),
        DragTarget<String>(
          builder:
              (context, candidateData, rejectedData) => Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      candidateData.isNotEmpty
                          ? Colors.white24
                          : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  fbDen.isEmpty ? "_" : fbDen,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          onAcceptWithDetails: (details) {
            setState(() {
              if (fbDen.length < 2) fbDen += details.data;
            });
            _playSound('snap');
          },
        ),
        if ((fbNum.isNotEmpty || fbDen.isNotEmpty) && _scenario >= 4)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  fbNum = "";
                  fbDen = "";
                });
                _playSound('alert');
              },
              child: Text(
                getString('clearBtn'),
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
      ],
    );
  }

  Widget _htmlText(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];
    List<String> parts = text.split('<b>');
    for (int i = 0; i < parts.length; i++) {
      if (i == 0) {
        spans.add(TextSpan(text: parts[i].replaceAll('<br>', '\n')));
      } else {
        List<String> subParts = parts[i].split('</b>');
        if (subParts.isNotEmpty) {
          spans.add(
            TextSpan(
              text: subParts[0].replaceAll('<br>', '\n'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          if (subParts.length > 1) {
            spans.add(TextSpan(text: subParts[1].replaceAll('<br>', '\n')));
          }
        }
      }
    }
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  List<Map<String, String>> _getSteps() {
    List<Map<String, String>> steps = [];
    if (_scenario <= 3) {
      steps.add({
        'hud': getString('s${_scenario}_h1'),
        'text': getString('s${_scenario}_t1'),
      });
      steps.add({
        'hud': getString('s${_scenario}_h2'),
        'text': getString('s${_scenario}_t2'),
      });
      steps.add({
        'hud': getString('s${_scenario}_h3'),
        'text': getString('s${_scenario}_t3'),
      });
      steps.add({
        'hud': getString('s${_scenario}_h4'),
        'text': getString('s${_scenario}_t4'),
      });
      steps.add({
        'hud': getString('s${_scenario}_h5'),
        'text': getString('s${_scenario}_t5'),
      });
    } else {
      steps.add({
        'hud': getString('s${_scenario}_h1'),
        'text': getString('s${_scenario}_t1'),
      });
      steps.add({
        'hud': getString('s${_scenario}_h2'),
        'text': getString('s${_scenario}_t2'),
      });
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sidebarWidth =
        screenWidth * 0.38; // Set to strictly 38% screen width

    List<Map<String, String>> currentSteps = _getSteps();

    // Check if initialization places popup out of bounds, automatically center it initially
    if (_popupOffset.dx == 150 && _popupOffset.dy == 100) {
      _popupOffset = Offset(screenWidth / 2 - 160, screenHeight / 2 - 150);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF090e17),
        body: Stack(
          children: [
            // === Main Pannable/Zoomable Workspace ===
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(
                  double.infinity,
                ), // Allows infinite panning
                minScale: 0.1,
                maxScale: 4.0,
                constrained: false,
                child: SizedBox(
                  width: 1200,
                  height: 800,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Pans Custom Paint
                      Positioned.fill(
                        child: GestureDetector(
                          onTapUp:
                              (details) =>
                                  _handleTapOnPan(details.localPosition),
                          child: CustomPaint(
                            painter: PanPainter(
                              pans: pans,
                              showFinalAnswer: _showFinalAnswer,
                              scenario: _scenario,
                            ),
                          ),
                        ),
                      ),

                      // Sliders (Pinned to Canvas Coordinates)
                      if (pans.isNotEmpty) _buildVSlider(pans[0]),
                      if (pans.isNotEmpty) _buildHSlider(pans[0]),

                      // Scenario 3 Add Pan Button
                      if (_scenario == 3 &&
                          pans.length == 1 &&
                          _addPanBtnActive)
                        Positioned(
                          left: pans[0].x + pans[0].w + 30,
                          top: pans[0].y + pans[0].h / 2 - 25,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pans.add(
                                  Pan(
                                    pans[0].x + pans[0].w + 110,
                                    pans[0].y,
                                    pans[0].w,
                                    pans[0].h,
                                    pans[0].cols,
                                    pans[0].rows,
                                  ),
                                );
                                _addPanBtnActive = false;
                              });
                              _playSound('alert');
                              if (_scenario == 3) _checkStepValidation();
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.orangeAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // === Fixed Action Layer Over Canvas ===
            // Placing Draggables and Buttons here PREVENTS gesture conflicts with InteractiveViewer
            // and ensures tiles drag flawlessly without scale issues.

            // Mode Toggle (S4/S5 only) (Fixed to Canvas Top-Center)
            if (_scenario >= 4 && !_showFinalAnswer)
              Positioned(
                top: 80,
                left:
                    _isSidebarOpen
                        ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 120
                        : screenWidth / 2 - 120,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(16),
                    fillColor: _mode == 'shade' ? Colors.blue : Colors.orange,
                    selectedColor: Colors.white,
                    color: Colors.white54,
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      minWidth: 120,
                    ),
                    isSelected: [_mode == 'shade', _mode == 'select'],
                    onPressed: (index) {
                      setState(() {
                        _mode = index == 0 ? 'shade' : 'select';
                      });
                      _playSound('click');
                    },
                    children: [
                      Text(
                        getString('modeShadeBtn'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        getString('modeSelectBtn'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            // === Stacked Bottom UI (Controls + HUD) ===
            Positioned(
              bottom: 24,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Unified Control Panel (Scenarios 4/5 Step 1+ OR Final Answers)
                  if ((_scenario >= 4 && _step >= 1) || _showFinalAnswer)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 15),
                          ],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 24,
                          runSpacing: 16,
                          children: [
                            // Only show Tray in interactive mode
                            if (_scenario >= 4 && _step >= 1) ...[
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    getString('trayText'),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(10, (index) {
                                      String val = index.toString();
                                      return Draggable<String>(
                                        data: val,
                                        // Required wrap with transparent Material so it drags accurately across the canvas
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: _buildTile(
                                            val,
                                            isDragging: true,
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _buildTile(val),
                                        ),
                                        onDragStarted:
                                            () => _playSound('click'),
                                        child: _buildTile(val),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              Container(
                                width: 2,
                                height: 80,
                                color: Colors.white24,
                              ),
                            ],

                            // Fraction Drop Zones
                            _buildFractionBox(),

                            // Check Work Button & Feedback
                            if (_scenario >= 4 &&
                                _step >= 1 &&
                                !_isSuccessPopupVisible) ...[
                              Container(
                                width: 2,
                                height: 80,
                                color: Colors.white24,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle),
                                    label: Text(getString('checkWorkBtn')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10b981),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 6,
                                    ),
                                    onPressed: _checkWork,
                                  ),
                                  if (feedbackText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        feedbackText,
                                        style: TextStyle(
                                          color: feedbackColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // 2. Next Step Button
                  if (_scenario >= 4 && _step == 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(getString('nextBtn')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10b981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 28,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 10,
                        ),
                        onPressed: () {
                          _advanceStep();
                          _playSound('click');
                        },
                      ),
                    ),

                  // 3. Mini HUD
                  if (_step < currentSteps.length && _scenario < 6)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      constraints: const BoxConstraints(maxWidth: 700),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x666366f1)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x336366f1), blurRadius: 25),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF818CF8),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              currentSteps[_step]['hud']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // === Sidebar ===
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Material(
                elevation:
                    16, // The Sidebar causes shadow/zIndex overlap on things mapped behind it
                color: const Color(0xFF1E293B).withOpacity(0.95),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          80,
                          20,
                          10,
                        ), // Padding adjusted for top icons
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getString('appTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getString('appSubtitle'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Language and Reset Controls (Below Header)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.language, size: 18),
                                label: Text(getString('langBtn')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF334155),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _toggleLanguage,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.refresh, size: 18),
                                label: Text(getString('resetBtn')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(
                                    0.2,
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _resetLab,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Colors.white24, height: 1),

                      // Scenario Dropdown & Body
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              getString('selectScenario'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
                                  dropdownColor: const Color(0xFF0F172A),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items:
                                      [1, 2, 3, 4, 5].map((int val) {
                                        return DropdownMenuItem<int>(
                                          value: val,
                                          child: Text(
                                            getString('s${val}_title'),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (val) {
                                    if (val != null) _loadScenario(val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Objective Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        getString('objectiveLbl'),
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    getString('s${_scenario}_obj'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Steps List
                            Column(
                              children: List.generate(currentSteps.length, (
                                index,
                              ) {
                                bool isPast = index < _step;
                                bool isCurrent = index == _step;

                                Color bgColor =
                                    isPast
                                        ? const Color(0x4D1E293B)
                                        : (isCurrent
                                            ? const Color(0x1AF43F5E)
                                            : const Color(0x331E293B));
                                Color borderColor =
                                    isCurrent
                                        ? Colors.redAccent.withOpacity(0.5)
                                        : Colors.white12;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow:
                                        isCurrent
                                            ? [
                                              BoxShadow(
                                                color: Colors.redAccent
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isPast)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.greenAccent,
                                          size: 28,
                                        )
                                      else
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color:
                                                isCurrent
                                                    ? Colors.redAccent
                                                    : Colors.white12,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color:
                                                  isCurrent
                                                      ? Colors.white
                                                      : Colors.white54,
                                              fontWeight: FontWeight.bold,
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
                                              '${getString('stepLabel')} ${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            _htmlText(
                                              currentSteps[index]['text']!,
                                              TextStyle(
                                                color:
                                                    isPast
                                                        ? Colors.white70
                                                        : (isCurrent
                                                            ? Colors.white
                                                            : Colors.white38),
                                                fontSize: 13,
                                                height: 1.5,
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
                          ],
                        ),
                      ),

                      // Footer
                      const Divider(color: Colors.white24, height: 1),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "© ZeroScienceLab - Fall in love with math and Science",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // === Top Left Controls (Menu Icon) ===
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: MediaQuery.of(context).padding.left + 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                  _playSound('pop');
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // === Shutter Screen / Cinematic Curtain ===
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _isShutterOpen ? -screenHeight : 0,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(
                color: const Color(0xFF020617),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            screenHeight -
                            MediaQuery.of(context).padding.vertical,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6366f1,
                                    ).withOpacity(0.6),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: Color(0xFF6366f1),
                                size: 72,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              getString('appTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              getString('appSubtitle'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 64),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.play_circle_fill,
                                size: 28,
                              ),
                              label: Text(
                                getString('enterLab'),
                                style: const TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366f1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 10,
                                shadowColor: const Color(0xFF6366f1),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isShutterOpen = true;
                                });
                                _playSound('shutter');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // === Draggable Compact Success Popup (Scrollable) ===
            if (_isSuccessPopupVisible)
              Positioned(
                left: _popupOffset.dx,
                top: _popupOffset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _popupOffset += details.delta;
                    });
                  },
                  child: Material(
                    color: Colors.transparent,
                    elevation: 30, // Elevated well above curtain/sidebar
                    child: Container(
                      width: 320,
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.8,
                      ), // Avoid overflowing tall content
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10b981),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top bar for dragging and close icon
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.drag_indicator,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => _isSuccessPopupVisible = false,
                                    );
                                    _playSound('click');
                                  },
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.celebration,
                                      color: Color(0xFF10b981),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      getString('chapterComplete'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      getString('s5_success'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh),
                                      label: Text(getString('resetBtn')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6366f1,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      onPressed: _resetLab,
                                    ),
                                  ],
                                ),
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

  Widget _buildTile(String val, {bool isDragging = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDragging ? Colors.pinkAccent : Colors.white24,
          width: 2,
        ),
        boxShadow:
            isDragging
                ? [
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ]
                : null,
      ),
      alignment: Alignment.center,
      child: Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class PanPainter extends CustomPainter {
  final List<Pan> pans;
  final bool showFinalAnswer;
  final int scenario;

  PanPainter({
    required this.pans,
    this.showFinalAnswer = false,
    this.scenario = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid lines to verify workspace boundaries
    Paint bgGridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.03)
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), bgGridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), bgGridPaint);
    }

    // Draw the pans
    for (var p in pans) {
      // Draw Base Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.x - 5, p.y + 5, p.w + 10, p.h + 10),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0xFF1c1917),
      );
      // Draw Rim
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.x - 10, p.y - 10, p.w + 20, p.h + 20),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF78350f),
      );
      // Draw Inner Base
      canvas.drawRect(
        Rect.fromLTWH(p.x, p.y, p.w, p.h),
        Paint()..color = const Color(0xFF451a03),
      );

      double colW = p.w / p.cols;
      double rowH = p.h / p.rows;

      // Draw Shaded Columns (Blue)
      Paint shadePaint = Paint()..color = const Color(0xAA38BDF8);
      for (int c in p.shadedCols) {
        canvas.drawRect(
          Rect.fromLTWH(p.x + c * colW, p.y, colW, p.h),
          shadePaint,
        );
      }

      // Draw Selected Rows (Yellow)
      Paint selectPaint = Paint()..color = const Color(0x99FACC15);
      for (int r in p.selectedRows) {
        canvas.drawRect(
          Rect.fromLTWH(p.x, p.y + r * rowH, p.w, rowH),
          selectPaint,
        );
      }

      // Draw Overlap (Green + Hatch)
      Paint overlapPaint = Paint()..color = const Color(0xE616A34A);
      Paint hatchPaint =
          Paint()
            ..color = Colors.black26
            ..strokeWidth = 2;

      for (int c in p.shadedCols) {
        for (int r in p.selectedRows) {
          Rect overlapRect = Rect.fromLTWH(
            p.x + c * colW,
            p.y + r * rowH,
            colW,
            rowH,
          );
          canvas.drawRect(overlapRect, overlapPaint);

          // Hatching
          canvas.save();
          canvas.clipRect(overlapRect);
          for (double i = -colW; i < colW + rowH; i += 10) {
            canvas.drawLine(
              Offset(overlapRect.left + i, overlapRect.top),
              Offset(overlapRect.left + i - rowH, overlapRect.bottom),
              hatchPaint,
            );
            canvas.drawLine(
              Offset(overlapRect.left + i, overlapRect.top),
              Offset(overlapRect.left + i + rowH, overlapRect.bottom),
              hatchPaint,
            );
          }
          canvas.restore();
        }
      }

      // Grid Lines
      Paint gridPaint =
          Paint()
            ..color = const Color(0xFF271002)
            ..strokeWidth = 3;
      for (int c = 1; c < p.cols; c++) {
        canvas.drawLine(
          Offset(p.x + c * colW, p.y),
          Offset(p.x + c * colW, p.y + p.h),
          gridPaint,
        );
      }
      for (int r = 1; r < p.rows; r++) {
        canvas.drawLine(
          Offset(p.x, p.y + r * rowH),
          Offset(p.x + p.w, p.y + r * rowH),
          gridPaint,
        );
      }

      // Outer Border
      canvas.drawRect(
        Rect.fromLTWH(p.x, p.y, p.w, p.h),
        Paint()
          ..color = const Color(0xFF92400e)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      // Final Answer Numbering Overlay (if active)
      if (showFinalAnswer && scenario < 4) {
        int count = 1;
        // Count overlapping blocks first
        for (int r in p.selectedRows) {
          for (int c in p.shadedCols) {
            _drawCircleText(
              canvas,
              '${count++}',
              Offset(p.x + c * colW + colW / 2, p.y + r * rowH + rowH / 2),
              Colors.black54,
              Colors.white,
            );
          }
        }
      }
    }
  }

  void _drawCircleText(
    Canvas canvas,
    String text,
    Offset center,
    Color bgColor,
    Color textColor,
  ) {
    canvas.drawCircle(center, 18, Paint()..color = bgColor);

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant PanPainter oldDelegate) => true;
}
