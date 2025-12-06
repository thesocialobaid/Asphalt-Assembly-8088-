# Car Dodging Game — x86 Assembly (16-bit Real Mode)

A simple terminal-based car dodging game built entirely in **x86 Assembly**, running in **text mode (80×25)** using **direct video memory access**.  
The project demonstrates low-level programming concepts including screen rendering, keyboard input handling, memory-mapped I/O, and real-time game loops.

---

## Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Technical Architecture](#technical-architecture)  
4. [How Rendering Works](#how-rendering-works)  
5. [Input Handling](#input-handling)  
6. [Collision & Game Logic](#collision--game-logic)  
7. [Build & Run Instructions](#build--run-instructions)  
8. [File Structure](#file-structure)  
9. [Code Explanation](#code-explanation)  
10. [Future Improvements](#future-improvements)  
11. [License](#license)

---

## Overview

This project is a **car dodging and coin collection game** written without any external graphics libraries.  
The display is managed by writing directly to **video memory (`0xB800`)**, and all movement is handled through BIOS interrupts.

The goal of the game is simple:
- Avoid falling obstacles  
- Collect falling coins  
- Move left or right to survive as long as possible  

Everything—from movement to rendering—is done manually at the assembly level.

---

## Features

- Player-controlled car that moves left/right.
- Falling obstacles that reset after leaving the screen.
- Coins that increase score when collected.
- Collision detection for game over.
- Score tracking.
- Screen rendering using direct memory writes.
- Keyboard input captured via BIOS (`INT 16h`).
- Runs inside DOSBox, Emu8086, MASM, TASM, or NASM.

---

## Technical Architecture

### 1. Display
The project uses **text video mode**:



---

## How Rendering Works

### Screen Clearing

The screen is cleared by iterating through all 2000 text cells and writing:


