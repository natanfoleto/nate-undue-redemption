# Nate

**Papel no jogo:** o herói, controlado pelo jogador. Homem comum de 30 anos, sem conhecimento especial, que aprende junto com quem joga (`01-historia.md`).
**Descrição visual:** humano blocado, com 2 blocos de altura, nas proporções e no estilo das skins do Minecraft: caixas retas (cabeça de 8 × 8 × 8 px, corpo de 8 × 12 × 4, braços e pernas de 4 × 12 × 4) e uma pele pintada pixel a pixel, com rosto, cabelo e as dobras da roupa. Roupa simples de ribeirinho: camiseta gasta, calça e botas de borracha. No pescoço, o muiraquitã, com uma lasca faltando. Esse é o visual base, sem equipamento; a arma aparece na mão e a armadura no corpo (`05-itens.md`). Cores: camiseta mostarda gasta, calça jeans, botas de borracha pretas, pele morena e cabelo preto curto (`10-arte-audio.md`). Regra: Nate precisa se destacar nos cenários escuros.

## Atributos
| Atributo | Valor |
|----------|-------|
| Vida máxima inicial | 100 |
| Velocidade de movimento | 5 blocos/s |
| Bônus de dano | 0% |
| Chance de crítico | 5% |
| Cargas da poção de vida | 3 (a partir do primeiro santuário; até 8 com melhorias) |
| Cura por carga | 40 |
| Vida que volta fora de combate | 2 por segundo, depois de 8 s sem levar dano |
| Espaços da barra fixa | 5 |
| Elementos equipados | 2 |

## Comportamento e habilidades

### Controles
No computador, com teclado e mouse ou com controle; os dois funcionam desde o início. Exportação para Windows e macOS (`12-tecnico.md`).

| Ação | Teclado e mouse | Controle (Xbox / PlayStation) |
|------|-----------------|-------------------------------|
| Andar | W A S D | analógico esquerdo |
| Mirar | mouse | analógico direito |
| Atacar com a arma de perto da mão (combo) | botão esquerdo | X / □ |
| Usar segurando: puxar e soltar o tiro; beber a poção | botão direito | RT / R2 |
| Escolher o espaço da barra fixa | 1 a 5 e a roda do mouse | direcional ◀ e ▶ |
| Esquivar (dash); com atacar, o golpe do dash | Espaço | A / ✕ |
| Magia 1 e 2 (as duas juntas: combinação) | Q e E | LB e RB / L1 e R1 |
| Interagir | F | B / ○ |
| Murais (a galeria) | G | direcional ▲ |
| Inventário | Tab | View / Touchpad |
| Pausa | Esc | Menu / Options |

- Todos os botões podem ser trocados numa tela do menu de opções (`09-interface.md`).
- No controle, o tiro fica no gatilho: dá para mirar com o analógico direito enquanto puxa.
- O M fica guardado para o mapa (`09-interface.md`).

### Movimento
- 5 blocos/s, uma velocidade só: sem pulo e sem botão de correr.
- Acelera e freia em 0,1 s: responde na hora, sem deslizar.
- Fora dos ataques, Nate olha para onde anda.

### Mira
- **Teclado e mouse:** os ataques vão na direção do cursor.
- **Controle:** na direção do analógico direito; com ele solto, na direção do movimento.
- **Ajuda de mira:** o golpe é puxado para o inimigo mais próximo dentro de um cone à frente. Tamanho do cone: `11-balanceamento.md`.
- **Seta da mira:** uma seta discreta no chão, junto de Nate, mostra para onde os ataques vão, no mouse e no controle, já puxada pela ajuda de mira.
- Dá para andar para um lado e atacar para outro.

### Item da mão
**Uma arma na mão, como no Minecraft.** A barra fixa tem 5 espaços (`05-itens.md`, `09-interface.md`); o espaço escolhido é o item que Nate segura. O botão esquerdo ataca com a arma de perto; o direito, segurado, usa a arma de longe ou a poção.
- Os números de 1 a 5 escolhem o espaço; a roda do mouse (no controle, o direcional) passa para o seguinte ou o anterior, do último volta ao primeiro. Troca a qualquer hora, até no meio do dash.
- Com uma arma de perto na mão, o botão esquerdo golpeia (o combo); com uma de longe, segurar o direito puxa e soltar atira; com a poção, segurar o direito bebe.
- Trocar de espaço para o golpe ou o tiro em andamento; a poção que está sendo bebida continua.
- Uma arma achada vai para o primeiro espaço vazio da barra e já fica na mão; a poção também entra na barra, sem ir para a mão.
- Na mão: a arma de perto na direita; a de longe e a poção na esquerda. A armadura fica vestida, fora da barra.

### Ataque corpo a corpo
**Combo de 3 golpes:** apertar em sequência faz os 3 golpes.

| Golpe | Dano | Recuo |
|-------|------|-------|
| 1º | o da arma | curto |
| 2º | o da arma | curto |
| 3º | maior (quanto: `11-balanceamento.md`) | longo, que interrompe mobs pesados |

- Toda arma corpo a corpo segue esse combo. Cada arma muda dano, área e tempos (`05-itens.md`).
- Nate golpeia parado ou andando: durante o golpe, anda à metade da velocidade, sem passo à frente (`11-balanceamento.md`). O golpe vai para a mira, não para onde ele anda.
- Tempo máximo entre dois apertos para o combo continuar: `11-balanceamento.md`.
- O dash cancela a recuperação do golpe.
- **Rastro:** cada golpe deixa uma meia-lua branca na área que ele acerta, grossa no meio e fina nas pontas (`10-arte-audio.md`).

### Golpe do dash
**Espaço + clique:** atacar durante o dash, ou logo antes de apertar o Espaço, guarda um golpe para o fim do dash.
- No fim do dash sai um golpe em arco na direção dele, com o dano e o recuo longo do 3º golpe do combo, sem preparação: o dash é a preparação.
- Um golpe por dash, só com uma arma de perto na mão.
- O aperto de atacar vale para o golpe do dash por 0,15 s antes do Espaço; nesse tempo, o dash cancela a preparação do golpe comum (`11-balanceamento.md`).

### Ataque à distância
**Puxar e soltar, sem munição.**
- Segurar o botão direito puxa até a força total; soltar atira. Soltar antes da força total cancela o tiro. Vale para todas as armas de longe. O tempo até a força total varia por arma (`05-itens.md`).
- Enquanto puxa, Nate anda à metade da velocidade e não usa magia. O dash cancela o tiro.
- O dano é menor que o do corpo a corpo (valores em `05-itens.md`).
- Também acerta alvos do cenário, como alavancas distantes (`08-mapa.md`).

### Esquiva
**Dash:** 3 blocos em 0,4 s. Nate se inclina e dispara para a frente, deixando cópias translúcidas pelo caminho e poeira nos pés (`10-arte-audio.md`).
- Direção: a do movimento; parado, para a frente de Nate.
- Invencível durante os 0,4 s do dash.
- Recarga: 0,5 s, contada do fim do dash (0,35 s com o Manto de fibra, `05-itens.md`).
- Cancela a recuperação dos golpes de Nate.

### Magias
- Nate equipa 2 elementos, cada um num botão. Q e E lançam a magia de cada um; os dois juntos lançam a combinação (`05-itens.md`).
- A combinação só sai com as duas magias prontas e põe as duas para recarregar.
- Aprender um elemento já dá o efeito dele fora de combate, equipado ou não.
- Os elementos equipados são trocados a qualquer momento, no inventário, com o jogo pausado (`05-itens.md`).
- A Luz Ancestral é do próprio muiraquitã: funciona sozinha e não ocupa espaço nem botão.

### Vida que volta
- Só fora de combate: nenhum inimigo atrás de Nate ou lutando com ele, e 8 s sem levar dano (golpe, veneno ou queimadura). Aí a vida volta 2 por segundo, até o máximo (de vazia a cheia, 50 s com 100 de vida).
- Qualquer dano recomeça a espera de 8 s. Em combate, a vida não volta: a cura vem da poção.

### Poção de vida
- Bebe com a poção na mão, segurando o botão direito. Não há atalho: para beber no meio da luta, Nate troca de espaço na barra.
- Beber leva 0,6 s, segurando o botão. Enquanto bebe, Nate anda à metade da velocidade e não ataca nem dá o dash.
- A cura e o gasto da carga acontecem no fim, mesmo se Nate levar um golpe. Soltar o botão antes do fim para de beber, sem gastar a carga.
- Com a vida cheia, Nate não bebe (toca o som de não dá).
- Cargas e cura por carga: `05-itens.md`.

### Ao levar um golpe
Perde vida (20 num golpe comum, 40 num forte), é empurrado conforme o golpe, perde o controle por 0,2 s e fica invencível por 1 s (`03-regras.md`).

### O que cada trecho ensina
Uma coisa nova por vez.

| Trecho | Ensina |
|--------|--------|
| Prólogo (luta com a criatura) | andar, combo e esquiva |
| Mina | ataque à distância (ex.: alavanca longe) e interagir (baú, alavanca) |
| Bosque, 1º santuário | Nate ganha a poção de vida; descansar e recarregar |
| Bosque | primeiro pergaminho (Fogo): o muiraquitã acorda; Luz Ancestral e Bola de Fogo |
| Ruínas | pergaminho de Terra e a primeira combinação, Magma |

Água e Ar, opcionais, são ensinados onde forem achados.

Prólogo e Mina não têm poção; a vida só volta fora de combate, então as lutas ali são leves (`06-mobs/`, `08-mapa.md`).

Nate começa com a espada e acha o estilingue, a primeira arma à distância, na Mina (`05-itens.md`).

## Interações
- **Mobs e chefe:** Nate fere com golpes, tiros e magias, e só é ferido por golpes avisados; encostar não fere. Qualquer golpe interrompe mobs leves; os pesados, só o 3º golpe do combo ou outro golpe com recuo longo (`03-regras.md`).
- **Armadilhas:** ferem Nate e os mobs; dá para atrair ou empurrar inimigos para elas.
- **Muiraquitã e magias:** a Luz Ancestral ilumina as áreas escuras; com Terra aprendida, os golpes quebram paredes rachadas; com o Selo, a porta da Grande Prisão abre. Os elementos equipados dão as magias em combate.
- **Cenário:** alavancas (perto, interagir; longe, tiro), baús (interagir), santuários (interagir para descansar, salvar e viajar), elevadores e portas que só abrem por um lado. Paredes bloqueiam golpes e tiros. Na natureza, o chão sobe e desce em rampas do próprio chão, por qualquer lado; nas construções, por escadas. Onde o desnível passa de 1 bloco, moitas ou pedras seguram Nate, sem quedas (`08-mapa.md`).
- **Murais:** interagir mostra o mural grande na tela; depois ele fica na galeria, aberta pelo botão dos murais (`09-interface.md`).
- **Morte:** volta ao último santuário, sem perder nada (`02-core-loop.md`).

## Animações necessárias
- Parado.
- Andar (também em meia velocidade, combinado com os golpes, puxar o tiro e beber a poção).
- Golpes 1, 2 e 3 do combo, parado ou andando (a parte de cima do corpo golpeia; as pernas andam).
- Puxar, segurar puxado e soltar o tiro: uma pose para cada tipo de arma (`05-itens.md`).
- Golpe do dash: o 3º golpe do combo, saindo no fim do dash.
- Dash: inclinado para a frente, os braços para trás e uma perna à frente.
- Usar magia: a mesma pose para todas, combinações incluídas (`05-itens.md`).
- Beber a poção.
- Interagir (alavanca, baú).
- Descansar no santuário.
- Levar golpe (0,2 s sem controle, sendo empurrado).
- Morrer.

## Sons necessários
- Passos (tipos de chão em `10-arte-audio.md`).
- Golpes 1, 2 e 3 cortando o ar; acerto; acerto crítico.
- Puxar o tiro, tiro na força total, soltar.
- Dash: um vush de vento.
- Trocar o item da mão.
- Usar magia (cada uma em `05-itens.md`).
- Beber a poção, cura concluída, tentar beber sem carga ou com a vida cheia.
- Levar golpe.
- Morrer.

## Assets necessários
- Modelo de Nate: humano blocado de 2 blocos, visual de ribeirinho, definido por código.
- Muiraquitã no pescoço, com a lasca faltando e inteiro (`05-itens.md`).
- Seta da mira no chão, definida por código.
- Efeito de piscar durante a invencibilidade.
- Rastro do dash (cópias translúcidas de Nate) e a poeira dos pés, por código.
- Rastro do golpe: a meia-lua branca, por código (`10-arte-audio.md`).
- Sinal de tiro na força total: brilho branco na ponta da arma e um clique curto (`10-arte-audio.md`).
- Ícones de botão para teclado e mouse, Xbox e PlayStation (`09-interface.md`).
