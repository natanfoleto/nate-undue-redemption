# Regras

Regras que valem para todas as entidades: atributos, vida e dano, golpes, recuo, invencibilidade e efeitos de status.

## Unidades
- **Distância:** blocos. 1 bloco é a aresta de um bloco do cenário.
- **Tempo:** segundos (s). **Velocidade:** blocos/s.
- **Vida e dano:** pontos, para Nate e para os inimigos.

## Atributos
Lista-padrão para as fichas. Os valores ficam em cada ficha (`04-player.md`, `05-itens.md`, `06-mobs/`, `07-chefes/`).

### Nate
| Atributo | Unidade |
|----------|---------|
| Vida máxima | pontos |
| Velocidade de movimento | blocos/s |
| Bônus de dano | % (soma de todos os bônus ativos) |
| Chance de crítico | % (base: 5%) |
| Cargas da poção de vida | cargas |
| Cura por carga | pontos |

### Mobs e chefe
| Atributo | Unidade |
|----------|---------|
| Vida | pontos |
| Velocidade de movimento | blocos/s |
| Peso | leve, pesado ou chefe |
| Percepção | blocos (distância em que nota Nate) |

### Todo golpe
Vale para golpes de Nate, mobs, chefe e armadilhas.

| Atributo | Unidade |
|----------|---------|
| Dano | pontos (contra Nate, sem sorte; contra inimigos, pela fórmula) |
| Área | forma (círculo, setor, retângulo ou projétil) e tamanho em blocos |
| Projétil | velocidade em blocos/s e alcance em blocos |
| Preparação | s |
| Tempo ativo | s |
| Recuperação | s |
| Recarga | s, quando houver |
| Recuo | nenhum, curto ou longo |
| Efeito de status | qual e por quanto tempo, quando houver |

Armadilhas têm os dois valores de dano: um contra Nate e outro contra os mobs.

## Vida e dano

### Escala
- **Nate:** vida em pontos, mostrada numa barra no HUD (`09-interface.md`). Os golpes inimigos tiram valores redondos: golpe comum, 20; golpe forte, 40; golpe do chefe, até 60. Cura, melhorias, veneno e a vida que volta fora de combate também contam em pontos (`04-player.md`).
- **Inimigos:** vida em pontos, mostrada em barra. O dano que Nate causa também é em pontos.
- A armadura não reduz dano: dá vida extra e outros bônus (`05-itens.md`).
- Vida inicial de Nate: 100 (`04-player.md`).

### Fórmula
**Dano que Nate causa:**

```
dano = dano do ataque × (1 + soma dos bônus em %) × variação × crítico
```

- **Bônus em %:** somam entre si antes de multiplicar.
- **Variação:** aleatória, de 0,9 a 1,1.
- **Crítico:** ×2, com chance base de 5%. Equipamento e melhorias podem aumentar a chance (`05-itens.md`).
- O resultado é arredondado para o inteiro mais próximo.
- Exemplo: espada 10, +20% de bônus, variação 1,05 e crítico → 10 × 1,2 × 1,05 × 2 = 25,2 → 25 pontos.
- O crítico mostra um número amarelo grande e faíscas amarelas, com um som de impacto agudo (`10-arte-audio.md`).

**Dano contra Nate:** sem sorte. Cada golpe tira sempre a mesma vida.

### Quem fere quem
| Origem do golpe | Fere Nate | Fere mobs |
|-----------------|-----------|-----------|
| Nate | não | sim |
| Mobs | sim | não |
| Armadilhas e perigos do cenário | sim | sim |

- Dá para atrair ou empurrar inimigos para armadilhas.
- Andando, os mobs contornam as armadilhas; empurrados, caem nelas (`06-mobs/`).

## Golpes

### Colisão
- Calculada no plano do chão, porque o jogo é jogado como 2D. Formas de área: círculo, setor, retângulo ou projétil.
- O chão tem platôs de 1 e 2 blocos, ligados por rampas do próprio chão (na natureza) e escadas (nas construções) (`08-mapa.md`). Um golpe só acerta quem está mais ou menos na mesma altura de quem bateu; o limite fica em `11-balanceamento.md`. Na beira de um platô, o próprio degrau segura os tiros.
- Todo golpe tem três tempos: preparação (o aviso), tempo ativo (quando fere) e recuperação.
- Acerta todos os alvos na área, cada um no máximo uma vez.
- Paredes bloqueiam golpes e projéteis. A exceção são os golpes da Boiúna, que passam pelos pilares da arena: a marca dela é sempre a área que ela atinge (`07-chefes/boiuna.md`).
- O projétil para no primeiro inimigo que acerta, salvo arma com efeito próprio (`05-itens.md`).
- Encostar num inimigo não fere. Só golpes avisados ferem.

### Aviso
Todo golpe inimigo é avisado antes de ferir (pilar 2).

| Golpe | Como avisa | Aviso mínimo |
|-------|------------|--------------|
| Comum (tira 20 de vida) | pose, brilho e som | 0,6 s |
| Forte (tira 40 ou mais) ou de área | marca no chão, exatamente igual à área que vai ferir, desde o começo da preparação | 1 s |

- O aviso conta do início da pose até o primeiro instante em que o golpe pode ferir. Em projéteis, conta até o disparo; o voo dá tempo extra.
- Golpes comuns dependem de poses bem legíveis (`06-mobs/`).
- A marca no chão é vermelho-alaranjada, com listras diagonais que vão enchendo até o golpe (`10-arte-audio.md`).

### Recuo e interrupção
- Cada golpe tem um recuo: nenhum, curto (1 bloco) ou longo (3 blocos).
- Cada alvo tem um peso, que decide o que o recuo faz com ele:

| Peso | Recuo curto | Recuo longo |
|------|-------------|-------------|
| Leve | empurra e interrompe | empurra e interrompe |
| Pesado | nada | empurra e interrompe |
| Chefe | nada | nada (`07-chefes/boiuna.md`) |

- **Interrompido:** perde o golpe que preparava e fica 0,4 s sem agir.
- **Nate:** é empurrado conforme o golpe e perde o controle por 0,2 s a cada golpe que leva.
- Bater primeiro interrompe mobs leves. Mobs pesados só são interrompidos por golpes com recuo longo (quais: `04-player.md` e `05-itens.md`).

### Invencibilidade após dano
- Depois de levar um golpe, Nate pisca e não leva dano por 1 s. Pode andar, atacar e esquivar normalmente; os 0,2 s sem controle contam dentro desse 1 s.
- Inimigos não têm invencibilidade após dano.
- Durante a esquiva, Nate fica invencível o dash inteiro, 0,4 s (`04-player.md`).

## Efeitos de status

### Lista
| Efeito | O que faz | Fonte |
|--------|-----------|-------|
| Atordoado | não se move nem ataca | magia Gelo |
| Lento | anda à metade da velocidade | magia Lamaçal; abalo do Golem de Pedra |
| Veneno | perde vida aos poucos; em Nate, 20 de uma vez | praga do Necromante |
| Queimadura | perde vida aos poucos | magias de Fogo: Bola de Fogo, Vapor, Magma e Tempestade de Fogo |

A queimadura é de Nate; o veneno é dos mobs.

### Regras gerais
- A intensidade de cada efeito é fixa. A duração, e no veneno e na queimadura também o ritmo, vem de quem aplica.
- Com a Água equipada, queimadura, veneno e lento duram metade do tempo em Nate (`05-itens.md`).
- O mesmo efeito não acumula: aplicar de novo renova a duração.
- Efeitos diferentes valem ao mesmo tempo.
- Efeito sem fonte no jogo é cortado.
- Cada efeito tem um ícone sobre quem sofre e, em Nate, também embaixo da barra de vida (`09-interface.md`). Cor, forma e som de cada efeito: `10-arte-audio.md`.

### Quem sofre o quê
| Alvo | Atordoado | Lento | Veneno | Queimadura |
|------|-----------|-------|--------|------------|
| Nate | nunca | sim | sim, mas não tira o último ponto de vida | sim, mas não tira o último ponto de vida |
| Mobs | sim | sim | sim | sim |
| Chefe | imune | imune | imune | imune |

- A única exceção do chefe é o atordoar no fim de cada parte da vida da fase 1, que faz parte da luta (`07-chefes/boiuna.md`).
- Quando um efeito não pega no chefe, aparece "imune" sobre ele (`09-interface.md`).
