#include <stdio.h>

/* 题目: 数组统计
 * 输入: n, 然后 n 个整数
 * 输出: max=X min=Y avg=Z   (Z 保留两位小数)
 * 要求: 实现 Stats, 用指针带回三个结果
 * 提示: 一次遍历即可; avg 注意用 double 转换
 */
void Stats(int a[], int n, int* max, int* min, double* avg)
{
    /* TODO */
    (void)a; (void)n; (void)max; (void)min; (void)avg;
}

int main(void)
{
    int n = 0;
    int a[100];
    if (scanf("%d", &n) != 1 || n <= 0 || n > 100) return 0;
    for (int i = 0; i < n; ++i) scanf("%d", &a[i]);

    int max = 0, min = 0;
    double avg = 0.0;
    Stats(a, n, &max, &min, &avg);
    printf("max=%d min=%d avg=%.2f\n", max, min, avg);
    return 0;
}