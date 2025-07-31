    ; Comando terminal 
    ; gdb ./BubbleSort
    ; (gdb) break _start          Marca o ponto de início
    ; (gdb) run                   Executa o programa
    ; (gdb)  x/6gd &array         Examina os 6 elementos do array antes da ordenação
    ; (gdb) break bubble_terminou Para antes de terminar
    ; (gdb) continue              Vai rodando
    ; (gdb) x/6gd &array          Examina os 6 elementos do array depois da ordenação
     

section .data
    array dq 5, 2, 8, 1, 9, 3   ; Array de exemplo com 6 elementos
    tam equ 6 ; Tamanho do array

section .text
    global _start

_start:
    ; Chama função bubble sort
    ; Empilha o endereço de retorno e pula para o início da função
    call bubble_sort
    jmp saida
    
; ========================================================================
; FUNÇÃO BUBBLE_SORT
; Implementa o algoritmo Bubble Sort para ordenação crescente
; 
; Funcionamento:
; - Loop externo: controla quantas passadas pelo array
; - Loop interno: compara elementos adjacentes em cada passada
; - Se array[i] > array[i+1], troca os elementos
; - A cada passada, o maior elemento vai para o final
; ========================================================================

; Configura o stack frame e salva registradores
bubble_sort:
    push rbp ; Salva o frame pointer anterior
    mov rbp, rsp ; Configura novo frame pointer

    ; Salva registradores que serão usados
    push rbx ; Será usado para índices e cálculos
    push rcx ; Armazenará array[i+1]
    push rdx ; Registrador reserva
    push r8  ; Controlará o loop externo
    push r9  ; Será o índice do loop interno
    
    mov r8, tam ; r8 = 6 (tamanho do array)
    dec r8 ; r8 = 5 (última posição válida)
 
; Controla quantas passadas pelo array são necessárias
; A cada passada, um elemento a menos precisa ser verificado
loop_externo:
    cmp r8, 0 ; Compara r8 com 0
    jle bubble_terminou ; Se r8 <= 0, ordenação completa
    
    mov r9, 0 ; r9 = 0 (reinicia índice interno)

; Percorre o array comparando elementos adjacentes
loop_interno:
    cmp r9, r8 ; Compara índice atual com limite
    jge proximo ; Se i >= limite, vai para próxima passada
    
    ; Carrega array[i] e array[i+1]
    mov rbx, r9 ; rbx = i
    mov rax, [array + rbx*8] ; rax = array[i]
    mov rcx, [array + rbx*8 + 8] ; rcx = array[i+1]
    
    ; Compara array[i] com array[i+1]
    cmp rax, rcx
    jle nao_troca ; Se array[i] <= array[i+1], não troca
    
    ; Troca array[i] e array[i+1]
    mov [array + rbx*8], rcx    ; array[i] = array[i+1]
    mov [array + rbx*8 + 8], rax ; array[i+1] = array[i]
    
; Incremento loop_interno
nao_troca:
    inc r9 ; i++ (próximo elemento)
    jmp loop_interno ; Volta para o início do loop interno
    
; Incremento loop_externo
proximo:
    dec r8 ; Diminui o limite (um elemento a menos para verificar) 
    ; o maior elemento já está na posição correta
    jmp loop_externo ; Volta para o início do loop externo

    
bubble_terminou:
   ; Restaura registradores na ordem inversa (LIFO)
    pop r9 ; Restaura r9
    pop r8 ; Restaura r8
    pop rdx; Restaura rdx
    pop rcx ; Restaura rcx
    pop rbx ; Restaura rbx
    pop rbp ; Restaura frame pointer anterior
    ret

saida:
    mov rax, 60     ; sys_exit
    mov rdi, 0      ; código de saída
    syscall
