//reaproveitei esse código do material de EDII do semestre passado

#include <stdio.h> 

#define TAMANHO_MAXIMO 100

void trocarValores(int *valorA, int *valorB) { 
	int valorTemporario = *valorA;
	*valorA = *valorB;
	*valorB = valorTemporario;
}

int divide(int vetor[], int inicio, int fim) {
	int alvo = vetor[fim];
	int indiceMenor = inicio - 1;
	for (int indiceAtual = inicio; indiceAtual < fim; indiceAtual++) {
		if (vetor[indiceAtual] <= alvo) {
			indiceMenor++;
			trocarValores(&vetor[indiceMenor], &vetor[indiceAtual]);
		}
	}
	trocarValores(&vetor[indiceMenor + 1], &vetor[fim]);
	return indiceMenor + 1;
}

void quicksort(int vetor[], int inicio, int fim) {
	if (inicio < fim) {
		int indiceAlvo = divide(vetor, inicio, fim);
		quicksort(vetor, inicio, indiceAlvo - 1);
		quicksort(vetor, indiceAlvo + 1, fim);
	}
}

void imprimirVetor(int vetor[], int quantidade) {
	for (int indice = 0; indice < quantidade; indice++) {
		printf("%d ", vetor[indice]);
	}
	printf("\n");
}

int main(void) {
	int vetor[TAMANHO_MAXIMO];
	int quantidade;
	printf("Digite a quantidade de elementos (1 a %d): ", TAMANHO_MAXIMO);
	scanf("%d", &quantidade);
	if (quantidade < 1 || quantidade > TAMANHO_MAXIMO) {
		printf("Quantidade invalida.\n");
		return 1;
	}
	for (int indice = 0; indice < quantidade; indice++) {
		printf("Digite o elemento %d: ", indice + 1);
		scanf("%d", &vetor[indice]);
	}
	quicksort(vetor, 0, quantidade - 1);
	printf("Vetor ordenado: ");
	imprimirVetor(vetor, quantidade);
	return 0;
}
