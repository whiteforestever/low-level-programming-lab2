%define link 0 ; только для первого раза

; %1 - Ключ (в кавычках)
; %2 - Имя метки, по которой будет находиться значение
%macro colon 2

    %ifstr %1
        %ifid %2
            %2:
                dq link
                db %1, 0
        %else
            %error "Не определена метка"
        %endif
    %else
        %error "Не определен ключ"
    %endif

    %define link %2

%endmacro