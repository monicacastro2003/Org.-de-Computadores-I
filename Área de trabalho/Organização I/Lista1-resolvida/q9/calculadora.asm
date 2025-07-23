section .data
    prompt      db "Digite a data e hora (dd/mm/aaaa hh:mm:ss): ", 0
    prompt_len  equ $ - prompt
    result      db "Timestamp Unix: ", 0
    result_len  equ $ - result
    newline     db 10, 0
    error_msg   db "Formato inválido! Use: dd/mm/aaaa hh:mm:ss", 10, 0
    error_len   equ $ - error_msg

    ; Constantes
    days_in_month dd 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    epoch_year    equ 1970
    sec_per_day   equ 86400
    sec_per_hour  equ 3600
    sec_per_min   equ 60

section .bss
    input       resb 50
    day         resd 1
    month       resd 1
    year        resd 1
    hour        resd 1
    minute      resd 1
    second      resd 1
    timestamp   resq 1
    buffer      resb 20

section .text
    global _start

_start:
    ; Mostrar prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Ler entrada
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 50
    syscall

    ; Processar entrada
    call parse_input
    cmp rax, 0
    je .error

    ; Validar data
    call validate_date
    cmp rax, 0
    je .error

    ; Calcular timestamp
    call calculate_timestamp

    ; Mostrar resultado
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, result_len
    syscall

    call print_number
    call print_newline
    jmp .exit

.error:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall

;----------------------------------------------------------
parse_input:
    xor rax, rax
    lea rsi, [input]

    ; Dia
    call parse_decimal
    test rdx, rdx
    jz .invalid
    mov [day], eax

    ; Verificar /
    cmp byte [rsi], '/'
    jne .invalid
    inc rsi

    ; Mês
    call parse_decimal
    test rdx, rdx
    jz .invalid
    mov [month], eax

    ; Verificar /
    cmp byte [rsi], '/'
    jne .invalid
    inc rsi

    ; Ano
    call parse_decimal
    test rdx, rdx
    jz .invalid
    mov [year], eax

    ; Verificar espaço
    cmp byte [rsi], ' '
    jne .invalid
    inc rsi

    ; Hora
    call parse_decimal
    test rdx, rdx
    jz .invalid
    mov [hour], eax

    ; Verificar :
    cmp byte [rsi], ':'
    jne .invalid
    inc rsi

    ; Minuto
    call parse_decimal
    test rdx, rdx
    jz .invalid
    mov [minute], eax

    ; Verificar :
    cmp byte [rsi], ':'
    jne .invalid
    inc rsi

    ; Segundo
    call parse_decimal
    test rdx, rdx
    jz .invalid
    mov [second], eax

    ; Verificar final (newline ou null)
    cmp byte [rsi], 10
    je .valid
    cmp byte [rsi], 0
    je .valid

.invalid:
    xor rax, rax
    ret

.valid:
    mov rax, 1
    ret

;----------------------------------------------------------
parse_decimal:
    xor eax, eax
    xor rcx, rcx
    xor rdx, rdx

.next_digit:
    mov cl, byte [rsi]
    cmp cl, '0'
    jb .done
    cmp cl, '9'
    ja .done

    imul eax, 10
    sub ecx, '0'
    add eax, ecx
    inc rsi
    inc rdx
    jmp .next_digit

.done:
    ret

;----------------------------------------------------------
validate_date:
    ; Validar ano
    mov eax, [year]
    cmp eax, epoch_year
    jl .invalid

    ; Validar mês
    mov eax, [month]
    cmp eax, 1
    jl .invalid
    cmp eax, 12
    jg .invalid

    ; Validar dia
    call check_day_in_month
    cmp rax, 0
    je .invalid

    ; Validar hora
    mov eax, [hour]
    cmp eax, 0
    jl .invalid
    cmp eax, 23
    jg .invalid

    ; Validar minuto
    mov eax, [minute]
    cmp eax, 0
    jl .invalid
    cmp eax, 59
    jg .invalid

    ; Validar segundo
    mov eax, [second]
    cmp eax, 0
    jl .invalid
    cmp eax, 59
    jg .invalid

    mov rax, 1
    ret

.invalid:
    xor rax, rax
    ret

;----------------------------------------------------------
check_day_in_month:
    mov eax, [month]
    dec eax
    mov ecx, [days_in_month + eax*4]

    ; Verificar fevereiro em ano bissexto
    mov eax, [month]
    cmp eax, 2
    jne .not_feb

    mov eax, [year]
    call is_leap_year
    test rax, rax
    jz .not_feb
    mov ecx, 29

.not_feb:
    mov eax, [day]
    cmp eax, ecx
    jg .invalid

    mov rax, 1
    ret

.invalid:
    xor rax, rax
    ret

;----------------------------------------------------------
is_leap_year:
    xor edx, edx
    mov ecx, 400
    div ecx
    test edx, edx
    jz .leap

    mov eax, [year]
    xor edx, edx
    mov ecx, 100
    div ecx
    test edx, edx
    jz .not_leap

    mov eax, [year]
    xor edx, edx
    mov ecx, 4
    div ecx
    test edx, edx
    jz .leap

.not_leap:
    xor rax, rax
    ret

.leap:
    mov rax, 1
    ret

;----------------------------------------------------------
calculate_timestamp:
    push rbp
    mov rbp, rsp

    ; Zerar acumulador
    mov qword [timestamp], 0

    ; 1. Calcular dias desde epoch
    call calculate_days_since_epoch
    imul rax, sec_per_day
    add [timestamp], rax

    ; 2. Adicionar horas
    mov eax, [hour]
    imul rax, sec_per_hour
    add [timestamp], rax

    ; 3. Adicionar minutos
    mov eax, [minute]
    imul rax, sec_per_min
    add [timestamp], rax

    ; 4. Adicionar segundos
    mov eax, [second]
    add [timestamp], rax

    leave
    ret

;----------------------------------------------------------
calculate_days_since_epoch:
    push rbp
    mov rbp, rsp

    ; Dias dos anos completos (1970 até ano-1)
    mov ecx, [year]
    sub ecx, epoch_year
    jle .year_done

    mov r8d, epoch_year
    xor r9, r9

.year_loop:
    mov eax, r8d
    call is_leap_year
    test rax, rax
    jz .not_leap

    add r9, 366
    jmp .next_year

.not_leap:
    add r9, 365

.next_year:
    inc r8d
    loop .year_loop

.year_done:
    ; Dias dos meses completos no ano atual
    mov ecx, [month]
    dec ecx
    jz .month_done

    xor ebx, ebx
    xor r10d, r10d

.month_loop:
    mov eax, [days_in_month + ebx*4]
    
    ; Ajuste para fevereiro em ano bissexto
    cmp ebx, 1
    jne .not_feb
    mov eax, [year]
    call is_leap_year
    test rax, rax
    jz .not_feb
    mov eax, 29

.not_feb:
    add r10d, eax
    inc ebx
    cmp ebx, ecx
    jl .month_loop

.month_done:
    ; Somar todos os dias
    add r9, r10

    ; Adicionar dias do mês atual (dia-1)
    mov eax, [day]
    dec eax
    add r9, rax

    mov rax, r9
    leave
    ret

;----------------------------------------------------------
print_number:
    mov rax, [timestamp]
    lea rdi, [buffer + 19]
    mov byte [rdi], 0
    mov rcx, 10

.convert_loop:
    dec rdi
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    test rax, rax
    jnz .convert_loop

    ; Calcular tamanho
    mov rsi, rdi
    lea rdx, [buffer + 19]
    sub rdx, rsi

    ; Mostrar número
    mov rax, 1
    mov rdi, 1
    syscall
    ret

;----------------------------------------------------------
print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
