# Panelas Malditas

Jogo de horda feito na Godot 4.7 para o projeto do 2º bimestre de Jogos Digitais II (UNIGRAN, 2026/2, Prof. Ezéfferth C. A. Fernandes).

Matheus Nunes De Paula

## A carta

| Parte da carta | O que saiu |
| --- | --- |
| Tema | Cozinha de restaurante com panelas rebeldes |
| Tipo de jogo | **Defesa**: proteger por 3 minutos um objeto fixo, que aguenta 5 toques de inimigo |
| Modo | **Horda** (arena vista de cima, movimento nas quatro direções) |

**A ideia:** você é o chef, e as panelas da cozinha se rebelaram. Elas entram pelas quatro portas atrás do caldeirão de sopa, que fica no centro da cozinha. Se o caldeirão levar 5 pancadas, a sopa está perdida. Aguente 3 minutos e o serviço está salvo.

## Como jogar

| Tecla | Ação |
| --- | --- |
| Setas ou W A S D | andar |
| 1, 2, 3 ou o mouse | escolher a melhoria ao subir de nível |
| Enter | jogar de novo, na tela de fim |

As panelas entram pelas quatro portas ou pulam dos fogões e das pias (que piscam em vermelho 1 s antes) e vão atrás do caldeirão. Há quatro tipos:

| Panela | O que faz |
| --- | --- |
| comum | vai atrás do caldeirão |
| frigideira | mais rápida |
| panela de pressão | mais lenta, aguenta 3 golpes |
| panela brava | vermelha, vai atrás do chef e não do caldeirão |
| chaleira | para longe do caldeirão e cospe vapor nele; o vapor tira um toque, a não ser que o chef entre na frente |

Cada panela que encosta no caldeirão é um toque, e no 5º toque você perde. O chef ataca sozinho: a faca dá uma volta em torno dele a cada 0,4 s e derruba as panelas que estiverem perto. Vá até elas antes que cheguem ao caldeirão. Encostar no chef também tira 1 de vida, e sem vida você perde. Aguente 3 minutos e você vence.

O chef não consegue subir no caldeirão, só ficar do lado dele. Cada panela derrubada dá XP (a de pressão e a chaleira valem 3, a brava 2 e as outras 1). Com XP suficiente o chef sobe de nível, o jogo pausa e você escolhe uma de três melhorias sorteadas:

| Melhoria | O que faz |
| --- | --- |
| Faca maior | alcance +4 (até 40) |
| Golpe mais rápido | recarga 15% menor (até 0,3 s) |
| Faca afiada | dano +1 |
| Botas de cozinha | chef 15% mais rápido |
| Avental reforçado | vida +1 |
| Tampa no caldeirão | o caldeirão aguenta +1 toque |

O primeiro nível pede 5 XP, e cada nível seguinte pede 5 a mais (10, 15, 20...).

Os 3 minutos têm três fases:

| Fase | Tempo | O que muda |
| --- | --- | --- |
| 1 | 0 a 1 min | só panelas comuns, entrando pelas portas |
| 2 | 1 a 2 min | os fogões e as pias começam a soltar panelas, e entram a frigideira e a chaleira |
| 3 | 2 a 3 min | chegam também a panela de pressão e a brava, e as panelas vêm mais duras (a comum aguenta 2 golpes e a de pressão 5) |

![Captura de tela](docs/captura.png)

## Andamento

| Tag | O que o jogo tem |
| --- | --- |
| `aula-08` | a cozinha vista de cima (40 × 22 peças, cabe numa tela), com parede, portas, fogões, pias e bancadas com colisão, e o chef andando nas quatro direções |
| `aula-09` | panelas que nascem nas portas e perseguem o chef, horda que aperta com o tempo, vida com invencibilidade, placar e telas de vitória e derrota |
| depois da `aula-09` | ficha Defesa: o caldeirão que aguenta 5 toques, as panelas indo atrás dele, o ataque do chef e os 3 minutos |
| `aula-10` | navegação: as panelas acham o caminho pela cozinha (recalculado 5 vezes por segundo) e contornam as bancadas, então o caldeirão apanha pelas quatro portas; o ataque do chef com recarga e placar de abates, com uma faca que dá uma volta em torno dele |
| depois da `aula-10` | panelas pulando também dos fogões e das pias, com aviso piscando antes, quatro tipos de panela, três fases nos 3 minutos, ataque automático, XP com melhorias, a chaleira, o caldeirão sólido e a arte nova com efeitos |
| depois da `aula-10` | sons e música de fundo |

## Créditos

- Arte (piso, paredes, portas, fogões, pias, bancadas, tapete, o chef, a faca, as panelas, a chaleira, o caldeirão e os efeitos): pixel art feita para este projeto.
- Sons e música (no estilo 8 bits): sintetizados para este projeto.
