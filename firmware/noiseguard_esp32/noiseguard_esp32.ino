/*
 * NoiseGuard ESP32 Firmware v9.0 (TinyML FFT Spectral Sound Classifier)
 * Author: Vanjara Bipin Rajubhai
 *
 * Real Edge-AI Sound Classification Pipeline:
 *   I2S Audio -> 512-pt FFT -> Spectral Feature Extraction -> Decision Tree Classifier
 *
 * Classified Sound Categories:
 *   1. Quiet Ambient   - Low energy across all bands
 *   2. Traffic          - Dominant low-frequency rumble (< 500 Hz)
 *   3. Horn             - Strong mid-frequency tonal peak (300-1200 Hz)
 *   4. Siren            - High ZCR + high spectral centroid + energy spread
 *   5. Construction     - Broadband impulsive (high crest factor + flat spectrum)
 *   6. Crowd / Speech   - Mid-frequency energy (300-3000 Hz), moderate ZCR
 *   7. Music / DJ       - Structured harmonic content, balanced energy
 *
 * Hardware: INMP441 MEMS Mic -> ESP32 (I2S) -> GPIO 32/25/33
 */

#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <driver/i2s.h>
#include <ArduinoJson.h>
#include <arduinoFFT.h>
#include <time.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

// ── Wi-Fi & Firebase ──────────────────────────────────────────
char wifiSSID[64]     = "vivoy200";
char wifiPassword[64] = "77777777";

const char* DEVICE_ID     = "NG-ESP32-001";
const char* LOCATION_NAME = "SG Highway, Ahmedabad";
const double FIXED_LAT    = 23.0301;
const double FIXED_LNG    = 72.5274;

const char* FIREBASE_PROJECT_ID = "noiseguard-9c13c";
const char* FIREBASE_API_KEY    = "AIzaSyDmgi5K0kqzrFWbU2MP3zzA7lZTYe_DRA0";

String rtdbUrl = String("https://") + FIREBASE_PROJECT_ID +
                 "-default-rtdb.firebaseio.com/telemetry/" + DEVICE_ID + ".json";
String firestoreUrl = String("https://firestore.googleapis.com/v1/projects/") +
                      FIREBASE_PROJECT_ID + "/databases/(default)/documents/noise_records/" +
                      DEVICE_ID + "?key=" + FIREBASE_API_KEY;
String firestoreAlertsUrl = String("https://firestore.googleapis.com/v1/projects/") +
                            FIREBASE_PROJECT_ID + "/databases/(default)/documents/alerts?key=" +
                            FIREBASE_API_KEY;

// ── Pin Definitions ───────────────────────────────────────────
#define I2S_SD_PIN      32
#define I2S_WS_PIN      25
#define I2S_SCK_PIN     33
#define LED_RED_PIN     18
#define LED_GREEN_PIN   19
#define BUZZER_PIN      21

// ── I2S & FFT Constants ──────────────────────────────────────
#define I2S_PORT        I2S_NUM_0
#define SAMPLE_RATE     16000
#define FFT_SIZE        512
#define FREQ_BIN_WIDTH  (SAMPLE_RATE / FFT_SIZE)   // 31.25 Hz per bin

// ── Frequency Band Bin Indices (at 16 kHz / 512 samples) ─────
#define AUDIBLE_START 2   //   62.5 Hz (ignores subsonic DC drift)
#define LOW_START   2     //   62.5 Hz
#define LOW_END     16    //  500 Hz
#define MID_START   17    //  531 Hz
#define MID_END     96    // 3000 Hz
#define HIGH_START  97    // 3031 Hz
#define HIGH_END    200   // 6250 Hz

// ── Calibration & Thresholds ──────────────────────────────────
const float DB_CALIBRATION_OFFSET = -14.0f; // Calibrated SPL: 40-45dB Quiet, 55-65dB Voice, 75-90dB Loud
float noiseThreshold = 65.0;
unsigned long lastPayloadTime       = 0;
unsigned long lastAlertDispatchTime = 0;
unsigned long lastWifiRetry         = 0;
const unsigned long SEND_INTERVAL_MS = 2000;

WiFiClientSecure secureClient;

double vReal[FFT_SIZE];
double vImag[FFT_SIZE];
ArduinoFFT<double> FFT = ArduinoFFT<double>(vReal, vImag, FFT_SIZE, SAMPLE_RATE);

// ── Classification Result ─────────────────────────────────────
struct SoundClassification {
  float    dbLevel;
  float    zcr;
  float    crestFactor;
  float    spectralCentroid;   // Hz – "center of mass" of the spectrum
  float    spectralRolloff;    // Hz – frequency below which 85% energy sits
  float    spectralFlatness;   // 0..1 – 0 = tonal, 1 = noisy/white
  float    lowBandEnergy;      // fractional energy in  62–500 Hz
  float    midBandEnergy;      // fractional energy in 531–3000 Hz
  float    highBandEnergy;     // fractional energy in 3031–6250 Hz
  String   predictedClass;
  float    confidence;
};

SoundClassification windowPeakCls;

// ── Prototypes ────────────────────────────────────────────────
void setupI2S();
SoundClassification classifySound();
void sendTelemetryToCloud(const SoundClassification& cls, bool isViolation);
void checkAlerts(float dbLevel, bool isViolation);

// ==============================================================
//                            SETUP
// ==============================================================
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
  Serial.begin(115200);
  delay(500);

  Serial.println("\n============================================================");
  Serial.println("  NoiseGuard ESP32 v9.2 – Calibrated SPL & Peak Tracking   ");
  Serial.println("============================================================");

  windowPeakCls.dbLevel = 0.0f;

  pinMode(LED_RED_PIN,   OUTPUT);
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(BUZZER_PIN,    OUTPUT);
  digitalWrite(LED_RED_PIN,   LOW);
  digitalWrite(LED_GREEN_PIN, LOW);
  digitalWrite(BUZZER_PIN,    LOW);

  WiFi.persistent(true);
  WiFi.setAutoReconnect(true);
  WiFi.mode(WIFI_STA);
  WiFi.setTxPower(WIFI_POWER_15dBm);

  secureClient.setInsecure();
  secureClient.setTimeout(3);

  Serial.printf("[WIFI] Connecting to '%s'...\n", wifiSSID);
  WiFi.begin(wifiSSID, wifiPassword);
  for (int i = 0; WiFi.status() != WL_CONNECTED && i < 20; i++) {
    delay(500);
    Serial.print(".");
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("\n[WIFI] Connected! IP: %s\n", WiFi.localIP().toString().c_str());
    digitalWrite(LED_GREEN_PIN, HIGH);
    configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  } else {
    Serial.println("\n[WIFI] Pending background connection...");
  }

  setupI2S();
  Serial.println("[DSP]  FFT engine ready – 512-pt @ 16 kHz (31.25 Hz/bin)");
}

// ==============================================================
//                          MAIN LOOP
// ==============================================================
void loop() {
  // Wi-Fi reconnect (non-blocking)
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_GREEN_PIN, LOW);
    if (millis() - lastWifiRetry > 5000) {
      lastWifiRetry = millis();
      WiFi.reconnect();
    }
  } else {
    digitalWrite(LED_GREEN_PIN, HIGH);
  }

  // 1. Continuously sample the INMP441 via classifySound() (blocks ~32ms on I2S DMA)
  SoundClassification cls = classifySound();

  // 2. Trigger real-time physical actuators immediately if a violation is detected
  bool isViolation = (cls.dbLevel > noiseThreshold);
  checkAlerts(cls.dbLevel, isViolation);

  // 3. Compare current reading against windowPeakCls and store the louder classification
  if (cls.dbLevel > windowPeakCls.dbLevel) {
    windowPeakCls = cls;
  }

  // 4. When SEND_INTERVAL_MS expires, transmit windowPeakCls to cloud
  if (millis() - lastPayloadTime >= SEND_INTERVAL_MS) {
    lastPayloadTime = millis();
    SoundClassification sendCls = (windowPeakCls.dbLevel > 0) ? windowPeakCls : cls;
    bool isPeakViolation = (sendCls.dbLevel > noiseThreshold);

    if (WiFi.status() == WL_CONNECTED) {
      sendTelemetryToCloud(sendCls, isPeakViolation);
    } else {
      Serial.printf("[OFFLINE PEAK] %.1f dB | %s (SC:%.0f RF:%.0f LMH:%.0f/%.0f/%.0f%%)\n",
                    sendCls.dbLevel, sendCls.predictedClass.c_str(),
                    sendCls.spectralCentroid, sendCls.spectralRolloff,
                    sendCls.lowBandEnergy * 100, sendCls.midBandEnergy * 100, sendCls.highBandEnergy * 100);
    }

    // 5. Reset windowPeakCls.dbLevel = 0 for the next interval
    windowPeakCls.dbLevel = 0.0f;
  }
}

// ==============================================================
//                         I2S SETUP
// ==============================================================
void setupI2S() {
  i2s_config_t cfg = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = i2s_comm_format_t(I2S_COMM_FORMAT_I2S | I2S_COMM_FORMAT_I2S_MSB),
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 8,
    .dma_buf_len   = FFT_SIZE,
    .use_apll = false,
    .tx_desc_auto_clear = false,
    .fixed_mclk = 0
  };
  i2s_pin_config_t pins = {
    .bck_io_num   = I2S_SCK_PIN,
    .ws_io_num    = I2S_WS_PIN,
    .data_out_num = I2S_PIN_NO_CHANGE,
    .data_in_num  = I2S_SD_PIN
  };
  i2s_driver_install(I2S_PORT, &cfg, 0, NULL);
  i2s_set_pin(I2S_PORT, &pins);
  i2s_start(I2S_PORT);
}

// ==============================================================
//      CORE DSP PIPELINE: I2S -> FFT -> Features -> Classify
// ==============================================================
SoundClassification classifySound() {
  int32_t rawSamples[FFT_SIZE];
  size_t  bytesRead = 0;
  SoundClassification cls;

  // ── 1. Read I2S audio block ─────────────────────────────────
  esp_err_t err = i2s_read(I2S_PORT, rawSamples, sizeof(rawSamples), &bytesRead, portMAX_DELAY);
  int N = bytesRead / sizeof(int32_t);
  if (err != ESP_OK || N == 0) {
    cls.dbLevel = 30.0; cls.predictedClass = "Error"; cls.confidence = 0;
    return cls;
  }

  // ── 2. Convert 32-bit I2S -> 16-bit PCM, remove DC offset ──
  double dcSum = 0;
  for (int i = 0; i < N; i++) {
    vReal[i] = (double)((int16_t)(rawSamples[i] >> 16));
    dcSum += vReal[i];
  }
  double dcMean = dcSum / N;
  for (int i = 0; i < N; i++) {
    vReal[i] -= dcMean;
    vImag[i]  = 0;
  }

  // ── 3. Time-domain features: RMS, Peak, ZCR ────────────────
  double sumSq = 0;
  float  peak  = 0;
  int    zc    = 0;
  for (int i = 0; i < N; i++) {
    sumSq += vReal[i] * vReal[i];
    float a = fabs(vReal[i]);
    if (a > peak) peak = a;
    if (i > 0 && ((vReal[i] >= 0 && vReal[i - 1] < 0) ||
                   (vReal[i] <  0 && vReal[i - 1] >= 0))) zc++;
  }
  double rms = sqrt(sumSq / N);
  if (rms < 0.5) rms = 0.5;

  cls.dbLevel     = constrain((float)(20.0 * log10(rms) + DB_CALIBRATION_OFFSET), 30.0f, 110.0f);
  cls.zcr         = (float)zc / N;
  cls.crestFactor = peak / (float)rms;

  // ── 4. FFT (Hamming window -> FFT -> Magnitude) ─────────────
  FFT.windowing(FFT_WIN_TYP_HAMMING, FFT_FORWARD);
  FFT.compute(FFT_FORWARD);
  FFT.complexToMagnitude();
  // vReal[0..N/2-1] now holds the magnitude spectrum

  int halfN = N / 2;

  // ── 5. Spectral energy in sub-bands (Audible range: 62.5 Hz to Nyquist) ──
  double totalEnergy = 0, lowEnergy = 0, midEnergy = 0, highEnergy = 0;
  for (int i = AUDIBLE_START; i < halfN; i++) {
    double e = vReal[i] * vReal[i];
    totalEnergy += e;
    if (i >= LOW_START  && i <= LOW_END)  lowEnergy  += e;
    if (i >= MID_START  && i <= MID_END)  midEnergy  += e;
    if (i >= HIGH_START && i <= HIGH_END) highEnergy += e;
  }
  if (totalEnergy < 1.0) totalEnergy = 1.0;

  cls.lowBandEnergy  = (float)(lowEnergy  / totalEnergy);
  cls.midBandEnergy  = (float)(midEnergy  / totalEnergy);
  cls.highBandEnergy = (float)(highEnergy / totalEnergy);

  // ── 6. Spectral Centroid (Audible frequency "center of mass") ──
  double weightedSum = 0, magSum = 0;
  for (int i = AUDIBLE_START; i < halfN; i++) {
    double freq = i * FREQ_BIN_WIDTH;
    weightedSum += freq * vReal[i];
    magSum      += vReal[i];
  }
  cls.spectralCentroid = (magSum > 0) ? (float)(weightedSum / magSum) : 0;

  // ── 7. Spectral Rolloff (freq below which 85% audible energy sits) ──
  double cumEnergy = 0;
  double rolloffThresh = totalEnergy * 0.85;
  cls.spectralRolloff = (float)(halfN * FREQ_BIN_WIDTH);
  for (int i = AUDIBLE_START; i < halfN; i++) {
    cumEnergy += vReal[i] * vReal[i];
    if (cumEnergy >= rolloffThresh) {
      cls.spectralRolloff = (float)(i * FREQ_BIN_WIDTH);
      break;
    }
  }

  // ── 8. Spectral Flatness (geometric mean / arithmetic mean) ──
  double logSum = 0;
  double arithSum = 0;
  int    validBins = 0;
  for (int i = AUDIBLE_START; i < halfN; i++) {
    if (vReal[i] > 0) {
      logSum += log(vReal[i]);
      arithSum += vReal[i];
      validBins++;
    }
  }
  if (validBins > 0 && arithSum > 0) {
    double geoMean   = exp(logSum / validBins);
    double arithMean = arithSum / validBins;
    cls.spectralFlatness = constrain((float)(geoMean / arithMean), 0.0f, 1.0f);
  } else {
    cls.spectralFlatness = 0;
  }

  // ── 9. TinyML Decision-Tree Classifier ──────────────────────
  //
  //  1. Quiet Ambient: dB < 48.0 dB
  //  2. Voice / Speech: midBand > 35%, centroid in 450-2800 Hz, moderate ZCR
  //  3. Siren: high ZCR > 0.25, centroid > 1400 Hz, highBand > 15%
  //  4. Vehicle Horn: low flatness (tonal), centroid in 350-1300 Hz, midBand dominant
  //  5. Construction: high crestFactor > 4.5, high flatness > 0.35, high dB
  //  6. Traffic: lowBand > 45%, centroid < 600 Hz, low ZCR < 0.15
  //  7. Music / DJ: harmonic spectrum, low+mid balanced, dB > 70

  if (cls.dbLevel < 48.0f) {
    cls.predictedClass = "Quiet Ambient";
    cls.confidence = 0.95f;

  } else if (cls.midBandEnergy > 0.35f && cls.spectralCentroid >= 450.0f
             && cls.spectralCentroid <= 2800.0f && cls.spectralFlatness > 0.12f
             && cls.dbLevel >= 48.0f && cls.dbLevel <= 78.0f) {
    cls.predictedClass = "Voice / Speech";
    cls.confidence = 0.94f;

  } else if (cls.zcr > 0.25f && cls.spectralCentroid > 1400.0f && cls.highBandEnergy > 0.15f) {
    cls.predictedClass = "Siren";
    cls.confidence = 0.93f;

  } else if (cls.spectralFlatness < 0.16f && cls.spectralCentroid >= 350.0f
             && cls.spectralCentroid <= 1300.0f && cls.midBandEnergy > 0.40f) {
    cls.predictedClass = "Vehicle Horn";
    cls.confidence = 0.91f;

  } else if (cls.crestFactor > 4.5f && cls.spectralFlatness > 0.35f && cls.dbLevel > 65.0f) {
    cls.predictedClass = "Construction";
    cls.confidence = 0.92f;

  } else if (cls.lowBandEnergy > 0.45f && cls.spectralCentroid < 600.0f && cls.zcr < 0.15f) {
    cls.predictedClass = "Traffic";
    cls.confidence = 0.90f;

  } else if (cls.dbLevel > 70.0f && cls.spectralFlatness < 0.22f
             && cls.lowBandEnergy > 0.20f && cls.midBandEnergy > 0.30f) {
    cls.predictedClass = "Music / DJ";
    cls.confidence = 0.88f;

  } else {
    cls.predictedClass = "Ambient Noise";
    cls.confidence = 0.82f;
  }

  return cls;
}

// ==============================================================
//                      ALERT ACTUATORS
// ==============================================================
void checkAlerts(float dbLevel, bool isViolation) {
  if (isViolation) {
    digitalWrite(LED_RED_PIN, HIGH);
    tone(BUZZER_PIN, 2000, 100);
  } else {
    digitalWrite(LED_RED_PIN, LOW);
    noTone(BUZZER_PIN);
  }
}

// ==============================================================
//              DUAL CLOUD TELEMETRY (RTDB + Firestore)
// ==============================================================
void sendTelemetryToCloud(const SoundClassification& cls, bool isViolation) {
  HTTPClient http;
  time_t nowSec = time(NULL);
  uint64_t epochMs = (nowSec > 1600000000)
                       ? ((uint64_t)nowSec * 1000ULL + (millis() % 1000))
                       : (1785900000000ULL + millis());

  // ── 1. Firebase Realtime Database PUT ───────────────────────
  if (http.begin(secureClient, rtdbUrl)) {
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(3000);

    JsonDocument doc;
    doc["id"]         = String("rt_") + String(epochMs);
    doc["deviceId"]   = DEVICE_ID;
    doc["noiseLevel"] = cls.dbLevel;
    doc["source"]     = cls.predictedClass;
    doc["confidence"] = cls.confidence;
    doc["latitude"]   = FIXED_LAT;
    doc["longitude"]  = FIXED_LNG;
    doc["threshold"]  = noiseThreshold;
    doc["violation"]  = isViolation;
    doc["address"]    = LOCATION_NAME;

    String payload;
    serializeJson(doc, payload);
    int code = http.PUT(payload);

    Serial.printf("[RTDB %d] %.1f dB | %s | SC:%.0f RF:%.0f SF:%.2f LMH:%.0f/%.0f/%.0f%% ZCR:%.2f CF:%.1f\n",
                  code, cls.dbLevel, cls.predictedClass.c_str(),
                  cls.spectralCentroid, cls.spectralRolloff, cls.spectralFlatness,
                  cls.lowBandEnergy * 100, cls.midBandEnergy * 100, cls.highBandEnergy * 100,
                  cls.zcr, cls.crestFactor);
    http.end();
  }

  // ── 2. Cloud Firestore PATCH ────────────────────────────────
  if (http.begin(secureClient, firestoreUrl)) {
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(3000);

    JsonDocument doc;
    JsonObject fields = doc["fields"].to<JsonObject>();
    fields["id"]["stringValue"]                 = String("rec_") + String(epochMs);
    fields["deviceId"]["stringValue"]           = DEVICE_ID;
    fields["noiseLevel"]["doubleValue"]         = cls.dbLevel;
    fields["source"]["stringValue"]             = cls.predictedClass;
    fields["confidence"]["doubleValue"]         = cls.confidence;
    fields["latitude"]["doubleValue"]           = FIXED_LAT;
    fields["longitude"]["doubleValue"]          = FIXED_LNG;
    fields["threshold"]["doubleValue"]          = noiseThreshold;
    fields["violation"]["booleanValue"]         = isViolation;
    fields["address"]["stringValue"]            = LOCATION_NAME;
    fields["spectralCentroid"]["doubleValue"]   = cls.spectralCentroid;
    fields["spectralRolloff"]["doubleValue"]    = cls.spectralRolloff;
    fields["spectralFlatness"]["doubleValue"]   = cls.spectralFlatness;
    fields["lowBandEnergy"]["doubleValue"]      = cls.lowBandEnergy;
    fields["midBandEnergy"]["doubleValue"]      = cls.midBandEnergy;
    fields["highBandEnergy"]["doubleValue"]     = cls.highBandEnergy;
    fields["zcr"]["doubleValue"]                = cls.zcr;
    fields["crestFactor"]["doubleValue"]        = cls.crestFactor;

    String payload;
    serializeJson(doc, payload);
    int fsCode = http.PATCH(payload);

    Serial.printf("[FIRESTORE %d] %.1f dB | %s | SC:%.0f RF:%.0f SF:%.2f LMH:%.0f/%.0f/%.0f%% ZCR:%.2f CF:%.1f\n",
                  fsCode, cls.dbLevel, cls.predictedClass.c_str(),
                  cls.spectralCentroid, cls.spectralRolloff, cls.spectralFlatness,
                  cls.lowBandEnergy * 100, cls.midBandEnergy * 100, cls.highBandEnergy * 100,
                  cls.zcr, cls.crestFactor);
    http.end();
  }

  // ── 3. Cloud Firestore Alert Dispatch (Throttled to 10s) ───
  if (isViolation && (millis() - lastAlertDispatchTime > 10000)) {
    lastAlertDispatchTime = millis();
    if (http.begin(secureClient, firestoreAlertsUrl)) {
      http.addHeader("Content-Type", "application/json");
      http.setTimeout(3000);

      JsonDocument alertDoc;
      JsonObject aFields = alertDoc["fields"].to<JsonObject>();
      aFields["alertId"]["stringValue"]               = String("alt_") + String(epochMs);
      aFields["deviceId"]["stringValue"]              = DEVICE_ID;
      aFields["noiseLevel"]["doubleValue"]            = cls.dbLevel;
      aFields["durationSeconds"]["integerValue"]       = "10";
      aFields["latitude"]["doubleValue"]              = FIXED_LAT;
      aFields["longitude"]["doubleValue"]             = FIXED_LNG;
      aFields["source"]["stringValue"]                = cls.predictedClass;
      aFields["resolved"]["booleanValue"]             = false;
      aFields["createdAt"]["stringValue"]             = "2026-09-11T15:00:00Z";
      aFields["address"]["stringValue"]               = LOCATION_NAME;
      aFields["confidence"]["doubleValue"]            = cls.confidence;
      aFields["spectralCentroid"]["doubleValue"]         = cls.spectralCentroid;
      aFields["spectralRolloff"]["doubleValue"]          = cls.spectralRolloff;
      aFields["spectralFlatness"]["doubleValue"]         = cls.spectralFlatness;
      aFields["lowBandEnergy"]["doubleValue"]            = cls.lowBandEnergy;
      aFields["midBandEnergy"]["doubleValue"]            = cls.midBandEnergy;
      aFields["highBandEnergy"]["doubleValue"]           = cls.highBandEnergy;
      aFields["zcr"]["doubleValue"]                      = cls.zcr;
      aFields["crestFactor"]["doubleValue"]              = cls.crestFactor;

      String aPayload;
      serializeJson(alertDoc, aPayload);
      int alertCode = http.POST(aPayload);
      Serial.printf("[ALERT DISPATCHED %d] 🚨 Violation: %.1f dB (%s) logged to Cloud Firestore!\n",
                    alertCode, cls.dbLevel, cls.predictedClass.c_str());
      http.end();
    }
  }
}

