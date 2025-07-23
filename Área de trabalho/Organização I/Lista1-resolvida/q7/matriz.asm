section .data
    ; Matriz 3x3 de exemplo (linhas x colunas)
    matriz dd 1, 2, 3     ; linha 0
           dd 4, 5, 6     ; linha 1
           dd 7, 8, 9     ; linha 2
    
    format db "O determinante da matriz 3x3 é: %d", 10, 0

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp

    ; ---- Cálculo dos produtos das diagonais PRINCIPAIS (soma) ----
    ; a11 * a22 * a33
    mov eax, [matriz + 0]     ; a11
    imul eax, [matriz + 16]   ; a22
    imul eax, [matriz + 32]   ; a33
    mov ebx, eax              ; guarda em ebx

    ; a12 * a23 * a31
    mov eax, [matriz + 4]     ; a12
    imul eax, [matriz + 20]   ; a23
    imul eax, [matriz + 24]   ; a31 (linha 2, coluna 0)
    add ebx, eax              ; soma ao resultado

    ; a13 * a21 * a32
    mov eax, [matriz + 8]     ; a13
    imul eax, [matriz + 12]   ; a21
    imul eax, [matriz + 28]   ; a32
    add ebx, eax              ; soma ao resultado

    ; ---- Cálculo dos produtos das diagonais SECUNDÁRIAS (subtração) ----
    ; a13 * a22 * a31
    mov eax, [matriz + 8]     ; a13
    imul eax, [matriz + 16]   ; a22
    imul eax, [matriz + 24]   ; a31
    sub ebx, eax              ; subtrai do resultado

    ; a11 * a23 * a32
    mov eax, [matriz + 0]     ; a11
    imul eax, [matriz + 20]   ; a23
    imul eax, [matriz + 28]   ; a32
    sub ebx, eax              ; subtrai do resultado

    ; a12 * a21 * a33
    mov eax, [matriz + 4]     ; a12
    imul eax, [matriz + 12]   ; a21
    imul eax, [matriz + 32]   ; a33
    sub ebx, eax              ; subtrai do resultado

    ; ---- Imprime o resultado ----
    mov rdi, format
    mov esi, ebx
    xor eax, eax
    call printf

    ; ---- Encerra o programa ----
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret
    
section .note.GNU-stack noalloc noexec nowrite progbits
