# Técnico

Motor, arquitetura, estrutura de pastas e convenções de código.

## Fundamentos
| Item | Decisão |
|------|---------|
| Motor | Godot 4.7.2, a versão estável no começo da produção (2026-10-12), fixada até o fim (sem atualizar no meio) |
| Linguagem | GDScript, sempre com tipos declarados (ex.: `var health: int = 5`) |
| Plataformas | Windows e macOS; o desenvolvimento acontece no Mac |
| Idioma do código | nomes de variáveis, funções e arquivos em inglês, como a API do Godot; comentários e textos do jogo em português |
| Textos do jogo | numa tabela de tradução do Godot desde o início, só com português do Brasil (`09-interface.md`) |

- Antes de publicar, o jogo precisa ser testado num Windows de verdade.
- No Mac, um jogo sem assinatura mostra um aviso de segurança, e assinar exige a conta paga de desenvolvedor da Apple. Assinar ou não: `[A DEFINIR na publicação]`.

## Arquitetura

### Mapa
- Uma cena por área: Prólogo e Mina, Bosque de Fungos, Ruínas e Grande Prisão (`08-mapa.md`).
- A troca de cena acontece nas passagens que já existem: o elevador (Mina → Bosque), a passagem escura (Bosque → Ruínas) e a porta da Grande Prisão. Na viagem rápida, a área de destino carrega durante um escurecimento da tela.
- O cenário é pintado bloco a bloco com o GridMap do Godot, com uma biblioteca de blocos por área: texturas de 32 px (as prontas) e de 16 px (as feitas para o jogo), projetadas pelo mundo para continuarem de um bloco para o outro (`10-arte-audio.md`). A grama tem a face de cima diferente das laterais. Detalhes menores que um bloco viram objetos à parte.
- As texturas ficam sem compressão, para os pixels continuarem nítidos: a detecção de 3D do Godot, que as trocaria por compressão com perda e mipmaps quando aparecem no 3D, fica desligada (`importer_defaults` no `project.godot` e `detect_3d/compress_to=0` em cada `.import`).
- **Relevo:** o chão tem platôs de 1 e 2 blocos, rampas do próprio chão na natureza e escadas nas construções (peças da biblioteca, com rampa na colisão) (`08-mapa.md`). Cada área sai de dois rascunhos em texto: o do mapa, com um caractere por bloco (o que é chão, abismo ou o resto), e o das alturas, em que o dígito é a altura do chão, n, s, e e w são escadas subindo para aquele lado, ^, v, > e < são rampas do chão (de 1 a 3 blocos seguidos) e de A a J é ponte na altura 0 a 9. Com `auto_ramps` (na Mina e no Bosque), todo desnível de 1 bloco entre dois chões vira rampa sozinho, com as peças de canto de dentro e de fora. A biblioteca de cada área tem, para cada chão que vira rampa, as peças de rampa de 1, 2 e 3 blocos e os 2 cantos, pelo nome ("Grama rampa 1/2", "Grama rampa canto de fora").
- **Formas soltas e chão misturado:** os rascunhos passam por `shapes.py` (reentrâncias e saliências nas paredes, conferindo o caminho principal a cada saliência); nos geradores, cada bloco de chão pega o material de um vizinho puxado por um ruído suave (`blend_source` do montador), para a borda entre dois chões ondular.
- **Geradores das áreas:** ficam em `game/tools/areas/`, junto com os rascunhos. Os rascunhos saem dos scripts em Python (`python3 game/tools/areas/mine_layout.py`, que também confere se o caminho principal se alcança); as bibliotecas de blocos e as áreas, dos scripts do Godot, a partir da raiz do repositório: `godot --headless --path game -s res://tools/areas/make_blocks.gd` e depois `make_mine.gd`, `make_forest.gd` e `make_ruins.gd`. Os geradores acham cada bloco da biblioteca pelo nome. Eles gravam nas áreas os valores das cenas que elas usam (Nate, o inventário, a pausa e as outras telas): depois de mudar uma dessas cenas, as áreas são geradas de novo. As texturas de terracota e de pedra clara das Ruínas saem de `make_ruins_textures.gd`, antes da importação e das bibliotecas.
- **Montador do terreno** (`terrain_builder.gd`): faz o chão, as escadas, as rampas, as paredes, as pontes e o terreno de fora até 24 blocos além do chão, para a câmera nunca ver o vazio: abismo onde há chão atrás na diagonal da câmera, morro na borda de fora. Cada coluna tem um teto, o da linha de visão da câmera até o chão atrás dela, e só tem os blocos que aparecem (do topo da vizinha mais baixa até o próprio topo). Ele também marca as beiradas dos platôs e assa o mapa de navegação dos mobs.
- Cada área tem quatro GridMaps: `Terrain` (o terreno, camada 1), `Sight` (blocos invisíveis em cima das paredes baixas, que seguram os tiros e a visão dos mobs até 3 blocos acima do chão, camada 1), `Barriers` (barreiras invisíveis na beira dos abismos, camada 4) e `Decor` (cercas, capim e flores, sem colisão).
- Água, rio e lava usam o shader `world/blocks/liquid.gdshader`: a textura é uma faixa de quadros que troca com o tempo.

### Modelos e animações
- Cada modelo é um arquivo de dados com a lista de caixas: tamanho, posição, ponto de giro e região da textura. Um script único, o montador, monta o modelo no jogo.
- As animações também são dados: poses-chave por tempo, com a rotação e a posição de cada parte, tocadas pelo mesmo sistema.
- Uma cena de prévia no editor mostra o modelo e a animação enquanto os dados são editados.
- Uma variante usa o mesmo modelo e só troca a textura (`06-mobs/README.md`).
- O montador e a prévia são feitos antes dos primeiros modelos.
- Medidas em pixels (16 px = 1 bloco), com o chão em y = 0 e a frente do modelo virada para −z.
- Cada caixa tem um nome e pode se prender a outra, girando junto com ela. Uma caixa de tamanho zero só agrupa partes.
- A textura segue o molde de caixa do Minecraft: cada caixa ocupa uma região que começa num canto dado. Sem textura, cada caixa usa a própria cor (caixa lisa).
- Chanfro por modelo (`bevel`, em pixels): corta as quinas de todas as caixas, sem passar de um terço do lado menor de cada uma. Hoje todos os modelos usam 0 (caixas retas, como no Minecraft).
- A pele de um modelo segue o molde de caixa das skins do Minecraft (`ModelData.texture`). As peles saem de geradores em `tools/models/`: `make_nate_skin.gd` (a de Nate, que também refaz o modelo), `make_mob_skins.gd` (as dos mobs, sem mudar as caixas), `make_item_models.gd` (os modelos dos itens, com as caixas e a pele, e o ícone da espada) e `make_scene_skins.gd` (o herói e o irmão das memórias, refeitos com as caixas de Nate, e as peles da cabeça da Boiúna, do santuário e do cogumelo de esporos, que mantêm as caixas). Cada um roda em três passos: as texturas, a importação e os modelos (`-- --model`).
- Uma pose cita só as partes que saem do repouso. Entre duas poses, o movimento é suave ou constante, e a troca de animação mistura as duas no tempo de mistura da nova.
- Os scripts ficam em `game/tools/models/` (o montador `BlockModel`, o tocador `ModelAnimator` e a prévia `model_preview.tscn`); os dados, em `game/data/models/` e `game/data/animations/`.

### Salvamento
- Um arquivo JSON na pasta do usuário, regravado a cada conquista (item, atalho, mural, inimigo morto) e a cada descanso (`02-core-loop.md`).
- Gravação segura: o jogo escreve num arquivo temporário e só no fim o troca pelo antigo, para não corromper o jogo salvo se o computador desligar no meio. Na troca, o arquivo antigo vira uma cópia de segurança, que o jogo lê se o principal estiver estragado.
- Tudo o que é salvo (mob, baú, atalho, mural, pergaminho, melhoria) tem um identificador único no mapa.
- O arquivo guarda: último santuário, itens, onde cada item está (a barra fixa, o espaço da mão, a mochila e a armadura vestida), elementos aprendidos e equipados, melhorias, objetos abertos, inimigos mortos, murais vistos, tempo de jogo e mortes (para o resumo do fim).
- O formato tem versão. Um jogo salvo de uma versão anterior é convertido ao abrir: a versão 3 trocou o equipamento (arma de perto, de longe e armadura) pela barra, pela mochila e pela armadura vestida; as armas equipadas abrem a barra, e os outros itens vão para os primeiros lugares livres. A versão 4 troca o facão pela espada e tira os itens que saíram do jogo (Picareta, Tacape, Lâmina de pedra verde, Zarabatana e Azagaia) da lista, da barra, da mochila e do que estava equipado; ela roda antes da 3, para as armas equipadas de um jogo bem antigo já entrarem com o nome novo. A versão 5 deixa duas armaduras: o Colete vira o Manto (sem repetir um Manto que já existia), a Armadura de minerador sai, e o baú da Mina, que agora guarda o Manto, muda de identificador.
- As opções do menu ficam num arquivo à parte, que não é apagado por "Novo jogo".

### Sistemas globais
Autoloads do Godot:

| Sistema | Função |
|---------|--------|
| `GameState` | progresso, ponto de retorno (o último santuário, ou o começo antes dele), os lugares dos itens (barra fixa, item da mão, mochila e armadura, com as regras em `ItemPlaces`) e troca de área |
| `SaveSystem` | grava e lê o JSON, com gravação segura |
| `Events` | canal de sinais (ex.: inimigo morreu, item achado, atalho aberto); o salvamento ouve esses sinais |
| `Balance` | carrega os arquivos de dados com os números do `11-balanceamento.md` |
| `InputManager` | último dispositivo usado (para os ícones de botão e para a mira seguir o cursor ou o analógico) e botões trocados |
| `AudioManager` | música por área, sons de ambiente e mixagem com os avisos acima da música |

### Combate
- Toda colisão de combate é calculada por código no plano do chão (`03-regras.md`). Cada entidade recebe golpes num círculo, e as áreas de golpe são círculo, setor, retângulo ou projétil. Um golpe só acerta quem está até a altura-limite de quem bateu (`height_reach`, em `data/balance/combat.tres`); nos tiros, conta o pé de quem atirou.
- Nate e os mobs são `CharacterBody3D` com cápsula e gravidade (`data/balance/world.tres`): ficam presos ao chão e sobem rampas, sem pulo nem queda.
- A marca de aviso é desenhada a partir da mesma forma do golpe: o que se vê é o que acerta.
- Componentes reutilizáveis, como nós filhos: vida, efeitos de status, recuo e área de golpe.
- A fórmula de dano fica numa função só, coberta por teste automático.
- Cada golpe é um recurso com a forma da área, os três tempos, o dano, o recuo e o tipo de aviso. Os golpes de Nate saem da arma: o tempo de cada golpe se divide em preparação, tempo ativo e recuperação pela regra do `11-balanceamento.md`.
- O projétil sai do centro de Nate, na altura da mão, e voa na linha da mira.
- Camadas de física: 1 o mundo, 2 Nate e 3 os mobs. Nate e os mobs se encostam sem se ferir, e os dois esbarram também nas barreiras da camada 4.
- Efeitos de status num componente (`StatusEffects`), com os sinais na tela (`StatusVisuals`); os números ficam em `data/balance/status.tres`.
- Magias: cada elemento (`ElementData`) tem uma magia (`SpellData`), e a tabela de combinações (`ComboTable`) dá a magia dos dois juntos. O componente `SpellCaster` de Nate lança e conta as recargas; as áreas que ficam no chão são `SpellArea`, e os efeitos visuais, `SpellEffects`.
- Os itens dividem a base `ItemData` (nome, ícone, raridade e modelo): armas de perto, de longe, armaduras e a poção de vida (`PotionData`). Os efeitos próprios ficam nos dados de cada categoria: o crítico a mais da lança, a flecha que atravessa, e a vida, a velocidade e a recarga do dash de cada armadura.
- Nate usa o item da mão: atacar (`attack`, o botão esquerdo) chama o combo da arma de perto, e usar segurando (`use_hold`, o botão direito ou o gatilho) puxa e solta o tiro ou bebe a poção, que só gasta a carga no fim e para sem gastar se o botão for solto; o aperto de atacar no dash, ou até `dash_strike_window` antes dele, guarda o golpe do dash, que sai no fim (`MeleeCombo.dash_strike`); `hotbar_1` a `hotbar_5`, `hotbar_next` e `hotbar_previous` trocam o espaço da barra. A vida de Nate e o dano contra ele são em pontos; a vida volta só fora de combate (`Mob.is_engaged`).
- Um mob pode ter um segundo golpe, alternado com o primeiro a cada vez na fila (o Golem); todo golpe pode aplicar um efeito de status.
- Magias em volta de Nate (`AROUND`) seguem Nate e empurram quem entra; a Rajada Veloz deixa Nate mais rápido e o Escudo de Areia segura o próximo golpe.
- Os scripts ficam em `game/combat/`; os mobs, em `game/mobs/`, com uma cena base e uma cena por tipo, que troca os dados. O Necromante troca também o script, filho da base `Mob`, para recuar e invocar.

### Áreas e objetos
- Cada área é uma cena em `game/world/areas/`, com o script `AreaLevel`, que põe Nate no último ponto de retorno ao abrir.
- Objetos do cenário em `game/world/objects/` (baú, alavanca, portão, item no chão, elevador, lampião) e armadilhas em `game/world/traps/`. Cada um tem um identificador único no mapa e grava o próprio estado no `SaveSystem`.
- A arena (`Arena`) fecha os portões quando Nate entra, solta as ondas dos arquivos de `game/data/arenas/` e reinicia se Nate morre no meio.
- A luz muda por zona (`LightingZone`): embaixo da terra o sol some e a luz vem dos lampiões.
- Paredes rachadas (`CrackedWall`), no grupo `breakables`: os golpes, as explosões e os tiros de Nate as quebram depois da Terra.
- Lanças do chão (`FloorSpears`), ponte de alavanca (`LeverBridge`), portão de várias alavancas, murais (`Mural`, com o mural grande em `MuralView` e a galeria `MuralGallery`, aberta pela ação `murals`; o sinal `Events.mural_seen` mostra a dica dela) e o altar do Selo (`SealAltar`).
- Áreas escuras (`DarkArea`): um decalque (`Decal`) tira a luz do ambiente do chão, das paredes e das plantas da área pela oclusão (o canal vermelho do ORM), sem mudar a cor deles, com a borda esfumada e ondulada, tirada da máscara de blocos escuros; ele só pega a camada de desenho 1, a do terreno, e os modelos de blocos (`BlockModel.MODEL_LAYER`, a camada 2) não escurecem. Por isso a luz de Nate (a Luz Ancestral, que acende e apaga aos poucos) mostra a cor de verdade do chão em volta dele. Embaixo da terra não há sol (`LightingZone`), e o escuro fica escuro; uma barreira segura Nate na borda até ele ter a Luz.
- Troca de área pelo `GameState`: a tela escurece, a cena carrega e Nate aparece no ponto de chegada (o elevador, um santuário). A saída de uma área é um `AreaExit`; sem a próxima área, ele mostra o fim da parte jogável.
- Santuários com o menu de descanso e viagem; os dados de cada um (nome, área e memória) ficam em `game/data/sanctuaries/`. As memórias são cenas em `game/world/memories/`.
- Camada de física 4: barreiras invisíveis, como a beira de uma vala; seguram quem anda, mas não os tiros nem a visão.
- O `GameState` guarda o ponto de retorno (e a área dele), os lugares dos itens, os elementos e as melhorias; o jogo novo começa com a espada na mão. O jogo salvo também guarda as dicas de controle já usadas, os santuários visitados e o tempo de jogo.
- O identificador de uma melhoria no mapa começa com o tipo dela (`heart_` ou `charge_`).
- Menus em `game/ui/`: o principal é a entrada do jogo (`main.tscn`), a pausa abre no Esc, o inventário no Tab e a galeria dos murais no G. Quem para o jogo (inventário, santuário, pergaminho, memória) cuida dos próprios botões enquanto está aberto.
- A barra fixa do HUD (`Hotbar`) é uma camada própria e some com o inventário aberto: ele tem a barra dele, com os mesmos espaços (`Hotbar.show_slots`), e os itens se arrastam entre ela, a mochila e a armadura (`ItemCell` e `ItemMoves`). Os detalhes do item ficam numa caixinha ao lado do espaço apontado, e Nate aparece num mundo 3D só dele (`NatePreview`, um `SubViewport` do tamanho em pixels que ele ocupa na tela). Ordem das camadas: HUD 1, inventário 3, barra fixa 4, fim da parte jogável 5, santuário, pergaminho e galeria dos murais 9, pausa 10, mural 12, memórias 30.
- A interface é desenhada para 1152 × 648 px e ampliada com a janela (`display/window/stretch/mode` em `canvas_items`, com `aspect` em `expand` e `scale` em 0,75). O 3D continua com os pixels da janela; as memórias e o boneco do inventário, que são `SubViewport`, também (`MemoryScene` e `NatePreview` acertam o tamanho deles pela escala da janela).
- O rastro do golpe é uma malha de meia-lua (`AreaMesh.crescent`) com o shader `world/effects/slash.gdshader`, que varre o arco e some por dois números (`progress` e `fade`) e é desenhado por cima de tudo.
- O visual de cada magia é um `SpellLook` (`data/effects/spells/`, gerado por `tools/effects/make_spell_looks.gd`), feito de camadas de partículas (`ParticleLayer`, que monta as `CPUParticles3D`): a aura ao lançar, o rastro do projétil, o impacto e a área que dura; mais a luz, a marca no chão (com a forma da área, pelo `AreaMesh`), o tremor da tela (`Events.screen_shake`, na `FollowCamera`, pelo `h_offset` e o `v_offset`) e a pausa curta no acerto (`HitStop`, que baixa o `Engine.time_scale` por um instante de tempo de verdade). O `SpellEffects` monta cada efeito, e o `EffectHolder` o toca no mundo: começa cada camada na hora dela, gira os redemoinhos, segue o projétil ou Nate, corre a faixa da Onda Cortante e do Magma, apaga a luz e sai quando os últimos cubinhos somem. Os esporos do Bosque usam as mesmas camadas (`data/effects/forest_spores.tres`).

### Inteligência dos mobs
- Máquina de estados simples: parado, perseguir, atacar e voltar.
- Para perseguir e voltar, os mobs seguem o mapa de navegação da área (`NavigationAgent3D` em cada mob; um `NavigationRegion3D` em cada área, com o mapa assado do terreno em `world/areas/*_navigation.res`): sobem e descem pelas escadas e rampas e contornam as paredes. Antes de o mapa ficar pronto, vão em linha reta.
- Uma fila global garante que no máximo 5 mobs preparem ataque ao mesmo tempo (`06-mobs/README.md`).

### Dados
- Os dados do jogo (números, modelos, animações e ondas das arenas) são recursos do Godot: tipados e editáveis no inspetor.
- Só o jogo salvo usa JSON, por segurança.
- Os números do `11-balanceamento.md` ficam nesses arquivos de dados, um por categoria (armas, magias, mobs, Boiúna etc.). Mudar um número não exige mexer no código.

### Som
- O `AudioManager` toca os sons pelo nome, do banco `data/audio/sounds.tres` (`SoundBank`): cada som (`SoundData`) tem uma ou mais gravações, uma sorteada a cada vez, o volume, o tom e quanto ele varia, e o canal. Os números da mixagem e as músicas gerais (menu, arenas e memórias) ficam em `data/audio/audio_rules.tres` (`AudioRules`); os tipos ficam em `game/audio/`.
- Canais em `default_bus_layout.tres`: Music, Ambience, Effects e Warnings. Um compressor no canal da música, ligado ao dos avisos, abaixa a música enquanto um aviso de golpe toca.
- Os sons do mundo saem de um ponto e quem ouve fica em Nate, virado como a câmera; os da interface tocam na tela. Os botões dos menus tocam sozinhos ao trocar de foco e ao serem apertados.
- Os dados dizem o som de cada coisa: o aviso e o golpe de cada ataque (`AttackData`), a ferida e a morte de cada mob (`MobData`) e o de cada magia (`SpellData`). Cada área (`AreaLevel`) diz a sua música e o som de fundo; a zona de luz da Mina troca o som de fundo ao entrar embaixo da terra; a arena e a memória põem a música delas por cima da da área e tiram no fim.

### Câmera e luz
- Câmera ortográfica, com ângulo isométrico: 45° de inclinação e 45° de giro. O enquadramento é de 14 blocos de altura de tela, provisório até o rascunho do mapa. Os números ficam em `11-balanceamento.md`.
- Fungos e padrões marajoara brilham pelo próprio material, com poucas luzes reais. A Luz Ancestral é uma luz presa em Nate.

### Interface
- Todo texto que aparece na tela passa pela tabela de tradução, só com português do Brasil por enquanto (`09-interface.md`).
- As imagens do mapa são geradas do próprio mapa: uma câmera de cima fotografa cada área, e o jogo desenha os ícones por cima. Toda mudança no mapa atualiza a imagem.

## Estrutura de pastas
O projeto do Godot fica em `game/`, ao lado de `docs/`, no mesmo repositório:

```
nate-undue-redemption/
├── CLAUDE.md
├── docs/
└── game/
```

Dentro de `game/`, as pastas são organizadas por assunto: cada parte do jogo junta as próprias cenas e scripts.

```
game/
├── project.godot
├── addons/        gdUnit4, a ferramenta de testes
├── assets/        texturas, sons, música e fontes
├── data/          números, modelos, animações e ondas
├── autoload/      sistemas globais
├── combat/        golpes, vida, efeitos e recuo
├── player/        Nate
├── mobs/          lobo, esqueleto, necromante e golem
├── boss/          Boiúna
├── world/         áreas, armadilhas e objetos
├── ui/            HUD, inventário, menus e mapa
├── audio/         tipos do banco de sons e das regras da mixagem
├── tools/         montador e prévia dos modelos, geradores das áreas (tools/areas/) e das imagens do mapa
├── localization/  tabela de textos
└── tests/         testes de regras e de salvamento
```

## Convenções de código
- Estilo oficial do GDScript: `snake_case` para arquivos, funções e variáveis; `PascalCase` para classes; `CONSTANT_CASE` para constantes.
- Tipos sempre declarados (ex.: `func take_damage(amount: int) -> void`).
- Nomes em inglês; comentários em português, curtos, explicando o porquê.
- Uma cena por entidade, com o comportamento comum em componentes (nós filhos). Herança de no máximo um nível, como a classe base `Mob`.
- Os sistemas conversam por sinais, nunca por caminhos longos de nós.
- Nenhum número fixo no código: os números vêm dos arquivos de dados.
- Todo texto que aparece na tela passa pela tabela de tradução.
- Tudo o que é salvo tem um identificador único no mapa.
- Commits em português, no formato `tipo: descrição`, como no histórico do repositório.

## Processo
- **Versão do Godot:** a estável mais recente no começo da produção, fixada até o fim.
- **Testes automáticos:** para as regras de combate (fórmula de dano, efeitos de status, recuo) e para o salvamento, com o gdUnit4 6.2.2, fixado junto com o Godot. O resto é testado jogando.
  - Os testes ficam em `game/tests/`. No editor, rodam pelo painel GdUnit; no terminal, a partir da raiz do repositório:
    `godot --headless --path game -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
  - O gdUnit4, os testes e os geradores das áreas (`tools/areas/`) ficam fora das exportações do jogo.
- **Git:** os arquivos gerados pelo Godot (`.godot/`), os relatórios dos testes (`reports/`) e as exportações ficam fora do git. Sem Git LFS no começo: texturas pequenas (até 32 px) e sons cabem no git normal; a música provisória soma cerca de 26 MB. Se a música definitiva pesar muito mais, vale passar o áudio para o Git LFS.
- **Assets prontos:** entram como provisórios no começo da produção e são registrados com origem e licença no `10-arte-audio.md`. Os créditos do jogo listam os que pedem crédito.
- **Ordem:** o montador de modelos e a prévia vêm antes dos primeiros modelos.
