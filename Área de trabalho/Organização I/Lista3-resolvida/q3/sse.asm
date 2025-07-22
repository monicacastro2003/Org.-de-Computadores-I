section .note.GNU-stack noalloc noexec nowrite progbits
section .data
    align 16
    row1: dd 1.0, 2.0, 3.0, 0.0   ; Linha 1: a, b, c
    row2: dd 0.0, 1.0, 4.0, 0.0   ; Linha 2: d, e, f
    row3: dd 5.0, 6.0, 0.0, 0.0   ; Linha 3: g, h, i
    fmt: db "Determinante (SSE): %.3f", 10, 0

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Carrega elementos individuais
    movss xmm0, [row1]        ; a
    movss xmm1, [row1+4]      ; b
    movss xmm2, [row1+8]      ; c
    
    movss xmm3, [row2]        ; d
    movss xmm4, [row2+4]      ; e
    movss xmm5, [row2+8]      ; f
    
    movss xmm6, [row3]        ; g
    movss xmm7, [row3+4]      ; h
    movss xmm8, [row3+8]      ; i

    ; --- Cálculo do determinante ---
    ; det = a(ei - fh) - b(di - fg) + c(dh - eg)

    ; Calcula ei - fh (usando xmm9 como temporário)
    movss xmm9, xmm4          ; e
    mulss xmm9, xmm8          ; e*i
    movss xmm10, xmm5         ; f
    mulss xmm10, xmm7         ; f*h
    subss xmm9, xmm10         ; ei - fh
    mulss xmm0, xmm9          ; a*(ei - fh)

    ; Calcula di - fg (usando xmm9 como temporário)
    movss xmm9, xmm3          ; d
    mulss xmm9, xmm8          ; d*i
    movss xmm10, xmm5         ; f
    mulss xmm10, xmm6         ; f*g
    subss xmm9, xmm10         ; di - fg
    mulss xmm1, xmm9          ; b*(di - fg)
    subss xmm0, xmm1          ; acumulado

    ; Calcula dh - eg (usando xmm9 como temporário)
    movss xmm9, xmm3          ; d
    mulss xmm9, xmm7          ; d*h
    movss xmm10, xmm4         ; e
    mulss xmm10, xmm6         ; e*g
    subss xmm9, xmm10         ; dh - eg
    mulss xmm2, xmm9          ; c*(dh - eg)
    addss xmm0, xmm2          ; resultado final

    ; Armazena e imprime
    movss [rsp+8], xmm0
    mov rdi, fmt
    movss xmm0, [rsp+8]
    cvtss2sd xmm0, xmm0
    mov rax, 1
    call printf

    add rsp, 16
    pop rbp
    xor eax, eax
    ret
