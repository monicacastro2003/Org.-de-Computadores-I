section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    prompt      db "Digite data/hora (dd/mm/aaaa hh:mm:ss): ", 0
    fmt_input   db "%d/%d/%d %d:%d:%d", 0
    fmt_output  db "Timestamp Unix: %ld", 10, 0
    error_fmt   db "Formato inválido!", 10, 0
    timezone    db "TZ=UTC", 0        ; Forçar UTC

section .bss
    dia     resd 1
    mes     resd 1
    ano     resd 1
    hora    resd 1
    minuto  resd 1
    segundo resd 1
    tm      resb 56                  

section .text
    global main
    extern printf, scanf, mktime, exit, memset, putenv

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                     

    ; Configurar timezone para UTC
    mov rdi, timezone
    call putenv

    ; Imprimir prompt
    mov rdi, prompt
    xor eax, eax
    call printf

    ; Configurar scanf
    mov rdi, fmt_input
    lea rsi, [dia]
    lea rdx, [mes]
    lea rcx, [ano]
    lea r8, [hora]
    lea r9, [minuto]
    push qword 0                    
    lea rax, [segundo]
    push rax                         
    xor eax, eax                     
    call scanf
    add rsp, 16                      
    cmp eax, 6
    jne .erro

    ; Inicializar struct tm
    lea rdi, [tm]
    xor rsi, rsi
    mov rdx, 56
    call memset

    ; Preencher struct tm
    mov eax, [segundo]
    mov [tm], eax                    ; tm_sec (0)
    mov eax, [minuto]
    mov [tm+4], eax                  ; tm_min (4)
    mov eax, [hora]
    mov [tm+8], eax                  ; tm_hour (8)
    mov eax, [dia]
    mov [tm+12], eax                 ; tm_mday (12)
    mov eax, [mes]
    dec eax
    mov [tm+16], eax                 ; tm_mon (16)
    mov eax, [ano]
    sub eax, 1900
    mov [tm+20], eax                 ; tm_year (20)
    mov dword [tm+32], -1            ; tm_isdst (32)

    ; Chamar mktime
    lea rdi, [tm]
    call mktime
    cmp rax, -1
    je .erro

    ; Imprimir resultado
    mov rsi, rax
    mov rdi, fmt_output
    xor eax, eax
    call printf

    ; Sair com sucesso
    xor edi, edi
    call exit

.erro:
    mov rdi, error_fmt
    xor eax, eax
    call printf
    mov edi, 1
    call exit
