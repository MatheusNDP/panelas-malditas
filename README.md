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
| Enter | jogar de novo, na tela de fim |

Por enquanto (Aula 09): as panelas entram pelas portas e vêm atrás do chef. Cada toque tira 1 de vida; sem vida, você perde. Aguente 60 segundos e você vence. O caldeirão e os 3 minutos da Defesa entram na próxima etapa.

![Captura de tela](docs/captura.png)

## Andamento

| Tag | O que o jogo tem |
| --- | --- |
| `aula-08` | a cozinha vista de cima (40 × 22 peças, cabe numa tela), com parede, portas, fogões, pias e bancadas com colisão, e o chef andando nas quatro direções |
| `aula-09` | panelas que nascem nas portas e perseguem o chef, horda que aperta com o tempo, vida com invencibilidade, placar e telas de vitória e derrota |

## Créditos

- Arte provisória (piso, parede, portas, fogões, pias, bancadas, o chef e a panela): feita para este projeto, com auxílio de IA. Ela vai ser trocada pela arte do tema na Aula 11.

## Uso de IA

Feito com a ajuda do Claude Code (assistente de IA da Anthropic), como a seção 6 do projeto permite. Cada script diz, na primeira linha, de onde veio o código (técnica do roteiro da aula ou IA).
