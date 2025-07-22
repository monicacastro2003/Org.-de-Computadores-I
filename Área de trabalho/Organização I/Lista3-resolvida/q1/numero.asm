section .note.GNU-stack noalloc noexec nowrite progbits
section .data
    fmt_float  db "%.8g", 10, 0    ; Formato para float + \n
    fmt_double db "%.17g", 10, 0    ; Formato para double + \n

section .text
    global print_float
    extern printf

print_float:
    push rbp
    mov rbp, rsp
    
    ; Verificar bits (32 ou 64)
    cmp esi, 32
    je .load_float
    cmp esi, 64
    je .load_double
    jmp .end

.load_float:
    movss xmm0, [rdi]       ; Carrega float
    cvtss2sd xmm0, xmm0     ; Converte para double
    mov rdi, fmt_float      ; Formato de saída
    jmp .call_printf

.load_double:
    movsd xmm0, [rdi]       ; Carrega double
    mov rdi, fmt_double     ; Formato de saída

.call_printf:
    ; Alinhamento de pilha para System V ABI
    mov al, 1               ; 1 argumento vetorial
    call printf

.end:
    pop rbp
    ret
