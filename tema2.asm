; Homework by Razvan Radoi, first of his name
extern puts
extern printf
extern strchr
section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

;   **** Task1 ****    
xor_strings:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]   ; string1's begining address
    mov ebx, [ebp + 12]  ; string2's begining address
xor_loop:
    cmp byte[eax], 0x00  ; if the strings' size is 0, nothing to do 
    je end_xor_strings
    mov cl, byte[eax]    ; assert each byte from string1
    xor cl, byte[ebx]    ; xor byte i of string1 with byte i of string 2
    mov byte[eax], cl    ; put xor result in string on position i
    inc eax              ; inc i for string1
    inc ebx              ; inc i for string2
    cmp byte[eax], 0x00  ; if the end of strings is reached
    jne xor_loop
    
end_xor_strings:         ; then decoding is complete
    leave
    ret
    
;   **** End of Task 1 ****
;   **** Task 2 ****

rolling_xor:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]       ; put strings' begining address in eax 
    xor ebx, ebx
find_len:                    ; find strings' length
    inc ebx
    cmp byte[eax + ebx - 1], 0x00
    jne find_len
    
    add eax, ebx             ; mov eax to the begining of the next string
    sub eax, 2               ; then sub 2 so that it points to the end of the needed string
    
    xor ebx, ebx             ; clean up the registers just to make sure
    xor ecx, ecx
    xor edx, edx
    
rolling_loop:
    cmp byte[eax - 1], 0x00  ; if the strings' length is 0, nothing to do
    je end_rolling
    mov cl, byte[eax]        ; assert one byte from input string
    mov dl, byte[eax - 1]    ; assert its predecessor 
    xor cl, dl               ; xor them
    mov byte[eax], cl        ; xor result is the decoded byte
    dec eax                  ; move on to next byte
    cmp byte[eax - 1], 0x00  ; do so untill begining of the string is reached
    jne rolling_loop
    
end_rolling:
    leave
    ret

;   **** End of Task 2 ****
;   **** Task 3 ****
xor_hex_strings:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]    ; eax points to the begining of the first string
    mov edx, eax          ; so does edx (needed later)
    mov ebx, [ebp + 12]   ; ebx points to the begining of the second string
    mov edi, ebx          ; so does edi (needed later)
    
    mov esi, eax          ; esi points to the begining of the first string

change_string:   
    cmp byte[eax] , 0x00  ; if the size of the input is 0, nothing to do
    je next_change
    mov cl, byte[eax]     ; assert a byte from string1
    cmp cl, 57            ; if it's a number, change it to decimal, accordingly
    jle clIsNumber
    sub cl, 87            ; otherwise it's a letter; change it accordingly
    jmp next1
clIsNumber:
    sub cl, 48
next1:
    mov ch, byte[eax + 1] ; assert next byte from string1
    cmp ch, 57            ; and change it to decimal, similarly
    jle chisNumber
    sub ch, 87
    jmp next2
chisNumber:
    sub ch, 48
next2:
    shl cl, 4             ; cl = cl * 16
    add cl, ch            ; cl += ch
    mov byte[esi], cl     ; result is put on i/2 where i is position where eax points
    add esi, 1            ; increase pointer to i/2
    add eax, 2            ; increase pointer to i
    cmp byte[eax], 0x00   ; repeat untill all of string1 is changed
    jne change_string
next_change:
    mov byte[esi], 0x00   ; mark the ending of newely converted string1
    mov esi, ebx          ; change_key modifies the key(string2) just like string1   
change_key:
    cmp byte[ebx], 0x00
    je end_changes
    mov cl, byte[ebx]
    cmp cl, 57
    jle inClNum
    sub cl, 87
    jmp next3
inClNum:
    sub cl, 48
next3:
    mov ch, byte[ebx + 1]
    cmp ch, 57
    jle inChNum
    sub ch, 87
    jmp next4
inChNum:
    sub ch, 48
next4:
    shl cl, 4
    add cl, ch
    mov byte[esi], cl
    add esi, 1
    add ebx, 2
    cmp byte[ebx], 0x00
    jne change_key
    
end_changes:              ; at this point string1 and string2 look like the strings for task1
    mov byte[esi], 0x00
    
    mov eax, edx          ; this is why edx was used at the begining 
    mov ebx, edi          ; this is why edi was used at the begining
same_xor_loop:            ; xor string1(input string) and string2 (key)
    cmp byte[eax], 0x00   ; just like in the case of task2
    je end_this
    mov cl, byte[eax]
    xor cl, byte[ebx]
    mov byte[eax], cl
    inc eax
    inc ebx
    cmp byte[eax], 0x00
    jne same_xor_loop
end_this:

    leave
    ret
    
; **** End of Task 3 ****
; **** Begining of main ****
main:
    push ebp
    mov ebp, esp
    sub esp, 2300

    ;fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80

	;read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

	;close(fd);
	mov eax, 6
	int 0x80

	; all input.dat contents are now in ecx (address on stack)

	; TASK 1: Simple XOR between two byte streams
        xor eax, eax  ; use eax to determine length of string 1.1
determine_string_size1:
        inc eax
        cmp byte[ecx + eax - 1], 0x00
        jne determine_string_size1
        
        push ecx          ; push address of string 1.1
        add eax, ecx      ; determine address of string1.2
        mov esi, eax      ; good for task 2
        push eax          ; push address of string 1.2
        call xor_strings  ; call xor_strings function
        
        pop ecx
        add esp, 4
                        
        push ecx          ; Print the first resulting string
        call puts
        add esp, 4

	; TASK 2: Rolling XOR
        mov ecx, esi      ; remember using esi to store that address? nice.
        xor eax, eax      ; determine size of string 2
determine_string_size2:
        inc eax
        cmp byte[ecx + eax - 1], 0x00
        jne determine_string_size2
        
        
        add eax, ecx      ; determine begining of string 2
        xor esi, esi
        mov esi, eax      ; using esi again for task3

        push eax          ; push begining address of string 2
        call rolling_xor
        pop ecx           ; store resulting string in ecx
        push ecx          ; print resulting string
        call puts
        add esp, 4

	; TASK 3: XORing strings represented as hex strings

        xor ecx, ecx
        mov ecx, esi
        xor eax, eax      ; determine size of string 3.1
determine_string_size3:
        inc eax
        cmp byte[ecx + eax - 1], 0x00
        jne determine_string_size3
        
        add ecx, eax      ; determine begining address of string 3.1
        
        push ecx          ; push begining address of string 3.1
        
        xor eax, eax      ; determine size of string 3.2
determine_string_size4:
        inc eax
        cmp byte[ecx + eax - 1], 0x00
        jne determine_string_size4
        
        add ecx, eax      ; determine begining address of string 3.2
        
        push ecx          ; push the begining address of string 3.2
        
        call xor_hex_strings
        pop ecx           ; put result in ecx
        add esp, 4        ; dispose of string 3.2 begining address
        
        push ecx          ; pring resulting string
        call puts
        add esp, 4

        ; Phew, finally done
        ; You tell me
    xor eax, eax
    leave
    ret
