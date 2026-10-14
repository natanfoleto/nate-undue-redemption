# Boiúna, o predador

**Papel no jogo:** o chefe final. É a criatura colossal das profundezas, presa só pelo sono que a prisão incompleta provocou. Acordou antes da hora, e a escuridão dela desperta esqueletos, necromantes e golens (`01-historia.md`, `06-mobs/`). A luta usa tudo o que Nate aprendeu: armas, magias, esquiva e o muiraquitã inteiro.
**Descrição visual:** cobra blocada colossal, preta, com olhos que brilham. A cabeça tem cerca de 4 blocos de comprimento; o corpo é maior que a arena e aparece só em partes, saindo de um fosso no centro. É inspirada na Boiúna, a Cobra Grande das lendas amazônicas ("cobra preta", em tupi), que vive no fundo dos rios e atrai pescadores com a luz dos olhos. Preta com reflexos roxos e olhos âmbar que brilham (`10-arte-audio.md`). No jogo, a cabeça tem a mandíbula que abre, e o corpo é uma fila de gomos numa curva, do fundo do fosso até a nuca, com escamas pretas, a barriga em placas e uma faixa de reflexo roxo no dorso; a cauda, mais fina, só sai do fosso na varrida. Quando ela fica entre a câmera e Nate, fica meio transparente, para ele não sumir atrás dela.

## Atributos
Valores exatos: `11-balanceamento.md`.

| Atributo | Valor |
|----------|-------|
| Vida da fase 1 | dividida em 4 partes |
| Vida da fase 2 | uma barra só |
| Peso | chefe: ignora todo recuo (`03-regras.md`) |
| Efeitos de status | imune; a única exceção é o atordoar da fase 1 |
| Duração-alvo da luta | cerca de 4 min na primeira tentativa: cerca de 2,5 min na fase 1 e 1,5 min na fase 2 |

## Comportamento e habilidades

### Arena: a Grande Prisão
- Arena com um fosso no centro, de onde a Boiúna sai, e um pilar de cada lado. Ela cabe inteira na câmera normal do jogo (`08-mapa.md`): 14 × 14 blocos, com o fosso de 4 × 4 e os pilares de 2 × 2 a 5 blocos do centro dele.
- A porta da Grande Prisão abre quando Nate interage com ela tendo o muiraquitã inteiro (`05-itens.md`).
- A luta começa quando Nate entra na arena: a porta fecha atrás dele, trancada, a Boiúna sai do fosso rugindo, a barra dela aparece e a música muda. A câmera puxa um pouco para o centro da arena, para mostrar mais dela.
- Antes da luta, ela respira no fundo do fosso.
- Nenhum mob entra na luta.

### Avisos
- Todos os golpes da Boiúna são fortes ou de área: marca no chão, exatamente igual à área atingida, e aviso de pelo menos 1 s (`03-regras.md`). Por isso eles passam pelos pilares: atrás de um pilar, Nate não fica protegido.
- Antes de qualquer golpe, os olhos dela brilham.
- Cada ataque tem um som de aviso próprio.

### Fase 1: de frente
- A arena está iluminada. A Boiúna sai do fosso e alterna os ataques da tabela.
- A vida da fase 1 tem 4 partes. Cada parte derrubada deixa a Boiúna atordoada por alguns segundos, e esse é o momento seguro de ativar um pilar. Duração do atordoar: `11-balanceamento.md`. Atordoada, ela ruge e desaba com a cabeça no chão, na frente do fosso, com as estrelas em volta.
- Cada parte cai inteira: o golpe que passa do fim dela para ali. A parte seguinte só cai depois que um pilar acende para cada parte derrubada; até lá, os golpes não tiram vida, aparece "imune" e a parte fica cinza na barra. No primeiro atordoar, aparece a dica do pilar.
- Na fase 1, o corpo recebe golpes em volta do fosso o tempo todo (dá para bater da beira dele), e a cabeça, quando está no chão: depois do bote e atordoada.
- **Pilar:** Nate ativa segurando o botão de interagir por um tempo, parado, de braços estendidos, e uma corrente de luz vai do muiraquitã até o cristal; se levar um golpe ou soltar o botão, a ativação para. Dá para tentar sem atordoar a Boiúna, a qualquer hora da fase 1, mas o jeito seguro é atordoar antes. Pronto para ativar, o cristal pulsa. Tempo: `11-balanceamento.md`.
- Cada pilar ativo prende a Boiúna com uma corrente de luz, do cristal até o corpo dela, e ela fica mais agressiva: espera menos entre um ataque e outro. Intervalos: `11-balanceamento.md`.
- Ela alterna os três ataques, nunca o mesmo duas vezes seguidas.
- Com os 4 pilares ativos, começa a fase 2.

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Depois do golpe |
|--------|------|------|------|-------|-------|-----------------|
| Bote | forte | 60 de vida | linha do fosso até onde Nate está | a cabeça recua e os olhos brilham | longo | a cabeça fica no chão alguns segundos: janela para bater |
| Varrida de cauda | área | 40 de vida | um setor da arena | a cauda se ergue | longo | — |
| Cuspe de escuridão | área | 40 de vida | círculos em pontos da arena | a garganta incha | nenhum | ficam poças por alguns segundos, que deixam lento quem pisa |

### Fase 2: na escuridão
- A arena apaga. Nate só enxerga dentro do brilho da Luz Ancestral do muiraquitã (`05-itens.md`). Os cristais dos pilares continuam acesos, mais fracos, e as duas correntes que sobraram seguem presas a ela.
- A Boiúna some na escuridão e ataca de emboscada: entre um ataque e outro, fica escondida no fosso; um ataque começa a cada tantos segundos, numa ordem fixa de emboscadas e cercos (`11-balanceamento.md`).
- Na emboscada, a cabeça pode ser ferida desde o aviso, quando os olhos aparecem, até voltar para a escuridão; no cerco, enquanto dá a volta em Nate.
- A vida da fase 2 é uma barra só. Quando acaba, a prisão fecha, e vêm a cena final e os créditos (`02-core-loop.md`).
- A passagem da fase 1 para a 2 é uma cena curta, feita no motor (`10-arte-audio.md`): presa pelos 4 pilares, ela se debate no alto, rompe 2 das 4 correntes, ruge, a arena apaga e ela some no fosso.
- **A prisão fechando:** as correntes rompidas voltam, as quatro a puxam para o fundo, uma tampa de jade fecha o fosso e a luz volta. Depois, a cena final, os créditos e o resumo; Nate volta ao S4, com a arena vazia (`02-core-loop.md`). A vitória fica no jogo salvo na hora; se o jogo fechar antes do fim do resumo, o fim passa de novo ao voltar, sem a luta.

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Depois do golpe |
|--------|------|------|------|-------|-------|-----------------|
| Emboscada | forte | 60 de vida | linha até Nate | os olhos aparecem na borda da Luz Ancestral | longo | a cabeça fica exposta: janela para bater |
| Cerco | área | 40 de vida | anel em volta de Nate | o corpo começa a circular | curto | — |

No Cerco, Nate escapa saindo do anel antes de ele fechar: o corpo dá a volta nele, num anel que vai apertando, e fere quem ainda estiver dentro quando fecha.

### Morte de Nate
- Na fase 1, a luta recomeça do início.
- Na fase 2, Nate volta ao santuário e, ao entrar de novo na arena, a luta recomeça na fase 2, com os 4 pilares ativos. A fase 2 alcançada fica no jogo salvo.
- Nos dois casos, a porta abre de novo e a Boiúna volta a dormir no fosso.

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
