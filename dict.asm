section .text

extern string_equals

global find_word

; rdi - Указатель на нуль-терминированную строку.
; rsi - Указатель на начало словаря.
; return address of the beginning of entry
; into the dictionary
; return rax = 0 if not found
find_word:    
    xor rax, rax

    .loop:
        test rsi, rsi
        jz .return_0
        push rdi
        push rsi
        add rsi, 8  ; чтобы получить ключ
        call string_equals
        pop rsi
        pop rdi
        test rax, rax
        jz .found
        mov rsi, [rsi] ; переходим дальше по списку, если не пришли в начало
        jmp .loop

    .found:
        mov rax, rsi
        ret

    .return_0:
        xor rax, rax
        ret
