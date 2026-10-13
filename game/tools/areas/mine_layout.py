"""Rascunho do mapa do prólogo e da Mina em texto: cada caractere é um bloco (x para a direita, z para baixo,
o norte em cima). Confere se o caminho principal liga o começo ao elevador."""
from collections import deque
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.dont_write_bytecode = True  # Sem __pycache__ dentro do repositório.
from shapes import roughen  # noqa: E402

W, H = 64, 126
grid = [[' '] * W for _ in range(H)]


def fill(x0, z0, x1, z1, ch):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            grid[z][x] = ch


def put(x, z, ch):
    grid[z][x] = ch


# Pedra maciça da Mina; as salas e corredores são escavados nela.
fill(0, 0, W - 1, 92, '#')

# 8) Sala do elevador, no fim da Mina.
fill(33, 2, 44, 9, 'w')
fill(37, 3, 39, 5, 'V')
fill(36, 10, 41, 10, 'a')            # portão de saída da arena (abre ao vencer)
# 7) Arena da Mina.
fill(30, 11, 47, 26, '.')
for x, z in [(31, 12), (46, 12), (31, 25), (46, 25), (38, 18)]:
    put(x, z, 'o')
fill(37, 27, 40, 27, 'a')            # portão de entrada da arena (fecha quando a luta começa)
# 6) Túnel do mural 1: a mina encontra os túneis do povo antigo.
fill(37, 28, 40, 37, '.')
fill(36, 30, 36, 35, 'M')
fill(41, 30, 41, 35, 'M')
# 5) Sala do baú com o Colete de minerador, e o desvio secreto da Picareta.
fill(31, 38, 46, 47, 'w')
put(45, 39, 'C')
put(33, 44, 'W')
put(43, 45, 'W')
fill(21, 42, 30, 43, '.')            # desvio estreito
fill(16, 39, 20, 46, '.')
put(17, 42, 'p')
fill(47, 41, 47, 44, 'X')            # parede rachada: Armadura de minerador (volta com Terra)
# 4) Corredor das pedras que caem, subindo para o norte.
fill(37, 48, 40, 75, '.')
put(38, 66, 'r')
put(39, 58, 'r')
put(38, 52, 'K')
put(39, 50, 'W')
for z in (55, 63, 71):
    put(36, z, 'l')
# 3) Corredor depois do portão, para o leste.
fill(22, 72, 36, 75, '.')
put(30, 73, 'K')
# 2) Sala da Baladeira, cortada por uma vala: a alavanca fica do outro lado e só o tiro alcança.
fill(4, 66, 20, 70, '.')             # beirada da alavanca, do outro lado da vala
put(12, 66, 'L')
fill(4, 71, 20, 72, '~')             # vala
fill(4, 73, 20, 84, '.')
put(9, 80, 'b')
fill(21, 73, 21, 74, 'G')            # portão aberto pela alavanca
put(5, 82, 'l')
put(19, 75, 'l')
# 1) Saguão da entrada da Mina (ponto de retorno) e o corredor até a sala da Baladeira.
fill(22, 80, 34, 90, '.')
fill(27, 89, 28, 89, 'E')
put(23, 81, 'l')
put(33, 81, 'l')
fill(21, 82, 21, 85, '.')
# Fenda aberta pelo tremor, ligando a clareira ao saguão.
fill(27, 91, 28, 97, 'f')
put(27, 94, 'F')

# Prólogo: clareira na floresta, na entrada da velha mina.
fill(10, 92, 45, 125, 'T')
fill(10, 92, 45, 95, 'R')            # o morro onde a mina entra
fill(12, 98, 43, 123, 'g')
fill(12, 96, 43, 97, 'R')            # paredão de pedra com a entrada velha da mina
fill(18, 96, 21, 97, 'm')            # boca da mina, fechada com tábuas
fill(27, 96, 28, 97, 'f')            # a fenda
for x, z in [(15, 104), (39, 103), (14, 116), (41, 118), (22, 112), (34, 108)]:
    put(x, z, 'T')
fill(27, 91, 28, 97, 'f')            # a fenda atravessa o morro até o saguão
put(27, 94, 'F')
put(27, 120, 'S')
put(28, 102, 'P')

# Sala da Armadura de minerador, atrás da parede rachada da sala do baú (volta com a Terra).
fill(48, 40, 53, 45, '.')
put(51, 42, 'y')
# Arena opcional, atrás de uma parede rachada no túnel do mural 1 (volta com a Terra): guarda +1 carga.
fill(36, 31, 36, 32, 'X')
fill(25, 31, 35, 32, '.')
fill(24, 31, 24, 32, 'i')
fill(6, 20, 23, 35, '.')
fill(14, 19, 15, 19, 'j')
fill(12, 13, 17, 18, '.')
put(14, 15, 'q')
for x, z in [(8, 22), (21, 22), (8, 33), (21, 33), (14, 27)]:
    put(x, z, 'u')

# Canto escuro do +1 coração, a leste do saguão da entrada: volta com a Luz Ancestral (08-mapa).
fill(35, 84, 40, 85, 'd')
fill(41, 81, 45, 88, 'd')
put(43, 84, 'h')

# Lampiões nas paredes das salas: a luz precisa bastar para ler os avisos (10-arte-audio).
for x, z in [(30, 40), (47, 46), (34, 37), (33, 48), (36, 29), (29, 13), (29, 24), (48, 13), (48, 24),
             (32, 5), (45, 5), (15, 43), (28, 71)]:
    put(x, z, 'l')

# Galeria inundada entre a sala do Estilingue e o corredor das pedras: o corredor do portão passa por cima dela numa
# ponte de tábuas (marcada nas alturas), com cerca dos dois lados e postes de lampião que descem até a água (08-mapa).
fill(22, 60, 35, 71, '~')
fill(22, 76, 35, 78, '~')
for x, z in [(25, 71), (31, 71), (25, 76), (31, 76)]:
    put(x, z, 'l')

# Alturas (relevo): um dígito por bloco com a altura do chão; n, s, e, w são escadas de pedra que sobem para aquele
# lado; ^, v, > e < são rampas do próprio chão (terrain_builder.gd).
heights = [['0'] * W for _ in range(H)]
FLOOR_CHARS = set('.wgfVaGEFbpCWKolrPSdhyijqu~LmTX')


def raise_area(x0, z0, x1, z1, h):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = str(h)


def bridge(x0, z0, x1, z1, letter):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = letter


def ramp(x0, z0, x1, z1, direction):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = direction


# A Mina sobe no corredor das pedras: tudo ao norte dele fica 1 bloco mais alto, e o chão sobe numa rampa de terra.
for z in range(0, 59):
    for x in range(W):
        if grid[z][x] in FLOOR_CHARS:
            heights[z][x] = '1'
ramp(37, 59, 40, 60, '^')
# A beirada da alavanca, do outro lado da vala, fica na mesma altura: o tiro de estilingue passa por cima da vala.
# Morrinhos na clareira do prólogo: a grama sobe em rampa por todos os lados (as rampas surgem sozinhas).
raise_area(14, 104, 20, 110, 1)
raise_area(36, 113, 42, 120, 1)
raise_area(30, 105, 35, 110, 1)
# A ponte de tábuas do corredor do portão, sobre a galeria inundada, na altura 0 (A).
bridge(22, 72, 35, 75, 'A')

# Caminho principal: do começo ao elevador, com os portões abertos.
passable = set('.wgfVaGEFbpCWKolrPS')
TARGETS = [('elevador', 'V', True), ('baú', 'C', True), ('Baladeira', 'b', True), ('Picareta', 'p', True),
           ('alavanca (não deve alcançar)', 'L', False)]


def reach_counts(grid):
    start = next((x, z) for z in range(H) for x in range(W) if grid[z][x] == 'S')
    seen = {start}
    queue = deque([start])
    while queue:
        x, z = queue.popleft()
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, nz = x + dx, z + dz
            if 0 <= nx < W and 0 <= nz < H and (nx, nz) not in seen and grid[nz][nx] in passable:
                seen.add((nx, nz))
                queue.append((nx, nz))
    counts = []
    for name, ch, _ in TARGETS:
        cells = [(x, z) for z in range(H) for x in range(W) if grid[z][x] == ch]
        reach = [c for c in cells if any((c[0] + dx, c[1] + dz) in seen for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)))]
        counts.append((len(reach), len(cells)))
    return counts


def path_ok(grid):
    return all((got == total) == wanted for (got, total), (_, _, wanted) in zip(reach_counts(grid), TARGETS))



# Salas e corredores menos quadrados (08-mapa), nas galerias da Mina (terra e tábuas) e na clareira (a mata da borda
# entrando e saindo); as arenas ficam como estão.
ARENAS = [(29, 10, 48, 27), (5, 18, 24, 36)]


def outside_arenas(x, z):
    return not any(x0 <= x <= x1 and z0 <= z <= z1 for x0, z0, x1, z1 in ARENAS)


print('formas soltas na Mina (chão, parede):', roughen(grid, heights, '.w', '#', 3, path_ok, region=outside_arenas))
print('formas soltas na clareira (chão, parede):', roughen(grid, heights, 'g', 'T', 5, path_ok))

# Pedra que não encosta em nenhum chão vira vazio: só sobram as paredes.
walkable = set('.wgfVaGEFbpCWKolrPSM~LmXdhyijqu')
floorish = set('.wgfVaGEFbpCWKolrPSdhyijqu')
for z in range(H):
    for x in range(W):
        if grid[z][x] != '#':
            continue
        near = any(0 <= z + dz < H and 0 <= x + dx < W and grid[z + dz][x + dx] in floorish
                   for dz in (-1, 0, 1) for dx in (-1, 0, 1))
        if not near:
            grid[z][x] = ' '

for (name, _, _), (got, total) in zip(TARGETS, reach_counts(grid)):
    print(f'{name}: {got}/{total} alcançáveis')

with open(os.path.join(HERE, 'mine_layout.txt'), 'w') as f:
    f.write('\n'.join(''.join(row).rstrip() for row in grid) + '\n')
with open(os.path.join(HERE, 'mine_heights.txt'), 'w') as f:
    f.write('\n'.join(''.join(row) for row in heights) + '\n')
