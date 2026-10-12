# Golem de Pedra

**Papel no jogo:** o tanque pesado. Tem muita vida e golpes fortes em área, e só é interrompido por golpes com recuo longo. É pedra despertada pela escuridão do predador.
**Descrição visual:** construto de pedra blocado, com 3 blocos de altura. O visual deixa claro que é pedra despertada pela escuridão do predador. Pedra cinza com rachaduras que brilham em roxo; o Ancião tem pedra escura e rachaduras mais largas (`10-arte-audio.md`).

## Atributos
Valores exatos: `11-balanceamento.md`.

| Atributo | Valor |
|----------|-------|
| Vida | muito alta |
| Velocidade de movimento | baixa |
| Peso | pesado |
| Percepção | média |

## Comportamento e habilidades
- Anda devagar até Nate e alterna os dois ataques.

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Efeito |
|--------|------|------|------|-------|-------|--------|
| Socão | forte | 2 corações | à frente, perto | marca no chão, pelo menos 1 s | longo | — |
| Abalo | área | 2 corações | círculo ao redor | marca no chão, pelo menos 1 s | curto | lento |

- **Resistência:** ignora o recuo curto. Só o 3º golpe do combo, a Azagaia marajoara e magias com recuo longo o empurram e interrompem (`03-regras.md`).

### Variante: Golem Ancião
- Maior e com mais vida, com outra cor.
- O abalo tem raio maior.
- Aparece nas Ruínas e nas arenas opcionais.

## Interações
- **Nate:** só fere com golpes avisados.
- **Armadilhas:** contorna andando; só cai nelas empurrado por recuo longo.

## Animações necessárias
- Parado.
- Andar.
- Socão: preparar e golpear.
- Abalo: preparar e golpear.
- Cambalear (empurrado por recuo longo).
- Desmoronar (morte).

## Sons necessários
- Passos pesados.
- Socão.
- Abalo.
- Pedra rachando ao levar golpe.
- Desmoronar.

## Assets necessários
- Modelo do golem, definido por código.
- Efeito do abalo.
- Pedaços de pedra ao desmoronar.
- Cores do Golem Ancião.
