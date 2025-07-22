#!/bin/bash

echo "Medindo tempo médio de execução..."
echo ""

# Lista dos programas que vamos testar
for program in fpu sse poli-fpu poli-sse
do
    echo "Executando $program 100 vezes..."

    total_time=0

    for i in {1..100}
    do
        # Mede o tempo de execução em milissegundos
        start=$(date +%s%3N)

        echo -e "1\n2\n3\n4\n5\n6\n1" | ./$program > /dev/null

        end=$(date +%s%3N)
        elapsed=$((end - start))
        total_time=$((total_time + elapsed))
    done

    # Calcula a média
    average=$(echo "scale=3; $total_time / 100" | bc)

    echo "Tempo médio para $program: $average ms"
    echo ""
done

