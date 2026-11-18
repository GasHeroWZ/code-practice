#include <stdio.h>

/* 题目: 原地反转字符串
 * 输入: 一行字符串(不含空格)
 * 输出: 反转后的字符串
 * 要求: 实现 Reverse, 必须原地修改(不能开新数组), 用前后两个指针向中间靠拢
 * 提示: char* left = s; char* right = s + len - 1; 交换后 left++ right--
 */
void Reverse(char* s)
{
    /* TODO */
    (void)s;
}

int main(void)
{
    char s[100] = {0};
    if (scanf("%99s", s) != 1) return 0;
    Reverse(s);
    printf("%s\n", s);
    return 0;
}