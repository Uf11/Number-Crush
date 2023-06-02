 [org 0x0100] 
 jmp start 
 name: dw 'Player Name: ' ,0
 score: dw 'Score: ' ,0
 score_num: dw 0
 remaingingmovesmsg:dw 'Remaining moves: ',0
 pool: db 0,'u','a','f','r','b','g','m','i'
 randomNum: dw 0
 getvalue: dw 0
 playerName: times 20 dw 0
 initiallmsg: dw 'Please entre player name :', 0
 welcomemsg:dw 'WELCOME TO REAL CANDY CRUSH', 0
 sizemsg:dw 'Entre size by pressing any digit from 4-9 ',0
 finalmsg:dw 'Sad to see you go, your final score was: ',0
 clickrow:db 0
 clickcolumn:db 0
 remaingingmoves:dw 1
 boardsize:dw 4
 
 inputsize:;takes input from user and stores it
 push ax
 push dx
 push bx
 inputChar1:
 mov dl, 53
 mov dh, 7
 mov ah, 02
 int 10h
 mov ah, 01h
 int 21h
 mov ah,0
 sub al,48
 cmp al,4
 jl inputChar1
 cmp al,9
 jg inputChar1
 mov [boardsize], al
 mov [remaingingmoves],al
 pop bx		
 pop dx
 pop ax
 ret
 
 inputPlayerName :;inputs name from user and stores it
 push ax
 push dx
 push bx
 mov dl, 33
 mov dh, 7
 mov ah, 02
 int 10h
 mov bx,playerName
 mov ah, 01h
 mov si,0
 inputChar:
 int 21h
 cmp al,13
 je end2
 mov [bx+si], al
 inc si
 jmp inputChar
 end2:	
 pop bx		
 pop dx
 pop ax
 ret	

 isfrompool:;checks if [getvalue] is from pool
 mov ax,[getvalue]
 cmp al,'u'
 je found
 cmp al,'a'
 je found
 cmp al,'f'
 je found
 cmp al,'r'
 je found
 cmp al,'b'
 je found
 cmp al,'g'
 je found
 cmp al,'m'
 je found
 cmp al,'i'
 je found
 cmp al,'B'
 je found
 mov ax,0
 ret
 found:
 mov ax,1
 ret
 
 noMouseClick:;get click row and column and check for legeal click
 xor ax, ax ;subservice to reset mouse
 int 33h
 waitForMouseClick:
 mov ax, 0001h 			;to show mouse
 int 33h
 mov ax,0003h
 int 33h
 or bx,bx
 jz short waitForMouseClick
 mov ax, 0002h 			;hide mouse after clicking
 int 33h
 mov si,dx                    
 mov dx,0
 mov ax,cx
 mov bx,8
 div bx                         ;dividing by 8 to convert it into row column format.
 mov cx,ax
 mov [clickrow],cl
 mov ax,si
 mov dx,0
 div bx                         ;dividing by 8 to convert it into row column format.  
 mov dx,ax
 mov [clickcolumn],dl
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ah,00h
 mov al, 80 ; load al with columns per row 
 mul dl ; multiply with y position 
 add ax, cx ; add x position 
 shl ax, 1 ; turn into byte offset 
 mov di,ax ; point di to required location 
 mov ax,word[es:di]
 mov [getvalue],ax
 call sleep_s
 call isfrompool
 cmp ax,0
 je waitForMouseClick
 ret
 
 popbomb:;removes char present in al from whole board
 pusha
 mov cx,[boardsize]
 verticalmove:
 mov bx,[boardsize]
 horizonatlmove:
 call get_value
 cmp [getvalue],al
 jne nosamevalue
 push ax
 mov ax,0x0720
 call insert
 mov ax,[score_num]
 add ax,1
 mov [score_num],ax
 call update_score
 pop ax
 nosamevalue:
 sub bx,1
 cmp bx,0
 jg horizonatlmove
 sub cx,1
 jg verticalmove
 popa
 ret

 swapping:;checks for legal click,swaps two char, check for bomb swap
 pusha
 call waitForMouseClick
 mov bx,0
 mov bl,[clickcolumn]
 mov cx,0
 mov cl,[clickrow]
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ah,00h
 mov al, 80 ; load al with columns per row 
 mul bl ; multiply with y position 
 add ax, cx ; add x position 
 shl ax, 1 ; turn into byte offset 
 mov di,ax ; point di to required location 
 mov ax,word[es:di]
 push di;first value to swap with original attributes
 push ax
 or ah,01010000b
 mov word[es:di],ax
 call sleep_s
 push cx
 push bx
 call waitForMouseClick
 pop bx
 pop cx
 mov ax,0
 mov al,[clickcolumn]
 mov dx,0
 mov dl,[clickrow]
 cmp dl,cl
 jg horizontal_isgreater
 jl horizontal_islesser
 je compare_vertical
 are_equal:
 pop ax
 pop di
 mov word[es:di],ax
 jmp end3
 horizontal_isgreater:
 sub dl,6
 cmp cl,dl
 jne are_equal
 cmp al,bl
 jne are_equal
 add dl,6
 jmp continue
 horizontal_islesser:
 add dl,6
 cmp cl,dl
 jne are_equal
 cmp al,bl
 jne are_equal
 sub dl,6
 jmp continue
 compare_vertical:
 cmp al,bl
 jg vertical_isgreater
 jl vertial_islesser
 je are_equal
 vertical_isgreater:
 sub al,2
 cmp al,bl
 jne are_equal
 cmp cl,dl
 jne are_equal
 add al,2
 jmp continue
 vertial_islesser:
 add al,2
 cmp al,bl
 jne are_equal
 cmp cl,dl
 jne are_equal
 sub al,2
 jmp continue 
 continue:;here error
 mov bx,ax
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ah,00h
 mov al, 80 ; load al with columns per row 
 mul bl ;multiply with y position 
 add ax, dx ; add x position 
 shl ax, 1 ; turn into byte offset 
 mov di,ax ; point di to required location 
 mov bx,word[es:di]
 pop ax
 cmp al,'B'
 je bxhasvalue
 cmp bl,'B'
 je axhasvalue
 jmp is_notbomb
 bxhasvalue:
 cmp bl,'B'
 jne nobigbomb1
 pop di
 mov word[es:di],ax
 mov ax,[remaingingmoves]
 add ax,1
 mov [remaingingmoves],ax
 jmp end3
 nobigbomb1:
 pop di
 mov word[es:di],0x0720
 mov ax,bx
 call popbomb
 jmp end3
 axhasvalue:
 cmp al,'B'
 jne nobigbomb2
 pop di
 mov word[es:di],ax
 mov ax,[remaingingmoves]
 add ax,1
 mov [remaingingmoves],ax
 jmp end3
 nobigbomb2:
 mov word[es:di],0x0720
 pop di
 call popbomb
 jmp end3
 is_notbomb:
 mov word[es:di],ax
 pop di
 mov word[es:di],bx
 end3:
 mov ax,[remaingingmoves]
 sub ax,1
 mov [remaingingmoves],ax
 call update_moves
 popa
 ret
  
 hline:;to print a single row
 mov word[es:di], 0x342d;printing - ;4a
 add di,2
 loop hline
 ret

 horizontal:;prints horitontal lines
 mov cx,[boardsize]
 add cx,1
 horizontal_jmp:
 push cx
 mov ax,[boardsize]
 mov cl,6
 mul cl
 add ax,1
 mov cx,ax
 push cx
 ;mov cx,73;length of row
 call hline
 pop cx
 mov ax,80
 sub ax,cx
 shl ax,1
 add ax,160
 add di,ax;moving to next line
 cmp di,4000;comparing end 
 pop cx
 loop horizontal_jmp;printing row till end
 ret
 
 vline:;prints individual vertical line
 mov word[es:di], 0x307C;print |
 add di,160;next line
 loop vline
 ret
 
 vertical:;prints vertical lines
 mov cx,[boardsize]
 add cx,1
 vertical_jmp:
 push cx
 mov ax,[boardsize]
 shl ax,1
 add ax,1
 mov cx,ax;length of columns
 push di
 call vline;print column
 pop di
 add di,12;space between columns
 cmp di,316;cmp to print 12 columns
 pop cx
 loop vertical_jmp
 ret
 
 clrscr:;clear screen bilal hashmi
 push es 
 push ax 
 push cx 
 push di 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 xor di, di ; point di to top left column 
 mov ax, 0x0720 ; space char in normal attribute 
 mov cx, 2000 ; number of screen locations 
 cld ; auto increment mode 
 rep stosw ; clear the whole screen 
 pop di
 pop cx 
 pop ax 
 pop es 
 ret 
  
 printstr:;prints string bilal hashmi
 push bp 
 mov bp, sp 
 push es 
 push ax 
 push cx 
 push si 
 push di 
 push ds 
 pop es ; load ds in es 
 mov di, [bp+4] ; point di to string 
 mov cx, 0xffff ; load maximum number in cx 
 mov al, 0; load a zero in al 
 repne scasb ; find zero in the string 
 mov ax, 0xffff ; load maximum number in ax 
 sub ax, cx ; find change in cx 
 dec ax ; exclude null from length 
 jz exit ; no printing if string is empty
 mov cx, ax ; load string length in cx 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov al, 80 ; load al with columns per row 
 mul byte [bp+8] ; multiply with y position 
 add ax, [bp+10] ; add x position 
 shl ax, 1 ; turn into byte offset 
 mov di,ax ; point di to required location 
 mov si, [bp+4] ; point si to string 
 mov ah, [bp+6] ; load attribute in ah 
 cld ; auto increment mode 
 nextchar:
 lodsb ; load next char in al 
 stosw ; print char/attribute pair 
 loop nextchar ; repeat for the whole string 
 exit:
 pop di 
 pop si 
 pop cx 
 pop ax 
 pop es 
 pop bp 
 ret 8 

 insert:;inserts at particular row and column
 ;bx has row
 ;cx has cols
 ;ax has insert value
 pusha
 cmp bx,0
 jng return
 cmp cx,0
 jng return
 cmp bx,[boardsize]
 jg return
 cmp cx,[boardsize]
 jg return
 push ax
 mov ax,0x0b800
 mov es,ax
 mov di,0
 pop ax
 shl bx,1
 push cx
 mov cx,bx
 rowinc:
 add di,160
 loop rowinc
 add di,6
 pop cx
 colinc:
 sub cx,1
 jz end
 add di,12
 and cx,cx
 jnz colinc
 end:
 mov dx,word[es:di]
 cmp al,0x20
 je insert_that
 cmp dl,' '
 jne return
 insert_that:
 mov word[es:di],ax
 return:
 popa
 ret
 
 randomNumber: ; generate a random number using the system time
 push cx
 push dx
 push ax
 rdtsc ;getting a random number in ax dx
 xor dx,dx ;making dx 0                  (range from main)
 div cx ;dividing by 5 to get numbers from 0-4
 add dl,1
 mov [randomNum],dl ;moving the random number in variable
 pop ax
 pop dx
 pop cx
 ret
 
 sleep_s:
 push cx
 mov cx, 0x5 ; change the values  to increase delay time
 delay_loop1_s:
 push cx
 mov cx, 0xFFFF
 delay_loop2_s:
 loop delay_loop2_s
 pop cx
 loop delay_loop1_s
 pop cx
 ret
 
 sleep:
 push cx
 mov cx, 0x20 ; change the values  to increase delay time
 delay_loop1:
 push cx
 mov cx, 0xFFFF
 delay_loop2:
 loop delay_loop2
 pop cx
 loop delay_loop1
 pop cx
 ret
 
 movecursor:;moves cursor to suitable position
 push dx
 push ax
 push cs
 pop es
 mov ah,0x02
 mov dx,0x0000
 int 0x10
 pop ax
 pop dx
 ret
 
 populate:;inserts values in first row and drops down it to fill board
 pusha
 mov dx,0
 loop31:
 add dx,1
 mov bx,1
 mov cx,0
 loop30:
 add cx,1
 push bx
 push cx
 mov cx,8;range
 call randomNumber
 mov bx,[randomNum];
 mov al,[pool+bx]
 mov ah,[randomNum]
 pop cx
 pop bx
 call insert
 cmp cx,[boardsize]
 jne loop30
 mov bx,1
 loop1:
 mov cx,0
 add bx,1
 loop2:
 add cx,1
 call get_value
 push dx
 mov dx,[getvalue]
 cmp dl,' '
 jne exit_populate
 sub bx,1
 call get_value
 mov ax,0x0720
 call insert
 mov ax,[getvalue]
 add bx,1
 call insert
 exit_populate:
 pop dx
 cmp cx,[boardsize]
 jne loop2
 cmp bx,[boardsize];
 jne loop1
 cmp dx,[boardsize]
 jne loop31
 popa
 ret
 
 update_moves:;update moves at its location
 push bp 
 push es 
 push ax 
 push bx 
 push cx 
 push dx 
 push di 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ax, [remaingingmoves] ; load number in ax 
 mov bx, 10 ; use base 10 for division 
 mov cx, 0 ; initialize count of digits 
 nextdigit2:
 mov dx, 0 ; zero upper half of dividend 
 div bx ; divide by 10 
 add dl, 0x30 ; convert digit into ascii value 
 push dx ; save ascii value on stack 
 inc cx ; increment count of values 
 cmp ax, 0 ; is the quotient zero 
 jnz nextdigit2 ; if no divide it again 
 mov word[es:112],0x0720
 mov word[es:114],0x0720
 mov word[es:116],0x0720
 mov di,112
 nextpos2: 
 pop dx ; remove a digit from the stack 
 mov dh, 0x2F ; use normal attribute 
 mov [es:di], dx ; print char on screen 
 add di, 2 ; move to next screen location 
 loop nextpos2 ; repeat for all digits on stack
 pop di 
 pop dx 
 pop cx 
 pop bx 
 pop ax 
 pop es 
 pop bp 
 ret 
 
 update_score:;updates score a its location
 push bp 
 push es 
 push ax 
 push bx 
 push cx 
 push dx 
 push di 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ax, [score_num] ; load number in ax 
 mov bx, 10 ; use base 10 for division 
 mov cx, 0 ; initialize count of digits 
 nextdigit1:
 mov dx, 0 ; zero upper half of dividend 
 div bx ; divide by 10 
 add dl, 0x30 ; convert digit into ascii value 
 push dx ; save ascii value on stack 
 inc cx ; increment count of values 
 cmp ax, 0 ; is the quotient zero 
 jnz nextdigit1 ; if no divide it again 
 mov word[es:132],0x0720
 mov word[es:134],0x0720
 mov word[es:136],0x0720
 mov di,132
 nextpos1: 
 pop dx ; remove a digit from the stack 
 mov dh, 0x2F ; use normal attribute 
 mov [es:di], dx ; print char on screen 
 add di, 2 ; move to next screen location 
 loop nextpos1 ; repeat for all digits on stack
 pop di 
 pop dx 
 pop cx 
 pop bx 
 pop ax 
 pop es 
 pop bp 
 ret 

 grid:;prints lines score name
 call clrscr ; call the clrscr subroutine
 mov ax, 10 
 push ax ; push x position 
 mov ax, 0
 push ax ; push y position 
 mov ax, 0x9c ; attribute 
 push ax ; push attribute 
 mov ax, name 
 push ax ; push address of message 
 call printstr 
 mov ax, 40 
 push ax ; push x position 
 mov ax, 0 
 push ax ; push y position 
 mov ax, 0x2F ; attribute 
 push ax ; push attribute 
 mov ax, remaingingmovesmsg 
 push ax ; push string score of message
 call printstr
 call update_moves
 mov ax, 60 
 push ax ; push x position 
 mov ax, 0 
 push ax ; push y position 
 mov ax, 0x2F ; attribute 
 push ax ; push attribute 
 mov ax, score 
 push ax ; push string score of message
 call printstr
 mov ax, 23
 push ax ; push x position 
 mov ax, 0
 push ax ; push y position 
 mov ax, 0x9c ; attribute 
 push ax ; push attribute 
 mov ax, playerName 
 push ax ; push address of message 
 call printstr 
 call update_score
 mov ax,0xb800
 mov es,ax
 mov di,160;staring printing horizontal lines after first line
 call horizontal;printing rows
 mov ax,0xb800
 mov es,ax
 mov di,160;staring printing vertical lines after first line
 call vertical;printing columns
 call movecursor
 ret
 
 get_value:;return value of particular row and columns helper
 pusha
 mov ax,0x0b800
 mov es,ax
 mov di,0
 shl bx,1
 push cx
 mov cx,bx
 rowinc1:
 add di,160
 loop rowinc1
 add di,6
 pop cx
 colinc1:
 sub cx,1
 jz end1
 add di,12
 jmp colinc1
 end1:
 mov dx,word[es:di]
 mov [getvalue],dx
 popa
 ret
 
 vertical_duplicate:;remove vertical sequences
 pusha
 mov cx,0
 loop3:
 mov bx,0
 add cx,1
 loop4:
 add bx,1
 push bx
 call get_value
 mov ax,[getvalue] 
 cmp al,'B'
 je compare1
 cmp al,'X'
 je compare1
 mov si,1;number of matching char in cx
 loop7:
 add bx,1
 call get_value
 mov dx,[getvalue]
 cmp al,dl
 jne not_found_vertically
 add si,1
 cmp bx,[boardsize]
 je not_found_vertically
 jmp loop7
 not_found_vertically:
 cmp si,3; number to match sequence of
 jl compare1
 xor dx,dx
 mov dx,si
 pop bx
 loop8:
 mov ax,0x0720
 call insert
 push cx
 mov cx,[score_num]
 add cx,1
 mov [score_num],cx
 pop cx
 add bx,1
 sub dx,1
 cmp dx,0
 jne loop8
 call update_score
 sub bx,1
 cmp si,4
 jl nobomb1
 mov ah,0x4F
 mov al,'B'
 call insert 
 call update_score
 nobomb1:
 push bx
 compare1:
 pop bx
 mov ax,[boardsize]
 sub ax,1
 cmp bx,ax
 jle loop4
 mov ax,[boardsize]
 sub ax,1
 cmp cx,ax
 jle loop3
 popa
 ret
 
 horizontal_duplicate:;remove horitontal sequences
 pusha
 mov bx,0
 loop9:
 mov cx,0
 add bx,1
 loop10:
 add cx,1
 push cx
 call get_value
 mov ax,[getvalue] 
 cmp al,'B'
 je compare2
 cmp al,'X'
 je compare2
 mov si,1;number of matching char in cx
 loop11:
 add cx,1
 call get_value
 mov dx,[getvalue]
 cmp al,dl
 jne not_found_horizontally
 add si,1
 cmp cx,[boardsize]
 je not_found_horizontally
 jmp loop11
 not_found_horizontally:
 cmp si,3; number to match sequence of
 jl compare2
 xor dx,dx
 mov dx,si
 pop cx
 loop12:
 mov ax,0x0720
 call insert
 push cx
 mov cx,[score_num]
 add cx,1
 mov [score_num],cx
 pop cx
 add cx,1
 sub dx,1
 cmp dx,0
 jne loop12
 call update_score
 sub cx,1
 cmp si,4
 jl nobombv
 mov ah,0x4F
 mov al,'B'
 call insert 
 call update_score
 nobombv:
 push cx
 compare2:
 pop cx
 mov ax,[boardsize]
 sub ax,1
 cmp cx,ax
 jle loop10
 mov ax,[boardsize]
 sub ax,1
 cmp bx,ax
 jle loop9
 popa
 ret
 
 has_duplicate:;tells if board has anymore sequences
 mov bx,0
 loop16:
 mov cx,0
 add bx,1
 loop17:
 add cx,1
 push cx
 call get_value
 mov ax,[getvalue] 
 cmp al,'B'
 je compare3
  cmp al,'X'
 je compare3
 mov si,1;number of matching char in cx
 loop18:
 add cx,1
 call get_value
 mov dx,[getvalue]
 cmp al,dl
 jne not_found_horizontally1
 add si,1
 cmp cx,[boardsize]
 je not_found_horizontally1
 jmp loop18
 not_found_horizontally1:
 cmp si,3; number to match sequence of
 jl compare3
 mov ax,1
 pop cx
 jmp return1
 compare3:
 pop cx
 mov ax,[boardsize]
 sub ax,1
 cmp cx,ax
 jle loop17
 mov ax,[boardsize]
 sub ax,1
 cmp bx,ax
 jle loop16
 mov cx,0
 loop20:
 mov bx,0
 add cx,1
 loop21:
 add bx,1
 push bx
 call get_value
 mov ax,[getvalue]
 cmp al,'B'
 je compareh 
 cmp al,'X'
 je compareh 
 mov si,1;number of matching char in cx
 loop22:
 add bx,1
 call get_value
 mov dx,[getvalue]
 cmp al,dl
 jne not_found_vertically1
 add si,1
 cmp bx,[boardsize]
 je not_found_vertically1
 jmp loop22
 not_found_vertically1:
 cmp si,3; number to match sequence of
 jl compareh
 mov ax,1
 pop cx
 jmp return1
 compareh:
 pop bx
 mov ax,[boardsize]
 sub ax,1
 cmp bx,ax
 jle loop21
 mov ax,[boardsize]
 sub ax,1
 cmp cx,ax
 jle loop20
 mov ax,0
 return1:
 ret
 
 check_duplicate:;check sequences
 pusha
 loop15:
 mov ax,0
 call horizontal_duplicate
 call update_score
 call remove_blockers
 call populate
 call vertical_duplicate
 call update_score
 call remove_blockers
 call populate
 call has_duplicate
 cmp  ax,0
 jne loop15
 popa
 ret
 
 initialscreen:
 call clrscr
 mov dx,25
 mov bx,2
 mov ax,0
 mov cx,0x20
 loop13:
 call sleep_s
 push ax
 push bx ; push x position 
 push ax ; push y position  
 push cx ; push attribute 
 mov ax, welcomemsg 
 push ax ; push address of message 
 call printstr
 add cx,2
 pop ax
 add ax, 1
 add bx,2
 sub dx,1
 cmp dx,0
 jne loop13
 mov dx,25
 mov bx,51
 mov ax,0
 mov cx,0x20
 loop14:
 call sleep_s
 push ax
 push bx ; push x position 
 push ax ; push y position  
 push cx ; push attribute 
 mov ax, welcomemsg 
 push ax ; push address of message 
 call printstr
 add cx,2
 pop ax
 add ax, 1
 sub bx,2
 sub dx,1
 cmp dx,0
 jne loop14
 call sleep_s
 call sleep_s
 call clrscr
 mov ax, 20
 push ax ; push x position 
 mov ax, 1
 push ax ; push y position 
 mov ax, 0x40 ; attribute 
 push ax ; push attribute 
 mov ax, welcomemsg 
 push ax ; push address of message 
 call sleep_s
 call printstr
 mov ax, 5
 push ax ; push x position 
 mov ax, 7
 push ax ; push y position 
 mov ax, 0x40 ; attribute 
 push ax ; push attribute 
 mov ax, initiallmsg 
 push ax ; push address of message 
 call sleep_s
 call printstr 
 call inputPlayerName
 call clrscr
 mov ax, 12
 push ax ; push x position 
 mov ax, 7
 push ax ; push y position 
 mov ax, 0x28 ; attribute 
 push ax ; push attribute 
 mov ax, sizemsg 
 push ax ; push address of message 
 call sleep_s
 call printstr 
 call inputsize
 call sleep
 call clrscr
 ret
 
 endscreen:;good bye screen
 call clrscr
 mov ax, 5
 push ax ; push x position 
 mov ax, 7
 push ax ; push y position 
 mov ax, 0xEF ; attribute 
 push ax ; push attribute 
 mov ax, finalmsg 
 push ax ; push address of message 
 call sleep_s
 call printstr
 push bp 
 push es 
 push ax 
 push bx 
 push cx 
 push dx 
 push di 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ax, [score_num] ; load number in ax 
 mov bx, 10 ; use base 10 for division 
 mov cx, 0 ; initialize count of digits 
 nextdigit3:
 mov dx, 0 ; zero upper half of dividend 
 div bx ; divide by 10 
 add dl, 0x30 ; convert digit into ascii value 
 push dx ; save ascii value on stack 
 inc cx ; increment count of values 
 cmp ax, 0 ; is the quotient zero 
 jnz nextdigit3 ; if no divide it again 
 mov di,1210
 nextpos3: 
 pop dx ; remove a digit from the stack 
 mov dh, 0xEF ; use normal attribute 
 mov [es:di], dx ; print char on screen 
 add di, 2 ; move to next screen location 
 loop nextpos3 ; repeat for all digits on stack
 pop di 
 pop dx 
 pop cx 
 pop bx 
 pop ax 
 pop es 
 pop bp 
 call sleep
 ret
 
 insert_blockers:;insert initial blockers
 pusha
 mov cx,[boardsize]
 again_blocker:
 push cx
 mov cx,[boardsize]
 sub cx,2
 call randomNumber
 mov bx,[randomNum]
 add bx,1
 mov cx,[boardsize]
 sub cx,2
 call randomNumber
 mov cx,[randomNum]
 add cx,1
 mov ax,0x0720
 call insert
 mov ah,0x1F
 mov al,'X'
 call insert
 pop cx
 sub cx,1
 cmp cx,1
 jne again_blocker
 popa
 ret
 
 check_surroundings:;helper for remove blockers
 pusha
 call get_value
 mov al,'X'
 cmp [getvalue],al
 jne nosamevalueb
 sub bx,1
 call get_value
 add bx,1
 mov al,' '
 cmp al,[getvalue]
 jne next_compare1
 jmp exit_insert_space
 next_compare1:
 add bx,1
 call get_value
 mov al,' '
 sub bx,1
 cmp al,[getvalue]
 jne next_compare2
 jmp exit_insert_space
 next_compare2:
 sub cx,1
 call get_value
 add cx,1
 mov al,' '
 cmp al,[getvalue]
 jne next_compare3
 jmp exit_insert_space 
 next_compare3:
 add cx,1
 call get_value
 sub cx,1
 mov al,' '
 cmp al,[getvalue]
 jne nosamevalueb
 exit_insert_space:
 mov ax,0x0720
 call insert
 nosamevalueb:
 popa
 ret
 
 remove_blockers:;check if a space is created in surrounding
 pusha
 mov cx,[boardsize]
 sub cx,1
 verticalmoveb:
 mov bx,[boardsize]
 sub bx,1
 horizonatlmoveb:
 call check_surroundings
 sub bx,1
 cmp bx,1
 jg horizonatlmoveb
 sub cx,1
 cmp cx,1
 jg verticalmoveb
 popa
 call populate
 ret
 
 start:
 call initialscreen;welcome screen
 call grid;print lines
 call populate;insert character drop down
 call insert_blockers;insert blockers
 call check_duplicate;check initiall sequencces
 call update_score;update score
 again_main:
 call swapping;swapping
 call check_duplicate;check sequencces
 call update_score;update score moves updated here
 mov ax,[remaingingmoves]
 cmp ax,0
 jne again_main
 call clrscr
 call endscreen;good bye
 mov ax, 0x4c00 ; terminate program 
 int 0x21 