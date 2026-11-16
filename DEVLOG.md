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

## Aula 10 -- 28/10

O que fiz: a navegação das panelas. Uma NavigationRegion2D cobre a cozinha e monta a malha de caminho a partir das colisões da camada objetos, com 6 px de folga em volta da parede, das bancadas, dos fogões e das pias. Cada panela ganhou um NavigationAgent2D e anda até o próximo ponto do caminho em vez de ir em linha reta. Agora as panelas de cima e de baixo contornam a bancada do meio e o caldeirão apanha pelas quatro portas.
O que travou: a NavigationRegion2D só lê as colisões dos próprios filhos, e as camadas da cozinha são irmãs dela, então a malha saía sem os obstáculos.
Como resolvi: coloquei a camada objetos no grupo navegacao e mandei a região ler só esse grupo. Se o mapa mudar, é só selecionar a Navegacao e clicar em Bake NavigationPolygon de novo.

## Aula 10 -- 28/10 (Parte 2 e ajustes, feitos em 29/10)

O que fiz: deixei a navegação igual à da folha, com as camadas chao e objetos dentro da Navegacao e a folga (Agent Radius) de volta em 10, e fiz o Bake de novo. Terminei o ataque da Parte 2: o chef só bate de 0,4 em 0,4 s, um clarão branco mostra o golpe e o placar conta as panelas derrubadas. De extra, a rota mais barata: um Timer de 0,2 s faz a panela recalcular o caminho 5 vezes por segundo em vez de 60.
O que travou: na primeira versão eu tinha baixado a folga para 6, e a folha avisa que assim a panela raspa nas quinas e engancha. E sem a trava do ataque, martelar o Espaço limpava a cozinha.
Como resolvi: com as camadas dentro da Navegacao o truque do grupo não foi mais preciso, e com a folga em 10 as panelas das quatro portas continuam chegando ao caldeirão. A trava é o pode_atacar, no mesmo jeito do invencivel do dano. No tipo Defesa os abates só aparecem no placar: quem dá a vitória continua sendo o relógio.

Depois: troquei o clarão branco por uma faca de cozinha (arte provisória, 24 × 10 px) que dá uma volta inteira em torno do chef em 0,2 s quando ele ataca. O raio do golpe subiu de 8 para 24, porque com 8 o chef só acertava a panela já encostada e o clarão ficava escondido atrás dele. A ponta da faca chega a 28 px, quase o mesmo alcance do golpe.

## Melhorias depois da Aula 10 -- 16/11

O professor trocou a Aula 11 por melhorar o jogo a partir da Aula 10.

O que fiz: as panelas não entram mais só pelas quatro portas. Agora elas também pulam dos dois fogões e das duas pias dos cantos, e são 8 lugares sorteados. Antes de soltar a panela, o fogão ou a pia pisca em vermelho por 1 s, para dar tempo de o chef chegar lá.
O que travou: com só quatro portas, todas no meio das paredes, as panelas faziam sempre os mesmos quatro caminhos até o caldeirão, e o jogo ficava previsível.
Como resolvi: mais quatro Marker2D nos Nascedouros, cada um com um ColorRect Aviso por cima do aparelho. Na horda, se o nascedouro sorteado tem Aviso, a cozinha pisca uma cópia dele com um Tween e só depois solta a panela. A cópia é para duas panelas seguidas do mesmo fogão não apagarem o aviso uma da outra.
Depois: o placar ficava por cima do fogão de cima e escondia o aviso dele. Passei o placar para uma linha só, em cima da parede de cima, com fonte 12: vida e abates à esquerda, tempo no meio e caldeirão à direita.

Ainda em 16/11: tipos de panela. Além da panela comum, agora saem a frigideira (rápida, velocidade 60), a panela de pressão (lenta, aguenta 3 golpes e fica meio transparente quando apanha) e a panela brava (vermelha, vai atrás do chef em vez do caldeirão). Cada tipo é uma cena herdada da inimigo.tscn, que só troca a arte e os números; a cozinha sorteia o tipo de cada panela (60% comum, 20% frigideira, 10% pressão, 10% brava).
O que travou: a panela brava cruzava o caldeirão no caminho até o chef, o caldeirão contava um toque e apagava a panela.
Como resolvi: o caldeirão agora só conta as panelas que estão atrás dele (grupo_alvo "objeto"); a brava passa por cima.
