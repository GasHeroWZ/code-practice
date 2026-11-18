#include <stdio.h>

/* 题目: 统计文件的行数与字符数
 * 输入: 一个文件名(不含空格), 例如 data.txt
 * 输出: lines=X chars=Y
 * 要求: 用 fopen 打开, fgetc 逐字符读, 统计 '\n' 的个数作为行数
 *       必须判断 fopen 是否返回 NULL, 失败时输出 open fail
 *       读完必须 fclose
 * 提示: 自己造一个 data.txt 测试, 比如 3 行文字
 */
int main(void)
{
    char name[100] = {0};
    if (scanf("%99s", name) != 1) return 0;

    FILE* f = fopen(name, "r");
    if (f == NULL) { printf("open fail\n"); return 0; }

    int lines = 0;
    long chars = 0;
    int ch = 0;
    /* TODO: 用 while ((ch = fgetc(f)) != EOF) 循环统计 */
    (void)ch;

    fclose(f);
    printf("lines=%d chars=%ld\n", lines, chars);
    return 0;
}