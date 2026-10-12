# Visão geral

## Conceito
Jogo de ação e exploração em 3D com câmera fixa, num mundo subterrâneo perdido: itens, combate, mobs e chefe. Projeto piloto de escopo pequeno, focado em aprender os sistemas do gênero.

## Decisões
- **Nome:** Nate: Undue Redemption
- **História e pilares:** ver `01-historia.md`.
- **Referência principal:** Minecraft Dungeons.
- **Perspectiva:** 3D com câmera fixa isométrica, jogado como 2D (chão plano, sem pulo nem verticalidade).
- **Estilo visual:** blocado/voxel, na linha de Minecraft Dungeons.
- **Estrutura do mapa:** mapa único e contínuo, sem andares, com áreas que se abrem conforme o jogador avança.
- **Jogadores:** só solo.
- **Dificuldade:** acessível; desafio extra sempre opcional.
- **Estilo de jogo:** definido pelo equipamento, sem classes.
- **Pipeline de assets:** modelos e animações blocados definidos por código sempre que possível.
- **Engine:** Godot 4 (recomendada) `[A DEFINIR]`

## Escopo inicial proposto `[A DEFINIR no core loop]`
- 1 mapa subterrâneo único (Agartha), desenhado à mão, com 3 áreas e a arena do chefe `[A DEFINIR em 08-mapa]`
- 1 herói com ataque corpo a corpo, ataque à distância e esquiva
- 3 relíquias (habilidades ativas que também abrem caminhos)
- 3 a 4 tipos de mob
- 1 chefe com 2 fases
- 10 a 15 itens, inventário simples e equipamento
- 15 a 30 minutos de jogo

## Roteiro de documentação
- [x] **01 Pilares e história** (`01-historia.md`)
- [ ] **02 Core loop** (`02-core-loop.md`): o que o jogador faz minuto a minuto, estrutura da partida, morte, progressão, vitória.
- [ ] **03 Regras** (`03-regras.md`): lista de atributos, fórmula de dano, hitbox, recuo, invencibilidade após dano, efeitos de status.
- [ ] **04 Player** (`04-player.md`): movimento, ataques, esquiva, atributos base, controles.
- [ ] **05 Itens** (`05-itens.md`): categorias, raridades, slots, consumíveis, relíquias, tabelas de loot.
- [ ] **06 Mobs** (`06-mobs/`): uma ficha por mob.
- [ ] **07 Chefes** (`07-chefes/`): fases, padrões de ataque, avisos visuais.
- [ ] **08 Mapa** (`08-mapa.md`): regiões, conexões, atalhos, santuários, armadilhas, dificuldade por região.
- [ ] **09 Interface** (`09-interface.md`): HUD, inventário, menus, telas de morte e vitória.
- [ ] **10 Arte e áudio** (`10-arte-audio.md`): guia de estilo, lista consolidada de assets e sons.
- [ ] **11 Balanceamento** (`11-balanceamento.md`): tabela com todos os números.
- [ ] **12 Técnico** (`12-tecnico.md`): arquitetura no Godot, estrutura de pastas, convenções de código.
