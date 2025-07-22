section .data
    numero      dq 123456789         ; número a imprimir
    newline     db 10                ; caractere de nova linha

section .bss
    buffer      resb 20              ; buffer para os dígitos

section .text
    global _start

_start:
    mov     rax, [numero]           ; carregar número
    cmp     rax, 0
    jne     print_number
    ; se for zero, imprime '0'
    mov     byte [buffer], '0'
    mov     rsi, buffer
    mov     rdx, 1
    jmp     write_result

print_number:
    mov     rbx, 10                 ; base decimal
    lea     rdi, [buffer + 20]      ; ponteiro para o fim do buffer
    mov     rcx, 0

convert_loop:
    xor     rdx, rdx
    div     rbx                     ; divide rax por 10
    dec     rdi
    add     dl, '0'
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     convert_loop

    mov     rsi, rdi                ; ponteiro para início da string
    mov     rdx, rcx                ; número de bytes a imprimir

write_result:
    mov     rax, 1                  ; syscall: write
    mov     rdi, 1                  ; stdout
    syscall

    ; imprime newline
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline
    mov     rdx, 1
    syscall

    ; sair do programa
    mov     rax, 60
    xor     rdi, rdi
    syscall
