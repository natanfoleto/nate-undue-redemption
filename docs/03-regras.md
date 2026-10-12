# Regras

Regras que valem para todas as entidades: atributos, vida e dano, golpes, recuo, invencibilidade e efeitos de status.

## Unidades
- **Distância:** blocos. 1 bloco é a aresta de um bloco do cenário.
- **Tempo:** segundos (s). **Velocidade:** blocos/s.
- **Vida e dano:** corações para Nate, pontos para os inimigos.

## Atributos
Lista-padrão para as fichas. Os valores ficam em cada ficha (`04-player.md`, `05-itens.md`, `06-mobs/`, `07-chefes/`).

### Nate
| Atributo | Unidade |
|----------|---------|
| Vida máxima | corações |
| Velocidade de movimento | blocos/s |
| Bônus de dano | % (soma de todos os bônus ativos) |
| Chance de crítico | % (base: 5%) |
| Cargas do frasco | cargas |
| Cura por carga | corações |

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
| Dano | corações (contra Nate) ou pontos (contra inimigos) |
| Área | forma (círculo, setor, retângulo ou projétil) e tamanho em blocos |
| Projétil | velocidade em blocos/s e alcance em blocos |
| Preparação | s |
| Tempo ativo | s |
| Recuperação | s |
| Recarga | s, quando houver |
| Recuo | nenhum, curto ou longo |
| Efeito de status | qual e por quanto tempo, quando houver |

Armadilhas têm os dois valores de dano: em corações, contra Nate, e em pontos, contra os mobs.

## Vida e dano

### Escala
- **Nate:** vida em corações inteiros. Cada golpe inimigo tira corações inteiros: golpe comum, 1; golpe forte, 2; golpe do chefe, até 3. Cura, melhorias e veneno também contam em corações.
- **Inimigos:** vida em pontos, mostrada em barra. O dano que Nate causa também é em pontos.
- Nada tira fração de coração. A armadura não reduz dano: dá corações extras e outros bônus (`05-itens.md`).
- Corações iniciais de Nate: `[A DEFINIR em 04-player]`.

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
- O crítico tem efeito e som próprios: `[A DEFINIR em 10-arte-audio]`.

**Dano contra Nate:** sem sorte. Cada golpe tira sempre os mesmos corações.

### Quem fere quem
| Origem do golpe | Fere Nate | Fere mobs |
|-----------------|-----------|-----------|
| Nate | não | sim |
| Mobs | sim | não |
| Armadilhas e perigos do cenário | sim | sim |

- Dá para atrair ou empurrar inimigos para armadilhas.
- Se os mobs desviam das armadilhas sozinhos: `[A DEFINIR em 06-mobs]`.

## Golpes

### Colisão
- Calculada no plano do chão, porque o jogo é jogado como 2D. Formas de área: círculo, setor, retângulo ou projétil.
- Todo golpe tem três tempos: preparação (o aviso), tempo ativo (quando fere) e recuperação.
- Acerta todos os alvos na área, cada um no máximo uma vez.
- Paredes bloqueiam golpes e projéteis.
- Encostar num inimigo não fere. Só golpes avisados ferem.

### Aviso
Todo golpe inimigo é avisado antes de ferir (pilar 2).

| Golpe | Como avisa | Aviso mínimo |
|-------|------------|--------------|
| Comum (tira 1 coração) | pose, brilho e som | 0,6 s |
| Forte (tira 2 corações ou mais) ou de área | marca no chão, exatamente igual à área que vai ferir, desde o começo da preparação | 1 s |

- O aviso conta do início da pose até o primeiro instante em que o golpe pode ferir. Em projéteis, conta até o disparo; o voo dá tempo extra.
- Golpes comuns dependem de poses bem legíveis (`06-mobs/`).
- Visual da marca no chão: `[A DEFINIR em 10-arte-audio]`.

### Recuo e interrupção
- Cada golpe tem um recuo: nenhum, curto (1 bloco) ou longo (3 blocos).
- Cada alvo tem um peso, que decide o que o recuo faz com ele:

| Peso | Recuo curto | Recuo longo |
|------|-------------|-------------|
| Leve | empurra e interrompe | empurra e interrompe |
| Pesado | nada | empurra e interrompe |
| Chefe | nada | nada, salvo o que `07-chefes/` definir |

- **Interrompido:** perde o golpe que preparava e fica 0,4 s sem agir.
- **Nate:** é empurrado conforme o golpe e perde o controle por 0,2 s a cada golpe que leva.
- Bater primeiro interrompe mobs leves. Mobs pesados só são interrompidos por golpes com recuo longo (quais: `04-player.md` e `05-itens.md`).

### Invencibilidade após dano
- Depois de levar um golpe, Nate pisca e não leva dano por 1 s. Pode andar, atacar e esquivar normalmente; os 0,2 s sem controle contam dentro desse 1 s.
- Inimigos não têm invencibilidade após dano.
- Invencibilidade durante a esquiva: `[A DEFINIR em 04-player]`.

## Efeitos de status

### Lista
| Efeito | O que faz | Fonte |
|--------|-----------|-------|
| Atordoado | não se move nem ataca | clarão da Muiraquitã da Luz |
| Lento | anda à metade da velocidade | `[A DEFINIR em 05-itens ou 06-mobs]` |
| Veneno | perde vida aos poucos; Nate perde corações inteiros | `[A DEFINIR em 05-itens ou 06-mobs]` |

### Regras gerais
- A intensidade de cada efeito é fixa. A duração, e no veneno também o ritmo, vem de quem aplica.
- O mesmo efeito não acumula: aplicar de novo renova a duração.
- Efeitos diferentes valem ao mesmo tempo.
- Efeito sem fonte no jogo é cortado.
- Ícone, cor e som de cada efeito: `[A DEFINIR em 09-interface e 10-arte-audio]`.

### Quem sofre o quê
| Alvo | Atordoado | Lento | Veneno |
|------|-----------|-------|--------|
| Nate | nunca | sim | sim, mas não tira o último coração |
| Mobs | sim | sim | sim |
| Chefe | imune | imune | imune |

- O chefe só sofre um efeito onde a luta for desenhada para isso (`07-chefes/`).
- Como mostrar que o chefe é imune: `[A DEFINIR em 09-interface]`.
