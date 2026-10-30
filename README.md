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
| Espaço | atacar as panelas perto do chef |
| Enter | jogar de novo, na tela de fim |

As panelas entram pelas portas e vão atrás do caldeirão. Cada panela que encosta nele é um toque, e no 5º toque você perde. Derrube as panelas com o Espaço antes que elas cheguem. Encostar no chef também tira 1 de vida, e sem vida você perde. Aguente 3 minutos e você vence.

![Captura de tela](docs/captura.png)

## Andamento

| Tag | O que o jogo tem |
| --- | --- |
| `aula-08` | a cozinha vista de cima (40 × 22 peças, cabe numa tela), com parede, portas, fogões, pias e bancadas com colisão, e o chef andando nas quatro direções |
| `aula-09` | panelas que nascem nas portas e perseguem o chef, horda que aperta com o tempo, vida com invencibilidade, placar e telas de vitória e derrota |
| depois da `aula-09` | ficha Defesa: o caldeirão que aguenta 5 toques, as panelas indo atrás dele, o ataque do chef e os 3 minutos |
| `aula-10` | navegação: as panelas acham o caminho pela cozinha (recalculado 5 vezes por segundo) e contornam as bancadas, então o caldeirão apanha pelas quatro portas; o ataque do chef com recarga, clarão e placar de abates |

## Créditos

- Arte provisória (piso, parede, portas, fogões, pias, bancadas, o chef, a panela e o caldeirão): feita para este projeto. Ela vai ser trocada pela arte do tema na Aula 11.
