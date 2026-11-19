#include <stdio.h>

/* 题目: 判断一个整数是否为素数
 * 要求: 实现 IsPrime, n <= 1 返回 0; 是素数返回 1; 否则返回 0
 * 提示: 只需试除到 sqrt(n) 或 i*i <= n
 * 验收: judge.ps1 全部用例通过
 */
int IsPrime(int n)
{
    /* TODO: 在这里实现 */
  
   
    if (n<=1)
    return 0;
    for(int i=2;i*i<=n;i++){
        if (n%i==0)
        return 0;
    }
    return 1;
}

int main(void)
{
    int n = 0;
    if (scanf("%d", &n) != 1) return 0;
    printf("%s\n", IsPrime(n) ? "yes" : "no");
    return 0;
}