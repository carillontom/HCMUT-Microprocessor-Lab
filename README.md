## 📘 Microprocessor Systems – Lab Overview (Lab 1 → Lab 5)

This repository contains all laboratory work for the **Microprocessor Systems** course at **Ho Chi Minh City University of Technology (HCMUT)**, implemented on the **ATmega324P** using low-level **AVR Assembly**.
Across 5 labs, we progressed from basic I/O control to timers, display interfaces, serial communication, ADC measurements, and interrupt-driven systems.

---

## 🔹 Lab 1 – I/O, Arithmetic & Software Delays

**Focus:** Basic digital I/O, computational instructions, and delay loops.

**Key topics:**

* Configuring ports as input/output (DIP switches ↔ bar LEDs). 
* Reading switch states and mirroring them to LEDs.
* Performing arithmetic on port values (adding 5, multiplying upper vs lower nibble, signed/unsigned). 
* Single switch → single LED control on the same port pin. 
* Implementing delay subroutines in pure assembly (`Delay1ms`, `Delay10ms`, `Delay100ms`, `Delay1s`) and using them to:

  * Generate a 1 kHz square wave on PA0.
  * Blink LEDs with precise timing. 
* (Advanced) Interfacing with the **74HC595 shift register** to create LED running effects via serial-to-parallel expansion. 

---

## 🔹 Lab 2 – 7-Segment LEDs, LCD & Button Debounce

**Focus:** Human–machine interfaces using 7-segment displays, LCD 16×2, and push buttons.

**Key topics:**

* Driving a 7-segment LED via a port and latch signals **nLE0/nLE1**. 
* Writing a generic `DELAY_MS` routine and using it to:

  * Generate known scan frequencies (e.g., 100 Hz).
  * Blink a single 7-segment digit at different periods (250 ms vs 40 ms) and explain perception differences (flicker vs persistence). 
* Sequentially scanning 4 digits (displaying 1-2-3-4 with different per-digit times like 40 ms and 10 ms). 
* Interfacing with a **16×2 LCD**:

  * Initialization and text display (“MCU-AVR LAB / Group: XX”). 
  * Understanding how the LCD distinguishes **COMMAND vs DATA**, and timing methods (busy flag vs fixed delays). 
* Interfacing with push buttons:

  * Counting button presses and showing the result on **bar LED + LCD**.
  * Implementing and comparing **with vs without debounce** behavior. 

---

## 🔹 Lab 3 – Timers for Delays, Pulses & 7-Segment Scanning

**Focus:** Hardware timers (Timer0, Timer1) for precise delays, pulse generation, and event counting.

**Key topics:**

* Using **Timer0** to generate a 1 ms delay and then a 500 Hz square wave on PA0 (simulation + oscilloscope verification). 
* Generating a 64 µs period square wave:

  * With **Timer0 in Normal mode**.
  * With **Timer1 in CTC mode**, comparing configuration and flags (TOVx vs OCFx). 
* Using **Timer1** to scan 4× 7-segment LEDs at 50 Hz while displaying “0123” (timer-driven multiplexing). 
* Configuring **Timer0 in counter mode** (external pulses on T0 pin):

  * Count push-button presses via external edges.
  * Display the count on the bar LED, and (advanced) on the 7-segment display. 

---

## 🔹 Lab 4 – UART / Serial Port Communication (USART)

**Focus:** Asynchronous serial communication between AVR and PC.

**Key topics:**

* Initializing **UART0** at 9600 bps (8N1) with an 8 MHz clock and analyzing the actual vs ideal baud rate. 
* Implementing a **simple echo**: receive one byte via UART and send it back to PC (Hercules terminal). 
* Mapping ASCII digits ‘0’–‘9’ to numerical values and displaying numbers on the bar LED based on received characters. 
* Implementing `NUM_TRANSFER`:

  * Transmit decimal representation of R16 (0–255) as ASCII characters with CR+LF.
  * Periodically send numbers every 1 second. 
* Counting button presses and sending the count as ASCII over UART to the terminal. 
* Using **Timer0 in counter mode** with external button input and streaming the updated count to the PC whenever it changes. 

---

## 🔹 Lab 5 – ADC Measurements, LCD Display & Timer/UART Interrupts

**Focus:** Analog-to-digital conversion, sensor interfacing, and full interrupt-driven systems.

### 🔸 Lab 5-1 – ADC & Measurement System

**Key topics:**

* Configuring the AVR **ADC**:

  * Single-ended input on ADC0/ADC1.
  * Using VREF = VCCA or internal reference. 
* Sending ADC samples to PC via **UART0** using custom frames:
  `0x55 ADCH ADCL 0xFF` at 1-second intervals. 
* Converting raw ADC values to voltages and:

  * Displaying results on a **16×2 LCD** for both ADC0 and ADC1. 
* Interfacing a **MCP9701 temperature sensor**, measuring its output via ADC, computing temperature, and showing it on the LCD. 
* Understanding ADC errors (offset, gain, DNL, INL, quantization) and formulas for Vin with different VREF values. 

### 🔸 Lab 5-2 – Timer & UART Interrupts

**Key topics:**

* Using **Timer0 interrupts** to:

  * Generate a 1 kHz clock on PA0 in both Normal and CTC modes.
  * Maintain continuous waveform generation while the main loop handles other tasks. 
* Concurrent button + LED control:

  * PA1 as button input, PA2 as LED.
  * Main program polls the button while the ISR maintains the 1 kHz signal. 
* Combining **Timer0 ISR + UART receive interrupt**:

  * Maintain 1 kHz output & button LED control (PA2).
  * Use UART RX interrupt to react to incoming characters:

    * Receive ‘B’ → turn PA3 LED ON.
    * Receive ‘T’ → turn PA3 LED OFF. 

---

## 🧠 Overall Skills Demonstrated

Through Labs 1–5, this course builds a solid foundation in:

* AVR Assembly and register-level programming
* Digital I/O, arithmetic operations, and delay design
* 7-segment multiplexing and LCD interfacing
* Hardware timers in delay, waveform generation, and counter modes
* UART communication (polling and interrupt-driven)
* ADC configuration, voltage measurement, and temperature sensing
* Designing **real-time embedded systems** that combine timers, ADC, UART, LCD, and interrupts
