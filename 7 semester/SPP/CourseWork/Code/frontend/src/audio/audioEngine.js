import * as Tone from 'tone';

let micStream = null;
let sourceNode = null;
let filterNodes = [];
let analyserNode = null;
let timeDomainBuffer = null;
let frequencyBuffer = null;

const MIC_REQUEST_TIMEOUT_MS = 12000;

export async function ensureAudio() {
  await Tone.start();

  const ctx = Tone.getContext().rawContext;
  if (ctx.state !== 'running') {
    await ctx.resume();
  }

  return ctx;
}

export function getAudioContext() {
  return Tone.getContext().rawContext;
}

export async function enableMic() {
  const ctx = await ensureAudio();

  if (micStream?.active && analyserNode) {
    return analyserNode;
  }

  if (micStream) {
    releaseMic();
  }

  const constraints = {
    audio: {
      echoCancellation: false,
      noiseSuppression: false,
      autoGainControl: false,
      channelCount: 1,
    },
  };

  let timedOut = false;
  const request = navigator.mediaDevices.getUserMedia(constraints);
  const timeout = new Promise((_, reject) => {
    setTimeout(() => {
      timedOut = true;
      const error = new Error('Браузер не ответил на запрос доступа к микрофону');
      error.name = 'MicTimeoutError';
      reject(error);
    }, MIC_REQUEST_TIMEOUT_MS);
  });

  try {
    micStream = await Promise.race([request, timeout]);
  } finally {
    if (timedOut) {
      request
        .then((stream) => stream.getTracks().forEach((track) => track.stop()))
        .catch(() => {});
    }
  }

  sourceNode = ctx.createMediaStreamSource(micStream);

  const highpass = ctx.createBiquadFilter();
  highpass.type = 'highpass';
  highpass.frequency.value = 70;
  highpass.Q.value = 0.707;

  const lowpass = ctx.createBiquadFilter();
  lowpass.type = 'lowpass';
  lowpass.frequency.value = 1800;
  lowpass.Q.value = 0.707;

  filterNodes = [highpass, lowpass];

  analyserNode = ctx.createAnalyser();
  analyserNode.fftSize = 8192;
  analyserNode.smoothingTimeConstant = 0;
  analyserNode.minDecibels = -100;
  analyserNode.maxDecibels = -10;

  sourceNode.connect(highpass);
  highpass.connect(lowpass);
  lowpass.connect(analyserNode);

  timeDomainBuffer = new Float32Array(analyserNode.fftSize);
  frequencyBuffer = new Float32Array(analyserNode.frequencyBinCount);

  return analyserNode;
}

export function getAnalyser() {
  return analyserNode;
}

export function getTimeDomainBuffer() {
  return timeDomainBuffer;
}

export function getFrequencyBuffer() {
  return frequencyBuffer;
}

export function getSampleRate() {
  return getAudioContext()?.sampleRate ?? 48000;
}

export function isMicActive() {
  return Boolean(micStream?.active && analyserNode);
}

export function getLevel() {
  if (!analyserNode || !timeDomainBuffer) {
    return { rms: 0, db: -Infinity, normalized: 0 };
  }

  analyserNode.getFloatTimeDomainData(timeDomainBuffer);

  let sum = 0;
  for (let i = 0; i < timeDomainBuffer.length; i++) {
    sum += timeDomainBuffer[i] * timeDomainBuffer[i];
  }

  const rms = Math.sqrt(sum / timeDomainBuffer.length);
  const db = rms > 0 ? 20 * Math.log10(rms) : -Infinity;

  const normalized = Number.isFinite(db)
    ? Math.max(0, Math.min(1, (db + 60) / 60))
    : 0;

  return { rms, db, normalized };
}

export function releaseMic() {
  if (filterNodes.length) {
    filterNodes.forEach((node) => {
      try {
        node.disconnect();
      } catch {
      }
    });
    filterNodes = [];
  }

  if (sourceNode) {
    try {
      sourceNode.disconnect();
    } catch {
    }
    sourceNode = null;
  }

  if (micStream) {
    micStream.getTracks().forEach((track) => track.stop());
    micStream = null;
  }

  analyserNode = null;
  timeDomainBuffer = null;
  frequencyBuffer = null;
}
