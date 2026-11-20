#include <stdio.h>

/* 题目: 用指针交换两个数
 * 输入: a b
 * 输出: a=新a b=新b   (交换后)
 * 要求: 实现 Swap, 必须通过指针修改实参 —— 这是理解指针的第一课
 * 常见错误: 只交换了形参, 忘了解引用
 */
void Swap(int* pa, int* pb)
{
    int a;int b;
  
 
  int c=0;
  c=*pa;
  *pa=*pb;
    *pb=c;
}
int main(void)
{
    int a = 0, b = 0;
    if (scanf("%d %d", &a, &b) != 2) return 0;
    Swap(&a, &b);
    printf("a=%d b=%d\n", a, b);
    return 0;
}