#include <stdio.h>

/* 题目: 复数结构体与运算
 * 输入: 四个整数 r1 i1 r2 i2
 * 输出: 三行: add=实部+虚部i / sub=... / mul=...
 * 格式: 虚部为负时输出 a-bi, 例如 add=3-2i
 * 要求: 定义 struct Complex, 实现 Add/Sub/Mul, 以及一个 Print 函数
 * 提示: (a+bi)(c+di) = (ac-bd) + (ad+bc)i
 * 注意: 打印时如果虚部是 0, 输出 a+0i 而不是 a
 */
struct Complex {
    int r;
    int i;
};

struct Complex Add(struct Complex x, struct Complex y)
{
    struct Complex z = {0, 0};
    /* TODO */
    (void)x; (void)y;
    return z;
}

struct Complex Sub(struct Complex x, struct Complex y)
{
    struct Complex z = {0, 0};
    /* TODO */
    (void)x; (void)y;
    return z;
}

struct Complex Mul(struct Complex x, struct Complex y)
{
    struct Complex z = {0, 0};
    /* TODO */
    (void)x; (void)y;
    return z;
}

void Print(const char* label, struct Complex z)
{
    /* TODO: 输出 label=实部+虚部i, 虚部为负时用 - 号 */
    (void)label; (void)z;
}

int main(void)
{
    struct Complex x = {0, 0}, y = {0, 0};
    if (scanf("%d %d %d %d", &x.r, &x.i, &y.r, &y.i) != 4) return 0;
    Print("add", Add(x, y));
    Print("sub", Sub(x, y));
    Print("mul", Mul(x, y));
    return 0;
}