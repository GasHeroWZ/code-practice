#include <stdio.h>

/* 题目: 统计二进制中 1 的个数
 * 输入: 一个非负整数
 * 输出: 一个整数
 * 要求: 实现 CountBits, 用位运算
 * 方法一: x & 1, 然后 x >>= 1
 * 方法二(更快): x & (x-1) 每次消掉最低位的 1, 循环次数等于 1 的个数
 * 建议: 两种都写一遍, 理解为什么方法二更快
 */
int CountBits(unsigned int x)
{
    /* TODO */
    (void)x;
    return 0;
}

int main(void)
{
    unsigned int x = 0;
    if (scanf("%u", &x) != 1) return 0;
    printf("%d\n", CountBits(x));
    return 0;
}