from pathlib import Path

WIDTH = 1024
HEIGHT = 1024
NIGHT = (18, 8, 42)
MOON = (255, 203, 87)
OWL = (107, 74, 43)
OWL_DARK = (90, 59, 34)
CREAM = (255, 247, 232)
INK = (26, 18, 56)
BEAK = (255, 176, 74)


def put(pixels: bytearray, x: int, y: int, color: tuple[int, int, int]) -> None:
    if 0 <= x < WIDTH and 0 <= y < HEIGHT:
        index = (y * WIDTH + x) * 3
        pixels[index : index + 3] = bytes(color)


def fill_circle(pixels: bytearray, cx: int, cy: int, radius: int, color: tuple[int, int, int]) -> None:
    radius_sq = radius * radius
    for y in range(cy - radius, cy + radius + 1):
        for x in range(cx - radius, cx + radius + 1):
            if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius_sq:
                put(pixels, x, y, color)


def main() -> None:
    pixels = bytearray(bytes(NIGHT) * WIDTH * HEIGHT)
    fill_circle(pixels, 512, 220, 90, MOON)
    fill_circle(pixels, 512, 560, 250, OWL)
    fill_circle(pixels, 390, 520, 92, CREAM)
    fill_circle(pixels, 634, 520, 92, CREAM)
    fill_circle(pixels, 390, 528, 38, INK)
    fill_circle(pixels, 634, 528, 38, INK)
    fill_circle(pixels, 372, 510, 12, (255, 255, 255))
    fill_circle(pixels, 616, 510, 12, (255, 255, 255))
    fill_circle(pixels, 330, 360, 28, MOON)
    fill_circle(pixels, 694, 360, 28, MOON)
    fill_circle(pixels, 512, 620, 28, BEAK)
    fill_circle(pixels, 430, 360, 70, OWL_DARK)
    fill_circle(pixels, 594, 360, 70, OWL_DARK)

    ppm = Path('/tmp/cluegame-icon.ppm')
    ppm.write_bytes(b'P6\n%d %d\n255\n' % (WIDTH, HEIGHT) + pixels)

    for dest in (Path('resources'), Path('public')):
        dest.mkdir(exist_ok=True)


if __name__ == '__main__':
    main()
