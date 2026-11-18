#include <stdio.h>

/* 题目: 结构体数组统计
 * 输入: n, 然后 n 行 "姓名(int) 分数"  —— 姓名用整数编号代替, 避免字符串输入干扰
 * 输出: 两行: avg=平均分(保留2位) / best=最高分者的姓名
 * 要求: 定义 struct Student { int id; int score; }; 实现函数求平均分和最高分者
 * 扩展: 想把 id 换成 char name[20] 的话, 自己改, 用例也得改
 */
struct Student {
    int id;
    int score;
};

double Average(struct Student* a, int n)
{
    /* TODO */
    (void)a; (void)n;
    return 0.0;
}

int BestId(struct Student* a, int n)
{
    /* TODO */
    (void)a; (void)n;
    return 0;
}

int main(void)
{
    int n = 0;
    struct Student a[100];
    if (scanf("%d", &n) != 1 || n <= 0 || n > 100) return 0;
    for (int i = 0; i < n; ++i) scanf("%d %d", &a[i].id, &a[i].score);
    printf("avg=%.2f\n", Average(a, n));
    printf("best=%d\n", BestId(a, n));
    return 0;
}