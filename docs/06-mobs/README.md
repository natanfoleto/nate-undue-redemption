# Mobs

Regras comuns aos mobs e distribuição por área. Cada criatura tem a própria ficha nesta pasta. Os números exatos (vida, velocidade, tempos e recuo) ficam em `11-balanceamento.md`.

## Bestiário
| Mob | Papel | Peso | Aparece primeiro em | Ficha |
|-----|-------|------|---------------------|-------|
| Lobo | corpo a corpo rápido, em bando de 2 a 4 | leve | Prólogo | `lobo.md` |
| Esqueleto Guerreiro | corpo a corpo; o soldado básico | leve | Mina | `esqueleto-guerreiro.md` |
| Necromante | ataque à distância e invocação; alvo prioritário | leve | Bosque de Fungos | `necromante.md` |
| Golem de Pedra | tanque pesado, com golpes em área | pesado | Ruínas | `golem-de-pedra.md` |

## Origem e tom
- **Lobos:** bichos de Agartha, assustados, que fogem do predador e sobem pela fenda. Na superfície, atacam rebanhos (`01-historia.md`).
- **Esqueletos, Necromantes e Golens:** nascem da escuridão do predador, que acordou antes da hora. Não são pessoas nem antepassados do povo antigo, e o visual precisa deixar isso claro (`10-arte-audio.md`). Quanto mais perto da prisão, mais deles.

## Regras comuns

### Comportamento base
- O mob nota Nate quando ele entra na percepção sem parede no meio, e então o persegue.
- Se perde Nate de vista por alguns segundos, volta ao lugar de antes, sem recuperar vida. Tempo: `11-balanceamento.md`.
- Golpes, avisos, recuo e efeitos seguem `03-regras.md`.

### Ataques em grupo
No máximo 5 mobs preparam ataque contra Nate ao mesmo tempo; os outros cercam e esperam a vez. Projéteis contam; invocar, não.

### Armadilhas
Andando, os mobs contornam as armadilhas. Empurrados por golpes ou magias, caem nelas.

### Variantes
Uma por tipo, nas Ruínas e nas arenas opcionais. Cada uma usa o mesmo modelo, com outra cor, mais vida ou dano e um ajuste.

| Variante | Ajuste |
|----------|--------|
| Lobo Alfa | maior e com mais vida; o salto é forte (2 corações, com marca no chão) |
| Esqueleto Veterano | mais vida; dá 2 golpes seguidos |
| Necromante Ancião | lança a praga em leque de 3 |
| Golem Ancião | maior e com mais vida; o abalo tem raio maior |

## Distribuição por área
Um tipo novo de mob por área: uma coisa nova por vez (`04-player.md`).

| Área | Mobs | Novidade |
|------|------|----------|
| Prólogo | 1 Lobo | a primeira luta |
| Mina | Lobo e Esqueleto Guerreiro | lutas leves, porque ainda não há cura |
| Bosque de Fungos | Lobo, Esqueleto Guerreiro e Necromante | o Necromante, alvo prioritário |
| Ruínas | os 4 tipos e as variantes | o Golem de Pedra e as variantes |
| Arenas opcionais | variantes | o desafio extra |

Mobs por encontro e ondas de cada arena: `08-mapa.md`.

## Fauna de cenário
- Uma espécie de dinossauro herbívoro vive no Bosque de Fungos, sem lutar. Ela mantém o mundo perdido de A Era do Gelo 3 (`01-historia.md`).
- Herbívoro de pescoço longo, com cerca de 5 blocos de altura, verde-musgo com manchas que brilham fraco; come cogumelos (`10-arte-audio.md`).
- Animações: parado, andar devagar e comer.

## Fora do escopo inicial
- A criatura poupada no prólogo voltar mais tarde para ajudar Nate (ideia opcional do `01-historia.md`).
