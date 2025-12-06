; Coal Project Phase 1 - Muhammad Obaidullah (24L-0509)
; Muhammad Usman Rafique (24L-0657)

[org 0x100]
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
drawsidewalk:
    mov cx, 25              
    mov bx, 0    
sidewalkloop:
    push cx
    push bx
    mov ax,bx
    mov cx,160
    mul cx
    mov di,ax
    test bl,1
    jnz whiteblock
    

yellowblock:
    mov ax,0xEEDB
    jmp drawblock

whiteblock:
    mov ax,0xFFDB

drawblock:
    mov word[es:di+28],ax
    mov word[es:di+130],ax

    pop bx
    pop cx
    inc bx
    loop sidewalkloop
drawRoadLines:
    mov bx, 1       
    mov di, 0     
    mov cx, 25      
line_loop:
    push cx         
    
    test bl, 1      
    pop cx          
    jnz skip_draw   
    
    push di        
    
    add di, 64   
    mov word [es:di], 0x0FDB  
    mov word [es:di+160],0x0FDB
    pop di         
    push di         
    
    add di, 96   
    mov word [es:di], 0x0FDB  
    mov word [es:di+160],0x0FDB
    pop di          

skip_draw:
    inc bx         
    add di, 320     
    loop line_loop
    
ret
	
drawPlayerCar:
    mov ax, 0xB800
    mov es, ax


    mov di, 3278
    mov word [es:di], 0x0BDB
    mov di, 3280
    mov word [es:di], 0x0BDB
    mov di, 3282
    mov word [es:di], 0x0BDB


    mov di, 3438
    mov word [es:di], 0x01DB
    mov di, 3440
    mov word [es:di], 0x01DB
    mov di, 3442
    mov word [es:di], 0x01DB

    mov di, 3436          
    mov word [es:di], 0x0EDB
    mov di, 3444          
    mov word [es:di], 0x0EDB

    mov di, 3598
    mov word [es:di], 0x00DB
    mov di, 3602
    mov word [es:di], 0x00DB

ret
    
random:
    push cx
    push dx
    push bx
    
    mov ah, 0x00
    int 0x1A      ;clock since mid  
    
    mov al, bh
    sub al, bl
            
    
    mov cl, al
    mov ax, dx
    mov dx,0
    div cx       
    
    mov al, dl
    add al, bl      
    
    pop bx
    pop dx
    pop cx
ret

drawobstacles:
    push cx
    push dx
   
    mov bl, 4
    mov bh, 18
    call random
    mov dh, al     

calculatecolumns:
    mov bl, 18
    mov bh, 62
    call random
    mov dl, al     
    

    mov al, dh      
    mov cl, 80
    mul cl          
    add al, dl      
    shl ax, 1       
    mov di, ax
    
    mov ax, 0x44DB  
    
    mov word [es:di], ax
    mov word [es:di+2],ax
    mov word [es:di+4],ax
    mov word [es:di+160],ax
    mov word [es:di+162],ax
    mov word [es:di+164],ax
    
    pop dx
    pop cx
ret

start:
    mov ax, 0x0003  ; 80x25 16-color text mode
    int 0x10
    
    mov ax, 0xB800
    mov es, ax
    
    call clrscr
	call drawBackground
	call drawRoadLines
	call drawPlayerCar
    call drawobstacles
    call drawsidewalk 

mov ah, 0x00
int 0x16
    
mov ax, 0x4C00
int 0x21