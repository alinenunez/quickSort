//CODIGO QUE O GEMINI FEZ E JA COLOCOU OS COMENTARIOS QUE VAO NOS AJUDAR EM ASSEMBLY. TIREI ESSES COMENTARIOS DO CODIGO QUE COLOQUEI NO OUTRO REPO


#include <stdio.h>
#include <stdlib.h> 

// 1. Definição da Estrutura (Mentalidade de 8 bytes)
typedef struct No {
    int valor;           // Primeiros 4 bytes
    struct No* proximo;  // Últimos 4 bytes (ponteiro)
} No;

// 2. Bloco de Alocação (Simulando a syscall do Heap)
No* aloca_no() {
    // No Assembly, isso será um bloco com a ecall (sbrk)
    return (No*)malloc(sizeof(No)); 
}

// 3. Bloco de Inserção (Exigirá o uso da Pilha/Stack no Assembly)
void insere_lista(No** cabeca_da_lista, int novo_valor) {
    // Ao chamar aloca_no(), o Assembly exigirá salvar o endereço de retorno (ra) na pilha
    No* novo_no = aloca_no(); 
    
    novo_no->valor = novo_valor;
    novo_no->proximo = *cabeca_da_lista;
    *cabeca_da_lista = novo_no; // O novo nó vira a cabeça
}

// 4. Bloco de Impressão (Validação)
void imprime_lista(No* atual) {
    while (atual != NULL) {
        printf("%d -> ", atual->valor);
        atual = atual->proximo; // Salta para o endereço do próximo nó
    }
    printf("Fim\n");
}

// 5. Bloco Principal
int main() {
    No* cabeca = NULL; // Lista inicia vazia (Zero)

    insere_lista(&cabeca, 10);
    insere_lista(&cabeca, 20);
    insere_lista(&cabeca, 30);

    imprime_lista(cabeca);

    return 0;
}