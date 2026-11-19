// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DataDetectivesApp());
}

// --- LOCALIZATION DATA EXACTLY FROM HTML ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': 'Data Detectives: Uncovering Stories in Numbers',
    'appSubtitle': 'Class 7 • CONNECTING THE DOTS...',
    'enterLab': 'Enter Lab',
    'reset': 'Reset',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'actTitle': 'Action:',
    'obsLbl': 'Observation:',
    'learnLbl': 'Learning:',
    'finalSuccessTitle': 'Case Closed!',
    'finalSuccessDesc': 'You have successfully mastered interpreting data and drawing inferences.',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
    'btn_equalize': 'EQUALIZE', 'btn_line_up': 'LINE UP', 'btn_scan': 'SCAN MEDIAN',
    'btn_analyze_s': 'ANALYZE SHUBMAN', 'btn_analyze_y': 'ANALYZE YASHASVI',
    'btn_observe': 'OBSERVE & CONTINUE', 'btn_bring_b': 'BRING GROUP B',
    'guava_label': 'guavas', 'basket_label': 'Basket',
    
    's1_eq_title': 'EQUALIZER 3000', 's1_mean_lbl': 'MEAN = ', 's1_group_a_lbl': 'GROUP A (5 members)', 's1_group_b_lbl': 'GROUP B (6 members)', 's1_summary': 'Even with 30 total guavas each, Group A gets a bigger share (fewer members)!',
    's2_median_height': 'Median Height:', 's2_med_val1': '170 cm', 's2_med_val2': '(170+173)/2 = 171.5 cm',
    's3_mean_mode': 'MEAN-MODE', 's3_median_mode': 'MEDIAN-MODE', 's3_shubman': 'SHUBMAN', 's3_yashasvi': 'YASHASVI', 's3_mean_val': 'Mean:', 's3_median_val': 'Median:', 's3_final_report': 'FINAL COMPARISON REPORT', 's3_summary': 'Yashasvi has a higher mean AND a higher median. A more solid performance overall!',
    's4_yahapur': 'Yahapur', 's4_wahapur': 'Wahapur', 's4_jan': 'Jan', 's4_feb': 'Feb', 's4_mar': 'Mar', 's4_apr': 'Apr', 's4_month': 'Month', 's4_table_title': 'Monthly Park Attendance', 's4_summary': 'Wahapur has more park attendance variation (bigger peaks and valleys).', 's4_palette': 'BLOCK PALETTE', 's4_drop_here': 'DROP HERE',
    's5_grade6': 'Grade 6', 's5_grade7': 'Grade 7', 's5_grade8': 'Grade 8', 's5_school_a': 'School A', 's5_school_b': 'School B', 's5_hypo_title': 'FINAL HYPOTHESIS', 's5_drag_clue': 'DRAG CLUE HERE', 's5_hover_details': 'Hover for details',
    's5_clue1': 'Both schools are in the same city and have similar weather.', 's5_clue2': 'School B has a well-funded \'Nutrition for All\' program providing free lunches.', 's5_clue3': 'The favorite color of students in School A is blue, while in School B it is green.', 's5_clue_prefix': 'CLUE',

    's1_title': '1. The Great Guava Equalizer', 's1_obj': 'To physically understand the concept of Arithmetic Mean as a \'fair-share\' value.',
    's1_hud1': 'DRAG all 5 Group A baskets onto the Equalizer Machine.', 's1_task1': 'DRAG each basket from Group A (3, 8, 10, 5, 4) onto the input platform.', 's1_obs1': 'Baskets are loaded.', 's1_learn1': 'We prepare data points to find their center.',
    's1_hud2': 'CLICK the green EQUALIZE button.', 's1_task2': 'CLICK the green \'EQUALIZE\' button on the machine.', 's1_obs2': 'The machine collects all 30 guavas and redistributes exactly 6 to each basket.', 's1_learn2': 'Mean is a \'fair-share\'. Total guavas (30) ÷ Total baskets (5) = 6.',
    's1_hud3': 'DRAG all 6 Group B baskets onto the input belt.', 's1_task3': 'DRAG all 6 baskets from Group B (5, 4, 6, 3, 4, 8) to the machine.', 's1_obs3': 'Baskets are loaded.', 's1_learn3': 'A new dataset is ready.',
    's1_hud4': 'CLICK the EQUALIZE button again.', 's1_task4': 'CLICK \'EQUALIZE\' again.', 's1_obs4': 'The machine collects 30 guavas and redistributes 5 to each basket.', 's1_learn4': 'Both groups had 30 guavas, but Group A\'s mean (6) is higher because they shared among fewer baskets (5).',
    's1_hud5': 'OBSERVE the final results.', 's1_task5': 'CLICK \'OBSERVE & CONTINUE\' to finish.', 's1_obs5': 'The mean mathematically levels out unequal numbers.', 's1_learn5': 'Arithmetic mean balances the values.', 's1_final': 'Great job! The Equalizer Machine shows how the mean finds a balanced, fair-share value.',

    's2_title': '2. The Outlier\'s Wobbly Bridge', 's2_obj': 'To visualize how an outlier significantly affects the mean but has little effect on the median.',
    's2_hud1': 'DRAG the 4 height blocks onto the Bridge.', 's2_task1': 'DRAG blocks (165, 170, 173, 175) onto the Wobbly Bridge.', 's2_obs1': 'The bridge balances out. Mean height is 170.75 cm.', 's2_learn1': 'The mean represents the balance point of these heights.',
    's2_hud2': 'DRAG the short 118cm block onto the bridge.', 's2_task2': 'A new member arrives! DRAG the 118cm block onto the bridge.', 's2_obs2': 'The bridge tilts drastically! The mean drops to 160.2 cm.', 's2_learn2': 'An extreme value (outlier) pulls the mean heavily.',
    's2_hud3': 'CLICK \'LINE UP\' to arrange the blocks.', 's2_task3': 'CLICK \'LINE UP\' to sort them by height.', 's2_obs3': 'The blocks arrange themselves from shortest to tallest.', 's2_learn3': 'Sorting is the first step to find the median.',
    's2_hud4': 'CLICK \'SCAN MEDIAN\' to find the middle.', 's2_task4': 'CLICK \'SCAN MEDIAN\' to identify the middle value.', 's2_obs4': 'The laser highlights 170cm as the middle block.', 's2_learn4': 'The median is 170cm, which didn\'t drop as drastically as the mean.',
    's2_hud5': 'DRAG the 118cm block away.', 's2_task5': 'DRAG the outlier block away to re-scan the median.', 's2_obs5': 'The laser centers on (170+173)/2 = 171.5 cm.', 's2_learn5': 'The outlier barely affected the median. Median is more stable!', 's2_final': 'Excellent! You proved that the Median is less sensitive to extreme outliers than the Mean.',

    's3_title': '3. The Cricket Performance Analyzer', 's3_obj': 'To use mean and median to compare two datasets and draw different conclusions.',
    's3_hud1': 'DRAG Shubman\'s towers into the Analyzer.', 's3_task1': 'DRAG the 5 towers (23, 7, 10, 52, 18) into the machine.', 's3_obs1': 'Shubman\'s data is loaded.', 's3_learn1': 'We will analyze Shubman\'s performance.',
    's3_hud2': 'CLICK \'ANALYZE SHUBMAN\' to process scores.', 's3_task2': 'CLICK \'ANALYZE SHUBMAN\'.', 's3_obs2': 'Mean = 22. Median = 18.', 's3_learn2': 'The machine calculates both central tendencies.',
    's3_hud3': 'DRAG Yashasvi\'s towers into the Analyzer.', 's3_task3': 'DRAG the 4 towers (26, 53, 2, 15) into the machine.', 's3_obs3': 'Yashasvi\'s data is loaded.', 's3_learn3': 'Now analyzing a different dataset.',
    's3_hud4': 'CLICK \'ANALYZE YASHASVI\' to process scores.', 's3_task4': 'CLICK \'ANALYZE YASHASVI\'.', 's3_obs4': 'Mean = 24. Median = 20.5.', 's3_learn4': 'Yashasvi has a higher mean AND median.',
    's3_hud5': 'OBSERVE the results side-by-side.', 's3_task5': 'CLICK \'OBSERVE & CONTINUE\' to finish.', 's3_obs5': 'Both measures suggest Yashasvi performed better.', 's3_learn5': 'Different statistical measures help validate arguments robustly.', 's3_final': 'Perfect! You used Mean and Median together to confidently conclude who had the better series.',

    's4_title': '4. The City Park Planner', 's4_obj': 'To construct a clustered bar graph and make a visual comparison.',
    's4_hud1': 'DRAG Jan blocks (G25, P19) to Slot 1.', 's4_task1': 'DRAG the Green (25) and Purple (19) blocks for January into the first slot.', 's4_obs1': 'The first cluster is formed.', 's4_learn1': 'Clustered bars group related data together.',
    's4_hud2': 'DRAG Feb blocks (G28, P10) to Slot 2.', 's4_task2': 'DRAG Green (28) and Purple (10) for February to the next slot.', 's4_obs2': 'The second cluster is formed.', 's4_learn2': 'We are building a visual timeline.',
    's4_hud3': 'DRAG Mar blocks (G20, P30) to Slot 3.', 's4_task3': 'DRAG Green (20) and Purple (30) for March to the third slot.', 's4_obs3': 'The third cluster is formed.', 's4_learn3': 'The graph makes numerical differences obvious.',
    's4_hud4': 'DRAG Apr blocks (G26, P12) to Slot 4.', 's4_task4': 'DRAG Green (26) and Purple (12) for April to the last slot.', 's4_obs4': 'The graph is complete.', 's4_learn4': 'Visualizing data reveals overall trends.',
    's4_hud5': 'OBSERVE the graph. Which has more variation?', 's4_task5': 'CLICK \'OBSERVE & CONTINUE\'.', 's4_obs5': 'Purple bars jump wildly. Green bars are stable.', 's4_learn5': 'Graphs allow us to instantly \'see\' data variability.', 's4_final': 'Brilliant! You built a graph and visually inferred that Wahapur (Purple) has more extreme variation in park attendance.',

    's5_title': '5. The Great Height Mystery', 's5_obj': 'To analyze dot plots and use contextual clues to draw an inference.',
    's5_hud1': 'CLICK the Grade 6, 7, and 8 Tabs.', 's5_task1': 'CLICK on the different tabs to view dot plots.', 's5_obs1': 'School B (Green) dots are consistently to the right.', 's5_learn1': 'The data shows a consistent pattern across grades.',
    's5_hud2': 'DRAG Clue cards under the Magnifying Glass.', 's5_task2': 'DRAG Clue 1 to the glass.', 's5_obs2': 'Clue 1: Same city, same weather.', 's5_learn2': 'This doesn\'t explain a difference between them.',
    's5_hud3': 'DRAG Clue 2 and Clue 3 under the glass.', 's5_task3': 'Read Clues 2 and 3 using the glass.', 's5_obs3': 'Clue 2: School B has a nutrition program.', 's5_learn3': 'We must identify which clue logically impacts height.',
    's5_hud4': 'DRAG Clue 2 to the FINAL HYPOTHESIS Slot.', 's5_task4': 'DRAG the most plausible clue card into the \'Final Hypothesis\' slot.', 's5_obs4': 'You selected a clue.', 's5_learn4': 'Nutrition directly affects growth. Data drives hypothesis generation.',
    's5_hud5': 'OBSERVE the conclusion.', 's5_task5': 'CLICK \'OBSERVE & CONTINUE\'.', 's5_obs5': 'You solved the mystery logically.', 's5_learn5': 'Data analysis combines math with real-world context.', 's5_final': 'Case closed! You proved that good data analysts look beyond the numbers to find the real-world story.',
  },
  'hi': {
    'shutterTitle': 'डेटा जासूस: संख्याओं में कहानियों को उजागर करना', 'appSubtitle': 'कक्षा 7 • बिंदुओं को जोड़ना...', 'enterLab': 'लैब में प्रवेश करें',
    'reset': 'रीसेट', 'selectScenario': 'परिदृश्य चुनें', 'stepLabel': 'चरण', 'doneBtn': 'पूर्ण', 'actTitle': 'कार्य:', 'obsLbl': 'अवलोकन:', 'learnLbl': 'सीख:', 
    'finalSuccessTitle': 'केस बंद!', 'finalSuccessDesc': 'आपने डेटा की व्याख्या करना और निष्कर्ष निकालना सफलतापूर्वक सीख लिया है।', 'finalRestartBtn': 'पुनरारंभ करें',
    'footer': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
    'btn_equalize': 'बराबर करें', 'btn_line_up': 'लाइन में लगाएं', 'btn_scan': 'माध्यिका खोजें', 'btn_analyze_s': 'शुभमन का विश्लेषण करें', 'btn_analyze_y': 'यशस्वी का विश्लेषण करें', 'btn_observe': 'देखें और आगे बढ़ें', 'btn_bring_b': 'ग्रुप B लाएं',
    'guava_label': 'अमरूद', 'basket_label': 'टोकरी',
    's1_eq_title': 'इक्वलाइज़र 3000', 's1_mean_lbl': 'माध्य = ', 's1_group_a_lbl': 'समूह A (5 सदस्य)', 's1_group_b_lbl': 'समूह B (6 सदस्य)', 's1_summary': '30 अमरूद होने पर भी, समूह A को बड़ा हिस्सा मिलता है!',
    's2_median_height': 'माध्यिका ऊंचाई:', 's2_med_val1': '170 सेमी', 's2_med_val2': '(170+173)/2 = 171.5 सेमी',
    's3_mean_mode': 'माध्य-मोड', 's3_median_mode': 'माध्यिका-मोड', 's3_shubman': 'शुभमन', 's3_yashasvi': 'यशस्वी', 's3_mean_val': 'माध्य:', 's3_median_val': 'माध्यिका:', 's3_final_report': 'अंतिम तुलना रिपोर्ट', 's3_summary': 'यशस्वी का माध्य और माध्यिका दोनों अधिक हैं।',
    's4_yahapur': 'यहापुर', 's4_wahapur': 'वहापुर', 's4_jan': 'जनवरी', 's4_feb': 'फरवरी', 's4_mar': 'मार्च', 's4_apr': 'अप्रैल', 's4_month': 'महीना', 's4_table_title': 'मासिक उपस्थिति', 's4_summary': 'वहापुर में उपस्थिति भिन्नता अधिक है।', 's4_palette': 'ब्लॉक पैलेट', 's4_drop_here': 'यहाँ छोड़ें',
    's5_grade6': 'कक्षा 6', 's5_grade7': 'कक्षा 7', 's5_grade8': 'कक्षा 8', 's5_school_a': 'स्कूल A', 's5_school_b': 'स्कूल B', 's5_hypo_title': 'अंतिम परिकल्पना', 's5_drag_clue': 'सुराग यहाँ खींचें', 's5_hover_details': 'विवरण के लिए होवर करें',
    's5_clue1': 'समान शहर, समान मौसम।', 's5_clue2': 'स्कूल B में मुफ्त पोषण कार्यक्रम है।', 's5_clue3': 'अलग-अलग पसंदीदा रंग।', 's5_clue_prefix': 'सुराग',

    's1_title': '1. अमरूद का बराबर होना', 's1_obj': 'समांतर माध्य की अवधारणा को समझना।',
    's1_hud1': 'सभी 5 टोकरियों को बेल्ट पर खींचें।', 's1_task1': 'ग्रुप A की टोकरियों को खींचें।', 's1_obs1': 'लोड हो गईं।', 's1_learn1': 'डेटा तैयार।',
    's1_hud2': 'बराबर करें बटन पर क्लिक करें।', 's1_task2': 'बराबर करें दबाएं।', 's1_obs2': 'अमरूद बराबर बंटे।', 's1_learn2': 'माध्य = उचित हिस्सा।',
    's1_hud3': 'ग्रुप B की 6 टोकरियों को खींचें।', 's1_task3': 'ग्रुप B खींचें।', 's1_obs3': 'लोड हो गईं।', 's1_learn3': 'नया डेटा।',
    's1_hud4': 'फिर से बराबर करें बटन पर क्लिक करें।', 's1_task4': 'बराबर करें दबाएं।', 's1_obs4': 'अमरूद बंटे।', 's1_learn4': 'अधिक लोग = छोटा हिस्सा।',
    's1_hud5': 'अंतिम परिणाम देखें।', 's1_task5': 'परिणाम देखें।', 's1_obs5': 'माध्य संतुलित करता है।', 's1_learn5': 'समांतर माध्य संतुलन बनाता है।', 's1_final': 'बहुत बढ़िया! मशीन दिखाती है कि माध्य कैसे काम करता है।',

    's2_title': '2. आउटलायर का डगमगाता पुल', 's2_obj': 'आउटलायर माध्य को कैसे प्रभावित करता है।',
    's2_hud1': '4 ऊंचाई ब्लॉकों को पुल पर खींचें।', 's2_task1': 'ब्लॉक खींचें।', 's2_obs1': 'पुल संतुलित।', 's2_learn1': 'माध्य संतुलन है।',
    's2_hud2': 'छोटे ब्लॉक को पुल पर खींचें।', 's2_task2': 'आउटलायर खींचें।', 's2_obs2': 'पुल झुका।', 's2_learn2': 'चरम मूल्य माध्य को खींचता है।',
    's2_hud3': 'लाइन में लगाने के लिए क्लिक करें।', 's2_task3': 'लाइन में लगाएं।', 's2_obs3': 'क्रमबद्ध।', 's2_learn3': 'माध्यिका के लिए छंटाई।',
    's2_hud4': 'माध्यिका खोजने के लिए स्कैन करें।', 's2_task4': 'स्कैन करें।', 's2_obs4': 'मध्य मूल्य।', 's2_learn4': 'माध्यिका मिली।',
    's2_hud5': 'ब्लॉक को दूर खींचें।', 's2_task5': 'आउटलायर हटाएं।', 's2_obs5': 'माध्यिका स्थिर।', 's2_learn5': 'माध्यिका अधिक स्थिर है।', 's2_final': 'उत्कृष्ट! माध्यिका अधिक स्थिर है।',

    's3_title': '3. क्रिकेट प्रदर्शन विश्लेषक', 's3_obj': 'तुलना करने के लिए माध्य और माध्यिका का उपयोग करना।',
    's3_hud1': 'शुभमन के टावरों को खींचें।', 's3_task1': 'शुभमन डेटा खींचें।', 's3_obs1': 'लोड।', 's3_learn1': 'तैयार।',
    's3_hud2': 'विश्लेषण करने के लिए क्लिक करें।', 's3_task2': 'विश्लेषण करें।', 's3_obs2': 'माध्य=22, माध्यिका=18.', 's3_learn2': 'गणना पूरी।',
    's3_hud3': 'यशस्वी के टावरों को खींचें।', 's3_task3': 'यशस्वी डेटा खींचें।', 's3_obs3': 'लोड।', 's3_learn3': 'तैयार।',
    's3_hud4': 'विश्लेषण करने के लिए क्लिक करें।', 's3_task4': 'विश्लेषण करें।', 's3_obs4': 'माध्य=24, माध्यिका=20.5.', 's3_learn4': 'अधिक मूल्य।',
    's3_hud5': 'परिणामों को एक साथ देखें।', 's3_task5': 'परिणाम देखें।', 's3_obs5': 'यशस्वी बेहतर।', 's3_learn5': 'तुलना में मदद।', 's3_final': 'सही! आपने विश्वासपूर्वक निष्कर्ष निकाला।',

    's4_title': '4. सिटी पार्क प्लानर', 's4_obj': 'बार ग्राफ बनाना और तुलना करना।',
    's4_hud1': 'जनवरी ब्लॉक खींचें।', 's4_task1': 'जनवरी ब्लॉक खींचें।', 's4_obs1': 'समूह 1।', 's4_learn1': 'समूहीकरण।',
    's4_hud2': 'फरवरी ब्लॉक खींचें।', 's4_task2': 'फरवरी ब्लॉक खींचें।', 's4_obs2': 'समूह 2।', 's4_learn2': 'समयरेखा।',
    's4_hud3': 'मार्च ब्लॉक खींचें।', 's4_task3': 'मार्च ब्लॉक खींचें।', 's4_obs3': 'समूह 3।', 's4_learn3': 'अंतर स्पष्ट।',
    's4_hud4': 'अप्रैल ब्लॉक खींचें।', 's4_task4': 'अप्रैल ब्लॉक खींचें।', 's4_obs4': 'पूरा।', 's4_learn4': 'रुझान देखें।',
    's4_hud5': 'ग्राफ देखें।', 's4_task5': 'ग्राफ देखें।', 's4_obs5': 'बैंगनी में बदलाव।', 's4_learn5': 'दृश्य भिन्नता।', 's4_final': 'शानदार! वहापुर में अधिक भिन्नता है।',

    's5_title': '5. महान ऊंचाई का रहस्य', 's5_obj': 'डॉट प्लॉट का विश्लेषण करना और संदर्भ का उपयोग करना।',
    's5_hud1': 'टैब पर क्लिक करें।', 's5_task1': 'टैब पर क्लिक करें।', 's5_obs1': 'B लंबा है।', 's5_learn1': 'पैटर्न देखा।',
    's5_hud2': 'सुराग 1 को लेंस के नीचे खींचें।', 's5_task2': 'सुराग 1 पढ़ें।', 's5_obs2': 'समान शहर।', 's5_learn2': 'अंतर नहीं बताता।',
    's5_hud3': 'सुराग 2 और 3 पढ़ें।', 's5_task3': 'सुराग 2 व 3 पढ़ें।', 's5_obs3': 'पोषण कार्यक्रम मिला।', 's5_learn3': 'तार्किक प्रभाव।',
    's5_hud4': 'सबसे अच्छे सुराग को खींचें।', 's5_task4': 'सही सुराग खींचें।', 's5_obs4': 'चुना गया।', 's5_learn4': 'पोषण = विकास।',
    's5_hud5': 'निष्कर्ष देखें।', 's5_task5': 'निष्कर्ष देखें।', 's5_obs5': 'रहस्य सुलझा।', 's5_learn5': 'वास्तविक दुनिया का संदर्भ।', 's5_final': 'केस बंद! आपने रहस्य सुलझा लिया।'
  }
};

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _snapPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3'; 
  static const String _snapUrl = 'audio/class7/mixkit_392.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  static Future<void> playClick() async => _play(_clickPlayer, _clickUrl);
  static Future<void> playSuccess() async => _play(_successPlayer, _successUrl);
  static Future<void> playError() async => _play(_errorPlayer, _errorUrl);
  static Future<void> playWhir() async => _play(_fxPlayer, _alertUrl);
  static Future<void> playSnap() async => _play(_snapPlayer, _snapUrl);
  static Future<void> playShutter() async => _play(_shutterPlayer, _shutterUrl);

  static Future<void> _play(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(AssetSource(url), volume: 0.5);
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }
}

// --- STATE MANAGEMENT ---
class LabState extends ChangeNotifier {
  String lang = 'en';
  bool isSidebarOpen = true;
  bool showIntro = true;
  
  int scenario = 1;
  int step = 0;
  bool simCompleted = false;

  String hudMessage = "";
  Timer? hudTimer;

  Offset activeStepPos = const Offset(20, 100);
  Offset successPopupPos = const Offset(200, 100);
  bool showSuccessPopup = false;

  double animProgress = 0.0;
  bool isAnimating = false;
  String animMode = '';
  double pointerX = 0;
  double pointerY = 0;

  // Custom Pan/Zoom State
  double canvasScale = 1.0;
  Offset canvasPan = Offset.zero;

  List<SimItem> draggables = [];
  List<DropZone> dropzones = [];
  List<SimButton> buttons = [];
  Map<String, dynamic> data = {};

  String t(String key) => translations[lang]?[key] ?? key;

  void setLang(String newLang) {
    lang = newLang;
    AudioEngine.playClick();
    notifyListeners();
  }

  void showHUD(String msg) {
    hudMessage = msg;
    notifyListeners();
    hudTimer?.cancel();
    hudTimer = Timer(const Duration(seconds: 4), () {
      hudMessage = "";
      notifyListeners();
    });
  }

  void loadScenario(int sId) {
    scenario = sId;
    step = 0;
    simCompleted = false;
    showSuccessPopup = false;
    isAnimating = false;
    draggables.clear();
    dropzones.clear();
    buttons.clear();
    data.clear();
    
    canvasScale = 1.0;
    canvasPan = Offset.zero;
    
    _initScenarioData();
    _updateButtons();
    if (sId <= 5) {
      String title = t('s${sId}_hud1');
      if (title.startsWith('s')) title = t('s${sId}_title');
      showHUD(title);
    }
    notifyListeners();
  }

  void advanceStep() {
    step++;
    _updateButtons();
    if (step < 5) showHUD(t('s${scenario}_hud${step+1}'));
    notifyListeners();
  }

  void completeScenario() {
    step = 5;
    simCompleted = true;
    buttons.clear();
    AudioEngine.playSuccess();
    showHUD(t('finalSuccessTitle'));
    if (scenario == 5) {
      showSuccessPopup = true;
    }
    notifyListeners();
  }

  void resetActivity() {
    lang = 'en'; 
    showIntro = true; 
    canvasScale = 1.0;
    canvasPan = Offset.zero;
    AudioEngine.playShutter();
    loadScenario(1);
  }

  void startAnimation(String mode) {
    isAnimating = true;
    animProgress = 0.0;
    animMode = mode;
    AudioEngine.playWhir();
    notifyListeners();
  }

  void _updateButtons() {
    buttons.clear();
    if (scenario == 1) {
      if (step == 1 && data['showBButton'] != true) buttons.add(SimButton('btn_equalize', -50, 40, 140, 40));
      if (step == 1 && data['showBButton'] == true) buttons.add(SimButton('btn_bring_b', 0, 180, 180, 40, color: Colors.orange));
      if (step == 3) buttons.add(SimButton('btn_equalize', -50, 40, 140, 40));
      if (step == 4) buttons.add(SimButton('btn_observe', 0, 240, 240, 40));
    } else if (scenario == 2) {
      if (step == 2) buttons.add(SimButton('btn_line_up', -250, -150, 140, 40, color: Colors.orange));
      if (step == 3) buttons.add(SimButton('btn_scan', -250, -150, 160, 40, color: Colors.blue));
    } else if (scenario == 3) {
      if (step == 1) buttons.add(SimButton('btn_analyze_s', 0, 80, 200, 40));
      if (step == 3) buttons.add(SimButton('btn_analyze_y', 0, 80, 200, 40));
      if (step == 4) buttons.add(SimButton('btn_observe', 0, 180, 240, 40));
    } else if (scenario == 4) {
      if (step == 4) buttons.add(SimButton('btn_observe', 0, 240, 240, 40));
    } else if (scenario == 5) {
      if (step == 4) buttons.add(SimButton('btn_observe', 0, 220, 240, 40));
    }
  }

  void _initScenarioData() {
    if (scenario == 1) {
      List<int> valsA = [3, 8, 10, 5, 4];
      List<int> valsB = [5, 4, 6, 3, 4, 8];
      data['showBButton'] = false;
      for (int i = 0; i < valsA.length; i++) draggables.add(SimItem(id: 'A$i', val: valsA[i].toDouble(), x: -430.0 + i * 65.0, y: 150.0, group: 'A', w: 60, h: 60));
      for (int i = 0; i < valsB.length; i++) draggables.add(SimItem(id: 'B$i', val: valsB[i].toDouble(), x: -430.0 + i * 55.0, y: 9999.0, targetY: 9999.0, group: 'B', w: 60, h: 60));
      dropzones.add(DropZone(id: 'machine', x: -450.0, y: -40.0, w: 300.0, h: 80.0));
    } 
    else if (scenario == 2) {
      List<int> vals = [165, 170, 173, 175];
      List<Color> colors = [Colors.lightBlue, Colors.blue, Colors.orange, Colors.red];
      data['bridgeAngle'] = 0.0;
      data['laserY'] = -999.0;
      for (int i = 0; i < vals.length; i++) draggables.add(SimItem(id: 'b$i', val: vals[i].toDouble(), x: -300.0 + i * 60.0, y: 150.0, color: colors[i], w: 40, h: vals[i]/1.5));
      draggables.add(SimItem(id: 'outlier', val: 118.0, x: -60.0, y: 150.0, color: Colors.yellow, w: 40, h: 118.0/1.5));
      dropzones.add(DropZone(id: 'bridge', x: -200.0, y: 60.0, w: 400.0, h: 40.0, isBridge: true));
    }
    else if (scenario == 3) {
      List<int> sVals = [23, 7, 10, 52, 18];
      List<int> yVals = [26, 53, 2, 15];
      for (int i = 0; i < sVals.length; i++) draggables.add(SimItem(id: 's$i', val: sVals[i].toDouble(), x: -300.0 + i * 45.0, y: 150.0, group: 'S', w: 40, h: math.max(sVals[i]*2.5, 30.0)));
      for (int i = 0; i < yVals.length; i++) draggables.add(SimItem(id: 'y$i', val: yVals[i].toDouble(), x: -300.0 + i * 45.0, y: 9999.0, targetY: 9999.0, group: 'Y', w: 40, h: math.max(yVals[i]*2.5, 30.0)));
      dropzones.add(DropZone(id: 'analyzer', x: -350.0, y: -20.0, w: 200.0, h: 60.0));
    }
    else if (scenario == 4) {
      List<Map<String, dynamic>> mData = [
        {'m': 's4_jan', 'g': 25, 'p': 19}, {'m': 's4_feb', 'g': 28, 'p': 10},
        {'m': 's4_mar', 'g': 20, 'p': 30}, {'m': 's4_apr', 'g': 26, 'p': 12}
      ];
      double originX = 150.0, originY = -50.0, tW = 40.0, tH = 20.0;
      data['slots'] = [];
      for (int r = 0; r < mData.length; r++) {
        var d = mData[r];
        double gx = originX - (r * tW); double gy = originY + (r * tH);
        double px = originX + tW - (r * tW); double py = originY + tH + (r * tH);
        
        data['slots'].add({'id': '${d['m']}_g', 'val': (d['g'] as int).toDouble(), 'x': gx, 'y': gy, 'city': 'G', 'r': r, 'c': 0});
        data['slots'].add({'id': '${d['m']}_p', 'val': (d['p'] as int).toDouble(), 'x': px, 'y': py, 'city': 'P', 'r': r, 'c': 1});
        
        draggables.add(SimItem(id: 'D_${d['m']}_g', val: (d['g'] as int).toDouble(), x: 340.0, y: -50.0 + r*80.0, color: Colors.green, group: d['m'] as String, city: 'G', w: 50, h: math.max((d['g'] as int)*3.5, 30.0)));
        draggables.add(SimItem(id: 'D_${d['m']}_p', val: (d['p'] as int).toDouble(), x: 420.0, y: -50.0 + r*80.0, color: Colors.purple, group: d['m'] as String, city: 'P', w: 50, h: math.max((d['p'] as int)*3.5, 30.0)));
      }
      for (var s in data['slots']) dropzones.add(DropZone(id: s['id'], x: s['x'], y: s['y'], w: tW*2, h: tH*2, city: s['city'], slotR: s['r'], slotC: s['c']));
    }
    else if (scenario == 5) {
      data['activeTab'] = 0;
      data['tabsClicked'] = <int>{0};
      data['c1Revealed'] = false;
      data['c2Revealed'] = false;
      data['c3Revealed'] = false;
      data['step2Advanced'] = false;
      
      data['tabs'] = [
        {'x': -400.0, 'y': -190.0, 'w': 100.0, 'h': 35.0},
        {'x': -290.0, 'y': -190.0, 'w': 100.0, 'h': 35.0},
        {'x': -180.0, 'y': -190.0, 'w': 100.0, 'h': 35.0}
      ];

      draggables.add(SimItem(id: 'c1', val: 1.0, x: -280.0, y: 160.0, color: Colors.white, w: 90, h: 65, group: 's5_clue1'));
      draggables.add(SimItem(id: 'c2', val: 2.0, x: -150.0, y: 160.0, color: Colors.yellow[200]!, w: 90, h: 65, group: 's5_clue2'));
      draggables.add(SimItem(id: 'c3', val: 3.0, x: -20.0, y: 160.0, color: Colors.white, w: 90, h: 65, group: 's5_clue3'));
      
      dropzones.add(DropZone(id: 'mag_glass', x: 200.0, y: 170.0, w: 100.0, h: 100.0));
      dropzones.add(DropZone(id: 'hypo', x: 200.0, y: -100.0, w: 200.0, h: 160.0, snapTarget: const Offset(300.0, -20.0)));
    }
  }

  void checkSubStep() {
    if (scenario == 1) {
      if (step == 0 && draggables.where((d) => d.group == 'A').every((d) => d.isSnapped)) advanceStep();
      if (step == 2 && draggables.where((d) => d.group == 'B').every((d) => d.isSnapped)) advanceStep();
    } else if (scenario == 2) {
      if (step == 0 && draggables.where((d) => d.id != 'outlier').every((d) => d.isSnapped)) advanceStep();
      if (step == 1 && draggables.firstWhere((d) => d.id == 'outlier').isSnapped) advanceStep();
    } else if (scenario == 3) {
      if (step == 0 && draggables.where((d) => d.group == 'S').every((d) => d.isSnapped)) advanceStep();
      if (step == 2 && draggables.where((d) => d.group == 'Y').every((d) => d.isSnapped)) advanceStep();
    } else if (scenario == 4) {
      List<String> mArr = ['s4_jan', 's4_feb', 's4_mar', 's4_apr'];
      if (draggables.where((d) => d.group == mArr[step]).every((d) => d.isSnapped)) advanceStep();
    } else if (scenario == 5) {
      if (step == 3 && draggables.any((d) => d.id == 'c2' && d.targetX == 300.0)) advanceStep();
    }
  }
}

class SimItem {
  String id; double val; double x, y, homeX, homeY, targetX, targetY;
  bool isDragging = false, isSnapped = false, inGlass = false, onBridge = false;
  double alpha = 1.0; String group, city; Color color; double w, h;
  int slotR = -1; int slotC = -1;
  
  SimItem({required this.id, required this.val, required this.x, required this.y, 
    this.group = '', this.city = '', this.color = Colors.blue, required this.w, required this.h, double? targetY}) 
    : homeX = x, homeY = y, targetX = x, targetY = targetY ?? y;
}

class DropZone {
  String id; double x, y, w, h; bool isBridge; Offset? snapTarget; String city;
  int slotR; int slotC;
  DropZone({required this.id, required this.x, required this.y, required this.w, required this.h, this.isBridge = false, this.snapTarget, this.city = '', this.slotR = -1, this.slotC = -1});
}

class SimButton {
  String id; double x, y, w, h; Color color;
  SimButton(this.id, this.x, this.y, this.w, this.h, {this.color = Colors.green});
}

// --- APP ENTRY ---
class DataDetectivesApp extends StatelessWidget {
  const DataDetectivesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Detectives',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.white)),
      ),
      home: const AnalyzingPropertiesandRealWorldApplications(),
    );
  }
}

// --- MAIN SCREEN ---
class AnalyzingPropertiesandRealWorldApplications extends StatefulWidget {
  const AnalyzingPropertiesandRealWorldApplications({Key? key}) : super(key: key);
  @override
  State<AnalyzingPropertiesandRealWorldApplications> createState() => _AnalyzingPropertiesandRealWorldApplicationsState();
}

class _AnalyzingPropertiesandRealWorldApplicationsState extends State<AnalyzingPropertiesandRealWorldApplications> with TickerProviderStateMixin {
  final LabState _state = LabState();
  late AnimationController _animCtrl;
  
  // Sidebar scroll control
  final ScrollController _sidebarScrollCtrl = ScrollController();
  int _lastStep = 0;

  bool _isDraggingAnItem = false;
  bool _isPanningCanvas = false;
  double _startScale = 1.0;
  Offset _startPan = Offset.zero;
  Offset _startFocal = Offset.zero;
  Offset _dragOffset = Offset.zero;
  SimItem? _draggedItem;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _state.addListener(() {
      if (!mounted) return;
      if (_state.step != _lastStep) {
        _lastStep = _state.step;
        if (_sidebarScrollCtrl.hasClients) {
          // Auto scroll sidebar to the active step roughly (header is ~220px, steps are ~100px)
          _sidebarScrollCtrl.animateTo(
            220.0 + (_state.step * 100.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      setState(() {});
    });
    
    _state.loadScenario(1);
    AudioEngine.playShutter();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))..repeat();
    _animCtrl.addListener(_updatePhysics);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _state.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    bool needsRender = false;
    for (var d in _state.draggables) {
      if ((d.x - d.targetX).abs() > 0.5 || (d.y - d.targetY).abs() > 0.5) {
        d.x += (d.targetX - d.x) * 0.2; d.y += (d.targetY - d.y) * 0.2;
        needsRender = true;
      }
    }

    if (_state.scenario == 2 && _state.step < 2) {
      var onB = _state.draggables.where((d) => d.onBridge).toList()..sort((a,b) => a.val.compareTo(b.val));
      double torque = 0;
      for (var d in onB) torque += (d.x) * d.val;
      double targetAngle = math.max(-0.25, math.min(0.25, torque * 0.0001));
      _state.data['bridgeAngle'] += (targetAngle - _state.data['bridgeAngle']) * 0.1;
      for (int i=0; i<onB.length; i++) {
        if (!onB[i].isDragging) {
          onB[i].targetX = (onB.length >= 5 ? -120.0 : -90.0) + i * 60.0;
          onB[i].targetY = 70.0; 
        }
      }
      needsRender = true;
    }

    if (_state.isAnimating) {
      _state.animProgress += 0.015;
      double p = _state.animProgress;
      
      if (_state.scenario == 1) {
        var active = _state.step == 1 ? _state.draggables.where((d)=>d.group=='A') : _state.draggables.where((d)=>d.group=='B');
        int targetVal = _state.step == 1 ? 6 : 5;
        int i=0;
        for (var b in active) {
          if (p < 0.3) { b.targetX = -50.0; b.targetY = -20.0; b.alpha = 1.0 - (p/0.3); }
          else if (p < 0.6) { b.alpha = 0.0; b.val = targetVal.toDouble(); b.x = 80.0; b.y = 25.0; b.targetX = 80.0; b.targetY = 25.0; }
          else { b.alpha = math.min(1.0, (p-0.6)/0.2); b.targetX = 140.0 + i*55.0; b.targetY = 25.0; }
          i++;
        }
        if (p >= 1) {
          _state.isAnimating = false; AudioEngine.playSuccess();
          if (_state.step == 1) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _state.data['showBButton'] = true;
                _state._updateButtons();
                setState((){});
              }
            });
          } else {
            _state.advanceStep();
          }
        }
      } 
      else if (_state.scenario == 2) {
        if (_state.animMode == 'lineup') {
          var onB = _state.draggables.where((d) => d.onBridge || d.isSnapped).toList()..sort((a,b)=>a.val.compareTo(b.val));
          for (int i=0; i<onB.length; i++) {
            onB[i].targetX = (onB.length == 5 ? -120.0 : -90.0) + i*60.0;
            onB[i].targetY = 40.0; onB[i].isSnapped = true; onB[i].onBridge = false;
          }
          if (p >= 1) { _state.isAnimating = false; _state.animMode = 'lineup_done'; _state.advanceStep(); }
        } else if (_state.animMode.contains('scan')) {
          _state.data['laserY'] = -20.0 + (math.sin(p * math.pi * 4.0) * 50.0);
          if (p >= 1) {
            _state.isAnimating = false; _state.data['laserY'] = 0.0; 
            _state.animMode = _state.animMode == 'scan' ? 'scan_done' : 'scan2_done';
            AudioEngine.playSnap(); _state.advanceStep();
            if (_state.animMode == 'scan2_done') _state.completeScenario();
          }
        }
      } 
      else if (_state.scenario == 3) {
        if (p >= 1) {
          _state.isAnimating = false; 
          _state.animMode = _state.animMode == 'analyze_shubman' ? 'shubman_done' : 'yashasvi_done';
          AudioEngine.playSnap(); 
          _state.advanceStep();
          if (_state.step == 2) {
            for(var s in _state.draggables.where((d)=>d.group=='S')) { s.targetY = 9999.0; s.alpha = 0.0; }
            for(var y in _state.draggables.where((d)=>d.group=='Y')) { y.y = 150.0; y.homeY = 150.0; y.targetY = 150.0; }
          }
        }
      }
      needsRender = true;
    }
    if (needsRender && mounted) setState(() {});
  }

  void _handleButtonPress(String id) {
    if (id == 'btn_equalize') _state.startAnimation('equalize');
    else if (id == 'btn_bring_b') {
      _state.data['showBButton'] = false;
      for (var b in _state.draggables.where((d)=>d.group=='A')) b.alpha = 0.0;
      for (var b in _state.draggables.where((d)=>d.group=='B')) { b.y = 150.0; b.homeY = 150.0; b.targetY = 150.0; }
      _state.advanceStep();
    }
    else if (id == 'btn_line_up') _state.startAnimation('lineup');
    else if (id == 'btn_scan') _state.startAnimation('scan');
    else if (id == 'btn_analyze_s') _state.startAnimation('analyze_shubman');
    else if (id == 'btn_analyze_y') _state.startAnimation('analyze_yashasvi');
    else if (id == 'btn_observe') { _state.advanceStep(); _state.completeScenario(); }
  }

  // Pointer down provides perfectly responsive click tests bypassing GestureDetector delay
  void _handlePointerDown(PointerDownEvent event, BoxConstraints consts) {
    if (_state.simCompleted || _state.isAnimating || _state.showIntro) return;

    double canvasWidth = consts.maxWidth;
    double localCanvasX = event.localPosition.dx;
    double localCanvasY = event.localPosition.dy;

    double worldX = (localCanvasX - canvasWidth / 2 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2 - _state.canvasPan.dy) / _state.canvasScale;

    // Hit Testing for Immediate Buttons
    for (var btn in _state.buttons) {
      if (worldX >= btn.x - btn.w/2 && worldX <= btn.x + btn.w/2 && worldY >= btn.y - btn.h/2 && worldY <= btn.y + btn.h/2) {
        _handleButtonPress(btn.id); 
        return;
      }
    }

    // Hit Testing for Scenario 5 Tabs
    if (_state.scenario == 5) {
      var tabs = _state.data['tabs'] as List;
      for (int i=0; i<tabs.length; i++) {
        var t = tabs[i];
        if (worldX >= t['x'] && worldX <= t['x']+t['w'] && worldY >= t['y'] && worldY <= t['y']+t['h']) {
          _state.data['activeTab'] = i; AudioEngine.playClick();
          if (_state.step == 0) {
            (_state.data['tabsClicked'] as Set).add(i);
            if ((_state.data['tabsClicked'] as Set).length == 3) _state.advanceStep();
          }
          setState((){});
          return;
        }
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, BoxConstraints consts) {
    if (_state.simCompleted || _state.isAnimating || _state.showIntro) return;

    double canvasWidth = consts.maxWidth;
    double localCanvasX = details.localFocalPoint.dx;
    double localCanvasY = details.localFocalPoint.dy;

    double worldX = (localCanvasX - canvasWidth / 2 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2 - _state.canvasPan.dy) / _state.canvasScale;

    _startPan = _state.canvasPan;
    _startScale = _state.canvasScale;
    _startFocal = details.localFocalPoint;

    // Hit Testing for Draggables
    for (int i = _state.draggables.length - 1; i >= 0; i--) {
      var d = _state.draggables[i];
      if (d.alpha <= 0) continue;
      bool canDrag = !d.isSnapped || (_state.scenario==2 && _state.step==4 && d.id=='outlier') || (_state.scenario==5 && !_state.simCompleted);
      
      double hitW = d.w, hitH = d.h;
      if (_state.scenario == 4) { hitH = math.max(d.val * 3.5, 30.0); hitW = 80.0; }
      if (_state.scenario == 3) { hitH = math.max(d.val * 2.5, 30.0); hitW = 40.0; }
      if (_state.scenario == 5 && d.inGlass) { hitW = 110.0; hitH = 110.0; }
      
      double left = d.x - hitW/2;
      double right = d.x + hitW/2;
      double top = (_state.scenario == 5) ? d.y - hitH/2 : d.y - hitH;
      if (_state.scenario == 4) top = d.y - hitH - 40.0; 
      if (_state.scenario == 3) top = d.y - hitH - 10.0;

      if (canDrag && worldX >= left && worldX <= right && worldY >= top && worldY <= top + hitH + 40.0) {
        _isDraggingAnItem = true; _draggedItem = d;
        d.isDragging = true; d.isSnapped = false; d.onBridge = false; d.inGlass = false;
        if (_state.scenario == 4) { d.slotR = -1; d.slotC = -1; }
        _dragOffset = Offset(worldX - d.x, worldY - d.y);
        _state.draggables.removeAt(i); _state.draggables.add(d);
        AudioEngine.playClick(); 
        setState((){});
        return;
      }
    }

    // Canvas Panning Enabled
    _isPanningCanvas = true;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, BoxConstraints consts) {
    if (_state.simCompleted || _state.isAnimating || _state.showIntro) return;

    double canvasWidth = consts.maxWidth;
    double localCanvasX = details.localFocalPoint.dx;
    double localCanvasY = details.localFocalPoint.dy;
    
    double worldX = (localCanvasX - canvasWidth / 2 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2 - _state.canvasPan.dy) / _state.canvasScale;

    if (_isDraggingAnItem && _draggedItem != null) {
      _draggedItem!.targetX = worldX - _dragOffset.dx;
      _draggedItem!.targetY = worldY - _dragOffset.dy;
    } else if (_isPanningCanvas) {
      _state.canvasPan = _startPan + (details.localFocalPoint - _startFocal);
      _state.canvasScale = (_startScale * details.scale).clamp(0.2, 3.0);
    }
    
    _state.pointerX = worldX;
    _state.pointerY = worldY;
    setState((){});
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isPanningCanvas = false;
    if (!_isDraggingAnItem || _draggedItem == null) return;
    _isDraggingAnItem = false;

    var d = _draggedItem!;
    d.isDragging = false; 
    bool snapped = false;

    for (var dz in _state.dropzones) {
      bool hit = false;
      // Adjusted collision logic for easier drop zones
      if (_state.scenario == 4) {
        if (math.sqrt(math.pow(d.targetX - dz.x, 2) + math.pow(d.targetY - dz.y, 2)) < 60.0) hit = true;
      } else if (_state.scenario == 5 && dz.id == 'mag_glass') {
        if (math.sqrt(math.pow(d.targetX - 250.0, 2) + math.pow(d.targetY - 220.0, 2)) < 80.0) hit = true;
      } else if (_state.scenario == 5 && dz.id == 'hypo') {
        if (math.sqrt(math.pow(d.targetX - 300.0, 2) + math.pow(d.targetY - (-20.0), 2)) < 120.0) hit = true;
      } else {
        if (d.targetX >= dz.x && d.targetX <= dz.x + dz.w && d.targetY >= dz.y && d.targetY <= dz.y + dz.h) hit = true;
      }

      if (hit) {
        bool valid = false;
        if (_state.scenario == 1 && dz.id == 'machine') valid = (_state.step == 0 && d.group == 'A') || (_state.step == 2 && d.group == 'B');
        else if (_state.scenario == 2 && dz.isBridge) valid = (_state.step == 0 && d.id != 'outlier') || (_state.step == 1 && d.id == 'outlier');
        else if (_state.scenario == 3 && dz.id == 'analyzer') valid = (_state.step == 0 && d.group == 'S') || (_state.step == 2 && d.group == 'Y');
        else if (_state.scenario == 4) {
          String reqMonth = dz.id.substring(0, dz.id.length - 2);
          valid = (d.group == reqMonth && d.city == dz.city && d.group == ['s4_jan','s4_feb','s4_mar','s4_apr'][_state.step]);
        } 
        else if (_state.scenario == 5 && dz.id == 'mag_glass') {
          // Strict logic ensuring sequence follows text clues accurately
          if (_state.step == 1) valid = (d.id == 'c1');
          else if (_state.step >= 2) valid = ['c1','c2','c3'].contains(d.id);
        }
        else if (_state.scenario == 5 && dz.id == 'hypo') valid = (_state.step >= 3 && d.id == 'c2'); 

        if (valid) {
          d.isSnapped = true; snapped = true;
          if (_state.scenario == 1) {
            int idx = _state.draggables.where((x)=>x.group==d.group && x.isSnapped).length - 1;
            d.targetX = -320.0 + idx * 45.0; d.targetY = 25.0;
          } else if (_state.scenario == 3) {
            int idx = _state.draggables.where((x)=>x.group==d.group && x.isSnapped).length - 1;
            d.targetX = -320.0 + idx * 45.0; d.targetY = -15.0;
          } else if (_state.scenario == 4) {
            d.targetX = dz.x; d.targetY = dz.y; d.slotR = dz.slotR; d.slotC = dz.slotC;
          } else if (_state.scenario == 5 && dz.id == 'mag_glass') {
            for (var other in _state.draggables) {
              if (other.id != d.id && other.inGlass) {
                other.targetX = other.homeX; other.targetY = other.homeY;
                other.isSnapped = false; other.inGlass = false;
              }
            }
            d.targetX = 250.0; d.targetY = 220.0; d.inGlass = true;
            if (_state.step == 1 && d.id == 'c1' && !_state.data['c1Revealed']) {
              _state.data['c1Revealed'] = true;
              Future.delayed(const Duration(milliseconds: 400), _state.advanceStep);
            }
            if (_state.step == 2) {
              if (d.id == 'c2') _state.data['c2Revealed'] = true;
              if (d.id == 'c3') _state.data['c3Revealed'] = true;
              if (_state.data['c2Revealed'] && _state.data['c3Revealed'] && !_state.data['step2Advanced']) {
                _state.data['step2Advanced'] = true;
                Future.delayed(const Duration(milliseconds: 400), _state.advanceStep);
              }
            }
          } else if (_state.scenario == 5 && dz.id == 'hypo') {
            d.targetX = dz.snapTarget!.dx; d.targetY = dz.snapTarget!.dy; d.inGlass = false;
          }

          if (_state.scenario == 2) d.onBridge = true;
          AudioEngine.playSnap(); _state.checkSubStep(); break;
        }
      }
    }

    if (!snapped && _state.scenario == 2 && _state.step == 4 && d.id == 'outlier') {
      if (d.targetX > -50.0 || d.targetY > 50.0 || d.targetY < -50.0 || d.targetX < -200.0) {
        d.isSnapped = false; d.onBridge = false; d.targetX = -350.0; d.targetY = 150.0;
        AudioEngine.playWhir();
        var remain = _state.draggables.where((x)=>x.id!='outlier').toList()..sort((a,b)=>a.val.compareTo(b.val));
        for(int i=0; i<remain.length; i++) remain[i].targetX = -90.0 + i*60.0;
        _state.startAnimation('scan2'); snapped = true;
      }
    }
    if (!snapped) { AudioEngine.playError(); d.targetX = d.homeX; d.targetY = d.homeY; d.isSnapped = false; d.inGlass = false; }
    _draggedItem = null;
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData.dark(); 
    double sidebarWidth = MediaQuery.of(context).size.width * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
          children: [
            // 1. DYNAMIC CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? sidebarWidth : 0,
              right: 0, top: 0, bottom: 0,
              child: Container(
                color: const Color(0xFF0F172A),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => _handlePointerDown(e, constraints),
                      child: GestureDetector(
                        onScaleStart: (d) => _handleScaleStart(d, constraints),
                        onScaleUpdate: (d) => _handleScaleUpdate(d, constraints),
                        onScaleEnd: _handleScaleEnd,
                        child: ClipRect(
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: LabPainter(_state),
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),

            // Mini HUD Overlay on Canvas
            if (_state.hudMessage.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _state.isSidebarOpen ? sidebarWidth : 0, right: 0, bottom: 30,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: Text(_state.hudMessage, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

            // 2. FULLY SCROLLABLE SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? 0 : -sidebarWidth,
              top: 0, bottom: 0, width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.95),
                  border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.3))),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(5,0))]
                ),
                child: SingleChildScrollView( 
                  controller: _sidebarScrollCtrl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 70), // padding for top-left icons
                      
                      // Title, Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_state.t('shutterTitle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent, height: 1.2)),
                            const SizedBox(height: 4),
                            Text(_state.t('appSubtitle'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      
                      // Language Toggle Buttons & Reset
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                List<String> langs = ['en', 'hi'];
                                int idx = langs.indexOf(_state.lang);
                                _state.setLang(langs[(idx + 1) % langs.length]);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.language, color: Colors.tealAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Text(_state.lang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _state.resetActivity,
                              icon: const Icon(Icons.refresh, size: 14),
                              label: Text(_state.t('reset'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                            )
                          ],
                        ),
                      ),
                      
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Divider(height: 24)),

                      // Scenario Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<int>(
                          isExpanded: true, dropdownColor: const Color(0xFF1E293B),
                          value: _state.scenario,
                          decoration: InputDecoration(
                            labelText: _state.t('selectScenario'), border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                          ),
                          items: [1,2,3,4,5].map((i) => DropdownMenuItem(value: i, child: Text(_state.t('s${i}_title'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) { if (v != null) _state.loadScenario(v); },
                        ),
                      ),
                      
                      // Objective Box
                      Container(
                        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.withOpacity(0.3))),
                        child: Text(_state.t('s${_state.scenario}_obj'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),

                      // Steps List
                      ListView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: 5,
                        itemBuilder: (ctx, i) {
                          bool isPast = i < _state.step;
                          bool isCurrent = i == _state.step && !_state.simCompleted;
                          return Opacity(
                            opacity: (isPast || isCurrent || _state.simCompleted) ? 1.0 : 0.4,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: isCurrent ? Colors.tealAccent : Colors.grey.withOpacity(0.3), width: isCurrent ? 2 : 1),
                                borderRadius: BorderRadius.circular(8), color: isCurrent ? Colors.teal.withOpacity(0.05) : null
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${_state.t('stepLabel')} ${i+1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  RichText(text: TextSpan(children: [
                                    TextSpan(text: "${_state.t('actTitle')} ", style: TextStyle(fontSize: 13, color: isCurrent ? Colors.tealAccent : Colors.white, fontWeight: FontWeight.bold)),
                                    TextSpan(text: _state.t('s${_state.scenario}_task${i+1}'), style: TextStyle(fontSize: 13, color: isCurrent ? Colors.tealAccent : Colors.white70))
                                  ])),
                                  if (isPast || (isCurrent && _state.simCompleted)) ...[
                                    const Divider(),
                                    RichText(text: TextSpan(children: [
                                      TextSpan(text: "${_state.t('obsLbl')} ", style: const TextStyle(fontSize: 12, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                      TextSpan(text: _state.t('s${_state.scenario}_obs${i+1}'), style: const TextStyle(fontSize: 12, color: Colors.greenAccent))
                                    ])),
                                    const SizedBox(height: 2),
                                    RichText(text: TextSpan(children: [
                                      TextSpan(text: "${_state.t('learnLbl')} ", style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                                      TextSpan(text: _state.t('s${_state.scenario}_learn${i+1}'), style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic))
                                    ])),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Footer
                      const SizedBox(height: 24),
                      Container(padding: const EdgeInsets.all(12), color: Colors.black12, child: Text(_state.t('footer'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)))
                    ],
                  ),
                ),
              ),
            ),

            // 3. TOP-LEFT NAVIGATION/MENU ICONS
            Positioned(
              top: 12, left: 12,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_state.isSidebarOpen ? Icons.menu_open : Icons.menu),
                    color: Colors.white, iconSize: 24,
                    onPressed: () { HapticFeedback.lightImpact(); setState(() => _state.isSidebarOpen = !_state.isSidebarOpen); },
                    style: IconButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              )
            ),

            // 4. FLOATING ACTIVE STEP (Visible when sidebar is closed)
            if (!_state.isSidebarOpen && !_state.simCompleted && !_state.showIntro)
              Positioned(
                left: _state.activeStepPos.dx, top: _state.activeStepPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _state.activeStepPos = Offset(
                        (_state.activeStepPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 280),
                        (_state.activeStepPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 100),
                      );
                    });
                  },
                  child: Container(
                    width: 280, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95), borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.tealAccent, width: 2), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(4, 4))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${_state.t('stepLabel')} ${_state.step + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                            const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RichText(text: TextSpan(children: [
                          TextSpan(text: "${_state.t('actTitle')} ", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: _state.t('s${_state.scenario}_task${_state.step + 1}'), style: const TextStyle(fontSize: 14, color: Colors.white))
                        ])),
                      ],
                    ),
                  ),
                ),
              ),

            // 5. SCENARIO COMPLETE MODAL (Intermediate)
            if (_state.simCompleted && _state.scenario < 5)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: 400, padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green, width: 3)),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 60), const SizedBox(height: 16),
                              Text(_state.t('s${_state.scenario}_final'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 24),
                              const Text("This scenario is completed! Please select the next scenario from the sidebar.", textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
                            ],
                          ),
                          Positioned(
                            top: -10, right: -10,
                            child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _state.simCompleted = false)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 6. FINAL SUCCESS POPUP (Draggable & Compact with Close Icon)
            if (_state.showSuccessPopup && _state.scenario == 5)
              Positioned(
                left: _state.successPopupPos.dx, top: _state.successPopupPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _state.successPopupPos = Offset(
                        (_state.successPopupPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 320),
                        (_state.successPopupPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 250),
                      );
                    });
                  },
                  child: Container(
                    width: 320, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95), borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber, width: 3), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(5, 5))],
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber, size: 50), const SizedBox(height: 12),
                              Text(_state.t('finalSuccessTitle'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text(_state.t('finalSuccessDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.white)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                                onPressed: () { setState(() => _state.showSuccessPopup = false); _state.resetActivity(); },
                                icon: const Icon(Icons.refresh, size: 18), label: Text(_state.t('reset'), style: const TextStyle(fontSize: 14)),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          top: -10, right: -10,
                          child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _state.showSuccessPopup = false)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 7. INTRO CURTAIN
            if (_state.showIntro)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: _state.showIntro ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset(0, -MediaQuery.of(context).size.height * (1-val)),
                      child: Container(
                        color: const Color(0xFF0F172A),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.analytics, color: Colors.tealAccent, size: 80),
                              const SizedBox(height: 20),
                              Text(_state.t('shutterTitle'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 10),
                              Text(_state.t('appSubtitle'), style: const TextStyle(color: Colors.teal, fontSize: 18)),
                              const SizedBox(height: 40),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                                onPressed: () { AudioEngine.playSuccess(); setState(() => _state.showIntro = false); },
                                icon: const Icon(Icons.play_circle, size: 28),
                                label: Text(_state.t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
    );
  }
}

// --- CUSTOM CANVAS RENDERER ---
class LabPainter extends CustomPainter {
  final LabState state;
  LabPainter(this.state) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Center the coordinate system & apply manual Pan/Zoom Matrix
    canvas.translate(size.width / 2 + state.canvasPan.dx, size.height / 2 + state.canvasPan.dy);
    canvas.scale(state.canvasScale);

    if (state.scenario != 5) {
      final groundPaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRect(const Rect.fromLTRB(-2000, 200, 2000, 1000), groundPaint);
      final linePaint = Paint()..color = const Color(0xFF334155)..strokeWidth=2;
      for (double i = -1500; i < 2000; i += 100) canvas.drawLine(Offset(i, 200), Offset(i-50, 1000), linePaint);
    }

    _drawScenarioSpecifics(canvas);

    // Draw Buttons
    for (var btn in state.buttons) {
      final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(btn.x, btn.y), width: btn.w, height: btn.h), const Radius.circular(8));
      canvas.drawRRect(rect, Paint()..color = btn.color);
      canvas.drawRRect(rect, Paint()..color = Colors.black26..style=PaintingStyle.stroke..strokeWidth=2);
      _drawText(canvas, state.t(btn.id), btn.x, btn.y, color: Colors.white, size: 14, weight: FontWeight.bold);
    }

    // Draw Draggables
    var sorted = List<SimItem>.from(state.draggables);
    if (state.scenario == 4) {
      sorted.sort((a,b) {
        int depthA = a.isSnapped ? (a.slotR + a.slotC) : 100;
        int depthB = b.isSnapped ? (b.slotR + b.slotC) : 100;
        if (a.isDragging) return 1;
        if (b.isDragging) return -1;
        return depthA.compareTo(depthB);
      });
    }

    for (var d in sorted) {
      if (d.alpha <= 0) continue;
      canvas.save();
      
      if (state.scenario == 2 && d.onBridge && !d.isDragging) {
        canvas.translate(0, 80); 
        canvas.rotate(state.data['bridgeAngle'] ?? 0); 
        canvas.translate(d.x, -10);
      } else {
        canvas.translate(d.x, d.y);
      }

      if (d.isDragging) canvas.scale(1.1);
      canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(d.alpha));

      if (state.scenario == 1) {
        _drawWovenBasket(canvas, d.val.toInt(), d.val.toInt(), d.id);
      } else if (state.scenario == 2) {
        final r = Rect.fromLTRB(-20, -d.h, 20, 0);
        canvas.drawRect(r, Paint()..color = d.color);
        canvas.drawRect(r, Paint()..color = Colors.black87..style=PaintingStyle.stroke..strokeWidth=2);
        _drawText(canvas, '${d.val.toInt()}', 0, -d.h - 15, color: Colors.white, size: 14);
      } else if (state.scenario == 3) {
        Color mainCol = (d.group == 'S') ? Colors.pink : Colors.deepPurple;
        Color accCol = (d.group == 'S') ? Colors.pinkAccent : Colors.deepPurpleAccent;
        _drawRunTower(canvas, 30.0, d.val*2.5, d.val.toInt(), mainCol, accCol);
      } else if (state.scenario == 4) {
        _drawIsoBlock(canvas, 0.0, 0.0, d.val, d.color, d.isSnapped, false);
        if (d.isDragging || !d.isSnapped) _drawText(canvas, '${d.val.toInt()}', 0.0, -(d.val*3.5)-20.0, color: Colors.white);
      } else if (state.scenario == 5) {
        _drawClueCard(canvas, d);
      }
      
      canvas.restore();
      canvas.restore();
    }

    // Overlays (Magnifying glass rendering on top)
    if (state.scenario == 5 && state.step > 0) _drawMagnifyingGlass(canvas);

    canvas.restore();
  }

  void _drawScenarioSpecifics(Canvas canvas) {
    if (state.scenario == 1) {
      // Belt
      canvas.drawRect(const Rect.fromLTRB(-550, 50, 550, 65), Paint()..color = const Color(0xFF64748B));
      for(int i=0; i<36; i++) canvas.drawCircle(Offset(-530 + i*30.0, 57), 5, Paint()..color = const Color(0xFF94A3B8));

      // Main Machine
      canvas.drawRRect(RRect.fromLTRBAndCorners(-100, -120, 100, 60, topLeft: const Radius.circular(25), topRight: const Radius.circular(25)), Paint()..color = Colors.lightBlue[100]!);
      canvas.drawRRect(RRect.fromLTRBR(-80, -80, 80, -20, const Radius.circular(8)), Paint()..color = Colors.black87);
      
      String display = '';
      if (state.step > 1 && state.step < 3) display = '6';
      if (state.step > 3) display = '5';
      if (state.isAnimating) display = (math.Random().nextInt(9)).toString();
      _drawText(canvas, display, 0, -50, color: Colors.greenAccent, size: 36, weight: FontWeight.bold);
      
      // Hopper
      Path hopper = Path()..moveTo(-60, -120)..lineTo(-10, -120)..lineTo(10, -200)..lineTo(-80, -200)..close();
      canvas.drawPath(hopper, Paint()..color = Colors.white.withOpacity(0.7));
      canvas.drawPath(hopper, Paint()..color = const Color(0xFF94A3B8)..style=PaintingStyle.stroke..strokeWidth=3);
      
      double hopperLevel = 0;
      if (state.isAnimating) {
        if (state.animProgress < 0.3) hopperLevel = state.animProgress / 0.3;
        else if (state.animProgress > 0.6) hopperLevel = 1.0 - ((state.animProgress - 0.6) / 0.4);
        else hopperLevel = 1.0;
      }
      if (hopperLevel > 0) {
        canvas.save(); canvas.clipPath(hopper);
        for(int i=0; i<(30*hopperLevel).toInt(); i++) _drawGuava(canvas, -40.0 + (i%5)*12.0, -125.0 - (i~/5)*10.0);
        canvas.restore();
      }

      // Input pipe
      Path inPipe = Path()..moveTo(-160, -80)..cubicTo(-140, -80, -120, -140, -80, -140)..lineTo(-80, -120)..cubicTo(-110, -120, -140, -60, -160, -60)..close();
      canvas.drawPath(inPipe, Paint()..color = const Color(0xFF64748B));

      // Output pipe
      canvas.drawRect(const Rect.fromLTRB(100, -90, 420, -80), Paint()..color = const Color(0xFF64748B));
      for(int i=0; i<6; i++) {
        canvas.drawLine(Offset(140 + i*55.0, -90), Offset(140 + i*55.0, -60), Paint()..color=const Color(0xFF64748B)..strokeWidth=10);
        Path drop = Path()..moveTo(130 + i*55.0, -60)..lineTo(150 + i*55.0, -60)..lineTo(145 + i*55.0, -40)..lineTo(135 + i*55.0, -40)..close();
        canvas.drawPath(drop, Paint()..color=const Color(0xFF475569));
      }
      
      if (state.step >= 4 && !state.isAnimating) {
        canvas.drawRRect(RRect.fromLTRBR(-350, 120, 350, 230, const Radius.circular(10)), Paint()..color = Colors.white.withOpacity(0.95));
        canvas.drawRRect(RRect.fromLTRBR(-300, 135, -100, 185, const Radius.circular(5)), Paint()..color = const Color(0xFF0F172A));
        _drawText(canvas, "${state.t('s1_mean_lbl')} 6", -200, 160, color: Colors.green, size: 24, weight: FontWeight.bold);
        _drawText(canvas, state.t('s1_group_a_lbl'), -200, 205, color: Colors.black, weight: FontWeight.bold);

        canvas.drawRRect(RRect.fromLTRBR(100, 135, 300, 185, const Radius.circular(5)), Paint()..color = const Color(0xFF0F172A));
        _drawText(canvas, "${state.t('s1_mean_lbl')} 5", 200, 160, color: Colors.green, size: 24, weight: FontWeight.bold);
        _drawText(canvas, state.t('s1_group_b_lbl'), 200, 205, color: Colors.black, weight: FontWeight.bold);
        
        _drawText(canvas, state.t('s1_summary'), 0, 220, color: Colors.black87, style: FontStyle.italic);
      }
    } 
    else if (state.scenario == 2) {
      if (state.step < 3 && state.animMode != 'lineup' && state.animMode != 'lineup_done') {
        Path p = Path()..moveTo(0, 80)..lineTo(25, 130)..lineTo(-25, 130)..close();
        canvas.drawPath(p, Paint()..color = Colors.blueGrey[700]!);

        canvas.save();
        canvas.translate(0, 80); canvas.rotate(state.data['bridgeAngle'] ?? 0);
        canvas.drawRect(const Rect.fromLTRB(-200, -10, 200, 10), Paint()..color = Colors.brown[300]!);
        canvas.restore();
      }

      if (state.step >= 3 || state.animMode == 'lineup' || state.animMode == 'lineup_done') {
        canvas.drawRRect(RRect.fromLTRBR(-250, -180, 250, 80, const Radius.circular(10)), Paint()..color = Colors.lightBlue.withOpacity(0.1));
      }

      if (state.step >= 3) {
        double ly = state.data['laserY'] ?? -999.0;
        if (ly != -999.0) {
          canvas.drawRect(Rect.fromLTRB(-250, ly-10, 250, ly+10), Paint()..color = Colors.red.withOpacity(0.3));
          canvas.drawLine(Offset(-250, ly), Offset(250, ly), Paint()..color=Colors.red..strokeWidth=4);
        }

        if (state.animMode == 'scan_done' || state.step >= 4 || state.animMode == 'scan2_done') {
          String text = (state.animMode == 'scan2_done') ? state.t('s2_med_val2') : state.t('s2_med_val1');
          canvas.drawRRect(RRect.fromLTRBR(-100, 100, 100, 150, const Radius.circular(5)), Paint()..color = const Color(0xFF0F172A));
          canvas.drawRRect(RRect.fromLTRBR(-100, 100, 100, 150, const Radius.circular(5)), Paint()..color = Colors.lightBlue..style=PaintingStyle.stroke..strokeWidth=2);
          _drawText(canvas, state.t('s2_median_height'), 0, 115, color: Colors.white, weight: FontWeight.bold);
          _drawText(canvas, text, 0, 135, color: Colors.lightBlueAccent, size: 16, weight: FontWeight.bold);
          
          double pointerX = (state.animMode == 'scan2_done') ? (-90.0 + 1.5*60.0) : (-120.0 + 2*60.0);
          Path arrow = Path()..moveTo(pointerX, 100)..lineTo(pointerX-10, 80)..lineTo(pointerX+10, 80)..close();
          canvas.drawPath(arrow, Paint()..color = Colors.amber);
        }
      }
    }
    else if (state.scenario == 3) {
      _draw25DBox(canvas, -380.0, -60.0, 760.0, 120.0, 40.0, const Color(0xFF334155), const Color(0xFF1E293B), const Color(0xFF475569));
      canvas.drawRRect(RRect.fromLTRBR(-360, -40, -140, 40, const Radius.circular(10)), Paint()..color = const Color(0xFF0F172A));
      
      _draw25DBox(canvas, -110.0, -240.0, 220.0, 180.0, 20.0, const Color(0xFF0F172A), const Color(0xFF020617), const Color(0xFF1E293B));
      canvas.drawRect(const Rect.fromLTRB(-90, -220, 90, -80), Paint()..color = Colors.white);
      _drawText(canvas, state.t('s3_mean_mode'), 0, -260, color: Colors.white, weight: FontWeight.bold);

      _draw25DBox(canvas, 130.0, -240.0, 220.0, 180.0, 20.0, const Color(0xFF0F172A), const Color(0xFF020617), const Color(0xFF1E293B));
      canvas.drawRect(const Rect.fromLTRB(150, -220, 330, -80), Paint()..color = Colors.white);
      _drawText(canvas, state.t('s3_median_mode'), 240, -260, color: Colors.white, weight: FontWeight.bold);
      
      if (state.step > 0 && state.animMode != 'shubman' && state.animMode != '') {
        if (state.step < 4) {
          bool isYash = (state.step >= 3);
          double p = state.animProgress > 1 ? 1 : state.animProgress;
          if (!state.isAnimating) p = 1.0;
          List<int> mVals = isYash ? [26, 53, 2, 15] : [23, 7, 10, 52, 18];
          List<int> medVals = isYash ? [2, 15, 26, 53] : [7, 10, 18, 23, 52];
          double tMean = isYash ? 24 : 22;
          
          Color mCol = isYash ? Colors.deepPurple : Colors.pink;
          Color aCol = isYash ? Colors.deepPurpleAccent : Colors.pinkAccent;

          for(int i=0; i<mVals.length; i++) {
            double cVal = mVals[i] + (tMean - mVals[i]) * math.min(1, p * 1.5);
            double bx = -80.0 + i*(160.0/mVals.length);
            canvas.save(); canvas.translate(bx+15.0, -80.0);
            _drawRunTower(canvas, 30.0, cVal*2.5, cVal.round(), mCol, aCol);
            canvas.restore();
          }

          for(int i=0; i<medVals.length; i++) {
            double startX = 160.0 + ((isYash ? [2,3,0,1] : [1,2,4,0,3])[i]) * (160.0/medVals.length);
            double endX = 160.0 + i * (160.0/medVals.length);
            double bx = startX + (endX - startX) * math.min(1, p * 1.5);
            canvas.save(); canvas.translate(bx+15.0, -80.0);
            _drawRunTower(canvas, 30.0, medVals[i]*2.5, medVals[i], mCol, aCol);
            canvas.restore();
          }

          if (p >= 1) {
            canvas.drawLine(Offset(-90.0, -80.0 - (tMean*2.5)), Offset(90.0, -80.0 - (tMean*2.5)), Paint()..color=Colors.red..strokeWidth=3);
            double mx = 160.0 + (isYash ? 1.5 : 2) * (160.0/(isYash?4:5));
            canvas.drawRect(Rect.fromLTRB(mx+5.0, -210.0, mx+25.0, -90.0), Paint()..color=Colors.yellow.withOpacity(0.4));
          }
        }
      }

      if (state.animMode == 'shubman_done') {
        _drawText(canvas, state.t('s3_shubman'), 50, -40, color: Colors.lightBlue, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_mean_val')} 22", -10, 0, color: Colors.white, size: 20, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_median_val')} 18", 110, 0, color: Colors.white, size: 20, weight: FontWeight.bold);
      } else if (state.animMode == 'yashasvi_done') {
        _drawText(canvas, state.t('s3_yashasvi'), 50, -40, color: Colors.lightBlue, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_mean_val')} 24", -10, 0, color: Colors.white, size: 20, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_median_val')} 20.5", 110, 0, color: Colors.white, size: 20, weight: FontWeight.bold);
      }

      if (state.step >= 4) {
        canvas.drawRRect(RRect.fromLTRBR(-350, -230, 350, 50, const Radius.circular(10)), Paint()..color=Colors.white.withOpacity(0.95));
        canvas.drawRRect(RRect.fromLTRBR(-350, -230, 350, 50, const Radius.circular(10)), Paint()..color=Colors.green..style=PaintingStyle.stroke..strokeWidth=3);
        _drawText(canvas, state.t('s3_final_report'), 0, -200, color: Colors.black, size: 24, weight: FontWeight.bold);
        
        canvas.drawRRect(RRect.fromLTRBR(-300, -160, -50, -40, const Radius.circular(10)), Paint()..color=Colors.white);
        canvas.drawRRect(RRect.fromLTRBR(-300, -160, -50, -40, const Radius.circular(10)), Paint()..color=Colors.grey..style=PaintingStyle.stroke);
        _drawText(canvas, state.t('s3_shubman'), -175, -130, color: Colors.blue, size: 18, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_mean_val')} 22", -175, -100, color: Colors.black, size: 20, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_median_val')} 18", -175, -70, color: Colors.black, size: 20, weight: FontWeight.bold);

        canvas.drawRRect(RRect.fromLTRBR(50, -160, 300, -40, const Radius.circular(10)), Paint()..color=Colors.white);
        canvas.drawRRect(RRect.fromLTRBR(50, -160, 300, -40, const Radius.circular(10)), Paint()..color=Colors.grey..style=PaintingStyle.stroke);
        _drawText(canvas, state.t('s3_yashasvi'), 175, -130, color: Colors.deepPurple, size: 18, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_mean_val')} 24", 175, -100, color: Colors.black, size: 20, weight: FontWeight.bold);
        _drawText(canvas, "${state.t('s3_median_val')} 20.5", 175, -70, color: Colors.black, size: 20, weight: FontWeight.bold);
        
        _drawText(canvas, state.t('s3_summary'), 0, -10, color: Colors.black87, style: FontStyle.italic);
      }
    }
    else if (state.scenario == 4) {
      // Data Table Left
      canvas.drawRRect(RRect.fromLTRBR(-460, -150, -180, 90, const Radius.circular(10)), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromLTRBR(-460, -150, -180, 90, const Radius.circular(10)), Paint()..color = Colors.grey..style=PaintingStyle.stroke);
      _drawText(canvas, state.t('s4_table_title'), -320, -130, color: Colors.white, size: 16, weight: FontWeight.bold);
      
      canvas.drawRect(const Rect.fromLTRB(-460, -110, -180, -80), Paint()..color = const Color(0xFF334155));
      _drawText(canvas, state.t('s4_month'), -400, -95, color: Colors.white, weight: FontWeight.bold);
      _drawText(canvas, state.t('s4_yahapur'), -290, -95, color: Colors.green, weight: FontWeight.bold);
      _drawText(canvas, state.t('s4_wahapur'), -210, -95, color: Colors.purpleAccent, weight: FontWeight.bold);

      List<Map<String,dynamic>> mRows = [ {'m':'s4_jan','g':25,'p':19}, {'m':'s4_feb','g':28,'p':10}, {'m':'s4_mar','g':20,'p':30}, {'m':'s4_apr','g':26,'p':12} ];
      for(int i=0; i<mRows.length; i++) {
        if (i%2!=0) canvas.drawRect(Rect.fromLTRB(-460, -80+i*30.0, -180, -50+i*30.0), Paint()..color=const Color(0xFF0F172A));
        _drawText(canvas, state.t(mRows[i]['m']), -400, -65+i*30.0, color: Colors.grey);
        _drawText(canvas, '${mRows[i]['g']}', -290, -65+i*30.0, color: Colors.green, weight: FontWeight.bold);
        _drawText(canvas, '${mRows[i]['p']}', -210, -65+i*30.0, color: Colors.purpleAccent, weight: FontWeight.bold);
      }

      // Palette Right
      canvas.drawRRect(RRect.fromLTRBR(300, -150, 460, 210, const Radius.circular(10)), Paint()..color = const Color(0xFF334155));
      canvas.drawRRect(RRect.fromLTRBR(300, -150, 460, 210, const Radius.circular(10)), Paint()..color = const Color(0xFF475569)..style=PaintingStyle.stroke..strokeWidth=2);
      _drawText(canvas, state.t('s4_palette'), 380, -130, color: Colors.grey, weight: FontWeight.bold);

      // Isometric Grid
      double originX = 150.0, originY = -50.0, tW = 40.0, tH = 20.0;
      for (int r=0; r<4; r++) {
        for (int c=0; c<2; c++) {
          double gx = originX + (c*tW) - (r*tW); double gy = originY + (c*tH) + (r*tH);
          Path p = Path()..moveTo(gx, gy)..lineTo(gx-tW, gy-tH)..lineTo(gx, gy-2*tH)..lineTo(gx+tW, gy-tH)..close();
          canvas.drawPath(p, Paint()..color=const Color(0xFF334155)..style=PaintingStyle.fill);
          canvas.drawPath(p, Paint()..color=const Color(0xFF1E293B)..style=PaintingStyle.stroke);
        }
        double lx = originX - (r*tW) - 30.0; double ly = originY + (r*tH) + 20.0;
        _drawText(canvas, state.t(['s4_jan','s4_feb','s4_mar','s4_apr'][r]), lx, ly, color: Colors.grey, weight: FontWeight.bold);
      }
      _drawText(canvas, state.t('s4_yahapur'), originX - 10.0, originY - 30.0, color: Colors.green, weight: FontWeight.bold);
      _drawText(canvas, state.t('s4_wahapur'), originX + 50.0, originY - 10.0, color: Colors.purpleAccent, weight: FontWeight.bold);

      if (state.step < 4) {
        String targetM = ['s4_jan','s4_feb','s4_mar','s4_apr'][state.step];
        for (var sl in state.data['slots']) {
          if ((sl['id'] as String).contains(targetM)) {
            Color hlC = sl['city'] == 'G' ? Colors.green : Colors.purpleAccent;
            _drawIsoBlock(canvas, sl['x'], sl['y'], 0.0, hlC, false, true);
            _drawText(canvas, state.t('s4_drop_here'), sl['x'], sl['y'] - 15.0, color: hlC, size: 10, weight: FontWeight.bold);
          }
        }
      }

      if (state.step >= 4) {
        canvas.drawRRect(RRect.fromLTRBR(-250, 150, 250, 210, const Radius.circular(10)), Paint()..color=Colors.white.withOpacity(0.9));
        canvas.drawRRect(RRect.fromLTRBR(-250, 150, 250, 210, const Radius.circular(10)), Paint()..color=Colors.green..style=PaintingStyle.stroke..strokeWidth=2);
        _drawText(canvas, state.t('s4_summary'), 0, 180, color: Colors.black, size: 14, weight: FontWeight.bold, maxW: 480);
      }
    }
    else if (state.scenario == 5) {
      canvas.drawRect(const Rect.fromLTRB(-600, -400, 600, 400), Paint()..color = const Color(0xFF291B13));
      
      canvas.drawRRect(RRect.fromLTRBR(180, -180, 420, 120, const Radius.circular(5)), Paint()..color = Colors.amber[300]!);
      canvas.drawRRect(RRect.fromLTRBR(180, -180, 420, 120, const Radius.circular(5)), Paint()..color = Colors.amber[700]!..style=PaintingStyle.stroke..strokeWidth=2);
      
      canvas.drawRRect(RRect.fromLTRBR(200, -100, 400, 60, const Radius.circular(8)), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromLTRBR(200, -100, 400, 60, const Radius.circular(8)), Paint()..color = const Color(0xFF475569)..style=PaintingStyle.stroke..strokeWidth=4);
      _drawText(canvas, state.t('s5_hypo_title'), 300, -140, color: Colors.brown[800]!, size: 18, weight: FontWeight.bold);
      _drawText(canvas, state.t('s5_drag_clue'), 300, -20, color: const Color(0xFF475569), size: 16, weight: FontWeight.bold);

      canvas.drawRRect(RRect.fromLTRBR(-420, -150, 140, 130, const Radius.circular(5)), Paint()..color = Colors.yellow[200]!);
      canvas.drawRRect(RRect.fromLTRBR(-420, -150, 140, 130, const Radius.circular(5)), Paint()..color = Colors.black..style=PaintingStyle.stroke);
      
      var tabs = state.data['tabs'];
      int act = state.data['activeTab'] ?? 0;
      List<String> lbls = ['s5_grade6', 's5_grade7', 's5_grade8'];
      for (int i=0; i<3; i++) {
        canvas.drawRRect(RRect.fromLTRBAndCorners(tabs[i]['x'], tabs[i]['y'], tabs[i]['x']+tabs[i]['w'], tabs[i]['y']+tabs[i]['h'], topLeft: const Radius.circular(8), topRight: const Radius.circular(8)), Paint()..color = (act==i)?Colors.yellow[200]!:Colors.yellow[400]!);
        canvas.drawRRect(RRect.fromLTRBAndCorners(tabs[i]['x'], tabs[i]['y'], tabs[i]['x']+tabs[i]['w'], tabs[i]['y']+tabs[i]['h'], topLeft: const Radius.circular(8), topRight: const Radius.circular(8)), Paint()..color = Colors.amber[700]!..style=PaintingStyle.stroke);
        _drawText(canvas, state.t(lbls[i]), tabs[i]['x']+50.0, tabs[i]['y']+18.0, color: Colors.brown[800]!, size: 14, weight: FontWeight.bold);
      }
      canvas.drawRect(Rect.fromLTRB(tabs[act]['x']+2.0, -152.0, tabs[act]['x']+tabs[act]['w']-2.0, -148.0), Paint()..color=Colors.yellow[200]!);

      canvas.drawRRect(RRect.fromLTRBR(-410, -140, 130, 120, const Radius.circular(2)), Paint()..color = const Color(0xFFF8FAFC));

      canvas.drawRect(const Rect.fromLTRB(-390, -90, -150, 70), Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawRect(const Rect.fromLTRB(-390, -90, -150, 70), Paint()..color = const Color(0xFF94A3B8)..style=PaintingStyle.stroke);
      _drawText(canvas, state.t('s5_school_a'), -270, -110, color: Colors.blue, size: 16, weight: FontWeight.bold);

      canvas.drawRect(const Rect.fromLTRB(-130, -90, 110, 70), Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawRect(const Rect.fromLTRB(-130, -90, 110, 70), Paint()..color = const Color(0xFF94A3B8)..style=PaintingStyle.stroke);
      _drawText(canvas, state.t('s5_school_b'), -10, -110, color: Colors.green, size: 16, weight: FontWeight.bold);

      final gridP = Paint()..color=const Color(0xFFCBD5E1)..strokeWidth=1;
      for(int i=1; i<=5; i++) {
        canvas.drawLine(Offset(-390.0, 50.0 - i*20.0), Offset(-150.0, 50.0 - i*20.0), gridP);
        canvas.drawLine(Offset(-130.0, 50.0 - i*20.0), Offset(110.0, 50.0 - i*20.0), gridP);
      }
      
      final axisP = Paint()..color=const Color(0xFF64748B)..strokeWidth=2;
      canvas.drawLine(const Offset(-380, 50), const Offset(-160, 50), axisP);
      canvas.drawLine(const Offset(-120, 50), const Offset(100, 50), axisP);
      for(int i=0; i<6; i++) {
        int v = 130 + i*5;
        _drawText(canvas, '$v', -370.0 + i*40.0, 65, color: const Color(0xFF475569));
        _drawText(canvas, '$v', -110.0 + i*40.0, 65, color: const Color(0xFF475569));
      }

      int offset = act * 5; 
      List<int> dotsA = [135, 135, 140, 140, 140, 145, 145];
      List<int> dotsB = [140, 145, 145, 150, 150, 150, 155];
      
      Map<int, int> freqA = {}; for(var v in dotsA) freqA[v+offset] = (freqA[v+offset] ?? 0) + 1;
      Map<int, int> freqB = {}; for(var v in dotsB) freqB[v+offset] = (freqB[v+offset] ?? 0) + 1;

      Map<String, dynamic>? hoveredDot;
      freqA.forEach((k, count) {
        double dx = -370.0 + ((k - 130)/5)*40.0;
        for(int i=0; i<count; i++) {
          double dy = 42.0 - i*14.0;
          canvas.drawCircle(Offset(dx, dy), 6, Paint()..color=Colors.blue);
          canvas.drawCircle(Offset(dx, dy), 6, Paint()..color=Colors.black..style=PaintingStyle.stroke);
          if (math.sqrt(math.pow(dx - state.pointerX, 2) + math.pow(dy - state.pointerY, 2)) < 8) hoveredDot = {'x':dx, 'y':dy, 'val':k};
        }
      });

      freqB.forEach((k, count) {
        double dx = -110.0 + ((k - 130)/5)*40.0;
        for(int i=0; i<count; i++) {
          double dy = 42.0 - i*14.0;
          canvas.drawCircle(Offset(dx, dy), 6, Paint()..color=Colors.green);
          canvas.drawCircle(Offset(dx, dy), 6, Paint()..color=Colors.black..style=PaintingStyle.stroke);
          if (math.sqrt(math.pow(dx - state.pointerX, 2) + math.pow(dy - state.pointerY, 2)) < 8) hoveredDot = {'x':dx, 'y':dy, 'val':k};
        }
      });

      if (hoveredDot != null) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(hoveredDot!['x'], hoveredDot!['y']-20.0), width: 40, height: 20), const Radius.circular(4)), Paint()..color=Colors.black87);
        _drawText(canvas, '${hoveredDot!['val']}cm', hoveredDot!['x'], hoveredDot!['y']-20.0, color: Colors.white, size: 10);
      }

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-150, 97), width: 140, height: 25), const Radius.circular(12)), Paint()..color=const Color(0xFFE2E8F0));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-150, 97), width: 140, height: 25), const Radius.circular(12)), Paint()..color=const Color(0xFF94A3B8)..style=PaintingStyle.stroke);
      _drawText(canvas, state.t('s5_hover_details'), -150, 97, color: const Color(0xFF475569), size: 11, weight: FontWeight.bold);
    }
  }

  void _drawGuava(Canvas canvas, double x, double y) {
    canvas.drawCircle(Offset(x, y), 7, Paint()..color = const Color(0xFF84CC16));
    canvas.drawCircle(Offset(x, y), 7, Paint()..color = const Color(0xFF3F6212)..style=PaintingStyle.stroke..strokeWidth=1.5);
    canvas.drawCircle(Offset(x, y-5), 1.5, Paint()..color = const Color(0xFF3F6212));
  }

  void _drawWovenBasket(Canvas canvas, int guavas, int valLabel, String basketIdLabel) {
    List<Offset> offs = const [Offset(-8,0),Offset(8,0),Offset(0,-8),Offset(-12,-10),Offset(12,-10),Offset(-6,-16),Offset(6,-16),Offset(0,-22),Offset(-10,-24),Offset(10,-24),Offset(-4,-30),Offset(4,-30),Offset(-12,-32),Offset(12,-32),Offset(0,-38)];
    for(int i=0; i<math.min(guavas, offs.length); i++) _drawGuava(canvas, offs[i].dx, offs[i].dy - 5.0);
    if (guavas > offs.length) _drawText(canvas, "+", 0, -40, color: Colors.white, size: 14, weight: FontWeight.bold);
    
    canvas.drawOval(const Rect.fromLTRB(-24, -10, 24, 0), Paint()..color=const Color(0xFFB45309));
    Path b = Path()..moveTo(-24, -5)..lineTo(24, -5)..lineTo(16, 25)..lineTo(-16, 25)..close();
    canvas.drawPath(b, Paint()..color=const Color(0xFFD97706));
    canvas.drawPath(b, Paint()..color=const Color(0xFFB45309)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawLine(const Offset(-20, 5), const Offset(20, 5), Paint()..color=const Color(0xFFB45309)..strokeWidth=2);
    canvas.drawLine(const Offset(-18, 15), const Offset(18, 15), Paint()..color=const Color(0xFFB45309)..strokeWidth=2);
    canvas.drawArc(const Rect.fromLTRB(-24, -10, 24, 0), 0, math.pi, false, Paint()..color=const Color(0xFFF59E0B));
    
    _drawText(canvas, '$valLabel', 0, 10, color: Colors.white, size: 16, weight: FontWeight.bold);
    _drawText(canvas, "${state.t('basket_label')} $basketIdLabel:", 0, 40, color: Colors.grey[400]!, size: 10, weight: FontWeight.bold);
    _drawText(canvas, "$valLabel ${state.t('guava_label')}", 0, 52, color: Colors.grey[400]!, size: 10);
  }

  void _draw25DBox(Canvas canvas, double x, double y, double w, double h, double d, Color front, Color side, Color top) {
    Path topP = Path()..moveTo(x,y)..lineTo(x+w,y)..lineTo(x+w-d,y-d)..lineTo(x-d,y-d)..close();
    canvas.drawPath(topP, Paint()..color=top);
    Path sideP = Path()..moveTo(x,y)..lineTo(x-d,y-d)..lineTo(x-d,y+h-d)..lineTo(x,y+h)..close();
    canvas.drawPath(sideP, Paint()..color=side);
    canvas.drawRect(Rect.fromLTRB(x, y, x+w, y+h), Paint()..color=front);
  }

  void _drawRunTower(Canvas canvas, double w, double h, int val, Color mainCol, Color accCol) {
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: w/2), Paint()..color=Colors.black38);
    double ballR = w/2;
    int ballCount = math.max(1, (h/(ballR*1.5)).floor());
    double spacing = h / ballCount;
    for(int i=0; i<ballCount; i++) {
      double cy = -(i*spacing) - ballR;
      canvas.drawCircle(Offset(0, cy), ballR, Paint()..color=mainCol);
      canvas.drawArc(Rect.fromCircle(center: Offset(0,cy), radius: ballR), math.pi*0.8, math.pi*0.4, false, Paint()..color=accCol..style=PaintingStyle.stroke..strokeWidth=1.5);
      canvas.drawArc(Rect.fromCircle(center: Offset(0,cy), radius: ballR), -math.pi*0.2, math.pi*0.4, false, Paint()..color=accCol..style=PaintingStyle.stroke..strokeWidth=1.5);
      canvas.drawCircle(Offset(-ballR*0.3, cy-ballR*0.3), ballR*0.3, Paint()..color=Colors.white30);
    }
    _drawText(canvas, '$val', 0, -h-20.0, color: Colors.white, size: 16, weight: FontWeight.bold);
  }

  void _drawIsoBlock(Canvas canvas, double x, double y, double h, Color c, bool isSnapped, bool isOutline) {
    double tW = 40.0, tH = 20.0, rH = h * 3.5;
    if (isOutline) {
      Path p = Path()..moveTo(x,y)..lineTo(x-tW,y-tH)..lineTo(x,y-2*tH)..lineTo(x+tW,y-tH)..close();
      canvas.drawPath(p, Paint()..color=c..style=PaintingStyle.stroke..strokeWidth=2);
      return;
    }
    if (isSnapped) {
      Path shadow = Path()..moveTo(x,y)..lineTo(x-tW,y-tH)..lineTo(x,y-tH*2)..lineTo(x+tW,y-tH)..close();
      canvas.drawPath(shadow, Paint()..color=Colors.black26);
    }
    Color topC = c == Colors.green ? Colors.greenAccent : Colors.purpleAccent;
    Color sideC = c == Colors.green ? Colors.green[700]! : Colors.deepPurple;
    Path front = Path()..moveTo(x,y)..lineTo(x-tW,y-tH)..lineTo(x-tW,y-tH-rH)..lineTo(x,y-rH)..close();
    canvas.drawPath(front, Paint()..color=c); canvas.drawPath(front, Paint()..color=Colors.black26..style=PaintingStyle.stroke);
    Path side = Path()..moveTo(x,y)..lineTo(x+tW,y-tH)..lineTo(x+tW,y-tH-rH)..lineTo(x,y-rH)..close();
    canvas.drawPath(side, Paint()..color=sideC); canvas.drawPath(side, Paint()..color=Colors.black26..style=PaintingStyle.stroke);
    Path top = Path()..moveTo(x,y-rH)..lineTo(x-tW,y-tH-rH)..lineTo(x,y-2*tH-rH)..lineTo(x+tW,y-tH-rH)..close();
    canvas.drawPath(top, Paint()..color=topC); canvas.drawPath(top, Paint()..color=Colors.black26..style=PaintingStyle.stroke);
  }

  void _drawClueCard(Canvas canvas, SimItem d) {
    canvas.drawRect(const Rect.fromLTRB(-45, -32, 45, 32), Paint()..color = d.color);
    canvas.drawRect(const Rect.fromLTRB(-45, -32, 45, 32), Paint()..color = Colors.orange..style=PaintingStyle.stroke);
    _drawText(canvas, '${state.t('s5_clue_prefix')} ${d.val.toInt()}', 0, -10, color: Colors.black87, size: 14, weight: FontWeight.bold);
  }

  void _drawMagnifyingGlass(Canvas canvas) {
    double magX = 250.0, magY = 220.0;
    canvas.save(); canvas.translate(magX, magY); canvas.rotate(math.pi/4);
    canvas.drawRRect(RRect.fromLTRBR(55, -5, 135, 15, const Radius.circular(10)), Paint()..color=Colors.black45); // shadow
    canvas.drawRRect(RRect.fromLTRBR(50, -12, 140, 12, const Radius.circular(12)), Paint()..color=const Color(0xFF3F2612));
    canvas.drawRect(const Rect.fromLTRB(70, -12, 75, 12), Paint()..color=const Color(0xFF291708));
    canvas.drawRect(const Rect.fromLTRB(90, -12, 95, 12), Paint()..color=const Color(0xFF291708));
    canvas.drawRect(const Rect.fromLTRB(110, -12, 115, 12), Paint()..color=const Color(0xFF291708));
    canvas.drawRRect(RRect.fromLTRBR(40, -15, 55, 15, const Radius.circular(4)), Paint()..color=const Color(0xFF94A3B8));
    canvas.rotate(-math.pi/4);

    canvas.drawCircle(const Offset(5, 5), 65, Paint()..color=Colors.black26); // Rim shadow
    canvas.drawCircle(Offset.zero, 65, Paint()..color=const Color(0xFF64748B)); // Rim
    canvas.drawCircle(Offset.zero, 55, Paint()..color=const Color(0xFFCBD5E1)); // Inner rim

    var inGlass = state.draggables.where((d)=>d.inGlass).toList();
    if (inGlass.isNotEmpty) {
      canvas.drawCircle(Offset.zero, 53, Paint()..color=const Color(0xFFFFFBEB));
      _drawText(canvas, state.t(inGlass.first.id == 'c1' ? 's5_clue1' : inGlass.first.id == 'c2' ? 's5_clue2' : 's5_clue3'), 0, 0, color: Colors.black, size: 11, weight: FontWeight.bold, maxW: 80);
    } else {
      canvas.drawCircle(Offset.zero, 53, Paint()..color=Colors.lightBlueAccent.withOpacity(0.2));
    }
    
    // Lens Reflections
    canvas.drawArc(const Rect.fromLTRB(-45, -45, 5, 5), math.pi, math.pi/2, false, Paint()..color=Colors.white54..style=PaintingStyle.stroke..strokeWidth=5);
    canvas.drawArc(const Rect.fromLTRB(10, 10, 40, 40), 0, math.pi/2, false, Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=5);
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, double x, double y, {Color color = Colors.black, double size = 12, FontWeight weight = FontWeight.normal, double maxW = 200, FontStyle style = FontStyle.normal}) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: weight, fontStyle: style)), textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxW); tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}