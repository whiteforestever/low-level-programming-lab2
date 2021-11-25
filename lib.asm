section .data

newline_char: db 10

section .text

global exit
global print_string
global string_length
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy

    ; Принимает код возврата и завершает текущий процесс
exit:
    mov rax, 60
    xor rdi, rdi
    syscall

    ; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rdi
    call string_length
    pop rsi
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    ret

    ; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax

    .loop:
        cmp byte[rdi+rax], 0
        je .return
        inc rax
        jmp .loop

    .return:
        ret

    ; Принимает код символа и выводит его в stdout
print_char:
    push rdi
    mov rdx, 1              ; the amount of bytes to write
    mov rax, 1              ; 'write' syscall identifier
    mov rsi, rsp            ; where do we take data from
    mov rdi, 1              ; stdout file descriptor
    syscall
    pop rdi
    ret

    ; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 0xA
    call print_char
    ret

    ; Выводит беззнаковое 8-байтовое число в десятичном формате 
    ; Совет: выделите место в стеке и храните там результаты деления
    ; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r8, rsp             ; r8 = return address
    mov rax, rdi
    mov rcx, 10

    .loop:
        xor rdx, rdx
        div rcx             ; в rax оставшееся число, в rdx остаток от деления (текущая цифра)
        add rdx, 0x30
        push rdx
        test rax, rax
        jnz .loop
    .recover:
        pop rdx
        cmp rdx, r8
        je .return
        add rax, rdx
        mul r10
    .return:
        ret

    ; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    test rdi, rdi
    jns print_uint
    neg rdi
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    jmp print_uint


    ; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor r8, r8
    xor r9, r9

    .string_equals_loop:
        mov r8b, [rdi]
        mov r9b, [rsi]
        cmp r8, r9
        jnz .return_0
        inc rdi
        inc rsi
        cmp r8, 0
        jnz .string_equals_loop
        mov rax, 1
        ret
        
    .return_0:
        xor rax, rax
        ret

    ; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    xor rax, rax
    xor rdi, rdi
    push 0         
    mov rsi, rsp  
    mov rdx, 1
    syscall
    pop rax
    cmp rax, 0x0          ; код null
    jz .return_0
    ret

    .return_0:
        mov rax, 0
        ret

    ; Принимает: адрес начала буфера, размер буфера
    ; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
    ; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
    ; Останавливается и возвращает 0 если слово слишком большое для буфера
    ; При успехе возвращает адрес буфера в rax, длину слова в rdx.
    ; При неудаче возвращает 0 в rax
    ; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    push r12                ; callee-saved register
    mov r9, rdi	            ; pointer where is the next character written to
    xor r11,r11	            ; index (at the end is the length)
    mov r12,rdi

    .skip_tabs:
        push r11
        push rsi
        call read_char
        pop rsi
        pop r11
        cmp rax, 0x0        ; null
        je .end
        cmp rax, 0x20       ; пробел
        je .skip_tabs
        cmp rax, 0x9        ; табуляция
        je .skip_tabs
        cmp rax, 0xA        ; перевод строки
        je .skip_tabs
        mov [r9], al
        inc r9              ; next symbol
        inc r11             ; index (length)++

    .read_symbol:
        cmp rsi, r11         ; if (size == 0) return 0
        je .return_0
        push r11            ; caller-saved, syscall changes the value
        push rsi
        call read_char
        pop rsi
        pop r11
        cmp rax, 0x0        ; null
        je .end
        cmp rax, 0x20       ; пробел
        je .end
        cmp rax, 0x9        ; табуляция
        je .end
        cmp rax, 0xA        ; перевод строки
        je .end
        mov [r9], rax
        inc r9              ; next symbol
        inc r11             ; index (length)++
        jmp .read_symbol
        
    .return_0:
        mov rdx, 0
        pop r12
        mov rax, 0
        ret

    .end:
        mov byte[r9], 0
        mov rdx, r11
        mov rax, r12
        pop r12
        ret

    ; Принимает указатель на строку, пытается
    ; прочитать из её начала беззнаковое число.
    ; Возвращает в rax: число, rdx : его длину в символах
    ; rdx = 0 если число прочитать не удалось
parse_uint:
    xor r8, r8              ; текущий символ
    xor rcx, rcx            ; счетчик длины
    mov r10, 10
    xor rax, rax            ; результат


    .A:
        mov r8b, [rdi]
        inc rdi
        cmp r8b, '0'
        jb .end
        cmp r8b, '9'
        ja .end
        sub r8b, '0'
        mov al, r8b
        inc rcx

    .B:
        mov r8b, [rdi]
        inc rdi
        cmp r8b, '0'
        jb .end
        cmp r8b, '9'
        ja .end
        inc rcx
        mul r10
        sub r8b, '0'
        add rax, r8
        jmp .B

    .end:
        mov rdx, rcx
        ret


    ; Принимает указатель на строку, пытается
    ; прочитать из её начала знаковое число.
    ; Если есть знак, пробелы между ним и числом не разрешены.
    ; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
    ; rdx = 0 если число прочитать не удалось
parse_int:
    cmp byte[rdi], '-'
    jz .negative
    call parse_uint
    ret

    .negative:
        inc rdi
        call parse_uint
        test rdx, rdx
        jz .err
        inc rdx             ; включаем в длину минус
        neg rax
        ret

    .err:
        xor rax, rax
        ret

    ; Принимает указатель на строку (rdi), указатель на буфер (rsi) и длину буфера (rdx)
    ; Копирует строку в буфер
    ; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    call string_length
    cmp rax, rdx
    jg .return_0

    .loop:
        mov rdx, [rdi]
        mov [rsi], rdx
        cmp dl, 0
        je .return
        inc rsi
        inc rdi
        jmp .loop

    .return_0:
        xor rax, rax

    .return:
        ret