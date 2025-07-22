section .note.GNU-stack noalloc noexec nowrite progbits
section .data
    ; Matriz com determinante = 1.0
    align 16
    matrix      dd 1.0, 2.0, 3.0   ; Linha 1
                dd 0.0, 1.0, 4.0   ; Linha 2
                dd 5.0, 6.0, 0.0   ; Linha 3
    fmt         db "Determinante: %.3f", 10, 0

section .bss
    result      resq 1              ; Espaço para armazenar o resultado

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16                    ; Alinhamento de pilha

    ; --- Cálculo do determinante ---
    fld dword [matrix+16]          ; e
    fmul dword [matrix+32]         ; e*i
    fld dword [matrix+20]          ; f
    fmul dword [matrix+28]         ; f*h
    fsubp                          ; ei-fh
    fmul dword [matrix]            ; a*(ei-fh)

    fld dword [matrix+12]          ; d
    fmul dword [matrix+32]         ; d*i
    fld dword [matrix+20]          ; f
    fmul dword [matrix+24]         ; f*g
    fsubp                          ; di-fg
    fmul dword [matrix+4]          ; b*(di-fg)
    fsubp                          ; subtrai

    fld dword [matrix+12]          ; d
    fmul dword [matrix+28]         ; d*h
    fld dword [matrix+16]          ; e
    fmul dword [matrix+24]         ; e*g
    fsubp                          ; dh-eg
    fmul dword [matrix+8]          ; c*(dh-eg)
    faddp                          ; resultado final

    ; Armazena o resultado na memória
    fstp qword [result]

    ; Chama printf
    mov rdi, fmt
    movq xmm0, [result]
    mov rax, 1
    call printf

    add rsp, 16
    pop rbp
    xor eax, eax
    ret
