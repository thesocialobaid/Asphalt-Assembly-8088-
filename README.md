Car Dodging Game (x86 Assembly – 16-bit Real Mode)

A simple car dodging and coin collection game written entirely in x86 Assembly, running in text mode (80×25) by directly manipulating video memory at 0xB800.
This project demonstrates low-level graphics, keyboard input handling, game logic, and screen rendering without any external libraries.

📌 Features

🚗 Player-controlled car (move left/right using arrow keys)

🚧 Obstacles falling from the top

🪙 Coins to collect

💥 Collision detection

📈 Score system (coins collected)

🔁 Looping gameplay

📺 Text-mode rendering using raw video memory writes

⌨️ Real-time keyboard input via BIOS interrupt

🛠️ Tech Stack

Language: x86 Assembly (MASM / TASM / NASM 16-bit syntax)

Mode: 16-bit Real Mode

Graphics: Text mode using video memory (0xB800)

Input: BIOS interrupt INT 16h

Environment: DOSBox / Emu8086 / MASM / TASM / NASM

📂 File Structure
/Car-Game-Assembly
│
├── game.asm       # Main game source code
├── README.md      # Documentation
└── assets/        # (Optional) Game screenshots or GIFs

🚀 How to Run
1. Using DOSBox
masm game.asm;
link game.obj;
game.exe

2. Using TASM
tasm game.asm
tlink game.obj
game.exe

3. Using Emu8086

Just open the .asm file and click Run → Emulate.

🎮 Controls
Key	Action
⬅️ Left Arrow	Move car left
➡️ Right Arrow	Move car right
🧠 How the Game Works (Technical Breakdown)

This section explains how each part of your code works in a clean, professional way.

1. 🎨 Writing to Video Memory

The program renders graphics by writing characters + colors directly to:

0xB800:0000


Each cell = 2 bytes

[byte1 = ASCII character] [byte2 = color attribute]


The function:

updateScreen:
    mov ax, 0B800h
    mov es, ax
    mov cx, 2000        ; 80 × 25 cells
    mov bx, 0
clear_loop:
    mov word ptr es:[bx], 0720h ; space + light gray
    add bx, 2
    loop clear_loop
    ret


✔ Efficiently clears the screen
✔ Uses direct memory access

2. 🚗 Car Rendering

Your car is drawn at:

carX = horizontal position
carY = vertical position


Using:

drawCar:
    mov ax, 0B800h
    mov es, ax
    mov bx, carY
    mov dx, 160
    mul dx             ; row offset
    add bx, ax
    mov dx, carX
    shl dx, 1          ; each column = 2 bytes
    add bx, dx
    mov ah, 04h        ; red color
    mov al, 'A'        ; car symbol
    mov word ptr es:[bx], ax

3. ⬇️ Obstacle Generation & Movement

Obstacles fall from the top by repeatedly increasing their Y position:

inc byte ptr obstacleY
cmp obstacleY, 24
jle skip_reset

reset:
    mov obstacleX, randomColumn
    mov obstacleY, 0


Each frame redraws them.

4. 🪙 Coin System

Coins behave similarly to obstacles but give score instead of collision:

inc byte ptr coinY
cmp coinY, 24
jle skip_coin_reset
mov coinY, 0


When carX == coinX and Y positions match → score++

5. 💥 Collision Detection
mov al, carX
cmp al, obstacleX
jne no_collision

mov al, carY
cmp al, obstacleY
jne no_collision

; collision happened!


If both X and Y match → game over.

6. ⌨️ Keyboard Input Handling
mov ah, 01h
int 16h          ; check key
jz no_key        ; no input

mov ah, 00h
int 16h          ; read key
cmp ah, 4Bh      ; left arrow
je move_left
cmp ah, 4Dh      ; right arrow
je move_right


Arrow keys move the car by adjusting carX.

7. 🕒 Timing Control (Game Speed)

A simple delay loop provides basic throttling:

delay:
    mov cx, 0FFFFh
    mov dx, 03000h
delay_loop:
    dec dx
    jnz delay_loop
    loop delay_loop

📈 Possible Improvements

Add start menu & game over screen

Implement levels / difficulty scaling

Add sound using PC speaker (INT 1Ah or OUT 61h)

Use double buffering for smoother rendering

Replace symbols with ASCII art cars

Add high score system
