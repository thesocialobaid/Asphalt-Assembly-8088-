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
    mov ax, 0x0720
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

    ; ------------------------------------------------
    ; Compute DI = (row*80 + col) * 2
    ; ------------------------------------------------
    mov al, [player_row]
    cbw
    mov bx, 80
    mul bx                  ; AX = row*80
    mov bl, [player_col]
    add ax, bx
    shl ax, 1               ; Multiply by 2 (word addressing)
    mov di, ax

    ; ------------------------------------------------
    ; Sports car design relative to DI
    ; ------------------------------------------------

    ; Row 1 - Narrow front
    mov word [es:di], 0x0EDB    ; Headlight left
    mov word [es:di+2], 0x0ADB
    mov word [es:di+4], 0x0ADB  ; Headlight right
    mov word [es:di+6], 0x0EDB  ; Headlight right

    ; Row 2 - Wider middle
    add di, 160
    mov word [es:di], 0x0BDB
    mov word [es:di+2], 0x0BDB   ; Windshield/cockpit
    mov word [es:di+4], 0x0BDB
    mov word [es:di+6], 0x0BDB

    ; Row 3 - Widest part
    add di, 160
    mov word [es:di], 0x0ADB      ; Left wheel
    mov word [es:di+2], 0x0ADB
    mov word [es:di+4], 0x0ADB
    mov word [es:di+6], 0x0ADB
   

    ; Row 4 - Back of car + spoiler
    add di, 160
    mov word [es:di], 0x08DB      ; Spoiler left
    mov word [es:di+2], 0x0ADB
    mov word [es:di+4], 0x0ADB
    mov word [es:di+6], 0x08DB    ; Spoiler right

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
    ; Position coins in the center of lanes (20, 40, 60)
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
    
    ; Start coins from above the map (negative position)
    mov byte [temp_row], 0
    pop bx
    ret

drawObstacleCar:
    push di
    push ax
    
    mov ax, 0x44DB
    mov word [es:di], 0x08DB      ; Spoiler left
    mov word [es:di+2], 0x0CDB
    mov word [es:di+4], 0x0CDB
    mov word [es:di+6], 0x08DB    ; Spoiler right
   
   
     
     ; Row 3 - Widest part
    add di, 160
    mov word [es:di], 0x0CDB      ; Left wheel
    mov word [es:di+2], 0x0CDB
    mov word [es:di+4], 0x0CDB
    mov word [es:di+6], 0x0CDB
    ; Row 2 - Wider middle
   
    add di, 160
    mov word [es:di], 0x0BDB
    mov word [es:di+2], 0x0BDB   ; Windshield/cockpit
    mov word [es:di+4], 0x0BDB
    mov word [es:di+6], 0x0BDB
    

  
     add di, 160
   
    mov word [es:di], 0x0EDB    ; Headlight left
    mov word [es:di+2], 0x0CDB
    mov word [es:di+4], 0x0CDB  ; Headlight right
    mov word [es:di+6], 0x0EDB  ; Headlight right
   
    add di, 160
    
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
    ; Check if obstacle timer has expired before drawing
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
    ; Only draw coins if their timer is expired
    mov al, [money_timer + si]
    cmp al, 0
    jne .skip_draw
    
    mov al, [money_col + si]
    mov bl, [money_row + si]
    
    ; Don't draw if coin is above visible area (negative) or below screen
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
    mov byte [money_row + si], 0  ; Start from top
    
    ; Set random timers for coins so they don't all appear at once
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
    
    ; Ensure obstacles start on different lanes
    call .ensure_different_lanes
    mov byte [obs_row + si], 0
    
    ; Set staggered timers for obstacles (more delay)
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
    
    ; Same lane, change current obstacle's lane
    call getLanePosition
    mov [obs_col + si], al
    mov bx, -1  ; Restart check
    
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
    ; Skip collision check if obstacle timer is active
    mov al, [obs_timer + si]
    cmp al, 0
    jne .no_collision
    
    ; Check if player and obstacle are in the same lane
    mov al, [obs_col + si]
    mov bl, [player_col]
    cmp al, bl
    jne .no_collision
    
    ; Check vertical proximity
    mov al, [obs_row + si]
    mov bl, [player_row]
    sub al, bl
    cmp al, 0
    jl .no_collision  ; Obstacle is above player
    cmp al, 4         ; More lenient collision detection
    ja .no_collision
    
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
    ; Skip if coin timer is active
    mov al, [money_timer + si]
    cmp al, 0
    jne .no_collision
    
    ; Check if player and coin are in the same lane
    mov al, [money_col + si]
    mov bl, [player_col]
    cmp al, bl
    jne .no_collision
    
    ; Check vertical proximity (within 2 rows)
    mov al, [money_row + si]
    mov bl, [player_row]
    sub al, bl
    cmp al, 0
    jl .no_collision  ; Coin is above player
    cmp al, 3         ; Allow some vertical tolerance
    ja .no_collision
    
    ; Collision detected - collect coin
    inc word [score]
    
    ; Add some fuel when collecting coins
    mov al, [fuel]
    cmp al, 95
    jae .max_fuel
    add al, 5
    mov [fuel], al
.max_fuel:
    
    ; Respawn coin
    call getMoneyPosition
    mov al, [temp_col]
    mov [money_col + si], al
    mov byte [money_row + si], 0
    
    ; Set respawn timer for coin
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
    
    mov ax, 0xB800
    mov es, ax
    
    ; Display score
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
    jmp .fuel_display
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

    ; Display fuel
.fuel_display:
    mov di, 140
    mov si, fuel_text
    mov cx, 6
    mov ah, 0x0F
.display_fuel_text:
    lodsb
    stosw
    loop .display_fuel_text
    
    mov di, 152
    mov al, [fuel]
    mov ah, 0
    mov bx, 10
    mov cx, 0
.convert_fuel:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jnz .convert_fuel
.display_fuel_digits:
    pop ax
    add al, '0'
    mov ah, 0x0A
    stosw
    loop .display_fuel_digits
    
    mov di, 158
    mov ax, 0x0A25
    stosw
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

displayGameOver:
    call clrscr
    
    mov ax, 0xB800
    mov es, ax
    
    mov di, 0
    mov si, game_over_text
    mov cx, 9
    mov ah, 0x0C
.display_game_over:
    lodsb
    stosw
    loop .display_game_over
    
    mov di, 940
    mov si, final_score_text
    mov cx, 13
    mov ah, 0x0F
.display_final_score_text:
    lodsb
    stosw
    loop .display_final_score_text
    
    mov di, 966
    mov ax, [score]
    mov bx, 10
    mov cx, 0
    cmp ax, 0
    jne .convert_loop
    mov ax, 0x0E30
    stosw
    jmp .wait_key
.convert_loop:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jnz .convert_loop
.display_final_digits:
    pop ax
    add al, '0'
    mov ah, 0x0E
    stosw
    loop .display_final_digits

.wait_key:
    mov ah, 0x00
    int 0x16
    
    ret

move_left:
    mov al, [player_col]
    cmp al, 40
    je .move_to_left_lane
    cmp al, 60
    je .move_to_middle_lane
    ; If already at left lane (20), do nothing
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
    ; If already at right lane (60), do nothing
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
    and ax, 7  ; Reduced speed by checking every 8 frames instead of 4
    jnz near .done
    
    ; Update obstacles with timer functionality
    mov si, 0
    mov cx, 0
    mov cl, [obstacle_count]
.update_obstacles:
    ; Decrement timer if active
    mov al, [obs_timer + si]
    cmp al, 0
    je .move_obstacle
    
    ; Timer active, decrement it
    dec al
    mov [obs_timer + si], al
    jmp .next_obstacle
    
.move_obstacle:
    mov al, [obs_row + si]
    inc al
    cmp al, 25
    jl .store_obs
    
    ; Reset obstacle with new lane and timer
    call getLanePosition
    mov [obs_col + si], al
    
    ; Ensure obstacles are on different lanes
    call .ensure_different_lanes
    mov byte [obs_row + si], 0
    
    ; Reset timer with staggered delay
    mov al, [obs_timer_delays + si]
    mov [obs_timer + si], al
    jmp .next_obstacle
    
.store_obs:
    mov [obs_row + si], al
    
.next_obstacle:
    inc si
    loop .update_obstacles
    
    ; Update money - move coins at the SAME speed as obstacles (every 8 frames)
    mov si, 0
    mov cx, 0
    mov cl, [money_count]
.update_money:
    mov al, [money_timer + si]
    cmp al, 0
    je .move_money
    
    ; Timer active, decrement it
    dec al
    mov [money_timer + si], al
    jmp .next_money
    
.move_money:
    mov al, [money_row + si]
    inc al
    cmp al, 25
    jl .store_money
    
    ; Reset coin with timer
    call getMoneyPosition
    mov al, [temp_col]
    mov [money_col + si], al
    mov byte [money_row + si], 0
    
    ; Shorter respawn timer for coins (10-25 frames)
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
    ; Ensure obstacles are on different lanes
    push si
    push cx
    push bx
    
    mov bx, 0
    mov cx, 0
    mov cl, [obstacle_count]
.check_lanes_loop:
    cmp bx, si  ; Don't compare with self
    je .next_lane_check
    
    mov al, [obs_col + bx]
    cmp al, [obs_col + si]
    jne .next_lane_check
    
    ; Same lane, change current obstacle's lane
    call getLanePosition
    mov [obs_col + si], al
    mov bx, -1  ; Restart check from beginning
    
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
    
    ; Display "[Y]es  [N]o" options
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

displayLogo:
    pusha
    mov ax, 0xB800
    mov es, ax

    ; Clear screen (black BG)
    mov di, 0
    mov cx, 2000
    mov ax, 0x0720       
    rep stosw

    ; ROW 6 — TITLE BORDER
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

    ; Row 15 — Developer Names
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

waitForKey:
    call displayLogo
    mov ah, 0x00
    int 0x16    
    ret

waitForSpace:
    call displayLogo
.wait_loop:
    mov ah, 0x01
    int 0x16
    jz .wait_loop
    
    mov ah, 0x00
    int 0x16
    cmp al, ' '
    jne .wait_loop
    
    mov byte [game_started], 1
    ret

start:
    mov ax, 0x0003
    int 0x10
    
    call waitForSpace
    
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

main_loop:
    cmp byte [game_over], 1
    je near game_over_screen

    mov cx, 12  ; Increased delay for slower game
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
    
    ; Then check other game controls
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
    ; If resuming, redraw everything and continue
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
    call updateMovingObjects
    call updateFuel
    call checkObstacleCollision
    call checkMoneyCollision

    call drawBackground
    call drawRoadLines
    call drawsidewalk
    call drawPlayerCar
    call drawobstacles
    call drawMoney
    call displayUI

    jmp main_loop

game_over_screen:
    call displayGameOver
    jmp start

exit_game:
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