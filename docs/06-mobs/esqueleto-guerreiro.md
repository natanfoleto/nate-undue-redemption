# Esqueleto Guerreiro

**Papel no jogo:** o soldado básico, de corpo a corpo e ritmo médio. São ossos despertados pela escuridão do predador, e não o corpo de uma pessoa do povo antigo.
**Descrição visual:** esqueleto blocado, com 2 blocos de altura e uma espada. O visual deixa claro que é uma criatura da escuridão do predador. Ossos cinza-escuros, com brilho roxo nos olhos e nas juntas; o Veterano tem ossos quase pretos e brilho mais forte (`10-arte-audio.md`).

## Atributos
Valores exatos: `11-balanceamento.md`.

| Atributo | Valor |
|----------|-------|
| Vida | média |
| Velocidade de movimento | média, abaixo da de Nate |
| Peso | leve |
| Percepção | média |

## Comportamento e habilidades
- Anda até Nate e ataca com a espada.

| Ataque | Tipo | Dano | Área | Aviso | Recuo | Efeito |
|--------|------|------|------|-------|-------|--------|
| Golpe de espada | comum | 20 de vida | setor curto à frente | ergue a espada, pelo menos 0,6 s | curto | — |

- **Invocado:** o Necromante faz esqueletos surgirem do chão. Esses se desfazem quando o Necromante morre (`necromante.md`).

### Variante: Esqueleto Veterano
- Mais vida, com outra cor.
- Dá 2 golpes seguidos; cada golpe tem o próprio aviso de pelo menos 0,6 s.
- Aparece nas Ruínas e nas arenas opcionais.

## Interações
- **Nate:** só fere com o golpe avisado. Qualquer golpe o interrompe (peso leve).
- **Necromante:** pode ser invocado por ele.
- **Armadilhas:** contorna andando e cai quando é empurrado.

## Animações necessárias
- Parado.
- Andar.
- Erguer a espada (aviso).
- Golpe de espada; segundo golpe (Veterano).
- Levar golpe.
- Desmontar (morte e quando o Necromante morre).
- Surgir do chão (invocado).

## Sons necessários
- Ossos chacoalhando ao andar.
- Espada cortando o ar.
- Acerto.
- Desmontar.
- Surgir do chão.

## Assets necessários
- Modelo do esqueleto e da espada, definidos por código.
- Cores do Esqueleto Veterano.
