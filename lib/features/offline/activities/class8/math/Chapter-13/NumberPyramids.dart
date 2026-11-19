// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

// --- 1. INTERNATIONALIZATION (i18n) DICTIONARY ---
class I18n {
  static const Map<String, Map<String, dynamic>> data = {
    'en': {
      'appTitle': "NUMBER PYRAMID LAB",
      'tagline': "Class 8 • ALGEBRA PLAY",
      'initBtn': "START MISSION",
      'headerTitle': "The Number Pyramid Lab",
      'headerSubtitle': "Class 8 • ALGEBRA PLAY",
      'ctxTitle': "Why Learn This?",
      'postTitle': "Analysis & Outcomes",
      'boardTitle': "Teacher Board",
      'objLabel': "Mission Objective",
      'conceptLabel': "Core Concepts",
      'stepInfoLabel': "Current Step",
      'navTitle': "Lab Progress",
      'btnStartLab': "Start Experiment",
      'btnRestart': "RESTART MISSION",
      'hudMission': "Current Objective",
      'msgMissionComplete': "MISSION ACCOMPLISHED",
      'finalSubtitle': "You built, solved, and derived the number-pyramid rule top = a + 3b + 3c + d.",
      'msgStepComplete': "Step Complete!",
      'msgWrong': "Not yet — remember: every cell equals the sum of the two cells directly below it. Adjust your blocks and try again.",
      'msgNeedFiveTrials': "Record at least 5 different pyramids before testing your rule.",
      'msgNeedDistinctTrial': "That exact base combination is already recorded — change base numbers.",
      'msgRuleMismatch': "Your rule didn't match the actual top for every recorded trial. Check the mismatched rows below and revise it.",
      'msgNeedVfCheck': "Press CHECK SEQUENCE MEMBERSHIP first, then verify.",
      'msgNeedReasoning': "Add at least one full sentence explaining your conjecture before verifying.",
      'msgNeedPredictions': "Enter all three predicted top values before verifying.",
      'proceedBtn': "PROCEED",
      'closeBtn': "CLOSE",
      'proofModalTitleTxt': "Where Does a + 3b + 3c + d Come From?",
      'proofModalBody': "Watch the coefficients grow as rows are added, following Pascal's Triangle:\n2 rows: top = a + b\n3 rows: top = a + 2b + c\n4 rows: top = a + 3b + 3c + d\nEach coefficient is the sum of the two coefficients above it — exactly the same addition rule the pyramid itself uses.",
      'recordTrialBtn': "RECORD TRIAL",
      'testRuleBtn': "TEST RULE (PREVIEW)",
      'checkVfBtn': "CHECK SEQUENCE MEMBERSHIP",
      'baseRowLabel': "Base Row (adjust amber blocks)",
      'topValueLabel': "Top Value",
      'predictedTopLabel': "Your Predicted Top",
      'ruleInputLabel': "Your Proposed Rule (use a, b, c, d)",
      'ruleInputPlaceholder': "e.g. a+3*b+3*c+d",
      'reasoningPrompt': "In one sentence: is the top value (21) itself a Virahāṅka-Fibonacci number, and what do you predict happens for ANY number of rows?",
      'reasoningPlaceholder': "Type your conjecture here (at least one full sentence)…",
      'trialsRecordedLabel': "Trials recorded",
      'previewMatchLabel': "Rule matches",
      'lockedChip': "GIVEN",
      'editableChip': "EDIT ME",
      'vfResultLabel': "Sequence check",
      'vfYes': "Virahāṅka-Fibonacci number",
      'vfNo': "NOT in the sequence",
      'pyramidLabel': "Pyramid",
      'objDesc': "Derive the addition rule for a number pyramid using four variables.",
      'conceptText': "Each block is the sum of the two directly below it. We can predict the top without computing middle steps.",
      'outcomesText': "You will derive the formula top = a + 3b + 3c + d.",
      'steps': [
        { 'id': "PYR-INTRO", 'title': "Step 1 of 14: Meet the Number Pyramid", 'instruction': "Change the three amber base blocks until they read 1, 9, 4. Watch each cell above become the sum of the two blocks directly below it, until the top reads 23.", 'validateLabel': "VERIFY TOP = 23" },
        { 'id': "PYR-2ROW", 'title': "Step 2 of 14: The Simplest Pyramid", 'instruction': "A 2-row pyramid has one rule: top = a + b. Set the two base blocks to 6 and 2 so the top reads 8.", 'validateLabel': "VERIFY TOP = 8" },
        { 'id': "PYR-3ROW", 'title': "Step 3 of 14: Three Rows, One Rule", 'instruction': "Set the base blocks to 3, 4, 3. Confirm the middle row becomes 7 and 7 before the top reaches 14.", 'validateLabel': "VERIFY TOP = 14" },
        { 'id': "PYR-4ROW", 'title': "Step 4 of 14: Four Rows Tall", 'instruction': "Build a full 4-row pyramid. Set the base blocks to 5, 4, 5, 0 and watch the sums climb to the top value 32.", 'validateLabel': "VERIFY TOP = 32" },
        { 'id': "PYR-BACKWARD-FILL", 'title': "Step 5 of 14: Working Backwards", 'instruction': "The top is fixed at 10 and the leftmost base block is fixed at 1 (cyan, GIVEN). Set the two unknown amber blocks until the row above reads 4 and 6, and the top locks at 10 — solve it by subtracting downward from the top.", 'validateLabel': "VERIFY BACKWARD SOLVE" },
        { 'id': "PYR-LETTER-60", 'title': "Step 6 of 14: Solve For The Letter", 'instruction': "The outer base blocks are fixed at 12 and 8. Set only the middle block (call it c) until the top reaches 60. Reason with 12+c=a, c+8=b, a+b=60.", 'validateLabel': "VERIFY TOP = 60" },
        { 'id': "PYR-FILL-A", 'title': "Step 7 of 14: Puzzle A — Find the Missing Base", 'instruction': "Two base blocks are fixed at 4 and 6. Set the two unknown blocks until the top reads 50 and the row above reads 22 on the right.", 'validateLabel': "VERIFY TOP = 50" },
        { 'id': "PYR-FILL-B", 'title': "Step 8 of 14: Puzzle B — Solve The System", 'instruction': "Base blocks are fixed at 5 and 7. Set the unknown blocks until the row above reads 40 on the left, row three reads 9 on the right, and the top reaches 70.", 'validateLabel': "VERIFY TOP = 70" },
        { 'id': "PYR-FILL-C", 'title': "Step 9 of 14: Puzzle C — Check Against The Top", 'instruction': "Base blocks are fixed at 3 and 5. Set the two unknown blocks so row three's right cell reads 7 and the top matches the given value 35.", 'validateLabel': "VERIFY TOP = 35" },
        { 'id': "FIO-Q1", 'title': "Step 10 of 14: Apply The Rule — No Building Needed", 'instruction': "Three 3-row pyramids are fully given. Using the rule top = a + 2b + c, work out each top value in your head (no dragging) and type your three predictions.", 'validateLabel': "VERIFY 3 PREDICTIONS" },
        { 'id': "FIO-Q2-RULE", 'title': "Step 11 of 14: Derive Your Own Rule", 'instruction': "Set all four base blocks to build at least 5 DIFFERENT 4-row pyramids. Record each trial, then type your proposed rule for the top in terms of a, b, c, d and test it against every trial you built.", 'validateLabel': "VERIFY RULE" },
        { 'id': "FIO-Q3", 'title': "Step 12 of 14: Apply Your Rule Again", 'instruction': "Three 4-row pyramids are fully given. Apply top = a + 3b + 3c + d directly — no building required — and type your three predictions.", 'validateLabel': "VERIFY 3 PREDICTIONS" },
        { 'id': "FIO-Q4-VF", 'title': "Step 13 of 14: The Virahāṅka-Fibonacci Pyramid", 'instruction': "The base is fixed to the first three Virahāṅka-Fibonacci numbers 1, 2, 3. Press CHECK SEQUENCE MEMBERSHIP, then verify every cell in the pyramid is itself a Virahāṅka-Fibonacci number.", 'validateLabel': "VERIFY VF PYRAMID" },
        { 'id': "FIO-Q5-CONJECTURE", 'title': "Step 14 of 14: The Final Conjecture", 'instruction': "The base is fixed to 1, 2, 3, 5. Check sequence membership, then write one sentence about whether the top is itself a Virahāṅka-Fibonacci number — and what you think happens for ANY number of rows.", 'validateLabel': "VERIFY CONJECTURE" },
      ],
    },
    'hi': {
      'appTitle': "अंक पिरामिड प्रयोगशाला",
      'tagline': "कक्षा 8 • बीजगणित खेल",
      'initBtn': "मिशन शुरू करें",
      'headerTitle': "अंक पिरामिड प्रयोगशाला",
      'headerSubtitle': "कक्षा 8 • बीजगणित खेल",
      'ctxTitle': "यह क्यों सीखें?",
      'postTitle': "विश्लेषण और परिणाम",
      'boardTitle': "शिक्षक बोर्ड",
      'objLabel': "मिशन लक्ष्य",
      'conceptLabel': "मूल अवधारणाएं",
      'stepInfoLabel': "वर्तमान चरण",
      'navTitle': "प्रयोगशाला प्रगति",
      'btnStartLab': "प्रयोग शुरू करें",
      'btnRestart': "मिशन पुनः आरंभ करें",
      'hudMission': "वर्तमान लक्ष्य",
      'msgMissionComplete': "मिशन पूरा हुआ",
      'finalSubtitle': "आपने पिरामिड नियम top = a + 3b + 3c + d बनाया, हल किया और निकाला।",
      'msgStepComplete': "चरण पूर्ण!",
      'msgWrong': "अभी सही नहीं है — याद रखें: हर कोशिका ठीक नीचे की दो कोशिकाओं के योग के बराबर होती है। अपने ब्लॉक समायोजित करें और फिर से प्रयास करें।",
      'msgNeedFiveTrials': "अपने नियम का परीक्षण करने से पहले कम से कम 5 अलग-अलग पिरामिड दर्ज करें।",
      'msgNeedDistinctTrial': "यह ठीक वही आधार संयोजन पहले से दर्ज है — आधार संख्या बदलें।",
      'msgRuleMismatch': "आपका नियम हर दर्ज किए गए परीक्षण के वास्तविक शीर्ष से मेल नहीं खाता। नीचे बेमेल पंक्तियों की जाँच करें और इसे संशोधित करें।",
      'msgNeedVfCheck': "पहले CHECK SEQUENCE MEMBERSHIP दबाएँ, फिर सत्यापित करें।",
      'msgNeedReasoning': "सत्यापित करने से पहले अपने अनुमान की व्याख्या करते हुए कम से कम एक पूरा वाक्य जोड़ें।",
      'msgNeedPredictions': "सत्यापित करने से पहले तीनों अनुमानित शीर्ष मान दर्ज करें।",
      'proceedBtn': "आगे बढ़ें",
      'closeBtn': "बंद करें",
      'proofModalTitleTxt': "a + 3b + 3c + d कहाँ से आता है?",
      'proofModalBody': "पंक्तियाँ जोड़े जाने पर गुणांकों को पास्कल के त्रिकोण के अनुसार बढ़ते हुए देखें:\n2 पंक्तियाँ: top = a + b\n3 पंक्तियाँ: top = a + 2b + c\n4 पंक्तियाँ: top = a + 3b + 3c + d\nहर गुणांक उसके ऊपर के दो गुणांकों का योग है — ठीक वही जोड़ का नियम जो पिरामिड स्वयं उपयोग करता है।",
      'recordTrialBtn': "परीक्षण दर्ज करें",
      'testRuleBtn': "नियम जाँचें (पूर्वावलोकन)",
      'checkVfBtn': "अनुक्रम सदस्यता जाँचें",
      'baseRowLabel': "आधार पंक्ति (एम्बर ब्लॉक बदलें)",
      'topValueLabel': "शीर्ष मान",
      'predictedTopLabel': "आपका अनुमानित शीर्ष",
      'ruleInputLabel': "आपका प्रस्तावित नियम (a, b, c, d का प्रयोग करें)",
      'ruleInputPlaceholder': "जैसे a+3*b+3*c+d",
      'reasoningPrompt': "एक वाक्य में: क्या शीर्ष मान (21) स्वयं एक विरहांक-फ़िबोनाची संख्या है, और आप किसी भी पंक्ति संख्या के लिए क्या अनुमान लगाते हैं?",
      'reasoningPlaceholder': "अपना अनुमान यहाँ टाइप करें (कम से कम एक पूरा वाक्य)…",
      'trialsRecordedLabel': "दर्ज किए गए परीक्षण",
      'previewMatchLabel': "नियम मेल",
      'lockedChip': "दिया गया",
      'editableChip': "संपादित करें",
      'vfResultLabel': "अनुक्रम जाँच",
      'vfYes': "विरहांक-फ़िबोनाची संख्या",
      'vfNo': "अनुक्रम में नहीं",
      'pyramidLabel': "पिरामिड",
      'objDesc': "चार चर का उपयोग करके संख्या पिरामिड के लिए जोड़ नियम निकालें।",
      'conceptText': "प्रत्येक ब्लॉक उसके ठीक नीचे के दो ब्लॉकों का योग है। हम मध्य चरणों की गणना किए बिना शीर्ष की भविष्यवाणी कर सकते हैं।",
      'outcomesText': "आप सूत्र top = a + 3b + 3c + d प्राप्त करेंगे।",
      'steps': [
        { 'id': "PYR-INTRO", 'title': "चरण 1/14: अंक पिरामिड से मिलें", 'instruction': "तीन एम्बर आधार ब्लॉकों को तब तक बदलें जब तक वे 1, 9, 4 न पढ़ें। देखें कि ऊपर की हर कोशिका ठीक नीचे के दो ब्लॉकों का योग कैसे बनती है, जब तक शीर्ष 23 न पढ़े।", 'validateLabel': "शीर्ष = 23 सत्यापित करें" },
        { 'id': "PYR-2ROW", 'title': "चरण 2/14: सबसे सरल पिरामिड", 'instruction': "2-पंक्ति पिरामिड का एक नियम है: top = a + b। दोनों आधार ब्लॉकों को 6 और 2 पर सेट करें ताकि शीर्ष 8 पढ़े।", 'validateLabel': "शीर्ष = 8 सत्यापित करें" },
        { 'id': "PYR-3ROW", 'title': "चरण 3/14: तीन पंक्तियाँ, एक नियम", 'instruction': "आधार ब्लॉकों को 3, 4, 3 पर सेट करें। पुष्टि करें कि मध्य पंक्ति 7 और 7 बनती है इससे पहले कि शीर्ष 14 तक पहुँचे।", 'validateLabel': "शीर्ष = 14 सत्यापित करें" },
        { 'id': "PYR-4ROW", 'title': "चरण 4/14: चार पंक्तियाँ ऊँची", 'instruction': "एक पूर्ण 4-पंक्ति पिरामिड बनाएं। आधार ब्लॉकों को 5, 4, 5, 0 पर सेट करें और देखें कि योग शीर्ष मान 32 तक कैसे बढ़ते हैं।", 'validateLabel': "शीर्ष = 32 सत्यापित करें" },
        { 'id': "PYR-BACKWARD-FILL", 'title': "चरण 5/14: पीछे की ओर काम करना", 'instruction': "शीर्ष 10 पर स्थिर है और सबसे बायां आधार ब्लॉक 1 (सियान, दिया गया) पर स्थिर है। दोनों अज्ञात एम्बर ब्लॉकों को सेट करें जब तक ऊपर की पंक्ति 4 और 6 न पढ़े, और शीर्ष 10 पर लॉक हो जाए — शीर्ष से नीचे घटाकर हल करें।", 'validateLabel': "पश्चगामी हल सत्यापित करें" },
        { 'id': "PYR-LETTER-60", 'title': "चरण 6/14: अक्षर के लिए हल करें", 'instruction': "बाहरी आधार ब्लॉक 12 और 8 पर स्थिर हैं। केवल मध्य ब्लॉक (इसे c कहें) सेट करें जब तक शीर्ष 60 तक न पहुँचे। 12+c=a, c+8=b, a+b=60 से तर्क करें।", 'validateLabel': "शीर्ष = 60 सत्यापित करें" },
        { 'id': "PYR-FILL-A", 'title': "चरण 7/14: पहेली A — लुप्त आधार खोजें", 'instruction': "दो आधार ब्लॉक 4 और 6 पर स्थिर हैं। दोनों अज्ञात ब्लॉकों को सेट करें जब तक शीर्ष 50 पढ़े और ऊपर की पंक्ति दाईं ओर 22 पढ़े।", 'validateLabel': "शीर्ष = 50 सत्यापित करें" },
        { 'id': "PYR-FILL-B", 'title': "चरण 8/14: पहेली B — प्रणाली हल करें", 'instruction': "आधार ब्लॉक 5 और 7 पर स्थिर हैं। अज्ञात ब्लॉकों को सेट करें जब तक ऊपर की पंक्ति बाईं ओर 40 पढ़े, तीसरी पंक्ति दाईं ओर 9 पढ़े, और शीर्ष 70 तक पहुँचे।", 'validateLabel': "शीर्ष = 70 सत्यापित करें" },
        { 'id': "PYR-FILL-C", 'title': "चरण 9/14: पहेली C — शीर्ष के विरुद्ध जाँचें", 'instruction': "आधार ब्लॉक 3 और 5 पर स्थिर हैं। दोनों अज्ञात ब्लॉकों को सेट करें ताकि तीसरी पंक्ति का दायां सेल 7 पढ़े और शीर्ष दिए गए मान 35 से मेल खाए।", 'validateLabel': "शीर्ष = 35 सत्यापित करें" },
        { 'id': "FIO-Q1", 'title': "चरण 10/14: नियम लागू करें — बनाने की आवश्यकता नहीं", 'instruction': "तीन 3-पंक्ति पिरामिड पूरी तरह दिए गए हैं। नियम top = a + 2b + c का उपयोग करके, प्रत्येक शीर्ष मान मन में निकालें और अपने तीन अनुमान टाइप करें।", 'validateLabel': "3 अनुमान सत्यापित करें" },
        { 'id': "FIO-Q2-RULE", 'title': "चरण 11/14: अपना नियम निकालें", 'instruction': "कम से कम 5 अलग-अलग 4-पंक्ति पिरामिड बनाने के लिए सभी चार आधार ब्लॉक सेट करें। हर परीक्षण दर्ज करें, फिर a, b, c, d के रूप में शीर्ष के लिए अपना प्रस्तावित नियम टाइप करें और इसे हर परीक्षण के विरुद्ध जाँचें।", 'validateLabel': "नियम सत्यापित करें" },
        { 'id': "FIO-Q3", 'title': "चरण 12/14: अपना नियम फिर से लागू करें", 'instruction': "तीन 4-पंक्ति पिरामिड पूरी तरह दिए गए हैं। top = a + 3b + 3c + d सीधे लागू करें — बनाने की आवश्यकता नहीं — और अपने तीन अनुमान टाइप करें।", 'validateLabel': "3 अनुमान सत्यापित करें" },
        { 'id': "FIO-Q4-VF", 'title': "चरण 13/14: विरहांक-फ़िबोनाची पिरामिड", 'instruction': "आधार पहले तीन विरहांक-फ़िबोनाची अंकों 1, 2, 3 पर स्थिर है। CHECK SEQUENCE MEMBERSHIP दबाएँ, फिर सत्यापित करें कि पिरामिड की हर कोशिका स्वयं एक विरहांक-फ़िबोनाची संख्या है।", 'validateLabel': "VF पिरामिड सत्यापित करें" },
        { 'id': "FIO-Q5-CONJECTURE", 'title': "चरण 14/14: अंतिम अनुमान", 'instruction': "आधार 1, 2, 3, 5 पर स्थिर है। अनुक्रम सदस्यता जाँचें, फिर एक वाक्य लिखें कि क्या शीर्ष स्वयं एक विरहांक-फ़िबोनाची संख्या है — और आप किसी भी पंक्ति संख्या के लिए क्या अनुमान लगाते हैं।", 'validateLabel': "अनुमान सत्यापित करें" },
      ],
    }
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

// --- 2. CONFIG & MATH ---
class PyramidScenario {
  final String id;
  final String mode;
  final int numRows;
  final List<int>? base;
  final List<bool>? locked;
  final int? targetTop;
  final int? targetRow2Left;
  final int? targetRow2Right;
  final int? targetRow3Right;
  final List<List<int>>? bases;
  final String? ruleLabel;

  PyramidScenario({
    required this.id,
    required this.mode,
    required this.numRows,
    this.base,
    this.locked,
    this.targetTop,
    this.targetRow2Left,
    this.targetRow2Right,
    this.targetRow3Right,
    this.bases,
    this.ruleLabel,
  });
}

final List<PyramidScenario> scenarios = [
  PyramidScenario(id: "PYR-INTRO", mode: "build", numRows: 3, base: [2, 2, 2], locked: [false, false, false]),
  PyramidScenario(id: "PYR-2ROW", mode: "build", numRows: 2, base: [1, 1], locked: [false, false]),
  PyramidScenario(id: "PYR-3ROW", mode: "build", numRows: 3, base: [1, 1, 1], locked: [false, false, false]),
  PyramidScenario(id: "PYR-4ROW", mode: "build", numRows: 4, base: [1, 1, 1, 1], locked: [false, false, false, false]),
  PyramidScenario(id: "PYR-BACKWARD-FILL", mode: "build", numRows: 3, base: [1, 1, 1], locked: [true, false, false], targetTop: 10, targetRow2Left: 4),
  PyramidScenario(id: "PYR-LETTER-60", mode: "build", numRows: 3, base: [12, 1, 8], locked: [true, false, true], targetTop: 60),
  PyramidScenario(id: "PYR-FILL-A", mode: "build", numRows: 4, base: [4, 1, 6, 1], locked: [true, false, true, false], targetTop: 50, targetRow2Right: 22),
  PyramidScenario(id: "PYR-FILL-B", mode: "build", numRows: 4, base: [5, 1, 7, 1], locked: [true, false, true, false], targetTop: 70, targetRow2Left: 40, targetRow3Right: 9),
  PyramidScenario(id: "PYR-FILL-C", mode: "build", numRows: 4, base: [3, 5, 1, 1], locked: [true, true, false, false], targetTop: 35, targetRow3Right: 7),
  PyramidScenario(id: "FIO-Q1", mode: "rule-apply", numRows: 3, bases: [[4, 13, 8], [7, 11, 3], [10, 14, 25]], ruleLabel: "a + 2b + c"),
  PyramidScenario(id: "FIO-Q2-RULE", mode: "rule-derive", numRows: 4, base: [2, 3, 4, 5], locked: [false, false, false, false]),
  PyramidScenario(id: "FIO-Q3", mode: "rule-apply", numRows: 4, bases: [[8, 19, 21, 13], [7, 18, 19, 6], [9, 7, 5, 11]], ruleLabel: "a + 3b + 3c + d"),
  PyramidScenario(id: "FIO-Q4-VF", mode: "vf-check", numRows: 3, base: [1, 2, 3], locked: [true, true, true]),
  PyramidScenario(id: "FIO-Q5-CONJECTURE", mode: "vf-conjecture", numRows: 4, base: [1, 2, 3, 5], locked: [true, true, true, true]),
];

class PyramidMath {
  static List<List<int>> pyramidSumFromBase(List<int> baseRow) {
    List<List<int>> rows = [List.from(baseRow)];
    List<int> current = List.from(baseRow);
    while (current.length > 1) {
      List<int> next = [];
      for (int i = 0; i < current.length - 1; i++) {
        next.add(current[i] + current[i + 1]);
      }
      rows.add(next);
      current = next;
    }
    return rows.reversed.toList();
  }

  static int topValueFromBase(List<int> baseRow) {
    return pyramidSumFromBase(baseRow).first.first;
  }

  static num evaluateRule(String exprStr, int a, int b, int c, int d) {
    try {
      String exp = exprStr.replaceAll(' ', '');
      exp = exp.replaceAllMapped(RegExp(r'(\d)([abcd])'), (match) => '${match[1]}*${match[2]}');
      
      exp = exp.replaceAll('a', a.toString())
          .replaceAll('b', b.toString())
          .replaceAll('c', c.toString())
          .replaceAll('d', d.toString());
      
      List<String> terms = exp.split('+');
      num sum = 0;
      for (String term in terms) {
        if (term.contains('*')) {
          List<String> factors = term.split('*');
          num prod = 1;
          for (String factor in factors) {
            prod *= double.parse(factor);
          }
          sum += prod;
        } else {
          sum += double.parse(term);
        }
      }
      return sum;
    } catch (e) {
      return double.nan;
    }
  }

  static List<int> vfSequenceUpTo(int maxVal) {
    List<int> seq = [1, 2];
    while (seq.last < maxVal) {
      seq.add(seq.last + seq[seq.length - 2]);
    }
    return seq;
  }

  static bool isVfPyramid(List<List<int>> rows) {
    List<int> flat = rows.expand((e) => e).toList();
    int maxVal = flat.reduce(math.max);
    Set<int> vfSet = vfSequenceUpTo(maxVal).toSet();
    return flat.every((v) => vfSet.contains(v));
  }
}

// --- 3. MAIN ACTIVITY ---
class NumberPyramidsActivity extends StatefulWidget {
  const NumberPyramidsActivity({super.key});

  @override
  State<NumberPyramidsActivity> createState() => _NumberPyramidsActivityState();
}

class _NumberPyramidsActivityState extends State<NumberPyramidsActivity> {
  String _lang = 'en';
  bool _isSidebarOpen = true;
  int _currentStepIndex = 0;
  bool _isCompleted = false;

  List<int> _baseRow = [];
  List<bool> _lockedBase = [];
  
  List<String> _predictions = ['', '', ''];
  List<Map<String, dynamic>> _trials = [];
  String _proposedRule = "";
  String _reasoning = "";
  bool _vfChecked = false;
  
  bool _isShutterOpen = false;

  // Dedicated audio players initialized with ReleaseMode.stop
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback on Android
  static const String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class8/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class8/mixkit_2574.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _loadStep(_currentStepIndex);
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
    _errorPlayer.dispose();
    super.dispose();
  }

  void _playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _resetLab() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _currentStepIndex = 0;
      _isCompleted = false;
      _isShutterOpen = false;
      _lang = 'en';
      _loadStep(0);
    });
  }

  void _toggleLanguage(String newLang) {
    if (_lang == newLang) return;
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _lang = newLang;
    });
  }

  void _loadStep(int index) {
    if (index >= scenarios.length) {
      setState(() => _isCompleted = true);
      _playSound(_successPlayer, _successUrl);
      return;
    }
    
    var scenario = scenarios[index];
    setState(() {
      _currentStepIndex = index;
      if (scenario.base != null) {
        _baseRow = List.from(scenario.base!);
      }
      if (scenario.locked != null) {
        _lockedBase = List.from(scenario.locked!);
      }
      _predictions = ['', '', ''];
      _trials = [];
      _proposedRule = "";
      _reasoning = "";
      _vfChecked = false;
    });
  }

  String _t(String key) {
    return I18n.get(_lang, key);
  }
  
  Map<String, dynamic> _stepDict() {
    return (I18n.data[_lang]!['steps'] as List)[_currentStepIndex];
  }

  void _toggleSidebar() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _showErrorPopup(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
    _playSound(_errorPlayer, _errorUrl);
  }

  void _verifyStep() {
    var scenario = scenarios[_currentStepIndex];
    bool passed = false;

    if (scenario.mode == 'build') {
      List<List<int>> currentPyramid = PyramidMath.pyramidSumFromBase(_baseRow);
      if (scenario.id == 'PYR-INTRO' && currentPyramid[0][0] == 23 && _baseRow.join(',') == '1,9,4') passed = true;
      else if (scenario.id == 'PYR-2ROW' && currentPyramid[0][0] == 8 && _baseRow.join(',') == '6,2') passed = true;
      else if (scenario.id == 'PYR-3ROW' && currentPyramid[0][0] == 14 && _baseRow.join(',') == '3,4,3') passed = true;
      else if (scenario.id == 'PYR-4ROW' && currentPyramid[0][0] == 32 && _baseRow.join(',') == '5,4,5,0') passed = true;
      else if (scenario.id == 'PYR-BACKWARD-FILL' && currentPyramid[0][0] == 10 && currentPyramid[1][0] == 4) passed = true;
      else if (scenario.id == 'PYR-LETTER-60' && currentPyramid[0][0] == 60) passed = true;
      else if (scenario.id == 'PYR-FILL-A' && currentPyramid[0][0] == 50 && currentPyramid[1][1] == 22) passed = true;
      else if (scenario.id == 'PYR-FILL-B' && currentPyramid[0][0] == 70 && currentPyramid[1][0] == 40 && currentPyramid[2][2] == 9) passed = true;
      else if (scenario.id == 'PYR-FILL-C' && currentPyramid[0][0] == 35 && currentPyramid[2][2] == 7) passed = true;
    } else if (scenario.mode == 'rule-apply') {
      if (_predictions.any((p) => p.isEmpty)) {
        _showErrorPopup(_t('msgNeedPredictions'));
        return;
      }
      bool allMatch = true;
      for (int i=0; i<3; i++) {
        int expectedTop = PyramidMath.topValueFromBase(scenario.bases![i]);
        if (int.tryParse(_predictions[i]) != expectedTop) allMatch = false;
      }
      passed = allMatch;
    } else if (scenario.mode == 'rule-derive') {
      if (_trials.length < 5) {
        _showErrorPopup(_t('msgNeedFiveTrials'));
        return;
      }
      bool allMatch = true;
      for (var t in _trials) {
        List<int> base = List<int>.from(t['base']);
        num ruleOut = PyramidMath.evaluateRule(_proposedRule, base[0], base[1], base[2], base[3]);
        if (ruleOut != t['actual']) {
          allMatch = false;
          break;
        }
      }
      if (!allMatch) {
        _showErrorPopup(_t('msgRuleMismatch'));
        return;
      }
      passed = true;
    } else if (scenario.mode == 'vf-check') {
      if (!_vfChecked) {
        _showErrorPopup(_t('msgNeedVfCheck'));
        return;
      }
      passed = true;
    } else if (scenario.mode == 'vf-conjecture') {
      if (!_vfChecked) {
        _showErrorPopup(_t('msgNeedVfCheck'));
        return;
      }
      if (_reasoning.trim().isEmpty) {
        _showErrorPopup(_t('msgNeedReasoning'));
        return;
      }
      passed = true;
    }

    if (passed) {
      _playSound(_successPlayer, _successUrl);
      _loadStep(_currentStepIndex + 1);
    } else {
      _showErrorPopup(_t('msgWrong'));
    }
  }

  void _recordTrial() {
    String currentBase = _baseRow.join(',');
    if (_trials.any((t) => t['baseStr'] == currentBase)) {
      _showErrorPopup(_t('msgNeedDistinctTrial'));
      return;
    }
    
    int actualTop = PyramidMath.topValueFromBase(_baseRow);
    
    setState(() {
      _trials.add({
        'baseStr': currentBase,
        'base': List<int>.from(_baseRow),
        'actual': actualTop,
      });
    });
    _playSound(_clickPlayer, _clickUrl);
  }

  Widget _buildLanguageAndControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _toggleLanguage('en'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _lang == 'en' ? Colors.cyan : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Text("EN", style: TextStyle(color: _lang == 'en' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleLanguage('hi'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _lang == 'hi' ? Colors.cyan : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Text("HI", style: TextStyle(color: _lang == 'hi' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _resetLab,
          )
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    var scenario = scenarios[_currentStepIndex];
    if (scenario.mode == 'rule-apply') {
      return Column(
        children: List.generate(3, (i) {
          String rule = scenario.ruleLabel!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(child: Text("Pyramid ${i+1} (${scenario.bases![i].join(', ')}):\n$rule", style: const TextStyle(fontSize: 12, color: Colors.grey))),
                SizedBox(
                  width: 80,
                  child: TextField(
                    onChanged: (val) => _predictions[i] = val,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(filled: true, fillColor: Colors.black38, border: OutlineInputBorder()),
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        }),
      );
    } else if (scenario.mode == 'rule-derive') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _recordTrial,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: Text(_t('recordTrialBtn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text("${_t('trialsRecordedLabel')}: ${_trials.length}", style: const TextStyle(color: Colors.white70)),
          TextField(
            onChanged: (val) => _proposedRule = val,
            decoration: InputDecoration(
              labelText: _t('ruleInputLabel'),
              hintText: _t('ruleInputPlaceholder'),
              filled: true,
              fillColor: Colors.black38,
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    } else if (scenario.mode == 'vf-check' || scenario.mode == 'vf-conjecture') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() => _vfChecked = true);
              _playSound(_clickPlayer, _clickUrl);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text(_t('checkVfBtn')),
          ),
          if (_vfChecked)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                PyramidMath.isVfPyramid(PyramidMath.pyramidSumFromBase(_baseRow)) ? _t('vfYes') : _t('vfNo'),
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          if (scenario.mode == 'vf-conjecture')
            TextField(
              onChanged: (val) => _reasoning = val,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _t('reasoningPrompt'),
                hintText: _t('reasoningPlaceholder'),
                filled: true,
                fillColor: Colors.black38,
              ),
              style: const TextStyle(color: Colors.white),
            )
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.95),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree, color: Colors.cyan, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_t('headerTitle'), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_t('headerSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.2)),
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

            _buildSectionHeader(Icons.track_changes, Colors.cyan, _t('objLabel')),
            _buildSectionBody(_t('objDesc')),
            const SizedBox(height: 10),

            _buildSectionHeader(Icons.lightbulb, Colors.amber, _t('conceptLabel')),
            _buildSectionBody(_t('conceptText')),
            const SizedBox(height: 10),

            _buildSectionHeader(Icons.analytics, Colors.indigoAccent, _t('postTitle')),
            _buildSectionBody(_t('outcomesText')),
            const SizedBox(height: 10),

            _buildSectionHeader(Icons.checklist, Colors.purpleAccent, _t('stepInfoLabel')),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(_stepDict()['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      Text("STEP ${_currentStepIndex+1}/14", style: const TextStyle(fontSize: 10, color: Colors.cyan)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: (_currentStepIndex+1)/14, backgroundColor: Colors.white12, color: Colors.cyan),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.cyan, width: 3)),
                      color: Colors.black45,
                    ),
                    child: Text(_stepDict()['instruction'], style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildControlPanel(),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verifyStep,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(_stepDict()['validateLabel'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("© ZEROSCIENCELAB | Fall in Love with Math and Science", textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontSize: 12)),
            ),
          ]
        )
      )
    );
  }

  Widget _buildSectionHeader(IconData icon, Color color, String title) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildSectionBody(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // 1. Center Canvas (Isometric Pyramid)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: CustomPaint(
                    size: const Size(600, 600),
                    painter: IsometricPyramidPainter(
                      baseRow: _baseRow,
                      lockedBase: _lockedBase,
                      scenario: scenarios[_currentStepIndex],
                    ),
                  ),
                ),
              ),
            ),

            // Base Row Editor (Overlaid at bottom for easy interaction)
            if (scenarios[_currentStepIndex].mode == 'build' || scenarios[_currentStepIndex].mode == 'rule-derive')
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_baseRow.length, (i) {
                    bool isLocked = scenarios[_currentStepIndex].locked![i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocked ? Colors.cyan.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                              border: Border.all(color: isLocked ? Colors.cyan : Colors.amber),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isLocked ? _t('lockedChip') : _t('editableChip'),
                              style: TextStyle(fontSize: 10, color: isLocked ? Colors.cyan : Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (!isLocked)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.white54),
                                  onPressed: () {
                                    _playSound(_clickPlayer, _clickUrl);
                                    setState(() { _baseRow[i]--; });
                                  },
                                ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isLocked ? Colors.cyan.withOpacity(0.8) : Colors.amber.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(_baseRow[i].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ),
                              if (!isLocked)
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.white54),
                                  onPressed: () {
                                    _playSound(_clickPlayer, _clickUrl);
                                    setState(() { _baseRow[i]++; });
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),

            // Sidebar Container
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0, bottom: 0, width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Sidebar Edge Toggle Button (Hamburger Menu on Top-Left) and Back Button
            if (_isShutterOpen)
              Positioned(
                left: 16,
                top: 16,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _toggleSidebar,
                ),
              ),

            // Shutter Start overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutQuart,
              top: _isShutterOpen ? -MediaQuery.of(context).size.height : 0,
              left: 0, right: 0, height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: Colors.cyan, 
                          border: Border.all(color: const Color(0xFF0F172A), width: 5), 
                          boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 40)]
                        ),
                        child: const Icon(Icons.account_tree, color: Colors.black, size: 60),
                      ),
                      const SizedBox(height: 32),
                      Text(_t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(_t('tagline'), style: const TextStyle(color: Colors.cyan, fontSize: 16, letterSpacing: 5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 60),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shadowColor: Colors.cyan.withOpacity(0.3),
                          elevation: 10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          _playSound(_fxPlayer, _shutterUrl);
                          setState(() => _isShutterOpen = true);
                        },
                        icon: const Icon(Icons.power_settings_new, color: Colors.black, size: 28),
                        label: Text(_t('initBtn'), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Final Success Screen (Scrollable)
            if (_isCompleted)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.cyan, width: 3),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.green, size: 90),
                            const SizedBox(height: 20),
                            Text(_t('msgMissionComplete'), style: const TextStyle(color: Colors.cyan, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text(_t('finalSubtitle'), style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh, color: Colors.black),
                              label: Text(_t('btnRestart'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                              onPressed: _resetLab,
                            )
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

// --- 4. ISOMETRIC 3D RENDERER ---
class IsometricPyramidPainter extends CustomPainter {
  final List<int> baseRow;
  final List<bool> lockedBase;
  final PyramidScenario scenario;

  IsometricPyramidPainter({required this.baseRow, required this.lockedBase, required this.scenario});

  @override
  void paint(Canvas canvas, Size size) {
    if (scenario.mode == 'rule-apply') {
      final TextPainter tp = TextPainter(
        text: const TextSpan(text: "Apply rule directly, no building needed.", style: TextStyle(color: Colors.white54, fontSize: 20)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset((size.width - tp.width)/2, size.height/2));
      return;
    }

    List<List<int>> pyramid = PyramidMath.pyramidSumFromBase(baseRow);
    int numRows = pyramid.length;
    
    double cubeSize = 50.0;
    double spacing = 10.0;

    canvas.translate(size.width / 2, size.height / 4);

    for (int r = 0; r < numRows; r++) {
      int cols = pyramid[r].length;
      for (int c = 0; c < cols; c++) {
        int val = pyramid[r][c];
        
        double px = (c - cols/2.0 + 0.5) * (cubeSize + spacing) * 1.2;
        double py = r * (cubeSize + spacing) * 1.1;

        bool isBase = (r == numRows - 1);
        bool isLocked = isBase ? lockedBase[c] : false;
        Color baseColor = isBase ? (isLocked ? Colors.cyan : Colors.amber) : Colors.deepPurpleAccent;
        if (r == 0) baseColor = Colors.orangeAccent;

        _drawCube(canvas, px, py, cubeSize, baseColor, val.toString());
      }
    }
  }

  void _drawCube(Canvas canvas, double cx, double cy, double size, Color color, String text) {
    Path topFace = Path()
      ..moveTo(cx, cy - size * 0.5)
      ..lineTo(cx + size * 0.866, cy - size * 0.25)
      ..lineTo(cx, cy)
      ..lineTo(cx - size * 0.866, cy - size * 0.25)
      ..close();

    Path leftFace = Path()
      ..moveTo(cx - size * 0.866, cy - size * 0.25)
      ..lineTo(cx, cy)
      ..lineTo(cx, cy + size * 0.5)
      ..lineTo(cx - size * 0.866, cy + size * 0.25)
      ..close();

    Path rightFace = Path()
      ..moveTo(cx + size * 0.866, cy - size * 0.25)
      ..lineTo(cx, cy)
      ..lineTo(cx, cy + size * 0.5)
      ..lineTo(cx + size * 0.866, cy + size * 0.25)
      ..close();

    Paint topPaint = Paint()..color = color.withOpacity(0.8)..style = PaintingStyle.fill;
    Paint leftPaint = Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.fill;
    Paint rightPaint = Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.fill;
    Paint strokePaint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.0;

    canvas.drawPath(topFace, topPaint);
    canvas.drawPath(topFace, strokePaint);
    canvas.drawPath(leftFace, leftPaint);
    canvas.drawPath(leftFace, strokePaint);
    canvas.drawPath(rightFace, rightPaint);
    canvas.drawPath(rightFace, strokePaint);

    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    canvas.save();
    canvas.translate(cx, cy);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IsometricPyramidPainter oldDelegate) {
    return true; 
  }
}
