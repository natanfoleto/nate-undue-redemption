# Core loop

O que o jogador faz minuto a minuto, como a partida se estrutura, o que acontece quando Nate morre, como ele fica mais forte e como o jogo termina.

## Resumo
Nate atravessa Agartha de santuário em santuário. Em cada área, ele luta contra mobs espalhados e em arenas e acha equipamento, melhorias, pergaminhos de magia, murais e atalhos. A Luz Ancestral do muiraquitã e a Terra abrem o caminho seguinte e, nas áreas já visitadas, segredos. Morrer não tira nada: Nate volta ao último santuário. A partida termina quando ele prende o predador na Grande Prisão, em cerca de 30 min. Depois disso, o mundo continua aberto para achar o que faltou.

## Minuto a minuto

### Loop de momento (segundos)
Andar → ver o aviso do ataque inimigo → esquivar ou se posicionar → atacar de perto, à distância ou com magia → usar o frasco quando a vida baixa.

Controles em `04-player.md`; dano, recuo e invencibilidade em `03-regras.md`.

### Loop de área (minutos)
1. **Santuário:** Nate descansa. Vida e frasco cheios, jogo salvo, memória na primeira visita.
2. **Exploração:** caminho principal e desvios, com mobs espalhados, baús e segredos.
3. **Lutas:** cada luta gasta vida e cargas do frasco. O que sobra decide se Nate avança ou volta para recarregar.
4. **Atalho:** abrir um caminho curto de volta ao santuário, ou chegar ao próximo.
5. **Arena:** o clímax da área, guardando um pergaminho ou uma passagem.
6. **Próxima área.** Cada poder novo de exploração (Luz Ancestral, Terra) também abre segredos nas áreas já visitadas, para quem quiser voltar.

Se Nate morre, volta ao passo 1 sem perder nada.

## Estrutura da partida
Abertura (cena) → Prólogo → Mina → Bosque de Fungos → Ruínas → Grande Prisão → Final (cena) → pós-jogo (volta ao mundo)

### Duração-alvo
Tempo de quem joga pela primeira vez, contando as mortes.

| Trecho | Tempo |
|--------|-------|
| Prólogo + Mina | 5 min |
| Bosque de Fungos | 9 min |
| Ruínas | 11 min |
| Grande Prisão | 5 min |
| **Caminho principal** | **30 min** |
| **Com todos os segredos** | **45 min** |

### Forma: linear com volta opcional
- O caminho principal segue sempre em frente. Nunca é preciso voltar para avançar.
- Cada poder de exploração é exigido uma vez no caminho principal: a Luz Ancestral na passagem escura e a Terra na parede rachada antes do Selo. Os outros usos abrem segredos, inclusive em áreas já visitadas.
- Voltar é opcional. Os atalhos (elevadores e portas que só abrem por um lado) e a viagem rápida encurtam a volta.
- Paredes rachadas e cantos escuros precisam ser reconhecíveis à primeira vista, para o jogador lembrar de voltar quando tiver o poder certo.

### Viagem rápida
- Ao descansar num santuário, Nate pode ir para outro santuário já visitado. Só sai de um santuário e só chega em outro.
- Os atalhos continuam valendo: depois de morrer, são eles que levam do santuário de volta ao ponto onde Nate estava.
- No menu do santuário, "Viajar" abre a lista dos santuários visitados (`09-interface.md`).

### Cadeia de progressão
| Trecho | Poder obtido | Passagem para o trecho seguinte |
|--------|--------------|---------------------------------|
| Prólogo | nenhum | Nate segue a criatura pela fenda |
| Mina | nenhum | sem exigência |
| Bosque de Fungos | pergaminho de Fogo; o muiraquitã acorda (Luz Ancestral) | passagem escura, que exige a Luz Ancestral |
| Ruínas | pergaminho de Terra e o Selo | o Selo, encaixado no muiraquitã, abre a Grande Prisão |
| Grande Prisão | nenhum | luta final |

Nas Ruínas, uma parede rachada no caminho até o Selo exige a Terra. Os pergaminhos de Água e Ar são opcionais (`05-itens.md`).

Lugar de cada passagem, pergaminho e segredo: `08-mapa.md`.

### Começo e fim
- **Abertura (cena):** Nhamundá, criaturas atacando rebanhos, Nate rejeitado pela cidade.
- **Prólogo (jogável, cerca de 1 min):** borda da mina, na floresta. Primeira luta, contra a criatura. Ela perde, foge pela fenda e Nate a segue.
- **Mina:** tutorial do resto dos controles. O que cada trecho ensina: `04-player.md`.
- **Final (cena):** o retorno à cidade.
- Criatura do prólogo: um Lobo (`06-mobs/lobo.md`).
- Cenas feitas no motor, sem fala (`10-arte-audio.md`).

## Combate no mapa
- **Mobs espalhados** no caminho principal e nos desvios. O jogador escolhe enfrentar ou contornar.
- **Arenas** nos momentos-chave: a passagem fecha até o jogador vencer as ondas. São 5: 1 na Mina, 2 no Bosque e 2 nas Ruínas, cada uma guardando um pergaminho ou uma passagem. A arena é o clímax da área e garante que o jogador pratique o que a área ensinou antes de seguir.
- Posição e ondas de cada arena: `08-mapa.md`.

## Cura
- **Frasco com cargas.** Nate sai do santuário com o frasco cheio, gasta cargas nas lutas e volta pelos atalhos ou avança até o próximo santuário para recarregar.
- Recarrega ao descansar no santuário.
- Nate ganha o frasco no primeiro santuário, no Bosque. Prólogo e Mina não têm cura (`04-player.md`).
- Cargas extras vêm de melhorias escondidas (ver Progressão de poder).
- 3 cargas; cada carga cura 2 corações (`05-itens.md`).

## Morte e salvamento
- Nate volta ao último santuário com vida e frasco cheios, sem perder nada.
- Antes do primeiro santuário (no Bosque), volta ao início do prólogo ou da Mina.

| O quê | Depois da morte |
|-------|-----------------|
| Itens, equipamento, elementos aprendidos e melhorias | ficam |
| Atalhos abertos e murais vistos | ficam |
| Inimigos já mortos | continuam mortos |
| Inimigos vivos | reiniciam, com vida cheia e na posição inicial |
| Arena incompleta | reinicia |
| Chefe | reinicia do começo da fase em que Nate morreu (`07-chefes/boiuna.md`) |

A morte custa só a caminhada de volta, que os atalhos encurtam. Dá para vencer um trecho difícil por desgaste, morrendo e voltando; isso é aceito, por causa da dificuldade acessível.

**Ao sair do jogo:** funciona como uma morte. Tudo o que foi conquistado é salvo na hora: itens, equipamento, elementos aprendidos, melhorias, atalhos, murais e inimigos mortos. Ao voltar, Nate está no último santuário. Como o jogo salva: `12-tecnico.md`.

## Progressão de poder
Nate fica mais forte com o que acha no mapa. Não há XP nem moeda.

| Fonte | Onde se acha |
|-------|--------------|
| Equipamento | cada peça tem um lugar fixo (baús, segredos, arenas); nada é sorteado |
| Melhorias permanentes | escondidas em segredos (ex.: +vida máxima, +1 carga no frasco) |
| Magias | 4 pergaminhos de elemento: Fogo e Terra no caminho principal; Água e Ar em segredos e arenas opcionais |

- Mobs não deixam nada ao morrer (`05-itens.md`).
- **Magias:** aprender um elemento já dá o efeito dele fora de combate (com Terra, os golpes quebram paredes rachadas); equipar dá a magia em combate. Nate equipa 2 elementos por vez, cada um num botão, como os artefatos do Minecraft Dungeons, e os dois juntos lançam a combinação (`04-player.md`).
- Magias, melhorias e as 13 peças de equipamento: `05-itens.md`.
- A Luz Ancestral é do próprio muiraquitã: funciona sozinha e, na luta final, revela o predador. O Selo é a lasca que falta no muiraquitã: não tem poder de combate e funciona só por estar com Nate, inclusive nos pilares da luta final (`05-itens.md`).
- Como nada é sorteado, sabemos o que o jogador pode ter em cada ponto do mapa. Isso guia o balanceamento (`11-balanceamento.md`).

## Desafio opcional
- **Arenas opcionais:** escondidas fora do caminho principal e mais difíceis que as arenas comuns, usando o mesmo sistema. Guardam as melhores recompensas.
- Uma por área: Mina, Bosque e Ruínas (`08-mapa.md`).
- Não há seletor de dificuldade: o desafio extra fica no mapa, para quem procura.

## Vitória e pós-jogo
- **Vitória:** vencer a fase 2 da Boiúna, o predador, e fechar a Grande Prisão (`07-chefes/boiuna.md`). Em seguida vêm a cena final e os créditos.
- **Pós-jogo, volta ao mundo:** depois dos créditos, Nate reaparece no último santuário, com o predador preso, para achar o que faltou.
- A arena da Grande Prisão fica vazia; o resto do mapa segue como estava.
- O contador de murais e segredos fica numa tela de progresso no menu de pausa, por área. Depois dos créditos, aparece um resumo da partida (`09-interface.md`).
