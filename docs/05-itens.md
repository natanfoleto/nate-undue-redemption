# Itens

Sistema de itens e as fichas de equipamento, muiraquitã e magias, poção de vida e melhorias. Os números exatos (dano, tempos, recargas e áreas) ficam em `11-balanceamento.md`.

## Sistema

### Lugares dos itens
| Lugar | Espaços | O que guarda |
|-------|---------|--------------|
| Barra fixa | 5 | os itens de mão: armas de perto, armas de longe e a poção de vida. O espaço escolhido é o item na mão de Nate, que o botão de usar usa (`04-player.md`) |
| Mochila | 15 | tudo o que não está na barra nem vestido |
| Armadura | 1 | a armadura vestida: vida extra e, às vezes, um bônus; não reduz dano (`03-regras.md`) |
| Elemento | 2 | uma magia em cada botão; os dois juntos lançam a combinação (`04-player.md`) |

- Na barra, só itens de mão; a armadura nunca entra nela.
- Cada item fica num lugar só. Os 5 da barra mais os 15 da mochila e a armadura cabem todos os itens do jogo.

### Raridade
| Raridade | Origem | O que tem |
|----------|--------|-----------|
| Comum | objetos de Nate, da superfície e da velha mina | só atributos |
| Marajoara | feitos pelo povo antigo e achados em Agartha | atributos e um efeito especial |

- A raridade conta a história: o antigo é mais poderoso.
- Itens marajoara têm padrões geométricos marajoara. De longe, o item marajoara tem brilho e moldura verde-jade; o comum, moldura cinza, sem brilho (`10-arte-audio.md`).
- Itens comuns precisam de perfis bem diferentes entre si, para não parecerem sem graça.

### Inventário e troca
- Nate guarda tudo o que acha. Uma arma, ou a poção, vai para o primeiro espaço vazio da barra (a arma já vai para a mão); com a barra cheia, para a mochila. A armadura é vestida se Nate estiver sem nenhuma; senão, vai para a mochila.
- No inventário, com o jogo pausado, os itens trocam de lugar à vontade: entre a barra, a mochila e a armadura. Os elementos, entre os aprendidos e os 2 espaços.
- Tela do inventário: `09-interface.md`.

### Visual
- A arma aparece na mão de Nate e a armadura no corpo.
- Cada armadura é um conjunto de blocos e cores sobre o modelo base de Nate, definido por código.

### Onde os itens ficam
- Cada item tem um lugar fixo no mapa: baús, segredos e arenas (`02-core-loop.md`). Não há tabelas de sorteio. A área de cada peça está nas fichas; o lugar exato fica em `08-mapa.md`.
- Os mobs não deixam nada ao morrer. O prêmio de uma luta é o caminho livre, e por isso a derrota do mob precisa de um efeito satisfatório (`10-arte-audio.md`).
- Itens não curam: a vida volta sozinha fora de combate, e no combate só a poção de vida cura (`04-player.md`).
- Achar um item mostra um feixe de luz sobre ele; ao pegar, partículas e um som de recompensa (`10-arte-audio.md`).

### Equipamento inicial
- Nate começa com o facão. A primeira arma à distância, o estilingue, é achada na Mina, onde o tiro é ensinado (`04-player.md`).
- Nenhuma armadura no início.

## Equipamento
13 peças: 5 armas corpo a corpo, 4 armas à distância e 4 armaduras. Dessas, 5 são comuns e 8 são marajoara.

### Armas corpo a corpo
**Papel no jogo:** o ataque principal de Nate. Cada arma muda o ritmo do combo de 3 golpes, e as marajoara somam um efeito.
**Descrição visual:** armas blocadas na mão de Nate. As comuns são ferramentas gastas de metal e madeira; as marajoara, de pedra e madeira com padrões geométricos marajoara. Tamanho: de 0,75 a 1,5 bloco de comprimento (`10-arte-audio.md`).

#### Atributos
Valores exatos: `11-balanceamento.md`.

| Peça | Raridade | Velocidade | Dano | Golpe | Efeito | Área |
|------|----------|------------|------|-------|--------|------|
| Facão | comum | média | médio | médio | — | inicial |
| Picareta | comum | lenta | alto | estreito | — | Mina |
| Lança marajoara | marajoara | média | médio | longo e estreito | mais chance de crítico | Bosque |
| Tacape marajoara | marajoara | lenta | alto | largo | o 3º golpe atordoa | Ruínas |
| Lâmina de pedra verde | marajoara | rápida | baixo | curto | cada acerto reduz a recarga das magias equipadas | Ruínas |

#### Comportamento e habilidades
- Todas seguem o combo de 3 golpes de Nate: 1º e 2º com recuo curto, 3º com mais dano e recuo longo (`04-player.md`).
- Cada arma muda velocidade, dano e tamanho do golpe. A sequência é sempre a mesma.
- **Lança marajoara:** chance de crítico maior que a base de 5% (`03-regras.md`).
- **Tacape marajoara:** o 3º golpe atordoa.
- **Lâmina de pedra verde:** cada acerto reduz a recarga das magias equipadas.

#### Interações
- **Mobs:** recuo e interrupção conforme o golpe (`03-regras.md`).
- **Paredes rachadas:** com a Terra aprendida, qualquer golpe as quebra.
- **Cenário:** paredes bloqueiam golpes.

#### Animações necessárias
- As do combo de Nate (`04-player.md`) servem para todas as armas.
- Rastro do golpe: arco branco curto; nas armas marajoara, verde-jade (`10-arte-audio.md`).

#### Sons necessários
- Golpe cortando o ar e acerto, em três pesos: leve (Lâmina de pedra verde), médio (Facão, Lança marajoara) e pesado (Picareta, Tacape marajoara).
- O atordoar do Tacape usa o som do efeito de status (`03-regras.md`).

#### Assets necessários
- 5 modelos de arma, definidos por código.
- Ícone de cada arma no inventário (`09-interface.md`).

### Armas à distância
**Papel no jogo:** atacar de longe e acertar alvos do cenário, como alavancas distantes. Não usam munição.
**Descrição visual:** armas blocadas na mão de Nate; o projétil de cada uma aparece em voo. As marajoara têm padrões geométricos marajoara.

#### Atributos
Valores exatos: `11-balanceamento.md`.

| Peça | Raridade | Tempo para puxar | Dano | Alcance | Projétil | Efeito | Área |
|------|----------|------------------|------|---------|----------|--------|------|
| Estilingue | comum | curto | baixo | médio | pedra | — | Mina |
| Zarabatana marajoara | marajoara | curto | baixo | médio | dardo | entorpece: deixa lento | Bosque |
| Azagaia marajoara | marajoara | longo | alto | médio | azagaia | recuo longo | Bosque |
| Arco marajoara | marajoara | longo | alto | longo | flecha | atravessa inimigos | Ruínas |

Recuo: Estilingue, curto; Zarabatana, nenhum; Arco, curto.

#### Comportamento e habilidades
- Segurar puxa até a força total; soltar atira; soltar antes cancela (`04-player.md`).
- O dano é menor que o das armas corpo a corpo.
- O projétil para no primeiro inimigo que acerta. A flecha do Arco marajoara é a exceção: atravessa e acerta todos na linha, cada um uma vez.
- **Zarabatana marajoara:** dardos que entorpecem e deixam lento, como os da zarabatana real, que usava curare para paralisar a caça.
- **Azagaia marajoara:** recuo longo, que interrompe mobs pesados de longe.

#### Interações
- **Cenário:** acertam alavancas distantes (`08-mapa.md`). Paredes bloqueiam projéteis.
- **Paredes rachadas:** com a Terra aprendida, o tiro também as quebra.

#### Animações necessárias
- Uma pose de puxar, segurar e soltar para cada tipo: estilingue, zarabatana, azagaia e arco. Enquanto puxa, Nate anda em meia velocidade (`04-player.md`).

#### Sons necessários
- Puxar e soltar, por tipo: elástico, sopro, arremesso e corda.
- Projétil acertando: pedra, dardo, azagaia e flecha.
- Tiro na força total (`04-player.md`).

#### Assets necessários
- 4 modelos de arma e 4 de projétil, definidos por código.
- Ícone de cada arma no inventário.

### Armaduras
**Papel no jogo:** dar vida extra e marcar o estilo, leve ou pesado.
**Descrição visual:** blocos e cores sobre o modelo base de Nate. As comuns são equipamento gasto de minerador; as marajoara, fibras trançadas e placas de cerâmica com padrões geométricos marajoara.

#### Atributos
Valores exatos: `11-balanceamento.md`.

| Peça | Raridade | Peso | Vida | Velocidade | Efeito | Área |
|------|----------|------|------|------------|--------|------|
| Colete de minerador | comum | leve | +20 | normal | — | Mina |
| Armadura de minerador | comum | pesada | +40 | menor | — | Mina |
| Manto de fibras marajoara | marajoara | leve | +20 | normal | dash recarrega mais rápido | Bosque |
| Couraça de cerâmica marajoara | marajoara | pesada | +40 | menor | mais dano | Ruínas |

#### Comportamento e habilidades
- A vida da armadura soma à vida máxima enquanto ela está vestida.
- Ao vestir, a vida extra chega vazia; ao tirar, a vida atual é cortada no novo máximo. Assim, trocar de armadura não cura.
- Armaduras pesadas fazem Nate andar mais devagar.
- **Manto de fibras marajoara:** o dash recarrega mais rápido: 0,35 s em vez de 0,5 s.
- **Couraça de cerâmica marajoara:** mais dano (bônus de dano, `03-regras.md`).

#### Interações
Nenhuma além dos atributos.

#### Animações necessárias
Nenhuma própria: a armadura acompanha as animações de Nate.

#### Sons necessários
Nenhum próprio.

#### Assets necessários
- 4 conjuntos de armadura sobre o modelo de Nate, definidos por código.
- Ícone de cada armadura no inventário.

## O muiraquitã e as magias
- Nate tem um único amuleto, o muiraquitã, desde o naufrágio (`01-historia.md`). Ele acorda no Bosque, quando Nate lê o primeiro pergaminho.
- Cada pergaminho ensina um elemento: Fogo, Água, Terra ou Ar. Cada elemento tem uma magia.
- Nate equipa 2 elementos de cada vez. Q e E lançam a magia de cada um; os dois juntos lançam a combinação dos dois (`04-player.md`).
- A combinação só sai com as duas magias prontas e põe as duas para recarregar.
- Cada magia tem a própria recarga, que continua contando mesmo quando o elemento não está equipado.
- Aprender um elemento já dá o efeito dele fora de combate, equipado ou não. Só a Terra tem esse efeito: os golpes de Nate quebram paredes rachadas.
- Todas as magias, combinações incluídas, usam a mesma pose de Nate (`04-player.md`); o que muda é o efeito.
- São 4 magias de elemento e 6 combinações: 10 magias no total.

### O muiraquitã
**Papel no jogo:** o amuleto do herói antigo, que liga Nate ao povo de Agartha. Dá a Luz Ancestral e, inteiro, fecha a prisão.
**Descrição visual:** amuleto de pedra verde com a forma clássica da muiraquitã, o sapo, e uma lasca faltando. Nate o usa no pescoço desde o prólogo. Cor verde-jade; a Luz Ancestral é um brilho branco-esverdeado (`10-arte-audio.md`).

#### Atributos
| Atributo | Valor |
|----------|-------|
| Raio da Luz Ancestral | `11-balanceamento.md` |

#### Comportamento e habilidades
- **Adormecido:** do prólogo até o primeiro pergaminho, não faz nada.
- **Luz Ancestral:** depois de acordar, o muiraquitã brilha sozinho nas áreas escuras, sem ocupar espaço nem botão. A passagem escura entre o Bosque e as Ruínas exige a Luz Ancestral (`02-core-loop.md`). Na luta final, é ela que revela o predador quando ele some na escuridão (`07-chefes/`).
- **O Selo:** a lasca que falta, escondida pelo irmão traidor no fim das Ruínas, onde a traição é descoberta. Com ela, o muiraquitã fica inteiro: a porta da Grande Prisão abre ao interagir e, na luta final, o amuleto ativa os pilares (`07-chefes/`). O Selo não tem poder de combate.

#### Interações
- Áreas escuras (`08-mapa.md`), porta da Grande Prisão e pilares (`07-chefes/`).

#### Animações necessárias
- O muiraquitã acordando, no primeiro pergaminho.
- Brilho da Luz Ancestral ao redor de Nate nas áreas escuras.
- A lasca se encaixando, quando Nate acha o Selo.

#### Sons necessários
- Muiraquitã acordando.
- Lasca se encaixando.
- Ativação na porta e nos pilares (`07-chefes/boiuna.md`).

#### Assets necessários
- Modelo do muiraquitã no pescoço de Nate, com a lasca faltando e inteiro.
- Modelo do Selo e ícone.
- Efeito do brilho.

### Pergaminhos
**Papel no jogo:** ensinam os elementos. São as recompensas de magia do mapa.
**Descrição visual:** rolo de fibra clara com desenhos marajoara em preto e vermelho. Ao ler, o rolo se abre na tela e mostra o desenho do elemento, sem texto (`10-arte-audio.md`).

#### Atributos
| Pergaminho | Área | Caminho |
|------------|------|---------|
| Fogo | Bosque | principal; é o primeiro e acorda o muiraquitã |
| Água | Bosque | opcional: arena opcional, atrás de um canto escuro |
| Terra | Ruínas | principal; vem antes da parede rachada do caminho até o Selo |
| Ar | Ruínas | opcional: arena opcional escondida |

#### Comportamento e habilidades
- Nate lê o pergaminho (interagir) e aprende o elemento na hora. A combinação de dois elementos vem sozinha quando Nate conhece os dois.
- Quem segue só o caminho principal termina com Fogo, Terra e a combinação Magma. Quem explora ganha Água e Ar e, com eles, as outras 5 combinações.
- Lugar de cada pergaminho: `08-mapa.md`.

#### Interações
Nenhuma além de ensinar o elemento.

#### Animações necessárias
- As de interagir de Nate (`04-player.md`).

#### Sons necessários
- O som de achar item (ver Sistema).

#### Assets necessários
- Modelo do pergaminho.

### Magias
**Papel no jogo:** os poderes de combate de Nate. O par de elementos equipado define o estilo da luta (pilar 1).
**Descrição visual:** cada magia tem a cor e o efeito do seu elemento: Fogo, laranja e amarelo; Água, azul-claro; Terra, marrom e ocre; Ar, branco e cinza-claro. Cada combinação mistura as cores dos dois elementos (`10-arte-audio.md`).

#### Atributos
Valores exatos (recarga, dano, áreas e durações): `11-balanceamento.md`.

**Magias de elemento**

| Magia | Elemento | Forma | Efeito |
|-------|----------|-------|--------|
| Bola de Fogo | Fogo | projétil que explode ao acertar | dano em área pequena e queimadura |
| Onda Cortante | Água | onda em linha à frente | dano e recuo curto |
| Colapso Terrestre | Terra | impacto em círculo ao redor de Nate | dano e recuo longo |
| Rajada Veloz | Ar | rajada em cone à frente | recuo longo; Nate fica mais rápido por alguns segundos |

**Combinações (Q+E)**

| Combinação | Elementos | Forma | Efeito |
|------------|-----------|-------|--------|
| Vapor | Fogo + Água | nuvem à frente, que fica alguns segundos no lugar | queimadura em quem está dentro |
| Magma | Fogo + Terra | erupção de lava em linha à frente | dano alto e queimadura |
| Tempestade de Fogo | Fogo + Ar | redemoinho ao redor de Nate, por alguns segundos | queimadura e recuo em quem chega perto |
| Gelo | Água + Ar | rajada gelada em cone à frente | atordoa |
| Lamaçal | Água + Terra | lama no chão, à frente, que fica alguns segundos | lento em quem passa |
| Escudo de Areia | Terra + Ar | areia girando ao redor de Nate, por alguns segundos | o próximo golpe recebido não tira vida |

Recuo da Tempestade de Fogo: curto.

#### Comportamento e habilidades
- **Água equipada:** queimadura, veneno e lento duram metade do tempo em Nate. A Água não cura: no combate, só a poção de vida cura.
- **Terra aprendida:** os golpes de Nate, tiros incluídos, quebram paredes rachadas. Sem a Terra, a parede responde com um som de pedra firme. A Terra é exigida uma vez no caminho principal, na parede rachada antes do Selo (`02-core-loop.md`).
- As magias de Fogo são a fonte de queimadura de Nate; o veneno é só dos mobs (`03-regras.md`).
- Nate não é ferido pelas próprias magias (`03-regras.md`).
- Onda Cortante, Colapso Terrestre, Rajada Veloz e Tempestade de Fogo empurram inimigos, inclusive para dentro de armadilhas.

#### Interações
- **Mobs:** recuo, interrupção e efeitos conforme cada magia (`03-regras.md`).
- **Chefe:** imune a efeitos de status, salvo onde a luta for desenhada para isso (`03-regras.md`).
- **Paredes rachadas:** quebram quando Nate já aprendeu Terra.

#### Animações necessárias
- A pose de usar magia de Nate (`04-player.md`), a mesma para as 10.
- Efeito visual de cada magia: 10 efeitos.

#### Sons necessários
- Um som para cada magia: 10 sons.
- Parede rachada quebrando e pedra firme, quando Nate bate sem ter aprendido Terra.

#### Assets necessários
- 10 efeitos visuais de magia, definidos por código.
- Ícone de cada elemento e de cada combinação (`09-interface.md`).

## Poção de vida
**Papel no jogo:** a cura do meio do combate (fora dele, a vida volta sozinha, `04-player.md`). Um item de mão, que fica na barra fixa como as armas. Recarrega no santuário.
**Descrição visual:** garrafinha de vidro com o líquido vermelho e rolha de cortiça (`10-arte-audio.md`).

### Atributos
| Atributo | Valor |
|----------|-------|
| Cargas | 3 (até 5 com melhorias) |
| Cura por carga | 40 |
| Tempo para beber | 0,6 s |

### Comportamento e habilidades
- Nate ganha a poção no primeiro santuário, no Bosque; ela entra na barra fixa, sem ir para a mão.
- Bebe com a poção na mão e o botão de usar, ou pelo atalho de beber, sem tirar a arma da mão (`04-player.md`).
- Beber leva 0,6 s, com Nate andando em meia velocidade, sem atacar nem dar o dash. A cura acontece no fim, mesmo se ele levar um golpe. Com a vida cheia, Nate não bebe.
- Recarrega ao descansar no santuário e quando Nate volta depois de morrer (`02-core-loop.md`).

### Interações
- Santuários: recarga.

### Animações necessárias
- Beber (`04-player.md`).

### Sons necessários
- Beber, cura concluída e tentar beber sem carga ou com a vida cheia (`04-player.md`).

### Assets necessários
- Modelo da poção, na mão de Nate.
- Ícone da poção; as cargas aparecem no espaço dela na barra (`09-interface.md`).

## Melhorias
**Papel no jogo:** recompensa permanente dos segredos (pilar 3).
**Descrição visual:** contas de jade, uma em forma de coração (+20 de vida) e outra em forma de gota (+1 carga) (`10-arte-audio.md`).

### Atributos
| Melhoria | Quantas | Efeito |
|----------|---------|--------|
| +20 de vida | 4 | vida máxima de 100 até 180 |
| +1 carga | 2 | poção de 3 até 5 cargas |

### Comportamento e habilidades
- Escondidas em segredos; lugar exato em `08-mapa.md`.
- Valem na hora e para sempre. A vida e a carga novas chegam cheias.

### Interações
Nenhuma além do efeito.

### Animações necessárias
Nenhuma própria.

### Sons necessários
- O som de achar item (ver Sistema).

### Assets necessários
- Um modelo para cada tipo de melhoria.
