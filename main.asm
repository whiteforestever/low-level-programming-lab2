section .data
    word_buf: times 256 db 0

section .rodata ; read-only
    overflow_message: db "Строка больше заданного буфера (макс. 255 символов)", 0
    not_found_message: db "Не найдена введенная строка", 0

section .text
%include "colon.inc"
%include "words.inc"

extern exit
extern print_string
extern string_length
extern print_char
extern print_newline
extern print_uint
extern print_int
extern string_equals
extern read_char
extern read_word
extern parse_uint
extern parse_int
extern string_copy
extern print_error
extern find_word

global _start

; Читает строку размером не более 255 символов в буфер с `stdin`.
; Пытается найти вхождение в словаре; 
; если оно найдено, распечатывает в `stdout` значение по этому ключу.
; Иначе выдает сообщение об ошибке.
; Не забудьте, что сообщения об ошибках нужно выводить в `stderr`.
_start:
    mov rdi, word_buf
    mov rsi, 256
    call read_word
    test rax, rax
    jz .overflow

    mov rdi, rax
    mov rsi, link
    call find_word
    test rax, rax
    jz .not_found

    add rax, 8              ; тк возвращается адрес, а нужен ключ
    mov rdi, rax
    call string_length      ; длина ключа
    add rdi, rax            ; переходим в конец ключа (null-terminator)
    inc rdi                 ; rdi = address of the beggining value
    call print_string
    call print_newline
    call exit

    .overflow:
        mov rdi, overflow_message
        call print_error
        call print_newline
        call exit

    .not_found:
        mov rdi, not_found_message
        call print_error
        call print_newline
        call exit
