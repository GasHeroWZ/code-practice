#include <stdio.h>

/* 题目: 求最大公约数与最小公倍数
 * 输入: 两个正整数 a b
 * 输出: gcd=G lcm=L
 * 要求: 实现 Gcd (辗转相除) 与 Lcm (a/Gcd*b, 注意防溢出)
 * 注意: 0 的处理, 负数可直接假定不会出现
 */
int Gcd(int a, int b)
{
   int t;
   while(b!=0){
   t=b;
   b=a%b;
   a=t; 
   }
    return a;
}

int Lcm(int a, int b)
{
    return a*b/Gcd(a,b);
}

int main(void)
{
    int a = 0, b = 0;
    if (scanf("%d %d", &a, &b) != 2) return 0;
    printf("gcd=%d lcm=%d\n", Gcd(a, b), Lcm(a, b));
    return 0;
}