# Balanceamento

Todos os números do jogo num lugar só. São valores iniciais, e os testes no motor vão ajustá-los. Ao ajustar, este documento muda primeiro; se o número também aparece numa ficha, a ficha muda junto. No projeto, os números ficam nos arquivos de dados de `game/data/` (`12-tecnico.md`).

## Âncoras
| Âncora | Valor |
|--------|-------|
| Golpe do facão | 10 pontos; 15 no 3º golpe do combo |
| Golpes de facão para derrubar | Lobo 3, Necromante 4, Esqueleto 5, Golem 15 |
| Variantes | cerca de 60% a mais de vida |
| Recarga das magias de elemento | 8 a 10 s |
| Efeitos de status | cerca de 2 s |
| Mobs por onda | 3 a 4 nas arenas comuns; até 5 nas opcionais |

## Partida
Tempo de quem joga pela primeira vez, contando as mortes (`02-core-loop.md`).

| Trecho | Tempo |
|--------|-------|
| Prólogo + Mina | 5 min |
| Bosque de Fungos | 9 min |
| Ruínas | 11 min |
| Grande Prisão | 5 min (luta da Boiúna: cerca de 4 min) |
| Caminho principal | 30 min |
| Com todos os segredos | 45 min |

## Nate
| Valor | Número |
|-------|--------|
| Vida inicial | 5 corações |
| Vida máxima | 9 corações com as 4 melhorias; até 11 com armadura de +2 |
| Velocidade | 5 blocos/s |
| Aceleração e frenagem | 0,1 s |
| Ajuda de mira | cone de 45° (22,5° para cada lado da mira), até 4 blocos |
| Passo à frente em cada golpe | 0,5 bloco |
| Janela para continuar o combo | 0,4 s depois da recuperação |
| Recuperação depois do tiro | 0,3 s |
| Rolamento | 3 blocos em 0,4 s, invencível o tempo todo; recarga de 1 s |
| Sem controle ao levar golpe | 0,2 s |
| Invencível depois de levar golpe | 1 s |
| Frasco | 3 cargas (até 5 com melhorias); 2 corações por carga; 0,6 s para beber |
| Chance de crítico | 5% |
| Elementos equipados | 2 |
| Raio da Luz Ancestral | 6 blocos |

## Câmera
O enquadramento é provisório até o rascunho do mapa (`12-tecnico.md`).

| Valor | Número |
|-------|--------|
| Inclinação | 45° |
| Giro | 45° |
| Enquadramento | 14 blocos de altura de tela (cerca de 25 de largura) |
| Distância até Nate | 30 blocos; não muda o enquadramento, só deixa a câmera longe das paredes |

## Regras de combate
| Valor | Número |
|-------|--------|
| Aviso mínimo do golpe comum | 0,6 s |
| Aviso mínimo do golpe forte ou de área | 1 s |
| Recuo curto | 1 bloco |
| Recuo longo | 3 blocos |
| Interrompido | 0,4 s sem agir |
| Variação do dano de Nate | de 0,9 a 1,1 |
| Crítico | dobra o dano |
| Dano inimigo em Nate | golpe comum 1 coração; forte 2; do chefe até 3 |
| Mobs atacando ao mesmo tempo | no máximo 5 |
| Tempo de cada golpe de Nate | 30% de preparação, 20% de tempo ativo e 50% de recuperação |

## Armas corpo a corpo
Todas ficam entre 23 e 27 pontos de dano por segundo; o que muda é o jeito de bater.

| Peça | Dano (1º e 2º / 3º) | Tempo por golpe | Alcance e ângulo | Efeito |
|------|---------------------|-----------------|------------------|--------|
| Facão | 10 / 15 | 0,5 s | 1,5 bloco, 90° | — |
| Picareta | 16 / 24 | 0,7 s | 1,75 bloco, 45° | — |
| Lança marajoara | 10 / 15 | 0,5 s | 3 blocos, 30° | crítico de 20% (5% da base mais 15%) |
| Tacape marajoara | 16 / 24 | 0,7 s | 1,75 bloco, 150° | o 3º golpe atordoa por 1,5 s |
| Lâmina de pedra verde | 7 / 11 | 0,35 s | 1,25 bloco, 90° | cada acerto tira 0,5 s da recarga das magias equipadas |

## Armas à distância
| Peça | Dano | Tempo para puxar | Alcance | Projétil | Recuo | Efeito |
|------|------|------------------|---------|----------|-------|--------|
| Baladeira | 6 | 0,4 s | 10 blocos | 20 blocos/s | curto | — |
| Zarabatana marajoara | 5 | 0,4 s | 10 blocos | 25 blocos/s | nenhum | lento por 2 s |
| Azagaia marajoara | 18 | 1 s | 10 blocos | 15 blocos/s | longo | — |
| Arco marajoara | 16 | 1 s | 16 blocos | 30 blocos/s | curto | atravessa |

## Armaduras
| Peça | Corações | Velocidade de Nate | Efeito |
|------|----------|--------------------|--------|
| Colete de minerador | +1 | 5 blocos/s | — |
| Armadura de minerador | +2 | 4,5 blocos/s | — |
| Manto de fibras marajoara | +1 | 5 blocos/s | a esquiva recarrega em 0,7 s, em vez de 1 s |
| Couraça de cerâmica marajoara | +2 | 4,5 blocos/s | 15% a mais de dano |

## Magias
As combinações gastam as duas recargas. Onde a combinação causa dano, ele é maior que a soma das duas magias separadas.

| Magia | Recarga | Dano | Área | Efeito |
|-------|---------|------|------|--------|
| Bola de Fogo | 8 s | 25 | projétil a 15 blocos/s, alcance de 12 blocos; explosão de raio 1,5 bloco | queimadura |
| Onda Cortante | 8 s | 20 | linha de 2 × 8 blocos | recuo curto |
| Colapso Terrestre | 10 s | 30 | círculo de raio 3 blocos | recuo longo |
| Rajada Veloz | 10 s | — | cone de 60°, 5 blocos | recuo longo; Nate fica 30% mais rápido por 3 s |
| Vapor | as duas | — | nuvem de raio 2,5 blocos, a 4 blocos à frente, por 4 s | queimadura em quem está dentro |
| Magma | as duas | 60 | linha de 2 × 8 blocos | queimadura |
| Tempestade de Fogo | as duas | — | raio de 2,5 blocos ao redor de Nate, por 4 s | queimadura e recuo curto |
| Gelo | as duas | 25 | cone de 60°, 6 blocos | atordoa por 2 s |
| Lamaçal | as duas | — | círculo de raio 3 blocos, a 4 blocos à frente, por 5 s | lento |
| Escudo de Areia | as duas | — | ao redor de Nate, por 6 s | segura 1 golpe |

## Efeitos de status
| Efeito | Valor |
|--------|-------|
| Atordoado | Gelo: 2 s; 3º golpe do Tacape: 1,5 s; Boiúna, depois de cada parte da vida da fase 1: 6 s |
| Lento | metade da velocidade. Zarabatana e abalo do Golem: 2 s. Lamaçal, esporos e poças da Boiúna: enquanto estiver dentro e mais 1 s |
| Veneno | praga do Necromante: 1 coração depois de 2 s |
| Queimadura | 4 pontos a cada 0,5 s, por 2 s (16 no total) |
| Água equipada | os efeitos em Nate duram metade do tempo; com ela, o veneno da praga acaba em 1 s e não chega a agir |

## Mobs
| Mob | Vida | Velocidade | Percepção | Vida da variante |
|-----|------|------------|-----------|------------------|
| Lobo | 30 | 4,5 blocos/s | 10 blocos | Alfa: 50 |
| Esqueleto Guerreiro | 50 | 3 blocos/s | 7 blocos | Veterano: 80 |
| Necromante | 40 | 3 blocos/s | 10 blocos | Ancião: 65 |
| Golem de Pedra | 150 | 2 blocos/s | 7 blocos | Ancião: 240 |

### Ataques dos mobs
O tempo ativo é de 0,2 s; no salto do lobo, de 0,3 s.

| Ataque | Preparação | Recuperação | Recarga | Área | Recuo |
|--------|------------|-------------|---------|------|-------|
| Lobo: salto com mordida | 0,6 s | 0,8 s | 2 s | salto de 3 blocos em linha | curto |
| Lobo Alfa: salto forte | 1 s | 0,8 s | 2 s | salto de 4 blocos em linha | longo |
| Esqueleto: golpe de espada | 0,7 s | 0,6 s | 1,5 s | setor de 90°, 1,5 bloco | curto |
| Necromante: praga | 0,8 s | 0,5 s | 3 s | projétil a 8 blocos/s, alcance de 12 blocos | nenhum |
| Necromante: invocar | 1,2 s | 0,8 s | 12 s | 2 esqueletos de cada vez, no máximo 3 vivos | — |
| Golem: socão | 1,2 s | 1 s | 3 s | retângulo de 2 × 3 blocos à frente | longo |
| Golem: abalo | 1,4 s | 1 s | 3 s | círculo de raio 3 blocos (Ancião: 4,5) | curto |

### Comportamento
| Valor | Número |
|-------|--------|
| Desistir de perseguir | 4 s sem ver Nate |
| Necromante recua | quando Nate chega a menos de 4 blocos |
| Lobo do prólogo foge | com 10 pontos de vida ou menos; no prólogo, ele não morre |

## Arenas e ondas
| Arena | Onda 1 | Onda 2 | Onda 3 |
|-------|--------|--------|--------|
| Mina | 3 Lobos | 2 Esqueletos e 1 Lobo | — |
| Bosque 1 | 3 Esqueletos | 1 Necromante e 2 Lobos | — |
| Bosque 2 | 4 Lobos | 2 Esqueletos e 1 Necromante | 1 Necromante e 3 Lobos |
| Ruínas 1 | 3 Esqueletos e 1 Necromante | 1 Golem (o primeiro encontro com ele) | — |
| Ruínas 2 | 1 Golem e 2 Esqueletos Veteranos | 1 Necromante Ancião e 3 Lobos Alfa | — |
| Opcional da Mina | 2 Lobos Alfa e 2 Esqueletos Veteranos | 1 Necromante Ancião e 3 Esqueletos Veteranos | — |
| Opcional do Bosque | 1 Necromante Ancião e 3 Lobos Alfa | 2 Necromantes Anciões e 3 Esqueletos Veteranos | — |
| Opcional das Ruínas | 1 Golem Ancião e 2 Esqueletos Veteranos | 1 Golem Ancião, 1 Necromante Ancião e 2 Lobos Alfa | 2 Golens Anciões e 1 Necromante Ancião |

## Armadilhas
| Armadilha | Dano | Área | Tempo | Recuo |
|-----------|------|------|-------|-------|
| Pedras que caem | 1 coração em Nate; 30 nos mobs | raio de 1 bloco | aviso de 1 s; cai uma vez | curto |
| Cogumelo de esporos | — (lento) | nuvem de raio 2 blocos | aviso de 1 s; nuvem por 3 s; volta a crescer em 8 s | — |
| Lanças do chão | 1 coração em Nate; 20 nos mobs | as placas do chão | ciclo de 4 s: 2 s recolhidas, 1 s de aviso, 1 s para fora | curto |

## Boiúna
| Valor | Número |
|-------|--------|
| Vida da fase 1 | 4 partes de 180 (720 no total) |
| Atordoada depois de cada parte | 6 s |
| Ativar um pilar | segurar interagir por 2 s |
| Intervalo entre ataques | 3 s; 2,5 s; 2 s; 1,5 s (com 0, 1, 2 e 3 pilares ativos) |
| Vida da fase 2 | 400 |
| Bote | preparação de 1,2 s; linha de 2 blocos de largura; 3 corações; recuo longo; cabeça no chão por 2,5 s |
| Varrida de cauda | preparação de 1,2 s; setor de 120°, raio de 8 blocos; 2 corações; recuo longo |
| Cuspe de escuridão | preparação de 1 s; 3 círculos de raio 1,5 bloco; 2 corações; sem recuo; poças por 4 s |
| Emboscada | preparação de 1,2 s; linha de 2 blocos de largura; 3 corações; recuo longo; cabeça exposta por 2,5 s; uma a cada 5 s |
| Cerco | anel de raio 3 blocos, que fecha em 1,2 s; 2 corações; recuo curto |

## Valores provisórios da produção
Números que a produção precisou para o jogo funcionar e que os outros documentos não fixavam. Ficam em uso até a decisão; cada um está nos arquivos de dados de `game/data/` ou na cena indicada.

| Valor | Número em uso | Onde |
|-------|---------------|------|
| Círculo em que Nate recebe golpes | raio de 0,3 bloco | `data/balance/player.tres` |
| Círculo em que o lobo recebe golpes | raio de 0,4 bloco (Alfa: 0,5) | `data/mobs/` |
| Largura da linha do salto do lobo | 1 bloco (Alfa: 1 bloco) | `data/attacks/` |
| Tempo do empurrão do recuo | 0,2 s, o mesmo tempo sem controle de Nate | `data/balance/combat.tres` |
| Altura em que uma parede bloqueia golpes, tiros e a visão dos mobs | 1 bloco, a do peito de Nate | `combat/hit_shape.gd` |
| Distância em que o lobo espera a vez de atacar | 4 blocos (Alfa: 5) | `data/mobs/` |
| Tamanho do Lobo Alfa | 1,25 vez o lobo | `data/mobs/wolf_alpha.tres` |
| Piscar da invencibilidade | troca a cada 0,1 s | `data/balance/player.tres` |
| Tela clareando quando Nate volta | 0,5 s | `data/balance/player.tres` |
| Marcas e efeitos na tela | rastro do golpe de 0,5 bloco de largura; número do crítico subindo 0,6 bloco em 0,8 s; barra de vida dos mobs de 0,8 × 0,1 bloco, 0,3 bloco acima da cabeça | cenas de `player/`, `combat/` e `mobs/` |
| Círculo em que o Esqueleto recebe golpes | raio de 0,35 bloco | `data/mobs/skeleton.tres` |
| Distância em que o Esqueleto espera a vez de atacar | 3 blocos | `data/mobs/skeleton.tres` |
| Alcance para interagir | 1,5 bloco (elevador: 1,6, do centro da plataforma) | cenas de `world/objects/` |
| Distância para pegar um item do chão | 0,75 bloco | `world/objects/item_pickup.tscn` |
| Distância que ativa um ponto de retorno | 2 blocos | `world/areas/mine.tscn` |
| Área que começa a luta da arena da Mina | 16 × 14 blocos, dentro dos 18 × 16 do chão | `world/areas/mine.tscn` |
| Lobo do prólogo fugindo | na velocidade do lobo | `mobs/prologue_wolf.gd` |
| Animações dos objetos | portão desce 2,1 blocos em 0,6 s; tampa do baú abre 100° em 0,4 s; alavanca vira 70° em 0,25 s; pedra cai de 3 blocos em 0,25 s; elevador desce 6 blocos em 3 s | cenas de `world/objects/` e `world/traps/` |
| Luz da Mina | lampião com alcance de 8 blocos; luz ambiente a 0,3 dentro da Mina, contra 0,7 na superfície, trocando em 1,5 s | `world/objects/lamp.tscn` e `world/areas/mine.tscn` |
| Fim da parte jogável | tela escurece em 1,5 s e aceita um botão depois de 1 s | `ui/end_screen.tscn` |
| Tempo para apertar o outro botão e sair a combinação | 0,1 s | `player/player.tscn` (SpellCaster) |
| Necromante | círculo em que recebe golpes de raio 0,35 bloco; espera a vez de atacar a 6 blocos; as marcas de invocação têm raio de 0,6 bloco, a 1,5 bloco de cada lado dele; leque da praga do Ancião de 30° | `data/mobs/`, `data/attacks/summon.tres` |
| Cogumelo de esporos | incha quando alguém chega a 1,5 bloco; inchado fica 1,3 vez maior e, estourado, 0,4 vez | `world/traps/spore_mushroom.tscn` |
| Dinossauro do Bosque | anda a 1 bloco/s, até 4 blocos de casa; fica parado de 3 a 6 s e come por 5 s | `world/fauna/dinosaur.tscn` |
| Troca de área, viagem rápida e descanso | a tela escurece e clareia em 0,5 s | `data/balance/world.tres` |
| Santuário | alcance para interagir de 2 blocos; acende em 1 s na primeira visita | `world/objects/sanctuary.tscn` |
| Elevador entre a Mina e o Bosque | a chegada anda metade da viagem (3 blocos em 1,5 s); quebrado, fica inclinado 8°; o conserto leva 0,8 s | `world/objects/elevator.tscn` |
| Porta que só abre por um lado | a laje desce 2,3 blocos em 0,8 s | `world/objects/one_way_door.tscn` |
| Pergaminho aberto | abre em 0,5 s e fecha com qualquer botão depois de 1 s | `ui/scroll_view.tscn` |
| Muiraquitã acordando | pulso de luz de 1,6 s | `player/player.tscn` |
| Memórias | 7 s (memória 1) e 8 s (memória 2); dá para pular depois de 1,5 s; a tela clareia em 0,6 s | `world/memories/` |
| Áreas escuras | o círculo da Luz Ancestral tem borda suave de 1,5 bloco | `world/areas/` |
| Efeitos das magias | estouro de 24 cubinhos em 0,5 s, com clarão do dobro do raio; onda a 55% de opacidade; nuvem de 40 cubinhos; praga saindo a 1,2 bloco do chão | `data/effects/spell_effects.tres`, `data/mobs/` |
| Luz do Bosque | luz ambiente a 0,85; luz dos cogumelos gigantes com alcance de 8 blocos e dos fungos pequenos com 6 | `world/areas/forest.tscn` |
| Área que começa a luta das arenas do Bosque | 15 × 13 blocos, dentro dos 18 × 16 do chão | `world/areas/forest.tscn` |
| Golem | círculo em que recebe golpes de raio 0,6 bloco; o Ancião é 1,2 vez maior; espera a vez de atacar a 4 blocos | `data/mobs/`, `mobs/golem.tscn` |
| Lanças do chão | uma placa de 1 × 1 bloco por vez; placas vizinhas com 0,7 s de diferença no ciclo; as lanças sobem e descem em 0,1 s | `world/traps/floor_spears.tscn`, `world/areas/ruins.tscn` |
| Escudo de Areia | a areia gira num raio de 1 bloco em volta de Nate | `data/attacks/sand_shield.tres` |
| Ponte de alavanca | 2 × 4 blocos; baixa em 1,2 s | `world/objects/lever_bridge.tscn` |
| Parede rachada sem a Terra | treme 0,06 bloco em 0,25 s | `world/objects/cracked_wall.tscn` |
| Murais | desenho na parede de 2 × 1,25 blocos; o mural grande aparece em 0,4 s e fecha com qualquer botão depois de 1 s | `world/objects/mural.tscn`, `ui/mural_view.tscn` |
| Memória 3 | 7 s | `world/memories/memory_3.tscn` |
| Arenas das Ruínas e arena opcional da Mina | a luta começa em 15 × 13 blocos (Mina: 16 × 14), dentro do chão de cada arena | `world/areas/` |
