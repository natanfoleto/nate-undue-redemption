"""Rascunho do mapa da Grande Prisão em texto: cada caractere é um bloco (x para a direita, z para baixo, o norte em
cima). Confere se a chegada, vinda da sala do Selo nas Ruínas, liga o S4, o mural 7 e a porta da Grande Prisão, e se
a arena, atrás da porta, tem o fosso no centro e os quatro pilares alcançáveis em volta dele."""
from collections import deque
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.dont_write_bytecode = True  # Sem __pycache__ dentro do repositório.
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, 'prison_layout.txt')

W, H = 44, 38
grid = [['#'] * W for _ in range(H)]


def fill(x0, z0, x1, z1, ch):
    for z in range(z0, z1 + 1):
        for x in range(x0, x1 + 1):
            grid[z][x] = ch


def put(x, z, ch):
    grid[z][x] = ch


# 1) Corredor da chegada, vindo da sala do Selo (a oeste); na ponta, a volta para as Ruínas.
fill(1, 18, 10, 19, '.')
fill(0, 18, 0, 19, 'x')
put(3, 18, 'R')
# 2) Antessala, de 12 × 12 blocos: o S4 com a memória 4, o mural 7 na parede norte e a porta da Grande Prisão na parede
# leste, de frente para o fosso.
fill(11, 13, 22, 24, '.')
put(14, 16, '4')
put(19, 12, '7')
fill(23, 17, 23, 20, 'D')
# 3) Arena da Boiúna, de 14 × 14 blocos (cabe na câmera): o fosso de 4 × 4 no centro, de onde ela sai, e um pilar de
# 2 × 2 de cada lado, a 5 blocos do centro.
fill(24, 12, 37, 25, ',')
fill(29, 17, 32, 20, '~')
for x0, z0 in [(30, 13), (30, 23), (25, 18), (35, 18)]:
    fill(x0, z0, x0 + 1, z0 + 1, 'P')

WALK = set('.,4RxD')


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


def near(ch, area):
    return any((x + dx, z + dz) in area for x, z in find(ch) for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)))


start = find('R')[0]
walk = reachable(start, WALK)
checks = [
    ("S4", all(cell in walk for cell in find('4'))),
    ("mural 7", near('7', walk)),
    ("porta da Grande Prisão", all(cell in walk for cell in find('D'))),
    ("volta às Ruínas", all(cell in walk for cell in find('x'))),
    ("os quatro pilares em volta do fosso", near('P', walk) and len(find('P')) == 16),
    ("o fosso no centro da arena", len(find('~')) == 16 and not near('~', reachable(start, WALK - set('D')))),
]
for name, ok in checks:
    print(f"{name}: {'ok' if ok else 'FALHOU'}")

# Alturas: a Grande Prisão é plana, construção do povo antigo.
heights = [['0'] * W for _ in range(H)]
lines = ["".join(row).rstrip() for row in grid]
open(OUT, "w").write("\n".join(lines) + "\n")
with open(OUT.replace('_layout', '_heights'), 'w') as f:
    f.write('\n'.join(''.join(row) for row in heights) + '\n')
