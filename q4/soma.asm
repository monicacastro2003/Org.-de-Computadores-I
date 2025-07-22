section .data
    prompt1 db "Digite o primeiro número: ", 0
    prompt2 db "Digite o segundo número: ", 0
    prompt3 db "Digite o terceiro número: ", 0
    format  db "A soma dos dois maiores números é: %d", 10, 0
    scanf_fmt db "%d", 0    ; Formato para scanf

section .bss
    num1 resd 1             ; Reserva espaço para 3 inteiros
    num2 resd 1
    num3 resd 1

section .text
    global main
    extern printf, scanf

main:
    push rbp
    mov rbp, rsp

    ; Lê o primeiro número
    mov rdi, prompt1
    xor eax, eax
    call printf
    mov rdi, scanf_fmt
    mov rsi, num1
    xor eax, eax
    call scanf

    ; Lê o segundo número
    mov rdi, prompt2
    xor eax, eax
    call printf
    mov rdi, scanf_fmt
    mov rsi, num2
    xor eax, eax
    call scanf

    ; Lê o terceiro número
    mov rdi, prompt3
    xor eax, eax
    call printf
    mov rdi, scanf_fmt
    mov rsi, num3
    xor eax, eax
    call scanf

    ; Carrega os três números
    mov eax, [num1]
    mov ebx, [num2]
    mov ecx, [num3]

    ; Encontra os dois maiores (mesma lógica anterior)
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
    add eax, ebx            ; Soma os dois maiores

    ; Imprime o resultado
    mov rdi, format
    mov esi, eax
    xor eax, eax
    call printf

    pop rbp
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
