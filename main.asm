%include "colon.inc"
%include "words.inc"

extern read_word
extern read_word
extern read_word
extern read_word
extern read_word
extern read_word
extern read_word
extern read_word

section .data
    word_buf: times 256 db 0

section .rodata ; read-only
    overflow_message: db "Строка больше заданного буфера (макс. 255 символов)", 0
    not_found_message: db "Не найдена строка", 0

section .text

global _start

_start:
    // TODO