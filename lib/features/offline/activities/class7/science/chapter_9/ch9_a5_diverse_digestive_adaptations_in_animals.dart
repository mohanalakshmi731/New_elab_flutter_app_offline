// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 9 • Activity 5
/// Diverse Digestive Adaptations in Animals.
///
/// Native Flutter port of `Cl7S-Ch9-A5-Diverse_Digestive_Adaptations_in_Animals.html`.
/// A see-through cow swallows grass into its rumen, brings the cud back up,
/// chews it again and sends it on to be absorbed; a see-through hen swallows
/// whole seeds and grit so that its muscular gizzard can grind them.
class Ch9A5DiverseDigestiveAdaptationsInAnimalsPage extends StatefulWidget {
  const Ch9A5DiverseDigestiveAdaptationsInAnimalsPage({super.key});

  @override
  State<Ch9A5DiverseDigestiveAdaptationsInAnimalsPage> createState() =>
      _Ch9A5DiverseDigestiveAdaptationsInAnimalsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, pickup 2356, magic 871.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer.
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / success popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// HTML `playSound('pop')`: swallowing, inspecting, rumination, chewing,
  /// grinding.
  pop('pop.mp3'),

  /// Picking a food item up from the tray.
  pickup('pickup.mp3'),

  /// Confetti burst at the end of a scenario.
  magic('magic.mp3');

  const _Sound(this.file);
  final String file;

  @override
  void play() => _Audio.play(this);
}

/// Fire-and-forget player for this lab's tones. A small pool lets tones
/// overlap; it is created on the first tone and freed when the lab closes.
abstract final class _Audio {
  static const int _poolSize = 4;
  static final List<AudioPlayer> _players = [];
  static int _next = 0;

  /// Plays [sound] without blocking. Silent under `flutter test`, which has
  /// no audio plugin. Errors (missing plugin, unsupported platform) are
  /// swallowed so audio never breaks the lab.
  static void play(_Sound sound, {double volume = 0.6}) {
    if (WidgetsBinding.instance is! WidgetsFlutterBinding) return;
    unawaited(_play(sound, volume));
  }

  static Future<void> _play(_Sound sound, double volume) async {
    try {
      if (_players.isEmpty) await _createPlayers();
      final player = _players[_next];
      _next = (_next + 1) % _players.length;
      await player.stop();
      await player.play(AssetSource('audio/class7/${sound.file}'), volume: volume, mode: PlayerMode.lowLatency);
    } catch (e) {
      if (kDebugMode) debugPrint('Audio: could not play ${sound.name}: $e');
    }
  }

  static Future<void> _createPlayers() async {
    for (var i = 0; i < _poolSize; i++) {
      _players.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
    }
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
    } catch (_) {
      // Not supported on every platform; tones still play.
    }
  }

  /// Frees the players; called by the controller when the lab closes.
  static void release() {
    for (final player in _players) {
      unawaited(player.dispose());
    }
    _players.clear();
    _next = 0;
  }
}

// ===================================================================== THEME

/// Tailwind colours used by this lab (indigo brand, organ and food colours
/// from the Three.js materials).
abstract final class _Colors {
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1); // med.blue
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981); // bio.main
  static const Color emerald600 = Color(0xFF059669);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // grass
  static const Color green600 = Color(0xFF16A34A); // food bolus
  static const Color green800 = Color(0xFF166534);
  static const Color lime500 = Color(0xFF84CC16); // chewed cud
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B); // cow intestine, seeds
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color yellow300 = Color(0xFFFDE047); // nutrients
  static const Color yellow700 = Color(0xFFA16207);
  static const Color yellow800 = Color(0xFF854D0E); // food paste
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose500 = Color(0xFFF43F5E); // abomasum
  static const Color rose600 = Color(0xFFE11D48); // reticulum
  static const Color rose700 = Color(0xFFBE123C); // rumen, esophagus
  static const Color rose950 = Color(0xFF4C0519);
  static const Color pink300 = Color(0xFFF9A8D4);
  static const Color pink800 = Color(0xFF9D174D); // omasum
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red800 = Color(0xFF991B1B); // gizzard lining
  static const Color red900 = Color(0xFF7F1D1D); // gizzard muscle
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables, indigo accent): sidebar, canvas, popups, curtain, buttons.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xEB0F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500,
    onAccent: Colors.white,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x594338CA),
    curtainText: Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: Color(0x996366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: Color(0xFFF8FAFC),
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo600,
    onAccent: Colors.white,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue600,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate800,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x594338CA),
    curtainText: Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.slate300,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xF2FFFFFF),
    labelText: _Colors.slate800,
  );

  static LabPalette of(bool isDark) => isDark ? dark : light;
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px).
const _font = LabFont(family: null, fallback: null, size: 15, minSize: 12, maxSize: 24);

/// This lab's tones, palettes and font, handed to the shared shell.
const _style = LabStyle(
  click: _Sound.click,
  toggle: _Sound.toggle,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.scenario,
  curtain: _Sound.curtain,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Diverse Digestive Adaptations in Animals',
    'app_subtitle': 'Class 7 • Life Processes in Animals',
    'scen_1_opt': "Scenario 1: The Ruminant's Two-Step Meal",
    'scen_2_opt': "Scenario 2: The Bird's Stone Grinder",
    'welcome_lab': 'Welcome to the Biology Lab.',
    'concept_exp': 'Exploration Steps',
    'exploration': 'Step',
    'observation': 'Observation',
    'observation_title': 'Key Takeaway',
    'sc_complete': 'Scenario {n} Complete!',
    // Setup board.
    'board_desc_1':
        "Cows eat tough grass. Let's explore their unique four-chambered stomach and how they chew their food twice!",
    'board_desc_2': "Birds don't have teeth! Let's discover how they grind up hard seeds using stones.",
    'board_btn': 'Setup Activity',
    // Current task (HTML HUD) per scenario and step.
    'hud_1_1': "DRAG the clump of grass and DROP it into the cow's mouth area.",
    'hud_1_2': "CLICK 'Inspect Stomach' to see a cross-section of the cow's digestive system.",
    'hud_1_3': "CLICK 'Rumination' to bring the partially digested food (cud) back up.",
    'hud_1_4': "CLICK and HOLD the 'Hold to Chew' button to thoroughly grind the cud.",
    'hud_1_5': "DRAG the finely chewed cud back to the cow's mouth for final digestion.",
    'hud_2_1': "DRAG the seeds and DROP them into the bird's beak.",
    'hud_2_2': "CLICK 'Inspect Digestive Tract' to see where the whole seeds go.",
    'hud_2_3': "DRAG the grit (small stones) and DROP it into the bird's beak.",
    'hud_2_4': "CLICK 'Grind Food' to activate the powerful muscles of the gizzard.",
    'hud_2_5': 'Observe the digested food moving to the intestine.',
    // Tray items and buttons.
    'lbl_grass': 'Grass',
    'lbl_cud': 'Chewed Cud',
    'lbl_seeds': 'Seeds',
    'lbl_grit': 'Grit',
    'btn_inspect': 'Inspect Stomach',
    'btn_inspect_tract': 'Inspect Digestive Tract',
    'btn_ruminate': 'Rumination',
    'btn_chew_hold': 'Hold to Chew',
    'lbl_chewing': 'Chewing...',
    'btn_grind': 'Grind Food',
    // Feedback.
    'grass_eaten': 'Grass already eaten.',
    'chew_first': 'Chew the cud first.',
    'seeds_eaten': 'Seeds already eaten.',
    'grit_now': 'Grit must be added now.',
    'drop_on_mouth': "Drop it into the cow's mouth!",
    'drop_on_beak': "Drop it into the bird's beak!",
    'drop_here': 'Drop Here',
    // Conclusions.
    'sum_head_1': 'The Ruminant Advantage!',
    'sum_body_1':
        'Cows have a four-chambered stomach adapted for eating tough plants. By regurgitating their food (rumination) and chewing it twice, they physically break down the tough plant fibers so microscopic bacteria in their stomach can properly digest it.',
    'sum_head_2': "Nature's Internal Teeth!",
    'sum_body_2':
        'Since birds cannot chew, they rely on a muscular organ called the gizzard. By swallowing small stones (grit), the gizzard acts like a millstone, mechanically grinding hard food like seeds so nutrients can be absorbed.',
    // Scene labels.
    'lbl_cow': 'Cow (Ruminant)',
    'lbl_hen': 'Hen (Bird)',
    'lbl_mouth': 'Mouth',
    'lbl_beak': 'Beak',
    'lbl_esophagus': 'Esophagus',
    'lbl_rumen': 'Rumen',
    'lbl_reticulum': 'Reticulum',
    'lbl_omasum': 'Omasum',
    'lbl_abomasum': 'Abomasum',
    'lbl_intestine': 'Intestine',
    'lbl_crop': 'Crop',
    'lbl_gizzard': 'Gizzard',
    'lbl_microbes': 'Microbes',
    'lbl_cud_raw': 'Cud',
    'lbl_nutrients': 'Nutrients absorbed',
  },
  'hi': {
    'app_title': 'जानवरों में विविध पाचन अनुकूलन',
    'app_subtitle': 'कक्षा 7 • जंतुओं में जैव प्रक्रम',
    'scen_1_opt': 'परिदृश्य 1: जुगाली करने वाले का दो-चरणीय भोजन',
    'scen_2_opt': 'परिदृश्य 2: पक्षी की पत्थर की चक्की',
    'welcome_lab': 'जीव विज्ञान लैब में आपका स्वागत है।',
    'concept_exp': 'अन्वेषण चरण',
    'exploration': 'चरण',
    'observation': 'अवलोकन',
    'observation_title': 'मुख्य निष्कर्ष',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'board_desc_1':
        'गाय कठोर घास खाती है। आइए उसके अनोखे चार-कक्षीय पेट को देखें और जानें कि वह अपना भोजन दो बार कैसे चबाती है!',
    'board_desc_2': 'पक्षियों के दाँत नहीं होते! आइए जानें कि वे कंकड़ की मदद से कठोर बीजों को कैसे पीसते हैं।',
    'board_btn': 'गतिविधि सेट करें',
    'hud_1_1': 'घास के गुच्छे को खींचकर गाय के मुँह पर छोड़ें।',
    'hud_1_2': "गाय के पाचन तंत्र का अनुप्रस्थ दृश्य देखने के लिए 'पेट का निरीक्षण करें' पर क्लिक करें।",
    'hud_1_3': "आंशिक रूप से पचे भोजन (कड) को वापस मुँह में लाने के लिए 'जुगाली' पर क्लिक करें।",
    'hud_1_4': "कड को अच्छी तरह पीसने के लिए 'चबाने के लिए दबाए रखें' बटन को दबाकर रखें।",
    'hud_1_5': 'अंतिम पाचन के लिए बारीक चबाए गए कड को वापस गाय के मुँह तक खींचें।',
    'hud_2_1': 'बीजों को खींचकर पक्षी की चोंच में छोड़ें।',
    'hud_2_2': "साबुत बीज कहाँ जाते हैं, यह देखने के लिए 'पाचन तंत्र का निरीक्षण करें' पर क्लिक करें।",
    'hud_2_3': 'कंकड़ (छोटे पत्थर) खींचकर पक्षी की चोंच में छोड़ें।',
    'hud_2_4': "गिज़र्ड की शक्तिशाली पेशियों को सक्रिय करने के लिए 'भोजन पीसें' पर क्लिक करें।",
    'hud_2_5': 'पचे हुए भोजन को आंत की ओर जाते हुए देखें।',
    'lbl_grass': 'घास',
    'lbl_cud': 'चबाया हुआ कड',
    'lbl_seeds': 'बीज',
    'lbl_grit': 'कंकड़',
    'btn_inspect': 'पेट का निरीक्षण करें',
    'btn_inspect_tract': 'पाचन तंत्र का निरीक्षण करें',
    'btn_ruminate': 'जुगाली',
    'btn_chew_hold': 'चबाने के लिए दबाए रखें',
    'lbl_chewing': 'चबा रहा है...',
    'btn_grind': 'भोजन पीसें',
    'grass_eaten': 'घास पहले ही खाई जा चुकी है।',
    'chew_first': 'पहले कड को चबाएँ।',
    'seeds_eaten': 'बीज पहले ही खाए जा चुके हैं।',
    'grit_now': 'कंकड़ अभी डालने का समय है।',
    'drop_on_mouth': 'इसे गाय के मुँह पर छोड़ें!',
    'drop_on_beak': 'इसे पक्षी की चोंच पर छोड़ें!',
    'drop_here': 'यहाँ छोड़ें',
    'sum_head_1': 'जुगाली का लाभ!',
    'sum_body_1':
        'गाय का पेट चार कक्षों वाला होता है, जो कठोर पौधे खाने के लिए अनुकूलित है। भोजन को वापस मुँह में लाकर (जुगाली) और दो बार चबाकर, गाय पौधों के कठोर रेशों को तोड़ देती है, ताकि उसके पेट के सूक्ष्म बैक्टीरिया इसे ठीक से पचा सकें।',
    'sum_head_2': 'प्रकृति के आंतरिक दाँत!',
    'sum_body_2':
        'पक्षी चबा नहीं सकते, इसलिए वे गिज़र्ड नामक पेशीय अंग पर निर्भर रहते हैं। छोटे पत्थर (कंकड़) निगलने से गिज़र्ड चक्की की तरह काम करता है और बीज जैसे कठोर भोजन को यांत्रिक रूप से पीस देता है, ताकि पोषक तत्व अवशोषित हो सकें।',
    'lbl_cow': 'गाय (जुगाली करने वाला पशु)',
    'lbl_hen': 'मुर्गी (पक्षी)',
    'lbl_mouth': 'मुँह',
    'lbl_beak': 'चोंच',
    'lbl_esophagus': 'ग्रासनली',
    'lbl_rumen': 'रूमेन',
    'lbl_reticulum': 'रेटिकुलम',
    'lbl_omasum': 'ओमेसम',
    'lbl_abomasum': 'एबोमेसम',
    'lbl_intestine': 'आंत',
    'lbl_crop': 'क्रॉप (अन्नपुट)',
    'lbl_gizzard': 'गिज़र्ड (पेषणी)',
    'lbl_microbes': 'सूक्ष्मजीव',
    'lbl_cud_raw': 'कड',
    'lbl_nutrients': 'पोषक तत्वों का अवशोषण',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visualize and interact with the process of rumination in a cow to understand how it digests tough, fibrous grass.',
      steps: [
        LabStep(
          concept: 'First Swallow',
          action: "DRAG the clump of grass and DROP it into the cow's mouth.",
          observation: 'The cow swallows the grass without much chewing.',
        ),
        LabStep(
          concept: 'The Rumen',
          action: "CLICK 'Inspect Stomach' button.",
          observation:
              'The grass travels to the Rumen (the first chamber) where it is partially broken down by microbes.',
        ),
        LabStep(
          concept: 'Rumination (Regurgitation)',
          action: "CLICK the 'Rumination' button.",
          observation: "The partially digested food, called 'cud', travels back up the esophagus to the mouth.",
        ),
        LabStep(
          concept: 'Mechanical Breakdown',
          action: "CLICK and HOLD 'Hold to Chew'.",
          observation: 'The cow thoroughly grinds the cud, breaking down the tough plant fibers into tiny pieces.',
        ),
        LabStep(
          concept: 'Final Digestion & Absorption',
          action: 'DRAG the fully chewed cud back down.',
          observation:
              'The fine slurry bypasses the rumen, going to other chambers and intestine where nutrients (yellow) are absorbed.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To understand the function of the gizzard and the role of grit in the mechanical digestion of food in birds.',
      steps: [
        LabStep(
          concept: 'Eating Whole Food',
          action: "DRAG the seeds and DROP them into the bird's beak.",
          observation: 'Because birds lack teeth, the hard seeds are swallowed completely whole.',
        ),
        LabStep(
          concept: 'The Gizzard',
          action: "CLICK 'Inspect Digestive Tract'.",
          observation:
              "The whole seeds collect in a muscular organ called the Gizzard. It tries to contract, but can't break the seeds alone.",
        ),
        LabStep(
          concept: 'Adding Grit',
          action: 'DRAG the pile of grit and DROP it into the beak.',
          observation: 'The small stones travel down and mix with the seeds inside the gizzard.',
        ),
        LabStep(
          concept: 'Mechanical Grinding',
          action: "CLICK 'Grind Food'.",
          observation:
              'The gizzard contracts powerfully, using the hard stones (grit) to crush and grind the seeds into a fine paste.',
        ),
        LabStep(
          concept: 'Absorption',
          action: 'Observe the flow.',
          observation:
              'The ground-up food paste moves to the small intestine where nutrients (yellow) are absorbed into the body.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'गाय में जुगाली की प्रक्रिया को देखना और उससे जुड़ना, ताकि समझ सकें कि वह कठोर, रेशेदार घास को कैसे पचाती है।',
      steps: [
        LabStep(
          concept: 'पहला निगलना',
          action: 'घास के गुच्छे को खींचकर गाय के मुँह में छोड़ें।',
          observation: 'गाय बिना ज़्यादा चबाए घास निगल लेती है।',
        ),
        LabStep(
          concept: 'रूमेन (Rumen)',
          action: "'पेट का निरीक्षण करें' बटन पर क्लिक करें।",
          observation: 'घास रूमेन (पहले कक्ष) में जाती है, जहाँ सूक्ष्मजीव इसे आंशिक रूप से तोड़ते हैं।',
        ),
        LabStep(
          concept: 'जुगाली (Rumination)',
          action: "'जुगाली' बटन पर क्लिक करें।",
          observation: "आंशिक रूप से पचा भोजन, जिसे 'कड' कहते हैं, ग्रासनली से होकर वापस मुँह में आता है।",
        ),
        LabStep(
          concept: 'यांत्रिक विखंडन',
          action: "'चबाने के लिए दबाए रखें' बटन को दबाकर रखें।",
          observation: 'गाय कड को अच्छी तरह पीसती है और पौधों के कठोर रेशों को छोटे टुकड़ों में तोड़ देती है।',
        ),
        LabStep(
          concept: 'अंतिम पाचन और अवशोषण',
          action: 'पूरी तरह चबाए गए कड को वापस नीचे खींचें।',
          observation:
              'बारीक घोल रूमेन को छोड़कर अन्य कक्षों और आंत में जाता है, जहाँ पोषक तत्व (पीले) अवशोषित होते हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'पक्षियों में भोजन के यांत्रिक पाचन में गिज़र्ड और कंकड़ (grit) की भूमिका को समझना।',
      steps: [
        LabStep(
          concept: 'साबुत भोजन खाना',
          action: 'बीजों को खींचकर पक्षी की चोंच में छोड़ें।',
          observation: 'दाँत न होने के कारण पक्षी कठोर बीजों को साबुत ही निगल लेते हैं।',
        ),
        LabStep(
          concept: 'गिज़र्ड (Gizzard)',
          action: "'पाचन तंत्र का निरीक्षण करें' पर क्लिक करें।",
          observation:
              'साबुत बीज गिज़र्ड नामक पेशीय अंग में जमा होते हैं। यह सिकुड़ने की कोशिश करता है, पर अकेले बीजों को नहीं तोड़ पाता।',
        ),
        LabStep(
          concept: 'कंकड़ (Grit) मिलाना',
          action: 'कंकड़ के ढेर को खींचकर चोंच में छोड़ें।',
          observation: 'छोटे पत्थर नीचे जाकर गिज़र्ड के अंदर बीजों के साथ मिल जाते हैं।',
        ),
        LabStep(
          concept: 'यांत्रिक पिसाई',
          action: "'भोजन पीसें' पर क्लिक करें।",
          observation:
              'गिज़र्ड ज़ोर से सिकुड़ता है और कठोर पत्थरों (कंकड़) की मदद से बीजों को कुचलकर बारीक लेप बना देता है।',
        ),
        LabStep(
          concept: 'अवशोषण',
          action: 'प्रवाह का निरीक्षण करें।',
          observation: 'पिसा हुआ भोजन-लेप छोटी आंत में जाता है, जहाँ पोषक तत्व (पीले) शरीर में अवशोषित होते हैं।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 560);

/// Radius (design px) of the dashed drop circle and of an accepted drop.
const double _dropRadius = 80;
const double _dropHit = 100;

/// Food the learner drags from the tray (HTML `.drag-item`s).
enum _Item { grass, cud, seeds, grit }

/// A 2D stand-in for the Three.js camera: the world point shown at the
/// stage centre and the design pixels per world unit.
@immutable
class _Cam {
  const _Cam(this.x, this.y, this.k);
  final double x, y, k;
}

// World units follow the Three.js scene (y points down here). The cow faces
// left, clear of the food tray (top right). The hen is drawn mirrored so it
// faces right: its beak stays clear of the mission card (top left) that
// replaces the sidebar when it is collapsed. Camera x is in drawn (mirrored)
// coordinates.
const _cowBase = _Cam(0.69, 0.19, 47);
const _cowInspect = _Cam(0.9, 0.55, 88); // HTML camera (0, 0, 12)
const _cowRuminate = _Cam(-0.6, 0.6, 65); // HTML camera (-2, 2, 15)
const _birdBase = _Cam(2.1, -0.25, 50);
const _birdInspect = _Cam(2.86, -1.1, 64); // HTML camera (0, 0, 12)

const double _cowGround = 5.3;
const double _birdGround = 4.6;

// ---- Cow digestive tract (HTML s1 meshes).
const Offset _cowMouth = Offset(-6.75, 0.5);
const Offset _cowGrassStart = Offset(-8.45, 0.3);
const Offset _rumenFood = Offset(-0.5, 0.25);
const Offset _rumenC = Offset(-0.2, 0.15);
const Offset _reticC = Offset(-2.6, 1.0);
const Offset _omasumC = Offset(2.55, -0.75);
const List<Offset> _cowEsophagus = [
  Offset(-6.75, 0.5),
  Offset(-6.2, 0.35),
  Offset(-5.4, -0.05),
  Offset(-4.4, -0.55),
  Offset(-3.3, -0.75),
  Offset(-2.3, -0.75),
  Offset(-1.6, -0.45),
];

/// Route of the fine cud past the rumen to the omasum and abomasum.
const List<Offset> _cowGroove = [
  Offset(-1.6, -0.45),
  Offset(-0.2, -1.15),
  Offset(1.4, -1.15),
  Offset(2.55, -0.75),
  Offset(2.85, 0.05),
  Offset(3.1, 0.8),
  Offset(3.65, 1.15),
];
const List<Offset> _cowAbomasum = [Offset(2.7, -0.15), Offset(2.95, 0.6), Offset(3.25, 1.0), Offset(3.7, 1.15)];
const List<Offset> _cowIntestine = [
  Offset(3.65, 1.15),
  Offset(4.1, 0.45),
  Offset(4.6, 0.3),
  Offset(4.8, 0.8),
  Offset(4.4, 1.0),
  Offset(4.05, 1.45),
  Offset(4.45, 1.75),
  Offset(4.75, 1.45),
  Offset(4.65, 2.0),
  Offset(4.25, 2.2),
];

// ---- Bird digestive tract (HTML s2 meshes).
const Offset _birdBeak = Offset(-5.3, -3.35);
const Offset _cropC = Offset(-3.05, -1.0);
const Offset _gizzardC = Offset(0, 0.2);
const List<Offset> _birdEsophagus = [
  Offset(-5.3, -3.35),
  Offset(-4.75, -3.05),
  Offset(-4.3, -2.6),
  Offset(-3.85, -1.95),
  Offset(-3.4, -1.35),
  Offset(-3.05, -1.0),
];
const List<Offset> _birdProvent = [
  Offset(-3.05, -1.0),
  Offset(-2.45, -0.65),
  Offset(-1.8, -0.35),
  Offset(-1.1, -0.05),
  Offset(0, 0.2),
];
const List<Offset> _birdIntestine = [
  Offset(0, 0.2),
  Offset(1.05, 0.75),
  Offset(1.65, 1.4),
  Offset(2.3, 1.1),
  Offset(2.8, 1.3),
  Offset(3.3, 0.75),
  Offset(3.75, 0.2),
];

/// Smooth (Catmull-Rom) open curve through [pts].
Path _smooth(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[math.max(i - 1, 0)];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = pts[math.min(i + 2, pts.length - 1)];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}

/// Smooth closed curve through [pts].
Path _smoothClosed(List<Offset> pts) {
  final n = pts.length;
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < n; i++) {
    final p0 = pts[(i - 1 + n) % n];
    final p1 = pts[i];
    final p2 = pts[(i + 1) % n];
    final p3 = pts[(i + 2) % n];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

/// A point moving along a smooth curve by arc length (the HTML tweens).
class _Route {
  _Route(List<Offset> pts) : _at = _build(pts);

  final Offset Function(double t) _at;

  Offset at(double t) => _at(t);

  static Offset Function(double t) _build(List<Offset> pts) {
    final metrics = _smooth(pts).computeMetrics().toList();
    if (metrics.isEmpty || metrics.first.length <= 0) return (_) => pts.last;
    final m = metrics.first;
    final len = m.length;
    return (t) => m.getTangentForOffset(len * t.clamp(0.0, 1.0))?.position ?? pts.last;
  }
}

/// A TWEEN.js style tween driven by the lab's ticker.
class _Tw {
  _Tw(this.ms, this.update, {this.curve = Curves.linear, this.passes = 1, this.yoyo = false, this.onDone});

  final double ms;
  final void Function(double v) update;
  final Curve curve;

  /// `repeat(n)` in TWEEN.js is `passes = n + 1`.
  final int passes;
  final bool yoyo;
  final VoidCallback? onDone;
  double? _start;
  bool done = false;

  void tick(double now) {
    if (done) return;
    _start ??= now;
    final elapsed = now - _start!;
    if (elapsed >= ms * passes) {
      update(!yoyo || passes.isOdd ? 1 : 0);
      done = true;
      onDone?.call();
      return;
    }
    final pass = (elapsed / ms).floor();
    var t = (elapsed - pass * ms) / ms;
    if (yoyo && pass.isOdd) t = 1 - t;
    update(curve.transform(t.clamp(0.0, 1.0)));
  }
}

/// Mutable scene model read by the painter every frame (the Three.js
/// `s1Refs` / `s2Refs` objects plus the camera).
class _DigestScene {
  int scenario = 0;

  /// 0 = setup board, 1..5 = steps, 6 = scenario complete.
  int step = 0;
  double time = 0;

  double camX = _cowBase.x, camY = _cowBase.y, camK = _cowBase.k;

  /// The camera has zoomed in on the stomach ("Inspect").
  bool inspected = false;

  /// 0..1 fade-in of the cut-away stomach and organ labels.
  double cut = 0;
  _Item? dragging;

  // Cow.
  bool grassVisible = true;
  Offset grassPos = _cowGrassStart;
  double grassScale = 1;
  bool foodVisible = false;
  Offset foodPos = _cowMouth;
  double foodScale = 0;
  double foodRot = 0;
  double chew = 0;
  bool chewing = false;
  bool foodInRumen = false;
  double chompUntil = -1;

  // Bird.
  bool seedsVisible = false;
  Offset seedsPos = _birdBeak;
  double seedsScale = 1;
  double seedsSpread = 0.2;
  double seedsRot = 0;
  bool gritVisible = false;
  Offset gritPos = _birdBeak;
  double gritScale = 1;
  double gritSpread = 0.16;
  double gritRot = 0;
  bool pasteVisible = false;
  Offset pastePos = _gizzardC;
  double pasteScale = 0;
  double gizzardScale = 1;
  bool grinding = false;
  double crush = 0;

  // Effects.
  double particlesStart = -1;
  Offset particlesPos = Offset.zero;
  double confettiStart = -1;

  bool get isCow => scenario == 0;

  /// Food colour: green grass bolus turning yellow-green as it is chewed
  /// (HTML `color.lerp(0x84cc16, 0.08)` every chew tick).
  Color get foodColor => Color.lerp(_Colors.green600, _Colors.lime500, 1 - math.pow(0.92, chew / 2).toDouble())!;

  /// Where food enters: the cow's mouth or the bird's beak.
  Offset get dropPoint => isCow ? _cowMouth : _birdBeak;

  /// 1 for the cow (faces left), -1 for the mirrored hen (faces right).
  double get mirror => isCow ? 1 : -1;

  /// World → design coordinates for the current camera.
  Offset toDesign(Offset w) => Offset(500 + (w.dx * mirror - camX) * camK, 280 + (w.dy - camY) * camK);

  void setCam(_Cam c) {
    camX = c.x;
    camY = c.y;
    camK = c.k;
  }

  /// HTML `initScenario3D()` + `resetS1UI()` / `resetS2UI()`.
  void reset(int index) {
    scenario = index;
    step = 0;
    setCam(index == 0 ? _cowBase : _birdBase);
    inspected = false;
    cut = 0;
    dragging = null;
    grassVisible = true;
    grassPos = _cowGrassStart;
    grassScale = 1;
    foodVisible = false;
    foodPos = _cowMouth;
    foodScale = 0;
    foodRot = 0;
    chew = 0;
    chewing = false;
    foodInRumen = false;
    chompUntil = -1;
    seedsVisible = false;
    seedsPos = _birdBeak;
    seedsScale = 1;
    seedsSpread = 0.2;
    seedsRot = 0;
    gritVisible = false;
    gritPos = _birdBeak;
    gritScale = 1;
    gritSpread = 0.16;
    gritRot = 0;
    pasteVisible = false;
    pastePos = _gizzardC;
    pasteScale = 0;
    gizzardScale = 1;
    grinding = false;
    crush = 0;
    particlesStart = -1;
    confettiStart = -1;
  }
}

class _Ch9A5DiverseDigestiveAdaptationsInAnimalsPageState extends State<Ch9A5DiverseDigestiveAdaptationsInAnimalsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _DigestScene _scene = _DigestScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();
  final List<_Tw> _tweens = [];

  /// Tray items already fed to the animal in this scenario.
  final Set<_Item> _used = {};

  late final Ticker _ticker;
  double _lastMs = 0;

  /// True while the animation started by the current action button runs
  /// (the HTML hides the button as soon as it is clicked).
  bool _busy = false;
  bool _chewPressed = false;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.reset(0);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _tweens.clear();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ frame loop

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1000.0;
    final dt = ((now - _lastMs) / 1000).clamp(0.0, 0.1);
    _lastMs = now;
    final sc = _scene;
    sc.time = now / 1000;
    if (_tweens.isNotEmpty) {
      for (final tw in List.of(_tweens)) {
        if (_tweens.contains(tw)) tw.tick(now);
      }
      _tweens.removeWhere((t) => t.done);
    }
    if (sc.chewing) _chewTick(dt);
    if (sc.grinding) {
      sc.seedsRot += dt * 9;
      sc.gritRot -= dt * 9;
    }
    _frame.value = sc.time;
  }

  void _tween(
    double ms,
    void Function(double v) update, {
    Curve curve = Curves.linear,
    int passes = 1,
    bool yoyo = false,
    VoidCallback? onDone,
  }) {
    _tweens.add(_Tw(ms, update, curve: curve, passes: passes, yoyo: yoyo, onDone: onDone));
  }

  /// Moves a point along a smooth path through [pts] (start = pts.first).
  void _moveAlong(
    List<Offset> pts,
    double ms,
    void Function(Offset p) set, {
    Curve curve = Curves.easeInOutQuad,
    VoidCallback? onDone,
  }) {
    final route = _Route(pts);
    _tween(ms, (v) => set(route.at(v)), curve: curve, onDone: onDone);
  }

  /// HTML camera tweens (`camera.position` + `controls.target`).
  void _camTo(_Cam c, {double ms = 1500}) {
    final sc = _scene;
    final fx = sc.camX, fy = sc.camY, fk = sc.camK;
    _tween(ms, (v) {
      sc.camX = fx + (c.x - fx) * v;
      sc.camY = fy + (c.y - fy) * v;
      sc.camK = fk + (c.k - fk) * v;
    }, curve: Curves.easeInOutCubic);
  }

  // ------------------------------------------------------------ logic

  /// HTML `changeScenario()` / `resetScenarioState`: back to the setup board.
  void _rebuildScene() {
    _lab.cancelPending();
    _tweens.clear();
    _busy = false;
    _chewPressed = false;
    _used.clear();
    _scene.reset(_scene.scenario);
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _rebuildScene();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _rebuildScene();
    });
  }

  void _setStep(int step) {
    if (!mounted) return;
    setState(() {
      _scene.step = step;
      _busy = false;
    });
  }

  /// HTML board button "Setup Activity": shows the scenario's tools.
  void _setupActivity() {
    if (_step != 0) return;
    _setStep(1);
  }

  List<_Item> get _trayItems {
    if (_scenario == 0) {
      if (_step == 1 && !_used.contains(_Item.grass)) return const [_Item.grass];
      if (_step == 5 && !_used.contains(_Item.cud)) return const [_Item.cud];
    } else {
      if (_step == 1 && !_used.contains(_Item.seeds)) return const [_Item.seeds];
      if (_step == 3 && !_used.contains(_Item.grit)) return const [_Item.grit];
    }
    return const [];
  }

  /// HTML `startUiDrag()` pointer-up: a drop inside the mouth / beak zone
  /// feeds the item; anywhere else shows a hint.
  void _onDragEnd(_Item item, DraggableDetails d) {
    if (!mounted) return;
    setState(() => _scene.dragging = null);
    final local = labGlobalToLocal(_stageKey, d.offset);
    if (local == null) return;
    if ((local - _scene.toDesign(_scene.dropPoint)).distance <= _dropHit) {
      _feed(item);
    } else {
      _lab.showToast(_t(_scene.isCow ? 'drop_on_mouth' : 'drop_on_beak'), isError: true);
    }
  }

  void _hintDrag() {
    _Audio.play(_Sound.click);
    _lab.showToast(_t(_scene.isCow ? 'drop_on_mouth' : 'drop_on_beak'), sound: false);
  }

  void _feed(_Item item) {
    switch (item) {
      case _Item.grass:
        if (_scenario != 0 || _step != 1 || _used.contains(item)) {
          _lab.showToast(_t('grass_eaten'), isError: true);
        } else {
          _s1SwallowGrass();
        }
      case _Item.cud:
        if (_scenario != 0 || _step != 5 || _used.contains(item)) {
          _lab.showToast(_t('chew_first'), isError: true);
        } else {
          _s1SwallowCud();
        }
      case _Item.seeds:
        if (_scenario != 1 || _step != 1 || _used.contains(item)) {
          _lab.showToast(_t('seeds_eaten'), isError: true);
        } else {
          _s2SwallowSeeds();
        }
      case _Item.grit:
        if (_scenario != 1 || _step != 3 || _used.contains(item)) {
          _lab.showToast(_t('grit_now'), isError: true);
        } else {
          _s2SwallowGrit();
        }
    }
  }

  // ---- Scenario 1: the cow.

  /// HTML `s1ActionSwallowGrass()`.
  void _s1SwallowGrass() {
    _Audio.play(_Sound.pop);
    setState(() => _used.add(_Item.grass));
    final sc = _scene;
    final from = sc.grassPos;
    sc.chompUntil = sc.time + 0.7;
    _tween(
      500,
      (v) {
        sc.grassPos = Offset.lerp(from, _cowMouth, v)!;
        sc.grassScale = 1 - v;
      },
      curve: Curves.easeIn,
      onDone: () => sc.grassVisible = false,
    );
    _lab.after(const Duration(milliseconds: 600), () {
      sc
        ..foodVisible = true
        ..foodPos = _cowMouth
        ..foodScale = 1;
      // Down the esophagus into the rumen.
      _moveAlong([..._cowEsophagus, _rumenFood], 1200, (p) => sc.foodPos = p, onDone: () => sc.foodInRumen = true);
      _lab.after(const Duration(milliseconds: 1400), () => _setStep(2));
    });
  }

  /// HTML `s1ActionInspect()`: zoom into the stomach, food churns.
  void _s1Inspect() {
    if (_busy || _scenario != 0 || _step != 2) return;
    _Audio.play(_Sound.pop);
    setState(() => _busy = true);
    final sc = _scene;
    sc.inspected = true;
    _camTo(_cowInspect);
    _tween(1500, (v) => sc.cut = v, curve: Curves.easeInOut);
    final base = sc.foodPos;
    _tween(400, (v) => sc.foodPos = Offset(base.dx, base.dy - 0.3 * v), passes: 5, yoyo: true);
    _lab.after(const Duration(milliseconds: 2000), () => _setStep(3));
  }

  /// HTML `s1ActionRuminate()`: the cud travels back up to the mouth.
  void _s1Ruminate() {
    if (_busy || _scenario != 0 || _step != 3) return;
    _Audio.play(_Sound.pop);
    setState(() => _busy = true);
    final sc = _scene;
    _camTo(_cowRuminate);
    sc.foodInRumen = false;
    _moveAlong([sc.foodPos, ..._cowEsophagus.reversed], 1500, (p) => sc.foodPos = p);
    _lab.after(const Duration(milliseconds: 1800), () => _setStep(4));
  }

  /// HTML `s1StartChew()` (pointer down on "Hold to Chew").
  void _startChew() {
    if (_scenario != 0 || _step != 4 || _scene.chew >= 100) return;
    if (!_scene.chewing) _Audio.play(_Sound.pop);
    _scene.chewing = true;
    setState(() => _chewPressed = true);
  }

  /// HTML `s1StopChew()` (pointer up / leave).
  void _stopChew() {
    if (!_scene.chewing && !_chewPressed) return;
    _scene.chewing = false;
    if (mounted) setState(() => _chewPressed = false);
  }

  /// HTML chew interval: +2 % every 50 ms while held.
  void _chewTick(double dt) {
    final sc = _scene;
    sc.chew = math.min(100, sc.chew + dt * 40);
    sc.foodRot += dt * 4;
    sc.foodScale = 1 - sc.chew * 0.004;
    if (sc.chew >= 100) {
      sc.chewing = false;
      _chewPressed = false;
      _setStep(5);
    }
  }

  /// HTML `s1ActionSwallowCud()`: past the rumen to the abomasum and on to
  /// the intestine, where the nutrients are absorbed.
  void _s1SwallowCud() {
    _Audio.play(_Sound.pop);
    setState(() => _used.add(_Item.cud));
    final sc = _scene;
    sc.chompUntil = sc.time + 0.4;
    _moveAlong(
      _cowEsophagus,
      600,
      (p) => sc.foodPos = p,
      curve: Curves.easeInQuad,
      onDone: () {
        _moveAlong(
          _cowGroove,
          800,
          (p) => sc.foodPos = p,
          curve: Curves.easeOutQuad,
          onDone: () {
            final s0 = sc.foodScale;
            _moveAlong(_cowIntestine, 1500, (p) => sc.foodPos = p);
            _tween(1500, (v) => sc.foodScale = s0 * (1 - v), onDone: () => sc.foodVisible = false);
            _lab.after(const Duration(milliseconds: 500), () {
              sc
                ..particlesStart = sc.time
                ..particlesPos = sc.foodPos;
            });
          },
        );
      },
    );
    _lab.after(const Duration(milliseconds: 3500), _conclude);
  }

  // ---- Scenario 2: the bird.

  /// HTML `s2ActionSwallowSeeds()`: whole seeds via the crop to the gizzard.
  void _s2SwallowSeeds() {
    _Audio.play(_Sound.pop);
    setState(() => _used.add(_Item.seeds));
    final sc = _scene;
    sc
      ..seedsVisible = true
      ..seedsPos = _birdBeak
      ..seedsSpread = 0.2;
    _moveAlong(
      _birdEsophagus,
      800,
      (p) => sc.seedsPos = p,
      onDone: () {
        _moveAlong(
          _birdProvent,
          800,
          (p) => sc.seedsPos = p,
          onDone: () {
            _tween(300, (v) => sc.seedsSpread = 0.2 + 0.2 * v, curve: Curves.easeOut);
          },
        );
      },
    );
    _lab.after(const Duration(milliseconds: 1800), () => _setStep(2));
  }

  /// HTML `s2ActionInspect()`: zoom in; the gizzard squeezes but fails.
  void _s2Inspect() {
    if (_busy || _scenario != 1 || _step != 2) return;
    _Audio.play(_Sound.pop);
    setState(() => _busy = true);
    final sc = _scene;
    sc.inspected = true;
    _camTo(_birdInspect);
    _tween(1500, (v) => sc.cut = v, curve: Curves.easeInOut);
    _tween(300, (v) => sc.gizzardScale = 1 - 0.1 * v, passes: 4, yoyo: true);
    _lab.after(const Duration(milliseconds: 2000), () => _setStep(3));
  }

  /// HTML `s2ActionSwallowGrit()`.
  void _s2SwallowGrit() {
    _Audio.play(_Sound.pop);
    setState(() => _used.add(_Item.grit));
    final sc = _scene;
    sc
      ..gritVisible = true
      ..gritPos = _birdBeak
      ..gritSpread = 0.16;
    _moveAlong(
      [..._birdEsophagus, ..._birdProvent.skip(1)],
      1200,
      (p) => sc.gritPos = p,
      onDone: () {
        _tween(300, (v) => sc.gritSpread = 0.16 + 0.24 * v, curve: Curves.easeOut);
      },
    );
    _lab.after(const Duration(milliseconds: 1500), () => _setStep(4));
  }

  /// HTML `s2ActionGrind()`: 16 strong contractions crush the seeds.
  void _s2Grind() {
    if (_busy || _scenario != 1 || _step != 4) return;
    _Audio.play(_Sound.pop);
    setState(() => _busy = true);
    final sc = _scene;
    sc.grinding = true;
    _tween(3200, (v) => sc.crush = v);
    _tween(
      200,
      (v) => sc.gizzardScale = 1 - 0.2 * v,
      passes: 16,
      yoyo: true,
      onDone: () {
        sc.grinding = false;
        final s0 = sc.seedsScale, g0 = sc.gritScale;
        _tween(
          500,
          (v) {
            sc.seedsScale = s0 * (1 - v);
            sc.gritScale = g0 * (1 - v);
          },
          onDone: () {
            sc
              ..seedsVisible = false
              ..gritVisible = false;
          },
        );
        sc
          ..pasteVisible = true
          ..pastePos = _gizzardC
          ..pasteScale = 0;
        _tween(500, (v) => sc.pasteScale = v, curve: Curves.easeOut);
        _lab.after(const Duration(milliseconds: 1000), _s2Absorb);
      },
    );
  }

  /// HTML `s2ActionAbsorption()`.
  void _s2Absorb() {
    _setStep(5);
    final sc = _scene;
    _moveAlong(_birdIntestine, 2000, (p) => sc.pastePos = p);
    _tween(2000, (v) => sc.pasteScale = 1 - v, onDone: () => sc.pasteVisible = false);
    _lab.after(const Duration(milliseconds: 1000), () {
      sc
        ..particlesStart = sc.time
        ..particlesPos = sc.pastePos;
    });
    _lab.after(const Duration(milliseconds: 3500), _conclude);
  }

  /// HTML `triggerConclusionState()`: confetti, then the summary popup.
  void _conclude() {
    if (!mounted) return;
    final sc = _scene;
    final idx = _scenario;
    setState(() => sc.step = 6);
    _Audio.play(_Sound.magic);
    sc.confettiStart = sc.time;
    _lab.showScenarioConclusion(
      scenarioIndex: idx,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 2500),
      title: () => _lab.t('success'),
      heading: () => _t('observation_title'),
      body: () => '${_t('sum_head_${idx + 1}')}\n${_t('sum_body_${idx + 1}')}',
      extra: () => Text(
        labFormat(_t('sc_complete'), {'n': idx + 1}),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _Theme.of(_lab.isDark).accent,
          fontSize: 17 * context.labScale,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _instruction() {
    if (_step == 0) return '';
    if (_step > 5) return labFormat(_t('sc_complete'), {'n': _scenario + 1});
    return _t('hud_${_scenario + 1}_$_step');
  }

  List<LabAction> _actions() {
    if (_step == 0) {
      return [
        LabAction(
          label: _t('board_btn'),
          icon: Icons.play_arrow_rounded,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _setupActivity,
        ),
      ];
    }
    if (_busy) return const [];
    if (_scenario == 0) {
      if (_step == 2) {
        return [
          LabAction(
            label: _t('btn_inspect'),
            icon: Icons.zoom_in,
            color: _Colors.indigo600,
            foreground: Colors.white,
            highlight: true,
            silent: true, // plays the HTML pop itself
            onTap: _s1Inspect,
          ),
        ];
      }
      if (_step == 3) {
        return [
          LabAction(
            label: _t('btn_ruminate'),
            icon: Icons.undo_rounded,
            color: _Colors.amber600,
            foreground: Colors.white,
            highlight: true,
            silent: true,
            onTap: _s1Ruminate,
          ),
        ];
      }
    } else {
      if (_step == 2) {
        return [
          LabAction(
            label: _t('btn_inspect_tract'),
            icon: Icons.zoom_in,
            color: _Colors.indigo600,
            foreground: Colors.white,
            highlight: true,
            silent: true,
            onTap: _s2Inspect,
          ),
        ];
      }
      if (_step == 4) {
        return [
          LabAction(
            label: _t('btn_grind'),
            icon: Icons.compress_rounded,
            color: _Colors.orange600,
            foreground: Colors.white,
            highlight: true,
            silent: true,
            onTap: _s2Grind,
          ),
        ];
      }
    }
    return const [];
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final items = _trayItems;
        final actions = _actions();
        return LabShell(
          controller: _lab,
          icon: Icons.pets,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: math.max(_step, 1),
          instruction: _instruction(),
          actions: actions,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _stepsLog(p, s),
          onEnterLab: () => _lab.showToast(_t('welcome_lab'), sound: false),
          onReset: _fullReset,
          overlays: [
            if (_step == 0) Positioned.fill(child: _boardBackdrop()),
            if (_step == 0) _boardCard(s, inset),
            if (items.isNotEmpty) _tray(s, inset, items),
            if (_scenario == 0 && _step == 4) _chewPanel(s, inset),
            // The HTML floats Inspect / Rumination / Grind over the scene;
            // while the sidebar is collapsed the mission card shows them.
            if (_step > 0 && actions.isNotEmpty && _lab.isSidebarOpen) _floatingAction(actions.first, s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: CustomPaint(
              key: _stageKey,
              size: _design,
              painter: _DigestPainter(
                scene: _scene,
                repaint: _frame,
                isDark: _lab.isDark,
                showLabels: _lab.showLabels,
                tr: _t,
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML sidebar "Exploration Steps": each step's concept, with the
  /// observation once the step is done.
  Widget _stepsLog(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final steps = _data.steps;
    final cur = math.max(_step, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          _stepTile(p, s, f, i + 1, steps[i], isCurrent: i + 1 == cur && _step <= steps.length, isPast: _step > i + 1),
      ],
    );
  }

  Widget _stepTile(
    LabPalette p,
    double s,
    double f,
    int id,
    LabStep step, {
    required bool isCurrent,
    required bool isPast,
  }) {
    final border = isCurrent ? p.accent : (isPast ? p.accent.withValues(alpha: 0.45) : p.cardBorder);
    final titleColor = isCurrent ? p.accent : (isPast ? p.textStrong : p.textMuted);
    return Container(
      margin: EdgeInsets.only(bottom: 6 * s),
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: isCurrent ? p.accent.withValues(alpha: 0.1) : p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: isCurrent ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 18 * s,
                height: 18 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast
                      ? p.accent.withValues(alpha: 0.2)
                      : (isCurrent ? p.accent : p.cardBorder.withValues(alpha: 0.4)),
                  border: Border.all(color: isPast || isCurrent ? p.accent : p.cardBorder),
                ),
                child: isPast
                    ? Icon(Icons.check, size: 11 * s, color: p.accent)
                    : Text(
                        '$id',
                        style: TextStyle(
                          fontSize: 9.5 * s,
                          fontWeight: FontWeight.w900,
                          color: isCurrent ? p.onAccent : p.textMuted,
                        ),
                      ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  '${_t('exploration')} $id • ${step.concept}',
                  style: TextStyle(color: titleColor, fontSize: 11.5 * f, fontWeight: FontWeight.w800, height: 1.25),
                ),
              ),
            ],
          ),
          if (isPast) ...[
            SizedBox(height: 5 * s),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${_t('observation')}: ',
                    style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: step.observation),
                ],
              ),
              style: TextStyle(color: p.textMuted, fontSize: 11 * f, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  /// HTML `#ui-setup-board` backdrop (dims the scene, blocks the canvas).
  Widget _boardBackdrop() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(color: _lab.isDark ? const Color(0xB3000000) : const Color(0x990F172A)),
    );
  }

  /// HTML setup board: animal, mission objective, description, button.
  Widget _boardCard(double s, EdgeInsets inset) {
    return Positioned(
      left: inset.left,
      top: inset.top,
      right: inset.right,
      bottom: inset.bottom,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 430 * s),
          margin: EdgeInsets.symmetric(horizontal: 10 * s),
          decoration: BoxDecoration(
            color: _Colors.slate800,
            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(color: _Colors.indigo500.withValues(alpha: 0.5), width: 3 * s),
            boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 30, offset: Offset(0, 12))],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18 * s, 12 * s, 18 * s, 16 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150 * s,
                  height: 74 * s,
                  child: CustomPaint(painter: _BadgePainter(_scenario)),
                ),
                SizedBox(height: 8 * s),
                Text(
                  _data.objective,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14.5 * s, fontWeight: FontWeight.w800, height: 1.35),
                ),
                SizedBox(height: 8 * s),
                Text(
                  _t('board_desc_${_scenario + 1}'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _Colors.indigo200, fontSize: 12.5 * s, height: 1.4),
                ),
                SizedBox(height: 14 * s),
                LabActionButton(
                  action: LabAction(
                    label: _t('board_btn'),
                    icon: Icons.play_arrow_rounded,
                    color: _Colors.indigo600,
                    foreground: Colors.white,
                    onTap: _setupActivity,
                  ),
                  scale: s,
                  expand: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#s1-tools` / `#s2-tools`: draggable food in the top-right dock.
  Widget _tray(double s, EdgeInsets inset, List<_Item> items) {
    return Positioned(
      top: inset.top + 46 * s,
      right: inset.right + 8 * s,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [for (final item in items) _trayItem(item, s)]),
      ),
    );
  }

  static Color _itemColor(_Item item) => switch (item) {
    _Item.grass => _Colors.green500,
    _Item.cud => _Colors.emerald500,
    _Item.seeds => _Colors.amber500,
    _Item.grit => _Colors.slate400,
  };

  static String _itemLabel(_Item item) => switch (item) {
    _Item.grass => 'lbl_grass',
    _Item.cud => 'lbl_cud',
    _Item.seeds => 'lbl_seeds',
    _Item.grit => 'lbl_grit',
  };

  Widget _trayItem(_Item item, double s) {
    final isDark = _lab.isDark;
    final color = _itemColor(item);
    Widget tile({double k = 1, bool lifted = false}) => Container(
      width: 64 * s * k,
      height: 64 * s * k,
      padding: EdgeInsets.all(9 * s * k),
      decoration: BoxDecoration(
        color: isDark ? _Colors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16 * s * k),
        border: Border.all(color: color.withValues(alpha: lifted ? 1 : 0.65), width: 2),
        boxShadow: [
          BoxShadow(
            color: lifted ? color.withValues(alpha: 0.45) : const Color(0x33000000),
            blurRadius: lifted ? 22 : 8,
            offset: Offset(0, lifted ? 10 : 4),
          ),
        ],
      ),
      child: CustomPaint(painter: _ItemIconPainter(item)),
    );
    final label = Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xD91E293B) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4)],
      ),
      child: Text(
        _t(_itemLabel(item)).toUpperCase(),
        style: TextStyle(
          color: isDark ? _Colors.slate300 : _Colors.slate600,
          fontSize: 9.5 * s,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
    final body = ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, time, child) =>
          Transform.translate(offset: Offset(0, math.sin(time * 2.4) * 3 * s), child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile(),
          SizedBox(height: 5 * s),
          label,
        ],
      ),
    );
    return TweenAnimationBuilder<double>(
      key: ValueKey(item),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(40 * s * (1 - v), 0), child: child),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10 * s),
        child: Draggable<_Item>(
          data: item,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Transform.translate(
            offset: Offset(-35 * s, -35 * s),
            child: Material(color: Colors.transparent, child: tile(k: 1.1, lifted: true)),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: body),
          onDragStarted: () {
            _Audio.play(_Sound.pickup);
            setState(() => _scene.dragging = item);
          },
          onDragEnd: (d) => _onDragEnd(item, d),
          child: GestureDetector(onTap: _hintDrag, child: body),
        ),
      ),
    );
  }

  /// HTML `#s1-actions` / `#s2-actions` (`.floating-action-ui`): the step's
  /// button bobbing above the HUD, clear of the organs.
  Widget _floatingAction(LabAction action, double s, EdgeInsets inset) {
    return Positioned(
      left: 12,
      right: inset.right,
      bottom: inset.bottom + 66 * s,
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: _frame,
          builder: (context, time, child) =>
              Transform.translate(offset: Offset(0, -5 * s * (1 - math.cos(time * 2 * math.pi / 3))), child: child),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * s),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: LabActionButton(action: action, scale: s * 1.08, expand: false),
          ),
        ),
      ),
    );
  }

  /// HTML `#s1-btn-chew` (press and hold) + `#s1-chew-progress`.
  Widget _chewPanel(double s, EdgeInsets inset) {
    final pressed = _chewPressed;
    // Anchored to the canvas edge (not the mission card) so the sidebar
    // animation never squeezes it.
    return Positioned(
      left: 12,
      right: inset.right,
      bottom: inset.bottom + 64 * s,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MouseRegion(
                onExit: (_) => _stopChew(),
                child: Listener(
                  onPointerDown: (_) => _startChew(),
                  onPointerUp: (_) => _stopChew(),
                  onPointerCancel: (_) => _stopChew(),
                  child: AnimatedScale(
                    scale: pressed ? 0.94 : 1,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 11 * s),
                      decoration: BoxDecoration(
                        color: pressed ? _Colors.emerald500 : _Colors.emerald600,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _Colors.emerald400, width: 3 * s),
                        boxShadow: [
                          BoxShadow(
                            color: _Colors.emerald500.withValues(alpha: pressed ? 0.75 : 0.4),
                            blurRadius: pressed ? 26 : 14,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, color: Colors.white, size: 20 * s),
                          SizedBox(width: 8 * s),
                          Text(
                            _t('btn_chew_hold'),
                            style: TextStyle(color: Colors.white, fontSize: 15 * s, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8 * s),
              ValueListenableBuilder<double>(valueListenable: _frame, builder: (context, time, child) => _chewBar(s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chewBar(double s) {
    final v = (_scene.chew / 100).clamp(0.0, 1.0);
    return Container(
      width: 230 * s,
      height: 22 * s,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xCC1E293B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _Colors.slate600, width: 2),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            alignment: Alignment.centerLeft,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [_Colors.emerald400, _Colors.green500])),
            ),
          ),
          Center(
            child: Text(
              '${_t('lbl_chewing')} ${(v * 100).round()}%',
              style: TextStyle(color: Colors.white, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================ PAINTING

/// Shared artwork (world units, y down): the glass cow and hen, food,
/// seeds, grit and paste. Used by the scene, the tray icons and the board.
abstract final class _Art {
  // ------------------------------------------------------------ glass skin

  /// Holographic glass fill (HTML `MeshPhysicalMaterial` with transmission).
  static void glassFill(Canvas canvas, Path path, bool isDark, {double alpha = 1, double rim = 0.3}) {
    final b = path.getBounds();
    final top = isDark ? const Color(0x3DF1F5F9) : const Color(0xC7FFFFFF);
    final bottom = isDark ? const Color(0x26818CF8) : const Color(0x99C7D2FE);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            top.withValues(alpha: top.a * alpha),
            bottom.withValues(alpha: bottom.a * alpha),
          ],
        ).createShader(b),
    );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rim
        ..color = (isDark ? _Colors.indigo300 : Colors.white).withValues(alpha: (isDark ? 0.32 : 0.9) * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rim * 0.45),
    );
    canvas.restore();
  }

  static void outline(Canvas canvas, Path path, bool isDark, {double alpha = 1, double width = 0.055}) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..color = (isDark ? _Colors.slate200 : _Colors.slate500).withValues(alpha: (isDark ? 0.8 : 0.95) * alpha),
    );
  }

  static Path _blob(Offset c, double rx, double ry, int seed) {
    const n = 12;
    return _smoothClosed([
      for (var i = 0; i < n; i++)
        c +
            Offset(math.cos(i * 2 * math.pi / n), math.sin(i * 2 * math.pi / n)).scale(
              rx * (1 + 0.16 * math.sin(i * 2.3 + seed) + 0.08 * math.sin(i * 4.1 + seed * 1.7)),
              ry * (1 + 0.16 * math.sin(i * 2.3 + seed) + 0.08 * math.sin(i * 4.1 + seed * 1.7)),
            ),
    ]);
  }

  static Path _feather(Offset base, Offset tip, double w, {double bend = 0.18}) {
    final d = tip - base;
    final u = d / d.distance;
    final n = Offset(-u.dy, u.dx);
    final mid = base + d * 0.55 + n * bend;
    final a = mid + n * w;
    final b = mid - n * w;
    return Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(a.dx, a.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(b.dx, b.dy, base.dx, base.dy)
      ..close();
  }

  // ------------------------------------------------------------------ cow

  /// Side view of the cow (faces left). [jaw] 0..1 opens the lower jaw.
  static Path cowBody(double jaw) {
    final j = jaw * 0.2;
    return Path()
      ..moveTo(-5.45, -1.75)
      ..quadraticBezierTo(-4.4, -2.5, -3.2, -2.55)
      ..cubicTo(-1.2, -2.6, 2.4, -2.85, 4.75, -2.5)
      ..cubicTo(5.4, -2.3, 5.55, -1.0, 5.3, 0.2)
      ..cubicTo(5.1, 1.2, 4.8, 2.0, 4.8, 2.9)
      ..lineTo(4.58, 4.72)
      ..lineTo(4.66, 5.3)
      ..lineTo(4.0, 5.3)
      ..lineTo(4.04, 4.72)
      ..lineTo(4.08, 3.3)
      ..cubicTo(4.05, 2.6, 3.75, 2.15, 3.3, 2.0)
      ..cubicTo(2.0, 2.35, -1.2, 2.45, -2.4, 2.1)
      ..cubicTo(-2.62, 2.45, -2.68, 3.2, -2.72, 4.72)
      ..lineTo(-2.68, 5.3)
      ..lineTo(-3.42, 5.3)
      ..lineTo(-3.38, 4.72)
      ..lineTo(-3.42, 2.7)
      ..cubicTo(-3.5, 2.0, -3.9, 1.5, -4.3, 1.05)
      ..cubicTo(-4.8, 0.95, -5.25, 0.6, -5.55, 0.25)
      ..cubicTo(-5.9, 0.75 + j, -6.5, 0.92 + j, -6.9, 0.82 + j)
      ..cubicTo(-7.05, 0.78 + j, -7.18, 0.68 + j, -7.16, 0.56)
      ..cubicTo(-7.36, 0.36, -7.32, -0.05, -7.1, -0.22)
      ..cubicTo(-6.8, -0.65, -6.3, -1.4, -5.95, -1.75)
      ..quadraticBezierTo(-5.72, -1.98, -5.45, -1.75)
      ..close();
  }

  static final Path _cowFarFore = Path()
    ..moveTo(-2.35, 1.85)
    ..lineTo(-1.72, 1.85)
    ..lineTo(-1.7, 4.68)
    ..lineTo(-1.66, 5.22)
    ..lineTo(-2.34, 5.22)
    ..lineTo(-2.32, 4.68)
    ..close();

  static final Path _cowFarHind = Path()
    ..moveTo(3.2, 1.6)
    ..lineTo(4.05, 1.6)
    ..cubicTo(4.1, 2.3, 3.95, 2.7, 3.92, 3.1)
    ..lineTo(3.9, 4.68)
    ..lineTo(3.94, 5.22)
    ..lineTo(3.3, 5.22)
    ..lineTo(3.34, 4.68)
    ..lineTo(3.36, 3.0)
    ..close();

  static final List<Path> _cowPatches = [
    _blob(const Offset(-1.5, -1.75), 1.45, 0.95, 1),
    _blob(const Offset(2.85, -1.55), 1.25, 1.05, 2),
    _blob(const Offset(0.9, 1.45), 1.0, 0.62, 3),
    _blob(const Offset(-4.3, -1.25), 0.62, 0.48, 4),
    _blob(const Offset(4.95, 0.35), 0.5, 0.85, 5),
    _blob(const Offset(-5.75, -1.25), 0.42, 0.38, 6),
  ];

  static void _hoof(Canvas canvas, List<Offset> quad, bool isDark, {double alpha = 1}) {
    final path = Path()..addPolygon(quad, true);
    canvas.drawPath(
      path,
      Paint()..color = (isDark ? _Colors.slate600 : _Colors.slate700).withValues(alpha: 0.9 * alpha),
    );
  }

  static void cow(Canvas canvas, {required bool isDark, double jaw = 0, double tailSwing = 0}) {
    // Far legs (behind the body).
    for (final leg in [_cowFarFore, _cowFarHind]) {
      glassFill(canvas, leg, isDark, alpha: 0.6, rim: 0.2);
      outline(canvas, leg, isDark, alpha: 0.5);
    }
    _hoof(
      canvas,
      const [Offset(-2.32, 4.75), Offset(-1.69, 4.75), Offset(-1.66, 5.22), Offset(-2.34, 5.22)],
      isDark,
      alpha: 0.6,
    );
    _hoof(
      canvas,
      const [Offset(3.33, 4.75), Offset(3.9, 4.75), Offset(3.94, 5.22), Offset(3.3, 5.22)],
      isDark,
      alpha: 0.6,
    );

    // Tail (swishes slowly).
    canvas.save();
    canvas.translate(4.85, -2.45);
    canvas.rotate(tailSwing);
    final tail = Path()
      ..moveTo(0, 0)
      ..cubicTo(0.75, 0.2, 0.92, 1.5, 0.84, 4.0);
    canvas.drawPath(
      tail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.13
        ..strokeCap = StrokeCap.round
        ..color = (isDark ? _Colors.slate300 : _Colors.slate500).withValues(alpha: 0.8),
    );
    final tuft = _blob(const Offset(0.84, 4.35), 0.2, 0.45, 9);
    canvas.drawPath(tuft, Paint()..color = (isDark ? _Colors.slate400 : _Colors.slate700).withValues(alpha: 0.8));
    canvas.restore();

    // Body, neck and head.
    final body = cowBody(jaw);
    glassFill(canvas, body, isDark, rim: 0.45);
    canvas.save();
    canvas.clipPath(body);
    final patch = Paint()
      ..color = isDark ? _Colors.slate950.withValues(alpha: 0.45) : _Colors.slate800.withValues(alpha: 0.28);
    for (final b in _cowPatches) {
      canvas.drawPath(b, patch);
    }
    // Cheek / jaw muscle.
    canvas.drawPath(
      Path()
        ..moveTo(-5.65, -0.75)
        ..quadraticBezierTo(-5.7, 0.2, -6.35, 0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05
        ..color = (isDark ? _Colors.slate300 : _Colors.slate500).withValues(alpha: 0.45),
    );
    canvas.restore();
    outline(canvas, body, isDark);

    // Hooves of the near legs.
    _hoof(canvas, const [Offset(-3.38, 4.75), Offset(-2.71, 4.75), Offset(-2.68, 5.3), Offset(-3.42, 5.3)], isDark);
    _hoof(canvas, const [Offset(4.04, 4.75), Offset(4.58, 4.75), Offset(4.66, 5.3), Offset(4.0, 5.3)], isDark);

    // Udder.
    final udder = Path()..addOval(Rect.fromCenter(center: const Offset(3.0, 2.25), width: 1.2, height: 0.72));
    canvas.drawPath(udder, Paint()..color = _Colors.pink300.withValues(alpha: isDark ? 0.55 : 0.75));
    for (final x in [2.68, 3.0, 3.32]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 0.07, 2.45, 0.14, 0.32), const Radius.circular(0.07)),
        Paint()..color = _Colors.pink300.withValues(alpha: isDark ? 0.7 : 0.9),
      );
    }
    outline(canvas, udder, isDark, alpha: 0.5, width: 0.04);

    // Ear.
    canvas.save();
    canvas.translate(-4.85, -1.85);
    canvas.rotate(-0.35);
    final ear = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: 1.15, height: 0.46));
    glassFill(canvas, ear, isDark, rim: 0.12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0.08, 0.02), width: 0.75, height: 0.22),
      Paint()..color = _Colors.pink300.withValues(alpha: isDark ? 0.45 : 0.7),
    );
    outline(canvas, ear, isDark, width: 0.045);
    canvas.restore();

    // Horn.
    final horn = Path()
      ..moveTo(-5.66, -1.8)
      ..quadraticBezierTo(-5.78, -2.35, -6.08, -2.62)
      ..quadraticBezierTo(-5.6, -2.48, -5.3, -1.9)
      ..close();
    canvas.drawPath(
      horn,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [_Colors.amber100, Color(0xFFD6B98C)],
        ).createShader(horn.getBounds()),
    );
    outline(canvas, horn, isDark, alpha: 0.7, width: 0.04);

    // Muzzle, nostril, mouth and eye.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-6.98, 0.2), width: 0.66, height: 0.92),
      Paint()..color = _Colors.pink300.withValues(alpha: isDark ? 0.55 : 0.75),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-7.1, 0.02), width: 0.13, height: 0.2),
      Paint()..color = isDark ? _Colors.slate900 : _Colors.slate700,
    );
    canvas.drawLine(
      const Offset(-7.18, 0.56),
      Offset(-6.75, 0.6 + jaw * 0.1),
      Paint()
        ..strokeWidth = 0.04
        ..strokeCap = StrokeCap.round
        ..color = isDark ? _Colors.slate300 : _Colors.slate700,
    );
    canvas.drawCircle(const Offset(-6.12, -0.95), 0.16, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(-6.15, -0.95), 0.11, Paint()..color = _Colors.slate900);
    canvas.drawCircle(const Offset(-6.19, -0.99), 0.035, Paint()..color = Colors.white);
  }

  // ------------------------------------------------------------------ hen

  static final Path henBody = Path()
    ..moveTo(-3.7, -3.55)
    ..cubicTo(-3.1, -2.6, -2.6, -2.0, -1.4, -2.0)
    ..cubicTo(0.6, -2.0, 2.4, -2.2, 3.6, -2.9)
    ..cubicTo(4.3, -2.6, 4.7, -1.4, 4.4, -0.4)
    ..cubicTo(4.1, 0.6, 3.2, 1.4, 2.2, 1.9)
    ..cubicTo(1.2, 2.5, -1.0, 2.6, -2.2, 1.9)
    ..cubicTo(-3.4, 1.2, -4.0, 0.0, -3.9, -0.9)
    ..cubicTo(-3.9, -1.6, -4.4, -2.1, -4.6, -2.5)
    ..cubicTo(-4.9, -2.75, -5.2, -2.85, -5.3, -3.05)
    ..cubicTo(-5.35, -3.7, -5.0, -4.25, -4.4, -4.3)
    ..cubicTo(-3.9, -4.3, -3.6, -4.0, -3.7, -3.55)
    ..close();

  static final Path _henWing = Path()
    ..moveTo(-2.3, -1.35)
    ..cubicTo(-0.8, -1.75, 1.6, -1.6, 3.0, -1.0)
    ..cubicTo(3.5, -0.75, 3.6, -0.3, 3.3, 0.05)
    ..cubicTo(2.0, 0.6, 0.0, 0.95, -1.4, 0.7)
    ..cubicTo(-2.4, 0.5, -2.8, -0.6, -2.3, -1.35)
    ..close();

  static final List<Path> _henTail = [
    _feather(const Offset(3.2, -2.55), const Offset(3.35, -4.35), 0.3),
    _feather(const Offset(3.5, -2.6), const Offset(4.15, -4.45), 0.32),
    _feather(const Offset(3.8, -2.5), const Offset(4.85, -4.05), 0.32),
    _feather(const Offset(4.0, -2.3), const Offset(5.35, -3.35), 0.28),
    _feather(const Offset(4.15, -2.0), const Offset(5.55, -2.5), 0.24),
  ];

  static final Path _henComb = Path.combine(
    PathOperation.union,
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(-4.92, -4.3), radius: 0.2))
      ..addOval(Rect.fromCircle(center: const Offset(-4.62, -4.5), radius: 0.26)),
    Path.combine(
      PathOperation.union,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(-4.28, -4.55), radius: 0.27))
        ..addOval(Rect.fromCircle(center: const Offset(-3.95, -4.42), radius: 0.22)),
      Path()..addRRect(
        RRect.fromRectAndRadius(const Rect.fromLTRB(-5.02, -4.42, -3.85, -4.12), const Radius.circular(0.1)),
      ),
    ),
  );

  static void _henLeg(Canvas canvas, Offset top, Offset ankle, bool isDark, {bool far = false}) {
    final a = far ? 0.6 : 1.0;
    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = _Colors.amber700.withValues(alpha: a);
    final light = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = (far ? _Colors.amber500 : _Colors.amber400).withValues(alpha: a);
    final toes = [ankle + const Offset(-0.95, 0.36), ankle + const Offset(-0.6, 0.42), ankle + const Offset(0.42, 0.3)];
    canvas.drawLine(top, ankle, dark..strokeWidth = 0.24);
    for (final t in toes) {
      canvas.drawLine(ankle, t, dark..strokeWidth = 0.16);
    }
    canvas.drawLine(top, ankle, light..strokeWidth = 0.16);
    for (final t in toes) {
      canvas.drawLine(ankle, t, light..strokeWidth = 0.09);
    }
    // Scales on the shank.
    final sc = Paint()
      ..strokeWidth = 0.025
      ..color = _Colors.amber700.withValues(alpha: 0.6 * a);
    for (var i = 1; i < 6; i++) {
      final p = Offset.lerp(top, ankle, i / 6)!;
      canvas.drawLine(p + const Offset(-0.07, 0), p + const Offset(0.07, 0.03), sc);
    }
  }

  static void hen(Canvas canvas, {required bool isDark}) {
    _henLeg(canvas, const Offset(0.55, 2.2), const Offset(0.5, 4.15), isDark, far: true);

    // Tail feathers (behind the body).
    for (final f in _henTail) {
      glassFill(canvas, f, isDark, alpha: 0.85, rim: 0.12);
      canvas.drawPath(f, Paint()..color = _Colors.amber600.withValues(alpha: isDark ? 0.12 : 0.1));
      outline(canvas, f, isDark, alpha: 0.75, width: 0.045);
    }

    final body = henBody;
    glassFill(canvas, body, isDark, rim: 0.42);
    canvas.save();
    canvas.clipPath(body);
    final feathers = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.035
      ..color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: isDark ? 0.13 : 0.25);
    for (var row = 0; row < 8; row++) {
      final y = -1.2 + row * 0.42;
      for (var col = 0; col < 14; col++) {
        final x = -4.2 + col * 0.46 + (row.isOdd ? 0.23 : 0);
        canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 0.22), 0.15, math.pi - 0.3, false, feathers);
      }
    }
    for (var i = 0; i < 7; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(-4.55 + i * 0.16, -3.05)
          ..quadraticBezierTo(-4.3 + i * 0.2, -2.2, -3.7 + i * 0.22, -1.55),
        feathers,
      );
    }
    canvas.restore();
    outline(canvas, body, isDark);

    // Folded wing with primary feathers.
    glassFill(canvas, _henWing, isDark, alpha: 0.7, rim: 0.18);
    final quill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.035
      ..color = (isDark ? _Colors.slate200 : _Colors.slate500).withValues(alpha: 0.35);
    for (var i = 0; i < 6; i++) {
      final x = -1.4 + i * 0.75;
      canvas.drawPath(
        Path()
          ..moveTo(x - 0.35, -1.25 + i * 0.02)
          ..quadraticBezierTo(x + 0.25, -0.3, x + 0.65, 0.55 - i * 0.12),
        quill,
      );
    }
    outline(canvas, _henWing, isDark, alpha: 0.7, width: 0.045);

    // Comb, wattle and ear lobe.
    final red = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_Colors.red400, _Colors.red600],
      ).createShader(const Rect.fromLTRB(-5.2, -4.85, -3.7, -4.1));
    canvas.drawPath(_henComb, red);
    outline(canvas, _henComb, isDark, alpha: 0.5, width: 0.035);
    final wattle = Path()
      ..moveTo(-5.2, -3.02)
      ..cubicTo(-5.32, -2.6, -5.02, -2.28, -4.9, -2.55)
      ..cubicTo(-4.84, -2.75, -4.94, -2.95, -5.0, -3.04)
      ..close();
    canvas.drawPath(
      wattle,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.red500, _Colors.red600],
        ).createShader(wattle.getBounds()),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-4.22, -3.28), width: 0.26, height: 0.2),
      Paint()..color = _Colors.red400.withValues(alpha: 0.7),
    );

    // Beak.
    final upper = Path()
      ..moveTo(-5.22, -3.64)
      ..cubicTo(-5.6, -3.64, -5.95, -3.46, -6.08, -3.3)
      ..lineTo(-5.3, -3.28)
      ..close();
    final lower = Path()
      ..moveTo(-5.3, -3.28)
      ..lineTo(-5.95, -3.28)
      ..cubicTo(-5.7, -3.1, -5.45, -3.06, -5.28, -3.08)
      ..close();
    canvas.drawPath(upper, Paint()..color = _Colors.amber500);
    canvas.drawPath(lower, Paint()..color = _Colors.amber600);
    final beakEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.035
      ..strokeJoin = StrokeJoin.round
      ..color = _Colors.amber700;
    canvas.drawPath(upper, beakEdge);
    canvas.drawPath(lower, beakEdge);
    canvas.drawCircle(const Offset(-5.45, -3.5), 0.04, Paint()..color = _Colors.amber700);

    // Eye.
    canvas.drawCircle(const Offset(-4.78, -3.68), 0.17, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(-4.8, -3.68), 0.13, Paint()..color = _Colors.amber500);
    canvas.drawCircle(const Offset(-4.82, -3.68), 0.07, Paint()..color = _Colors.slate950);
    canvas.drawCircle(const Offset(-4.85, -3.71), 0.03, Paint()..color = Colors.white);

    _henLeg(canvas, const Offset(-0.55, 2.3), const Offset(-0.7, 4.2), isDark);
  }

  // ----------------------------------------------------------------- food

  /// A grass tuft standing on [base], [h] tall (HTML grass clump).
  static void grass(Canvas canvas, Offset base, double h, {double time = 0, double alpha = 1}) {
    if (h <= 0.01) return;
    const blades = [
      (-0.42, -0.35, 0.8),
      (-0.32, -0.6, 0.62),
      (-0.25, -0.15, 1.0),
      (-0.1, 0.05, 0.9),
      (0.0, -0.08, 1.12),
      (0.05, 0.22, 1.04),
      (0.2, 0.36, 0.86),
      (0.12, 0.62, 0.6),
      (0.32, 0.5, 0.72),
    ];
    for (var i = 0; i < blades.length; i++) {
      final (dx, lean, hf) = blades[i];
      final bx = base.dx + dx * h * 0.55;
      final sway = math.sin(time * 2 + i) * 0.03 * h;
      final tip = Offset(bx + lean * h * 0.6 + sway, base.dy - hf * h);
      final w = 0.085 * h;
      final path = Path()
        ..moveTo(bx - w, base.dy)
        ..quadraticBezierTo(bx - w * 0.3 + (tip.dx - bx) * 0.3, base.dy - hf * h * 0.55, tip.dx, tip.dy)
        ..quadraticBezierTo(bx + w * 0.5 + (tip.dx - bx) * 0.35, base.dy - hf * h * 0.5, bx + w, base.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              _Colors.green800.withValues(alpha: alpha),
              (i.isEven ? _Colors.green500 : _Colors.green400).withValues(alpha: alpha),
            ],
          ).createShader(Rect.fromPoints(Offset(bx - w, base.dy), tip)),
      );
    }
  }

  /// Lumpy food bolus / cud (HTML dodecahedron). [fiber] shows grass bits.
  static void bolus(Canvas canvas, Offset c, double r, Color color, double rot, {double fiber = 1}) {
    if (r <= 0.005) return;
    const n = 11;
    final pts = [
      for (var i = 0; i < n; i++)
        c +
            Offset(math.cos(rot + i * 2 * math.pi / n), math.sin(rot + i * 2 * math.pi / n)) *
                (r * (1 + 0.11 * math.sin(i * 3.7) + 0.06 * math.cos(i * 5.3))),
    ];
    final path = _smoothClosed(pts);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [labShade(color, 0.35), color, labShade(color, -0.45)],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    // Flat-shaded facets.
    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05
      ..color = labShade(color, -0.4).withValues(alpha: 0.45);
    for (var i = 0; i < n; i += 3) {
      canvas.drawLine(c + (pts[i] - c) * 0.35, pts[i], facet);
    }
    if (fiber > 0.05) {
      final f = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09
        ..strokeCap = StrokeCap.round
        ..color = _Colors.green800.withValues(alpha: 0.7 * fiber);
      for (var i = 0; i < 4; i++) {
        final a = rot * 0.7 + i * 1.6;
        final p = c + Offset(math.cos(a), math.sin(a)) * r * 0.35;
        canvas.drawLine(p, p + Offset(math.cos(a + 1.2), math.sin(a + 1.2)) * r * 0.75, f);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = labShade(color, -0.55).withValues(alpha: 0.8),
    );
  }

  /// A cluster of hard seeds; [crush] 0..1 breaks them into fragments.
  static void seeds(Canvas canvas, Offset c, double spread, double scale, double rot, double crush) {
    if (scale <= 0.01) return;
    const n = 7;
    final color = Color.lerp(_Colors.amber500, _Colors.yellow700, crush)!;
    for (var i = 0; i < n; i++) {
      final a = rot + i * 2 * math.pi / n;
      final d = i == 0 ? 0.0 : spread * (i.isEven ? 1.0 : 0.62);
      final p = c + Offset(math.cos(a * 1.0 + i), math.sin(a * 1.0 + i)) * d * scale;
      final pieces = crush < 0.08 ? 1 : 1 + (crush * 3).ceil();
      for (var j = 0; j < pieces; j++) {
        final size = scale * (pieces == 1 ? 1.0 : (1 - 0.7 * crush) / math.sqrt(pieces.toDouble()) * 1.2);
        final off = pieces == 1
            ? Offset.zero
            : Offset(math.cos(j * 2.4 + i), math.sin(j * 2.4 + i)) * 0.09 * scale * (0.5 + crush);
        canvas.save();
        canvas.translate(p.dx + off.dx, p.dy + off.dy);
        canvas.rotate(a + j * 1.3);
        final rect = Rect.fromCenter(center: Offset.zero, width: 0.24 * size, height: 0.15 * size);
        if (pieces == 1) {
          canvas.drawOval(
            rect,
            Paint()
              ..shader = RadialGradient(
                center: const Alignment(-0.4, -0.5),
                colors: [labShade(color, 0.4), color, labShade(color, -0.4)],
              ).createShader(rect),
          );
          canvas.drawLine(
            Offset(-0.08 * size, 0),
            Offset(0.08 * size, 0),
            Paint()
              ..strokeWidth = 0.018 * size
              ..color = labShade(color, -0.45),
          );
        } else {
          final frag = Path()
            ..moveTo(rect.left, rect.center.dy)
            ..lineTo(rect.center.dx + rect.width * 0.1, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..close();
          canvas.drawPath(frag, Paint()..color = j.isEven ? color : labShade(color, -0.2));
        }
        canvas.restore();
      }
    }
  }

  /// A cluster of small grey stones (grit).
  static void grit(Canvas canvas, Offset c, double spread, double scale, double rot) {
    if (scale <= 0.01) return;
    for (var i = 0; i < 6; i++) {
      final a = -rot + i * 2 * math.pi / 6 + 0.4;
      final d = spread * (i.isEven ? 1.0 : 0.55);
      final p = c + Offset(math.cos(a), math.sin(a)) * d * scale;
      final r = 0.1 * scale * (0.85 + 0.3 * ((i * 37) % 10) / 10);
      final pts = [
        for (var v = 0; v < 6; v++)
          p +
              Offset(math.cos(v * math.pi / 3 + i), math.sin(v * math.pi / 3 + i)) *
                  r *
                  (0.8 + 0.25 * math.sin(v * 2.1 + i)),
      ];
      final path = Path()..addPolygon(pts, true);
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.5),
            colors: [_Colors.slate200, _Colors.slate400, _Colors.slate600],
          ).createShader(Rect.fromCircle(center: p, radius: r)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.02 * scale
          ..color = _Colors.slate700,
      );
    }
  }

  /// Ground-up food paste (HTML brown sphere).
  static void paste(Canvas canvas, Offset c, double r, double time) {
    if (r <= 0.005) return;
    const n = 12;
    final path = _smoothClosed([
      for (var i = 0; i < n; i++)
        c +
            Offset(math.cos(i * 2 * math.pi / n), math.sin(i * 2 * math.pi / n)) *
                (r * (1 + 0.07 * math.sin(time * 3 + i * 1.7))),
    ]);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [labShade(_Colors.yellow800, 0.4), _Colors.yellow800, labShade(_Colors.yellow800, -0.4)],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.3, -r * 0.4), width: r * 0.6, height: r * 0.3),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }
}

/// One confetti piece (HTML `confetti()` at the scenario end).
@immutable
class _Confetto {
  const _Confetto(this.vx, this.vy, this.spin, this.flip, this.w, this.h, this.color);
  final double vx, vy, spin, flip, w, h;
  final Color color;
}

class _DigestPainter extends CustomPainter {
  _DigestPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.tr,
  }) : super(repaint: repaint);

  final _DigestScene scene;
  final bool isDark;
  final bool showLabels;
  final String Function(String key) tr;

  static final List<Offset> _cowParticles = _randomOffsets(50, 1.25, 11);
  static final List<Offset> _birdParticles = _randomOffsets(30, 1.0, 12);
  static final List<Offset> _fibres = _randomOffsets(14, 1.0, 21);
  static final List<Offset> _microbes = _randomOffsets(18, 1.0, 22);
  static final List<Offset> _floorSpots = _randomOffsets(40, 1.0, 31);

  static final List<_Confetto> _confetti = () {
    final r = math.Random(42);
    const colors = [Color(0xFF4F46E5), Color(0xFF3B82F6), Color(0xFF10B981), Colors.white];
    return [
      for (var i = 0; i < 120; i++)
        () {
          final a = -math.pi / 2 + (r.nextDouble() - 0.5) * 1.75;
          final v = 450 + r.nextDouble() * 650;
          return _Confetto(
            math.cos(a) * v,
            math.sin(a) * v,
            (r.nextDouble() - 0.5) * 12,
            4 + r.nextDouble() * 8,
            7 + r.nextDouble() * 6,
            5 + r.nextDouble() * 4,
            colors[i % colors.length],
          );
        }(),
    ];
  }();

  static List<Offset> _randomOffsets(int n, double half, int seed) {
    final r = math.Random(seed);
    return [for (var i = 0; i < n; i++) Offset((r.nextDouble() - 0.5) * 2 * half, (r.nextDouble() - 0.5) * 2 * half)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    _paintBackdrop(canvas, size);
    canvas.save();
    canvas.translate(500 - s.camX * s.camK, 280 - s.camY * s.camK);
    canvas.scale(s.camK * s.mirror, s.camK);
    if (s.isCow) {
      _paintCowWorld(canvas);
    } else {
      _paintBirdWorld(canvas);
    }
    canvas.restore();
    _paintDropZone(canvas);
    if (showLabels) {
      if (s.isCow) {
        _cowLabels(canvas);
      } else {
        _birdLabels(canvas);
      }
    }
    _paintConfetti(canvas);
  }

  // ------------------------------------------------------------ backdrop

  void _paintBackdrop(Canvas canvas, Size size) {
    final s = scene;
    final bleed = labBleed(size);
    final groundY = s.toDesign(Offset(0, s.isCow ? _cowGround : _birdGround)).dy;
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF0B1120), Color(0xFF141E38)] : const [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, groundY)),
    );
    // Soft spotlight behind the animal.
    final c = s.toDesign(s.isCow ? const Offset(-0.8, 0.4) : const Offset(-0.4, -0.6));
    final r = 7.0 * s.camK;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _Colors.indigo500.withValues(alpha: isDark ? 0.24 : 0.16),
            _Colors.indigo500.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Holographic lab grid (1 world unit), moving with the camera.
    final grid = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? _Colors.indigo300 : _Colors.indigo400).withValues(alpha: isDark ? 0.06 : 0.1);
    final x0 = s.camX + (bleed.left - 500) / s.camK;
    final x1 = s.camX + (bleed.right - 500) / s.camK;
    final y0 = s.camY + (bleed.top - 280) / s.camK;
    for (var wx = x0.floor(); wx <= x1.ceil(); wx++) {
      final x = 500 + (wx - s.camX) * s.camK;
      canvas.drawLine(Offset(x, bleed.top), Offset(x, groundY), grid);
    }
    for (var wy = y0.floor(); wy <= (s.isCow ? _cowGround : _birdGround); wy++) {
      final y = s.toDesign(Offset(0, wy.toDouble())).dy;
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
    // Floor with perspective lines.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, groundY, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF1B2545), Color(0xFF0B1120)] : const [Color(0xFFC7D2FE), Color(0xFFE2E8F0)],
        ).createShader(Rect.fromLTRB(0, groundY, size.width, groundY + 260)),
    );
    final floorLine = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? _Colors.indigo300 : _Colors.indigo500).withValues(alpha: isDark ? 0.08 : 0.12);
    for (var wx = x0.floor(); wx <= x1.ceil(); wx++) {
      final x = 500 + (wx - s.camX) * s.camK;
      canvas.drawLine(Offset(x, groundY), Offset(500 + (x - 500) * 3.2, groundY + 600), floorLine);
    }
    canvas.drawLine(
      Offset(bleed.left, groundY),
      Offset(bleed.right, groundY),
      Paint()
        ..strokeWidth = 1.5
        ..color = _Colors.indigo400.withValues(alpha: isDark ? 0.35 : 0.45),
    );
  }

  /// Grass tufts (cow) or scattered grain (hen) on the floor.
  void _floorDecor(Canvas canvas, double ground) {
    final s = scene;
    for (var i = 0; i < _floorSpots.length; i++) {
      final o = _floorSpots[i];
      final x = -14 + i * 0.7 + o.dx * 0.3;
      final y = ground + 0.1 + (o.dy + 1) * 0.6;
      if (s.isCow) {
        if (i.isOdd) continue;
        _Art.grass(canvas, Offset(x, y), 0.38 + 0.12 * o.dx.abs(), time: s.time, alpha: isDark ? 0.45 : 0.6);
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 0.14, height: 0.09),
          Paint()..color = _Colors.amber500.withValues(alpha: isDark ? 0.45 : 0.6),
        );
        if (i % 3 == 0) {
          canvas.drawLine(
            Offset(x + 0.2, y + 0.05),
            Offset(x + 0.75, y - 0.05 + o.dx * 0.1),
            Paint()
              ..strokeWidth = 0.035
              ..color = _Colors.amber400.withValues(alpha: isDark ? 0.3 : 0.45),
          );
        }
      }
    }
  }

  // --------------------------------------------------------------- cow

  void _paintCowWorld(Canvas canvas) {
    final s = scene;
    _floorDecor(canvas, _cowGround);
    labGroundShadow(canvas, const Offset(0.6, _cowGround), 11.5, 0.7, opacity: isDark ? 0.55 : 0.25);
    _Art.cow(canvas, isDark: isDark, jaw: _jawOpen(), tailSwing: math.sin(s.time * 1.4) * 0.07);
    _paintCowOrgans(canvas);
    if (s.grassVisible && s.grassScale > 0.01) {
      _Art.grass(canvas, s.grassPos + Offset(0, 0.6 * s.grassScale), 1.25 * s.grassScale, time: s.time);
    }
    if (s.foodVisible && s.foodScale > 0.01) {
      _Art.bolus(canvas, s.foodPos, 0.42 * s.foodScale, s.foodColor, s.foodRot, fiber: 1 - s.chew / 100);
    }
    _paintParticles(canvas, _cowParticles);
  }

  double _jawOpen() {
    final s = scene;
    if (s.chewing) return 0.5 + 0.5 * math.sin(s.time * 16);
    if (s.time < s.chompUntil) return math.sin(s.time * 20).abs();
    return 0;
  }

  /// Ball-shaped organ with a lit gradient and an outline.
  void _organ(Canvas canvas, Offset c, double rx, double ry, Color color) {
    final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: [labShade(color, 0.35), color, labShade(color, -0.45)],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-rx * 0.35, -ry * 0.48), width: rx * 0.6, height: ry * 0.3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rx * 0.06),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.04
        ..color = labShade(color, -0.55).withValues(alpha: 0.85),
    );
  }

  /// Tube-shaped organ (esophagus, abomasum, intestine).
  void _tube(Canvas canvas, Path path, double w, Color color) {
    Paint stroke(double width, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;
    canvas.drawPath(path, stroke(w + 0.08, labShade(color, -0.5)));
    canvas.drawPath(path, stroke(w, color));
    canvas.drawPath(
      path.shift(Offset(-w * 0.1, -w * 0.18)),
      stroke(w * 0.32, labShade(color, 0.45).withValues(alpha: 0.6)),
    );
  }

  void _paintCowOrgans(Canvas canvas) {
    final s = scene;
    _tube(canvas, _smooth(_cowEsophagus), 0.3, _Colors.rose700);

    // Omasum (behind the rumen) with its leaf-like folds.
    _organ(canvas, _omasumC, 0.82, 0.82, _Colors.pink800);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: _omasumC, radius: 0.72)));
    final leaf = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.04
      ..color = _Colors.pink300.withValues(alpha: 0.4);
    for (var i = -2; i <= 2; i++) {
      final y = _omasumC.dy + i * 0.26;
      canvas.drawPath(
        Path()
          ..moveTo(_omasumC.dx - 0.8, y + 0.15)
          ..quadraticBezierTo(_omasumC.dx, y - 0.22, _omasumC.dx + 0.8, y + 0.15),
        leaf,
      );
    }
    canvas.restore();

    _tube(canvas, _smooth(_cowAbomasum), 0.95, _Colors.rose500);
    _tube(canvas, _smooth(_cowIntestine), 0.34, _Colors.amber500);

    // Rumen, cut open after "Inspect Stomach".
    _organ(canvas, _rumenC, 2.45, 1.8, _Colors.rose700);
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08
      ..strokeCap = StrokeCap.round
      ..color = labShade(_Colors.rose700, -0.35).withValues(alpha: 0.55 * (1 - s.cut));
    final rumenRect = Rect.fromCenter(center: _rumenC, width: 4.9, height: 3.6);
    canvas.drawArc(rumenRect.deflate(0.45), 2.4, 1.4, false, band);
    canvas.drawArc(rumenRect.deflate(0.45), -0.7, 1.2, false, band);
    if (s.cut > 0) {
      final inner = Rect.fromCenter(center: _rumenC + const Offset(0, 0.05), width: 4.3, height: 3.05);
      canvas.drawOval(
        inner,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF881337).withValues(alpha: 0.95 * s.cut),
              _Colors.rose950.withValues(alpha: 0.95 * s.cut),
            ],
          ).createShader(inner),
      );
      canvas.save();
      canvas.clipPath(Path()..addOval(inner));
      _rumenContents(canvas, inner);
      canvas.restore();
      canvas.drawOval(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05
          ..color = _Colors.rose300.withValues(alpha: 0.5 * s.cut),
      );
    }

    // Reticulum (in front) with its honeycomb lining.
    _organ(canvas, _reticC, 0.82, 0.82, _Colors.rose600);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: _reticC, radius: 0.74)));
    final hex = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.03
      ..color = Colors.white.withValues(alpha: 0.24);
    const hr = 0.17;
    for (var row = -4; row <= 4; row++) {
      for (var col = -4; col <= 4; col++) {
        final cx = _reticC.dx + col * hr * 1.732 + (row.isOdd ? hr * 0.866 : 0);
        final cy = _reticC.dy + row * hr * 1.5;
        canvas.drawPath(
          Path()..addPolygon([
            for (var v = 0; v < 6; v++)
              Offset(
                cx + hr * math.cos(math.pi / 6 + v * math.pi / 3),
                cy + hr * math.sin(math.pi / 6 + v * math.pi / 3),
              ),
          ], true),
          hex,
        );
      }
    }
    canvas.restore();
  }

  /// Fibrous grass and microbes churning inside the opened rumen.
  void _rumenContents(Canvas canvas, Rect inner) {
    final s = scene;
    final c = inner.center;
    final fibre = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.06
      ..strokeCap = StrokeCap.round
      ..color = _Colors.green500.withValues(alpha: 0.75 * s.cut);
    for (var i = 0; i < _fibres.length; i++) {
      final o = _fibres[i];
      final p =
          c +
          Offset(
            o.dx * inner.width * 0.38 + math.sin(s.time * 0.8 + i) * 0.12,
            o.dy * inner.height * 0.32 + math.cos(s.time * 0.7 + i) * 0.08,
          );
      final a = i * 1.3 + math.sin(s.time * 0.5 + i) * 0.4;
      final d = Offset(math.cos(a), math.sin(a)) * 0.28;
      canvas.drawPath(
        Path()
          ..moveTo(p.dx - d.dx, p.dy - d.dy)
          ..quadraticBezierTo(p.dx + d.dy * 0.4, p.dy - d.dx * 0.4, p.dx + d.dx, p.dy + d.dy),
        fibre,
      );
    }
    final microbe = Paint()..color = const Color(0xFFE9D5FF).withValues(alpha: 0.85 * s.cut);
    for (var i = 0; i < _microbes.length; i++) {
      final o = _microbes[i];
      final p =
          c +
          Offset(
            o.dx * inner.width * 0.4 + math.sin(s.time * 1.6 + i * 2) * 0.18,
            o.dy * inner.height * 0.34 + math.cos(s.time * 1.3 + i) * 0.14,
          );
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(s.time * (i.isEven ? 1.2 : -0.9) + i);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: i % 3 == 0 ? 0.08 : 0.16, height: 0.07), microbe);
      canvas.restore();
    }
  }

  // -------------------------------------------------------------- bird

  void _paintBirdWorld(Canvas canvas) {
    final s = scene;
    _floorDecor(canvas, _birdGround);
    labGroundShadow(canvas, const Offset(-0.1, _birdGround), 6.0, 0.55, opacity: isDark ? 0.55 : 0.25);
    _Art.hen(canvas, isDark: isDark);
    _paintBirdOrgans(canvas);
    final g = s.gizzardScale;
    final jitter = s.grinding ? Offset(math.sin(s.time * 41) * 0.03, math.cos(s.time * 37) * 0.03) : Offset.zero;
    if (s.seedsVisible) {
      final inG = (s.seedsPos - _gizzardC).distance < 0.05;
      _Art.seeds(
        canvas,
        s.seedsPos + jitter,
        s.seedsSpread * (inG ? g : 1),
        s.seedsScale * (inG ? g : 1),
        s.seedsRot,
        s.crush,
      );
    }
    if (s.gritVisible) {
      final inG = (s.gritPos - _gizzardC).distance < 0.05;
      _Art.grit(canvas, s.gritPos - jitter, s.gritSpread * (inG ? g : 1), s.gritScale * (inG ? g : 1), s.gritRot);
    }
    if (s.pasteVisible) _Art.paste(canvas, s.pastePos, 0.55 * s.pasteScale, s.time);
    _paintParticles(canvas, _birdParticles);
  }

  void _paintBirdOrgans(Canvas canvas) {
    final s = scene;
    final eso = isDark ? _Colors.slate300 : _Colors.slate400;
    _tube(canvas, _smooth(_birdIntestine.sublist(1)), 0.36, isDark ? _Colors.slate400 : _Colors.slate500);
    _tube(canvas, _smooth(_birdEsophagus), 0.24, eso);
    _tube(canvas, _smooth(_birdProvent), 0.3, eso);

    // Crop: a thin-walled storage sac.
    _organ(canvas, _cropC, 0.62, 0.6, isDark ? _Colors.slate500 : _Colors.slate400);

    // Gizzard: thick muscular ring around a lumen.
    final g = s.gizzardScale;
    final c = _gizzardC;
    final outer = 1.2 * g;
    final lumen = 0.68 * g;
    final rect = Rect.fromCircle(center: c, radius: outer);
    canvas.drawCircle(
      c,
      outer,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [labShade(_Colors.red800, 0.25), _Colors.red900, labShade(_Colors.red900, -0.45)],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    final striation = Paint()
      ..strokeWidth = 0.035
      ..color = labShade(_Colors.red800, 0.35).withValues(alpha: 0.35);
    for (var i = 0; i < 28; i++) {
      final a = i * 2 * math.pi / 28;
      final u = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + u * (lumen + 0.08), c + u * (outer - 0.08), striation);
    }
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-0.4 * g, -0.72 * g), width: 0.75 * g, height: 0.26 * g),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.05),
    );
    final lr = Rect.fromCircle(center: c, radius: lumen);
    canvas.drawCircle(
      c,
      lumen,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF3B0A0A), _Colors.red800.withValues(alpha: 0.85)],
        ).createShader(lr),
    );
    canvas.drawCircle(
      c,
      lumen,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.04
        ..color = labShade(_Colors.red800, 0.4).withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      c,
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.045
        ..color = labShade(_Colors.red900, -0.5),
    );
  }

  // ----------------------------------------------------------- effects

  /// Yellow nutrient particles spreading out and fading (HTML Points).
  void _paintParticles(Canvas canvas, List<Offset> pts) {
    final s = scene;
    if (s.particlesStart < 0) return;
    final t = (s.time - s.particlesStart) / 1.5;
    if (t < 0 || t >= 1) return;
    final spread = 2 * t;
    final o = 1 - t;
    final dot = Paint()..color = _Colors.yellow300.withValues(alpha: o);
    for (final p in pts) {
      final c = s.particlesPos + p * spread;
      labGlow(canvas, c, 0.26, _Colors.yellow300, intensity: o * 0.8);
      canvas.drawCircle(c, 0.07, dot);
    }
  }

  void _paintDropZone(Canvas canvas) {
    final s = scene;
    final expecting = s.isCow ? (s.step == 1 || s.step == 5) : (s.step == 1 || s.step == 3);
    if (!expecting) return;
    final c = s.toDesign(s.dropPoint);
    final active = s.dragging != null;
    final pulse = 0.5 + 0.5 * math.sin(s.time * 4);
    final r = active ? _dropRadius : _dropRadius * (0.62 + 0.05 * pulse);
    if (active) {
      canvas.drawCircle(c, r, Paint()..color = _Colors.emerald500.withValues(alpha: 0.2));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = _Colors.emerald500.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    labDashedPath(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 4 : 2.5
        ..color = (isDark ? _Colors.emerald400 : _Colors.emerald600).withValues(alpha: active ? 1 : 0.4 + 0.35 * pulse),
      dash: 12,
      gap: 8,
      phase: s.time * 20,
    );
    if (active) {
      labText(
        canvas,
        tr('drop_here'),
        c + Offset(0, r + 16),
        size: 15,
        weight: FontWeight.w800,
        color: _Colors.green400,
        background: const Color(0xCC064E3B),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        radius: 6,
      );
    }
  }

  void _paintConfetti(Canvas canvas) {
    final s = scene;
    if (s.confettiStart < 0) return;
    final t = s.time - s.confettiStart;
    if (t < 0 || t > 2.8) return;
    final alpha = (t < 2.0 ? 1.0 : 1 - (t - 2.0) / 0.8).clamp(0.0, 1.0);
    final drag = (1 - math.exp(-1.4 * t)) / 1.4;
    for (final c in _confetti) {
      final x = 500 + c.vx * drag;
      final y = 280 + c.vy * drag + 0.5 * 650 * t * t;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.spin * t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: c.w, height: c.h * (0.3 + 0.7 * math.cos(t * c.flip).abs())),
        Paint()..color = c.color.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  // ------------------------------------------------------------ labels

  void _label(Canvas canvas, String text, Offset world, {Offset? pointTo, double opacity = 1, Color? border}) {
    if (opacity <= 0.02) return;
    final s = scene;
    final at = s.toDesign(world);
    final lineColor = (isDark ? Colors.white : _Colors.slate700).withValues(alpha: 0.6 * opacity);
    if (pointTo != null) {
      final to = s.toDesign(pointTo);
      canvas.drawLine(
        at,
        to,
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(to, 3.5, Paint()..color = lineColor);
    }
    labText(
      canvas,
      text,
      at,
      size: 15,
      weight: FontWeight.w700,
      color: isDark ? Colors.white : _Colors.slate800,
      background: isDark ? const Color(0xE61E293B) : const Color(0xF2FFFFFF),
      border: border ?? (isDark ? _Colors.slate600 : _Colors.slate300),
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      opacity: opacity,
    );
  }

  bool get _particlesOn => scene.particlesStart >= 0 && scene.time - scene.particlesStart < 1.5;

  void _cowLabels(Canvas canvas) {
    final s = scene;
    if (!s.inspected) _label(canvas, tr('lbl_cow'), const Offset(0.6, -3.35), border: _Colors.indigo400);
    if (s.step == 1 && s.grassVisible && s.grassScale > 0.9) {
      _label(canvas, tr('lbl_grass'), s.grassPos + const Offset(0, -1.15));
    }
    if (s.step == 1 || s.step == 5) {
      _label(
        canvas,
        tr('lbl_mouth'),
        const Offset(-7.0, 1.8),
        pointTo: const Offset(-7.0, 0.7),
        border: _Colors.emerald500,
      );
    }
    final o = s.cut;
    if (s.inspected) {
      _label(canvas, tr('lbl_esophagus'), const Offset(-3.9, -1.55), pointTo: const Offset(-3.9, -0.68), opacity: o);
      _label(canvas, tr('lbl_rumen'), const Offset(-0.2, -0.95), opacity: o, border: _Colors.rose500);
      _label(canvas, tr('lbl_reticulum'), const Offset(-2.6, 2.35), pointTo: const Offset(-2.6, 1.6), opacity: o);
      _label(canvas, tr('lbl_omasum'), const Offset(2.55, -2.05), pointTo: const Offset(2.55, -1.5), opacity: o);
      _label(canvas, tr('lbl_abomasum'), const Offset(2.6, 2.3), pointTo: const Offset(3.05, 0.85), opacity: o);
      _label(canvas, tr('lbl_intestine'), const Offset(3.95, 2.75), pointTo: const Offset(4.35, 1.85), opacity: o);
      if (s.foodInRumen) _label(canvas, tr('lbl_microbes'), const Offset(0.7, 1.0), opacity: o);
    }
    if ((s.step == 4 || s.step == 5) && s.foodVisible && (s.foodPos - _cowMouth).distance < 0.05) {
      _label(
        canvas,
        tr(s.step == 5 ? 'lbl_cud' : 'lbl_cud_raw'),
        _cowMouth + const Offset(0.2, -1.15),
        border: _Colors.lime500,
      );
    }
    if (_particlesOn) {
      _label(canvas, tr('lbl_nutrients'), s.particlesPos + const Offset(0, -1.9), border: _Colors.yellow300);
    }
  }

  void _birdLabels(Canvas canvas) {
    final s = scene;
    if (!s.inspected) _label(canvas, tr('lbl_hen'), const Offset(0.4, -2.75), border: _Colors.indigo400);
    if (s.step == 1 || s.step == 3) {
      _label(
        canvas,
        tr('lbl_beak'),
        const Offset(-5.6, -1.85),
        pointTo: const Offset(-5.75, -3.15),
        border: _Colors.emerald500,
      );
    }
    final o = s.cut;
    if (s.inspected) {
      _label(canvas, tr('lbl_esophagus'), const Offset(-2.6, -2.8), pointTo: const Offset(-3.95, -2.1), opacity: o);
      _label(canvas, tr('lbl_crop'), const Offset(-4.9, -0.3), pointTo: const Offset(-3.6, -0.9), opacity: o);
      _label(
        canvas,
        tr('lbl_gizzard'),
        const Offset(1.8, -1.2),
        pointTo: const Offset(0.85, -0.6),
        opacity: o,
        border: _Colors.red500,
      );
      _label(canvas, tr('lbl_intestine'), const Offset(2.75, 0.1), pointTo: const Offset(2.3, 1.05), opacity: o);
    }
    if (_particlesOn) {
      _label(canvas, tr('lbl_nutrients'), s.particlesPos + const Offset(0, -1.6), border: _Colors.yellow300);
    }
  }

  @override
  bool shouldRepaint(covariant _DigestPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.tr != tr;
}

/// Food icon in a tray tile.
class _ItemIconPainter extends CustomPainter {
  const _ItemIconPainter(this.item);

  final _Item item;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide / 2;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(u);
    switch (item) {
      case _Item.grass:
        _Art.grass(canvas, const Offset(0, 0.9), 1.65);
      case _Item.cud:
        _Art.bolus(canvas, Offset.zero, 0.66, _Colors.lime500, 0.4, fiber: 0);
      case _Item.seeds:
        _Art.seeds(canvas, Offset.zero, 0.44, 2.6, 0.3, 0);
      case _Item.grit:
        _Art.grit(canvas, Offset.zero, 0.48, 3.0, 0.2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ItemIconPainter old) => old.item != item;
}

/// The animal on the setup board (HTML board icon).
class _BadgePainter extends CustomPainter {
  const _BadgePainter(this.scenario);

  final int scenario;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    labGlow(canvas, c, size.height * 0.7, _Colors.indigo500, intensity: 0.5);
    final cow = scenario == 0;
    final bounds = cow ? const Rect.fromLTRB(-7.4, -2.9, 6.0, 5.4) : const Rect.fromLTRB(-6.2, -4.95, 5.7, 4.7);
    final k = math.min(size.width / bounds.width, size.height / bounds.height) * 0.95;
    final m = cow ? 1.0 : -1.0; // the hen faces right, as in the scene
    canvas.save();
    canvas.translate(c.dx - m * bounds.center.dx * k, c.dy - bounds.center.dy * k);
    canvas.scale(m * k, k);
    if (cow) {
      _Art.cow(canvas, isDark: true);
    } else {
      _Art.hen(canvas, isDark: true);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BadgePainter old) => old.scenario != scenario;
}

// ============================================================= LAB FRAMEWORK
// The lab screen used by every activity: shell (sidebar, curtain, canvas
// tools, popups, settings), controller, widgets, painting helpers and shell
// strings. Kept in this file so the activity stands alone.

// =========================================================== LAB STYLE TYPES

// The shapes of a lab's audio, theme and font. The values themselves (which
// tones, which colours, which font) live in every activity file, in its
// AUDIO / THEME / FONT sections; the shared shell only reads them.

/// A sound effect. Each activity declares its own tones (an enum that
/// implements this) and plays them with its own player.
abstract interface class LabTone {
  void play();
}

/// One lab's light or dark palette (the HTML `:root` / `.dark` variables).
@immutable
class LabPalette {
  const LabPalette({
    required this.isDark,
    required this.bg,
    required this.panel,
    required this.border,
    required this.card,
    required this.cardBorder,
    required this.canvasBg,
    required this.text,
    required this.textStrong,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.danger,
    required this.onDanger,
    required this.info,
    required this.popupBg,
    required this.popupHeader,
    required this.dialogBg,
    required this.toastBg,
    required this.toastText,
    required this.curtainBg,
    required this.curtainGlow,
    required this.curtainText,
    required this.curtainMuted,
    required this.curtainIcon,
    required this.buttonBg,
    required this.buttonIcon,
    required this.buttonBorder,
    required this.readoutBg,
    required this.readoutBorder,
    required this.readoutIcon,
    required this.labelBg,
    required this.labelText,
  });

  final bool isDark;

  /// Page background (`--bg-primary`).
  final Color bg;

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  final Color panel;
  final Color border;

  /// Inset cards inside panels.
  final Color card;
  final Color cardBorder;

  /// Canvas background (`bg-slate-100 dark:bg-slate-900`).
  final Color canvasBg;

  final Color text;
  final Color textStrong;
  final Color textMuted;

  /// Brand colour (ZSL yellow) and the text drawn on it.
  final Color accent;
  final Color onAccent;

  /// Secondary buttons (e.g. "Continue") and their text.
  final Color primary;
  final Color onPrimary;

  /// Completed scenario, error toast (and its text), completed step.
  final Color success;
  final Color danger;
  final Color onDanger;
  final Color info;

  /// Success popup body and header, settings dialog.
  final Color popupBg;
  final Color popupHeader;
  final Color dialogBg;

  /// Feedback toast.
  final Color toastBg;
  final Color toastText;

  /// Intro curtain with "Enter Lab".
  final Color curtainBg;
  final Color curtainGlow;
  final Color curtainText;
  final Color curtainMuted;
  final Color curtainIcon;

  /// Fixed menu and back buttons.
  final Color buttonBg;
  final Color buttonIcon;
  final Color buttonBorder;

  /// Dark HUD readouts (clocks, meters, timers).
  final Color readoutBg;
  final Color readoutBorder;
  final Color readoutIcon;

  /// Dark chip used for floating object labels in the scenes.
  final Color labelBg;
  final Color labelText;

  /// Material theme for the lab's widgets, in [font].
  ThemeData theme(LabFont font) => ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        useMaterial3: true,
        fontFamily: font.family,
        fontFamilyFallback: font.fallback,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: accent,
        ),
        scaffoldBackgroundColor: bg,
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          thumbColor: accent,
        ),
      );
}

/// One lab's font: family (`null` = the app's font, which on devices is the
/// platform font with Devanagari for Hindi) and the sidebar text size
/// setting (px).
@immutable
class LabFont {
  const LabFont({
    this.family,
    this.fallback,
    this.size = 15,
    this.minSize = 12,
    this.maxSize = 24,
  });

  final String? family;
  final List<String>? fallback;

  /// Default, smallest and largest sidebar text size (HTML
  /// `--sidebar-font-size`).
  final double size;
  final double minSize;
  final double maxSize;

  /// This font, or the app's font from [ambient] when [family] is null.
  LabFont orAmbient(TextStyle? ambient) => family != null
      ? this
      : LabFont(
          family: ambient?.fontFamily,
          fallback: fallback ?? ambient?.fontFamilyFallback,
          size: size,
          minSize: minSize,
          maxSize: maxSize,
        );

  /// The font of the lab on screen, used for canvas text. Set by the shell
  /// from the lab's [LabStyle].
  static LabFont active = const LabFont();
}

/// What an activity hands the shared shell: the tones it plays for shell
/// events, its light / dark palettes and its font.
@immutable
class LabStyle {
  const LabStyle({
    required this.click,
    required this.toggle,
    required this.correct,
    required this.wrong,
    required this.success,
    required this.scenario,
    required this.curtain,
    required this.dark,
    required this.light,
    this.font = const LabFont(),
    this.releaseAudio,
  });

  /// Button click, sidebar toggle, right / wrong feedback, success popup,
  /// scenario change and the intro curtain.
  final LabTone click;
  final LabTone toggle;
  final LabTone correct;
  final LabTone wrong;
  final LabTone success;
  final LabTone scenario;
  final LabTone curtain;

  final LabPalette dark;
  final LabPalette light;
  final LabFont font;

  /// Frees the lab's audio players; called when the lab closes.
  final VoidCallback? releaseAudio;

  LabPalette palette(bool isDark) => isDark ? dark : light;
}

/// Gives the shell's widgets the open lab's style and current palette.
class LabStyleScope extends InheritedWidget {
  const LabStyleScope({
    super.key,
    required this.style,
    required this.palette,
    required super.child,
  });

  final LabStyle style;
  final LabPalette palette;

  static LabStyleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LabStyleScope>();

  static LabStyleScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No LabStyleScope: build lab widgets inside a LabShell.');
    return scope!;
  }

  @override
  bool updateShouldNotify(LabStyleScope oldWidget) =>
      style != oldWidget.style || palette != oldWidget.palette;
}

/// Responsive helpers for landscape phones through to tablets.
extension LabResponsive on BuildContext {
  /// UI scale: ~0.8 on small landscape phones, 1.0 at 400dp short side,
  /// capped at 1.45 on large tablets.
  double get labScale {
    final shortest = MediaQuery.sizeOf(this).shortestSide;
    return (shortest / 400).clamp(0.8, 1.45);
  }
}

// ================================================================ LAB MODELS

/// One step of a scenario (matches the HTML `steps: [{id, concept, action,
/// observation}]` entries). Steps are numbered from 1 by their position.
@immutable
class LabStep {
  const LabStep({
    required this.concept,
    required this.action,
    this.observation = '',
  });

  final String concept;
  final String action;
  final String observation;
}

/// A scenario's mission objective and steps for one language.
@immutable
class LabScenarioData {
  const LabScenarioData({
    required this.objective,
    required this.steps,
    this.title = '',
  });

  final String title;
  final String objective;
  final List<LabStep> steps;
}

/// A dynamic action button. Shown in the sidebar's action area and, while
/// the sidebar is collapsed, inside the floating mission card.
@immutable
class LabAction {
  const LabAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.foreground,
    this.enabled = true,
    this.highlight = false,
    this.sound,
    this.silent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Button fill. Defaults to the ZSL yellow.
  final Color? color;

  /// Text / icon colour. Defaults to a readable colour for [color].
  final Color? foreground;
  final bool enabled;

  /// Pulsing glow, like the HTML `.action-btn` animation.
  final bool highlight;

  /// Played on tap; `null` plays the lab's click tone.
  final LabTone? sound;

  /// No tap sound (when [onTap] plays its own).
  final bool silent;
}

/// Content of the draggable, scrollable success / observation popup.
@immutable
class LabPopupContent {
  const LabPopupContent({
    required this.title,
    this.heading,
    this.body,
    this.extra,
    this.actions = const [],
    this.icon = Icons.check_circle,
    this.accent,
  });

  final String title;

  /// Small uppercase heading above [body] (e.g. "Observation").
  final String? heading;
  final String? body;

  /// Optional extra widget (tables, result chips...) below [body].
  final Widget? extra;
  final List<LabAction> actions;
  final IconData icon;
  final Color? accent;
}

/// Popup content is rebuilt on every frame so that a language switch
/// re-translates an open popup.
typedef LabPopupBuilder = LabPopupContent Function();

// ========================================================= LAB SHELL STRINGS

// English / Hindi localisation helpers.

enum LabLang {
  en('EN'),
  hi('हि');

  const LabLang(this.badge);

  /// Short text shown on the language toggle button.
  final String badge;

  /// Key used in the `{'en': {...}, 'hi': {...}}` string tables.
  String get code => name;

  LabLang get next => this == LabLang.en ? LabLang.hi : LabLang.en;
}

/// A string table in the same shape as the HTML `i18n` objects:
/// `{'en': {'key': 'text'}, 'hi': {'key': 'पाठ'}}`.
typedef LabStringTable = Map<String, Map<String, String>>;

/// Looks [key] up in [table] for [lang], falling back to English, then to
/// the key itself so a missing translation is visible but never crashes.
String labTr(LabStringTable table, LabLang lang, String key) {
  return table[lang.code]?[key] ?? table['en']?[key] ?? key;
}

/// Replaces `{name}` placeholders in [template] with [values].
String labFormat(String template, Map<String, Object> values) {
  var out = template;
  values.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
  return out;
}

/// Strings used by the shared lab shell (header, sidebar, tools, settings,
/// popups, footer). Activity specific strings live in each activity file.
const LabStringTable kLabCommonStrings = {
  'en': {
    'enter_lab': 'Enter Lab',
    'select_scenario': 'Select Scenario',
    'mission_obj': 'Mission Objective',
    'target_output': 'Target Output',
    'curr_obj': 'Current Objective',
    'step': 'Step',
    'of': 'of',
    'concept_focus': 'Concept Focus:',
    'action': 'Action:',
    'actions': 'Actions',
    'controls': 'Lab Controls',
    'settings': 'Settings',
    'theme': 'Theme',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'font_size': 'Font Size',
    'on': 'On',
    'off': 'Off',
    'toggle_language': 'Toggle Language',
    'reset_lab': 'Reset Lab',
    'back_home': 'Back to Home',
    'menu': 'Menu',
    'tool_labels': 'Toggle Labels',
    'tool_lock': 'Lock / Unlock Camera',
    'tool_pan': 'Pan Mode',
    'tool_reset_view': 'Reset View',
    'tool_zoom_in': 'Zoom In',
    'tool_zoom_out': 'Zoom Out',
    'close': 'Close',
    'btn_continue': 'Continue',
    'btn_restart': 'Restart Lab',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Scientific Conclusion',
    'lbl_observation': 'Observation',
    'success': 'Success!',
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario.',
    'msg_all_complete': 'All scenarios complete! Great work.',
    'completed': 'Completed',
    'minimize': 'Minimize',
    'expand': 'Expand',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
  },
  'hi': {
    'enter_lab': 'लैब में प्रवेश करें',
    'select_scenario': 'परिदृश्य चुनें',
    'mission_obj': 'मिशन का उद्देश्य',
    'target_output': 'लक्ष्य परिणाम',
    'curr_obj': 'वर्तमान उद्देश्य',
    'step': 'चरण',
    'of': 'में से',
    'concept_focus': 'अवधारणा:',
    'action': 'कार्य:',
    'actions': 'कार्य',
    'controls': 'लैब नियंत्रण',
    'settings': 'सेटिंग्स',
    'theme': 'थीम',
    'light_mode': 'लाइट मोड',
    'dark_mode': 'डार्क मोड',
    'font_size': 'फ़ॉन्ट का आकार',
    'on': 'चालू',
    'off': 'बंद',
    'toggle_language': 'भाषा बदलें',
    'reset_lab': 'लैब रीसेट करें',
    'back_home': 'होम पर वापस जाएँ',
    'menu': 'मेनू',
    'tool_labels': 'लेबल दिखाएँ / छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक',
    'tool_pan': 'पैन मोड',
    'tool_reset_view': 'दृश्य रीसेट करें',
    'tool_zoom_in': 'ज़ूम इन',
    'tool_zoom_out': 'ज़ूम आउट',
    'close': 'बंद करें',
    'btn_continue': 'जारी रखें',
    'btn_restart': 'लैब फिर से शुरू करें',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'वैज्ञानिक निष्कर्ष',
    'lbl_observation': 'अवलोकन',
    'success': 'सफलता!',
    'msg_scenario_complete': 'परिदृश्य पूर्ण! कृपया अगला परिदृश्य चुनें।',
    'msg_all_complete': 'सभी परिदृश्य पूर्ण! बहुत बढ़िया।',
    'completed': 'पूर्ण',
    'minimize': 'छोटा करें',
    'expand': 'बड़ा करें',
    'footer': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
  },
};

// ============================================================ LAB CONTROLLER

/// Transient feedback message (the HTML `#feedback-toast`).
@immutable
class LabToast {
  const LabToast(this.text, {this.isError = false, required this.id});
  final String text;
  final bool isError;
  final int id;
}

/// Shared UI state for one lab: language, theme, sidebar, labels, camera
/// tools, toast and popup. Owned by the activity's State and passed to
/// [LabShell]. Activities rebuild on changes with a `ListenableBuilder`.
class LabController extends ChangeNotifier {
  LabController({required this.style, this.camLocked = false})
      : fontSize = style.font.size;

  static const double minZoom = 0.5;
  static const double maxZoom = 5;

  /// The activity's own tones, palettes and font.
  final LabStyle style;

  LabLang lang = LabLang.en;
  bool isDark = true;

  /// Sidebar font size in px (HTML `--sidebar-font-size`), within the
  /// lab font's range.
  double fontSize;
  bool showLabels = true;
  bool isSidebarOpen = true;

  /// Sidebar width as a fraction of the screen; drag its edge to resize.
  static const double defaultSidebarFraction = 0.30;
  double sidebarFraction = defaultSidebarFraction;

  /// How far the user dragged each floating card, by card id (see
  /// [LabMovable]).
  final Map<String, Offset> cardOffsets = {};

  /// True once the curtain has lifted (HTML `State.isLabActive`).
  bool isLabActive = false;

  /// Locked: pinch / drag do not move the canvas (zoom buttons still work).
  bool camLocked;

  /// Pan mode: drags move the canvas instead of interacting with the scene.
  bool panMode = false;
  bool settingsOpen = false;

  /// Scenarios finished in this session (HTML `completedScenarios`).
  final Set<int> completedScenarios = {};

  /// Zoom / pan of the canvas (driven by InteractiveViewer and tool buttons).
  final TransformationController transform = TransformationController();

  LabToast? toast;
  LabPopupBuilder? popup;

  Timer? _toastTimer;
  int _toastId = 0;
  bool _disposed = false;
  final Set<Timer> _timers = {};

  // Hooks registered by the shell / zoom viewer.
  void Function(double factor)? _zoomHook;
  VoidCallback? _resetViewHook;
  VoidCallback? _fullResetHook;

  /// Common (shell) string for the current language.
  String t(String key) => labTr(kLabCommonStrings, lang, key);

  /// Activity string from [table] for the current language.
  String tr(LabStringTable table, String key) => labTr(table, lang, key);

  double get fontScale => fontSize / style.font.size;

  /// The lab's palette for the current theme.
  LabPalette get palette => style.palette(isDark);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool get isDisposed => _disposed;

  /// Runs [fn] after [delay] (the HTML `setTimeout`). Pending callbacks are
  /// cancelled when the lab is disposed, so they never touch a dead State.
  Timer after(Duration delay, VoidCallback fn) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      if (!_disposed) fn();
    });
    _timers.add(timer);
    return timer;
  }

  /// Cancels every pending [after] callback (e.g. on scenario change).
  void cancelPending() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  // ---------------------------------------------------------------- settings

  void toggleLanguage() {
    style.click.play();
    lang = lang.next;
    _notify();
  }

  void setLanguage(LabLang value) {
    if (lang == value) return;
    lang = value;
    _notify();
  }

  void toggleTheme() {
    style.click.play();
    isDark = !isDark;
    _notify();
  }

  void setFontSize(double value) {
    fontSize = value.clamp(style.font.minSize, style.font.maxSize).toDouble();
    _notify();
  }

  void toggleSettings() {
    style.click.play();
    settingsOpen = !settingsOpen;
    _notify();
  }

  // ----------------------------------------------------------------- sidebar

  void toggleSidebar() {
    style.toggle.play();
    isSidebarOpen = !isSidebarOpen;
    _notify();
  }

  void openSidebar() {
    if (isSidebarOpen) return;
    style.toggle.play();
    isSidebarOpen = true;
    _notify();
  }

  // ------------------------------------------------------------ canvas tools

  void toggleLabels() {
    style.click.play();
    showLabels = !showLabels;
    _notify();
  }

  void toggleCamLock() {
    style.click.play();
    camLocked = !camLocked;
    _notify();
  }

  void togglePanMode() {
    style.click.play();
    panMode = !panMode;
    _notify();
  }

  void zoomIn() {
    style.click.play();
    _zoomHook?.call(1.25);
  }

  void zoomOut() {
    style.click.play();
    _zoomHook?.call(0.8);
  }

  /// Animates the canvas back to 100% zoom, centred.
  void resetView({bool sound = true}) {
    if (sound) style.click.play();
    if (_resetViewHook != null) {
      _resetViewHook!();
    } else {
      transform.value = Matrix4.identity();
    }
  }

  // ---------------------------------------------------------------- feedback

  /// Shows the floating feedback toast for 3 seconds. Plays the lab's
  /// "correct" / "wrong" tone unless [sound] is false.
  void showToast(String text, {bool isError = false, bool sound = true}) {
    if (sound) (isError ? style.wrong : style.correct).play();
    _toastTimer?.cancel();
    toast = LabToast(text, isError: isError, id: ++_toastId);
    _notify();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toast = null;
      _notify();
    });
  }

  /// Opens the draggable, scrollable popup. [builder] runs on every rebuild
  /// so it should read strings through [tr] / [t] to follow language changes.
  /// Plays [sound] (default: the lab's success tone) unless [silent].
  void showPopup(LabPopupBuilder builder, {LabTone? sound, bool silent = false}) {
    if (!silent) (sound ?? style.success).play();
    popup = builder;
    _notify();
  }

  void hidePopup({bool sound = true}) {
    if (popup == null) return;
    if (sound) style.click.play();
    popup = null;
    _notify();
  }

  /// The standard end-of-scenario flow from the HTML `showConclusion()`:
  /// marks the scenario complete, re-opens the sidebar and shows the
  /// conclusion popup. When every scenario is done the popup offers
  /// "Restart Lab"; otherwise "Continue" closes it and shows the
  /// "Scenario Complete" toast.
  void showScenarioConclusion({
    required int scenarioIndex,
    required int totalScenarios,
    required String Function() body,
    String Function()? title,
    String Function()? heading,
    Widget Function()? extra,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    completedScenarios.add(scenarioIndex);
    final allDone = completedScenarios.length >= totalScenarios;
    after(delay, () {
      if (!isSidebarOpen) {
        isSidebarOpen = true;
        style.toggle.play();
      }
      showPopup(() => LabPopupContent(
            title: title?.call() ?? t('success'),
            heading: heading?.call() ?? t('lbl_observation'),
            body: body(),
            extra: extra?.call(),
            actions: [
              if (allDone)
                LabAction(
                  label: t('btn_restart'),
                  icon: Icons.restart_alt,
                  onTap: requestFullReset,
                )
              else
                LabAction(
                  label: t('btn_continue'),
                  icon: Icons.arrow_forward,
                  color: palette.primary,
                  foreground: palette.onPrimary,
                  onTap: () {
                    hidePopup(sound: false);
                    showToast(t('msg_scenario_complete'));
                  },
                ),
            ],
          ));
    });
  }

  /// Full "Reset Lab" (HTML `resetApp(false)`): closes the curtain, resets
  /// language, theme, font size, labels and sidebar, then calls the
  /// activity's `onReset`.
  void requestFullReset() => _fullResetHook?.call();

  /// Restores the shell defaults. Called by the shell during a full reset.
  void resetShellState() {
    cancelPending();
    _toastTimer?.cancel();
    toast = null;
    popup = null;
    settingsOpen = false;
    lang = LabLang.en;
    isDark = true;
    fontSize = style.font.size;
    showLabels = true;
    isSidebarOpen = true;
    sidebarFraction = defaultSidebarFraction;
    cardOffsets.clear();
    panMode = false;
    completedScenarios.clear();
    transform.value = Matrix4.identity();
    _notify();
  }

  void markLabActive(bool active) {
    isLabActive = active;
    _notify();
  }

  // ------------------------------------------------------- shell internals

  // ignore: use_setters_to_change_properties
  void attachZoomHooks({
    required void Function(double factor) zoom,
    required VoidCallback resetView,
  }) {
    _zoomHook = zoom;
    _resetViewHook = resetView;
  }

  void detachZoomHooks() {
    _zoomHook = null;
    _resetViewHook = null;
  }

  // ignore: use_setters_to_change_properties
  void attachResetHook(VoidCallback hook) => _fullResetHook = hook;

  void detachResetHook() => _fullResetHook = null;

  @override
  void dispose() {
    _disposed = true;
    style.releaseAudio?.call();
    _toastTimer?.cancel();
    cancelPending();
    transform.dispose();
    super.dispose();
  }
}

// ================================================================= LAB STAGE

/// Key of the design-size box inside [LabStage] (used by tests to convert
/// design coordinates to screen positions).
const ValueKey<String> labStageDesignKey = ValueKey('lab-stage-design');

/// A fixed "design size" scene that is scaled to fit the available canvas
/// area (BoxFit.contain) and centred. Everything inside [child] is laid out,
/// painted and hit-tested in design coordinates, so a `CustomPainter` can
/// draw at e.g. 1000x560 and `GestureDetector.localPosition` values come
/// back in the same coordinates at any screen size.
///
/// [background] fills the whole canvas area (including letterbox space)
/// behind the scaled scene.
class LabStage extends StatelessWidget {
  const LabStage({
    super.key,
    required this.designSize,
    required this.child,
    this.background,
  });

  final Size designSize;
  final Widget child;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ?background,
        FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            key: labStageDesignKey,
            width: designSize.width,
            height: designSize.height,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A rect that extends well past the design area. The stage is letterboxed
/// when the canvas aspect ratio differs from the design size, and nothing
/// clips the painter there, so fill sky / ground / water with this rect
/// (and extend tracks, tables, horizons) to avoid visible seams.
Rect labBleed(Size size) =>
    Rect.fromLTRB(-size.width * 1.5, -size.height * 1.5, size.width * 2.5, size.height * 2.5);

/// Converts a global position (e.g. `DragTargetDetails.offset`) into the
/// local coordinates of the widget owning [key] (e.g. a LabStage child),
/// accounting for zoom, pan and stage scaling.
Offset? labGlobalToLocal(GlobalKey key, Offset global) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.globalToLocal(global);
}

/// Zoomable / pannable canvas used by [LabShell]. Pinch and drag move the
/// canvas unless the camera is locked; in pan mode the scene ignores
/// touches so every drag pans. Tool buttons zoom about the centre.
class LabZoomViewer extends StatefulWidget {
  const LabZoomViewer({super.key, required this.controller, required this.child});

  final LabController controller;
  final Widget child;

  @override
  State<LabZoomViewer> createState() => _LabZoomViewerState();
}

class _LabZoomViewerState extends State<LabZoomViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Matrix4Tween? _tween;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(_onTick);
    widget.controller.attachZoomHooks(zoom: _zoomBy, resetView: _reset);
  }

  @override
  void didUpdateWidget(covariant LabZoomViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachZoomHooks();
      widget.controller.attachZoomHooks(zoom: _zoomBy, resetView: _reset);
    }
  }

  @override
  void dispose() {
    widget.controller.detachZoomHooks();
    _anim.dispose();
    super.dispose();
  }

  void _onTick() {
    final tween = _tween;
    if (tween == null) return;
    widget.controller.transform.value =
        tween.transform(Curves.easeOutCubic.transform(_anim.value));
  }

  void _animateTo(Matrix4 target) {
    _tween = Matrix4Tween(
      begin: widget.controller.transform.value.clone(),
      end: target,
    );
    _anim.forward(from: 0);
  }

  void _zoomBy(double factor) {
    if (_viewport.isEmpty) return;
    final current = widget.controller.transform.value;
    final scale = current.getMaxScaleOnAxis();
    final target =
        (scale * factor).clamp(LabController.minZoom, LabController.maxZoom);
    final f = target / scale;
    final cx = _viewport.width / 2;
    final cy = _viewport.height / 2;
    // Scale about the viewport centre: x' = f * x + c * (1 - f).
    final about = Matrix4.identity()
      ..setEntry(0, 0, f)
      ..setEntry(1, 1, f)
      ..setEntry(0, 3, cx * (1 - f))
      ..setEntry(1, 3, cy * (1 - f));
    _animateTo(about.multiplied(current));
  }

  void _reset() => _animateTo(Matrix4.identity());

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final gesturesOn = c.panMode || !c.camLocked;
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return InteractiveViewer(
          transformationController: c.transform,
          minScale: LabController.minZoom,
          maxScale: LabController.maxZoom,
          boundaryMargin: const EdgeInsets.all(400),
          panEnabled: gesturesOn,
          scaleEnabled: gesturesOn,
          child: IgnorePointer(
            ignoring: c.panMode,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ========================================================= LAB PAINT HELPERS

/// Painting helpers that stand in for the Three.js meshes and HTML labels of
/// the original labs. All take design-space coordinates.

/// Lightens (amount > 0) or darkens (amount < 0) [c] by mixing with white
/// or black.
Color labShade(Color c, double amount) {
  if (amount >= 0) return Color.lerp(c, Colors.white, amount.clamp(0, 1))!;
  return Color.lerp(c, Colors.black, (-amount).clamp(0, 1))!;
}

/// Draws [text] anchored at [at]. [anchor] picks which point of the text box
/// sits on [at] (centre by default). With [background] the text is drawn
/// inside a rounded pill (the HTML floating labels / distance badges).
/// Returns the painted rect.
Rect labText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 14,
  Color color = Colors.white,
  FontWeight weight = FontWeight.w600,
  Alignment anchor = Alignment.center,
  TextAlign align = TextAlign.center,
  double? maxWidth,
  Color? background,
  Color? border,
  double borderWidth = 1.5,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  double radius = 999,
  double opacity = 1,
  String? fontFamily,
  List<Shadow>? shadows,
  double letterSpacing = 0,
}) {
  if (opacity <= 0) return Rect.zero;
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        color: color.withValues(alpha: color.a * opacity),
        fontWeight: weight,
        fontFamily: fontFamily ?? LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
        shadows: shadows,
        letterSpacing: letterSpacing,
        height: 1.2,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth ?? double.infinity);

  final pad = background != null || border != null ? padding : EdgeInsets.zero;
  final w = tp.width + pad.horizontal;
  final h = tp.height + pad.vertical;
  final left = at.dx - (anchor.x + 1) / 2 * w;
  final top = at.dy - (anchor.y + 1) / 2 * h;
  final rect = Rect.fromLTWH(left, top, w, h);

  if (background != null || border != null) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(radius, h / 2)));
    if (background != null) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(rr, Paint()..color = background.withValues(alpha: background.a * opacity));
    }
    if (border != null) {
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = border.withValues(alpha: border.a * opacity),
      );
    }
  }
  tp.paint(canvas, Offset(left + pad.left, top + pad.top));
  return rect;
}

/// Floating object label like the HTML `.object-label` chips
/// (dark pill, white bold text).
Rect labPill(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 13,
  Color background = const Color(0xE61E293B),
  Color color = Colors.white,
  Color? border = const Color(0xFF475569),
  Alignment anchor = Alignment.center,
  double opacity = 1,
}) {
  return labText(
    canvas,
    text,
    at,
    size: size,
    color: color,
    weight: FontWeight.w700,
    background: background,
    border: border,
    borderWidth: 1,
    anchor: anchor,
    opacity: opacity,
  );
}

/// Straight arrow with a filled head.
void labArrow(
  Canvas canvas,
  Offset from,
  Offset to, {
  Color color = Colors.white,
  double width = 3,
  double head = 12,
  bool dashed = false,
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final dir = to - from;
  final len = dir.distance;
  if (len < 0.001) return;
  final u = dir / len;
  final base = to - u * head;
  if (dashed) {
    labDashedLine(canvas, from, base, paint);
  } else {
    canvas.drawLine(from, base, paint);
  }
  final n = Offset(-u.dy, u.dx);
  final path = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(base.dx + n.dx * head * 0.55, base.dy + n.dy * head * 0.55)
    ..lineTo(base.dx - n.dx * head * 0.55, base.dy - n.dy * head * 0.55)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
}

/// Dashed straight line.
void labDashedLine(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 8,
  double gap = 6,
  double phase = 0,
}) {
  final total = (b - a).distance;
  if (total <= 0) return;
  final u = (b - a) / total;
  var d = -(phase % (dash + gap));
  while (d < total) {
    final s = math.max(d, 0.0);
    final e = math.min(d + dash, total);
    if (e > s) canvas.drawLine(a + u * s, a + u * e, paint);
    d += dash + gap;
  }
}

/// Dashed version of any [path] (e.g. orbits, light rays).
void labDashedPath(Canvas canvas, Path path, Paint paint,
    {double dash = 8, double gap = 6, double phase = 0}) {
  for (final metric in path.computeMetrics()) {
    var d = -(phase % (dash + gap));
    while (d < metric.length) {
      final s = math.max(d, 0.0);
      final e = math.min(d + dash, metric.length);
      if (e > s) canvas.drawPath(metric.extractPath(s, e), paint);
      d += dash + gap;
    }
  }
}

/// Lit sphere (MeshStandardMaterial look) with a soft drop shadow option.
void labSphere(
  Canvas canvas,
  Offset c,
  double r,
  Color color, {
  Offset light = const Offset(-0.35, -0.4),
  double highlight = 0.45,
  double shade = 0.55,
  bool outline = false,
  double opacity = 1,
}) {
  final rect = Rect.fromCircle(center: c, radius: r);
  final paint = Paint()
    ..shader = RadialGradient(
      center: Alignment(light.dx, light.dy),
      radius: 1.05,
      colors: [
        labShade(color, highlight).withValues(alpha: opacity),
        color.withValues(alpha: opacity),
        labShade(color, -shade).withValues(alpha: opacity),
      ],
      stops: const [0, 0.5, 1],
    ).createShader(rect);
  canvas.drawCircle(c, r, paint);
  if (outline) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(color, -0.6).withValues(alpha: 0.6 * opacity),
    );
  }
}

/// Additive-looking radial glow (light bulbs, flames, sun, hot spots).
void labGlow(Canvas canvas, Offset c, double r, Color color, {double intensity = 1}) {
  if (intensity <= 0 || r <= 0) return;
  final rect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: (0.85 * intensity).clamp(0, 1)),
        color.withValues(alpha: (0.35 * intensity).clamp(0, 1)),
        color.withValues(alpha: 0),
      ], stops: const [0, 0.35, 1]).createShader(rect),
  );
}

/// Soft elliptical contact shadow under an object.
void labGroundShadow(Canvas canvas, Offset c, double w, double h, {double opacity = 0.3}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.35),
  );
}

/// Oblique "2.5D" cuboid: [front] face plus top and right faces receding by
/// [depth] towards the upper right. Approximates a Three.js BoxGeometry.
void labBox3D(
  Canvas canvas,
  Rect front,
  double depth,
  Color color, {
  double angle = -0.6,
  bool stroke = true,
  double opacity = 1,
  double radius = 0,
}) {
  final d = Offset(math.cos(angle), math.sin(angle)) * depth;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  final top = Path()
    ..moveTo(front.left, front.top)
    ..lineTo(front.left + d.dx, front.top + d.dy)
    ..lineTo(front.right + d.dx, front.top + d.dy)
    ..lineTo(front.right, front.top)
    ..close();
  final side = Path()
    ..moveTo(front.right, front.top)
    ..lineTo(front.right + d.dx, front.top + d.dy)
    ..lineTo(front.right + d.dx, front.bottom + d.dy)
    ..lineTo(front.right, front.bottom)
    ..close();
  canvas.drawPath(top, Paint()..color = a(labShade(color, 0.25)));
  canvas.drawPath(side, Paint()..color = a(labShade(color, -0.3)));
  final frontPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [a(labShade(color, 0.08)), a(labShade(color, -0.12))],
    ).createShader(front);
  if (radius > 0) {
    canvas.drawRRect(RRect.fromRectAndRadius(front, Radius.circular(radius)), frontPaint);
  } else {
    canvas.drawRect(front, frontPaint);
  }
  if (stroke) {
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = a(labShade(color, -0.45).withValues(alpha: 0.6));
    canvas.drawPath(top, edge);
    canvas.drawPath(side, edge);
    canvas.drawRect(front, edge);
  }
}

/// Upright cylinder seen slightly from above (CylinderGeometry look).
/// [rect] is the bounding box of the side; the top ellipse height is
/// `rect.width * tilt`.
void labCylinder(
  Canvas canvas,
  Rect rect,
  Color color, {
  double tilt = 0.28,
  double opacity = 1,
  bool drawTop = true,
}) {
  final eh = rect.width * tilt;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  final body = Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.left, rect.bottom)
    ..arcTo(Rect.fromLTWH(rect.left, rect.bottom - eh / 2, rect.width, eh), math.pi, -math.pi, false)
    ..lineTo(rect.right, rect.top)
    ..close();
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        a(labShade(color, -0.35)),
        a(labShade(color, 0.25)),
        a(color),
        a(labShade(color, -0.45)),
      ], stops: const [0, 0.3, 0.6, 1]).createShader(rect),
  );
  if (drawTop) {
    canvas.drawOval(
      Rect.fromLTWH(rect.left, rect.top - eh / 2, rect.width, eh),
      Paint()..color = a(labShade(color, 0.3)),
    );
  }
}

/// Glass beaker with optional liquid. [fill] is 0..1 of the inner height.
void labBeaker(
  Canvas canvas,
  Rect rect, {
  double fill = 0,
  Color liquid = const Color(0xFF60A5FA),
  Color glass = const Color(0xFFBFDBFE),
  bool graduations = true,
  double liquidOpacity = 0.75,
}) {
  final r = rect.width * 0.08;
  final inner = rect.deflate(3);
  if (fill > 0) {
    final h = inner.height * fill.clamp(0, 1);
    final lr = Rect.fromLTRB(inner.left, inner.bottom - h, inner.right, inner.bottom);
    canvas.drawRRect(
      RRect.fromRectAndCorners(lr, bottomLeft: Radius.circular(r), bottomRight: Radius.circular(r)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(liquid, 0.15).withValues(alpha: liquidOpacity),
            labShade(liquid, -0.2).withValues(alpha: liquidOpacity),
          ],
        ).createShader(lr),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(lr.center.dx, lr.top), width: lr.width, height: lr.width * 0.12),
      Paint()..color = labShade(liquid, 0.3).withValues(alpha: liquidOpacity),
    );
  }
  final glassPath = Path()
    ..moveTo(rect.left - 4, rect.top)
    ..lineTo(rect.left, rect.top + 6)
    ..lineTo(rect.left, rect.bottom - r)
    ..quadraticBezierTo(rect.left, rect.bottom, rect.left + r, rect.bottom)
    ..lineTo(rect.right - r, rect.bottom)
    ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - r)
    ..lineTo(rect.right, rect.top);
  canvas.drawPath(glassPath, Paint()..color = glass.withValues(alpha: 0.12));
  canvas.drawPath(
    glassPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = glass.withValues(alpha: 0.85),
  );
  // Glass highlight.
  canvas.drawLine(
    Offset(rect.left + rect.width * 0.12, rect.top + 12),
    Offset(rect.left + rect.width * 0.12, rect.bottom - 12),
    Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.25),
  );
  if (graduations) {
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = glass.withValues(alpha: 0.7);
    for (var i = 1; i <= 4; i++) {
      final y = rect.bottom - rect.height * i / 5;
      canvas.drawLine(Offset(rect.right - rect.width * 0.25, y), Offset(rect.right - 3, y), g);
    }
  }
}

/// Test tube (rounded bottom) with optional liquid.
void labTestTube(
  Canvas canvas,
  Rect rect, {
  double fill = 0,
  Color liquid = const Color(0xFF60A5FA),
  Color glass = const Color(0xFFBFDBFE),
}) {
  final r = rect.width / 2;
  final path = Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.left, rect.bottom - r)
    ..arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r), clockwise: false)
    ..lineTo(rect.right, rect.top);
  if (fill > 0) {
    canvas.save();
    canvas.clipPath(Path()..addPath(path, Offset.zero)..close());
    final h = rect.height * fill.clamp(0, 1);
    canvas.drawRect(
      Rect.fromLTRB(rect.left, rect.bottom - h, rect.right, rect.bottom),
      Paint()..color = liquid.withValues(alpha: 0.8),
    );
    canvas.restore();
  }
  canvas.drawPath(path, Paint()..color = glass.withValues(alpha: 0.12));
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = glass.withValues(alpha: 0.85),
  );
  canvas.drawLine(
    Offset(rect.left - 3, rect.top),
    Offset(rect.right + 3, rect.top),
    Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = glass,
  );
}

/// Flickering flame (candle / burner / combustion). [t] is time in seconds.
void labFlame(Canvas canvas, Offset base, double height, double t, {double intensity = 1}) {
  if (intensity <= 0) return;
  final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
  final h = height * flick * intensity;
  final w = height * 0.42 * intensity;
  labGlow(canvas, base.translate(0, -h * 0.45), h * 1.1, const Color(0xFFF97316), intensity: 0.55 * intensity);
  Path flame(double sx, double sy) => Path()
    ..moveTo(base.dx, base.dy - h * sy)
    ..cubicTo(base.dx + w * sx, base.dy - h * sy * 0.55, base.dx + w * sx * 0.9, base.dy,
        base.dx, base.dy)
    ..cubicTo(base.dx - w * sx * 0.9, base.dy, base.dx - w * sx, base.dy - h * sy * 0.55,
        base.dx, base.dy - h * sy)
    ..close();
  canvas.drawPath(flame(1, 1), Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.9));
  canvas.drawPath(flame(0.7, 0.75), Paint()..color = const Color(0xFFFACC15));
  canvas.drawPath(flame(0.35, 0.4), Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.9));
}

/// Wavy heat / airflow arrow (convection, breezes).
void labWavyArrow(Canvas canvas, Offset from, Offset to, double t,
    {Color color = const Color(0xFFF97316), double amp = 6, double width = 3}) {
  final dir = to - from;
  final len = dir.distance;
  if (len < 1) return;
  final u = dir / len;
  final n = Offset(-u.dy, u.dx);
  final path = Path()..moveTo(from.dx, from.dy);
  for (var d = 0.0; d <= len - 10; d += 4) {
    final p = from + u * d + n * (amp * math.sin(d / 14 - t * 6));
    path.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color,
  );
  labArrow(canvas, from + u * (len - 14), to, color: color, width: width, head: 11);
}

/// Minimal 3D -> 2D projector for orbit-style scenes (Earth / Sun / Moon,
/// rotating globes). Rotates by [yaw] about Y, then [pitch] about X, then
/// applies a perspective divide with camera distance [distance].
class LabProjector {
  const LabProjector({
    required this.center,
    this.scale = 1,
    this.yaw = 0,
    this.pitch = 0.35,
    this.distance = 900,
  });

  final Offset center;
  final double scale;
  final double yaw;
  final double pitch;
  final double distance;

  /// Returns the projected point and its depth (larger = closer to viewer).
  ({Offset p, double depth, double k}) project(double x, double y, double z) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = x * cy + z * sy;
    final z1 = -x * sy + z * cy;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final y2 = y * cp - z1 * sp;
    final z2 = y * sp + z1 * cp;
    final k = distance / (distance - z2 * scale);
    return (
      p: Offset(center.dx + x1 * scale * k, center.dy - y2 * scale * k),
      depth: z2,
      k: k,
    );
  }

  Offset point(double x, double y, double z) => project(x, y, z).p;
}

// =============================================================== LAB WIDGETS

/// Picks the palette's dark text or white for a coloured button fill.
Color labOnColor(Color fill, LabPalette palette) =>
    fill.computeLuminance() > 0.45 ? palette.onAccent : Colors.white;

/// Button for a [LabAction]; pulses when `action.highlight` is set.
class LabActionButton extends StatefulWidget {
  const LabActionButton({
    super.key,
    required this.action,
    this.scale = 1,
    this.expand = true,
    this.dense = false,
  });

  final LabAction action;
  final double scale;
  final bool expand;
  final bool dense;

  @override
  State<LabActionButton> createState() => _LabActionButtonState();
}

class _LabActionButtonState extends State<LabActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant LabActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final on = widget.action.highlight && widget.action.enabled;
    if (on && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!on && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    final s = widget.scale;
    final scope = LabStyleScope.of(context);
    final fill = a.color ?? scope.palette.accent;
    final fg = a.foreground ?? labOnColor(fill, scope.palette);
    final enabled = a.enabled && a.onTap != null;
    final vPad = (widget.dense ? 7.0 : 10.0) * s;

    final button = Material(
      color: enabled ? fill : fill.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * s),
        onTap: enabled
            ? () {
                if (!a.silent) (a.sound ?? scope.style.click).play();
                a.onTap!();
              }
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: vPad),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (a.icon != null) ...[
                Icon(a.icon, size: 16 * s, color: fg.withValues(alpha: enabled ? 1 : 0.6)),
                SizedBox(width: 6 * s),
              ],
              Flexible(
                child: Text(
                  a.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fg.withValues(alpha: enabled ? 1 : 0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: (widget.dense ? 11.5 : 13) * s,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = a.highlight && enabled;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            boxShadow: [
              if (glow)
                BoxShadow(
                  color: fill.withValues(alpha: 0.35 + 0.4 * _pulse.value),
                  blurRadius: (12 + 12 * _pulse.value) * s,
                ),
            ],
          ),
          child: child,
        );
      },
      child: button,
    );
  }
}

/// Lays out a list of actions as full-width buttons (sidebar) or a wrap.
class LabActionList extends StatelessWidget {
  const LabActionList({
    super.key,
    required this.actions,
    this.scale = 1,
    this.dense = false,
  });

  final List<LabAction> actions;
  final double scale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(height: 8 * scale),
          LabActionButton(action: actions[i], scale: scale, dense: dense),
        ],
      ],
    );
  }
}

/// A floating card the user can drag anywhere inside the area it fills.
/// Use it as `Positioned.fill(child: LabMovable(...))`: the card is placed
/// by [left] / [top] / [right] / [bottom] / [width] / [height] like a
/// [Positioned] (centred when none is set), then shifted by the drag. The
/// card itself moves, so it can be grabbed again wherever it is; taps on the
/// empty rest of the area pass through. Taps, sliders and drags on controls
/// inside the card still work; a drag that starts on the card moves it. The
/// card stays inside the area, and its position is kept per [id] in the
/// controller, so it comes back where it was left.
class LabMovable extends StatefulWidget {
  const LabMovable({
    super.key,
    required this.controller,
    required this.id,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.margin = const EdgeInsets.all(4),
  });

  final LabController controller;
  final String id;
  final Widget child;

  /// Space kept clear inside the area's edges (e.g. the canvas tool column).
  final EdgeInsets margin;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  @override
  State<LabMovable> createState() => _LabMovableState();
}

class _LabMovableState extends State<LabMovable> {
  final GlobalKey _cardKey = GlobalKey();
  bool _moving = false;
  Offset _startOffset = Offset.zero;
  Offset _startPointer = Offset.zero;

  /// The card's box without any drag, in area coordinates (taken at the
  /// start of each drag).
  Rect? _home;

  Offset get _offset => widget.controller.cardOffsets[widget.id] ?? Offset.zero;

  // Measured from the touch-down point, so the card follows the finger
  // exactly instead of lagging by the drag slop.
  void _down(DragDownDetails d) => _startPointer = d.globalPosition;

  void _start(DragStartDetails _) {
    _startOffset = _offset;
    final area = context.findRenderObject();
    final card = _cardKey.currentContext?.findRenderObject();
    _home = area is RenderBox && card is RenderBox && card.hasSize
        ? (card.localToGlobal(Offset.zero, ancestor: area) - _startOffset) & card.size
        : null;
    setState(() => _moving = true);
  }

  void _update(DragUpdateDetails d) {
    var offset = _startOffset + d.globalPosition - _startPointer;
    final area = context.findRenderObject();
    final home = _home;
    if (home != null && area is RenderBox && area.hasSize) {
      final bounds = widget.margin.deflateRect(Offset.zero & area.size);
      offset = Offset(
        _keepInside(offset.dx, home.left, home.right, bounds.left, bounds.right),
        _keepInside(offset.dy, home.top, home.bottom, bounds.top, bounds.bottom),
      );
    }
    setState(() => widget.controller.cardOffsets[widget.id] = offset);
  }

  /// Shift along one axis that keeps [start, end] inside [lo, hi]. A card
  /// bigger than the area may slide until its edges meet the area's.
  static double _keepInside(double shift, double start, double end, double lo, double hi) {
    final a = lo - start;
    final b = hi - end;
    return a <= b ? shift.clamp(a, b) : shift.clamp(b, a);
  }

  void _end() {
    if (_moving) setState(() => _moving = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final o = _offset;
    Widget grab(Widget card) => GestureDetector(
          key: _cardKey,
          onPanDown: _down,
          onPanStart: _start,
          onPanUpdate: _update,
          onPanEnd: (_) => _end(),
          onPanCancel: _end,
          child: AnimatedScale(
            scale: _moving ? 1.03 : 1,
            duration: const Duration(milliseconds: 120),
            child: card,
          ),
        );
    // Move the card itself, not a full-width Center / Align around it.
    final child = w.child;
    final placed = child is Align && child.child != null
        ? Align(
            key: child.key,
            alignment: child.alignment,
            widthFactor: child.widthFactor,
            heightFactor: child.heightFactor,
            child: grab(child.child!),
          )
        : grab(child);

    if (w.left == null && w.top == null && w.right == null && w.bottom == null) {
      return Center(child: Transform.translate(offset: o, child: placed));
    }
    final noX = w.left == null && w.right == null;
    final noY = w.top == null && w.bottom == null;
    return Stack(
      children: [
        Positioned(
          left: noX ? o.dx : (w.left == null ? null : w.left! + o.dx),
          right: w.right == null ? null : w.right! - o.dx,
          top: noY ? o.dy : (w.top == null ? null : w.top! + o.dy),
          bottom: w.bottom == null ? null : w.bottom! - o.dy,
          width: w.width,
          height: w.height,
          child: placed,
        ),
      ],
    );
  }
}

/// Frosted panel matching the HTML `.glass-panel`.
class LabGlassCard extends StatelessWidget {
  const LabGlassCard({
    super.key,
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 14,
    this.borderColor,
    this.color,
    this.shadow = true,
  });

  final LabPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? palette.panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? palette.border),
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}

/// Small uppercase section heading (HTML `uppercase tracking-widest`).
class LabSectionLabel extends StatelessWidget {
  const LabSectionLabel(this.text, {super.key, this.color, this.size = 11, this.icon});

  final String text;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LabStyleScope.of(context).palette.accent;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: size * 1.3, color: c),
          SizedBox(width: size * 0.45),
        ],
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: c,
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Labelled slider for sidebar controls (HTML `<input type="range">`).
class LabSliderControl extends StatelessWidget {
  const LabSliderControl({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueText,
    this.divisions,
    this.scale = 1,
    this.onChangeEnd,
    this.enabled = true,
    this.activeColor,
  });

  final LabPalette palette;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String? valueText;
  final int? divisions;
  final double scale;
  final bool enabled;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (valueText != null)
              Text(
                valueText!,
                style: TextStyle(
                  color: activeColor ?? palette.accent,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4 * scale,
            activeTrackColor: activeColor ?? palette.accent,
            thumbColor: activeColor ?? palette.accent,
            inactiveTrackColor: palette.cardBorder,
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * scale),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8 * scale),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}

/// A row of selectable chips (mode / material / option pickers).
class LabChoiceChips<T> extends StatelessWidget {
  const LabChoiceChips({
    super.key,
    required this.palette,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scale = 1,
    this.enabled = true,
  });

  final LabPalette palette;

  /// value -> label
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final double scale;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6 * scale,
      runSpacing: 6 * scale,
      children: [
        for (final e in options.entries)
          ChoiceChip(
            label: Text(
              e.value,
              style: TextStyle(
                fontSize: 11.5 * scale,
                fontWeight: FontWeight.w700,
                color: e.key == selected ? palette.onAccent : palette.text,
              ),
            ),
            selected: e.key == selected,
            selectedColor: palette.accent,
            backgroundColor: palette.card,
            side: BorderSide(color: palette.cardBorder),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: enabled
                ? (_) {
                    LabStyleScope.of(context).style.click.play();
                    onSelected(e.key);
                  }
                : null,
          ),
      ],
    );
  }
}

/// "Label ........ value" row for sidebar readouts.
class LabInfoRow extends StatelessWidget {
  const LabInfoRow({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    this.valueColor,
    this.scale = 1,
  });

  final LabPalette palette;
  final String label;
  final String value;
  final Color? valueColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: palette.textMuted, fontSize: 12 * scale, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? palette.textStrong,
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark rounded display used for HUD readouts (clocks, meters, timers).
class LabReadout extends StatelessWidget {
  const LabReadout({
    super.key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF4ADE80),
    this.scale = 1,
    this.fontSize = 22,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final double scale;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Scales down instead of overflowing while the canvas resizes.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: _box(LabStyleScope.of(context).palette),
    );
  }

  Widget _box(LabPalette p) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: p.readoutBg,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: p.readoutBorder, width: 2.5 * scale),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: p.readoutIcon, size: fontSize * scale),
            SizedBox(width: 10 * scale),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              color: color,
              fontSize: fontSize * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================= LAB SHELL

/// The common screen used by every Class 7 Science lab:
///
/// * intro curtain with "Enter Lab" (animated, with sound),
/// * collapsible, scrollable left sidebar (30% of the width; drag its right
///   edge to resize it between 20% and half the screen) holding the
///   header (title, language, reset, settings), scenario selector,
///   target output (mission objective + current step), all action buttons,
///   optional activity controls and the footer,
/// * a fixed menu button (top-left) that expands / collapses the sidebar,
///   and a back button (top-right, above everything, also on the curtain)
///   that returns to the home page,
/// * a floating mission card with the dynamic action buttons while the
///   sidebar is collapsed,
/// * the zoomable canvas with tool buttons (labels, lock, pan, reset view,
///   zoom in / out), feedback toast, HUD objective and activity overlays,
/// * the scrollable success popup and the settings dialog.
///
/// Every floating card (popup, settings, mission card, HUD objective and the
/// activity's overlay cards) can be dragged anywhere on screen ([LabMovable]).
///
/// Tones, colours and font come from the activity's [LabStyle] (via the
/// controller), so every lab sounds and looks the way its own file says.
class LabShell extends StatefulWidget {
  const LabShell({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stage,
    this.scenarioNames = const [],
    this.scenarioIndex = 0,
    this.onScenarioChanged,
    this.objective = '',
    this.steps = const [],
    this.currentStep = 1,
    this.instruction,
    this.actions = const [],
    this.sidebarExtra,
    this.sidebarExtraTitle,
    this.overlays = const [],
    this.onEnterLab,
    this.onReset,
    this.showHud = true,
    this.showTools = true,
  });

  final LabController controller;
  final IconData icon;
  final String title;
  final String subtitle;

  /// The scene, usually a [LabStage]. Wrapped in the zoomable viewer.
  final Widget stage;

  /// Localised scenario names (the HTML `<select>` options).
  final List<String> scenarioNames;
  final int scenarioIndex;

  /// Called with the new index. The shell plays the scenario sound.
  final ValueChanged<int>? onScenarioChanged;

  /// Localised mission objective for the current scenario.
  final String objective;

  /// Localised steps of the current scenario.
  final List<LabStep> steps;

  /// 1-based current step (may be steps.length + 1 when finished).
  final int currentStep;

  /// Overrides the current objective text (defaults to the step's action).
  final String? instruction;

  /// Dynamic action buttons for the current state.
  final List<LabAction> actions;

  /// Extra activity controls / readouts shown in the sidebar.
  final Widget? sidebarExtra;
  final String? sidebarExtraTitle;

  /// Positioned widgets drawn above the canvas (not zoomed): readouts,
  /// trays, result panels...
  final List<Widget> overlays;

  /// Called once the curtain has lifted (HTML `enterLab()` / `initThreeJS`).
  final VoidCallback? onEnterLab;

  /// Called on a full reset (HTML `resetApp(false)`) after the shell state
  /// has been restored; the activity resets its scenario / step / scene.
  final VoidCallback? onReset;

  /// Shows the "Current Objective" HUD at the bottom of the canvas while
  /// the sidebar is open.
  final bool showHud;
  final bool showTools;

  @override
  State<LabShell> createState() => _LabShellState();
}

class _LabShellState extends State<LabShell> with TickerProviderStateMixin {
  late final AnimationController _curtain = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
    value: widget.controller.isLabActive ? 1 : 0,
  );
  late final AnimationController _iconPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  /// True while the sidebar's edge is being dragged (no width animation).
  bool _resizing = false;
  double _resizeStartX = 0;
  double _resizeStartWidth = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.attachResetHook(_fullReset);
    // The "Enter Lab" button is built outside the curtain's AnimatedBuilder,
    // so rebuild when the curtain starts or stops moving; otherwise it stays
    // disabled after a full reset.
    _curtain.addStatusListener(_onCurtainStatus);
  }

  void _onCurtainStatus(AnimationStatus _) {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant LabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachResetHook();
      widget.controller.attachResetHook(_fullReset);
    }
  }

  @override
  void dispose() {
    widget.controller.detachResetHook();
    _curtain.dispose();
    _iconPulse.dispose();
    super.dispose();
  }

  void _enterLab() {
    if (_curtain.isAnimating) return;
    widget.controller.style.curtain.play();
    _curtain.forward().whenComplete(() {
      if (!mounted) return;
      _iconPulse.stop();
      widget.controller.markLabActive(true);
      widget.onEnterLab?.call();
    });
  }

  void _fullReset() {
    final c = widget.controller;
    c.style.curtain.play();
    c.resetShellState();
    c.markLabActive(false);
    _iconPulse.repeat(reverse: true);
    _curtain.reverse();
    widget.onReset?.call();
  }

  void _exit() {
    widget.controller.style.click.play();
    Navigator.of(context).maybePop();
  }

  /// Narrowest and widest sidebar for a screen of [width].
  (double, double) _sidebarRange(double width) {
    final min = math.max(180.0, width * 0.2);
    return (min, math.max(min, width * 0.5));
  }

  double _sidebarWidth(double width) {
    final (min, max) = _sidebarRange(width);
    return (width * widget.controller.sidebarFraction).clamp(min, max);
  }

  /// Grip on the sidebar's right edge: drag it to resize the sidebar.
  Widget _resizeHandle(LabPalette p, double width) {
    final c = widget.controller;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragDown: (d) {
          _resizeStartX = d.globalPosition.dx;
          _resizeStartWidth = _sidebarWidth(width);
        },
        onHorizontalDragStart: (_) => setState(() => _resizing = true),
        onHorizontalDragUpdate: (d) => setState(() {
          final (min, max) = _sidebarRange(width);
          final w = _resizeStartWidth + d.globalPosition.dx - _resizeStartX;
          c.sidebarFraction = w.clamp(min, max) / width;
        }),
        onHorizontalDragEnd: (_) => setState(() => _resizing = false),
        onHorizontalDragCancel: () => setState(() => _resizing = false),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 4,
            height: _resizing ? 64 : 40,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: _resizing ? 0.9 : 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  /// Room kept clear of canvas cards: the tool column on the right.
  EdgeInsets _canvasMargin(EdgeInsets pad) =>
      EdgeInsets.fromLTRB(4, 4, widget.showTools ? 56 + pad.right : 4, 4);

  /// Activity overlay cards can be dragged anywhere on the canvas. Full-size
  /// layers (Positioned.fill) stay put.
  Widget _movableOverlay(Widget overlay, int index, EdgeInsets margin) {
    if (overlay is! Positioned) return overlay;
    if (overlay.left == 0 && overlay.top == 0 && overlay.right == 0 && overlay.bottom == 0) {
      return overlay;
    }
    return Positioned.fill(
      key: overlay.key,
      child: LabMovable(
        controller: widget.controller,
        id: 'overlay-$index-${overlay.child.runtimeType}',
        margin: margin,
        left: overlay.left,
        top: overlay.top,
        right: overlay.right,
        bottom: overlay.bottom,
        width: overlay.width,
        height: overlay.height,
        child: overlay.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final p = c.palette;
        // Canvas text (labText) follows the lab's font.
        final font = c.style.font.orAmbient(Theme.of(context).textTheme.bodyMedium);
        LabFont.active = font;
        final size = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final s = context.labScale;
        final sidebarW = _sidebarWidth(size.width);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          },
          child: Theme(
            data: p.theme(font),
            child: LabStyleScope(
              style: c.style,
              palette: p,
              child: Scaffold(
                backgroundColor: p.bg,
                body: Stack(
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: _resizing ? Duration.zero : const Duration(milliseconds: 380),
                          curve: Curves.easeInOutCubic,
                          width: c.isSidebarOpen ? sidebarW : 0,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: sidebarW,
                                    maxWidth: sidebarW,
                                    child: _Sidebar(shell: widget, palette: p, scale: s),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                width: 10,
                                child: _resizeHandle(p, size.width),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildCanvas(context, p, s, pad)),
                      ],
                    ),
                    if (!c.isSidebarOpen && c.isLabActive)
                      Positioned.fill(
                        child: LabMovable(
                          controller: c,
                          id: 'mission',
                          top: 12 + pad.top,
                          left: 76 + pad.left,
                          child: _FloatingMissionCard(shell: widget, palette: p, scale: s),
                        ),
                      ),
                    // Menu button: fixed position, won't slide with the sidebar,
                    // always in front of the sidebar and canvas.
                    Positioned(
                      top: 16 + pad.top,
                      left: 16 + pad.left,
                      child: _fixedButton(
                        p,
                        tooltip: c.t('menu'),
                        icon: c.isSidebarOpen ? Icons.menu_open : Icons.menu,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          c.toggleSidebar();
                        },
                      ),
                    ),
                    if (c.popup != null) _PopupLayer(controller: c, palette: p, scale: s),
                    if (c.settingsOpen) _SettingsLayer(controller: c, palette: p, scale: s),
                    _buildCurtain(context, p, s, pad),
                    // Back button: top-right, above the tool column, in front of
                    // everything (curtain included) so it is always reachable.
                    Positioned(
                      top: 16 + pad.top,
                      right: 8 + pad.right,
                      child: _fixedButton(
                        p,
                        tooltip: c.t('back_home'),
                        icon: Icons.arrow_back_rounded,
                        onPressed: _exit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The menu / back button (48 px tap target).
  Widget _fixedButton(
    LabPalette p, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      color: p.buttonIcon,
      iconSize: 28,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: p.buttonBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.buttonBorder),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    final w = widget;
    final instruction = _currentInstruction(w);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: p.canvasBg),
          LabZoomViewer(controller: c, child: w.stage),
          for (var i = 0; i < w.overlays.length; i++) _movableOverlay(w.overlays[i], i, _canvasMargin(pad)),
          if (w.showHud && c.isSidebarOpen && instruction.isNotEmpty)
            Positioned.fill(
              child: LabMovable(
                controller: c,
                id: 'hud',
                margin: _canvasMargin(pad),
                left: 12,
                right: 60 + pad.right,
                bottom: 8 + pad.bottom,
                child: Center(
                  child: _HudChip(text: instruction, palette: p, scale: s, label: c.t('curr_obj')),
                ),
              ),
            ),
          if (w.showTools)
            Positioned(
              right: 8 + pad.right,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ToolsPanel(controller: c, palette: p, scale: s),
              ),
            ),
          // Kept clear of the floating mission card and the tool column.
          Positioned(
            top: 10 + pad.top,
            left: labOverlayInsets(context, c).left + 4,
            right: labOverlayInsets(context, c).right,
            child: Center(
              child: _ToastView(toast: c.toast, palette: p, scale: s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurtain(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: _curtain,
      builder: (context, child) {
        if (_curtain.value >= 1) return const SizedBox.shrink();
        final dy = Curves.easeInOutCubic.transform(_curtain.value);
        return FractionalTranslation(translation: Offset(0, -dy), child: child);
      },
      child: Material(
        color: p.curtainBg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [p.curtainGlow, p.curtainBg.withValues(alpha: 0)], radius: 0.9),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32 * s, vertical: 24 * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween(begin: 0.55, end: 1.0).animate(_iconPulse),
                            child: Icon(widget.icon, size: 56 * s, color: p.accent),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainText,
                              fontSize: 30 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: p.curtainMuted, fontSize: 15 * s, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 24 * s),
                          FilledButton.icon(
                            onPressed: _curtain.isAnimating ? null : _enterLab,
                            icon: Icon(Icons.play_arrow_rounded, size: 22 * s),
                            label: Text(c.t('enter_lab')),
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: p.onAccent,
                              padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 14 * s),
                              textStyle: TextStyle(fontSize: 17 * s, fontWeight: FontWeight.w800),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Left of the back button, which the shell draws above the curtain.
            Positioned(
              top: 20 + pad.top,
              right: 64 + pad.right,
              child: TextButton.icon(
                onPressed: c.toggleLanguage,
                icon: const Icon(Icons.translate, size: 18),
                label: Text(c.lang.badge, style: const TextStyle(fontWeight: FontWeight.w800)),
                style: TextButton.styleFrom(foregroundColor: p.curtainIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Width of the floating mission card shown while the sidebar is collapsed.
double _missionCardWidth(Size size, double s) => (size.width * 0.36).clamp(200.0, 380.0 * s);

/// Insets (relative to the canvas area) that keep activity overlays clear
/// of the shell's own canvas UI: the tool column on the right and, while
/// the sidebar is collapsed, the menu button + floating mission card on the
/// left. Use `left`/`right` for overlays placed along the top edge, e.g.
/// `Positioned(top: 10, left: i.left, right: i.right, child: Center(...))`.
EdgeInsets labOverlayInsets(BuildContext context, LabController c) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final s = context.labScale;
  final left = c.isSidebarOpen ? 8.0 : 76 + pad.left + _missionCardWidth(size, s) + 8;
  return EdgeInsets.fromLTRB(left, 8 + pad.top, 56 + pad.right, 8 + pad.bottom);
}

String _currentInstruction(LabShell w) {
  if (w.instruction != null) return w.instruction!;
  if (w.steps.isEmpty) return '';
  final i = (w.currentStep - 1).clamp(0, w.steps.length - 1);
  return w.steps[i].action;
}

// ============================================================== SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.shell, required this.palette, required this.scale});

  final LabShell shell;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = shell.controller;
    final p = palette;
    final s = scale;
    final f = s * c.fontScale;
    final pad = MediaQuery.paddingOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(right: BorderSide(color: p.border)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(4, 0))],
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(12 * s + pad.left, 12 + pad.top, 12 * s, 8 * s),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _header(context, p, s),
                SizedBox(height: 12 * s),
                if (shell.scenarioNames.length > 1) ...[_scenarioSelector(p, s, f), SizedBox(height: 12 * s)],
                _targetOutput(p, s, f),
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(c.t('actions'), size: 10.5 * s, icon: Icons.touch_app),
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s),
                ],
                if (shell.sidebarExtra != null) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(shell.sidebarExtraTitle ?? c.t('controls'), size: 10.5 * s, icon: Icons.tune),
                  SizedBox(height: 8 * s),
                  shell.sidebarExtra!,
                ],
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10 * s + pad.left, 10 * s, 10 * s, 10 * s + pad.bottom),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: Text(
                  c.t('footer'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text.withValues(alpha: 0.85),
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, LabPalette p, double s) {
    final c = shell.controller;
    Widget headerBtn(IconData icon, String tip, VoidCallback onTap, {String? text}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17 * s, color: p.textStrong),
                if (text != null) ...[
                  SizedBox(width: 4 * s),
                  Text(
                    text,
                    style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12 * s),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Leaves room for the fixed menu button at top-left.
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Container(
                  width: 34 * s,
                  height: 34 * s,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(shell.icon, color: p.accent, size: 20 * s),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shell.title,
                        style: TextStyle(
                          color: p.textStrong,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5 * s,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        shell.subtitle,
                        style: TextStyle(color: p.textMuted, fontSize: 10 * s, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Wrap(
          spacing: 6 * s,
          runSpacing: 6 * s,
          alignment: WrapAlignment.center,
          children: [
            headerBtn(Icons.translate, c.t('toggle_language'), c.toggleLanguage, text: c.lang.badge),
            headerBtn(Icons.restart_alt, c.t('reset_lab'), () {
              c.style.click.play();
              c.requestFullReset();
            }),
            headerBtn(Icons.settings, c.t('settings'), c.toggleSettings),
          ],
        ),
      ],
    );
  }

  Widget _scenarioSelector(LabPalette p, double s, double f) {
    final c = shell.controller;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c.t('select_scenario').toUpperCase(),
            style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          SizedBox(height: 6 * s),
          for (var i = 0; i < shell.scenarioNames.length; i++) ...[
            if (i > 0) SizedBox(height: 6 * s),
            _scenarioTile(p, s, f, i),
          ],
        ],
      ),
    );
  }

  Widget _scenarioTile(LabPalette p, double s, double f, int i) {
    final c = shell.controller;
    final selected = i == shell.scenarioIndex;
    final done = c.completedScenarios.contains(i);
    return Material(
      color: selected ? p.accent.withValues(alpha: 0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: selected || shell.onScenarioChanged == null
            ? null
            : () {
                c.style.scenario.play();
                shell.onScenarioChanged!(i);
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.accent : p.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : (selected ? Icons.menu_book : Icons.radio_button_unchecked),
                size: 16 * s,
                color: done ? p.success : (selected ? p.accent : p.textMuted),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  shell.scenarioNames[i],
                  style: TextStyle(
                    color: selected ? p.textStrong : p.text,
                    fontSize: 11.5 * f,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetOutput(LabPalette p, double s, double f) {
    final c = shell.controller;
    final steps = shell.steps;
    final hasSteps = steps.isNotEmpty;
    final cur = shell.currentStep;
    final idx = hasSteps ? (cur - 1).clamp(0, steps.length - 1) : 0;
    final step = hasSteps ? steps[idx] : null;
    final instruction = _currentInstruction(shell);

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabSectionLabel(c.t('target_output'), size: 10.5 * s, icon: Icons.track_changes),
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              c.t('mission_obj'),
              style: TextStyle(color: p.textMuted, fontSize: 10 * f, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3 * s),
            Text(
              shell.objective,
              style: TextStyle(color: p.text, fontSize: 12.5 * f, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ],
          if (hasSteps) ...[
            SizedBox(height: 10 * s),
            Row(
              children: [
                Text(
                  '${c.t('step')} ${cur.clamp(1, steps.length)} ${c.t('of')} ${steps.length}',
                  style: TextStyle(color: p.textStrong, fontSize: 11 * f, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Wrap(
                    spacing: 4 * s,
                    runSpacing: 4 * s,
                    alignment: WrapAlignment.end,
                    children: [
                      for (var i = 1; i <= steps.length; i++)
                        Container(
                          width: 16 * s,
                          height: 16 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < cur
                                ? p.info.withValues(alpha: 0.25)
                                : (i == cur ? p.accent : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(color: i < cur ? p.info : (i == cur ? p.accent : p.cardBorder)),
                          ),
                          child: i < cur
                              ? Icon(Icons.check, size: 10 * s, color: p.info)
                              : Text(
                                  '$i',
                                  style: TextStyle(
                                    fontSize: 8.5 * s,
                                    fontWeight: FontWeight.w800,
                                    color: i == cur ? p.onAccent : p.textMuted,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (instruction.isNotEmpty) ...[
            SizedBox(height: 10 * s),
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.accent.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 14 * s, color: p.accent),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          c.t('curr_obj').toUpperCase(),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 9.5 * f,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step != null && step.concept.isNotEmpty && shell.instruction == null) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      '${c.t('concept_focus')} ${step.concept}',
                      style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w700),
                    ),
                  ],
                  SizedBox(height: 4 * s),
                  Text(
                    instruction,
                    style: TextStyle(color: p.textStrong, fontSize: 12.5 * f, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================= FLOATING MISSION CARD

class _FloatingMissionCard extends StatefulWidget {
  const _FloatingMissionCard({required this.shell, required this.palette, required this.scale});

  final LabShell shell;
  final LabPalette palette;
  final double scale;

  @override
  State<_FloatingMissionCard> createState() => _FloatingMissionCardState();
}

class _FloatingMissionCardState extends State<_FloatingMissionCard> {
  bool _minimized = false;

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    final c = shell.controller;
    final p = widget.palette;
    final s = widget.scale;
    final size = MediaQuery.sizeOf(context);
    final width = _missionCardWidth(size, s);
    final instruction = _currentInstruction(shell);
    final steps = shell.steps;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: size.height - 24),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(10 * s),
        borderColor: p.accent.withValues(alpha: 0.6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, size: 15 * s, color: p.accent),
                  SizedBox(width: 5 * s),
                  Expanded(
                    child: Text(
                      c.t('mission_obj').toUpperCase(),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      c.style.click.play();
                      setState(() => _minimized = !_minimized);
                    },
                    child: Tooltip(
                      message: _minimized ? c.t('expand') : c.t('minimize'),
                      child: Icon(_minimized ? Icons.expand_more : Icons.expand_less, size: 20 * s, color: p.textMuted),
                    ),
                  ),
                ],
              ),
              if (!_minimized) ...[
                if (shell.objective.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Text(
                    shell.objective,
                    style: TextStyle(color: p.text, fontSize: 11.5 * s, height: 1.35, fontWeight: FontWeight.w500),
                  ),
                ],
                if (instruction.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: p.accent.withValues(alpha: 0.5)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (steps.isNotEmpty)
                            TextSpan(
                              text: '${c.t('step')} ${shell.currentStep.clamp(1, steps.length)}/${steps.length} • ',
                              style: TextStyle(color: p.accent, fontWeight: FontWeight.w800),
                            ),
                          TextSpan(text: instruction),
                        ],
                      ),
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 11.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s, dense: true),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================ CANVAS UI

class _HudChip extends StatelessWidget {
  const _HudChip({required this.text, required this.palette, required this.scale, required this.label});

  final String text;
  final String label;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520 * s),
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        borderColor: palette.accent.withValues(alpha: 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, size: 12 * s, color: palette.accent),
                SizedBox(width: 4 * s),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 9 * s,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2 * s),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textStrong, fontWeight: FontWeight.w700, fontSize: 11 * s, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale.clamp(0.85, 1.25);
    Widget tool(IconData icon, String tip, VoidCallback onTap, {bool active = false}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 34 * s,
            height: 34 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: active ? p.accent.withValues(alpha: 0.18) : Colors.transparent,
            ),
            child: Icon(icon, size: 19 * s, color: active ? p.accent : p.textMuted),
          ),
        ),
      );
    }

    final divider = Container(
      width: 24 * s,
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 3 * s),
      color: p.cardBorder,
    );

    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.all(4 * s),
      radius: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tool(c.showLabels ? Icons.label : Icons.label_off, c.t('tool_labels'), c.toggleLabels, active: c.showLabels),
          divider,
          tool(c.camLocked ? Icons.lock : Icons.lock_open, c.t('tool_lock'), c.toggleCamLock, active: c.camLocked),
          tool(Icons.pan_tool_alt, c.t('tool_pan'), c.togglePanMode, active: c.panMode),
          tool(Icons.center_focus_strong, c.t('tool_reset_view'), c.resetView),
          tool(Icons.zoom_in, c.t('tool_zoom_in'), c.zoomIn),
          tool(Icons.zoom_out, c.t('tool_zoom_out'), c.zoomOut),
        ],
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.toast, required this.palette, required this.scale});

  final LabToast? toast;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = toast;
    final s = scale;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: t == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(t.id),
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                  color: t.isError ? palette.danger : palette.toastBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.isError ? Icons.error : Icons.info,
                      size: 16 * s,
                      color: t.isError ? palette.onDanger : palette.toastText,
                    ),
                    SizedBox(width: 6 * s),
                    Flexible(
                      child: Text(
                        t.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.isError ? palette.onDanger : palette.toastText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5 * s,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ==================================================================== POPUP

class _PopupLayer extends StatelessWidget {
  const _PopupLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final builder = c.popup;
    if (builder == null) return const SizedBox.shrink();
    final content = builder();
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final accent = content.accent ?? p.accent;
    final width = (size.width * 0.6).clamp(260.0, 470.0 * s);

    return Positioned.fill(
      child: LabMovable(
        controller: c,
        id: 'popup',
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(scale: v, child: child),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: size.height * 0.86),
              decoration: BoxDecoration(
                color: p.popupBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (drag anywhere on the card to move it).
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                    decoration: BoxDecoration(
                      color: p.popupHeader,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Icon(content.icon, color: accent, size: 18 * s),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            content.title,
                            style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 14 * s),
                          ),
                        ),
                        Icon(Icons.drag_indicator, size: 18 * s, color: p.textMuted),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: c.t('close'),
                          onPressed: () => c.hidePopup(),
                          icon: Icon(Icons.close, size: 18 * s, color: p.text),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(14 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (content.heading != null) ...[
                            Container(
                              padding: EdgeInsets.only(bottom: 4 * s),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: p.cardBorder)),
                              ),
                              child: Text(
                                content.heading!.toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5 * s,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: 8 * s),
                          ],
                          if (content.body != null)
                            Text(
                              content.body!,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13 * s * c.fontScale.clamp(0.9, 1.4),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          if (content.extra != null) ...[SizedBox(height: 10 * s), content.extra!],
                          if (content.actions.isNotEmpty) ...[
                            SizedBox(height: 14 * s),
                            LabActionList(actions: content.actions, scale: s),
                          ],
                        ],
                      ),
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
}

// ================================================================= SETTINGS

class _SettingsLayer extends StatelessWidget {
  const _SettingsLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final label = TextStyle(color: p.textStrong, fontSize: 13 * s, fontWeight: FontWeight.w600);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: c.toggleSettings,
              child: const ColoredBox(color: Color(0x80000000)),
            ),
          ),
          Positioned.fill(
            child: LabMovable(
              controller: c,
              id: 'settings',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: (size.width * 0.5).clamp(260.0, 360.0 * s),
                  constraints: BoxConstraints(maxHeight: size.height * 0.88),
                  decoration: BoxDecoration(
                    color: p.dialogBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(18 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.t('settings'),
                                style: TextStyle(color: p.textStrong, fontSize: 17 * s, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: c.toggleSettings,
                              tooltip: c.t('close'),
                              icon: Icon(Icons.close, color: p.text),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('theme'), style: label)),
                            FilledButton.tonalIcon(
                              onPressed: c.toggleTheme,
                              icon: Icon(c.isDark ? Icons.dark_mode : Icons.light_mode, size: 18 * s),
                              label: Text(c.isDark ? c.t('light_mode') : c.t('dark_mode')),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('font_size'), style: label)),
                            Text(
                              '${c.fontSize.round()}px',
                              style: TextStyle(color: p.textMuted, fontSize: 12 * s),
                            ),
                          ],
                        ),
                        Slider(
                          value: c.fontSize,
                          min: c.style.font.minSize,
                          max: c.style.font.maxSize,
                          divisions: (c.style.font.maxSize - c.style.font.minSize).round(),
                          onChanged: c.setFontSize,
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
    );
  }
}
