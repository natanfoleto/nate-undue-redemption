# Arte e áudio

Origem dos assets, guia de estilo e a lista completa de assets e sons, que sai das fichas.

## Origem dos assets
| Tipo | Origem |
|------|--------|
| Personagens e criaturas (Nate, mobs, Boiúna, dinossauro) | por código: blocos definidos no código, com animações também por código |
| Objetos do cenário (baú, alavanca, portão etc.) | montados com blocos, como os personagens |
| Cenário | blocos montados no motor; texturas de materiais comuns (pedra, terra, madeira, metal) de um único pacote pronto CC0; texturas marajoara e dos fungos bioluminescentes feitas para o jogo |
| Efeitos sonoros | prontos, com licença livre, ajustados para o jogo (corte, volume e tom) |
| Música | pronta, com licença livre e crédito ao autor quando a licença pedir |
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
| Texturas de 16 px da sala de teste, da clareira, da Mina e do Bosque (`assets/textures/`: cobblestone, cobblestone_mossy, dirt, grass_top, grass_side, oak_log_side, oak_log_top, oak_leaves, oak_planks, stone_generic, sandstone_carved, mud, basalt e serpentine), provisórias | "16x16 block texture set", de ARoachIFoundOnMyPillow: https://opengameart.org/content/16x16-block-texture-set | CC0 | não |
| 36 ícones de botão de teclado e mouse, Xbox e PlayStation (`assets/ui/buttons/`), provisórios | "Input Prompts Pixel 16×", de Kenney: https://opengameart.org/content/input-prompts-pixel-16%C3%97 | CC0 | não (crédito opcional ao Kenney) |

Os ícones definitivos são feitos para o jogo (`09-interface.md`). O pacote dos materiais comuns é escolhido na etapa 4.

Feitos para o jogo na etapa 6, provisórios: as texturas marajoara das Ruínas (`marajoara_wall`, `marajoara_floor`, `marajoara_jade` e `spear_plate`), os ícones de Terra, Ar, das combinações, das armas e armaduras das Ruínas e da Mina, do Selo e do muiraquitã inteiro, os desenhos dos pergaminhos de Terra e Ar e as imagens dos 7 murais (`assets/murals/`).

Feitos para o jogo na etapa 5, provisórios: as texturas dos fungos (`mushroom_stem`, `mushroom_cap_cyan` e `mushroom_cap_lime`), os ícones de 16 × 16 dos itens, dos elementos, da combinação Vapor, dos efeitos de status, do frasco, do muiraquitã e das melhorias, os desenhos dos pergaminhos de Fogo e Água e o papel do pergaminho aberto (`assets/ui/`).

### Plano de produção
Assets prontos entram como provisórios logo no começo da produção, para testar os sistemas cedo, e são trocados pelos definitivos aos poucos.

## Guia de estilo

### Base
- **Densidade:** 16 px por bloco em tudo. As texturas do cenário têm 16×16 pixels, e os personagens usam a mesma densidade (1 pixel equivale a 1/16 de bloco). Nate, com 2 blocos de altura, tem 32 pixels de altura.
- **Luz:** o subterrâneo é escuro, mas cada área tem a sua luz: lampiões na Mina, fungos que brilham no Bosque e padrões marajoara acesos nas Ruínas. Escuridão total só nas áreas que exigem a Luz Ancestral. Em todo lugar, a luz precisa bastar para ler os avisos (pilar 2).
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
| Rastro do golpe | arco branco curto; nas armas marajoara, verde-jade | — |

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
| Ruínas | terracota, preto e creme, as cores da cerâmica marajoara | padrões acesos em verde-jade |
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
| Dinossauro do Bosque | herbívoro de pescoço longo, com cerca de 5 blocos de altura, verde-musgo com manchas que brilham fraco; come cogumelos |
| Luz Ancestral | brilho branco-esverdeado |
| Magias | Fogo: laranja e amarelo; Água: azul-claro; Terra: marrom e ocre; Ar: branco e cinza-claro; cada combinação mistura as cores dos dois elementos |
| Frasco | moringa de cerâmica marajoara |
| Melhorias | contas de jade, uma em forma de coração (+1 coração) e outra em forma de gota (+1 carga) |
| Pergaminho | rolo de fibra clara com desenhos marajoara em preto e vermelho; ao ler, o rolo se abre na tela e mostra o desenho do elemento, sem texto |
| Armas | de 0,75 a 1,5 bloco de comprimento |
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
| 1 | S1 | o herói descansa num santuário e enche a moringa | o frasco e o descanso |
| 2 | S2 | o herói atravessa a escuridão guiado pela luz do muiraquitã | a passagem escura |
| 3 | S3 | o herói e o irmão enfrentam o predador lado a lado | a relação dos irmãos, antes da traição |
| 4 | S4 | a traição: na hora de fechar a prisão, falta a lasca, e o predador só adormece | a luta final |

### Outras cenas
- **Abertura:** Nhamundá à beira do rio. Lobos atacam um rebanho, moradores dão as costas a Nate, e ele vai sozinho para a floresta.
- **Troca de fase da Boiúna:** ela se solta em parte das correntes, ruge, e a arena se apaga.
- **Final:** Nate volta à cidade, que agora depende dele, o guardião da passagem.

## Áudio

### Música
Sete faixas instrumentais, sem letra, com flautas, tambores e marimbas para dar clima amazônico.

| Faixa | Onde toca |
|-------|-----------|
| Tema principal | menu, cena final e créditos |
| Mina | prólogo e Mina |
| Bosque de Fungos | Bosque |
| Ruínas | Ruínas |
| Memórias | as 4 memórias |
| Arenas | todas as arenas |
| Boiúna | luta final, mais intensa na fase 2 |

### Ambiente
| Área | Sons de fundo |
|------|---------------|
| Prólogo | pássaros e insetos |
| Mina | gotas, madeira rangendo e vento nos túneis |
| Bosque de Fungos | zumbido grave e fungos pulsando |
| Ruínas | eco e pedra |
| Grande Prisão | silêncio grave e a respiração da Boiúna |

### Regras de som
- Todo ataque inimigo tem som de aviso próprio (`03-regras.md`).
- Os sons de aviso sempre ficam acima da música na mixagem.
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
| Muiraquitã, Selo, pergaminho, moringa e as 2 melhorias | 6 | `05-itens.md` |
| Mobs: Lobo, Esqueleto Guerreiro com espada, Necromante com cajado e Golem de Pedra; as variantes só trocam a cor | 4 | `06-mobs/` |
| Projétil da praga | 1 | `06-mobs/necromante.md` |
| Dinossauro do Bosque | 1 | `06-mobs/README.md` |
| Gado do rebanho, na abertura | 1 | `10-arte-audio.md` |
| Boiúna, em segmentos | 1 | `07-chefes/boiuna.md` |
| Objetos do cenário: santuário, baú, alavanca, portão, ponte, porta que só abre por um lado, elevador, parede rachada, pilar e porta da Grande Prisão | 10 | `08-mapa.md` |
| Armadilhas: pedras do teto, cogumelo de esporos e placas com lanças | 3 | `08-mapa.md` |
| Cenário de superfície: árvores da floresta, entrada da mina e casas de Nhamundá à beira do rio | — | `08-mapa.md`, `10-arte-audio.md` |

### Texturas (16×16 pixels por bloco)
| Textura | Origem |
|---------|--------|
| Materiais comuns: pedra, terra, madeira e metal | pacote pronto CC0 |
| Padrões marajoara: paredes das Ruínas, santuários, pilares, placas das lanças e itens marajoara | feitas para o jogo |
| Fungos bioluminescentes | feitas para o jogo |
| Peles de personagens e criaturas: Nate, roupas das cenas, mobs e cores das variantes, Boiúna, dinossauro e gado | feitas para o jogo |
| Os 7 murais | feitos para o jogo |

Tamanho de cada mural, em blocos: `[A DEFINIR no rascunho do mapa]`.

### Animações (por código)
| De quem | Quantas | Ficha |
|---------|---------|-------|
| Nate | 11, mais 4 poses de tiro | `04-player.md`, `05-itens.md` |
| Mobs | de 6 a 8 por tipo | `06-mobs/` |
| Dinossauro do Bosque | 3: parado, andar devagar e comer | `06-mobs/README.md` |
| Boiúna | 12 | `07-chefes/boiuna.md` |
| Muiraquitã | 3: acordar, brilho e lasca se encaixando | `05-itens.md` |
| Objetos e armadilhas | as das fichas | `08-mapa.md` |
| Cenas | 7, montadas no motor | `10-arte-audio.md` |

### Efeitos visuais (partículas blocadas)
| Grupo | Efeitos |
|-------|---------|
| Golpes | rastro (branco e verde-jade), acerto e crítico |
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
