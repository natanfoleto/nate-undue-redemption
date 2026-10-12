# Visão geral

## Conceito
Jogo de ação e exploração em 3D com câmera fixa, num mundo subterrâneo perdido: itens, combate, mobs e chefe. Projeto piloto de escopo pequeno, focado em aprender os sistemas do gênero.

## Decisões
- **Nome:** Nate: Undue Redemption
- **História e pilares:** ver `01-historia.md`.
- **Core loop:** ver `02-core-loop.md`.
- **Regras:** ver `03-regras.md`.
- **Player:** ver `04-player.md`.
- **Itens:** ver `05-itens.md`.
- **Mobs:** ver `06-mobs/`.
- **Chefe:** ver `07-chefes/boiuna.md`.
- **Mapa:** ver `08-mapa.md`.
- **Interface:** ver `09-interface.md`.
- **Arte e áudio:** ver `10-arte-audio.md`.
- **Balanceamento:** ver `11-balanceamento.md`.
- **Referência principal:** Minecraft Dungeons.
- **Perspectiva:** 3D com câmera fixa isométrica, jogado como 2D (chão plano, sem pulo nem verticalidade).
- **Estilo visual:** blocado/voxel, na linha de Minecraft Dungeons.
- **Estrutura do mapa:** mapa único e contínuo, sem andares, com áreas que se abrem conforme o jogador avança. Caminho principal linear, com volta opcional a áreas já visitadas.
- **Jogadores:** só solo.
- **Dificuldade:** acessível, com morte sem perda; desafio extra sempre opcional, em arenas escondidas no mapa.
- **Estilo de jogo:** definido pelo equipamento e pelo par de elementos equipado, sem classes.
- **Pipeline de assets:** modelos e animações blocados definidos por código sempre que possível.
- **Engine:** Godot 4 (recomendada) `[A DEFINIR]`

## Escopo inicial
- 1 mapa subterrâneo único (Agartha), desenhado à mão: prólogo na borda da mina, 3 áreas e a arena do chefe (`08-mapa.md`)
- 30 min de caminho principal; 45 min com todos os segredos
- 1 herói com ataque corpo a corpo, ataque à distância e esquiva
- 1 amuleto, o muiraquitã (Luz Ancestral e o Selo), e 4 elementos aprendidos em pergaminhos: 4 magias e 6 combinações
- 4 tipos de mob (Lobo, Esqueleto Guerreiro, Necromante e Golem de Pedra), com uma variante de cada, e 1 dinossauro de cenário
- 1 chefe com 2 fases: a Boiúna, o predador
- 13 peças de equipamento (5 armas corpo a corpo, 4 à distância e 4 armaduras), 6 melhorias escondidas e o frasco de cura; inventário simples
- 4 santuários, 7 murais e 3 tipos de armadilha
- 5 arenas (1 na Mina, 2 no Bosque e 2 nas Ruínas) e 3 arenas opcionais, uma por área
- 7 cenas curtas, feitas no motor: abertura, uma memória por santuário, troca de fase da Boiúna e final
- 7 faixas de música e cerca de 100 efeitos sonoros

## Roteiro de documentação
- [x] **01 Pilares e história** (`01-historia.md`)
- [x] **02 Core loop** (`02-core-loop.md`): o que o jogador faz minuto a minuto, estrutura da partida, morte, progressão, vitória.
- [x] **03 Regras** (`03-regras.md`): lista de atributos, fórmula de dano, hitbox, recuo, invencibilidade após dano, efeitos de status.
- [x] **04 Player** (`04-player.md`): movimento, ataques, esquiva, atributos base, controles.
- [x] **05 Itens** (`05-itens.md`): categorias, raridades, slots, consumíveis, muiraquitã e magias, tabelas de loot.
- [x] **06 Mobs** (`06-mobs/`): uma ficha por mob.
- [x] **07 Chefes** (`07-chefes/`): fases, padrões de ataque, avisos visuais.
- [x] **08 Mapa** (`08-mapa.md`): regiões, conexões, atalhos, santuários, armadilhas, dificuldade por região.
- [x] **09 Interface** (`09-interface.md`): HUD, inventário, menus, telas de morte e vitória.
- [x] **10 Arte e áudio** (`10-arte-audio.md`): guia de estilo, lista consolidada de assets e sons.
- [x] **11 Balanceamento** (`11-balanceamento.md`): tabela com todos os números.
- [ ] **12 Técnico** (`12-tecnico.md`): arquitetura no Godot, estrutura de pastas, convenções de código.
