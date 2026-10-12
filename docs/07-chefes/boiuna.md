# Boiúna, o predador

**Papel no jogo:** o chefe final. É a criatura colossal das profundezas, presa só pelo sono que a prisão incompleta provocou. Acordou antes da hora, e a escuridão dela desperta esqueletos, necromantes e golens (`01-historia.md`, `06-mobs/`). A luta usa tudo o que Nate aprendeu: armas, magias, esquiva e o muiraquitã inteiro.
**Descrição visual:** cobra blocada colossal, preta, com olhos que brilham. A cabeça tem cerca de 4 blocos de comprimento; o corpo é maior que a arena e aparece só em partes, saindo de um fosso no centro. É inspirada na Boiúna, a Cobra Grande das lendas amazônicas ("cobra preta", em tupi), que vive no fundo dos rios e atrai pescadores com a luz dos olhos. Preta com reflexos roxos e olhos âmbar que brilham (`10-arte-audio.md`).

## Atributos
Valores exatos: `[A DEFINIR em 11-balanceamento]`.

| Atributo | Valor |
|----------|-------|
| Vida da fase 1 | dividida em 4 partes |
| Vida da fase 2 | uma barra só |
| Peso | chefe: ignora todo recuo (`03-regras.md`) |
| Efeitos de status | imune; a única exceção é o atordoar da fase 1 |
| Duração-alvo da luta | cerca de 4 min na primeira tentativa: cerca de 2,5 min na fase 1 e 1,5 min na fase 2 |

## Comportamento e habilidades

### Arena: a Grande Prisão
- Arena com um fosso no centro, de onde a Boiúna sai, e um pilar de cada lado. Ela cabe inteira na câmera normal do jogo (`08-mapa.md`). Medidas em blocos: no rascunho do mapa no motor.
- A porta da Grande Prisão abre quando Nate interage com ela tendo o muiraquitã inteiro (`05-itens.md`).
- Nenhum mob entra na luta.

### Avisos
- Todos os golpes da Boiúna são fortes ou de área: marca no chão, exatamente igual à área atingida, e aviso de pelo menos 1 s (`03-regras.md`).
- Antes de qualquer golpe, os olhos dela brilham.
- Cada ataque tem um som de aviso próprio.

### Fase 1: de frente
- A arena está iluminada. A Boiúna sai do fosso e alterna os ataques da tabela.
- A vida da fase 1 tem 4 partes. Cada parte derrubada deixa a Boiúna atordoada por alguns segundos, e esse é o momento seguro de ativar um pilar. Duração do atordoar: `[A DEFINIR em 11-balanceamento]`.
- **Pilar:** Nate ativa segurando o botão de interagir por um tempo; se levar um golpe, a ativação para. Dá para tentar sem atordoar a Boiúna, mas o jeito seguro é atordoar antes. Tempo: `[A DEFINIR em 11-balanceamento]`.
- Cada pilar ativo prende a Boiúna com uma corrente de luz, e ela fica mais agressiva: espera menos entre um ataque e outro. Intervalos: `[A DEFINIR em 11-balanceamento]`.
- Com os 4 pilares ativos, começa a fase 2.

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Depois do golpe |
|--------|------|------|------|-------|-------|-----------------|
| Bote | forte | 3 corações | linha do fosso até onde Nate está | a cabeça recua e os olhos brilham | longo | a cabeça fica no chão alguns segundos: janela para bater |
| Varrida de cauda | área | 2 corações | um setor da arena | a cauda se ergue | longo | — |
| Cuspe de escuridão | área | 2 corações | círculos em pontos da arena | a garganta incha | `[A DEFINIR em 11-balanceamento]` | ficam poças por alguns segundos, que deixam lento quem pisa |

### Fase 2: na escuridão
- A arena apaga. Nate só enxerga dentro do brilho da Luz Ancestral do muiraquitã (`05-itens.md`).
- A Boiúna some na escuridão e ataca de emboscada.
- A vida da fase 2 é uma barra só. Quando acaba, a prisão fecha, e vêm a cena final e os créditos (`02-core-loop.md`).
- A passagem da fase 1 para a 2 é uma cena curta, feita no motor (`10-arte-audio.md`).

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Depois do golpe |
|--------|------|------|------|-------|-------|-----------------|
| Emboscada | forte | 3 corações | linha até Nate | os olhos aparecem na borda da Luz Ancestral | longo | a cabeça fica exposta: janela para bater |
| Cerco | área | 2 corações | anel em volta de Nate | o corpo começa a circular | `[A DEFINIR em 11-balanceamento]` | — |

No Cerco, Nate escapa saindo do anel antes de ele fechar.

### Morte de Nate
- Na fase 1, a luta recomeça do início.
- Na fase 2, Nate volta ao santuário e, ao entrar de novo na arena, a luta recomeça na fase 2, com os 4 pilares ativos.

## Interações
- **Nate:** só fere com golpes avisados. Armas e magias ferem a Boiúna normalmente, mas os efeitos de status não pegam.
- **Pilares:** ativados por Nate com o muiraquitã inteiro.
- **Luz Ancestral:** revela a Boiúna na fase 2.
- **Recuo:** Nate não a empurra.

## Animações necessárias
- Sair do fosso e voltar para ele.
- Acompanhar Nate com a cabeça.
- Bote: recuar a cabeça e avançar; cabeça no chão.
- Varrida de cauda: erguer e varrer.
- Cuspe: inchar a garganta e cuspir.
- Atordoada, no fim de cada parte da vida da fase 1.
- Presa por uma corrente de luz a cada pilar.
- Sumir na escuridão, na passagem para a fase 2.
- Emboscada: surgir do escuro e dar o bote; cabeça exposta.
- Cerco: circular e apertar.
- Levar golpe.
- Ser selada, no fim da luta.

## Sons necessários
- Aviso de cada ataque: bote, cauda, cuspe, emboscada e cerco.
- Golpes: bote, varrida, cuspe caindo e cerco apertando.
- Rugido ao ser atordoada e ao trocar de fase.
- Pilar ativando e corrente de luz se prendendo.
- Porta da Grande Prisão abrindo.
- Prisão fechando.

## Assets necessários
- Modelo da Boiúna em segmentos (cabeça, corpo e cauda), definido por código.
- Olhos que brilham.
- Fosso central, 4 pilares e a porta da Grande Prisão (`08-mapa.md`).
- Efeitos: corrente de luz, cuspe, poças de escuridão e as marcas no chão de cada ataque.
- Iluminação da arena acesa e apagada.
