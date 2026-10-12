# Nate

**Papel no jogo:** o herói, controlado pelo jogador. Homem comum de 30 anos, sem conhecimento especial, que aprende junto com quem joga (`01-historia.md`).
**Descrição visual:** humano blocado, com as proporções do Minecraft e 2 blocos de altura. Roupa simples de ribeirinho: camiseta gasta, calça e botas de borracha. No pescoço, o muiraquitã, com uma lasca faltando. Esse é o visual base, sem equipamento; a arma aparece na mão e a armadura no corpo (`05-itens.md`). Cores exatas: `[A DEFINIR em 10-arte-audio]`, com uma regra: Nate precisa se destacar nos cenários escuros.

## Atributos
| Atributo | Valor |
|----------|-------|
| Vida máxima inicial | 5 corações |
| Velocidade de movimento | 5 blocos/s |
| Bônus de dano | 0% |
| Chance de crítico | 5% |
| Cargas do frasco | 3 (a partir do primeiro santuário) |
| Cura por carga | 2 corações |
| Elementos equipados | 2 |

## Comportamento e habilidades

### Controles
No computador, com teclado e mouse ou com controle; os dois funcionam desde o início. Sistemas e exportação: `[A DEFINIR em 12-tecnico]`.

| Ação | Teclado e mouse | Controle (Xbox / PlayStation) |
|------|-----------------|-------------------------------|
| Andar | W A S D | analógico esquerdo |
| Mirar | mouse | analógico direito |
| Atacar | botão esquerdo | X / □ |
| Ataque à distância (segurar e soltar) | botão direito | RT / R2 |
| Esquivar | Espaço | A / ✕ |
| Magia 1 e 2 (as duas juntas: combinação) | Q e E | LB e RB / L1 e R1 |
| Frasco | R | Y / △ |
| Interagir | F | B / ○ |
| Inventário | Tab | View / Touchpad |
| Pausa | Esc | Menu / Options |

- Todos os botões podem ser trocados numa tela do menu de opções (`09-interface.md`).
- No controle, o tiro fica no gatilho para dar para mirar com o analógico direito enquanto puxa.

### Movimento
- 5 blocos/s, uma velocidade só: sem pulo e sem botão de correr.
- Acelera e freia em 0,1 s: responde na hora, sem deslizar.
- Fora dos ataques, Nate olha para onde anda.

### Mira
- **Teclado e mouse:** os ataques vão na direção do cursor.
- **Controle:** na direção do analógico direito; com ele solto, na direção do movimento.
- **Ajuda de mira:** o golpe é puxado para o inimigo mais próximo dentro de um cone à frente. Tamanho do cone: `[A DEFINIR em 11-balanceamento]`.
- Dá para andar para um lado e atacar para outro.

### Ataque corpo a corpo
**Combo de 3 golpes:** apertar em sequência faz os 3 golpes.

| Golpe | Dano | Recuo |
|-------|------|-------|
| 1º | o da arma | curto |
| 2º | o da arma | curto |
| 3º | maior (quanto: `11-balanceamento.md`) | longo, que interrompe mobs pesados |

- Toda arma corpo a corpo segue esse combo. Cada arma muda dano, área e tempos (`05-itens.md`).
- Durante o golpe, Nate dá um pequeno passo à frente e não anda. Tamanho do passo: `[A DEFINIR em 11-balanceamento]`.
- Tempo máximo entre dois apertos para o combo continuar: `[A DEFINIR em 11-balanceamento]`.
- A esquiva cancela a recuperação do golpe.

### Ataque à distância
**Puxar e soltar, sem munição.**
- Segurar puxa até a força total; soltar atira. Soltar antes da força total cancela o tiro. O tempo até a força total varia por arma (`05-itens.md`).
- Enquanto puxa, Nate anda à metade da velocidade e não ataca de perto nem usa magia. Esquivar cancela o tiro.
- O dano é menor que o do corpo a corpo (valores em `05-itens.md`).
- Também acerta alvos do cenário, como alavancas distantes (`08-mapa.md`).

### Esquiva
**Rolamento:** 3 blocos em 0,4 s.
- Direção: a do movimento; parado, rola para a frente de Nate.
- Invencível durante os 0,4 s do rolamento.
- Recarga: 1 s, contada do fim do rolamento.
- Cancela a recuperação dos golpes de Nate.

### Magias
- Nate equipa 2 elementos, cada um num botão. Q e E lançam a magia de cada um; os dois juntos lançam a combinação (`05-itens.md`).
- A combinação só sai com as duas magias prontas e põe as duas para recarregar.
- Aprender um elemento já dá o efeito dele fora de combate, equipado ou não.
- Os elementos equipados são trocados a qualquer momento, no inventário, com o jogo pausado (`05-itens.md`).
- A Luz Ancestral é do próprio muiraquitã: funciona sozinha e não ocupa espaço nem botão.

### Frasco
- Beber leva 0,6 s. Enquanto bebe, Nate anda à metade da velocidade e não ataca nem esquiva.
- A cura acontece no fim, mesmo se Nate levar um golpe: a carga nunca é perdida.
- Cargas e cura por carga: `05-itens.md`.

### Ao levar um golpe
Perde corações inteiros, é empurrado conforme o golpe, perde o controle por 0,2 s e fica invencível por 1 s (`03-regras.md`).

### O que cada trecho ensina
Uma coisa nova por vez.

| Trecho | Ensina |
|--------|--------|
| Prólogo (luta com a criatura) | andar, combo e esquiva |
| Mina | ataque à distância (ex.: alavanca longe) e interagir (baú, alavanca) |
| Bosque, 1º santuário | Nate ganha o frasco; descansar e recarregar |
| Bosque | primeiro pergaminho (Fogo): o muiraquitã acorda; Luz Ancestral e Bola de Fogo |
| Ruínas | pergaminho de Terra e a primeira combinação, Magma |

Água e Ar, opcionais, são ensinados onde forem achados.

Prólogo e Mina não têm cura, então as lutas ali são leves (`06-mobs/`, `08-mapa.md`).

Nate começa com o facão e acha a baladeira, a primeira arma à distância, na Mina (`05-itens.md`).

## Interações
- **Mobs e chefe:** Nate fere com golpes, tiros e magias, e só é ferido por golpes avisados; encostar não fere. Qualquer golpe interrompe mobs leves; os pesados, só o 3º golpe do combo ou outro golpe com recuo longo (`03-regras.md`).
- **Armadilhas:** ferem Nate e os mobs; dá para atrair ou empurrar inimigos para elas.
- **Muiraquitã e magias:** a Luz Ancestral ilumina as áreas escuras; com Terra aprendida, os golpes quebram paredes rachadas; com o Selo, a porta da Grande Prisão abre. Os elementos equipados dão as magias em combate.
- **Cenário:** alavancas (perto, interagir; longe, tiro), baús (interagir), santuários (interagir para descansar, salvar e viajar), elevadores e portas que só abrem por um lado. Paredes bloqueiam golpes e tiros.
- **Murais:** interagir mostra o mural grande na tela; depois ele fica na galeria (`09-interface.md`).
- **Morte:** volta ao último santuário, sem perder nada (`02-core-loop.md`).

## Animações necessárias
- Parado.
- Andar (também em meia velocidade, combinado com puxar o tiro e beber do frasco).
- Golpes 1, 2 e 3 do combo, com o passo à frente.
- Puxar, segurar puxado e soltar o tiro: uma pose para cada tipo de arma (`05-itens.md`).
- Rolamento.
- Usar magia: a mesma pose para todas, combinações incluídas (`05-itens.md`).
- Beber do frasco.
- Interagir (alavanca, baú).
- Descansar no santuário.
- Levar golpe (0,2 s sem controle, sendo empurrado).
- Morrer.

## Sons necessários
- Passos (tipos de chão em `10-arte-audio.md`).
- Golpes 1, 2 e 3 cortando o ar; acerto; acerto crítico.
- Puxar o tiro, tiro na força total, soltar.
- Rolamento.
- Usar magia (cada uma em `05-itens.md`).
- Beber do frasco, cura concluída, tentar beber sem carga.
- Levar golpe.
- Morrer.

## Assets necessários
- Modelo de Nate: humano blocado de 2 blocos, visual de ribeirinho, definido por código.
- Muiraquitã no pescoço, com a lasca faltando e inteiro (`05-itens.md`).
- Efeito de piscar durante a invencibilidade.
- Sinal de tiro na força total: `[A DEFINIR em 10-arte-audio]`.
- Ícones de botão para teclado e mouse, Xbox e PlayStation (`09-interface.md`).
