# Lobo

**Papel no jogo:** o mob rápido de bando e o primeiro inimigo do jogo. É um bicho de Agartha, assustado, que foge do predador e sobe pela fenda; na superfície, ataca rebanhos.
**Descrição visual:** lobo blocado, com 1 bloco de altura. Cinza-escuro, com olhos âmbar; o Alfa é preto, com os olhos mais fortes (`10-arte-audio.md`).

## Atributos
Valores exatos: `11-balanceamento.md`.

| Atributo | Valor |
|----------|-------|
| Vida | baixa |
| Velocidade de movimento | alta, perto da de Nate |
| Peso | leve |
| Percepção | alta |

## Comportamento e habilidades
- Anda em bando de 2 a 4. O bando cerca Nate, e cada lobo ataca quando chega a vez dele (no máximo 5 atacando, `README.md`).

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Efeito |
|--------|------|------|------|-------|-------|--------|
| Salto com mordida | comum | 20 de vida | salto curto em linha à frente | abaixa e rosna, pelo menos 0,6 s | curto | — |

- **Prólogo:** um lobo sozinho ataca Nate na borda da mina. Quando a vida dele baixa até um limite, ele foge mancando pela fenda, e Nate o segue. Limite: `11-balanceamento.md`.

### Variante: Lobo Alfa
- Maior e com mais vida, com outra cor.
- O salto é forte: 40 de vida e recuo longo, com marca no chão e aviso de pelo menos 1 s.
- Aparece nas Ruínas e nas arenas opcionais.

## Interações
- **Nate:** só fere com o salto avisado; encostar não fere (`03-regras.md`). Qualquer golpe o interrompe (peso leve).
- **Outros mobs:** não fere nenhum.
- **Armadilhas:** contorna andando e cai quando é empurrado.

## Animações necessárias
- Parado.
- Andar e correr.
- Abaixar e rosnar (aviso).
- Salto com mordida.
- Levar golpe (empurrado e interrompido).
- Morrer.
- Fugir mancando (prólogo).

## Sons necessários
- Rosnado (aviso).
- Mordida.
- Ganido ao levar golpe.
- Morte.

## Assets necessários
- Modelo do lobo, definido por código.
- Cores do Lobo Alfa.
