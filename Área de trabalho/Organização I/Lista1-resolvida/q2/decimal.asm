section .data
    numero      dq -987654321       ; número sinalizado
    newline     db 10               ; quebra de linha

section .bss
    buffer      resb 20             ; buffer para dígitos (até 20)

section .text
    global _start

_start:
    mov     rax, [numero]           ; carrega o número
    mov     rsi, buffer             ; rsi = buffer (vamos reutilizar depois)
    cmp     rax, 0
    jl      negativo                ; se rax < 0, pula para tratar sinal

positivo:
    cmp     rax, 0
    jne     print_number
    ; se for zero, imprime '0'
    mov     byte [buffer], '0'
    mov     rsi, buffer
    mov     rdx, 1
    jmp     write_result

negativo:
    ; imprime o sinal '-'
    mov     rax, 1                  ; syscall write
    mov     rdi, 1                  ; stdout
    mov     rsi, minus
    mov     rdx, 1
    syscall

    mov     rax, [numero]
    neg     rax                     ; transforma o número em positivo

print_number:
    mov     rbx, 10
    lea     rdi, [buffer + 20]
    mov     rcx, 0

convert_loop:
    xor     rdx, rdx
    div     rbx
    dec     rdi
    add     dl, '0'
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     convert_loop

    mov     rsi, rdi
    mov     rdx, rcx

write_result:
    mov     rax, 1
    mov     rdi, 1
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

section .data
    minus db '-'
