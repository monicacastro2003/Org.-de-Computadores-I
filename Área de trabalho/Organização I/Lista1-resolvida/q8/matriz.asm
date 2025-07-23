section .data
    matA: dd 1, 2, 3
          dd 4, 5, 6
          dd 7, 8, 9

    matB: dd 9, 8, 7
          dd 6, 5, 4
          dd 3, 2, 1

    fmt: db "%d ", 0
    newline: db 10, 0

section .bss
    matC: resd 9

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp

    ; Inicialização de matC
    mov rdi, matC
    mov rcx, 9
    xor eax, eax
    rep stosd

    ; Multiplicação de matrizes
    xor rbx, rbx        ; i = 0
row_loop:
    cmp rbx, 3
    jge print_matrix

    xor rcx, rcx        ; j = 0
col_loop:
    cmp rcx, 3
    jge next_row

    ; Calcular endereço de matC[i][j]
    mov rax, rbx
    imul rax, 3
    add rax, rcx
    lea r12, [matC + rax*4]  ; r12 = &matC[i][j]

    xor r13, r13        ; k = 0
    xor r14d, r14d      ; acumulador = 0
mult_loop:
    cmp r13, 3
    jge store_result

    ; A[i][k]
    mov rax, rbx
    imul rax, 3
    add rax, r13
    mov eax, [matA + rax*4]

    ; B[k][j]
    mov rdx, r13
    imul rdx, 3
    add rdx, rcx
    mov edx, [matB + rdx*4]

    ; Acumular
    imul eax, edx
    add r14d, eax

    inc r13
    jmp mult_loop

store_result:
    mov [r12], r14d     ; matC[i][j] = acumulador

    inc rcx
    jmp col_loop

next_row:
    inc rbx
    jmp row_loop

print_matrix:
    ; Configuração segura para impressão
    xor r15, r15        ; i = 0
print_row:
    cmp r15, 3
    jge end_program

    xor r14, r14        ; j = 0
print_col:
    cmp r14, 3
    jge next_print_row

    ; Calcular posição e carregar valor
    mov rax, r15
    imul rax, 3
    add rax, r14
    mov esi, [matC + rax*4]  ; Valor para printf

    ; Chamada segura para printf
    mov rdi, fmt
    xor eax, eax        ; Número de registros vetoriais = 0
    call printf

    inc r14
    jmp print_col

next_print_row:
    ; Nova linha
    mov rdi, newline
    xor eax, eax
    call printf

    inc r15
    jmp print_row

end_program:
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret
    
    
    
section .note.GNU-stack noalloc noexec nowrite progbits
