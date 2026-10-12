# Interface

HUD, menus e telas do jogo. O visual de ícones, fontes e cores fica em `10-arte-audio.md`.

## Regras gerais
- Os ícones de botão mudam sozinhos conforme o último dispositivo usado: teclado e mouse, Xbox ou PlayStation (`04-player.md`).
- O inventário (Tab) e a pausa (Esc) pausam o jogo.

## HUD

```
+--------------------------------------+
| ♥♥♥♥♥  frasco 3        == Boiúna ==  |
|                                      |
|               Nate                   |
|                                      |
|                        [Q] [E] (Q+E) |
+--------------------------------------+
```

| Elemento | Onde | O que mostra |
|----------|------|--------------|
| Corações | alto, à esquerda | vida atual e máxima |
| Frasco | ao lado dos corações | cargas |
| Efeitos em Nate | ao lado dos corações | um ícone para cada efeito ativo |
| Magias | embaixo, à direita | os 2 elementos equipados, a recarga de cada um e o sinal de combinação pronta |
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
- Interagir abre um menu com "Descansar" e "Viajar". "Viajar" mostra a lista dos santuários já visitados (`02-core-loop.md`).

## Inventário
Uma tela só, em três partes:

```
+-------------+------------------------+
| Nate        | itens da categoria     |
| corpo a c.  |  [ ] [ ] [ ] [ ]       |
| distância   |  [ ] [ ]               |
| armadura    |                        |
| elemento 1  |                        |
| elemento 2  |                        |
+-------------+------------------------+
| detalhes e comparação com o equipado |
+--------------------------------------+
```

- **Esquerda:** Nate e os 5 espaços (`05-itens.md`). Escolher um espaço mostra, à direita, os itens daquela categoria.
- **Embaixo:** detalhes do item e comparação com o equipado, atributo por atributo, com seta verde (melhor) ou vermelha (pior).
- Com os 2 elementos escolhidos, a tela mostra a combinação que eles formam.
- A tela também mostra corações, cargas do frasco e o muiraquitã, com ou sem a lasca.

## Mapa
- Uma imagem de cada área com segredos (Mina, Bosque de Fungos e Ruínas), aberta pelo menu de pausa.
- Mostra os santuários e marca os cantos escuros e as paredes rachadas que Nate já viu e ainda não abriu: os lugares para onde vale voltar.
- As imagens precisam acompanhar as mudanças do mapa durante os testes (`12-tecnico.md`).

## Murais
- Ao interagir, a câmera se aproxima e o mural aparece grande na tela, sem texto.
- Depois disso, o mural fica numa galeria no menu de pausa, para ver de novo. A galeria mostra quantos dos 7 murais Nate já achou.

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
- Continuar, Mapa, Murais, Progresso, Opções e Voltar ao menu principal.
- O inventário abre com Tab.

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
- Sugestão para o `12-tecnico.md`: guardar os textos numa tabela desde o início, para facilitar uma tradução no futuro.

## Fim da partida
- Depois da cena final e dos créditos, aparece um resumo da partida: tempo de jogo, mortes e segredos achados.
- Em seguida, Nate volta ao mundo para o pós-jogo (`02-core-loop.md`).

## Assets e sons da interface
- **Ícones:** corações, frasco, os 4 elementos e as 6 combinações, as 13 peças de equipamento, os 4 efeitos de status, o aviso de imune e os botões de teclado e mouse, Xbox e PlayStation.
- **Imagens:** os mapas da Mina, do Bosque e das Ruínas.
- **Sons de menu:** navegar, confirmar, voltar e equipar.
- Visual de ícones, fontes e cores: `[A DEFINIR em 10-arte-audio]`.
