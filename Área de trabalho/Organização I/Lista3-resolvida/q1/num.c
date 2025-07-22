#include <stdio.h>

void print_float(void *num, int bits);

int main() {
    float f;
    double d;
    
    printf("=== Impressão de Números Reais ===\n");
    printf("Digite um número float (32-bit): ");
    scanf("%f", &f);
    
    printf("Digite um número double (64-bit): ");
    scanf("%lf", &d);
    
    printf("\nResultados:\n");
    printf("Float (32-bit): ");
    print_float(&f, 32);
    
    printf("Double (64-bit): ");
    print_float(&d, 64);

    return 0;
}
