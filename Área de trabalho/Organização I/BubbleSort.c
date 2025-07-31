// Código base

#include<stdio.h>
#include<stdlib.h>

int main(){
    
    int vetor[] = {5, 2, 8, 1, 9, 3};
    int tam = 6;
    
    int aux;

    for(int i = 0; i < tam; i++) { //contador externo
        for(int j = 0; j < tam - 1; j++) { //contador interno
            if(vetor[j] > vetor[j+1]) { //ao inverter a seta muda a ordem de ordenação
            aux = vetor[j];
            vetor[j] = vetor[j+1];
            vetor[j+1] = aux;
            }
        }
        
    }
    return 0;
    
} 