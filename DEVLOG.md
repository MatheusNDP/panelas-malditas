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

Ainda em 16/11: fases. Os 3 minutos agora têm três fases de 1 minuto. Na fase 1 só entram panelas comuns, e só pelas portas. Na fase 2 os fogões e as pias começam a soltar panelas, e entram as frigideiras. Na fase 3 chegam também a panela de pressão e a brava. O placar mostra a fase, e na troca aparece um aviso amarelo por 2,5 s.
O que travou: com tudo liberado desde o começo, o jogo já começava no máximo e não tinha para onde crescer.
Como resolvi: uma função fase() calcula a fase pelo tempo que já passou no Relogio, e tanto o sorteio do nascedouro quanto o do tipo de panela consultam essa fase.

Ainda em 16/11: experiência e melhorias. Joguei e ficou difícil demais: o chef não derrubava panelas rápido o bastante. Agora o ataque é automático, com a faca girando sozinha a cada 0,4 s, e cada panela derrubada dá XP (pressão 3, brava 2, as outras 1). Ao subir de nível o jogo pausa e mostra três melhorias sorteadas entre seis: faca maior, golpe mais rápido, faca afiada, botas, avental (vida) e tampa no caldeirão. A escolha é com 1, 2, 3 ou com o mouse. Também deixei a horda acelerar mais devagar: em vez de chegar a uma panela a cada 0,5 s por volta dos 30 s, ela vai de 2 s até 0,5 s ao longo de 2 minutos e só chega ao máximo na fase 3.
O que travou: a melhoria da faca maior muda o raio do CircleShape2D, e esse recurso é compartilhado pela cena salva, então o raio maior continuava na partida seguinte. E a tela de melhoria precisa funcionar com o jogo pausado.
Como resolvi: o chef faz uma cópia do círculo no _ready e só mexe na cópia. A tela de melhoria é um CanvasLayer com process_mode "When Paused", então só ela roda enquanto o jogo está pausado; a recarga da faca usa um timer que também pausa.

Ainda em 16/11: equilíbrio e arte nova. Jogando, o chef ficava forte demais com as melhorias: parado em cima do caldeirão, nada passava.
O que fiz: as melhorias ficaram menores (faca +4 até 40, recarga até 0,3 s) e cada nível pede 5 XP a mais. O caldeirão ganhou um corpo sólido numa camada só dele (camada 4), que só o chef enxerga: o chef não sobe mais nele, e as panelas continuam encostando. Na fase 3 a panela comum aguenta 2 golpes e a de pressão 5. E entrou a chaleira, nas fases 2 e 3: ela para a 80 px do caldeirão, apita (fica clara e treme) e cospe vapor nele a cada 3 s. O vapor tira um toque, a não ser que o chef entre na frente. A chaleira é uma cena herdada da panela com um script que estende o inimigo.gd.
Arte: troquei toda a arte por pixel art nova com a mesma paleta. O TileSet agora tem pontas de bancada, fogão e pia, paredes diferentes em cima, embaixo e nos lados, portas duplas e ladrilhos com manchas. Também entraram o tapete embaixo do caldeirão, sombras embaixo de todo mundo, vapor subindo do caldeirão, panelas que surgem com um "pop" e andam dando pulinhos, clarão branco ao apanhar, cacos quando quebram, fumaça quando nascem, um rastro em volta da faca, a tela tremendo quando o caldeirão ou o chef apanham, uma luz mais quente (CanvasModulate) e cantos da tela mais escuros.
O que travou: a cor dos cacos gravada na cena com 3 números (Color(r, g, b)) fazia a cena não abrir; no arquivo .tscn a cor precisa dos 4 (com o alfa).
Como resolvi: acrescentei o alfa nas cores. As colisões das peças novas continuam quadradas de 16 px, então o mapa de navegação não mudou.

Ainda em 16/11: som. O jogo era todo em silêncio.
O que fiz: efeitos sonoros no estilo 8 bits para a faca acertando, a panela quebrando, o golpe que não quebra, o caldeirão apanhando, o chef se machucando, o apito da chaleira, o vapor batendo no chef, subir de nível, a troca de fase, a vitória e a derrota, e uma música de fundo de 16 compassos em Lá menor que toca em loop. Tudo fica na pasta sons/.
Como fiz: um Autoload chamado Som (scripts/som.gd), que existe o jogo todo e sobrevive à troca de cena. Qualquer script chama Som.tocar("quebra"). Ele tem 8 AudioStreamPlayer para tocar vários sons ao mesmo tempo, muda um pouco o tom a cada vez para não ficar repetitivo e ignora o mesmo som repetido no mesmo instante (várias panelas quebrando juntas). O Som roda com process_mode Always, para o som de subir de nível tocar com o jogo pausado. A música para nas telas de fim, que tocam a própria musiquinha.
O que travou: a música precisava tocar em loop sem configurar nada na importação.
Como resolvi: o arquivo musica.wav tem um bloco "smpl" com o laço, e a Godot já importa a música em loop.
Depois: fechando a janela com a música tocando, a Godot avisava que a musica.wav tinha ficado presa na memória ("leaked at exit"). Agora o Som desliga o auto_accept_quit, para todos os sons quando a janela pede para fechar e só chama get_tree().quit() 0,1 s depois.
