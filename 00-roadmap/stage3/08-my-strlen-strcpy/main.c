#include <stdio.h>

/* 题目: 手写 strlen 和 strcpy
 * 输入: 一行字符串(不含空格, 长度 < 100)
 * 输出: 两行: 长度, 复制后的字符串
 * 要求: 实现 MyStrlen 与 MyStrcpy, 不许调用标准库的同名函数
 * 提示: 判断结束用 *s == '\0'; strcpy 要返回目标起始地址
 * 注意: 字符串末尾的 '\0' 必须被复制
 */
unsigned int MyStrlen(const char* s)
{
    /* TODO */
    (void)s;
    return 0;
}

char* MyStrcpy(char* dst, const char* src)
{
    /* TODO */
    (void)src;
    return dst;
}

int main(void)
{
    char s[100] = {0};
    char t[100] = {0};
    if (scanf("%99s", s) != 1) return 0;
    MyStrcpy(t, s);
    printf("%u\n%s\n", MyStrlen(s), t);
    return 0;
}