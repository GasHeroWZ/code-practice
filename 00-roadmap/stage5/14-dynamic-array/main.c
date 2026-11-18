#include <stdio.h>
#include <stdlib.h>

/* 题目: 动态数组（手写可变长数组）
 * 输入: n, 然后 n 个整数
 * 输出: 两行: sum=总和 / count=元素个数
 * 要求: 用 malloc 分配初始容量 4, 满了用 realloc 翻倍, 全部读完
 *       必须检查 malloc/realloc 是否返回 NULL
 *       程序结束前必须 free
 * 提示: 这就是第 26 讲动态顺序表的雏形, 学会这题顺序表就没难度
 */
int main(void)
{
    int n = 0;
    if (scanf("%d", &n) != 1 || n <= 0) return 0;

    int capacity = 4;
    int* a = (int*)malloc(sizeof(int) * capacity);
    if (a == NULL) { printf("malloc fail\n"); return 1; }
    int size = 0;
    long long sum = 0;

    for (int i = 0; i < n; ++i) {
        int v = 0;
        if (scanf("%d", &v) != 1) break;
        /* TODO: 如果 size == capacity, 用 realloc 扩容(capacity*2), 并更新 capacity */
        /* TODO: 把 v 放进数组, size++, sum += v */
        (void)v;
    }

    printf("sum=%lld\ncount=%d\n", sum, size);
    free(a);
    a = NULL;
    return 0;
}