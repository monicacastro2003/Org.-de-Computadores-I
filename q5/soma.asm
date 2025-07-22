section .data
    num1    dd 15      ; Primeiro número
    num2    dd 27      ; Segundo número
    num3    dd 13      ; Terceiro número
    format  db "A soma dos dois maiores números é: %d", 10, 0

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp

    ; Carrega os três números
    mov eax, [num1]
    mov ebx, [num2]
    mov ecx, [num3]

    ; Encontra os dois maiores números
    cmp eax, ebx
    jge .compare_num1_num3
    xchg eax, ebx

.compare_num1_num3:
    cmp eax, ecx
    jge .compare_num2_num3
    xchg eax, ecx

.compare_num2_num3:
    cmp ebx, ecx
    jge .soma
    xchg ebx, ecx

.soma:
    add eax, ebx      ; Soma os dois maiores

    ; Prepara para chamar printf
    mov rdi, format
    mov esi, eax
    xor eax, eax
    call printf

    pop rbp
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits 
