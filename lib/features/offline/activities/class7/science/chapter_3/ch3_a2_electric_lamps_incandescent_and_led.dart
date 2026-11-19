// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 3 • Activity 2
/// Electric Lamps: Incandescent and LED.
///
/// Native Flutter port of `Cl7S-Ch3-A2-Electric_Lamps__Incandescent_and_LED.html`.
/// Scenario 1: tap the five key parts of an incandescent bulb and an LED,
/// then switch on an incandescent and an LED torch. Scenario 2: wire a cell
/// holder to a lamp holder (tap two terminals per wire) until the lamp glows.
class Ch3A2ElectricLampsIncandescentAndLEDPage extends StatefulWidget {
  const Ch3A2ElectricLampsIncandescentAndLEDPage({super.key});

  @override
  State<Ch3A2ElectricLampsIncandescentAndLEDPage> createState() =>
      _Ch3A2ElectricLampsIncandescentAndLEDPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, switchTap 2585, whoosh
/// 1492.
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
  pop('pop.mp3'),
  drop('drop.mp3'),
  switchTap('switch.mp3'),
  whoosh('whoosh.mp3');

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
      await player.play(
        AssetSource('audio/class7/${sound.file}'),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
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

/// Brand and Tailwind colours used by this lab.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
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
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static LabPalette of(bool isDark) => isDark ? dark : light;
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 24,
);

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

class _Ch3A2ElectricLampsIncandescentAndLEDPageState
    extends State<Ch3A2ElectricLampsIncandescentAndLEDPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _LampScene _scene = _LampScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _frame.value = _scene.time;
    })..start();
    _scene.reset();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ============================================================ LOGIC

  /// HTML `resetScene()`: rebuilds the objects of the current scenario.
  void _buildScenario() {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _scene.reset();
    if (_scene.scenario == 0) {
      _scene.setHud('st_obs_mission', 'act_obs_mission', _Tone.blue, {'n': _partIds.length});
    } else {
      _scene.setHud('st_wiring_mission', 'act_wiring_start', _Tone.yellow);
    }
    _lab.resetView(sound: false);
  }

  /// HTML `enterLab()` -> `loadScenario(current)`.
  void _onEnterLab() => setState(_buildScenario);

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _buildScenario();
    });
  }

  /// HTML `fullAppReset()`: back to scenario 1 behind the curtain.
  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _buildScenario();
      _scene.setHud('st_ready', 'act_ready', _Tone.yellow);
    });
  }

  /// HTML `onPointerDown()` raycasting.
  void _onTap(Offset p) {
    if (!_lab.isLabActive) return;
    final s = _scene;
    if (s.scenario == 1 && s.circuitSolved) return;
    if (s.scenario == 0) {
      if (s.torches) {
        for (var i = 0; i < 2; i++) {
          if (_G.switchRect(i).contains(p)) return _toggleTorch(i);
        }
      } else if (!s.partsSolved) {
        for (final e in _G.partRects.entries) {
          if (e.value.contains(p)) return _partClick(e.key);
        }
      }
    } else {
      String? best;
      var bestD = _G.terminalHitR;
      for (final id in _terminalIds) {
        final d = (_G.terminal(id) - p).distance;
        if (d < bestD) {
          bestD = d;
          best = id;
        }
      }
      if (best != null) _terminalClick(best);
    }
  }

  /// HTML `handlePartClick()`.
  void _partClick(String id) {
    final s = _scene;
    setState(() {
      s.flashAt[id] = s.time;
      if (!s.found.contains(id)) {
        s.found.add(id);
        s.foundAt[id] = s.time;
        final remaining = _partIds.length - s.found.length;
        if (remaining == 0) {
          s.partsSolved = true;
          _Audio.play(_Sound.success);
          s.setHud('st_parts_identified', 'act_all_found', _Tone.green);
          _lab.after(const Duration(milliseconds: 2000), _transitionToTorches);
        } else {
          _Audio.play(_Sound.correct);
          s.setHud('st_obs_log', 'act_found', _Tone.green, {'name': '@p_$id', 'rem': remaining});
        }
      } else {
        _Audio.play(_Sound.click);
        s.setHud('st_already', 'act_already', _Tone.amber, {'name': '@p_$id'});
      }
    });
  }

  /// HTML `transitionToTorches()`.
  void _transitionToTorches() {
    if (!mounted || _scene.scenario != 0) return;
    setState(() {
      _scene
        ..torches = true
        ..torchesAt = _scene.time
        ..torchInteractions = 0;
      _scene.setHud('st_testing', 'act_testing', _Tone.yellow);
    });
    _Audio.play(_Sound.whoosh);
  }

  /// HTML `handleTorchClick()`.
  void _toggleTorch(int i) {
    final s = _scene;
    _Audio.play(_Sound.switchTap);
    setState(() {
      s.torchOn[i] = !s.torchOn[i];
      s.toggledAt[i] = s.time;
      s.torchInteractions++;
    });
    if (s.torchInteractions == 1) {
      _lab.after(const Duration(milliseconds: 5000), _showObservation);
    }
  }

  /// HTML `handleTerminalClick()`.
  void _terminalClick(String id) {
    final s = _scene;
    _Audio.play(_Sound.click);
    setState(() {
      if (s.selected == null) {
        s.selected = id;
        s.selectedAt = s.time;
        s.setHud('st_wiring_started', 'act_wiring_sec', _Tone.amber, {'name': '@t_$id'});
      } else if (s.selected == id) {
        s.selected = null;
        s.setHud('st_action_required', 'act_action_required', _Tone.yellow);
      } else {
        _createWire(s.selected!, id);
        s.selected = null;
        _autoValidate();
      }
    });
  }

  /// HTML `createWire()`.
  void _createWire(String a, String b) {
    _Audio.play(_Sound.drop);
    _scene.wires.add(_Wire(a, b, _scene.time));
    if (_scene.wiringStep < 2) _scene.wiringStep = 2;
  }

  /// HTML `findConnections()`: terminals reachable through wires.
  Set<String> _connections(String start) {
    final visited = <String>{};
    final queue = [start];
    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      if (!visited.add(cur)) continue;
      for (final w in _scene.wires) {
        if (w.a == cur && !visited.contains(w.b)) queue.add(w.b);
        if (w.b == cur && !visited.contains(w.a)) queue.add(w.a);
      }
    }
    return visited;
  }

  /// HTML `autoValidate()`.
  void _autoValidate() {
    final pos = _connections('bat_pos');
    final neg = _connections('bat_neg');
    if (pos.contains('bat_neg')) return _triggerError('act_short');
    final t1 = pos.contains('bulb_term1') || neg.contains('bulb_term1');
    final t2 = pos.contains('bulb_term2') || neg.contains('bulb_term2');
    if (t1 && t2) {
      if ((pos.contains('bulb_term1') && neg.contains('bulb_term2')) ||
          (pos.contains('bulb_term2') && neg.contains('bulb_term1'))) {
        _triggerSuccess();
      } else {
        _triggerError('act_same_side');
      }
    } else {
      _scene.wiringError = false;
      _scene.setHud('st_incomplete', 'act_incomplete', _Tone.orange);
    }
  }

  /// HTML `triggerSuccessCircuit()`.
  void _triggerSuccess() {
    final s = _scene;
    if (s.circuitSolved) return;
    s
      ..circuitSolved = true
      ..solvedAt = s.time
      ..wiringError = false
      ..wiringStep = 3;
    _Audio.play(_Sound.success);
    s.setHud('st_success', 'act_success', _Tone.green);
    _lab.after(const Duration(milliseconds: 4000), _showObservation);
  }

  /// HTML `triggerError()`.
  void _triggerError(String msg) {
    _Audio.play(_Sound.wrong);
    _scene.wiringError = true;
    _scene.setHud('st_error', msg, _Tone.red);
  }

  /// Clears every wire so a short circuit / wrong wiring can be undone
  /// (the HTML could only do this by reloading the scenario).
  void _resetWires() {
    setState(() {
      _scene.wires.clear();
      _scene
        ..selected = null
        ..wiringError = false
        ..wiringStep = 1;
      _scene.setHud('st_wiring_mission', 'act_wiring_start', _Tone.yellow);
    });
    _lab.showToast(_t('msg_wires_reset'), sound: false);
    _Audio.play(_Sound.pop);
  }

  /// HTML `showObservationPopup()`.
  void _showObservation() {
    if (!mounted) return;
    final n = _scene.scenario + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => _t('obs_log'),
      heading: () => _t('obs_title_$n'),
      body: () => _t('obs_text_$n'),
    );
  }

  /// Resolves a HUD template (HTML `renderHUD()` / `getDynamicText()`).
  String _hudText(String key, Map<String, Object> params) {
    final values = <String, Object>{
      for (final e in params.entries)
        e.key: e.value is String && (e.value as String).startsWith('@')
            ? _t((e.value as String).substring(1))
            : e.value,
    };
    return labFormat(_t(key), values);
  }

  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == 0 && s.torches) {
      return [
        for (var i = 0; i < 2; i++)
          LabAction(
            label: labFormat(_t(s.torchOn[i] ? 'btn_switch_off' : 'btn_switch_on'),
                {'name': _t(i == 0 ? 'tt_inc_torch' : 'tt_led_torch')}),
            icon: s.torchOn[i] ? Icons.flashlight_off : Icons.flashlight_on,
            color: i == 0 ? _Colors.red600 : _Colors.blue600,
            foreground: Colors.white,
            highlight: s.torchInteractions == 0,
            silent: true,
            onTap: () => _toggleTorch(i),
          ),
      ];
    }
    if (s.scenario == 1) {
      return [
        LabAction(
          label: _t('btn_reset_wires'),
          icon: Icons.link_off,
          color: s.wiringError ? _Colors.red600 : _Colors.slate600,
          foreground: Colors.white,
          enabled: s.wires.isNotEmpty && !s.circuitSolved,
          highlight: s.wiringError,
          silent: true,
          onTap: _resetWires,
        ),
      ];
    }
    return const [];
  }

  // =============================================================== UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.bolt,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          actions: _actions(),
          sidebarExtraTitle: _scene.scenario == 0
              ? (_scene.torches ? _t('torch_switches') : _t('parts_found'))
              : _t('circuit_status'),
          sidebarExtra: _scene.scenario == 0 ? _partsPanel(p, s) : _circuitPanel(p, s),
          onEnterLab: _onEnterLab,
          onReset: _fullReset,
          showHud: false,
          overlays: [_hudOverlay(context, p, s)],
          stage: LabStage(
            designSize: _design,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _onTap(d.localPosition),
              child: CustomPaint(
                size: _design,
                painter: _LampPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _panel(LabPalette p, double s, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _checkRow(LabPalette p, double f, String text, bool done, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * f),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15 * f,
            color: done ? (color ?? _Colors.green) : p.textMuted,
          ),
          SizedBox(width: 6 * f),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: done ? p.textStrong : p.textMuted,
                fontSize: 12 * f,
                fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Scenario 1 readout: identified parts, then the torch switch states.
  Widget _partsPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final sc = _scene;
    if (sc.torches) {
      return _panel(p, s, [
        for (var i = 0; i < 2; i++)
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t(i == 0 ? 'tt_inc_torch' : 'tt_led_torch'),
            value: _t(sc.torchOn[i] ? 'state_on' : 'state_off'),
            valueColor: sc.torchOn[i] ? _Colors.green : p.textMuted,
          ),
        Divider(color: p.cardBorder, height: 14 * s),
        for (final id in _partIds) _checkRow(p, f, _t('p_$id'), true),
      ]);
    }
    return _panel(p, s, [
      LabInfoRow(
        palette: p,
        scale: f,
        label: _t('parts_found'),
        value: '${sc.found.length} / ${_partIds.length}',
        valueColor: sc.partsSolved ? _Colors.green : _Colors.zslYellow,
      ),
      Divider(color: p.cardBorder, height: 12 * s),
      for (final id in _partIds) _checkRow(p, f, _t('p_$id'), sc.found.contains(id)),
    ]);
  }

  /// Scenario 2 readout: selected terminal, wires and lamp state.
  Widget _circuitPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final sc = _scene;
    return _panel(p, s, [
      LabInfoRow(
        palette: p,
        scale: f,
        label: _t('selected_terminal'),
        value: sc.selected == null ? _t('none') : _t('t_${sc.selected}'),
        valueColor: sc.selected == null ? p.textMuted : _Colors.zslYellow,
      ),
      LabInfoRow(
        palette: p,
        scale: f,
        label: _t('lamp'),
        value: _t(sc.circuitSolved ? 'lamp_glowing' : 'lamp_off'),
        valueColor: sc.circuitSolved ? _Colors.green : p.textMuted,
      ),
      Divider(color: p.cardBorder, height: 12 * s),
      Text(
        '${_t('wires_connected')}: ${sc.wires.length}',
        style: TextStyle(color: p.textStrong, fontSize: 12 * f, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 4 * s),
      if (sc.wires.isEmpty)
        Text(_t('no_wires'), style: TextStyle(color: p.textMuted, fontSize: 11.5 * f))
      else
        for (final w in sc.wires)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2 * f),
            child: Row(
              children: [
                Icon(Icons.cable, size: 14 * f, color: const Color(0xFF00E5FF)),
                SizedBox(width: 6 * f),
                Expanded(
                  child: Text(
                    '${_t('t_${w.a}')}  ↔  ${_t('t_${w.b}')}',
                    style: TextStyle(color: p.text, fontSize: 11.5 * f, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
    ]);
  }

  static Color _toneColor(_Tone tone, bool dark) => switch (tone) {
        _Tone.yellow => _Colors.zslYellow,
        _Tone.blue => dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
        _Tone.green => dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
        _Tone.amber => dark ? const Color(0xFFFACC15) : const Color(0xFFCA8A04),
        _Tone.red => dark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
        _Tone.orange => dark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
      };

  /// The HTML bottom `#hud-panel` (status line + action, pop animation).
  Widget _hudOverlay(BuildContext context, LabPalette p, double s) {
    final inset = labOverlayInsets(context, _lab);
    final hud = _scene.hud;
    final color = _toneColor(hud.tone, p.isDark);
    final icon = switch (hud.tone) {
      _Tone.green => Icons.check_circle,
      _Tone.red => Icons.warning_rounded,
      _ => Icons.info,
    };
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: inset.bottom,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(hud.id),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, v, child) {
              final scale = v < 0.5 ? 0.95 + 0.2 * v : 1.05 - 0.1 * (v - 0.5);
              return Opacity(
                opacity: (0.8 + 0.4 * v).clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 540 * s),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
                decoration: BoxDecoration(
                  color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.circular(14 * s),
                  border: Border.all(
                    color: p.isDark ? _Colors.slate600 : _Colors.slate300,
                    width: 1.5,
                  ),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14 * s, color: color),
                        SizedBox(width: 5 * s),
                        Flexible(
                          child: Text(
                            _t(hud.status).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 10.5 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: _lab.lang == LabLang.hi ? 0 : 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      _hudText(hud.action, hud.params),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 12.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================ STRINGS
//
// Copied from the HTML `T` dictionary, `getDynamicText()` templates and the
// `scenarios` object (Telugu dropped). Strings the HTML hard-coded or only
// had in English are translated here as well.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Electric Lamps Incandescent and LED',
    'app_subtitle': 'Class 7 • Electricity: Circuits and their Components',
    'scen_1': 'Observing Electric Lamps',
    'scen_2': 'Making a Lamp Glow',
    'desc_1':
        'Let us examine the internal components of two types of electric lamps: the Incandescent Bulb and the Light Emitting Diode (LED).',
    'desc_2':
        'An electrical circuit provides a complete path for electricity to flow. We use an electric cell inside a holder and wires to make an incandescent lamp glow.',
    // Observation popup.
    'obs_log': 'Observation Log',
    'obs_title_1': 'What we observed',
    'obs_title_2': 'Circuit Analysis',
    'obs_text_1':
        'An incandescent bulb uses a thin filament to produce light and has two non-polar base terminals (Tip and Case). An LED lacks a filament, using a semiconductor instead, and requires strict adherence to polarity (+ Long and - Short legs) to function.\n\nMany modern torches use LEDs instead of incandescent bulbs.',
    'obs_text_2':
        'A complete electrical circuit requires a continuous conductive path. The current flows from the positive terminal of the power source, through the connecting wires, into the lamp\'s filament, and back to the negative terminal.',
    // HUD status lines.
    'st_ready': 'SYSTEM READY',
    'st_obs_mission': 'OBSERVATION MISSION',
    'st_obs_log': 'OBSERVATION LOG',
    'st_wiring_mission': 'WIRING MISSION',
    'st_testing': 'TESTING PHASE',
    'st_parts_identified': 'PARTS IDENTIFIED',
    'st_already': 'ALREADY FOUND',
    'st_wiring_started': 'WIRING STARTED',
    'st_action_required': 'ACTION REQUIRED',
    'st_error': 'ERROR DETECTED',
    'st_incomplete': 'CIRCUIT INCOMPLETE',
    'st_success': 'SUCCESS!',
    // HUD messages.
    'act_ready': 'Select a scenario to begin.',
    'act_obs_mission': 'Find and click {n} key components on the lamps.',
    'act_found': 'Found {name}! {rem} left to find.',
    'act_already': '{name} was already observed.',
    'act_all_found': 'All parts found!',
    'act_testing':
        'Many torches in use today have a Light Emitting Diode (LED) lamp, instead of an incandescent lamp. Click the switches to test them.',
    'act_wiring_start': 'Click a terminal on the battery holder to start.',
    'act_wiring_sec': 'Now click a second terminal to connect to {name}.',
    'act_action_required': 'Click a terminal on the battery or lamp to start wiring.',
    'act_short': 'SHORT CIRCUIT! You connected the battery terminals directly to each other.',
    'act_same_side': 'Both lamp terminals are connected to the SAME side of the battery!',
    'act_incomplete': 'The path is broken. Connect remaining terminals.',
    'act_success': 'The circuit is closed. The lamp glows!',
    // Lamp parts (scenario 1).
    'p_filament': 'Incandescent Filament',
    'p_case': 'Incandescent Screw Case',
    'p_tip': 'Incandescent Base Tip',
    'p_led_long': 'LED Longer Wire (+)',
    'p_led_short': 'LED Shorter Wire (-)',
    // Torch part labels.
    'tl_glass': 'Glass bulb',
    'tl_supports': 'Thick wire supports',
    'tl_filament': 'Filament (thin wire)',
    'tl_case': 'Metal case (Negative terminal)',
    'tl_tip': 'Metal tip (Positive terminal)',
    'tl_led': 'LED lamp',
    'tl_board': 'Circuit board (No filament)',
    'tl_terminals': 'Two terminals (+ Positive, - Negative)',
    // Main titles.
    'tt_inc_lamp': 'Incandescent Lamp',
    'tt_led_lamp': 'LED Lamp',
    'tt_inc_torch': 'Incandescent Lamp Torch',
    'tt_led_torch': 'LED Lamp Torch',
    // Terminals (scenario 2).
    't_bat_pos': 'Battery (+)',
    't_bat_neg': 'Battery (-)',
    't_bulb_term1': 'Lamp Screw 1',
    't_bulb_term2': 'Lamp Screw 2',
    // Sidebar readouts and buttons (not in the HTML).
    'parts_found': 'Parts Found',
    'torch_switches': 'Torch Switches',
    'circuit_status': 'Circuit Status',
    'state_on': 'ON',
    'state_off': 'OFF',
    'btn_switch_on': 'Switch ON: {name}',
    'btn_switch_off': 'Switch OFF: {name}',
    'btn_reset_wires': 'Reset Wires',
    'selected_terminal': 'Selected terminal',
    'none': 'None',
    'wires_connected': 'Wires connected',
    'no_wires': 'No wires connected yet.',
    'lamp': 'Lamp',
    'lamp_glowing': 'Glowing',
    'lamp_off': 'Not glowing',
    'msg_wires_reset': 'Wires removed. Start wiring again.',
  },
  'hi': {
    'app_title': 'विद्युत लैंप: इनकैंडेसेंट और एलईडी',
    'app_subtitle': 'कक्षा 7 • विद्युत: परिपथ और उनके घटक',
    'scen_1': 'विद्युत लैंप का अवलोकन',
    'scen_2': 'लैंप को जलाना',
    'desc_1':
        'आइए दो प्रकार के विद्युत लैंपों के आंतरिक घटकों की जांच करें: इनकैंडेसेंट बल्ब और प्रकाश उत्सर्जक डायोड (एलईडी)।',
    'desc_2':
        'एक विद्युत परिपथ बिजली के प्रवाह के लिए एक संपूर्ण मार्ग प्रदान करता है। हम इनकैंडेसेंट लैंप को जलाने के लिए एक होल्डर के अंदर एक विद्युत सेल और तारों का उपयोग करते हैं।',
    'obs_log': 'अवलोकन लॉग',
    'obs_title_1': 'हमने क्या देखा',
    'obs_title_2': 'परिपथ विश्लेषण',
    'obs_text_1':
        'एक इनकैंडेसेंट बल्ब प्रकाश उत्पन्न करने के लिए एक पतले फिलामेंट का उपयोग करता है और इसमें दो गैर-ध्रुवीय आधार टर्मिनल (नोक और आवरण) होते हैं। एलईडी में फिलामेंट नहीं होता, इसके बजाय सेमीकंडक्टर का उपयोग होता है, और काम करने के लिए ध्रुवता (+ लंबे और - छोटे पैर) का कड़ाई से पालन करना आवश्यक है।\n\nकई आधुनिक टॉर्चों में इनकैंडेसेंट बल्बों के बजाय एलईडी का उपयोग किया जाता है।',
    'obs_text_2':
        'एक पूर्ण विद्युत परिपथ के लिए एक निरंतर प्रवाहकीय मार्ग की आवश्यकता होती है। करंट शक्ति स्रोत के धनात्मक टर्मिनल से प्रवाहित होता है, जो तारों से होते हुए लैंप के फिलामेंट में जाता है, और वापस ऋणात्मक टर्मिनल में आता है।',
    'st_ready': 'सिस्टम तैयार',
    'st_obs_mission': 'अवलोकन मिशन',
    'st_obs_log': 'अवलोकन लॉग',
    'st_wiring_mission': 'वायरिंग मिशन',
    'st_testing': 'परीक्षण चरण',
    'st_parts_identified': 'भागों की पहचान की गई',
    'st_already': 'पहले ही मिल चुका है',
    'st_wiring_started': 'वायरिंग शुरू हुई',
    'st_action_required': 'कार्रवाई आवश्यक है',
    'st_error': 'त्रुटि पाई गई',
    'st_incomplete': 'परिपथ अपूर्ण है',
    'st_success': 'सफलता!',
    'act_ready': 'शुरू करने के लिए एक परिदृश्य चुनें।',
    'act_obs_mission': 'लैंप पर {n} प्रमुख घटकों को ढूंढें और क्लिक करें।',
    'act_found': '{name} मिल गया! {rem} खोजना बाकी है।',
    'act_already': '{name} पहले ही देखा जा चुका है।',
    'act_all_found': 'सभी भाग मिल गए!',
    'act_testing':
        'आजकल उपयोग होने वाले कई टॉर्चों में इनकैंडेसेंट लैंप के बजाय लाइट एमिटिंग डायोड (एलईडी) लैंप होता है। उनका परीक्षण करने के लिए स्विच पर क्लिक करें।',
    'act_wiring_start': 'शुरू करने के लिए बैटरी होल्डर पर एक टर्मिनल पर क्लिक करें।',
    'act_wiring_sec': 'अब {name} से जुड़ने के लिए दूसरे टर्मिनल पर क्लिक करें।',
    'act_action_required': 'वायरिंग शुरू करने के लिए बैटरी या लैंप के किसी टर्मिनल पर क्लिक करें।',
    'act_short': 'शॉर्ट सर्किट! आपने बैटरी टर्मिनलों को सीधे एक-दूसरे से जोड़ दिया है।',
    'act_same_side': 'लैंप के दोनों टर्मिनल बैटरी के एक ही तरफ से जुड़े हैं!',
    'act_incomplete': 'मार्ग टूटा हुआ है। शेष टर्मिनलों को जोड़ें।',
    'act_success': 'परिपथ बंद है। लैंप जलता है!',
    'p_filament': 'इनकैंडेसेंट फिलामेंट',
    'p_case': 'इनकैंडेसेंट पेंच आवरण',
    'p_tip': 'इनकैंडेसेंट आधार नोक',
    'p_led_long': 'एलईडी लंबा तार (+)',
    'p_led_short': 'एलईडी छोटा तार (-)',
    'tl_glass': 'कांच का बल्ब',
    'tl_supports': 'मोटे तार के सहारे',
    'tl_filament': 'फिलामेंट (पतला तार)',
    'tl_case': 'धातु का आवरण (ऋणात्मक टर्मिनल)',
    'tl_tip': 'धातु की नोक (धनात्मक टर्मिनल)',
    'tl_led': 'एलईडी लैंप',
    'tl_board': 'सर्किट बोर्ड (कोई फिलामेंट नहीं)',
    'tl_terminals': 'दो टर्मिनल (+ धनात्मक, - ऋणात्मक)',
    'tt_inc_lamp': 'इनकैंडेसेंट लैंप',
    'tt_led_lamp': 'एलईडी लैंप',
    'tt_inc_torch': 'इनकैंडेसेंट लैंप टॉर्च',
    'tt_led_torch': 'एलईडी लैंप टॉर्च',
    't_bat_pos': 'बैटरी (+)',
    't_bat_neg': 'बैटरी (-)',
    't_bulb_term1': 'लैंप पेंच 1',
    't_bulb_term2': 'लैंप पेंच 2',
    'parts_found': 'मिले हुए भाग',
    'torch_switches': 'टॉर्च स्विच',
    'circuit_status': 'परिपथ की स्थिति',
    'state_on': 'चालू',
    'state_off': 'बंद',
    'btn_switch_on': 'चालू करें: {name}',
    'btn_switch_off': 'बंद करें: {name}',
    'btn_reset_wires': 'तार रीसेट करें',
    'selected_terminal': 'चुना गया टर्मिनल',
    'none': 'कोई नहीं',
    'wires_connected': 'जुड़े हुए तार',
    'no_wires': 'अभी तक कोई तार नहीं जुड़ा है।',
    'lamp': 'लैंप',
    'lamp_glowing': 'जल रहा है',
    'lamp_off': 'नहीं जल रहा',
    'msg_wires_reset': 'तार हटा दिए गए। फिर से वायरिंग शुरू करें।',
  },
};

// ========================================================== SCENARIOS
//
// `objective` is the HTML `task`; each step's `action` is the HTML
// procedural step text. Concepts / observations are written for the shell.

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'Observing Electric Lamps',
      objective:
          'Observe the internal structure. Identify the filament, the two casing terminals of the bulb, and the two legs of the LED.',
      steps: [
        LabStep(
          concept: 'Incandescent Lamp',
          action:
              'An incandescent bulb uses a thin glowing wire called a Filament. It connects to circuits via a Screw Case and a Base Tip.',
          observation: 'The filament, screw case and base tip of the incandescent lamp are labelled.',
        ),
        LabStep(
          concept: 'LED Lamp',
          action:
              'An LED has no filament. It has a Longer Wire (+) and a Shorter Wire (-) to define its polarity.',
          observation: 'The longer (+) and shorter (-) wires of the LED are labelled.',
        ),
        LabStep(
          concept: 'Torches: Incandescent vs LED',
          action:
              'Many torches in use today have a Light Emitting Diode (LED) lamp, instead of an incandescent lamp. Identify the parts, then test them in torches!',
          observation:
              'Switching on the torches shows the glowing filament of one and the glowing LEDs of the other.',
        ),
      ],
    ),
    LabScenarioData(
      title: 'Making a Lamp Glow',
      objective:
          "Construct a complete circuit by connecting the cell holder's terminals to the lamp holder's terminals.",
      steps: [
        LabStep(
          concept: 'Power Source',
          action:
              'A battery provides distinct positive (+) and negative (-) terminals as a source of electrical energy.',
          observation: 'The cell holder has a positive (+) and a negative (-) terminal.',
        ),
        LabStep(
          concept: 'Connecting Wires',
          action:
              "Connecting wires form a conductive path between the power source and the lamp's receiving terminals.",
          observation: 'Each wire joins two terminals.',
        ),
        LabStep(
          concept: 'Closed Circuit',
          action:
              'A completely closed loop allows current to flow, resulting in the lamp glowing brightly.',
          observation: 'The lamp glows only when the loop is complete.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'विद्युत लैंप का अवलोकन',
      objective:
          'आंतरिक संरचना का निरीक्षण करें। फिलामेंट, बल्ब के दो आवरण टर्मिनलों और एलईडी के दो पैरों की पहचान करें।',
      steps: [
        LabStep(
          concept: 'इनकैंडेसेंट लैंप',
          action:
              'एक इनकैंडेसेंट बल्ब फिलामेंट नामक पतले चमकते तार का उपयोग करता है। यह पेंचदार आवरण और आधार नोक के माध्यम से परिपथों से जुड़ता है।',
          observation: 'इनकैंडेसेंट लैंप का फिलामेंट, पेंचदार आवरण और आधार नोक लेबल हो गए हैं।',
        ),
        LabStep(
          concept: 'एलईडी लैंप',
          action:
              'एलईडी में कोई फिलामेंट नहीं होता है। इसकी ध्रुवता को परिभाषित करने के लिए इसमें एक लंबा तार (+) और एक छोटा तार (-) होता है।',
          observation: 'एलईडी के लंबे (+) और छोटे (-) तार लेबल हो गए हैं।',
        ),
        LabStep(
          concept: 'टॉर्च: इनकैंडेसेंट बनाम एलईडी',
          action:
              'आजकल उपयोग होने वाले कई टॉर्चों में इनकैंडेसेंट लैंप के बजाय लाइट एमिटिंग डायोड (एलईडी) लैंप होता है। भागों की पहचान करें, फिर उन्हें टॉर्च में परखें!',
          observation: 'टॉर्च चालू करने पर एक में फिलामेंट और दूसरे में एलईडी चमकते दिखाई देते हैं।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'लैंप को जलाना',
      objective:
          'सेल होल्डर के टर्मिनलों को लैंप होल्डर के टर्मिनलों से जोड़कर एक पूर्ण परिपथ का निर्माण करें।',
      steps: [
        LabStep(
          concept: 'शक्ति स्रोत',
          action:
              'बैटरी विद्युत ऊर्जा के स्रोत के रूप में अलग-अलग धनात्मक (+) और ऋणात्मक (-) टर्मिनल प्रदान करती है।',
          observation: 'सेल होल्डर में एक धनात्मक (+) और एक ऋणात्मक (-) टर्मिनल है।',
        ),
        LabStep(
          concept: 'जोड़ने वाले तार',
          action:
              'जोड़ने वाले तार शक्ति स्रोत और लैंप के प्राप्त करने वाले टर्मिनलों के बीच एक प्रवाहकीय मार्ग बनाते हैं।',
          observation: 'प्रत्येक तार दो टर्मिनलों को जोड़ता है।',
        ),
        LabStep(
          concept: 'बंद परिपथ',
          action:
              'एक पूरी तरह से बंद लूप करंट को प्रवाहित होने देता है, जिसके परिणामस्वरूप लैंप चमकने लगता है।',
          observation: 'लूप पूरा होने पर ही लैंप जलता है।',
        ),
      ],
    ),
  ],
};

// ======================================================== SCENE MODEL

const Size _design = Size(1000, 560);

/// HUD status colours (HTML `text-zsl-yellow`, `text-blue-400`, ...).
enum _Tone { yellow, blue, green, amber, red, orange }

/// The HTML `AppState.currentHud`: i18n keys + params, resolved at build
/// time so the language toggle re-translates the HUD.
@immutable
class _Hud {
  const _Hud(this.status, this.action, this.tone, {this.params = const {}, this.id = 0});

  final String status;
  final String action;
  final _Tone tone;

  /// Template values. Strings starting with '@' are i18n keys.
  final Map<String, Object> params;
  final int id;
}

class _Wire {
  _Wire(this.a, this.b, this.at);
  final String a;
  final String b;
  final double at;
}

/// Clickable lamp parts of scenario 1 (HTML `partName`s).
const List<String> _partIds = ['filament', 'case', 'tip', 'led_long', 'led_short'];
const List<String> _incParts = ['filament', 'case', 'tip'];
const List<String> _ledParts = ['led_long', 'led_short'];

/// Terminals of scenario 2 (HTML `createTerminal` ids).
const List<String> _terminalIds = ['bat_pos', 'bat_neg', 'bulb_term2', 'bulb_term1'];

/// Mutable scene state read by the painter every frame.
class _LampScene {
  int scenario = 0;
  double time = 0;

  _Hud hud = const _Hud('st_ready', 'act_ready', _Tone.yellow);
  int _hudId = 0;

  // ---- Scenario 1: observing lamps, then torches.
  final List<String> found = [];
  final Map<String, double> foundAt = {};
  final Map<String, double> flashAt = {};
  bool partsSolved = false;
  bool torches = false;
  double torchesAt = -10;
  final List<bool> torchOn = [false, false];
  final List<double> toggledAt = [-10, -10];
  int torchInteractions = 0;

  // ---- Scenario 2: wiring the lamp.
  String? selected;
  double selectedAt = -10;
  final List<_Wire> wires = [];
  bool circuitSolved = false;
  double solvedAt = -10;
  bool wiringError = false;
  int wiringStep = 1;

  void setHud(String status, String action, _Tone tone, [Map<String, Object> params = const {}]) {
    hud = _Hud(status, action, tone, params: params, id: ++_hudId);
  }

  /// HTML `resetScene()` state part.
  void reset() {
    found.clear();
    foundAt.clear();
    flashAt.clear();
    partsSolved = false;
    torches = false;
    torchesAt = -10;
    torchOn[0] = false;
    torchOn[1] = false;
    toggledAt[0] = -10;
    toggledAt[1] = -10;
    torchInteractions = 0;
    selected = null;
    selectedAt = -10;
    wires.clear();
    circuitSolved = false;
    solvedAt = -10;
    wiringError = false;
    wiringStep = 1;
  }

  bool get incDone => _incParts.every(found.contains);
  bool get ledDone => _ledParts.every(found.contains);

  /// Current procedural step (1-based) for the shell's target card.
  int get step {
    if (scenario == 0) {
      if (torches) return 3;
      if (!incDone) return 1;
      if (!ledDone) return 2;
      return 3;
    }
    return wiringStep;
  }

  /// 0..1 progress of an effect started at [at] lasting [dur] seconds.
  double since(double at, double dur) => ((time - at) / dur).clamp(0.0, 1.0);
}

// ========================================================== GEOMETRY
//
// Shared by the painter and hit-testing so taps use exactly the drawn
// shapes. All values are design coordinates (1000 x 560).

class _G {
  _G._();

  // ---- Scenario 1 lamps (HTML bulb at x = -3.5, scale 1.8; LED at 3.5, scale 2.2).
  static const Offset bulbBase = Offset(350, 425);
  static const double bulbU = 82;
  static const double bulbB = 0.6; // HTML `bulbOffset` in scenario 1
  static const Offset ledBase = Offset(650, 425);
  static const double ledU = 98;
  static const double ledShortEnd = 0.3; // the cathode leg stops above the table

  static Offset bulbL(double x, double y) => Offset(bulbBase.dx + x * bulbU, bulbBase.dy - y * bulbU);
  static Offset ledL(double x, double y) => Offset(ledBase.dx + x * ledU, ledBase.dy - y * ledU);

  static Rect _r(Offset a, Offset b) => Rect.fromPoints(a, b).inflate(6);

  /// Hit regions in priority order (HTML invisible hitboxes).
  static Map<String, Rect> get partRects => {
        'tip': _r(bulbL(-0.35, bulbB - 0.75), bulbL(0.35, bulbB - 0.32)),
        'filament': _r(bulbL(-0.6, bulbB + 1.55), bulbL(0.6, bulbB + 1.05)),
        'case': _r(bulbL(-0.6, bulbB - 0.32), bulbL(0.6, bulbB + 0.4)),
        'led_long': _r(ledL(0.02, 0), ledL(0.42, 2.0)),
        'led_short': _r(ledL(-0.52, ledShortEnd - 0.05), ledL(0.02, 2.0)),
      };

  /// Where each part's leader line starts.
  static Offset partAnchor(String id) => switch (id) {
        'filament' => bulbL(0, bulbB + 1.3),
        'case' => bulbL(0, bulbB),
        'tip' => bulbL(0, bulbB - 0.55),
        'led_long' => ledL(0.2, 1.0),
        _ => ledL(-0.3, 1.0),
      };

  /// Label offsets (HTML `partOffsets`, fitted to the design size).
  static Offset partOffset(String id) => switch (id) {
        'filament' => const Offset(-200, -48),
        'case' => const Offset(-205, 10),
        'tip' => const Offset(-150, 62),
        'led_long' => const Offset(185, 75),
        _ => const Offset(200, -25),
      };

  static Offset get bulbTitle => bulbL(0, 3.2);
  static Offset get ledTitle => ledL(0, 3.58);

  // ---- Scenario 1 torches (HTML torches at x = -5 / +5, scale 1.4).
  static const double tU = 46; // px per torch-local unit
  static const double tFz = 0.74; // axial foreshortening (axis points at the viewer)
  static const double tRy = 0.67; // cross-section ellipse ratio
  static const List<Offset> torchO = [Offset(330, 230), Offset(660, 230)];

  /// Torch-local point: [x] across, [a] along the axis (+ = towards the
  /// viewer), [h] height above the axis.
  static Offset tp(int i, double x, double a, double h) =>
      Offset(torchO[i].dx + x * tU, torchO[i].dy + a * tFz * tU - h * tRy * tU);

  /// Separate battery caps (HTML capGroup at x = +-2, z = 2.5, y = -0.25).
  /// Point inside the reflector: depth is compressed so the bulb / LED
  /// board sit near the middle of the open front (clearer than true depth).
  static Offset ti(int i, double x, double a, double h) => tp(i, x, 2.6 - (2.6 - a) * 0.45, h);

  static Offset capCenter(int i) => tp(i, i == 0 ? 2.6 : -2.6, 2.5, -0.25);

  static Rect switchRect(int i) => Rect.fromPoints(tp(i, -0.95, -0.45, 1.35), tp(i, 0.95, 1.4, 0.45));

  static Offset torchTitle(int i) => tp(i, 0, -3.25, 0);

  static Offset torchAnchor(int i, String id) => switch (id) {
        'tl_glass' => ti(i, -0.2, 1.8, 0.35),
        'tl_supports' => ti(i, -0.14, 1.6, -0.2),
        'tl_filament' => ti(i, -0.05, 1.8, 0),
        'tl_case' => capCenter(i) + const Offset(-26, 10),
        'tl_tip' => capCenter(i) + const Offset(0, 6),
        'tl_led' => ti(i, 0.5, 1.38, 0),
        'tl_board' => ti(i, -0.25, 1.35, -0.55),
        _ => capCenter(i) + const Offset(0, 8),
      };

  /// Label positions (HTML `torchPartOffsets`, fitted to the design size).
  static Offset torchLabel(int i, String id) => switch (id) {
        'tl_glass' => ti(i, 0, 1.8, 0) + const Offset(-185, -112),
        'tl_supports' => ti(i, 0, 1.8, 0) + const Offset(-215, -45),
        'tl_filament' => ti(i, 0, 1.8, 0) + const Offset(-200, 22),
        'tl_case' => capCenter(i) + const Offset(-150, 87),
        'tl_tip' => capCenter(i) + const Offset(-70, 132),
        'tl_led' => ti(i, 0, 1.38, 0) + const Offset(180, -108),
        'tl_board' => ti(i, 0, 1.38, 0) + const Offset(200, -40),
        _ => capCenter(i) + const Offset(170, 87),
      };

  static const List<String> incTorchLabels = ['tl_glass', 'tl_supports', 'tl_filament', 'tl_case', 'tl_tip'];
  static const List<String> ledTorchLabels = ['tl_led', 'tl_board', 'tl_terminals'];

  // ---- Scenario 2 (battery at x = -4.5, scale 1.4; lamp at 4.5, scale 1.8).
  static const double wU = 50;
  static const double wSp = 0.47; // sin(28 deg) camera pitch
  static Offset w(double x, double y, double z) => Offset(480 + x * wU, 350 - y * wU + z * wU * wSp);

  static const Map<String, List<double>> terminal3D = {
    'bat_pos': [-8.14, 0.85, 0],
    'bat_neg': [-0.86, 0.85, 0],
    'bulb_term1': [7.2, 0.82, 0],
    'bulb_term2': [1.8, 0.82, 0],
  };

  static Offset terminal(String id) {
    final p = terminal3D[id]!;
    return w(p[0], p[1], p[2]);
  }

  static Offset terminalLabel(String id) {
    final p = terminal3D[id]!;
    return w(p[0], p[1] + 1.05, p[2]);
  }

  static const double terminalHitR = 40;

  /// HTML `createWire()` curve: Catmull-Rom through p1, a mid point on the
  /// table pushed 4 units sideways (or towards / away from the viewer).
  static List<double> wireMid(String a, String b) {
    final p1 = terminal3D[a]!, p2 = terminal3D[b]!;
    var mx = (p1[0] + p2[0]) / 2, mz = (p1[2] + p2[2]) / 2;
    const my = 0.05;
    const d = 4.0;
    if (p1[0] < 0 && p2[0] < 0) {
      mx -= d;
    } else if (p1[0] > 0 && p2[0] > 0) {
      mx += d;
    } else {
      // (p2 - p1) x (0, 1, 0) = (-dz, 0, dx), normalised.
      final ox = -(p2[2] - p1[2]), oz = p2[0] - p1[0];
      final len = math.sqrt(ox * ox + oz * oz);
      if (len > 0) {
        mx += ox / len * d;
        mz += oz / len * d;
      }
    }
    return [mx, my, mz];
  }

  /// Samples the wire curve in 3D (n + 1 points).
  static List<List<double>> wirePoints(String a, String b, {int n = 40}) {
    final pts = [terminal3D[a]!, wireMid(a, b), terminal3D[b]!];
    return _catmull3(pts, n);
  }
}

/// Uniform Catmull-Rom through [pts] (end points duplicated), [n] segments.
List<List<double>> _catmull3(List<List<double>> pts, int n) {
  final out = <List<double>>[];
  final segs = pts.length - 1;
  for (var k = 0; k <= n; k++) {
    final u = k / n * segs;
    final i = math.min(u.floor(), segs - 1);
    final t = u - i;
    final p0 = pts[math.max(i - 1, 0)], p1 = pts[i], p2 = pts[i + 1];
    final p3 = pts[math.min(i + 2, pts.length - 1)];
    final t2 = t * t, t3 = t2 * t;
    out.add([
      for (var c = 0; c < p1.length; c++)
        0.5 *
            (2 * p1[c] +
                (-p0[c] + p2[c]) * t +
                (2 * p0[c] - 5 * p1[c] + 4 * p2[c] - p3[c]) * t2 +
                (-p0[c] + 3 * p1[c] - 3 * p2[c] + p3[c]) * t3),
    ]);
  }
  return out;
}

/// Smooth 2D path through [pts] (Catmull-Rom).
Path _smoothPath(List<Offset> pts, {int n = 32}) {
  final raw = _catmull3([for (final p in pts) [p.dx, p.dy]], n);
  final path = Path()..moveTo(raw.first[0], raw.first[1]);
  for (final p in raw.skip(1)) {
    path.lineTo(p[0], p[1]);
  }
  return path;
}

// ============================================================ PAINTER

class _LampPainter extends CustomPainter {
  _LampPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
  }) : super(repaint: repaint);

  final _LampScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    _paintTable(canvas, size, horizon: s.scenario == 0 ? 46 : 40);
    if (s.scenario == 0) {
      final f = s.torches ? Curves.easeInOut.transform(s.since(s.torchesAt, 0.6)) : 0.0;
      if (f < 1) _withOpacity(canvas, size, 1 - f, () => _paintLamps(canvas));
      if (s.torches) _withOpacity(canvas, size, f, () => _paintTorches(canvas));
    } else {
      _paintCircuit(canvas, size);
    }
  }

  void _withOpacity(Canvas canvas, Size size, double o, VoidCallback draw) {
    if (o <= 0) return;
    if (o >= 1) return draw();
    canvas.saveLayer(labBleed(size), Paint()..color = Color.fromRGBO(0, 0, 0, o));
    draw();
    canvas.restore();
  }

  // ---------------------------------------------------------------- table

  /// HTML `createWoodenTable()`: #8B5A2B planks with #A0522D / #6B4226
  /// grain, seen in perspective, plus the canvas background above it.
  void _paintTable(Canvas canvas, Size size, {required double horizon}) {
    final bleed = labBleed(size);
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, horizon + 1),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF020617), Color(0xFF1E293B)]
              : const [Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
        ).createShader(Rect.fromLTRB(0, horizon - 160, 0, horizon)),
    );
    final top = Rect.fromLTRB(bleed.left, horizon, bleed.right, bleed.bottom);
    canvas.drawRect(top, Paint()..color = const Color(0xFF8B5A2B));
    final rnd = math.Random(7);
    final span = size.height + 140 - horizon;
    final grain = Paint();
    for (var i = 0; i < 180; i++) {
      final d = rnd.nextDouble();
      final y = horizon + span * math.pow(d, 1.7);
      final th = (rnd.nextDouble() * 3 + 0.6) * (0.35 + 1.4 * d);
      final c = rnd.nextBool() ? const Color(0xFFA0522D) : const Color(0xFF6B4226);
      grain.color = c.withValues(alpha: rnd.nextDouble() * 0.4 + 0.1);
      canvas.drawRect(Rect.fromLTRB(bleed.left, y, bleed.right, y + th), grain);
    }
    // Far end of the table fades into shadow.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, horizon, bleed.right, horizon + 230),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: isDark ? 0.55 : 0.32), Colors.transparent],
        ).createShader(Rect.fromLTRB(0, horizon, 0, horizon + 230)),
    );
    // Warm key light (HTML DirectionalLight 0xffeacc from the upper right).
    canvas.drawRect(
      top,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.3, 0.05),
          radius: 0.85,
          colors: [Color(0x38FFEACC), Color(0x00FFEACC)],
        ).createShader(Rect.fromLTWH(0, horizon, size.width, size.height - horizon)),
    );
    // Near edge.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, size.height - 110, bleed.right, bleed.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x40000000)],
        ).createShader(Rect.fromLTRB(0, size.height - 110, 0, size.height)),
    );
    canvas.drawLine(
      Offset(bleed.left, horizon),
      Offset(bleed.right, horizon),
      Paint()
        ..color = const Color(0x40FFE0B0)
        ..strokeWidth = 1.5,
    );
  }

  // ------------------------------------------------------- scenario 1: lamps

  double _flash(String id) {
    final at = scene.flashAt[id];
    if (at == null) return 0;
    final k = (scene.time - at) / 0.3;
    return k >= 0 && k < 1 ? 1 - k : 0;
  }

  void _paintLamps(Canvas canvas) {
    final s = scene;
    _castShadow(canvas, _G.bulbBase, _G.bulbBase + const Offset(-105, -58), 80, opacity: 0.28);
    _castShadow(canvas, _G.ledBase, _G.ledBase + const Offset(-135, -78), 48, opacity: 0.24);
    _drawBulb(
      canvas,
      _G.bulbBase,
      _G.bulbU,
      b: _G.bulbB,
      withTip: true,
      flashFilament: _flash('filament'),
      flashCase: _flash('case'),
      flashTip: _flash('tip'),
    );
    _drawLed(canvas, _G.ledBase, _G.ledU, flashLong: _flash('led_long'), flashShort: _flash('led_short'));
    if (!showLabels) return;
    _mainTitle(canvas, _t('tt_inc_lamp'), _G.bulbTitle);
    _mainTitle(canvas, _t('tt_led_lamp'), _G.ledTitle);
    for (final id in s.found) {
      final o = Curves.easeOut.transform(s.since(s.foundAt[id]!, 0.4));
      final from = _G.partAnchor(id);
      _leaderLabel(canvas, _t('p_$id'), from, from + _G.partOffset(id), o);
    }
  }

  // ----------------------------------------------------- scenario 1: torches

  double _torchLevel(int i) {
    final k = Curves.easeOut.transform(scene.since(scene.toggledAt[i], 0.25));
    return scene.torchOn[i] ? k : 1 - k;
  }

  void _paintTorches(Canvas canvas) {
    final s = scene;
    for (var i = 0; i < 2; i++) {
      _drawTorch(canvas, i, _torchLevel(i), s.time, hint: s.torchInteractions == 0, sw: _switchPos(i));
    }
    for (var i = 0; i < 2; i++) {
      _drawCap(canvas, i);
    }
    for (var i = 0; i < 2; i++) {
      _drawBeam(canvas, i, _torchLevel(i), s.time);
    }
    if (!showLabels) return;
    for (var i = 0; i < 2; i++) {
      _mainTitle(canvas, _t(i == 0 ? 'tt_inc_torch' : 'tt_led_torch'), _G.torchTitle(i));
      for (final id in i == 0 ? _G.incTorchLabels : _G.ledTorchLabels) {
        _leaderLabel(canvas, _t(id), _G.torchAnchor(i, id), _G.torchLabel(i, id), 1);
      }
      final on = s.torchOn[i];
      labText(
        canvas,
        _t(on ? 'state_on' : 'state_off'),
        _G.tp(i, 1.25, 0.2, 1.1),
        size: 13,
        weight: FontWeight.w800,
        color: Colors.white,
        background: on ? const Color(0xE616A34A) : const Color(0xE6334155),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        anchor: Alignment.centerLeft,
      );
    }
  }

  /// Slider position 0 (back, off) .. 1 (front, on), animated.
  double _switchPos(int i) {
    final k = Curves.easeInOut.transform(scene.since(scene.toggledAt[i], 0.15));
    return scene.torchOn[i] ? k : 1 - k;
  }

  // ------------------------------------------------------ scenario 2: circuit

  void _paintCircuit(Canvas canvas, Size size) {
    final s = scene;
    final glow = s.circuitSolved ? Curves.easeOut.transform(s.since(s.solvedAt, 0.8)) : 0.0;
    if (glow > 0) _lightPool(canvas, _G.w(4.5, 0, 0.6), 7 * _G.wU, 2.6 * _G.wU, const Color(0xFFFFDD44), glow * 0.95);
    _castShadow(canvas, _G.w(-4.5, 0, 0), _G.w(-6.2, 0, -1.6), 2.7 * _G.wU, opacity: 0.32);
    _castShadow(canvas, _G.w(4.5, 0, 0), _G.w(2.6, 0, -2.4), 3.4 * _G.wU, opacity: 0.28);

    final front = <_Wire>[], back = <_Wire>[];
    for (final w in s.wires) {
      (_G.wireMid(w.a, w.b)[2] < 0 ? back : front).add(w);
    }
    for (final w in back) {
      _drawWire(canvas, w, s.since(w.at, 0.25));
    }
    _drawBattery(canvas);
    _drawLampHolder(canvas, glow);
    for (final w in front) {
      _drawWire(canvas, w, s.since(w.at, 0.25));
    }
    for (final id in _terminalIds) {
      _drawTerminal(canvas, id, s.selected == id, s.time);
    }
    if (glow > 0) {
      final c = _G.w(4.5, 0.1 + 2.0 * 1.8, 0);
      canvas.drawRect(
        labBleed(size),
        Paint()
          ..blendMode = BlendMode.plus
          ..color = const Color(0xFFFFDD44).withValues(alpha: 0.06 * glow),
      );
      labGlow(canvas, c, 6 * _G.wU, const Color(0xFFFFDD44), intensity: 0.7 * glow);
      labGlow(canvas, c, 2.2 * _G.wU, const Color(0xFFFFF4C2), intensity: 0.5 * glow);
    }
    if (!showLabels) return;
    for (final id in _terminalIds) {
      final isPos = id == 'bat_pos', isNeg = id == 'bat_neg';
      final r = _fitLabel(_t('t_$id'), _G.terminalLabel(id), size: 16, padH: 12, padV: 6);
      labText(
        canvas,
        _t('t_$id'),
        r.center,
        size: 16,
        weight: FontWeight.w700,
        color: isPos ? const Color(0xFFF87171) : (isNeg ? const Color(0xFF4ADE80) : Colors.white),
        background: const Color(0xF20F172A),
        border: const Color(0x33FFFFFF),
        borderWidth: 1,
        radius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      );
    }
  }

  // ------------------------------------------------------------- labels

  /// Measures a label and keeps it inside the safe design area (clear of
  /// the tool column), returning its rect.
  Rect _fitLabel(
    String text,
    Offset center, {
    required double size,
    FontWeight weight = FontWeight.w700,
    double padH = 12,
    double padV = 6,
    double letterSpacing = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          letterSpacing: letterSpacing,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final r = Rect.fromCenter(center: center, width: tp.width + padH * 2, height: tp.height + padV * 2);
    final dx = r.left < 8 ? 8 - r.left : (r.right > 895 ? 895 - r.right : 0.0);
    final dy = r.top < 6 ? 6 - r.top : (r.bottom > 554 ? 554 - r.bottom : 0.0);
    return r.shift(Offset(dx, dy));
  }

  /// HTML `.part-label` with its animated dashed SVG leader line.
  void _leaderLabel(Canvas canvas, String text, Offset from, Offset to, double o) {
    if (o <= 0) return;
    final r = _fitLabel(text, to + Offset(0, 10 * (1 - o)), size: 16);
    final line = Paint()
      ..color = _Colors.zslYellow.withValues(alpha: o)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    labDashedLine(canvas, from, r.center, line, dash: 4, gap: 4, phase: -scene.time * 8);
    canvas.drawCircle(from, 3.5, Paint()..color = _Colors.zslYellow.withValues(alpha: o));
    labText(
      canvas,
      text,
      r.center,
      size: 16,
      weight: FontWeight.w700,
      color: Colors.white,
      background: const Color(0xF20F172A),
      border: _Colors.zslYellow,
      borderWidth: 1,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      opacity: o,
    );
  }

  /// HTML `.main-title-label` (yellow, uppercase).
  void _mainTitle(Canvas canvas, String text, Offset at) {
    final up = text.toUpperCase();
    final ls = lang == LabLang.hi ? 0.0 : 1.0;
    final r = _fitLabel(up, at, size: 15, weight: FontWeight.w800, padH: 16, padV: 7, letterSpacing: ls);
    labText(
      canvas,
      up,
      r.center,
      size: 15,
      weight: FontWeight.w800,
      color: _Colors.zslYellow,
      background: const Color(0xE60F172A),
      border: _Colors.zslYellow,
      borderWidth: 1,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      letterSpacing: ls,
    );
  }

  @override
  bool shouldRepaint(covariant _LampPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
}

// ------------------------------------------------------------ helpers

/// Soft shadow cast along the table from [base] towards [tip].
void _castShadow(Canvas canvas, Offset base, Offset tip, double w, {double opacity = 0.3}) {
  final mid = (base + tip) / 2;
  final len = (tip - base).distance;
  canvas.save();
  canvas.translate(mid.dx, mid.dy);
  canvas.rotate((tip - base).direction);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: len + w, height: w * 0.42),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.16),
  );
  canvas.restore();
}

/// Light falling on the table (point light / spot light).
void _lightPool(Canvas canvas, Offset c, double rx, double ry, Color color, double intensity) {
  final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
  canvas.drawOval(
    rect,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: (0.6 * intensity).clamp(0.0, 1.0)),
        color.withValues(alpha: (0.22 * intensity).clamp(0.0, 1.0)),
        color.withValues(alpha: 0),
      ], stops: const [0, 0.45, 1]).createShader(rect),
  );
}

// ====================================================== OBJECT DRAWING
//
// 2.5D illustrations of the Three.js meshes. Colours are the HTML hex
// values; sizes follow the HTML geometry (local units x [u] pixels).

Path _quad(Offset a, Offset b, Offset c, Offset d) => Path()
  ..moveTo(a.dx, a.dy)
  ..lineTo(b.dx, b.dy)
  ..lineTo(c.dx, c.dy)
  ..lineTo(d.dx, d.dy)
  ..close();

/// Horizontal metallic gradient (cylindrical shading, light from the right).
Shader _metal(Rect r, Color c) => LinearGradient(
      colors: [
        labShade(c, -0.5),
        labShade(c, 0.05),
        labShade(c, 0.5),
        labShade(c, -0.1),
        labShade(c, -0.55),
      ],
      stops: const [0, 0.25, 0.55, 0.8, 1],
    ).createShader(r);

/// Silver wire with an outline and highlight (LED legs).
void _metalWire(Canvas canvas, Path path, double width, {double flash = 0}) {
  Paint s(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;
  canvas.drawPath(path, s(const Color(0xFF4B5563), width + 2));
  canvas.drawPath(path, s(const Color(0xFF9CA3AF), width));
  canvas.drawPath(path.shift(Offset(-width * 0.18, 0)), s(const Color(0xFFE5E7EB), width * 0.3));
  if (flash > 0) {
    canvas.drawPath(
      path,
      s(_Colors.zslYellow.withValues(alpha: 0.6 * flash), width + 10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(path, s(_Colors.zslYellow.withValues(alpha: flash), width));
  }
}

/// HTML `buildIncandescentBulb()`. [o] is the group origin on screen, [u]
/// pixels per local unit, [b] the HTML `bulbOffset`. [withTip] adds the
/// insulator and base tip (scenario 1). [glow] 0..1 lights the filament.
void _drawBulb(
  Canvas canvas,
  Offset o,
  double u, {
  required double b,
  bool withTip = false,
  double glow = 0,
  double flashFilament = 0,
  double flashCase = 0,
  double flashTip = 0,
}) {
  Offset l(double x, double y) => Offset(o.dx + x * u, o.dy - y * u);
  Path trap(double y0, double r0, double y1, double r1) => _quad(l(-r0, y0), l(r0, y0), l(r1, y1), l(-r1, y1));

  // ---- Glass envelope (sphere + neck), amber tinted 0xffaa00 @ 0.25.
  final center = l(0, b + 1.2);
  final sphere = Rect.fromCircle(center: center, radius: u);
  final glass = Path.combine(
    PathOperation.union,
    Path()..addOval(sphere),
    trap(b + 0.2, 0.45, b + 0.85, 0.72),
  );
  canvas.drawPath(
    glass,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        radius: 1.05,
        colors: [
          Color.lerp(const Color(0x33FFF3D6), const Color(0xE6FFF6CC), glow)!,
          Color.lerp(const Color(0x30FFAA00), const Color(0xB3FFD34D), glow)!,
          Color.lerp(const Color(0x70FFAA00), const Color(0xCCFFB300), glow)!,
        ],
        stops: const [0, 0.62, 1],
      ).createShader(sphere),
  );

  // ---- Glass stem (0xdd6633 @ 0.8).
  final stem = trap(b + 0.25, 0.3, b + 0.8, 0.15);
  canvas.drawPath(
    stem,
    Paint()
      ..shader = const LinearGradient(colors: [
        Color(0xCC9A3F1E),
        Color(0xCCF0905C),
        Color(0xCCDD6633),
        Color(0xCC8A3518),
      ], stops: [0, 0.35, 0.65, 1]).createShader(stem.getBounds()),
  );

  // ---- Lead-in wires and thick wire supports (0x444444).
  final wire = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF444444);
  for (final sx in [-1.0, 1.0]) {
    canvas.drawLine(l(sx * 0.12, b + 0.32), l(sx * 0.07, b + 0.78), wire..strokeWidth = math.max(1.2, 0.035 * u));
    canvas.drawLine(l(sx * 0.07, b + 0.78), l(sx * 0.4, b + 1.2), wire..strokeWidth = math.max(1.6, 0.06 * u));
  }

  // ---- Filament (thin coiled wire, CatmullRom like the HTML TubeGeometry).
  final fil = _smoothPath([
    l(-0.4, b + 1.2),
    l(-0.2, b + 1.4),
    l(0, b + 1.25),
    l(0.2, b + 1.4),
    l(0.4, b + 1.2),
  ]);
  Paint fs(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;
  final fw = math.max(2.0, 0.08 * u);
  if (glow > 0) {
    canvas.drawPath(fil, fs(const Color(0xFFFFCC00).withValues(alpha: 0.85 * glow), fw * 5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }
  canvas.drawPath(fil, fs(Color.lerp(const Color(0xFF333333), const Color(0xFFFFCC00), glow)!, fw));
  labDashedPath(canvas, fil, fs(Color.lerp(const Color(0xFF6B6B6B), const Color(0xFFFFFBEB), glow)!, fw * 0.55),
      dash: 2, gap: 2);
  if (flashFilament > 0) {
    canvas.drawPath(fil, fs(_Colors.zslYellow.withValues(alpha: 0.6 * flashFilament), fw * 4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(fil, fs(_Colors.zslYellow.withValues(alpha: flashFilament), fw));
  }

  // ---- Glass highlights (drawn over the internals).
  canvas.drawPath(
    glass,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Color.lerp(const Color(0x80FFD27A), const Color(0xCCFFF1B8), glow)!,
  );
  canvas.save();
  canvas.translate(center.dx - 0.42 * u, center.dy - 0.45 * u);
  canvas.rotate(-0.6);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: 0.42 * u, height: 0.2 * u),
    Paint()..color = Colors.white.withValues(alpha: 0.55),
  );
  canvas.restore();
  canvas.drawCircle(l(-0.12, b + 1.95), 0.05 * u, Paint()..color = Colors.white.withValues(alpha: 0.6));
  canvas.drawArc(
    sphere.deflate(0.12 * u),
    -0.35,
    0.9,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05 * u
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.22),
  );

  // ---- Screw case (metal 0x888888 with thread rings).
  final casePath = trap(b - 0.3, 0.4, b + 0.3, 0.5);
  canvas.drawPath(casePath, Paint()..shader = _metal(casePath.getBounds(), const Color(0xFF888888)));
  for (final dy in [-0.2, -0.08, 0.04, 0.16]) {
    final y = b + dy;
    final r = 0.4 + (dy + 0.3) / 0.6 * 0.1 + 0.03;
    final ring = Rect.fromCenter(center: l(0, y), width: 2 * r * u, height: 0.16 * u);
    canvas.drawArc(
      ring,
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, 0.07 * u)
        ..color = const Color(0xFFC9C9C9),
    );
    canvas.drawArc(
      ring.shift(Offset(0, 0.045 * u)),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 0.03 * u)
        ..color = const Color(0xFF3F3F3F),
    );
  }
  if (flashCase > 0) {
    canvas.drawPath(casePath, Paint()..color = _Colors.zslYellow.withValues(alpha: 0.7 * flashCase));
    labGlow(canvas, l(0, b), 0.9 * u, _Colors.zslYellow, intensity: 0.6 * flashCase);
  }

  if (!withTip) return;
  // ---- Insulator (0x111827) and base tip (0x4b5563).
  final ins = trap(b - 0.5, 0.15, b - 0.3, 0.3);
  canvas.drawPath(ins, Paint()..shader = _metal(ins.getBounds(), const Color(0xFF1F2937)));
  final tip = trap(b - 0.6, 0.08, b - 0.5, 0.12);
  canvas.drawPath(tip, Paint()..shader = _metal(tip.getBounds(), const Color(0xFF6B7280)));
  canvas.drawOval(
    Rect.fromCenter(center: l(0, b - 0.6), width: 0.16 * u, height: 0.05 * u),
    Paint()..color = const Color(0xFF9CA3AF),
  );
  if (flashTip > 0) {
    canvas.drawPath(tip, Paint()..color = _Colors.zslYellow.withValues(alpha: flashTip));
    labGlow(canvas, l(0, b - 0.55), 0.45 * u, _Colors.zslYellow, intensity: 0.8 * flashTip);
  }
}

/// HTML `buildLED()`: green lens on a flange, anvil / post / bond wire
/// inside, a longer (+) and a kinked shorter (-) leg.
void _drawLed(Canvas canvas, Offset o, double u, {double flashLong = 0, double flashShort = 0}) {
  Offset l(double x, double y) => Offset(o.dx + x * u, o.dy - y * u);
  final legW = 0.12 * u;

  // ---- Legs.
  final longLeg = Path()
    ..moveTo(l(0.2, 0).dx, l(0.2, 0).dy)
    ..lineTo(l(0.2, 2.02).dx, l(0.2, 2.02).dy);
  final shortLeg = Path()
    ..moveTo(l(-0.2, 2.02).dx, l(-0.2, 2.02).dy)
    ..lineTo(l(-0.2, 1.5).dx, l(-0.2, 1.5).dy)
    ..lineTo(l(-0.3, 1.4).dx, l(-0.3, 1.4).dy)
    ..lineTo(l(-0.3, _G.ledShortEnd).dx, l(-0.3, _G.ledShortEnd).dy);
  _metalWire(canvas, longLeg, legW, flash: flashLong);
  _metalWire(canvas, shortLeg, legW, flash: flashShort);

  // ---- Internals (silver 0xc0c0c0): anvil + cup, post, bond wire.
  const silver = Color(0xFFC0C0C0);
  final anvil = Rect.fromPoints(l(-0.4, 2.55), l(0, 2.05));
  canvas.drawRect(anvil, Paint()..shader = _metal(anvil, silver));
  final cup = _quad(l(-0.35, 2.48), l(-0.05, 2.48), l(-0.02, 2.66), l(-0.38, 2.66));
  canvas.drawPath(cup, Paint()..shader = _metal(cup.getBounds(), silver));
  canvas.drawOval(
    Rect.fromCenter(center: l(-0.2, 2.66), width: 0.36 * u, height: 0.07 * u),
    Paint()..color = const Color(0xFF6B7280),
  );
  final post = Rect.fromPoints(l(0.125, 2.45), l(0.275, 2.05));
  canvas.drawRect(post, Paint()..shader = _metal(post, silver));
  final bond = Path()
    ..moveTo(l(0.2, 2.45).dx, l(0.2, 2.45).dy)
    ..quadraticBezierTo(l(0.02, 2.66).dx, l(0.02, 2.66).dy, l(-0.2, 2.6).dx, l(-0.2, 2.6).dy);
  canvas.drawPath(
    bond,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, 0.025 * u)
      ..color = const Color(0xFFE5E7EB),
  );

  // ---- Lens: cylinder + dome (0x006400 @ 0.8).
  final dome = Rect.fromCircle(center: l(0, 2.8), radius: 0.5 * u);
  final lens = Path()
    ..moveTo(l(-0.5, 2.0).dx, l(-0.5, 2.0).dy)
    ..lineTo(l(-0.5, 2.8).dx, l(-0.5, 2.8).dy)
    ..arcTo(dome, math.pi, math.pi, false)
    ..lineTo(l(0.5, 2.0).dx, l(0.5, 2.0).dy)
    ..close();
  final lb = lens.getBounds();
  canvas.drawPath(
    lens,
    Paint()
      ..shader = const LinearGradient(colors: [
        Color(0xE6003A00),
        Color(0x9922A022),
        Color(0x8C0B7A0B),
        Color(0xE6002800),
      ], stops: [0, 0.3, 0.62, 1]).createShader(lb),
  );
  canvas.drawPath(
    lens,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF15803D).withValues(alpha: 0.8),
  );
  // Highlights.
  final streak = RRect.fromRectAndRadius(
    Rect.fromPoints(l(-0.36, 2.95), l(-0.24, 2.12)),
    Radius.circular(0.06 * u),
  );
  canvas.drawRRect(streak, Paint()..color = Colors.white.withValues(alpha: 0.32));
  canvas.drawOval(
    Rect.fromCenter(center: l(-0.18, 3.05), width: 0.2 * u, height: 0.12 * u),
    Paint()..color = Colors.white.withValues(alpha: 0.45),
  );

  // ---- Flange (base ring r 0.55).
  final flange = RRect.fromRectAndRadius(Rect.fromPoints(l(-0.55, 2.06), l(0.55, 1.94)), Radius.circular(0.04 * u));
  canvas.drawRRect(
    flange,
    Paint()
      ..shader = const LinearGradient(colors: [
        Color(0xF0003A00),
        Color(0xE62E9A2E),
        Color(0xF0004D00),
      ]).createShader(flange.outerRect),
  );
}

// ------------------------------------------------------------ torches

/// One frustum of a torch body lying along the view axis (oblique view):
/// the union of its far / near cross-section ellipses.
void _torchSeg(Canvas canvas, int i, double a0, double a1, double r0, double r1, Color c) {
  const u = _G.tU;
  final e0 = Rect.fromCenter(center: _G.tp(i, 0, a0, 0), width: 2 * r0 * u, height: 2 * r0 * u * _G.tRy);
  final e1 = Rect.fromCenter(center: _G.tp(i, 0, a1, 0), width: 2 * r1 * u, height: 2 * r1 * u * _G.tRy);
  final quad = _quad(
    Offset(e0.left, e0.center.dy),
    Offset(e1.left, e1.center.dy),
    Offset(e1.right, e1.center.dy),
    Offset(e0.right, e0.center.dy),
  );
  final shape = Path.combine(
    PathOperation.union,
    Path.combine(PathOperation.union, Path()..addOval(e0), quad),
    Path()..addOval(e1),
  );
  canvas.drawPath(shape, Paint()..shader = _metal(shape.getBounds(), c));
  canvas.drawArc(
    e1,
    0.05,
    math.pi - 0.1,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = labShade(c, -0.55).withValues(alpha: 0.7),
  );
}

/// HTML `buildInteractiveTorch()`: hollow body (red handle for the
/// incandescent torch, blue for the LED torch), reflector, glass bulb or
/// LED board, glass cover and the slide switch. [level] 0..1 = light on.
void _drawTorch(Canvas canvas, int i, double level, double t, {required bool hint, required double sw}) {
  final led = i == 1;
  const u = _G.tU;
  Offset p(double x, double a, double h) => _G.tp(i, x, a, h);
  Offset q(double x, double a, double h) => _G.ti(i, x, a, h);
  const silver = Color(0xFFE5E7EB);
  final handle = led ? const Color(0xFF2563EB) : const Color(0xFFDC2626);
  final light = led ? const Color(0xFF00FF00) : const Color(0xFFFFDD44);

  _castShadow(canvas, p(-0.55, -2.6, -0.72), p(-0.8, 2.4, -0.72), 2.6 * u, opacity: 0.32);
  _torchSeg(canvas, i, -2.5, -2.1, 0.75, 0.75, silver);
  _torchSeg(canvas, i, -2.1, 0.4, 0.72, 0.72, handle);
  _torchSeg(canvas, i, 0.4, 1.0, 0.72, 0.9, silver);

  // ---- Slide switch on top of the handle (black base, coloured slider).
  final top = _quad(p(-0.3, 0, 0.92), p(0.3, 0, 0.92), p(0.3, 1.0, 0.92), p(-0.3, 1.0, 0.92));
  canvas.drawPath(top, Paint()..color = const Color(0xFF2A2A2A));
  canvas.drawPath(
    _quad(p(-0.3, 1.0, 0.92), p(0.3, 1.0, 0.92), p(0.3, 1.0, 0.72), p(-0.3, 1.0, 0.72)),
    Paint()..color = const Color(0xFF111111),
  );
  canvas.drawLine(p(-0.12, 0.08, 0.92), p(-0.12, 0.92, 0.92), Paint()..color = Colors.black..strokeWidth = 2);
  canvas.drawLine(p(0.12, 0.08, 0.92), p(0.12, 0.92, 0.92), Paint()..color = Colors.black..strokeWidth = 2);
  final ac = 0.25 + 0.5 * sw;
  final off = led ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);
  final sc = Color.lerp(off, const Color(0xFF22CC22), sw)!;
  final sTop = _quad(p(-0.2, ac - 0.2, 1.045), p(0.2, ac - 0.2, 1.045), p(0.2, ac + 0.2, 1.045), p(-0.2, ac + 0.2, 1.045));
  canvas.drawPath(
    _quad(p(-0.2, ac + 0.2, 1.045), p(0.2, ac + 0.2, 1.045), p(0.2, ac + 0.2, 0.86), p(-0.2, ac + 0.2, 0.86)),
    Paint()..color = labShade(sc, -0.35),
  );
  canvas.drawPath(sTop, Paint()..shader = _metal(sTop.getBounds(), sc));
  for (final k in [-0.1, 0.0, 0.1]) {
    canvas.drawLine(p(-0.15, ac + k, 1.045), p(0.15, ac + k, 1.045),
        Paint()..color = labShade(sc, -0.45)..strokeWidth = 1.2);
  }
  if (hint && level <= 0) {
    final pulse = 0.5 + 0.5 * math.sin(t * 4 + i);
    final r = Rect.fromPoints(p(-0.55, -0.25, 1.1), p(0.55, 1.15, 0.8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(r.inflate(4 + 4 * pulse), const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.zslYellow.withValues(alpha: 0.35 + 0.5 * pulse),
    );
  }

  // ---- Head: flare + straight top.
  _torchSeg(canvas, i, 1.0, 2.0, 0.9, 1.6, silver);
  _torchSeg(canvas, i, 2.0, 2.6, 1.6, 1.6, silver);

  // ---- Reflector seen through the open front.
  final front = Rect.fromCenter(center: p(0, 2.6, 0), width: 3.0 * u, height: 3.0 * u * _G.tRy);
  canvas.drawOval(
    Rect.fromCenter(center: front.center, width: 3.2 * u, height: 3.2 * u * _G.tRy),
    Paint()..color = const Color(0xFFF8FAFC),
  );
  canvas.save();
  canvas.clipPath(Path()..addOval(front));
  final rb = led ? 0.8 : 0.4;
  final throat = q(0, 1.4, 0);
  canvas.drawOval(
    front,
    Paint()
      ..shader = RadialGradient(
        center: Alignment(0, (throat.dy - front.center.dy) / (front.height / 2)),
        radius: 1.1,
        colors: const [Color(0xFFE2E8F0), Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF8B98AA)],
        stops: const [0, 0.32, 0.72, 1],
      ).createShader(front),
  );
  for (var k = 1; k < 5; k++) {
    final a = 1.4 + 1.2 * k / 5;
    final r = rb + (1.5 - rb) * k / 5;
    canvas.drawOval(
      Rect.fromCenter(center: q(0, a, 0), width: 2 * r * u, height: 2 * r * u * _G.tRy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x3364748B),
    );
  }
  if (!led) {
    // Socket, thick wire supports, glass bulb and filament.
    canvas.drawOval(
      Rect.fromCenter(center: throat, width: 2 * rb * u, height: 2 * rb * u * _G.tRy),
      Paint()..color = const Color(0xFF374151),
    );
    final bulbC = q(0, 1.8, 0);
    final bulbR = Rect.fromCircle(center: bulbC, radius: 0.5 * u);
    canvas.drawCircle(
      bulbC,
      0.5 * u,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0x99FFFFFF), Color(0x40CBD5E1), Color(0x9964748B)],
        ).createShader(bulbR),
    );
    final sup = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(q(-0.1, 1.4, -0.05), q(-0.21, 1.8, 0.02), sup);
    canvas.drawLine(q(0.1, 1.4, -0.05), q(0.21, 1.8, 0.02), sup);
    final filPath = Path();
    for (var k = 0; k <= 12; k++) {
      final x = -0.21 + 0.42 * k / 12;
      final pt = q(x, 1.8, 0.02 + (k.isEven ? 0.04 : -0.04));
      k == 0 ? filPath.moveTo(pt.dx, pt.dy) : filPath.lineTo(pt.dx, pt.dy);
    }
    if (level > 0) labGlow(canvas, bulbC, 1.2 * u, light, intensity: level);
    canvas.drawPath(
      filPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round
        ..color = Color.lerp(const Color(0xFF333333), const Color(0xFFFFF4C2), level)!,
    );
    canvas.drawCircle(bulbC, 0.5 * u,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0xFF64748B));
    canvas.drawCircle(bulbC + Offset(-0.18 * u, -0.18 * u), 0.08 * u, Paint()..color = Colors.white.withValues(alpha: 0.7));
  } else {
    // Circuit board with a central chip and 8 tiny LEDs (no filament).
    final board = Rect.fromCenter(center: q(0, 1.35, 0), width: 1.5 * u, height: 1.5 * u * _G.tRy);
    canvas.drawOval(
      board,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFFE5E5E5), Color(0xFFCCCCCC), Color(0xFF9CA3AF)])
            .createShader(board),
    );
    canvas.drawOval(board.deflate(5), Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x5564748B));
    canvas.drawRect(
      Rect.fromCenter(center: q(0, 1.38, 0), width: 0.3 * u, height: 0.3 * u * _G.tRy),
      Paint()..color = const Color(0xFF111111),
    );
    for (var k = 0; k < 8; k++) {
      final ang = k / 8 * math.pi * 2;
      final c = q(math.cos(ang) * 0.5, 1.38, math.sin(ang) * 0.5);
      if (level > 0) labGlow(canvas, c, 0.3 * u, light, intensity: level);
      canvas.drawRect(
        Rect.fromCenter(center: c, width: 0.13 * u, height: 0.13 * u * _G.tRy + 2),
        Paint()..color = Color.lerp(const Color(0xFF444400), const Color(0xFFB6FFB6), level)!,
      );
    }
  }
  canvas.restore();

  // ---- Glass cover (0xffffff @ 0.1) with a highlight.
  final cover = Rect.fromCenter(center: p(0, 2.55, 0), width: 3.1 * u, height: 3.1 * u * _G.tRy);
  canvas.drawOval(cover, Paint()..color = Colors.white.withValues(alpha: 0.08));
  canvas.drawArc(
    cover.deflate(6),
    math.pi * 1.05,
    math.pi * 0.45,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.45),
  );
  canvas.drawOval(
    Rect.fromCenter(center: front.center, width: 3.2 * u, height: 3.2 * u * _G.tRy),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF94A3B8),
  );
}

/// The separate battery caps (HTML capGroup): red / blue shell with a
/// black base; a spring and brass tip (incandescent) or a flat contact (LED).
void _drawCap(Canvas canvas, int i) {
  final led = i == 1;
  const u = _G.tU;
  final c = _G.capCenter(i);
  final shell = led ? const Color(0xFF2563EB) : const Color(0xFFDC2626);
  const r = 0.75 * u;
  labGroundShadow(canvas, c + const Offset(-10, r * 0.8), 2.4 * r, 0.6 * r, opacity: 0.35);
  final back = Rect.fromCenter(center: c + const Offset(0, -0.17 * u), width: 2 * r, height: 1.6 * r);
  final open = Rect.fromCenter(center: c + const Offset(0, 0.17 * u), width: 2 * r, height: 1.6 * r);
  final outer = Path.combine(
    PathOperation.union,
    Path.combine(
      PathOperation.union,
      Path()..addOval(back),
      _quad(Offset(back.left, back.center.dy), Offset(open.left, open.center.dy), Offset(open.right, open.center.dy),
          Offset(back.right, back.center.dy)),
    ),
    Path()..addOval(open),
  );
  canvas.drawPath(outer, Paint()..shader = _metal(outer.getBounds(), shell));
  canvas.drawOval(open, Paint()..color = labShade(shell, -0.5));
  final base = open.deflate(5).shift(const Offset(0, -4));
  canvas.drawOval(base, Paint()..color = const Color(0xFF222222));
  if (!led) {
    for (var k = 0; k < 4; k++) {
      final rr = Rect.fromCenter(
        center: c + Offset(0, -0.06 * u + k * 0.06 * u),
        width: 0.6 * u - k * 2,
        height: 0.48 * u - k * 2,
      );
      canvas.drawOval(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..color = Color.lerp(const Color(0xFF9CA3AF), const Color(0xFFF1F5F9), k / 3)!,
      );
    }
    labSphere(canvas, c + const Offset(0, 0.12 * u), 0.15 * u, const Color(0xFFDDAA55));
  } else {
    final disk = Rect.fromCenter(center: c + const Offset(0, -0.04 * u), width: 1.0 * u, height: 0.8 * u);
    canvas.drawOval(
      disk,
      Paint()..shader = const RadialGradient(colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF94A3B8)]).createShader(disk),
    );
    canvas.drawOval(disk.deflate(6), Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x8864748B));
  }
  canvas.drawOval(
    open,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = labShade(shell, 0.3),
  );
}

/// Additive light cone (HTML volumetric cone, opacity 0.35) and the lit
/// spot on the table in front of the torch.
void _drawBeam(Canvas canvas, int i, double level, double t) {
  if (level <= 0) return;
  const u = _G.tU;
  final light = i == 1 ? const Color(0xFF00FF00) : const Color(0xFFFFDD44);
  Offset p(double x, double a, double h) => _G.tp(i, x, a, h);
  _lightPool(canvas, p(0, 6.5, -0.72), 3.4 * u, 1.5 * u, light, 0.45 * level);
  final e0 = Rect.fromCenter(center: p(0, 2.6, 0), width: 3.0 * u, height: 3.0 * u * _G.tRy);
  final e1 = Rect.fromCenter(center: p(0, 11.6, 0), width: 7.7 * u, height: 7.7 * u * _G.tRy);
  final cone = Path.combine(
    PathOperation.union,
    Path.combine(
      PathOperation.union,
      Path()..addOval(e0),
      _quad(Offset(e0.left, e0.center.dy), Offset(e1.left, e1.center.dy), Offset(e1.right, e1.center.dy),
          Offset(e0.right, e0.center.dy)),
    ),
    Path()..addOval(e1),
  );
  final b = Rect.fromLTRB(e1.left, e0.top, e1.right, e1.bottom);
  canvas.drawPath(
    cone,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          light.withValues(alpha: 0.35 * level),
          light.withValues(alpha: 0.14 * level),
          light.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(b),
  );
  canvas.drawOval(e0, Paint()..blendMode = BlendMode.plus..color = light.withValues(alpha: 0.35 * level));
  labGlow(canvas, e0.center, 2.0 * u, light, intensity: 0.55 * level);
}

// ------------------------------------------------------------ circuit

/// HTML `buildBattery()`: black holder base, brass tabs and a cell lying
/// on its side (copper 0xb87333 half, black 0x222222 half, grey + cap).
void _drawBattery(Canvas canvas) {
  const s = 1.4;
  Offset g(double x, double y, double z) => _G.w(-4.5 + x * s, 0.5 + y * s, z * s);
  const unit = _G.wU * s;

  // Brass tabs under the terminals.
  const brass = Color(0xFFB48B3B);
  for (final sx in [-1.0, 1.0]) {
    final topFace = _quad(g(sx * 2.0, 0.25, -0.3), g(sx * 2.8, 0.25, -0.3), g(sx * 2.8, 0.25, 0.3), g(sx * 2.0, 0.25, 0.3));
    canvas.drawPath(topFace, Paint()..shader = _metal(topFace.getBounds(), brass));
    canvas.drawPath(
      _quad(g(sx * 2.0, 0.25, 0.3), g(sx * 2.8, 0.25, 0.3), g(sx * 2.8, 0.15, 0.3), g(sx * 2.0, 0.15, 0.3)),
      Paint()..color = labShade(brass, -0.4),
    );
  }

  // Holder base box 4.0 x 0.6 x 1.4 (0x111111).
  final top = _quad(g(-2, 0.6, -0.7), g(2, 0.6, -0.7), g(2, 0.6, 0.7), g(-2, 0.6, 0.7));
  final front = _quad(g(-2, 0.6, 0.7), g(2, 0.6, 0.7), g(2, 0, 0.7), g(-2, 0, 0.7));
  canvas.drawPath(
    top,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1C1C1C), Color(0xFF333333)],
      ).createShader(top.getBounds()),
  );
  canvas.drawPath(
    front,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF242424), Color(0xFF0A0A0A)],
      ).createShader(front.getBounds()),
  );
  canvas.drawLine(g(-2, 0.6, 0.7), g(2, 0.6, 0.7), Paint()..color = const Color(0x55FFFFFF)..strokeWidth = 1.2);
  final groove = _quad(g(-1.95, 0.6, -0.5), g(1.95, 0.6, -0.5), g(1.95, 0.6, 0.5), g(-1.95, 0.6, 0.5));
  canvas.drawPath(groove, Paint()..color = const Color(0xFF050505));

  // The cell (r 0.65 along x, centre y 1.1).
  final cy = g(0, 1.1, 0).dy;
  final rr = 0.65 * unit * 1.08;
  Rect half(double x0, double x1) => Rect.fromLTRB(g(x0, 0, 0).dx, cy - rr, g(x1, 0, 0).dx, cy + rr);
  Shader roll(Rect r, Color c) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [labShade(c, 0.15), labShade(c, 0.5), c, labShade(c, -0.55)],
        stops: const [0, 0.25, 0.55, 1],
      ).createShader(r);
  const copper = Color(0xFFB87333);
  const black = Color(0xFF222222);
  final capR = Rect.fromLTRB(g(-2.05, 0, 0).dx, cy - 0.2 * unit, g(-1.85, 0, 0).dx, cy + 0.2 * unit);
  canvas.drawRRect(RRect.fromRectAndRadius(capR, const Radius.circular(4)), Paint()..shader = roll(capR, const Color(0xFF9CA3AF)));
  final left = half(-1.9, 0);
  final right = half(0, 1.9);
  canvas.drawRRect(
    RRect.fromRectAndCorners(left, topLeft: const Radius.circular(6), bottomLeft: const Radius.circular(6)),
    Paint()..shader = roll(left, copper),
  );
  canvas.drawRRect(
    RRect.fromRectAndCorners(right, topRight: const Radius.circular(6), bottomRight: const Radius.circular(6)),
    Paint()..shader = roll(right, black),
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(right.right - 3, cy), width: 8, height: rr * 2),
    Paint()..color = const Color(0xFF3A3A3A),
  );
  canvas.drawLine(Offset(left.right, cy - rr), Offset(left.right, cy + rr), Paint()..color = const Color(0x66000000)..strokeWidth = 2);
}

/// Upright cylinder in the scenario 2 view (bottom / top centres given).
void _upCyl(Canvas canvas, Offset bottom, double topY, double r, Color c) {
  labCylinder(canvas, Rect.fromLTRB(bottom.dx - r, topY, bottom.dx + r, bottom.dy), c, tilt: _G.wSp);
}

/// HTML scenario 2 lamp: holder base, brass tabs, socket and the bulb.
void _drawLampHolder(Canvas canvas, double glow) {
  const s = 1.8;
  Offset g(double x, double y, double z) => _G.w(4.5 + x * s, 0.1 + y * s, z * s);
  const unit = _G.wU * s;

  _upCyl(canvas, g(0, 0, 0), g(0, 0.3, 0).dy, 1.6 * unit, const Color(0xFF1F2937));
  canvas.drawOval(
    Rect.fromCenter(center: g(0, 0.3, 0), width: 3.2 * unit, height: 3.2 * unit * _G.wSp),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x55FFFFFF),
  );
  const brass = Color(0xFFB48B3B);
  for (final sx in [-1.0, 1.0]) {
    final tab = _quad(g(sx * 1.1, 0.33, -0.3), g(sx * 1.7, 0.33, -0.3), g(sx * 1.7, 0.33, 0.3), g(sx * 1.1, 0.33, 0.3));
    canvas.drawPath(tab, Paint()..shader = _metal(tab.getBounds(), brass));
  }
  final socketTop = g(0, 0.75, 0);
  _upCyl(canvas, g(0, 0.3, 0), socketTop.dy, 0.8 * unit, const Color(0xFF111827));
  final hole = Rect.fromCenter(center: socketTop, width: 1.25 * unit, height: 1.25 * unit * _G.wSp);
  canvas.drawOval(hole, Paint()..color = const Color(0xFF030712));

  // Bulb (offset 0.8), its screw case partly hidden inside the socket.
  canvas.save();
  canvas.clipPath(
    Path.combine(
      PathOperation.union,
      Path()..addRect(Rect.fromLTRB(-2000, -2000, 3000, socketTop.dy)),
      Path()..addOval(hole),
    ),
  );
  _drawBulb(canvas, g(0, 0, 0), unit, b: 0.8, glow: glow);
  canvas.restore();
}

/// HTML `createTerminal()`: metal screw (0x9ca3af) with a coloured ring
/// (red +, green -, white lamp). Selected: yellow, 1.5x (`highlightTerminal`).
void _drawTerminal(Canvas canvas, String id, bool selected, double t) {
  final c = _G.terminal(id);
  final isPos = id == 'bat_pos', isNeg = id == 'bat_neg';
  final unit = _G.wU * (id.startsWith('bat') ? 1.4 : 1.8);
  final k = selected ? 1.5 : 1.0;
  final ring = selected
      ? _Colors.zslYellow
      : (isPos ? const Color(0xFFEF4444) : (isNeg ? const Color(0xFF22C55E) : Colors.white));
  if (selected) {
    labGlow(canvas, c, 0.9 * unit, _Colors.zslYellow, intensity: 0.55 + 0.25 * math.sin(t * 6));
  }
  final ringRect = Rect.fromCenter(
    center: c + Offset(0, 0.06 * unit),
    width: 0.68 * unit * k,
    height: 0.68 * unit * k * _G.wSp,
  );
  canvas.drawOval(
    ringRect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.07 * unit
      ..color = ring.withValues(alpha: selected ? 0.95 : 0.75),
  );
  final r = 0.25 * unit * k;
  final h = 0.15 * unit * k;
  final metal = selected ? Color.lerp(const Color(0xFF9CA3AF), _Colors.zslYellow, 0.6)! : const Color(0xFF9CA3AF);
  labCylinder(canvas, Rect.fromLTRB(c.dx - r, c.dy - h, c.dx + r, c.dy + 0.04 * unit), metal, tilt: _G.wSp);
  final cap = Rect.fromCenter(center: Offset(c.dx, c.dy - h), width: 2 * r, height: 2 * r * _G.wSp);
  canvas.drawOval(
    cap,
    Paint()..shader = RadialGradient(colors: [labShade(metal, 0.5), metal, labShade(metal, -0.3)]).createShader(cap),
  );
  canvas.drawLine(
    Offset(cap.left + r * 0.45, cap.center.dy),
    Offset(cap.right - r * 0.45, cap.center.dy),
    Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = math.max(1.5, r * 0.18)
      ..strokeCap = StrokeCap.round,
  );
}

/// HTML `createWire()` tube (0x00e5ff, radius 0.08), drawn in from the
/// first terminal as [progress] goes 0 -> 1.
void _drawWire(Canvas canvas, _Wire w, double progress) {
  final pts3 = _G.wirePoints(w.a, w.b);
  final count = math.max(2, (pts3.length * progress).ceil());
  final path = Path();
  final shadow = Path();
  for (var k = 0; k < count && k < pts3.length; k++) {
    final q = pts3[k];
    final sp = _G.w(q[0], q[1], q[2]);
    final sh = _G.w(q[0] - 0.35, 0, q[2] - 0.35);
    if (k == 0) {
      path.moveTo(sp.dx, sp.dy);
      shadow.moveTo(sh.dx, sh.dy);
    } else {
      path.lineTo(sp.dx, sp.dy);
      shadow.lineTo(sh.dx, sh.dy);
    }
  }
  Paint s(Color c, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;
  const d = 0.16 * _G.wU;
  canvas.drawPath(shadow, s(Colors.black.withValues(alpha: 0.28), d)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  canvas.drawPath(path, s(const Color(0xFF0E7490), d + 2.5));
  canvas.drawPath(path, s(const Color(0xFF00E5FF), d));
  canvas.drawPath(path.shift(const Offset(0, -1.6)), s(Colors.white.withValues(alpha: 0.55), d * 0.28));
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
