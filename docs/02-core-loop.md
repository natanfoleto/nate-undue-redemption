# Core loop

O que o jogador faz minuto a minuto, como a partida se estrutura, o que acontece quando Nate morre, como ele fica mais forte e como o jogo termina.

## Resumo
Nate atravessa Agartha de santuário em santuário. Em cada área, ele luta contra mobs espalhados e em arenas e acha equipamento, melhorias, muiraquitãs, murais e atalhos. As relíquias da história abrem o caminho seguinte e, nas áreas já visitadas, segredos. Morrer não tira nada: Nate volta ao último santuário. A partida termina quando ele prende o predador na Grande Prisão, em cerca de 30 min. Depois disso, o mundo continua aberto para achar o que faltou.

## Minuto a minuto

### Loop de momento (segundos)
Andar → ver o aviso do ataque inimigo → esquivar ou se posicionar → atacar de perto, à distância ou com a muiraquitã equipada → usar o frasco quando a vida baixa.

Controles em `04-player.md`; dano, recuo e invencibilidade em `03-regras.md`.

### Loop de área (minutos)
1. **Santuário:** Nate descansa. Vida e frasco cheios, jogo salvo, memória na primeira visita.
2. **Exploração:** caminho principal e desvios, com mobs espalhados, baús e segredos.
3. **Lutas:** cada luta gasta vida e cargas do frasco. O que sobra decide se Nate avança ou volta para recarregar.
4. **Atalho:** abrir um caminho curto de volta ao santuário, ou chegar ao próximo.
5. **Arena:** o clímax da área, guardando uma relíquia ou uma passagem.
6. **Próxima área.** Cada relíquia nova também abre segredos nas áreas já visitadas, para quem quiser voltar.

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
- Cada relíquia é exigida uma vez no caminho principal. Os outros usos abrem segredos, inclusive em áreas já visitadas.
- Voltar é opcional. Os atalhos (elevadores e portas que só abrem por um lado) e a viagem rápida encurtam a volta.
- Paredes rachadas e cantos escuros precisam ser reconhecíveis à primeira vista, para o jogador lembrar de voltar quando tiver a relíquia certa.

### Viagem rápida
- Ao descansar num santuário, Nate pode ir para outro santuário já visitado. Só sai de um santuário e só chega em outro.
- Os atalhos continuam valendo: depois de morrer, são eles que levam do santuário de volta ao ponto onde Nate estava.
- Tela de escolha (lista dos santuários visitados): `[A DEFINIR em 09-interface]`.

### Cadeia de progressão
| Trecho | Relíquia obtida | Passagem para o trecho seguinte |
|--------|-----------------|---------------------------------|
| Prólogo | nenhuma | Nate segue a criatura pela fenda |
| Mina | nenhuma | sem exigência de relíquia |
| Bosque de Fungos | Muiraquitã da Luz | passagem escura, que exige a Luz |
| Ruínas | Muiraquitã da Rocha e o Selo | o Selo abre a Grande Prisão |
| Grande Prisão | nenhuma | luta final |

Nas Ruínas, uma parede rachada no caminho até o Selo exige a Rocha.

Posição exata de cada passagem, relíquia e segredo: `[A DEFINIR em 08-mapa]`.

### Começo e fim
- **Abertura (cena):** Nhamundá, criaturas atacando rebanhos, Nate rejeitado pela cidade.
- **Prólogo (jogável, cerca de 1 min):** borda da mina, na floresta. Primeira luta, contra a criatura. Ela perde, foge pela fenda e Nate a segue.
- **Mina:** tutorial do resto dos controles. O que cada trecho ensina: `[A DEFINIR em 04-player]`.
- **Final (cena):** o retorno à cidade.
- Criatura do prólogo: `[A DEFINIR em 06-mobs]`.
- Formato das cenas: `[A DEFINIR em 10-arte-audio]`.

## Combate no mapa
- **Mobs espalhados** no caminho principal e nos desvios. O jogador escolhe enfrentar ou contornar.
- **Arenas** nos momentos-chave: a passagem fecha até o jogador vencer as ondas. Cerca de 1 a 2 por área, guardando uma relíquia ou uma passagem. A arena é o clímax da área e garante que o jogador pratique o que a área ensinou antes de seguir.
- Número, posição e ondas de cada arena: `[A DEFINIR em 08-mapa]`.

## Cura
- **Frasco com cargas.** Nate sai do santuário com o frasco cheio, gasta cargas nas lutas e volta pelos atalhos ou avança até o próximo santuário para recarregar.
- Recarrega ao descansar no santuário.
- Cargas extras vêm de melhorias escondidas (ver Progressão de poder).
- Número de cargas e cura por carga: `[A DEFINIR em 05-itens]`.

## Morte e salvamento
- Nate volta ao último santuário com vida e frasco cheios, sem perder nada.
- Antes do primeiro santuário (no Bosque), volta ao início do prólogo ou da Mina.

| O quê | Depois da morte |
|-------|-----------------|
| Itens, equipamento, relíquias e melhorias | ficam |
| Atalhos abertos e murais vistos | ficam |
| Inimigos já mortos | continuam mortos |
| Inimigos vivos | reiniciam, com vida cheia e na posição inicial |
| Arena incompleta | reinicia |
| Chefe | reinicia |

A morte custa só a caminhada de volta, que os atalhos encurtam. Dá para vencer um trecho difícil por desgaste, morrendo e voltando; isso é aceito, por causa da dificuldade acessível.

**Ao sair do jogo:** funciona como uma morte. Tudo o que foi conquistado é salvo na hora: itens, equipamento, relíquias, melhorias, atalhos, murais e inimigos mortos. Ao voltar, Nate está no último santuário. Como salvar a cada conquista: `[A DEFINIR em 12-tecnico]`.

## Progressão de poder
Nate fica mais forte com o que acha no mapa. Não há XP nem moeda.

| Fonte | Onde se acha |
|-------|--------------|
| Equipamento | cada peça tem um lugar fixo (baús, segredos, arenas); nada é sorteado |
| Melhorias permanentes | escondidas em segredos (ex.: +vida máxima, +1 carga no frasco) |
| Muiraquitãs | as 3 relíquias da história no caminho principal; 2 muiraquitãs opcionais em segredos e arenas opcionais |

- Mobs não deixam equipamento. O que deixam: `[A DEFINIR em 05-itens]`.
- **Muiraquitãs:** ter a relíquia já abre caminhos; equipar dá o poder em combate. Nate equipa um número limitado por vez, como os artefatos do Minecraft Dungeons. Quantas ficam equipadas e em quais botões: `[A DEFINIR em 04-player e 05-itens]`.
- Poderes das 2 muiraquitãs opcionais, lista de melhorias e lista de equipamento (10 a 15 peças): `[A DEFINIR em 05-itens]`.
- Uso do Selo em combate, se houver: `[A DEFINIR em 05-itens]`. Na luta final, o Selo ativa os pilares e a Luz revela o predador; se isso usa o efeito de ter a relíquia ou o de equipá-la: `[A DEFINIR em 07-chefes]`.
- Como nada é sorteado, sabemos o que o jogador pode ter em cada ponto do mapa. Isso guia o balanceamento (`11-balanceamento.md`).

## Desafio opcional
- **Arenas opcionais:** escondidas fora do caminho principal e mais difíceis que as arenas comuns, usando o mesmo sistema. Guardam as melhores recompensas.
- Cerca de 1 por área. Número e posição: `[A DEFINIR em 08-mapa]`.
- Não há seletor de dificuldade: o desafio extra fica no mapa, para quem procura.

## Vitória e pós-jogo
- **Vitória:** vencer a fase 2 do predador e fechar a Grande Prisão (detalhes em `07-chefes/`). Em seguida vêm a cena final e os créditos.
- **Pós-jogo, volta ao mundo:** depois dos créditos, Nate reaparece no último santuário, com o predador preso, para achar o que faltou.
- A arena da Grande Prisão fica vazia; o resto do mapa segue como estava.
- Contador de murais e segredos achados: `[A DEFINIR em 09-interface]`.
