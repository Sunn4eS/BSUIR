export function createPluckGate(options = {}) {
  const {
    attackSeconds = 0.02,
    noiseSeconds = 1.5,
    gateDb = 6,
    holdMs = 150,
    minNoiseRms = 0.002,
    maxNoiseRms = 0.1,
  } = options;

  let attackAlpha = 0.3;
  let noiseAlpha = 0.02;

  let fastRms = 0;
  let noiseRms = minNoiseRms;
  let isOpen = false;
  let lastLoudAt = -Infinity;
  let lastOnsetAt = -Infinity;
  let lastFrameAt = -Infinity;
  let onsetCount = 0;

  function openThreshold() {
    const boosted = noiseRms * Math.pow(10, gateDb / 20);
    return Math.min(Math.max(boosted, minNoiseRms * 4), maxNoiseRms);
  }

  function push(rms, nowMs = Date.now()) {
    const dt = lastFrameAt === -Infinity ? 0.05 : Math.max(0, (nowMs - lastFrameAt) / 1000);
    lastFrameAt = nowMs;

    if (dt > 0) {
      attackAlpha = 1 - Math.exp(-dt / attackSeconds);
      noiseAlpha = 1 - Math.exp(-dt / noiseSeconds);
    }

    fastRms = fastRms + attackAlpha * (rms - fastRms);

    if (rms > noiseRms) {
      noiseRms = Math.min(noiseRms + noiseAlpha * (rms - noiseRms), maxNoiseRms);
    } else {
      noiseRms = Math.max(noiseRms * 0.99, minNoiseRms);
    }

    const threshold = openThreshold();

    if (fastRms >= noiseRms) {
      lastLoudAt = nowMs;
    }

    const isOnset = !isOpen && fastRms >= threshold;
    if (isOnset) {
      isOpen = true;
      lastOnsetAt = nowMs;
      onsetCount += 1;
    } else if (isOpen && nowMs - lastLoudAt > holdMs) {
      isOpen = false;
    }

    return { isOpen, isOnset, rms, fastRms, noiseRms, openThreshold: threshold, lastOnsetAt };
  }

  function reset() {
    fastRms = 0;
    noiseRms = minNoiseRms;
    isOpen = false;
    lastLoudAt = -Infinity;
    lastOnsetAt = -Infinity;
    lastFrameAt = -Infinity;
    onsetCount = 0;
  }

  function getState() {
    return {
      isOpen,
      fastRms,
      noiseRms,
      openThreshold: openThreshold(),
      lastOnsetAt,
      onsetCount,
    };
  }

  return { push, reset, getState };
}
