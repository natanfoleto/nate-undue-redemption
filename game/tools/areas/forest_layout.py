"""Rascunho do mapa do Bosque de Fungos em texto: cada caractere é um bloco (x para a direita, z para baixo,
o norte em cima). Confere se o caminho principal liga a chegada do elevador à saída pela passagem escura, e se
cada segredo é alcançável (os escuros, com a Luz Ancestral)."""
from collections import deque
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.dont_write_bytecode = True  # Sem __pycache__ dentro do repositório.
from shapes import roughen  # noqa: E402
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, 'forest_layout.txt')

W, H = 100, 76
grid = [['#'] * W for _ in range(H)]


def fill(x0, z0, x1, z1, ch):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            grid[z][x] = ch


def put(x, z, ch):
    grid[z][x] = ch


# 1) S1, na chegada do elevador: o frasco, a memória 1 e o elevador quebrado.
fill(4, 60, 19, 71, ',')
fill(6, 66, 8, 68, 'V')
put(16, 62, '1')
put(4, 71, 'U')
put(19, 71, 'U')
put(19, 60, 'u')
# Porta que só abre por um lado: o atalho do meio do Bosque de volta ao S1 (abre pelo lado de fora da sala).
fill(20, 64, 20, 65, 'D')
# 2) Corredor ao norte, com cogumelos de esporos dos dois lados e 2 lobos no fim.
fill(9, 50, 14, 59, '.')
put(9, 56, 's')
put(14, 53, 's')
put(11, 53, 'W')
put(13, 52, 'W')
put(8, 58, 'u')
put(15, 51, 'u')
# Desvio da Zarabatana, a oeste do corredor.
fill(6, 54, 8, 55, '.')
fill(1, 51, 5, 58, ',')
put(2, 52, 'z')
put(4, 57, 'W')
put(2, 55, 'K')
put(1, 58, 'U')
# 3) Sala do baú com a Lança marajoara, e o primeiro Necromante.
fill(4, 36, 21, 49, '.')
fill(5, 37, 9, 40, ',')
put(20, 37, 'C')
put(12, 39, 'N')
put(7, 45, 'K')
put(4, 36, 'U')
put(21, 49, 'U')
put(21, 36, 'u')
# Corredor até a arena 1.
fill(11, 30, 14, 35, '.')
# 4) Arena 1, que guarda o pergaminho de Fogo.
fill(4, 13, 21, 28, ',')
fill(11, 29, 14, 29, 'a')
fill(11, 12, 14, 12, 'b')
for x, z in [(6, 15), (19, 15), (6, 26), (19, 26), (12, 20)]:
    put(x, z, 'o')
put(4, 13, 'u')
put(21, 28, 'u')
# Sala do pergaminho de Fogo: o muiraquitã acorda.
fill(9, 4, 16, 11, '.')
put(12, 6, 'F')
put(9, 4, 'U')
put(16, 4, 'U')
# Canto escuro da Azagaia, logo ao lado: ensina a Luz Ancestral.
fill(3, 7, 8, 8, 'd')
fill(1, 1, 4, 6, 'd')
put(2, 2, 'j')
# 5) Corredor do mural 2, para o leste; o mural na parede norte.
fill(17, 6, 40, 9, '.')
fill(26, 5, 33, 5, 'M')
put(29, 5, 'm')
put(30, 8, 'K')
put(36, 7, 'K')
put(22, 9, 'u')
put(38, 6, 'u')
# 6) Caverna dos cogumelos gigantes.
fill(41, 2, 64, 28, ',')
fill(46, 6, 58, 24, '.')
for x, z in [(43, 5), (44, 18), (47, 26), (55, 3), (62, 14), (61, 27), (52, 12), (58, 21)]:
    put(x, z, 'U')
put(45, 23, 's')
put(60, 9, 's')
put(52, 15, 'W')
put(56, 7, 'W')
put(59, 25, 'N')
# Desvio do Manto, cercado de cogumelos de esporos.
fill(60, 2, 64, 5, '.')
put(62, 3, 'c')
for x, z in [(59, 3), (59, 6), (62, 6), (64, 7)]:
    put(x, z, 's')
# Mural 3, escondido atrás de uma fresta de 1 bloco na parede oeste da caverna.
fill(36, 1, 39, 3, '.')
put(40, 2, '.')
fill(35, 0, 40, 0, 'M')
put(37, 0, '3')
put(41, 3, 'U')
put(41, 1, 'U')
# Arena opcional, atrás de um canto escuro: guarda o pergaminho de Água.
fill(65, 14, 71, 15, 'd')
fill(73, 6, 90, 21, ',')
fill(72, 14, 72, 15, 'g')
fill(91, 12, 91, 13, 'k')
fill(92, 10, 96, 15, '.')
put(95, 12, 'A')
for x, z in [(75, 8), (88, 8), (75, 19), (88, 19), (81, 13)]:
    put(x, z, 'q')
put(73, 6, 'u')
put(90, 21, 'u')
# 7) Corredor ao sul da caverna e a sala do meio do Bosque.
fill(48, 29, 51, 36, '.')
put(48, 33, 's')
fill(40, 37, 55, 48, '.')
put(43, 40, 'K')
put(53, 46, 'K')
put(48, 47, 'W')
put(40, 37, 'U')
put(55, 48, 'U')
# Desvio do +1 coração, a leste da sala do meio.
fill(56, 41, 62, 42, '.')
fill(63, 38, 68, 45, ',')
put(66, 41, 'h')
put(64, 39, 'W')
put(65, 44, 'W')
put(68, 38, 'U')
# Atalho de volta ao S1: corredor do meio do Bosque até a porta que só abre por um lado.
fill(24, 44, 39, 45, '.')
fill(24, 46, 25, 65, '.')
fill(21, 64, 23, 65, '.')
put(26, 47, 'u')
put(23, 63, 'u')
# 8) S2, antes da arena da passagem escura: a memória 2.
fill(46, 49, 49, 53, '.')
fill(42, 54, 57, 63, ',')
put(50, 56, '2')
put(42, 63, 'U')
put(57, 54, 'u')
# 9) Arena 2, que guarda a passagem escura.
fill(58, 57, 58, 60, 'e')
fill(59, 50, 76, 65, ',')
fill(77, 57, 77, 60, 'f')
for x, z in [(61, 52), (74, 52), (61, 63), (74, 63), (68, 57)]:
    put(x, z, 'p')
put(59, 50, 'u')
put(76, 65, 'u')
# 10) Passagem escura até as Ruínas: exige a Luz Ancestral.
fill(78, 57, 95, 60, 'd')
fill(94, 57, 95, 60, 'x')

# Parede rachada com o +1 coração (volta com a Terra, na etapa 6): na parede oeste da sala do baú.
fill(1, 44, 2, 46, '.')
put(1, 45, 'H')
put(3, 45, 'X')

# Fenda de fungos que corta o corredor entre a caverna dos cogumelos e a sala do meio: o corredor passa por cima
# num pé de cogumelo caído (marcado nas alturas), com cerca dos dois lados (08-mapa).
fill(41, 30, 47, 35, '~')
fill(52, 30, 59, 35, '~')

FLOOR = set(".,dVxzjcAhHFC123mosqpLNKW")
WALKABLE = FLOOR | set("abefgkDdu")


def find(ch):
    return [(x, z) for z in range(H) for x in range(W) if grid[z][x] == ch]


def reachable(start, passable):
    seen = {start}
    queue = deque([start])
    while queue:
        x, z = queue.popleft()
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, nz = x + dx, z + dz
            if 0 <= nx < W and 0 <= nz < H and (nx, nz) not in seen and grid[nz][nx] in passable:
                seen.add((nx, nz))
                queue.append((nx, nz))
    return seen


def results(grid):
    """Cada conferência: o nome e se ela vale."""
    start = find('1')[0]
    # Sem a Luz Ancestral nem a Terra: o caminho principal até o pergaminho de Fogo.
    before_light = reachable(start, (WALKABLE - set("dD")) | set("."))
    with_light = reachable(start, WALKABLE - set("D") - set("X"))
    found = []
    for name, ch, area in [("pergaminho de Fogo", 'F', before_light), ("baú da Lança", 'C', before_light),
                           ("Zarabatana", 'z', before_light), ("S2", '2', with_light), ("saída", 'x', with_light),
                           ("Azagaia (escuro)", 'j', with_light), ("Manto", 'c', with_light),
                           ("+1 coração", 'h', with_light), ("mural 2", 'm', None), ("mural 3", '3', None),
                           ("pergaminho de Água", 'A', with_light)]:
        cells = find(ch)
        if area is None:
            # Murais ficam na parede: basta um vizinho alcançável.
            ok = any((x + dx, z + dz) in with_light for x, z in cells for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        else:
            ok = bool(cells) and all(cell in area for cell in cells)
        found.append((name, ok))
    # A porta liga o meio do Bosque ao S1: do lado de fora dela, a sala do S1 fica do outro lado.
    door = find('D')
    found.append(("porta com o S1 do outro lado", (door[0][0] - 1, door[0][1]) in before_light))
    found.append(("o canto escuro não se alcança sem a Luz", find('j')[0] not in before_light))
    found.append(("a saída não se alcança sem a Luz", find('x')[0] not in before_light))
    return found


def path_ok(grid):
    return all(ok for _, ok in results(grid))


def report(grid):
    for name, ok in results(grid):
        print(f"{name}: {'ok' if ok else 'FALHOU'}")




# Alturas (relevo): um dígito por bloco com a altura do chão; ^, v, > e < são rampas do próprio chão, que sobem para
# aquele lado (terrain_builder.gd).
heights = [['0'] * W for _ in range(H)]
for z in range(H):
    for x in range(W):
        if grid[z][x] != '#':
            heights[z][x] = '1'


def raise_area(x0, z0, x1, z1, h):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = str(h)


def ramp(x0, z0, x1, z1, direction):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = direction


# Embaixo: a chegada do elevador, o corredor norte, o desvio da Zarabatana, o atalho até a porta, o S2, a arena 2 e
# a passagem escura. O resto do Bosque fica 1 bloco acima, e o terraço do Manto, 2; no meio da caverna dos cogumelos,
# um morro também sobe a 2. Os corredores sobem em rampas longas de terra; o terraço e o morro, em rampas curtas que
# surgem sozinhas por todos os lados.
raise_area(0, 50, 23, 75, 0)
raise_area(24, 51, 25, 65, 0)
raise_area(40, 50, 99, 75, 0)
ramp(9, 50, 14, 51, '^')
ramp(24, 50, 25, 51, '^')
ramp(46, 49, 49, 50, '^')
raise_area(52, 2, 64, 8, 2)
# O pé de cogumelo caído sobre a fenda, na altura 1 (B).
for z in range(30, 36):
    for x in range(48, 52):
        heights[z][x] = 'B'
raise_area(47, 16, 52, 21, 2)

# Salas e corredores menos quadrados (08-mapa); as arenas ficam como estão.
ARENAS = [(3, 12, 22, 29), (72, 5, 91, 22), (58, 49, 77, 66)]


def outside_arenas(x, z):
    return not any(x0 <= x <= x1 and z0 <= z <= z1 for x0, z0, x1, z1 in ARENAS)


print('formas soltas (chão, parede):', roughen(grid, heights, '.,', '#', 11, path_ok, region=outside_arenas))
report(grid)
lines = ["".join(row).rstrip() for row in grid]
open(OUT, "w").write("\n".join(lines) + "\n")
with open(OUT.replace('_layout', '_heights'), 'w') as f:
    f.write('\n'.join(''.join(row) for row in heights) + '\n')
