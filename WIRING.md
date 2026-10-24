# NoiseGuard ESP32 — Complete Hardware Wiring Guide

> **Note:** All components operate at **3.3V logic**. Do **NOT** connect 5V directly to the INMP441 or ESP32 GPIO pins.

---

## Components Required

| # | Component | Qty | Purpose |
|---|-----------|-----|---------|
| 1 | **ESP32 DevKit V1** (30-pin or 38-pin) | 1 | Edge microcontroller |
| 2 | **INMP441** MEMS Microphone Module | 1 | I2S digital audio sampling |
| 3 | **Red LED** (5mm) | 1 | Noise threshold violation indicator |
| 4 | **Green LED** (5mm) | 1 | Wi-Fi connectivity status |
| 5 | **Active Buzzer** (3.3V) | 1 | Instant audible alarm |
| 6 | **220Ω Resistors** | 2 | Current limiting for LEDs |
| 7 | **Breadboard & Jumper Wires** | 1 set | Prototyping |
| 8 | **Micro-USB Cable** | 1 | Power & serial flashing |

---

## 1. INMP441 MEMS Microphone → ESP32 (I2S Bus)

```
  INMP441 Module                 ESP32 DevKit V1
  ┌──────────────┐              ┌──────────────┐
  │              │              │              │
  │  VDD  ──────────────────▶  │  3V3         │
  │  GND  ──────────────────▶  │  GND         │
  │  SD   ──────────────────▶  │  GPIO 32     │  (I2S Data In)
  │  WS   ──────────────────▶  │  GPIO 25     │  (I2S Word Select / LRCLK)
  │  SCK  ──────────────────▶  │  GPIO 33     │  (I2S Serial Clock / BCLK)
  │  L/R  ──────────────────▶  │  GND         │  (LOW = Left Channel)
  │              │              │              │
  └──────────────┘              └──────────────┘
```

| INMP441 Pin | ESP32 Pin | Wire Color (suggested) | Notes |
|-------------|-----------|------------------------|-------|
| **VDD** | **3V3** | Red | 3.3V power |
| **GND** | **GND** | Black | Common ground |
| **SD** | **GPIO 32** | Yellow | Serial Data (audio output from mic) |
| **WS** | **GPIO 25** | Green | Word Select / Left-Right Clock |
| **SCK** | **GPIO 33** | Blue | Bit Clock |
| **L/R** | **GND** | Black | Tied to GND → selects **Left channel** |

> **Important:** The **L/R pin** MUST be grounded. The firmware uses `I2S_CHANNEL_FMT_ONLY_LEFT`. If L/R is left floating, the mic will output silence or random noise.

---

## 2. Red Alert LED (Noise Violation)

```
  ESP32 GPIO 18  ──────[ 220Ω ]──────▶|────── GND
                                    (Red LED)
                                  Anode(+) Cathode(-)
```

- **GPIO 18** → 220Ω Resistor → Red LED Anode (+)
- Red LED Cathode (−) → **GND**
- Triggered immediately whenever noise level exceeds the threshold.

---

## 3. Green Status LED (Wi-Fi Online)

```
  ESP32 GPIO 19  ──────[ 220Ω ]──────▶|────── GND
                                   (Green LED)
                                  Anode(+) Cathode(-)
```

- **GPIO 19** → 220Ω Resistor → Green LED Anode (+)
- Green LED Cathode (−) → **GND**
- Lights up solid when connected to Wi-Fi; turns off during reconnects.

---

## 4. Active Buzzer (Physical Audio Alarm)

```
  ESP32 GPIO 21  ──────────────────▶  Buzzer (+)
                                      Buzzer (−) ──── GND
```

- **GPIO 21** → Buzzer (+)
- Buzzer (−) → **GND**

---

## 5. Complete Pinout Summary

| ESP32 Pin | Connected Hardware | Function |
|-----------|-------------------|----------|
| **3V3** | INMP441 VDD | 3.3V Power |
| **GND** | INMP441 GND, INMP441 L/R, LED Cathodes, Buzzer (−) | Common Ground |
| **GPIO 32** | INMP441 SD | I2S Serial Data |
| **GPIO 25** | INMP441 WS | I2S Word Select (LRCLK) |
| **GPIO 33** | INMP441 SCK | I2S Bit Clock (BCLK) |
| **GPIO 18** | Red LED (via 220Ω) | Noise Violation Indicator |
| **GPIO 19** | Green LED (via 220Ω) | Wi-Fi Connected Status |
| **GPIO 21** | Active Buzzer (+) | Instant Audible Alarm |
