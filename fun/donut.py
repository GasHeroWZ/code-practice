"""
终端里的 3D 甜甜圈 —— 纯标准库，不需要装任何东西

运行:
    python donut.py            一直转，Ctrl+C 停止
    python donut.py --frames 3 只画 3 帧（测试用）

原理:
    1. 环面每个点由两个角度 u、v 决定（大圆 + 小圆管）
    2. 每帧用旋转矩阵把点转到新角度，再透视投影压到二维屏幕
    3. z 缓冲处理遮挡；用表面法线跟光源的夹角决定亮度，才有立体感
"""

import math
import sys
import time

CHARS = ".,-~:;=!*#$@"          # 亮度从暗到亮
WIDTH, HEIGHT = 64, 28          # 字符网格大小
R1, R2 = 1.0, 0.42              # 大圆半径、管半径
DIST = 4.5                       # 摄像机距离
FOCAL = 2.2                      # 焦距
LIGHT = (-0.35, 0.45, 0.82)     # 光源方向（左上偏前）


def render(angle_a: float, angle_b: float) -> str:
    """把环面投影成一帧字符画。angle_a 绕 X 轴、angle_b 绕 Y 轴。"""
    buf = [' '] * (WIDTH * HEIGHT)
    zbuf = [-1e9] * (WIDTH * HEIGHT)

    cos_a, sin_a = math.cos(angle_a), math.sin(angle_a)
    cos_b, sin_b = math.cos(angle_b), math.sin(angle_b)

    lu, lv, lw = LIGHT

    for iu in range(60):
        u = iu * 2 * math.pi / 60
        cos_u, sin_u = math.cos(u), math.sin(u)
        for iv in range(28):
            v = iv * 2 * math.pi / 28
            cos_v, sin_v = math.cos(v), math.sin(v)

            # 环面上的三维坐标
            x = (R1 + R2 * cos_v) * cos_u
            y = (R1 + R2 * cos_v) * sin_u
            z = R2 * sin_v

            # 表面法线（从管中心指向该点）
            nx = cos_v * cos_u
            ny = cos_v * sin_u
            nz = sin_v

            # 绕 X 轴旋转
            y1 = y * cos_a - z * sin_a
            z1 = y * sin_a + z * cos_a
            ny1 = ny * cos_a - nz * sin_a
            nz1 = ny * sin_a + nz * cos_a

            # 绕 Y 轴旋转
            x2 = x * cos_b + z1 * sin_b
            z2 = -x * sin_b + z1 * cos_b
            nx2 = nx * cos_b + nz1 * sin_b
            nz2 = -nx * sin_b + nz1 * cos_b

            # 透视投影
            depth = z2 + DIST
            if depth <= 0.1:
                continue
            scale = FOCAL / depth
            px = int(WIDTH / 2 + x2 * scale * WIDTH / 4.2)
            py = int(HEIGHT / 2 - y1 * scale * HEIGHT / 2.9)

            if not (0 <= px < WIDTH and 0 <= py < HEIGHT):
                continue

            idx = py * WIDTH + px
            if depth > zbuf[idx]:
                zbuf[idx] = depth
                # 法线与光源的夹角 → 亮度（负值和背光面压暗）
                lum = nx2 * lu + ny1 * lv + nz2 * lw
                t = max(lum, 0.0) ** 1.1
                buf[idx] = CHARS[min(int(t * (len(CHARS) - 1)), len(CHARS) - 1)]

    return "\n".join("".join(buf[r * WIDTH:(r + 1) * WIDTH]) for r in range(HEIGHT))


def main() -> None:
    frames = None
    if "--frames" in sys.argv:
        frames = int(sys.argv[sys.argv.index("--frames") + 1])

    # Windows 终端启用 ANSI，用于光标归位（原地刷新，不闪屏）
    use_ansi = False
    if sys.platform == "win32":
        try:
            import ctypes
            handle = ctypes.windll.kernel32.GetStdHandle(-11)
            if ctypes.windll.kernel32.SetConsoleMode(handle, 7):
                use_ansi = True
        except Exception:
            pass

    a = b = 0.0
    count = 0
    try:
        while frames is None or count < frames:
            frame = render(a, b)
            if use_ansi:
                sys.stdout.write("\x1b[H" + frame)
            else:
                sys.stdout.write(frame + "\n")
            sys.stdout.flush()
            a += 0.11
            b += 0.06
            count += 1
            time.sleep(0.03)
    except KeyboardInterrupt:
        pass
    print("\nGood night.")


if __name__ == "__main__":
    main()
