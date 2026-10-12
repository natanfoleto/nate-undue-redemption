# Necromante

**Papel no jogo:** o invocador à distância e o alvo prioritário. Quando ele morre, os esqueletos que invocou se desfazem, e por isso vale eliminá-lo primeiro. É uma criatura da escuridão do predador, e não uma pessoa do povo antigo.
**Descrição visual:** figura blocada de manto, com 2 blocos de altura e um cajado. O visual deixa claro que é uma criatura da escuridão do predador. Cores: `[A DEFINIR em 10-arte-audio]`.

## Atributos
Valores exatos: `[A DEFINIR em 11-balanceamento]`.

| Atributo | Valor |
|----------|-------|
| Vida | baixa |
| Velocidade de movimento | média |
| Peso | leve |
| Percepção | alta |

## Comportamento e habilidades
- Mantém distância: recua quando Nate chega perto. Distância: `[A DEFINIR em 11-balanceamento]`.

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Efeito |
|--------|------|------|------|-------|-------|--------|
| Praga | comum | 1 coração | projétil | ergue o cajado, pelo menos 0,6 s até o disparo; o voo dá tempo extra | nenhum | veneno |
| Invocar | área | — | marca no chão onde os esqueletos vão surgir | pelo menos 1 s | — | surgem Esqueletos Guerreiros |

- **Invocar:** mantém até 3 esqueletos invocados vivos ao mesmo tempo. Invocar não conta no limite de 5 mobs atacando (`README.md`). Recarga: `[A DEFINIR em 11-balanceamento]`.
- **Ao morrer:** os esqueletos que ele invocou se desfazem.

### Variante: Necromante Ancião
- Outra cor.
- Lança a praga em leque de 3.
- Aparece nas Ruínas e nas arenas opcionais.

## Interações
- **Nate:** só fere com a praga avisada. Qualquer golpe o interrompe (peso leve), inclusive enquanto invoca.
- **Esqueletos:** invoca e, ao morrer, desfaz os que invocou.
- **Armadilhas:** contorna andando e cai quando é empurrado.

## Animações necessárias
- Parado.
- Andar e recuar.
- Erguer o cajado (praga).
- Invocar (cajado no chão).
- Levar golpe.
- Morrer.

## Sons necessários
- Praga: lançar, voo e acerto.
- Invocar.
- Morte, junto com os esqueletos se desfazendo.

## Assets necessários
- Modelo do necromante e do cajado, definidos por código.
- Projétil da praga.
- Efeito da marca de invocação.
- Cores do Necromante Ancião.
