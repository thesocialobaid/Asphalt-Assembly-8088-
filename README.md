# 🏎️ Asphalt – 8088 Assembly Game Engine

![Language](https://img.shields.io/badge/Language-Assembly_8088-red)
![Platform](https://img.shields.io/badge/Platform-MS_DOS-blue)
![Architecture](https://img.shields.io/badge/Arch-16_bit_Real_Mode-yellow)
![Status](https://img.shields.io/badge/Status-Completed-success)

> A high-performance, real-time arcade racing simulation engineered entirely in **16-bit x86 Assembly**. Featuring direct hardware manipulation, custom interrupt handling for multitasking, and direct memory access rendering.

---

## 📜 Table of Contents
- [Abstract](#-abstract)
- [Key Features](#-key-features)
- [System Architecture](#-system-architecture)
- [Technical Implementation](#-technical-implementation)
- [Game Logic Flow](#-game-logic-flow)
- [How to Run](#-how-to-run)
- [Controls](#-controls)
- [Future Work](#-future-work)
- [Development Team](#-development-team)

---

## 📖 Abstract
**Asphalt** is an academic semester project developed at **FAST-NUCES Lahore** designed to push the limits of the Intel 8088 architecture. Unlike high-level applications that rely on OS abstractions, Asphalt operates in **Real Mode**, interacting directly with the CPU registers, system stack, and hardware I/O ports.

The core engineering challenge was to implement a **non-blocking game loop** where game logic (physics, collision, rendering) runs concurrently with a background audio engine, effectively simulating multitasking on a single-threaded processor.

---

## 🚀 Key Features

- **⚡ Asynchronous Audio Engine:** Implemented a custom **Interrupt Service Routine (ISR)** by hooking the hardware timer interrupt (`0x1C`). This allows background music and sound effects to play without freezing the game loop.
- **🖥️ Direct Memory Access (DMA) Rendering:** Bypasses slow BIOS interrupts (`INT 10h`) and writes directly to the Video Memory Segment (`0xB800`) for flicker-free, high-speed graphics.
- **⛽ Dynamic Resource Economy:** Features a fuel consumption system that forces aggressive gameplay (collecting coins to refuel) rather than passive dodging.
- **🎲 Pseudo-Random Generation:** Utilizes the System Clock (`INT 1A`) to seed a Linear Congruential Generator (LCG) for unpredictable obstacle spawning logic.

---

## ⚙️ System Architecture

The application is designed as a `.COM` executable within a 64KB segment. It consists of three primary subsystems:

1.  **The Game Loop:** A polling-based loop that manages state transitions.
2.  **The Rendering Engine:** A DMA-based system that draws ASCII sprites to the Video Segment.
3.  **The Audio Scheduler:** An interrupt-driven background process.

### Video Memory Mapping
The screen is treated as a linear 1D array mapped to the segment `0xB800`.
- **Addressing Formula:** `Offset = (Row * 160) + (Col * 2)`
- **Sprite Rendering:** Sprites are constructed programmatically using extended ASCII block characters (`0xDB`, `0xDC`, `0xDF`) with specific attribute bytes for color.

---

## 🛠️ Technical Implementation

### 1. The Audio Scheduler (ISR Hook) - *The USP*
Standard Assembly `beep` routines pause the CPU. We solved this by hooking the 18.2 Hz system timer.

```nasm
; Hooking the Timer Interrupt logic
mov ax, 0x251C      ; DOS Function: Set Interrupt Vector
mov dx, timer_isr   ; Address of our custom ISR
int 0x21            ; Execute Hook
