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

**Jogue no navegador:** https://matheusndp.github.io/panelas-malditas/

## Como jogar

| Tecla | Ação |
| --- | --- |
| Setas ou W A S D | andar |
| 1, 2, 3 ou o mouse | escolher o cartão ao subir de nível |
| Enter | começar, na tela de início |
| Esc | pausar o jogo e abrir o livro de receitas (e continuar) |
| setas ou A / D | no livro de receitas, virar a página |
| M | na pausa, voltar para a tela de início |
| mouse | na tela de fim, "Continuar Jogando" / "Jogar de Novo" e "Menu Inicial" |

### O objetivo (Defesa)

As panelas entram pelas quatro portas ou pulam dos fogões e das pias (que piscam em vermelho 1 s antes) e vão atrás do caldeirão. Cada panela que encosta no caldeirão é um toque, e no 5º toque você perde. Encostar no chef tira 1 de vida, e sem vida você também perde. **Aguente 3 minutos e você vence.**

Depois da vitória dá para seguir na **hora extra**: "Continuar Jogando" mantém o mesmo chef, as mesmas armas e o mesmo nível, a horda segue no ritmo do fim da fase 3 e o placar conta "Hora extra: m:ss" até o chef cair ou o caldeirão ser derrubado.

### As panelas

| Panela | O que faz |
| --- | --- |
| comum | vai atrás do caldeirão |
| frigideira | mais rápida |
| panela de pressão | mais lenta e aguenta mais golpes |
| panela brava | vermelha, vai atrás do chef e não do caldeirão |
| chaleira | para a 80 px do caldeirão e cospe vapor nele a cada 3 s; o vapor tira um toque, a não ser que o chef entre na frente |
| Panelão | a panela gigante: chega aos 2:15 pela porta da esquerda, é lenta, aguenta 50 golpes, vale 25 XP e, se chegar ao caldeirão, fica batendo nele a cada 1,5 s até ser derrubada |

A cada fase as panelas vêm mais duras: +1 de vida na fase 2 e +2 na fase 3.

### A máquina de estados das panelas

O comportamento de cada panela é uma máquina de estados (`enum Estado` no [inimigo.gd](scripts/inimigo.gd)). A cada quadro, `proximo_estado()` decide a troca e o `match` faz o que o estado atual manda:

| Estado | O que a panela faz | Sai dele quando |
| --- | --- | --- |
| SURGINDO | acabou de nascer, cresce com o "pop" e não anda | passam 0,25 s → PERSEGUINDO |
| PERSEGUINDO | segue o caminho do NavigationAgent2D (recalculado 5 vezes por segundo) e contorna as bancadas | um rato morde ou o Gongo deixa tonta → TRAVADA |
| TRAVADA | fica parada no lugar | a mordida e a tontura acabam → PERSEGUINDO |
| ATACANDO | parada, atacando o caldeirão | depende da panela (abaixo) |

A chaleira e o Panelão herdam do inimigo.gd e só acrescentam as transições deles:

- **Chaleira:** PERSEGUINDO → ATACANDO quando chega a 80 px do caldeirão (liga o Timer do vapor); volta a PERSEGUINDO se for empurrada para longe, e a TRAVADA se for mordida.
- **Panelão:** PERSEGUINDO → ATACANDO quando encosta no caldeirão (liga o Timer das pancadas), e desse estado ele não sai mais; é pesado demais para ficar TRAVADA.

### XP, níveis e cartões

O chef ataca sozinho: a faca dá uma volta em torno dele a cada 0,4 s. Cada panela derrubada solta bolinhas de XP (a de pressão e a chaleira soltam 3, a brava 2, o Panelão 25 e as outras 1). Quando o chef passa perto (48 px), as bolinhas voam até ele. Na fase 1 as bolinhas são verdes e valem 1; na fase 2, azuis e valem 1,5; na fase 3, vermelhas e valem 2.

O primeiro nível pede 5 XP, e cada nível seguinte pede 5 a mais. Ao subir de nível o jogo pausa e mostra três cartões sorteados, sem repetir: temperos (melhorias), armas novas (cartão "NOVA") ou o próximo nível de uma arma que o chef já tem ("Nv 2", "Nv 3").

| Tempero | O que faz |
| --- | --- |
| Faca maior | alcance +5 (24 → 39, 3 cartões; o terceiro vira o Cutelo do Chef) |
| Golpe rápido | recarga 15% menor (até 0,3 s) |
| Faca afiada | dano +1 |
| Botas | chef 15% mais rápido |
| Vida +1 | vida +1 |
| Caldeirão +1 | o caldeirão aguenta +1 toque |

O chef pode ter até 4 armas além da faca. Cada arma tem 3 níveis e, no nível 3, **evolui** sozinha (o cartão avisa "evolui: ..." em dourado):

| Arma | Como funciona | Evolução no nível 3 |
| --- | --- | --- |
| Faca (a do começo) | gira em volta do chef e acerta quem estiver perto | **Cutelo do Chef**: duas lâminas douradas e mais dano |
| Panelaço | o chef bate uma tampa e solta uma onda que acerta e empurra as panelas | **Gongo**: onda gigante que deixa as panelas tontas por 1 s |
| Talheres | arremessa facas e garfos nas panelas mais perto; atravessam panelas e param na parede | **Faqueiro**: talheres para todos os lados |
| Colher suspeita | colheres que giram longe do chef, por fora da faca e no sentido contrário | **Batucada**: cada pancada empurra as panelas em volta |
| Pote de mel | poça de mel que gruda, machuca e deixa quem pisa mais lento | **Rastro de Mel**: o chef pinga mel por onde anda |
| Ratatui | ratinhos que correm até as panelas, mordem e seguram no lugar (1, 2 e 3 ratos) | **Ninhada**: 4 ratos que mordem mais rápido |

### Power-ups

A cada 12 s aparece um power-up num lugar sorteado do chão (no máximo 3 ao mesmo tempo), e as panelas também soltam power-ups quando quebram (o Panelão sempre solta dois). O power-up pisca nos últimos 3 s e some depois de 15 s:

| Power-up | Efeito |
| --- | --- |
| Ímã | puxa todas as bolinhas de XP da cozinha até o chef |
| Pimenta | chef 60% mais rápido por 8 s |
| Coxinha | vida +1 (só aparece quando o chef está machucado) |
| Gelo | congela todas as panelas por 4 s |
| Tampa | o caldeirão não leva toque por 6 s |

### As fases

| Fase | Tempo | O que muda |
| --- | --- | --- |
| 1 | 0 a 1 min | só panelas comuns, entrando pelas portas |
| 2 | 1 a 2 min | os fogões e as pias começam a soltar panelas, e entram a frigideira e a chaleira |
| 3 | 2 a 3 min | chegam também a panela de pressão e a brava; aos 2:15 entra o Panelão |

O livro de receitas (Esc) explica cada arma, tempero, power-up, panela e evolução com o desenho ao lado.

![Captura de tela](docs/captura.png)

## Andamento

O professor deu as aulas até a Aula 10; as Aulas 11 e 12 não aconteceram, e o tempo delas foi usado para melhorar o jogo a partir da Aula 10. Por isso há tags só até a `aula-10`.

| Tag | O que o jogo tem |
| --- | --- |
| `aula-08` | a cozinha vista de cima (40 × 22 peças, cabe numa tela), com parede, portas, fogões, pias e bancadas com colisão, e o chef andando nas quatro direções |
| `aula-09` | panelas que nascem nas portas e perseguem o chef, horda que aperta com o tempo, vida com invencibilidade, placar e telas de vitória e derrota |
| depois da `aula-09` | ficha Defesa: o caldeirão que aguenta 5 toques, as panelas indo atrás dele, o ataque do chef e os 3 minutos |
| `aula-10` | navegação: as panelas acham o caminho pela cozinha e contornam as bancadas; o ataque do chef com recarga e placar de abates |
| depois da `aula-10` | panelas pulando dos fogões e das pias, quatro tipos de panela, a chaleira, três fases, ataque automático, XP com melhorias e a arte nova com efeitos |
| depois da `aula-10` | sons e música, tela de início, tela de fim com resumo e recorde, o Panelão com barra de vida, pausa com o livro de receitas |
| depois da `aula-10` | armas novas com níveis, power-ups, cartões de nível sem repetição, o Ratatui e as evoluções das armas |
| depois da `aula-10` | XP por fase, hitbox das panelas do tamanho do desenho, hora extra depois da vitória |
| depois da `aula-10` | a máquina de estados das panelas (SURGINDO, PERSEGUINDO, TRAVADA, ATACANDO) |
| depois da `aula-10` | o jogo exportado para a Web e publicado no GitHub Pages por um workflow do GitHub Actions |

## Créditos

- Arte (piso, paredes, portas, fogões, pias, bancadas, tapete, o chef, as armas, as panelas, a chaleira, o caldeirão, os ícones, os power-ups e os efeitos): pixel art feita a partir de imagens de referência encontradas no Pinterest, alteradas com ajuda de IA e ajustadas para a paleta e o tamanho do jogo. Os autores e as licenças das imagens originais não foram identificados.
- Sons e música (no estilo 8 bits): sintetizados para este projeto.

## Uso de IA

O jogo foi feito com a ajuda do Claude Code (assistente de IA da Anthropic), como a seção 6 da folha do projeto permite. A IA ajudou a escrever o código dos scripts, o workflow de publicação no GitHub Pages ([.github/workflows/pages.yml](.github/workflows/pages.yml)) e a alterar as imagens de referência da arte. Cada script diz, na primeira linha (`# Origem:`), de onde veio a técnica: do roteiro da aula (Prof. Ezéfferth) e/ou do auxílio de IA. As decisões do jogo (a cozinha, as panelas, as armas, o equilíbrio e o que mudar a cada teste) estão registradas no [DEVLOG.md](DEVLOG.md).
