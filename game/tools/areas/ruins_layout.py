"""Rascunho do mapa das Ruínas em texto: cada caractere é um bloco (x para a direita, z para baixo, o norte em cima).
Confere se o caminho principal liga a chegada à saída depois do Selo, passando pela Terra antes da parede rachada,
se a ponte é o atalho de volta ao S3 e se cada segredo é alcançável."""
from collections import deque
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.dont_write_bytecode = True  # Sem __pycache__ dentro do repositório.
from shapes import roughen  # noqa: E402
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, 'ruins_layout.txt')

W, H = 100, 84
grid = [['#'] * W for _ in range(H)]


def fill(x0, z0, x1, z1, ch):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            grid[z][x] = ch


def put(x, z, ch):
    grid[z][x] = ch


# 1) Salão da chegada, vindo da passagem escura do Bosque: o baú do +1 carga e o primeiro encontro.
fill(6, 70, 19, 81, '.')
put(12, 80, 'R')
put(17, 72, 'C')
for x, z, ch in [(9, 73, 'K'), (15, 75, 'K'), (12, 71, 'W')]:
    put(x, z, ch)
for x, z in [(6, 70), (19, 70), (6, 81), (19, 81)]:
    put(x, z, 'J')
# 2) Corredor das lanças do chão, subindo para o norte: ensina a armadilha.
fill(10, 56, 15, 69, ',')
for z in (66, 63, 60):
    for x in range(10, 16):
        put(x, z, 'p')
put(13, 57, 'A')
# Desvio da carga: um nicho do lado das lanças.
fill(16, 60, 19, 62, '.')
put(18, 61, 'Q')
# 3) Salão do S3, no meio das Ruínas: a memória 3.
fill(4, 40, 21, 55, '.')
put(12, 44, '3')
for x, z in [(4, 40), (21, 40), (4, 55), (21, 55)]:
    put(x, z, 'J')
# Vão a leste do S3: a ponte de alavanca, que baixa do outro lado e vira atalho.
fill(22, 44, 27, 45, '.')
fill(23, 44, 26, 45, 'B')
# 4) Arena 1, que guarda o pergaminho de Terra.
fill(11, 34, 14, 39, ',')
fill(11, 34, 14, 34, 'a')
fill(4, 18, 21, 33, '.')
fill(11, 17, 14, 17, 'b')
for x, z in [(6, 20), (19, 20), (6, 31), (19, 31), (12, 25)]:
    put(x, z, '1')
# Sala do pergaminho de Terra.
fill(9, 9, 16, 16, '.')
put(12, 11, 'T')
put(9, 9, 'J')
put(16, 9, 'J')
# Nicho do +1 coração, a oeste da sala da Terra.
fill(3, 12, 8, 13, ',')
fill(1, 8, 4, 11, ',')
put(2, 9, 'h')
# 5) Parede rachada (exige Terra) e o corredor das minas antigas, para o leste e depois para o sul.
fill(17, 10, 17, 11, 'X')
fill(18, 10, 51, 11, ',')
for x, z, ch in [(28, 10, 'V'), (33, 11, 'V'), (37, 10, 'N')]:
    put(x, z, ch)
fill(39, 12, 40, 33, ',')
for z in (16, 28):
    put(39, z, 'p')
    put(40, z, 'p')
put(40, 22, 'G')
# 6) Salão antes da arena 2: a alavanca que baixa a ponte até o S3.
fill(28, 34, 45, 47, '.')
# A alavanca fica no canto norte: do lado do S3, as paredes do vão seguram o tiro (a Terra vem antes).
put(29, 36, 'L')
for x, z, ch in [(35, 37, 'A'), (41, 38, 'A'), (38, 44, 'V'), (43, 41, 'E')]:
    put(x, z, ch)
put(28, 34, 'J')
put(45, 47, 'J')
# Mural 6, escondido: uma fresta de 1 bloco na parede norte do salão.
put(34, 33, '.')
fill(32, 30, 36, 32, '.')
fill(32, 29, 36, 29, '6')
# +20 de vida, atrás de uma parede rachada na parede sul do salão.
fill(35, 48, 36, 48, 'X')
fill(32, 49, 39, 54, ',')
put(36, 52, 'k')
put(33, 53, 'V')
put(38, 50, 'V')
# 7) Arena 2, que guarda a sala do Selo.
fill(46, 38, 48, 41, '.')
fill(49, 38, 49, 41, 'e')
fill(50, 32, 67, 47, '.')
fill(68, 38, 68, 41, 'f')
for x, z in [(52, 34), (65, 34), (52, 45), (65, 45), (58, 39)]:
    put(x, z, '2')
# 8) Sala do Selo: o mural 4, a lasca do muiraquitã e o mural 5.
fill(69, 34, 80, 45, '.')
fill(72, 33, 77, 33, '4')
fill(72, 46, 77, 46, '5')
put(75, 39, 'S')
for x, z in [(69, 34), (80, 34), (69, 45), (80, 45)]:
    put(x, z, 'J')
# Saída: o caminho até a Grande Prisão (a parte jogável termina aqui até ela existir).
fill(81, 39, 92, 40, ',')
fill(91, 39, 92, 40, 'x')
# Segredo do Arco marajoara: 3 alavancas do outro lado de um vão, que só o tiro alcança, abrem o portão.
fill(52, 3, 66, 16, '.')
fill(52, 8, 66, 9, '~')
for x in (54, 59, 64):
    put(x, 4, 'l')
fill(67, 13, 67, 14, 'g')
fill(68, 11, 73, 16, '.')
put(71, 13, 'w')
for x, z in [(55, 14), (63, 12)]:
    put(x, z, 'W')
# Desvio da Couraça de cerâmica, cercado de lanças do chão.
fill(20, 74, 35, 75, ',')
for x in range(22, 35, 2):
    put(x, 74, 'p')
    put(x + 1, 75, 'p')
fill(36, 71, 41, 78, '.')
put(39, 74, 'c')
# Arena opcional, escondida atrás da sala da Couraça: guarda o pergaminho de Ar.
fill(42, 77, 49, 78, ',')
fill(50, 77, 50, 78, 'u')
fill(51, 66, 68, 79, '.')
fill(69, 72, 69, 73, 'v')
fill(70, 70, 74, 75, '.')
put(72, 72, 'Y')
for x, z in [(53, 68), (66, 68), (53, 77), (66, 77), (59, 72)]:
    put(x, z, '7')

# Fenda de lava que corta o corredor das minas antigas: o corredor passa por cima numa ponte de pedra (marcada nas
# alturas), com balaustrada dos dois lados (08-mapa).
fill(30, 23, 38, 26, '~')
fill(41, 23, 49, 26, '~')

FLOORISH = set(".,BRCKWAQ3a1bTJhXVNGpL6EOke2fS45xlgwcuv7Y~!")
WALK = set(".,RCKWAQ3a1bThVNGpLEOke2fSxwcuv7Y")


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
    """Cada conferência: o nome e se ela vale (as que dizem "não deve" valem quando o lugar não se alcança)."""
    start = find('R')[0]
    # Antes da Terra: a parede rachada (X) segura; a ponte (B) está levantada; o portão do Arco (g) fechado.
    no_earth = reachable(start, WALK)
    with_earth = reachable(start, WALK | set("X"))
    with_bow = reachable(start, WALK | set("XBg"))

    def ok(ch, area):
        cells = find(ch)
        return bool(cells) and all(cell in area for cell in cells)

    def near(ch, area):
        return any((x + dx, z + dz) in area for x, z in find(ch) for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)))

    found = []
    for name, ch, area in [("+1 carga (baú)", 'C', no_earth), ("S3", '3', no_earth), ("pergaminho de Terra", 'T', no_earth),
                           ("alavanca da ponte", 'L', with_earth), ("Selo", 'S', with_earth), ("saída", 'x', with_earth),
                           ("+1 carga", 'Q', no_earth), ("+1 coração", 'h', no_earth), ("Couraça", 'c', no_earth),
                           ("+20 de vida (parede rachada)", 'k', with_earth), ("Arco (alavancas)", 'w', with_bow),
                           ("pergaminho de Ar", 'Y', no_earth)]:
        found.append((name, ok(ch, area)))
    found.append(("Selo não alcança antes da Terra", not ok('S', no_earth)))
    found.append(("+20 de vida da parede rachada não alcança antes da Terra", not ok('k', no_earth)))
    found.append(("murais 4, 5 e 6", near('4', with_earth) and near('5', with_earth) and near('6', with_earth)))
    found.append(("alavancas do Arco do outro lado do vão", all(c not in with_earth for c in find('l'))))
    # Linha de tiro: do lado do S3, nenhum lugar acerta a alavanca da ponte (as paredes do vão seguram o tiro).
    lever = find('L')[0]
    target = (lever[0] + 0.5, lever[1] + 0.5)
    spots = [(x + 0.5, z + 0.5) for z in range(H) for x in range(W) if (x, z) in no_earth and x <= 22]
    found.append(("alavanca da ponte fora do tiro pelo lado do S3", all(blocked(spot, target) for spot in spots)))
    return found


def blocked(a, b):
    steps = 200
    for i in range(steps + 1):
        x = a[0] + (b[0] - a[0]) * i / steps
        z = a[1] + (b[1] - a[1]) * i / steps
        if grid[int(z)][int(x)] == '#':
            return True
    return False


def path_ok(grid):
    return all(ok for _, ok in results(grid))


def report(grid):
    for name, ok in results(grid):
        print(f"{name}: {'ok' if ok else 'FALHOU'}")


# Alturas (relevo): um dígito por bloco com a altura do chão; n, s, e, w são escadas de pedra que sobem para aquele
# lado (terrain_builder.gd). As Ruínas são construção: as subidas são escadarias.
heights = [['1'] * W for _ in range(H)]


def raise_area(x0, z0, x1, z1, h):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = str(h)


def stairs(x0, z0, x1, z1, direction):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            heights[z][x] = direction


# A chegada, o corredor das lanças, o desvio da Couraça e a arena opcional ficam embaixo; uma escadaria sobe ao
# salão do S3; a arena 2, a sala do Selo e a saída ficam mais um bloco acima.
raise_area(0, 56, 99, 83, 0)
stairs(10, 56, 15, 56, 'n')
raise_area(48, 30, 99, 48, 2)
stairs(47, 38, 47, 41, 'e')
# A ponte de pedra sobre a fenda de lava, na altura 1 (B).
for z in range(23, 27):
    for x in range(39, 41):
        heights[z][x] = 'B'

# Os túneis das minas antigas (o chão de cascalho) menos quadrados (08-mapa); os salões do povo antigo são
# construção e ficam retos, e as arenas ficam como estão.
ARENAS = [(3, 17, 22, 34), (49, 31, 68, 48), (50, 65, 69, 80)]


def outside_arenas(x, z):
    return not any(x0 <= x <= x1 and z0 <= z <= z1 for x0, z0, x1, z1 in ARENAS)


print('formas soltas (chão, parede):', roughen(grid, heights, ',', '#', 17, path_ok, region=outside_arenas))
report(grid)
lines = ["".join(row).rstrip() for row in grid]
open(OUT, "w").write("\n".join(lines) + "\n")
with open(OUT.replace('_layout', '_heights'), 'w') as f:
    f.write('\n'.join(''.join(row) for row in heights) + '\n')
