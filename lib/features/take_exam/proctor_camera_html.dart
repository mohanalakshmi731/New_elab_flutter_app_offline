/// The self-contained page hosted by `ProctorCameraView`: it owns the
/// browser-only parts of `ExamProctorPanel.vue` — `getUserMedia`, the
/// `<video>` preview, canvas frame capture (`toDataURL('image/jpeg', 0.78)`),
/// the Web-Audio analyser and the `MediaRecorder` — and nothing else. All
/// proctoring decisions (what is sent to the AI service, when, and how the
/// answers become warnings) are made in Dart.
///
/// Dart → page: `window.proctor.run(method, id, args)` / `proctor.capture(id)`
/// via `evaluateJavascript`.
/// Page → Dart (`window.flutter_inappwebview.callHandler`):
/// * `ready`   `{secure, media, online}` once the bridge is up,
/// * `result`  `{id, ok, value, error}` for `run`,
/// * `frame`   `{id, ok, dataUrl, width, height, sums, error}` for `capture`,
/// * `chunk`   `{type, data(base64)}` for every recorder chunk,
/// * `network` `{online}` on `window` `online` / `offline`.
library;

const proctorCameraHtml = r'''<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<title>Proctor camera</title>
<style>
  html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: #0f1117;
    -webkit-user-select: none; user-select: none; -webkit-touch-callout: none; }
  video { display: block; width: 100%; height: 100%; object-fit: cover; background: #0f1117; }
</style>
</head>
<body>
<video id="video" autoplay muted playsinline></video>
<script>
(function () {
  'use strict';
  var video = document.getElementById('video');
  var stream = null;
  var recorder = null;
  var audioContext = null;
  var audioSource = null;
  var audioAnalyser = null;
  var finished = false;

  function send(name, payload) {
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler(name, payload);
      }
    } catch (e) { /* bridge gone */ }
  }

  // `error instanceof Error ? error.message : <Dart fallback>`
  function errMsg(error) {
    var isError = error instanceof Error ||
      (typeof DOMException !== 'undefined' && error instanceof DOMException);
    return isError ? String(error.message) : null;
  }

  function videoConstraints() {
    return { width: { ideal: 640 }, height: { ideal: 480 }, facingMode: 'user' };
  }

  function stopTracks() {
    if (stream) stream.getTracks().forEach(function (track) { track.stop(); });
    stream = null;
  }

  function stopAudioMonitor() {
    if (audioContext && audioContext.state !== 'closed') {
      audioContext.close().catch(function () {});
    }
    audioContext = null;
    audioSource = null;
    audioAnalyser = null;
  }

  // startAudioMonitor(): 'ready' | 'unavailable' | 'unsupported'
  function startAudioMonitor() {
    stopAudioMonitor();
    var audioTracks = stream ? stream.getAudioTracks() : [];
    if (!audioTracks.length) return 'unavailable';
    var AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (!AudioContextClass) return 'unsupported';
    audioContext = new AudioContextClass();
    audioSource = audioContext.createMediaStreamSource(new MediaStream(audioTracks));
    audioAnalyser = audioContext.createAnalyser();
    audioAnalyser.fftSize = 2048;
    audioAnalyser.smoothingTimeConstant = 0.25;
    audioSource.connect(audioAnalyser);
    return 'ready';
  }

  // startCamera(): video + audio first, video only when that fails.
  async function start() {
    var micFailed = false;
    var micError = null;
    try {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Camera access is not supported in this browser');
      }
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: videoConstraints(),
          audio: { echoCancellation: false, noiseSuppression: false, autoGainControl: true }
        });
      } catch (error) {
        micFailed = true;
        micError = errMsg(error);
        stream = await navigator.mediaDevices.getUserMedia({ video: videoConstraints(), audio: false });
      }
      if (finished) {
        stopTracks();
        return { ok: true, finished: true, micFailed: micFailed, micError: micError };
      }
      video.srcObject = stream;
      await video.play();
      var audio = startAudioMonitor();
      return { ok: true, finished: false, micFailed: micFailed, micError: micError, audio: audio };
    } catch (error) {
      return { ok: false, error: errMsg(error), micFailed: micFailed, micError: micError };
    }
  }

  function withTimeout(promise, ms) {
    return new Promise(function (resolve, reject) {
      var timer = setTimeout(function () { reject(new Error('timeout')); }, ms);
      promise.then(function (v) { clearTimeout(timer); resolve(v); },
                   function (e) { clearTimeout(timer); reject(e); });
    });
  }

  // resumeAudioMonitor(). Without a click inside the page some engines never
  // settle resume(), so it is bounded.
  async function resumeAudio() {
    var failed = false;
    if (audioContext && audioContext.state === 'suspended') {
      try { await withTimeout(audioContext.resume(), 1500); } catch (e) { failed = true; }
    }
    return { failed: failed, state: audioContext ? audioContext.state : null };
  }

  function b64(bytes) {
    var s = '';
    for (var i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
    return btoa(s);
  }

  // The analyser snapshot analyzeAudioWindow() works on.
  async function sampleAudio() {
    if (!audioAnalyser || !audioContext) return { available: false };
    var resumed = await resumeAudio();
    if (!audioContext || !audioAnalyser || audioContext.state !== 'running') {
      return { available: true, resumeFailed: resumed.failed, running: false };
    }
    var timeData = new Uint8Array(audioAnalyser.fftSize);
    var frequencyData = new Uint8Array(audioAnalyser.frequencyBinCount);
    audioAnalyser.getByteTimeDomainData(timeData);
    audioAnalyser.getByteFrequencyData(frequencyData);
    return {
      available: true, resumeFailed: resumed.failed, running: true,
      sampleRate: audioContext.sampleRate, fftSize: audioAnalyser.fftSize,
      time: b64(timeData), freq: b64(frequencyData)
    };
  }

  function tracks() {
    var list = stream ? stream.getAudioTracks() : [];
    return {
      hasStream: !!stream,
      count: list.length,
      tracks: list.map(function (t) { return { label: t.label, enabled: t.enabled, muted: t.muted }; })
    };
  }

  function supportedRecordingMimeType() {
    var candidates = [
      'video/webm;codecs=vp9,opus',
      'video/webm;codecs=vp8,opus',
      'video/webm;codecs=vp9',
      'video/webm;codecs=vp8',
      'video/webm'
    ];
    for (var i = 0; i < candidates.length; i++) {
      try { if (MediaRecorder.isTypeSupported(candidates[i])) return candidates[i]; } catch (e) {}
    }
    return '';
  }

  // startRecording(): 5 s chunks are handed to Dart, which uploads them.
  function startRecording() {
    if (!stream || typeof MediaRecorder === 'undefined') return { created: false, skipped: true };
    var mimeType = supportedRecordingMimeType();
    try {
      recorder = new MediaRecorder(stream, mimeType ? { mimeType: mimeType } : undefined);
      recorder.ondataavailable = function (event) {
        if (!event.data || !event.data.size) return;
        var type = event.data.type;
        var reader = new FileReader();
        reader.onloadend = function () {
          var result = String(reader.result || '');
          var comma = result.indexOf(',');
          send('chunk', { type: type, data: comma >= 0 ? result.substring(comma + 1) : '' });
        };
        reader.readAsDataURL(event.data);
      };
      recorder.start(5000);
      return { created: true, state: recorder.state };
    } catch (error) {
      return { created: !!recorder, state: recorder ? recorder.state : null, error: errMsg(error), failed: true };
    }
  }

  // finish(): analyser, recorder, tracks.
  function stop() {
    finished = true;
    stopAudioMonitor();
    var recorderError;
    if (recorder && recorder.state !== 'inactive') {
      try { recorder.stop(); } catch (error) { recorderError = errMsg(error) || ''; }
    }
    stopTracks();
    return { recorderError: recorderError === undefined ? null : recorderError, recorderFailed: recorderError !== undefined };
  }

  function capture(id) {
    try {
      if (!video || !video.videoWidth || !video.videoHeight) throw new Error('Camera frame is not ready');
      var width = Math.min(640, video.videoWidth);
      var height = Math.round((video.videoHeight / video.videoWidth) * width);
      var canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      var context = canvas.getContext('2d');
      if (!context) throw new Error('Unable to capture camera frame');
      context.drawImage(video, 0, 0, width, height);
      var data = context.getImageData(0, 0, width, height).data;
      var sums = [];
      for (var y = 0; y < height; y += 8) {
        for (var x = 0; x < width; x += 8) {
          var o = (y * width + x) * 4;
          sums.push(data[o] + data[o + 1] + data[o + 2]);
        }
      }
      send('frame', {
        id: id, ok: true, dataUrl: canvas.toDataURL('image/jpeg', 0.78),
        width: width, height: height, sums: sums
      });
    } catch (error) {
      send('frame', { id: id, ok: false, error: errMsg(error) });
    }
  }

  var api = {
    start: start,
    resumeAudio: resumeAudio,
    sampleAudio: sampleAudio,
    tracks: tracks,
    startRecording: startRecording,
    stop: stop
  };

  window.proctor = {
    run: function (method, id, args) {
      Promise.resolve()
        .then(function () { return api[method](args); })
        .then(function (value) { send('result', { id: id, ok: true, value: value === undefined ? null : value }); },
              function (error) { send('result', { id: id, ok: false, error: errMsg(error) }); });
    },
    capture: capture
  };

  window.addEventListener('online', function () { send('network', { online: true }); });
  window.addEventListener('offline', function () { send('network', { online: false }); });
  document.addEventListener('contextmenu', function (e) { e.preventDefault(); });

  var booted = false;
  function boot() {
    if (booted) return;
    booted = true;
    send('ready', {
      secure: !!window.isSecureContext,
      media: !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia),
      online: navigator.onLine !== false
    });
  }
  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) boot();
  window.addEventListener('flutterInAppWebViewPlatformReady', boot);
})();
</script>
</body>
</html>
''';
