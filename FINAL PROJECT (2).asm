; 24L-0509 ; MUHAMMAD OBAIDULLAH  
; 24L-0657 ; MUHAMMAD USMAN RAFIQUE 

[org 0x0100]

jmp start

clrscr:
    mov di, 0
    mov cx, 2000
    mov ax, 0x0720
    cld
    rep stosw
    ret

drawBackground:
    mov cx, 25
    mov di, 0
    mov bx, 0

draw_bg_loop:
    push cx
    push di
    push bx
    cld

    test bl, 1
    jnz darkgrass

lightgrass:
    mov ax, 0x2AB2
    jmp drawleftgrass

darkgrass:
    mov ax, 0x22B2

drawleftgrass:
    mov cx, 15
    rep stosw

drawroad:
    mov ax, 0x08B0
    mov cx, 50
    rep stosw
    pop bx
    push bx
    test bl, 1
    jnz darkgrassright

lightgrassright:
    mov ax, 0x2AB2
    jmp drawrightgrass

darkgrassright:
    mov ax, 0x22B2

drawrightgrass:
    mov cx, 15
    rep stosw

    pop bx
    pop di
    pop cx

    inc bx
    add di, 160
    loop draw_bg_loop
    ret

drawRoadLines:
    mov bx, 1
    mov di, 0
    mov cx, 25
line_loop:
    push cx
    test bl, 1
    jnz skip_draw

    push di
    add di, 64
    mov word [es:di], 0x0FDB
    add di, 160
    mov word [es:di], 0x0FDB
    pop di
    
    push di
    add di, 96
    mov word [es:di], 0x0FDB
    add di, 160
    mov word [es:di], 0x0FDB
    pop di

skip_draw:
    pop cx
    inc bx
    add di, 320
    loop line_loop
    ret

drawsidewalk:
    mov cx, 25
    mov bx, 0
sidewalkloop:
    push cx
    push bx
    mov ax, bx
    mov cx, 160
    mul cx
    mov di, ax
    test bl, 1
    jnz whiteblock

yellowblock:
    mov ax, 0xEEDB
    jmp drawblock

whiteblock:
    mov ax, 0xFFDB

drawblock:
    mov word[es:di+28], ax
    mov word[es:di+130], ax
    pop bx
    pop cx
    inc bx
    loop sidewalkloop
    ret

drawPlayerCar:
    mov ax, 0xB800
    mov es, ax

    ; Calculate Position
    mov al, [player_row]
    cbw
    mov bx, 80
    mul bx
    mov bl, [player_col]
    add ax, bx
    shl ax, 1
    mov di, ax

    ; --- ROW 1: Tires and Hood ---
    mov word [es:di], 0x70DC
    mov word [es:di+2], 0x04DF
    mov word [es:di+4], 0x04DF
    mov word [es:di+6], 0x70DC

    ; --- ROW 2: Windshield and Body ---
    add di, 160
    mov word [es:di], 0x04DB
    mov word [es:di+2], 0x03DB
    mov word [es:di+4], 0x03DB
    mov word [es:di+6], 0x04DB
    
    add di, 160
    mov word [es:di], 0x04DB
    mov word [es:di+2], 0x04DB
    mov word [es:di+4], 0x04DB
    mov word [es:di+6], 0x04DB

    ; --- ROW 3: Roof/Spoiler ---
    add di, 160
    mov word [es:di], 0x04DC
    mov word [es:di+2], 0x04DB
    mov word [es:di+4], 0x04DB
    mov word [es:di+6], 0x04DC
    ret

random:
    push cx
    push dx
    push bx

    mov ah, 0x00
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov cx, [max_random]
    cmp cx, 0
    je .end
    div cx
    mov al, dl

.end:
    pop bx
    pop dx
    pop cx
    ret

getLanePosition:
    push bx
    mov word [max_random], 3
    call random
    cmp al, 0
    je .lane1
    cmp al, 1
    je .lane2
    mov al, 60
    jmp .done
.lane1:
    mov al, 20
    jmp .done
.lane2:
    mov al, 40
.done:
    pop bx
    ret

getMoneyPosition:
    push bx
    mov word [max_random], 3
    call random
    cmp al, 0
    je .lane1
    cmp al, 1
    je .lane2
    mov al, 60
    jmp .set_col
.lane1:
    mov al, 20
    jmp .set_col
.lane2:
    mov al, 40
.set_col:
    mov [temp_col], al
    
    mov byte [temp_row], 0
    pop bx
    ret

drawObstacleCar:
    push di
    push ax
    
    ; --- ROW 1: Front (Tires + Bumper) ---
    mov word [es:di], 0x70DC
    mov word [es:di+2], 0x05DF
    mov word [es:di+4], 0x05DF
    mov word [es:di+6], 0x70DC
    
    ; --- ROW 2: Windshield & Body ---
   
    
    ; --- ROW 3: Roof & Back ---
    add di, 160
    mov word [es:di], 0x05DB
    mov word [es:di+2], 0x05DB
    mov word [es:di+4], 0x05DB
    mov word [es:di+6], 0x05DB
     
    add di, 160
    mov word [es:di], 0x05DB
    mov word [es:di+2], 0x03DB
    mov word [es:di+4], 0x03DB
    mov word [es:di+6], 0x05DB
    ; --- ROW 4: Rear Spoiler & Tires ---
    add di, 160
    mov word [es:di], 0x70DF
    mov word [es:di+2], 0x05DC
    mov word [es:di+4], 0x05DC
    mov word [es:di+6], 0x70DF
    
    pop ax
    pop di
    ret

drawMoneyCoin:
    push di
    push ax
    mov ax, 0xEE24
    mov [es:di], ax
    pop ax
    pop di
    ret

drawobstacles:
    push ax
    push bx
    push cx
    push si
    push di

    mov ax, 0xB800
    mov es, ax
    mov cx, 0
    mov cl, [obstacle_count]
    mov si, 0

drawobs_loop:
    mov al, [obs_timer + si]
    cmp al, 0
    jne .skip_draw
    
    mov al, [obs_col + si]
    mov bl, [obs_row + si]
    
    mov ah, 0
    mov bh, 0
    mov ax, bx
    mov dx, 80
    mul dx
    mov dl, [obs_col + si]
    mov dh, 0
    add ax, dx
    shl ax, 1
    mov di, ax
    
    call drawObstacleCar
.skip_draw:
    inc si
    loop drawobs_loop

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret

drawMoney:
    push ax
    push bx
    push cx
    push si
    push di

    mov ax, 0xB800
    mov es, ax
    mov cx, 0
    mov cl, [money_count]
    mov si, 0

draw_money_loop:
    mov al, [money_timer + si]
    cmp al, 0
    jne .skip_draw
    
    mov al, [money_col + si]
    mov bl, [money_row + si]
    
    cmp bl, 25
    jae .skip_draw
    
    mov ah, 0
    mov bh, 0
    mov ax, bx
    mov dx, 80
    mul dx
    mov dl, [money_col + si]
    mov dh, 0
    add ax, dx
    shl ax, 1
    mov di, ax
    
    call drawMoneyCoin
.skip_draw:
    inc si
    loop draw_money_loop

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret

initializeMoney:
    push cx
    push si
    
    mov cx, 0
    mov cl, [money_count]
    mov si, 0
    
init_money_loop:
    call getMoneyPosition
    mov al, [temp_col]
    mov [money_col + si], al
    mov byte [money_row + si], 0
    
    mov word [max_random], 30
    call random
    add al, 5
    mov [money_timer + si], al
    
    inc si
    loop init_money_loop
    
    pop si
    pop cx
    ret

initializeObstacles:
    push cx
    push si
    
    mov cx, 0
    mov cl, [obstacle_count]
    mov si, 0
    
init_obs_loop:
    call getLanePosition
    mov [obs_col + si], al
    
    call .ensure_different_lanes
    mov byte [obs_row + si], 0
    
    mov al, [obs_timer_delays + si]
    mov [obs_timer + si], al
    
    inc si
    loop init_obs_loop
    
    pop si
    pop cx
    ret

.ensure_different_lanes:
    push si
    push cx
    push bx
    
    mov bx, 0
.check_lanes_init:
    cmp bx, si
    je .next_init_check
    
    mov al, [obs_col + bx]
    cmp al, [obs_col + si]
    jne .next_init_check
    
    call getLanePosition
    mov [obs_col + si], al
    mov bx, -1
    
.next_init_check:
    inc bx
    cmp bl, [obstacle_count]
    jl .check_lanes_init
    
    pop bx
    pop cx
    pop si
    ret

checkObstacleCollision:
    push cx
    push si
    push ax
    push bx
    
    mov cx, 0
    mov cl, [obstacle_count]
    mov si, 0
    
check_obs_collision_loop:
    mov al, [obs_timer + si]
    cmp al, 0
    jne .no_collision
    
    mov al, [obs_col + si]
    mov bl, [player_col]
    cmp al, bl
    jne .no_collision
    
    mov al, [obs_row + si]
    mov bl, [player_row]
    
    cmp al, bl
    jle .obstacle_above_or_same
    
    ; Obstacle is below player
    sub al, bl
    cmp al, 3        ; If obstacle is within 3 rows below player
    jle .collision
    jmp .no_collision
    
.obstacle_above_or_same:
    sub bl, al       ; Get distance (player_row - obstacle_row)
    cmp bl, 4        ; If obstacle is within 4 rows above player (obstacle is 4 rows tall)
    jle .collision
    jmp .no_collision
    
.collision:
    mov byte [play_collision], 1
    mov byte [game_over], 1
    jmp .collision_found
    
.no_collision:
    inc si
    loop check_obs_collision_loop

.collision_found:
    pop bx
    pop ax
    pop si
    pop cx
    ret

checkMoneyCollision:
    push cx
    push si
    push ax
    push bx
    
    mov cx, 0
    mov cl, [money_count]
    mov si, 0
    
check_money_collision_loop:
    mov al, [money_timer + si]
    cmp al, 0
    jne .no_collision
    
    mov al, [money_col + si]
    mov bl, [player_col]
    cmp al, bl
    jne .no_collision
    
    mov al, [money_row + si]
    mov bl, [player_row]
    sub al, bl
    cmp al, 0
    jl .no_collision
    cmp al, 3
    ja .no_collision
    
    inc word [score]
    mov byte [play_coin], 1
    
    mov al, [fuel]
    cmp al, 95
    jae .max_fuel
    add al, 5
    mov [fuel], al
.max_fuel:
    
    call getMoneyPosition
    mov al, [temp_col]
    mov [money_col + si], al
    mov byte [money_row + si], 0
    
    mov word [max_random], 15
    call random
    add al, 10
    mov [money_timer + si], al
    
.no_collision:
    inc si
    loop check_money_collision_loop
    
    pop bx
    pop ax
    pop si
    pop cx
    ret

updateFuel:
    push ax
    
    mov ax, [frame_counter]
    mov dx, 0
    mov cx, 36
    div cx
    cmp dx, 0
    jne .fuel_done
    
    mov al, [fuel]
    cmp al, 1
    jb .fuel_empty
    dec al
    mov [fuel], al
    jmp .fuel_done
    
.fuel_empty:
    mov byte [fuel], 0
    mov byte [game_over], 1
    
.fuel_done:
    pop ax
    ret

displayUI:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0xB800
    mov es, ax
    
    ; ---------------------------
    ; 1. DRAW SCORE (Top Left)
    ; ---------------------------
    mov di, 0
    mov si, score_text
    mov cx, 7
    mov ah, 0x0F
.display_score_text:
    lodsb
    stosw
    loop .display_score_text
    
    mov ax, [score]
    mov bx, 10
    mov cx, 0
    cmp ax, 0
    jne .convert_loop
    mov ax, 0x0E30
    stosw
    jmp .fuel_section

.convert_loop:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jnz .convert_loop

.display_digits:
    pop ax
    add al, '0'
    mov ah, 0x0E
    stosw
    loop .display_digits

    ; ---------------------------
    ; 2. DRAW FUEL TEXT & BAR
    ; ---------------------------
.fuel_section:
    mov di, 130
    
    mov si, fuel_text
    mov cx, 6
    mov ah, 0x0F
.display_fuel_text:
    lodsb
    stosw
    loop .display_fuel_text
    
    mov al, [fuel]
    mov ah, 0
    mov bl, 10
    div bl
    mov bl, al
    
    mov cx, 10
    
    mov dh, 0x0E
    cmp bl, 3
    ja .draw_bar_loop
    mov dh, 0x04

.draw_bar_loop:
    cmp bl, 0
    jg .draw_filled
    
    mov word [es:di], 0x08B0
    jmp .next_block

.draw_filled:
    mov al, 0xFE
    mov ah, dh
    mov word [es:di], ax
    dec bl

.next_block:
    add di, 2
    loop .draw_bar_loop

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
displayGameOver:
    mov ax, 0xB800
    mov es, ax
    mov di, 0
    mov cx, 2000
    mov ax, 0x0000
    rep stosw

    mov si, game_over_map
    mov di, 698
    mov dx, 10

.row_loop:
    push di
    mov cx, 31
    
.col_loop:
    lodsb
    cmp al, 1
    jne .skip_block
    
    mov word [es:di], 0x44DB
    jmp .next_col
    
.skip_block:
    mov word [es:di], 0x0020
    
.next_col:
    add di, 2
    loop .col_loop

    push cx
    mov cx, 0xFFFF
.d3: loop .d3
    mov cx, 0x8FFF
.d4: loop .d4
    pop cx

    pop di
    add di, 160
    dec dx
    jnz .row_loop

	mov di, 15*160
	mov cx,80
	mov ax, 0x4CD
	rep stosw
	
    mov di, 17*160 +1*2
    add di, 68
    
    mov si, final_score_text
    mov cx, 13
    mov ah, 0x0F
.print_txt:
    lodsb
    stosw
    loop .print_txt

    mov ax, [score]
    mov bx, 10
    mov cx, 0
    
    cmp ax, 0
    jne .score_convert
    mov ax, 0x0E30
    stosw
    jmp .restart_prompt

.score_convert:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jnz .score_convert
.score_print:
    pop ax
    add al, '0'
    mov ah, 0x0E
    stosw
    loop .score_print

.restart_prompt:
    mov di, 21 * 160 + 25 * 2
    mov si, restart_text
    mov cx, 29
    mov ah, 0x87
.print_restart:
    lodsb
    stosw
    loop .print_restart

    mov ah, 0x00
    int 0x16
    ret

move_left:
    mov al, [player_col]
    cmp al, 40
    je .move_to_left_lane
    cmp al, 60
    je .move_to_middle_lane
    jmp .skip_move

.move_to_left_lane:
    mov al, 20
    mov [player_col], al
    jmp .skip_move

.move_to_middle_lane:
    mov al, 40
    mov [player_col], al
    jmp .skip_move

.skip_move:
    jmp near after_key

move_right:
    mov al, [player_col]
    cmp al, 20
    je .move_to_middle_lane
    cmp al, 40
    je .move_to_right_lane
    jmp .skip_move

.move_to_middle_lane:
    mov al, 40
    mov [player_col], al
    jmp .skip_move

.move_to_right_lane:
    mov al, 60
    mov [player_col], al
    jmp .skip_move

.skip_move:
    jmp near after_key

move_up:
    mov al, [player_row]
    cmp al, 3
    jbe .skip_move
    sub al, 2
    mov [player_row], al
.skip_move:
    jmp near after_key

move_down:
    mov al, [player_row]
    cmp al, 21
    jae .skip_move
    add al, 2
    mov [player_row], al
.skip_move:
    jmp near after_key

updateMovingObjects:
    mov ax, [frame_counter]
    and ax, 7
    jnz near .done
    
    ; First check if moving would cause collision
    mov si, 0
    mov cx, 0
    mov cl, [obstacle_count]
    
.check_collision_before_move:
    mov al, [obs_timer + si]
    cmp al, 0
    jne .next_obstacle_check
    
    mov al, [obs_col + si]
    mov bl, [player_col]
    cmp al, bl
    jne .next_obstacle_check
    
    ; Check if obstacle is RIGHT ABOVE player (1 row away)
    mov al, [obs_row + si]
    mov bl, [player_row]
    
    ; If obstacle is exactly 1 row above player, don't move it
    ; This prevents head-on collision overlap
    sub bl, al
    cmp bl, 1
    je .skip_obstacle_move
    
.next_obstacle_check:
    inc si
    loop .check_collision_before_move
    
    ; Now move obstacles
    mov si, 0
    mov cx, 0
    mov cl, [obstacle_count]
.update_obstacles:
    mov al, [obs_timer + si]
    cmp al, 0
    je .move_obstacle
    
    dec al
    mov [obs_timer + si], al
    jmp .next_obstacle
    
.skip_obstacle_move:
    ; Don't move this obstacle if it would cause immediate collision
    jmp .next_obstacle
    
.move_obstacle:
    mov al, [obs_row + si]
    inc al
    cmp al, 25
    jl .store_obs
    
    call getLanePosition
    mov [obs_col + si], al
    
    call .ensure_different_lanes
    mov byte [obs_row + si], 0
    
    mov al, [obs_timer_delays + si]
    mov [obs_timer + si], al
    jmp .next_obstacle
    
.store_obs:
    mov [obs_row + si], al
    
.next_obstacle:
    inc si
    loop .update_obstacles
    
    ; Update money (same as before)
    mov si, 0
    mov cx, 0
    mov cl, [money_count]
.update_money:
    mov al, [money_timer + si]
    cmp al, 0
    je .move_money
    
    dec al
    mov [money_timer + si], al
    jmp .next_money
    
.move_money:
    mov al, [money_row + si]
    inc al
    cmp al, 25
    jl .store_money
    
    call getMoneyPosition
    mov al, [temp_col]
    mov [money_col + si], al
    mov byte [money_row + si], 0
    
    mov word [max_random], 15
    call random
    add al, 10
    mov [money_timer + si], al
    jmp .next_money
    
.store_money:
    mov [money_row + si], al
    
.next_money:
    inc si
    loop .update_money

.done:
    ret

.ensure_different_lanes:
    push si
    push cx
    push bx
    
    mov bx, 0
    mov cx, 0
    mov cl, [obstacle_count]
.check_lanes_loop:
    cmp bx, si
    je .next_lane_check
    
    mov al, [obs_col + bx]
    cmp al, [obs_col + si]
    jne .next_lane_check
    
    call getLanePosition
    mov [obs_col + si], al
    mov bx, -1
    
.next_lane_check:
    inc bx
    loop .check_lanes_loop
    
    pop bx
    pop cx
    pop si
    ret

showPauseScreen:
    pusha
    mov ax, 0xB800
    mov es, ax
    
    mov di, 11*160 + 30*2
    mov si, pause_message
    mov cx, 19
    mov ah, 0x4F
.display_message:
    lodsb
    stosw
    loop .display_message
    
    mov di, 12*160 + 32*2
    mov si, pause_options
    mov cx, 12
    mov ah, 0x4E
.display_options:
    lodsb
    stosw
    loop .display_options
    
    popa
    ret

handlePauseInput:
    mov ah, 0x00
    int 0x16
    
    cmp al, 'y'
    je .quit_game
    cmp al, 'Y'
    je .quit_game
    cmp al, 'n'
    je .resume_game
    cmp al, 'N'
    je .resume_game
    cmp al, 27
    je .resume_game
    jmp handlePauseInput

.quit_game:
    mov byte [game_should_quit], 1
    ret

.resume_game:
    mov byte [game_should_quit], 0
    ret
    getUsername:
    pusha
    mov ax, 0xB800
    mov es, ax
    
    ; Clear screen with blue background
    mov di, 0
    mov cx, 2000
    mov ax, 0x0720  ; Blue background
    rep stosw
    
    ; Title
    mov di, 5*160 + 28*2
    mov si, username_title
    mov cx, 25
    mov ah, 0x07    ; White on blue
.print_title:
    lodsb
    stosw
    loop .print_title
    
    ; Underline
    mov di, 6*160 + 28*2
    mov cx, 25
    mov ax, 0x07C4  ; White line on blue
.underline:
    stosw
    loop .underline
    
    ; Prompt
    mov di, 9*160 + 20*2
    mov si, username_prompt
    mov cx, 41
    mov ah, 0x07    ; Yellow on blue
.print_prompt:
    lodsb
    stosw
    loop .print_prompt
    
    ; Draw input box
    mov di, 11*160 + 25*2
    mov cx, 30
    mov ax, 0x072D  ; Dashes for input box
.draw_box:
    stosw
    loop .draw_box
    
    ; Initialize username buffer
    mov di, username_buffer
    mov cx, 30
    mov al, 0
.clear_buffer:
    mov [di], al
    inc di
    loop .clear_buffer
    
    ; Set cursor position
    mov word [username_pos], 0
    mov word [cursor_pos], 11*160 + 25*2
    
    popa
    ret

inputUsername:
    call getUsername
    
.input_loop:
    mov ah, 0x00
    int 0x16
    
    cmp ah, 0x1C     ; Enter key
    je .done_input
    
    cmp ah, 0x0E     ; Backspace
    je .handle_backspace
    
    cmp al, 32       ; Space and above
    jl .input_loop
    cmp al, 126      ; Below DEL
    ja .input_loop
    
    ; Check if buffer is full (29 chars max)
    mov bx, [username_pos]
    cmp bx, 29
    jae .input_loop
    
    ; Store character in buffer
    mov di, username_buffer
    add di, bx
    mov [di], al
    inc word [username_pos]
    
    ; Display character
    mov di, [cursor_pos]
    mov ah, 0x1F     ; White on blue
    mov [es:di], ax
    add word [cursor_pos], 2
    
    jmp .input_loop

.handle_backspace:
    cmp word [username_pos], 0
    je .input_loop
    
    dec word [username_pos]
    sub word [cursor_pos], 2
    
    ; Clear character on screen
    mov di, [cursor_pos]
    mov word [es:di], 0x1720  ; Blue background space
    
    ; Remove from buffer
    mov bx, [username_pos]
    mov di, username_buffer
    add di, bx
    mov byte [di], 0
    
    jmp .input_loop

.done_input:
    ; Ensure null termination
    mov bx, [username_pos]
    mov di, username_buffer
    add di, bx
    mov byte [di], 0
    
    ret

displayUsernameInGame:
    pusha
    mov ax, 0xB800
    mov es, ax
    
    ; Display "PLAYER: " in top-right corner
    mov di, 160
    mov si, player_text
    mov cx, 8
    mov ah, 0x0F
.print_player:
    lodsb
    stosw
    loop .print_player
    
    ; Display username
    mov di, 178
    mov si, username_buffer
.display_loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E  ; Yellow
    stosw
    jmp .display_loop
    
.done:
    popa
    ret
displayLogo:
    pusha
    mov ax, 0xB800
    mov es, ax

    mov di, 0
    mov cx, 2000
    mov ax, 0x0720
    rep stosw

    mov di, 6*160
    mov cx, 80
.titleBorder:
    mov word [es:di], 0x0F3D
    add di, 2
    loop .titleBorder
    
    mov di, 7*160 + 32*2
    mov word [es:di],   0x0E41
    mov word [es:di+2], 0x0E53
    mov word [es:di+4], 0x0E50
    mov word [es:di+6], 0x0E48
    mov word [es:di+8], 0x0E41
    mov word [es:di+10], 0x0E4C
    mov word [es:di+12], 0x0E54
    mov word [es:di+14], 0x0E20
    mov word [es:di+16], 0x0E41
    mov word [es:di+18], 0x0E53
    mov word [es:di+20], 0x0E53
    mov word [es:di+22], 0x0E45
    mov word [es:di+24], 0x0E4D
    mov word [es:di+26], 0x0E42
    mov word [es:di+28], 0x0E4C
    mov word [es:di+30], 0x0E59
    
    mov di, 8*160
    mov cx, 80
.titleBottom:
    mov word [es:di], 0x0F3D
    add di, 2
    loop .titleBottom

    mov di, 9*160
    mov cx, 20
.loopprintnine:
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    loop .loopprintnine

    mov di, 10*160+4
    mov cx, 20
.loopprintten:
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    loop .loopprintten
   
    mov di, 11*160
    mov cx, 20
.loopprintel:
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    loop .loopprintel

    mov di, 12*160+4
    mov cx, 20
.loopprinttwe:
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    loop .loopprinttwe
    
    mov di, 13*160
    mov cx, 20
.loopprintthir:
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x0FDB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    mov word [es:di], 0x00DB
    add di, 2
    loop .loopprintthir

    mov di, 15*160 + 30*2
    mov word [es:di],     0x0742
    mov word [es:di+2],   0x0779
    mov word [es:di+4],   0x0720
    mov word [es:di+6],   0x074F
    mov word [es:di+8],   0x0762
    mov word [es:di+10],  0x0761
    mov word [es:di+12],  0x0769
    mov word [es:di+14],  0x0764
    mov word [es:di+16],  0x0775
    mov word [es:di+18],  0x076C
    mov word [es:di+20],  0x076C
    mov word [es:di+22],  0x0761
    mov word [es:di+24],  0x0768
    mov word [es:di+26],  0x0720
    mov word [es:di+28],  0x0726
    mov word [es:di+30],  0x0720
    mov word [es:di+32],  0x0755
    mov word [es:di+34],  0x0773
    mov word [es:di+36],  0x076D
    mov word [es:di+38],  0x0761
    mov word [es:di+40],  0x076E
    
    mov di, 16*160 + 30*2
    mov word [es:di],     0x8F50
    mov word [es:di+2],   0x8F72
    mov word [es:di+4],   0x8F65
    mov word [es:di+6],   0x8F73
    mov word [es:di+8],   0x8F73
    mov word [es:di+10],  0x8F20
    mov word [es:di+12],  0x8F41
    mov word [es:di+14],  0x8F6E
    mov word [es:di+16],  0x8F79
    mov word [es:di+18],  0x8F20
    mov word [es:di+20],  0x8F6B
    mov word [es:di+22],  0x8F65
    mov word [es:di+24],  0x8F79
    mov word [es:di+26],  0x8F20
    mov word [es:di+28],  0x8F74
    mov word [es:di+30],  0x8F6F
    mov word [es:di+32],  0x8F20
    mov word [es:di+34],  0x8F73
    mov word [es:di+36],  0x8F74
    mov word [es:di+38], 0x8F61
    mov word [es:di+40], 0x8F72
    mov word [es:di+42], 0x8F74

    popa
    ret

displayInstructions:
    pusha
    mov ax, 0xB800
    mov es, ax
    
    ; Clear screen with black background
    mov di, 0
    mov cx, 2000
    mov ax, 0x0720
    rep stosw
    
    ; Draw decorative border
    mov di, 0
    mov cx, 80
    mov ax, 0x0FCD
.border_top:
    mov [es:di], ax
    add di, 2
    loop .border_top
    
    mov di, 24*160
    mov cx, 80
.border_bottom:
    mov [es:di], ax
    add di, 2
    loop .border_bottom
    
    ; Title
    mov di, 2*160 + 30*2
    mov si, inst_title
    mov cx, 15
    mov ah, 0x0F
.print_title:
    lodsb
    stosw
    loop .print_title
    
    ; Controls section
    mov di, 5*160 + 10*2
    mov si, inst_controls
    mov cx, 59
    mov ah, 0x0E
.print_controls:
    lodsb
    stosw
    loop .print_controls
    
    ; Controls details
    mov di, 7*160 + 10*2
    mov si, inst_up
    mov cx, 28
    mov ah, 0x0A
.print_up:
    lodsb
    stosw
    loop .print_up
    
    mov di, 8*160 + 10*2
    mov si, inst_down
    mov cx, 30
    mov ah, 0x0A
.print_down:
    lodsb
    stosw
    loop .print_down
    
    mov di, 9*160 + 10*2
    mov si, inst_left
    mov cx, 32
    mov ah, 0x0A
.print_left:
    lodsb
    stosw
    loop .print_left
    
    mov di, 10*160 + 10*2
    mov si, inst_right
    mov cx, 33
    mov ah, 0x0A
.print_right:
    lodsb
    stosw
    loop .print_right
    
    ; Objectives section
    mov di, 13*160 + 10*2
    mov si, inst_objectives
    mov cx, 47
    mov ah, 0x0E
.print_obj:
    lodsb
    stosw
    loop .print_obj
    
    ; Objectives details
    mov di, 15*160 + 10*2
    mov si, inst_avoid
    mov cx, 27
    mov ah, 0x0C
.print_avoid:
    lodsb
    stosw
    loop .print_avoid
    
    mov di, 16*160 + 10*2
    mov si, inst_collect
    mov cx, 40
    mov ah, 0x0A
.print_collect:
    lodsb
    stosw
    loop .print_collect
    
    mov di, 17*160 + 10*2
    mov si, inst_fuel
    mov cx, 36
    mov ah, 0x0B
.print_fuel:
    lodsb
    stosw
    loop .print_fuel
    
    ; Continue prompt
    mov di, 20*160 + 20*2
    mov si, inst_continue
    mov cx, 39
    mov ah, 0x8F
.print_continue:
    lodsb
    stosw
    loop .print_continue
    
    popa
    ret

waitForInstructions:
    call displayInstructions
    
.input_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x20          ; Space bar - start game
    je .continue_game
    
    cmp al, 27            ; ESC - go back to title screen
    je .back_to_title
    
    jmp .input_loop
    
.continue_game:
    ret
    
.back_to_title:
    mov byte [game_started], 0
    jmp waitForSpace

waitForSpace:
    call displayLogo

    mov ax, 0xB800
    mov es, ax
    mov di, 2880
    mov cx, 800
    mov ax, 0x0020
    rep stosw

.input_loop:
    mov ah, 0x00
    int 0x16
    
    ; Remove the space bar check and accept ANY key
    ; cmp al, 0x20    ; <-- REMOVE or COMMENT OUT THIS LINE
    ; jne .input_loop ; <-- REMOVE or COMMENT OUT THIS LINE
    
    ; Just accept ANY key press (except maybe ESC for exit)
    cmp al, 27       ; Optional: Check for ESC to exit
    je .exit_program
    
    call waitForInstructions
    call inputUsername
    mov byte [game_started], 1
    ret

.exit_program:
    mov ax, 0x4C00
    int 0x21 

play_sound_hardware: 
   push ax 
   push dx 
   
   cmp di, 0 
   je .turnoff 
   
   in al,0x61 
   or al,3 
   out 0x61, al 
   
   mov dx,0x0012 
   mov ax, 0x34DE 
   div di
   
   mov dx,ax
   mov al,0xB6 
   out 0x43, al 
   
   mov ax,dx 
   out 0x42, al
   mov al,ah 
   out 0x42, al
   jmp .done_sound 
   
  .turnoff: 
     in al, 0x61 
	 and al,0xFC
	 out 0x61, al 
  
  .done_sound: 
      pop dx 
	  pop ax 
	  ret 

timer_isr: 
    push ax 
    push bx 
    push di 
    push si 
    push ds 
    
    push cs 
    pop ds 
    
	cmp byte [game_over], 1
    je .force_silence
	
    dec word [sound_tick] 
    cmp word [sound_tick], 0
    jg near .exit_isr
    
    cmp byte [play_collision], 1 
    je .do_crash 
    
    cmp byte [play_coin], 1 
    je .do_coin
    
    jmp .do_bg
	
	.force_silence: 
	    call play_sound_hardware_off
		jmp .exit_isr
    
.do_crash: 
    mov si, crash_data
    add si, [crash_ptr] 
    mov di, [si]
    cmp di, 0
    je .stop_crash 
    
    call play_sound_hardware 
    mov bx, [si+2]
    mov [sound_tick], bx 
    add word [crash_ptr], 4 
    jmp .exit_isr 

.stop_crash: 
    mov byte [play_collision], 0 
    mov word [crash_ptr], 0 
    mov word [sound_tick], 1
    jmp .exit_isr 
    
.do_coin:
    mov si, coin_data
    add si, [coin_ptr]
    mov di, [si]
    cmp di, 0
    je .stop_coin
    
    call play_sound_hardware
    mov bx, [si+2]
    mov [sound_tick], bx
    add word [coin_ptr], 4
    jmp .exit_isr

.stop_coin:
    mov byte [play_coin], 0
    mov word [coin_ptr], 0
    mov word [sound_tick], 1
    jmp .exit_isr

.do_bg:
    mov si, bg_data
    add si, [bg_ptr]
    mov di, [si]
    cmp di, 0
    je .reset_bg
    
    call play_sound_hardware
    mov bx, [si+2]
    mov [sound_tick], bx
    add word [bg_ptr], 4
    jmp .exit_isr

.reset_bg:
    mov word [bg_ptr], 0
    jmp .do_bg

.exit_isr:
    mov al, 0x20
    out 0x20, al

    pop ds
    pop si
    pop di
    pop bx
    pop ax
    iret
	
play_sound_hardware_off: 
    push ax 
	in al,0x61 
	and al,0xFC 
	out 0x61, al 
	pop ax 
	ret 
		
start:
    mov ax, 0x351C
    int 0x21 
    mov [oldisr], bx
    mov [oldisr+2], es
    mov dx, timer_isr
    mov ax, 0x251C
    int 0x21
	 
    mov ax, 0x0003
    int 0x10
    
    call waitForSpace
	mov ax,0xb800 
	mov es,ax 
	
	mov byte[player_col],40
    
    cmp byte [game_started], 1
    jne start
    mov ax, 0xB800
    mov es, ax

    mov byte [player_col], 40
    mov byte [player_row], 18

    mov byte [obstacle_count], 2
    call initializeObstacles

    mov byte [money_count], 5
    call initializeMoney

    mov word [score], 0
    mov byte [fuel], 100
    mov byte [game_over], 0
    mov word [frame_counter], 0
    mov word [max_random], 1

    call clrscr
    call drawBackground
    call drawRoadLines
    call drawsidewalk
    call drawPlayerCar
    call drawobstacles
    call drawMoney
    call displayUI
    call displayUsernameInGame 

main_loop:
    cmp byte [game_over], 1
    je near game_over_screen

    mov cx, 12
.delay:
    push cx
    mov cx, 0x0FFF
.delay_inner:
    loop .delay_inner
    pop cx
    loop .delay

    inc word [frame_counter]

    mov ah, 0x01
    int 0x16
    jnz key_present
    jmp after_key

key_present:
    mov ah, 0x00
    int 0x16
    
    cmp al, 27
    je near .handle_pause
    
    cmp al, 'a'
    je near move_left
    cmp al, 'A'
    je near move_left
    cmp al, 'd'
    je near move_right
    cmp al, 'D'
    je near move_right
    cmp al, 'w'
    je near move_up
    cmp al, 'W'
    je near move_up
    cmp al, 's'
    je near move_down
    cmp al, 'S'
    je near move_down
    cmp ah, 75
    je near move_left
    cmp ah, 77
    je near move_right
    cmp ah, 72
    je near move_up
    cmp ah, 80
    je near move_down
    jmp after_key

.handle_pause:
    call showPauseScreen
    call handlePauseInput
    cmp byte [game_should_quit], 1
    je near exit_game
    call clrscr
    call drawBackground
    call drawRoadLines
    call drawsidewalk
    call drawPlayerCar
    call drawobstacles
    call drawMoney
    call displayUI
    jmp main_loop

after_key:
    ; Check collisions FIRST, before any updates
    call checkObstacleCollision
    call checkMoneyCollision
    
    ; If game over, skip updates and just draw
    cmp byte [game_over], 1
    je .skip_updates
    
    ; Update game state
    call updateMovingObjects
    call updateFuel
    
.skip_updates:
    ; Always redraw the screen
    call drawBackground
    call drawRoadLines
    call drawsidewalk
    call drawPlayerCar
    call drawobstacles
    call drawMoney
    call displayUI
    call displayUsernameInGame
    
    jmp main_loop

game_over_screen:
    call displayGameOver
    jmp start

exit_game:
    in al, 0x61 
    and al, 0xFC 
    out 0x61, al 
	
    mov dx, [old_isr] 
    mov ds, [old_isr+2] 
    mov ax, 0x251C 
    int 0x21 
	
    push cs 
    pop ds 
	
    mov byte [game_started], 0
    jmp start


player_col:    db 40
player_row:    db 18
obstacle_count: db 2
obs_col:       times 2 db 0
obs_row:       times 2 db 0
obs_timer:     times 2 db 0
obs_timer_delays: db 0, 40
money_count:   db 5
money_col:     times 5 db 0
money_row:     times 5 db 0
money_timer:   times 5 db 0
score:         dw 0
fuel:          db 100
game_over:     db 0
frame_counter: dw 0
last_tick:     dw 0
max_random:    dw 1
temp_col:      db 0
temp_row:      db 0

score_text:    db 'SCORE: '
fuel_text:     db 'FUEL: '
game_over_text: db 'GAME OVER'
final_score_text: db 'FINAL SCORE: '
game_started:   db 0

pause_message: db 'Do you want to quit?'
pause_options: db '[Y]es  [N]o'
game_should_quit: db 0
restart_text: db 'Press any Key to restart game'
start_prompt_text: db 'Press Space Bar to Start'

; Instruction screen text
inst_title:          db 'GAME INSTRUCTIONS'
inst_controls:       db '==================== CONTROLS ===================='
inst_up:             db 'UP / W    : Move car upwards'
inst_down:           db 'DOWN / S  : Move car downwards'
inst_left:           db 'LEFT / A  : Change to left lane (20, 40, 60)'
inst_right:          db 'RIGHT / D : Change to right lane (20, 40, 60)'
inst_objectives:     db '================== OBJECTIVES ==================='
inst_avoid:          db 'AVOID purple obstacle cars (CRASH = GAME OVER)'
inst_collect:        db 'COLLECT yellow coins (+1 score, +5 fuel)'
inst_fuel:           db 'MANAGE fuel - it decreases over time!'
inst_continue:       db 'Press SPACE to start game, ESC for back'

; Music data
oldisr: dd 0
sound_tick:   dw 1
play_coin:    db 0
play_collision: db 0

bg_ptr:    dw 0
coin_ptr:  dw 0
crash_ptr: dw 0

old_isr: dd 0

coin_data:     dw 987, 1 , 1318,  0, 0
crash_data:
    ; --- Sharp initial impact ---
    dw 1800, 1, 0, 1     ; very sharp hit
    dw 1500, 1, 0, 1
    dw 1200, 1, 0, 1

    ; --- chaotic broken metal sound ---
    dw 950,  1, 0, 1
    dw 1300, 1, 0, 1
    dw 700,  1, 0, 1
    dw 1100, 1, 0, 1
    dw 600,  2, 0, 1

    ; --- debris falling / rattling ---
    dw 450,  2, 0, 1
    dw 520,  1, 0, 1
    dw 380,  2, 0, 1
    dw 300,  3, 0, 1

    ; --- low rumble fade ---
    dw 200,  3, 0, 1
    dw 120,  4, 0, 1
    dw 80,   5, 0, 1
    dw 50,   6, 0, 1

    dw 0, 0
bg_data:
    ; --- Phrase 1: rising tension ---
    dw 523, 4, 0, 1     ; C5
    dw 587, 4, 0, 1     ; D5
    dw 659, 4, 0, 1     ; E5b (Eb5)
    dw 698, 8, 0, 1     ; F5

    dw 784, 4, 0, 1     ; G5
    dw 698, 4, 0, 1     ; F5
    dw 659, 4, 0, 1     ; Eb5
    dw 587, 8, 0, 1     ; D5

    ; --- Phrase 2: Heroic ascent ---
    dw 523, 4, 0, 1     ; C5
    dw 659, 4, 0, 1     ; Eb5
    dw 784, 4, 0, 1     ; G5
    dw 880, 8, 0, 1     ; A5

    dw 988, 4, 0, 1     ; B5
    dw 1046, 4, 0, 1    ; C6
    dw 988, 4, 0, 1     ; B5
    dw 880, 8, 0, 1     ; A5

    ; --- Phrase 3: Climax ---
    dw 1046, 4, 0, 1    ; C6
    dw 1175, 4, 0, 1    ; D6
    dw 1319, 4, 0, 1    ; E6
    dw 1397, 8, 0, 1    ; F6

    dw 1568, 4, 0, 1    ; G6
    dw 1397, 4, 0, 1    ; F6
    dw 1319, 4, 0, 1    ; E6
    dw 1175, 8, 0, 1    ; D6

    ; --- Ending soft loop tail ---
    dw 1046, 6, 0, 1    ; C6
    dw 784,  6, 0, 1    ; G5
    dw 659,  6, 0, 1    ; Eb5
    dw 523,  8, 0, 1    ; C5 (loop resolves beautifully)

    dw 0, 0
game_over_map:
    db 0,1,1,1,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0
    db 1,0,0,0,0,0,1,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0
    db 1,0,0,1,1,0,1,1,1,0,0,0,1,0,1,0,1,0,0,1,1,1,0,0,0,0,0,0,0,0,0
    db 1,0,0,0,1,0,1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0
    db 0,1,1,1,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0
    db 0,1,1,1,0,0,1,0,0,0,1,0,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0
    db 1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0
    db 1,0,0,0,1,0,0,1,0,1,0,0,1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0
    db 1,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0
    db 0,1,1,1,0,0,0,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0
username_buffer: times 31 db 0
username_pos:    dw 0
cursor_pos:      dw 0
username_title:  db 'ENTER YOUR NAME/ROLL NUMBER'
username_prompt: db 'Type anything and press ENTER to continue'
player_text:     db 'PLAYER: '