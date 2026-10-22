# DEVLOG — Panelas Malditas

## Aula 08 -- 07/10 (feita em 21/10)

O que fiz: a cozinha do zero, com 40 × 22 peças que cabem numa tela e arte provisória nossa (piso xadrez, parede, quatro portas, fogões, pias e bancadas), nas camadas chao e objetos, com colisão no TileSet. E o chef andando nas quatro direções.
O que travou: comecei atrasado, só no dia da Aula 09. Primeiro montei a vila do roteiro, e depois entendi que o jogo tem que ser nosso do zero: da aula se copia a técnica, não o mapa.
Como resolvi: apaguei o repositório e recomecei com a cozinha e arte própria em retângulos. Deixei a câmera de fora, porque a arena cabe inteira na tela.

## Aula 09 -- 21/10

O que fiz: as panelas (arte provisória) nascendo nas quatro portas e perseguindo o chef, a horda que aperta com o tempo, a vida com 1 segundo de invencibilidade, o placar de vida e tempo e as telas de vitória (aguentar 60 s) e de derrota.
O que travou: a fonte 48 da folha não cabia na tela de 640 × 352. E as panelas que entram pelas portas de cima e de baixo ficam presas atrás das bancadas, porque andam em linha reta até o chef.
Como resolvi: usei fonte 28 nas telas de fim e 16 no placar. As panelas presas ficam para a Aula 10, que ensina o inimigo a contornar obstáculos.

## Depois da Aula 09 -- 21/10 (ficha Defesa, adiantada)

O que fiz: o caldeirão no centro (Objeto, que conta 5 toques), as panelas indo atrás dele em vez do chef, o ataque com Espaço, o relógio em 3 minutos e um placar dos toques no caldeirão.
O que travou: como o caldeirão é uma Area2D, o chef passa por cima dele. E, como as panelas de cima e de baixo continuam presas nas bancadas, por enquanto o caldeirão só apanha pelos lados.
Como resolvi: deixei assim por enquanto. O caminho das panelas é a Aula 10.
