# Mapa

Agartha é um mapa único e contínuo, sem andares. O caminho principal segue sempre em frente, e voltar a áreas já visitadas é opcional (`02-core-loop.md`). As medidas de cada área e da arena da Boiúna, em blocos, ficam para o rascunho do mapa no motor, depois da documentação.

## Visão geral
Prólogo (superfície) → Mina → elevador → Bosque de Fungos → passagem escura → Ruínas → antessala → Grande Prisão

| Trecho | Tempo-alvo | Santuário | Mobs por encontro | Variantes | Armadilha | Cura |
|--------|-----------|-----------|-------------------|-----------|-----------|------|
| Prólogo | cerca de 1 min | — (volta ao início do prólogo) | 1 Lobo | não | — | não |
| Mina | cerca de 4 min | — (volta à entrada da Mina) | 1 a 3 | não | pedras que caem | não |
| Bosque de Fungos | 9 min | S1 e S2 | 2 a 4 | não | cogumelos de esporos | frasco |
| Ruínas | 11 min | S3 | 3 a 5 | sim | lanças do chão | frasco |
| Grande Prisão | 5 min | S4 | a Boiúna | — | — | frasco |

Arenas opcionais têm ondas maiores, com variantes.

## Rascunho no motor
O prólogo e a Mina já têm um rascunho jogável, em `game/world/areas/mine.tscn` (etapa 4 do `13-plano-de-producao.md`). As medidas são propostas, para conferir jogando.

| Trecho | Medidas | O que tem |
|---------|---------|-----------|
| Clareira do prólogo | 32 × 26 blocos de grama, cercada de mata, com o paredão de pedra e a boca velha da mina ao norte e dois morrinhos de 1 bloco, com degraus | o começo, o lobo e a fenda de 2 blocos de largura até a Mina |
| Saguão da entrada da Mina | 13 × 11 blocos | o ponto de retorno da Mina |
| Sala do Estilingue | 17 × 12 blocos, cortada por uma vala de 2 blocos; do outro lado, uma beirada de 5 blocos com a alavanca | o Estilingue no chão e o portão que a alavanca abre |
| Corredor do portão | 15 × 4 blocos | 1 Esqueleto |
| Corredor das pedras | 4 × 28 blocos, subindo para o norte | 2 pedras que caem, 1 Lobo e 1 Esqueleto |
| Sala do baú | 16 × 10 blocos | o baú com o Colete de minerador, 2 Lobos e a parede rachada da Armadura de minerador |
| Desvio da Picareta | corredor de 10 × 2 blocos até uma sala de 5 × 8 | a Picareta |
| Túnel do mural 1 | 4 × 10 blocos, com paredes de pedra do povo antigo | o lugar do mural 1 |
| Arena da Mina | 18 × 16 blocos, com portão na entrada e na saída | as 2 ondas do `11-balanceamento.md` |
| Sala do elevador | 12 × 8 blocos | o elevador, que desce até o Bosque de Fungos |

O caminho principal tem cerca de 135 blocos andando, sem contar as lutas. O canto escuro do +1 coração fica a leste do saguão da entrada: um corredor de 6 × 2 blocos até uma sala de 5 × 8, escura. A parede rachada da Armadura de minerador e a arena opcional ainda esperam a Terra (etapa 6).

O Bosque de Fungos tem um rascunho jogável em `game/world/areas/forest.tscn` (etapa 5). As medidas também são propostas, para conferir jogando.

| Trecho | Medidas | O que tem |
|---------|---------|-----------|
| Chegada do elevador | 16 × 12 blocos de musgo | o elevador quebrado, o S1 e a porta que só abre por um lado, na parede leste |
| Corredor norte | 6 × 10 blocos | 2 cogumelos de esporos e 2 Lobos |
| Desvio da Zarabatana | passagem de 3 × 2 blocos até uma sala de 5 × 8 | a Zarabatana marajoara, 1 Lobo e 1 Esqueleto |
| Sala do baú | 18 × 14 blocos | o baú com a Lança marajoara, o primeiro Necromante e 1 Esqueleto; na parede oeste, a parede rachada do +1 coração (volta com Terra) |
| Arena 1 | 18 × 16 blocos, com portão na entrada e na saída | as 2 ondas do `11-balanceamento.md` |
| Sala do pergaminho de Fogo | 8 × 8 blocos | o pergaminho de Fogo; a oeste, o canto escuro da Azagaia (corredor de 6 × 2 e sala de 4 × 6) |
| Corredor do mural 2 | 24 × 4 blocos | o lugar do mural 2 na parede norte e 2 Esqueletos |
| Caverna dos dinossauros | 24 × 27 blocos, com cogumelos gigantes | 2 dinossauros, 2 Lobos e 1 Necromante; o desvio do Manto, num terraço 1 bloco mais alto, com escada, cercado de cogumelos de esporos; uma fresta de 1 bloco até o mural 3 escondido |
| Arena opcional | corredor escuro de 7 × 2 blocos, arena de 18 × 16 e uma sala de 5 × 6 | as 2 ondas do `11-balanceamento.md` e o pergaminho de Água |
| Sala do meio | 16 × 12 blocos | 2 Esqueletos e 1 Lobo; a leste, o desvio do +1 coração (2 Lobos); a oeste, o corredor do atalho até a porta do S1 (cerca de 40 blocos) |
| S2 | 16 × 10 blocos | o S2 |
| Arena 2 | 18 × 16 blocos, com portão na entrada e na saída | as 3 ondas do `11-balanceamento.md` |
| Passagem escura | 18 × 4 blocos | exige a Luz Ancestral; no fim, a parte jogável termina até as Ruínas existirem |

O caminho principal do Bosque tem cerca de 190 blocos andando, sem contar as lutas. A passagem escura leva às Ruínas.

Na Mina, a sala do baú tem a parede rachada da Armadura de minerador (sala de 6 × 6 blocos), e o túnel do mural 1 tem a parede rachada da arena opcional: corredor de 11 × 2 blocos, arena de 18 × 16 e uma sala de 6 × 6 com o +1 carga.

As Ruínas têm um rascunho jogável em `game/world/areas/ruins.tscn` (etapa 6). As medidas também são propostas, para conferir jogando.

| Trecho | Medidas | O que tem |
|---------|---------|-----------|
| Salão da chegada | 14 × 12 blocos | o baú do Tacape marajoara, 2 Esqueletos e 1 Lobo |
| Corredor das lanças | 6 × 14 blocos, subindo para o norte | 3 fileiras de lanças do chão, 1 Lobo Alfa e o nicho do +1 carga |
| Salão do S3 | 18 × 16 blocos | o S3; a leste, o vão de 4 blocos que a ponte cobre |
| Arena 1 | 18 × 16 blocos, com portão na entrada e na saída | as 2 ondas do `11-balanceamento.md` |
| Sala do pergaminho de Terra | 8 × 8 blocos | o pergaminho de Terra; a oeste, o nicho do +1 coração; a leste, a parede rachada do caminho principal |
| Corredor das minas antigas | 34 × 2 blocos e depois 2 × 22, para o sul | 2 Esqueletos Veteranos, 1 Necromante, 1 Golem e lanças do chão; a leste, a galeria das 3 alavancas do Arco |
| Salão antes da arena 2 | 18 × 14 blocos | a alavanca da ponte, 2 Lobos Alfa, 1 Veterano e 1 Necromante Ancião; a fresta do mural 6 e a parede rachada da Lâmina de pedra verde |
| Arena 2 | 18 × 16 blocos, com portão na entrada e na saída | as 2 ondas do `11-balanceamento.md` |
| Sala do Selo | 12 × 12 blocos | o mural 4, o Selo e o mural 5; a saída para a Grande Prisão |
| Desvio da Couraça | corredor de 16 × 2 blocos com lanças até uma sala de 6 × 8 | a Couraça de cerâmica e a passagem para a arena opcional (18 × 14 blocos), que guarda o pergaminho de Ar |

O caminho principal das Ruínas tem cerca de 150 blocos andando, sem contar as lutas.

### Relevo e bordas
- O chão tem platôs de 1 e 2 blocos, ligados por escadas. Nate e os mobs sobem e descem por elas; nas beiradas sem escada, moitas (na clareira) ou pedras (no Bosque) seguram quem anda: não há quedas. Golpes só acertam quem está mais ou menos na mesma altura (`03-regras.md`).
- **Clareira:** dois morrinhos com degraus. **Mina:** o corredor das pedras sobe 1 bloco para o norte, e tudo dali em diante fica 1 bloco acima. **Bosque:** a chegada do elevador, o S2, a arena 2 e a passagem escura ficam embaixo; o resto, 1 bloco acima; o terraço do Manto, 2. **Ruínas:** a chegada, o corredor das lanças e o desvio da Couraça ficam embaixo; uma escadaria sobe ao salão do S3; a arena 2, a sala do Selo e a saída ficam mais 1 bloco acima.
- No lugar das paredes retas, bordas naturais, como no Minecraft Dungeons. Na frente da câmera (sul e leste do chão), a parede é baixa e cai como barranco no escuro, para não esconder Nate; atrás (norte e oeste), ela sobe alta e irregular, com morros de pedra subindo depois dela. Na clareira, a borda é de mata: árvores altas atrás, moitas baixas na frente.
- As paredes baixas seguram os tiros e a visão dos mobs como as outras, com blocos invisíveis por cima. Em volta das áreas escuras e atrás dos murais, a parede da frente é um pouco mais alta. Números: `11-balanceamento.md`.

## Trecho a trecho

### Prólogo: borda da mina
- Clareira na floresta, na entrada da velha mina da família, onde o tremor abriu a fenda.
- Um Lobo ataca Nate, e a luta ensina a andar, o combo e a esquiva (`04-player.md`). Quando a vida do Lobo baixa até um limite, ele foge mancando pela fenda, e Nate o segue (`06-mobs/lobo.md`).
- Ponto de retorno: início do prólogo.

### Mina
- Galerias da velha mina: vigas de madeira, trilhos e ferramentas abandonadas.
- Ponto de retorno: entrada da Mina. Não há santuário nem cura, então as lutas são leves.
- Caminho principal, em ordem:
  1. O Estilingue e, logo depois, uma alavanca distante que só o tiro alcança: ela abre um portão e ensina o tiro.
  2. Baú com o Colete de minerador.
  3. Mural 1, onde a mina da família encontra os túneis do povo antigo.
  4. Arena da Mina.
  5. Elevador velho da mina: desce para Agartha, quebra no caminho e deixa Nate no Bosque.
- **Segredos:** Picareta (desvio); +1 coração (canto escuro, volta com a Luz Ancestral); Armadura de minerador (parede rachada, volta com Terra).
- **Arena opcional:** atrás de uma parede rachada (volta com Terra); guarda +1 carga.

### Bosque de Fungos
- Cogumelos gigantes bioluminescentes e dinossauros herbívoros, que vivem ali sem lutar (`06-mobs/README.md`).
- Caminho principal, em ordem:
  1. S1, na chegada do elevador: Nate ganha o frasco, vê a memória 1 e conserta o elevador, que vira atalho para a Mina.
  2. Baú com a Lança marajoara.
  3. Arena 1, que guarda o pergaminho de Fogo. Ao ler o pergaminho, o muiraquitã acorda: Luz Ancestral e Bola de Fogo.
  4. Mural 2.
  5. S2.
  6. Arena 2, que guarda a passagem escura.
  7. Passagem escura até as Ruínas, que exige a Luz Ancestral.
- **Atalho:** porta que só abre por um lado, do meio do Bosque de volta ao S1.
- **Segredos:** Zarabatana marajoara (desvio); Manto de fibras marajoara (desvio cercado de cogumelos); +1 coração (desvio); Azagaia marajoara (canto escuro); +1 coração (parede rachada, volta com Terra); mural 3 (escondido).
- **Arena opcional:** atrás de um canto escuro; guarda o pergaminho de Água.

### Ruínas
- A cidade e as minas antigas do povo antigo, com murais e mecanismos.
- Caminho principal, em ordem:
  1. Tacape marajoara.
  2. S3.
  3. Arena 1, que guarda o pergaminho de Terra.
  4. Parede rachada, que exige Terra.
  5. Arena 2, que guarda a sala do Selo.
  6. Sala do Selo: o mural 4, a lasca do muiraquitã e o mural 5, que mostra a traição.
- **Atalho:** ponte baixada por alavanca, do trecho antes da arena 2 até o S3.
- **Segredos:** Arco marajoara (alavancas); Couraça de cerâmica marajoara (desvio com lanças); Lâmina de pedra verde (parede rachada); +1 coração; +1 carga; mural 6 (escondido: o rosto do irmão).
- **Arena opcional:** escondida; guarda o pergaminho de Ar.

### Grande Prisão
- **Antessala:** S4, com a memória 4, e o mural 7.
- **Porta da Grande Prisão:** abre com o muiraquitã inteiro (`05-itens.md`).
- **Arena da Boiúna:** cabe inteira na câmera normal do jogo, com o fosso no centro e um pilar de cada lado (`07-chefes/boiuna.md`).

## Santuários
| Santuário | Onde | Memória |
|-----------|------|---------|
| S1 | Bosque, na chegada do elevador | memória 1 |
| S2 | Bosque, antes da arena da passagem escura | memória 2 |
| S3 | Ruínas, no meio | memória 3 |
| S4 | antessala da Grande Prisão | memória 4: a traição do irmão e onde a prisão falhou (`01-historia.md`) |

- Viagem rápida entre os 4 santuários (`02-core-loop.md`).
- Conteúdo das memórias: `10-arte-audio.md`.

## Murais
| Mural | Onde | Tipo | Conteúdo |
|-------|------|------|----------|
| 1 | Mina, onde a mina da família encontra os túneis do povo antigo | caminho | o povo antigo vivendo em Agartha |
| 2 | Bosque | caminho | o predador surgindo das profundezas e o povo fugindo |
| 3 | Bosque | escondido | o povo construindo os santuários e a Grande Prisão |
| 4 | Ruínas, sala do Selo | caminho | os dois irmãos: o herói recebe o muiraquitã, e o irmão olha com inveja |
| 5 | Ruínas, sala do Selo | caminho | a traição: o irmão tira a lasca do muiraquitã e a esconde |
| 6 | Ruínas | escondido | o rosto do irmão |
| 7 | antessala da Grande Prisão | caminho | a prisão ativada pela metade: o predador adormece em vez de ficar preso |

## Arenas e ondas
A passagem fecha até o jogador vencer as ondas (`02-core-loop.md`). Quantos mobs há em cada onda: `11-balanceamento.md`.

| Arena | Guarda | Ondas |
|-------|--------|-------|
| Mina | a descida pelo elevador | 1) Lobos; 2) Esqueletos e Lobos |
| Bosque 1 | pergaminho de Fogo | 1) Esqueletos; 2) Necromante com Lobos |
| Bosque 2 | passagem escura | 1) Lobos; 2) Esqueletos e Necromante; 3) Necromante com Lobos |
| Ruínas 1 | pergaminho de Terra | 1) Esqueletos e Necromante; 2) Golem de Pedra |
| Ruínas 2 | sala do Selo | 1) Golem e Esqueletos Veteranos; 2) Necromante Ancião com Lobos Alfa |
| Opcional da Mina | +1 carga | variantes, em ondas maiores |
| Opcional do Bosque | pergaminho de Água | variantes, em ondas maiores |
| Opcional das Ruínas | pergaminho de Ar | variantes, em ondas maiores |

## Onde ficam os itens
| Item | Área | Onde | Exige |
|------|------|------|-------|
| Facão | Prólogo | inicial | — |
| Estilingue | Mina | caminho | — |
| Colete de minerador | Mina | caminho (baú) | — |
| Picareta | Mina | segredo (desvio) | — |
| +1 coração | Mina | segredo (canto escuro) | Luz Ancestral (volta) |
| Armadura de minerador | Mina | segredo (parede rachada) | Terra (volta) |
| +1 carga | Mina | arena opcional | Terra (volta) |
| Lança marajoara | Bosque | caminho (baú) | — |
| Pergaminho de Fogo | Bosque | arena 1 | — |
| Zarabatana marajoara | Bosque | segredo (desvio) | — |
| Manto de fibras marajoara | Bosque | segredo (desvio cercado de cogumelos) | — |
| +1 coração | Bosque | segredo (desvio) | — |
| Azagaia marajoara | Bosque | segredo (canto escuro) | Luz Ancestral |
| +1 coração | Bosque | segredo (parede rachada) | Terra (volta) |
| Pergaminho de Água | Bosque | arena opcional (atrás de canto escuro) | Luz Ancestral |
| Tacape marajoara | Ruínas | caminho | — |
| Pergaminho de Terra | Ruínas | arena 1 | — |
| O Selo | Ruínas | caminho (sala do Selo) | Terra |
| Arco marajoara | Ruínas | segredo (alavancas) | — |
| Couraça de cerâmica marajoara | Ruínas | segredo (desvio com lanças) | — |
| Lâmina de pedra verde | Ruínas | segredo (parede rachada) | Terra |
| +1 coração | Ruínas | segredo | — |
| +1 carga | Ruínas | segredo | — |
| Pergaminho de Ar | Ruínas | arena opcional (escondida) | — |

Ao todo: 12 peças de equipamento no mapa, além do facão inicial; 6 melhorias; 4 pergaminhos; e o Selo.

## Atalhos
| Atalho | Liga | Abre quando |
|--------|------|-------------|
| Elevador da mina | S1 e a Mina | Nate conserta o elevador, perto do S1 |
| Porta que só abre por um lado | meio do Bosque e S1 | Nate passa por ela do lado de dentro |
| Ponte de alavanca | trecho antes da arena 2 das Ruínas e S3 | Nate puxa a alavanca |

Além dos atalhos, há viagem rápida entre os santuários.

## Armadilhas
As três ferem Nate e os mobs (`03-regras.md`). Os mobs contornam as armadilhas andando e caem nelas quando empurrados (`06-mobs/README.md`).

### Pedras que caem
**Papel no jogo:** o perigo da Mina. Pune quem passa distraído e serve para derrubar mobs.
**Descrição visual:** pedras soltas no teto da galeria, com rachaduras visíveis. Tamanho: 1 bloco.

#### Atributos
| Atributo | Valor |
|----------|-------|
| Dano | 1 coração em Nate; em mobs: `11-balanceamento.md` |
| Área | círculo no chão; raio: `11-balanceamento.md` |
| Aviso | marca no chão, 1 s |
| Recuo | curto |
| Usos | um: depois de cair, não volta |

#### Comportamento e habilidades
- Quando Nate ou um mob passa por baixo, a marca aparece no chão e, 1 s depois, a pedra cai.

#### Interações
- Fere quem estiver na marca quando a pedra cai, Nate ou mob.

#### Animações necessárias
- Pedra rachando e caindo.

#### Sons necessários
- Rachadura (aviso).
- Impacto.

#### Assets necessários
- Pedras do teto e pedra caída.
- Marca no chão.

### Cogumelo de esporos
**Papel no jogo:** o perigo do Bosque. Atrasa quem passa perto e serve para deixar mobs lentos.
**Descrição visual:** cogumelo bioluminescente que incha antes de estourar. Tamanho: 1,5 bloco de altura.

#### Atributos
| Atributo | Valor |
|----------|-------|
| Dano | nenhum |
| Área | nuvem em círculo; raio e duração: `11-balanceamento.md` |
| Efeito | lento |
| Aviso | incha, com marca no chão, 1 s |
| Recarga | volta a crescer depois de alguns segundos: `11-balanceamento.md` |

#### Comportamento e habilidades
- Estoura quando Nate ou um mob passa perto. A nuvem fica alguns segundos e deixa lento quem está dentro.

#### Interações
- A nuvem afeta Nate e os mobs.

#### Animações necessárias
- Inchar, estourar e crescer de novo.

#### Sons necessários
- Inchar (aviso).
- Estouro.

#### Assets necessários
- Modelo do cogumelo.
- Nuvem de esporos.

### Lanças do chão
**Papel no jogo:** o perigo das Ruínas. Dá ritmo aos corredores e serve para ferir mobs empurrados.
**Descrição visual:** placas de pedra no chão, com padrões geométricos marajoara, de onde lanças saem pelas frestas. Tamanho: placas de 1×1 bloco.

#### Atributos
| Atributo | Valor |
|----------|-------|
| Dano | 1 coração em Nate; em mobs: `11-balanceamento.md` |
| Área | as placas do chão |
| Aviso | o chão racha e brilha, 1 s |
| Ciclo | `11-balanceamento.md` |
| Recuo | curto |

#### Comportamento e habilidades
- Funcionam em ciclo fixo: aviso, lanças para fora e lanças recolhidas.

#### Interações
- Ferem quem estiver sobre as placas quando as lanças saem, Nate ou mob.

#### Animações necessárias
- Chão rachando e brilhando.
- Lanças subindo e descendo.

#### Sons necessários
- Aviso.
- Lanças saindo.

#### Assets necessários
- Placas do chão.
- Lanças.

## Objetos do cenário
**Papel no jogo:** os pontos de interação do mapa: descanso, recompensas, atalhos e caminhos que pedem um poder.
**Descrição visual:** na Mina, madeira e metal gastos; em Agartha, pedra e cerâmica com padrões geométricos marajoara. Cores: a paleta de cada área (`10-arte-audio.md`).

### Atributos
| Objeto | O que faz | Animações | Sons |
|--------|-----------|-----------|------|
| Santuário | interagir: descansar (cura, recarrega o frasco, salva e dá viagem rápida); na primeira visita, memória | acender na primeira visita | ativar; descansar |
| Baú | interagir: abre, e o item vai para o inventário | abrir | abrir; achar item |
| Alavanca | interagir de perto ou acertar com tiro de longe: abre um portão ou baixa uma ponte | mudar de posição | alavanca |
| Portão | abre com a alavanca | abrir | abrir |
| Ponte de alavanca | baixa com a alavanca; deitada sobre o vão, vira chão firme, e só então dá para atravessar | baixar | ponte |
| Porta que só abre por um lado | atalho: abre só pelo lado de dentro | abrir | abrir |
| Elevador da mina | desce e quebra na chegada ao Bosque; consertado, liga S1 e a Mina | descer, quebrar, subir | elevador; quebra |
| Parede rachada | quebra com qualquer golpe quando Nate já aprendeu Terra; sem Terra, responde com som de pedra firme | quebrar | quebrar; pedra firme |
| Área escura | sem a Luz Ancestral, Nate para na borda; com ela, o brilho ilumina o caminho | — | — |
| Mural | conta a história sem texto; interagir mostra o mural grande na tela, e depois ele fica na galeria (`09-interface.md`) | — | — |
| Pilar da prisão e porta da Grande Prisão | ver `07-chefes/boiuna.md` | — | — |

### Comportamento e habilidades
- Cada objeto funciona como a tabela descreve; o estado de cada um (aberto, consertado, quebrado) é salvo na hora (`02-core-loop.md`).

### Interações
- Com Nate, por interagir, tiro (alavancas) ou golpe (paredes rachadas).

### Animações necessárias
- As da tabela.

### Sons necessários
- Os da tabela.

### Assets necessários
- Um modelo para cada objeto, com os estados da tabela.
- Iluminação das áreas escuras.
