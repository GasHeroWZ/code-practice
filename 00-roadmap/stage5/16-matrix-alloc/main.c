#include <stdio.h>
#include <stdlib.h>

/* 题目: 动态分配二维数组
 * 输入: n m
 * 输出: n 行, 第 i 行 j 列的值是 i*m+j, 每个数后跟一个空格
 * 要求: 用 int** 分配 n 行指针 + 每行 m 个 int
 *       结束时先 free 每一行, 再 free 行指针数组(顺序不能反)
 * 提示: 这是内存泄漏和野指针的高发题, 建议用 gdb 或仔细检查 free 次数
 */
int main(void)
{
    int n = 0, m = 0;
    if (scanf("%d %d", &n, &m) != 2 || n <= 0 || m <= 0) return 0;

    int** a = (int**)malloc(sizeof(int*) * n);
    if (a == NULL) return 1;
    for (int i = 0; i < n; ++i) {
        a[i] = (int*)malloc(sizeof(int) * m);
        if (a[i] == NULL) return 1;
    }

    /* TODO: 填充 a[i][j] = i*m + j, 并按要求输出 */

    for (int i = 0; i < n; ++i) free(a[i]);
    free(a);
    return 0;
}