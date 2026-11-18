#include <stdio.h>

/* 题目: 打印乘法表
 * 输入: n (1..9)
 * 输出: n 行, 第 i 行打印 i 个式子, 每个式子格式 "%d*%d=%-3d"
 *       行末不能有多余空格, 最后一行后有一个换行
 * 示例 (n=3):
 *   1*1=1
 *   1*2=2  2*2=4
 *   1*3=3  2*3=6  3*3=9
 * 要求: 实现 PrintTable, 用嵌套循环
 * 注意: %-3d 是左对齐占 3 位, 用来对齐
 */
void PrintTable(int n)
{
    /* TODO */
    (void)n;
}

int main(void)
{
    int n = 0;
    if (scanf("%d", &n) != 1) return 0;
    PrintTable(n);
    return 0;
}