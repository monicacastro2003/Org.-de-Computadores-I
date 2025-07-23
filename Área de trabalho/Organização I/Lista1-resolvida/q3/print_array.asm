section .text
    global print_array_int
    extern printf

print_array_int:
    push rbp
    mov rbp, rsp
    push r12              ; Preservar r12 (para o ponteiro do array)
    push r13              ; Preservar r13 (para o tamanho)
    push r14              ; Preservar r14 (para o contador i)

    mov r12, rdi          ; r12 = ponteiro do array
    mov r13, rsi          ; r13 = tamanho do array
    xor r14, r14          ; i = 0

.loop:
    cmp r14, r13          ; Compara i com tamanho
    jge .fim

    ; Prepara args para printf
    mov rdi, formato      ; Formato "%d\n" (primeiro arg)
    mov esi, [r12 + r14*4] ; array[i] (segundo arg)
    xor eax, eax           ; Nenhum registro SSE usado
    call printf

    inc r14               ; i++
    jmp .loop

.fim:
    pop r14               ; Restaura r14
    pop r13               ; Restaura r13
    pop r12               ; Restaura r12
    pop rbp
    ret

section .data
    formato db "%d", 10, 0  ; Formato: "%d\n"
    
section .note.GNU-stack noalloc noexec nowrite progbits
    
    
