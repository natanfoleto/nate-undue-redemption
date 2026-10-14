# Interface

HUD, menus e telas do jogo. O visual de ícones, fontes e cores fica em `10-arte-audio.md`.

## Regras gerais
- Os ícones de botão mudam sozinhos conforme o último dispositivo usado: teclado e mouse, Xbox ou PlayStation (`04-player.md`).
- O inventário (Tab), a galeria dos murais (G) e a pausa (Esc) pausam o jogo.
- A interface acompanha o tamanho da janela, a 75% da escala da tela de base (1152 × 648 px): legível em tela grande, sem tomar a tela; o 3D continua desenhado com os pixels da janela (`11-balanceamento.md`).

## HUD

```
+----------------------------------------------+
| [====80/100====]          == Boiúna ==       |
| (efeitos)                                    |
|                     Nate                     |
|            [ícone] Lança marajoara           |
|                  Estilingue                  |
|        [1][2*][3 3][4][5]       [Q] [E] (Q+E)|
+----------------------------------------------+
```

| Elemento | Onde | O que mostra |
|----------|------|--------------|
| Barra de vida | alto, à esquerda | a vida atual e a máxima, em número em cima da barra; a barra cresce com a vida máxima (armadura e melhorias); a vida perdida fica clara um instante antes de sumir; com pouca vida, a barra fica laranja |
| Efeitos em Nate | embaixo da barra de vida | um ícone para cada efeito ativo |
| Barra fixa | embaixo, no centro | os 5 espaços (`05-itens.md`), com o número de cada um, o ícone do item, moldura verde-jade nas peças marajoara e cinza nas comuns; o espaço vazio fica apagado; o item da mão tem moldura dourada; a poção mostra as cargas. No controle, setas dos lados lembram o direcional. Some com o inventário aberto, que tem a barra dele |
| Nome do item da mão | em cima da barra fixa | ao trocar de espaço, o nome do item por 1,2 s, sumindo em 0,5 s |
| Magias | embaixo, à direita | os 2 elementos equipados, a recarga de cada um e o sinal de combinação pronta, que pulsa (cresce e clareia) quando ela fica pronta |
| Item achado | em cima da barra fixa | o ícone e o nome de cada item pego (arma, armadura, poção, melhoria ou elemento), por 3 s, sumindo em 0,6 s |
| Barra do chefe | no alto, ao centro | vida da Boiúna; na fase 1, dividida em 4 partes |
| Barra dos mobs | sobre a cabeça | vida, só depois de o mob levar dano |
| Efeitos nos mobs | sobre a cabeça | um ícone para cada efeito |
| Imune | sobre o chefe | a palavra "imune" quando um efeito não pega (`03-regras.md`) |

O centro da tela fica livre para os avisos dos golpes (pilar 2).

## Combate
- **Números de dano:** golpes normais não mostram número. O crítico mostra o dano, grande e de outra cor, junto com o efeito e o som próprios (`03-regras.md`).
- **Morte:** Nate cai, a tela escurece por cerca de 2 s e ele reaparece no último santuário, sem menu (`02-core-loop.md`).

## Dicas de controle
- Quando uma ação nova aparece, o ícone do botão surge perto de Nate (ex.: [F] Interagir) e some depois que ele usa a ação.
- O que cada trecho ensina: `04-player.md`.

## Santuário
- Interagir abre um menu com "Descansar", "Viajar" e "Voltar". "Viajar" mostra a lista dos santuários já visitados (`02-core-loop.md`); "Voltar" fecha o menu.

## Inventário
Parecido com o do Minecraft: uma caixa de tamanho fixo no centro da tela, por cima do jogo escurecido. Os detalhes de um item aparecem numa caixinha ao lado dele, e por isso a caixa nunca muda de tamanho:

```
+-------------------------- Inventário --------------------------+
| [Armadura]  +----------+  Vida: 80 / 100                        |
| [Elem. 1 ]  |   Nate   |  Poção de vida: 3 / 3                  |
| [Elem. 2 ]  | (boneco) |  (muiraquitã) Muiraquitã               |
|             +----------+  Combinação: Vapor                     |
| Mochila                         Elementos aprendidos            |
| [ ][ ][ ][ ][ ]                 [ ][ ]                          |
| [ ][ ][ ][ ][ ]                 [ ][ ]                          |
| [1][2][3][4][5]  (a barra fixa)                                 |
+-----------------------------------------------------------------+
      +--------------------------+
      | Nome (cor da raridade)   |  <- ao lado do item apontado
      | Comum ou Marajoara       |
      | atributo   valor   ▲     |
      +--------------------------+
```

- **Em cima, à esquerda:** a armadura vestida e os 2 elementos, numa coluna; vazios, mostram um ícone apagado do que vai ali.
- **No meio:** Nate, o boneco do jogo, com o item da mão, a armadura e o muiraquitã, virando um pouco para o lado do mouse.
- **À direita:** a vida, as cargas da poção, o muiraquitã (com ou sem a lasca; apagado até acordar) e a combinação que os 2 elementos formam.
- **Embaixo:** a mochila, 10 espaços; os elementos aprendidos; e a barra fixa, que entra no inventário (a do HUD some enquanto ele está aberto).
- **Detalhes:** numa caixinha de largura fixa ao lado do item apontado (o mouse em cima ou o foco), que vai para o lado esquerdo quando não cabe à direita: o nome, na cor da raridade (verde-jade na marajoara), a raridade e a comparação com o que Nate usa, atributo por atributo, com seta verde (melhor) ou vermelha (pior): a armadura, com a vestida; a arma, com a da mão, se for do mesmo tipo, ou com a primeira do mesmo tipo na barra. No espaço vazio da armadura e dos elementos, só o nome do espaço. Com o mouse, a caixinha some quando ele sai do item.
- **Trocar de lugar:** arrastar com o mouse; ou clicar no item e clicar no espaço de destino (no teclado e no controle, confirmar e confirmar de novo). Os números de 1 a 5 põem o item apontado naquele espaço da barra. Os itens trocam entre a barra, a mochila e a armadura (a barra só aceita itens de mão; o espaço da armadura, só armadura); um elemento aprendido vai para um dos 2 espaços, e soltar um elemento equipado na lista dos aprendidos tira ele do espaço.
- Voltar larga o item levado; sem item levado, fecha o inventário.

## Mapa
- Uma imagem de cada área com segredos (Mina, Bosque de Fungos e Ruínas), aberta pelo menu de pausa e pela tecla M, guardada para ele.
- Mostra os santuários e marca os cantos escuros e as paredes rachadas que Nate já viu e ainda não abriu: os lugares para onde vale voltar.
- As imagens são geradas do próprio mapa por uma câmera de cima, com os ícones desenhados por cima, e se atualizam a cada mudança no mapa (`12-tecnico.md`).

## Murais
- Ao interagir, a câmera se aproxima e o mural aparece grande na tela, sem texto.
- Depois disso, o mural fica na galeria dos murais, com botão próprio, fora da pausa: G no teclado; no controle, o direcional para cima. A galeria para o jogo e mostra as miniaturas dos murais já vistos, para ver de novo em tamanho grande, e quantos dos 7 Nate já achou; os que faltam ficam escuros. Voltar, G ou Esc fecham.
- A dica do botão dos murais aparece depois do primeiro mural visto.

## Progresso
Tela no menu de pausa que mostra, para cada área, quantos murais, melhorias, pergaminhos e equipamentos Nate já achou. Exemplo:

```
Bosque   murais 1/2   melhorias 1/2   pergaminhos 1/2   equipamento 2/4
```

Guia o pós-jogo (`02-core-loop.md`), mostrando onde ainda falta algo.

## Menus

### Menu principal
- Continuar (quando há jogo salvo), Novo jogo, Opções e Sair.
- Um jogo salvo só. "Novo jogo" pede confirmação antes de apagar o jogo salvo.

### Pausa
- Continuar, Mapa, Progresso, Configurações e Voltar ao menu principal. Os murais têm o botão próprio (ver Murais).
- **Configurações:** o volume da música (com o som de fundo) e o dos efeitos sonoros (golpes, tiros, passos e avisos), de 0 a 100, guardados nas opções. Os outros grupos das opções entram aqui depois.
- O inventário abre com Tab, e a galeria dos murais com G.

### Opções
| Grupo | Opções |
|-------|--------|
| Controles | trocar qualquer botão (`04-player.md`) |
| Áudio | volume da música e dos efeitos |
| Vídeo | resolução e tela cheia |
| Acessibilidade | tremor de tela liga e desliga; tamanho do texto |

Os avisos dos golpes não dependem só de cor, para ajudar daltônicos (regra para `10-arte-audio.md`).

### Idioma
- Só português do Brasil. O jogo tem pouco texto: não há falas, e os murais não têm texto.
- Os textos ficam numa tabela de tradução desde o início, para facilitar uma tradução no futuro (`12-tecnico.md`).

## Fim da partida
- Depois da cena final e dos créditos, aparece um resumo da partida: tempo de jogo, mortes e segredos achados.
- Em seguida, Nate volta ao mundo para o pós-jogo (`02-core-loop.md`).

## Assets e sons da interface
- **Ícones:** a poção de vida, os 4 elementos e as 6 combinações, as 6 peças de equipamento, os 4 efeitos de status, o aviso de imune e os botões de teclado e mouse, Xbox e PlayStation. A barra de vida é desenhada por código.
- **Imagens:** os mapas da Mina, do Bosque e das Ruínas.
- **Sons de menu:** navegar, confirmar, voltar e equipar.
- Ícones em pixel art de 16×16 pixels, feitos para o jogo; fonte pixel com licença livre (OFL) e com os acentos do português; cores em `10-arte-audio.md`.
