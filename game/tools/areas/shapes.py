"""Formas mais soltas para os rascunhos das áreas (08-mapa): as paredes das salas e dos corredores ganham reentrâncias
e saliências, para nada parecer uma caixa. Tudo é fixo: o mesmo rascunho sai sempre igual.

roughen() muda o rascunho e as alturas juntos: a reentrância fica na altura do chão de onde ela sai; perto de
objetos, portas, murais, escadas, rampas e pontes nada muda."""
import math

SIDES = ((1, 0), (-1, 0), (0, 1), (0, -1))


def _hash(x, z, salt):
    h = (x * 374761393 + z * 668265263 + salt * 1442695041) & 0xFFFFFFFF
    h = ((h ^ (h >> 13)) * 1274126177) & 0xFFFFFFFF
    return ((h ^ (h >> 16)) & 0xFFFFFFFF) / 0xFFFFFFFF


def smooth(x, z, scale, salt=0):
    """Ruído suave de 0 a 1: valores sorteados numa grade de [scale] blocos, misturados entre os cantos."""
    gx, gz = x / scale, z / scale
    x0, z0 = math.floor(gx), math.floor(gz)
    tx, tz = gx - x0, gz - z0
    tx, tz = tx * tx * (3 - 2 * tx), tz * tz * (3 - 2 * tz)
    top = _hash(x0, z0, salt) * (1 - tx) + _hash(x0 + 1, z0, salt) * tx
    down = _hash(x0, z0 + 1, salt) * (1 - tx) + _hash(x0 + 1, z0 + 1, salt) * tx
    return top * (1 - tz) + down * tz


def roughen(grid, heights, floor, wall, salt, check, carve=0.6, deep=0.74, grow=0.3, region=None):
    """Reentrâncias: a parede ([wall]) encostada num chão ([floor]) vira esse chão onde o ruído passa de [carve], e a
    de trás dela também onde passa de [deep], desde que sobre parede atrás (a reentrância nunca abre caminho novo).
    Saliências: o chão encostado na parede vira parede onde o ruído fica abaixo de [grow], se o lugar tiver 6 blocos
    ou mais de fundo e [check](grid) (o caminho principal e os segredos) continuar valendo. [region](x, z) limita as
    mudanças a uma parte do mapa. Devolve quantos blocos viraram chão e quantos viraram parede."""
    H, W = len(grid), len(grid[0])

    def inside(x, z):
        return 0 <= x < W and 0 <= z < H

    def at(x, z):
        return grid[z][x] if inside(x, z) else ' '

    def plain(x, z):
        # Bloco comum: chão ou parede sem nada, e sem escada, rampa ou ponte nas alturas.
        ch = at(x, z)
        return (ch in floor or ch == wall) and heights[z][x] in '0123456789'

    def calm(x, z):
        # Nada especial a 2 blocos.
        return all(plain(x + dx, z + dz) or at(x + dx, z + dz) == ' ' for dz in range(-2, 3) for dx in range(-2, 3))

    def allowed(x, z):
        return inside(x, z) and calm(x, z) and (region is None or region(x, z))

    def thick(x, z, dx, dz):
        # A parede continua atrás do bloco, de frente e nas duas diagonais.
        px, pz = dz, dx
        return all(at(x + dx + s * px, z + dz + s * pz) == wall for s in (-1, 0, 1))

    # Reentrâncias, decididas no rascunho de antes e aplicadas juntas. Cada uma tem 2 blocos de largura ou mais (nada
    # de fresta), e o fundo só afunda no meio dela, para a curva sair arredondada.
    first = {}
    for z in range(H):
        for x in range(W):
            if grid[z][x] != wall or not allowed(x, z):
                continue
            for dx, dz in SIDES:
                fx, fz = x - dx, z - dz
                if at(fx, fz) in floor and thick(x, z, dx, dz) and smooth(x, z, 3.5, salt) > carve:
                    first[(x, z)] = (dx, dz, fx, fz)
                    break
    carved = []
    for (x, z), (dx, dz, fx, fz) in first.items():
        px, pz = dz, dx
        if (x + px, z + pz) not in first and (x - px, z - pz) not in first:
            continue
        carved.append((x, z, fx, fz))
        bx, bz = x + dx, z + dz
        middle = (x + px, z + pz) in first and (x - px, z - pz) in first
        if middle and smooth(bx, bz, 3.5, salt) > deep and allowed(bx, bz) and thick(bx, bz, dx, dz):
            carved.append((bx, bz, fx, fz))
    for x, z, fx, fz in carved:
        grid[z][x] = grid[fz][fx]
        heights[z][x] = heights[fz][fx]
    # Saliências, uma de cada vez, conferindo o caminho a cada uma.
    grown = 0
    for z in range(H):
        for x in range(W):
            if grid[z][x] not in floor or not allowed(x, z) or smooth(x, z, 3.0, salt + 1) > grow:
                continue
            for dx, dz in SIDES:
                if at(x + dx, z + dz) != wall:
                    continue
                depth = 0
                while at(x - dx * (depth + 1), z - dz * (depth + 1)) in floor:
                    depth += 1
                if depth < 6:
                    continue
                old = grid[z][x]
                grid[z][x] = wall
                if check(grid):
                    grown += 1
                else:
                    grid[z][x] = old
                break
    return len(carved), grown
