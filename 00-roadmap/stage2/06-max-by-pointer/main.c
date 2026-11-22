#include <stdio.h>

/* 题目: 用指针遍历数组找最大值
 * 输入: n, 然后 n 个整数
 * 输出: max=X index=I   (I 是最大值的下标, 有多个取第一个)
 * 要求: 实现 MaxByPointer, 形参是 int* 和 n, 用 *(p+i) 或 p[i] 访问
 * 禁止: 不要用下标变量当循环条件之外的东西, 必须体现指针移动
 */
int MaxByPointer(int* p, int n, int* index)
{
    int*q=p;
    int max=*q;*index=0;
    for(int i=1;i<n;i++){
        q++;
        if(*q>max){
            max=*q;
            *index=i;
        }
}
    return max;
}

int main(void)
{
    int n = 0, a[100];
    if (scanf("%d", &n) != 1 || n <= 0 || n > 100) return 0;
    for (int i = 0; i < n; ++i) scanf("%d", &a[i]);
    int idx = 0;
    int m = MaxByPointer(a, n, &idx);
    printf("max=%d index=%d\n", m, idx);
    return 0;
}