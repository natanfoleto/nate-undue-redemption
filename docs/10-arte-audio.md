# Arte e áudio

Origem dos assets, guia de estilo e a lista completa de assets e sons, que sai das fichas.

## Origem dos assets
| Tipo | Origem |
|------|--------|
| Personagens e criaturas (Nate, mobs, Boiúna) | por código: blocos definidos no código, com animações também por código |
| Objetos do cenário (baú, alavanca, portão etc.) | montados com blocos, como os personagens |
| Cenário | blocos montados no motor; texturas de materiais comuns (pedra, terra, madeira, metal) de um único pacote pronto CC0, pintado à mão; texturas marajoara e dos fungos bioluminescentes feitas para o jogo |
| Efeitos sonoros | prontos, com licença livre, ajustados para o jogo (volume e tom, no banco de sons): a família de pacotes de Kenney, as criaturas de rubberduck e as magias de leohpaz |
| Música | pronta, com licença livre e crédito ao autor quando a licença pedir; por enquanto, faixas CC0 de Alexander Ehlers e de Kistol |
| Ícones da interface | pixel art feita para o jogo: cerca de 40 ícones de 16×16 pixels, ampliados na tela |
| Fonte | fonte pixel com licença livre (OFL) e com os acentos do português |

### Licenças
- Preferir CC0 (uso livre, inclusive comercial). CC BY também serve, com crédito nos créditos do jogo.
- Não usar assets de "uso pessoal" nem "não comercial".
- Nunca usar arquivos do Minecraft ou do Minecraft Dungeons. O estilo pode lembrar, mas os arquivos não podem vir de lá.
- Um pacote, ou uma família de pacotes, por tipo de asset, para manter a coerência.
- Cada asset pronto entra no registro abaixo.

### Registro de assets prontos
| Asset | Origem (link) | Licença | Crédito exigido |
|-------|---------------|---------|-----------------|
| Texturas pintadas à mão do cenário, da sala de teste e das memórias (`assets/textures/painted/`: grass, grass_side, dirt, stone, cobble, mossy_cobble, stone_brick, sandstone_brick, bark, leaves, jungle_leaves, planks, wood, gravel, clay, clay_brick, desert_stone, sand e rail), reduzidas de 128 para 32 px; a grama perde 25% da cor, e `grass_side` junta a terra com a franja de grama do pacote. Plantas (grass_tuft, grass_tall, jungle_grass, papyrus, flower_blue, flower_yellow e flower_red), com o recorte limpo. Água, rio e lava animados (water_strip, river_strip e lava_strip: 8 quadros de 32 px, um embaixo do outro) | "Big pack of hand painted tiling textures", de drummyfish: https://opengameart.org/node/91360 | CC0 | não (crédito apreciado) |
| Sons de Nate, das armas, dos objetos e da interface (`assets/audio/kenney/`), provisórios | "RPG Audio", "Impact Sounds" e "Interface Sounds", de Kenney: https://kenney.nl/assets/rpg-audio, https://kenney.nl/assets/impact-sounds e https://kenney.nl/assets/interface-sounds | CC0 | não (crédito opcional a Kenney) |
| Vozes dos mobs (`assets/audio/rubberduck/`), provisórias | "80 CC0 creature SFX" e "80 CC0 creture SFX #2", de rubberduck: https://opengameart.org/content/80-cc0-creature-sfx e https://opengameart.org/content/80-cc0-creture-sfx-2 | CC0 | não |
| Sons das magias e da praga (`assets/audio/leohpaz/`), provisórios | "8 Magic Attacks", de leohpaz: https://opengameart.org/content/8-magic-attacks | CC-BY 4.0 | sim: leohpaz |
| Música do menu, das memórias, das arenas, do Bosque e das Ruínas (`assets/audio/music/`: great_mission, doomed, waking_the_devil, spacetime e warped), provisória | "Free Music Pack", de Alexander Ehlers (tricksntraps): https://opengameart.org/content/free-music-pack | CC0 | não |
| Música do prólogo e da Mina (`assets/audio/music/krakatoa.ogg`), provisória | "Krakatoa", de Kistol: https://opengameart.org/content/krakatoa | CC0 | não |
| Som de fundo da Mina e das Ruínas (`assets/audio/ambience/dungeon_ambient_1.ogg`), provisório | "Loopable Dungeon Ambience", de JaggedStone: https://opengameart.org/content/loopable-dungeon-ambience | CC0 | não |
| 36 ícones de botão de teclado e mouse, Xbox e PlayStation (`assets/ui/buttons/`), provisórios | "Input Prompts Pixel 16×", de Kenney: https://opengameart.org/content/input-prompts-pixel-16%C3%97 | CC0 | não (crédito opcional ao Kenney) |

Os ícones definitivos são feitos para o jogo (`09-interface.md`). O pacote dos materiais comuns é o do drummyfish, pintado à mão, escolhido depois do primeiro teste de jogo para o cenário não ficar idêntico ao Minecraft. Ele troca o "16x16 block texture set" (ARoachIFoundOnMyPillow, CC0), usado até a etapa 6.

Feitos para o jogo na etapa 6, provisórios: as texturas marajoara das Ruínas (`marajoara_jade` e `spear_plate`), os ícones de Terra, Ar, das combinações, das armas e armaduras das Ruínas e da Mina, do Selo e do muiraquitã inteiro, os desenhos dos pergaminhos de Terra e Ar e as imagens dos 7 murais (`assets/murals/`).

Feitos para o jogo na etapa 5, provisórios: as texturas dos fungos (`mushroom_stem`, `mushroom_cap_cyan` e `mushroom_cap_lime`), os ícones de 16 × 16 dos itens, dos elementos, da combinação Vapor, dos efeitos de status, do muiraquitã e das melhorias, os desenhos dos pergaminhos de Fogo e Água e o papel do pergaminho aberto (`assets/ui/`).

Feitos para o jogo depois do segundo teste de jogo, provisórios: o som do golpe de lâmina (`assets/audio/ours/swoosh.wav`, um vush de vento) e o do dash (`dash.wav`, mais grave e longo), sintetizados de ruído filtrado; o ícone e o modelo da poção de vida (`assets/ui/items/flask.png`); a pose do dash; as peças de rampa e de canto do chão (`tools/areas/`); e as peles de Nate, dos mobs e dos itens no molde das skins do Minecraft (`assets/textures/`).

Feitos para o jogo depois do terceiro teste de jogo, provisórios: as texturas das Ruínas no lugar dos losangos e ziguezagues marajoara, a parede de tijolos de terracota lisos (`terracotta_wall`) e o piso de placas grandes de pedra clara (`light_stone_floor`), pintadas por `tools/areas/make_ruins_textures.gd`; as peles do herói, do irmão, da cabeça da Boiúna, do santuário e do cogumelo de esporos (`tools/models/make_scene_skins.gd`); o ícone da espada; a meia-lua do golpe (`world/effects/slash.gdshader`); e os ícones dos botões G e direcional para cima.

### Plano de produção
Assets prontos entram como provisórios logo no começo da produção, para testar os sistemas cedo, e são trocados pelos definitivos aos poucos.

## Guia de estilo

### Base
- **Densidade:** personagens, objetos e ícones usam 16 px por bloco (1 pixel equivale a 1/16 de bloco); Nate, com 2 blocos de altura, tem 32 pixels de altura. As texturas prontas do cenário têm 32 px por bloco, pintadas à mão, mais detalhadas que as do Minecraft; as feitas para o jogo (marajoara e fungos) seguem com 16 px.
- **Caixas retas e pele pintada:** personagens, criaturas e itens são caixas retas, como no Minecraft, com a pele pintada pixel a pixel no molde das skins do Minecraft, a 16 px por bloco: Nate (rosto, cabelo e as dobras da roupa); os mobs (o pelo do lobo, os ossos do esqueleto com as juntas roxas, o manto do necromante com a barra roxa, a pedra do golem em blocos com veios roxos), com as variantes nas cores delas; e os itens (a lâmina com fio e ponta, os cabos com rebites e amarrações, os padrões marajoara, as costuras e os rebites das armaduras). Nas cenas, o herói e o irmão têm as caixas e as proporções de Nate, com outra roupa (o herói: túnica cor de urucum com a faixa creme de traços pretos, tanga de algodão, faixa vermelha na cabeça, cabelo comprido, traços de jenipapo nos antebraços e o muiraquitã inteiro; o irmão: túnica escura com a faixa ocre, cabelo curto, a testa franzida, o olhar de lado e uma cicatriz); a cabeça da Boiúna tem escamas, a barriga em placas, olhos âmbar de pupila em fenda e presas; o santuário, blocos de pedra com musgo, o pilar com o losango entalhado, as faixas vermelha e preta e o cristal de jade; e o cogumelo de esporos, o pé com fibras e o chapéu com pintas e lamelas.
- **Chão em manchas:** a grama da clareira e o chão da Mina misturam 3 tons em manchas, e a grama tem terra nas laterais, para o relevo aparecer e o chão não ficar chapado. Onde um chão encontra outro, a borda ondula e mistura os dois (`08-mapa.md`).
- **Rampas:** na natureza, o relevo sobe em rampas do próprio chão, com a textura de cima seguindo a inclinação e as laterais do bloco; escadas de pedra só nas construções (`08-mapa.md`).
- **Profundidade:** abaixo do chão, a rocha fica mais escura, e o fundo dos abismos tem cor e luz próprias (água escura, água brilhante e fungos, lava), para a câmera ler a altura de cada parte.
- **Luz:** o subterrâneo é escuro, mas cada área tem a sua luz: lampiões na Mina, fungos que brilham no Bosque e padrões marajoara acesos nas Ruínas. Escuridão total só nas áreas que exigem a Luz Ancestral, e ela é do próprio lugar: o chão, as paredes e as plantas escurecem, sem camada por cima, e Nate, os mobs e os itens continuam visíveis; com a Luz Ancestral, a luz de Nate clareia em volta dele. Em todo lugar, a luz precisa bastar para ler os avisos (pilar 2).
- **Efeitos visuais:** partículas blocadas, feitas de pequenos cubos e quadrados: faíscas, poeira, fogo, água e escuridão.

### Cenas
- Feitas no motor, sem fala: modelos blocados do jogo, câmera em movimento e música.
- São 7: abertura, 4 memórias, a troca de fase da Boiúna e o final.
- Personagens que só aparecem nas cenas (moradores de Nhamundá, o herói antigo e o irmão) saem do modelo base de Nate, com outras roupas e cores.
- A abertura pede um cenário pequeno de Nhamundá.

### Sinais de leitura
Cada sinal tem forma própria, e não só cor, para ajudar daltônicos (`09-interface.md`).

| Sinal | Visual | Som |
|-------|--------|-----|
| Aviso de golpe forte ou de área | marca vermelho-alaranjada no chão, com listras diagonais que vão enchendo até o golpe | o aviso próprio de cada ataque |
| Aviso de golpe comum | brilho branco no inimigo, junto com a pose | som curto |
| Crítico | número amarelo grande e faíscas amarelas | impacto agudo |
| Tiro na força total | brilho branco na ponta da arma | clique curto |
| Achar item | feixe de luz sobre o item e partículas ao pegar | som de recompensa |
| Raridade | marajoara: brilho e moldura verde-jade, a cor do muiraquitã; comum: moldura cinza, sem brilho | — |
| Atordoado | estrelas amarelas girando sobre a cabeça; ícone de estrela | som de tontura |
| Lento | partículas azuis nos pés; ícone de pegada | som abafado |
| Veneno | bolhas verdes; ícone de gota | borbulhar |
| Queimadura | chamas laranja; ícone de chama | crepitar |
| Imune | a palavra "imune", em cinza | batida seca |
| Invencível | Nate pisca | — |
| Rastro do golpe | meia-lua branca, grossa no meio e fina nas duas pontas, adaptada dos jogos 2D: aparece varrendo a área do golpe, por cima de tudo, e some; o começo do arco e a beira de dentro mais transparentes; a mesma em todas as armas | vush de vento, o mesmo em todos os golpes |
| Dash | cópias translúcidas de Nate pelo caminho, que somem em 0,25 s, e poeira de cubos nos pés | vush de vento mais grave |
| Item da mão | moldura dourada no espaço da barra fixa e o nome do item em cima dela | som curto de lâmina |

### Linguagem de cor
- **Roxo:** a escuridão do predador. Só as criaturas dela e a Boiúna usam roxo.
- **Verde-jade:** o povo antigo e o muiraquitã: itens marajoara, padrões das Ruínas e pilares da prisão.
- **Vermelho-alaranjado:** perigo, nas marcas de aviso.

### Paleta por área
| Área | Cenário | Luz |
|------|---------|-----|
| Prólogo | verdes da mata e terra vermelha | sol de fim de tarde |
| Mina | madeira escura, terra ocre e pedra cinza | lampiões amarelos |
| Bosque de Fungos | azul-escuro e verde-musgo | fungos ciano e verde-limão |
| Ruínas | paredes de tijolo de terracota liso e piso de placas grandes de pedra clara, sem padrão; o marajoara (preto, creme e verde-jade) só nos detalhes, como os pilares | padrões acesos em verde-jade |
| Grande Prisão | pedra escura | pilares que acendem em verde-jade |

### Cores e tamanhos
| Entidade | Visual |
|----------|--------|
| Nate | camiseta mostarda gasta, calça jeans, botas de borracha pretas, pele morena e cabelo preto curto; o muiraquitã verde-jade no pescoço |
| Lobo | cinza-escuro, com olhos âmbar; Alfa: preto, com os olhos mais fortes |
| Esqueleto Guerreiro | ossos cinza-escuros com brilho roxo nos olhos e nas juntas; Veterano: ossos quase pretos e brilho mais forte |
| Necromante | manto roxo-escuro, rosto em sombra, olhos roxos e cajado com pedra roxa; Ancião: manto preto com bordas roxas |
| Golem de Pedra | pedra cinza com rachaduras que brilham em roxo; Ancião: pedra escura e rachaduras mais largas |
| Boiúna | preta com reflexos roxos e olhos âmbar que brilham |
| Luz Ancestral | brilho branco-esverdeado |
| Magias | Fogo: laranja e amarelo; Água: azul-claro; Terra: marrom e ocre; Ar: branco e cinza-claro; cada combinação mistura as cores dos dois elementos |
| Poção de vida | garrafinha de vidro com o líquido vermelho, um brilho claro no vidro e rolha de cortiça |
| Melhorias | contas de jade, uma em forma de coração (+20 de vida) e outra em forma de gota (+1 carga) |
| Pergaminho | rolo de fibra clara com desenhos marajoara em preto e vermelho; ao ler, o rolo se abre na tela e mostra o desenho do elemento, sem texto |
| Armas | de 0,5 bloco (estilingue) a 1,8 bloco (lança) de comprimento |
| Pedras que caem | 1 bloco |
| Cogumelo de esporos | 1,5 bloco de altura |
| Lanças do chão | placas de 1×1 bloco |

## História visual

### Murais
Contam a história pública do povo antigo. Ficam onde o `08-mapa.md` define.

| Mural | Onde | Conteúdo |
|-------|------|----------|
| 1 | Mina, onde a mina encontra os túneis antigos | o povo antigo vivendo em Agartha |
| 2 | Bosque | o predador surgindo das profundezas e o povo fugindo |
| 3 | Bosque, escondido | o povo construindo os santuários e a Grande Prisão |
| 4 | Ruínas, sala do Selo | os dois irmãos: o herói recebe o muiraquitã, e o irmão olha com inveja |
| 5 | Ruínas, sala do Selo | a traição: o irmão tira a lasca do muiraquitã e a esconde |
| 6 | Ruínas, escondido | o rosto do irmão |
| 7 | antessala da Grande Prisão | a prisão ativada pela metade: o predador adormece em vez de ficar preso |

### Memórias
Mostram a vida pessoal do herói antigo. Cada uma prepara o que vem logo depois: é assim que um homem comum aprende a usar as construções (`01-historia.md`).

| Memória | Santuário | Conteúdo | O que prepara |
|---------|-----------|----------|---------------|
| 1 | S1 | o herói descansa num santuário e enche a poção | a poção de vida e o descanso |
| 2 | S2 | o herói atravessa a escuridão guiado pela luz do muiraquitã | a passagem escura |
| 3 | S3 | o herói e o irmão enfrentam o predador lado a lado | a relação dos irmãos, antes da traição |
| 4 | S4 | a traição: na hora de fechar a prisão, falta a lasca, e o predador só adormece | a luta final |

### Outras cenas
- **Abertura:** Nhamundá à beira do rio. Lobos atacam um rebanho, moradores dão as costas a Nate, e ele vai sozinho para a floresta.
- **Troca de fase da Boiúna:** ela se solta em parte das correntes, ruge, e a arena se apaga.
- **Final:** Nate volta à cidade, que agora depende dele, o guardião da passagem.

## Áudio

### Música
Sete faixas instrumentais, sem letra, com flautas, tambores e marimbas para dar clima amazônico. As provisórias são as faixas prontas abaixo; só "Krakatoa", de percussão e marimba, tem o clima amazônico.

| Faixa | Onde toca | Faixa provisória |
|-------|-----------|------------------|
| Tema principal | menu, cena final e créditos | "Great mission" (Alexander Ehlers) |
| Mina | prólogo e Mina | "Krakatoa" (Kistol) |
| Bosque de Fungos | Bosque | "Spacetime" (Alexander Ehlers) |
| Ruínas | Ruínas | "Warped" (Alexander Ehlers) |
| Memórias | as 4 memórias, por cima da música da área | "Doomed" (Alexander Ehlers) |
| Arenas | todas as arenas, da primeira onda até a vitória, por cima da música da área | "Waking the devil" (Alexander Ehlers) |
| Boiúna | luta final, mais intensa na fase 2 | `[A DEFINIR na etapa 7]` |

### Ambiente
| Área | Sons de fundo | Som provisório |
|------|---------------|----------------|
| Prólogo | pássaros e insetos | nenhum ainda |
| Mina | gotas, madeira rangendo e vento nos túneis | "Loopable Dungeon Ambience" (JaggedStone), só embaixo da terra |
| Bosque de Fungos | zumbido grave e fungos pulsando | nenhum ainda |
| Ruínas | eco e pedra | "Loopable Dungeon Ambience" (JaggedStone) |
| Grande Prisão | silêncio grave e a respiração da Boiúna | `[A DEFINIR na etapa 7]` |

### Regras de som
- Todo ataque inimigo tem som de aviso próprio (`03-regras.md`).
- Os sons de aviso sempre ficam acima da música na mixagem: eles tocam num canal próprio, um pouco mais alto, e a música abaixa sozinha enquanto um aviso toca.
- Os sons do mundo saem do ponto onde acontecem e ficam mais baixos longe de Nate; os da interface tocam na tela.
- Passos conforme o chão: grama e musgo, madeira (tábuas, pontes e a plataforma do elevador) e pedra ou terra.
- Golpes e acertos de Nate soam em três pesos: leve, médio e pesado (`05-itens.md`).

## Lista completa de assets e sons
Tudo sai das fichas. Os detalhes de cada item estão na ficha indicada.

### Modelos (por código)
| Modelo | Quantos | Ficha |
|--------|---------|-------|
| Nate, o modelo base humano, com o muiraquitã com e sem a lasca | 1 | `04-player.md` |
| Personagens das cenas, feitos do modelo de Nate: moradores, herói antigo e irmão | 3 | `10-arte-audio.md` |
| Seta da mira | 1 | `04-player.md` |
| Armaduras sobre o modelo de Nate | 4 | `05-itens.md` |
| Armas corpo a corpo | 5 | `05-itens.md` |
| Armas à distância e seus projéteis | 4 + 4 | `05-itens.md` |
| Muiraquitã, Selo, pergaminho, poção de vida e as 2 melhorias | 6 | `05-itens.md` |
| Mobs: Lobo, Esqueleto Guerreiro com espada, Necromante com cajado e Golem de Pedra; as variantes só trocam a cor | 4 | `06-mobs/` |
| Projétil da praga | 1 | `06-mobs/necromante.md` |
| Gado do rebanho, na abertura | 1 | `10-arte-audio.md` |
| Boiúna, em segmentos | 1 | `07-chefes/boiuna.md` |
| Objetos do cenário: santuário, baú, alavanca, portão, ponte, porta que só abre por um lado, elevador, parede rachada, pilar e porta da Grande Prisão | 10 | `08-mapa.md` |
| Armadilhas: pedras do teto, cogumelo de esporos e placas com lanças | 3 | `08-mapa.md` |
| Cenário de superfície: árvores da floresta, entrada da mina e casas de Nhamundá à beira do rio | — | `08-mapa.md`, `10-arte-audio.md` |

### Texturas (32 px por bloco nas prontas; 16 px nas feitas para o jogo)
| Textura | Origem |
|---------|--------|
| Materiais comuns: pedra, terra, madeira e metal | pacote pronto CC0, pintado à mão |
| Padrões marajoara: pilares das Ruínas, santuários, placas das lanças e itens marajoara | feitas para o jogo |
| Terracota e pedra clara das Ruínas | feitas para o jogo, no jeito das pintadas (32 px por bloco) |
| Fungos bioluminescentes | feitas para o jogo |
| Peles de personagens e criaturas: Nate, roupas das cenas, mobs e cores das variantes, Boiúna e gado | feitas para o jogo |
| Os 7 murais | feitos para o jogo |

Tamanho de cada mural, em blocos: `[A DEFINIR no rascunho do mapa]`.

### Animações (por código)
| De quem | Quantas | Ficha |
|---------|---------|-------|
| Nate | 11, mais 2 poses de tiro | `04-player.md`, `05-itens.md` |
| Mobs | de 6 a 8 por tipo | `06-mobs/` |
| Boiúna | 12 | `07-chefes/boiuna.md` |
| Muiraquitã | 3: acordar, brilho e lasca se encaixando | `05-itens.md` |
| Objetos e armadilhas | as das fichas | `08-mapa.md` |
| Cenas | 7, montadas no motor | `10-arte-audio.md` |

### Efeitos visuais (partículas blocadas)
| Grupo | Efeitos |
|-------|---------|
| Golpes | rastro (a meia-lua branca), acerto e crítico |
| Nate | rastro e poeira do dash |
| Sinais | marca de aviso no chão, brilho de golpe comum, tiro na força total, feixe de item e piscar de invencibilidade |
| Efeitos de status | estrelas, partículas azuis, bolhas verdes e chamas |
| Magias | 10, uma por magia |
| Muiraquitã | brilho da Luz Ancestral |
| Mobs | praga, marca de invocação, esqueletos se desfazendo, abalo e pedras do golem desmoronando |
| Boiúna | cuspe, poças de escuridão e corrente de luz |
| Cenário | nuvem de esporos, poeira das pedras e iluminação de cada área |

### Sons
| Grupo | Quantos | Ficha |
|-------|---------|-------|
| Nate | cerca de 15 | `04-player.md` |
| Armas | cerca de 18 | `05-itens.md` |
| Magias e muiraquitã | 12 | `05-itens.md` |
| Mobs | cerca de 19 | `06-mobs/` |
| Boiúna | cerca de 13 | `07-chefes/boiuna.md` |
| Armadilhas e objetos | cerca de 18 | `08-mapa.md` |
| Sinais e efeitos de status | 5 | `03-regras.md`, `10-arte-audio.md` |
| Interface | 4 | `09-interface.md` |
| Ambiente | 5 sons de fundo | `10-arte-audio.md` |
| Música | 7 faixas | `10-arte-audio.md` |

São cerca de 100 efeitos sonoros, além dos sons de fundo e da música.

### Interface
| Asset | Quantos |
|-------|---------|
| Ícones de 16×16 pixels | cerca de 40 |
| Imagens de mapa (Mina, Bosque e Ruínas) | 3 |
| Fonte pixel (OFL) | 1 |
